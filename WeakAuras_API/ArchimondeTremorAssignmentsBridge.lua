local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local EVENT_NAME = "MERFINPLUS_ARCHIMONDE_TREMOR_ASSIGNMENTS_UPDATED"
local PUBLIC_NAME = "MerfinPlusArchimondeTremorAssignments"
local RAID_GROUP_ID = "bt_mh"
local SNAPSHOT_VERSION = 1

local Public = _G[PUBLIC_NAME]
if type(Public) ~= "table" then
  Public = {}
  _G[PUBLIC_NAME] = Public
end

local GROUPS = {
  {
    key = "group1", number = 1, markerName = "square", markerIndex = 6,
    sectionNames = { "Square Worldmark - Group 1", "Archimonde Square Group" },
  },
  {
    key = "group2", number = 2, markerName = "triangle", markerIndex = 4,
    sectionNames = { "Triangle Worldmark - Group 2", "Archimonde Triangle Group" },
  },
  {
    key = "group3", number = 3, markerName = "diamond", markerIndex = 3,
    sectionNames = { "Diamond Worldmark - Group 3", "Archimonde Diamond Group" },
  },
  {
    key = "group4", number = 4, markerName = "star", markerIndex = 1,
    sectionNames = { "Star Worldmark - Group 4", "Archimonde Star Group" },
  },
  {
    key = "group5", number = 5, markerName = "circle", markerIndex = 2,
    sectionNames = { "Circle Worldmark - Group 5", "Archimonde Circle Group" },
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
  return lower(ShortPlayerName(value) or "")
end

local function CopyGroupDefinition(definition)
  return {
    key = definition.key,
    number = definition.number,
    label = "Group " .. tostring(definition.number),
    markerName = definition.markerName,
    markerIndex = definition.markerIndex,
    markerToken = "{rt" .. tostring(definition.markerIndex) .. "}",
    sectionFound = false,
    players = {},
    shamans = {},
  }
end

local function BuildSource(entry)
  local parsed = entry and entry.parsed
  return {
    mode = "guild-manager",
    importId = tostring(entry and entry.id or ""),
    contentSignature = tostring(entry and entry.contentSignature or ""),
    protocol = tostring(entry and (entry.protocol or (parsed and parsed.protocol)) or ""),
    receivedBroadcast = entry and entry.receivedBroadcast == true or false,
  }
end

local function NewSnapshot(entry, available, reason)
  local snapshot = {
    schema = "merfinplus.archimonde.tremor.assignments",
    version = SNAPSHOT_VERSION,
    available = available == true,
    bossKey = "archimonde",
    encounter = {
      key = "archimonde",
      name = "Archimonde",
      encounterID = 622,
      npcID = 17968,
      raidKey = "mount_hyjal",
    },
    source = BuildSource(entry),
    groups = {},
  }
  if reason then snapshot.source.reason = tostring(reason) end
  for _, definition in ipairs(GROUPS) do
    snapshot.groups[#snapshot.groups + 1] = CopyGroupDefinition(definition)
  end
  return snapshot
end

local function FindArchimonde(parsed)
  if type(parsed) ~= "table" then return nil end
  if type(parsed.bossMap) == "table" then
    local boss = parsed.bossMap.archimonde
    if type(boss) == "table" then return boss end
  end
  for _, boss in ipairs(type(parsed.bosses) == "table" and parsed.bosses or {}) do
    if NormalizeKey(boss.key) == "archimonde" or NormalizeKey(boss.name) == "archimonde" then
      return boss
    end
  end
end

local function SectionMatches(section, definition)
  local sourceKey = NormalizeKey(section and section.sourceName)
  local nameKey = NormalizeKey(section and section.name)
  for _, sectionName in ipairs(definition.sectionNames) do
    local wanted = NormalizeKey(sectionName)
    if sourceKey == wanted or nameKey == wanted then return true end
  end
  return false
end

local function AddUnique(list, seen, value)
  local name = ShortPlayerName(value)
  local key = PlayerKey(name)
  if not name or key == "" or seen[key] then return end
  seen[key] = true
  list[#list + 1] = name
end

function MerfinPlus:BuildArchimondeTremorAssignmentsSnapshot()
  if type(self.GetRaidAssignmentImportForGroup) ~= "function" then
    return NewSnapshot(nil, false, "raid-assignment-api-unavailable")
  end

  local entry = self:GetRaidAssignmentImportForGroup(RAID_GROUP_ID)
  if not entry then return NewSnapshot(nil, false, "no-active-bt-mh-import") end
  if entry.parseError then return NewSnapshot(entry, false, entry.parseError) end

  local boss = FindArchimonde(entry.parsed)
  if not boss then return NewSnapshot(entry, false, "archimonde-assignments-missing") end

  local snapshot = NewSnapshot(entry, true)
  for index, definition in ipairs(GROUPS) do
    local output = snapshot.groups[index]
    local playersSeen, shamansSeen = {}, {}
    for _, section in ipairs(type(boss.sections) == "table" and boss.sections or {}) do
      if SectionMatches(section, definition) then
        output.sectionFound = true
        output.sectionName = tostring(section.name or section.sourceName or "")
        for _, row in ipairs(type(section.rows) == "table" and section.rows or {}) do
          AddUnique(output.players, playersSeen, row.player)
          if NormalizeKey(row.class) == "shaman" then
            AddUnique(output.shamans, shamansSeen, row.player)
          end
        end
      end
    end
  end
  return snapshot
end

function MerfinPlus:GetArchimondeTremorAssignmentsSnapshot()
  local snapshot = self:BuildArchimondeTremorAssignmentsSnapshot()
  self.archimondeTremorAssignmentsSnapshot = snapshot
  Public.snapshot = snapshot
  return snapshot
end

function MerfinPlus:ResolveArchimondeTremorAssignment(playerName)
  local snapshot = self:GetArchimondeTremorAssignmentsSnapshot()
  if not snapshot.available then
    return nil, snapshot.source and snapshot.source.reason or "assignments-unavailable", snapshot
  end

  local wanted = PlayerKey(playerName)
  if wanted == "" then return nil, "player-name-missing", snapshot end
  local matches = {}
  for _, group in ipairs(snapshot.groups) do
    for _, shaman in ipairs(group.shamans) do
      if PlayerKey(shaman) == wanted then matches[#matches + 1] = group end
    end
  end
  if #matches == 1 then return matches[1], snapshot end
  if #matches > 1 then return nil, "player-is-assigned-to-multiple-archimonde-groups", snapshot end
  return nil, "player-is-not-an-assigned-archimonde-shaman", snapshot
end

local function SnapshotSignature(snapshot)
  local parts = {
    tostring(snapshot.version or ""),
    snapshot.available and "1" or "0",
    tostring(snapshot.source and snapshot.source.importId or ""),
    tostring(snapshot.source and snapshot.source.contentSignature or ""),
    tostring(snapshot.source and snapshot.source.reason or ""),
  }
  for _, group in ipairs(snapshot.groups or {}) do
    parts[#parts + 1] = group.key
    parts[#parts + 1] = group.sectionFound and "1" or "0"
    for _, player in ipairs(group.players or {}) do parts[#parts + 1] = PlayerKey(player) end
    parts[#parts + 1] = "shamans"
    for _, player in ipairs(group.shamans or {}) do parts[#parts + 1] = PlayerKey(player) end
  end
  return table.concat(parts, "\31")
end

function MerfinPlus:PublishArchimondeTremorAssignments(force)
  local snapshot = self:GetArchimondeTremorAssignmentsSnapshot()
  local signature = SnapshotSignature(snapshot)
  if not force and self.archimondeTremorAssignmentsPublishedSignature == signature then
    return false, snapshot
  end
  self.archimondeTremorAssignmentsPublishedSignature = signature
  if type(_G.WeakAuras) == "table" and type(_G.WeakAuras.ScanEvents) == "function" then
    _G.WeakAuras.ScanEvents(EVENT_NAME, snapshot)
    return true, snapshot
  end
  return false, snapshot
end

MerfinPlus.ARCHIMONDE_TREMOR_ASSIGNMENTS_EVENT = EVENT_NAME
MerfinPlus.ARCHIMONDE_TREMOR_ASSIGNMENTS_SNAPSHOT_VERSION = SNAPSHOT_VERSION
MerfinPlus.ARCHIMONDE_TREMOR_ASSIGNMENTS_GROUPS = GROUPS

Public.schema = "merfinplus.archimonde.tremor.bridge"
Public.version = 1
Public.snapshotVersion = SNAPSHOT_VERSION
Public.event = EVENT_NAME
Public.GetSnapshot = function() return MerfinPlus:GetArchimondeTremorAssignmentsSnapshot() end
Public.ResolvePlayer = function(playerName)
  return MerfinPlus:ResolveArchimondeTremorAssignment(playerName)
end

if type(Merfin) == "table" then
  Merfin.GetArchimondeTremorAssignmentsSnapshot = Public.GetSnapshot
  Merfin.ResolveArchimondeTremorAssignment = Public.ResolvePlayer
end

if type(MerfinPlus.NotifyRaidAssignmentsChanged) == "function" and type(hooksecurefunc) == "function" then
  hooksecurefunc(MerfinPlus, "NotifyRaidAssignmentsChanged", function(owner)
    owner:PublishArchimondeTremorAssignments(true)
  end)
end

if type(MerfinPlus.InitializeRaidAssignments) == "function" and type(hooksecurefunc) == "function" then
  hooksecurefunc(MerfinPlus, "InitializeRaidAssignments", function(owner)
    owner:PublishArchimondeTremorAssignments(true)
  end)
end
