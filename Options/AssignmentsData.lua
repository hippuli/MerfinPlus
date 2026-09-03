-- General Assignments import data, based on the local Guild Manager MGMGA schema.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local CLASS_NAME_TO_TOKEN = {
  warrior = "WARRIOR",
  paladin = "PALADIN",
  hunter = "HUNTER",
  rogue = "ROGUE",
  priest = "PRIEST",
  shaman = "SHAMAN",
  mage = "MAGE",
  warlock = "WARLOCK",
  druid = "DRUID",
  demonhunter = "DEMONHUNTER",
  ["demon hunter"] = "DEMONHUNTER",
}

-- Used only to recover MGMGA payloads that were flattened by a single-line
-- EditBox before they reached the parser. Longest names must come first.
local CLASS_SPEC_NAMES = {
  WARRIOR = { "Protection", "Fury", "Arms" },
  PALADIN = { "Retribution", "Protection", "Holy" },
  HUNTER = { "Beast Mastery", "Marksmanship", "Survival" },
  ROGUE = { "Assassination", "Subtlety", "Combat" },
  PRIEST = { "Discipline", "Shadow", "Holy" },
  SHAMAN = { "Restoration", "Enhancement", "Elemental" },
  MAGE = { "Arcane", "Frost", "Fire" },
  WARLOCK = { "Destruction", "Demonology", "Affliction" },
  DRUID = { "Restoration", "Feral Combat", "Balance", "Feral" },
  DEMONHUNTER = { "Vengeance", "Devourer", "Havoc" },
}

local CLASS_ICON_TEXTURES = {
  WARRIOR = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\WARRIOR.tga",
  PALADIN = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\PALADIN.tga",
  HUNTER = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\HUNTER.tga",
  ROGUE = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\ROGUE.tga",
  PRIEST = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\PRIEST.tga",
  SHAMAN = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\SHAMAN.tga",
  MAGE = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\MAGE.tga",
  WARLOCK = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\WARLOCK.tga",
  DRUID = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\DRUID.tga",
  DEMONHUNTER = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\DEMONHUNTER.tga",
}

local SPEC_ICON_TEXTURES = {
  WARRIOR = {
    arms = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\warrior_arms.tga",
    fury = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\warrior_fury.tga",
    protection = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\warrior_protection.tga",
  },
  PALADIN = {
    holy = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\paladin_holy.tga",
    protection = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\paladin_protection.tga",
    retribution = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\paladin_retribution.tga",
  },
  HUNTER = {
    beastmastery = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\hunter_beastmastery.tga",
    marksmanship = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\hunter_marksmanship.tga",
    survival = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\hunter_survival.tga",
  },
  ROGUE = {
    assassination = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\rogue_assassination.tga",
    combat = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\rogue_combat.tga",
    subtlety = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\rogue_subtlety.tga",
  },
  PRIEST = {
    discipline = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\priest_discipline.tga",
    holy = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\priest_holy.tga",
    shadow = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\priest_shadow.tga",
    smite = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\priest_smite.tga",
  },
  SHAMAN = {
    elemental = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\shaman_elemental.tga",
    enhancement = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\shaman_enhancement.tga",
    restoration = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\shaman_restoration.tga",
  },
  MAGE = {
    arcane = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\mage_arcane.tga",
    fire = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\mage_fire.tga",
    frost = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\mage_frost.tga",
  },
  WARLOCK = {
    affliction = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\warlock_affliction.tga",
    demonology = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\warlock_demonology.tga",
    destruction = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\warlock_destruction.tga",
  },
  DRUID = {
    balance = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\druid_balance.tga",
    feral = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\druid_feral.tga",
    feralcombat = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\druid_feral.tga",
    restoration = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\druid_restoration.tga",
  },
  DEMONHUNTER = {
    devourer = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\demonhunter_devourer.tga",
    havoc = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\demonhunter_havoc.tga",
    vengeance = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Specs\\demonhunter_vengeance.tga",
  },
}

local SPEC_ICON_FALLBACK_SPELLS = {
  WARRIOR = { arms = 12294, fury = 23881, protection = 2565 },
  PALADIN = { holy = 635, protection = 31935, retribution = 20271 },
  HUNTER = { beastmastery = 34026, marksmanship = 19434, survival = 1499 },
  ROGUE = { assassination = 1329, combat = 1752, subtlety = 1784 },
  PRIEST = { discipline = 17, holy = 2060, shadow = 589, smite = 585 },
  SHAMAN = { elemental = 403, enhancement = 17364, restoration = 1064 },
  MAGE = { arcane = 5143, fire = 133, frost = 116 },
  WARLOCK = { affliction = 980, demonology = 687, destruction = 29722 },
  DRUID = { balance = 5176, feral = 768, feralcombat = 768, restoration = 774 },
}

local ROLE_ICON_TEXTURES = {
  tank = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\tank.tga",
  heal = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\heal.tga",
  dps = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\dps.tga",
}

local CLASS_COLORS = {
  WARRIOR = { 0.78, 0.61, 0.43 },
  PALADIN = { 0.96, 0.55, 0.73 },
  HUNTER = { 0.67, 0.83, 0.45 },
  ROGUE = { 1.00, 0.96, 0.41 },
  PRIEST = { 1.00, 1.00, 1.00 },
  SHAMAN = { 0.00, 0.44, 0.87 },
  MAGE = { 0.25, 0.78, 0.92 },
  WARLOCK = { 0.53, 0.53, 0.93 },
  DRUID = { 1.00, 0.49, 0.04 },
  DEMONHUNTER = { 0.64, 0.19, 0.79 },
}

local ASSIGNMENT_DISPLAY_LABELS = {
  battleshout = "Battle Shout",
  bloodlust = "Bloodlust",
  cc = "CC",
  commandingshout = "Commanding Shout",
  curse = "Curse",
  demoshout = "Demoralizing Shout",
  exposearmor = "Expose Armor",
  faeriefire = "Faerie Fire",
  fearward = "Fear Ward",
  fortitude = "Fortitude",
  huntersmark = "Hunter's Mark",
  intellect = "Intellect",
  innervate = "Innervate",
  judgement = "Judgement",
  maintank = "Main Tank",
  markofthewild = "Mark of the Wild",
  misdirection = "Misdirection",
  mt = "Main Tank",
  mtot = "Main Tank / Off Tank",
  offtank = "Off Tank",
  painsuppression = "Pain Suppression",
  powerinfusion = "Power Infusion",
  raid = "Raid",
  sheep = "Sheep",
  soulstone = "Soulstone",
  spirit = "Spirit",
  thorns = "Thorns",
  thunderclap = "Thunder Clap",
}

local TARGET_DISPLAY_LABELS = {
  assigned = "",
  main = "Main",
  backup = "Backup",
  maintarget = "Main Target",
  offtarget = "Off Target",
  lightmaintarget = "Main Target",
  lightofftarget = "Off Target",
  wisdommaintarget = "Main Target",
  wisdomofftarget = "Off Target",
  justicemaintarget = "Main Target",
  justiceofftarget = "Off Target",
  crusadermaintarget = "Main Target",
  crusaderofftarget = "Off Target",
  elements = "Elements",
  agony = "Agony",
}

local ASSIGNMENT_ICON_SPELLS = {
  battleshout = { id = 6673, icon = "Interface\\Icons\\Ability_Warrior_BattleShout" },
  bloodlust = { id = 2825, icon = "Interface\\Icons\\Spell_Nature_BloodLust" },
  cc = { icon = "Interface\\Icons\\Spell_Shadow_Possession" },
  commandingshout = { id = 469, icon = "Interface\\Icons\\Ability_Warrior_RallyingCry" },
  curse = { id = 980, icon = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde" },
  demoshout = { id = 1160, icon = "Interface\\Icons\\Ability_Warrior_WarCry" },
  exposearmor = { id = 8647, icon = "Interface\\Icons\\Ability_Warrior_Riposte" },
  faeriefire = { id = 770, icon = "Interface\\Icons\\Spell_Nature_FaerieFire" },
  fearward = { id = 6346, icon = "Interface\\Icons\\Spell_Holy_Excorcism" },
  fortitude = { id = 1243, icon = "Interface\\Icons\\Spell_Holy_WordFortitude" },
  huntersmark = { id = 1130, icon = "Interface\\Icons\\Ability_Hunter_SniperShot" },
  innervate = { id = 29166, icon = "Interface\\Icons\\Spell_Nature_Lightning" },
  intellect = { id = 1459, icon = "Interface\\Icons\\Spell_Holy_MagicalSentry" },
  judgement = { id = 20271, icon = "Interface\\Icons\\Spell_Holy_RighteousFury" },
  maintank = { icon = ROLE_ICON_TEXTURES.tank },
  markofthewild = { id = 1126, icon = "Interface\\Icons\\Spell_Nature_Regeneration" },
  misdirection = { id = 34477, icon = "Interface\\Icons\\Ability_Hunter_Misdirection" },
  mt = { icon = ROLE_ICON_TEXTURES.heal },
  mtot = { icon = ROLE_ICON_TEXTURES.heal },
  offtank = { icon = ROLE_ICON_TEXTURES.tank },
  painsuppression = { id = 33206, icon = "Interface\\Icons\\Spell_Holy_PainSupression" },
  powerinfusion = { id = 10060, icon = "Interface\\Icons\\Spell_Holy_PowerInfusion" },
  raid = { icon = ROLE_ICON_TEXTURES.heal },
  sheep = { id = 118, icon = "Interface\\Icons\\Spell_Nature_Polymorph" },
  soulstone = { id = 20707, icon = "Interface\\Icons\\Spell_Shadow_SoulGem" },
  spirit = { id = 14752, icon = "Interface\\Icons\\Spell_Holy_DivineSpirit" },
  thorns = { id = 467, icon = "Interface\\Icons\\Spell_Nature_Thorns" },
  thunderclap = { id = 6343, icon = "Interface\\Icons\\Ability_ThunderClap" },
}

local JUDGEMENT_ASSIGNMENT_SPELLS = {
  crusader = { label = "Judgement of the Crusader", id = 27158, icon = "Interface\\Icons\\Spell_Holy_HolySmite" },
  justice = { label = "Judgement of Justice", id = 20164, icon = "Interface\\Icons\\Spell_Holy_SealOfWrath" },
  light = { label = "Judgement of Light", id = 27160, icon = "Interface\\Icons\\Spell_Holy_HealingAura" },
  wisdom = { label = "Judgement of Wisdom", id = 27166, icon = "Interface\\Icons\\Spell_Holy_RighteousnessAura" },
}

local RAID_TARGET_ASSIGNMENT_ICONS = {
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

local function Trim(value)
  value = tostring(value or "")
  value = value:gsub("^%s+", ""):gsub("%s+$", "")
  value = value:gsub("^\239\187\191", "")
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function NormalizeName(value)
  return tostring(value or ""):lower():gsub("[%s%p%c]+", "")
end

local function CleanPlayerName(name)
  local clean = tostring(name or "")
  local dash = clean:find("-", 1, true)
  return dash and clean:sub(1, dash - 1) or clean
end

local function TitleCaseToken(value)
  value = Trim(value):gsub("[_%-%s]+", " ")
  value = value:gsub("(%l)(%u)", "%1 %2")
  return value:gsub("(%a)([%w']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
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

local function ExtractPipedFields(line)
  line = tostring(line or "")
  local firstPipe = line:find("|", 1, true)
  if not firstPipe then
    return Trim(line), "", ""
  end
  local secondPipe = line:find("|", firstPipe + 1, true)
  if not secondPipe then
    return Trim(line:sub(1, firstPipe - 1)), Trim(line:sub(firstPipe + 1)), ""
  end
  return Trim(line:sub(1, firstPipe - 1)), Trim(line:sub(firstPipe + 1, secondPipe - 1)), Trim(line:sub(secondPipe + 1))
end

local SplitAssignmentAndTarget

local function CountPipes(line)
  local _, count = tostring(line or ""):gsub("|", "")
  return count
end

local function SplitFlattenedPlayerRows(line)
  local fields = SplitPipes(line)
  if #fields <= 3 or (#fields % 2) ~= 1 then
    return nil
  end

  local rows = {}
  local playerName = Trim(fields[1])
  local fieldIndex = 2
  while fieldIndex + 1 <= #fields do
    local className = Trim(fields[fieldIndex])
    local classToken = CLASS_NAME_TO_TOKEN[NormalizeName(className)]
    local specAndNextPlayer = Trim(fields[fieldIndex + 1])
    local specs = classToken and CLASS_SPEC_NAMES[classToken]
    local spec
    local nextPlayer = ""

    for _, candidate in ipairs(specs or {}) do
      local candidateLength = #candidate
      if specAndNextPlayer:sub(1, candidateLength):lower() == candidate:lower() then
        local remainder = specAndNextPlayer:sub(candidateLength + 1)
        if remainder == "" or remainder:match("^%s+") then
          spec = Trim(specAndNextPlayer:sub(1, candidateLength))
          nextPlayer = Trim(remainder)
          break
        end
      end
    end

    local hasAnotherRow = fieldIndex + 2 <= #fields
    if playerName == "" or not classToken or not spec or (hasAnotherRow and nextPlayer == "") then
      return nil
    end

    rows[#rows + 1] = {
      name = CleanPlayerName(playerName),
      class = className,
      spec = spec,
      classToken = classToken,
    }
    playerName = nextPlayer
    fieldIndex = fieldIndex + 2
  end

  return #rows > 1 and rows or nil
end

local function SplitFlattenedAssignmentRows(line, players)
  if CountPipes(line) <= 2 or #(players or {}) == 0 then
    return nil
  end

  local lowerLine = tostring(line or ""):lower()
  local starts = { 1 }
  local seenStarts = { [1] = true }
  for _, player in ipairs(players) do
    local playerName = tostring(player.name or "")
    if playerName ~= "" then
      local needle = " " .. playerName:lower() .. "|"
      local searchFrom = 1
      while true do
        local matchStart = lowerLine:find(needle, searchFrom, true)
        if not matchStart then
          break
        end
        local rowStart = matchStart + 1
        if not seenStarts[rowStart] then
          starts[#starts + 1] = rowStart
          seenStarts[rowStart] = true
        end
        searchFrom = matchStart + #needle
      end
    end
  end

  if #starts <= 1 then
    return nil
  end
  table.sort(starts)

  local knownPlayers = {}
  for _, player in ipairs(players) do
    knownPlayers[NormalizeName(player.name)] = true
  end

  local rows = {}
  for index, rowStart in ipairs(starts) do
    local nextStart = starts[index + 1]
    local rowEnd = nextStart and (nextStart - 2) or #line
    local fragment = Trim(line:sub(rowStart, rowEnd))
    local first, second, third = ExtractPipedFields(fragment)
    if not knownPlayers[NormalizeName(first)] or second == "" or CountPipes(fragment) > 2 then
      return nil
    end
    second, third = SplitAssignmentAndTarget(second, third)
    rows[#rows + 1] = {
      player = CleanPlayerName(first),
      assignment = second,
      target = third,
    }
  end

  return #rows > 1 and rows or nil
end

SplitAssignmentAndTarget = function(assignment, target)
  assignment = Trim(assignment)
  target = Trim(target)
  if target == "" then
    local pipe = assignment:find("|", 1, true)
    if pipe then
      target = Trim(assignment:sub(pipe + 1))
      assignment = Trim(assignment:sub(1, pipe - 1))
    end
  end
  return assignment, target
end

local function NormalizeAssignmentRawText(raw)
  raw = tostring(raw or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
  raw = raw:gsub("\\r\\n", "\n"):gsub("\\n", "\n")
  raw = raw:gsub("^\239\187\191", ""):gsub("\239\187\191", "")
  raw = raw:gsub("\226\128\139", ""):gsub("\226\128\140", ""):gsub("\226\128\141", "")
  raw = raw:gsub("\194\160", " ")
  raw = raw:gsub("|+", "|")
  raw = raw:gsub("MGMGA%s*|%s*", "MGMGA|")
  raw = raw:gsub("META%s*|%s*", "META|")
  raw = raw:gsub("(MGMGA|%d+)%s*(META|)", "%1\nMETA|")
  raw = raw:gsub("([^%s])(%[[^%]]+%])", "%1\n%2")
  raw = raw:gsub("(%S)%s+(%[[^%]]+%])", "%1\n%2")
  raw = raw:gsub("(%])([^%s%[]+|)", "%1\n%2")
  raw = raw:gsub("(%])%s+([^%s%[]+|)", "%1\n%2")
  raw = raw:gsub("(//)(%[[^%]]+%])", "%1\n%2")
  raw = raw:gsub("(//)%s+(%[[^%]]+%])", "%1\n%2")
  raw = raw:gsub("%s*//%s*", "\n//\n")
  raw = raw:gsub("\n\n+", "\n")
  return Trim(raw)
end

local function BuildNormalizedGeneralAssignments(parsed)
  local output = {
    tostring(parsed.protocol or "MGMGA") .. "|" .. tostring(parsed.version or 1),
    "META|" .. tostring(parsed.expansion or "") .. "|" .. tostring(parsed.raidKey or "") .. "|" .. tostring(parsed.label or ""),
    "[Players]",
  }
  for _, player in ipairs(parsed.players or {}) do
    output[#output + 1] = tostring(player.name or "") .. "|" .. tostring(player.class or "") .. "|" .. tostring(player.spec or "")
  end
  for _, section in ipairs(parsed.sections or {}) do
    if section.name ~= "Players" and #(section.rows or {}) > 0 then
      output[#output + 1] = "//"
      output[#output + 1] = "[" .. tostring(section.name or "") .. "]"
      for _, row in ipairs(section.rows or {}) do
        local value = tostring(row.player or "") .. "|" .. tostring(row.assignment or "")
        if row.target and row.target ~= "" then
          value = value .. "|" .. tostring(row.target)
        end
        output[#output + 1] = value
      end
    end
  end
  return table.concat(output, "\n")
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
  return date and date("%Y-%m-%d %H:%M:%S", timestamp) or tostring(timestamp or "")
end

local function GetCurrentExpansionKey()
  if MerfinPlus.GetExportExpansionInfo then
    local expansion = MerfinPlus:GetExportExpansionInfo()
    if expansion then
      return expansion
    end
  end
  return MerfinPlus.IsTBC() and "tbc" or ""
end

local function GetSpellIconTexture(spellID)
  if C_Spell and C_Spell.GetSpellTexture then
    local texture = C_Spell.GetSpellTexture(spellID)
    if texture then
      return texture
    end
  end
  if GetSpellTexture then
    local texture = GetSpellTexture(spellID)
    if texture then
      return texture
    end
  end
  if GetSpellInfo then
    local _, _, texture = GetSpellInfo(spellID)
    return texture
  end
end

local function GetJudgementAssignment(target)
  local normalized = NormalizeName(target)
  for key, spell in pairs(JUDGEMENT_ASSIGNMENT_SPELLS) do
    if normalized:find(key, 1, true) then
      return spell, key
    end
  end
end

local function FormatTargetLabel(target)
  target = Trim(target)
  if target == "" then
    return ""
  end
  local groupStart, groupEnd = target:lower():match("^group%-(%d+)%-(%d+)$")
  if groupStart and groupEnd then
    return "Group " .. groupStart .. "-" .. groupEnd
  end
  local groupSingle = target:lower():match("^group%-(%d+)$")
  if groupSingle then
    return "Group " .. groupSingle
  end
  return TARGET_DISPLAY_LABELS[NormalizeName(target)] or TitleCaseToken(target)
end

function MerfinPlus:GetGeneralAssignmentStorage()
  if not self.db or not self.db.global then
    self.generalAssignmentFallbackStorage = self.generalAssignmentFallbackStorage or {
      generalImports = {},
      generalCollapsedSections = {},
    }
    return self.generalAssignmentFallbackStorage
  end
  self.db.global.assignments = self.db.global.assignments or {}
  local storage = self.db.global.assignments
  storage.generalImports = storage.generalImports or {}
  storage.generalCollapsedSections = storage.generalCollapsedSections or {}
  storage.viewState = storage.viewState or {}
  return storage
end

function MerfinPlus:GetGeneralAssignmentImports()
  return self:GetGeneralAssignmentStorage().generalImports
end

function MerfinPlus:GetGeneralAssignmentUIState()
  self.generalAssignmentUIState = self.generalAssignmentUIState or {
    input = "",
    status = "",
    statusTone = "muted",
  }
  return self.generalAssignmentUIState
end

function MerfinPlus:GetGeneralAssignmentClassToken(className)
  local lower = tostring(className or ""):lower()
  local compact = NormalizeName(lower)
  return CLASS_NAME_TO_TOKEN[lower] or CLASS_NAME_TO_TOKEN[lower:gsub("%s+", "")] or CLASS_NAME_TO_TOKEN[compact]
end

function MerfinPlus:GetGeneralAssignmentClassIcon(classToken)
  return classToken and CLASS_ICON_TEXTURES[classToken] or nil
end

function MerfinPlus:GetGeneralAssignmentSpecIcon(classToken, spec)
  local specKey = NormalizeName(spec)
  local textures = classToken and SPEC_ICON_TEXTURES[classToken]
  local fallbackSpells = classToken and SPEC_ICON_FALLBACK_SPELLS[classToken]
  local path = textures and textures[specKey] or nil
  local fallback = fallbackSpells and GetSpellIconTexture(fallbackSpells[specKey]) or nil
  if not path and not fallback then
    return nil
  end
  return {
    path = path,
    fallback = fallback,
  }
end

function MerfinPlus:GetGeneralAssignmentClassColor(classToken)
  local colors = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken])
    or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken])
    or CLASS_COLORS[classToken]
    or { 0.9, 0.9, 0.9 }
  return colors.r or colors[1], colors.g or colors[2], colors.b or colors[3]
end

function MerfinPlus:GetGeneralAssignmentRoleIcon(classToken, spec)
  local key = NormalizeName(spec)
  if key == "" then
    return nil
  end
  if key:find("tank", 1, true) or key == "protection" or key == "guardian" then
    return ROLE_ICON_TEXTURES.tank
  end
  if key:find("heal", 1, true) or key == "holy" or key == "discipline" or key == "restoration" then
    return ROLE_ICON_TEXTURES.heal
  end
  return ROLE_ICON_TEXTURES.dps
end

function MerfinPlus:GetGeneralAssignmentSectionDisplay(sectionName)
  local label = Trim(sectionName)
  local displayLabel = self:LocalizeAssignmentSection(label)
  local key = NormalizeName(label)
  local classToken = self:GetGeneralAssignmentClassToken(label)
  if classToken then
    return displayLabel, CLASS_ICON_TEXTURES[classToken]
  elseif key:find("tank", 1, true) then
    return displayLabel, ROLE_ICON_TEXTURES.tank
  elseif key:find("heal", 1, true) then
    return displayLabel, ROLE_ICON_TEXTURES.heal
  elseif key:find("dps", 1, true) or key:find("damage", 1, true) then
    return displayLabel, ROLE_ICON_TEXTURES.dps
  end
  return displayLabel, nil
end

function MerfinPlus:GetGeneralAssignmentSpellDisplay(task)
  local assignment, target = SplitAssignmentAndTarget(task and task.assignment or "", task and task.target or "")
  local key = NormalizeName(assignment)
  if key == "judgement" then
    local judgement = GetJudgementAssignment(target)
    if judgement then
      return judgement.label, GetSpellIconTexture(judgement.id) or judgement.icon
    end
  end
  local iconData = ASSIGNMENT_ICON_SPELLS[key]
  local icon
  if iconData then
    icon = (iconData.id and GetSpellIconTexture(iconData.id)) or iconData.icon
  end
  local label = ASSIGNMENT_DISPLAY_LABELS[key] or TitleCaseToken(assignment)
  return self:LocalizeKnownValue(label, iconData and iconData.id), icon
end

function MerfinPlus:GetGeneralAssignmentTargetDisplay(task, parsed)
  local _, target = SplitAssignmentAndTarget(task and task.assignment or "", task and task.target or "")
  if target == "" or NormalizeName(target) == "assigned" then
    return "", nil, nil, false
  end
  local markerIcon = RAID_TARGET_ASSIGNMENT_ICONS[NormalizeName(target)]
  if markerIcon then
    return "", nil, markerIcon, true
  end
  local normalizedTarget = NormalizeName(CleanPlayerName(target))
  for _, player in ipairs(parsed and parsed.players or {}) do
    if NormalizeName(player.name) == normalizedTarget then
      local classToken = player.classToken or self:GetGeneralAssignmentClassToken(player.class)
      return player.name, classToken, self:GetGeneralAssignmentClassIcon(classToken), false
    end
  end
  return FormatTargetLabel(target), nil, nil, false
end

function MerfinPlus:NormalizeGeneralAssignmentString(raw)
  return NormalizeAssignmentRawText(raw)
end

function MerfinPlus:ParseGeneralAssignments(raw)
  raw = NormalizeAssignmentRawText(raw)
  local parsed = {
    protocol = "MGMGA",
    version = 1,
    expansion = "",
    raidKey = "",
    label = "",
    players = {},
    playerMap = {},
    sections = {},
  }
  local foundHeader, foundMeta = false, false
  local lines = {}
  for line in (raw .. "\n"):gmatch("([^\n]*)\n") do
    line = Trim(line)
    if line ~= "" then
      lines[#lines + 1] = line
      local version = line:match("MGMGA%s*|%s*(%d+)")
      if version then
        foundHeader = true
        parsed.version = tonumber(version) or 1
      end
      local metaStart = line:find("META|", 1, true)
      if metaStart then
        local fields = SplitPipes(line:sub(metaStart))
        foundMeta = true
        parsed.expansion = Trim(fields[2])
        parsed.raidKey = Trim(fields[3])
        parsed.label = Trim(fields[4])
      end
    end
  end

  local currentSection
  for _, line in ipairs(lines) do
    if line ~= "//" and not line:find("MGMGA|", 1, true) and not line:find("META|", 1, true) then
      local sectionName = line:match("^%[(.-)%]$")
      if sectionName then
        currentSection = { name = sectionName, rows = {} }
        parsed.sections[#parsed.sections + 1] = currentSection
      elseif currentSection then
        if currentSection.name == "Players" then
          local recoveredPlayers = SplitFlattenedPlayerRows(line)
          if recoveredPlayers then
            for _, player in ipairs(recoveredPlayers) do
              parsed.players[#parsed.players + 1] = player
              parsed.playerMap[player.name] = player
            end
          else
            local first, second, third = ExtractPipedFields(line)
            if second == "" and third ~= "" then
              second, third = SplitAssignmentAndTarget(third, "")
            else
              second, third = SplitAssignmentAndTarget(second, third)
            end
            if first ~= "" then
              local player = {
                name = CleanPlayerName(first),
                class = second,
                spec = third,
                classToken = self:GetGeneralAssignmentClassToken(second),
              }
              parsed.players[#parsed.players + 1] = player
              parsed.playerMap[player.name] = player
            end
          end
        else
          local recoveredRows = SplitFlattenedAssignmentRows(line, parsed.players)
          if recoveredRows then
            for _, row in ipairs(recoveredRows) do
              currentSection.rows[#currentSection.rows + 1] = row
            end
          else
            local first, second, third = ExtractPipedFields(line)
            if second == "" and third ~= "" then
              second, third = SplitAssignmentAndTarget(third, "")
            else
              second, third = SplitAssignmentAndTarget(second, third)
            end
            if first ~= "" or second ~= "" then
              currentSection.rows[#currentSection.rows + 1] = {
                player = CleanPlayerName(first),
                assignment = second,
                target = third,
              }
            end
          end
        end
      end
    elseif line == "//" then
      currentSection = nil
    end
  end

  if not foundHeader and (#parsed.players > 0 or #parsed.sections > 0) then
    foundHeader = true
    parsed.version = 1
  end
  if (not foundMeta or parsed.expansion == "") and (#parsed.players > 0 or #parsed.sections > 0) then
    foundMeta = true
    parsed.expansion = GetCurrentExpansionKey()
    parsed.raidKey = ""
    parsed.label = parsed.label ~= "" and parsed.label or "General Assignments"
  end
  if parsed.protocol ~= "MGMGA" or parsed.expansion == "" or (#parsed.players == 0 and #parsed.sections == 0) then
    local detail = "header=" .. tostring(foundHeader)
      .. ", meta=" .. tostring(foundMeta)
      .. ", players=" .. tostring(#parsed.players)
      .. ", sections=" .. tostring(#parsed.sections)
    return nil, "Invalid General Assignments string (" .. detail .. ")."
  end
  parsed.normalizedRaw = BuildNormalizedGeneralAssignments(parsed)
  return parsed
end

function MerfinPlus:FindGeneralAssignmentImport(importID)
  for _, entry in ipairs(self:GetGeneralAssignmentImports()) do
    if entry.id == importID then
      return entry
    end
  end
end

function MerfinPlus:GetSelectedGeneralAssignmentImport()
  local storage = self:GetGeneralAssignmentStorage()
  local selected = self:FindGeneralAssignmentImport(storage.activeGeneralImportId)
  if not selected then
    local imports = storage.generalImports
    selected = imports[#imports]
    storage.activeGeneralImportId = selected and selected.id or nil
  end
  if selected and selected.raw then
    selected.parsed, selected.parseError = self:ParseGeneralAssignments(selected.raw)
  end
  return selected
end

function MerfinPlus:SetSelectedGeneralAssignmentImport(importID)
  local entry = self:FindGeneralAssignmentImport(importID)
  if entry then
    self:GetGeneralAssignmentStorage().activeGeneralImportId = entry.id
    self:NotifyGeneralAssignmentsChanged()
  end
  return entry
end

function MerfinPlus:GetGeneralAssignmentImportName(entry)
  if not entry then
    return "No saved imports"
  end
  local label = entry.label and entry.label ~= "" and entry.label or entry.raidKey or "General Assignments"
  return tostring(entry.protocol or "MGMGA") .. "|" .. tostring(entry.version or 1) .. " - " .. label
end

function MerfinPlus:GetGeneralAssignmentImportTimestamp(entry)
  return entry and (entry.importedAtText or tostring(entry.importedAt or "")) or ""
end

function MerfinPlus:SaveGeneralAssignmentImport(raw, receivedBroadcast, sender)
  local parsed, errorText = self:ParseGeneralAssignments(raw)
  if not parsed then
    return nil, errorText
  end
  receivedBroadcast = receivedBroadcast == true
  local storage = self:GetGeneralAssignmentStorage()
  local imports = self:GetGeneralAssignmentImports()
  for _, existing in ipairs(imports) do
    local existingParsed = existing.raw and self:ParseGeneralAssignments(existing.raw)
    if existingParsed
      and existingParsed.normalizedRaw == parsed.normalizedRaw
      and (existing.receivedBroadcast == true) == receivedBroadcast
    then
      storage.activeGeneralImportId = existing.id
      if receivedBroadcast then
        storage.activePersonalGeneralImportId = existing.id
        existing.broadcastSender = tostring(sender or existing.broadcastSender or "")
      end
      existing.parsed = existingParsed
      self:NotifyGeneralAssignmentsChanged()
      return existing, nil, true
    end
  end

  if receivedBroadcast then
    for index = #imports, 1, -1 do
      if imports[index].receivedBroadcast == true then
        storage.generalCollapsedSections[imports[index].id] = nil
        table.remove(imports, index)
      end
    end
  end

  local now = Now()
  local ordinal = #imports + 1
  local importID
  repeat
    importID = tostring(now) .. "-assign-" .. tostring(ordinal)
    ordinal = ordinal + 1
  until not self:FindGeneralAssignmentImport(importID)

  local entry = {
    id = importID,
    protocol = parsed.protocol,
    version = parsed.version,
    expansion = parsed.expansion,
    raidKey = parsed.raidKey,
    label = parsed.label,
    raw = parsed.normalizedRaw,
    parsed = parsed,
    importedAt = now,
    importedAtText = FormatTimestamp(now),
    updatedAt = now,
    updatedAtText = FormatTimestamp(now),
    receivedBroadcast = receivedBroadcast,
    broadcastSender = tostring(sender or ""),
  }
  imports[#imports + 1] = entry
  storage.activeGeneralImportId = entry.id
  if receivedBroadcast then
    storage.activePersonalGeneralImportId = entry.id
  end
  self:NotifyGeneralAssignmentsChanged()
  return entry, nil, false
end

function MerfinPlus:GetActivePersonalGeneralAssignmentImport()
  local storage = self:GetGeneralAssignmentStorage()
  local entry = self:FindGeneralAssignmentImport(storage.activePersonalGeneralImportId)
  if entry and entry.receivedBroadcast == true then
    entry.parsed, entry.parseError = self:ParseGeneralAssignments(entry.raw)
    return entry
  end
  storage.activePersonalGeneralImportId = nil
end

function MerfinPlus:DeleteGeneralAssignmentImport(importID)
  local storage = self:GetGeneralAssignmentStorage()
  local imports = storage.generalImports
  local removed
  for index, entry in ipairs(imports) do
    if entry.id == importID then
      removed = entry
      table.remove(imports, index)
      break
    end
  end
  if not removed then
    return nil
  end
  storage.generalCollapsedSections[importID] = nil
  if storage.activePersonalGeneralImportId == importID then
    storage.activePersonalGeneralImportId = nil
  end
  local nextEntry = imports[#imports]
  storage.activeGeneralImportId = nextEntry and nextEntry.id or nil
  self:NotifyGeneralAssignmentsChanged()
  return removed
end

function MerfinPlus:BuildPersonalGeneralAssignmentPayload(parsed, playerName)
  local playerKey = NormalizeName(CleanPlayerName(playerName))
  if not parsed or playerKey == "" then
    return nil, 0
  end

  local includedPlayers = {}
  local personalSections = {}
  local taskCount = 0
  includedPlayers[playerKey] = true

  for _, section in ipairs(parsed.sections or {}) do
    if section.name ~= "Players" then
      local rows = {}
      for _, task in ipairs(section.rows or {}) do
        if NormalizeName(CleanPlayerName(task.player)) == playerKey then
          rows[#rows + 1] = task
          taskCount = taskCount + 1
          local targetKey = NormalizeName(CleanPlayerName(task.target))
          if targetKey ~= "" then
            for _, player in ipairs(parsed.players or {}) do
              if NormalizeName(player.name) == targetKey then
                includedPlayers[targetKey] = true
                break
              end
            end
          end
        end
      end
      if #rows > 0 then
        personalSections[#personalSections + 1] = { name = section.name, rows = rows }
      end
    end
  end
  if taskCount == 0 then
    return nil, 0
  end

  local personal = {
    protocol = parsed.protocol,
    version = parsed.version,
    expansion = parsed.expansion,
    raidKey = parsed.raidKey,
    label = parsed.label,
    players = {},
    sections = personalSections,
  }
  for _, player in ipairs(parsed.players or {}) do
    if includedPlayers[NormalizeName(player.name)] then
      personal.players[#personal.players + 1] = player
    end
  end
  return BuildNormalizedGeneralAssignments(personal), taskCount
end

function MerfinPlus:IsGeneralAssignmentSectionCollapsed(entry, sectionName)
  local storage = self:GetGeneralAssignmentStorage()
  local importID = entry and entry.id or "default"
  storage.generalCollapsedSections[importID] = storage.generalCollapsedSections[importID] or {}
  local value = storage.generalCollapsedSections[importID][tostring(sectionName or "")]
  return value == nil and true or value == true
end

function MerfinPlus:ToggleGeneralAssignmentSection(entry, sectionName)
  if not entry then
    return
  end
  local storage = self:GetGeneralAssignmentStorage()
  storage.generalCollapsedSections[entry.id] = storage.generalCollapsedSections[entry.id] or {}
  local state = storage.generalCollapsedSections[entry.id]
  local key = tostring(sectionName or "")
  state[key] = not self:IsGeneralAssignmentSectionCollapsed(entry, sectionName)
  self:NotifyGeneralAssignmentsChanged()
end

function MerfinPlus:FindGeneralAssignmentPlayer(parsed, playerName)
  local direct = parsed and parsed.playerMap and parsed.playerMap[playerName]
  if direct then
    return direct
  end
  local key = NormalizeName(playerName)
  for _, player in ipairs(parsed and parsed.players or {}) do
    if NormalizeName(player.name) == key then
      return player
    end
  end
end

function MerfinPlus:RegisterGeneralAssignmentsWidget(widget)
  self.generalAssignmentWidgets = self.generalAssignmentWidgets or setmetatable({}, { __mode = "k" })
  self.generalAssignmentWidgets[widget] = true
end

function MerfinPlus:UnregisterGeneralAssignmentsWidget(widget)
  if self.generalAssignmentWidgets then
    self.generalAssignmentWidgets[widget] = nil
  end
end

function MerfinPlus:NotifyGeneralAssignmentsChanged()
  for widget in pairs(self.generalAssignmentWidgets or {}) do
    if widget.Refresh then
      widget:Refresh()
    end
  end
  if self.UpdateAssignmentWidgetVisibility then
    self:UpdateAssignmentWidgetVisibility()
  end
end
