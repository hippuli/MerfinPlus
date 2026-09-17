-- TBC Raid Assignments data and private MGMRA transport, adapted from the
-- locally installed MerfinUI Guild Manager protocol and display rules.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local RAID_ASSIGNMENT_ADDON_PREFIX = "MGMRA"
local ASSIGNMENT_TRANSPORT_REVISION = "2"
local MGMRA4_TRANSPORT_REVISION = "4.1"
local MGMRA4_PLAN_TRANSPORT_REVISION = "4P.1"
local BROADCAST_CHUNK_SIZE = 180
local MAX_ASSIGNMENT_TRANSPORT_CHUNKS = 2048
local ASSIGNMENT_ACK_WINDOW_SECONDS = 5
local ASSIGNMENT_DELIVERY_SCOPED_RAID = "SCOPED_RAID"
local ASSIGNMENT_DELIVERY_FULL_RAID = "FULL_RAID"
local RAID_CATALOG_KEYS = {
  karazhan = "karazhan",
  tempest_keep = "tempest-keep",
  serpentshrine_cavern = "serpentshrine-cavern",
  black_temple = "black-temple",
  mount_hyjal = "hyjal",
  sunwell_plateau = "sunwell-plateau",
}

local RAID_TARGET_ICONS = {
  star = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
  circle = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
  orange = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
  diamond = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
  triangle = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
  moon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
  square = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
  cross = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
  x = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
  skull = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
}

local ROLE_ICONS = {
  tank = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\tank.tga",
  heal = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\heal.tga",
  dps = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\dps.tga",
  position = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\position_white.tga",
}

local function Trim(value)
  value = tostring(value or "")
  value = value:gsub("^%s+", ""):gsub("%s+$", "")
  value = value:gsub("^\239\187\191", "")
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function NormalizeName(value)
  return tostring(value or ""):lower():gsub("[%s%p%c]+", "")
end

local function CleanPlayerName(value)
  local name = tostring(value or "")
  local dash = name:find("-", 1, true)
  return dash and name:sub(1, dash - 1) or name
end

local function SplitPipes(line)
  local fields = {}
  line = tostring(line or "")
  local startIndex = 1
  while true do
    local pipeIndex = line:find("|", startIndex, true)
    if not pipeIndex then
      fields[#fields + 1] = line:sub(startIndex)
      break
    end
    fields[#fields + 1] = line:sub(startIndex, pipeIndex - 1)
    startIndex = pipeIndex + 1
  end
  return fields
end

local function EncodeAddonPayload(value)
  value = tostring(value or "")
  value = value:gsub("%%", "%%25")
  value = value:gsub("\r", "%%0D")
  value = value:gsub("\n", "%%0A")
  value = value:gsub("|", "%%7C")
  return value
end

local function DecodeAddonPayload(value)
  value = tostring(value or "")
  value = value:gsub("%%7[Cc]", "|")
  value = value:gsub("%%0[Dd]", "\r")
  value = value:gsub("%%0[Aa]", "\n")
  value = value:gsub("%%25", "%%")
  return value
end

local function NormalizeRaidAssignmentRawText(raw)
  raw = tostring(raw or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
  raw = raw:gsub("\\r\\n", "\n"):gsub("\\n", "\n")
  raw = raw:gsub("^\239\187\191", ""):gsub("\239\187\191", "")
  raw = raw:gsub("\226\128\139", ""):gsub("\226\128\140", ""):gsub("\226\128\141", "")
  raw = raw:gsub("\194\160", " ")
  raw = raw:gsub("|+", "|")
  raw = raw:gsub("MGMRA%s*|%s*", "MGMRA|")
  raw = raw:gsub("META%s*|%s*", "META|")
  raw = raw:gsub("(MGMRA|%d+)%s*(META|)", "%1\nMETA|")
  raw = raw:gsub("([^%s])(%[[^%]]+%])", "%1\n%2")
  raw = raw:gsub("(////)%s*(%[[^%]]+%])", "%1\n%2")
  raw = raw:gsub("(//)%s*(%[[^%]]+%])", "%1\n%2")
  raw = raw:gsub("\n\n+", "\n")
  return Trim(raw)
end

local function GetRaidAssignmentContentSignature(raw)
  local normalized = NormalizeRaidAssignmentRawText(raw)
  local hash = 0
  for index = 1, #normalized do
    hash = (hash * 31 + normalized:byte(index)) % 1000000007
  end
  return tostring(#normalized) .. "-" .. tostring(hash)
end

local function Now()
  if GetServerTime then
    return GetServerTime()
  elseif time then
    return time()
  end
  return 0
end

local function FormatTimestamp(timestamp)
  -- Saved-import labels must remain readable in the fixed-width picker.  The
  -- stored numeric timestamp remains the authoritative value.
  return date and date("%Y-%m-%d %H:%M", timestamp) or tostring(timestamp or "")
end

local function GetAddonVersion()
  local getter = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
  return getter and tostring(getter("MerfinPlus", "Version") or "unknown") or "unknown"
end

local function TitleCaseToken(value)
  value = Trim(value):gsub("[_%-%s]+", " ")
  value = value:gsub("(%l)(%u)", "%1 %2")
  return value:gsub("(%a)([%w']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

local RAID_ASSIGNMENT_CLASS_TOKENS = {
  demonhunter = "DEMONHUNTER",
  druid = "DRUID",
  hunter = "HUNTER",
  mage = "MAGE",
  paladin = "PALADIN",
  priest = "PRIEST",
  rogue = "ROGUE",
  shaman = "SHAMAN",
  warlock = "WARLOCK",
  warrior = "WARRIOR",
}

-- Assignment/Boss Plan exports may use later canonical Druid role names while
-- the TBC media pack intentionally ships one Feral icon. Keep this alias table
-- narrowly scoped to Druid and return the existing bundled texture.
local RAID_ASSIGNMENT_SPEC_ICON_ALIASES = {
  DRUID = {
    guardian = "feral",
    ["104"] = "feral",
    druidguardian = "feral",
    guardiandruid = "feral",
    feraltank = "feral",
    feralcombat = "feral",
  },
}

function MerfinPlus:NormalizeRaidAssignmentSpecIconKey(classToken, spec)
  local token = tostring(classToken or ""):upper()
  local key = tostring(spec or ""):lower():gsub("[%s%p%c]+", "")
  return RAID_ASSIGNMENT_SPEC_ICON_ALIASES[token] and RAID_ASSIGNMENT_SPEC_ICON_ALIASES[token][key] or key
end

function MerfinPlus:GetRaidAssignmentSpecIconPath(classToken, spec)
  local token = tostring(classToken or ""):upper()
  local key = self:NormalizeRaidAssignmentSpecIconKey(token, spec)
  if token == "" or key == "" then return nil end
  return "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\"
    .. token:lower() .. "_" .. key .. ".tga"
end

local function GetRaidAssignmentClassToken(className)
  return RAID_ASSIGNMENT_CLASS_TOKENS[NormalizeName(className)]
end

local function GetRaidAssignmentClassIcon(classToken)
  if not classToken then
    return nil
  end
  if classToken == "DEMONHUNTER" then
    return "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\DEMONHUNTER.tga"
  end
  return "Interface\\Icons\\ClassIcon_" .. TitleCaseToken(classToken)
end

local function RaidBossIcon(raid, name, sourceName)
  local catalogRaid = RAID_CATALOG_KEYS[raid]
  local normalizedName = NormalizeName(name)
  local normalizedSourceName = NormalizeName(sourceName)
  local wanted = { normalizedName, normalizedSourceName }
  local assetCatalog = MerfinPlus.GetTBCBossPlanAssetCatalog and MerfinPlus:GetTBCBossPlanAssetCatalog() or {}
  for _, asset in ipairs(assetCatalog.assets or {}) do
    if asset.kind == "portrait" and asset.variant == "primary" and asset.raid == catalogRaid then
      local encounter = NormalizeName(asset.encounter)
      for _, candidate in ipairs(wanted) do
        if candidate ~= "" and (candidate == encounter or candidate:find(encounter, 1, true)
          or encounter:find(candidate, 1, true)) then
          return asset.runtimePath
        end
      end
    end
  end
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function RaidBoss(raid, name, sourceName)
  local key = string.lower(tostring(name or "")):gsub("[^%w]+", "_"):gsub("_+$", "")
  return {
    key = key,
    name = name,
    raidKey = raid,
    localeID = raid .. ":" .. key,
    icon = RaidBossIcon(raid, name, sourceName or name),
  }
end

local RAID_GROUPS = {
  {
    id = "karazhan",
    name = "Karazhan",
    raids = {
      {
        localeID = "raid:karazhan",
        name = "Karazhan",
        abbreviation = "KZ",
        bosses = {
          RaidBoss("karazhan", "Attumen the Huntsman"),
          RaidBoss("karazhan", "Moroes"),
          RaidBoss("karazhan", "Maiden of Virtue"),
          RaidBoss("karazhan", "Opera Event"),
          RaidBoss("karazhan", "The Curator"),
          RaidBoss("karazhan", "Terestian Illhoof"),
          RaidBoss("karazhan", "Shade of Aran"),
          RaidBoss("karazhan", "Netherspite"),
          RaidBoss("karazhan", "Chess Event"),
          RaidBoss("karazhan", "Prince Malchezaar", "Prince Machlezaar"),
          RaidBoss("karazhan", "Nightbane"),
        },
      },
    },
  },
  {
    id = "tk_ssc",
    name = "TK/SSC",
    savedImportLabel = "SSC/TK",
    raids = {
      {
        localeID = "raid:tempest_keep",
        name = "The Eye",
        abbreviation = "TK",
        bosses = {
          RaidBoss("tempest_keep", "Al'ar"),
          RaidBoss("tempest_keep", "Void Reaver"),
          RaidBoss("tempest_keep", "High Astromancer Solarian"),
          RaidBoss("tempest_keep", "Kael'thas Sunstrider"),
        },
      },
      {
        localeID = "raid:serpentshrine_cavern",
        name = "Serpentshrine Cavern",
        abbreviation = "SSC",
        bosses = {
          RaidBoss("serpentshrine_cavern", "Hydross the Unstable"),
          RaidBoss("serpentshrine_cavern", "The Lurker Below"),
          RaidBoss("serpentshrine_cavern", "Leotheras the Blind"),
          RaidBoss("serpentshrine_cavern", "Fathom-Lord Karathress"),
          RaidBoss("serpentshrine_cavern", "Morogrim Tidewalker"),
          RaidBoss("serpentshrine_cavern", "Lady Vashj"),
        },
      },
    },
  },
  {
    id = "bt_mh",
    name = "BT/MH",
    savedImportLabel = "BT/MH",
    raids = {
      {
        localeID = "raid:black_temple",
        name = "Black Temple",
        abbreviation = "BT",
        bosses = {
          RaidBoss("black_temple", "High Warlord Naj'entus", "Najentus"),
          RaidBoss("black_temple", "Supremus"),
          RaidBoss("black_temple", "Shade of Akama", "Akama"),
          RaidBoss("black_temple", "Teron Gorefiend", "TeronGorefiend"),
          RaidBoss("black_temple", "Gurtogg Bloodboil", "GurtoggBloodboil"),
          RaidBoss("black_temple", "Reliquary of Souls", "ReliqoftheLost"),
          RaidBoss("black_temple", "Mother Shahraz", "Shahraz"),
          RaidBoss("black_temple", "The Illidari Council", "IllidariCouncil"),
          RaidBoss("black_temple", "Illidan Stormrage", "Illidan"),
        },
      },
      {
        localeID = "raid:mount_hyjal",
        name = "Battle for Mount Hyjal",
        abbreviation = "MH",
        bosses = {
          RaidBoss("mount_hyjal", "Rage Winterchill", "Rage_Winterchill"),
          RaidBoss("mount_hyjal", "Anetheron"),
          RaidBoss("mount_hyjal", "Kaz'rogal", "Kazrogal"),
          RaidBoss("mount_hyjal", "Azgalor"),
          RaidBoss("mount_hyjal", "Archimonde"),
        },
      },
    },
  },
  {
    id = "sunwell_plateau",
    name = "Sunwell Plateau",
    raids = {
      {
        localeID = "raid:sunwell_plateau",
        name = "Sunwell Plateau",
        abbreviation = "SWP",
        bosses = {
          RaidBoss("sunwell_plateau", "Kalecgos"),
          RaidBoss("sunwell_plateau", "Brutallus"),
          RaidBoss("sunwell_plateau", "Felmyst", "felmyst"),
          RaidBoss("sunwell_plateau", "Eredar Twins", "eredar twins"),
          RaidBoss("sunwell_plateau", "M'uru"),
          RaidBoss("sunwell_plateau", "Kil'jaeden"),
        },
      },
    },
  },
}

local V2_ASSIGNMENT_SECTIONS = {
  akamainterruptleft = { section = "Interrupt Left Door", marker = "star" },
  akamainterruptright = { section = "Interrupt Right Door", marker = "square" },
  akamafrosttrapleft = { section = "Frost Trap Left Door", marker = "star" },
  akamafrosttrapright = { section = "Frost Trap Right Door", marker = "square" },
  councilmagetank = { section = "Mage Tank" },
  councilmalandeinterrupts = { section = "Lady Malande Interrupts" },
  councilzerevorinterrupts = { section = "Zerevor Interrupts" },
  reliquaryspiritshockinterrupts = { section = "Spirit Shock Interrupt Rotation" },
  archimondesquaregroup = { section = "Square Worldmark - Group 1", marker = "square" },
  archimondetrianglegroup = { section = "Triangle Worldmark - Group 2", marker = "triangle" },
  archimondediamondgroup = { section = "Diamond Worldmark - Group 3", marker = "diamond" },
  archimondestargroup = { section = "Star Worldmark - Group 4", marker = "star" },
  archimondecirclegroup = { section = "Circle Worldmark - Group 5", marker = "circle" },
  gurtoggstargroup = { section = "Star Worldmark - Group 1", marker = "star" },
  gurtoggdiamondgroup = { section = "Diamond Worldmark - Group 2", marker = "diamond" },
  gurtoggcirclegroup = { section = "Circle Worldmark - Group 3", marker = "circle" },
  anetheronrangedstargroup = { section = "Star Worldmark - Ranged Group 1", marker = "star" },
  anetheronrangedsquaregroup = { section = "Square Worldmark - Ranged Group 2", marker = "square" },
  anetheronrangeddiamondgroup = { section = "Diamond Worldmark - Ranged Group 3", marker = "diamond" },
  illidanphasetwotankpositions = { section = "Phase Two Tank Positions" },
  illidanphasetwodiamondgroup = { section = "Diamond Worldmark - Group 1", marker = "diamond" },
  illidanphasetwostargroup = { section = "Star Worldmark - Group 2", marker = "star" },
  illidanphasetwocirclegroup = { section = "Circle Worldmark - Group 3", marker = "circle" },
  illidanphasetwomeleepositions = { section = "Melee Positioning" },
  illidanphasefourwarlocktank = { section = "Warlock Tank" },
  illidanphasefourtankthree = { section = "Tank 3" },
}

local function CanonicalRaidAssignmentV2Section(assignmentKey, phase, sectionName, marker)
  local canonical = V2_ASSIGNMENT_SECTIONS[NormalizeName(assignmentKey)]
  if not canonical then
    return sectionName, marker
  end
  local canonicalSection = canonical.section
  if Trim(phase) ~= "" then
    canonicalSection = Trim(phase) .. " - " .. canonicalSection
  end
  return canonicalSection, canonical.marker or marker
end

local function GetSectionMarker(sectionName)
  local sectionLabel = Trim(sectionName)
  local normalizedSection = NormalizeName(sectionLabel)
  for markerStart, markerName, markerEnd in sectionLabel:gmatch("()(%a+)()") do
    local markerKey = NormalizeName(markerName)
    local marker = RAID_TARGET_ICONS[markerKey]
    local isMarkerSection = marker and (
      normalizedSection == markerKey
      or normalizedSection:find("worldmark", 1, true)
      or normalizedSection:find("marker", 1, true)
      or normalizedSection:find("group", 1, true)
      or normalizedSection:find("crew", 1, true)
    )
    if isMarkerSection then
      local before = sectionLabel:sub(1, markerStart - 1)
      local after = sectionLabel:sub(markerEnd)
      after = after:gsub("^%s*[Ww][Oo][Rr][Ll][Dd]%s*[Mm][Aa][Rr][Kk][Ee]?[Rr]?", "")
      after = after:gsub("^%s*[%-%:]%s*", "")
      local displayLabel = Trim((before or "") .. (after or ""))
      displayLabel = Trim(displayLabel:gsub("%s+", " "):gsub("%s*[%-%:]%s*$", ""))
      return marker, displayLabel
    end
  end
end

function MerfinPlus:GetRaidAssignmentGroups()
  return RAID_GROUPS
end

function MerfinPlus:RaidAssignmentTrashAppliesToRaid(boss, raidKey)
  if not boss or boss.isTrash ~= true then return false end
  local wanted = NormalizeName(raidKey)
  for _, member in ipairs(type(boss.trashMembers) == "table" and boss.trashMembers or {}) do
    if NormalizeName(member) == wanted then return true end
  end
  return NormalizeName(boss.raidKey) == wanted
end

function MerfinPlus:GetRaidAssignmentSharedTrashBoss(parsed, groupID)
  local wanted = NormalizeName(groupID)
  for _, boss in ipairs(parsed and parsed.bosses or {}) do
    if boss.isTrash == true and NormalizeName(boss.trashGroup) == wanted
      and type(boss.trashMembers) == "table" and #boss.trashMembers > 1
    then
      return boss
    end
  end
end

function MerfinPlus:GetRaidAssignmentSharedTrashNavigation(parsed, group)
  if not group or not group.raids or not group.raids[1] then return nil end
  local trash = self:GetRaidAssignmentSharedTrashBoss(parsed, group.id)
  if not trash then return nil end
  local anchor = NormalizeName(tostring(group.raids[1].localeID or ""):match(":(.+)$") or group.raids[1].name)
  if NormalizeName(trash.trashAnchor) ~= anchor then return nil end
  return trash, group.raids[1]
end

local function RaidAssignmentNavigationRaidKey(raid)
  return NormalizeName(tostring(raid and raid.localeID or ""):match(":(.+)$") or (raid and raid.name) or "")
end

local function RaidAssignmentNavigationKey(kind, groupID, raidKey, bossKey)
  return table.concat({
    NormalizeName(kind),
    NormalizeName(groupID),
    NormalizeName(raidKey),
    NormalizeName(bossKey),
  }, "::")
end

function MerfinPlus:BuildRaidAssignmentAdditionalOverview(parsed, group)
  local sections = {}
  for _, boss in ipairs(parsed and parsed.bosses or {}) do
    for _, section in ipairs(boss.sections or {}) do
      if section.kind == "additional" or NormalizeName(section.name) == "additionalassignments" then
        if #(section.rows or {}) > 0 then
          sections[#sections + 1] = {
            name = tostring(boss.name or section.name or "Additional Assignments"),
            sourceName = section.name,
            kind = "additional",
            context = section.context,
            rows = section.rows,
          }
        end
      end
    end
  end
  if #sections == 0 then return nil end
  return {
    key = "additional:" .. tostring(group and group.id or "raid"),
    name = "Additional Assignments",
    raidKey = "",
    isAdditionalOverview = true,
    sections = sections,
  }
end

local function ParsedHasBossPlan(parsed, boss)
  if type(parsed) ~= "table" or type(boss) ~= "table" then return false end
  local candidates = {}
  for _, value in ipairs({ boss.key, boss.name }) do
    local normalized = NormalizeName(value)
    if normalized ~= "" then candidates[#candidates + 1] = normalized end
  end
  for _, plan in ipairs(parsed.bossPlans or {}) do
    local planBoss = NormalizeName(plan and plan.boss)
    if planBoss ~= "" then
      for _, candidate in ipairs(candidates) do
        if candidate == planBoss or candidate:find(planBoss, 1, true) then return true end
      end
    end
  end
  return false
end

function MerfinPlus:BuildRaidAssignmentNavigation(parsed, group)
  local navigation = {}
  if not parsed or not group then return navigation end

  local function AddBoss(kind, boss, importedBoss, raid, title)
    local raidKey = RaidAssignmentNavigationRaidKey(raid)
    navigation[#navigation + 1] = {
      kind = kind,
      key = RaidAssignmentNavigationKey(kind, group.id, raidKey, boss and boss.key),
      title = title or tostring(boss and boss.name or "Raid Assignments"),
      boss = boss,
      importedBoss = importedBoss,
      raid = raid,
    }
  end

  local sharedTrash, sharedAnchor = self:GetRaidAssignmentSharedTrashNavigation(parsed, group)
  if sharedTrash and sharedAnchor then
    AddBoss("trash", sharedTrash, sharedTrash, sharedAnchor, "Trash Assignments")
  end

  for _, raid in ipairs(group.raids or {}) do
    local raidEntries = {}
    local raidKey = RaidAssignmentNavigationRaidKey(raid)
    for _, importedBoss in ipairs(parsed.bosses or {}) do
      if importedBoss.isTrash and importedBoss ~= sharedTrash
        and NormalizeName(importedBoss.raidKey) == raidKey
      then
        raidEntries[#raidEntries + 1] = {
          kind = "trash", boss = importedBoss, importedBoss = importedBoss,
          title = "Trash Assignments",
        }
      end
    end
    for _, catalogBoss in ipairs(raid.bosses or {}) do
      local importedBoss = self:GetRaidAssignmentBoss(parsed, catalogBoss)
      if importedBoss or ParsedHasBossPlan(parsed, catalogBoss) then
        raidEntries[#raidEntries + 1] = {
          kind = "boss", boss = catalogBoss, importedBoss = importedBoss,
          title = catalogBoss.localeID and self.GetLocalizedBossName
            and self:GetLocalizedBossName(catalogBoss.localeID, catalogBoss.name)
            or tostring(catalogBoss.name or "Boss"),
        }
      end
    end
    if #raidEntries > 0 then
      navigation[#navigation + 1] = {
        kind = "heading",
        key = RaidAssignmentNavigationKey("heading", group.id, raidKey, ""),
        title = self.GetLocalizedRaidName
          and self:GetLocalizedRaidName(raid.localeID, raid.name)
          or tostring(raid.name or "Raid"),
        raid = raid,
      }
      for _, item in ipairs(raidEntries) do
        AddBoss(item.kind, item.boss, item.importedBoss, raid, item.title)
      end
    end
  end

  local additional = self:BuildRaidAssignmentAdditionalOverview(parsed, group)
  if additional then
    AddBoss("additional", additional, additional, nil, "Additional Assignments")
  end
  return navigation
end

function MerfinPlus:GetRaidAssignmentNavigationEntry(groupID, navigationKey)
  local group = self:GetRaidAssignmentGroup(groupID)
  local entry = group and self:GetRaidAssignmentImportForGroup(group.id)
  for _, item in ipairs(self:BuildRaidAssignmentNavigation(entry and entry.parsed, group)) do
    if item.kind ~= "heading" and item.key == navigationKey then return item end
  end
end

function MerfinPlus:SelectRaidAssignmentNavigationEntry(groupID, navigationKey, knownItem, suppressRefresh)
  local item = knownItem or self:GetRaidAssignmentNavigationEntry(groupID, navigationKey)
  if not item then return nil, "Raid Assignments navigation entry is unavailable." end
  local state = self:GetRaidAssignmentUIState()
  if state.selectedGroup == groupID and state.selectedBossKey == navigationKey then return item end
  state.selectedGroup = groupID
  state.selectedBossKey = item.key
  if not suppressRefresh then self:NotifyRaidAssignmentOptionsChanged() end
  return item
end

function MerfinPlus:GetRaidAssignmentGroup(groupID)
  for _, group in ipairs(RAID_GROUPS) do
    if group.id == groupID then
      return group
    end
  end
end

function MerfinPlus:GetRaidAssignmentStorage()
  if not self.db or not self.db.global then
    self.raidAssignmentFallbackStorage = self.raidAssignmentFallbackStorage or {
      raidImports = {},
      raidCollapsedSections = {},
      activeRaidImportByGroup = {},
      viewState = {},
    }
    return self.raidAssignmentFallbackStorage
  end
  self.db.global.assignments = self.db.global.assignments or {}
  local storage = self.db.global.assignments
  storage.raidImports = storage.raidImports or {}
  storage.raidCollapsedSections = storage.raidCollapsedSections or {}
  storage.activeRaidImportByGroup = storage.activeRaidImportByGroup or {}
  storage.viewState = storage.viewState or {}
  return storage
end

function MerfinPlus:GetRaidAssignmentImports()
  return self:GetRaidAssignmentStorage().raidImports
end

local function NormalizePersistedRaidAssignmentStatus(text)
  text = tostring(text or "")
  local sender = text:match("^Received MFPRA [FDP] revision %d+ from (.-) %(%d+ rows%)%.$")
    or text:match("^Received MFPRA1 [FDP] revision %d+ from (.-) %(%d+ rows%)%.$")
    or text:match("^Assignments received from (.-)%.$")
    or text:match("^Boss Plan received from (.-)%.$")
  if sender and sender ~= "" then return "Received from " .. sender .. "." end
  return text
end

function MerfinPlus:GetRaidAssignmentUIState()
  local storage = self:GetRaidAssignmentStorage()
  local viewState = storage.viewState
  viewState.raidAssignments = viewState.raidAssignments or {}
  self.raidAssignmentUIState = viewState.raidAssignments
  local state = self.raidAssignmentUIState
  state.input = state.input or ""
  state.status = NormalizePersistedRaidAssignmentStatus(state.status)
  state.statusTone = state.statusTone or "muted"
  if state.selectedGroup and not self:GetRaidAssignmentGroup(state.selectedGroup) then
    state.selectedGroup = nil
    state.selectedBossKey = nil
  end
  return state
end

function MerfinPlus:SetRaidAssignmentStatus(text, tone)
  local state = self:GetRaidAssignmentUIState()
  state.status = tostring(text or "")
  state.statusTone = tone or "muted"
  self:NotifyRaidAssignmentStatusChanged()
end

function MerfinPlus:NormalizeRaidAssignmentString(raw)
  return NormalizeRaidAssignmentRawText(raw)
end

function MerfinPlus:GetRaidAssignmentAbbreviation(raid)
  return raid and tostring(raid.abbreviation or raid.name or "Raid") or "Raid"
end

local RAID_NAME_ALIASES = {
  hyjalsummit = "mounthyjal",
  battleformounthyjal = "mounthyjal",
  blacktemple = "blacktemple",
}

local RAID_GROUP_NAME_ALIASES = {
  tbckarazhan = "karazhan",
  tbcsunwell = "sunwell_plateau",
  tempestkeepandserpentshrinecavern = "tk_ssc",
  hyjalsummitandblacktemple = "bt_mh",
}

local function FindCatalogRaidGroup(raidName)
  local normalizedName = NormalizeName(raidName)
  local groupID = RAID_GROUP_NAME_ALIASES[normalizedName]
  for _, group in ipairs(RAID_GROUPS) do
    if NormalizeName(group.id) == normalizedName or group.id == groupID then
      return group
    end
  end
end

local function FindCatalogRaid(raidName)
  local normalizedName = NormalizeName(raidName)
  local alias = RAID_NAME_ALIASES[normalizedName]
  for _, group in ipairs(RAID_GROUPS) do
    for _, raid in ipairs(group.raids or {}) do
      local raidKey = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$"))
      if normalizedName == NormalizeName(raid.name) or normalizedName == raidKey or alias == raidKey then
        return group, raid
      end
    end
  end
end

local function FindCatalogBoss(raid, bossName)
  local normalizedName = NormalizeName(bossName)
  for _, boss in ipairs(raid and raid.bosses or {}) do
    if normalizedName == NormalizeName(boss.name) or normalizedName == NormalizeName(boss.key) then
      return boss
    end
  end
end

local function ParseMGMRA2AssignmentRows(raw, lines)
  local parsed = {
    protocol = "MGMRA",
    version = 2,
    v2Version = 2,
    expansion = "",
    raidKey = "",
    label = "",
    comp = "",
    raids = {},
    raidMap = {},
    bosses = {},
    bossMap = {},
    v2Assignments = {},
  }
  local foundHeader, foundRaid, foundAssignment = false, false, false
  local bossMap = {}

  local function AddRaid(group, raid, comp)
    local raidKey = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$"))
    if not parsed.raidMap[raidKey] then
      parsed.raidMap[raidKey] = {
        groupID = group.id,
        key = raidKey,
        name = raid.name,
        localeID = raid.localeID,
        comp = comp or "",
      }
      parsed.raids[#parsed.raids + 1] = parsed.raidMap[raidKey]
    end
    return parsed.raidMap[raidKey]
  end

  local function AddBoss(group, raid, catalogBoss, isTrash, displayName, comp)
    local raidEntry = AddRaid(group, raid, comp)
    local key = isTrash and (raidEntry.key .. ":trash") or catalogBoss.key
    local uniqueKey = NormalizeName(key)
    local boss = bossMap[uniqueKey]
    if not boss then
      boss = {
        key = key,
        name = displayName or catalogBoss.name,
        raidKey = catalogBoss.raidKey,
        localeID = isTrash and nil or catalogBoss.localeID,
        icon = isTrash and nil or catalogBoss.icon,
        isTrash = isTrash == true,
        sections = {},
        sectionMap = {},
        v2Assignments = {},
      }
      bossMap[uniqueKey] = boss
      parsed.bosses[#parsed.bosses + 1] = boss
      parsed.bossMap[NormalizeName(boss.key)] = boss
      parsed.bossMap[NormalizeName(boss.name)] = boss
    end
    return boss
  end

  for _, line in ipairs(lines) do
    local protocol, version = line:match("^(MGMRA)|(%d+)$")
    if protocol then
      if foundHeader or tonumber(version) ~= 2 then
        return nil, "Invalid Raid Assignments version. Expected MGMRA|2."
      end
      foundHeader = true
    elseif line:sub(1, 5) == "RAID|" then
      local fields = SplitPipes(line)
      if #fields < 7
        or NormalizeName(fields[2]) ~= "expansion"
        or NormalizeName(fields[4]) ~= "raid"
        or NormalizeName(fields[6]) ~= "comp"
      then
        return nil, "Invalid MGMRA|2 RAID record."
      end
      local expansion = NormalizeName(fields[3])
      if expansion ~= "tbc" then
        return nil, "This Raid Assignments import is not for TBC."
      end
      local group, raid = FindCatalogRaid(Trim(fields[5]))
      if not raid then
        return nil, "Unsupported TBC raid in MGMRA|2: " .. Trim(fields[5])
      end
      foundRaid = true
      parsed.expansion = "tbc"
      parsed.label = Trim(fields[5])
      parsed.comp = Trim(fields[7])
      AddRaid(group, raid, parsed.comp)
    elseif line:sub(1, 11) == "ASSIGNMENT|" then
      local fields = SplitPipes(line)
      if #fields < 8 then
        return nil, "Invalid MGMRA|2 ASSIGNMENT record."
      end
      local encounterName = Trim(fields[2])
      local raidName, bossName = encounterName:match("^(.-)%s*%-%s*(.+)$")
      local trashRaidName = encounterName:match("^(.-)%s+[Tt]rash$")
      local isTrash = trashRaidName ~= nil
      raidName = Trim(isTrash and trashRaidName or raidName)
      bossName = Trim(bossName)
      if raidName == "" or (not isTrash and bossName == "") then
        return nil, "Invalid MGMRA|2 encounter: " .. encounterName
      end
      local group, raid = FindCatalogRaid(raidName)
      if not raid then
        return nil, "Unsupported TBC raid assignment: " .. encounterName
      end
      local catalogBoss
      if isTrash then
        catalogBoss = {
          key = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$")),
          name = encounterName,
          raidKey = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$")),
        }
      else
        catalogBoss = FindCatalogBoss(raid, bossName)
        if not catalogBoss then
          return nil, "Unsupported TBC encounter in MGMRA|2: " .. encounterName
        end
      end
      local boss = AddBoss(group, raid, catalogBoss, isTrash, encounterName, parsed.comp)
      local sectionName = Trim(fields[3])
      local sectionKey = NormalizeName(sectionName)
      local section = boss.sectionMap[sectionKey]
      if not section then
        section = { name = sectionName, rows = {} }
        boss.sectionMap[sectionKey] = section
        boss.sections[#boss.sections + 1] = section
      end
      local task = {
        assignment = Trim(fields[4]),
        displayLabel = Trim(fields[4]),
        player = Trim(fields[5]),
        class = Trim(fields[6]),
        spec = Trim(fields[7]),
        target = table.concat(fields, " | ", 8),
        rawLine = line,
      }
      if task.assignment == "" or task.player == "" then
        return nil, "Invalid MGMRA|2 assignment row for " .. encounterName
      end
      section.rows[#section.rows + 1] = task
      foundAssignment = true
    end
  end

  if not foundHeader then
    return nil, "Invalid Raid Assignments version. Expected MGMRA|2."
  end
  if not foundRaid then
    return nil, "MGMRA|2 imports require at least one RAID record."
  end
  if not foundAssignment or #parsed.bosses == 0 then
    return nil, "MGMRA|2 imports require assignment rows."
  end
  parsed.normalizedRaw = raw
  return parsed
end

local function ReadNamedFields(fields, startIndex)
  local values = {}
  for index = startIndex or 1, #fields, 2 do
    local key = NormalizeName(fields[index])
    if key ~= "" then
      values[key] = Trim(fields[index + 1])
    end
  end
  return values
end

local function ParseMGMRA3AssignmentRows(raw, lines)
  local parsed = {
    protocol = "MGMRA",
    version = 3,
    v2Version = 0,
    v3Version = 3,
    expansion = "tbc",
    raidKey = "",
    label = "Raid Assignments",
    comp = "",
    raids = {},
    raidMap = {},
    bosses = {},
    bossMap = {},
    v2Assignments = {},
  }
  local foundHeader, foundRaid, foundContext, foundPlayer = false, false, false, false
  local bossMap = {}
  local currentContext, currentSection

  local function AddRaid(group, raid, comp)
    local raidKey = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$"))
    local entry = parsed.raidMap[raidKey]
    if not entry then
      entry = {
        groupID = group.id,
        key = raidKey,
        name = raid.name,
        localeID = raid.localeID,
        comp = comp or "",
      }
      parsed.raidMap[raidKey] = entry
      parsed.raids[#parsed.raids + 1] = entry
    elseif comp and comp ~= "" then
      entry.comp = comp
    end
    return entry
  end

  local function AddBoss(group, raid, catalogBoss, isTrash, displayName)
    local raidEntry = AddRaid(group, raid, parsed.comp)
    local key = isTrash and (raidEntry.key .. ":trash") or catalogBoss.key
    local uniqueKey = NormalizeName(key)
    local boss = bossMap[uniqueKey]
    if not boss then
      boss = {
        key = key,
        name = displayName or catalogBoss.name,
        raidKey = catalogBoss.raidKey,
        localeID = isTrash and nil or catalogBoss.localeID,
        icon = isTrash and nil or catalogBoss.icon,
        isTrash = isTrash == true,
        sections = {},
        sectionMap = {},
        v2Assignments = {},
      }
      bossMap[uniqueKey] = boss
      parsed.bosses[#parsed.bosses + 1] = boss
      parsed.bossMap[NormalizeName(boss.key)] = boss
      parsed.bossMap[NormalizeName(boss.name)] = boss
    end
    return boss
  end

  for _, line in ipairs(lines) do
    local fields = SplitPipes(line)
    local recordType = NormalizeName(fields[1])
    if recordType == "mgmra" then
      if foundHeader or tonumber(fields[2]) ~= 3 then
        return nil, "Invalid Raid Assignments version. Expected MGMRA|3."
      end
      foundHeader = true
    elseif recordType == "raid" then
      local named = ReadNamedFields(fields, 3)
      local raidName = Trim(fields[2])
      if NormalizeName(named.expansion) ~= "tbc" or raidName == "" then
        return nil, "Invalid MGMRA|3 RAID record."
      end
      local group, raid = FindCatalogRaid(raidName)
      group = group or FindCatalogRaidGroup(raidName)
      if not group then
        return nil, "Unsupported TBC raid in MGMRA|3: " .. raidName
      end
      parsed.label = raidName
      parsed.comp = named.comp ~= "" and named.comp or parsed.comp
      if raid then
        AddRaid(group, raid, parsed.comp)
      else
        for _, groupedRaid in ipairs(group.raids or {}) do
          AddRaid(group, groupedRaid, parsed.comp)
        end
      end
      foundRaid = true
    elseif recordType == "context" then
      local contextType = NormalizeName(fields[2])
      local startIndex = contextType == "boss" and 4 or 3
      local named = ReadNamedFields(fields, startIndex)
      local raidName = Trim(named.raid)
      local bossName = contextType == "boss" and Trim(fields[3]) or ""
      local isTrash = contextType == "trash"
      if (not isTrash and contextType ~= "boss") or raidName == "" or (not isTrash and bossName == "") then
        return nil, "Invalid MGMRA|3 CONTEXT record."
      end
      local group, raid = FindCatalogRaid(raidName)
      if not raid then
        return nil, "Unsupported TBC raid context in MGMRA|3: " .. raidName
      end
      local catalogBoss
      if isTrash then
        catalogBoss = {
          key = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$")),
          name = raid.name .. " Trash",
          raidKey = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$")),
        }
      else
        catalogBoss = FindCatalogBoss(raid, bossName)
        if not catalogBoss then
          return nil, "Unsupported TBC encounter in MGMRA|3: " .. bossName
        end
      end
      local boss = AddBoss(group, raid, catalogBoss, isTrash, isTrash and (raidName .. " Trash") or bossName)
      currentContext = {
        type = isTrash and "Trash" or "Boss",
        raidName = raidName,
        bossName = bossName,
        phase = Trim(named.phase),
        boss = boss,
      }
      currentSection = nil
      foundContext = true
    elseif recordType == "section" then
      local sectionName = Trim(fields[2])
      if not currentContext or sectionName == "" then
        return nil, "MGMRA|3 SECTION records require a preceding CONTEXT."
      end
      local displayName = sectionName
      if currentContext.phase ~= "" then
        displayName = "Phase " .. currentContext.phase .. ": " .. sectionName
      end
      currentSection = {
        name = displayName,
        sourceName = sectionName,
        context = currentContext,
        rows = {},
      }
      currentContext.boss.sections[#currentContext.boss.sections + 1] = currentSection
    elseif recordType == "player" then
      if not currentContext or not currentSection then
        return nil, "MGMRA|3 PLAYER records require a preceding SECTION."
      end
      local named = ReadNamedFields(fields, 3)
      local task = {
        assignment = Trim(named.task),
        displayLabel = Trim(named.task),
        player = Trim(fields[2]),
        class = Trim(named.class),
        spec = Trim(named.spec),
        marker = Trim(named.worldmark),
        targetClass = Trim(named.targetclass),
        targetSpec = Trim(named.targetspec),
        slot = Trim(named.slot),
        position = Trim(named.position),
        target = Trim(named.target) ~= "" and Trim(named.target)
          or Trim(named.allocation) ~= "" and Trim(named.allocation)
          or Trim(named.position) ~= "" and Trim(named.position)
          or Trim(named.state) ~= "" and Trim(named.state)
          or Trim(named.worldmark),
        rawLine = line,
      }
      if task.player == "" or task.class == "" or task.spec == "" or task.assignment == "" then
        return nil, "Invalid MGMRA|3 PLAYER record."
      end
      currentSection.rows[#currentSection.rows + 1] = task
      foundPlayer = true
    end
  end

  if not foundHeader then
    return nil, "Invalid Raid Assignments version. Expected MGMRA|3."
  end
  if not foundRaid or not foundContext or not foundPlayer or #parsed.bosses == 0 then
    return nil, "MGMRA|3 imports require RAID, CONTEXT, SECTION, and PLAYER records."
  end
  parsed.normalizedRaw = raw
  return parsed
end

function MerfinPlus:ParseRaidAssignments(raw)
  local envelopeRaw = tostring(raw or "")
  if self.IsMGMRA4Envelope and self:IsMGMRA4Envelope(envelopeRaw) then
    local envelope, envelopeError = self:DecodeAndValidateMGMRA4Envelope(envelopeRaw)
    if not envelope then
      return nil, envelopeError
    end
    local legacyParsed, legacyError = self:ParseRaidAssignments(envelope.legacyAssignments)
    if not legacyParsed then
      return nil, "Invalid MGMRA4 legacyAssignments: " .. tostring(legacyError or "unknown error")
    end
    if legacyParsed.version ~= 3 then
      return nil, "MGMRA4 legacyAssignments must use MGMRA|3."
    end

    -- MGMRA4 is an additive envelope. Keep the legacy document authoritative so
    -- all existing save, personal-selection, and broadcast paths remain MGMRA|3.
    legacyParsed.envelopeVersion = 4
    legacyParsed.catalogVersion = envelope.catalogVersion
    legacyParsed.mgmra4Raw = envelopeRaw
    legacyParsed.mgmra4 = envelope
    legacyParsed.bossPlans = envelope.plans
    return legacyParsed
  end

  raw = NormalizeRaidAssignmentRawText(raw)
  local parsed = {
    protocol = "MGMRA",
    version = 1,
    v2Version = 0,
    expansion = "",
    raidKey = "",
    label = "",
    bosses = {},
    bossMap = {},
    v2Assignments = {},
  }
  local lines = {}
  for line in (raw .. "\n"):gmatch("([^\n]*)\n") do
    line = Trim(line)
    if line ~= "" then
      lines[#lines + 1] = line
    end
  end

  local headerVersion
  local hasMGMRA2Rows = false
  for _, line in ipairs(lines) do
    local protocol, version = line:match("^([^|]+)|(%d+)$")
    if NormalizeName(protocol) == "mgmra" then
      headerVersion = tonumber(version)
    end
    if line:sub(1, 5) == "RAID|" or line:sub(1, 11) == "ASSIGNMENT|" then
      hasMGMRA2Rows = true
    end
  end
  if headerVersion == 3 then
    return ParseMGMRA3AssignmentRows(raw, lines)
  end
  if hasMGMRA2Rows then
    return ParseMGMRA2AssignmentRows(raw, lines)
  end

  local bossStarts = {}
  for index = 1, #lines - 1 do
    local heading = lines[index]:match("^%[(.-)%]$")
    if heading and lines[index + 1]:sub(1, 5) == "META|" then
      bossStarts[#bossStarts + 1] = { headerIndex = index, name = Trim(heading) }
    end
  end

  local rootEnd = bossStarts[1] and bossStarts[1].headerIndex - 1 or #lines
  for index = 1, rootEnd do
    local line = lines[index]
    local protocol, version = line:match("^(MGMRA)|(%d+)$")
    if protocol then
      parsed.version = tonumber(version) or 1
    elseif line:sub(1, 5) == "META|" then
      local fields = SplitPipes(line)
      parsed.expansion = Trim(fields[2])
      parsed.raidKey = Trim(fields[3])
      parsed.label = Trim(fields[4])
    end
  end

  local seenV2AssignmentIDs = {}
  for index = 1, rootEnd do
    local line = lines[index]
    if line:sub(1, 3) == "V2|" then
      local fields = SplitPipes(line)
      local version = tonumber(fields[2])
      if version == 2 and #fields >= 15 then
        local function ReadField(fieldIndex)
          local value = DecodeAddonPayload(Trim(fields[fieldIndex]))
          return value == "-" and "" or value
        end
        local assignmentID = ReadField(3)
        if assignmentID ~= "" and not seenV2AssignmentIDs[assignmentID] then
          seenV2AssignmentIDs[assignmentID] = true
          local phase = ReadField(6)
          local assignmentKey = ReadField(7)
          local marker = ReadField(9)
          local sectionName = ReadField(10)
          sectionName, marker = CanonicalRaidAssignmentV2Section(assignmentKey, phase, sectionName, marker)
          local target = ReadField(15)
          local task = {
            assignmentId = assignmentID,
            bossKey = ReadField(4),
            planId = ReadField(5),
            phase = phase,
            assignmentKey = assignmentKey,
            slot = tonumber(ReadField(8)) or 0,
            marker = marker,
            sectionName = sectionName,
            assignment = ReadField(11),
            displayLabel = ReadField(11),
            player = ReadField(12),
            class = ReadField(13),
            spec = ReadField(14),
            target = target ~= "" and target or marker,
            rawLine = line,
          }
          if task.player ~= "" then
            parsed.v2Assignments[#parsed.v2Assignments + 1] = task
            parsed.v2Version = 2
          end
        end
      end
    end
  end

  for bossIndex, start in ipairs(bossStarts) do
    local meta = SplitPipes(lines[start.headerIndex + 1])
    local boss = {
      name = start.name,
      key = Trim(meta[2]),
      raidKey = Trim(meta[3]),
      sections = {},
      v2Assignments = {},
    }
    parsed.bosses[#parsed.bosses + 1] = boss
    local blockEnd = (bossStarts[bossIndex + 1] and bossStarts[bossIndex + 1].headerIndex - 1) or #lines
    local currentSection
    for index = start.headerIndex + 2, blockEnd do
      local line = lines[index]
      local heading = line:match("^%[(.-)%]$")
      if heading then
        currentSection = { name = Trim(heading), rows = {} }
        boss.sections[#boss.sections + 1] = currentSection
      elseif line ~= "//" and line ~= "////" and currentSection then
        local fields = SplitPipes(line)
        if #fields >= 2 then
          local isAdditional = NormalizeName(currentSection.name) == "additionalassignments"
          local task
          if isAdditional and #fields >= 4 then
            local useIndex
            for fieldIndex = 5, #fields do
              if NormalizeName(fields[fieldIndex]) == "use" then
                useIndex = fieldIndex
                break
              end
            end
            local spellName = useIndex and Trim(fields[useIndex + 1]) or Trim(fields[4])
            local targetName = ""
            for fieldIndex = (useIndex or #fields) + 1, #fields do
              if NormalizeName(fields[fieldIndex]) == "useon" then
                targetName = Trim(fields[#fields])
                break
              end
            end
            task = {
              assignment = spellName,
              displayLabel = spellName,
              player = Trim(fields[3]),
              class = Trim(fields[1]),
              spec = Trim(fields[2]),
              target = targetName,
              context = Trim(fields[4]) .. (Trim(fields[5]) ~= "" and (": " .. Trim(fields[5])) or ""),
              rawLine = line,
            }
          else
            task = {
              assignment = Trim(fields[1]),
              player = Trim(fields[2]),
              class = Trim(fields[3]),
              spec = Trim(fields[4]),
              target = table.concat(fields, " | ", 5),
              rawLine = line,
            }
          end
          if task.player ~= "" then
            currentSection.rows[#currentSection.rows + 1] = task
          end
        end
      end
    end
  end

  if parsed.expansion == "" then
    parsed.expansion = "tbc"
  end
  if parsed.label == "" then
    parsed.label = "Raid Assignments"
  end
  for _, boss in ipairs(parsed.bosses) do
    local key = NormalizeName(boss.key)
    if key ~= "" then
      parsed.bossMap[key] = boss
      local shortKey = NormalizeName(tostring(boss.key or ""):match("([^.]+)$"))
      if shortKey ~= "" then
        parsed.bossMap[shortKey] = boss
      end
    end
    parsed.bossMap[NormalizeName(boss.name)] = boss
  end
  for _, task in ipairs(parsed.v2Assignments) do
    local taskBossKey = NormalizeName(task.bossKey)
    for _, boss in ipairs(parsed.bosses) do
      if taskBossKey ~= "" and NormalizeName(boss.key) == taskBossKey then
        boss.v2Assignments[#boss.v2Assignments + 1] = task
        break
      end
    end
  end
  if #parsed.bosses == 0 then
    return nil, "Invalid Raid Assignments string: no boss blocks found."
  end
  parsed.normalizedRaw = raw
  return parsed
end

function MerfinPlus:GetRaidAssignmentBoss(parsed, boss)
  if not parsed or not boss then
    return nil
  end
  local uiKey = NormalizeName(boss.key)
  local uiName = NormalizeName(boss.name)
  local uiRaidKey = NormalizeName(boss.raidKey)
  local bestBoss, bestScore
  for _, parsedBoss in ipairs(parsed.bosses or {}) do
    local shortKey = NormalizeName(tostring(parsedBoss.key or ""):match("([^.]+)$"))
    local headingKey = NormalizeName(parsedBoss.name)
    local headingBossKey = NormalizeName(tostring(parsedBoss.name or ""):match("%s%-%s(.+)$") or parsedBoss.name)
    local parsedRaidKey = NormalizeName(parsedBoss.raidKey)
    local raidMatches = uiRaidKey == ""
      or parsedRaidKey == ""
      or uiRaidKey == parsedRaidKey
      or uiRaidKey:find(parsedRaidKey, 1, true) ~= nil
      or parsedRaidKey:find(uiRaidKey, 1, true) ~= nil
    local score = 0
    if raidMatches then
      if shortKey ~= "" and shortKey == uiKey then
        score = 100
      elseif headingBossKey ~= "" and headingBossKey == uiName then
        score = 95
      elseif headingKey == uiName then
        score = 90
      elseif shortKey ~= "" and uiKey ~= "" and (uiKey:find(shortKey, 1, true) or shortKey:find(uiKey, 1, true)) then
        score = 80
      elseif headingBossKey ~= "" and uiName ~= "" and (headingBossKey:find(uiName, 1, true) or uiName:find(headingBossKey, 1, true)) then
        score = 70
      end
    end
    if score > (bestScore or 0) then
      bestBoss, bestScore = parsedBoss, score
    end
  end
  return bestBoss
end

function MerfinPlus:GetRaidAssignmentBossLocaleID(parsedBoss)
  if not parsedBoss then
    return nil
  end
  local singleBossDocument = { bosses = { parsedBoss } }
  for _, group in ipairs(RAID_GROUPS) do
    for _, raid in ipairs(group.raids or {}) do
      for _, catalogBoss in ipairs(raid.bosses or {}) do
        if self:GetRaidAssignmentBoss(singleBossDocument, catalogBoss) == parsedBoss then
          return catalogBoss.localeID
        end
      end
    end
  end
end

function MerfinPlus:FindRaidAssignmentGroupForParsed(parsed)
  for _, importedRaid in ipairs(parsed and parsed.raids or {}) do
    for _, group in ipairs(RAID_GROUPS) do
      for _, raid in ipairs(group.raids or {}) do
        local raidKey = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$"))
        if raidKey == NormalizeName(importedRaid.key) then
          return group
        end
      end
    end
  end
  for _, group in ipairs(RAID_GROUPS) do
    for _, raid in ipairs(group.raids or {}) do
      for _, boss in ipairs(raid.bosses or {}) do
        if self:GetRaidAssignmentBoss(parsed, boss) then
          return group
        end
      end
    end
  end
end

local RAID_ASSIGNMENT_ENTRY_PARSE_CACHE = setmetatable({}, { __mode = "k" })

local function GetStoredRaidAssignmentParseSource(owner, entry)
  if entry and entry.canonicalRaw and owner.ParseCanonicalRaidAssignmentEntry then
    return "canonical", entry.canonicalRaw, entry.canonicalSignature
  end
  return "legacy", entry and (entry.mgmra4Raw or entry.raw) or "", entry and entry.contentSignature
end

function MerfinPlus:CacheRaidAssignmentEntryParse(entry, parsed, parseError)
  if not entry then return parsed, parseError end
  local sourceKind, sourceRaw, sourceSignature = GetStoredRaidAssignmentParseSource(self, entry)
  RAID_ASSIGNMENT_ENTRY_PARSE_CACHE[entry] = {
    sourceKind = sourceKind,
    sourceRaw = sourceRaw,
    sourceSignature = sourceSignature,
    parsed = parsed,
    parseError = parseError,
  }
  entry.parsed, entry.parseError = parsed, parseError
  return parsed, parseError
end

function MerfinPlus:InvalidateRaidAssignmentEntryParse(entry)
  if not entry then return end
  RAID_ASSIGNMENT_ENTRY_PARSE_CACHE[entry] = nil
  entry.parsed, entry.parseError = nil, nil
end

local function ParseStoredRaidAssignmentEntry(owner, entry)
  local sourceKind, sourceRaw, sourceSignature = GetStoredRaidAssignmentParseSource(owner, entry)
  local cached = entry and RAID_ASSIGNMENT_ENTRY_PARSE_CACHE[entry]
  if cached
    and cached.sourceKind == sourceKind
    and cached.sourceRaw == sourceRaw
    and cached.sourceSignature == sourceSignature
  then
    entry.parsed, entry.parseError = cached.parsed, cached.parseError
    return cached.parsed, cached.parseError
  end
  local parsed, parseError
  if sourceKind == "canonical" then
    parsed, parseError = owner:ParseCanonicalRaidAssignmentEntry(entry)
  else
    parsed, parseError = owner:ParseRaidAssignments(sourceRaw)
  end
  return owner:CacheRaidAssignmentEntryParse(entry, parsed, parseError)
end

function MerfinPlus:GetRaidAssignmentImportForGroup(groupID)
  local storage = self:GetRaidAssignmentStorage()
  local activeID = storage.activeRaidImportByGroup[groupID]
  local selected
  for _, entry in ipairs(storage.raidImports) do
    if entry.id == activeID and entry.raidGroup == groupID then
      selected = entry
      break
    end
  end
  if not selected then
    for index = #storage.raidImports, 1, -1 do
      local entry = storage.raidImports[index]
      if entry.raidGroup == groupID then
        selected = entry
        storage.activeRaidImportByGroup[groupID] = entry.id
        break
      end
    end
  end
  if selected and selected.raw then
    selected.parsed, selected.parseError = ParseStoredRaidAssignmentEntry(self, selected)
  end
  return selected
end

local function GetRaidAssignmentImportRaidLabel(entry)
  local selectedRaids, unmatched = {}, {}
  for _, raid in ipairs(entry and entry.parsed and entry.parsed.raids or {}) do
    local name = Trim(raid.name or raid.key)
    local group, catalogRaid = FindCatalogRaid(name)
    if group and catalogRaid then
      selectedRaids[group.id] = selectedRaids[group.id] or {}
      selectedRaids[group.id][catalogRaid.localeID] = true
    elseif name ~= "" then
      unmatched[#unmatched + 1] = name
    end
  end

  local labels = {}
  for _, group in ipairs(RAID_GROUPS) do
    local selected = selectedRaids[group.id]
    if selected then
      local selectedCount = 0
      for _, raid in ipairs(group.raids or {}) do
        if selected[raid.localeID] then
          selectedCount = selectedCount + 1
        end
      end
      if selectedCount == #(group.raids or {}) and group.savedImportLabel then
        labels[#labels + 1] = group.savedImportLabel
      else
        for _, raid in ipairs(group.raids or {}) do
          if selected[raid.localeID] then
            labels[#labels + 1] = MerfinPlus:GetRaidAssignmentAbbreviation(raid)
          end
        end
      end
    end
  end
  for _, name in ipairs(unmatched) do
    labels[#labels + 1] = name
  end
  if #labels == 0 then
    labels[1] = Trim(entry and entry.raidGroupName) ~= "" and entry.raidGroupName or "Raid Assignments"
  end
  return table.concat(labels, "/")
end

local function IsManageableRaidAssignmentImport(entry)
  return type(entry) == "table" and (
    (type(entry.canonicalRaw) == "string" and entry.canonicalRaw ~= "")
    or (type(entry.raw) == "string" and entry.raw ~= "")
  )
end

local function GetRaidAssignmentBossPlanSourceKey(entry)
  local raw = tostring(entry and (entry.canonicalRaw or entry.mgmra4Raw) or "")
  local hash = 5381
  for index = 1, #raw do
    hash = (hash * 33 + raw:byte(index)) % 2147483647
  end
  return tostring(entry and entry.contentSignature or "") .. ":" .. tostring(#raw) .. ":" .. tostring(hash)
end

local function ClearRaidAssignmentPlanStorageForEntry(storage, entry)
  local sourceKey = GetRaidAssignmentBossPlanSourceKey(entry)
  for _, candidate in ipairs(storage.raidImports or {}) do
    if GetRaidAssignmentBossPlanSourceKey(candidate) == sourceKey then
      return
    end
  end
  for _, storageKey in ipairs({ "bossPlanLocalEdits", "bossPlanWorkingDrafts" }) do
    if type(storage[storageKey]) == "table" then
      storage[storageKey][sourceKey] = nil
    end
  end
end

local function ClearRaidAssignmentGroupState(owner, storage, groupID)
  local normalizedGroup = NormalizeName(groupID)
  local cachePrefix = normalizedGroup .. "\31"
  for _, storageKey in ipairs({ "mfpPersonalWidgetTrashByRaid", "mfpPersonalWidgetTrashScopes" }) do
    for key in pairs(storage[storageKey] or {}) do
      if tostring(key):sub(1, #cachePrefix) == cachePrefix then
        storage[storageKey][key] = nil
      end
    end
  end
  for key in pairs(storage.mfpReceivedRevisions or {}) do
    for _, kind in ipairs({ "F", "D", "P" }) do
      local prefix = kind .. ":" .. tostring(groupID) .. ":"
      if tostring(key):sub(1, #prefix) == prefix then
        storage.mfpReceivedRevisions[key] = nil
        break
      end
    end
  end
  if storage.mfpPersonalWidgetState
    and tostring(storage.mfpPersonalWidgetState.g or "") == tostring(groupID)
  then
    storage.mfpPersonalWidgetState = nil
  end
  if storage.personalRaidSelection
    and tostring(storage.personalRaidSelection.raidGroup or "") == tostring(groupID)
  then
    storage.personalRaidSelection = nil
  end
  if storage.activePersonalRaidImportId then
    local activeEntry
    for _, candidate in ipairs(storage.raidImports or {}) do
      if tostring(candidate.id or "") == tostring(storage.activePersonalRaidImportId) then
        activeEntry = candidate
        break
      end
    end
    if not activeEntry then
      storage.activePersonalRaidImportId = nil
      storage.activePersonalRaidBossKey = nil
    end
  end
  if type(storage.localPersonalRaidRaw) == "string" and storage.localPersonalRaidRaw ~= "" then
    local parsed = owner:ParseRaidAssignments(storage.localPersonalRaidRaw)
    local group = parsed and owner:FindRaidAssignmentGroupForParsed(parsed)
    if group and group.id == groupID then
      storage.localPersonalRaidRaw = nil
      owner:InvalidateLocalPersonalRaidAssignmentParse()
    end
  end
  if type(storage.bossPlanReceivedRevisionByGroup) == "table" then
    storage.bossPlanReceivedRevisionByGroup[groupID] = nil
  end
  local planRevisionPrefix = tostring(groupID) .. "|"
  for key in pairs(storage.bossPlanReceivedRevisionByPlan or {}) do
    if tostring(key):sub(1, #planRevisionPrefix) == planRevisionPrefix then
      storage.bossPlanReceivedRevisionByPlan[key] = nil
    end
  end
  owner.mfpCanonicalPersonalImportCache = nil
end

function MerfinPlus:GetSavedRaidAssignmentImports()
  local saved = {}
  for _, entry in ipairs(self:GetRaidAssignmentStorage().raidImports or {}) do
    if IsManageableRaidAssignmentImport(entry) then
      entry.parsed, entry.parseError = ParseStoredRaidAssignmentEntry(self, entry)
      entry.importedAtText = FormatTimestamp(entry.importedAt)
      local raidLabel = GetRaidAssignmentImportRaidLabel(entry)
      if entry.receivedBroadcast == true then
        local sender = CleanPlayerName(entry.broadcastSender)
        entry.savedLabel = (sender ~= "" and self:T("Received from %s", sender) or self:T("Received Sync"))
          .. " - " .. raidLabel .. " - " .. tostring(entry.importedAtText or "")
      else
        entry.savedLabel = raidLabel .. " - " .. tostring(entry.importedAtText or "")
      end
      saved[#saved + 1] = entry
    end
  end
  table.sort(saved, function(left, right)
    local leftAt, rightAt = tonumber(left.importedAt) or 0, tonumber(right.importedAt) or 0
    if leftAt == rightAt then
      return tostring(left.id) > tostring(right.id)
    end
    return leftAt > rightAt
  end)
  return saved
end

function MerfinPlus:SelectSavedRaidAssignmentImport(importID)
  local wantedID = tostring(importID or "")
  for _, entry in ipairs(self:GetSavedRaidAssignmentImports()) do
    if tostring(entry.id or "") == wantedID then
      local state = self:GetRaidAssignmentUIState()
      state.selectedSavedRaidImportID = entry.id
      if not entry.parsed then
        state.status = "Saved Raid Assignments import selected, but it cannot be loaded. You can remove it safely."
        state.statusTone = "red"
        self:NotifyRaidAssignmentsChanged()
        return entry, entry.parseError or "Saved Raid Assignments import could not be parsed."
      end
      local storage = self:GetRaidAssignmentStorage()
      storage.activeRaidImportByGroup[entry.raidGroup] = entry.id
      state.selectedGroup = entry.raidGroup
      state.selectedBossKey = nil
      state.status = "Saved Raid Assignments import loaded."
      state.statusTone = "good"
      self:NotifyRaidAssignmentsChanged()
      return entry
    end
  end
  return nil, "Saved Raid Assignments import is unavailable."
end

function MerfinPlus:RemoveSavedRaidAssignmentImport(importID)
  local storage = self:GetRaidAssignmentStorage()
  local wantedID = tostring(importID or "")
  for index, entry in ipairs(storage.raidImports or {}) do
    if tostring(entry.id or "") == wantedID and IsManageableRaidAssignmentImport(entry) then
      self:InvalidateRaidAssignmentEntryParse(entry)
      table.remove(storage.raidImports, index)
      local replacement
      for candidateIndex = #storage.raidImports, 1, -1 do
        local candidate = storage.raidImports[candidateIndex]
        if candidate.raidGroup == entry.raidGroup and IsManageableRaidAssignmentImport(candidate) then
          replacement = candidate
          break
        end
      end
      if tostring(storage.activeRaidImportByGroup[entry.raidGroup] or "") == wantedID then
        storage.activeRaidImportByGroup[entry.raidGroup] = replacement and replacement.id or nil
      end
      if tostring(storage.activePersonalRaidImportId or "") == wantedID then
        storage.activePersonalRaidImportId = nil
        storage.activePersonalRaidBossKey = nil
      end
      if storage.personalRaidSelection
        and tostring(storage.personalRaidSelection.entryID or "") == wantedID
      then
        storage.personalRaidSelection = nil
      end
      local collapsedPrefix = wantedID .. "::"
      for key in pairs(storage.raidCollapsedSections or {}) do
        if tostring(key):sub(1, #collapsedPrefix) == collapsedPrefix then
          storage.raidCollapsedSections[key] = nil
        end
      end
      local state = self:GetRaidAssignmentUIState()
      if tostring(state.selectedSavedRaidImportID or "") == wantedID then
        state.selectedSavedRaidImportID = replacement and replacement.id or nil
        if replacement then
          state.selectedGroup = replacement.raidGroup
          state.selectedBossKey = nil
        else
          if state.selectedGroup == entry.raidGroup then
            state.selectedGroup = nil
          end
          state.selectedBossKey = nil
        end
      end
      if not replacement then
        storage.activeRaidImportByGroup[entry.raidGroup] = nil
        if state.selectedGroup == entry.raidGroup then
          state.selectedGroup = nil
          state.selectedBossKey = nil
        end
        ClearRaidAssignmentGroupState(self, storage, entry.raidGroup)
      end
      ClearRaidAssignmentPlanStorageForEntry(storage, entry)
      state.status = "Saved Raid Assignments import removed."
      state.statusTone = "muted"
      self:NotifyRaidAssignmentsChanged()
      return true
    end
  end
  return false, "Saved Raid Assignments import is unavailable."
end

local function SerializeMGMRA3Task(task, targetPlayer)
  local line = tostring(task.rawLine or "")
  if targetPlayer and not targetPlayer.ambiguous and not line:find("|TargetClass|", 1, true) then
    line = line .. "|TargetClass|" .. tostring(targetPlayer.class or "")
      .. "|TargetSpec|" .. tostring(targetPlayer.spec or "")
  end
  return line
end

local function SerializeMGMRA3(parsed, bosses, playerName)
  local output = { "MGMRA|3" }
  local selected = {}
  for _, boss in ipairs(bosses or parsed.bosses or {}) do
    selected[boss] = true
  end
  local usedRaids = {}
  for _, boss in ipairs(parsed.bosses or {}) do
    if selected[boss] and not usedRaids[boss.raidKey] then
      local raid = parsed.raidMap and parsed.raidMap[NormalizeName(boss.raidKey)]
      if raid then
        output[#output + 1] = table.concat({
          "RAID", raid.name, "Expansion", "TBC", "Comp", raid.comp or parsed.comp or "",
        }, "|")
        usedRaids[boss.raidKey] = true
      end
    end
  end
  local count = 0
  for _, boss in ipairs(parsed.bosses or {}) do
    if selected[boss] then
      local playerMap = playerName and MerfinPlus:BuildRaidAssignmentPlayerMap(boss) or nil
      for _, section in ipairs(boss.sections or {}) do
        local rows = {}
        for _, task in ipairs(section.rows or {}) do
          if not playerName
            or NormalizeName(CleanPlayerName(task.player)) == NormalizeName(CleanPlayerName(playerName))
          then
            rows[#rows + 1] = task
          end
        end
        if #rows > 0 then
          local context = section.context or {}
          if boss.isTrash then
            output[#output + 1] = table.concat({ "CONTEXT", "Trash", "Raid", context.raidName or boss.raidKey or "" }, "|")
          else
            local contextLine = table.concat({
              "CONTEXT", "Boss", context.bossName or boss.name or "", "Raid", context.raidName or boss.raidKey or "",
            }, "|")
            if context.phase and context.phase ~= "" then
              contextLine = contextLine .. "|Phase|" .. context.phase
            end
            output[#output + 1] = contextLine
          end
          output[#output + 1] = "SECTION|" .. tostring(section.sourceName or section.name or "")
          for _, task in ipairs(rows) do
            local targetPlayer = playerMap and playerMap[NormalizeName(CleanPlayerName(task.target))]
            output[#output + 1] = SerializeMGMRA3Task(task, targetPlayer)
            count = count + 1
          end
        end
      end
    end
  end
  return count > 0 and table.concat(output, "\n") or nil, count
end

local function MergeMGMRA3Documents(existing, incoming)
  local function GetRaidKey(document)
    for _, boss in ipairs(document.bosses or {}) do
      if boss.isTrash then
        return NormalizeName(boss.raidKey)
      end
    end
    local boss = document.bosses and document.bosses[1]
    return NormalizeName(boss and boss.raidKey)
  end
  local function GetTrash(document, raidKey)
    for _, boss in ipairs(document.bosses or {}) do
      if boss.isTrash and NormalizeName(boss.raidKey) == raidKey then
        return boss
      end
    end
  end
  local function GetCurrentBoss(document, raidKey)
    -- A personal payload represents one current boss.  Use its last non-Trash
    -- record so an older payload can never leave several boss blocks visible.
    local current
    for _, boss in ipairs(document.bosses or {}) do
      if not boss.isTrash and NormalizeName(boss.raidKey) == raidKey then
        current = boss
      end
    end
    return current
  end

  local existingRaidKey = GetRaidKey(existing)
  local incomingRaidKey = GetRaidKey(incoming)
  -- A Trash delivery for another raid establishes a completely new personal
  -- context.  Never retain Trash or boss data from the previous raid.
  if incomingRaidKey ~= "" and existingRaidKey ~= "" and incomingRaidKey ~= existingRaidKey then
    return incoming
  end
  local raidKey = incomingRaidKey ~= "" and incomingRaidKey or existingRaidKey
  if raidKey == "" then
    return incoming
  end

  local incomingTrash = GetTrash(incoming, raidKey)
  local incomingBoss = GetCurrentBoss(incoming, raidKey)
  local selectedTrash = incomingTrash or GetTrash(existing, raidKey)
  -- A newly broadcast boss replaces the previous boss.  A Trash-only update
  -- retains the one current boss and moves/keeps Trash above it.
  local selectedBoss = incomingBoss or GetCurrentBoss(existing, raidKey)
  existing.bosses = {}
  if selectedTrash then
    existing.bosses[#existing.bosses + 1] = selectedTrash
  end
  if selectedBoss then
    existing.bosses[#existing.bosses + 1] = selectedBoss
  end

  existing.raidMap = existing.raidMap or {}
  existing.raids = existing.raids or {}
  for _, raid in ipairs(incoming.raids or {}) do
    if not existing.raidMap[raid.key] then
      existing.raidMap[raid.key] = raid
      existing.raids[#existing.raids + 1] = raid
    end
  end
  existing.bossMap = {}
  for _, boss in ipairs(existing.bosses) do
    existing.bossMap[NormalizeName(boss.key)] = boss
    existing.bossMap[NormalizeName(boss.name)] = boss
  end
  existing.normalizedRaw = SerializeMGMRA3(existing)
  return existing
end

function MerfinPlus:SaveRaidAssignmentImport(raw, groupID, receivedBroadcast, sender, suppressDuplicateRefresh, skipPersonalWidgetRefresh)
  local parsed, errorText = self:ParseRaidAssignments(raw)
  if not parsed then
    return nil, errorText
  end
  local group = self:GetRaidAssignmentGroup(groupID) or self:FindRaidAssignmentGroupForParsed(parsed)
  if not group then
    return nil, "The imported bosses do not match a supported TBC raid."
  end
  local contentSignature = GetRaidAssignmentContentSignature(parsed.normalizedRaw)

  local storage = self:GetRaidAssignmentStorage()
  if receivedBroadcast == true and parsed.version == 3 and not parsed.mgmra4Raw then
    for _, existing in ipairs(storage.raidImports) do
      if existing.raidGroup == group.id and existing.receivedBroadcast == true and existing.raw then
        local previous = self:ParseRaidAssignments(existing.raw)
        if previous and previous.version == 3 then
          parsed = MergeMGMRA3Documents(previous, parsed)
          break
        end
      end
    end
  end
  for _, existing in ipairs(storage.raidImports) do
    existing.contentSignature = existing.contentSignature
      or GetRaidAssignmentContentSignature(existing.raw)
    if existing.raidGroup == group.id
      and existing.contentSignature == contentSignature
      and NormalizeRaidAssignmentRawText(existing.raw) == parsed.normalizedRaw
      and (existing.receivedBroadcast == true) == (receivedBroadcast == true)
    then
      if not parsed.mgmra4Raw and existing.mgmra4Raw then
        local envelopeParsed = self:ParseRaidAssignments(existing.mgmra4Raw)
        parsed = envelopeParsed or parsed
      end
      if parsed.mgmra4Raw then
        existing.envelopeVersion = parsed.envelopeVersion
        existing.catalogVersion = parsed.catalogVersion
        existing.mgmra4Raw = parsed.mgmra4Raw
      end
      self:CacheRaidAssignmentEntryParse(existing, parsed)
      if suppressDuplicateRefresh then
        return existing, nil, true
      end
      storage.activeRaidImportByGroup[group.id] = existing.id
      local state = self:GetRaidAssignmentUIState()
      state.selectedGroup = group.id
      state.selectedBossKey = nil
      if receivedBroadcast == true then
        storage.activePersonalRaidImportId = existing.id
        storage.activePersonalRaidBossKey = parsed.bosses[1] and parsed.bosses[1].key or nil
        existing.broadcastSender = tostring(sender or existing.broadcastSender or "")
        state.selectedSavedRaidImportID = existing.id
      else
        state.selectedSavedRaidImportID = existing.id
      end
      self:NotifyRaidAssignmentsChanged(not skipPersonalWidgetRefresh)
      return existing, nil, true
    end
  end

  local now = Now()
  local ordinal = #storage.raidImports + 1
  local importID
  local used = {}
  for _, entry in ipairs(storage.raidImports) do
    used[entry.id] = true
  end
  repeat
    importID = tostring(now) .. "-raid-" .. tostring(ordinal)
    ordinal = ordinal + 1
  until not used[importID]

  local entry = {
    id = importID,
    protocol = parsed.protocol,
    version = parsed.version,
    expansion = parsed.expansion,
    raidGroup = group.id,
    raidGroupName = group.name,
    raw = parsed.normalizedRaw,
    envelopeVersion = parsed.envelopeVersion,
    catalogVersion = parsed.catalogVersion,
    mgmra4Raw = parsed.mgmra4Raw,
    contentSignature = contentSignature,
    parsed = parsed,
    importedAt = now,
    importedAtText = FormatTimestamp(now),
    receivedBroadcast = receivedBroadcast == true,
    broadcastSender = tostring(sender or ""),
  }

  local insertIndex = #storage.raidImports + 1
  for index = #storage.raidImports, 1, -1 do
    local existing = storage.raidImports[index]
    if entry.receivedBroadcast and existing.receivedBroadcast and existing.raidGroup == group.id then
      if storage.activeRaidImportByGroup[existing.raidGroup] == existing.id then
        storage.activeRaidImportByGroup[existing.raidGroup] = nil
      end
      insertIndex = index
      self:InvalidateRaidAssignmentEntryParse(existing)
      table.remove(storage.raidImports, index)
    end
  end
  table.insert(storage.raidImports, math.min(insertIndex, #storage.raidImports + 1), entry)
  self:CacheRaidAssignmentEntryParse(entry, parsed)
  storage.activeRaidImportByGroup[group.id] = entry.id
  local state = self:GetRaidAssignmentUIState()
  state.selectedGroup = group.id
  state.selectedBossKey = nil
  state.selectedSavedRaidImportID = entry.id
  if entry.receivedBroadcast then
    storage.activePersonalRaidImportId = entry.id
    storage.activePersonalRaidBossKey = parsed.bosses[1] and parsed.bosses[1].key or nil
  end
  self:NotifyRaidAssignmentsChanged(not skipPersonalWidgetRefresh)
  return entry, nil, false
end

function MerfinPlus:FindRaidAssignmentImportBySignature(groupID, contentSignature)
  for _, entry in ipairs(self:GetRaidAssignmentStorage().raidImports or {}) do
    entry.contentSignature = entry.contentSignature
      or GetRaidAssignmentContentSignature(entry.raw)
    if entry.raidGroup == groupID and entry.contentSignature == contentSignature then
      entry.parsed, entry.parseError = ParseStoredRaidAssignmentEntry(self, entry)
      if entry.parsed then
        return entry
      end
    end
  end
end

function MerfinPlus:ResolvePersonalRaidAssignmentSelection(groupID, contentSignature, raidKey, bossKey)
  local entry = self:FindRaidAssignmentImportBySignature(groupID, contentSignature)
  if not entry or not entry.parsed then
    return nil, nil, "Full Raid Assignments sync is required before boss assignments can be shown."
  end
  local boss = self:GetRaidAssignmentBoss(entry.parsed, {
    key = bossKey,
    raidKey = raidKey,
    name = bossKey,
  })
  if not boss then
    return nil, nil, "The selected boss is not present in the synced Raid Assignments."
  end
  return entry, boss
end

function MerfinPlus:InvalidateLocalPersonalRaidAssignmentParse()
  self.raidAssignmentLocalPersonalParseCache = nil
end

local function ParseLocalPersonalRaidAssignments(owner, raw)
  raw = tostring(raw or "")
  local cached = owner.raidAssignmentLocalPersonalParseCache
  if cached and cached.raw == raw then
    return cached.parsed, cached.parseError
  end
  local parsed, parseError = owner:ParseRaidAssignments(raw)
  owner.raidAssignmentLocalPersonalParseCache = {
    raw = raw,
    parsed = parsed,
    parseError = parseError,
  }
  return parsed, parseError
end

function MerfinPlus:SetPersonalRaidAssignmentSelection(entry, boss)
  local storage = self:GetRaidAssignmentStorage()
  local contentSignature = entry.contentSignature or GetRaidAssignmentContentSignature(entry.raw)
  local previous = storage.personalRaidSelection
  local sameRaidContext = previous
    and previous.raidGroup == entry.raidGroup
    and previous.contentSignature == contentSignature
    and NormalizeName(previous.raidKey) == NormalizeName(boss.raidKey)
  local selection = sameRaidContext and previous or {
    entryID = entry.id,
    raidGroup = entry.raidGroup,
    contentSignature = contentSignature,
    raidKey = boss.raidKey,
  }
  selection.entryID = entry.id
  selection.raidGroup = entry.raidGroup
  selection.contentSignature = contentSignature
  selection.raidKey = boss.raidKey
  if boss.isTrash then
    selection.trashBossKey = boss.key
  else
    -- There is intentionally only one current non-Trash boss.  Later boss
    -- commands replace it while retaining this raid's persistent Trash card.
    selection.bossKey = boss.key
  end
  storage.personalRaidSelection = selection
  -- A selection command resolves from a full local document.  It must never
  -- retain an older row payload as the widget's source of truth.
  storage.localPersonalRaidRaw = nil
  self:InvalidateLocalPersonalRaidAssignmentParse()
  storage.activePersonalRaidImportId = nil
  storage.activePersonalRaidBossKey = nil
end

function MerfinPlus:GetActivePersonalRaidAssignmentImport()
  local storage = self:GetRaidAssignmentStorage()
  if storage.mfpPersonalWidgetState and self.BuildCanonicalPersonalRaidAssignmentImport then
    local canonical = self:BuildCanonicalPersonalRaidAssignmentImport()
    if canonical then return canonical end
  end
  local selection = storage.personalRaidSelection
  if selection then
    local entry = self:FindRaidAssignmentImportBySignature(
      selection.raidGroup,
      selection.contentSignature
    )
    if entry then
      entry.personalRaidSelection = selection
      return entry
    end
    storage.personalRaidSelection = nil
  end
  if storage.localPersonalRaidRaw then
    local parsed = ParseLocalPersonalRaidAssignments(self, storage.localPersonalRaidRaw)
    if parsed then
      return {
        id = "local-personal",
        raw = storage.localPersonalRaidRaw,
        parsed = parsed,
        receivedBroadcast = false,
      }
    end
    storage.localPersonalRaidRaw = nil
    self:InvalidateLocalPersonalRaidAssignmentParse()
  end
  for _, entry in ipairs(storage.raidImports) do
    if entry.id == storage.activePersonalRaidImportId then
      entry.parsed, entry.parseError = ParseStoredRaidAssignmentEntry(self, entry)
      return entry
    end
  end
  storage.activePersonalRaidImportId = nil
  storage.activePersonalRaidBossKey = nil
end

function MerfinPlus:SetLocalPersonalRaidAssignments(raw)
  local incoming = self:ParseRaidAssignments(raw)
  if not incoming or incoming.version ~= 3 then
    return
  end
  local storage = self:GetRaidAssignmentStorage()
  if storage.localPersonalRaidRaw then
    local existing = ParseLocalPersonalRaidAssignments(self, storage.localPersonalRaidRaw)
    if existing and existing.version == 3 then
      incoming = MergeMGMRA3Documents(existing, incoming)
    end
  end
  storage.localPersonalRaidRaw = incoming.normalizedRaw
  self.raidAssignmentLocalPersonalParseCache = {
    raw = storage.localPersonalRaidRaw,
    parsed = incoming,
  }
end

function MerfinPlus:GetActivePersonalRaidAssignmentBoss(entry)
  local parsed = entry and entry.parsed
  local storage = self:GetRaidAssignmentStorage()
  local selection = entry and entry.personalRaidSelection or storage.personalRaidSelection
  local selectedKey = selection and (selection.bossKey or selection.trashBossKey)
    or storage.activePersonalRaidBossKey
  local key = NormalizeName(selectedKey)
  if not parsed then
    return nil
  end
  if key ~= "" then
    for _, boss in ipairs(parsed.bosses or {}) do
      if NormalizeName(boss.key) == key or NormalizeName(boss.name) == key then
        return boss
      end
    end
  end
  return parsed.bosses and parsed.bosses[1]
end

function MerfinPlus:GetActivePersonalRaidAssignmentBosses(entry)
  local parsed = entry and entry.parsed
  if not parsed then
    return {}
  end
  local selection = entry.personalRaidSelection or self:GetRaidAssignmentStorage().personalRaidSelection
  if selection then
    local output = {}
    local selected, trash
    for _, boss in ipairs(parsed.bosses or {}) do
      if NormalizeName(boss.key) == NormalizeName(selection.trashBossKey)
        and boss.isTrash
        and NormalizeName(boss.raidKey) == NormalizeName(selection.raidKey)
      then
        trash = boss
      end
      if NormalizeName(boss.key) == NormalizeName(selection.bossKey)
        and not boss.isTrash
        and NormalizeName(boss.raidKey) == NormalizeName(selection.raidKey)
      then
        selected = boss
      end
    end
    -- Preserve older persisted selection records where bossKey itself was a
    -- Trash key, while newer records keep Trash and current boss separately.
    if not trash and not selected then
      local legacySelected = self:GetActivePersonalRaidAssignmentBoss(entry)
      if legacySelected and legacySelected.isTrash then
        trash = legacySelected
      else
        selected = legacySelected
      end
    end
    if trash then
      output[#output + 1] = trash
    end
    if selected then
      output[#output + 1] = selected
    end
    return output
  end
  local trash, bosses = {}, {}
  for _, boss in ipairs(parsed.bosses or {}) do
    if boss.isTrash then
      trash[#trash + 1] = boss
    else
      bosses[#bosses + 1] = boss
    end
  end
  for _, boss in ipairs(bosses) do
    trash[#trash + 1] = boss
  end
  return trash
end

local RAID_ASSIGNMENT_SECTIONS_CACHE = setmetatable({}, { __mode = "k" })
local RAID_ASSIGNMENT_DETAIL_SECTIONS_CACHE = setmetatable({}, { __mode = "k" })
local RAID_ASSIGNMENT_PLAYER_MAP_CACHE = setmetatable({}, { __mode = "k" })

function MerfinPlus:GetRaidAssignmentSections(boss)
  if not boss then
    return {}
  end
  local cached = RAID_ASSIGNMENT_SECTIONS_CACHE[boss]
  if cached then return cached end
  if #(boss.v2Assignments or {}) == 0 then
    cached = boss.sections or {}
    RAID_ASSIGNMENT_SECTIONS_CACHE[boss] = cached
    return cached
  end

  -- V2 is authoritative for rows it contains, but older/full MGMRA exports can
  -- have legacy cards that were not emitted as V2 rows. Using V2 exclusively
  -- made those cards disappear (notably Illidan P2's tank positions, marker
  -- groups and melee positioning). Build the V2 cards first, then merge them
  -- into the complete legacy source order and retain V2-only cards afterwards.
  local v2Sections, v2ByName = {}, {}
  for _, task in ipairs(boss.v2Assignments) do
    local sectionName = task.sectionName ~= "" and task.sectionName or task.phase
    sectionName = sectionName ~= "" and sectionName or "Raid Assignments"
    local sectionKey = NormalizeName(sectionName)
    local section = v2ByName[sectionKey]
    if not section then
      section = { name = sectionName, rows = {} }
      v2ByName[sectionKey] = section
      v2Sections[#v2Sections + 1] = section
    end
    section.rows[#section.rows + 1] = task
  end

  if #(boss.sections or {}) == 0 then
    RAID_ASSIGNMENT_SECTIONS_CACHE[boss] = v2Sections
    return v2Sections
  end

  local sections, included = {}, {}
  for _, legacySection in ipairs(boss.sections or {}) do
    local sectionKey = NormalizeName(legacySection.name)
    local section = v2ByName[sectionKey] or legacySection
    if not included[sectionKey] and #(section.rows or {}) > 0 then
      included[sectionKey] = true
      sections[#sections + 1] = section
    end
  end
  for _, section in ipairs(v2Sections) do
    local sectionKey = NormalizeName(section.name)
    if not included[sectionKey] and #(section.rows or {}) > 0 then
      included[sectionKey] = true
      sections[#sections + 1] = section
    end
  end
  RAID_ASSIGNMENT_SECTIONS_CACHE[boss] = sections
  return sections
end

local function IsIllidanPhaseTwoMeleePositionSection(section)
  local context = section and section.context or {}
  local bossName = NormalizeName(context.bossName or (context.boss and context.boss.name))
  local phase = NormalizeName(context.phase)
  local sectionName = NormalizeName(section and (section.name or section.sourceName))
  local isIllidan = bossName == "illidan" or bossName == "illidanstormrage"
  local isPhaseTwo = phase == "2" or sectionName:find("phase2", 1, true) ~= nil
  return isIllidan and isPhaseTwo and sectionName:find("meleeposition", 1, true) ~= nil
end

local function IsIndividualMeleeOrRangedPositionSection(section)
  -- Only canonical position cards are redundant with the visual Boss Plan.
  -- Illidan's phase mechanics intentionally use utility cards (including the
  -- Phase 2 melee positioning special case) and must remain visible both here
  -- and in the personal Assignment Widget.
  if IsIllidanPhaseTwoMeleePositionSection(section) then return false end
  if not section or NormalizeName(section.kind) ~= "position" then return false end
  local sectionRole
  for _, rowData in ipairs(section.rows or {}) do
    local task = rowData.task or rowData
    local role = NormalizeName(task and task.role)
    if role == "melee" or role == "ranged" then
      if sectionRole and sectionRole ~= role then return false end
      sectionRole = role
    elseif role ~= "" then
      return false
    end
  end
  if sectionRole == "melee" or sectionRole == "ranged" then return true end

  -- Support canonical position cards from older imports that predate roles.
  -- Do not apply this name fallback to utility/special cards (see above).
  local sectionName = NormalizeName(section.name or section.sourceName)
  return (sectionName:find("meleeposition", 1, true) ~= nil)
    or (sectionName:find("rangedposition", 1, true) ~= nil)
end

function MerfinPlus:IsRaidAssignmentSectionVisibleInUI(section)
  return not IsIndividualMeleeOrRangedPositionSection(section)
end

function MerfinPlus:GetRaidAssignmentDetailSections(boss)
  if not boss then return {} end
  local cached = RAID_ASSIGNMENT_DETAIL_SECTIONS_CACHE[boss]
  if cached then return cached end
  local sections, classSections, buffSection = {}, {}, nil
  for _, sourceSection in ipairs(self:GetRaidAssignmentSections(boss)) do
    -- The MGMRA category is represented by a class-named source section
    -- (for example, "Priest").  Only those Class Assignments are condensed.
    -- Position, marker, and every other non-Buff section retain their original
    -- category cards and rows. Buff is the one nested grouping requested below.
    if not self:IsRaidAssignmentSectionVisibleInUI(sourceSection) then
      -- Keep the imported section on the boss and in the sync payload so the
      -- Boss Plan renderer can still position every player. Only the regular
      -- Assignment detail UI omits these redundant individual position lists.
    elseif sourceSection.kind == "buff" or NormalizeName(sourceSection.name) == "buff" or NormalizeName(sourceSection.name) == "buffassignments" then
      if not buffSection then
        buffSection = {
          name = "Buff Assignments",
          isBuffGroup = true,
          rows = {},
          classSections = {},
        }
        sections[#sections + 1] = buffSection
      end
      for _, task in ipairs(sourceSection.rows or {}) do
        local className = TitleCaseToken(task.class)
        local classKey = NormalizeName(className)
        if classKey == "" then
          className, classKey = "Other", "other"
        end
        local classSection = buffSection.classSections[classKey]
        if not classSection then
          classSection = { name = className, rows = {} }
          buffSection.classSections[classKey] = classSection
          buffSection.rows[#buffSection.rows + 1] = classSection
        end
        classSection.rows[#classSection.rows + 1] = {
          task = task,
          sectionName = sourceSection.name,
        }
      end
    elseif GetRaidAssignmentClassToken(sourceSection.name) then
      for _, task in ipairs(sourceSection.rows or {}) do
        local className = TitleCaseToken(task.class or sourceSection.name)
        local classKey = NormalizeName(className)
        if classKey == "" then
          className, classKey = "Other", "other"
        end
        local section = classSections[classKey]
        if not section then
          section = {
            name = className .. " Assigns",
            rows = {},
          }
          classSections[classKey] = section
          sections[#sections + 1] = section
        end
        section.rows[#section.rows + 1] = {
          task = task,
          sectionName = sourceSection.name,
        }
      end
    else
      sections[#sections + 1] = sourceSection
    end
  end
  RAID_ASSIGNMENT_DETAIL_SECTIONS_CACHE[boss] = sections
  return sections
end

function MerfinPlus:BuildRaidAssignmentPlayerMap(boss)
  if not boss then return {} end
  local cached = RAID_ASSIGNMENT_PLAYER_MAP_CACHE[boss]
  if cached then return cached end
  local players = {}
  local function AddTask(task)
    local name = CleanPlayerName(task.player)
    local key = NormalizeName(name)
    local identity = NormalizeName(task.class) .. "\31" .. NormalizeName(task.spec)
    if name ~= "" and not players[key] then
      players[key] = {
        name = name,
        class = task.class,
        classToken = GetRaidAssignmentClassToken(task.class),
        spec = task.spec,
        identity = identity,
      }
    elseif name ~= "" and players[key].identity ~= identity then
      -- A shared export placeholder (for example, one name for every
      -- class/spec) is not a real player identity.  Keep the assignment rows
      -- distinct and do not use an arbitrary first row for target resolution.
      players[key].ambiguous = true
    end
  end
  for _, task in ipairs(boss and boss.v2Assignments or {}) do
    AddTask(task)
  end
  for _, section in ipairs(boss and boss.sections or {}) do
    for _, task in ipairs(section.rows or {}) do
      AddTask(task)
    end
  end
  RAID_ASSIGNMENT_PLAYER_MAP_CACHE[boss] = players
  return players
end

function MerfinPlus:GetRaidAssignmentSectionDisplay(sectionName, sectionKind, sectionRole)
  local marker, markerLabel = GetSectionMarker(sectionName)
  if marker then
    return self:LocalizeAssignmentSection(markerLabel), marker, true
  end
  local displayLabel = self:LocalizeAssignmentSection(sectionName)
  local key = NormalizeName(sectionName)
  local roleKey = NormalizeName(sectionRole)
  if roleKey == "tank" or key:find("tank", 1, true) then
    return displayLabel, ROLE_ICONS.tank, false
  elseif roleKey == "heal" or roleKey == "healer" or key:find("heal", 1, true) then
    return displayLabel, ROLE_ICONS.heal, false
  elseif sectionKind == "position" then
    return displayLabel, ROLE_ICONS.position, false
  elseif key:find("position", 1, true) then
    return displayLabel, ROLE_ICONS.position, false
  end
  return displayLabel, nil, false
end

local RAID_ASSIGNMENT_SPELL_IDS = {
  sheep = { 118 },
  fearward = { 6346 },
  thorns = { 467 },
  innervate = { 29166 },
  powerinfusion = { 10060 },
  soulstone = { 20707 },
  soulstoneresurrection = { 20707 },
  markofthewild = { 26991 },
  fortitude = { 25389, 1243 },
  powerwordfortitude = { 25389, 1243 },
  divinespirit = { 25312, 14752 },
  intellect = { 27126, 1459 },
  arcaneintellect = { 27126, 1459 },
  amplifymagic = { 33946, 1008 },
  intellectamplifymagic = { 27126, 1459, 33946, 1008 },
  curseofelements = { 11722 },
  curseofrecklessness = { 704, 27226, 11717 },
  curseofagony = { 980, 11672 },
  curseofdoom = { 603 },
  spiritshockinterruptrotation = { 41426 },
  deadenspellreflection = { 41410 },
  runeshieldspellsteal = { 41431 },
  seethetranqshot = { 41520 },
  faeriefire = { 26993, 770 },
  bloodlust = { 2825 },
  heroism = { 32182 },
  misdirection = { 34477 },
  huntersmark = { 14325 },
  demoralizingshout = { 1160 },
  demoshout = { 1160 },
  thunderclap = { 6343 },
  commandingshout = { 469 },
  exposearmor = { 8647 },
  judgement = { 20271 },
  judgements = { 20271 },
  judgementoflight = { 27163, 20271 },
  judgementofwisdom = { 27164, 20186 },
  judgementofjustice = { 20184 },
}

local RAID_ASSIGNMENT_MULTI_SPELL_IDS = {
  intellectamplifymagic = {
    { 27126, 1459 },
    { 33946, 1008 },
  },
}

local RAID_ASSIGNMENT_SPELL_ICON_CACHE = {}

local RAID_ASSIGNMENT_SPELL_ICON_FALLBACKS = {
  curseofrecklessness = "Interface\\Icons\\Spell_Shadow_UnholyStrength",
  curseofagony = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
}

local function ResolveRaidAssignmentSpellIcon(candidates)
  local cacheKeyParts = {}
  for index, candidate in ipairs(candidates or {}) do cacheKeyParts[index] = tostring(candidate) end
  local cacheKey = table.concat(cacheKeyParts, "\31")
  local cached = RAID_ASSIGNMENT_SPELL_ICON_CACHE[cacheKey]
  if cached ~= nil then return cached or nil end
  for _, candidate in ipairs(candidates or {}) do
    if candidate ~= "" then
      local spellID = tonumber(candidate)
      local icon
      if spellID and C_Spell and C_Spell.GetSpellTexture then
        icon = C_Spell.GetSpellTexture(spellID)
      end
      if not icon and spellID and GetSpellTexture then
        icon = GetSpellTexture(spellID)
      end
      if not icon and GetSpellInfo then
        local _, _, spellInfoIcon = GetSpellInfo(candidate)
        icon = spellInfoIcon
      end
      if icon then
        RAID_ASSIGNMENT_SPELL_ICON_CACHE[cacheKey] = icon
        return icon
      end
    end
  end
  RAID_ASSIGNMENT_SPELL_ICON_CACHE[cacheKey] = false
end

function MerfinPlus:ResolveCanonicalRaidAssignmentIcon(token)
  token = Trim(token)
  local spellID = tonumber(token:match("^spell:([1-9][0-9]*)$"))
  if spellID then return ResolveRaidAssignmentSpellIcon({ spellID }) end
  local icon = token:match("^icon:([a-z0-9_]+)$")
  return icon and ("Interface\\Icons\\" .. icon) or nil
end

function MerfinPlus:GetRaidAssignmentMarkerIcon(marker)
  return RAID_TARGET_ICONS[NormalizeName(marker)]
end

local function ExtractTrailingRaidMarker(value)
  local label = Trim(value)
  if label == "" then return "", nil end
  local core = label:gsub("[%s%p]+$", "")
  local markerStart, markerName = core:match("()(%a+)$")
  local markerIcon = markerName and RAID_TARGET_ICONS[NormalizeName(markerName)]
  if not markerIcon then return label, nil end
  local cleaned = Trim(core:sub(1, markerStart - 1):gsub("[%s%p]+$", ""))
  return cleaned, markerIcon
end

function MerfinPlus:GetRaidAssignmentLabelMarkerDisplay(task)
  task = task or {}
  local sourceLabel = Trim(task.displayLabel)
  if sourceLabel == "" then sourceLabel = Trim(task.assignment) end
  local label, suffixMarker = ExtractTrailingRaidMarker(sourceLabel)
  return label, suffixMarker
end

local function GetRaidAssignmentSpellIcons(task)
  local assignment = Trim(task and task.assignment or "")
  local target = Trim(task and task.target or "")
  local candidates = { assignment }
  local assignmentKey = NormalizeName(assignment)
  local targetKey = NormalizeName(target)
  if assignmentKey == "sheep" then
    candidates[#candidates + 1] = "Polymorph"
  elseif assignmentKey == "soulstone" then
    candidates[#candidates + 1] = "Soulstone Resurrection"
  elseif assignmentKey == "curse" then
    candidates[#candidates + 1] = "Curse of " .. target
    if targetKey:find("elements", 1, true) then
      assignmentKey = "curseofelements"
    elseif targetKey:find("recklessness", 1, true) then
      assignmentKey = "curseofrecklessness"
    elseif targetKey:find("agony", 1, true) then
      assignmentKey = "curseofagony"
    elseif targetKey:find("doom", 1, true) then
      assignmentKey = "curseofdoom"
    end
  end
  if assignmentKey == "judgement" or assignmentKey == "judgements" then
    if targetKey:find("wisdom", 1, true) then
      assignmentKey = "judgementofwisdom"
    elseif targetKey:find("justice", 1, true) then
      assignmentKey = "judgementofjustice"
    elseif targetKey:find("light", 1, true) then
      assignmentKey = "judgementoflight"
    end
  end
  local multiSpellIDs = RAID_ASSIGNMENT_MULTI_SPELL_IDS[assignmentKey]
  if multiSpellIDs then
    local primary = ResolveRaidAssignmentSpellIcon(multiSpellIDs[1])
    local secondary = ResolveRaidAssignmentSpellIcon(multiSpellIDs[2])
    return primary, secondary
  end
  for _, spellID in ipairs(RAID_ASSIGNMENT_SPELL_IDS[assignmentKey] or {}) do
    candidates[#candidates + 1] = spellID
  end
  return ResolveRaidAssignmentSpellIcon(candidates) or RAID_ASSIGNMENT_SPELL_ICON_FALLBACKS[assignmentKey]
end

function MerfinPlus:GetRaidAssignmentPositionLabel(task)
  local position = Trim(task and task.position or "")
  local slot = Trim(task and task.slot or "")
  local assignmentKey = NormalizeName((task and task.role) or (task and task.assignment))
  local prefix = ({
    tank = "T",
    heal = "H",
    healer = "H",
    melee = "M",
    ranged = "R",
  })[assignmentKey]
  if prefix and slot:match("^%d+$") then
    return prefix .. slot
  end
  local compact = position:upper():gsub("%s+", "")
  if compact:match("^[HTMR]%d+$") then
    return compact
  end
  return position ~= "" and position or nil
end

function MerfinPlus:GetRaidAssignmentSpellDisplay(task, sectionName)
  local assignment = Trim(task and task.assignment or "")
  local assignmentWithoutMarker, assignmentSuffixMarker = ExtractTrailingRaidMarker(assignment)
  local displayLabel, displayMarker = self:GetRaidAssignmentLabelMarkerDisplay(task)
  local assignmentMarkerIcon = displayMarker or assignmentSuffixMarker
  assignment = assignmentSuffixMarker and assignmentWithoutMarker or assignment
  local sectionMarker = GetSectionMarker(sectionName)
  local taskMarker = RAID_TARGET_ICONS[NormalizeName(task and task.marker)]
  local sectionKey = NormalizeName(sectionName)
  local isPositionSection = sectionMarker ~= nil or taskMarker ~= nil or sectionKey:find("position", 1, true)
  local positionNumber = assignment:match("^[Pp]+%s*(%d+)$")
    or assignment:match("^[Ss][Ll][Oo][Tt]%s*(%d+)$")
    or assignment:match("^[Pp][Oo][Ss][Ii][Tt][Ii][Oo][Nn]%s*(%d+)$")
    or assignment:match("^(%d+)$")
  if (sectionMarker or taskMarker) and not positionNumber then
    positionNumber = assignment:match("^[MmRr]%s*(%d+)$")
  end
  if isPositionSection and positionNumber then
    return "P" .. positionNumber, sectionMarker or taskMarker or ROLE_ICONS.position,
      self:GetRaidAssignmentPositionLabel(task), nil, assignmentMarkerIcon
  end
  local iconTask = task
  if assignment ~= Trim(task and task.assignment or "") then
    iconTask = {}
    for field, value in pairs(task or {}) do iconTask[field] = value end
    iconTask.assignment = assignment
  end
  local spellIcon, secondarySpellIcon = GetRaidAssignmentSpellIcons(iconTask)
  local bossSpellIcon = self:ResolveCanonicalRaidAssignmentIcon(task and task.bossSpellIcon)
  if bossSpellIcon then spellIcon = bossSpellIcon end
  local label = displayLabel ~= "" and displayLabel or TitleCaseToken(assignment)
  return label, spellIcon, self:GetRaidAssignmentPositionLabel(task), secondarySpellIcon, assignmentMarkerIcon
end

local function FormatRaidAssignmentGroups(groups)
  local values = {}
  for _, group in ipairs(type(groups) == "table" and groups or {}) do values[#values + 1] = tostring(group) end
  return #values > 0 and ("Groups " .. table.concat(values, " + ")) or ""
end

local function FormatRaidAssignmentMultiTargets(task, playerMap)
  if type(task and task.targetNames) ~= "table" or #task.targetNames < 1 then return nil end
  local output = {}
  for index, rawName in ipairs(task.targetNames) do
    local name = CleanPlayerName(rawName)
    local classToken = GetRaidAssignmentClassToken(task.targetClasses and task.targetClasses[index])
    local player = playerMap and playerMap[NormalizeName(name)]
    if not classToken and player and not player.ambiguous then
      classToken = player.classToken or GetRaidAssignmentClassToken(player.class)
    end
    if classToken then
      local r, g, b = GetClassColor(classToken)
      output[#output + 1] = string.format("|cff%02x%02x%02x%s|r", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5), name)
    else
      output[#output + 1] = name
    end
  end
  return table.concat(output, ", ")
end

function MerfinPlus:GetRaidAssignmentTargetDisplay(task, playerMap)
  local multiTarget = FormatRaidAssignmentMultiTargets(task, playerMap)
  if multiTarget then return multiTarget, nil, nil, false, nil, true end
  local target = Trim(task and task.target or "")
  local targetKind = tostring(task and task.targetKind or "")
  if targetKind == "none" then return "", nil, nil, false end
  if targetKind == "groups" then
    local groups = FormatRaidAssignmentGroups(task and task.groups)
    if groups ~= "" then return groups, nil, nil, false end
  end
  if targetKind == "worldmarker" then
    local marker = NormalizeName((task and task.marker ~= "" and task.marker) or target)
    local markerIcon = RAID_TARGET_ICONS[marker]
    return "", nil, markerIcon, markerIcon ~= nil
  end
  if target == "" or NormalizeName(target) == "assigned" then
    return "", nil, nil, false
  end
  local markerIcon = RAID_TARGET_ICONS[NormalizeName(target)]
  if markerIcon then
    return "", nil, markerIcon, true
  end
  if task and task.targetClass ~= "" and (targetKind == "player" or task.targetSpec ~= "") then
    local classToken = GetRaidAssignmentClassToken(task.targetClass)
    if classToken then
      return target, classToken, GetRaidAssignmentClassIcon(classToken), false, task.targetSpec
    end
  end
  local targetPlayer = playerMap and playerMap[NormalizeName(CleanPlayerName(target))]
  if targetPlayer and not targetPlayer.ambiguous then
    local classToken = targetPlayer.classToken or GetRaidAssignmentClassToken(targetPlayer.class)
    return targetPlayer.name, classToken, GetRaidAssignmentClassIcon(classToken), false, targetPlayer.spec
  end
  return TitleCaseToken(target), nil, nil, false
end

local function AppendVisibleText(output, value, suffix)
  value = Trim(value)
  if value ~= "" then output[#output + 1] = value .. (suffix or "") end
end

local RAID_ASSIGNMENT_ROW_DISPLAY_CACHE = setmetatable({}, { __mode = "k" })

function MerfinPlus:BuildRaidAssignmentRowDisplay(task, sectionName, playerMap)
  task = task or {}
  local cacheKey = tostring(sectionName or "") .. "\31" .. tostring(playerMap or "")
  local taskCache = RAID_ASSIGNMENT_ROW_DISPLAY_CACHE[task]
  if taskCache and taskCache[cacheKey] then return taskCache[cacheKey] end
  taskCache = taskCache or {}
  RAID_ASSIGNMENT_ROW_DISPLAY_CACHE[task] = taskCache
  if task.kind == "additional" then
    local what, action = {}, {}
    AppendVisibleText(what, task.bossSpellName)
    AppendVisibleText(what, task.customWhat)
    AppendVisibleText(action, task.abilityName, task.abilitySymbiosis and " (Symbiosis Exchange)" or nil)
    AppendVisibleText(action, task.cooldownName, task.cooldownSymbiosis and " (Symbiosis Exchange)" or nil)
    AppendVisibleText(action, task.customAbilityCooldown)
    local parts = {}
    if #what > 0 then parts[#parts + 1] = table.concat(what, " / ") end
    if #action > 0 then parts[#parts + 1] = table.concat(action, " / ") end
    local targetLabel, targetClass, targetIcon, targetIsMarker, targetSpec = self:GetRaidAssignmentTargetDisplay(task, playerMap)
    local markerIcon = self:GetRaidAssignmentMarkerIcon(task.marker)
    if markerIcon then targetIcon, targetIsMarker = markerIcon, targetLabel == "" end
    local whatIconToken = Trim(task.bossSpellIcon)
    if whatIconToken == "" then whatIconToken = Trim(task.customWhatIcon) end
    local actionIconToken = Trim(task.abilityIcon)
    if actionIconToken == "" then actionIconToken = Trim(task.cooldownIcon) end
    local rawLabel = #parts > 0 and table.concat(parts, " · ") or Trim(task.displayLabel or task.assignment)
    local label, assignmentMarkerIcon = ExtractTrailingRaidMarker(rawLabel)
    if assignmentMarkerIcon and targetIsMarker and targetIcon == assignmentMarkerIcon then
      targetIcon, targetIsMarker = nil, false
    end
    local display = {
      label = label,
      icon = self:ResolveCanonicalRaidAssignmentIcon(whatIconToken),
      secondaryIcon = self:ResolveCanonicalRaidAssignmentIcon(actionIconToken),
      assignmentMarkerIcon = assignmentMarkerIcon,
      target = targetLabel, targetClass = targetClass, targetIcon = targetIcon,
      targetIsMarker = targetIsMarker, targetSpec = targetSpec,
      note = Trim(task.note), isAdditional = true,
    }
    taskCache[cacheKey] = display
    return display
  end
  local label, icon, positionCode, secondaryIcon, assignmentMarkerIcon = self:GetRaidAssignmentSpellDisplay(task, sectionName)
  local target, targetClass, targetIcon, targetIsMarker, targetSpec, multiTarget = self:GetRaidAssignmentTargetDisplay(task, playerMap)
  if assignmentMarkerIcon and targetIsMarker and targetIcon == assignmentMarkerIcon then
    targetIcon, targetIsMarker = nil, false
  end
  if task.targetKind == "position" and positionCode and positionCode ~= "" then
    target, targetClass, targetIcon, targetIsMarker, targetSpec = positionCode, nil, nil, false, nil
  elseif (not target or target == "") and positionCode and positionCode ~= "" then
    target = positionCode
  end
  local display = {
    label = label, icon = icon, secondaryIcon = secondaryIcon, assignmentMarkerIcon = assignmentMarkerIcon,
    target = target, targetClass = targetClass, targetIcon = targetIcon,
    targetIsMarker = targetIsMarker, targetSpec = targetSpec,
    multiTarget = multiTarget == true,
    note = Trim(task.note), positionCode = positionCode,
  }
  taskCache[cacheKey] = display
  return display
end

function MerfinPlus:IsRaidAssignmentTaskVisibleToPlayer(task, playerName)
  if not task then return false end
  if task.kind == "additional" and task.visibility ~= "assignee" then return false end
  return NormalizeName(CleanPlayerName(task.player)) == NormalizeName(CleanPlayerName(playerName))
end

function MerfinPlus:IsRaidAssignmentSectionCollapsed(entry, boss, sectionName)
  local storage = self:GetRaidAssignmentStorage()
  local key = tostring(entry and entry.id or "") .. "::"
    .. tostring(boss and (boss.key or boss.name) or "") .. "::" .. tostring(sectionName or "")
  local value = storage.raidCollapsedSections[key]
  -- Assignment cards open collapsed.  A user expansion is stored explicitly,
  -- so all newly imported, loaded, and otherwise unseen sections stay compact.
  return value ~= false
end

function MerfinPlus:ToggleRaidAssignmentSection(entry, boss, sectionName, suppressRefresh)
  if not entry or not boss then
    return
  end
  local storage = self:GetRaidAssignmentStorage()
  local key = tostring(entry.id) .. "::" .. tostring(boss.key or boss.name or "") .. "::" .. tostring(sectionName or "")
  storage.raidCollapsedSections[key] = not self:IsRaidAssignmentSectionCollapsed(entry, boss, sectionName)
  if not suppressRefresh then self:NotifyRaidAssignmentsChanged() end
end

local function PlayerMatches(taskPlayer, playerName)
  return NormalizeName(CleanPlayerName(taskPlayer)) == NormalizeName(CleanPlayerName(playerName))
end

function MerfinPlus:BuildPersonalRaidBossPayload(parsed, boss, playerName)
  if not parsed or not boss or Trim(playerName) == "" then
    return nil, 0
  end
  if parsed.version == 3 then
    local selected = {}
    -- Personal deliveries always retain this raid's Trash cards before the
    -- selected boss card. Received v3 documents merge by boss key, so later
    -- boss broadcasts add/update only that boss and never discard Trash.
    for _, candidate in ipairs(parsed.bosses or {}) do
      if candidate.isTrash and NormalizeName(candidate.raidKey) == NormalizeName(boss.raidKey) then
        selected[#selected + 1] = candidate
      end
    end
    if not boss.isTrash then
      selected[#selected + 1] = boss
    elseif #selected == 0 then
      selected[#selected + 1] = boss
    end
    return SerializeMGMRA3(parsed, selected, playerName)
  end
  local output = {
    "MGMRA|" .. tostring(parsed.version or 1),
    "META|" .. tostring(parsed.expansion or "tbc") .. "|" .. tostring(parsed.raidKey or "") .. "|" .. tostring(parsed.label or "Raid Assignments"),
  }
  local v2Count = 0
  for _, task in ipairs(boss.v2Assignments or {}) do
    if PlayerMatches(task.player, playerName) and task.rawLine and task.rawLine ~= "" then
      output[#output + 1] = task.rawLine
      v2Count = v2Count + 1
    end
  end

  output[#output + 1] = "[" .. tostring(boss.name or "") .. "]"
  output[#output + 1] = "META|" .. tostring(boss.key or "") .. "|" .. tostring(boss.raidKey or "")
  local legacyCount = 0
  for _, section in ipairs(boss.sections or {}) do
    local personalRows = {}
    for _, task in ipairs(section.rows or {}) do
      if PlayerMatches(task.player, playerName) then
        personalRows[#personalRows + 1] = task
      end
    end
    if #personalRows > 0 then
      output[#output + 1] = "[" .. tostring(section.name or "") .. "]"
      for _, task in ipairs(personalRows) do
        output[#output + 1] = task.rawLine or table.concat({
          task.assignment or "",
          task.player or "",
          task.class or "",
          task.spec or "",
          task.target or "",
        }, "|")
        legacyCount = legacyCount + 1
      end
      output[#output + 1] = "//"
    end
  end
  local taskCount = v2Count > 0 and v2Count or legacyCount
  if taskCount == 0 then
    return nil, 0
  end
  return table.concat(output, "\n"), taskCount
end

function MerfinPlus:BuildRaidBossBroadcastPayload(parsed, boss)
  if not parsed or not boss then
    return nil, 0
  end
  if parsed.version == 3 then
    return SerializeMGMRA3(parsed, { boss })
  end
  local output = {
    "MGMRA|" .. tostring(parsed.version or 1),
    "META|" .. tostring(parsed.expansion or "tbc") .. "|" .. tostring(parsed.raidKey or "") .. "|" .. tostring(parsed.label or "Raid Assignments"),
    "[" .. tostring(boss.name or "") .. "]",
    "META|" .. tostring(boss.key or "") .. "|" .. tostring(boss.raidKey or ""),
  }
  local count = 0
  for _, task in ipairs(boss.v2Assignments or {}) do
    if task.rawLine and task.rawLine ~= "" then
      output[#output + 1] = task.rawLine
      count = count + 1
    end
  end
  for _, section in ipairs(boss.sections or {}) do
    output[#output + 1] = "[" .. tostring(section.name or "") .. "]"
    for _, task in ipairs(section.rows or {}) do
      output[#output + 1] = task.rawLine or table.concat({
        task.assignment or "", task.player or "", task.class or "", task.spec or "", task.target or "",
      }, "|")
      count = count + 1
    end
    output[#output + 1] = "//"
  end
  return count > 0 and table.concat(output, "\n") or nil, count
end

function MerfinPlus:CanBroadcastRaidAssignments()
  local raidCount = (GetNumRaidMembers and GetNumRaidMembers()) or 0
  local groupCount = (GetNumGroupMembers and GetNumGroupMembers()) or 0
  local partyCount = (GetNumSubgroupMembers and GetNumSubgroupMembers())
    or (GetNumPartyMembers and GetNumPartyMembers())
    or 0
  local inRaid = (IsInRaid and IsInRaid()) or raidCount > 0
  local inGroup = (IsInGroup and IsInGroup()) or inRaid or groupCount > 0 or partyCount > 0
  if not inGroup then
    return false, "You need to be in a group."
  end
  local isLeader = (UnitIsGroupLeader and UnitIsGroupLeader("player"))
    or (inRaid and IsRaidLeader and IsRaidLeader())
    or ((not inRaid) and UnitIsPartyLeader and UnitIsPartyLeader("player"))
    or ((not inRaid) and IsPartyLeader and IsPartyLeader())
  local isAssistant = inRaid and (
    (UnitIsGroupAssistant and UnitIsGroupAssistant("player"))
    or (IsRaidOfficer and IsRaidOfficer())
  )
  if inRaid and not isLeader and not isAssistant and UnitInRaid and GetRaidRosterInfo then
    local raidIndex = UnitInRaid("player")
    if raidIndex then
      local _, rank = GetRaidRosterInfo(raidIndex)
      isLeader = rank == 2
      isAssistant = rank == 1
    end
  end
  if not isLeader and not isAssistant then
    return false, "Only group leaders or raid assistants can broadcast."
  end
  return true
end

function MerfinPlus:RegisterRaidAssignmentPrefix()
  local function Register(prefix)
    local ok, result
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
      ok, result = pcall(C_ChatInfo.RegisterAddonMessagePrefix, prefix)
    elseif RegisterAddonMessagePrefix then
      ok, result = pcall(RegisterAddonMessagePrefix, prefix)
    end
    return ok == true and result ~= false
  end
  local raidRegistered = Register(RAID_ASSIGNMENT_ADDON_PREFIX)
  self.assignmentPrefixSupport = {
    raid = raidRegistered,
  }
  return raidRegistered
end

function MerfinPlus:SendAssignmentAddonMessage(prefix, message, target, distribution, priority, queueName, callback, callbackArg)
  distribution = distribution or "WHISPER"
  if distribution == "WHISPER" and (not target or target == "") then
    return false
  end
  local sender
  local messageType = tostring(message or ""):match("^([^|]+)")
  priority = priority or (((messageType == "ACK" or messageType == "NACK"
    or messageType == "RACK" or messageType == "RNACK") and "ALERT") or "NORMAL")
  if ChatThrottleLib and ChatThrottleLib.SendAddonMessage then
    sender = function()
      return ChatThrottleLib:SendAddonMessage(priority, prefix, message, distribution, target, queueName, callback, callbackArg)
    end
  elseif C_ChatInfo and C_ChatInfo.SendAddonMessage then
    sender = function()
      local result = C_ChatInfo.SendAddonMessage(prefix, message, distribution, target)
      if result ~= false and callback then callback(callbackArg) end
      return result
    end
  elseif SendAddonMessage then
    sender = function()
      local result = SendAddonMessage(prefix, message, distribution, target)
      if result ~= false and callback then callback(callbackArg) end
      return result
    end
  end
  if sender then
    local ok, result = pcall(sender)
    return ok == true and result ~= false
  end
  return false
end

function MerfinPlus:SendRaidAssignmentAddonMessage(message, target, distribution)
  return self:SendAssignmentAddonMessage(RAID_ASSIGNMENT_ADDON_PREFIX, message, target, distribution)
end

function MerfinPlus:GetRaidAssignmentBroadcastChannel()
  local raidCount = (GetNumRaidMembers and GetNumRaidMembers()) or 0
  local inRaid = (IsInRaid and IsInRaid()) or raidCount > 0
  if inRaid then
    return "RAID"
  end
  local groupCount = (GetNumGroupMembers and GetNumGroupMembers()) or 0
  local partyCount = (GetNumSubgroupMembers and GetNumSubgroupMembers())
    or (GetNumPartyMembers and GetNumPartyMembers())
    or 0
  if (IsInGroup and IsInGroup()) or groupCount > 0 or partyCount > 0 then
    return "PARTY"
  end
end

local function GetUnitCommName(unit)
  if not UnitExists or not UnitExists(unit) then
    return nil
  end
  local name, realm
  if UnitFullName then
    name, realm = UnitFullName(unit)
  end
  if not name or name == "" then
    name = UnitName and UnitName(unit) or nil
  end
  if not name or name == "" then
    return nil
  end
  local commName = name
  if realm and realm ~= "" then
    realm = tostring(realm):gsub("%s+", "")
    commName = name .. "-" .. realm
  end
  local classToken
  if UnitClass then
    local _, unitClassToken = UnitClass(unit)
    classToken = unitClassToken
  end
  return {
    unit = unit,
    name = CleanPlayerName(name),
    commName = commName,
    connected = not UnitIsConnected or UnitIsConnected(unit) ~= false,
    isSelf = UnitIsUnit and UnitIsUnit(unit, "player") or unit == "player",
    classToken = classToken,
  }
end

function MerfinPlus:GetRaidAssignmentGroupRecipients()
  local recipients, byShort, byFull, ambiguous, seenFull = {}, {}, {}, {}, {}
  local function AddUnit(unit)
    local recipient = GetUnitCommName(unit)
    if not recipient then
      return
    end
    local shortKey = NormalizeName(recipient.name)
    local fullKey = NormalizeName(recipient.commName)
    if seenFull[fullKey] then
      return
    end
    seenFull[fullKey] = true
    recipients[#recipients + 1] = recipient
    if byShort[shortKey] and byShort[shortKey].commName ~= recipient.commName then
      ambiguous[shortKey] = true
      byShort[shortKey] = nil
    elseif not ambiguous[shortKey] then
      byShort[shortKey] = recipient
    end
    byFull[fullKey] = recipient
  end

  AddUnit("player")
  local raidCount = (GetNumRaidMembers and GetNumRaidMembers()) or 0
  local groupCount = (GetNumGroupMembers and GetNumGroupMembers()) or 0
  local partyCount = (GetNumSubgroupMembers and GetNumSubgroupMembers())
    or (GetNumPartyMembers and GetNumPartyMembers())
    or 0
  local inRaid = (IsInRaid and IsInRaid()) or raidCount > 0
  if inRaid then
    local count = groupCount > 0 and groupCount or raidCount
    for index = 1, count do
      AddUnit("raid" .. tostring(index))
    end
  else
    for index = 1, partyCount do
      AddUnit("party" .. tostring(index))
    end
  end
  return recipients, byShort, byFull, ambiguous
end

local function GetBossAssignedPlayers(boss)
  local names, seen = {}, {}
  local sourceSections
  if #(boss and boss.v2Assignments or {}) > 0 then
    sourceSections = { { rows = boss.v2Assignments } }
  else
    sourceSections = boss and boss.sections or {}
  end
  for _, section in ipairs(sourceSections) do
    for _, task in ipairs(section.rows or {}) do
      local name = Trim(task.player)
      local key = NormalizeName(CleanPlayerName(name))
      if key ~= "" and not seen[key] then
        seen[key] = true
        names[#names + 1] = name
      end
    end
  end
  return names
end

local function BuildChunkMessages(raw, importID, deliveryType)
  local encoded = EncodeAddonPayload(raw)
  local total = math.max(1, math.ceil(#encoded / BROADCAST_CHUNK_SIZE))
  local start = "START|" .. tostring(importID) .. "|" .. tostring(total)
  if deliveryType and deliveryType ~= "" then
    start = start .. "|" .. tostring(deliveryType)
  end
  local messages = { start }
  for index = 1, total do
    local chunk = encoded:sub(((index - 1) * BROADCAST_CHUNK_SIZE) + 1, index * BROADCAST_CHUNK_SIZE)
    messages[#messages + 1] = "DATA|" .. tostring(importID) .. "|" .. tostring(index) .. "|" .. chunk
  end
  messages[#messages + 1] = "END|" .. tostring(importID)
  return messages
end

local SendPersonalQueue

local function QueuePersonalPayload(queue, prefix, entryID, payload, recipient, shortKey, deliveryType)
  local broadcastID = tostring(entryID) .. "-personal-" .. tostring(Now()) .. "-" .. shortKey
  for _, message in ipairs(BuildChunkMessages(payload, broadcastID, deliveryType)) do
    queue[#queue + 1] = { prefix = prefix, target = recipient.commName, message = message }
  end
  return broadcastID
end

local function BuildMGMRA4ChunkMessages(raw, importID)
  local total = math.max(1, math.ceil(#raw / BROADCAST_CHUNK_SIZE))
  local messages = {
    table.concat({ "V4START", tostring(importID), tostring(total), ASSIGNMENT_DELIVERY_FULL_RAID, "1" }, "|"),
  }
  for index = 1, total do
    local chunk = raw:sub(((index - 1) * BROADCAST_CHUNK_SIZE) + 1, index * BROADCAST_CHUNK_SIZE)
    messages[#messages + 1] = "V4DATA|" .. tostring(importID) .. "|" .. tostring(index) .. "|" .. chunk
  end
  messages[#messages + 1] = "V4END|" .. tostring(importID)
  return messages, total
end

local function BuildMGMRA4PlanChunkMessages(raw, importID, metadata)
  local total = math.max(1, math.ceil(#raw / BROADCAST_CHUNK_SIZE))
  local start
  if metadata then
    start = table.concat({
      "V4PSTART", tostring(importID), tostring(total), "1",
      tostring(metadata.bossId), tostring(metadata.planId), tostring(metadata.revision),
    }, "|")
  else
    start = table.concat({ "V4PSTART", tostring(importID), tostring(total), "1" }, "|")
  end
  local messages = { start }
  for index = 1, total do
    local chunk = raw:sub(((index - 1) * BROADCAST_CHUNK_SIZE + 1), index * BROADCAST_CHUNK_SIZE)
    messages[#messages + 1] = "V4PDATA|" .. tostring(importID) .. "|" .. tostring(index) .. "|" .. chunk
  end
  messages[#messages + 1] = "V4PEND|" .. tostring(importID)
  return messages, total
end

local function QueueGroupPayload(queue, prefix, entryID, payload, deliveryType, distribution, priority)
  local broadcastID = tostring(entryID) .. "-group-" .. tostring(Now())
  -- Scoped boss/trash broadcasts deliberately use the original START shape.
  -- Existing MGMRA|3 clients already interpret a START without a delivery type
  -- as a scoped delivery; sending the newer SCOPED_RAID suffix made those
  -- clients discard START before they could assemble the payload or ACK it.
  local wireDeliveryType = deliveryType
  if deliveryType == ASSIGNMENT_DELIVERY_SCOPED_RAID then wireDeliveryType = nil end
  for _, message in ipairs(BuildChunkMessages(payload, broadcastID, wireDeliveryType)) do
    queue[#queue + 1] = {
      prefix = prefix,
      target = nil,
      distribution = distribution,
      priority = priority,
      message = message,
    }
  end
  return broadcastID
end

local function QueueMGMRA4GroupPayload(queue, prefix, entryID, payload, distribution, priority)
  local broadcastID = tostring(entryID) .. "-v4-group-" .. tostring(Now())
  local messages, total = BuildMGMRA4ChunkMessages(payload, broadcastID)
  for _, message in ipairs(messages) do
    queue[#queue + 1] = {
      prefix = prefix,
      target = nil,
      distribution = distribution,
      priority = priority,
      message = message,
    }
  end
  return broadcastID, total
end

local function QueueMGMRA4PlanGroupPayload(queue, prefix, entryID, payload, distribution, metadata)
  local broadcastID = tostring(entryID) .. "-v4p-group-" .. tostring(Now())
  local messages, total = BuildMGMRA4PlanChunkMessages(payload, broadcastID, metadata)
  for _, message in ipairs(messages) do
    queue[#queue + 1] = {
      prefix = prefix, target = nil, distribution = distribution, priority = "ALERT", message = message,
    }
  end
  return broadcastID, total
end

local function QueueScopedSelectionCommand(queue, prefix, entry, boss, distribution)
  local broadcastID = tostring(entry.id) .. "-select-" .. tostring(Now())
  local signature = entry.contentSignature or GetRaidAssignmentContentSignature(entry.raw)
  entry.contentSignature = signature
  queue[#queue + 1] = {
    prefix = prefix,
    target = nil,
    distribution = distribution,
    message = table.concat({
      "SELECT",
      broadcastID,
      signature,
      tostring(entry.raidGroup or ""),
      tostring(boss.raidKey or ""),
      tostring(boss.key or ""),
    }, "|"),
  }
  return broadcastID
end

local function QueueEmptyAssignmentNotice(queue, prefix, entryID, recipient)
  local shortKey = NormalizeName(recipient.name)
  local broadcastID = tostring(entryID) .. "-empty-" .. tostring(Now()) .. "-" .. shortKey
  queue[#queue + 1] = {
    prefix = prefix,
    target = recipient.commName,
    message = table.concat({
      "EMPTY",
      broadcastID,
      GetAddonVersion(),
      ASSIGNMENT_TRANSPORT_REVISION,
    }, "|"),
  }
  return broadcastID
end

local function CancelAssignmentDeliveryTimers(session)
  if not session then return end
  for timer in pairs(session.deliveryTimers or {}) do
    if timer and timer.Cancel then pcall(timer.Cancel, timer) end
  end
  session.deliveryTimers = {}
end

local function ScheduleAssignmentDeliveryTimer(session, delay, callback)
  if not session or session.finalized or session.aborted then return end
  session.deliveryTimers = session.deliveryTimers or {}
  local timer
  local function Run()
    if timer then session.deliveryTimers[timer] = nil end
    if session.finalized or session.aborted then return end
    callback()
  end
  if C_Timer and C_Timer.NewTimer then
    timer = C_Timer.NewTimer(delay, Run)
    if timer then session.deliveryTimers[timer] = true end
  elseif C_Timer and C_Timer.After then
    -- Older clients do not return a cancellable handle. Run still checks the
    -- session state, so a completed/aborted transfer becomes a cheap no-op.
    C_Timer.After(delay, Run)
  else
    Run()
  end
  return timer
end

SendPersonalQueue = function(owner, prefix, queue, summary, statusSetter, deliverySession)
  if summary.sent == 0 and summary.localCount == 0 and summary.emptySent == 0 then
    statusSetter(
      owner:T(
        "No personal assignments sent: %d not in group, %d offline, %d ambiguous.",
        summary.missing,
        summary.offline,
        summary.ambiguous
      ),
      "red"
    )
    owner:AbortAssignmentDeliverySession(deliverySession)
    return false
  end

  if not owner:RegisterRaidAssignmentPrefix() then
    statusSetter("Assignment addon-message prefixes could not be registered.", "red")
    owner:AbortAssignmentDeliverySession(deliverySession)
    return false
  end
  statusSetter("", "muted")
  -- This bounded queue belongs exclusively to the explicit user action that
  -- created the delivery session. Submit it once; ChatThrottleLib may pace its
  -- own wire writes, but MerfinPlus never maintains a background chunk loop or
  -- automatically starts a second pass.
  for _, item in ipairs(queue) do
    if deliverySession.finalized or deliverySession.aborted then break end
    if not owner:SendAssignmentAddonMessage(item.prefix, item.message, item.target, item.distribution, item.priority) then
      deliverySession.sendFailures = (deliverySession.sendFailures or 0) + 1
      break
    end
  end
  deliverySession.ackTimeout = math.max(
    ASSIGNMENT_ACK_WINDOW_SECONDS * 2,
    math.min(30, #queue * 0.05)
  )
  owner:MarkAssignmentDeliveryQueueFinished(deliverySession)
  return (deliverySession.sendFailures or 0) == 0
end

local function IsGroupLeaderOrAssistant(unit)
  if not unit then
    return false
  end
  local isLeader = (UnitIsGroupLeader and UnitIsGroupLeader(unit))
    or (UnitIsPartyLeader and UnitIsPartyLeader(unit))
  local isAssistant = UnitIsGroupAssistant and UnitIsGroupAssistant(unit)
  if UnitInRaid and GetRaidRosterInfo then
    local raidIndex = UnitInRaid(unit)
    if raidIndex then
      local _, rank = GetRaidRosterInfo(raidIndex)
      isLeader = isLeader or rank == 2
      isAssistant = isAssistant or rank == 1
    end
  end
  return (isLeader or isAssistant) and true or false
end

local function CountRaidAssignmentRows(parsed)
  local count = 0
  if #(parsed and parsed.v2Assignments or {}) > 0 then
    return #(parsed.v2Assignments or {})
  end
  for _, boss in ipairs(parsed and parsed.bosses or {}) do
    for _, section in ipairs(boss.sections or {}) do
      count = count + #(section.rows or {})
    end
  end
  return count
end

local function BossPlanDeltaIdentity(plan)
  return table.concat({
    NormalizeName(plan and plan.raid), NormalizeName(plan and plan.boss),
    tostring(plan and plan.phase or 0), NormalizeName(plan and plan.name),
  }, "|")
end

local function BossPlanWireBossID(plan)
  -- Parentheses prevent string.gsub's substitution-count second return value
  -- from becoming an accidental extra table element.
  return table.concat({ "bp", NormalizeName(plan and plan.raid), (NormalizeName(plan and plan.boss)) }, ".")
end

local function BossPlanWirePlanID(plan, globalIndex)
  return table.concat({ BossPlanWireBossID(plan), "plan", tostring(globalIndex) }, ".")
end

local function IsValidBossPlanWireID(value)
  return type(value) == "string" and #value >= 3 and #value <= 180
    and value:match("^[a-z0-9._%-]+$") ~= nil
end

local function GetMGMRA4ImportForWireRaidGroup(owner, raidGroup)
  for index = #(owner:GetRaidAssignmentImports() or {}), 1, -1 do
    local entry = owner:GetRaidAssignmentImports()[index]
    if entry and entry.mgmra4Raw then
      local parsed = entry.parsed
      if not parsed or not parsed.mgmra4 then parsed = owner:ParseRaidAssignments(entry.mgmra4Raw) end
      if parsed and parsed.mgmra4 and parsed.mgmra4.raidGroup == raidGroup then
        entry.parsed = parsed
        return entry
      end
    end
  end
end

local function SetAssignmentReceiverStatus(owner, prefix, text, tone)
  owner:SetRaidAssignmentStatus(text, tone)
end

function MerfinPlus:BroadcastFullAssignmentDocument(raw, deliveryType, sourceID)
  local allowed, reason = self:CanBroadcastRaidAssignments()
  if not allowed then
    return false, reason
  end
  if type(raw) ~= "string" or Trim(raw) == "" then
    return false, "No valid assignment document is available to sync."
  end
  if deliveryType ~= ASSIGNMENT_DELIVERY_FULL_RAID then
    return false, "Unsupported assignment sync type."
  end

  local recipients = self:GetRaidAssignmentGroupRecipients()
  local distribution = self:GetRaidAssignmentBroadcastChannel()
  if not distribution then
    return false, "No raid or party addon-message channel is available."
  end
  local remoteRecipients = {}
  for _, recipient in ipairs(recipients) do
    if not recipient.isSelf and recipient.connected then
      remoteRecipients[#remoteRecipients + 1] = recipient
    end
  end
  if #remoteRecipients == 0 then
    return false, "No other connected group members were found for assignment sync."
  end
  local queue = {}
  local session = self:BeginAssignmentDeliverySession(RAID_ASSIGNMENT_ADDON_PREFIX)
  session.workflow = "full"
  local summary = { sent = #remoteRecipients, emptySent = 0, localCount = 1, missing = 0, offline = 0, ambiguous = 0 }
  local legacyRaw = raw
  local isMGMRA4 = self.IsMGMRA4Envelope and self:IsMGMRA4Envelope(raw)
  if isMGMRA4 then
    local limits = self:GetMGMRA4Limits()
    if #raw > limits.broadcastLimitChars then
      self:AbortAssignmentDeliverySession(session)
      return false, "MGMRA4 exceeds the 32,400-character addon broadcast limit; use clipboard import."
    end
    local parsed, parseError = self:ParseRaidAssignments(raw)
    if not parsed or not parsed.mgmra4 then
      self:AbortAssignmentDeliverySession(session)
      return false, parseError or "The MGMRA4 payload is invalid."
    end
    legacyRaw = parsed.mgmra4.legacyAssignments
  end

  -- V4 is submitted before the much larger uncompressed MGMRA3 compatibility
  -- body as part of this same explicit transfer. The fallback remains byte-for-
  -- byte compatible and is retained for clients that do not understand V4.
  if isMGMRA4 then
    local v4BroadcastID = QueueMGMRA4GroupPayload(
      queue,
      RAID_ASSIGNMENT_ADDON_PREFIX,
      sourceID or deliveryType,
      raw,
      distribution,
      "BULK"
    )
    for _, recipient in ipairs(remoteRecipients) do
      self:RegisterAssignmentDeliveryPending(
        session,
        v4BroadcastID,
        recipient,
        MGMRA4_TRANSPORT_REVISION,
        "mgmra4"
      )
    end
  end
  local legacyBroadcastID = QueueGroupPayload(
    queue,
    RAID_ASSIGNMENT_ADDON_PREFIX,
    isMGMRA4 and ((sourceID or deliveryType) .. "-mgmra4-fallback") or (sourceID or deliveryType),
    legacyRaw,
    deliveryType,
    distribution,
    "BULK"
  )
  for _, recipient in ipairs(remoteRecipients) do
    self:RegisterAssignmentDeliveryPending(
      session,
      legacyBroadcastID,
      recipient,
      ASSIGNMENT_TRANSPORT_REVISION,
      isMGMRA4 and "legacy-fallback" or "legacy"
    )
  end
  local sent = SendPersonalQueue(self, RAID_ASSIGNMENT_ADDON_PREFIX, queue, summary, function(text, tone)
    self:SetRaidAssignmentStatus(text, tone)
  end, session)
  if sent then
    self:SetRaidAssignmentStatus(
      isMGMRA4
        and "Submitting one complete MGMRA4 snapshot plus MGMRA3 fallback; waiting for receiver receipts."
        or "Sending the full assignment snapshot; waiting for receiver receipts.",
      "muted"
    )
  end
  return sent, sent and "pending" or "send failed"
end

function MerfinPlus:BroadcastFullRaidAssignments(groupID)
  local entry = self:GetRaidAssignmentImportForGroup(groupID)
  if not entry or not entry.raw then
    return false, "No imported Raid Assignments exist for the selected raid."
  end
  return self:BroadcastFullAssignmentDocument(
    entry.mgmra4Raw or entry.raw,
    ASSIGNMENT_DELIVERY_FULL_RAID,
    entry.id
  )
end

function MerfinPlus:BroadcastBossPlanDocument(raw, metadata)
  local allowed, reason = self:CanBroadcastRaidAssignments()
  if not allowed then return false, reason end
  if not self:IsMGMRA4Envelope(raw) then return false, "Boss Plan Send requires an MGMRA4 plan envelope." end
  local envelope, envelopeError = self:DecodeAndValidateMGMRA4Envelope(raw)
  if not envelope then return false, envelopeError or "Boss Plan payload is invalid." end
  if #(envelope.plans or {}) ~= 1 then return false, "Boss Plan Send must contain exactly one plan." end
  if type(metadata) ~= "table" then
    return false, "Boss Plan Send requires a bossId, planId, and saved revision."
  end
  local plan = envelope.plans[1]
  local bossID, planID, revision = metadata.bossId, metadata.planId, tonumber(metadata.revision)
  if not IsValidBossPlanWireID(bossID) or not IsValidBossPlanWireID(planID) or not revision or revision < 1 then
    return false, "Boss Plan Send metadata is invalid. Save the selected plan again."
  end
  if bossID ~= BossPlanWireBossID(plan) then
    return false, "Boss Plan Send bossId does not match the selected plan (got " .. tostring(bossID)
      .. ", expected " .. BossPlanWireBossID(plan) .. ")."
  end
  local distribution = self:GetRaidAssignmentBroadcastChannel()
  if not distribution then return false, "No raid or party addon-message channel is available." end
  local remoteRecipients = {}
  for _, recipient in ipairs(self:GetRaidAssignmentGroupRecipients()) do
    if not recipient.isSelf and recipient.connected then remoteRecipients[#remoteRecipients + 1] = recipient end
  end
  if #remoteRecipients == 0 then return false, "No other connected group members were found for Boss Plan Send." end
  local limits = self:GetMGMRA4Limits()
  if #raw > limits.broadcastLimitChars then return false, "The selected Boss Plan exceeds the addon broadcast limit." end
  local queue = {}
  if self.activeBossPlanDeliverySession and not self.activeBossPlanDeliverySession.finalized then
    self:AbortAssignmentDeliverySession(self.activeBossPlanDeliverySession)
  end
  local session = self:BeginAssignmentDeliverySession(RAID_ASSIGNMENT_ADDON_PREFIX)
  session.workflow = "bossplan"
  session.planId, session.bossId, session.revision = planID, bossID, revision
  self.activeBossPlanDeliverySession = session
  local broadcastID, chunks = QueueMGMRA4PlanGroupPayload(
    queue, RAID_ASSIGNMENT_ADDON_PREFIX, "bossplan-r" .. tostring(revision), raw, distribution,
    { bossId = bossID, planId = planID, revision = revision }
  )
  for _, recipient in ipairs(remoteRecipients) do
    self:RegisterAssignmentDeliveryPending(
      session, broadcastID, recipient, MGMRA4_PLAN_TRANSPORT_REVISION, "bossplan-delta"
    )
  end
  local summary = { sent = #remoteRecipients, emptySent = 0, localCount = 1, missing = 0, offline = 0, ambiguous = 0 }
  local sent = SendPersonalQueue(self, RAID_ASSIGNMENT_ADDON_PREFIX, queue, summary, function(text, tone)
    self:SetRaidAssignmentStatus(text, tone)
  end, session)
  if sent then
    self:SetRaidAssignmentStatus(
      self:T("Sending one Boss Plan delta (%d bytes, %d chunks); waiting for receiver receipts.", #raw, chunks),
      "muted"
    )
  end
  return sent, sent and "pending" or "send failed"
end

function MerfinPlus:CancelActiveBossPlanDelivery()
  local session = self.activeBossPlanDeliverySession
  if session and not session.finalized then self:AbortAssignmentDeliverySession(session) end
  self.activeBossPlanDeliverySession = nil
end

local function GetAssignmentProtocolLabel(prefix)
  return MerfinPlus:T("Raid Assignments")
end

local function GetClassColorString(classToken)
  local colorTable = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
  local color = colorTable and classToken and colorTable[classToken]
  if color and type(color.colorStr) == "string" and color.colorStr ~= "" then
    return color.colorStr
  end
  if color and type(color.r) == "number" and type(color.g) == "number" and type(color.b) == "number" then
    return string.format(
      "ff%02x%02x%02x",
      math.floor((color.r * 255) + 0.5),
      math.floor((color.g * 255) + 0.5),
      math.floor((color.b * 255) + 0.5)
    )
  end
  return "ffdddddd"
end

local function ColorizeConfirmedRecipient(recipient)
  local name = CleanPlayerName(recipient and recipient.sender or recipient and recipient.commName or "Unknown")
  local version = tostring(recipient and recipient.version or "")
  if version == "" then
    version = "unknown"
  end
  if version:sub(1, 1):lower() ~= "v" then
    version = "v" .. version
  end
  local compatibilityNote = ""
  if recipient and recipient.compatible == false then
    compatibilityNote = string.format(" [transport r%s]", tostring(recipient.revision or "unknown"))
  elseif recipient and recipient.capability == "mgmra4" then
    compatibilityNote = " [MGMRA4 boss plan]"
  elseif recipient and recipient.capability == "legacy-fallback" then
    compatibilityNote = " [MGMRA3 assignments only]"
  end
  return string.format(
    "|c%s%s|r (%s)%s",
    GetClassColorString(recipient and recipient.classToken),
    name,
    version,
    compatibilityNote
  )
end

local function SetAssignmentDeliveryStatus(owner, session, text, tone)
  owner:SetRaidAssignmentStatus(text, tone)
  if session and session.workflow == "bossplan" then
    local viewer = owner.bossPlanViewer
    if viewer and viewer.SetStatus and (not viewer.IsShown or viewer:IsShown()) then
      viewer:SetStatus(text, tone == "red" and "error" or tone)
    end
  end
end

local function CleanupAssignmentDeliverySession(owner, session)
  CancelAssignmentDeliveryTimers(session)
  for pendingKey, pending in pairs(session.pending or {}) do
    if owner.assignmentDeliveryPending then
      local byRecipient = owner.assignmentDeliveryPending[pending.broadcastID]
      if byRecipient then
        byRecipient[pendingKey] = nil
        if not next(byRecipient) then owner.assignmentDeliveryPending[pending.broadcastID] = nil end
      end
    end
  end
  session.pending = {}
  if owner.assignmentDeliverySessions then owner.assignmentDeliverySessions[session.id] = nil end
  if owner.activeBossPlanDeliverySession == session then owner.activeBossPlanDeliverySession = nil end
end

function MerfinPlus:FinalizeAssignmentDeliverySession(session)
  if not session or session.finalized then return end
  local confirmedByRecipient, recipientOrder = {}, {}
  for _, broadcastID in ipairs(session.order or {}) do
    local recipient = session.confirmed and session.confirmed[broadcastID]
    if recipient then
      local recipientKey = NormalizeName(recipient.commName or recipient.sender)
      local previous = confirmedByRecipient[recipientKey]
      if not previous then
        recipientOrder[#recipientOrder + 1] = recipientKey
      end
      if not previous or recipient.capability == "mgmra4" then
        confirmedByRecipient[recipientKey] = recipient
      end
    end
  end
  local confirmed = {}
  for _, recipientKey in ipairs(recipientOrder) do
    confirmed[#confirmed + 1] = ColorizeConfirmedRecipient(confirmedByRecipient[recipientKey])
  end
  local label = session.workflow == "bossplan" and "Boss Plan"
    or session.workflow == "boss-delta" and "Selected-boss widget"
    or GetAssignmentProtocolLabel(session.prefix)
  local pendingCount = 0
  for _ in pairs(session.pending or {}) do pendingCount = pendingCount + 1 end
  if pendingCount > 0 and not session.aborted and (session.sendFailures or 0) == 0
    and (session.rejections or 0) == 0
  then
    session.finalized = true
    local text
    if #confirmed > 0 then
      text = self:T(
        "%s delivered (%s); no confirmation was observed from %d group member(s).",
        label,
        table.concat(confirmed, ", "),
        pendingCount
      )
    else
      text = self:T("%s payload was submitted once; no receiver confirmation was observed.", label)
    end
    SetAssignmentDeliveryStatus(self, session, text, "muted")
    self.PrettyPrint(text)
    CleanupAssignmentDeliverySession(self, session)
    return
  end
  session.finalized = true
  local missingMGMRA4 = session.rejectedMGMRA4 or 0
  for _, pending in pairs(session.pending or {}) do
    if pending.capability == "mgmra4" then missingMGMRA4 = missingMGMRA4 + 1 end
  end
  if #confirmed > 0 and missingMGMRA4 > 0 then
    local text = self:T(
      "%s delivery was only partially confirmed by %s; %d MGMRA4 Boss Plan receipt(s) are missing.",
      label,
      table.concat(confirmed, ", "),
      missingMGMRA4
    )
    SetAssignmentDeliveryStatus(self, session, text, "muted")
    self.PrettyPrint(text)
  elseif #confirmed > 0 then
    local text = self:T("%s delivered (%s).", label, table.concat(confirmed, ", "))
    SetAssignmentDeliveryStatus(self, session, text, "good")
    self.PrettyPrint(text)
  elseif (session.rejections or 0) > 0 then
    local text = session.lastRejectionText or self:T("%s delivery was rejected by a receiver.", label)
    SetAssignmentDeliveryStatus(self, session, text, "red")
  elseif (session.sendFailures or 0) > 0 then
    local text = self:T("%s delivery could not be sent on the group addon-message channel.", label)
    SetAssignmentDeliveryStatus(self, session, text, "red")
    self.PrettyPrint(text)
  end
  CleanupAssignmentDeliverySession(self, session)
end

function MerfinPlus:ScheduleAssignmentDeliveryFinalization(session)
  if not session or session.finalized or not session.queueFinished then
    return
  end
  session.ackGeneration = (session.ackGeneration or 0) + 1
  local generation = session.ackGeneration
  local finish = function()
    if not session.finalized and session.queueFinished and session.ackGeneration == generation then
      self:FinalizeAssignmentDeliverySession(session)
    end
  end
  if session.ackTimer and session.ackTimer.Cancel then
    pcall(session.ackTimer.Cancel, session.ackTimer)
    if session.deliveryTimers then session.deliveryTimers[session.ackTimer] = nil end
  end
  session.ackTimer = ScheduleAssignmentDeliveryTimer(
    session,
    session.ackTimeout or ASSIGNMENT_ACK_WINDOW_SECONDS,
    finish
  )
end

function MerfinPlus:BeginAssignmentDeliverySession(prefix)
  self.assignmentDeliverySessions = self.assignmentDeliverySessions or {}
  self.assignmentDeliveryPending = self.assignmentDeliveryPending or {}
  self.assignmentDeliverySessionCounter = (self.assignmentDeliverySessionCounter or 0) + 1
  local session = {
    id = tostring(prefix) .. "-" .. tostring(Now()) .. "-" .. tostring(self.assignmentDeliverySessionCounter),
    prefix = prefix,
    order = {},
    pending = {},
    confirmed = {},
    queueFinished = false,
    finalized = false,
  }
  self.assignmentDeliverySessions[session.id] = session
  return session
end

function MerfinPlus:RegisterAssignmentDeliveryPending(session, broadcastID, recipient, expectedRevision, capability)
  if not session or not broadcastID or not recipient then
    return
  end
  local pending = {
    session = session,
    recipient = recipient,
    broadcastID = broadcastID,
    expectedRevision = expectedRevision or ASSIGNMENT_TRANSPORT_REVISION,
    capability = capability or "legacy",
  }
  local pendingKey = tostring(broadcastID) .. "\001" .. NormalizeName(recipient.commName or recipient.name)
  session.order[#session.order + 1] = pendingKey
  session.pending[pendingKey] = pending
  self.assignmentDeliveryPending[broadcastID] = self.assignmentDeliveryPending[broadcastID] or {}
  self.assignmentDeliveryPending[broadcastID][pendingKey] = pending
end

function MerfinPlus:AbortAssignmentDeliverySession(session)
  if not session or session.finalized then
    return
  end
  session.aborted = true
  self:FinalizeAssignmentDeliverySession(session)
end

function MerfinPlus:MarkAssignmentDeliveryQueueFinished(session)
  if not session or session.finalized then
    return
  end
  session.queueFinished = true
  if (session.sendFailures or 0) > 0 then
    self:FinalizeAssignmentDeliverySession(session)
  else
    self:ScheduleAssignmentDeliveryFinalization(session)
  end
end

local function SenderMatchesRecipient(sender, recipient)
  local senderFull = NormalizeName(sender)
  local recipientFull = NormalizeName(recipient and recipient.commName)
  if senderFull ~= "" and senderFull == recipientFull then
    return true
  end
  return NormalizeName(CleanPlayerName(sender)) == NormalizeName(recipient and recipient.name)
end

function MerfinPlus:IsAuthorizedRaidAssignmentSender(sender)
  local senderText = tostring(sender or "")
  local senderFull = NormalizeName(senderText)
  local senderShort = NormalizeName(CleanPlayerName(senderText))
  if senderShort == "" then
    return false
  end
  local fullMatch, shortMatch, shortMatches = nil, nil, 0
  for _, recipient in ipairs(self:GetRaidAssignmentGroupRecipients()) do
    if senderFull ~= "" and senderFull == NormalizeName(recipient.commName) then
      fullMatch = recipient
      break
    end
    if senderShort == NormalizeName(recipient.name) then
      shortMatch = recipient
      shortMatches = shortMatches + 1
    end
  end
  local senderUnit = fullMatch and fullMatch.unit or (shortMatches == 1 and shortMatch and shortMatch.unit)
  if not senderUnit then
    return false
  end
  return IsGroupLeaderOrAssistant(senderUnit)
end

local function GetCurrentRosterClassToken(owner, sender, fallback)
  local _, byShort, byFull = owner:GetRaidAssignmentGroupRecipients()
  local senderEntry = byFull[NormalizeName(sender)] or byShort[NormalizeName(CleanPlayerName(sender))]
  return senderEntry and senderEntry.classToken or fallback
end

local function ColorizeAssignmentSender(owner, sender)
  local classToken = GetCurrentRosterClassToken(owner, sender, nil)
  return string.format(
    "|c%s%s|r",
    GetClassColorString(classToken),
    CleanPlayerName(sender)
  )
end

local function DeliveryKindForCapability(capability)
  if capability == "mgmra4" then return "full-v4" end
  if capability == "legacy" or capability == "legacy-fallback" then return "full-legacy" end
  if capability == "bossplan-delta" then return "bossplan" end
  if capability == "boss-delta" then return "boss-delta" end
  return capability or "assignment"
end

function MerfinPlus:SendAssignmentDeliveryReceipt(prefix, transferID, rowCount, revision, kind, sender, sourceChannel)
  local version = GetAddonVersion()
  local legacy = table.concat({ "ACK", transferID, tostring(rowCount), version, revision }, "|")
  local receipt = table.concat({ "RACK", kind, transferID, tostring(rowCount), version, revision }, "|")
  -- Keep the original whisper ACK for older senders. Anniversary clients have
  -- shown successful group delivery while this return whisper was not observed,
  -- so modern peers also echo a kind-bound receipt on the originating group
  -- channel. Only the sender with a matching pending transfer accepts it.
  self:SendAssignmentAddonMessage(prefix, legacy, sender, "WHISPER", "ALERT")
  if sourceChannel == "RAID" or sourceChannel == "PARTY" then
    self:SendAssignmentAddonMessage(prefix, receipt, nil, sourceChannel, "ALERT")
  else
    self:SendAssignmentAddonMessage(prefix, receipt, sender, "WHISPER", "ALERT")
  end
end

function MerfinPlus:HandleAssignmentDeliveryFeedback(prefix, broadcastID, sender, rowCount, remoteVersion, remoteRevision, rejectedReason, receiptKind)
  local label = GetAssignmentProtocolLabel(prefix)
  local senderName = CleanPlayerName(sender)
  local candidates = self.assignmentDeliveryPending and self.assignmentDeliveryPending[broadcastID]
  local pendingKey, pending
  for candidateKey, candidate in pairs(candidates or {}) do
    if candidate.session.prefix == prefix and SenderMatchesRecipient(sender, candidate.recipient)
      and (not receiptKind or receiptKind == DeliveryKindForCapability(candidate.capability))
    then
      pendingKey, pending = candidateKey, candidate
      break
    end
  end
  if not pending then
    return
  end
  local session = pending.session
  local compatible = tostring(remoteRevision or "") == tostring(pending.expectedRevision or ASSIGNMENT_TRANSPORT_REVISION)
  session.pending[pendingKey] = nil
  candidates[pendingKey] = nil
  if not next(candidates) then
    self.assignmentDeliveryPending[broadcastID] = nil
  end

  if rejectedReason and rejectedReason ~= "" then
    local text = self:T("%s delivery rejected by %s: %s.", label, senderName, rejectedReason)
    session.rejections = (session.rejections or 0) + 1
    session.lastRejectionText = text
    if pending.capability == "mgmra4" then
      session.rejectedMGMRA4 = (session.rejectedMGMRA4 or 0) + 1
    end
    SetAssignmentDeliveryStatus(self, session, text, "red")
    self.PrettyPrint(text)
  else
    session.confirmed[pendingKey] = {
      sender = senderName,
      commName = pending.recipient.commName,
      classToken = GetCurrentRosterClassToken(self, sender, pending.recipient.classToken),
      rowCount = tonumber(rowCount) or 0,
      version = tostring(remoteVersion or ""),
      revision = tostring(remoteRevision or ""),
      compatible = compatible,
      capability = pending.capability,
    }
    -- A successful MGMRA4 receipt proves that this client received the full
    -- assignments + Boss Plans snapshot. Its MGMRA3 compatibility receipt must
    -- not delay the sender's result behind the large fallback body.
    if pending.capability == "mgmra4" then
      for fallbackKey, fallback in pairs(session.pending or {}) do
        if fallback.capability == "legacy-fallback"
          and SenderMatchesRecipient(sender, fallback.recipient)
        then
          session.pending[fallbackKey] = nil
          local fallbackCandidates = self.assignmentDeliveryPending
            and self.assignmentDeliveryPending[fallback.broadcastID]
          if fallbackCandidates then
            fallbackCandidates[fallbackKey] = nil
            if not next(fallbackCandidates) then
              self.assignmentDeliveryPending[fallback.broadcastID] = nil
            end
          end
        end
      end
    elseif pending.capability == "legacy-fallback" then
      -- V4 is always sent first. If the same recipient only acknowledges the
      -- later fallback, classify it immediately as assignments-only instead of
      -- waiting through a long MGMRA4 receipt window.
      for v4Key, v4Pending in pairs(session.pending or {}) do
        if v4Pending.capability == "mgmra4"
          and SenderMatchesRecipient(sender, v4Pending.recipient)
        then
          session.pending[v4Key] = nil
          session.rejectedMGMRA4 = (session.rejectedMGMRA4 or 0) + 1
          local v4Candidates = self.assignmentDeliveryPending
            and self.assignmentDeliveryPending[v4Pending.broadcastID]
          if v4Candidates then
            v4Candidates[v4Key] = nil
            if not next(v4Candidates) then
              self.assignmentDeliveryPending[v4Pending.broadcastID] = nil
            end
          end
        end
      end
    end
  end
  if not next(session.pending) then
    self:FinalizeAssignmentDeliverySession(session)
  else
    local remaining = 0
    for _ in pairs(session.pending or {}) do remaining = remaining + 1 end
    SetAssignmentDeliveryStatus(
      self,
      session,
      self:T("Receipt received from %s; waiting for %d remaining receipt(s).", senderName, remaining),
      "muted"
    )
    self:ScheduleAssignmentDeliveryFinalization(session)
  end
end

function MerfinPlus:BroadcastPersonalRaidAssignments(catalogBoss)
  local allowed, reason = self:CanBroadcastRaidAssignments()
  if not allowed then
    self:SetRaidAssignmentStatus(reason, "red")
    return false
  end
  local state = self:GetRaidAssignmentUIState()
  local groupID = state.selectedGroup
  local entry = self:GetRaidAssignmentImportForGroup(groupID)
  local boss = entry and entry.parsed and self:GetRaidAssignmentBoss(entry.parsed, catalogBoss)
  if not entry or not boss then
    self:SetRaidAssignmentStatus("No imported assignments exist for the selected boss.", "red")
    return false
  end

  local recipients = self:GetRaidAssignmentGroupRecipients()
  local distribution = self:GetRaidAssignmentBroadcastChannel()
  if not distribution then
    self:SetRaidAssignmentStatus("No raid or party addon-message channel is available.", "red")
    return false
  end
  local remoteRecipients = {}
  for _, recipient in ipairs(recipients) do
    if not recipient.isSelf and recipient.connected then
      remoteRecipients[#remoteRecipients + 1] = recipient
    end
  end
  entry.contentSignature = entry.contentSignature or GetRaidAssignmentContentSignature(entry.raw)
  self:SetPersonalRaidAssignmentSelection(entry, boss)
  local deltaRaw, deltaRows = self:BuildRaidBossBroadcastPayload(entry.parsed, boss)
  if not deltaRaw or deltaRows < 1 then
    self:SetRaidAssignmentStatus("The selected boss has no assignment rows to broadcast.", "red")
    return false
  end
  if #remoteRecipients == 0 then
    self:SetRaidAssignmentStatus("No other connected group members were found for this broadcast.", "red")
    if self.MarkAssignmentWidgetContentDirty then
      self:MarkAssignmentWidgetContentDirty("assignmentWidget")
    elseif self.RefreshAssignmentWidget then
      self:RefreshAssignmentWidget()
    end
    return false
  end
  local queue = {}
  local deliverySession = self:BeginAssignmentDeliverySession(RAID_ASSIGNMENT_ADDON_PREFIX)
  deliverySession.workflow = "boss-delta"
  local summary = {
    sent = #remoteRecipients,
    emptySent = 0,
    localCount = 1,
    missing = 0,
    offline = 0,
    ambiguous = 0,
  }
  local broadcastID = QueueGroupPayload(
    queue,
    RAID_ASSIGNMENT_ADDON_PREFIX,
    tostring(entry.id) .. "-boss-" .. tostring(boss.key or boss.name),
    deltaRaw,
    ASSIGNMENT_DELIVERY_SCOPED_RAID,
    distribution,
    "ALERT"
  )
  for _, recipient in ipairs(remoteRecipients) do
    self:RegisterAssignmentDeliveryPending(deliverySession, broadcastID, recipient, ASSIGNMENT_TRANSPORT_REVISION, "boss-delta")
  end

  local sent = SendPersonalQueue(self, RAID_ASSIGNMENT_ADDON_PREFIX, queue, summary, function(text, tone)
    self:SetRaidAssignmentStatus(text, tone)
  end, deliverySession)
  if sent and self.MarkAssignmentWidgetContentDirty then
    self:MarkAssignmentWidgetContentDirty("assignmentWidget")
  elseif sent and self.RefreshAssignmentWidget then
    self:RefreshAssignmentWidget()
  end
  if sent then
    summary.payloadBytes, summary.chunks = #deltaRaw, math.max(1, #queue - 2)
    self:SetRaidAssignmentStatus(
      self:T("Sending selected-boss widget delta (%d rows, %d bytes, %d chunks); waiting for receipts.", deltaRows, #deltaRaw, summary.chunks),
      "muted"
    )
  end
  return sent, summary
end

function MerfinPlus:HandleRaidAssignmentAddonMessage(_, prefix, message, channel, sender)
  if prefix ~= RAID_ASSIGNMENT_ADDON_PREFIX then
    return
  end
  local selfRecipient = GetUnitCommName("player")
  local senderText = tostring(sender or "")
  local senderHasRealm = senderText:find("-", 1, true) ~= nil
  local sameFullName = selfRecipient
    and NormalizeName(senderText) == NormalizeName(selfRecipient.commName)
  local sameLocalShortName = not senderHasRealm
    and selfRecipient
    and NormalizeName(CleanPlayerName(senderText)) == NormalizeName(selfRecipient.name)
  if sameFullName or sameLocalShortName then
    return
  end
  message = tostring(message or "")

  local receiptKind, receiptID, receiptRows, receiptVersion, receiptRevision =
    message:match("^RACK|([^|]+)|([^|]+)|([^|]*)|([^|]*)|([^|]*)$")
  if receiptID then
    self:HandleAssignmentDeliveryFeedback(
      prefix, receiptID, sender, tonumber(receiptRows) or 0,
      receiptVersion, receiptRevision, nil, receiptKind
    )
    return
  end

  local ackID, ackRows, ackVersion, ackRevision =
    message:match("^ACK|([^|]+)|([^|]*)|([^|]*)|([^|]*)$")
  if ackID then
    self:HandleAssignmentDeliveryFeedback(
      prefix,
      ackID,
      sender,
      tonumber(ackRows) or 0,
      ackVersion,
      ackRevision
    )
    return
  end

  local nackID, nackReason, nackVersion, nackRevision =
    message:match("^NACK|([^|]+)|([^|]*)|([^|]*)|([^|]*)$")
  if nackID then
    self:HandleAssignmentDeliveryFeedback(
      prefix,
      nackID,
      sender,
      0,
      nackVersion,
      nackRevision,
      nackReason ~= "" and nackReason or "invalid payload"
    )
    return
  end

  -- Full assignment documents are accepted only from the current group leader
  -- or an assistant. ACK/NACK feedback above is separately bound to a pending
  -- recipient and must remain available to ordinary recipients.
  if not self:IsAuthorizedRaidAssignmentSender(sender) then
    return
  end

  self.assignmentBroadcastBuffers = self.assignmentBroadcastBuffers or {}
  local prefixBuffers = self.assignmentBroadcastBuffers[prefix]
  if not prefixBuffers then
    prefixBuffers = {}
    self.assignmentBroadcastBuffers[prefix] = prefixBuffers
  end

  local planID, planTotal, planCatalog, planBossID, planWireID, planRevision =
    message:match("^V4PSTART|([^|]+)|(%d+)|(%d+)|([^|]+)|([^|]+)|(%d+)$")
  local modernPlanFrame = planID ~= nil
  if not planID then
    planID, planTotal, planCatalog = message:match("^V4PSTART|([^|]+)|(%d+)|(%d+)$")
  end
  if planID then
    local total = tonumber(planTotal) or 0
    local limits = self:GetMGMRA4Limits()
    local maximumChunks = math.ceil(limits.broadcastLimitChars / limits.broadcastChunkChars)
    local globalIndex = modernPlanFrame and tonumber(tostring(planWireID):match("%.plan%.(%d+)$")) or nil
    if tonumber(planCatalog) ~= 1 or total < 1 or total > maximumChunks
      or (modernPlanFrame and (not IsValidBossPlanWireID(planBossID)
        or not IsValidBossPlanWireID(planWireID) or not globalIndex or (tonumber(planRevision) or 0) < 1))
    then
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", planID, "invalid Boss Plan start", GetAddonVersion(), MGMRA4_PLAN_TRANSPORT_REVISION }, "|"),
        sender, "WHISPER", "ALERT"
      )
      return
    end
    prefixBuffers[NormalizeName(sender) .. "\001V4P\001" .. planID] = {
      total = total, chunks = {}, sender = sender, importID = planID, bossPlanDelta = true,
      revision = tonumber(planRevision) or tonumber(planID:match("%-r(%d+)%-v4p")) or tonumber(planID:match("(%d+)$")) or 0,
      bossId = planBossID, planId = planWireID, planGlobalIndex = globalIndex,
    }
    return
  end

  local planDataID, planIndex, planChunk = message:match("^V4PDATA|([^|]+)|(%d+)|(.*)$")
  if planDataID then
    local buffer = prefixBuffers[NormalizeName(sender) .. "\001V4P\001" .. planDataID]
    local index = tonumber(planIndex) or 0
    if buffer and index >= 1 and index <= buffer.total and #(planChunk or "") <= BROADCAST_CHUNK_SIZE then
      buffer.chunks[index] = planChunk or ""
    end
    return
  end

  local planEndID = message:match("^V4PEND|([^|]+)$")
  if planEndID then
    local bufferID = NormalizeName(sender) .. "\001V4P\001" .. planEndID
    local buffer = prefixBuffers[bufferID]
    if not buffer then return end
    local chunks = {}
    for index = 1, buffer.total do
      if buffer.chunks[index] == nil then
        self:SendAssignmentAddonMessage(
          prefix,
          table.concat({ "NACK", planEndID, "missing Boss Plan chunk", GetAddonVersion(), MGMRA4_PLAN_TRANSPORT_REVISION }, "|"),
          sender, "WHISPER", "ALERT"
        )
        prefixBuffers[bufferID] = nil
        return
      end
      chunks[index] = buffer.chunks[index]
    end
    local raw = table.concat(chunks)
    local delta, deltaError = self:DecodeAndValidateMGMRA4Envelope(raw)
    local deltaPlan = delta and delta.plans and delta.plans[1]
    local entry = delta and GetMGMRA4ImportForWireRaidGroup(self, delta.raidGroup)
    local existing = entry and entry.mgmra4Raw and self:DecodeAndValidateMGMRA4Envelope(entry.mgmra4Raw)
    local planKey = deltaPlan and BossPlanDeltaIdentity(deltaPlan)
    local storage = self:GetRaidAssignmentStorage()
    storage.bossPlanReceivedRevisionByPlan = storage.bossPlanReceivedRevisionByPlan or {}
    local revisionKey = tostring(delta and delta.raidGroup or "") .. "|"
      .. tostring(buffer.planId or planKey or "")
    local previousRevision = tonumber(storage.bossPlanReceivedRevisionByPlan[revisionKey]) or 0
    local stale = buffer.revision > 0 and previousRevision > 0 and buffer.revision <= previousRevision
    local mergedEntry, mergeError
    if stale then
      mergeError = "Ignored an older Boss Plan delta revision."
    elseif delta and #(delta.plans or {}) == 1 and deltaPlan and existing then
      local replaced = false
      if buffer.planId then
        local targetIndex = buffer.planGlobalIndex
        local target = targetIndex and existing.plans and existing.plans[targetIndex]
        if target and buffer.bossId == BossPlanWireBossID(deltaPlan)
          and buffer.bossId == BossPlanWireBossID(target)
          and buffer.planId == BossPlanWirePlanID(target, targetIndex)
        then
          existing.plans[targetIndex], replaced = deltaPlan, true
        else
          mergeError = "Boss Plan delta identity does not match the existing bossId + planId instance."
        end
      else
        -- Compatibility for already-deployed pre-identity V4P frames.
        for index, plan in ipairs(existing.plans or {}) do
          if BossPlanDeltaIdentity(plan) == planKey then existing.plans[index], replaced = deltaPlan, true; break end
        end
      end
      local mergedRaw
      if replaced then mergedRaw, mergeError = self:EncodeMGMRA4Envelope(existing)
      elseif not mergeError then mergeError = "The matching Boss Plan instance does not exist; run a full sync first." end
      if mergedRaw then mergedEntry, mergeError = self:SaveRaidAssignmentImport(mergedRaw, nil, true, sender, true, true) end
      if mergedEntry and buffer.revision > 0 then storage.bossPlanReceivedRevisionByPlan[revisionKey] = buffer.revision end
    else
      mergeError = deltaError or "A complete MGMRA4 snapshot is required before a Boss Plan delta can be applied."
    end
    if mergedEntry or stale then
      local text = stale and mergeError or self:T("Received one Boss Plan update from %s.", ColorizeAssignmentSender(self, sender))
      self:SetRaidAssignmentStatus(text, stale and "muted" or "good")
      self:SendAssignmentDeliveryReceipt(prefix, planEndID, "1", MGMRA4_PLAN_TRANSPORT_REVISION, "bossplan", sender, channel)
      if mergedEntry and self.RefreshOpenBossPlanFromImport then
        self:RefreshOpenBossPlanFromImport(mergedEntry, sender, buffer.revision)
      end
    else
      self:SetRaidAssignmentStatus(mergeError or "Received Boss Plan delta was invalid.", "red")
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", planEndID, "Boss Plan delta requires full sync", GetAddonVersion(), MGMRA4_PLAN_TRANSPORT_REVISION }, "|"),
        sender, "WHISPER", "ALERT"
      )
    end
    prefixBuffers[bufferID] = nil
    return
  end

  local v4ID, v4Total, v4DeliveryType, v4CatalogVersion =
    message:match("^V4START|([^|]+)|(%d+)|([^|]+)|(%d+)$")
  if v4ID then
    local total = tonumber(v4Total) or 0
    local limits = self:GetMGMRA4Limits()
    local maximumChunks = math.ceil(limits.broadcastLimitChars / limits.broadcastChunkChars)
    if v4DeliveryType ~= ASSIGNMENT_DELIVERY_FULL_RAID
      or tonumber(v4CatalogVersion) ~= 1
      or total < 1
      or total > maximumChunks
    then
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", v4ID, "invalid MGMRA4 start", GetAddonVersion(), MGMRA4_TRANSPORT_REVISION }, "|"),
        sender
      )
      return
    end
    local bufferID = NormalizeName(sender) .. "\001V4\001" .. v4ID
    prefixBuffers[bufferID] = {
      total = total,
      chunks = {},
      sender = sender,
      importID = v4ID,
      deliveryType = v4DeliveryType,
      mgmra4 = true,
      revision = tonumber(v4ID:match("%-r(%d+)%-v4")) or tonumber(v4ID:match("(%d+)$")) or 0,
    }
    return
  end

  local v4DataID, v4Index, v4Chunk = message:match("^V4DATA|([^|]+)|(%d+)|(.*)$")
  if v4DataID then
    local buffer = prefixBuffers[NormalizeName(sender) .. "\001V4\001" .. v4DataID]
    local index = tonumber(v4Index) or 0
    if buffer and index >= 1 and index <= buffer.total and #(v4Chunk or "") <= BROADCAST_CHUNK_SIZE then
      buffer.chunks[index] = v4Chunk or ""
    end
    return
  end

  local v4EndID = message:match("^V4END|([^|]+)$")
  if v4EndID then
    local bufferID = NormalizeName(sender) .. "\001V4\001" .. v4EndID
    local buffer = prefixBuffers[bufferID]
    if not buffer then
      return
    end
    local chunks = {}
    for chunkIndex = 1, buffer.total do
      if buffer.chunks[chunkIndex] == nil then
        self:SendAssignmentAddonMessage(
          prefix,
          table.concat({ "NACK", v4EndID, "missing MGMRA4 chunk", GetAddonVersion(), MGMRA4_TRANSPORT_REVISION }, "|"),
          sender
        )
        prefixBuffers[bufferID] = nil
        return
      end
      chunks[#chunks + 1] = buffer.chunks[chunkIndex]
    end
    local raw = table.concat(chunks)
    local limits = self:GetMGMRA4Limits()
    local entry, errorText, staleRevision
    if #raw <= limits.broadcastLimitChars and self:IsMGMRA4Envelope(raw) then
      local envelope, envelopeError = self:DecodeAndValidateMGMRA4Envelope(raw)
      if envelope then
        local storage = self:GetRaidAssignmentStorage()
        storage.bossPlanReceivedRevisionByGroup = storage.bossPlanReceivedRevisionByGroup or {}
        local previousRevision = tonumber(storage.bossPlanReceivedRevisionByGroup[envelope.raidGroup]) or 0
        if buffer.revision > 0 and previousRevision > 0 and buffer.revision <= previousRevision then
          staleRevision = true
          errorText = "Ignored an older MGMRA4 Boss Plan revision."
        else
          entry, errorText = self:SaveRaidAssignmentImport(raw, nil, true, sender, true, true)
          if entry and buffer.revision > 0 then
            storage.bossPlanReceivedRevisionByGroup[envelope.raidGroup] = buffer.revision
          end
        end
      else
        errorText = envelopeError
      end
    else
      errorText = "Received MGMRA4 payload exceeds the broadcast limit or has an invalid prefix."
    end
    if entry and entry.mgmra4Raw then
      local rowCount = CountRaidAssignmentRows(entry.parsed)
      local planCount = #(entry.parsed and entry.parsed.bossPlans or {})
      local text = self:T(
        "Received %s Assignments and %d Boss Plans from %s.",
        GetRaidAssignmentImportRaidLabel(entry),
        planCount,
        ColorizeAssignmentSender(self, sender)
      )
      self:SetRaidAssignmentStatus(text, "good")
      self.PrettyPrint(text)
      self:SendAssignmentDeliveryReceipt(prefix, v4EndID, rowCount, MGMRA4_TRANSPORT_REVISION, "full-v4", sender, channel)
      if self.MarkAssignmentWidgetContentDirty then
        self:MarkAssignmentWidgetContentDirty("assignmentWidget")
      elseif self.RefreshAssignmentWidget then
        self:RefreshAssignmentWidget()
      end
      if self.RefreshOpenBossPlanFromImport then
        self:RefreshOpenBossPlanFromImport(entry, sender, buffer.revision)
      end
    elseif staleRevision then
      self:SetRaidAssignmentStatus(errorText, "muted")
      self:SendAssignmentDeliveryReceipt(prefix, v4EndID, "stale", MGMRA4_TRANSPORT_REVISION, "full-v4", sender, channel)
    else
      self:SetRaidAssignmentStatus(errorText or "Received MGMRA4 Boss Plan was invalid.", "red")
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", v4EndID, "invalid MGMRA4 payload", GetAddonVersion(), MGMRA4_TRANSPORT_REVISION }, "|"),
        sender
      )
    end
    prefixBuffers[bufferID] = nil
    return
  end

  local selectionID, contentSignature, groupID, raidKey, bossKey =
    message:match("^SELECT|([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)$")
  if selectionID then
    local entry, boss, selectionError = self:ResolvePersonalRaidAssignmentSelection(
      groupID,
      contentSignature,
      raidKey,
      bossKey
    )
    if entry and boss then
      self:SetPersonalRaidAssignmentSelection(entry, boss)
      if self.MarkAssignmentWidgetContentDirty then
        self:MarkAssignmentWidgetContentDirty("assignmentWidget")
      elseif self.RefreshAssignmentWidget then
        self:RefreshAssignmentWidget()
      end
      local bossLabel = boss.isTrash and tostring(boss.name or (raidKey .. " Trash"))
        or self:GetLocalizedBossName(self:GetRaidAssignmentBossLocaleID(boss), boss.name)
      local text = self:T(
        "Boss Assignments for %s received from %s.",
        bossLabel,
        ColorizeAssignmentSender(self, sender)
      )
      self:SetRaidAssignmentStatus(text, "good")
      self.PrettyPrint(text)
      self:SendAssignmentDeliveryReceipt(prefix, selectionID, "1", ASSIGNMENT_TRANSPORT_REVISION, "boss-delta", sender, channel)
    else
      local text = selectionError or "Full Raid Assignments sync is required before boss assignments can be shown."
      self:SetRaidAssignmentStatus(text, "red")
      self.PrettyPrint(text)
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", selectionID, "missing full sync", GetAddonVersion(), ASSIGNMENT_TRANSPORT_REVISION }, "|"),
        sender
      )
    end
    return
  end

  local emptyID, senderVersion, senderRevision =
    message:match("^EMPTY|([^|]+)|([^|]*)|([^|]*)$")
  if emptyID then
    local text = self:T(
      "No personal %s rows were assigned to you by %s%s.",
      GetAssignmentProtocolLabel(prefix),
      CleanPlayerName(sender),
      senderRevision == ASSIGNMENT_TRANSPORT_REVISION
        and ""
        or self:T(" (different transport revision)")
    )
    SetAssignmentReceiverStatus(self, prefix, text, "muted")
    self.PrettyPrint(text)
    self:SendAssignmentDeliveryReceipt(prefix, emptyID, "0", ASSIGNMENT_TRANSPORT_REVISION, "assignment", sender, channel)
    return
  end

  local importID, total, deliveryType = message:match("^START|([^|]+)|(%d+)|([^|]+)$")
  if not importID then
    importID, total = message:match("^START|([^|]+)|(%d+)$")
    deliveryType = ASSIGNMENT_DELIVERY_SCOPED_RAID
  end
  if importID then
    if deliveryType ~= ASSIGNMENT_DELIVERY_SCOPED_RAID
      and deliveryType ~= ASSIGNMENT_DELIVERY_FULL_RAID
    then
      return
    end
    local numericTotal = tonumber(total) or 0
    if numericTotal < 1 or numericTotal > MAX_ASSIGNMENT_TRANSPORT_CHUNKS then
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", importID, "invalid chunk count", GetAddonVersion(), ASSIGNMENT_TRANSPORT_REVISION }, "|"),
        sender,
        "WHISPER",
        "ALERT"
      )
      return
    end
    local bufferID = NormalizeName(sender) .. "\001" .. importID
    prefixBuffers[bufferID] = {
      total = numericTotal,
      chunks = {},
      sender = sender,
      importID = importID,
      deliveryType = deliveryType,
      bossPlanRevision = tonumber(importID:match("%-r(%d+)%-group")) or 0,
      isMGMRA4Fallback = importID:find("%-mgmra4%-fallback%-", 1, false) ~= nil,
    }
    return
  end
  local dataID, index, chunk = message:match("^DATA|([^|]+)|(%d+)|(.*)$")
  if dataID then
    local buffer = prefixBuffers[NormalizeName(sender) .. "\001" .. dataID]
    local numericIndex = tonumber(index) or 0
    if buffer and numericIndex >= 1 and numericIndex <= buffer.total and #(chunk or "") <= BROADCAST_CHUNK_SIZE then
      buffer.chunks[numericIndex] = chunk or ""
    end
    return
  end
  local endID = message:match("^END|([^|]+)$")
  if not endID then
    return
  end
  local bufferID = NormalizeName(sender) .. "\001" .. endID
  local buffer = prefixBuffers[bufferID]
  if not buffer then
    return
  end
  local encoded = {}
  for chunkIndex = 1, buffer.total do
    if buffer.chunks[chunkIndex] == nil then
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", endID, "missing chunk", GetAddonVersion(), ASSIGNMENT_TRANSPORT_REVISION }, "|"),
        sender
      )
      prefixBuffers[bufferID] = nil
      return
    end
    encoded[#encoded + 1] = buffer.chunks[chunkIndex]
  end
  local raw = DecodeAddonPayload(table.concat(encoded))
  -- Scoped delivery is a strict assignment-row delta for one selected boss.
  -- It updates only the personal/raid-leader widget source. It never replaces
  -- the full assignment import and cannot carry MGMRA4 plan or image data.
  if buffer.deliveryType == ASSIGNMENT_DELIVERY_SCOPED_RAID then
    local parsedDelta, deltaError = self:ParseRaidAssignments(raw)
    local deltaBoss = parsedDelta and parsedDelta.bosses and parsedDelta.bosses[1]
    if parsedDelta and parsedDelta.version == 3 and deltaBoss and not parsedDelta.mgmra4 then
      self:SetLocalPersonalRaidAssignments(raw)
      local storage = self:GetRaidAssignmentStorage()
      storage.personalRaidSelection = nil
      storage.activePersonalRaidImportId = nil
      storage.activePersonalRaidBossKey = deltaBoss.key
      local rowCount = CountRaidAssignmentRows(parsedDelta)
      local text = self:T("Received selected-boss widget delta (%d rows) from %s.", rowCount, ColorizeAssignmentSender(self, sender))
      self:SetRaidAssignmentStatus(text, "good")
      if self.MarkAssignmentWidgetContentDirty then
        self:MarkAssignmentWidgetContentDirty("assignmentWidget")
      elseif self.RefreshAssignmentWidget then
        self:RefreshAssignmentWidget()
      end
      self:SendAssignmentDeliveryReceipt(prefix, endID, rowCount, ASSIGNMENT_TRANSPORT_REVISION, "boss-delta", sender, channel)
    else
      self:SetRaidAssignmentStatus(deltaError or "Received selected-boss widget delta was invalid.", "red")
      self:SendAssignmentAddonMessage(
        prefix,
        table.concat({ "NACK", endID, "invalid boss delta", GetAddonVersion(), ASSIGNMENT_TRANSPORT_REVISION }, "|"),
        sender,
        "WHISPER",
        "ALERT"
      )
    end
    prefixBuffers[bufferID] = nil
    return
  end
  local entry, errorText, parsed, staleBossPlanFallback
  if buffer.deliveryType == ASSIGNMENT_DELIVERY_FULL_RAID then
    local revisions = self:GetRaidAssignmentStorage().bossPlanReceivedRevisionByGroup or {}
    local parsedFallback = self:ParseRaidAssignments(raw)
    local fallbackGroup = parsedFallback and self:FindRaidAssignmentGroupForParsed(parsedFallback)
    local currentEntry = fallbackGroup and self:GetRaidAssignmentImportForGroup(fallbackGroup.id)
    local previousRevision = fallbackGroup and tonumber(revisions[fallbackGroup.id]) or 0
    if buffer.isMGMRA4Fallback and currentEntry and currentEntry.mgmra4Raw then
      staleBossPlanFallback = true
      errorText = "MGMRA3 compatibility fallback acknowledged; the complete MGMRA4 snapshot remains active."
    elseif buffer.bossPlanRevision > 0 and previousRevision > 0 and buffer.bossPlanRevision <= previousRevision then
      staleBossPlanFallback = true
      errorText = "Ignored an older MGMRA3 compatibility fallback."
    else
      entry, errorText = self:SaveRaidAssignmentImport(raw, nil, false, sender, true, true)
      parsed = entry and entry.parsed
    end
  end
  if entry then
    local rowCount = CountRaidAssignmentRows(parsed)
    local text
    text = self:T(
      "Received %s Assignments from %s.",
      GetRaidAssignmentImportRaidLabel(entry),
      ColorizeAssignmentSender(self, sender)
    )
    self:SetRaidAssignmentStatus(text, "good")
    self.PrettyPrint(text)
    self:SendAssignmentDeliveryReceipt(prefix, endID, rowCount, ASSIGNMENT_TRANSPORT_REVISION, "full-legacy", sender, channel)
  elseif staleBossPlanFallback then
    self:SetRaidAssignmentStatus(errorText, "muted")
    self:SendAssignmentDeliveryReceipt(prefix, endID, "stale", ASSIGNMENT_TRANSPORT_REVISION, "full-legacy", sender, channel)
  else
    self:SetRaidAssignmentStatus(
      errorText or self:T("Received Raid Assignments were invalid."),
      "red"
    )
    self:SendAssignmentAddonMessage(
      prefix,
      table.concat({ "NACK", endID, "invalid Raid payload", GetAddonVersion(), ASSIGNMENT_TRANSPORT_REVISION }, "|"),
      sender
    )
  end
  prefixBuffers[bufferID] = nil
end

function MerfinPlus:InitializeRaidAssignments()
  self:GetRaidAssignmentStorage()
  local prefixesReady = self:RegisterRaidAssignmentPrefix()
  if not prefixesReady then
    self.PrettyPrint(self:T("Assignment addon-message prefixes could not be registered."))
  end
  if not self.assignmentAddonEventFrame then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
      self:HandleRaidAssignmentAddonMessage(event, prefix, message, channel, sender)
    end)
    self.assignmentAddonEventFrame = frame
  end
end

function MerfinPlus:RegisterRaidAssignmentsWidget(widget)
  self.raidAssignmentWidgets = self.raidAssignmentWidgets or setmetatable({}, { __mode = "k" })
  self.raidAssignmentWidgets[widget] = true
end

function MerfinPlus:NotifyRaidAssignmentOptionsChanged()
  for widget in pairs(self.raidAssignmentWidgets or {}) do
    if widget.Refresh then
      widget:Refresh()
    end
  end
end

function MerfinPlus:NotifyRaidAssignmentStatusChanged()
  local state = self:GetRaidAssignmentUIState()
  for widget in pairs(self.raidAssignmentWidgets or {}) do
    if widget.UpdateStatus then
      widget:UpdateStatus(state)
    end
  end
end

function MerfinPlus:UnregisterRaidAssignmentsWidget(widget)
  if self.raidAssignmentWidgets then
    self.raidAssignmentWidgets[widget] = nil
  end
end

function MerfinPlus:NotifyRaidAssignmentsChanged(refreshPersonalWidget)
  self:NotifyRaidAssignmentOptionsChanged()
  if self.NotifyAssignmentWidgetContentChanged then
    self:NotifyAssignmentWidgetContentChanged(refreshPersonalWidget)
    return
  end
  if refreshPersonalWidget ~= false and self.RefreshAssignmentWidget then
    self:RefreshAssignmentWidget()
  end
  if self.RefreshRaidLeaderWidget then
    self:RefreshRaidLeaderWidget()
  end
end
