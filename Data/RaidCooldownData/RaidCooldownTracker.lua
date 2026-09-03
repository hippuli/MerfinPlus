-- Event-driven TBC Raid Cooldown runtime.
-- Functional source: user-supplied [Merfin] RCD [Backend] WeakAura.
-- MerfinPlus owns roster, inspect/talent eligibility, combat events and tracked
-- cooldown state. WeakAura frontends receive immutable renderer snapshots only.

local _, MerfinPlus = ...

local UPDATE_EVENT = "MERFINPLUS_RAID_COOLDOWNS_UPDATED"
local Tracker = {
  initialized = false,
  rosterUnits = {},
  activeCooldowns = {},
  rendererConfigs = {},
  inspectQueue = {},
  inspectQueued = {},
  inspectPending = nil,
  spellIDToName = {},
  spellNameToID = {},
  states = {},
  statesByRenderer = {},
  revision = 0,
  readyTimers = {},
  rosterRefreshGeneration = 0,
  lifeStates = {},
  reincarnationPending = {},
  reincarnationStarts = {},
  externalResurrections = {},
  soulstoneStates = {},
}

MerfinPlus.RaidCooldownTracker = Tracker

local CLASS_ORDER = {
  WARRIOR = 1,
  PALADIN = 2,
  HUNTER = 3,
  ROGUE = 4,
  PRIEST = 5,
  SHAMAN = 6,
  MAGE = 7,
  WARLOCK = 8,
  DRUID = 9,
}

local ROLE_BY_TREE = {
  DRUID = { 1, 1, 3 },
  PALADIN = { 3, 2, 1 },
  PRIEST = { 3, 3, 1 },
  SHAMAN = { 1, 1, 3 },
  WARRIOR = { 1, 1, 2 },
}

local UNIT_SPELL_MAP = {
  [26994] = { trackedSpellID = 26994, destName = "Unknown" },
  [17928] = { trackedSpellID = 17928 },
  [724] = { trackedSpellID = 724 },
  [20549] = { trackedSpellID = 20549 },
  [20608] = { reincarnation = true },
  [21169] = { reincarnation = true },
}

local REINCARNATION_SPELL_IDS = {
  [20608] = true,
  [21169] = true,
}

local REINCARNATION_DEDUPE_SECONDS = 5
local REINCARNATION_SETTLE_SECONDS = 0.10
local RESURRECTION_EXCLUSION_SECONDS = 15

local AURA_REMOVED_COOLDOWNS = {
  [17116] = true,
  [16188] = true,
  [16166] = true,
  [11129] = true,
  [12043] = true,
}

local RESET_COOLDOWNS = {
  [23989] = { 34477 },
  [11958] = { 45438, 12472, 11958, 31687 },
}

local SHARED_COOLDOWNS = {
  [13809] = { 14311 },
  [14311] = { 13809 },
  [27023] = { 27025 },
  [27025] = { 27023 },
  [1719] = { 20230, 871 },
  [20230] = { 1719, 871 },
  [871] = { 1719, 20230 },
}

local SOULSTONES = {
  [20707] = true,
  [20762] = true,
  [20763] = true,
  [20764] = true,
  [20765] = true,
  [27239] = true,
}

local function DeepCopy(value, seen)
  if type(value) ~= "table" then
    return value
  end
  seen = seen or {}
  if seen[value] then
    return seen[value]
  end
  local copy = {}
  seen[value] = copy
  for key, child in pairs(value) do
    copy[DeepCopy(key, seen)] = DeepCopy(child, seen)
  end
  return copy
end

local function ShortName(name)
  if type(name) ~= "string" or name == "" then
    return nil
  end
  if Ambiguate then
    return Ambiguate(name, "short")
  end
  return name:match("^[^-]+") or name
end

local function MonotonicTime()
  return GetTime and GetTime() or 0
end

local function IsRecent(timestamp, now, window)
  timestamp = tonumber(timestamp)
  if not timestamp then
    return false
  end
  return now >= timestamp and now - timestamp <= window
end

local function SpellName(spellID)
  if C_Spell and C_Spell.GetSpellName then
    return C_Spell.GetSpellName(spellID)
  end
  return GetSpellInfo(spellID)
end

local function SpellIcon(spellID)
  if C_Spell and C_Spell.GetSpellTexture then
    return C_Spell.GetSpellTexture(spellID)
  end
  return select(3, GetSpellInfo(spellID))
end

local function GetRuntimeRoot()
  if not MerfinPlus.db or not MerfinPlus.db.global then
    return nil
  end
  local trackerRoot = MerfinPlus.db.global.raidCooldownTracker
  if type(trackerRoot) ~= "table" then
    trackerRoot = {}
    MerfinPlus.db.global.raidCooldownTracker = trackerRoot
  end
  local runtime = trackerRoot.runtime
  if type(runtime) ~= "table" then
    runtime = {}
    trackerRoot.runtime = runtime
  end
  runtime.schemaVersion = 1
  runtime.roster = type(runtime.roster) == "table" and runtime.roster or {}
  runtime.revision = tonumber(runtime.revision) or 0
  return runtime
end

local function IterateGroupUnits()
  local units = {}
  if IsInRaid and IsInRaid() then
    for index = 1, GetNumGroupMembers() do
      units[#units + 1] = "raid" .. index
    end
  elseif IsInGroup and IsInGroup() then
    units[#units + 1] = "player"
    local count = GetNumSubgroupMembers and GetNumSubgroupMembers()
      or math.max(0, (GetNumGroupMembers() or 1) - 1)
    for index = 1, count do
      units[#units + 1] = "party" .. index
    end
  else
    units[1] = "player"
  end
  return units
end

local function GetSubGroup(unitID, unitName)
  if not (IsInRaid and IsInRaid()) then
    return 1
  end
  for index = 1, GetNumGroupMembers() do
    local rosterName, _, subgroup = GetRaidRosterInfo(index)
    if ShortName(rosterName) == unitName or unitID == "raid" .. index then
      return subgroup or 1
    end
  end
  return 1
end

local function TalentRank(unitData, tab, row, column)
  local talents = unitData and unitData.talents
  return talents
    and talents[tab]
    and talents[tab][row]
    and talents[tab][row][column]
    or 0
end

local function SpecMatches(requiredSpec, currentSpec)
  if not requiredSpec then
    return true
  end
  if type(requiredSpec) == "table" then
    for _, specID in ipairs(requiredSpec) do
      if specID == currentSpec then
        return true
      end
    end
    return false
  end
  return requiredSpec == currentSpec
end

local function CooldownReduction(data, unitData)
  local reduction = 0
  if not data.minus then
    return reduction
  end
  for index = 1, #(data.minusTabIndex or {}) do
    local rank = TalentRank(
      unitData,
      data.minusTabIndex[index],
      data.minusTalentRow[index],
      data.minusTalentColumn[index]
    )
    local perPoint = data.minusPerPoint[index]
    if type(perPoint) == "table" then
      for point = 1, rank do
        reduction = reduction + (tonumber(perPoint[point]) or 0)
      end
    else
      reduction = reduction + rank * (tonumber(perPoint) or 0)
    end
  end
  return reduction
end

function Tracker:GetDefinition()
  return MerfinPlus:GetRaidCooldownTrackerExpansion()
end

function Tracker:GetRoster()
  local runtime = GetRuntimeRoot()
  return runtime and runtime.roster or {}
end

function Tracker:BuildSpellLookup()
  self.spellIDToName = {}
  self.spellNameToID = {}
  local definition = self:GetDefinition()
  for _, spells in pairs(definition and definition.spellData or {}) do
    for spellID in pairs(spells) do
      local name = SpellName(spellID)
      if name then
        self.spellIDToName[spellID] = name
        self.spellNameToID[name] = spellID
      end
    end
  end
end

function Tracker:BuildActiveConfig()
  self.activeCooldowns = {}
  self.rendererConfigs = {}

  local definition = self:GetDefinition()
  local catalog = definition and definition.spellData or {}
  local trackerState = MerfinPlus:EnsureRaidCooldownTrackerState()
  if not definition or not trackerState then
    return
  end

  for _, rendererKey in ipairs(definition.rendererOrder or {}) do
    local rendererState = trackerState.renderers[rendererKey]
    if rendererState and rendererState.enabled == true then
      local config = rendererState.config
      self.rendererConfigs[rendererKey] = config
      for className, entries in pairs(config.cds or {}) do
        for rawSpellID, enabled in pairs(entries) do
          local spellID = tonumber(rawSpellID)
          if enabled
            and spellID
            and catalog[className]
            and catalog[className][spellID]
          then
            self.activeCooldowns[className] = self.activeCooldowns[className] or {}
            self.activeCooldowns[className][spellID] = true
          end
        end
      end
    end
  end
end

local function BuildRendererFilters(config)
  local advancedRoles = {}
  local customOrder = {}
  for _, entry in ipairs(config.advanced and config.advanced.display or {}) do
    local spellID = tonumber(entry.spellID)
    if spellID then
      advancedRoles[spellID] = {
        entry.dps == true,
        entry.tank == true,
        entry.healer == true,
      }
    end
  end

  for _, entry in ipairs(config.advanced and config.advanced.order or {}) do
    local spellID = tonumber(entry.spellID)
    if spellID then
      customOrder[spellID] = math.max(1, math.floor(tonumber(entry.index) or 1))
    end
  end
  return advancedRoles, customOrder
end

function Tracker:ApplyCooldownEligibility(unitName)
  local roster = self:GetRoster()
  local unitData = roster[unitName]
  local definition = self:GetDefinition()
  local classSpells = definition
    and definition.spellData
    and unitData
    and definition.spellData[unitData.className]
  local enabled = unitData and self.activeCooldowns[unitData.className]
  if not unitData or not classSpells or not enabled then
    return false
  end

  unitData.cds = type(unitData.cds) == "table" and unitData.cds or {}
  local changed = false
  for spellID in pairs(enabled) do
    local data = classSpells[spellID]
    local raceAllowed = not data.raceReq
      or (unitData.race and data.race and data.race[unitData.race])
    local talentAllowed = not data.tReq
      or (unitData.talents
        and TalentRank(unitData, data.tabIndex, data.talentRow, data.talentColumn) > 0)
    local specAllowed = not (MerfinPlus.IsMoP and MerfinPlus:IsMoP())
      or SpecMatches(data.spec, unitData.spec)

    if raceAllowed and talentAllowed and specAllowed then
      local duration = math.max(0, (tonumber(data.dur) or 0) - CooldownReduction(data, unitData))
      local cooldown = unitData.cds[spellID]
      if not cooldown then
        cooldown = {}
        unitData.cds[spellID] = cooldown
        changed = true
      end
      if cooldown.dur ~= duration then
        cooldown.dur = duration
        changed = true
      end
    elseif unitData.cds[spellID] then
      unitData.cds[spellID] = nil
      changed = true
    end
  end
  return changed
end

function Tracker:UpdateUnitInfo(unitID, rosterIndex)
  if not UnitExists(unitID) then
    return nil, false
  end
  local unitName = ShortName(UnitName(unitID))
  local _, className = UnitClass(unitID)
  if not unitName or not className or unitName == (UNKNOWNOBJECT or "Unknown") then
    return nil, false
  end

  local roster = self:GetRoster()
  local unitData = roster[unitName]
  local changed = false
  if type(unitData) ~= "table" then
    unitData = {}
    roster[unitName] = unitData
    changed = true
  end

  local _, race = UnitRace(unitID)
  local values = {
    className = className,
    race = race,
    connected = UnitIsConnected(unitID) == true,
    subGroup = GetSubGroup(unitID, unitName),
    rosterIndex = tonumber(rosterIndex) or math.huge,
  }
  for key, value in pairs(values) do
    if unitData[key] ~= value then
      unitData[key] = value
      changed = true
    end
  end
  unitData.role = tonumber(unitData.role) or 1
  unitData.cds = type(unitData.cds) == "table" and unitData.cds or {}
  self.rosterUnits[unitName] = unitID

  if self:UpdateUnitLifeState(unitID, unitName, unitData) then
    changed = true
  end

  if self:ApplyCooldownEligibility(unitName) then
    changed = true
  end
  return unitName, changed
end

function Tracker:RefreshRoster()
  local present = {}
  local changed = false
  self.rosterUnits = {}

  for rosterIndex, unitID in ipairs(IterateGroupUnits()) do
    local unitName, unitChanged = self:UpdateUnitInfo(unitID, rosterIndex)
    if unitName then
      present[unitName] = true
      changed = unitChanged or changed
    end
  end

  local roster = self:GetRoster()
  for unitName in pairs(roster) do
    if not present[unitName] then
      roster[unitName] = nil
      self.inspectQueued[unitName] = nil
      self.lifeStates[unitName] = nil
      self.reincarnationPending[unitName] = nil
      self.reincarnationStarts[unitName] = nil
      self.externalResurrections[unitName] = nil
      self.soulstoneStates[unitName] = nil
      changed = true
    end
  end

  for unitName, unitID in pairs(self.rosterUnits) do
    if unitID == "player" then
      if self:ReadTalents(unitName, false) then
        changed = true
      end
    elseif not roster[unitName].talents
      or not roster[unitName].lastInspect
      or GetTime() - roster[unitName].lastInspect > 5
    then
      self:QueueInspect(unitName)
    end
  end
  self:TryInspect()
  return changed
end

function Tracker:ReadTalents(unitName, isInspect)
  local roster = self:GetRoster()
  local unitData = roster[unitName]
  if not unitData then
    return false
  end

  if MerfinPlus.IsMoP and MerfinPlus:IsMoP() then
    local specializationAPI = C_SpecializationInfo
    local getSpecialization = specializationAPI and specializationAPI.GetSpecialization
      or GetSpecialization
    local getSpecializationInfo = specializationAPI
      and specializationAPI.GetSpecializationInfo
      or GetSpecializationInfo
    local getSpecializationInfoByID = specializationAPI
      and specializationAPI.GetSpecializationInfoByID
      or GetSpecializationInfoByID
    local unitID = self.rosterUnits[unitName]
    local specializationID
    if isInspect and unitID and GetInspectSpecialization then
      specializationID = GetInspectSpecialization(unitID)
    elseif getSpecialization and getSpecializationInfo then
      local specializationIndex = getSpecialization()
      if specializationIndex then
        specializationID = getSpecializationInfo(specializationIndex)
      end
    end
    specializationID = tonumber(specializationID) or nil
    if specializationID and specializationID <= 0 then
      specializationID = nil
    end

    local role = 1
    if specializationID and getSpecializationInfoByID then
      local _, _, _, _, roleToken = getSpecializationInfoByID(specializationID)
      role = roleToken == "TANK" and 2
        or roleToken == "HEALER" and 3
        or 1
    end

    local talents = {}
    local getTalentInfo = specializationAPI and specializationAPI.GetTalentInfo
    if getTalentInfo then
      for tier = 1, 6 do
        for column = 1, 3 do
          local talentInfo = getTalentInfo({
            tier = tier,
            column = column,
            isInspect = isInspect == true,
            target = unitID,
          })
          if type(talentInfo) == "table" and talentInfo.selected then
            talents[tier] = talents[tier] or {}
            talents[tier][column] = talentInfo.selected
          end
        end
      end
    end

    local previous = unitData.talents
    unitData.talents = talents
    unitData.spec = specializationID or unitData.spec
    unitData.lastInspect = GetTime()
    local changed = previous == nil or unitData.role ~= role
    unitData.role = role
    return self:ApplyCooldownEligibility(unitName) or changed
  end

  local talents = {}
  local activeGroup = GetActiveTalentGroup and GetActiveTalentGroup(isInspect) or 1
  local tabCount = GetNumTalentTabs and GetNumTalentTabs() or 0
  for tabIndex = 1, tabCount do
    talents[tabIndex] = {}
    local talentCount = GetNumTalents(tabIndex, activeGroup) or 0
    for talentIndex = 1, talentCount do
      local name, _, row, column, rank = GetTalentInfo(
        tabIndex,
        talentIndex,
        isInspect,
        false,
        activeGroup
      )
      if name and rank and rank > 0 then
        talents[tabIndex][row] = talents[tabIndex][row] or {}
        talents[tabIndex][row][column] = rank
      end
    end
  end

  local previous = unitData.talents
  unitData.talents = talents
  unitData.lastInspect = GetTime()

  local tabTotals = { 0, 0, 0 }
  for tabIndex, rows in pairs(talents) do
    for _, columns in pairs(rows) do
      for _, rank in pairs(columns) do
        tabTotals[tabIndex] = (tabTotals[tabIndex] or 0) + rank
      end
    end
  end
  local bestTree, bestPoints = 1, -1
  for tabIndex = 1, 3 do
    if (tabTotals[tabIndex] or 0) > bestPoints then
      bestTree, bestPoints = tabIndex, tabTotals[tabIndex] or 0
    end
  end
  local roleMap = ROLE_BY_TREE[unitData.className]
  local role = roleMap and roleMap[bestTree] or 1
  local changed = previous == nil or unitData.role ~= role
  unitData.role = role
  return self:ApplyCooldownEligibility(unitName) or changed
end

function Tracker:IsInspectable(unitID)
  if not unitID or unitID == "player" or not UnitExists(unitID) then
    return false
  end
  if not UnitIsConnected(unitID) or UnitCanAttack("player", unitID) then
    return false
  end
  if UnitAffectingCombat("player") or (InCombatLockdown and InCombatLockdown()) then
    return false
  end
  if UnitIsVisible and not UnitIsVisible(unitID) then
    return false
  end
  -- Inspect has a shorter interaction range than ordinary visibility.  Do not
  -- call NotifyInspect outside that range: Blizzard can emit an "out of
  -- range" error/voice line even for a valid raid member.  This matches the
  -- original RCD backend guard and intentionally fails closed if the client
  -- does not expose the interaction-distance API.
  if not CheckInteractDistance or not CheckInteractDistance(unitID, 4) then
    return false
  end
  return not CanInspect or CanInspect(unitID)
end

function Tracker:QueueInspect(unitName)
  if not unitName or self.inspectQueued[unitName] or self.inspectPending == unitName then
    return
  end
  self.inspectQueued[unitName] = true
  self.inspectQueue[#self.inspectQueue + 1] = unitName
end

function Tracker:TryInspect()
  if self.inspectPending or UnitAffectingCombat("player") then
    return
  end
  local attempts = #self.inspectQueue
  for _ = 1, attempts do
    local unitName = table.remove(self.inspectQueue, 1)
    self.inspectQueued[unitName] = nil
    local unitID = self.rosterUnits[unitName]
    if self:IsInspectable(unitID) then
      self.inspectPending = unitName
      NotifyInspect(unitID)
      C_Timer.After(2, function()
        if Tracker.inspectPending == unitName then
          Tracker.inspectPending = nil
          Tracker:TryInspect()
        end
      end)
      return
    end
    if unitID and self:GetRoster()[unitName] then
      self:QueueInspect(unitName)
    end
  end
end

function Tracker:QueueStaleInspects()
  for unitName, unitID in pairs(self.rosterUnits) do
    local unitData = self:GetRoster()[unitName]
    if unitID ~= "player"
      and unitData
      and (not unitData.lastInspect or GetTime() - unitData.lastInspect > 5)
    then
      self:QueueInspect(unitName)
    end
  end
end

function Tracker:OnInspectReady(guid)
  local unitName = self.inspectPending
  local unitID = unitName and self.rosterUnits[unitName]
  if not unitName or not unitID or (guid and UnitGUID(unitID) ~= guid) then
    return false
  end
  local changed = self:ReadTalents(unitName, true)
  self.inspectPending = nil
  if ClearInspectPlayer then
    ClearInspectPlayer()
  end
  C_Timer.After(0, function()
    Tracker:TryInspect()
  end)
  return changed
end

function Tracker:ResolveReincarnationSpellID(unitData)
  local cooldowns = unitData and unitData.cds
  if type(cooldowns) ~= "table" then
    return nil
  end

  local isMoP = MerfinPlus.IsMoP and MerfinPlus:IsMoP()
  if isMoP and cooldowns[20608] then
    return 20608
  elseif not isMoP and cooldowns[21169] then
    return 21169
  end
  if cooldowns[20608] then
    return 20608
  elseif cooldowns[21169] then
    return 21169
  end
  return nil
end

function Tracker:StartReincarnationCooldown(unitName, reason)
  local unitData = unitName and self:GetRoster()[unitName]
  if not unitData or unitData.className ~= "SHAMAN" then
    return false
  end

  local spellID = self:ResolveReincarnationSpellID(unitData)
  local cooldown = spellID and unitData.cds and unitData.cds[spellID]
  if not cooldown or not cooldown.dur then
    return false
  end

  -- Reincarnation cannot legitimately be used while it is already cooling
  -- down. This also makes CLEU, unit-spellcast and dead-to-alive signals
  -- idempotent instead of moving the same expiration forward more than once.
  if tonumber(cooldown.expTimeOS) and cooldown.expTimeOS > time() + 1 then
    return false
  end

  local now = MonotonicTime()
  local previous = self.reincarnationStarts[unitName]
  if previous
    and previous.spellID == spellID
    and IsRecent(previous.at, now, REINCARNATION_DEDUPE_SECONDS)
  then
    return false
  end

  if not self:SetCooldown(unitName, spellID) then
    return false
  end
  self.reincarnationStarts[unitName] = {
    at = now,
    spellID = spellID,
    reason = reason,
  }
  return true
end

function Tracker:UnitHasSoulstone(unitID)
  if not unitID or not UnitExists(unitID) or not UnitBuff then
    return false
  end
  for index = 1, 40 do
    local aura = { UnitBuff(unitID, index) }
    if not aura[1] then
      break
    end
    local spellID = tonumber(aura[10]) or tonumber(aura[11])
    if spellID and SOULSTONES[spellID] then
      return true
    end
  end
  return false
end

function Tracker:RecordSoulstoneAura(unitName, applied)
  if not unitName then
    return
  end
  local state = self.soulstoneStates[unitName] or {}
  self.soulstoneStates[unitName] = state
  if applied then
    state.active = true
    state.removedAt = nil
  else
    state.active = nil
    state.removedAt = MonotonicTime()
  end
end

function Tracker:RecordExternalResurrection(sourceName, destName)
  if sourceName and destName and sourceName ~= destName then
    local lifeState = self.lifeStates[destName]
    self.externalResurrections[destName] = {
      at = MonotonicTime(),
      generation = lifeState and lifeState.dead and lifeState.generation or nil,
    }
  end
end

function Tracker:GetUnitLifeState(unitName, unitData)
  local state = self.lifeStates[unitName]
  if state then
    return state
  end
  local initiallyDead = unitData and unitData.dead == true
  state = {
    dead = initiallyDead,
    seenAlive = not initiallyDead,
    ghostSeen = false,
    generation = 0,
  }
  self.lifeStates[unitName] = state
  return state
end

function Tracker:RecordUnitDeath(unitName, ghost)
  local unitData = unitName and self:GetRoster()[unitName]
  if not unitData then
    return false
  end

  local state = self:GetUnitLifeState(unitName, unitData)
  local changed = unitData.dead ~= true
  if not state.dead then
    state.generation = (tonumber(state.generation) or 0) + 1
    state.diedAt = MonotonicTime()
    state.sawAliveBeforeDeath = state.seenAlive == true
    state.ghostSeen = ghost == true
    local soulstone = self.soulstoneStates[unitName]
    state.soulstoneAtDeath = (soulstone and soulstone.active == true)
      or (soulstone and IsRecent(soulstone.removedAt, state.diedAt, RESURRECTION_EXCLUSION_SECONDS))
      or self:UnitHasSoulstone(self.rosterUnits[unitName])
  elseif ghost then
    state.ghostSeen = true
  end
  state.dead = true
  unitData.dead = true
  return changed
end

function Tracker:QueueReincarnationTransition(unitName, generation)
  self.reincarnationPending[unitName] = generation

  local function evaluate()
    if Tracker.reincarnationPending[unitName] ~= generation then
      return
    end
    Tracker.reincarnationPending[unitName] = nil

    local unitData = Tracker:GetRoster()[unitName]
    local state = Tracker.lifeStates[unitName]
    local now = MonotonicTime()
    local external = Tracker.externalResurrections[unitName]
    local externalAt = external and external.at
    local soulstone = Tracker.soulstoneStates[unitName]
    local externallyResurrected = state
      and state.diedAt
      and external
      and ((external.generation and external.generation == state.generation)
        or (externalAt
          and externalAt >= state.diedAt - 1
          and IsRecent(externalAt, now, RESURRECTION_EXCLUSION_SECONDS)))
    local usedSoulstone = state
      and (state.soulstoneAtDeath
        or (soulstone and soulstone.active == true)
        or (soulstone and IsRecent(soulstone.removedAt, now, RESURRECTION_EXCLUSION_SECONDS)))

    local shouldStart = unitData
      and unitData.className == "SHAMAN"
      and unitData.dead ~= true
      and state
      and state.sawAliveBeforeDeath == true
      and state.ghostSeen ~= true
      and not externallyResurrected
      and not usedSoulstone

    Tracker.externalResurrections[unitName] = nil
    Tracker.soulstoneStates[unitName] = nil
    if state then
      state.diedAt = nil
      state.sawAliveBeforeDeath = nil
      state.soulstoneAtDeath = nil
      state.ghostSeen = false
    end

    if shouldStart and Tracker:StartReincarnationCooldown(unitName, "dead-to-alive") then
      Tracker:Emit("reincarnation-dead-to-alive")
    end
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(REINCARNATION_SETTLE_SECONDS, evaluate)
  else
    evaluate()
  end
end

function Tracker:UpdateUnitLifeState(unitID, unitName, unitData)
  if not unitID or not unitName or not unitData then
    return false
  end

  local dead = UnitIsDeadOrGhost(unitID) == true
  local ghost = UnitIsGhost and UnitIsGhost(unitID) == true or false
  local changed = unitData.dead ~= dead
  local state = self.lifeStates[unitName]
  if not state then
    self.lifeStates[unitName] = {
      dead = dead,
      seenAlive = not dead,
      ghostSeen = ghost,
      generation = 0,
    }
    unitData.dead = dead
    return changed
  end

  if dead then
    changed = self:RecordUnitDeath(unitName, ghost) or changed
  else
    local resurrected = state.dead == true
    state.dead = false
    state.seenAlive = true
    unitData.dead = false
    if resurrected then
      self:QueueReincarnationTransition(unitName, state.generation)
    end
  end
  return changed
end

function Tracker:ScheduleCooldownReady(unitName, spellID, cooldown)
  local expirationOS = cooldown and tonumber(cooldown.expTimeOS)
  local remaining = expirationOS and expirationOS - time() or 0
  if remaining <= 0 then
    return
  end

  local timerKey = unitName .. "\031" .. tostring(spellID)
  if self.readyTimers[timerKey] == expirationOS then
    return
  end
  self.readyTimers[timerKey] = expirationOS

  local function refreshWhenReady()
    if Tracker.readyTimers[timerKey] ~= expirationOS then
      return
    end

    local unitData = Tracker:GetRoster()[unitName]
    local current = unitData and unitData.cds and unitData.cds[spellID]
    if not current or tonumber(current.expTimeOS) ~= expirationOS then
      Tracker.readyTimers[timerKey] = nil
      return
    end

    local secondsUntilReady = expirationOS - time()
    if secondsUntilReady > 0 then
      -- `time()` is whole-second precision while C_Timer is not.  Do not
      -- discard the only ready refresh when the timer wakes up a fraction of
      -- a second before the tracked cooldown has actually elapsed.
      C_Timer.After(secondsUntilReady + 0.05, refreshWhenReady)
      return
    end

    Tracker.readyTimers[timerKey] = nil
    Tracker:Emit("cooldown-ready")
  end

  C_Timer.After(remaining + 0.05, refreshWhenReady)
end

function Tracker:SetCooldown(unitName, spellID, destName)
  local unitData = self:GetRoster()[unitName]
  local cooldown = unitData and unitData.cds and unitData.cds[spellID]
  if not cooldown or not cooldown.dur then
    return false
  end
  cooldown.expTimeOS = time() + cooldown.dur
  cooldown.destName = destName
  self:ScheduleCooldownReady(unitName, spellID, cooldown)
  return true
end

function Tracker:ResetCooldown(unitName, spellID)
  local unitData = self:GetRoster()[unitName]
  local cooldown = unitData and unitData.cds and unitData.cds[spellID]
  if not cooldown then
    return false
  end
  cooldown.expTimeOS = time()
  self.readyTimers[unitName .. "\031" .. tostring(spellID)] = nil
  return true
end

function Tracker:FindUnitBuff(unitName, spellID)
  local unitID = self.rosterUnits[unitName]
  if not unitID or not UnitExists(unitID) then
    return nil
  end
  local expectedName = self.spellIDToName[spellID]
  for index = 1, 40 do
    local aura = { UnitBuff(unitID, index) }
    local name = aura[1]
    if not name then
      break
    end
    local duration = tonumber(aura[5])
    local expirationTime = tonumber(aura[6])
    local auraSpellID = tonumber(aura[10]) or tonumber(aura[11])
    -- Older Classic signatures include a rank field after the aura name.
    if not duration or not expirationTime then
      duration = tonumber(aura[6])
      expirationTime = tonumber(aura[7])
    end
    if auraSpellID == spellID or name == expectedName then
      return duration, expirationTime
    end
  end
end

function Tracker:AddCooldownBuff(unitName, spellID, destName)
  local unitData = self:GetRoster()[unitName]
  local cooldown = unitData and unitData.cds and unitData.cds[spellID]
  if not cooldown then
    return false
  end

  if spellID == 34477 then
    cooldown.destName = destName or cooldown.destName
    cooldown.threatBuff = true
    return true
  end

  local duration, expirationTime = self:FindUnitBuff(destName, spellID)
  if not duration or not expirationTime then
    return false
  end
  cooldown.buffDuration = duration
  cooldown.buffExpirationTimeOS = time() + duration
  cooldown.isBuff = true
  C_Timer.After(math.max(0, expirationTime - GetTime()), function()
    local current = Tracker:GetRoster()[unitName]
    current = current and current.cds and current.cds[spellID]
    if current and current.isBuff then
      current.isBuff = false
      Tracker:Emit("buff-expired")
    end
  end)
  return true
end

function Tracker:HandleCombatLog()
  local info = { CombatLogGetCurrentEventInfo() }
  local subEvent = info[2]
  local sourceName = ShortName(info[5])
  local destName = ShortName(info[9])
  local spellID = tonumber(info[12])
  local spellName = info[13]

  if spellID and SOULSTONES[spellID] and destName then
    if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
      self:RecordSoulstoneAura(destName, true)
    elseif subEvent == "SPELL_AURA_REMOVED" then
      self:RecordSoulstoneAura(destName, false)
    end
  end
  if subEvent == "SPELL_RESURRECT" then
    self:RecordExternalResurrection(sourceName, destName)
  elseif subEvent == "UNIT_DIED" then
    return self:RecordUnitDeath(destName, false)
  end

  local unitData = sourceName and self:GetRoster()[sourceName]
  if not unitData then
    return false
  end

  local changed = false
  local resetList = spellID and RESET_COOLDOWNS[spellID]
  if subEvent == "SPELL_CAST_SUCCESS" and resetList then
    for _, resetSpellID in ipairs(resetList) do
      changed = self:ResetCooldown(sourceName, resetSpellID) or changed
    end
  end

  local sharedList = spellID and SHARED_COOLDOWNS[spellID]
  if subEvent == "SPELL_CAST_SUCCESS" and sharedList then
    for _, sharedSpellID in ipairs(sharedList) do
      changed = self:SetCooldown(sourceName, sharedSpellID, destName) or changed
    end
  end

  if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH")
    and spellID
    and SOULSTONES[spellID]
  then
    changed = self:SetCooldown(sourceName, 27239, destName) or changed
  end


  if REINCARNATION_SPELL_IDS[spellID]
    and (subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_RESURRECT")
  then
    return self:StartReincarnationCooldown(sourceName, "combat-log") or changed
  end

  local trackedSpellID
  if spellID and unitData.cds and unitData.cds[spellID] then
    trackedSpellID = spellID
  elseif spellName then
    local mapped = self.spellNameToID[spellName]
    if mapped and unitData.cds and unitData.cds[mapped] then
      trackedSpellID = mapped
    end
  end
  if not trackedSpellID then
    return changed
  end

  if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
    if trackedSpellID ~= 34477 then
      changed = self:AddCooldownBuff(sourceName, trackedSpellID, destName) or changed
    end
  elseif subEvent == "SPELL_CAST_SUCCESS" then
    if trackedSpellID == 34477 then
      changed = self:SetCooldown(sourceName, trackedSpellID, destName) or changed
      local cooldown = unitData.cds[trackedSpellID]
      cooldown.isBuff = false
      cooldown.buffDuration = nil
      cooldown.buffExpirationTimeOS = nil
      cooldown.threatBuff = true
      cooldown.destName = destName or cooldown.destName
    elseif not AURA_REMOVED_COOLDOWNS[trackedSpellID]
      and (spellName ~= self.spellIDToName[6795] or spellID == 6795)
    then
      changed = self:SetCooldown(sourceName, trackedSpellID, destName) or changed
    end
  elseif subEvent == "SPELL_AURA_REMOVED" then
    if trackedSpellID == 34477 then
      local cooldown = unitData.cds[trackedSpellID]
      cooldown.isBuff = false
      cooldown.threatBuff = false
      changed = true
    elseif AURA_REMOVED_COOLDOWNS[trackedSpellID] then
      changed = self:SetCooldown(sourceName, trackedSpellID, destName) or changed
    end
  elseif subEvent == "SPELL_RESURRECT" then
    changed = self:SetCooldown(sourceName, trackedSpellID, destName) or changed
  end
  return changed
end

function Tracker:HandleUnitSpellcast(unitID, spellID)
  local mapping = UNIT_SPELL_MAP[tonumber(spellID)]
  local unitName = mapping and ShortName(UnitName(unitID))
  if not mapping or not unitName then
    return false
  end
  if mapping.reincarnation then
    return self:StartReincarnationCooldown(unitName, "unit-spellcast")
  end
  return self:SetCooldown(unitName, mapping.trackedSpellID, mapping.destName)
end

function Tracker:RefreshUnitConditions(unitID)
  local unitName = ShortName(UnitName(unitID))
  local unitData = unitName and self:GetRoster()[unitName]
  if not unitData then
    return false
  end
  local connected = UnitIsConnected(unitID) == true
  local changed = unitData.connected ~= connected
  unitData.connected = connected
  changed = self:UpdateUnitLifeState(unitID, unitName, unitData) or changed
  return changed
end

function Tracker:ResetEncounterCooldowns()
  local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
  if instanceType and maxPlayers and maxPlayers < 10 then
    return false
  end
  local changed = false
  for unitName, unitData in pairs(self:GetRoster()) do
    if unitData.className == "SHAMAN" then
      changed = self:ResetCooldown(unitName, 2825) or changed
      changed = self:ResetCooldown(unitName, 32182) or changed
    end
  end
  return changed
end

function Tracker:IsUnitVisible(unitName, unitData, config)
  local playerName = ShortName(UnitName("player"))
  if unitName == playerName and not config.display.showMyself then
    return false
  end
  if unitData.dead and not config.display.showDead then
    return false
  end
  if not unitData.connected and not config.display.showOffline then
    return false
  end
  return (tonumber(unitData.subGroup) or 1) <= (tonumber(config.display.raidSubGroups) or 8)
end

function Tracker:BuildRendererStates(rendererKey, config)
  local definition = self:GetDefinition()
  local states = {}
  if not definition or not config then
    return states
  end

  local advancedRoles, customOrder = BuildRendererFilters(config)
  local nowOS = time()
  local now = GetTime()
  for unitName, unitData in pairs(self:GetRoster()) do
    local enabled = config.cds and config.cds[unitData.className]
    local classCatalog = definition.spellData[unitData.className]
    if enabled and classCatalog and self:IsUnitVisible(unitName, unitData, config) then
      for rawSpellID, isEnabled in pairs(enabled) do
        local spellID = tonumber(rawSpellID)
        local cooldown = unitData.cds and unitData.cds[spellID]
        local spellDefinition = classCatalog[spellID]
        if isEnabled == true and cooldown and spellDefinition then
          local remaining = math.max(0, (tonumber(cooldown.expTimeOS) or nowOS) - nowOS)
          local buffRemaining = math.max(
            0,
            (tonumber(cooldown.buffExpirationTimeOS) or nowOS) - nowOS
          )
          local isBuff = cooldown.isBuff == true and buffRemaining > 0
          -- The Bars frontend uses a non-positive expiration time as its
          -- ready-state contract.  Sending the current (positive) GetTime()
          -- value here keeps its cooldown desaturation condition active until
          -- WeakAuras is rebuilt by /wa or /reload.
          local isReady = not isBuff and remaining <= 0
          local roleFilter = advancedRoles[spellID]
          -- An explicitly activated taunt must be visible regardless of the
          -- roster role. The imported advanced defaults mark taunts as
          -- tank-only, which hid active off-role taunts from Bars and Taunts.
          local roleAllowed = spellDefinition.roleIndependent == true
            or not roleFilter
            or roleFilter[tonumber(unitData.role) or 1]
          local readyAllowed = config.display.showReady or remaining > 0
          local buffAllowed = not isBuff or config.display.showBuff
          if remaining > 0 then
            self:ScheduleCooldownReady(unitName, spellID, cooldown)
          end
          if roleAllowed and readyAllowed and buffAllowed then
            local duration = isBuff and config.display.showBuff
              and (tonumber(cooldown.buffDuration) or buffRemaining)
              or (tonumber(cooldown.dur) or 0)
            local expirationTime = isBuff and config.display.showBuff
              and (now + buffRemaining)
              or (remaining > 0 and (now + remaining) or 0)
            local stateKey = unitName .. tostring(spellID)
            states[stateKey] = {
              progressType = "timed",
              duration = duration,
              expirationTime = expirationTime,
              ready = isReady,
              icon = SpellIcon(spellID),
              show = true,
              changed = true,
              autoHide = not config.display.showReady or nil,
              srcName = unitName,
              className = unitData.className,
              role = unitData.role,
              dead = unitData.dead,
              subGroup = unitData.subGroup,
              connected = unitData.connected,
              destName = cooldown.destName,
              isDestName = cooldown.destName ~= nil and cooldown.destName ~= "",
              threatBuff = cooldown.threatBuff or false,
              isBuff = isBuff,
              unit = unitName,
              classIndex = CLASS_ORDER[unitData.className],
              spellIndex = spellDefinition.index,
              unitIndex = tonumber(unitData.rosterIndex) or math.huge,
              sortName = unitName,
              advancedIndex = customOrder[spellID] or false,
              customOrder = config.advanced and config.advanced.customOrder or false,
              spellId = spellID,
              spellName = SpellName(spellID),
            }
          end
        end
      end
    end
  end
  return states
end

function Tracker:BuildStates()
  local definition = self:GetDefinition()
  self.statesByRenderer = {}
  if not definition then
    self.states = {}
    return
  end
  for _, rendererKey in ipairs(definition.rendererOrder or {}) do
    local config = self.rendererConfigs[rendererKey]
    self.statesByRenderer[rendererKey] = config
      and self:BuildRendererStates(rendererKey, config)
      or {}
  end
  self.states = self.statesByRenderer[definition.defaultRendererKey] or {}
end

function Tracker:RefreshAuraBarReadyVisuals()
  if not (WeakAuras and WeakAuras.GetRegion) then
    return
  end

  local definition = self:GetDefinition()
  if not definition then
    return
  end

  for _, rendererKey in ipairs(definition.rendererOrder or {}) do
    local renderer = definition.renderers and definition.renderers[rendererKey]
    if renderer and renderer.regionType == "aurabar" then
      local config = self.rendererConfigs[rendererKey]
      local showReadySymbol = config
        and config.display
        and config.display.showReadySymbol == true
      local states = self.statesByRenderer[rendererKey] or {}
      for stateKey, state in pairs(states) do
        local region = WeakAuras.GetRegion(renderer.frontendID, stateKey)
        -- The supplied Bars frontend stores its ready checkmark in subregion
        -- 11.  Its conditional visibility is not refreshed reliably after a
        -- custom state update, so mirror the same ready state explicitly.
        local readyMarker = region and region.subRegions and region.subRegions[11]
        if readyMarker then
          if state.ready and showReadySymbol then
            readyMarker:Show()
          else
            readyMarker:Hide()
          end
        end
        local presentation = renderer.presentation or {}
        local classColor = state.className
          and RAID_CLASS_COLORS
          and RAID_CLASS_COLORS[state.className]
        local barColorMode = presentation.barColorMode
        if not renderer.presentation and state.ready then
          -- Expansion catalogs without an explicit presentation contract keep
          -- the legacy ready-state class color until they opt into one.
          barColorMode = "class"
        end
        -- Preserve the supplied frontends' dead and active-buff colors. For
        -- ordinary cooldown/ready states, apply the renderer's explicit
        -- presentation contract after WeakAuras has evaluated conditions.
        -- This keeps the Dark Theme neutral even when ready while the other
        -- AuraBar frontends retain their class-colored bars.
        if region and not state.dead and not state.isBuff then
          local barColor = barColorMode == "fixed"
            and presentation.barColor
            or barColorMode == "class" and classColor
            or nil
          if barColor and region.Color then
            region:Color(
              barColor.r or barColor[1],
              barColor.g or barColor[2],
              barColor.b or barColor[3],
              barColor.a or barColor[4] or 1
            )
          end
        end
        if presentation.sourceNameColorMode == "class" and classColor then
          for _, subRegionIndex in ipairs(presentation.sourceNameSubRegions or {}) do
            local nameRegion = region
              and region.subRegions
              and region.subRegions[subRegionIndex]
            if nameRegion and nameRegion.Color then
              nameRegion:Color(
                classColor.r,
                classColor.g,
                classColor.b,
                classColor.a or 1
              )
            end
          end
        end
        if state.ready then
          if region and region.SetIconDesaturated then
            region:SetIconDesaturated(false)
          end
        end
      end
    end
  end
end

function Tracker:QueueRosterReconciliation(reason)
  self.rosterRefreshGeneration = (tonumber(self.rosterRefreshGeneration) or 0) + 1
  local generation = self.rosterRefreshGeneration

  local function schedule(delay, suffix)
    C_Timer.After(delay, function()
      if not Tracker.initialized
        or Tracker.rosterRefreshGeneration ~= generation
      then
        return
      end
      -- Unit/class/raid-roster APIs can settle after GROUP_ROSTER_UPDATE.
      -- Re-read them at three bounded points and publish a fresh revision
      -- even when the cache comparison reports no difference. Frontends use
      -- that revision to reconcile missing and newly eligible clones.
      Tracker:RefreshRoster()
      Tracker:Emit(reason .. suffix)
    end)
  end

  -- Generation guards coalesce event bursts. There is no OnUpdate or ticker,
  -- so the expensive all-renderer snapshot rebuild remains strictly bounded.
  schedule(0, "")
  schedule(0.10, "-settle-0.1")
  schedule(1.00, "-settle-1.0")
end

function Tracker:RestoreAuraBarReadyVisualsAfterWeakAurasOptions()
  if self.weakAurasOptionsRefreshPending then
    return
  end
  self.weakAurasOptionsRefreshPending = true

  -- WeakAuras finishes rebuilding its trigger regions after its Options
  -- window closes. Deliver one new snapshot after that rebuild, then apply
  -- the marker correction to the new clones. This is a bounded close-event
  -- recovery, not an idle refresh loop.
  C_Timer.After(0.10, function()
    if Tracker.initialized then
      Tracker:Emit("weakauras-options-closed")
    end
  end)
  C_Timer.After(0.35, function()
    Tracker.weakAurasOptionsRefreshPending = nil
    if Tracker.initialized then
      Tracker:RefreshAuraBarReadyVisuals()
    end
  end)
end

function Tracker:HookWeakAurasOptions()
  if self.weakAurasOptionsHooked then
    return
  end
  -- WeakAuras intentionally keeps its Options frame private.  Hook its
  -- public close API instead; this is present both before and after the
  -- Options addon has created its frame, and therefore also works for /wa.
  if not (WeakAuras and WeakAuras.HideOptions and hooksecurefunc) then
    return
  end
  self.weakAurasOptionsHooked = true
  hooksecurefunc(WeakAuras, "HideOptions", function()
    if Tracker.initialized then
      Tracker:RestoreAuraBarReadyVisualsAfterWeakAurasOptions()
    end
  end)

  -- The named frame is created lazily by WeakAurasOptions. When it already
  -- exists, also cover a direct frame close without relying solely on the
  -- public helper path.
  local optionsFrame = _G.WeakAurasOptions
  if optionsFrame and optionsFrame.HookScript then
    optionsFrame:HookScript("OnHide", function()
      if Tracker.initialized then
        Tracker:RestoreAuraBarReadyVisualsAfterWeakAurasOptions()
      end
    end)
  end
end

function Tracker:Emit(reason)
  if not self.initialized then
    return
  end
  self:BuildStates()
  local runtime = GetRuntimeRoot()
  self.revision = self.revision + 1
  if runtime then
    runtime.revision = self.revision
  end
  local snapshot = MerfinPlus:GetRaidCooldownTrackerSnapshot()
  if MerfinPlus.SendMessage then
    MerfinPlus:SendMessage(UPDATE_EVENT, snapshot, reason)
  end
  MerfinPlus:DispatchRaidCooldownTrackerSnapshots(UPDATE_EVENT, reason, true)
  -- WeakAuras applies custom-trigger state before its clones are fully
  -- refreshed. Apply the Ready visuals one frame later; this is event-driven
  -- and runs only after a real tracker update, never as an idle loop.
  C_Timer.After(0, function()
    if Tracker.initialized then
      Tracker:RefreshAuraBarReadyVisuals()
    end
  end)
end

function Tracker:OnEvent(event, ...)
  local changed = false
  if event == "ADDON_LOADED" then
    local addonName = ...
    if addonName == "WeakAurasOptions" then
      C_Timer.After(0, function()
        if Tracker.initialized then
          Tracker:HookWeakAurasOptions()
        end
      end)
    end
  elseif event == "GROUP_ROSTER_UPDATE" then
    self:QueueRosterReconciliation(event)
    return
  elseif event == "PLAYER_ENTERING_WORLD" then
    changed = self:RefreshRoster()
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    changed = self:HandleCombatLog()
  elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
    local unitID, _, spellID = ...
    changed = self:HandleUnitSpellcast(unitID, spellID)
  elseif event == "UNIT_HEALTH" or event == "UNIT_CONNECTION" or event == "UNIT_FLAGS" then
    changed = self:RefreshUnitConditions(...)
  elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
    changed = self:RefreshUnitConditions("player")
  elseif event == "ENCOUNTER_END" then
    changed = self:ResetEncounterCooldowns()
  elseif event == "INSPECT_READY" then
    changed = self:OnInspectReady(...)
  elseif event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED" then
    local playerName = ShortName(UnitName("player"))
    changed = playerName and self:ReadTalents(playerName, false) or false
  elseif event == "PLAYER_REGEN_ENABLED" then
    self:QueueStaleInspects()
    self:TryInspect()
  elseif event == "PLAYER_LOGOUT" then
    self:RefreshRoster()
  end
  if changed then
    self:Emit(event)
  end
end

function MerfinPlus:RaidCooldownTrackerOnEvent(event, ...)
  Tracker:OnEvent(event, ...)
end

function MerfinPlus:GetRaidCooldownTrackedStates(frontendID)
  local definition = self:GetRaidCooldownTrackerExpansion()
  local rendererKey = self:GetRaidCooldownRendererKey(frontendID)
  if not definition or not rendererKey or not definition.renderers[rendererKey] then
    return {}, Tracker.revision
  end
  if not self:IsRaidCooldownRendererEnabled(rendererKey) then
    return {}, Tracker.revision
  end
  return DeepCopy(Tracker.statesByRenderer[rendererKey] or {}), Tracker.revision
end

function MerfinPlus:RefreshRaidCooldownTrackerConfig(path)
  if not Tracker.initialized then
    return
  end
  Tracker:BuildActiveConfig()
  local changed = false
  for unitName in pairs(Tracker:GetRoster()) do
    changed = Tracker:ApplyCooldownEligibility(unitName) or changed
  end
  Tracker:Emit(path or (changed and "config-and-eligibility" or "config"))
end

function MerfinPlus:InitializeRaidCooldownTracker()
  if Tracker.initialized or not self:GetRaidCooldownTrackerExpansion() then
    return
  end
  if not self:HasEnabledRaidCooldownRenderers() then
    return
  end
  local runtime = GetRuntimeRoot()
  Tracker.revision = runtime and runtime.revision or 0
  Tracker:BuildSpellLookup()
  Tracker:BuildActiveConfig()
  Tracker.initialized = true

  local events = {
    "ADDON_LOADED",
    "PLAYER_ENTERING_WORLD",
    "GROUP_ROSTER_UPDATE",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_HEALTH",
    "UNIT_CONNECTION",
    "UNIT_FLAGS",
    "PLAYER_ALIVE",
    "PLAYER_UNGHOST",
    "ENCOUNTER_END",
    "INSPECT_READY",
    "PLAYER_TALENT_UPDATE",
    "CHARACTER_POINTS_CHANGED",
    "PLAYER_REGEN_ENABLED",
    "PLAYER_LOGOUT",
  }
  local eventFrame = CreateFrame("Frame")
  Tracker.eventFrame = eventFrame
  eventFrame:SetScript("OnEvent", function(_, event, ...)
    Tracker:OnEvent(event, ...)
  end)
  for _, event in ipairs(events) do
    eventFrame:RegisterEvent(event)
  end

  Tracker:RefreshRoster()
  Tracker:HookWeakAurasOptions()
  Tracker:Emit("initialize")
end

function MerfinPlus:ShutdownRaidCooldownTracker()
  if not Tracker.initialized then
    return
  end
  if Tracker.eventFrame then
    Tracker.eventFrame:UnregisterAllEvents()
    Tracker.eventFrame:SetScript("OnEvent", nil)
    Tracker.eventFrame = nil
  end
  Tracker.initialized = false
  Tracker.rosterRefreshGeneration = (tonumber(Tracker.rosterRefreshGeneration) or 0) + 1
  Tracker.inspectQueue = {}
  Tracker.inspectQueued = {}
  Tracker.inspectPending = nil
  Tracker.readyTimers = {}
  Tracker.lifeStates = {}
  Tracker.reincarnationPending = {}
  Tracker.reincarnationStarts = {}
  Tracker.externalResurrections = {}
  Tracker.soulstoneStates = {}
  Tracker.weakAurasOptionsHooked = nil
  Tracker.weakAurasOptionsRefreshPending = nil
  Tracker.activeCooldowns = {}
  Tracker.rosterUnits = {}
  Tracker.states = {}
  Tracker.statesByRenderer = {}
end
