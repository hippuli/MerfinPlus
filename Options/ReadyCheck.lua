-- TBC Anniversary Ready Check window and durability exchange.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
if not (Merfin.IsTBC()) then
  return
end

local LSM = LibStub("LibSharedMedia-3.0", true)
local ADDON_PREFIX = "MFP_RC1"
local T5_PREFIX = "MERFIN_VC"
local T5_PACK_KEY = "T5"
local T6_PACK_KEY = "T6"
local T6_ASSIGNMENTS_PACK_KEY = "T6A"
local PACK_REQUEST_RETRY_DELAYS = { 0.8, 2.0 }
local PACK_REQUEST_SETTLE_SECONDS = 3.2
local EXPIRING_SECONDS = 5 * 60
local DURABILITY_BASIS_POINTS_PER_PERCENT = 100
local DURABILITY_MAX_BASIS_POINTS = 100 * DURABILITY_BASIS_POINTS_PER_PERCENT
local BASE_WIDTH = 940
local BASE_HEIGHT = 820
local MIN_WIDTH = 260
local MIN_HEIGHT = 120
local MAX_WIDTH = 1600
local MAX_HEIGHT = 1000

local READY_CHECK_DEFAULTS = {
  enabled = false,
  enableSlashMerfinRT = false,
  leaderOnly = false,
  assistantOnly = false,
  displayDuration = 15,
  fontSize = 14,
  sortByClass = false,
  sortByName = false,
  reportFood = false,
  reportFlask = false,
  reportScrolls = false,
  reportMotw = false,
  reportIntellect = false,
  reportAttackPower = false,
  reportStamina = false,
  reportSpirit = false,
  reportArmor = false,
  reportShadow = false,
  reportMight = false,
  reportWisdom = false,
  reportKings = false,
  reportSalvation = false,
  showExpiring = true,
  showFoodColumn = true,
  showFlaskColumn = true,
  showScrollsColumn = true,
  showMotwColumn = true,
  showIntellectColumn = true,
  showAttackPowerColumn = true,
  showStaminaColumn = true,
  showSpiritColumn = true,
  showArmorColumn = true,
  showShadowColumn = true,
  showMightColumn = true,
  showWisdomColumn = true,
  showKingsColumn = true,
  showSalvationColumn = true,
  showDurabilityColumn = true,
  showMerfinPlusColumn = true,
  showT5Column = true,
  showT6Column = true,
  showT6AColumn = true,
  windowWidth = BASE_WIDTH,
  windowHeight = BASE_HEIGHT,
  windowX = 0,
  windowY = 0,
}

-- Spell IDs are matched against auras directly visible on each group unit.
-- Food includes the Classic and TBC Well Fed variants that can be active at
-- level 70. Flask includes Classic, TBC, Shattrath and unstable raid flasks.
local CATEGORY_SPELLS = {
  food = {
    18125, 18141, 18191, 18192, 18194, 18222, 19705, 19706, 19708, 19709,
    19710, 19711, 22730, 22789, 22790, 24799, 24870, 25661, 25694, 25804,
    25941, 29335, 33254, 33256, 33257, 33259, 33261, 33263, 33265, 33268,
    33272, 35272, 40323, 42293, 43722, 43730, 43764, 43771, 44097, 44098,
    44099, 44100, 44101, 44102, 44104, 44105, 44106, 45245, 45619, 46682,
    46687, 46899,
  },
  flask = {
    17626, 17627, 17628, 17629,
    28518, 28519, 28520, 28521, 28540,
    40567, 40568, 40572, 40573, 40575, 40576,
    41608, 41609, 41610, 41611, 42735, 46837, 46839,
  },
  battleElixir = {
    -- Classic battle elixirs still usable at level 70
    11334, 11405, 11406, 11474, 16322, 16323, 16329, 17038, 17537,
    17538, 17539, 21920, 26276,
    -- TBC battle elixirs
    28490, 28491, 28493, 28497, 28501, 28503, 33720, 33721, 33726, 38954,
  },
  guardianElixir = {
    -- Classic guardian elixirs still usable at level 70
    3593, 10668, 10693, 11348, 11371, 16325, 16326, 17535, 24361,
    24363, 24382, 24383, 24417,
    -- TBC guardian elixirs
    28502, 28509, 28514, 39625, 39626, 39627, 39628,
  },
  scrolls = {
    8091, 8094, 8095, 8096, 8097, 8098, 8099, 8100, 8101,
    8112, 8113, 8114, 8115, 8116, 8117, 8118, 8119, 8120,
    12174, 12175, 12176, 12177, 12178, 12179,
    33077, 33078, 33079, 33080, 33081, 33082,
  },
  motw = {
    1126, 5232, 5234, 6756, 8907, 9884, 9885, 21849, 21850, 26990, 26991,
  },
  intellect = {
    -- Arcane Intellect and Arcane Brilliance
    1459, 1460, 1461, 10156, 10157, 23028, 27126, 27127,
  },
  attackPower = {
    -- Battle Shout
    6673, 5242, 6192, 11549, 11550, 11551, 25289, 2048,
    -- Trueshot Aura and Unleashed Rage
    19506, 20905, 20906, 27066, 30802, 30808, 30809,
  },
  stamina = {
    -- Power Word: Fortitude and Prayer of Fortitude
    1243, 1244, 1245, 2791, 10937, 10938, 25389,
    21562, 21564, 25392,
  },
  spirit = {
    14752, 14818, 14819, 25312, 27841, 27681, 32999,
  },
  armor = {
    -- Inner Fire
    588, 602, 1006, 7128, 10951, 10952, 25431,
    -- Devotion Aura
    465, 643, 1032, 10290, 10291, 10292, 10293, 27149,
    -- Frost/Ice Armor, Demon Armor and Stoneskin Totem
    168, 7300, 7301, 7302, 7320, 10219, 10220, 27124,
    706, 1086, 11733, 11734, 11735, 27260,
    8071, 8154, 8155, 10406, 10407, 10408, 25508,
  },
  shadow = {
    -- Shadow Protection and Prayer of Shadow Protection
    976, 10957, 10958, 25433, 27683, 39374,
    -- Shadow Resistance Aura
    19876, 19895, 19896, 27151,
  },
  might = {
    -- Blessing and Greater Blessing of Might
    19740, 19834, 19835, 19836, 19837, 19838, 25291, 27140,
    25782, 25916, 27141,
  },
  wisdom = {
    -- Blessing and Greater Blessing of Wisdom
    19742, 19850, 19852, 19853, 19854, 25290, 27142,
    25894, 25918, 27143,
  },
  kings = {
    20217, 25898,
  },
  salvation = {
    1038, 25895,
  },
}

local COLUMNS = {
  { key = "food", label = "Food", shortLabel = "Food", width = 64, visibleSetting = "showFoodColumn" },
  { key = "flask", label = "Flask / Elixir", shortLabel = "F/E", width = 58, visibleSetting = "showFlaskColumn", flaskElixirs = true },
  { key = "scrolls", label = "Scroll", shortLabel = "Scroll", width = 48, visibleSetting = "showScrollsColumn" },
  { key = "motw", label = "Mark of the Wild (MotW)", shortLabel = "MotW", width = 48, visibleSetting = "showMotwColumn" },
  { key = "intellect", label = "Intellect", shortLabel = "Int", width = 46, visibleSetting = "showIntellectColumn" },
  { key = "attackPower", label = "Attack Power", shortLabel = "AP", width = 42, visibleSetting = "showAttackPowerColumn" },
  { key = "stamina", label = "Stamina", shortLabel = "Stam", width = 48, visibleSetting = "showStaminaColumn" },
  { key = "spirit", label = "Spirit", shortLabel = "Spirit", width = 46, visibleSetting = "showSpiritColumn" },
  { key = "armor", label = "Armor", shortLabel = "Armor", width = 48, visibleSetting = "showArmorColumn" },
  { key = "shadow", label = "Shadow Protection", shortLabel = "Shadow", width = 54, visibleSetting = "showShadowColumn" },
  { key = "might", label = "Blessing of Might", shortLabel = "Might", width = 46, visibleSetting = "showMightColumn" },
  { key = "wisdom", label = "Blessing of Wisdom", shortLabel = "Wis", width = 48, visibleSetting = "showWisdomColumn" },
  { key = "kings", label = "Blessing of Kings", shortLabel = "Kings", width = 46, visibleSetting = "showKingsColumn" },
  { key = "salvation", label = "Blessing of Salvation", shortLabel = "Salv", width = 46, visibleSetting = "showSalvationColumn" },
  { key = "durability", label = "Durability", shortLabel = "Dur", width = 48, visibleSetting = "showDurabilityColumn", durability = true },
  { key = "merfinPlus", label = "Merfin Plus", shortLabel = "MP", width = 66, visibleSetting = "showMerfinPlusColumn", version = true },
  { key = "t5", label = "T5", shortLabel = "T5", width = 76, visibleSetting = "showT5Column", t5Version = true },
  { key = "t6", label = "T6", shortLabel = "T6", width = 76, visibleSetting = "showT6Column", t6Version = true },
  { key = "t6a", label = "T6 Assignments", shortLabel = "T6A", width = 76, visibleSetting = "showT6AColumn", t6AVersion = true },
}

MerfinPlus.READY_CHECK_COLUMNS = COLUMNS

local OPTION_ICONS = {
  food = 136000,
  flask = "Interface\\Icons\\INV_Potion_41",
  scrolls = 134937,
  motw = "Interface\\Icons\\Spell_Nature_Regeneration",
  intellect = "Interface\\Icons\\Spell_Holy_MagicalSentry",
  attackPower = "Interface\\Icons\\Ability_Warrior_BattleShout",
  stamina = "Interface\\Icons\\Spell_Holy_WordFortitude",
  spirit = "Interface\\Icons\\Spell_Holy_DivineSpirit",
  armor = "Interface\\Icons\\Spell_Holy_DevotionAura",
  shadow = "Interface\\Icons\\Spell_Shadow_AntiShadow",
  might = "Interface\\Icons\\Spell_Holy_FistOfJustice",
  wisdom = "Interface\\Icons\\Spell_Holy_SealOfWisdom",
  kings = "Interface\\Icons\\Spell_Magic_MageArmor",
  salvation = "Interface\\Icons\\Spell_Holy_SealOfSalvation",
  durability = "Interface\\Icons\\Trade_BlackSmithing",
  merfinPlus = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\merfinui_logo_2",
  t5 = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\raid\\t5raid.png",
  t6 = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\raid\\t6raid.png",
  t6a = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\raid\\assignmentsraid.png",
}
MerfinPlus.READY_CHECK_OPTION_ICONS = OPTION_ICONS

local function IconLabel(key, label)
  local texture = OPTION_ICONS[key]
  return texture and string.format("|T%s:18:18:0:0|t %s", texture, MerfinPlus:T(label)) or MerfinPlus:T(label)
end

local AURA_CATEGORY_KEYS = {
  "food",
  "flask",
  "battleElixir",
  "guardianElixir",
  "scrolls",
  "motw",
  "intellect",
  "attackPower",
  "stamina",
  "spirit",
  "armor",
  "shadow",
  "might",
  "wisdom",
  "kings",
  "salvation",
}

local REPORT_CATEGORIES = {
  { reportSetting = "reportFood", label = "Food", auraKey = "food" },
  { reportSetting = "reportFlask", label = "Flask / Elixir", flaskElixirs = true },
  { reportSetting = "reportScrolls", label = "Scroll", auraKey = "scrolls" },
  { reportSetting = "reportMotw", label = "MotW", auraKey = "motw" },
  { reportSetting = "reportIntellect", label = "Intellect", auraKey = "intellect" },
  { reportSetting = "reportAttackPower", label = "Attack Power", auraKey = "attackPower" },
  { reportSetting = "reportStamina", label = "Stamina", auraKey = "stamina" },
  { reportSetting = "reportSpirit", label = "Spirit", auraKey = "spirit" },
  { reportSetting = "reportArmor", label = "Armor", auraKey = "armor" },
  { reportSetting = "reportShadow", label = "Shadow Protection", auraKey = "shadow" },
  { reportSetting = "reportMight", label = "Blessing of Might", auraKey = "might" },
  { reportSetting = "reportWisdom", label = "Blessing of Wisdom", auraKey = "wisdom" },
  { reportSetting = "reportKings", label = "Blessing of Kings", auraKey = "kings" },
  { reportSetting = "reportSalvation", label = "Blessing of Salvation", auraKey = "salvation" },
}

local STATUS_TEXTURES = {
  waiting = READY_CHECK_WAITING_TEXTURE or "Interface\\RaidFrame\\ReadyCheck-Waiting",
  ready = READY_CHECK_READY_TEXTURE or "Interface\\RaidFrame\\ReadyCheck-Ready",
  notready = READY_CHECK_NOT_READY_TEXTURE or "Interface\\RaidFrame\\ReadyCheck-NotReady",
}

local SPELL_CATEGORY_BY_ID = {}
local SPELL_CATEGORY_BY_NAME = {}

local function Clamp(value, minimum, maximum)
  value = tonumber(value) or minimum
  if value < minimum then
    return minimum
  elseif value > maximum then
    return maximum
  end
  return value
end

local function Round(value)
  return math.floor((tonumber(value) or 0) + 0.5)
end

local function GetCanonicalAddonVersion()
  local getter = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
  if not getter then
    return "unknown"
  end

  local ok, version = pcall(getter, "MerfinPlus", "Version")
  version = ok and tostring(version or "") or ""
  version = version:match("^%s*(.-)%s*$") or ""
  return version ~= "" and version or "unknown"
end

local function EncodeAddonVersion(version)
  version = tostring(version or "unknown")
  version = version:gsub("[^%w%._%+%-@]", ""):sub(1, 32)
  return version ~= "" and version or "unknown"
end

local function NormalizeReportedVersion(version)
  version = tostring(version or ""):match("^%s*(.-)%s*$") or ""
  if version == "" or version == "unknown" or #version > 32 or version:find("[^%w%._%+%-@]") then
    return nil
  end
  return version
end

local function EncodePackVersion(version)
  local normalized = NormalizeReportedVersion(version)
  return normalized and EncodeAddonVersion(normalized) or "x"
end

local function DecodePackVersion(token)
  if token == "x" then return nil end
  return NormalizeReportedVersion(token)
end

local function FormatAddonVersion(version)
  version = tostring(version or "")
  if version == "" then
    return "?"
  end
  if version:match("^[vV]") or not version:match("^%d") then
    return version
  end
  return "v" .. version
end

local function ResolveReadyCheckFont()
  if LSM then
    local ok, font = pcall(LSM.Fetch, LSM, "font", "Merfin Font 1", true)
    if ok and type(font) == "string" and font ~= "" then
      return font
    end
  end
  if GameFontNormal and GameFontNormal.GetFont then
    local font = GameFontNormal:GetFont()
    if type(font) == "string" and font ~= "" then
      return font
    end
  end
  if type(STANDARD_TEXT_FONT) == "string" and STANDARD_TEXT_FONT ~= "" then
    return STANDARD_TEXT_FONT
  end
  return "Fonts\\FRIZQT__.TTF"
end

local function ApplyReadyCheckFont(fontString, size, flags)
  if not fontString then
    return false
  end

  local candidates = {
    ResolveReadyCheckFont(),
    type(STANDARD_TEXT_FONT) == "string" and STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",
    "Fonts\\FRIZQT__.TTF",
  }
  local attempted = {}
  for _, font in ipairs(candidates) do
    if font and not attempted[font] then
      attempted[font] = true
      local ok = pcall(fontString.SetFont, fontString, font, size or 12, flags or "OUTLINE")
      local currentFont = fontString:GetFont()
      if ok and currentFont then
        return true
      end
    end
  end
  return false
end

local function NormalizeName(name)
  name = tostring(name or "")
  if Ambiguate and name ~= "" then
    local ok, shortName = pcall(Ambiguate, name, "short")
    if ok and shortName and shortName ~= "" then
      name = shortName
    end
  end
  name = name:match("^[^-]+") or name
  return string.lower(name)
end

local function DisplayName(name)
  name = tostring(name or UNKNOWN or "Unknown")
  if Ambiguate then
    local ok, shortName = pcall(Ambiguate, name, "short")
    if ok and shortName and shortName ~= "" then
      return shortName
    end
  end
  return name:match("^[^-]+") or name
end

local function GetUnitFullName(unit)
  local name, realm = UnitName(unit)
  if not name then
    return nil
  end
  if realm and realm ~= "" then
    return name .. "-" .. realm
  end
  return name
end

local function ResolveReadyCheckName(nameOrUnit)
  if type(nameOrUnit) ~= "string" or nameOrUnit == "" then
    return nil
  end
  if UnitExists and UnitExists(nameOrUnit) then
    return GetUnitFullName(nameOrUnit)
  end
  return nameOrUnit
end

local function GetGroupChannel()
  if LE_PARTY_CATEGORY_INSTANCE and IsInGroup and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
    return "INSTANCE_CHAT"
  end
  if IsInRaid and IsInRaid() then
    return "RAID"
  end
  if IsInGroup and IsInGroup() then
    return "PARTY"
  end
  return nil
end

local function IsPlayerGroupLeader()
  if UnitIsGroupLeader then
    return UnitIsGroupLeader("player") and true or false
  end
  if IsRaidLeader and IsRaidLeader() then
    return true
  end
  return UnitIsPartyLeader and UnitIsPartyLeader("player") and true or false
end

local function IsPlayerGroupAssistant()
  if UnitIsGroupAssistant then
    return UnitIsGroupAssistant("player") and true or false
  end
  return IsRaidOfficer and IsRaidOfficer() and not IsPlayerGroupLeader() or false
end

local function AddGroupUnits(target)
  if IsInRaid and IsInRaid() then
    local count = GetNumGroupMembers and GetNumGroupMembers() or (GetNumRaidMembers and GetNumRaidMembers()) or 0
    for index = 1, count do
      target[#target + 1] = "raid" .. index
    end
    return
  end

  if IsInGroup and IsInGroup() then
    target[#target + 1] = "player"
    local count = GetNumSubgroupMembers and GetNumSubgroupMembers()
      or (GetNumPartyMembers and GetNumPartyMembers())
      or 0
    for index = 1, count do
      target[#target + 1] = "party" .. index
    end
  end
end

local function IsSenderInGroup(sender)
  local senderKey = NormalizeName(sender)
  if senderKey == "" then
    return false
  end

  local units = {}
  AddGroupUnits(units)
  for _, unit in ipairs(units) do
    if UnitExists(unit) and NormalizeName(GetUnitFullName(unit)) == senderKey then
      return true
    end
  end
  return false
end

local function SendReadyCheckAddonMessage(prefix, message, distribution, target, queueName)
  if not prefix or not message or not distribution then
    return false
  end

  local sender
  if ChatThrottleLib and ChatThrottleLib.SendAddonMessage then
    sender = function()
      return ChatThrottleLib:SendAddonMessage(
        "ALERT",
        prefix,
        message,
        distribution,
        target,
        queueName
      )
    end
  elseif C_ChatInfo and C_ChatInfo.SendAddonMessage then
    sender = function()
      return C_ChatInfo.SendAddonMessage(prefix, message, distribution, target)
    end
  elseif SendAddonMessage then
    sender = function()
      return SendAddonMessage(prefix, message, distribution, target)
    end
  end

  if not sender then return false end
  local ok, result = pcall(sender)
  return ok == true and result ~= false
end

local function SendAddonPayload(message, distribution, target)
  return SendReadyCheckAddonMessage(ADDON_PREFIX, message, distribution, target, "MFP-RC")
end

local function SendGroupChat(message)
  local channel = GetGroupChannel()
  if not channel or not message or message == "" then
    return false
  end

  local sender = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
  if not sender then
    return false
  end

  local ok = pcall(sender, message, channel)
  return ok
end

local function CalculateLocalDurability()
  if not GetInventoryItemDurability then
    return nil
  end

  local minimumBasisPoints
  for slot = 1, 18 do
    local current, maximum = GetInventoryItemDurability(slot)
    if current and maximum and maximum > 0 then
      local basisPoints = math.floor((current / maximum) * DURABILITY_MAX_BASIS_POINTS)
      minimumBasisPoints = minimumBasisPoints and math.min(minimumBasisPoints, basisPoints) or basisPoints
    end
  end

  return minimumBasisPoints and Clamp(minimumBasisPoints, 0, DURABILITY_MAX_BASIS_POINTS) or nil
end

local function GetAuraData(unit, index)
  if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
    local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, "HELPFUL")
    if aura then
      return {
        name = aura.name,
        icon = aura.icon,
        applications = aura.applications or 0,
        duration = aura.duration or 0,
        expirationTime = aura.expirationTime or 0,
        spellId = aura.spellId,
      }
    end
    return nil
  end

  if not UnitBuff then
    return nil
  end
  local name, icon, applications, _, duration, expirationTime, _, _, _, spellId = UnitBuff(unit, index)
  if not name then
    return nil
  end
  return {
    name = name,
    icon = icon,
    applications = applications or 0,
    duration = duration or 0,
    expirationTime = expirationTime or 0,
    spellId = spellId,
  }
end

local function AuraRemaining(aura, now)
  if not aura or not aura.expirationTime or aura.expirationTime <= 0 then
    return math.huge
  end
  return math.max(0, aura.expirationTime - now)
end

local function ScanUnitAuras(unit)
  local found = {}
  local matchesByCategory = {}
  local now = GetTime()

  for index = 1, 80 do
    local aura = GetAuraData(unit, index)
    if not aura then
      break
    end

    local category = aura.spellId and SPELL_CATEGORY_BY_ID[aura.spellId]
      or (aura.name and SPELL_CATEGORY_BY_NAME[aura.name])
    if category then
      matchesByCategory[category] = matchesByCategory[category] or {}
      matchesByCategory[category][#matchesByCategory[category] + 1] = aura
      local previous = found[category]
      if not previous or AuraRemaining(aura, now) < AuraRemaining(previous, now) then
        found[category] = aura
      end
    end
  end

  for category, matches in pairs(matchesByCategory) do
    table.sort(matches, function(left, right)
      local leftName = string.lower(tostring(left.name or ""))
      local rightName = string.lower(tostring(right.name or ""))
      if leftName ~= rightName then
        return leftName < rightName
      end
      local leftID = tonumber(left.spellId) or 0
      local rightID = tonumber(right.spellId) or 0
      if leftID ~= rightID then
        return leftID < rightID
      end
      return AuraRemaining(left, now) < AuraRemaining(right, now)
    end)
    found[category].matchedCount = #matches
  end
  found.matchesByCategory = matchesByCategory
  return found
end

local function SendT5Payload(message, distribution, target)
  return SendReadyCheckAddonMessage(T5_PREFIX, message, distribution, target, "MFP-RC-PACK")
end

local function GetWeakAuraVersion(data)
  if type(data) == "table" and data.semver and data.semver ~= "" then
    return tostring(data.semver)
  end
end

local function GetLocalT5Version()
  local ids = { "[T5] Core", "[T5] MerfinPlus Check" }
  if WeakAuras and WeakAuras.GetData then
    for _, id in ipairs(ids) do
      local version = GetWeakAuraVersion(WeakAuras.GetData(id))
      if version then return version end
    end
  end
  local displays = WeakAurasSaved and WeakAurasSaved.displays
  if type(displays) ~= "table" then return nil end
  for _, id in ipairs(ids) do
    local version = GetWeakAuraVersion(displays[id])
    if version then return version end
  end
  for _, data in pairs(displays) do
    if type(data) == "table" and (
      data.wagoID == "1qyg9npGm"
      or (type(data.url) == "string" and data.url:find("wago.io/merfin_t5", 1, true))
      or data.id == "[T5] Core"
      or data.parent == "[T5] Core"
    ) then
      local version = GetWeakAuraVersion(data)
      if version then return version end
    end
  end
end

local function GetLocalT6Version()
  local rootID = "[Merfin] T6"
  local coreID = "[T6] Core"
  local checkID = "[T6] MerfinPlus Check"
  local officialWagoID = "-NQSiwrk8"
  local directMerfinUID = "MUIX1226"
  local minimumMerfinRevision = 2

  local savedDisplays = WeakAurasSaved and WeakAurasSaved.displays
  local function GetDisplay(id)
    if WeakAuras and WeakAuras.GetData then
      local data = WeakAuras.GetData(id)
      if type(data) == "table" then return data end
    end
    if type(savedDisplays) == "table" and type(savedDisplays[id]) == "table" then
      return savedDisplays[id]
    end
  end

  local root = GetDisplay(rootID)
  local core = GetDisplay(coreID)
  local check = GetDisplay(checkID)
  if not root or not core or not check
    or root.id ~= rootID
    or core.id ~= coreID
    or core.parent ~= rootID
    or check.id ~= checkID
    or check.parent ~= coreID
  then
    return nil
  end

  local function HasConflictingWagoIdentity(data)
    return type(data.wagoID) == "string"
      and data.wagoID ~= ""
      and data.wagoID ~= officialWagoID
  end

  local hasOfficialWagoIdentity = root.wagoID == officialWagoID
    or core.wagoID == officialWagoID
    or check.wagoID == officialWagoID
  local hasConflictingWagoIdentity = HasConflictingWagoIdentity(root)
    or HasConflictingWagoIdentity(core)
    or HasConflictingWagoIdentity(check)

  local description = type(root.desc) == "string" and root.desc or ""
  local embeddedUID = description:match("MerfinUID:%s*([%w_-]+)")
  local embeddedRevision = tonumber(description:match("MerfinRev:%s*(%d+)"))
  local hasDirectIdentity = embeddedUID == directMerfinUID
    and embeddedRevision ~= nil
    and embeddedRevision >= minimumMerfinRevision

  if hasConflictingWagoIdentity or (not hasOfficialWagoIdentity and not hasDirectIdentity) then
    return nil
  end

  return GetWeakAuraVersion(check)
    or GetWeakAuraVersion(core)
    or GetWeakAuraVersion(root)
end

local function GetLocalT6AssignmentsVersion()
  local rootID = "[Merfin] T6 Assigns"
  local officialWagoID = "ueFpAzV3e"
  local directMerfinUID = "MUIX1228"
  local minimumMerfinRevision = 1

  local data
  if WeakAuras and WeakAuras.GetData then
    data = WeakAuras.GetData(rootID)
  end
  if type(data) ~= "table" then
    local displays = WeakAurasSaved and WeakAurasSaved.displays
    data = type(displays) == "table" and displays[rootID] or nil
  end
  if type(data) ~= "table" or data.id ~= rootID then
    return nil
  end

  local description = type(data.desc) == "string" and data.desc or ""
  local embeddedUID = description:match("MerfinUID:%s*([%w_-]+)")
  local embeddedRevision = tonumber(description:match("MerfinRev:%s*(%d+)"))
  local hasDirectIdentity = embeddedUID == directMerfinUID
    and embeddedRevision ~= nil
    and embeddedRevision >= minimumMerfinRevision

  local url = type(data.url) == "string" and string.lower(data.url) or ""
  local hasOfficialWagoIdentity = data.wagoID == officialWagoID
    or url:find("wago.io/t6_assigns", 1, true) ~= nil

  if not hasDirectIdentity and not hasOfficialWagoIdentity then
    return nil
  end

  return GetWeakAuraVersion(data)
    or (data.version and tostring(data.version))
    or (embeddedRevision and tostring(embeddedRevision))
end

local function RequestRaidPackVersions()
  local channel = GetGroupChannel()
  if channel then
    SendT5Payload("REQ:" .. T5_PACK_KEY, channel)
    SendT5Payload("REQ:" .. T6_PACK_KEY, channel)
    SendT5Payload("REQ:" .. T6_ASSIGNMENTS_PACK_KEY, channel)
  end
end

local function RequestMissingRaidPackVersions(owner)
  local frame = owner and owner.readyCheckFrame
  for _, member in ipairs(frame and frame.members or {}) do
    local target = member.fullName or GetUnitFullName(member.unit)
    local connected = not UnitIsConnected or UnitIsConnected(member.unit) ~= false
    if connected and target and NormalizeName(target) ~= NormalizeName(GetUnitFullName("player")) then
      local key = member.nameKey
      if owner.readyCheckNonce
        and not (owner.readyCheckVersionResponded and owner.readyCheckVersionResponded[key])
      then
        SendAddonPayload("Q:" .. owner.readyCheckNonce, "WHISPER", target)
      end
      if not (owner.readyCheckT5Responded and owner.readyCheckT5Responded[key]) then
        SendT5Payload("REQ:" .. T5_PACK_KEY, "WHISPER", target)
      end
      if not (owner.readyCheckT6Responded and owner.readyCheckT6Responded[key]) then
        SendT5Payload("REQ:" .. T6_PACK_KEY, "WHISPER", target)
      end
      if not (owner.readyCheckT6AResponded and owner.readyCheckT6AResponded[key]) then
        SendT5Payload("REQ:" .. T6_ASSIGNMENTS_PACK_KEY, "WHISPER", target)
      end
    end
  end
end

local function ReadyCheckAuraSignature(auras)
  local parts = {}
  local now = GetTime()
  for _, category in ipairs(AURA_CATEGORY_KEYS) do
    local aura = auras and auras[category]
    if aura then
      local matches = auras.matchesByCategory and auras.matchesByCategory[category]
        or { aura }
      for _, matchedAura in ipairs(matches) do
        parts[#parts + 1] = table.concat({
          category,
          tostring(matchedAura.spellId or matchedAura.name or ""),
          tostring(matchedAura.name or ""),
          tostring(matchedAura.icon or ""),
          tostring(matchedAura.applications or 0),
          tostring(matchedAura.expirationTime or 0),
          AuraRemaining(matchedAura, now) <= EXPIRING_SECONDS and "expiring" or "lasting",
        }, ":")
      end
    end
  end
  return table.concat(parts, "|")
end

local function GetFlaskElixirState(auras)
  if not auras then
    return nil
  end

  if auras.flask then
    return {
      kind = "flask",
      remaining = AuraRemaining(auras.flask, GetTime()),
      entries = {
        { label = "Flask", aura = auras.flask },
      },
    }
  end

  local entries = {}
  if auras.battleElixir then
    entries[#entries + 1] = { label = "Battle Elixir", aura = auras.battleElixir }
  end
  if auras.guardianElixir then
    entries[#entries + 1] = { label = "Guardian Elixir", aura = auras.guardianElixir }
  end
  if #entries == 0 then
    return nil
  end

  local remaining = math.huge
  for _, entry in ipairs(entries) do
    remaining = math.min(remaining, AuraRemaining(entry.aura, GetTime()))
  end
  return {
    kind = #entries == 2 and "bothElixirs"
      or (auras.battleElixir and "battleElixir" or "guardianElixir"),
    remaining = remaining,
    entries = entries,
  }
end

local function SetBorderColor(widget, red, green, blue, alpha)
  for _, texture in ipairs(widget.borderTextures or {}) do
    texture:SetColorTexture(red, green, blue, alpha or 1)
  end
end

local function AddBorderTextures(widget, thickness)
  thickness = thickness or 1
  widget.borderTextures = {}

  local top = widget:CreateTexture(nil, "BORDER")
  top:SetPoint("TOPLEFT")
  top:SetPoint("TOPRIGHT")
  top:SetHeight(thickness)
  widget.borderTextures[#widget.borderTextures + 1] = top

  local bottom = widget:CreateTexture(nil, "BORDER")
  bottom:SetPoint("BOTTOMLEFT")
  bottom:SetPoint("BOTTOMRIGHT")
  bottom:SetHeight(thickness)
  widget.borderTextures[#widget.borderTextures + 1] = bottom

  local left = widget:CreateTexture(nil, "BORDER")
  left:SetPoint("TOPLEFT")
  left:SetPoint("BOTTOMLEFT")
  left:SetWidth(thickness)
  widget.borderTextures[#widget.borderTextures + 1] = left

  local right = widget:CreateTexture(nil, "BORDER")
  right:SetPoint("TOPRIGHT")
  right:SetPoint("BOTTOMRIGHT")
  right:SetWidth(thickness)
  widget.borderTextures[#widget.borderTextures + 1] = right
end

local function ShowReadyCheckTooltip(owner, title, description)
  if not GameTooltip then
    return
  end
  GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
  GameTooltip:SetText(title or "", theme.accentBright[1], theme.accentBright[2], theme.accentBright[3])
  if description and description ~= "" then
    GameTooltip:AddLine(description, 0.9, 0.9, 0.9, true)
  end
  GameTooltip:Show()
end

local function ShowReadyCheckAuraTooltip(owner, aura, categoryLabel)
  if not GameTooltip or not aura then
    return
  end
  GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
  GameTooltip:SetText(
    aura.name or MerfinPlus:T("Buff active"),
    theme.accentBright[1], theme.accentBright[2], theme.accentBright[3]
  )
  if categoryLabel and categoryLabel ~= "" then
    GameTooltip:AddLine(categoryLabel, 0.72, 0.72, 0.72)
  end
  local applications = tonumber(aura.applications) or 0
  if applications > 1 then
    GameTooltip:AddLine(MerfinPlus:T("Stacks: %d", applications), 0.9, 0.9, 0.9)
  end
  local remaining = AuraRemaining(aura, GetTime())
  if remaining ~= math.huge then
    GameTooltip:AddLine(
      MerfinPlus:T("Remaining: %d:%02d", math.floor(remaining / 60), math.floor(remaining % 60)),
      0.9,
      0.9,
      0.9
    )
  end
  GameTooltip:Show()
end

local function CreateHeaderCell(parent)
  local cell = CreateFrame("Frame", nil, parent)
  cell.text = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyReadyCheckFont(cell.text, 12, "OUTLINE")
  cell.text:SetPoint("CENTER")
  cell.text:SetJustifyH("CENTER")
  cell.text:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
  cell:EnableMouse(true)
  cell:SetScript("OnEnter", function(current)
    ShowReadyCheckTooltip(current, current.tooltipTitle, current.tooltipDescription)
  end)
  cell:SetScript("OnLeave", function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
  return cell
end

local function CreateAuraCell(parent)
  local cell = CreateFrame("Frame", nil, parent)
  cell.background = cell:CreateTexture(nil, "BACKGROUND")
  cell.background:SetAllPoints()
  cell.background:SetColorTexture(theme.surface[1], theme.surface[2], theme.surface[3], 0.75)

  cell.icon = cell:CreateTexture(nil, "ARTWORK")
  cell.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  cell.icon2 = cell:CreateTexture(nil, "ARTWORK")
  cell.icon2:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  cell.icon2:Hide()

  cell.expiringIcon = cell:CreateTexture(nil, "OVERLAY")
  cell.expiringIcon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
  cell.expiringIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  cell.expiringIcon:SetVertexColor(1, 0.68, 0.12, 1)
  cell.expiringIcon:Hide()

  cell.text = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyReadyCheckFont(cell.text, 10, "OUTLINE")
  cell.text:SetPoint("CENTER")
  cell.text:SetJustifyH("CENTER")

  AddBorderTextures(cell, 1)
  SetBorderColor(cell, theme.borderSoft[1], theme.borderSoft[2], theme.borderSoft[3], theme.borderSoft[4])

  cell:EnableMouse(true)
  cell:SetScript("OnEnter", function(current)
    if not GameTooltip then
      return
    end
    GameTooltip:SetOwner(current, "ANCHOR_RIGHT")
    GameTooltip:SetText(
      current.categoryLabel or "",
      theme.accentBright[1], theme.accentBright[2], theme.accentBright[3]
    )
    if current.auraGroup then
      for _, entry in ipairs(current.auraGroup) do
        local entryLabel = MerfinPlus:T(entry.label)
        if entry.aura then
          GameTooltip:AddLine(string.format("%s: %s", entryLabel, entry.aura.name or MerfinPlus:T("Buff active")), 1, 1, 1)
          local remaining = AuraRemaining(entry.aura, GetTime())
          if remaining ~= math.huge then
            GameTooltip:AddLine("  " .. MerfinPlus:T("Remaining: %d:%02d", math.floor(remaining / 60), math.floor(remaining % 60)), 0.9, 0.9, 0.9)
          end
        else
          GameTooltip:AddLine(MerfinPlus:T("%s: Missing", entryLabel), 1, 0.25, 0.25)
        end
      end
    elseif current.auraData then
      GameTooltip:AddLine(current.auraData.name or MerfinPlus:T("Buff active"), 1, 1, 1)
      local remaining = AuraRemaining(current.auraData, GetTime())
      if remaining ~= math.huge then
        GameTooltip:AddLine(MerfinPlus:T("Remaining: %d:%02d", math.floor(remaining / 60), math.floor(remaining % 60)), 0.9, 0.9, 0.9)
      end
    elseif current.usesAuraIconButtons then
      return
    elseif current.durabilityBasisPoints ~= nil then
      GameTooltip:AddLine(string.format("%.2f%%", current.durabilityBasisPoints / DURABILITY_BASIS_POINTS_PER_PERCENT), 1, 1, 1)
    elseif current.isOffline then
      GameTooltip:AddLine(MerfinPlus:T("Offline"), 0.60, 0.60, 0.60)
    elseif current.isT5Version or current.isT6Version or current.isT6AVersion then
      if not current.packResponded then
        GameTooltip:AddLine(MerfinPlus:T("Waiting for response..."), 0.72, 0.72, 0.72)
      else
        GameTooltip:AddLine(current.versionValue and MerfinPlus:T("Reported: %s", current.versionValue) or "Missing", current.versionValue and 0.4 or 1, current.versionValue and 1 or 0.25, 0.3)
      end
      if current.localVersion then GameTooltip:AddLine(MerfinPlus:T("Local: %s", current.localVersion), 0.75, 0.75, 0.75) end
    elseif current.isVersion then
      if current.versionValue then
        GameTooltip:AddLine(MerfinPlus:T("Reported: %s", current.versionValue), 1, 1, 1)
        GameTooltip:AddLine(MerfinPlus:T("Local: %s", current.localVersion or MerfinPlus:T("Unknown")), 0.75, 0.75, 0.75)
      else
        GameTooltip:AddLine(MerfinPlus:T("Unknown until the player responds with MerfinPlus."), 0.65, 0.65, 0.65)
      end
    else
      GameTooltip:AddLine(MerfinPlus:T(current.isDurability and "Unknown until the player responds." or "Missing"), 1, 0.25, 0.25)
    end
    if current.isExpiring then
      GameTooltip:AddLine(MerfinPlus:T("Expiring in 5 minutes or less."), 1, 0.55, 0.10)
    end
    GameTooltip:Show()
  end)
  cell:SetScript("OnLeave", function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
  return cell
end

local function CreateReadyCheckAuraIconButton(cell)
  local button = CreateFrame("Button", nil, cell)
  button.texture = button:CreateTexture(nil, "ARTWORK")
  button.texture:SetAllPoints()
  button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  button:SetScript("OnEnter", function(current)
    ShowReadyCheckAuraTooltip(current, current.auraData, current.categoryLabel)
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
  button:SetScript("OnHide", function()
    if GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(button) then
      GameTooltip:Hide()
    end
  end)
  button:Hide()
  return button
end

local function SetReadyCheckAuraIconButtons(cell, auras, categoryLabel)
  cell.auraIconButtons = cell.auraIconButtons or {}
  local count = type(auras) == "table" and #auras or 0
  for index = 1, count do
    local button = cell.auraIconButtons[index]
    if not button then
      button = CreateReadyCheckAuraIconButton(cell)
      cell.auraIconButtons[index] = button
    end
    local aura = auras[index]
    button.auraData = aura
    button.categoryLabel = categoryLabel
    button.texture:SetTexture(aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    button.texture:SetVertexColor(1, 1, 1, 1)
    button:Show()
  end
  for index = count + 1, #cell.auraIconButtons do
    local button = cell.auraIconButtons[index]
    button.auraData = nil
    button.categoryLabel = nil
    button:Hide()
  end
  cell.usesAuraIconButtons = count > 0
end

local function LayoutReadyCheckCellIcons(cell, rowHeight, scale)
  if not cell then
    return
  end
  rowHeight = tonumber(rowHeight) or 19
  scale = tonumber(scale) or 1
  local cellWidth = cell:GetWidth()
  local iconSize = math.max(9, math.min(rowHeight - 6, 14 * scale, cellWidth - 4))

  if cell.isT5Version or cell.isT6Version or cell.isT6AVersion then
    cell.icon:ClearAllPoints()
    cell.icon:SetPoint("CENTER", cell, "CENTER", 0, 0)
    cell.icon:SetSize(iconSize, iconSize)
    cell.icon2:Hide()
    cell.expiringIcon:Hide()
    return
  end

  if cell.usesAuraIconButtons then
    local visibleButtons = {}
    for _, button in ipairs(cell.auraIconButtons or {}) do
      if button:IsShown() then
        visibleButtons[#visibleButtons + 1] = button
      end
    end
    local showExpiringIcon = cell.expiringIcon:IsShown()
    local visualCount = #visibleButtons + (showExpiringIcon and 1 or 0)
    local availableWidth = math.max(1, cellWidth - (4 * scale))
    if visualCount > 0 then
      local gap = visualCount > 1
        and math.min(math.max(1, 2 * scale), availableWidth / (visualCount * 3))
        or 0
      iconSize = math.max(
        0.5,
        math.min(iconSize, (availableWidth - ((visualCount - 1) * gap)) / visualCount)
      )
      local totalWidth = (visualCount * iconSize) + ((visualCount - 1) * gap)
      local x = -totalWidth / 2
      for _, button in ipairs(visibleButtons) do
        button:ClearAllPoints()
        button:SetPoint("LEFT", cell, "CENTER", x, 0)
        button:SetSize(iconSize, iconSize)
        x = x + iconSize + gap
      end
      cell.expiringIcon:ClearAllPoints()
      if showExpiringIcon then
        local expiringIconSize = math.max(5, math.min(iconSize * 0.7, 10 * scale))
        cell.expiringIcon:SetPoint("LEFT", cell, "CENTER", x + ((iconSize - expiringIconSize) / 2), 0)
        cell.expiringIcon:SetSize(expiringIconSize, expiringIconSize)
      else
        cell.expiringIcon:SetPoint("CENTER")
      end
    end
    cell.icon:Hide()
    cell.icon2:Hide()
    return
  end

  cell.icon:ClearAllPoints()
  cell.icon2:ClearAllPoints()
  cell.expiringIcon:ClearAllPoints()
  local showSecondIcon = cell.icon2:IsShown()
  local showExpiringIcon = cell.expiringIcon:IsShown()
  if showSecondIcon and showExpiringIcon then
    iconSize = math.max(7, math.min(iconSize, (cellWidth - 8) / 3))
    cell.icon:SetPoint("RIGHT", cell, "CENTER", -((iconSize / 2) + 1), 0)
    cell.icon2:SetPoint("CENTER", cell, "CENTER", 0, 0)
    cell.expiringIcon:SetPoint("LEFT", cell, "CENTER", (iconSize / 2) + 2, 0)
  elseif showSecondIcon then
    iconSize = math.max(8, math.min(iconSize, (cellWidth - 5) / 2))
    cell.icon:SetPoint("RIGHT", cell, "CENTER", -1, 0)
    cell.icon2:SetPoint("LEFT", cell, "CENTER", 1, 0)
    cell.expiringIcon:SetPoint("CENTER")
  elseif showExpiringIcon then
    iconSize = math.max(8, math.min(iconSize, (cellWidth - 5) / 2))
    cell.icon:SetPoint("RIGHT", cell, "CENTER", -1, 0)
    cell.icon2:SetPoint("CENTER")
    cell.expiringIcon:SetPoint("LEFT", cell, "CENTER", 2, 0)
  else
    cell.icon:SetPoint("CENTER")
    cell.icon2:SetPoint("CENTER")
    cell.expiringIcon:SetPoint("CENTER")
  end
  cell.icon:SetSize(iconSize, iconSize)
  cell.icon2:SetSize(iconSize, iconSize)
  local expiringIconSize = math.max(7, math.min(iconSize * 0.7, 10 * scale))
  cell.expiringIcon:SetSize(expiringIconSize, expiringIconSize)
end

local function CreateReadyCheckRow(parent)
  local row = CreateFrame("Frame", nil, parent)
  row.background = row:CreateTexture(nil, "BACKGROUND")
  row.background:SetAllPoints()

  row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyReadyCheckFont(row.nameText, 12, "OUTLINE")
  row.nameText:SetJustifyH("LEFT")
  row.nameText:SetTextColor(1, 1, 1, 1)

  row.statusIcon = row:CreateTexture(nil, "ARTWORK")
  row.statusIcon:SetTexCoord(0, 1, 0, 1)

  row.statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyReadyCheckFont(row.statusText, 9, "OUTLINE")
  row.statusText:SetJustifyH("CENTER")
  row.statusText:SetText("OFF")
  row.statusText:SetTextColor(0.58, 0.58, 0.58, 1)
  row.statusText:Hide()

  row.cells = {}
  for index, column in ipairs(COLUMNS) do
    local cell = CreateAuraCell(row)
    cell.categoryLabel = column.label
    cell.isDurability = column.durability and true or false
    cell.isVersion = column.version and true or false
    cell.isT5Version = column.t5Version and true or false
    cell.isT6Version = column.t6Version and true or false
    cell.isT6AVersion = column.t6AVersion and true or false
    row.cells[index] = cell
  end
  return row
end

local function MigrateReadyCheckSettings(settings)
  local legacyReportFoodFlask = rawget(settings, "reportFoodFlask")
  if legacyReportFoodFlask ~= nil then
    if rawget(settings, "reportFood") == nil then
      settings.reportFood = legacyReportFoodFlask and true or false
    end
    if rawget(settings, "reportFlask") == nil then
      settings.reportFlask = legacyReportFoodFlask and true or false
    end
    settings.reportFoodFlask = nil
  end
end

local function GetVisibleReadyCheckColumns(settings)
  local visibleColumns = {}
  for index, column in ipairs(COLUMNS) do
    if settings[column.visibleSetting] then
      visibleColumns[#visibleColumns + 1] = {
        index = index,
        column = column,
      }
    end
  end
  return visibleColumns
end

function MerfinPlus:GetReadyCheckSettings()
  local profile = self.db and self.db.profile
  if not profile then
    return READY_CHECK_DEFAULTS
  end

  if type(profile.readyCheck) ~= "table" then
    profile.readyCheck = {}
  end
  local settings = profile.readyCheck
  MigrateReadyCheckSettings(settings)
  for key, defaultValue in pairs(READY_CHECK_DEFAULTS) do
    if settings[key] == nil then
      settings[key] = defaultValue
    end
  end

  settings.displayDuration = Clamp(Round(settings.displayDuration), 5, 60)
  settings.fontSize = Clamp(Round(settings.fontSize), 8, 24)
  settings.windowWidth = Clamp(Round(settings.windowWidth), MIN_WIDTH, MAX_WIDTH)
  settings.windowHeight = Clamp(Round(settings.windowHeight), MIN_HEIGHT, MAX_HEIGHT)
  settings.windowX = tonumber(settings.windowX) or 0
  settings.windowY = tonumber(settings.windowY) or 0
  return settings
end

function MerfinPlus:IsReadyCheckDisplayAllowed()
  local settings = self:GetReadyCheckSettings()
  if not settings.enabled then
    return false
  end

  local leaderGate = settings.leaderOnly and true or false
  local assistantGate = settings.assistantOnly and true or false
  if not leaderGate and not assistantGate then
    return true
  end

  return (leaderGate and IsPlayerGroupLeader())
    or (assistantGate and IsPlayerGroupAssistant())
    or false
end

function MerfinPlus:SetReadyCheckSetting(key, value)
  local settings = self:GetReadyCheckSettings()
  if key == "displayDuration" then
    value = Clamp(Round(value), 5, 60)
  elseif key == "fontSize" then
    value = Clamp(Round(value), 8, 24)
  else
    value = value and true or false
  end
  settings[key] = value

  if self.RefreshReadyCheckPreviewWidgets
    and type(key) == "string"
    and key:match("^show.+Column$")
  then
    self:RefreshReadyCheckPreviewWidgets()
  end

  if key == "enabled" and not value then
    self.readyCheckActive = false
    if self.readyCheckFrame then
      self.readyCheckFrame:Hide()
    end
  elseif self.readyCheckFrame and self.readyCheckFrame:IsShown() then
    self:RefreshReadyCheckWindow()
  end
end

function MerfinPlus:BuildReadyCheckOptions()
  return {
    type = "group",
    name = self:T("Ready Check"),
    get = function(info)
      return MerfinPlus:GetReadyCheckSettings()[info[#info]]
    end,
    set = function(info, value)
      MerfinPlus:SetReadyCheckSetting(info[#info], value)
    end,
    args = {
      header = {
        type = "header",
        name = self:T("Ready Check"),
        order = 0,
      },
      description = {
        type = "description",
        name = self:T("Shows a movable and resizable raid status window when a Blizzard ready check begins."),
        order = 1,
        width = "full",
      },
      enabled = {
        type = "toggle",
        name = self:T("Enable"),
        order = 2,
        width = 1.5,
      },
      enableSlashMerfinRT = {
        type = "toggle",
        name = self:T("Enable use /merfinrt"),
        desc = self:T("Allows /merfinrt to open a manual roster check without starting a Blizzard Ready Check."),
        order = 2.5,
        width = 1.5,
      },
      leaderOnly = {
        type = "toggle",
        name = self:T("Enable only while group leader"),
        desc = self:T("When both role restrictions are selected, either group leader or assistant is allowed."),
        order = 3,
        width = 1.5,
      },
      assistantOnly = {
        type = "toggle",
        name = self:T("Enable only while assistant"),
        desc = self:T("When both role restrictions are selected, either group leader or assistant is allowed."),
        order = 4,
        width = 1.5,
      },
      displayDuration = {
        type = "range",
        name = self:T("Display Duration"),
        desc = self:T("Seconds to keep the window visible from the moment the ready check starts."),
        order = 5,
        min = 5,
        max = 60,
        step = 1,
        width = "full",
      },
      fontSize = {
        type = "range",
        name = self:T("Font Size"),
        desc = self:T("Controls Ready Check text size independently of window resizing."),
        order = 6,
        min = 8,
        max = 24,
        step = 1,
        width = "full",
      },
      sortByName = {
        type = "toggle",
        name = self:T("Sort by Name"),
        order = 7,
        width = 1.5,
      },
      sortByClass = {
        type = "toggle",
        name = self:T("Sort by Class"),
        order = 8,
        width = 1.5,
      },
      showExpiring = {
        type = "toggle",
        name = self:T("Show Expiring Buffs, Food and Flask"),
        desc = self:T("Highlights every tracked aura with 5 minutes or less remaining using an orange cell and hourglass."),
        order = 9,
        width = "full",
      },
      reportHeader = {
        type = "header",
        name = self:T("Report in Chat:"),
        order = 10,
      },
      reportFood = {
        type = "toggle",
        name = function() return IconLabel("food", "Food") end,
        order = 11,
        width = 1.0,
      },
      reportFlask = {
        type = "toggle",
        name = function() return IconLabel("flask", "Flask / Elixir") end,
        order = 12,
        width = 1.0,
      },
      reportScrolls = {
        type = "toggle",
        name = function() return IconLabel("scrolls", "Scroll") end,
        order = 13,
        width = 1.0,
      },
      reportMotw = {
        type = "toggle",
        name = function() return IconLabel("motw", "MotW") end,
        order = 14,
        width = 1.0,
      },
      reportIntellect = {
        type = "toggle",
        name = function() return IconLabel("intellect", "Intellect") end,
        order = 15,
        width = 1.0,
      },
      reportAttackPower = {
        type = "toggle",
        name = function() return IconLabel("attackPower", "Attack Power") end,
        order = 16,
        width = 1.0,
      },
      reportStamina = {
        type = "toggle",
        name = function() return IconLabel("stamina", "Stamina") end,
        order = 17,
        width = 1.0,
      },
      reportSpirit = {
        type = "toggle",
        name = function() return IconLabel("spirit", "Spirit") end,
        order = 18,
        width = 1.0,
      },
      reportArmor = {
        type = "toggle",
        name = function() return IconLabel("armor", "Armor") end,
        order = 19,
        width = 1.0,
      },
      reportShadow = {
        type = "toggle",
        name = function() return IconLabel("shadow", "Shadow Protection") end,
        order = 20,
        width = 1.0,
      },
      reportMight = {
        type = "toggle",
        name = function() return IconLabel("might", "Blessing of Might") end,
        order = 21,
        width = 1.0,
      },
      reportWisdom = {
        type = "toggle",
        name = function() return IconLabel("wisdom", "Blessing of Wisdom") end,
        order = 22,
        width = 1.0,
      },
      reportKings = {
        type = "toggle",
        name = function() return IconLabel("kings", "Blessing of Kings") end,
        order = 23,
        width = 1.0,
      },
      reportSalvation = {
        type = "toggle",
        name = function() return IconLabel("salvation", "Blessing of Salvation") end,
        order = 24,
        width = 1.0,
      },
      frameHeader = {
        type = "header",
        name = self:T("Ready Check Frame Settings"),
        order = 25,
      },
      showFoodColumn = {
        type = "toggle",
        name = function() return IconLabel("food", "Food") end,
        order = 26,
        width = 1.0,
      },
      showFlaskColumn = {
        type = "toggle",
        name = function() return IconLabel("flask", "Flask / Elixir") end,
        order = 27,
        width = 1.0,
      },
      showScrollsColumn = {
        type = "toggle",
        name = function() return IconLabel("scrolls", "Scroll") end,
        order = 28,
        width = 1.0,
      },
      showMotwColumn = {
        type = "toggle",
        name = function() return IconLabel("motw", "MotW") end,
        order = 29,
        width = 1.0,
      },
      showIntellectColumn = {
        type = "toggle",
        name = function() return IconLabel("intellect", "Intellect") end,
        order = 30,
        width = 1.0,
      },
      showAttackPowerColumn = {
        type = "toggle",
        name = function() return IconLabel("attackPower", "Attack Power") end,
        order = 31,
        width = 1.0,
      },
      showStaminaColumn = {
        type = "toggle",
        name = function() return IconLabel("stamina", "Stamina") end,
        order = 32,
        width = 1.0,
      },
      showSpiritColumn = {
        type = "toggle",
        name = function() return IconLabel("spirit", "Spirit") end,
        order = 33,
        width = 1.0,
      },
      showArmorColumn = {
        type = "toggle",
        name = function() return IconLabel("armor", "Armor") end,
        order = 34,
        width = 1.0,
      },
      showShadowColumn = {
        type = "toggle",
        name = function() return IconLabel("shadow", "Shadow Protection") end,
        order = 35,
        width = 1.0,
      },
      showMightColumn = {
        type = "toggle",
        name = function() return IconLabel("might", "Blessing of Might") end,
        order = 36,
        width = 1.0,
      },
      showWisdomColumn = {
        type = "toggle",
        name = function() return IconLabel("wisdom", "Blessing of Wisdom") end,
        order = 37,
        width = 1.0,
      },
      showKingsColumn = {
        type = "toggle",
        name = function() return IconLabel("kings", "Blessing of Kings") end,
        order = 38,
        width = 1.0,
      },
      showSalvationColumn = {
        type = "toggle",
        name = function() return IconLabel("salvation", "Blessing of Salvation") end,
        order = 39,
        width = 1.0,
      },
      showDurabilityColumn = {
        type = "toggle",
        name = function() return IconLabel("durability", "Durability") end,
        order = 40,
        width = 1.0,
      },
      showMerfinPlusColumn = {
        type = "toggle",
        name = function() return IconLabel("merfinPlus", "Merfin Plus") end,
        order = 41,
        width = 1.0,
      },
      showT5Column = {
        type = "toggle",
        name = function() return IconLabel("t5", "T5") end,
        order = 42,
        width = 1.0,
      },
      showT6Column = {
        type = "toggle",
        name = function() return IconLabel("t6", "T6") end,
        order = 43,
        width = 1.0,
      },
      showT6AColumn = {
        type = "toggle",
        name = function() return IconLabel("t6a", "T6A") end,
        order = 44,
        width = 1.0,
      },
      previewHeader = {
        type = "header",
        name = self:T("Interactive Preview"),
        order = 45,
      },
      preview = {
        type = "description",
        name = "",
        order = 46,
        width = "full",
        dialogControl = "MerfinPlusReadyCheckPreview",
      },
    },
  }
end

function MerfinPlus:SaveReadyCheckWindowGeometry()
  local frame = self.readyCheckFrame
  if not frame then
    return
  end

  local settings = self:GetReadyCheckSettings()
  settings.windowWidth = Round(frame:GetWidth())
  settings.windowHeight = Round(frame:GetHeight())
  local centerX, centerY = frame:GetCenter()
  local parentX, parentY = UIParent:GetCenter()
  if centerX and centerY and parentX and parentY then
    settings.windowX = Round(centerX - parentX)
    settings.windowY = Round(centerY - parentY)
  end
end

function MerfinPlus:CreateReadyCheckWindow()
  if self.readyCheckFrame then
    return self.readyCheckFrame
  end

  local settings = self:GetReadyCheckSettings()
  local frame = CreateFrame("Frame", "MerfinPlusReadyCheckFrame", UIParent)
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:SetResizable(true)
  frame:EnableMouse(true)
  if frame.SetClipsChildren then frame:SetClipsChildren(true) end
  frame:SetSize(settings.windowWidth, settings.windowHeight)
  frame:SetPoint("CENTER", UIParent, "CENTER", settings.windowX, settings.windowY)

  if frame.SetResizeBounds then
    frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)
  else
    if frame.SetMinResize then
      frame:SetMinResize(MIN_WIDTH, MIN_HEIGHT)
    end
    if frame.SetMaxResize then
      frame:SetMaxResize(MAX_WIDTH, MAX_HEIGHT)
    end
  end

  frame.background = frame:CreateTexture(nil, "BACKGROUND")
  frame.background:SetAllPoints()
  frame.background:SetColorTexture(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.96)
  AddBorderTextures(frame, 2)
  SetBorderColor(frame, theme.border[1], theme.border[2], theme.border[3], theme.border[4])

  frame.titleBar = CreateFrame("StatusBar", nil, frame)
  frame.titleBar:SetPoint("TOPLEFT", 2, -2)
  frame.titleBar:SetPoint("TOPRIGHT", -2, -2)
  frame.titleBar:EnableMouse(true)
  frame.titleBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  frame.titleBar:SetStatusBarColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.52)
  frame.titleBar:SetMinMaxValues(0, 1)
  frame.titleBar:SetValue(1)
  frame.titleBar.background = frame.titleBar:CreateTexture(nil, "BACKGROUND")
  frame.titleBar.background:SetAllPoints()
  frame.titleBar.background:SetColorTexture(theme.selected[1], theme.selected[2], theme.selected[3], 0.98)

  frame.countText = frame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyReadyCheckFont(frame.countText, 12, "OUTLINE")
  frame.countText:SetJustifyH("LEFT")
  frame.countText:SetTextColor(1, 1, 1, 1)

  frame.titleText = frame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyReadyCheckFont(frame.titleText, 12, "OUTLINE")
  frame.titleText:SetPoint("CENTER")
  frame.titleText:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)

  frame.closeButton = CreateFrame("Button", nil, frame.titleBar)
  frame.closeButton:SetPoint("RIGHT", -6, 0)
  frame.closeButton.text = frame.closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyReadyCheckFont(frame.closeButton.text, 16, "OUTLINE")
  frame.closeButton.text:SetPoint("CENTER", 0, 1)
  frame.closeButton.text:SetText("×")
  frame.closeButton.text:SetTextColor(0.9, 0.9, 0.9, 1)
  frame.closeButton:SetScript("OnEnter", function(button)
    button.text:SetTextColor(1, 0.25, 0.25, 1)
  end)
  frame.closeButton:SetScript("OnLeave", function(button)
    button.text:SetTextColor(0.9, 0.9, 0.9, 1)
  end)
  frame.closeButton:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame.header = CreateFrame("Frame", nil, frame)
  frame.header.background = frame.header:CreateTexture(nil, "BACKGROUND")
  frame.header.background:SetAllPoints()
  frame.header.background:SetColorTexture(theme.surfaceRaised[1], theme.surfaceRaised[2], theme.surfaceRaised[3], 0.98)
  frame.headerCells = {}
  frame.headerTexts = {}
  for index = 1, #COLUMNS + 2 do
    local cell = CreateHeaderCell(frame.header)
    cell.text:SetJustifyH(index == 1 and "LEFT" or "CENTER")
    frame.headerCells[index] = cell
    frame.headerTexts[index] = cell.text
  end

  frame.rows = {}
  frame.members = {}

  frame.resizeHandle = CreateFrame("Button", nil, frame)
  frame.resizeHandle:SetPoint("BOTTOMRIGHT", -2, 2)
  frame.resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  frame.resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  frame.resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  frame.resizeHandle:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" then
      frame:StartSizing("BOTTOMRIGHT")
    end
  end)
  frame.resizeHandle:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    MerfinPlus:UpdateReadyCheckWindowLayout(true)
    MerfinPlus:SaveReadyCheckWindowGeometry()
  end)

  frame.titleBar:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" then
      frame:StartMoving()
    end
  end)
  frame.titleBar:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    MerfinPlus:SaveReadyCheckWindowGeometry()
  end)
  frame:SetScript("OnSizeChanged", function()
    MerfinPlus:UpdateReadyCheckWindowLayout(false)
  end)
  frame:SetScript("OnHide", function()
    MerfinPlus:CancelReadyCheckCountdownTimer()
    MerfinPlus:CancelReadyCheckPackRequestTimers()
    if MerfinPlus.readyCheckManualMode then
      MerfinPlus.readyCheckManualMode = false
      MerfinPlus.readyCheckActive = false
    end
    MerfinPlus.readyCheckAuraRefreshGeneration = (MerfinPlus.readyCheckAuraRefreshGeneration or 0) + 1
    MerfinPlus.readyCheckAuraRefreshPending = nil
    MerfinPlus.readyCheckDirtyAuraUnits = {}
    MerfinPlus:SaveReadyCheckWindowGeometry()
  end)

  frame:Hide()
  self.readyCheckFrame = frame
  self:RefreshReadyCheckTheme()
  return frame
end

function MerfinPlus:RefreshReadyCheckTheme()
  local frame = self.readyCheckFrame
  if not frame then return end
  frame.background:SetColorTexture(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.96)
  SetBorderColor(frame, theme.border[1], theme.border[2], theme.border[3], theme.border[4])
  frame.titleBar:SetStatusBarColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.52)
  frame.titleBar.background:SetColorTexture(
    theme.selected[1], theme.selected[2], theme.selected[3], 0.98
  )
  frame.titleText:SetTextColor(
    theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1
  )
  frame.header.background:SetColorTexture(
    theme.surfaceRaised[1], theme.surfaceRaised[2], theme.surfaceRaised[3], 0.98
  )
  for _, cell in ipairs(frame.headerCells or {}) do
    cell.text:SetTextColor(
      theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1
    )
  end
  for _, texture in ipairs({
    frame.resizeHandle:GetNormalTexture(),
    frame.resizeHandle:GetHighlightTexture(),
    frame.resizeHandle:GetPushedTexture(),
  }) do
    texture:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  end
  self:ApplyUIFontSizeDelta(frame)
end

function MerfinPlus:GetReadyCheckFont()
  return ResolveReadyCheckFont()
end

function MerfinPlus:CancelReadyCheckCountdownTimer()
  if self.readyCheckCountdownTimer then
    self.readyCheckCountdownTimer:Cancel()
    self.readyCheckCountdownTimer = nil
  end
end

function MerfinPlus:ScheduleReadyCheckCountdownTick()
  self:CancelReadyCheckCountdownTimer()
  local frame = self.readyCheckFrame
  if not frame or not frame:IsShown() or not frame.countdownEndsAt then return end
  local remaining = math.max(0, frame.countdownEndsAt - GetTime())
  if remaining <= 0 or not (C_Timer and C_Timer.NewTimer) then return end
  self.readyCheckCountdownTimer = C_Timer.NewTimer(math.min(0.03, remaining), function()
    MerfinPlus.readyCheckCountdownTimer = nil
    MerfinPlus:UpdateReadyCheckCountdown(0, false)
    MerfinPlus:ScheduleReadyCheckCountdownTick()
  end)
end

function MerfinPlus:StartReadyCheckCountdown(seconds)
  local frame = self.readyCheckFrame
  if not frame then
    return
  end

  local duration = math.max(1, tonumber(seconds) or 1)
  frame.countdownDuration = duration
  frame.countdownEndsAt = GetTime() + duration
  frame.countdownDisplayedSecond = nil
  self:UpdateReadyCheckCountdown(0, true)
  self:ScheduleReadyCheckCountdownTick()
end

function MerfinPlus:UpdateReadyCheckCountdown(_elapsed, _force)
  local frame = self.readyCheckFrame
  if not frame or not frame:IsShown() or not frame.countdownEndsAt then
    return
  end

  local duration = math.max(1, tonumber(frame.countdownDuration) or 1)
  local remaining = math.max(0, frame.countdownEndsAt - GetTime())
  frame.titleBar:SetMinMaxValues(0, duration)
  frame.titleBar:SetValue(math.min(duration, remaining))
  local displayedSecond = math.ceil(remaining)
  if _force or frame.countdownDisplayedSecond ~= displayedSecond then
    frame.countdownDisplayedSecond = displayedSecond
    frame.titleText:SetText(self:T("MP: Ready Check (%d sec.)", displayedSecond))
  end
end

function MerfinPlus:UpdateReadyCheckWindowLayout(fitHeight, fitWidth)
  local frame = self.readyCheckFrame
  if not frame then
    return
  end
  -- Layout writes the configured base sizes. Restore first, then apply the
  -- global +1 UI rule again after every resize or font-size setting change.
  self:RestoreUIFontSizeDelta(frame)

  local settings = self:GetReadyCheckSettings()
  local visibleColumns = GetVisibleReadyCheckColumns(settings)
  local naturalGridWidth = 130 + 40
  for _, visible in ipairs(visibleColumns) do
    naturalGridWidth = naturalGridWidth + (visible.column.width or 48)
  end
  local desiredWidth = Clamp(naturalGridWidth + 12, MIN_WIDTH, MAX_WIDTH)
  if fitWidth and math.abs((frame:GetWidth() or 0) - desiredWidth) > 0.5 then
    frame.readyCheckFittingWidth = true
    frame:SetWidth(desiredWidth)
    frame.readyCheckFittingWidth = nil
  end
  local width = frame:GetWidth() or desiredWidth
  local availableGridWidth = math.max(1, width - 12)
  -- Derive the grid from the real inner width. A fixed lower scale used to
  -- leave the columns wider than a manually resized Ready Check frame.
  local scale = math.min(1.35, availableGridWidth / math.max(1, naturalGridWidth))
  scale = math.max(0.15, scale)
  local fontSize = Clamp(Round(settings.fontSize), 8, 24)
  local titleFontSize = Clamp(fontSize + 1, 9, 25)
  local textScale = math.min(1, math.max(0.58, scale))
  local headerFontSize = Clamp(Round((fontSize - 2) * textScale), 7, 22)
  local margin = 6 * scale
  local titleHeight = math.max(fontSize + 10, 24 * math.min(1, scale))
  local headerHeight = math.max(fontSize + 8, 21 * math.min(1, scale))
  local baseRowHeight = math.max(fontSize + 5, 19 * math.min(1, scale))
  frame.readyCheckScale = scale
  local memberCount = math.max(1, #(frame.members or {}))
  local desiredHeight = Clamp(
    4 + titleHeight + (4 * scale) + headerHeight + (memberCount * baseRowHeight) + margin,
    MIN_HEIGHT,
    MAX_HEIGHT
  )

  if fitHeight and math.abs((frame:GetHeight() or 0) - desiredHeight) > 0.5 then
    frame.readyCheckFittingHeight = true
    frame:SetHeight(desiredHeight)
    frame.readyCheckFittingHeight = nil
  end

  local availableRowsHeight = math.max(
    1,
    (frame:GetHeight() or desiredHeight) - 4 - titleHeight - (4 * scale) - headerHeight - margin
  )
  local rowHeight = math.min(baseRowHeight, math.max(7, availableRowsHeight / memberCount))
  local rowFontSize = Clamp(Round(math.min(fontSize, rowHeight - 4)), 6, fontSize)
  frame.readyCheckRowHeight = rowHeight

  frame.titleBar:SetHeight(titleHeight)
  frame.countText:ClearAllPoints()
  frame.countText:SetPoint("LEFT", 8 * scale, 0)
  frame.countText:SetWidth(math.max(36, (width * 0.28) - (12 * scale)))
  frame.titleText:ClearAllPoints()
  frame.titleText:SetPoint("CENTER", frame.titleBar, "CENTER", 0, 0)
  frame.titleText:SetWidth(math.max(48, width * 0.48))
  ApplyReadyCheckFont(frame.countText, titleFontSize, "OUTLINE")
  ApplyReadyCheckFont(frame.titleText, titleFontSize, "OUTLINE")
  frame.closeButton:SetSize(titleHeight - 4, titleHeight - 4)
  ApplyReadyCheckFont(frame.closeButton.text, Clamp(fontSize + 5, 13, 29), "OUTLINE")

  local nameWidth = 130 * scale
  local statusWidth = 40 * scale
  frame.visibleColumns = visibleColumns
  local columnWidths = {}
  local gridWidth = nameWidth + statusWidth
  for _, visible in ipairs(visibleColumns) do
    columnWidths[visible.index] = (visible.column.width or 48) * scale
    gridWidth = gridWidth + columnWidths[visible.index]
  end

  frame.header:ClearAllPoints()
  frame.header:SetPoint("TOP", frame, "TOP", 0, -(titleHeight + 4 * scale))
  frame.header:SetSize(gridWidth, headerHeight)
  frame.header:SetHeight(headerHeight)
  frame.resizeHandle:SetSize(18 * scale, 18 * scale)

  for _, headerCell in ipairs(frame.headerCells) do
    headerCell:Hide()
  end

  local x = 0
  local function PositionHeaderCell(headerCell, cellWidth, title, description, text, justifyLeft)
    headerCell.tooltipTitle = self:T(title)
    headerCell.tooltipDescription = self:T(description)
    headerCell.text:SetText(self:T(text))
    headerCell:ClearAllPoints()
    headerCell:SetPoint("LEFT", frame.header, "LEFT", x, 0)
    headerCell:SetSize(cellWidth, headerHeight)
    headerCell.text:ClearAllPoints()
    headerCell.text:SetPoint(justifyLeft and "LEFT" or "CENTER", headerCell, justifyLeft and "LEFT" or "CENTER", justifyLeft and 4 * scale or 0, 0)
    headerCell.text:SetWidth(cellWidth - (justifyLeft and 4 * scale or 0))
    ApplyReadyCheckFont(headerCell.text, headerFontSize, "OUTLINE")
    headerCell:Show()
    x = x + cellWidth
  end

  PositionHeaderCell(frame.headerCells[1], nameWidth, "Player", "Grouped player name", "Player", true)
  PositionHeaderCell(frame.headerCells[2], statusWidth, "Ready Status", "Waiting, ready, or not ready", "RC", false)
  for _, visible in ipairs(visibleColumns) do
    local column = visible.column
    local description
    if column.flaskElixirs then
      description = "Satisfied by a Flask, a Battle Elixir, a Guardian Elixir, or both elixirs."
    elseif column.durability then
      description = "Lowest equipped-item durability reported by MerfinPlus."
    elseif column.version then
      description = "MerfinPlus version reported by the player."
    elseif column.t5Version or column.t6Version or column.t6AVersion then
      local packLabel = column.t6AVersion and "T6 Assignments" or (column.t6Version and "T6" or "T5")
      description = packLabel .. " installation status reported by the player."
    else
      description = "Directly read from visible group auras."
    end
    PositionHeaderCell(
      frame.headerCells[visible.index + 2],
      columnWidths[visible.index],
      column.label,
      description,
      column.shortLabel or column.label,
      false
    )
  end

  for index, row in ipairs(frame.rows) do
    local member = frame.members[index]
    if member then
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -((index - 1) * rowHeight))
      row:SetSize(gridWidth, math.max(8, rowHeight - 1))
      row.nameText:ClearAllPoints()
      row.nameText:SetPoint("LEFT", row, "LEFT", 5 * scale, 0)
      row.nameText:SetSize(nameWidth - (8 * scale), rowHeight)
      ApplyReadyCheckFont(row.nameText, rowFontSize, "OUTLINE")
      row.statusIcon:ClearAllPoints()
      row.statusIcon:SetPoint("CENTER", row, "LEFT", nameWidth + (statusWidth / 2), 0)
      local statusIconSize = math.max(10, math.min(rowHeight - 4, 15 * scale))
      row.statusIcon:SetSize(statusIconSize, statusIconSize)
      if row.statusText then
        row.statusText:ClearAllPoints()
        row.statusText:SetPoint("CENTER", row.statusIcon, "CENTER", 0, 0)
        row.statusText:SetWidth(statusWidth)
        ApplyReadyCheckFont(row.statusText, Clamp(rowFontSize - 2, 7, 22), "OUTLINE")
      end

      local cellX = nameWidth + statusWidth
      for _, cell in ipairs(row.cells) do
        cell:Hide()
      end
      for _, visible in ipairs(visibleColumns) do
        local cell = row.cells[visible.index]
        local columnWidth = columnWidths[visible.index]
        cell:ClearAllPoints()
        cell:SetPoint("LEFT", row, "LEFT", cellX + scale, 0)
        cell:SetSize(math.max(8, columnWidth - (2 * scale)), math.max(8, rowHeight - 2))
        LayoutReadyCheckCellIcons(cell, rowHeight, scale)
        cell.text:ClearAllPoints()
        cell.text:SetAllPoints(cell)
        if cell.isT5Version or cell.isT6Version or cell.isT6AVersion then
          cell.text:ClearAllPoints()
          cell.text:SetPoint("LEFT", cell.icon, "RIGHT", 2 * scale, 0)
          cell.text:SetPoint("RIGHT", cell, "RIGHT", -2 * scale, 0)
        end
        ApplyReadyCheckFont(cell.text, Clamp(rowFontSize - 2, 7, 22), "OUTLINE")
        cell:Show()
        cellX = cellX + columnWidth
      end
      row:Show()
    else
      row:Hide()
    end
  end
  self:ApplyUIFontSizeDelta(frame)
end

function MerfinPlus:BuildReadyCheckRoster()
  local units = {}
  AddGroupUnits(units)
  local members = {}

  for rosterIndex, unit in ipairs(units) do
    if UnitExists(unit) and UnitIsPlayer(unit) then
      local fullName = GetUnitFullName(unit)
      local _, classFile = UnitClass(unit)
      local guid = UnitGUID(unit)
      if fullName then
        members[#members + 1] = {
          unit = unit,
          guid = guid,
          key = guid or NormalizeName(fullName),
          nameKey = NormalizeName(fullName),
          fullName = fullName,
          name = DisplayName(fullName),
          classFile = classFile,
          rosterIndex = rosterIndex,
        }
      end
    end
  end

  local settings = self:GetReadyCheckSettings()
  if settings.sortByClass or settings.sortByName then
    table.sort(members, function(left, right)
      if settings.sortByClass then
        local leftClass = left.classFile or "ZZZ"
        local rightClass = right.classFile or "ZZZ"
        if leftClass ~= rightClass then
          return leftClass < rightClass
        end
      end
      if settings.sortByName then
        local leftName = string.lower(left.name or "")
        local rightName = string.lower(right.name or "")
        if leftName ~= rightName then
          return leftName < rightName
        end
      end
      return left.rosterIndex < right.rosterIndex
    end)
  end

  return members
end

function MerfinPlus:GetStoredReadyStatus(member)
  if self.readyCheckManualMode then return "waiting" end
  local status = self.readyCheckStatuses and self.readyCheckStatuses[member.key]
  if not status and self.readyCheckStatusesByName then
    status = self.readyCheckStatusesByName[member.nameKey]
  end
  if not status and GetReadyCheckStatus then
    status = GetReadyCheckStatus(member.unit)
  end
  if status ~= "ready" and status ~= "notready" then
    status = "waiting"
  end
  return status
end

local function IsReadyCheckMemberOffline(member)
  if not member or type(member.unit) ~= "string" or not UnitIsConnected then
    return false
  end
  return UnitIsConnected(member.unit) == false
end

function MerfinPlus:SetReadyCheckOfflineCell(cell, column)
  cell.categoryLabel = self:T(column.label)
  cell.auraData = nil
  cell.auraGroup = nil
  cell.durabilityValue = nil
  cell.durabilityBasisPoints = nil
  cell.versionValue = nil
  cell.localVersion = nil
  cell.isDurability = false
  cell.isVersion = false
  cell.isT5Version = false
  cell.isT6Version = false
  cell.isT6AVersion = false
  cell.isExpiring = false
  cell.isOffline = true
  if cell.auraIconButtons then
    SetReadyCheckAuraIconButtons(cell, nil, nil)
  end
  cell.icon:Hide()
  cell.icon2:Hide()
  cell.expiringIcon:Hide()
  cell.text:ClearAllPoints()
  cell.text:SetAllPoints(cell)
  cell.text:SetText("OFF")
  cell.text:SetTextColor(0.58, 0.58, 0.58, 1)
  cell.background:SetColorTexture(0.045, 0.045, 0.045, 0.82)
  SetBorderColor(cell, 0.24, 0.24, 0.24, 0.92)
end

function MerfinPlus:SetReadyCheckAuraCell(cell, column, aura, auraMatches)
  local useIndividualIcons = column.key == "food"
  cell.categoryLabel = self:T(column.label)
  cell.auraData = useIndividualIcons and nil or aura
  cell.auraGroup = nil
  cell.durabilityValue = nil
  cell.durabilityBasisPoints = nil
  cell.versionValue = nil
  cell.localVersion = nil
  cell.isDurability = false
  cell.isVersion = false
  cell.isT5Version = false
  cell.isT6Version = false
  cell.isT6AVersion = false
  cell.isExpiring = false
  cell.isOffline = false
  cell.icon2:Hide()
  cell.expiringIcon:Hide()
  if useIndividualIcons then
    local displayAuras = auraMatches
    if type(displayAuras) ~= "table" and aura then
      displayAuras = { aura }
    end
    SetReadyCheckAuraIconButtons(cell, displayAuras, cell.categoryLabel)
    cell.icon:Hide()
  elseif cell.auraIconButtons then
    SetReadyCheckAuraIconButtons(cell, nil, nil)
  end

  if not aura then
    cell.icon:Hide()
    cell.text:SetText("—")
    cell.text:SetTextColor(0.95, 0.28, 0.28, 1)
    cell.background:SetColorTexture(0.12, 0.025, 0.025, 0.82)
    SetBorderColor(cell, 0.45, 0.10, 0.10, 0.95)
    return
  end

  if not useIndividualIcons then
    cell.icon:SetTexture(aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    cell.icon:SetVertexColor(1, 1, 1, 1)
    cell.icon:Show()
  end
  cell.background:SetColorTexture(0.025, 0.09, 0.035, 0.82)

  local settings = self:GetReadyCheckSettings()
  local remaining = AuraRemaining(aura, GetTime())
  local expiring = settings.showExpiring
    and remaining ~= math.huge
    and remaining <= EXPIRING_SECONDS

  if expiring then
    cell.isExpiring = true
    cell.expiringIcon:Show()
    cell.text:SetText("")
    cell.text:SetTextColor(1, 0.72, 0.10, 1)
    cell.background:SetColorTexture(0.25, 0.10, 0.01, 0.88)
    SetBorderColor(cell, 1, 0.42, 0.05, 1)
  else
    cell.text:SetText(not useIndividualIcons and (aura.matchedCount or 0) > 1
      and tostring(aura.matchedCount)
      or "")
    cell.text:SetTextColor(1, 1, 1, 1)
    SetBorderColor(cell, 0.18, 0.62, 0.25, 0.95)
  end
end

function MerfinPlus:SetReadyCheckFlaskCell(cell, auras)
  local state = GetFlaskElixirState(auras)
  cell.categoryLabel = self:T("Flask / Elixir")
  cell.auraData = nil
  cell.auraGroup = state and state.entries or nil
  cell.durabilityValue = nil
  cell.durabilityBasisPoints = nil
  cell.versionValue = nil
  cell.localVersion = nil
  cell.isDurability = false
  cell.isVersion = false
  cell.isT5Version = false
  cell.isT6Version = false
  cell.isT6AVersion = false
  cell.isExpiring = false
  cell.isOffline = false
  cell.icon:Hide()
  cell.icon2:Hide()
  cell.expiringIcon:Hide()

  if not state then
    cell.text:SetText("—")
    cell.text:SetTextColor(0.95, 0.28, 0.28, 1)
    cell.background:SetColorTexture(0.12, 0.025, 0.025, 0.82)
    SetBorderColor(cell, 0.45, 0.10, 0.10, 0.95)
    return
  end

  for index, entry in ipairs(state.entries) do
    local icon = index == 1 and cell.icon or cell.icon2
    icon:SetTexture(entry.aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    icon:SetVertexColor(1, 1, 1, 1)
    icon:Show()
  end

  local expiring = self:GetReadyCheckSettings().showExpiring
    and state.remaining ~= math.huge
    and state.remaining <= EXPIRING_SECONDS
  if expiring then
    cell.isExpiring = true
    cell.expiringIcon:Show()
    cell.text:SetText("")
    cell.text:SetTextColor(1, 0.72, 0.10, 1)
    cell.background:SetColorTexture(0.25, 0.10, 0.01, 0.88)
    SetBorderColor(cell, 1, 0.42, 0.05, 1)
    return
  end

  cell.text:SetText("")
  cell.icon:SetVertexColor(1, 1, 1, 1)
  cell.icon2:SetVertexColor(1, 1, 1, 1)
  cell.text:SetTextColor(1, 1, 1, 1)
  cell.background:SetColorTexture(0.025, 0.09, 0.035, 0.82)
  SetBorderColor(cell, 0.18, 0.62, 0.25, 0.95)
end

function MerfinPlus:SetReadyCheckDurabilityCell(cell, value)
  cell.categoryLabel = self:T("Durability")
  cell.auraData = nil
  cell.auraGroup = nil
  cell.durabilityValue = nil
  cell.durabilityBasisPoints = value
  cell.versionValue = nil
  cell.localVersion = nil
  cell.isDurability = true
  cell.isVersion = false
  cell.isT5Version = false
  cell.isT6Version = false
  cell.isT6AVersion = false
  cell.isExpiring = false
  cell.isOffline = false
  cell.icon:Hide()
  cell.icon2:Hide()
  cell.expiringIcon:Hide()

  if value == nil then
    cell.text:SetText("?")
    cell.text:SetTextColor(0.65, 0.65, 0.65, 1)
    cell.background:SetColorTexture(0.055, 0.055, 0.055, 0.82)
    SetBorderColor(cell, 0.28, 0.28, 0.28, 0.95)
    return
  end

  local basisPoints = Clamp(Round(value), 0, DURABILITY_MAX_BASIS_POINTS)
  local wholePercent = math.floor(basisPoints / DURABILITY_BASIS_POINTS_PER_PERCENT)
  cell.durabilityBasisPoints = basisPoints
  cell.durabilityValue = wholePercent
  cell.text:SetText(string.format("%d%%", wholePercent))
  if wholePercent >= 75 then
    cell.text:SetTextColor(0.25, 1, 0.35, 1)
    SetBorderColor(cell, 0.18, 0.62, 0.25, 0.95)
  elseif wholePercent >= 50 then
    cell.text:SetTextColor(1, 0.88, 0.20, 1)
    SetBorderColor(cell, 0.75, 0.60, 0.10, 0.95)
  elseif wholePercent >= 25 then
    cell.text:SetTextColor(1, 0.55, 0.10, 1)
    SetBorderColor(cell, 0.85, 0.35, 0.05, 0.95)
  else
    cell.text:SetTextColor(1, 0.20, 0.20, 1)
    SetBorderColor(cell, 0.65, 0.08, 0.08, 0.95)
  end
  cell.background:SetColorTexture(0.035, 0.035, 0.035, 0.82)
end

function MerfinPlus:SetReadyCheckVersionCell(cell, version, responded)
  local localVersion = GetCanonicalAddonVersion()
  version = responded and NormalizeReportedVersion(version) or nil

  cell.categoryLabel = self:T("Merfin Plus")
  cell.auraData = nil
  cell.auraGroup = nil
  cell.durabilityValue = nil
  cell.durabilityBasisPoints = nil
  cell.versionValue = version
  cell.localVersion = localVersion
  cell.isDurability = false
  cell.isVersion = true
  cell.isT5Version = false
  cell.isT6Version = false
  cell.isT6AVersion = false
  cell.isExpiring = false
  cell.isOffline = false
  cell.icon:Hide()
  cell.icon2:Hide()
  cell.expiringIcon:Hide()

  if not version or localVersion == "unknown" then
    cell.text:SetText("?")
    cell.text:SetTextColor(0.65, 0.65, 0.65, 1)
    cell.background:SetColorTexture(0.055, 0.055, 0.055, 0.82)
    SetBorderColor(cell, 0.28, 0.28, 0.28, 0.95)
    return
  end

  cell.text:SetText(FormatAddonVersion(version))
  if version == localVersion then
    cell.text:SetTextColor(0.25, 1, 0.35, 1)
    cell.background:SetColorTexture(0.025, 0.09, 0.035, 0.82)
    SetBorderColor(cell, 0.18, 0.62, 0.25, 0.95)
  else
    cell.text:SetTextColor(1, 0.28, 0.28, 1)
    cell.background:SetColorTexture(0.12, 0.025, 0.025, 0.82)
    SetBorderColor(cell, 0.65, 0.08, 0.08, 0.95)
  end
end

function MerfinPlus:UpdateReadyCheckResponseCount()
  local frame = self.readyCheckFrame
  if not frame or not frame:IsShown() then
    return
  end
  local responded = 0
  for _, member in ipairs(frame.members or {}) do
    if member.status == "ready" or member.status == "notready" then
      responded = responded + 1
    end
  end
  if self.readyCheckManualMode then
    frame.countText:SetText(string.format("%s: %d", self:T("Players"), #(frame.members or {})))
  else
    frame.countText:SetText(string.format("%s: %d/%d", self:T("Responses"), responded, #(frame.members or {})))
  end
end

local function ApplyReadyCheckPackStatus(cell, installed, responded)
  cell.packResponded = responded and true or false
  cell.icon2:Hide()
  cell.expiringIcon:Hide()
  cell.text:SetText("")
  cell.icon:SetVertexColor(1, 1, 1, 1)
  cell.icon:Show()

  if not responded then
    cell.icon:SetTexture(STATUS_TEXTURES.waiting)
    cell.text:SetTextColor(0.72, 0.72, 0.72, 1)
    cell.background:SetColorTexture(0.055, 0.055, 0.055, 0.82)
    SetBorderColor(cell, 0.30, 0.30, 0.30, 0.95)
  elseif installed then
    cell.icon:SetTexture(STATUS_TEXTURES.ready)
    cell.text:SetTextColor(0.25, 1, 0.35, 1)
    cell.background:SetColorTexture(0.025, 0.09, 0.035, 0.82)
    SetBorderColor(cell, 0.18, 0.62, 0.25, 0.95)
  else
    cell.icon:SetTexture(STATUS_TEXTURES.notready)
    cell.text:SetTextColor(1, 0.28, 0.28, 1)
    cell.background:SetColorTexture(0.12, 0.025, 0.025, 0.82)
    SetBorderColor(cell, 0.65, 0.08, 0.08, 0.95)
  end
end

function MerfinPlus:SetReadyCheckT5Cell(cell, version, responded)
  version = responded and NormalizeReportedVersion(version) or nil
  local installed = version ~= nil
  cell.categoryLabel = "T5"
  cell.auraData, cell.auraGroup = nil, nil
  cell.durabilityValue, cell.durabilityBasisPoints = nil, nil
  cell.versionValue, cell.localVersion = version, nil
  cell.isDurability, cell.isVersion, cell.isT5Version, cell.isT6Version, cell.isExpiring = false, false, true, false, false
  cell.isT6AVersion = false
  cell.isOffline = false
  ApplyReadyCheckPackStatus(cell, installed, responded)
end

function MerfinPlus:SetReadyCheckT6Cell(cell, version, responded)
  version = responded and NormalizeReportedVersion(version) or nil
  local installed = version ~= nil
  cell.categoryLabel = "T6"
  cell.auraData, cell.auraGroup = nil, nil
  cell.durabilityValue, cell.durabilityBasisPoints = nil, nil
  cell.versionValue, cell.localVersion = version, nil
  cell.isDurability, cell.isVersion, cell.isT5Version, cell.isT6Version, cell.isExpiring = false, false, false, true, false
  cell.isT6AVersion = false
  cell.isOffline = false
  ApplyReadyCheckPackStatus(cell, installed, responded)
end

function MerfinPlus:SetReadyCheckT6ACell(cell, version, responded)
  version = responded and NormalizeReportedVersion(version) or nil
  local installed = version ~= nil
  cell.categoryLabel = "T6 Assignments"
  cell.auraData, cell.auraGroup = nil, nil
  cell.durabilityValue, cell.durabilityBasisPoints = nil, nil
  cell.versionValue, cell.localVersion = version, nil
  cell.isDurability, cell.isVersion, cell.isT5Version, cell.isT6Version, cell.isExpiring = false, false, false, false, false
  cell.isT6AVersion = true
  cell.isOffline = false
  if cell.auraIconButtons then SetReadyCheckAuraIconButtons(cell, nil, nil) end
  ApplyReadyCheckPackStatus(cell, installed, responded)
end

function MerfinPlus:RenderReadyCheckMember(member, options)
  local frame = self.readyCheckFrame
  local row = member and member.row
  if not frame or not row then
    return false
  end
  options = options or {}

  local wasOffline = member.isOffline
  local offline = IsReadyCheckMemberOffline(member)
  member.isOffline = offline

  local auraChanged = false
  if options.auras and not offline then
    local auras = ScanUnitAuras(member.unit)
    local signature = ReadyCheckAuraSignature(auras)
    auraChanged = options.forceAuras or signature ~= member.auraSignature
    member.auras = auras
    member.auraSignature = signature
  end

  if options.static then
    local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
    local color = classColors and member.classFile and classColors[member.classFile]
    if color then
      row.background:SetColorTexture(color.r, color.g, color.b, 0.42)
    else
      row.background:SetColorTexture(0.20, 0.20, 0.20, 0.42)
    end
    row.nameText:SetText(member.name)
  end

  if offline then
    row.background:SetColorTexture(0.10, 0.10, 0.10, 0.46)
    row.nameText:SetText(member.name)
    if row.nameText.SetTextColor then
      row.nameText:SetTextColor(0.58, 0.58, 0.58, 1)
    end
    row.statusIcon:Hide()
    if row.statusText then row.statusText:Show() end
    for cellIndex, column in ipairs(COLUMNS) do
      local cell = row.cells[cellIndex]
      self:SetReadyCheckOfflineCell(cell, column)
      if options.layoutCells and frame.readyCheckRowHeight then
        LayoutReadyCheckCellIcons(cell, frame.readyCheckRowHeight, frame.readyCheckScale)
      end
    end
    return auraChanged
  end

  if row.nameText.SetTextColor then
    row.nameText:SetTextColor(1, 1, 1, 1)
  end
  if row.statusText then row.statusText:Hide() end

  if options.status or wasOffline then
    member.status = self:GetStoredReadyStatus(member)
    row.statusIcon:SetTexture(STATUS_TEXTURES[member.status] or STATUS_TEXTURES.waiting)
    row.statusIcon:Show()
  end

  for cellIndex, column in ipairs(COLUMNS) do
    local cell = row.cells[cellIndex]
    local cellChanged = false
    if column.t6AVersion and options.t6AVersion then
      self:SetReadyCheckT6ACell(
        cell,
        self.readyCheckT6AVersions and self.readyCheckT6AVersions[member.nameKey],
        self.readyCheckT6AResponded and self.readyCheckT6AResponded[member.nameKey]
      )
      cellChanged = true
    elseif column.t6Version and options.t6Version then
      self:SetReadyCheckT6Cell(cell, self.readyCheckT6Versions and self.readyCheckT6Versions[member.nameKey], self.readyCheckT6Responded and self.readyCheckT6Responded[member.nameKey])
      cellChanged = true
    elseif column.t5Version and options.t5Version then
      self:SetReadyCheckT5Cell(
        cell,
        self.readyCheckT5Versions and self.readyCheckT5Versions[member.nameKey],
        self.readyCheckT5Responded and self.readyCheckT5Responded[member.nameKey]
      )
      cellChanged = true
    elseif column.version and options.version then
      self:SetReadyCheckVersionCell(
        cell,
        self.readyCheckVersions and self.readyCheckVersions[member.nameKey],
        self.readyCheckVersionResponded and self.readyCheckVersionResponded[member.nameKey]
      )
      cellChanged = true
    elseif column.durability and options.durability then
      self:SetReadyCheckDurabilityCell(cell, self.readyCheckDurability and self.readyCheckDurability[member.nameKey])
      cellChanged = true
    elseif not column.version and not column.t5Version and not column.t6Version and not column.t6AVersion and not column.durability and auraChanged then
      if column.flaskElixirs then
        self:SetReadyCheckFlaskCell(cell, member.auras)
      else
        self:SetReadyCheckAuraCell(
          cell,
          column,
          member.auras[column.key],
          member.auras.matchesByCategory and member.auras.matchesByCategory[column.key]
        )
      end
      cellChanged = true
    end

    if cellChanged and options.layoutCells and frame.readyCheckRowHeight then
      LayoutReadyCheckCellIcons(cell, frame.readyCheckRowHeight, frame.readyCheckScale)
    end
  end
  return auraChanged
end

function MerfinPlus:GetDisplayedReadyCheckMember(unitOrName)
  local frame = self.readyCheckFrame
  if not frame or not frame:IsShown() or type(unitOrName) ~= "string" then
    return nil
  end
  return (frame.membersByUnit and frame.membersByUnit[unitOrName])
    or (frame.membersByName and frame.membersByName[NormalizeName(unitOrName)])
end

function MerfinPlus:RefreshReadyCheckMember(unitOrName, options)
  local member = self:GetDisplayedReadyCheckMember(unitOrName)
  if not member then
    return false
  end
  self:RenderReadyCheckMember(member, options)
  if options and options.status then
    self:UpdateReadyCheckResponseCount()
  end
  return true
end

function MerfinPlus:IsReadyCheckSenderInGroup(sender)
  if self.readyCheckActive and self:GetDisplayedReadyCheckMember(sender) then
    return true
  end
  return IsSenderInGroup(sender)
end

function MerfinPlus:QueueReadyCheckAuraRefresh(unit)
  if not self.readyCheckActive or not self:GetDisplayedReadyCheckMember(unit) then
    return
  end
  self.readyCheckDirtyAuraUnits = self.readyCheckDirtyAuraUnits or {}
  self.readyCheckDirtyAuraUnits[unit] = true
  if self.readyCheckAuraRefreshPending then
    return
  end

  self.readyCheckAuraRefreshPending = true
  self.readyCheckAuraRefreshGeneration = (self.readyCheckAuraRefreshGeneration or 0) + 1
  local generation = self.readyCheckAuraRefreshGeneration
  local function refreshDirtyRows()
    if MerfinPlus.readyCheckAuraRefreshGeneration ~= generation then
      return
    end
    MerfinPlus.readyCheckAuraRefreshPending = nil
    local dirtyUnits = MerfinPlus.readyCheckDirtyAuraUnits or {}
    MerfinPlus.readyCheckDirtyAuraUnits = {}
    for dirtyUnit in pairs(dirtyUnits) do
      MerfinPlus:RefreshReadyCheckMember(dirtyUnit, {
        auras = true,
        layoutCells = true,
      })
    end
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(0.05, refreshDirtyRows)
  else
    refreshDirtyRows()
  end
end

function MerfinPlus:RefreshReadyCheckWindow()
  local frame = self.readyCheckFrame
  if not frame or not frame:IsShown() then
    return
  end

  self.readyCheckAuraRefreshGeneration = (self.readyCheckAuraRefreshGeneration or 0) + 1
  self.readyCheckAuraRefreshPending = nil
  self.readyCheckDirtyAuraUnits = {}

  frame.members = self:BuildReadyCheckRoster()
  frame.membersByUnit = {}
  frame.membersByName = {}

  for index, member in ipairs(frame.members) do
    local row = frame.rows[index]
    if not row then
      row = CreateReadyCheckRow(frame)
      frame.rows[index] = row
    end
    member.row = row
    frame.membersByUnit[member.unit] = member
    frame.membersByName[member.nameKey] = member
    self:RenderReadyCheckMember(member, {
      auras = true,
      forceAuras = true,
      status = true,
      durability = true,
      version = true,
      t5Version = true,
      t6Version = true,
      t6AVersion = true,
      static = true,
    })
  end

  for index = #frame.members + 1, #frame.rows do
    frame.rows[index]:Hide()
  end

  self:UpdateReadyCheckResponseCount()
  self:UpdateReadyCheckWindowLayout(true, true)
  self:UpdateReadyCheckCountdown(0, true)
  self:RefreshReadyCheckTheme()
end

function MerfinPlus:CancelReadyCheckHideTimer()
  if self.readyCheckHideTimer then
    self.readyCheckHideTimer:Cancel()
    self.readyCheckHideTimer = nil
  end
end

function MerfinPlus:CancelReadyCheckPackRequestTimers()
  self.readyCheckPackRequestGeneration = (self.readyCheckPackRequestGeneration or 0) + 1
  for _, timer in ipairs(self.readyCheckPackRequestTimers or {}) do
    if timer and timer.Cancel then timer:Cancel() end
  end
  self.readyCheckPackRequestTimers = {}
  self.readyCheckPackCollectionActive = false
end

function MerfinPlus:FinalizeReadyCheckPackResponses(generation)
  if generation ~= self.readyCheckPackRequestGeneration
    or not self.readyCheckActive
    or not self.readyCheckFrame
    or not self.readyCheckFrame:IsShown()
  then
    return
  end

  self.readyCheckPackCollectionActive = false
  self.readyCheckT5Responded = self.readyCheckT5Responded or {}
  self.readyCheckT6Responded = self.readyCheckT6Responded or {}
  self.readyCheckT6AResponded = self.readyCheckT6AResponded or {}
  for _, member in ipairs(self.readyCheckFrame.members or {}) do
    if not IsReadyCheckMemberOffline(member) then
      local key = member.nameKey
      if self.readyCheckT5Responded[key] == nil then self.readyCheckT5Responded[key] = true end
      if self.readyCheckT6Responded[key] == nil then self.readyCheckT6Responded[key] = true end
      if self.readyCheckT6AResponded[key] == nil then self.readyCheckT6AResponded[key] = true end
      self:RefreshReadyCheckMember(member.unit or member.name, {
        t5Version = true,
        t6Version = true,
        t6AVersion = true,
        layoutCells = true,
      })
    end
  end
end

function MerfinPlus:ScheduleReadyCheckPackRequests()
  self:CancelReadyCheckPackRequestTimers()
  self.readyCheckPackCollectionActive = true
  local generation = self.readyCheckPackRequestGeneration
  if not (C_Timer and C_Timer.NewTimer) then return end

  for _, delay in ipairs(PACK_REQUEST_RETRY_DELAYS) do
    local timer = C_Timer.NewTimer(delay, function()
      if generation == MerfinPlus.readyCheckPackRequestGeneration
        and MerfinPlus.readyCheckActive
        and MerfinPlus.readyCheckFrame
        and MerfinPlus.readyCheckFrame:IsShown()
      then
        RequestMissingRaidPackVersions(MerfinPlus)
      end
    end)
    self.readyCheckPackRequestTimers[#self.readyCheckPackRequestTimers + 1] = timer
  end

  local settleTimer = C_Timer.NewTimer(PACK_REQUEST_SETTLE_SECONDS, function()
    MerfinPlus:FinalizeReadyCheckPackResponses(generation)
  end)
  self.readyCheckPackRequestTimers[#self.readyCheckPackRequestTimers + 1] = settleTimer
end

function MerfinPlus:ScheduleReadyCheckHide(seconds, updateCountdown)
  self:CancelReadyCheckHideTimer()
  if updateCountdown ~= false then
    self:StartReadyCheckCountdown(seconds)
  end
  if not (C_Timer and C_Timer.NewTimer) then
    return
  end
  self.readyCheckHideTimer = C_Timer.NewTimer(math.max(1, tonumber(seconds) or 1), function()
    MerfinPlus.readyCheckHideTimer = nil
    if MerfinPlus.readyCheckActive and not MerfinPlus.readyCheckFinished then
      MerfinPlus:HandleReadyCheckFinished()
    end
    MerfinPlus.readyCheckActive = false
    if MerfinPlus.readyCheckFrame then
      MerfinPlus.readyCheckFrame:Hide()
    end
  end)
end

function MerfinPlus:RequestReadyCheckDurability()
  local channel = GetGroupChannel()
  if not channel then
    return
  end

  local tick = math.floor((GetTime() or 0) * 1000) % 1679616
  self.readyCheckNonceCounter = ((self.readyCheckNonceCounter or 0) + 1) % 36
  self.readyCheckNonce = string.format("%05x%x", tick, self.readyCheckNonceCounter)
  self.readyCheckDurability = {}
  self.readyCheckVersions = {}
  self.readyCheckVersionResponded = {}
  self.readyCheckT5Versions = {}
  self.readyCheckT5Responded = {}
  self.readyCheckT6Versions = {}
  self.readyCheckT6Responded = {}
  self.readyCheckT6AVersions = {}
  self.readyCheckT6AResponded = {}

  local playerName = GetUnitFullName("player")
  local localDurability = CalculateLocalDurability()
  if playerName then
    local playerKey = NormalizeName(playerName)
    if localDurability ~= nil then
      self.readyCheckDurability[playerKey] = localDurability
    end
    self.readyCheckVersions[playerKey] = NormalizeReportedVersion(GetCanonicalAddonVersion())
    self.readyCheckVersionResponded[playerKey] = true
    local t5Version = NormalizeReportedVersion(GetLocalT5Version())
    self.readyCheckT5Versions[playerKey] = t5Version
    self.readyCheckT5Responded[playerKey] = true
    local t6Version = NormalizeReportedVersion(GetLocalT6Version())
    self.readyCheckT6Versions[playerKey] = t6Version
    self.readyCheckT6Responded[playerKey] = true
    local t6AVersion = NormalizeReportedVersion(GetLocalT6AssignmentsVersion())
    self.readyCheckT6AVersions[playerKey] = t6AVersion
    self.readyCheckT6AResponded[playerKey] = true
  end

  SendAddonPayload("Q:" .. self.readyCheckNonce, channel)
  RequestRaidPackVersions()
  self:ScheduleReadyCheckPackRequests()
end

function MerfinPlus:HandleReadyCheckAddonMessage(_, prefix, message, _, sender)
  if type(message) ~= "string" or not self:IsReadyCheckSenderInGroup(sender) then
    return
  end

  if prefix == T5_PREFIX then
    local command, pack, version = strsplit(":", message)
    local supportedPack = pack == T5_PACK_KEY or pack == T6_PACK_KEY or pack == T6_ASSIGNMENTS_PACK_KEY
    if command == "REQ" and supportedPack then
      local localVersion
      if pack == T5_PACK_KEY then
        localVersion = NormalizeReportedVersion(GetLocalT5Version())
      elseif pack == T6_PACK_KEY then
        localVersion = NormalizeReportedVersion(GetLocalT6Version())
      else
        localVersion = NormalizeReportedVersion(GetLocalT6AssignmentsVersion())
      end
      if localVersion and NormalizeName(sender) ~= NormalizeName(GetUnitFullName("player")) then
        SendT5Payload("WA:" .. pack .. ":" .. localVersion, "WHISPER", sender)
      end
    elseif command == "WA" and supportedPack and self.readyCheckPackCollectionActive then
      local senderKey = NormalizeName(sender)
      local versionsKey = pack == T5_PACK_KEY and "readyCheckT5Versions"
        or (pack == T6_PACK_KEY and "readyCheckT6Versions" or "readyCheckT6AVersions")
      local respondedKey = pack == T5_PACK_KEY and "readyCheckT5Responded"
        or (pack == T6_PACK_KEY and "readyCheckT6Responded" or "readyCheckT6AResponded")
      self[versionsKey] = self[versionsKey] or {}; self[respondedKey] = self[respondedKey] or {}
      if self[respondedKey][senderKey] then return end
      self[versionsKey][senderKey] = NormalizeReportedVersion(version); self[respondedKey][senderKey] = true
      self:RefreshReadyCheckMember(sender, {
        t5Version = pack == T5_PACK_KEY,
        t6Version = pack == T6_PACK_KEY,
        t6AVersion = pack == T6_ASSIGNMENTS_PACK_KEY,
        layoutCells = true,
      })
    end
    return
  end

  if prefix ~= ADDON_PREFIX then return end

  local requestNonce = message:match("^Q:([%w]+)$")
  if requestNonce then
    local playerName = GetUnitFullName("player")
    if NormalizeName(sender) == NormalizeName(playerName) then
      return
    end

    self.readyCheckRespondedRequests = self.readyCheckRespondedRequests or {}
    local requestKey = NormalizeName(sender) .. ":" .. requestNonce
    local now = GetTime and GetTime() or 0
    for key, sentAt in pairs(self.readyCheckRespondedRequests) do
      if now - (tonumber(sentAt) or 0) > 60 then
        self.readyCheckRespondedRequests[key] = nil
      end
    end
    local previousResponse = self.readyCheckRespondedRequests[requestKey]
    if previousResponse and now - previousResponse < 0.5 then
      return
    end
    self.readyCheckRespondedRequests[requestKey] = now

    local durability = CalculateLocalDurability()
    local durabilityToken = durability ~= nil and tostring(durability) or "x"
    local version = EncodeAddonVersion(GetCanonicalAddonVersion())
    local t5Version = EncodePackVersion(GetLocalT5Version())
    local t6Version = EncodePackVersion(GetLocalT6Version())
    local t6AVersion = EncodePackVersion(GetLocalT6AssignmentsVersion())
    -- Keep the established D response unchanged for older MerfinPlus clients.
    -- Pack presence is a separate nonce-bound response understood by newer
    -- clients, while MERFIN_VC remains available to WeakAura bridges.
    SendAddonPayload(string.format("D:%s:b%s:v%s", requestNonce, durabilityToken, version), "WHISPER", sender)
    SendAddonPayload(
      string.format("P:%s:t5%s:t6%s:t6a%s", requestNonce, t5Version, t6Version, t6AVersion),
      "WHISPER",
      sender
    )
    return
  end

  local packNonce, remoteT5, remoteT6, remoteT6A =
    message:match("^P:([%w]+):t5([^:]+):t6([^:]+):t6a([^:]+)$")
  if packNonce then
    if packNonce ~= self.readyCheckNonce then return end
    if (remoteT5 ~= "x" and not NormalizeReportedVersion(remoteT5))
      or (remoteT6 ~= "x" and not NormalizeReportedVersion(remoteT6))
      or (remoteT6A ~= "x" and not NormalizeReportedVersion(remoteT6A))
    then
      return
    end

    local senderKey = NormalizeName(sender)
    self.readyCheckT5Versions = self.readyCheckT5Versions or {}
    self.readyCheckT5Responded = self.readyCheckT5Responded or {}
    self.readyCheckT6Versions = self.readyCheckT6Versions or {}
    self.readyCheckT6Responded = self.readyCheckT6Responded or {}
    self.readyCheckT6AVersions = self.readyCheckT6AVersions or {}
    self.readyCheckT6AResponded = self.readyCheckT6AResponded or {}
    self.readyCheckT5Versions[senderKey] = DecodePackVersion(remoteT5)
    self.readyCheckT5Responded[senderKey] = true
    self.readyCheckT6Versions[senderKey] = DecodePackVersion(remoteT6)
    self.readyCheckT6Responded[senderKey] = true
    self.readyCheckT6AVersions[senderKey] = DecodePackVersion(remoteT6A)
    self.readyCheckT6AResponded[senderKey] = true
    self:RefreshReadyCheckMember(sender, {
      t5Version = true,
      t6Version = true,
      t6AVersion = true,
      layoutCells = true,
    })
    return
  end

  local responseNonce, durabilityToken, remoteVersion = message:match("^D:([%w]+):b([%w]+):v([^:]+)$")
  if responseNonce then
    if responseNonce ~= self.readyCheckNonce then
      return
    end

    local durability
    if durabilityToken ~= "x" then
      durability = tonumber(durabilityToken)
      if not durability or durability < 0 or durability > DURABILITY_MAX_BASIS_POINTS then
        return
      end
      durability = Round(durability)
    end

    local senderKey = NormalizeName(sender)
    self.readyCheckDurability = self.readyCheckDurability or {}
    self.readyCheckVersions = self.readyCheckVersions or {}
    self.readyCheckVersionResponded = self.readyCheckVersionResponded or {}
    self.readyCheckDurability[senderKey] = durability
    self.readyCheckVersions[senderKey] = NormalizeReportedVersion(remoteVersion)
    self.readyCheckVersionResponded[senderKey] = true
    self:RefreshReadyCheckMember(sender, {
      durability = true,
      version = true,
      layoutCells = true,
    })
    return
  end

  local durabilityText
  responseNonce, durabilityText = message:match("^D:([%w]+):b(%d+)$")
  local legacyWholePercent = false
  if not responseNonce then
    responseNonce, durabilityText = message:match("^D:([%w]+):(%d%d?%d?)$")
    legacyWholePercent = responseNonce and true or false
  end
  if not responseNonce or responseNonce ~= self.readyCheckNonce then
    return
  end

  local durability = tonumber(durabilityText)
  local maximum = legacyWholePercent and 100 or DURABILITY_MAX_BASIS_POINTS
  if not durability or durability < 0 or durability > maximum then
    return
  end
  if legacyWholePercent then
    durability = durability * DURABILITY_BASIS_POINTS_PER_PERCENT
  end
  self.readyCheckDurability = self.readyCheckDurability or {}
  self.readyCheckDurability[NormalizeName(sender)] = Round(durability)
  self:RefreshReadyCheckMember(sender, {
    durability = true,
    layoutCells = true,
  })
end

function MerfinPlus:HandleReadyCheckStart(_, initiator)
  self.readyCheckManualMode = false
  self:CancelReadyCheckHideTimer()
  self.readyCheckStatuses = {}
  self.readyCheckStatusesByName = {}
  self.readyCheckReportSent = false
  self.readyCheckFinished = false

  local initiatorName = ResolveReadyCheckName(initiator)
  local playerName = GetUnitFullName("player")
  if initiatorName and playerName and NormalizeName(initiatorName) == NormalizeName(playerName) then
    local playerGUID = UnitGUID("player")
    if playerGUID then
      self.readyCheckStatuses[playerGUID] = "ready"
    end
    self.readyCheckStatusesByName[NormalizeName(playerName)] = "ready"
  end

  if not self:IsReadyCheckDisplayAllowed() then
    self.readyCheckActive = false
    if self.readyCheckFrame then
      self.readyCheckFrame:Hide()
    end
    return
  end

  self.readyCheckActive = true
  local frame = self:CreateReadyCheckWindow()
  frame:Show()
  self:RequestReadyCheckDurability()
  self:RefreshReadyCheckWindow()

  -- Display Duration is one lifetime for the window. Only a genuinely new
  -- READY_CHECK event may establish a new deadline; confirmations and the
  -- finished event update state without extending it.
  self:ScheduleReadyCheckHide(self:GetReadyCheckSettings().displayDuration)
end

function MerfinPlus:HandleReadyCheckConfirm(_, unit, ready)
  if self.readyCheckManualMode or not self.readyCheckActive then
    return
  end

  local status = ready and "ready" or "notready"
  local guid = unit and UnitGUID(unit)
  local fullName = unit and GetUnitFullName(unit)
  if guid then
    self.readyCheckStatuses[guid] = status
  end
  if fullName then
    self.readyCheckStatusesByName[NormalizeName(fullName)] = status
  elseif type(unit) == "string" then
    self.readyCheckStatusesByName[NormalizeName(unit)] = status
  end
  self:RefreshReadyCheckMember(unit or fullName or "", {
    status = true,
  })
end

local function SendMissingList(label, names)
  if #names == 0 then
    return
  end

  local prefix = string.format(MerfinPlus:T("Ready Check - Missing %s: "), MerfinPlus:T(label))
  local message = prefix
  for index, name in ipairs(names) do
    local addition = (message == prefix and "" or ", ") .. name
    if #message + #addition > 235 and message ~= prefix then
      SendGroupChat(message)
      message = prefix .. name
    else
      message = message .. addition
    end
  end
  if message ~= prefix then
    SendGroupChat(message)
  end
end

function MerfinPlus:ReportReadyCheckCategories()
  if self.readyCheckReportSent then
    return
  end

  local settings = self:GetReadyCheckSettings()
  local selectedCategories = {}
  for _, category in ipairs(REPORT_CATEGORIES) do
    if settings[category.reportSetting] then
      selectedCategories[#selectedCategories + 1] = {
        category = category,
        missing = {},
      }
    end
  end
  if #selectedCategories == 0 then
    return
  end
  self.readyCheckReportSent = true

  local members = self:BuildReadyCheckRoster()
  for _, member in ipairs(members) do
    if not IsReadyCheckMemberOffline(member) then
      local auras = ScanUnitAuras(member.unit)
      for _, selected in ipairs(selectedCategories) do
        local category = selected.category
        local present = category.flaskElixirs and GetFlaskElixirState(auras)
          or (category.auraKey and auras[category.auraKey])
        if not present then
          selected.missing[#selected.missing + 1] = member.name
        end
      end
    end
  end

  for _, selected in ipairs(selectedCategories) do
    SendMissingList(selected.category.label, selected.missing)
  end
end

function MerfinPlus:HandleReadyCheckFinished()
  if self.readyCheckManualMode then return end
  if not self.readyCheckActive or self.readyCheckFinished then
    return
  end
  self.readyCheckFinished = true

  -- Blizzard's native ready-check display converts unanswered players to the
  -- not-ready state when the check times out. Mirror that final state even if
  -- GetReadyCheckStatus has already been cleared by the client.
  local frame = self.readyCheckFrame
  local members = frame and frame.members or self:BuildReadyCheckRoster()
  for _, member in ipairs(members) do
    if self:GetStoredReadyStatus(member) == "waiting" then
      self.readyCheckStatuses[member.key] = "notready"
      self.readyCheckStatusesByName[member.nameKey] = "notready"
    end
    if member.row then
      self:RenderReadyCheckMember(member, { status = true })
    end
  end
  self:UpdateReadyCheckResponseCount()
  self:ReportReadyCheckCategories()
end

function MerfinPlus:OpenManualReadyCheck()
  local settings = self:GetReadyCheckSettings()
  if not settings.enableSlashMerfinRT then
    local message = "|cff57d9ffMerfinPlus:|r "
      .. self:T("Enable 'Enable use /merfinrt' in Ready Check settings first.")
    if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
      DEFAULT_CHAT_FRAME:AddMessage(message)
    elseif type(print) == "function" then
      print(message)
    end
    return false
  end

  self:CancelReadyCheckHideTimer()
  self:CancelReadyCheckCountdownTimer()
  self.readyCheckManualMode = true
  self.readyCheckActive = true
  self.readyCheckFinished = false
  self.readyCheckReportSent = false
  self.readyCheckStatuses = {}
  self.readyCheckStatusesByName = {}

  local frame = self:CreateReadyCheckWindow()
  frame.countdownDuration = nil
  frame.countdownEndsAt = nil
  frame.countdownDisplayedSecond = nil
  frame:Show()
  self:RequestReadyCheckDurability()
  self:RefreshReadyCheckWindow()
  frame.titleBar:SetMinMaxValues(0, 1)
  frame.titleBar:SetValue(1)
  frame.titleText:SetText(self:T("MP: Manual Raid Check"))
  self:UpdateReadyCheckResponseCount()
  return true
end

function MerfinPlus:HandleReadyCheckUnitAura(_, unit)
  if not self.readyCheckActive or not self.readyCheckFrame or not self.readyCheckFrame:IsShown() then
    return
  end
  if unit == "player" or tostring(unit):match("^party%d+$") or tostring(unit):match("^raid%d+$") then
    self:QueueReadyCheckAuraRefresh(unit)
  end
end

function MerfinPlus:HandleReadyCheckRosterUpdate()
  if not self.readyCheckActive then
    return
  end
  if not GetGroupChannel() then
    self.readyCheckActive = false
    self:CancelReadyCheckHideTimer()
    if self.readyCheckFrame then
      self.readyCheckFrame:Hide()
    end
    return
  end
  self:RefreshReadyCheckWindow()
end

function MerfinPlus:HandleReadyCheckUnitConnection()
  if self.readyCheckActive and self.readyCheckFrame and self.readyCheckFrame:IsShown() then
    self:RefreshReadyCheckWindow()
  end
end

function MerfinPlus:InitializeReadyCheck()
  if self.readyCheckInitialized then
    return
  end
  self.readyCheckInitialized = true
  self:GetReadyCheckSettings()

  for category, spellIDs in pairs(CATEGORY_SPELLS) do
    for _, spellID in ipairs(spellIDs) do
      SPELL_CATEGORY_BY_ID[spellID] = category
      local spellName = GetSpellInfo and GetSpellInfo(spellID)
      if spellName then
        SPELL_CATEGORY_BY_NAME[spellName] = category
      end
    end
  end

  local registerPrefix = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix
  if registerPrefix then
    pcall(registerPrefix, ADDON_PREFIX)
    pcall(registerPrefix, T5_PREFIX)
  end

  -- A dedicated frame prevents this module from replacing AceEvent handlers
  -- already registered on the shared MerfinPlus addon object (Pull Timer uses
  -- CHAT_MSG_ADDON and GROUP_ROSTER_UPDATE as well).
  local eventFrame = CreateFrame("Frame")
  eventFrame:RegisterEvent("READY_CHECK")
  eventFrame:RegisterEvent("READY_CHECK_CONFIRM")
  eventFrame:RegisterEvent("READY_CHECK_FINISHED")
  eventFrame:RegisterEvent("CHAT_MSG_ADDON")
  eventFrame:RegisterEvent("UNIT_AURA")
  eventFrame:RegisterEvent("UNIT_CONNECTION")
  eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
  eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "READY_CHECK" then
      MerfinPlus:HandleReadyCheckStart(event, ...)
    elseif event == "READY_CHECK_CONFIRM" then
      MerfinPlus:HandleReadyCheckConfirm(event, ...)
    elseif event == "READY_CHECK_FINISHED" then
      MerfinPlus:HandleReadyCheckFinished(event, ...)
    elseif event == "CHAT_MSG_ADDON" then
      MerfinPlus:HandleReadyCheckAddonMessage(event, ...)
    elseif event == "UNIT_AURA" then
      MerfinPlus:HandleReadyCheckUnitAura(event, ...)
    elseif event == "UNIT_CONNECTION" then
      MerfinPlus:HandleReadyCheckUnitConnection(event, ...)
    elseif event == "GROUP_ROSTER_UPDATE" then
      MerfinPlus:HandleReadyCheckRosterUpdate(event, ...)
    end
  end)
  self.readyCheckEventFrame = eventFrame
end

if SlashCmdList then
  SLASH_MERFINPLUSRAIDTEST1 = "/merfinrt"
  SlashCmdList["MERFINPLUSRAIDTEST"] = function()
    MerfinPlus:OpenManualReadyCheck()
  end
end
