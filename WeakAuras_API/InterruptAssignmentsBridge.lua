local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local EVENT_NAME = "MERFINPLUS_INTERRUPT_ASSIGNMENTS_UPDATED"
local SNAPSHOT_VERSION = 2
local RAID_GROUP_ID = "bt_mh"
local GUILD_MANAGER_MODE = "guild-manager"
local MANUAL_MODE = "manual"
local PUBLIC_NAME = "MerfinPlusInterruptAssignments"
local Public = _G[PUBLIC_NAME]
if type(Public) ~= "table" then
  Public = {}
  _G[PUBLIC_NAME] = Public
end
Public.snapshots = type(Public.snapshots) == "table" and Public.snapshots or {}

local BOSSES = {
  reliquary = {
    key = "reliquary",
    label = "Reliquary of Souls",
    encounterID = 606,
    npcID = "23419",
    aliases = { "ReliqoftheLost", "reliquary_of_souls" },
    icon = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\bosses\\tbc\\catalog\\black-temple\\reliquary-of-souls\\primary.blp",
    catalogBoss = { key = "reliquary_of_souls", name = "Reliquary of Souls", raidKey = "black_temple" },
    fields = {
      {
        key = "spiritShock",
        label = "Spirit Shock Interrupt",
        spellID = 41426,
        assignmentKey = "reliquaryspiritshockinterrupts",
        sectionNames = { "Spirit Shock Interrupt Rotation", "Spirit Shock Interrupt" },
        rotation = true,
      },
      {
        key = "runeShield",
        label = "Rune Shield Spell Steal",
        spellID = 41431,
        assignmentKey = "runeshieldspellsteal",
        sectionNames = { "Rune Shield Spell Steal" },
      },
      {
        key = "seethe",
        label = "Seethe Tranq Shot",
        spellID = 41520,
        assignmentKey = "seethetranqshot",
        sectionNames = { "Seethe Tranq Shot" },
      },
    },
  },
  council = {
    key = "council",
    label = "The Illidari Council",
    encounterID = 608,
    npcID = "22951",
    aliases = { "IllidariCouncil", "illidari_council" },
    icon = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\bosses\\tbc\\catalog\\black-temple\\illidari-council\\primary.blp",
    catalogBoss = { key = "illidari_council", name = "The Illidari Council", raidKey = "black_temple" },
    fields = {
      {
        key = "prayerOfHealing",
        label = "Prayer of Healing",
        spellID = 41455,
        assignmentKey = "councilmalandeinterrupts",
        sectionNames = {
          "Lady Malande Circle of Healing Interrupts",
          "Lady Malande Interrupts",
          "Prayer of Healing",
        },
        rotation = true,
      },
    },
  },
}
local BOSS_ORDER = { "reliquary", "council" }

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

local function CopySource(source, mode)
  local result = {}
  for key, value in pairs(type(source) == "table" and source or {}) do
    if type(value) ~= "table" then result[key] = value end
  end
  result.mode = mode
  return result
end

local function BossDefinition(value)
  if type(value) == "table" then value = value.key or value.name or value.encounterID end
  local numeric = tonumber(value)
  local normalized = NormalizeKey(value)
  for _, key in ipairs(BOSS_ORDER) do
    local definition = BOSSES[key]
    local aliasMatch = false
    for _, alias in ipairs(definition.aliases or {}) do
      if normalized == NormalizeKey(alias) then aliasMatch = true break end
    end
    if numeric == definition.encounterID or aliasMatch
      or normalized == NormalizeKey(key)
      or normalized == NormalizeKey(definition.label)
      or normalized == NormalizeKey(definition.catalogBoss.key)
      or normalized == NormalizeKey(definition.catalogBoss.name) then
      return definition
    end
  end
end

local function FieldDefinition(boss, fieldKey)
  for _, field in ipairs(boss and boss.fields or {}) do
    if field.key == fieldKey then return field end
  end
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

local function NewSnapshot(definition, source, available, reason)
  local snapshot = {
    schema = "merfinplus.interrupt.assignments",
    version = SNAPSHOT_VERSION,
    available = available == true,
    bossKey = definition.key,
    encounter = {
      key = definition.key,
      name = definition.label,
      encounterID = definition.encounterID,
      raidKey = "black_temple",
    },
    source = source or { mode = GUILD_MANAGER_MODE },
    assignments = {},
    rotations = {},
  }
  if reason then snapshot.source.reason = reason end
  for _, field in ipairs(definition.fields) do
    local assignment = {
      key = field.key,
      label = field.label,
      spellID = field.spellID,
      players = {},
    }
    snapshot.assignments[field.key] = assignment
    if field.rotation then
      snapshot.rotations[definition.key] = {
        key = definition.key,
        label = field.label,
        spellID = field.spellID,
        players = assignment.players,
        groups = {},
      }
    end
  end
  return snapshot
end

local function SnapshotSignature(snapshot)
  local parts = {
    tostring(snapshot.version or ""),
    snapshot.available and "1" or "0",
    tostring(snapshot.bossKey or ""),
    tostring(snapshot.source and snapshot.source.mode or ""),
    tostring(snapshot.source and snapshot.source.importId or ""),
    tostring(snapshot.source and snapshot.source.contentSignature or ""),
    tostring(snapshot.source and snapshot.source.reason or ""),
  }
  local definition = BossDefinition(snapshot.bossKey)
  for _, field in ipairs(definition and definition.fields or {}) do
    local assignment = snapshot.assignments and snapshot.assignments[field.key]
    parts[#parts + 1] = field.key
    for _, player in ipairs(assignment and assignment.players or {}) do
      parts[#parts + 1] = PlayerKey(player)
    end
    if field.rotation then
      local rotation = snapshot.rotations and snapshot.rotations[definition.key]
      for _, group in ipairs(rotation and rotation.groups or {}) do
        parts[#parts + 1] = "group"
        for _, player in ipairs(group) do parts[#parts + 1] = PlayerKey(player) end
      end
    end
  end
  return table.concat(parts, "\31")
end

local function ParseManualPlayerGroups(value)
  local groups, players = {}, {}
  value = tostring(value or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
  for line in (value .. "\n"):gmatch("(.-)\n") do
    local group = {}
    for token in line:gmatch("[^,;%s]+") do
      local name = ShortPlayerName(token)
      if name and name ~= "" then
        if #name > 48 then return nil, nil, "Player names must not exceed 48 characters." end
        if #players >= 10 then return nil, nil, "Each assignment supports at most 10 players." end
        group[#group + 1] = name
        players[#players + 1] = name
      end
    end
    if #group > 0 then groups[#groups + 1] = group end
  end
  return groups, players
end

local function ParseManualPlayerNames(value, allowDuplicates)
  local players, seen = {}, {}
  for token in tostring(value or ""):gmatch("[^,;%s]+") do
    local name = ShortPlayerName(token)
    local key = PlayerKey(name)
    if name and key ~= "" and (allowDuplicates or not seen[key]) then
      if #name > 48 then return nil, "Player names must not exceed 48 characters." end
      if #players >= 10 then return nil, "Each assignment supports at most 10 players." end
      seen[key] = true
      players[#players + 1] = name
    end
  end
  return players
end

local function AssignmentStorage(owner)
  local storage = owner:GetRaidAssignmentStorage()
  if type(storage.interruptAssignments) ~= "table" then storage.interruptAssignments = {} end
  for _, key in ipairs(BOSS_ORDER) do
    local settings = storage.interruptAssignments[key]
    if type(settings) ~= "table" then
      settings = {}
      storage.interruptAssignments[key] = settings
    end
    if settings.mode ~= GUILD_MANAGER_MODE and settings.mode ~= MANUAL_MODE then
      settings.mode = GUILD_MANAGER_MODE
    end
    if type(settings.manual) ~= "table" then settings.manual = {} end
    for _, field in ipairs(BOSSES[key].fields) do
      settings.manual[field.key] = tostring(settings.manual[field.key] or "")
    end
    settings.sourceRevision = tonumber(settings.sourceRevision) or 0
    settings.status = tostring(settings.status or "")
    settings.statusTone = settings.statusTone or "muted"
  end
  return storage, storage.interruptAssignments
end

local function CacheSnapshot(owner, definition, snapshot)
  owner.interruptAssignmentsSnapshots = type(owner.interruptAssignmentsSnapshots) == "table"
    and owner.interruptAssignmentsSnapshots or {}
  owner.interruptAssignmentsSnapshots[definition.key] = snapshot
  Public.snapshots[definition.key] = snapshot
  Public.snapshot = snapshot
  return snapshot
end

local function ScanSnapshot(owner, definition, snapshot, force)
  local weakAuras = _G.WeakAuras
  if type(weakAuras) ~= "table" or type(weakAuras.ScanEvents) ~= "function" then return false end
  owner.interruptAssignmentsPublishedSignatures = type(owner.interruptAssignmentsPublishedSignatures) == "table"
    and owner.interruptAssignmentsPublishedSignatures or {}
  local signature = SnapshotSignature(snapshot)
  if not force and owner.interruptAssignmentsPublishedSignatures[definition.key] == signature then return false end
  weakAuras.ScanEvents(EVENT_NAME, snapshot)
  owner.interruptAssignmentsPublishedSignatures[definition.key] = signature
  return true
end

local function ClearCachedSnapshot(owner, definition, reason, publish)
  owner.interruptAssignmentsSnapshots = type(owner.interruptAssignmentsSnapshots) == "table"
    and owner.interruptAssignmentsSnapshots or {}
  owner.interruptAssignmentsPublishedSignatures = type(owner.interruptAssignmentsPublishedSignatures) == "table"
    and owner.interruptAssignmentsPublishedSignatures or {}
  owner.interruptAssignmentsSnapshots[definition.key] = nil
  owner.interruptAssignmentsPublishedSignatures[definition.key] = nil
  Public.snapshots[definition.key] = nil
  if publish then
    local snapshot = CacheSnapshot(owner, definition, NewSnapshot(
      definition,
      { mode = owner:GetInterruptAssignmentMode(definition.key) },
      false,
      reason
    ))
    ScanSnapshot(owner, definition, snapshot, true)
  end
end

function MerfinPlus:GetInterruptAssignmentMode(bossKey)
  local definition = BossDefinition(bossKey)
  if not definition then return nil end
  local _, settings = AssignmentStorage(self)
  return settings[definition.key].mode
end

function MerfinPlus:GetInterruptAssignmentSourceRevision(bossKey)
  local definition = BossDefinition(bossKey)
  if not definition then return 0 end
  local _, settings = AssignmentStorage(self)
  return settings[definition.key].sourceRevision
end

function MerfinPlus:SetInterruptAssignmentMode(bossKey, mode)
  local definition = BossDefinition(bossKey)
  if not definition or (mode ~= GUILD_MANAGER_MODE and mode ~= MANUAL_MODE) then return false end
  local _, settings = AssignmentStorage(self)
  local setting = settings[definition.key]
  if setting.mode == mode then return false end
  setting.mode = mode
  setting.status = ""
  setting.sourceRevision = setting.sourceRevision + 1
  self:EndInterruptAssignmentsEncounter(definition.key)
  ClearCachedSnapshot(self, definition, "source-switch", true)
  return true
end

function MerfinPlus:GetInterruptManualAssignment(bossKey, fieldKey)
  local definition = BossDefinition(bossKey)
  if not definition or not FieldDefinition(definition, fieldKey) then return "" end
  local _, settings = AssignmentStorage(self)
  return settings[definition.key].manual[fieldKey]
end

function MerfinPlus:SetInterruptManualAssignment(bossKey, fieldKey, value)
  local definition = BossDefinition(bossKey)
  if not definition or not FieldDefinition(definition, fieldKey) then return false end
  local _, settings = AssignmentStorage(self)
  local setting = settings[definition.key]
  value = tostring(value or "")
  if setting.manual[fieldKey] == value then return false end
  setting.manual[fieldKey] = value
  setting.sourceRevision = setting.sourceRevision + 1
  if setting.mode == MANUAL_MODE then ClearCachedSnapshot(self, definition, "manual-edit", true) end
  return true
end

function MerfinPlus:SetInterruptAssignmentsStatus(bossKey, text, tone)
  local definition = BossDefinition(bossKey)
  if not definition then return end
  local _, settings = AssignmentStorage(self)
  settings[definition.key].status = tostring(text or "")
  settings[definition.key].statusTone = tone or "muted"
end

function MerfinPlus:GetInterruptAssignmentsStatus(bossKey)
  local definition = BossDefinition(bossKey)
  if not definition then return "", "muted" end
  local _, settings = AssignmentStorage(self)
  local setting = settings[definition.key]
  return setting.status, setting.statusTone
end

local function SectionMatches(section, field)
  local sourceKey = NormalizeKey(section and section.sourceName)
  local nameKey = NormalizeKey(section and section.name)
  if sourceKey == NormalizeKey(field.assignmentKey) then return true end
  for _, name in ipairs(field.sectionNames or {}) do
    local wanted = NormalizeKey(name)
    if sourceKey == wanted or nameKey == wanted then return true end
  end
  return false
end

local function CollectPlayers(boss, field)
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
    if NormalizeKey(task.assignmentKey) == NormalizeKey(field.assignmentKey) then Add(task) end
  end
  for _, section in ipairs(type(boss and boss.sections) == "table" and boss.sections or {}) do
    if SectionMatches(section, field) then
      for _, task in ipairs(type(section.rows) == "table" and section.rows or {}) do Add(task) end
    end
  end
  table.sort(candidates, function(left, right)
    local leftSlotted, rightSlotted = left.slot > 0, right.slot > 0
    if leftSlotted ~= rightSlotted then return leftSlotted end
    if leftSlotted and left.slot ~= right.slot then return left.slot < right.slot end
    return left.sequence < right.sequence
  end)
  local result, seen = {}, {}
  for _, candidate in ipairs(candidates) do
    local key = PlayerKey(candidate.name)
    if key ~= "" and (field.rotation or not seen[key]) then
      seen[key] = true
      result[#result + 1] = candidate.name
      if #result == 10 then break end
    end
  end
  return result
end

local function ResolvePersonalBoss(owner, definition)
  if type(owner.GetActivePersonalRaidAssignmentImport) ~= "function" then return nil end
  local entry = owner:GetActivePersonalRaidAssignmentImport()
  if not entry or not entry.parsed or type(owner.GetRaidAssignmentBoss) ~= "function" then return nil end
  local boss = owner:GetRaidAssignmentBoss(entry.parsed, definition.catalogBoss)
  return boss and entry or nil, boss
end

local function ResolvePersistentBoss(owner, definition)
  if type(owner.GetRaidAssignmentImportForGroup) ~= "function"
    or type(owner.GetRaidAssignmentBoss) ~= "function" then return nil end
  local entry = owner:GetRaidAssignmentImportForGroup(RAID_GROUP_ID)
  local boss = entry and entry.parsed and owner:GetRaidAssignmentBoss(entry.parsed, definition.catalogBoss)
  return boss and entry or nil, boss
end

function MerfinPlus:BuildGuildManagerInterruptAssignmentsSnapshot(bossKey, preferPersonal)
  local definition = BossDefinition(bossKey)
  if not definition then return nil, "Unknown interrupt assignment boss." end
  local entry, boss
  if preferPersonal then entry, boss = ResolvePersonalBoss(self, definition) end
  if not boss then entry, boss = ResolvePersistentBoss(self, definition) end
  if not boss and not preferPersonal then entry, boss = ResolvePersonalBoss(self, definition) end
  local snapshot = NewSnapshot(definition, BuildSource(entry, GUILD_MANAGER_MODE), false)
  local total = 0
  if boss then
    for _, field in ipairs(definition.fields) do
      local players = CollectPlayers(boss, field)
      snapshot.assignments[field.key].players = players
      if field.rotation then
        snapshot.rotations[definition.key].players = players
        for _, player in ipairs(players) do
          snapshot.rotations[definition.key].groups[#snapshot.rotations[definition.key].groups + 1] = { player }
        end
      end
      total = total + #players
    end
  end
  snapshot.available = boss ~= nil and total > 0
  return snapshot
end

function MerfinPlus:BuildManualInterruptAssignmentsSnapshot(bossKey)
  local definition = BossDefinition(bossKey)
  if not definition then return nil, "Unknown interrupt assignment boss." end
  local _, settings = AssignmentStorage(self)
  local snapshot = NewSnapshot(definition, { mode = MANUAL_MODE }, false)
  local total, rotationCount = 0, 0
  for _, field in ipairs(definition.fields) do
    local players, parseError
    local groups
    if field.rotation then
      groups, players, parseError = ParseManualPlayerGroups(settings[definition.key].manual[field.key])
    else
      players, parseError = ParseManualPlayerNames(settings[definition.key].manual[field.key], false)
    end
    if not players then return nil, parseError end
    snapshot.assignments[field.key].players = players
    if field.rotation then
      snapshot.rotations[definition.key].players = players
      snapshot.rotations[definition.key].groups = groups
      rotationCount = rotationCount + #players
    end
    total = total + #players
  end
  if rotationCount == 0 then
    return nil, definition.label .. " requires at least one interrupt player."
  end
  snapshot.available = total > 0
  return snapshot
end

function MerfinPlus:NormalizeInterruptAssignmentsSnapshot(snapshot, forcedMode, forcedBossKey)
  if type(snapshot) ~= "table" then return nil, "Interrupt assignment snapshot is invalid." end
  local definition = BossDefinition(forcedBossKey or snapshot.bossKey
    or (type(snapshot.encounter) == "table" and (snapshot.encounter.key or snapshot.encounter.name)))
  if not definition then return nil, "Interrupt assignment snapshot boss is invalid." end
  local version = tonumber(snapshot.version)
  if snapshot.schema ~= "merfinplus.interrupt.assignments" or (version ~= 1 and version ~= SNAPSHOT_VERSION) then
    return nil, "Interrupt assignment snapshot contract is invalid."
  end
  local mode = forcedMode or (type(snapshot.source) == "table" and snapshot.source.mode)
  if mode == "weak-aura-manual" then mode = MANUAL_MODE end
  if mode ~= GUILD_MANAGER_MODE and mode ~= MANUAL_MODE then
    return nil, "Interrupt assignment snapshot source is invalid."
  end
  local normalized = NewSnapshot(definition, CopySource(snapshot.source, mode), snapshot.available == true)
  local total, rotationCount = 0, 0
  for _, field in ipairs(definition.fields) do
    local sourceAssignment = type(snapshot.assignments) == "table" and snapshot.assignments[field.key]
    if not sourceAssignment and field.rotation and type(snapshot.rotations) == "table" then
      sourceAssignment = snapshot.rotations[definition.key]
    end
    local players, seen = {}, {}
    for _, value in ipairs(type(sourceAssignment) == "table" and sourceAssignment.players or {}) do
      local name = ShortPlayerName(type(value) == "table" and value.name or value)
      local key = PlayerKey(name)
      if not name or key == "" or #name > 48 or (seen[key] and not field.rotation) or #players >= 10 then
        return nil, "Interrupt assignment snapshot contains invalid players."
      end
      seen[key] = true
      players[#players + 1] = name
    end
    local groups = {}
    if field.rotation then
      local sourceRotation = type(snapshot.rotations) == "table" and snapshot.rotations[definition.key]
      local sourceGroups = type(sourceRotation) == "table" and sourceRotation.groups
      if type(sourceGroups) == "table" and #sourceGroups > 0 then
        players = {}
        for _, sourceGroup in ipairs(sourceGroups) do
          if type(sourceGroup) ~= "table" then
            return nil, "Interrupt assignment snapshot contains invalid groups."
          end
          local group = {}
          for _, value in ipairs(sourceGroup) do
            local name = ShortPlayerName(type(value) == "table" and value.name or value)
            if not name or name == "" or #name > 48 or #players >= 10 then
              return nil, "Interrupt assignment snapshot contains invalid groups."
            end
            group[#group + 1] = name
            players[#players + 1] = name
          end
          if #group > 0 then groups[#groups + 1] = group end
        end
      else
        for _, player in ipairs(players) do groups[#groups + 1] = { player } end
      end
    end
    normalized.assignments[field.key].players = players
    if field.rotation then
      normalized.rotations[definition.key].players = players
      normalized.rotations[definition.key].groups = groups
      rotationCount = rotationCount + #players
    end
    total = total + #players
  end
  normalized.available = snapshot.available == true and total > 0 and rotationCount > 0
  return normalized
end

function MerfinPlus:GetInterruptAssignmentsSnapshot(bossKey)
  local definition = BossDefinition(bossKey)
  if not definition then return nil end
  self.interruptAssignmentsSnapshots = type(self.interruptAssignmentsSnapshots) == "table"
    and self.interruptAssignmentsSnapshots or {}
  return self.interruptAssignmentsSnapshots[definition.key]
    or CacheSnapshot(self, definition, NewSnapshot(
      definition,
      { mode = self:GetInterruptAssignmentMode(definition.key) },
      false,
      "not-synced"
    ))
end

function MerfinPlus:PublishInterruptAssignmentsSnapshot(snapshot, force)
  local definition = BossDefinition(snapshot and snapshot.bossKey)
  if not definition then return false end
  CacheSnapshot(self, definition, snapshot)
  return ScanSnapshot(self, definition, snapshot, force)
end

function MerfinPlus:PublishReceivedInterruptAssignmentsSnapshot(snapshot, sender)
  local normalized = self:NormalizeInterruptAssignmentsSnapshot(snapshot)
  if not normalized then return false end
  normalized.source.sender = tostring(sender or "")
  if normalized.source.mode == MANUAL_MODE then normalized.source.mode = "weak-aura-manual" end
  self:PublishInterruptAssignmentsSnapshot(normalized, true)
  local state = self.interruptSyncEncounterState
  if state and state.active and state.bossKey == normalized.bossKey then
    self:RecordInterruptAssignmentsSyncSuccess(normalized.bossKey,
      normalized.source.mode == "weak-aura-manual" and MANUAL_MODE or GUILD_MANAGER_MODE,
      "received-assignment-sync")
  end
  return true
end

function MerfinPlus:PublishReceivedInterruptManualSnapshot(snapshot, sender)
  if type(snapshot) == "table" then
    snapshot.source = snapshot.source or {}
    snapshot.source.mode = MANUAL_MODE
  end
  return self:PublishReceivedInterruptAssignmentsSnapshot(snapshot, sender)
end

function MerfinPlus:CanBroadcastInterruptAssignments()
  if type(self.CanBroadcastRaidAssignments) ~= "function" then
    return false, "Interrupt assignment sync is unavailable."
  end
  return self:CanBroadcastRaidAssignments()
end

function MerfinPlus:GetInterruptCatalogBoss(bossKey)
  local definition = BossDefinition(bossKey)
  if not definition or type(self.GetRaidAssignmentGroup) ~= "function" then return nil end
  local group = self:GetRaidAssignmentGroup(RAID_GROUP_ID)
  for _, raid in ipairs(group and group.raids or {}) do
    for _, boss in ipairs(raid.bosses or {}) do
      if BossDefinition(boss) == definition then return boss end
    end
  end
end

function MerfinPlus:RecordInterruptAssignmentsSyncSuccess(bossKey, mode, trigger)
  local definition = BossDefinition(bossKey)
  if not definition then return end
  local state = self.interruptSyncEncounterState
  self.interruptLastSuccessfulSync = {
    bossKey = definition.key,
    mode = mode,
    trigger = trigger,
    generation = state and state.active and state.generation or nil,
    sourceRevision = self:GetInterruptAssignmentSourceRevision(definition.key),
    time = (GetServerTime and GetServerTime()) or (time and time()) or 0,
  }
  if state and state.active and state.bossKey == definition.key
    and state.sourceRevision == self:GetInterruptAssignmentSourceRevision(definition.key) then
    state.succeededGeneration = state.generation
  end
end

function MerfinPlus:MaybeBroadcastInterruptAssignmentsForBoss(catalogBoss)
  local definition = BossDefinition(catalogBoss)
  if not definition then return false, { skipped = true, reason = "not-interrupt-boss" } end
  if self:GetInterruptAssignmentMode(definition.key) ~= GUILD_MANAGER_MODE then
    return false, { skipped = true, reason = "manual-mode" }
  end
  local snapshot = self:BuildGuildManagerInterruptAssignmentsSnapshot(definition.key, false)
  local normalized, normalizeError = self:NormalizeInterruptAssignmentsSnapshot(snapshot, GUILD_MANAGER_MODE, definition.key)
  if not normalized or not normalized.available then
    local reason = normalizeError or (definition.label .. " has no Guild Manager WeakAura assignments.")
    self:SetInterruptAssignmentsStatus(definition.key, reason, "red")
    return false, reason
  end
  self:PublishInterruptAssignmentsSnapshot(normalized, true)
  self:RecordInterruptAssignmentsSyncSuccess(definition.key, GUILD_MANAGER_MODE, "boss-assignments")
  self:SetInterruptAssignmentsStatus(definition.key,
    definition.label .. " WeakAura assignments synced with the boss assignments.", "green")
  return true, { mode = GUILD_MANAGER_MODE, piggyback = true, bossKey = definition.key }
end

function MerfinPlus:RecordReceivedInterruptAssignmentsForBoss(catalogBoss, sender)
  local definition = BossDefinition(catalogBoss)
  if not definition then return false end
  local snapshot = self:BuildGuildManagerInterruptAssignmentsSnapshot(definition.key, true)
  local normalized = self:NormalizeInterruptAssignmentsSnapshot(snapshot, GUILD_MANAGER_MODE, definition.key)
  if not normalized or not normalized.available then
    ClearCachedSnapshot(self, definition, "received-boss-without-weakaura-assignments", true)
    return false
  end
  normalized.source.sender = tostring(sender or "")
  self:PublishInterruptAssignmentsSnapshot(normalized, true)
  self:RecordInterruptAssignmentsSyncSuccess(definition.key, GUILD_MANAGER_MODE, "received-boss-assignments")
  self:SetInterruptAssignmentsStatus(definition.key,
    definition.label .. " WeakAura assignments received from " .. tostring(sender or "") .. ".", "green")
  return true
end

function MerfinPlus:SyncGuildManagerInterruptAssignments(bossKey, trigger)
  local definition = BossDefinition(bossKey)
  local catalogBoss = definition and self:GetInterruptCatalogBoss(definition.key)
  if not definition or not catalogBoss or type(self.BroadcastPersonalRaidAssignments) ~= "function" then
    local reason = (definition and definition.label or "Interrupt") .. " boss assignment sync is unavailable."
    if definition then self:SetInterruptAssignmentsStatus(definition.key, reason, "red") end
    return false, reason
  end
  local sent, metrics = self:BroadcastPersonalRaidAssignments(catalogBoss, false, RAID_GROUP_ID)
  if not sent then
    self:SetInterruptAssignmentsStatus(definition.key,
      metrics or (definition.label .. " boss assignments could not be synced."), "red")
  elseif type(metrics) == "table" then
    metrics.interruptTrigger = trigger
  end
  return sent, metrics
end

function MerfinPlus:BroadcastActiveInterruptAssignments(bossKey, trigger)
  local definition = BossDefinition(bossKey)
  if not definition then return false, "Unknown interrupt assignment boss." end
  local allowed, reason = self:CanBroadcastInterruptAssignments()
  if not allowed then self:SetInterruptAssignmentsStatus(definition.key, reason, "red"); return false, reason end
  local mode = self:GetInterruptAssignmentMode(definition.key)
  if mode == GUILD_MANAGER_MODE then
    return self:SyncGuildManagerInterruptAssignments(definition.key, trigger)
  end
  local snapshot, buildError = self:BuildManualInterruptAssignmentsSnapshot(definition.key)
  if not snapshot then self:SetInterruptAssignmentsStatus(definition.key, buildError, "red"); return false, buildError end
  local normalized, normalizeError = self:NormalizeInterruptAssignmentsSnapshot(snapshot, MANUAL_MODE, definition.key)
  if not normalized then self:SetInterruptAssignmentsStatus(definition.key, normalizeError, "red"); return false, normalizeError end
  if type(self.BroadcastInterruptAssignmentsSnapshot) ~= "function" then
    reason = "Interrupt assignment sync transport is unavailable."
    self:SetInterruptAssignmentsStatus(definition.key, reason, "red")
    return false, reason
  end
  local sent, metrics = self:BroadcastInterruptAssignmentsSnapshot(normalized, definition.key, MANUAL_MODE, trigger)
  if sent then
    self:RecordInterruptAssignmentsSyncSuccess(definition.key, MANUAL_MODE, trigger)
    self:SetInterruptAssignmentsStatus(definition.key, definition.label .. " manual assignments synced.", "green")
  else
    self:SetInterruptAssignmentsStatus(definition.key,
      metrics or (definition.label .. " manual assignments could not be synced."), "red")
  end
  return sent, metrics
end

function MerfinPlus:SyncManualInterruptAssignments(bossKey)
  local definition = BossDefinition(bossKey)
  if not definition then return false, "Unknown interrupt assignment boss." end
  if self:GetInterruptAssignmentMode(definition.key) ~= MANUAL_MODE then
    local reason = "Use Manual Groups must be active before manual assignments can be synced."
    self:SetInterruptAssignmentsStatus(definition.key, reason, "red")
    return false, reason
  end
  return self:BroadcastActiveInterruptAssignments(definition.key, "manual-button")
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

function MerfinPlus:TryAutomaticInterruptAssignmentsSync(bossKey)
  local definition = BossDefinition(bossKey)
  local state = self.interruptSyncEncounterState
  if not definition or not state or not state.active or state.bossKey ~= definition.key
    or state.sourceRevision ~= self:GetInterruptAssignmentSourceRevision(definition.key)
    or state.succeededGeneration == state.generation or not state.senderRole then return false end
  local allowed = self:CanBroadcastInterruptAssignments()
  if not allowed then return false end
  return self:BroadcastActiveInterruptAssignments(definition.key, "pull-emergency")
end

function MerfinPlus:BeginInterruptAssignmentsEncounter(bossKey, forceNewGeneration)
  local definition = BossDefinition(bossKey)
  if not definition then return false end
  local state = self.interruptSyncEncounterState
  if state and state.active and state.bossKey == definition.key and forceNewGeneration ~= true then return false end
  local generation = (self.interruptSyncEncounterGeneration or 0) + 1
  self.interruptSyncEncounterGeneration = generation
  state = {
    active = true,
    bossKey = definition.key,
    generation = generation,
    sourceRevision = self:GetInterruptAssignmentSourceRevision(definition.key),
    senderRole = AutomaticSenderRole(),
  }
  self.interruptSyncEncounterState = state
  local function TrySync()
    local current = self.interruptSyncEncounterState
    if current == state and current.active and current.generation == generation
      and current.sourceRevision == self:GetInterruptAssignmentSourceRevision(definition.key) then
      self:TryAutomaticInterruptAssignmentsSync(definition.key)
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

function MerfinPlus:EndInterruptAssignmentsEncounter(bossKey)
  local definition = BossDefinition(bossKey)
  local state = self.interruptSyncEncounterState
  if state and (not definition or state.bossKey == definition.key) then
    state.active = nil
    state.senderRole = nil
    self.interruptSyncEncounterState = nil
    return true
  end
  return false
end

function MerfinPlus:HandleInterruptAssignmentsEncounterEnd(encounterID, success)
  local definition = BossDefinition(encounterID)
  if not definition then return false end
  self:EndInterruptAssignmentsEncounter(definition.key)
  if success == true or tonumber(success) == 1 then
    ClearCachedSnapshot(self, definition, "successful-encounter-completion", true)
    return true
  end
  return false
end

local function NPCIDFromGUID(guid)
  if type(guid) ~= "string" then return nil end
  return guid:match("^[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-([^%-]+)")
end

function MerfinPlus:GetLiveInterruptAssignmentsBoss()
  local function Match(unit)
    local npcID = NPCIDFromGUID(UnitGUID and UnitGUID(unit))
    if not npcID or (UnitIsDeadOrGhost and UnitIsDeadOrGhost(unit)) then return nil end
    for _, key in ipairs(BOSS_ORDER) do if BOSSES[key].npcID == npcID then return BOSSES[key] end end
  end
  for index = 1, 5 do
    local definition = Match("boss" .. index)
    if definition then return definition end
  end
  return Match("target") or Match("focus")
end

function MerfinPlus:InitializeInterruptAssignmentsPullSync()
  if self.interruptAssignmentsPullSyncInitialized or not CreateFrame then return end
  self.interruptAssignmentsPullSyncInitialized = true
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ENCOUNTER_START")
  frame:RegisterEvent("ENCOUNTER_END")
  frame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:SetScript("OnEvent", function(_, event, encounterID, encounterName, difficultyID, groupSize, success)
    if event == "ENCOUNTER_START" then
      local definition = BossDefinition(encounterID)
      if definition then self:BeginInterruptAssignmentsEncounter(definition.key, true) end
      return
    end
    if event == "ENCOUNTER_END" then
      self:HandleInterruptAssignmentsEncounterEnd(encounterID, success)
      return
    end
    if event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
      local definition = self:GetLiveInterruptAssignmentsBoss()
      if definition then self:BeginInterruptAssignmentsEncounter(definition.key) end
      return
    end
    if event == "PLAYER_REGEN_DISABLED" then
      local function Probe()
        local definition = self:GetLiveInterruptAssignmentsBoss()
        if definition then self:BeginInterruptAssignmentsEncounter(definition.key) end
      end
      if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(0.5, Probe)
        C_Timer.After(1.5, Probe)
      else
        Probe()
      end
      return
    end
    if event == "PLAYER_REGEN_ENABLED" and self.interruptSyncEncounterState then
      local function EndIfGone()
        if not self:GetLiveInterruptAssignmentsBoss() then self:EndInterruptAssignmentsEncounter() end
      end
      if C_Timer and type(C_Timer.After) == "function" then C_Timer.After(0.5, EndIfGone) else EndIfGone() end
    end
  end)
  self.interruptAssignmentsPullSyncFrame = frame
end

function MerfinPlus:InvalidateInterruptAssignmentSnapshots(reason)
  for _, key in ipairs(BOSS_ORDER) do
    if self:GetInterruptAssignmentMode(key) == GUILD_MANAGER_MODE then
      ClearCachedSnapshot(self, BOSSES[key], reason or "assignment-source-changed", true)
    end
  end
end

function MerfinPlus:InitializeInterruptAssignmentsBridge()
  if self.interruptAssignmentsBridgeInitialized then return end
  self.interruptAssignmentsBridgeInitialized = true
  self:InitializeInterruptAssignmentsPullSync()
  for _, key in ipairs(BOSS_ORDER) do
    local definition = BOSSES[key]
    local snapshot = self:GetInterruptAssignmentsSnapshot(key)
    ScanSnapshot(self, definition, snapshot, true)
  end
end

MerfinPlus.INTERRUPT_ASSIGNMENTS_EVENT = EVENT_NAME
MerfinPlus.INTERRUPT_ASSIGNMENTS_SNAPSHOT_VERSION = SNAPSHOT_VERSION
MerfinPlus.INTERRUPT_ASSIGNMENTS_GUILD_MANAGER_MODE = GUILD_MANAGER_MODE
MerfinPlus.INTERRUPT_ASSIGNMENTS_MANUAL_MODE = MANUAL_MODE
MerfinPlus.INTERRUPT_ASSIGNMENTS_RELIQUARY_ICON = BOSSES.reliquary.icon
MerfinPlus.INTERRUPT_ASSIGNMENTS_COUNCIL_ICON = BOSSES.council.icon
MerfinPlus.INTERRUPT_ASSIGNMENTS_BOSSES = BOSSES

Public.schema = "merfinplus.interrupt.bridge"
Public.version = 2
Public.snapshotVersion = SNAPSHOT_VERSION
Public.event = EVENT_NAME
Public.GetSnapshot = function(bossKey)
  return MerfinPlus:GetInterruptAssignmentsSnapshot(bossKey)
end
Public.BroadcastManualRotations = function(snapshot)
  if type(MerfinPlus.BroadcastInterruptManualAssignments) ~= "function" then
    return false, "Interrupt manual sync transport is unavailable."
  end
  return MerfinPlus:BroadcastInterruptManualAssignments(snapshot)
end
if type(Merfin) == "table" then
  Merfin.GetInterruptAssignmentsSnapshot = Public.GetSnapshot
  Merfin.BroadcastInterruptManualAssignments = Public.BroadcastManualRotations
end

if type(MerfinPlus.NotifyRaidAssignmentsChanged) == "function" then
  hooksecurefunc(MerfinPlus, "NotifyRaidAssignmentsChanged", function(owner)
    owner:InvalidateInterruptAssignmentSnapshots("assignment-source-changed")
  end)
end
if type(MerfinPlus.InitializeRaidAssignments) == "function" then
  hooksecurefunc(MerfinPlus, "InitializeRaidAssignments", function(owner)
    owner:InitializeInterruptAssignmentsBridge()
  end)
end
