local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local EVENT_NAME = "MERFINPLUS_GURTOGG_ASSIGNMENTS_UPDATED"
local SNAPSHOT_VERSION = 3
local RAID_GROUP_ID = "bt_mh"
local GUILD_MANAGER_MODE = "guild-manager"
local MANUAL_MODE = "manual"
local GURTOGG_ENCOUNTER_ID = 605
local GURTOGG_NPC_ID = "22948"
local GURTOGG_ICON = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\bosses\\tbc\\catalog\\black-temple\\gurtogg-bloodboil\\primary.blp"
local PUBLIC_BRIDGE_NAME = "MerfinPlusGurtoggAssignments"
local PublicBridge = _G[PUBLIC_BRIDGE_NAME]
if type(PublicBridge) ~= "table" then
  PublicBridge = {}
  _G[PUBLIC_BRIDGE_NAME] = PublicBridge
end
local GURTOGG_BOSS = {
  key = "gurtogg_bloodboil",
  name = "Gurtogg Bloodboil",
  raidKey = "black_temple",
}

local GROUP_DEFINITIONS = {
  {
    key = "star",
    order = 1,
    label = "Star Worldmark - Group 1",
    marker = "star",
    markerIndex = 1,
    assignmentKey = "gurtoggstargroup",
  },
  {
    key = "diamond",
    order = 2,
    label = "Diamond Worldmark - Group 2",
    marker = "diamond",
    markerIndex = 3,
    assignmentKey = "gurtoggdiamondgroup",
  },
  {
    key = "circle",
    order = 3,
    label = "Circle Worldmark - Group 3",
    marker = "circle",
    markerIndex = 2,
    assignmentKey = "gurtoggcirclegroup",
  },
}

local CLASS_TOKEN_BY_KEY = {
  deathknight = "DEATHKNIGHT",
  druid = "DRUID",
  hunter = "HUNTER",
  mage = "MAGE",
  monk = "MONK",
  paladin = "PALADIN",
  priest = "PRIEST",
  rogue = "ROGUE",
  shaman = "SHAMAN",
  warlock = "WARLOCK",
  warrior = "WARRIOR",
}

local function Trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function NormalizeKey(value)
  return Trim(value):lower():gsub("[%s%p%c]+", "")
end

local function NormalizeClassToken(value)
  return CLASS_TOKEN_BY_KEY[NormalizeKey(value)]
end

local function ShortPlayerName(value)
  local name = Trim(value)
  name = name:gsub("|[cC]%x%x%x%x%x%x%x%x", ""):gsub("|[rR]", "")
  local dash = name:find("-", 1, true)
  if dash then
    name = name:sub(1, dash - 1)
  end
  name = Trim(name)
  return name ~= "" and name or nil
end

local function PlayerKey(value)
  local lower = strlower or string.lower
  return lower(tostring(value or ""))
end

local function BloodBoilStackTarget(boss, index)
  local targets = boss and boss.bloodBoilStackTargets
  local target = type(targets) == "table" and tonumber(targets[index]) or nil
  if not target or target % 1 ~= 0 or target < 1 or target > 10 then return 1 end
  return target
end

local function NewSnapshotGroup(definition, stackTarget)
  return {
    key = definition.key,
    order = definition.order,
    label = definition.label,
    marker = definition.marker,
    markerIndex = definition.markerIndex,
    assignmentKey = definition.assignmentKey,
    stackTarget = stackTarget,
    players = {},
    members = {},
  }
end

local function SectionMatches(section, definition)
  local wanted = NormalizeKey(definition.label)
  return NormalizeKey(section and section.sourceName) == wanted
    or NormalizeKey(section and section.name) == wanted
end

local function AddCandidate(candidates, task, sequence)
  local player = ShortPlayerName(task and task.player)
  if not player then return end
  candidates[#candidates + 1] = {
    player = player,
    slot = tonumber(task.slot) or 0,
    sequence = sequence,
  }
end

local function CollectGroupCandidates(boss, definition)
  local candidates = {}
  local sequence = 0

  for _, task in ipairs(type(boss.v2Assignments) == "table" and boss.v2Assignments or {}) do
    if NormalizeKey(task.assignmentKey) == NormalizeKey(definition.assignmentKey) then
      sequence = sequence + 1
      AddCandidate(candidates, task, sequence)
    end
  end

  for _, section in ipairs(type(boss.sections) == "table" and boss.sections or {}) do
    if SectionMatches(section, definition) then
      for _, task in ipairs(type(section.rows) == "table" and section.rows or {}) do
        sequence = sequence + 1
        AddCandidate(candidates, task, sequence)
      end
    end
  end

  table.sort(candidates, function(left, right)
    local leftSlotted, rightSlotted = left.slot > 0, right.slot > 0
    if leftSlotted ~= rightSlotted then return leftSlotted end
    if leftSlotted and left.slot ~= right.slot then return left.slot < right.slot end
    return left.sequence < right.sequence
  end)
  return candidates
end

local function BuildSource(entry)
  if not entry then return { mode = GUILD_MANAGER_MODE } end
  local parsed = entry.parsed
  return {
    mode = GUILD_MANAGER_MODE,
    importId = tostring(entry.id or ""),
    contentSignature = tostring(entry.contentSignature or ""),
    protocol = tostring(entry.protocol or (parsed and parsed.protocol) or ""),
    protocolVersion = tonumber(entry.envelopeVersion or (parsed and parsed.envelopeVersion)
      or entry.version or (parsed and parsed.version)) or 0,
    receivedBroadcast = entry.receivedBroadcast == true,
  }
end

local function SnapshotSignature(snapshot)
  local parts = {
    tostring(snapshot.version),
    snapshot.available and "1" or "0",
    snapshot.source and snapshot.source.mode or "",
    snapshot.source and snapshot.source.importId or "",
    snapshot.source and snapshot.source.contentSignature or "",
  }
  for _, group in ipairs(snapshot.groups) do
    parts[#parts + 1] = group.key
    parts[#parts + 1] = tostring(group.stackTarget)
    for index, player in ipairs(group.players) do
      local member = group.members[index] or {}
      parts[#parts + 1] = PlayerKey(player)
      parts[#parts + 1] = tostring(member.classToken or "")
      parts[#parts + 1] = tostring(member.spec or "")
    end
  end
  return table.concat(parts, "\31")
end

local function CopySource(source, mode)
  local copy = {}
  for key, value in pairs(type(source) == "table" and source or {}) do
    if type(value) ~= "table" then copy[key] = value end
  end
  copy.mode = mode
  return copy
end

local function UnitForPlayerName(name)
  local wanted = PlayerKey(ShortPlayerName(name))
  if wanted == "" then return nil end
  if PlayerKey(ShortPlayerName(UnitName and UnitName("player"))) == wanted then return "player" end
  local inRaid = IsInRaid and IsInRaid()
  local count = GetNumGroupMembers and GetNumGroupMembers() or 0
  local prefix = inRaid and "raid" or "party"
  for index = 1, count do
    local unit = prefix .. index
    if PlayerKey(ShortPlayerName(UnitName and UnitName(unit))) == wanted then return unit end
  end
end

local function PlayerMember(name)
  local member = { name = name }
  local unit = UnitForPlayerName(name)
  if unit and UnitClass then member.classToken = select(2, UnitClass(unit)) end
  return member
end

local function ParseManualPlayerNames(value)
  local players = {}
  local localPlayers = {}
  for token in tostring(value or ""):gmatch("[^,;%s]+") do
    local name = ShortPlayerName(token)
    local key = PlayerKey(name)
    if name and key ~= "" and not localPlayers[key] then
      if #name > 48 then return nil, "Player names must not exceed 48 characters." end
      if #players >= 10 then return nil, "Each Gurtogg group supports at most 10 players." end
      localPlayers[key] = true
      players[#players + 1] = name
    end
  end
  return players
end

local function ManualGroupSettings(owner)
  local storage = owner:GetRaidAssignmentStorage()
  local mode = storage.gurtoggAssignmentsMode
  if mode ~= GUILD_MANAGER_MODE and mode ~= MANUAL_MODE then
    storage.gurtoggAssignmentsMode = GUILD_MANAGER_MODE
  end
  if type(storage.gurtoggManualGroups) ~= "table" then storage.gurtoggManualGroups = {} end
  for _, definition in ipairs(GROUP_DEFINITIONS) do
    local group = storage.gurtoggManualGroups[definition.key]
    if type(group) ~= "table" then
      group = {}
      storage.gurtoggManualGroups[definition.key] = group
    end
    group.players = tostring(group.players or "")
    group.stackTarget = BloodBoilStackTarget({ bloodBoilStackTargets = { group.stackTarget } }, 1)
  end
  return storage, storage.gurtoggManualGroups
end

local function InvalidateActiveSnapshot(owner)
  owner.gurtoggAssignmentsSnapshot = nil
  owner.gurtoggAssignmentsPublishedSignature = nil
  PublicBridge.snapshot = nil
  if type(owner.QueueGurtoggAssignmentsPublish) == "function" then
    owner:QueueGurtoggAssignmentsPublish()
  end
end

function MerfinPlus:GetGurtoggAssignmentMode()
  local storage = ManualGroupSettings(self)
  return storage.gurtoggAssignmentsMode
end

function MerfinPlus:SetGurtoggAssignmentMode(mode)
  if mode ~= GUILD_MANAGER_MODE and mode ~= MANUAL_MODE then return false end
  local storage = ManualGroupSettings(self)
  if storage.gurtoggAssignmentsMode == mode then return false end
  storage.gurtoggAssignmentsMode = mode
  storage.gurtoggSyncStatus = ""
  self.gurtoggAssignmentSourceRevision = (self.gurtoggAssignmentSourceRevision or 0) + 1
  self.gurtoggSyncEncounterActive = nil
  self.gurtoggSyncAutomaticSenderRole = nil
  self.gurtoggSyncSourceRevision = nil
  self.gurtoggSyncSucceededGeneration = nil
  self.gurtoggLastSuccessfulSync = nil
  InvalidateActiveSnapshot(self)
  return true
end

function MerfinPlus:GetGurtoggManualGroupSettings(groupKey)
  local _, groups = ManualGroupSettings(self)
  return groups[groupKey]
end

function MerfinPlus:SetGurtoggManualGroupPlayers(groupKey, value)
  local group = self:GetGurtoggManualGroupSettings(groupKey)
  if not group then return false end
  group.players = tostring(value or "")
  if self:GetGurtoggAssignmentMode() == MANUAL_MODE then InvalidateActiveSnapshot(self) end
  return true
end

function MerfinPlus:SetGurtoggManualGroupStackTarget(groupKey, value)
  local group = self:GetGurtoggManualGroupSettings(groupKey)
  value = tonumber(value)
  if not group or not value or value % 1 ~= 0 or value < 1 or value > 10 then return false end
  group.stackTarget = value
  if self:GetGurtoggAssignmentMode() == MANUAL_MODE then InvalidateActiveSnapshot(self) end
  return true
end

function MerfinPlus:SetGurtoggGroupAssignmentsStatus(text, tone)
  local storage = ManualGroupSettings(self)
  storage.gurtoggSyncStatus = tostring(text or "")
  storage.gurtoggSyncStatusTone = tone or "muted"
end

function MerfinPlus:GetGurtoggGroupAssignmentsStatus()
  local storage = ManualGroupSettings(self)
  return tostring(storage.gurtoggSyncStatus or ""), storage.gurtoggSyncStatusTone or "muted"
end

function MerfinPlus:BuildManualGurtoggAssignmentsSnapshot()
  local _, settings = ManualGroupSettings(self)
  local snapshot = {
    schema = "merfinplus.gurtogg.assignments",
    version = SNAPSHOT_VERSION,
    available = true,
    encounter = {
      key = GURTOGG_BOSS.key,
      planKey = "t6.black_temple.gurtogg_bloodboil",
      name = GURTOGG_BOSS.name,
      raidKey = GURTOGG_BOSS.raidKey,
    },
    source = { mode = MANUAL_MODE },
    groupOrder = {},
    groups = {},
  }
  for _, definition in ipairs(GROUP_DEFINITIONS) do
    local setting = settings[definition.key]
    local players, parseError = ParseManualPlayerNames(setting.players)
    if not players then return nil, parseError end
    if #players == 0 then
      return nil, string.format("%s requires at least one player.", definition.label)
    end
    local group = NewSnapshotGroup(definition, setting.stackTarget)
    for _, player in ipairs(players) do
      group.players[#group.players + 1] = player
      group.members[#group.members + 1] = PlayerMember(player)
    end
    snapshot.groupOrder[#snapshot.groupOrder + 1] = group.key
    snapshot.groups[#snapshot.groups + 1] = group
  end
  return snapshot
end

function MerfinPlus:NormalizeGurtoggAssignmentsSnapshot(snapshot, forcedMode)
  if type(snapshot) ~= "table" or snapshot.schema ~= "merfinplus.gurtogg.assignments"
    or tonumber(snapshot.version) ~= SNAPSHOT_VERSION or snapshot.available ~= true
    or type(snapshot.groups) ~= "table" then
    return nil, "Gurtogg group snapshot is invalid."
  end
  local mode = forcedMode or (type(snapshot.source) == "table" and snapshot.source.mode)
  if mode == "weak-aura-manual" then mode = MANUAL_MODE end
  if mode ~= GUILD_MANAGER_MODE and mode ~= MANUAL_MODE then
    return nil, "Gurtogg group snapshot source is invalid."
  end
  local sourceGroups = {}
  for _, group in ipairs(snapshot.groups) do
    if type(group) ~= "table" or sourceGroups[group.key] then
      return nil, "Gurtogg group snapshot contains duplicate groups."
    end
    sourceGroups[group.key] = group
  end
  local normalized = {
    schema = "merfinplus.gurtogg.assignments",
    version = SNAPSHOT_VERSION,
    available = true,
    encounter = {
      key = GURTOGG_BOSS.key,
      planKey = "t6.black_temple.gurtogg_bloodboil",
      name = GURTOGG_BOSS.name,
      raidKey = GURTOGG_BOSS.raidKey,
    },
    source = CopySource(snapshot.source, mode),
    groupOrder = {},
    groups = {},
  }
  local claimedPlayers = {}
  local totalPlayers = 0
  for _, definition in ipairs(GROUP_DEFINITIONS) do
    local sourceGroup = sourceGroups[definition.key]
    local target = sourceGroup and tonumber(sourceGroup.stackTarget)
    if not sourceGroup or not target or target % 1 ~= 0 or target < 1 or target > 10 then
      return nil, "Gurtogg group snapshot is missing a valid group or stack target."
    end
    local group = NewSnapshotGroup(definition, target)
    local members = type(sourceGroup.members) == "table" and sourceGroup.members or sourceGroup.players
    if type(members) ~= "table" or #members > 10 then
      return nil, "Gurtogg group snapshot has invalid members."
    end
    local groupPlayers = {}
    for _, sourceMember in ipairs(members) do
      local name = ShortPlayerName(type(sourceMember) == "table" and sourceMember.name or sourceMember)
      local key = PlayerKey(name)
      if not name or key == "" or #name > 48 or groupPlayers[key]
        or (mode ~= MANUAL_MODE and claimedPlayers[key]) then
        return nil, "Gurtogg group snapshot has invalid or duplicate players."
      end
      groupPlayers[key] = true
      claimedPlayers[key] = true
      local member = { name = name }
      if type(sourceMember) == "table" then
        member.classToken = NormalizeClassToken(sourceMember.classToken or sourceMember.class)
        local spec = Trim(sourceMember.spec)
        member.spec = spec ~= "" and spec or nil
      end
      group.players[#group.players + 1] = name
      group.members[#group.members + 1] = member
      totalPlayers = totalPlayers + 1
    end
    normalized.groupOrder[#normalized.groupOrder + 1] = group.key
    normalized.groups[#normalized.groups + 1] = group
  end
  if totalPlayers == 0 then return nil, "Gurtogg group snapshot has no players." end
  return normalized
end

local function CacheSnapshot(snapshot)
  MerfinPlus.gurtoggAssignmentsSnapshot = snapshot
  PublicBridge.snapshot = snapshot
  return snapshot
end

local function ResolveSnapshotEntryAndBoss(owner)
  local entry = owner:GetActivePersonalRaidAssignmentImport()
  if entry then
    local activeBoss
    if entry.canonicalPersonal then
      -- Canonical personal projections may contain persistent Trash first and
      -- exactly one current non-Trash boss second. The latter is the synced
      -- boss that must control this bridge.
      for _, candidate in ipairs(type(entry.parsed) == "table" and entry.parsed.bosses or {}) do
        if candidate.isTrash ~= true then
          activeBoss = candidate
          break
        end
      end
    else
      activeBoss = owner:GetActivePersonalRaidAssignmentBoss(entry)
    end
    local boss = activeBoss and owner:GetRaidAssignmentBoss({ bosses = { activeBoss } }, GURTOGG_BOSS)
    return entry, boss
  end

  -- Preserve the existing local/restored-import behavior when no personal
  -- sync projection exists at all. Never fall back here when another synced
  -- boss is active, or the older full Gurtogg import would remain visible.
  entry = owner:GetRaidAssignmentImportForGroup(RAID_GROUP_ID)
  local boss = entry and entry.parsed and owner:GetRaidAssignmentBoss(entry.parsed, GURTOGG_BOSS)
  return entry, boss
end

function MerfinPlus:BuildGurtoggAssignmentsSnapshot()
  local entry, boss = ResolveSnapshotEntryAndBoss(self)
  local snapshot = {
    schema = "merfinplus.gurtogg.assignments",
    version = SNAPSHOT_VERSION,
    available = false,
    encounter = {
      key = GURTOGG_BOSS.key,
      planKey = "t6.black_temple.gurtogg_bloodboil",
      name = GURTOGG_BOSS.name,
      raidKey = GURTOGG_BOSS.raidKey,
    },
    source = BuildSource(entry),
    groupOrder = {},
    groups = {},
  }

  local claimedPlayers = {}
  local playerCount = 0
  local playerMap = boss and self:BuildRaidAssignmentPlayerMap(boss) or {}
  for _, definition in ipairs(GROUP_DEFINITIONS) do
    local group = NewSnapshotGroup(definition, BloodBoilStackTarget(boss, definition.order))
    snapshot.groupOrder[#snapshot.groupOrder + 1] = group.key
    snapshot.groups[#snapshot.groups + 1] = group
    if boss then
      for _, candidate in ipairs(CollectGroupCandidates(boss, definition)) do
        local key = PlayerKey(candidate.player)
        if key ~= "" and not claimedPlayers[key] then
          claimedPlayers[key] = true
          group.players[#group.players + 1] = candidate.player
          local playerInfo = playerMap[key]
          local member = { name = candidate.player }
          if playerInfo and not playerInfo.ambiguous then
            member.classToken = NormalizeClassToken(playerInfo.classToken or playerInfo.class)
            local spec = Trim(playerInfo.spec)
            member.spec = spec ~= "" and spec or nil
          end
          group.members[#group.members + 1] = member
          playerCount = playerCount + 1
        end
      end
    end
  end
  snapshot.available = boss ~= nil and playerCount > 0
  return snapshot
end

local function BuildUnavailableGurtoggAssignmentsSnapshot(mode)
  return {
    schema = "merfinplus.gurtogg.assignments",
    version = SNAPSHOT_VERSION,
    available = false,
    encounter = {
      key = GURTOGG_BOSS.key,
      planKey = "t6.black_temple.gurtogg_bloodboil",
      name = GURTOGG_BOSS.name,
      raidKey = GURTOGG_BOSS.raidKey,
    },
    source = { mode = mode },
    groupOrder = {},
    groups = {},
  }
end

function MerfinPlus:GetGurtoggAssignmentsSnapshot()
  local snapshot = self.gurtoggAssignmentsSnapshot
  if type(snapshot) ~= "table" then
    snapshot = self:GetGurtoggAssignmentMode() == MANUAL_MODE
      and BuildUnavailableGurtoggAssignmentsSnapshot(MANUAL_MODE)
      or self:BuildGurtoggAssignmentsSnapshot()
    snapshot = CacheSnapshot(snapshot)
  end
  return snapshot
end

function MerfinPlus:PublishGurtoggAssignmentsSnapshot()
  local snapshot = self:GetGurtoggAssignmentsSnapshot()
  local signature = SnapshotSignature(snapshot)

  local weakAuras = _G.WeakAuras
  if type(weakAuras) ~= "table" or type(weakAuras.ScanEvents) ~= "function" then
    return false
  end
  if self.gurtoggAssignmentsPublishedSignature == signature then
    return false
  end

  weakAuras.ScanEvents(EVENT_NAME, snapshot)
  self.gurtoggAssignmentsPublishedSignature = signature
  return true
end

function MerfinPlus:QueueGurtoggAssignmentsPublish()
  if self.gurtoggAssignmentsPublishQueued then return end
  self.gurtoggAssignmentsPublishQueued = true
  local function PublishQueuedSnapshot()
    self.gurtoggAssignmentsPublishQueued = nil
    self:PublishGurtoggAssignmentsSnapshot()
  end
  if C_Timer and type(C_Timer.After) == "function" then
    C_Timer.After(0, PublishQueuedSnapshot)
  else
    PublishQueuedSnapshot()
  end
end

local function IsGurtoggBoss(value)
  local key = NormalizeKey(type(value) == "table" and (value.key or value.name) or value)
  return key == NormalizeKey(GURTOGG_BOSS.key) or key == NormalizeKey(GURTOGG_BOSS.name)
end

local function IsGurtoggGUID(guid)
  if type(guid) ~= "string" then return false end
  local npc = guid:match("^[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-([^%-]+)")
  return npc == GURTOGG_NPC_ID
end

function MerfinPlus:HasLiveGurtoggUnit()
  local function IsLive(unit)
    return IsGurtoggGUID(UnitGUID and UnitGUID(unit))
      and not (UnitIsDeadOrGhost and UnitIsDeadOrGhost(unit))
  end
  for index = 1, 5 do
    if IsLive("boss" .. index) then return true end
  end
  return IsLive("target") or IsLive("focus")
end

function MerfinPlus:CanBroadcastGurtoggAssignments()
  if type(self.CanBroadcastRaidAssignments) ~= "function" then
    return false, "Gurtogg group sync is unavailable."
  end
  return self:CanBroadcastRaidAssignments()
end

function MerfinPlus:GetActiveGurtoggAssignmentsSnapshot()
  local mode = self:GetGurtoggAssignmentMode()
  if mode == MANUAL_MODE then return self:BuildManualGurtoggAssignmentsSnapshot() end
  return nil, "Guild Manager mode uses the canonical Gurtogg boss assignment sync."
end

function MerfinPlus:RecordGurtoggAssignmentsSyncSuccess(mode, trigger)
  self.gurtoggLastSuccessfulSync = {
    mode = mode,
    trigger = trigger,
    encounterGeneration = self.gurtoggSyncEncounterActive and self.gurtoggSyncEncounterGeneration or nil,
    sourceRevision = self.gurtoggAssignmentSourceRevision or 0,
    time = (GetServerTime and GetServerTime()) or (time and time()) or 0,
  }
  if self.gurtoggSyncEncounterActive
    and self.gurtoggSyncSourceRevision == (self.gurtoggAssignmentSourceRevision or 0) then
    self.gurtoggSyncSucceededGeneration = self.gurtoggSyncEncounterGeneration
  end
end

function MerfinPlus:BroadcastActiveGurtoggAssignments(trigger)
  local allowed, reason = self:CanBroadcastGurtoggAssignments()
  if not allowed then self:SetGurtoggGroupAssignmentsStatus(reason, "red"); return false, reason end
  if self:GetGurtoggAssignmentMode() == GUILD_MANAGER_MODE then
    return self:SyncGuildManagerGurtoggAssignments(trigger)
  end
  local snapshot, buildError = self:GetActiveGurtoggAssignmentsSnapshot()
  if not snapshot then self:SetGurtoggGroupAssignmentsStatus(buildError, "red"); return false, buildError end
  local normalized, normalizeError = self:NormalizeGurtoggAssignmentsSnapshot(snapshot)
  if not normalized then self:SetGurtoggGroupAssignmentsStatus(normalizeError, "red"); return false, normalizeError end
  if type(self.BroadcastGurtoggAssignmentsSnapshot) ~= "function" then
    reason = "Gurtogg group sync transport is unavailable."
    self:SetGurtoggGroupAssignmentsStatus(reason, "red")
    return false, reason
  end
  local sent, metrics = self:BroadcastGurtoggAssignmentsSnapshot(normalized, normalized.source.mode, trigger)
  if sent then
    self:RecordGurtoggAssignmentsSyncSuccess(normalized.source.mode, trigger)
    self:SetGurtoggGroupAssignmentsStatus("Gurtogg group assignments synced.", "green")
  else
    self:SetGurtoggGroupAssignmentsStatus(metrics or "Gurtogg group assignments could not be synced.", "red")
  end
  return sent, metrics
end

function MerfinPlus:MaybeBroadcastGurtoggAssignmentsForBoss(catalogBoss)
  if not IsGurtoggBoss(catalogBoss) then return false, { skipped = true, reason = "not-gurtogg" } end
  if self:GetGurtoggAssignmentMode() ~= GUILD_MANAGER_MODE then
    return false, { skipped = true, reason = "manual-mode" }
  end
  self:RecordGurtoggAssignmentsSyncSuccess(GUILD_MANAGER_MODE, "boss-assignments")
  self:SetGurtoggGroupAssignmentsStatus("Gurtogg group assignments synced with the boss assignments.", "green")
  return true, { mode = GUILD_MANAGER_MODE, piggyback = true }
end

function MerfinPlus:RecordReceivedGurtoggAssignmentsForBoss(bossKey, sender)
  if not IsGurtoggBoss(bossKey) then return false end
  self:RecordGurtoggAssignmentsSyncSuccess(GUILD_MANAGER_MODE, "received-boss-assignments")
  self:SetGurtoggGroupAssignmentsStatus("Gurtogg group assignments received from " .. tostring(sender or "") .. ".", "green")
  return true
end

function MerfinPlus:GetGurtoggCatalogBoss()
  local group = self:GetRaidAssignmentGroup(RAID_GROUP_ID)
  for _, raid in ipairs(group and group.raids or {}) do
    for _, boss in ipairs(raid.bosses or {}) do
      if IsGurtoggBoss(boss) then return boss end
    end
  end
end

function MerfinPlus:SyncGuildManagerGurtoggAssignments(trigger)
  local catalogBoss = self:GetGurtoggCatalogBoss()
  if not catalogBoss or type(self.BroadcastPersonalRaidAssignments) ~= "function" then
    local reason = "Gurtogg boss assignment sync is unavailable."
    self:SetGurtoggGroupAssignmentsStatus(reason, "red")
    return false, reason
  end
  local sent, metrics = self:BroadcastPersonalRaidAssignments(catalogBoss, false, RAID_GROUP_ID)
  if not sent then
    self:SetGurtoggGroupAssignmentsStatus(metrics or "Gurtogg boss assignments could not be synced.", "red")
  elseif type(metrics) == "table" then
    metrics.gurtoggTrigger = trigger
  end
  return sent, metrics
end

function MerfinPlus:SyncManualGurtoggGroups()
  if self:GetGurtoggAssignmentMode() ~= MANUAL_MODE then
    local reason = "Use Manual Groups must be active before manual groups can be synced."
    self:SetGurtoggGroupAssignmentsStatus(reason, "red")
    return false, reason
  end
  return self:BroadcastActiveGurtoggAssignments("manual-button")
end

local function IsLocalRaidLeader()
  local leader = UnitIsGroupLeader and UnitIsGroupLeader("player")
  if not leader and IsInRaid and IsInRaid() and IsRaidLeader then leader = IsRaidLeader() end
  if not leader and IsInRaid and IsInRaid() and UnitInRaid and GetRaidRosterInfo then
    local index = UnitInRaid("player")
    local rank = index and select(2, GetRaidRosterInfo(index))
    leader = rank == 2
  end
  return leader == true
end

local function IsDesignatedRaidAssistant()
  if not (IsInRaid and IsInRaid() and UnitIsGroupAssistant and UnitIsGroupAssistant("player")) then
    return false
  end
  local localKey = PlayerKey(ShortPlayerName(UnitName and UnitName("player")))
  if localKey == "" then return false end
  for index = 1, GetNumGroupMembers and GetNumGroupMembers() or 0 do
    local unit = "raid" .. index
    if UnitIsGroupAssistant(unit) then
      local candidate = PlayerKey(ShortPlayerName(UnitName and UnitName(unit)))
      if candidate ~= "" and candidate < localKey then return false end
    end
  end
  return true
end

local function AutomaticSenderRole()
  if IsLocalRaidLeader() then return "leader" end
  if IsDesignatedRaidAssistant() then return "assistant" end
end

function MerfinPlus:TryAutomaticGurtoggAssignmentsSync()
  if not self.gurtoggSyncEncounterActive
    or self.gurtoggSyncSourceRevision ~= (self.gurtoggAssignmentSourceRevision or 0)
    or self.gurtoggSyncSucceededGeneration == self.gurtoggSyncEncounterGeneration then return false end
  local allowed = self:CanBroadcastGurtoggAssignments()
  if not allowed then return false end
  if not self.gurtoggSyncAutomaticSenderRole then return false end
  return self:BroadcastActiveGurtoggAssignments("pull-emergency")
end

function MerfinPlus:BeginGurtoggSyncEncounter(forceNewGeneration)
  if self.gurtoggSyncEncounterActive and forceNewGeneration ~= true then return false end
  self.gurtoggSyncEncounterActive = true
  self.gurtoggSyncEncounterGeneration = (self.gurtoggSyncEncounterGeneration or 0) + 1
  self.gurtoggSyncSucceededGeneration = nil
  self.gurtoggSyncSourceRevision = self.gurtoggAssignmentSourceRevision or 0
  self.gurtoggSyncAutomaticSenderRole = AutomaticSenderRole()
  local generation = self.gurtoggSyncEncounterGeneration
  local sourceRevision = self.gurtoggSyncSourceRevision
  local function TrySync()
    if self.gurtoggSyncEncounterActive
      and self.gurtoggSyncEncounterGeneration == generation
      and self.gurtoggSyncSourceRevision == sourceRevision
      and sourceRevision == (self.gurtoggAssignmentSourceRevision or 0) then
      self:TryAutomaticGurtoggAssignmentsSync()
    end
  end
  if C_Timer and type(C_Timer.After) == "function" then
    local assistantFallback = self.gurtoggSyncAutomaticSenderRole == "assistant"
    C_Timer.After(assistantFallback and 2.5 or 0.5, TrySync)
    C_Timer.After(assistantFallback and 4 or 1.5, TrySync)
  else
    TrySync()
  end
  return true
end

function MerfinPlus:EndGurtoggSyncEncounter()
  self.gurtoggSyncEncounterActive = nil
  self.gurtoggSyncAutomaticSenderRole = nil
  self.gurtoggSyncSourceRevision = nil
end

function MerfinPlus:ClearCompletedGurtoggManualSnapshot()
  local snapshot = self.gurtoggAssignmentsSnapshot or PublicBridge.snapshot
  local mode = type(snapshot) == "table" and type(snapshot.source) == "table" and snapshot.source.mode
  if snapshot == nil or snapshot.available ~= true
    or (mode ~= MANUAL_MODE and mode ~= "weak-aura-manual") then return false end
  local cleared = BuildUnavailableGurtoggAssignmentsSnapshot(MANUAL_MODE)
  cleared.source.reason = "successful-gurtogg-kill"
  CacheSnapshot(cleared)
  self.gurtoggAssignmentsPublishedSignature = nil
  self:PublishGurtoggAssignmentsSnapshot()
  return true
end

function MerfinPlus:HandleGurtoggSyncEncounterEnd(encounterID, success)
  if tonumber(encounterID) ~= GURTOGG_ENCOUNTER_ID then return false end
  self:EndGurtoggSyncEncounter()
  if success == true or tonumber(success) == 1 then
    return self:ClearCompletedGurtoggManualSnapshot()
  end
  return false
end

function MerfinPlus:InitializeGurtoggPullSync()
  if self.gurtoggPullSyncInitialized or not CreateFrame then return end
  self.gurtoggPullSyncInitialized = true
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ENCOUNTER_START")
  frame:RegisterEvent("ENCOUNTER_END")
  frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:SetScript("OnEvent", function(_, event, encounterID, encounterName, difficultyID, groupSize, success)
    if event == "ENCOUNTER_START" then
      if tonumber(encounterID) == GURTOGG_ENCOUNTER_ID then self:BeginGurtoggSyncEncounter(true) end
      return
    end
    if event == "ENCOUNTER_END" then
      self:HandleGurtoggSyncEncounterEnd(encounterID, success)
      return
    end
    if event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
      if self:HasLiveGurtoggUnit() then self:BeginGurtoggSyncEncounter() end
      return
    end
    if event == "PLAYER_REGEN_DISABLED" then
      local function Probe()
        if self:HasLiveGurtoggUnit() then self:BeginGurtoggSyncEncounter() end
      end
      if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0.5, Probe)
        C_Timer.After(1.5, Probe)
      else
        Probe()
      end
      return
    end
    if event == "PLAYER_REGEN_ENABLED" and self.gurtoggSyncEncounterActive then
      local function EndIfGone()
        if not self:HasLiveGurtoggUnit() then self:EndGurtoggSyncEncounter() end
      end
      if C_Timer and type(C_Timer.After) == "function" then C_Timer.After(0.5, EndIfGone) else EndIfGone() end
    end
  end)
  self.gurtoggPullSyncFrame = frame
end

function MerfinPlus:InitializeGurtoggAssignmentsBridge()
  if self.gurtoggAssignmentsBridgeInitialized then return end
  self.gurtoggAssignmentsBridgeInitialized = true
  if type(self.NotifyAssignmentWidgetContentChanged) == "function" then
    hooksecurefunc(self, "NotifyAssignmentWidgetContentChanged", function(owner)
      owner.gurtoggAssignmentsSnapshot = nil
      PublicBridge.snapshot = nil
      owner:QueueGurtoggAssignmentsPublish()
    end)
  end
  self:InitializeGurtoggPullSync()

  if IsLoggedIn and IsLoggedIn() then
    self:QueueGurtoggAssignmentsPublish()
  elseif not CreateFrame then
    self:QueueGurtoggAssignmentsPublish()
  else
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(loginFrame)
      loginFrame:UnregisterEvent("PLAYER_LOGIN")
      loginFrame:SetScript("OnEvent", nil)
      self:QueueGurtoggAssignmentsPublish()
    end)
    self.gurtoggAssignmentsLoginFrame = frame
  end
end

MerfinPlus.GURTOGG_ASSIGNMENTS_EVENT = EVENT_NAME
MerfinPlus.GURTOGG_ASSIGNMENTS_SNAPSHOT_VERSION = SNAPSHOT_VERSION
MerfinPlus.GURTOGG_ASSIGNMENTS_GUILD_MANAGER_MODE = GUILD_MANAGER_MODE
MerfinPlus.GURTOGG_ASSIGNMENTS_MANUAL_MODE = MANUAL_MODE
MerfinPlus.GURTOGG_ASSIGNMENTS_ICON = GURTOGG_ICON
PublicBridge.schema = "merfinplus.gurtogg.bridge"
PublicBridge.version = 1
PublicBridge.snapshotVersion = SNAPSHOT_VERSION
PublicBridge.event = EVENT_NAME

function MerfinPlus:PublishReceivedGurtoggAssignmentsSnapshot(snapshot, sender)
  local normalized = self:NormalizeGurtoggAssignmentsSnapshot(snapshot)
  if not normalized then return false end
  normalized.source.sender = tostring(sender or "")
  if normalized.source.mode == MANUAL_MODE then normalized.source.mode = "weak-aura-manual" end
  CacheSnapshot(normalized)
  local weakAuras = _G.WeakAuras
  if type(weakAuras) == "table" and type(weakAuras.ScanEvents) == "function" then
    weakAuras.ScanEvents(EVENT_NAME, normalized)
  end
  if self.gurtoggSyncEncounterActive then
    self:RecordGurtoggAssignmentsSyncSuccess(
      normalized.source.mode == "weak-aura-manual" and MANUAL_MODE or GUILD_MANAGER_MODE,
      "received-group-sync"
    )
  end
  return true
end

function MerfinPlus:PublishReceivedGurtoggManualSnapshot(snapshot, sender)
  if type(snapshot) == "table" then
    snapshot.source = snapshot.source or {}
    snapshot.source.mode = MANUAL_MODE
  end
  return self:PublishReceivedGurtoggAssignmentsSnapshot(snapshot, sender)
end

PublicBridge.GetSnapshot = function()
  return MerfinPlus:GetGurtoggAssignmentsSnapshot()
end
PublicBridge.BroadcastManualGroups = function(snapshot)
  if type(MerfinPlus.BroadcastGurtoggManualGroups) ~= "function" then
    return false, "Gurtogg manual sync transport is unavailable."
  end
  return MerfinPlus:BroadcastGurtoggManualGroups(snapshot)
end
if type(Merfin) == "table" then
  Merfin.GetGurtoggAssignmentsSnapshot = PublicBridge.GetSnapshot
  Merfin.BroadcastGurtoggManualGroups = PublicBridge.BroadcastManualGroups
end

if type(MerfinPlus.NotifyRaidAssignmentsChanged) == "function" then
  hooksecurefunc(MerfinPlus, "NotifyRaidAssignmentsChanged", function(owner)
    owner.gurtoggAssignmentsSnapshot = nil
    PublicBridge.snapshot = nil
    owner:QueueGurtoggAssignmentsPublish()
  end)
end
if type(MerfinPlus.InitializeRaidAssignments) == "function" then
  hooksecurefunc(MerfinPlus, "InitializeRaidAssignments", function(owner)
    owner:InitializeGurtoggAssignmentsBridge()
  end)
end
