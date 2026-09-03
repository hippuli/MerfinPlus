local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local EVENT_NAME = "MERFINPLUS_ILLIDAN_PHASE2_ASSIGNMENTS_UPDATED"
local SNAPSHOT_VERSION = 1
local RAID_GROUP_ID = "bt_mh"
local GUILD_MANAGER_MODE = "guild-manager"
local MANUAL_MODE = "manual"
local PUBLIC_NAME = "MerfinPlusIllidanPhase2Assignments"
local Public = _G[PUBLIC_NAME]
if type(Public) ~= "table" then
  Public = {}
  _G[PUBLIC_NAME] = Public
end

local BOSS = {
  key = "illidan",
  label = "Illidan Stormrage",
  encounterID = 609,
  npcID = "22917",
  aliases = { "Illidan", "IllidanStormrage", "illidan_stormrage" },
  icon = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\bosses\\tbc\\catalog\\black-temple\\illidan-stormrage\\primary.blp",
  catalogBoss = { key = "illidan_stormrage", name = "Illidan Stormrage", raidKey = "black_temple" },
}

local GROUPS = {
  {
    key = "group1", label = "Phase 2 Group 1", markerIndex = 3, markerName = "Diamond",
    sectionNames = { "Diamond Worldmark - Group 1", "Phase 2: Diamond Worldmark - Group 1", "Phase 2 Group 1" },
  },
  {
    key = "group2", label = "Phase 2 Group 2", markerIndex = 1, markerName = "Star",
    sectionNames = { "Star Worldmark - Group 2", "Phase 2: Star Worldmark - Group 2", "Phase 2 Group 2" },
  },
  {
    key = "group3", label = "Phase 2 Group 3", markerIndex = 2, markerName = "Circle",
    sectionNames = { "Circle Worldmark - Group 3", "Phase 2: Circle Worldmark - Group 3", "Phase 2 Group 3" },
  },
}

local function Trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function NormalizeKey(value)
  return Trim(value):lower():gsub("[%s%p%c]+", "")
end

local function ShortPlayerName(value)
  local name = Trim(value)
  name = name:gsub("|[cC]%x%x%x%x%x%x%x%x", ""):gsub("|[rR]", "")
  name = name:match("^([^%-]+)") or name
  name = Trim(name)
  return name ~= "" and name or nil
end

local function PlayerKey(value)
  local lower = strlower or string.lower
  return lower(tostring(value or ""))
end

local function IsIllidan(value)
  if type(value) == "table" then value = value.key or value.name or value.encounterID end
  if tonumber(value) == BOSS.encounterID then return true end
  local normalized = NormalizeKey(value)
  if normalized == NormalizeKey(BOSS.key) or normalized == NormalizeKey(BOSS.label)
    or normalized == NormalizeKey(BOSS.catalogBoss.key) then return true end
  for _, alias in ipairs(BOSS.aliases) do
    if normalized == NormalizeKey(alias) then return true end
  end
  return false
end

local function GroupDefinition(value)
  local normalized = NormalizeKey(type(value) == "table" and (value.key or value.label) or value)
  local numeric = tonumber(value)
  for index, definition in ipairs(GROUPS) do
    if numeric == index or normalized == NormalizeKey(definition.key)
      or normalized == NormalizeKey(definition.label) then return definition, index end
  end
end

local function CopySource(source, mode)
  local result = {}
  for key, value in pairs(type(source) == "table" and source or {}) do
    if type(value) ~= "table" then result[key] = value end
  end
  result.mode = mode
  return result
end

local function BuildSource(entry, mode)
  if not entry then return { mode = mode } end
  local parsed = entry.parsed
  return {
    mode = mode,
    importId = tostring(entry.id or ""),
    contentSignature = tostring(entry.contentSignature or ""),
    protocol = tostring(entry.protocol or (parsed and parsed.protocol) or ""),
    protocolVersion = tonumber(entry.envelopeVersion or (parsed and parsed.envelopeVersion)
      or entry.version or (parsed and parsed.version)) or 0,
    receivedBroadcast = entry.receivedBroadcast == true,
  }
end

local function NewSnapshot(source, available, reason)
  local snapshot = {
    schema = "merfinplus.illidan.phase2.assignments",
    version = SNAPSHOT_VERSION,
    available = available == true,
    bossKey = BOSS.key,
    encounter = {
      key = BOSS.key,
      name = BOSS.label,
      encounterID = BOSS.encounterID,
      raidKey = BOSS.catalogBoss.raidKey,
    },
    source = source or { mode = GUILD_MANAGER_MODE },
    groups = {},
  }
  if reason then snapshot.source.reason = reason end
  for _, definition in ipairs(GROUPS) do
    snapshot.groups[#snapshot.groups + 1] = {
      key = definition.key,
      label = definition.label,
      markerIndex = definition.markerIndex,
      markerName = definition.markerName,
      players = {},
    }
  end
  return snapshot
end

local function SnapshotSignature(snapshot)
  local parts = {
    tostring(snapshot.version or ""), snapshot.available and "1" or "0",
    tostring(snapshot.source and snapshot.source.mode or ""),
    tostring(snapshot.source and snapshot.source.importId or ""),
    tostring(snapshot.source and snapshot.source.contentSignature or ""),
    tostring(snapshot.source and snapshot.source.reason or ""),
  }
  for index, group in ipairs(snapshot.groups or {}) do
    parts[#parts + 1] = tostring(index)
    for _, player in ipairs(group.players or {}) do parts[#parts + 1] = PlayerKey(player) end
  end
  return table.concat(parts, "\31")
end

local function AssignmentStorage(owner)
  local storage = owner:GetRaidAssignmentStorage()
  local settings = storage.illidanPhase2Assignments
  if type(settings) ~= "table" then
    settings = {}
    storage.illidanPhase2Assignments = settings
  end
  if settings.mode ~= GUILD_MANAGER_MODE and settings.mode ~= MANUAL_MODE then
    settings.mode = GUILD_MANAGER_MODE
  end
  if type(settings.manual) ~= "table" then settings.manual = {} end
  for _, definition in ipairs(GROUPS) do
    settings.manual[definition.key] = tostring(settings.manual[definition.key] or "")
  end
  settings.sourceRevision = tonumber(settings.sourceRevision) or 0
  settings.status = tostring(settings.status or "")
  settings.statusTone = settings.statusTone or "muted"
  return storage, settings
end

local function ParsePlayers(value)
  local players, seen = {}, {}
  for token in tostring(value or ""):gmatch("[^,;%s]+") do
    local name = ShortPlayerName(token)
    local key = PlayerKey(name)
    if name and key ~= "" and not seen[key] then
      if #name > 48 then return nil, "Player names must not exceed 48 characters." end
      if #players >= 6 then return nil, "Each Illidan Phase 2 group supports at most 6 players." end
      seen[key] = true
      players[#players + 1] = name
    end
  end
  return players
end

local function CacheSnapshot(owner, snapshot)
  owner.illidanPhase2AssignmentsSnapshot = snapshot
  Public.snapshot = snapshot
  return snapshot
end

local function ScanSnapshot(owner, snapshot, force)
  local weakAuras = _G.WeakAuras
  if type(weakAuras) ~= "table" or type(weakAuras.ScanEvents) ~= "function" then return false end
  local signature = SnapshotSignature(snapshot)
  if not force and owner.illidanPhase2PublishedSignature == signature then return false end
  weakAuras.ScanEvents(EVENT_NAME, snapshot)
  owner.illidanPhase2PublishedSignature = signature
  return true
end

local function ClearCachedSnapshot(owner, reason, publish)
  owner.illidanPhase2AssignmentsSnapshot = nil
  owner.illidanPhase2PublishedSignature = nil
  Public.snapshot = nil
  if publish then
    local snapshot = CacheSnapshot(owner, NewSnapshot(
      { mode = owner:GetIllidanPhase2AssignmentMode() }, false, reason
    ))
    ScanSnapshot(owner, snapshot, true)
  end
end

function MerfinPlus:GetIllidanPhase2AssignmentMode()
  local _, settings = AssignmentStorage(self)
  return settings.mode
end

function MerfinPlus:GetIllidanPhase2SourceRevision()
  local _, settings = AssignmentStorage(self)
  return settings.sourceRevision
end

function MerfinPlus:SetIllidanPhase2AssignmentMode(mode)
  if mode ~= GUILD_MANAGER_MODE and mode ~= MANUAL_MODE then return false end
  local _, settings = AssignmentStorage(self)
  if settings.mode == mode then return false end
  settings.mode = mode
  settings.status = ""
  settings.sourceRevision = settings.sourceRevision + 1
  self:EndIllidanPhase2AssignmentsEncounter()
  ClearCachedSnapshot(self, "source-switch", true)
  return true
end

function MerfinPlus:GetIllidanPhase2ManualGroup(groupKey)
  local definition = GroupDefinition(groupKey)
  if not definition then return "" end
  local _, settings = AssignmentStorage(self)
  return settings.manual[definition.key]
end

function MerfinPlus:SetIllidanPhase2ManualGroup(groupKey, value)
  local definition = GroupDefinition(groupKey)
  if not definition then return false end
  local _, settings = AssignmentStorage(self)
  value = tostring(value or "")
  if settings.manual[definition.key] == value then return false end
  settings.manual[definition.key] = value
  settings.sourceRevision = settings.sourceRevision + 1
  if settings.mode == MANUAL_MODE then ClearCachedSnapshot(self, "manual-edit", true) end
  return true
end

function MerfinPlus:SetIllidanPhase2AssignmentsStatus(text, tone)
  local _, settings = AssignmentStorage(self)
  settings.status = tostring(text or "")
  settings.statusTone = tone or "muted"
end

function MerfinPlus:GetIllidanPhase2AssignmentsStatus()
  local _, settings = AssignmentStorage(self)
  return settings.status, settings.statusTone
end

local function SectionMatches(section, definition)
  local sourceKey = NormalizeKey(section and section.sourceName)
  local nameKey = NormalizeKey(section and section.name)
  for _, name in ipairs(definition.sectionNames) do
    local wanted = NormalizeKey(name)
    if sourceKey == wanted or nameKey == wanted then return true end
  end
  return false
end

local function TaskMatches(task, definition)
  local keys = { task and task.assignmentKey, task and task.sectionName, task and task.phase }
  for _, value in ipairs(keys) do
    local normalized = NormalizeKey(value)
    for _, name in ipairs(definition.sectionNames) do
      if normalized ~= "" and normalized == NormalizeKey(name) then return true end
    end
  end
  return false
end

local function CollectPlayers(boss, definition)
  local candidates, sequence = {}, 0
  local function Add(task)
    local player = ShortPlayerName(task and task.player)
    if not player then return end
    sequence = sequence + 1
    candidates[#candidates + 1] = {
      name = player,
      slot = tonumber(task and task.slot) or 0,
      sequence = sequence,
    }
  end
  for _, task in ipairs(type(boss and boss.v2Assignments) == "table" and boss.v2Assignments or {}) do
    if TaskMatches(task, definition) then Add(task) end
  end
  for _, section in ipairs(type(boss and boss.sections) == "table" and boss.sections or {}) do
    if SectionMatches(section, definition) then
      for _, task in ipairs(type(section.rows) == "table" and section.rows or {}) do Add(task) end
    end
  end
  table.sort(candidates, function(left, right)
    local leftSlotted, rightSlotted = left.slot > 0, right.slot > 0
    if leftSlotted ~= rightSlotted then return leftSlotted end
    if leftSlotted and left.slot ~= right.slot then return left.slot < right.slot end
    return left.sequence < right.sequence
  end)
  local players, seen = {}, {}
  for _, candidate in ipairs(candidates) do
    local key = PlayerKey(candidate.name)
    if key ~= "" and not seen[key] then
      seen[key] = true
      players[#players + 1] = candidate.name
      if #players == 6 then break end
    end
  end
  return players
end

local function ResolvePersonalBoss(owner)
  if type(owner.GetActivePersonalRaidAssignmentImport) ~= "function"
    or type(owner.GetRaidAssignmentBoss) ~= "function" then return nil end
  local entry = owner:GetActivePersonalRaidAssignmentImport()
  local boss = entry and entry.parsed and owner:GetRaidAssignmentBoss(entry.parsed, BOSS.catalogBoss)
  return boss and entry or nil, boss
end

local function ResolvePersistentBoss(owner)
  if type(owner.GetRaidAssignmentImportForGroup) ~= "function"
    or type(owner.GetRaidAssignmentBoss) ~= "function" then return nil end
  local entry = owner:GetRaidAssignmentImportForGroup(RAID_GROUP_ID)
  local boss = entry and entry.parsed and owner:GetRaidAssignmentBoss(entry.parsed, BOSS.catalogBoss)
  return boss and entry or nil, boss
end

function MerfinPlus:BuildGuildManagerIllidanPhase2Snapshot(preferPersonal)
  local entry, boss
  if preferPersonal then entry, boss = ResolvePersonalBoss(self) end
  if not boss then entry, boss = ResolvePersistentBoss(self) end
  if not boss and not preferPersonal then entry, boss = ResolvePersonalBoss(self) end
  local snapshot = NewSnapshot(BuildSource(entry, GUILD_MANAGER_MODE), false)
  local total = 0
  if boss then
    for index, definition in ipairs(GROUPS) do
      local players = CollectPlayers(boss, definition)
      snapshot.groups[index].players = players
      total = total + #players
    end
  end
  snapshot.available = boss ~= nil and total > 0
  return snapshot
end

function MerfinPlus:BuildManualIllidanPhase2Snapshot()
  local _, settings = AssignmentStorage(self)
  local snapshot = NewSnapshot({ mode = MANUAL_MODE }, false)
  local total = 0
  for index, definition in ipairs(GROUPS) do
    local players, parseError = ParsePlayers(settings.manual[definition.key])
    if not players then return nil, parseError end
    snapshot.groups[index].players = players
    total = total + #players
  end
  if total == 0 then return nil, "Illidan Phase 2 requires at least one assigned player." end
  snapshot.available = true
  return snapshot
end

function MerfinPlus:NormalizeIllidanPhase2AssignmentsSnapshot(snapshot, forcedMode)
  if type(snapshot) ~= "table" or snapshot.schema ~= "merfinplus.illidan.phase2.assignments"
    or tonumber(snapshot.version) ~= SNAPSHOT_VERSION or not IsIllidan(snapshot.bossKey
      or (type(snapshot.encounter) == "table" and snapshot.encounter.key)) then
    return nil, "Illidan Phase 2 assignment snapshot contract is invalid."
  end
  local mode = forcedMode or (snapshot.source and snapshot.source.mode)
  if mode == "weak-aura-manual" then mode = MANUAL_MODE end
  if mode ~= GUILD_MANAGER_MODE and mode ~= MANUAL_MODE then
    return nil, "Illidan Phase 2 assignment snapshot source is invalid."
  end
  local normalized = NewSnapshot(CopySource(snapshot.source, mode), snapshot.available == true)
  local sourceByKey = {}
  for index, group in ipairs(type(snapshot.groups) == "table" and snapshot.groups or {}) do
    local definition = GroupDefinition(group)
    if not definition then definition = GROUPS[index] end
    if definition then sourceByKey[definition.key] = group end
  end
  local total = 0
  for index, definition in ipairs(GROUPS) do
    local source = sourceByKey[definition.key]
    local players, seen = {}, {}
    for _, value in ipairs(type(source) == "table" and source.players or {}) do
      local name = ShortPlayerName(type(value) == "table" and value.name or value)
      local key = PlayerKey(name)
      if not name or key == "" or #name > 48 then
        return nil, "Illidan Phase 2 assignment snapshot contains invalid players."
      end
      if not seen[key] then
        if #players >= 6 then
          return nil, "Each Illidan Phase 2 group supports at most 6 players."
        end
        seen[key] = true
        players[#players + 1] = name
      end
    end
    normalized.groups[index].players = players
    total = total + #players
  end
  normalized.available = snapshot.available == true and total > 0
  return normalized
end

function MerfinPlus:GetIllidanPhase2AssignmentsSnapshot()
  return self.illidanPhase2AssignmentsSnapshot or CacheSnapshot(self, NewSnapshot(
    { mode = self:GetIllidanPhase2AssignmentMode() }, false, "not-synced"
  ))
end

function MerfinPlus:PublishIllidanPhase2AssignmentsSnapshot(snapshot, force)
  CacheSnapshot(self, snapshot)
  return ScanSnapshot(self, snapshot, force)
end

function MerfinPlus:PublishReceivedIllidanPhase2ManualSnapshot(snapshot, sender)
  local normalized = self:NormalizeIllidanPhase2AssignmentsSnapshot(snapshot)
  if not normalized then return false end
  normalized.source.sender = tostring(sender or "")
  if normalized.source.mode == MANUAL_MODE then normalized.source.mode = "weak-aura-manual" end
  self:PublishIllidanPhase2AssignmentsSnapshot(normalized, true)
  local state = self.illidanPhase2EncounterState
  if state and state.active then
    self:RecordIllidanPhase2SyncSuccess(
      normalized.source.mode == "weak-aura-manual" and MANUAL_MODE or GUILD_MANAGER_MODE,
      "received-assignment-sync"
    )
  end
  return true
end

function MerfinPlus:CanBroadcastIllidanPhase2Assignments()
  if type(self.CanBroadcastRaidAssignments) ~= "function" then
    return false, "Illidan Phase 2 assignment sync is unavailable."
  end
  return self:CanBroadcastRaidAssignments()
end

function MerfinPlus:GetIllidanCatalogBoss()
  if type(self.GetRaidAssignmentGroup) ~= "function" then return nil end
  local group = self:GetRaidAssignmentGroup(RAID_GROUP_ID)
  for _, raid in ipairs(group and group.raids or {}) do
    for _, boss in ipairs(raid.bosses or {}) do
      if IsIllidan(boss) then return boss end
    end
  end
end

function MerfinPlus:RecordIllidanPhase2SyncSuccess(mode, trigger)
  local state = self.illidanPhase2EncounterState
  self.illidanPhase2LastSuccessfulSync = {
    mode = mode,
    trigger = trigger,
    generation = state and state.active and state.generation or nil,
    sourceRevision = self:GetIllidanPhase2SourceRevision(),
    time = (GetServerTime and GetServerTime()) or (time and time()) or 0,
  }
  if state and state.active and state.sourceRevision == self:GetIllidanPhase2SourceRevision() then
    state.succeededGeneration = state.generation
  end
end

function MerfinPlus:MaybeBroadcastIllidanPhase2AssignmentsForBoss(catalogBoss)
  if not IsIllidan(catalogBoss) then
    self:EndIllidanPhase2AssignmentsEncounter()
    ClearCachedSnapshot(self, "other-boss-sync", true)
    return false, { skipped = true, reason = "not-illidan" }
  end
  if self:GetIllidanPhase2AssignmentMode() ~= GUILD_MANAGER_MODE then
    return false, { skipped = true, reason = "manual-mode" }
  end
  local snapshot = self:BuildGuildManagerIllidanPhase2Snapshot(false)
  local normalized, normalizeError = self:NormalizeIllidanPhase2AssignmentsSnapshot(snapshot, GUILD_MANAGER_MODE)
  if not normalized or not normalized.available then
    local reason = normalizeError or "Illidan has no Guild Manager Phase 2 group assignments."
    self:SetIllidanPhase2AssignmentsStatus(reason, "red")
    return false, reason
  end
  self:PublishIllidanPhase2AssignmentsSnapshot(normalized, true)
  self:RecordIllidanPhase2SyncSuccess(GUILD_MANAGER_MODE, "boss-assignments")
  self:SetIllidanPhase2AssignmentsStatus(
    "Illidan Phase 2 groups synced with the boss assignments.", "green"
  )
  return true, { mode = GUILD_MANAGER_MODE, piggyback = true, bossKey = BOSS.key }
end

function MerfinPlus:RecordReceivedIllidanPhase2AssignmentsForBoss(catalogBoss, sender)
  if not IsIllidan(catalogBoss) then
    self:EndIllidanPhase2AssignmentsEncounter()
    ClearCachedSnapshot(self, "other-boss-sync", true)
    return false
  end
  local snapshot = self:BuildGuildManagerIllidanPhase2Snapshot(true)
  local normalized = self:NormalizeIllidanPhase2AssignmentsSnapshot(snapshot, GUILD_MANAGER_MODE)
  if not normalized or not normalized.available then
    ClearCachedSnapshot(self, "received-illidan-without-phase2-groups", true)
    return false
  end
  normalized.source.sender = tostring(sender or "")
  self:PublishIllidanPhase2AssignmentsSnapshot(normalized, true)
  self:RecordIllidanPhase2SyncSuccess(GUILD_MANAGER_MODE, "received-boss-assignments")
  self:SetIllidanPhase2AssignmentsStatus(
    "Illidan Phase 2 groups received from " .. tostring(sender or "") .. ".", "green"
  )
  return true
end

function MerfinPlus:SyncGuildManagerIllidanPhase2Assignments(trigger)
  local catalogBoss = self:GetIllidanCatalogBoss()
  if not catalogBoss or type(self.BroadcastPersonalRaidAssignments) ~= "function" then
    local reason = "Illidan boss assignment sync is unavailable."
    self:SetIllidanPhase2AssignmentsStatus(reason, "red")
    return false, reason
  end
  local sent, metrics = self:BroadcastPersonalRaidAssignments(catalogBoss, false, RAID_GROUP_ID)
  if not sent then
    self:SetIllidanPhase2AssignmentsStatus(
      metrics or "Illidan boss assignments could not be synced.", "red"
    )
  elseif type(metrics) == "table" then
    metrics.illidanPhase2Trigger = trigger
  end
  return sent, metrics
end

function MerfinPlus:BroadcastActiveIllidanPhase2Assignments(trigger)
  local allowed, reason = self:CanBroadcastIllidanPhase2Assignments()
  if not allowed then self:SetIllidanPhase2AssignmentsStatus(reason, "red"); return false, reason end
  local mode = self:GetIllidanPhase2AssignmentMode()
  if mode == GUILD_MANAGER_MODE then return self:SyncGuildManagerIllidanPhase2Assignments(trigger) end
  local snapshot, buildError = self:BuildManualIllidanPhase2Snapshot()
  if not snapshot then self:SetIllidanPhase2AssignmentsStatus(buildError, "red"); return false, buildError end
  local normalized, normalizeError = self:NormalizeIllidanPhase2AssignmentsSnapshot(snapshot, MANUAL_MODE)
  if not normalized then self:SetIllidanPhase2AssignmentsStatus(normalizeError, "red"); return false, normalizeError end
  if type(self.BroadcastIllidanPhase2AssignmentsSnapshot) ~= "function" then
    reason = "Illidan Phase 2 assignment transport is unavailable."
    self:SetIllidanPhase2AssignmentsStatus(reason, "red")
    return false, reason
  end
  local sent, metrics = self:BroadcastIllidanPhase2AssignmentsSnapshot(normalized, MANUAL_MODE, trigger)
  if sent then
    self:RecordIllidanPhase2SyncSuccess(MANUAL_MODE, trigger)
    self:SetIllidanPhase2AssignmentsStatus("Illidan Phase 2 manual groups synced.", "green")
  else
    self:SetIllidanPhase2AssignmentsStatus(
      metrics or "Illidan Phase 2 manual groups could not be synced.", "red"
    )
  end
  return sent, metrics
end

function MerfinPlus:SyncManualIllidanPhase2Assignments()
  if self:GetIllidanPhase2AssignmentMode() ~= MANUAL_MODE then
    local reason = "Use Manual Groups must be active before manual assignments can be synced."
    self:SetIllidanPhase2AssignmentsStatus(reason, "red")
    return false, reason
  end
  return self:BroadcastActiveIllidanPhase2Assignments("manual-button")
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

function MerfinPlus:TryAutomaticIllidanPhase2AssignmentsSync()
  local state = self.illidanPhase2EncounterState
  if not state or not state.active
    or state.sourceRevision ~= self:GetIllidanPhase2SourceRevision()
    or state.succeededGeneration == state.generation or not state.senderRole then return false end
  local allowed = self:CanBroadcastIllidanPhase2Assignments()
  if not allowed then return false end
  return self:BroadcastActiveIllidanPhase2Assignments("pull-emergency")
end

function MerfinPlus:BeginIllidanPhase2AssignmentsEncounter(forceNewGeneration)
  local state = self.illidanPhase2EncounterState
  if state and state.active and forceNewGeneration ~= true then return false end
  local generation = (self.illidanPhase2EncounterGeneration or 0) + 1
  self.illidanPhase2EncounterGeneration = generation
  state = {
    active = true,
    generation = generation,
    sourceRevision = self:GetIllidanPhase2SourceRevision(),
    senderRole = AutomaticSenderRole(),
  }
  self.illidanPhase2EncounterState = state
  local function TrySync()
    local current = self.illidanPhase2EncounterState
    if current == state and current.active and current.generation == generation
      and current.sourceRevision == self:GetIllidanPhase2SourceRevision() then
      self:TryAutomaticIllidanPhase2AssignmentsSync()
    end
  end
  if C_Timer and type(C_Timer.After) == "function" then
    local assistant = state.senderRole == "assistant"
    C_Timer.After(assistant and 2.5 or 0.5, TrySync)
    C_Timer.After(assistant and 4 or 1.5, TrySync)
  else
    TrySync()
  end
  return true
end

function MerfinPlus:EndIllidanPhase2AssignmentsEncounter()
  local state = self.illidanPhase2EncounterState
  if not state then return false end
  state.active = nil
  state.senderRole = nil
  self.illidanPhase2EncounterState = nil
  return true
end

function MerfinPlus:HandleIllidanPhase2EncounterEnd(success)
  self:EndIllidanPhase2AssignmentsEncounter()
  if success == true or tonumber(success) == 1 then
    ClearCachedSnapshot(self, "successful-encounter-completion", true)
    return true
  end
  return false
end

local function NPCIDFromGUID(guid)
  if type(guid) ~= "string" then return nil end
  return guid:match("^[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-([^%-]+)")
end

function MerfinPlus:IsIllidanEngaged()
  local function Match(unit)
    return NPCIDFromGUID(UnitGUID and UnitGUID(unit)) == BOSS.npcID
      and not (UnitIsDeadOrGhost and UnitIsDeadOrGhost(unit))
  end
  for index = 1, 5 do if Match("boss" .. index) then return true end end
  return Match("target") or Match("focus")
end

function MerfinPlus:InitializeIllidanPhase2PullSync()
  if self.illidanPhase2PullSyncInitialized or not CreateFrame then return end
  self.illidanPhase2PullSyncInitialized = true
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ENCOUNTER_START")
  frame:RegisterEvent("ENCOUNTER_END")
  frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:SetScript("OnEvent", function(_, event, encounterID, encounterName, difficultyID, groupSize, success)
    if event == "ENCOUNTER_START" then
      if tonumber(encounterID) == BOSS.encounterID then self:BeginIllidanPhase2AssignmentsEncounter(true) end
      return
    end
    if event == "ENCOUNTER_END" then
      if tonumber(encounterID) == BOSS.encounterID then self:HandleIllidanPhase2EncounterEnd(success) end
      return
    end
    if event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
      if self:IsIllidanEngaged() then self:BeginIllidanPhase2AssignmentsEncounter() end
      return
    end
    if event == "PLAYER_REGEN_DISABLED" then
      local function Probe()
        if self:IsIllidanEngaged() then self:BeginIllidanPhase2AssignmentsEncounter() end
      end
      if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0.5, Probe)
        C_Timer.After(1.5, Probe)
      else
        Probe()
      end
      return
    end
    if event == "PLAYER_REGEN_ENABLED" and self.illidanPhase2EncounterState then
      local function EndIfGone()
        if not self:IsIllidanEngaged() then self:EndIllidanPhase2AssignmentsEncounter() end
      end
      if C_Timer and type(C_Timer.After) == "function" then C_Timer.After(0.5, EndIfGone) else EndIfGone() end
    end
  end)
  self.illidanPhase2PullSyncFrame = frame
end

function MerfinPlus:InvalidateIllidanPhase2Assignments(reason)
  if self:GetIllidanPhase2AssignmentMode() == GUILD_MANAGER_MODE then
    ClearCachedSnapshot(self, reason or "assignment-source-changed", true)
  end
end

function MerfinPlus:InitializeIllidanPhase2AssignmentsBridge()
  if self.illidanPhase2AssignmentsBridgeInitialized then return end
  self.illidanPhase2AssignmentsBridgeInitialized = true
  self:InitializeIllidanPhase2PullSync()
  ScanSnapshot(self, self:GetIllidanPhase2AssignmentsSnapshot(), true)
end

MerfinPlus.ILLIDAN_PHASE2_ASSIGNMENTS_EVENT = EVENT_NAME
MerfinPlus.ILLIDAN_PHASE2_ASSIGNMENTS_SNAPSHOT_VERSION = SNAPSHOT_VERSION
MerfinPlus.ILLIDAN_PHASE2_ASSIGNMENTS_GUILD_MANAGER_MODE = GUILD_MANAGER_MODE
MerfinPlus.ILLIDAN_PHASE2_ASSIGNMENTS_MANUAL_MODE = MANUAL_MODE
MerfinPlus.ILLIDAN_PHASE2_ASSIGNMENTS_ICON = BOSS.icon
MerfinPlus.ILLIDAN_PHASE2_ASSIGNMENTS_GROUPS = GROUPS

Public.schema = "merfinplus.illidan.phase2.bridge"
Public.version = 1
Public.snapshotVersion = SNAPSHOT_VERSION
Public.event = EVENT_NAME
Public.GetSnapshot = function() return MerfinPlus:GetIllidanPhase2AssignmentsSnapshot() end
Public.BroadcastManualGroups = function(snapshot)
  if type(MerfinPlus.BroadcastIllidanPhase2AssignmentsSnapshot) ~= "function" then
    return false, "Illidan Phase 2 assignment transport is unavailable."
  end
  return MerfinPlus:BroadcastIllidanPhase2AssignmentsSnapshot(snapshot, MANUAL_MODE, "legacy-manual")
end
if type(Merfin) == "table" then
  Merfin.GetIllidanPhase2AssignmentsSnapshot = Public.GetSnapshot
  Merfin.BroadcastIllidanPhase2ManualGroups = Public.BroadcastManualGroups
end

if type(MerfinPlus.NotifyRaidAssignmentsChanged) == "function" then
  hooksecurefunc(MerfinPlus, "NotifyRaidAssignmentsChanged", function(owner)
    owner:InvalidateIllidanPhase2Assignments("assignment-source-changed")
  end)
end
if type(MerfinPlus.InitializeRaidAssignments) == "function" then
  hooksecurefunc(MerfinPlus, "InitializeRaidAssignments", function(owner)
    owner:InitializeIllidanPhase2AssignmentsBridge()
  end)
end
