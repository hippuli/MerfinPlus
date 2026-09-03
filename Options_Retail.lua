-- MerfinPlus Options & Media Registration
-- Comments in English as requested.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local Locale = GetLocale()
local L = MerfinPlus.L

-- AceConfig may be supplied by another addon, so customize the live widget
-- registry instead of relying on MerfinPlus' bundled Ace3 copy being active.
do
  local widgetType = "DropdownGroup"
  local baseConstructor = AceGUI.WidgetRegistry[widgetType]
  local baseVersion = AceGUI:GetWidgetVersion(widgetType)
  if baseConstructor and baseVersion then
    AceGUI:RegisterWidgetType(widgetType, function()
      local widget = baseConstructor()
      local BaseSetTitle = widget.SetTitle
      local BaseOnWidthSet = widget.OnWidthSet

      widget.SetTitle = function(control, title)
        control.merfinPlusRaidSelector = title == L["Raids"]
        BaseSetTitle(control, control.merfinPlusRaidSelector and "" or title)
        control.dropdown.text:SetJustifyH(control.merfinPlusRaidSelector and "LEFT" or "RIGHT")
      end

      widget.OnWidthSet = function(control, width)
        BaseOnWidthSet(control, width)
        if control.merfinPlusRaidSelector then
          control:SetDropdownWidth(math.max(200, width - 2))
        end
      end

      return widget
    end, baseVersion + 1)
  end
end

local GRAY_MULTILINE_TYPE = "MerfinPlusGrayMultiLineEditBox"
if not AceGUI:GetWidgetVersion(GRAY_MULTILINE_TYPE) then
  AceGUI:RegisterWidgetType(GRAY_MULTILINE_TYPE, function()
    local widget = AceGUI:Create("MultiLineEditBox")
    local BaseOnAcquire = widget.OnAcquire
    local BaseSetDisabled = widget.SetDisabled

    widget.OnAcquire = function(control)
      BaseOnAcquire(control)
      control.editBox:SetTextColor(0.65, 0.65, 0.65)
    end

    widget.SetDisabled = function(control, disabled)
      BaseSetDisabled(control, disabled)
      if not disabled then
        control.editBox:SetTextColor(0.65, 0.65, 0.65)
      end
    end

    widget.type = GRAY_MULTILINE_TYPE
    return widget
  end, 1)
end

local cooldownTooltipSpells = {}
local COOLDOWN_DROPDOWN_TYPE = "MerfinPlusCooldownDropdown"
if not AceGUI:GetWidgetVersion(COOLDOWN_DROPDOWN_TYPE) then
  AceGUI:RegisterWidgetType(COOLDOWN_DROPDOWN_TYPE, function()
    local widget = AceGUI:Create("Dropdown")
    local BaseOnAcquire = widget.OnAcquire
    local BaseSetList = widget.SetList
    local BaseOnRelease = widget.OnRelease
    local acquiredByBaseConstructor = true

    widget.OnAcquire = function(control)
      if acquiredByBaseConstructor then
        acquiredByBaseConstructor = false
        return
      end
      BaseOnAcquire(control)
    end

    widget.SetList = function(control, list, order, itemType)
      BaseSetList(control, list, order, itemType)
      for _, item in control.pullout:IterateItems() do
        local spellID = cooldownTooltipSpells[item.userdata.value]
        if spellID then
          item:SetOnEnter(function(dropdownItem)
            GameTooltip:SetOwner(dropdownItem.frame, "ANCHOR_CURSOR")
            GameTooltip:SetFrameStrata("TOOLTIP")
            local pulloutFrame = dropdownItem.pullout and dropdownItem.pullout.frame
            GameTooltip:SetFrameLevel((pulloutFrame and pulloutFrame:GetFrameLevel() or 0) + 100)
            if GameTooltip.SetSpellByID then
              GameTooltip:SetSpellByID(spellID)
            else
              GameTooltip:SetHyperlink("spell:" .. spellID)
            end
            GameTooltip:Show()
          end)
          item:SetOnLeave(function(dropdownItem)
            if GameTooltip:IsOwned(dropdownItem.frame) then GameTooltip:Hide() end
          end)
        end
      end
    end

    widget.OnRelease = function(control)
      GameTooltip:Hide()
      BaseOnRelease(control)
    end

    widget.type = COOLDOWN_DROPDOWN_TYPE
    return widget
  end, 1)
end

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

local function DeserializeJSON(source)
  if C_EncodingUtil and C_EncodingUtil.DeserializeJSON then
    return C_EncodingUtil.DeserializeJSON(source)
  end
  if MerfinPlusJSON and MerfinPlusJSON.decode then
    return MerfinPlusJSON.decode(source)
  end
  return nil, "EncodingUtil"
end

local isTitan = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

MerfinPlus.GetDefaultFont = function(type)
  return (Locale == "zhTW" or Locale == "zhCN" or isTitan) and "CN Merged (SF-Yahee)"
    or (type == "bold" and "SFUIDisplayCondensed-Bold" or "SFUIDisplayCondensed-Semibold")
end

MerfinPlus.GetDefaultRaidFont = function(type)
  return (Locale == "zhTW" or Locale == "zhCN" or isTitan) and "CN Merged (SF-Yahee)"
    or (type == "bold" and "PT Sans Narrow Bold" or "PT Sans Narrow")
end

Merfin.GetDefaultFont = MerfinPlus.GetDefaultFont
Merfin.GetDefaultRaidFont = MerfinPlus.GetDefaultRaidFont

local function IsWrath()
  local build = MerfinPlus.BuildInfo or select(4, GetBuildInfo())
  return build > 33000 and build < 40000
end

local function IsMoP()
  local build = MerfinPlus.BuildInfo or select(4, GetBuildInfo())
  return build > 50000 and build < 60000
end

local function IsCata()
  local build = MerfinPlus.BuildInfo or select(4, GetBuildInfo())
  return build > 40000 and build < 50000
end

local function IsTBC()
  local build = MerfinPlus.BuildInfo or select(4, GetBuildInfo())
  return build > 20504 and build < 30000
end

Merfin.IsTBC = IsTBC

-- Friendly-marker mechanics are part of the same MerfinPlus Auto-Marker
-- profile, but are kept separate from enemy NPC settings.
MerfinPlus.AutoMarkerDefaults = MerfinPlus.AutoMarkerDefaults or {}
MerfinPlus.AutoMarkerDefaults.mouseover = MerfinPlus.AutoMarkerDefaults.mouseover or 4
MerfinPlus.AutoMarkerDefaults.instances = MerfinPlus.AutoMarkerDefaults.instances or {}
MerfinPlus.AutoMarkerDefaults.mechanics = MerfinPlus.AutoMarkerDefaults.mechanics or {
  najentusImpalingSpine = { enable = true, marks = { 8 } },
  supremusChase = { enable = true, marks = { 8 } },
  teronCrushingShadows = { enable = true, marks = { 1, 2, 3, 4, 5 } },
  gurtoggFelRage = { enable = true, marks = { 8 } },
  teronShadowOfDeath = { enable = true, marks = { 8 } },
  friendlyMarkerTest = { enable = true, marks = { 8 } },
  reliquarySpite = { enable = true, marks = { 1, 2, 3 } },
  reliquarySoulDrain = { enable = true, marks = { 1, 2, 3, 4, 5 } },
  fattalAttraction = { enable = true, marks = { 1, 2, 3 } },
  deadlyPoison = { enable = true, marks = { 8 } },
  parasite = { enable = true, marks = { 8 } },
}

MerfinPlus.FriendlyMarkerCatalog = MerfinPlus.FriendlyMarkerCatalog or {
  {
    key = "najentusImpalingSpine", name = "Impaling Spine", icon = 135855,
    raid = "IID564", raidName = "Black Temple", boss = "601", bossName = "High Warlord Naj'entus",
    spellID = 39837, maxMarks = 1,
  },
  {
    key = "supremusChase", name = "Chase Target", icon = 132284,
    raid = "IID564", raidName = "Black Temple", boss = "602", bossName = "Supremus",
    applyEvent = "CHAGE_TARGET", clearEvent = "PHASE_TANK", maxMarks = 1,
  },
  {
    key = "teronCrushingShadows", name = "Crushing Shadows", spellID = 40243,
    raid = "IID564", raidName = "Black Temple", boss = "604", bossName = "Teron Gorefiend",
    maxMarks = 5,
  },
  {
    key = "teronShadowOfDeath", name = "Shadow of Death", icon = 135752,
    raid = "IID564", raidName = "Black Temple", boss = "604", bossName = "Teron Gorefiend",
    spellID = 40251, maxMarks = 1,
  },
  {
    key = "gurtoggFelRage", name = "Fel Rage", icon = 135791,
    raid = "IID564", raidName = "Black Temple", boss = "605", bossName = "Gurtogg Bloodboil",
    spellID = 40604, maxMarks = 1,
  },
  {
    key = "friendlyMarkerTest", name = "Test: 13165", spellID = 13165,
    raid = "IID564", raidName = "Black Temple", boss = "test", bossName = "Test",
    maxMarks = 1,
  },
  {
    key = "reliquarySpite", name = "Spite", spellID = 41376,
    raid = "IID564", raidName = "Black Temple", boss = "606", bossName = "Reliquary of Souls",
    maxMarks = 3,
  },
  {
    key = "reliquarySoulDrain", name = "Soul Drain", spellID = 41303,
    raid = "IID564", raidName = "Black Temple", boss = "606", bossName = "Reliquary of Souls",
    maxMarks = 5,
  },
  {
    key = "fattalAttraction", name = "Fatal Attraction", spellID = 41001,
    raid = "IID564", raidName = "Black Temple", boss = "607", bossName = "Mother Shahraz",
    maxMarks = 3,
  },
  {
    key = "deadlyPoison", name = "Deadly Poison", spellID = 41485,
    raid = "IID564", raidName = "Black Temple", boss = "608", bossName = "Illidari Council",
    maxMarks = 1,
  },
  {
    key = "parasite", name = "Parasitic Shadowfiend", spellID = 41917,
    raid = "IID564", raidName = "Black Temple", boss = "609", bossName = "Illidan Stormrage",
    maxMarks = 1,
  },
}

MerfinPlus.defaults = {
  profile = {
    minimapButton = {
      angle = 225,
    },
    pullStartTime = 0,
    pullExpTime = 0,
    pullTotalTime = 0,
    pullSenderName = "Unknown",
    breakStartTime = 0,
    breakExpTime = 0,
    breakTotalTime = 0,
    breakSenderName = "Unknown",
    lfgStartTimer = 0,
    lfgExpTimer = 0,

    font1 = MerfinPlus.GetDefaultFont(),
    font2 = MerfinPlus.GetDefaultFont("bold"),
    font3 = MerfinPlus.GetDefaultRaidFont(),
    font4 = MerfinPlus.GetDefaultRaidFont("bold"),
    bar1 = "MerfinMainDark",
    bar2 = "MerfinMain",
    bar3 = "MerfinMainDark",

    useSpecificLocalization = false,
    rpTextLocale = GAME_LOCALE or GetLocale(),
    rpSoundLocale = GAME_LOCALE or GetLocale(),
    rpChatLocale = GAME_LOCALE or GetLocale(),
    ttsEnabled = true,
    ttsApplyAll = true,
    ttsVolume = 30,
    ttsUseSpecificVoiceID = false,
    ttsVoiceID = 1,
    ttsVoiceRate = 2,
    ttsTestText = "Merfin Test Sound",

    raidCooldowns = {
      general = {
        enableTimeline = true,
        disableCD = false,
        emphasizedBar = true,
        emphasizedOn = 7,
        berserkOnlyShow = false,
        berserkShowOn = 60,
        enableRL = true,
      },
      raids = {
        blackTemple = {},
        hyjalSummit = {},
      },
    },

    raidAutoMarker = MerfinPlus.AutoMarkerDefaults,

    simImports = {},
  },
  global = {
    companion = {
      weakAuras = {
        selected = {},
        updatedAt = 0,
        revision = 0,
        source = "",
      },
    },
    wowSims = {
      profiles = {},
      assigned = {},
      defaultsVersion = -1,
      defaults = nil,
    },
  },
}

local IsRaidPackSpecificLocalizationEnabled = function(db)
  if not db then
    return false
  end

  local useSpecificLocalization = rawget(db, "useSpecificLocalization")
  if useSpecificLocalization ~= nil then
    return useSpecificLocalization and true or false
  end

  local oldUseClientLocale = rawget(db, "useClientLocale")
  return oldUseClientLocale == false
end

function MerfinPlus:NormalizeRaidPackLocaleSettings()
  local db = self.db and self.db.profile
  if not db then
    return
  end

  local oldRaidLocale = rawget(db, "raidLocale")
  if oldRaidLocale then
    if rawget(db, "rpTextLocale") == nil then
      db.rpTextLocale = oldRaidLocale
    end
    if rawget(db, "rpSoundLocale") == nil then
      db.rpSoundLocale = oldRaidLocale
    end
    if rawget(db, "rpChatLocale") == nil then
      db.rpChatLocale = oldRaidLocale
    end
  end

  local oldUseClientLocale = rawget(db, "useClientLocale")
  if oldUseClientLocale ~= nil and rawget(db, "useSpecificLocalization") == nil then
    db.useSpecificLocalization = not oldUseClientLocale
  end
end

do
  if IsTBC() then
    function MerfinPlus:InitializeWoWSimDefaults()
      if not MerfinPlus.db or not MerfinPlus.db.global then
        return
      end

      local wowSims = MerfinPlus.db.global.wowSims
      wowSims.profiles = wowSims.profiles or {}
      wowSims.assigned = wowSims.assigned or {}

      local profiles = wowSims.profiles

      local function AddProfile(key, data)
        data.key = key
        profiles[key] = data
      end

      local installedVersion = wowSims.defaultsVersion or -1

      if installedVersion < 0 then
        -- WARRIOR
        AddProfile("WarriorProtection-PreRaidBIS-2", {
          class = "WARRIOR",
          specKey = "WarriorProtection",
          specID = 163,
          icon = 134952,
          importedAt = 0,
          items = {
            [1] = 28180,
            [2] = 29386,
            [3] = 27803,
            [5] = 28205,
            [6] = 28995,
            [7] = 29184,
            [8] = 29239,
            [9] = 28996,
            [10] = 27475,
            [11] = 30834,
            [12] = 28553,
            [13] = 23836,
            [14] = 28121,
            [15] = 27804,
            [16] = 28189,
            [17] = 29266,
          },
          itemSuffixes = {},
        })
        AddProfile("WarriorArms-PreRaidBIS-2", {
          class = "WARRIOR",
          specKey = "WarriorArms",
          specID = 161,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 32087,
            [2] = 29381,
            [3] = 33173,
            [5] = 23522,
            [6] = 27985,
            [7] = 30538,
            [8] = 25686,
            [9] = 23537,
            [10] = 25685,
            [11] = 23038,
            [12] = 29379,
            [13] = 29383,
            [14] = 21670,
            [15] = 24259,
            [16] = 28438,
            [17] = 23542,
          },
          itemSuffixes = {},
        })
        AddProfile("WarriorFury-PreRaidBIS-2", {
          class = "WARRIOR",
          specKey = "WarriorFury",
          specID = 164,
          icon = 132347,
          importedAt = 0,
          items = {
            [1] = 32087,
            [2] = 29381,
            [3] = 33173,
            [5] = 23522,
            [6] = 27985,
            [7] = 30538,
            [8] = 25686,
            [9] = 23537,
            [10] = 25685,
            [11] = 23038,
            [12] = 29379,
            [13] = 29383,
            [14] = 21670,
            [15] = 24259,
            [16] = 28438,
            [17] = 23542,
          },
          itemSuffixes = {},
        })

        -- PALADIN
        AddProfile("PaladinProtection-PreRaidBIS-2", {
          class = "PALADIN",
          specKey = "PaladinProtection",
          specID = 383,
          icon = 135893,
          importedAt = 0,
          items = {
            [1] = 32083,
            [2] = 28245,
            [3] = 27706,
            [5] = 28203,
            [6] = 29253,
            [7] = 29184,
            [8] = 29254,
            [9] = 29252,
            [10] = 30741,
            [11] = 28407,
            [12] = 29172,
            [13] = 27529,
            [14] = 29370,
            [15] = 27804,
            [16] = 32450,
            [17] = 29176,
          },
          itemSuffixes = {},
        })
        AddProfile("PaladinHoly-PreRaidBIS-2", {
          class = "PALADIN",
          specKey = "PaladinHoly",
          specID = 382,
          icon = 135920,
          importedAt = 0,
          items = {
            [1] = 32472,
            [2] = 31691,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 24261,
            [8] = 27411,
            [9] = 29523,
            [10] = 29506,
            [11] = 27780,
            [12] = 29169,
            [13] = 29168,
            [14] = 29376,
            [15] = 31329,
            [16] = 23047,
            [17] = 23556,
            [18] = 29274,
          },
          itemSuffixes = {},
        })
        AddProfile("PaladinRetribution-PreRaidBIS-2", {
          class = "PALADIN",
          specKey = "PaladinRetribution",
          specID = 381,
          icon = 135873,
          importedAt = 0,
          items = {
            [1] = 32087,
            [2] = 29381,
            [3] = 33173,
            [5] = 23522,
            [6] = 29247,
            [7] = 30257,
            [8] = 25686,
            [9] = 23537,
            [10] = 30341,
            [11] = 30834,
            [12] = 29177,
            [13] = 29383,
            [14] = 28034,
            [15] = 33122,
            [16] = 28429,
          },
          itemSuffixes = {},
        })

        -- HUNTER
        AddProfile("HunterBeastMastery-PreRaidBIS-2", {
          class = "HUNTER",
          specKey = "HunterBeastMastery",
          specID = 361,
          icon = 132164,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 29381,
            [3] = 27801,
            [5] = 28228,
            [6] = 29526,
            [7] = 27874,
            [8] = 25686,
            [9] = 29527,
            [10] = 27474,
            [11] = 30860,
            [12] = 31077,
            [13] = 29383,
            [14] = 28288,
            [15] = 24259,
            [16] = 27846,
            [17] = 28435,
          },
          itemSuffixes = {},
        })
        AddProfile("HunterMarksmanship-PreRaidBIS-2", {
          class = "HUNTER",
          specKey = "HunterMarksmanship",
          specID = 363,
          icon = 132222,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 29381,
            [3] = 27801,
            [5] = 28228,
            [6] = 29526,
            [7] = 27874,
            [8] = 25686,
            [9] = 29527,
            [10] = 27474,
            [11] = 30860,
            [12] = 31077,
            [13] = 29383,
            [14] = 28288,
            [15] = 24259,
            [16] = 27846,
            [17] = 28315,
          },
          itemSuffixes = {},
        })
        AddProfile("HunterSurvival-PreRaidBIS-2", {
          class = "HUNTER",
          specKey = "HunterSurvival",
          specID = 362,
          icon = 132215,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 28343,
            [3] = 27801,
            [5] = 28228,
            [6] = 27760,
            [7] = 27837,
            [8] = 29262,
            [9] = 25697,
            [10] = 27474,
            [11] = 31326,
            [12] = 22961,
            [13] = 29383,
            [14] = 28034,
            [15] = 29382,
            [16] = 27846,
            [17] = 28263,
          },
          itemSuffixes = {},
        })

        -- ROGUE
        AddProfile("RogueCombat-PreRaidBIS-2", {
          class = "ROGUE",
          specKey = "RogueCombat",
          specID = 181,
          icon = 132090,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 28264,
            [6] = 29247,
            [7] = 27837,
            [8] = 25686,
            [9] = 29246,
            [10] = 25685,
            [11] = 31920,
            [12] = 30834,
            [13] = 23206,
            [14] = 29383,
            [15] = 24259,
            [16] = 28438,
            [17] = 28189,
          },
          itemSuffixes = {},
        })
        AddProfile("RogueAssassination-PreRaidBIS-2", {
          class = "ROGUE",
          specKey = "RogueAssassination",
          specID = 182,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 28264,
            [6] = 29247,
            [7] = 27837,
            [8] = 25686,
            [9] = 29246,
            [10] = 25685,
            [11] = 31920,
            [12] = 30834,
            [13] = 23206,
            [14] = 29383,
            [15] = 24259,
            [16] = 28438,
            [17] = 28189,
          },
          itemSuffixes = {},
        })
        AddProfile("RogueSubtlety-PreRaidBIS-2", {
          class = "ROGUE",
          specKey = "RogueSubtlety",
          specID = 183,
          icon = 132320,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 28264,
            [6] = 29247,
            [7] = 27837,
            [8] = 25686,
            [9] = 29246,
            [10] = 25685,
            [11] = 31920,
            [12] = 30834,
            [13] = 23206,
            [14] = 29383,
            [15] = 24259,
            [16] = 28438,
            [17] = 28189,
          },
          itemSuffixes = {},
        })

        -- PRIEST
        AddProfile("PriestHoly-PreRaidBIS-2", {
          class = "PRIEST",
          specKey = "PriestHoly",
          specID = 202,
          icon = 237542,
          importedAt = 0,
          items = {
            [1] = 32090,
            [2] = 29374,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 24261,
            [8] = 29251,
            [9] = 29183,
            [10] = 27536,
            [11] = 29373,
            [12] = 32535,
            [13] = 29376,
            [14] = 21625,
            [15] = 29354,
            [16] = 23556,
            [17] = 29170,
          },
          itemSuffixes = {},
        })
        AddProfile("PriestDiscipline-PreRaidBIS-2", {
          class = "PRIEST",
          specKey = "PriestDiscipline",
          specID = 201,
          icon = 135987,
          importedAt = 0,
          items = {
            [1] = 32090,
            [2] = 29374,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 24261,
            [8] = 29251,
            [9] = 29183,
            [10] = 27536,
            [11] = 29373,
            [12] = 32535,
            [13] = 29376,
            [14] = 21625,
            [15] = 29354,
            [16] = 23556,
            [17] = 29170,
          },
          itemSuffixes = {},
        })
        AddProfile("PriestShadow-PreRaidBIS-2", {
          class = "PRIEST",
          specKey = "PriestShadow",
          specID = 203,
          icon = 136207,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 18814,
            [3] = 21869,
            [5] = 21871,
            [6] = 31199,
            [7] = 24262,
            [8] = 21870,
            [9] = 31225,
            [10] = 31166,
            [11] = 21709,
            [12] = 23031,
            [13] = 29370,
            [14] = 27683,
            [15] = 31201,
            [16] = 30832,
            [17] = 29272,
          },
          itemSuffixes = {},
        })

        -- SHAMAN
        AddProfile("ShamanRestoration-PreRaidBIS-2", {
          class = "SHAMAN",
          specKey = "ShamanRestoration",
          specID = 262,
          icon = 136052,
          importedAt = 0,
          items = {
            [1] = 32475,
            [2] = 32531,
            [3] = 27826,
            [5] = 29522,
            [6] = 29524,
            [7] = 24261,
            [8] = 27411,
            [9] = 29523,
            [10] = 27806,
            [11] = 29169,
            [12] = 32535,
            [13] = 29376,
            [14] = 38288,
            [15] = 31329,
            [16] = 32451,
            [17] = 29267,
          },
          itemSuffixes = {},
        })
        AddProfile("ShamanElemental-PreRaidBIS-2", {
          class = "SHAMAN",
          specKey = "ShamanElemental",
          specID = 261,
          icon = 136048,
          importedAt = 0,
          items = {
            [1] = 32086,
            [2] = 28134,
            [3] = 32078,
            [5] = 29519,
            [6] = 29520,
            [7] = 24262,
            [8] = 28406,
            [9] = 29521,
            [10] = 27465,
            [11] = 29126,
            [12] = 29367,
            [13] = 29370,
            [14] = 27683,
            [15] = 29369,
            [16] = 32450,
            [17] = 29273,
          },
          itemSuffixes = {},
        })
        AddProfile("ShamanEnhancement-PreRaidBIS-2", {
          class = "SHAMAN",
          specKey = "ShamanEnhancement",
          specID = 263,
          icon = 136051,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 29525,
            [6] = 29526,
            [7] = 31544,
            [8] = 25686,
            [9] = 29527,
            [10] = 25685,
            [11] = 30834,
            [12] = 31920,
            [13] = 29383,
            [14] = 23206,
            [15] = 33122,
            [16] = 28438,
            [17] = 29348,
          },
          itemSuffixes = {},
        })

        -- MAGE
        AddProfile("MageArcane-PreRaidBIS-2", {
          class = "MAGE",
          specKey = "MageArcane",
          specID = 81,
          icon = 135932,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28134,
            [3] = 27994,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 27821,
            [9] = 27462,
            [10] = 21847,
            [11] = 28227,
            [12] = 31339,
            [13] = 23207,
            [14] = 29132,
            [15] = 23050,
            [16] = 23554,
            [17] = 29271,
          },
          itemSuffixes = {},
        })
        AddProfile("MageFire-PreRaidBIS-2", {
          class = "MAGE",
          specKey = "MageFire",
          specID = 41,
          icon = 135810,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28134,
            [3] = 30925,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 27821,
            [9] = 24250,
            [10] = 21847,
            [11] = 29172,
            [12] = 21709,
            [13] = 23207,
            [14] = 29132,
            [15] = 23050,
            [16] = 23554,
            [17] = 29270,
          },
          itemSuffixes = {},
        })
        AddProfile("MageFrost-PreRaidBIS-2", {
          class = "MAGE",
          specKey = "MageFrost",
          specID = 61,
          icon = 135846,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 27493,
            [11] = 29172,
            [12] = 21709,
            [13] = 23207,
            [14] = 29132,
            [15] = 23050,
            [16] = 23554,
            [17] = 29269,
          },
          itemSuffixes = {},
        })

        -- WARLOCK
        AddProfile("WarlockAffliction-PreRaidBIS-2", {
          class = "WARLOCK",
          specKey = "WarlockAffliction",
          specID = 302,
          icon = 136145,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 21186,
            [10] = 21585,
            [11] = 29172,
            [12] = 29126,
            [13] = 29370,
            [14] = 27683,
            [15] = 23050,
            [16] = 31336,
            [17] = 29273,
          },
          itemSuffixes = {},
        })
        AddProfile("WarlockDemonology-PreRaidBIS-2", {
          class = "WARLOCK",
          specKey = "WarlockDemonology",
          specID = 303,
          icon = 136172,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 21186,
            [10] = 21585,
            [11] = 29172,
            [12] = 29126,
            [13] = 29370,
            [14] = 27683,
            [15] = 23050,
            [16] = 31336,
            [17] = 29273,
          },
          itemSuffixes = {},
        })
        AddProfile("WarlockDestruction-PreRaidBIS-2", {
          class = "WARLOCK",
          specKey = "WarlockDestruction",
          specID = 301,
          icon = 136186,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 21186,
            [10] = 21585,
            [11] = 29172,
            [12] = 29126,
            [13] = 29370,
            [14] = 27683,
            [15] = 23050,
            [16] = 31336,
            [17] = 29273,
          },
          itemSuffixes = {},
        })

        -- DRUID
        AddProfile("DruidRestoration-PreRaidBIS-2", {
          class = "DRUID",
          specKey = "DruidRestoration",
          specID = 282,
          icon = 136041,
          importedAt = 0,
          items = {
            [1] = 24264,
            [2] = 30377,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 24261,
            [8] = 27411,
            [9] = 29183,
            [10] = 29506,
            [11] = 27780,
            [12] = 31383,
            [13] = 29376,
            [14] = 19395,
            [15] = 31329,
            [16] = 32451,
            [17] = 29274,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidFeralDPS-PreRaidBIS-2", {
          class = "DRUID",
          specKey = "DruidFeralCombat",
          specID = 281,
          icon = 132276,
          importedAt = 0,
          items = {
            [1] = 8345,
            [2] = 24114,
            [3] = 27797,
            [5] = 29525,
            [6] = 29247,
            [7] = 31544,
            [8] = 25686,
            [9] = 29246,
            [10] = 28396,
            [11] = 30834,
            [12] = 31920,
            [13] = 29383,
            [14] = 23206,
            [15] = 31255,
            [16] = 31334,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidFeralTank-PreRaidBIS-2", {
          class = "DRUID",
          specKey = "DruidFeralCombat",
          specID = 281,
          icon = 132276,
          importedAt = 0,
          items = {
            [1] = 29502,
            [2] = 29815,
            [3] = 27434,
            [5] = 25689,
            [6] = 30942,
            [7] = 25690,
            [8] = 28987,
            [9] = 30944,
            [10] = 30943,
            [11] = 30834,
            [12] = 29384,
            [13] = 29383,
            [14] = 23206,
            [15] = 28256,
            [16] = 29171,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidBalance-PreRaidBIS-2", {
          class = "DRUID",
          specKey = "DruidBalance",
          specID = 283,
          icon = 136096,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28134,
            [3] = 27796,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 27821,
            [9] = 29523,
            [10] = 21847,
            [11] = 29172,
            [12] = 28227,
            [13] = 29370,
            [14] = 29132,
            [15] = 27981,
            [16] = 23554,
            [17] = 29271,
          },
          itemSuffixes = {},
        })
        AddProfile("RogueCombat-PreRaidBIS", {
          class = "ROGUE",
          specKey = "RogueCombat",
          specID = 181,
          icon = 132090,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 28264,
            [6] = 29247,
            [7] = 27837,
            [8] = 25686,
            [9] = 29246,
            [10] = 25685,
            [11] = 31077,
            [12] = 30834,
            [13] = 29383,
            [14] = 28288,
            [15] = 27878,
            [16] = 28438,
            [17] = 28189,
            [18] = 29152,
          },
          itemSuffixes = {},
        })

        AddProfile("RogueSubtlety-PreRaidBIS", {
          class = "ROGUE",
          specKey = "RogueSubtlety",
          specID = 183,
          icon = 132320,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 28264,
            [6] = 29247,
            [7] = 27837,
            [8] = 25686,
            [9] = 29246,
            [10] = 25685,
            [11] = 31077,
            [12] = 30834,
            [13] = 29383,
            [14] = 28288,
            [15] = 27878,
            [16] = 28438,
            [17] = 28189,
            [18] = 29152,
          },
          itemSuffixes = {},
        })

        AddProfile("PriestShadow-PreRaidBIS", {
          class = "PRIEST",
          specKey = "PriestShadow",
          specID = 203,
          icon = 136207,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28245,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 29317,
            [11] = 31075,
            [12] = 29352,
            [13] = 29370,
            [14] = 27683,
            [15] = 24252,
            [16] = 30832,
            [17] = 29272,
            [18] = 29350,
          },
          itemSuffixes = {},
        })

        AddProfile("MageFrost-PreRaidBIS", {
          class = "MAGE",
          specKey = "MageFrost",
          specID = 61,
          icon = 135846,
          importedAt = 0,
          items = {
            [1] = 28193,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 27465,
            [11] = 28227,
            [12] = 32779,
            [13] = 29370,
            [14] = 27683,
            [15] = 29369,
            [16] = 29155,
            [17] = 29269,
            [18] = 29350,
          },
          itemSuffixes = {},
        })

        AddProfile("DruidRestoration-PreRaidBIS", {
          class = "DRUID",
          specKey = "DruidRestoration",
          specID = 282,
          icon = 136041,
          importedAt = 0,
          items = {
            [1] = 32090,
            [2] = 30377,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 30543,
            [8] = 27411,
            [9] = 29183,
            [10] = 29506,
            [11] = 31383,
            [12] = 27780,
            [13] = 29376,
            [14] = 30841,
            [15] = 29354,
            [16] = 29353,
            [17] = 29274,
            [18] = 27886,
          },
          itemSuffixes = {},
        })

        AddProfile("MageArcane-PreRaidBIS", {
          class = "MAGE",
          specKey = "MageArcane",
          specID = 81,
          icon = 135932,
          importedAt = 0,
          items = {
            [1] = 28278,
            [2] = 28134,
            [3] = 27738,
            [5] = 21848,
            [6] = 21846,
            [7] = 30532,
            [8] = 29258,
            [9] = 28411,
            [10] = 21847,
            [11] = 29367,
            [12] = 29352,
            [13] = 29370,
            [14] = 27683,
            [15] = 25777,
            [16] = 29155,
            [17] = 29271,
            [18] = 28386,
          },
          itemSuffixes = {},
        })

        AddProfile("WarlockDestruction-PreRaidBIS", {
          class = "WARLOCK",
          specKey = "WarlockDestruction",
          specID = 301,
          icon = 136186,
          importedAt = 0,
          items = {
            [1] = 28193,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 27465,
            [11] = 28227,
            [12] = 29367,
            [13] = 27683,
            [14] = 29370,
            [15] = 27981,
            [16] = 29155,
            [17] = 29273,
            [18] = 29350,
          },
          itemSuffixes = {},
        })

        AddProfile("HunterMarksmanship-PreRaidBIS", {
          class = "HUNTER",
          specKey = "HunterMarksmanship",
          specID = 363,
          icon = 132222,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 29381,
            [3] = 27801,
            [5] = 28228,
            [6] = 27760,
            [7] = 30538,
            [8] = 25686,
            [9] = 29246,
            [10] = 27474,
            [11] = 30860,
            [12] = 31077,
            [13] = 29383,
            [14] = 28288,
            [15] = 24259,
            [16] = 28435,
            [18] = 29351,
          },
          itemSuffixes = {},
        })

        AddProfile("ShamanEnhancement-PreRaidBIS", {
          class = "SHAMAN",
          specKey = "ShamanEnhancement",
          specID = 263,
          icon = 136051,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 29515,
            [6] = 29516,
            [7] = 30538,
            [8] = 25686,
            [9] = 29517,
            [10] = 25685,
            [11] = 30834,
            [12] = 30365,
            [13] = 29383,
            [14] = 28288,
            [15] = 24259,
            [16] = 29348,
            [17] = 27872,
            [18] = 27815,
          },
          itemSuffixes = {},
        })

        AddProfile("ShamanRestoration-PreRaidBIS", {
          class = "SHAMAN",
          specKey = "ShamanRestoration",
          specID = 262,
          icon = 136052,
          importedAt = 0,
          items = {
            [1] = 32090,
            [2] = 31691,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 30543,
            [8] = 27411,
            [9] = 29183,
            [10] = 28304,
            [11] = 29168,
            [12] = 29814,
            [13] = 29376,
            [14] = 28190,
            [15] = 24254,
            [16] = 23556,
            [17] = 29274,
            [18] = 27544,
          },
          itemSuffixes = {},
        })

        AddProfile("MageFire-PreRaidBIS", {
          class = "MAGE",
          specKey = "MageFire",
          specID = 41,
          icon = 135810,
          importedAt = 0,
          items = {
            [1] = 28193,
            [2] = 28134,
            [3] = 27796,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 28406,
            [9] = 28411,
            [10] = 21847,
            [11] = 28227,
            [12] = 29367,
            [13] = 29370,
            [14] = 27683,
            [15] = 29369,
            [16] = 29155,
            [17] = 29270,
            [18] = 29350,
          },
          itemSuffixes = {},
        })

        AddProfile("WarriorArms-PreRaidBIS", {
          class = "WARRIOR",
          specKey = "WarriorArms",
          specID = 161,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 32087,
            [2] = 29349,
            [3] = 33173,
            [5] = 23522,
            [6] = 27985,
            [7] = 30257,
            [8] = 25686,
            [9] = 28381,
            [10] = 25685,
            [11] = 30834,
            [12] = 29379,
            [13] = 29383,
            [14] = 28034,
            [15] = 24259,
            [16] = 28429,
            [18] = 30279,
          },
          itemSuffixes = {},
        })

        AddProfile("WarlockAffliction-PreRaidBIS", {
          class = "WARLOCK",
          specKey = "WarlockAffliction",
          specID = 302,
          icon = 136145,
          importedAt = 0,
          items = {
            [1] = 28193,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 27465,
            [11] = 28227,
            [12] = 29367,
            [13] = 27683,
            [14] = 29370,
            [15] = 27981,
            [16] = 29155,
            [17] = 29273,
            [18] = 29350,
          },
          itemSuffixes = {},
        })

        AddProfile("PriestHoly-PreRaidBIS", {
          class = "PRIEST",
          specKey = "PriestHoly",
          specID = 202,
          icon = 237542,
          importedAt = 0,
          items = {
            [1] = 32090,
            [2] = 30377,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 30543,
            [8] = 27411,
            [9] = 29183,
            [10] = 24393,
            [11] = 27780,
            [12] = 29168,
            [13] = 29376,
            [14] = 28190,
            [15] = 29354,
            [16] = 29353,
            [17] = 29170,
            [18] = 27885,
          },
          itemSuffixes = {},
        })

        AddProfile("WarlockDemonology-PreRaidBIS", {
          class = "WARLOCK",
          specKey = "WarlockDemonology",
          specID = 303,
          icon = 136172,
          importedAt = 0,
          items = {
            [1] = 28193,
            [2] = 28134,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 27465,
            [11] = 28227,
            [12] = 29367,
            [13] = 27683,
            [14] = 29370,
            [15] = 27981,
            [16] = 29155,
            [17] = 29273,
            [18] = 29350,
          },
          itemSuffixes = {},
        })

        AddProfile("WarriorFury-PreRaidBIS", {
          class = "WARRIOR",
          specKey = "WarriorFury",
          specID = 164,
          icon = 132347,
          importedAt = 0,
          items = {
            [1] = 32087,
            [2] = 29381,
            [3] = 33173,
            [5] = 23522,
            [6] = 27985,
            [7] = 30538,
            [8] = 25686,
            [9] = 28381,
            [10] = 25685,
            [11] = 30834,
            [12] = 29379,
            [13] = 29383,
            [14] = 28034,
            [15] = 24259,
            [16] = 28438,
            [17] = 29124,
            [18] = 30279,
          },
          itemSuffixes = {},
        })

        AddProfile("WarriorProtection-PreRaidBIS", {
          class = "WARRIOR",
          specKey = "WarriorProtection",
          specID = 163,
          icon = 134952,
          importedAt = 0,
          items = {
            [1] = 32083,
            [2] = 28244,
            [3] = 32073,
            [5] = 28205,
            [6] = 28385,
            [7] = 29184,
            [8] = 28383,
            [9] = 28381,
            [10] = 30341,
            [11] = 30834,
            [12] = 28553,
            [13] = 28121,
            [14] = 29383,
            [15] = 28377,
            [16] = 28189,
            [17] = 29266,
            [18] = 29152,
          },
          itemSuffixes = {},
        })

        AddProfile("ShamanElemental-PreRaidBIS", {
          class = "SHAMAN",
          specKey = "ShamanElemental",
          specID = 261,
          icon = 136048,
          importedAt = 0,
          items = {
            [1] = 32086,
            [2] = 31692,
            [3] = 27796,
            [5] = 29519,
            [6] = 29520,
            [7] = 24262,
            [8] = 28406,
            [9] = 29521,
            [10] = 27465,
            [11] = 32779,
            [12] = 29367,
            [13] = 27683,
            [14] = 29370,
            [15] = 29369,
            [16] = 30832,
            [17] = 29268,
            [18] = 28248,
          },
          itemSuffixes = {},
        })

        AddProfile("HunterSurvival-PreRaidBIS", {
          class = "HUNTER",
          specKey = "HunterSurvival",
          specID = 362,
          icon = 132215,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 28343,
            [3] = 27801,
            [5] = 28228,
            [6] = 27760,
            [7] = 27837,
            [8] = 29248,
            [9] = 25697,
            [10] = 27474,
            [11] = 31277,
            [12] = 27453,
            [13] = 29383,
            [14] = 28288,
            [15] = 29382,
            [16] = 29329,
            [18] = 29351,
          },
          itemSuffixes = {},
        })

        AddProfile("RogueAssassination-PreRaidBIS", {
          class = "ROGUE",
          specKey = "RogueAssassination",
          specID = 182,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 28224,
            [2] = 29381,
            [3] = 27797,
            [5] = 28264,
            [6] = 29247,
            [7] = 27837,
            [8] = 25686,
            [9] = 29246,
            [10] = 25685,
            [11] = 31077,
            [12] = 30834,
            [13] = 29383,
            [14] = 28288,
            [15] = 27878,
            [16] = 29360,
            [17] = 29346,
            [18] = 29152,
          },
          itemSuffixes = {},
        })

        AddProfile("PaladinHoly-PreRaidBIS", {
          class = "PALADIN",
          specKey = "PaladinHoly",
          specID = 382,
          icon = 135920,
          importedAt = 0,
          items = {
            [1] = 32084,
            [2] = 31691,
            [3] = 27775,
            [5] = 28230,
            [6] = 29250,
            [7] = 30543,
            [8] = 27411,
            [9] = 23539,
            [10] = 27457,
            [11] = 29168,
            [12] = 27780,
            [13] = 29376,
            [14] = 28190,
            [15] = 29354,
            [16] = 29353,
            [17] = 29274,
            [18] = 25644,
          },
          itemSuffixes = {},
        })

        AddProfile("HunterBeastMastery-PreRaidBIS", {
          class = "HUNTER",
          specKey = "HunterBeastMastery",
          specID = 361,
          icon = 132164,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 29381,
            [3] = 27801,
            [5] = 28228,
            [6] = 27760,
            [7] = 30538,
            [8] = 25686,
            [9] = 29246,
            [10] = 27474,
            [11] = 30860,
            [12] = 31077,
            [13] = 29383,
            [14] = 28288,
            [15] = 24259,
            [16] = 28435,
            [18] = 29351,
          },
          itemSuffixes = {},
        })

        AddProfile("PaladinRetribution-PreRaidBIS", {
          class = "PALADIN",
          specKey = "PaladinRetribution",
          specID = 381,
          icon = 135873,
          importedAt = 0,
          items = {
            [1] = 32087,
            [2] = 29119,
            [3] = 33173,
            [5] = 23522,
            [6] = 27985,
            [7] = 30257,
            [8] = 28176,
            [9] = 23537,
            [10] = 30341,
            [11] = 30834,
            [12] = 29177,
            [13] = 29383,
            [14] = 28288,
            [15] = 24259,
            [16] = 28429,
            [18] = 27484,
          },
          itemSuffixes = {},
        })

        AddProfile("PaladinProtection-PreRaidBIS", {
          class = "PALADIN",
          specKey = "PaladinProtection",
          specID = 383,
          icon = 135893,
          importedAt = 0,
          items = {
            [1] = 32083,
            [2] = 29173,
            [3] = 27739,
            [5] = 28203,
            [6] = 29253,
            [7] = 29184,
            [8] = 29254,
            [9] = 29252,
            [10] = 23517,
            [11] = 28407,
            [12] = 29323,
            [13] = 29370,
            [14] = 27529,
            [15] = 27804,
            [16] = 30832,
            [17] = 29266,
            [18] = 29388,
          },
          itemSuffixes = {},
        })

        AddProfile("DruidBalance-PreRaidBIS", {
          class = "DRUID",
          specKey = "DruidBalance",
          specID = 283,
          icon = 136096,
          importedAt = 0,
          items = {
            [1] = 28278,
            [2] = 28134,
            [3] = 27796,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 28406,
            [9] = 24250,
            [10] = 21847,
            [11] = 28227,
            [12] = 29367,
            [13] = 29370,
            [14] = 27683,
            [15] = 27981,
            [16] = 30832,
            [17] = 29271,
            [18] = 27518,
          },
          itemSuffixes = {},
        })

        wowSims.defaultsVersion = 0
        installedVersion = 0
      end
      if installedVersion < 2 then
        -- Phase 1
        -- DRUID
        AddProfile("DruidBalance-Phase1BIS", {
          class = "DRUID",
          specKey = "DruidBalance",
          specID = 283,
          icon = 136096,
          importedAt = 0,
          items = {
            [1] = 29093,
            [2] = 28762,
            [3] = 29095,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 28517,
            [9] = 24250,
            [10] = 21847,
            [11] = 29287,
            [12] = 28753,
            [13] = 29370,
            [14] = 27683,
            [15] = 28766,
            [16] = 28770,
            [17] = 29271,
            [18] = 27518,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidFeralDps-Phase1BIS", {
          class = "DRUID",
          specKey = "DruidFeralCombat",
          specID = 281,
          icon = 132276,
          importedAt = 0,
          items = {
            [1] = 8345,
            [2] = 29381,
            [3] = 29100,
            [5] = 29096,
            [6] = 28750,
            [7] = 28741,
            [8] = 28545,
            [9] = 29246,
            [10] = 28506,
            [11] = 30834,
            [12] = 28791,
            [13] = 29383,
            [14] = 28830,
            [15] = 24259,
            [16] = 28658,
            [18] = 29390,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidFeralTank-Phase1BIS", {
          class = "DRUID",
          specKey = "DruidFeralCombat",
          specID = 281,
          icon = 132276,
          importedAt = 0,
          items = {
            [1] = 29098,
            [2] = 28509,
            [3] = 29100,
            [5] = 29096,
            [6] = 28423,
            [7] = 29099,
            [8] = 28422,
            [9] = 28445,
            [10] = 30644,
            [11] = 29279,
            [12] = 30834,
            [13] = 28579,
            [14] = 29383,
            [15] = 28660,
            [16] = 28658,
            [18] = 23198,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidRestoration-Phase1BIS", {
          class = "DRUID",
          specKey = "DruidRestoration",
          specID = 282,
          icon = 136041,
          importedAt = 0,
          items = {
            [1] = 29086,
            [2] = 28609,
            [3] = 29089,
            [5] = 21875,
            [6] = 21873,
            [7] = 28591,
            [8] = 28752,
            [9] = 29183,
            [10] = 28521,
            [11] = 28763,
            [12] = 29290,
            [13] = 29376,
            [14] = 30841,
            [15] = 28765,
            [16] = 28771,
            [17] = 29274,
            [18] = 27886,
          },
          itemSuffixes = {},
        })
        -- HUNTER
        AddProfile("HunterBeastMastery-Phase1BIS", {
          class = "HUNTER",
          specKey = "HunterBeastMastery",
          specID = 361,
          icon = 132164,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 29381,
            [3] = 27801,
            [5] = 28228,
            [6] = 28828,
            [7] = 28741,
            [8] = 28545,
            [9] = 29246,
            [10] = 27474,
            [11] = 28757,
            [12] = 28791,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 28435,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        AddProfile("HunterMarksmanship-Phase1BIS", {
          class = "HUNTER",
          specKey = "HunterMarksmanship",
          specID = 363,
          icon = 132222,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 29381,
            [3] = 27801,
            [5] = 28228,
            [6] = 28828,
            [7] = 28741,
            [8] = 28545,
            [9] = 29246,
            [10] = 27474,
            [11] = 28757,
            [12] = 28791,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 28435,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        AddProfile("HunterSurvival-Phase1BIS", {
          class = "HUNTER",
          specKey = "HunterSurvival",
          specID = 362,
          icon = 132215,
          importedAt = 0,
          items = {
            [1] = 28275,
            [2] = 28343,
            [3] = 27801,
            [5] = 28228,
            [6] = 27760,
            [7] = 28741,
            [8] = 28545,
            [9] = 25697,
            [10] = 27474,
            [11] = 31277,
            [12] = 28791,
            [13] = 28830,
            [14] = 29383,
            [15] = 28672,
            [16] = 28587,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        -- MAGE
        AddProfile("MageArcane-Phase1BIS", {
          class = "MAGE",
          specKey = "MageArcane",
          specID = 81,
          icon = 135932,
          importedAt = 0,
          items = {
            [1] = 29076,
            [2] = 28762,
            [3] = 29079,
            [5] = 21848,
            [6] = 21846,
            [7] = 28594,
            [8] = 28517,
            [9] = 28411,
            [10] = 21847,
            [11] = 29287,
            [12] = 28793,
            [13] = 29370,
            [14] = 28785,
            [15] = 28797,
            [16] = 28770,
            [17] = 29271,
            [18] = 28783,
          },
          itemSuffixes = {},
        })
        AddProfile("MageFire-Phase1BIS", {
          class = "MAGE",
          specKey = "MageFire",
          specID = 41,
          icon = 135810,
          importedAt = 0,
          items = {
            [1] = 29076,
            [2] = 28762,
            [3] = 29079,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 28517,
            [9] = 28411,
            [10] = 21847,
            [11] = 28793,
            [12] = 28753,
            [13] = 29370,
            [14] = 27683,
            [15] = 28766,
            [16] = 28770,
            [17] = 29270,
            [18] = 28673,
          },
          itemSuffixes = {},
        })
        AddProfile("MageFrost-Phase1BIS", {
          class = "MAGE",
          specKey = "MageFrost",
          specID = 61,
          icon = 135846,
          importedAt = 0,
          items = {
            [1] = 29076,
            [2] = 28762,
            [3] = 21869,
            [5] = 21871,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 28780,
            [11] = 28793,
            [12] = 28753,
            [13] = 29370,
            [14] = 27683,
            [15] = 28766,
            [16] = 28770,
            [17] = 29269,
            [18] = 28673,
          },
          itemSuffixes = {},
        })
        -- PALADIN
        AddProfile("PaladinHoly-Phase1BIS", {
          class = "PALADIN",
          specKey = "PaladinHoly",
          specID = 382,
          icon = 135920,
          importedAt = 0,
          items = {
            [1] = 29061,
            [2] = 28609,
            [3] = 29064,
            [5] = 29062,
            [6] = 28733,
            [7] = 28748,
            [8] = 28752,
            [9] = 23539,
            [10] = 28505,
            [11] = 28763,
            [12] = 28790,
            [13] = 29376,
            [14] = 28590,
            [15] = 28765,
            [16] = 28771,
            [17] = 29458,
            [18] = 25644,
          },
          itemSuffixes = {},
        })
        AddProfile("PaladinProtection-Phase1BIS", {
          class = "PALADIN",
          specKey = "PaladinProtection",
          specID = 383,
          icon = 135893,
          importedAt = 0,
          items = {
            [1] = 29068,
            [2] = 28516,
            [3] = 29070,
            [5] = 29066,
            [6] = 28566,
            [7] = 29069,
            [8] = 30641,
            [9] = 29252,
            [10] = 28518,
            [11] = 29279,
            [12] = 29172,
            [13] = 29370,
            [14] = 28789,
            [15] = 27804,
            [16] = 28802,
            [17] = 28825,
            [18] = 29388,
          },
          itemSuffixes = {},
        })
        AddProfile("PaladinRetribution-Phase1BIS", {
          class = "PALADIN",
          specKey = "PaladinRetribution",
          specID = 381,
          icon = 135873,
          importedAt = 0,
          items = {
            [1] = 29073,
            [2] = 28745,
            [3] = 29075,
            [5] = 29071,
            [6] = 28779,
            [7] = 30257,
            [8] = 28608,
            [9] = 28795,
            [10] = 30644,
            [11] = 30834,
            [12] = 28730,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 28429,
            [18] = 27484,
          },
          itemSuffixes = {},
        })
        -- PRIEST
        AddProfile("PriestHoly-Phase1BIS", {
          class = "PRIEST",
          specKey = "PriestHoly",
          specID = 202,
          icon = 237542,
          importedAt = 0,
          items = {
            [1] = 29049,
            [2] = 28822,
            [3] = 21874,
            [5] = 21875,
            [6] = 21873,
            [7] = 28742,
            [8] = 28663,
            [9] = 29183,
            [10] = 28508,
            [11] = 28763,
            [12] = 29290,
            [13] = 29376,
            [14] = 28823,
            [15] = 28765,
            [16] = 28771,
            [17] = 29170,
            [18] = 28588,
          },
          itemSuffixes = {},
        })
        AddProfile("PriestShadow-Phase1BIS", {
          class = "PRIEST",
          specKey = "PriestShadow",
          specID = 203,
          icon = 136207,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 30666,
            [3] = 21869,
            [5] = 21871,
            [6] = 28799,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 28780,
            [11] = 28753,
            [12] = 29352,
            [13] = 29370,
            [14] = 27683,
            [15] = 28570,
            [16] = 28770,
            [17] = 29272,
            [18] = 29350,
          },
          itemSuffixes = {},
        })
        AddProfile("PriestSmite-Phase1BIS", {
          class = "PRIEST",
          specKey = "PriestShadow",
          specID = 203,
          icon = 136207,
          importedAt = 0,
          items = {
            [1] = 24266,
            [2] = 28530,
            [3] = 29060,
            [5] = 29056,
            [6] = 24256,
            [7] = 30734,
            [8] = 28517,
            [9] = 24250,
            [10] = 30725,
            [11] = 28793,
            [12] = 29172,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 30723,
            [17] = 28734,
            [18] = 28673,
          },
          itemSuffixes = {},
        })
        -- ROGUE
        AddProfile("RogueAssassination-Phase1BIS", {
          class = "ROGUE",
          specKey = "RogueAssassination",
          specID = 182,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 29044,
            [2] = 29381,
            [3] = 27797,
            [5] = 29045,
            [6] = 29247,
            [7] = 28741,
            [8] = 28545,
            [9] = 29246,
            [10] = 27531,
            [11] = 28757,
            [12] = 28649,
            [13] = 28830,
            [14] = 29383,
            [15] = 28672,
            [16] = 28768,
            [17] = 28572,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        AddProfile("RogueCombat-Phase1BIS", {
          class = "ROGUE",
          specKey = "RogueCombat",
          specID = 181,
          icon = 132090,
          importedAt = 0,
          items = {
            [1] = 29044,
            [2] = 29381,
            [3] = 27797,
            [5] = 29045,
            [6] = 29247,
            [7] = 28741,
            [8] = 28545,
            [9] = 29246,
            [10] = 27531,
            [11] = 28757,
            [12] = 28649,
            [13] = 28830,
            [14] = 29383,
            [15] = 28672,
            [16] = 28438,
            [17] = 28189,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        AddProfile("RogueSubtlety-Phase1BIS", {
          class = "ROGUE",
          specKey = "RogueSubtlety",
          specID = 183,
          icon = 132320,
          importedAt = 0,
          items = {
            [1] = 29044,
            [2] = 29381,
            [3] = 27797,
            [5] = 29045,
            [6] = 29247,
            [7] = 28741,
            [8] = 28545,
            [9] = 29246,
            [10] = 27531,
            [11] = 28757,
            [12] = 28649,
            [13] = 28830,
            [14] = 29383,
            [15] = 28672,
            [16] = 28438,
            [17] = 28189,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        -- SHAMAN
        AddProfile("ShamanElemental-Phase1BIS", {
          class = "SHAMAN",
          specKey = "ShamanElemental",
          specID = 261,
          icon = 136048,
          importedAt = 0,
          items = {
            [1] = 29035,
            [2] = 28762,
            [3] = 29037,
            [5] = 29519,
            [6] = 29520,
            [7] = 24262,
            [8] = 28517,
            [9] = 29521,
            [10] = 28780,
            [11] = 30667,
            [12] = 28753,
            [13] = 28785,
            [14] = 29370,
            [15] = 28797,
            [16] = 28770,
            [17] = 29268,
            [18] = 28248,
          },
          itemSuffixes = {},
        })
        AddProfile("ShamanEnhancement-Phase1BIS", {
          class = "SHAMAN",
          specKey = "ShamanEnhancement",
          specID = 263,
          icon = 136051,
          importedAt = 0,
          items = {
            [1] = 29040,
            [2] = 29381,
            [3] = 29043,
            [5] = 29515,
            [6] = 29516,
            [7] = 28741,
            [8] = 28545,
            [9] = 29517,
            [10] = 28776,
            [11] = 28757,
            [12] = 28649,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 28767,
            [17] = 27872,
            [18] = 27815,
          },
          itemSuffixes = {},
        })
        AddProfile("ShamanRestoration-Phase1BIS", {
          class = "SHAMAN",
          specKey = "ShamanRestoration",
          specID = 262,
          icon = 136052,
          importedAt = 0,
          items = {
            [1] = 29028,
            [2] = 28609,
            [3] = 29031,
            [5] = 21875,
            [6] = 21873,
            [7] = 28751,
            [8] = 28752,
            [9] = 29183,
            [10] = 28520,
            [11] = 28763,
            [12] = 28790,
            [13] = 29376,
            [14] = 28190,
            [15] = 28765,
            [16] = 28771,
            [17] = 29458,
            [18] = 28523,
          },
          itemSuffixes = {},
        })
        -- WARLOCK
        AddProfile("WarlockAffliction-Phase1BIS", {
          class = "WARLOCK",
          specKey = "WarlockAffliction",
          specID = 302,
          icon = 136145,
          importedAt = 0,
          items = {
            [1] = 28963,
            [2] = 28762,
            [3] = 28967,
            [5] = 28964,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 28968,
            [11] = 28793,
            [12] = 28753,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 28802,
            [17] = 29273,
            [18] = 28673,
          },
          itemSuffixes = {},
        })
        AddProfile("WarlockDestructionFire-Phase1BIS", {
          class = "WARLOCK",
          specKey = "WarlockDestruction",
          specID = 301,
          icon = 136186,
          importedAt = 0,
          items = {
            [1] = 28963,
            [2] = 28530,
            [3] = 28967,
            [5] = 21848,
            [6] = 21846,
            [7] = 24262,
            [8] = 28517,
            [9] = 24250,
            [10] = 21847,
            [11] = 28793,
            [12] = 28753,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 28802,
            [17] = 29270,
            [18] = 28673,
          },
          itemSuffixes = {},
        })
        AddProfile("WarlockDemonology-Phase1BIS", {
          class = "WARLOCK",
          specKey = "WarlockDemonology",
          specID = 303,
          icon = 136172,
          importedAt = 0,
          items = {
            [1] = 28963,
            [2] = 28762,
            [3] = 28967,
            [5] = 28964,
            [6] = 24256,
            [7] = 24262,
            [8] = 21870,
            [9] = 24250,
            [10] = 28968,
            [11] = 28793,
            [12] = 28753,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 28802,
            [17] = 29273,
            [18] = 28673,
          },
          itemSuffixes = {},
        })
        -- WARRIOR
        AddProfile("WarriorArms-Phase1BIS", {
          class = "WARRIOR",
          specKey = "WarriorArms",
          specID = 161,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 29021,
            [2] = 28745,
            [3] = 29023,
            [5] = 29019,
            [6] = 28779,
            [7] = 28741,
            [8] = 28608,
            [9] = 28795,
            [10] = 28824,
            [11] = 28757,
            [12] = 28730,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 28429,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        AddProfile("WarriorFury-Phase1BIS", {
          class = "WARRIOR",
          specKey = "WarriorFury",
          specID = 164,
          icon = 132347,
          importedAt = 0,
          items = {
            [1] = 29021,
            [2] = 28745,
            [3] = 29023,
            [5] = 29019,
            [6] = 28779,
            [7] = 28741,
            [8] = 28608,
            [9] = 28795,
            [10] = 28824,
            [11] = 28757,
            [12] = 28730,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 28438,
            [17] = 28729,
            [18] = 28772,
          },
          itemSuffixes = {},
        })
        AddProfile("WarriorProtection-Phase1BIS", {
          class = "WARRIOR",
          specKey = "WarriorProtection",
          specID = 163,
          icon = 134952,
          importedAt = 0,
          items = {
            [1] = 29011,
            [2] = 28244,
            [3] = 29023,
            [5] = 29012,
            [6] = 28385,
            [7] = 28621,
            [8] = 28383,
            [9] = 28381,
            [10] = 30644,
            [11] = 30834,
            [12] = 29279,
            [13] = 28121,
            [14] = 29383,
            [15] = 28377,
            [16] = 28749,
            [17] = 28825,
            [18] = 28826,
          },
          itemSuffixes = {},
        })
        wowSims.defaultsVersion = 2
        installedVersion = 2
      end
      if installedVersion < 3 then
        -- Phase 2
        -- DRUID
        AddProfile("DruidBalance-Phase2BIS", {
          class = "DRUID",
          specKey = "DruidBalance",
          specID = 283,
          icon = 136096,
          importedAt = 0,
          items = {
            [1] = 30233,
            [2] = 30015,
            [3] = 30235,
            [5] = 30231,
            [6] = 30038,
            [7] = 24262,
            [8] = 30037,
            [9] = 29918,
            [10] = 30232,
            [11] = 28753,
            [12] = 29302,
            [13] = 29370,
            [14] = 27683,
            [15] = 28797,
            [16] = 29988,
            [18] = 32387,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidFeralDps-Phase2BIS", {
          class = "DRUID",
          specKey = "DruidFeralCombat",
          specID = 281,
          icon = 132276,
          importedAt = 0,
          items = {
            [1] = 8345,
            [2] = 30017,
            [3] = 29100,
            [5] = 29096,
            [6] = 30106,
            [7] = 29995,
            [8] = 28545,
            [9] = 29966,
            [10] = 29947,
            [11] = 30052,
            [12] = 29997,
            [13] = 29383,
            [14] = 30627,
            [15] = 29994,
            [16] = 28658,
            [18] = 29390,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidFeralTank-Phase2BIS", {
          class = "DRUID",
          specKey = "DruidFeralCombat",
          specID = 281,
          icon = 132276,
          importedAt = 0,
          items = {
            [1] = 30228,
            [2] = 33066,
            [3] = 30230,
            [5] = 30222,
            [6] = 30106,
            [7] = 30229,
            [8] = 32790,
            [9] = 32810,
            [10] = 29947,
            [11] = 29279,
            [12] = 30834,
            [13] = 28579,
            [14] = 32658,
            [15] = 28660,
            [16] = 30021,
            [18] = 32387,
          },
          itemSuffixes = {},
        })
        AddProfile("DruidRestoration-Phase2BIS", {
          class = "DRUID",
          specKey = "DruidRestoration",
          specID = 282,
          icon = 136041,
          importedAt = 0,
          items = {
            [1] = 30219,
            [2] = 30018,
            [3] = 30221,
            [5] = 30216,
            [6] = 30036,
            [7] = 28591,
            [8] = 30092,
            [9] = 30062,
            [10] = 28521,
            [11] = 30110,
            [12] = 28763,
            [13] = 29376,
            [14] = 30841,
            [15] = 29989,
            [16] = 30108,
            [17] = 29274,
            [18] = 27886,
          },
          itemSuffixes = {},
        })
        -- HUNTER
        AddProfile("HunterBeastMastery-Phase2BIS", {
          class = "HUNTER",
          specKey = "HunterBeastMastery",
          specID = 361,
          icon = 132164,
          importedAt = 0,
          items = {
            [1] = 30141,
            [2] = 30017,
            [3] = 30143,
            [5] = 30139,
            [6] = 30040,
            [7] = 29995,
            [8] = 30104,
            [9] = 29966,
            [10] = 30140,
            [11] = 29997,
            [12] = 28791,
            [13] = 28830,
            [14] = 29383,
            [15] = 29994,
            [16] = 29993,
            [18] = 30105,
          },
          itemSuffixes = {},
        })
        AddProfile("HunterMarksmanship-Phase2BIS", {
          class = "HUNTER",
          specKey = "HunterMarksmanship",
          specID = 363,
          icon = 132222,
          importedAt = 0,
          items = {
            [1] = 30141,
            [2] = 30017,
            [3] = 30143,
            [5] = 30139,
            [6] = 30040,
            [7] = 29995,
            [8] = 30104,
            [9] = 29966,
            [10] = 30140,
            [11] = 29997,
            [12] = 28791,
            [13] = 28830,
            [14] = 29383,
            [15] = 29994,
            [16] = 29993,
            [18] = 30105,
          },
          itemSuffixes = {},
        })
        AddProfile("HunterSurvival-Phase2BIS", {
          class = "HUNTER",
          specKey = "HunterSurvival",
          specID = 362,
          icon = 132215,
          importedAt = 0,
          items = {
            [1] = 30141,
            [2] = 30017,
            [3] = 30143,
            [5] = 30139,
            [6] = 30040,
            [7] = 30142,
            [8] = 30104,
            [9] = 29966,
            [10] = 28506,
            [11] = 29298,
            [12] = 28791,
            [13] = 28830,
            [14] = 29383,
            [15] = 29994,
            [16] = 29993,
            [18] = 30105,
          },
          itemSuffixes = {},
        })
        -- MAGE
        AddProfile("MageArcane-Phase2BIS", {
          class = "MAGE",
          specKey = "MageArcane",
          specID = 81,
          icon = 135932,
          importedAt = 0,
          items = {
            [1] = 30206,
            [2] = 30015,
            [3] = 30210,
            [5] = 30196,
            [6] = 30038,
            [7] = 30207,
            [8] = 30067,
            [9] = 29918,
            [10] = 29987,
            [11] = 29287,
            [12] = 29302,
            [13] = 29370,
            [14] = 30720,
            [15] = 29992,
            [16] = 29988,
            [18] = 28783,
          },
          itemSuffixes = {},
        })
        AddProfile("MageFire-Phase2BIS", {
          class = "MAGE",
          specKey = "MageFire",
          specID = 41,
          icon = 135810,
          importedAt = 0,
          items = {
            [1] = 30206,
            [2] = 30015,
            [3] = 30210,
            [5] = 30107,
            [6] = 30038,
            [7] = 24262,
            [8] = 30037,
            [9] = 29918,
            [10] = 21847,
            [11] = 29302,
            [12] = 28753,
            [13] = 29370,
            [14] = 30626,
            [15] = 28797,
            [16] = 30095,
            [17] = 29270,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        AddProfile("MageFrost-Phase2BIS", {
          class = "MAGE",
          specKey = "MageFrost",
          specID = 61,
          icon = 135846,
          importedAt = 0,
          items = {
            [1] = 30206,
            [2] = 30015,
            [3] = 30210,
            [5] = 30107,
            [6] = 30038,
            [7] = 24262,
            [8] = 21870,
            [9] = 29918,
            [10] = 28780,
            [11] = 29302,
            [12] = 28753,
            [13] = 29370,
            [14] = 27683,
            [15] = 28797,
            [16] = 30095,
            [17] = 29269,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        -- PALADIN
        AddProfile("PaladinHoly-Phase2BIS", {
          class = "PALADIN",
          specKey = "PaladinHoly",
          specID = 382,
          icon = 135920,
          importedAt = 0,
          items = {
            [1] = 30136,
            [2] = 30018,
            [3] = 30138,
            [5] = 30134,
            [6] = 30030,
            [7] = 29991,
            [8] = 30027,
            [9] = 30047,
            [10] = 30112,
            [11] = 30110,
            [12] = 29920,
            [13] = 29376,
            [14] = 28590,
            [15] = 29989,
            [16] = 30108,
            [17] = 29458,
            [18] = 25644,
          },
          itemSuffixes = {},
        })
        AddProfile("PaladinProtection-Phase2BIS", {
          class = "PALADIN",
          specKey = "PaladinProtection",
          specID = 383,
          icon = 135893,
          importedAt = 0,
          items = {
            [1] = 30125,
            [2] = 33065,
            [3] = 29070,
            [5] = 29066,
            [6] = 30096,
            [7] = 30126,
            [8] = 32267,
            [9] = 32515,
            [10] = 30124,
            [11] = 33054,
            [12] = 29172,
            [13] = 29370,
            [14] = 30447,
            [15] = 29925,
            [16] = 30095,
            [17] = 28825,
            [18] = 27917,
          },
          itemSuffixes = {},
        })
        AddProfile("PaladinRetribution-Phase2BIS", {
          class = "PALADIN",
          specKey = "PaladinRetribution",
          specID = 381,
          icon = 135873,
          importedAt = 0,
          items = {
            [1] = 32461,
            [2] = 30022,
            [3] = 30055,
            [5] = 30129,
            [6] = 30106,
            [7] = 30257,
            [8] = 30081,
            [9] = 28795,
            [10] = 29947,
            [11] = 30834,
            [12] = 30061,
            [13] = 28830,
            [14] = 29383,
            [15] = 30098,
            [16] = 28430,
            [18] = 27484,
          },
          itemSuffixes = {},
        })
        -- PRIEST
        AddProfile("PriestHoly-Phase2BIS", {
          class = "PRIEST",
          specKey = "PriestHoly",
          specID = 202,
          icon = 237542,
          importedAt = 0,
          items = {
            [1] = 30152,
            [2] = 30018,
            [3] = 30154,
            [5] = 30150,
            [6] = 30036,
            [7] = 30153,
            [8] = 30100,
            [9] = 32516,
            [10] = 30151,
            [11] = 30110,
            [12] = 29290,
            [13] = 29376,
            [14] = 30665,
            [15] = 29989,
            [16] = 30108,
            [17] = 29170,
            [18] = 30080,
          },
          itemSuffixes = {},
        })
        AddProfile("PriestShadow-Phase2BIS", {
          class = "PRIEST",
          specKey = "PriestShadow",
          specID = 203,
          icon = 136207,
          importedAt = 0,
          items = {
            [1] = 29986,
            [2] = 30666,
            [3] = 21869,
            [5] = 30107,
            [6] = 30038,
            [7] = 29972,
            [8] = 21870,
            [9] = 29918,
            [10] = 28780,
            [11] = 30109,
            [12] = 29922,
            [13] = 29370,
            [14] = 28789,
            [15] = 29992,
            [16] = 28770,
            [17] = 29272,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        AddProfile("PriestSmite-Phase2BIS", {
          class = "PRIEST",
          specKey = "PriestShadow",
          specID = 203,
          icon = 136207,
          importedAt = 0,
          items = {
            [1] = 30161,
            [2] = 30015,
            [3] = 30163,
            [5] = 30107,
            [6] = 30038,
            [7] = 30162,
            [8] = 30037,
            [9] = 29918,
            [10] = 30160,
            [11] = 30109,
            [12] = 28793,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 30723,
            [17] = 30049,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        -- ROGUE
        AddProfile("RogueAssassination-Phase2BIS", {
          class = "ROGUE",
          specKey = "RogueAssassination",
          specID = 182,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 30146,
            [2] = 29381,
            [3] = 30149,
            [5] = 30101,
            [6] = 30106,
            [7] = 30148,
            [8] = 28545,
            [9] = 29966,
            [10] = 30145,
            [11] = 29997,
            [12] = 30052,
            [13] = 28830,
            [14] = 30450,
            [15] = 28672,
            [16] = 30103,
            [17] = 29962,
            [18] = 29949,
          },
          itemSuffixes = {},
        })
        AddProfile("RogueCombat-Phase2BIS", {
          class = "ROGUE",
          specKey = "RogueCombat",
          specID = 181,
          icon = 132090,
          importedAt = 0,
          items = {
            [1] = 30146,
            [2] = 29381,
            [3] = 30149,
            [5] = 30101,
            [6] = 30106,
            [7] = 30148,
            [8] = 28545,
            [9] = 29966,
            [10] = 30145,
            [11] = 29997,
            [12] = 30052,
            [13] = 28830,
            [14] = 30450,
            [15] = 28672,
            [16] = 30082,
            [17] = 28189,
            [18] = 29949,
          },
          itemSuffixes = {},
        })
        AddProfile("RogueSubtlety-Phase2BIS", {
          class = "ROGUE",
          specKey = "RogueSubtlety",
          specID = 183,
          icon = 132320,
          importedAt = 0,
          items = {
            [1] = 30146,
            [2] = 29381,
            [3] = 30149,
            [5] = 30101,
            [6] = 30106,
            [7] = 30148,
            [8] = 28545,
            [9] = 29966,
            [10] = 30145,
            [11] = 29997,
            [12] = 30052,
            [13] = 28830,
            [14] = 30450,
            [15] = 28672,
            [16] = 30082,
            [17] = 28189,
            [18] = 29949,
          },
          itemSuffixes = {},
        })
        -- SHAMAN
        AddProfile("ShamanElemental-Phase2BIS", {
          class = "SHAMAN",
          specKey = "ShamanElemental",
          specID = 261,
          icon = 136048,
          importedAt = 0,
          items = {
            [1] = 29035,
            [2] = 30015,
            [3] = 29037,
            [5] = 30169,
            [6] = 30038,
            [7] = 30172,
            [8] = 30067,
            [9] = 29918,
            [10] = 28780,
            [11] = 30667,
            [12] = 30109,
            [13] = 28785,
            [14] = 29370,
            [15] = 28797,
            [16] = 29988,
            [18] = 28248,
          },
          itemSuffixes = {},
        })
        AddProfile("ShamanEnhancement-Phase2BIS", {
          class = "SHAMAN",
          specKey = "ShamanEnhancement",
          specID = 263,
          icon = 136051,
          importedAt = 0,
          items = {
            [1] = 30190,
            [2] = 30017,
            [3] = 30055,
            [5] = 30185,
            [6] = 30106,
            [7] = 30192,
            [8] = 30104,
            [9] = 30091,
            [10] = 30189,
            [11] = 29997,
            [12] = 30052,
            [13] = 28830,
            [14] = 29383,
            [15] = 29994,
            [16] = 32944,
            [17] = 29996,
            [18] = 27815,
          },
          itemSuffixes = {},
        })
        AddProfile("ShamanRestoration-Phase2BIS", {
          class = "SHAMAN",
          specKey = "ShamanRestoration",
          specID = 262,
          icon = 136052,
          importedAt = 0,
          items = {
            [1] = 30166,
            [2] = 30018,
            [3] = 30168,
            [5] = 30164,
            [6] = 21873,
            [7] = 29991,
            [8] = 30092,
            [9] = 30047,
            [10] = 29976,
            [11] = 28763,
            [12] = 29920,
            [13] = 29376,
            [14] = 28190,
            [15] = 29989,
            [16] = 30108,
            [17] = 29458,
            [18] = 28523,
          },
          itemSuffixes = {},
        })
        -- WARLOCK
        AddProfile("WarlockAffliction-Phase2BIS", {
          class = "WARLOCK",
          specKey = "WarlockAffliction",
          specID = 302,
          icon = 136145,
          importedAt = 0,
          items = {
            [1] = 30212,
            [2] = 30015,
            [3] = 28967,
            [5] = 30107,
            [6] = 30038,
            [7] = 30213,
            [8] = 30037,
            [9] = 29918,
            [10] = 28968,
            [11] = 30109,
            [12] = 29302,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 30095,
            [17] = 30049,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        AddProfile("WarlockDestruction-Phase2BIS", {
          class = "WARLOCK",
          specKey = "WarlockDestruction",
          specID = 301,
          icon = 136186,
          importedAt = 0,
          items = {
            [1] = 30212,
            [2] = 30015,
            [3] = 28967,
            [5] = 30107,
            [6] = 30038,
            [7] = 30213,
            [8] = 30037,
            [9] = 29918,
            [10] = 28968,
            [11] = 30109,
            [12] = 29302,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 30095,
            [17] = 30049,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        AddProfile("WarlockDestructionFire-Phase2BIS", {
          class = "WARLOCK",
          specKey = "WarlockDestruction",
          specID = 301,
          icon = 136186,
          importedAt = 0,
          items = {
            [1] = 28963,
            [2] = 30015,
            [3] = 28967,
            [5] = 30107,
            [6] = 30038,
            [7] = 30213,
            [8] = 30037,
            [9] = 29918,
            [10] = 21847,
            [11] = 30109,
            [12] = 29302,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 30095,
            [17] = 29270,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        AddProfile("WarlockDemonology-Phase2BIS", {
          class = "WARLOCK",
          specKey = "WarlockDemonology",
          specID = 303,
          icon = 136172,
          importedAt = 0,
          items = {
            [1] = 30212,
            [2] = 30015,
            [3] = 28967,
            [5] = 30107,
            [6] = 30038,
            [7] = 30213,
            [8] = 30037,
            [9] = 29918,
            [10] = 28968,
            [11] = 30109,
            [12] = 29302,
            [13] = 27683,
            [14] = 29370,
            [15] = 28766,
            [16] = 30095,
            [17] = 30049,
            [18] = 29982,
          },
          itemSuffixes = {},
        })
        -- WARRIOR
        AddProfile("WarriorArms-Phase2BIS", {
          class = "WARRIOR",
          specKey = "WarriorArms",
          specID = 161,
          icon = 132292,
          importedAt = 0,
          items = {
            [1] = 30120,
            [2] = 30022,
            [3] = 30055,
            [5] = 30118,
            [6] = 30106,
            [7] = 30121,
            [8] = 30081,
            [9] = 28795,
            [10] = 30119,
            [11] = 29997,
            [12] = 30061,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 29993,
            [18] = 30105,
          },
          itemSuffixes = {},
        })
        AddProfile("WarriorFury-Phase2BIS", {
          class = "WARRIOR",
          specKey = "WarriorFury",
          specID = 164,
          icon = 132347,
          importedAt = 0,
          items = {
            [1] = 30120,
            [2] = 30022,
            [3] = 30055,
            [5] = 30118,
            [6] = 30106,
            [7] = 30121,
            [8] = 30081,
            [9] = 30057,
            [10] = 30119,
            [11] = 29997,
            [12] = 28757,
            [13] = 28830,
            [14] = 29383,
            [15] = 24259,
            [16] = 28439,
            [17] = 30082,
            [18] = 30105,
          },
          itemSuffixes = {},
        })
        AddProfile("WarriorProtection-Phase2BIS", {
          class = "WARRIOR",
          specKey = "WarriorProtection",
          specID = 163,
          icon = 134952,
          importedAt = 0,
          items = {
            [1] = 30115,
            [2] = 33066,
            [3] = 30117,
            [5] = 30113,
            [6] = 30106,
            [7] = 30116,
            [8] = 32793,
            [9] = 32818,
            [10] = 29947,
            [11] = 30834,
            [12] = 30083,
            [13] = 28121,
            [14] = 29383,
            [15] = 29925,
            [16] = 30058,
            [17] = 28825,
            [18] = 32756,
          },
          itemSuffixes = {},
        })
        wowSims.defaultsVersion = 3
        installedVersion = 3
      end
    end
    local function AutoAssignWoWSimsProfileIfMissing()
      if not MerfinPlus.db or not MerfinPlus.db.global then
        return
      end

      local wowSims = MerfinPlus.db.global.wowSims

      wowSims.profiles = wowSims.profiles or {}
      wowSims.assigned = wowSims.assigned or {}

      local profiles = wowSims.profiles
      local assigned = wowSims.assigned

      local name, realm = UnitName("player")
      if not name then
        return
      end
      realm = realm or GetNormalizedRealmName() or "UNKNOWN"
      local charKey = name .. "-" .. realm

      assigned[charKey] = assigned[charKey] or {}

      local class = select(2, UnitClass("player"))
      if not class then
        return
      end

      local bestTab, bestPoints = nil, -1
      for tab = 1, GetNumTalentTabs() do
        local points = select(5, GetTalentTabInfo(tab))
        if points and points > bestPoints then
          bestPoints = points
          bestTab = tab
        end
      end
      if not bestTab then
        return
      end

      local SPEC_ID_BY_CLASS_AND_TAB = {
        WARRIOR = { [1] = 161, [2] = 164, [3] = 163 },
        PALADIN = { [1] = 382, [2] = 383, [3] = 381 },
        HUNTER = { [1] = 361, [2] = 363, [3] = 362 },
        ROGUE = { [1] = 182, [2] = 181, [3] = 183 },
        PRIEST = { [1] = 201, [2] = 202, [3] = 203 },
        SHAMAN = { [1] = 261, [2] = 263, [3] = 262 },
        MAGE = { [1] = 81, [2] = 41, [3] = 61 },
        WARLOCK = { [1] = 302, [2] = 303, [3] = 301 },
        DRUID = { [1] = 283, [2] = 281, [3] = 282 },
      }

      local specID = SPEC_ID_BY_CLASS_AND_TAB[class] and SPEC_ID_BY_CLASS_AND_TAB[class][bestTab]

      if not specID then
        return
      end

      if assigned[charKey][specID] then
        return
      end

      for key, profile in pairs(profiles) do
        if
          profile
          and profile.class == class
          and profile.specID == specID
          and key
          and key:match("%-PreRaidBIS$")
          and not key:match("FeralTank")
        then
          assigned[charKey][specID] = key
          if WeakAuras and WeakAuras.ScanEvents then
            WeakAuras.ScanEvents("MERFIN_WOWSIM_CHANGED")
          end
          return
        end
      end
    end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function()
      C_Timer.After(1, function()
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")
        AutoAssignWoWSimsProfileIfMissing()
      end)
    end)
  end
end

-- Helper to access the active profile table safely
function MerfinPlus:GetDB()
  return (self.db and self.db.profile) or MerfinPlus.defaults.profile
end

local CATA_WOWSIM_SPEC_BY_CLASS_ID = {
  [1] = { 161, 164, 163 },
  [2] = { 382, 383, 381 },
  [3] = { 361, 363, 362 },
  [4] = { 182, 181, 183 },
  [5] = { 201, 202, 203 },
  [6] = { 250, 251, 252 },
  [7] = { 261, 263, 262 },
  [8] = { 81, 41, 61 },
  [9] = { 302, 303, 301 },
  [11] = { 283, 281, 282 },
}

local function GetEffectiveSpecID()
  if IsWrath() or IsTBC() then
    return select(2, Merfin.GetPlayerRole())
  elseif IsMoP() then
    return GetSpecializationInfoForClassID(select(3, UnitClass("player")), C_SpecializationInfo.GetSpecialization())
  elseif IsCata() then
    local classID = select(3, UnitClass("player"))
    local treeIndex = GetPrimaryTalentTree()
    local specs = classID and CATA_WOWSIM_SPEC_BY_CLASS_ID[classID]
    return specs and treeIndex and specs[treeIndex] or nil
  end
end

local function GetCharKey()
  local name = UnitName("player") or "Unknown"
  local realm = GetNormalizedRealmName() or GetRealmName() or "UnknownRealm"
  return name .. "-" .. realm
end

function Merfin.GetActiveSimProfile()
  local db = MerfinPlus.db
  if not (db and db.global and db.global.wowSims) then
    return nil
  end

  local charKey = GetCharKey()
  local assigned = db.global.wowSims.assigned[charKey]
  if not assigned then
    return nil
  end

  local specID = GetEffectiveSpecID()
  if not specID then
    return nil
  end

  local profileKey = assigned[specID]
  if not profileKey then
    return nil
  end

  return db.global.wowSims.profiles[profileKey]
end

function Merfin.GetActiveItemSuffix()
  local profile = Merfin.GetActiveSimProfile()
  if not profile or not profile.itemSuffixes then
    return nil
  end

  return profile.itemSuffixes
end

-- Build and register all options (Blizzard panels + standalone window + slash commands)
function MerfinPlus:SetupOptions()
  local version = GetAddOnMetadata("MerfinPlus", "Version") or "?"

  local wowSimOptions

  -- ==== Media lists (LSM) ====
  local function GetFontList()
    local fonts = {}
    local excluded = {
      ["Merfin Font 1"] = true,
      ["Merfin Font 2"] = true,
      ["Merfin Raid Font"] = true,
      ["Merfin Raid Font (Bold)"] = true,
    }
    for name in pairs(LSM:HashTable("font")) do
      if not excluded[name] then
        fonts[name] = name
      end
    end
    return fonts
  end

  local function GetStatusBarList()
    local bars = {}
    local excluded = {
      ["Merfin Status Bar 1"] = true,
      ["Merfin Status Bar 2"] = true,
      ["Merfin Raid Status Bar"] = true,
    }
    for name in pairs(LSM:HashTable("statusbar")) do
      if not excluded[name] then
        bars[name] = name
      end
    end
    return bars
  end

  -- ==== UI reload popup ====
  local function ConfirmReload()
    StaticPopupDialogs["MERFINPLUS_RELOAD_UI"] = {
      text = L["A reload of the interface is required for this change to take effect.\n\nReload now?"],
      button1 = YES,
      button2 = NO,
      OnAccept = function()
        ReloadUI()
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }
    StaticPopup_Show("MERFINPLUS_RELOAD_UI")
  end

  -- ==== Root (Blizzard top-level) ====
  local mainOptions = {
    type = "group",
    name = "MerfinPlus v" .. version,
    args = {
      version = {
        type = "description",
        name = "|cff00ccff" .. L["Version:"] .. "|r" .. version,
        fontSize = "medium",
        order = 1,
      },
      author = {
        type = "description",
        name = L["Author: "] .. "Merfin",
        fontSize = "medium",
        order = 2,
      },
      spacer = { type = "description", name = " ", order = 3 },
      description = {
        type = "description",
        name = L["MerfinPlus provides custom fonts, textures, and utilities that enhance or support WeakAuras and other Merfin UI components."],
        fontSize = "large",
        order = 4,
      },
      spacer2 = { type = "description", name = " ", order = 5 },
    },
  }

  -- ==== Media ====
  local mediaOptions = {
    type = "group",
    name = "Media",
    args = {
      description = {
        type = "description",
        name = L["Change primary fonts and status bar textures used by Merfin features. A UI reload is required."],
        fontSize = "medium",
        order = 0,
      },
    },
  }

  local fontNames = { "Merfin Font 1", "Merfin Font 2" }
  local barNames = { "Merfin Status Bar 1", "Merfin Status Bar 2" }

  for i = 1, #fontNames do
    mediaOptions.args["font" .. i] = {
      type = "select",
      name = fontNames[i],
      desc = L["Select font for element "] .. i,
      values = GetFontList,
      get = function()
        return self.db.profile["font" .. i]
      end,
      set = function(_, v)
        self.db.profile["font" .. i] = v
        ConfirmReload()
      end,
      dialogControl = "LSM30_Font",
      order = i + 1,
    }
  end
  for i = 1, #barNames do
    mediaOptions.args["bar" .. i] = {
      type = "select",
      name = barNames[i],
      desc = L["Select status bar texture for element "] .. i,
      values = GetStatusBarList,
      get = function()
        return self.db.profile["bar" .. i]
      end,
      set = function(_, v)
        self.db.profile["bar" .. i] = v
        ConfirmReload()
      end,
      dialogControl = "LSM30_Statusbar",
      order = i + 10,
    }
  end

  local raidPackLocaleValues = {
    enUS = "enUS",
    deDE = "deDE",
    frFR = "frFR",
    esES = "esES",
    esMX = "esMX",
    itIT = "itIT",
    ptBR = "ptBR",
    ruRU = "ruRU",
    koKR = "koKR",
    zhCN = "zhCN",
    zhTW = "zhTW",
  }

  local raidCooldownCatalog = {
    serpentshrineCavern = {},
    tempestKeep = {},
    blackTemple = {
      { encounter = "601", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "601", id = "ImpalingSpine", spell = 39837 },
      { encounter = "601", id = "TidalShield", spell = 39872 },
      { encounter = "602", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "602", id = "ChaseTarget", name = "Chase Target", spell = 39837 },
      { encounter = "602", id = "MoltenPunch", spell = 40126 },
      { encounter = "603", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "603", id = "AshtongueDefender", spell = 40457 },
      { encounter = "603", id = "AshtongueSorcerer", name = "Ashtongue Sorcerer", icon = 136033 },
      { encounter = "604", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "604", id = "CrushingShadows", spell = 40243 },
      { encounter = "604", id = "Incinerate", spell = 40239 },
      { encounter = "604", id = "ShadowOfDeath", spell = 40251 },
      { encounter = "605", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "605", id = "BewilderingStrike", spell = 40491 },
      { encounter = "605", id = "Bloodboil", spell = 42005 },
      { encounter = "605", id = "Eject", spell = 40597 },
      { encounter = "605", id = "FelAcidBreath", spell = 40508 },
      { encounter = "605", id = "FelRage", spell = 40604 },
      { encounter = "606", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "606", id = "0Mana", name = "0 Mana", icon = 135738 },
      { encounter = "606", id = "Transition", name = "Transition", icon = "Interface\\Addons\\MerfinPlus\\Media\\icons\\raid\\bt_eos_128.png" },
      { encounter = "606", id = "Deaden", spell = 41410 },
      { encounter = "606", id = "Enrage", spell = 41305 },
      { encounter = "606", id = "Fixate", spell = 41294 },
      { encounter = "606", id = "RuneShield", spell = 41431 },
      { encounter = "606", id = "SoulDrain", spell = 41303 },
      { encounter = "606", id = "SoulScream", spell = 41545 },
      { encounter = "606", id = "Spite", spell = 41376 },
      { encounter = "607", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "607", id = "FatalAttraction", spell = 41001, icon = 136202 },
      { encounter = "607", id = "PrismaticAura", name = "Next Prismatic Aura", icon = 134088 },
      { encounter = "607", id = "SilencingShriek", spell = 40823 },
      { encounter = "608", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "608", id = "Blizzard", spell = 41482 },
      { encounter = "608", id = "CircleOfHealing", spell = 41455 },
      { encounter = "608", id = "Consecration", spell = 41541 },
      { encounter = "608", id = "DampenMagic", spell = 41478 },
      { encounter = "608", id = "Flamestrike", spell = 41481 },
      { encounter = "608", id = "Vanish", name = "Vanish", spell = 41476 },
      { encounter = "609", id = "Berserk", name = "Berserk", icon = 136206 },
      { encounter = "609", id = "AgonizingFlames", spell = 40932 },
      { encounter = "609", id = "DarkBarrage", spell = 40585 },
      { encounter = "609", id = "DemonForm", name = "Demon Form", icon = 40506 },
      { encounter = "609", id = "DrawSoul", spell = 40904 },
      { encounter = "609", id = "EyeBlast", spell = 40018, icon = 135780 },
      { encounter = "609", id = "FlameBurst", spell = 41131 },
      { encounter = "609", id = "FlameCrash", spell = 40832 },
      { encounter = "609", id = "ParasiticShadowfiend", spell = 41917 },
      { encounter = "609", id = "Phase4", name = "Phase 4", icon = "Interface\\Addons\\MerfinPlus\\Media\\icons\\raid\\bt_illidan_128.png" },
      { encounter = "609", id = "Shear", spell = 41032 },
    },
    hyjalSummit = {},
  }

  for _, cooldown in ipairs(MerfinPlus.BTTrashCooldownCatalog or {}) do
    raidCooldownCatalog.blackTemple[#raidCooldownCatalog.blackTemple + 1] = cooldown
  end
  for _, cooldown in ipairs(MerfinPlus.SSCCooldownCatalog or {}) do
    raidCooldownCatalog.serpentshrineCavern[#raidCooldownCatalog.serpentshrineCavern + 1] = cooldown
  end
  for _, cooldown in ipairs(MerfinPlus.TKCooldownCatalog or {}) do
    raidCooldownCatalog.tempestKeep[#raidCooldownCatalog.tempestKeep + 1] = cooldown
  end
  MerfinPlus.RaidCooldownCatalog = raidCooldownCatalog

  local encounterNames = {
    ["623"] = "Hydross the Unstable", ["624"] = "The Lurker Below",
    ["625"] = "Leotheras the Blind", ["627"] = "Morogrim Tidewalker", ["628"] = "Lady Vashj",
    ["730"] = "Al'ar", ["731"] = "Void Reaver", ["732"] = "High Astromancer Solarian",
    ["733"] = "Kael'thas Sunstrider",
    ["601"] = "High Warlord Naj'entus", ["602"] = "Supremus", ["603"] = "Shade of Akama",
    ["604"] = "Teron Gorefiend", ["605"] = "Gurtogg Bloodboil", ["606"] = "Reliquary of Souls",
    ["607"] = "Mother Shahraz", ["608"] = "Illidari Council", ["609"] = "Illidan Stormrage",
  }

  local raidBossIconPath = "Interface\\Addons\\MerfinPlus\\Media\\icons\\raid\\"
  local encounterBossIcons = {
    ["623"] = raidBossIconPath .. "ssc_hydross_128.png",
    ["624"] = raidBossIconPath .. "ssc_lurker_128.png",
    ["625"] = raidBossIconPath .. "ssc_leotheras_128.png",
    ["627"] = raidBossIconPath .. "ssc_morogrim_128.png",
    ["628"] = raidBossIconPath .. "ssc_vashj_128.png",
    ["730"] = raidBossIconPath .. "tk_alar_128.png",
    ["731"] = raidBossIconPath .. "tk_reaver_128.png",
    ["732"] = raidBossIconPath .. "tk_solarian_128.png",
    ["733"] = raidBossIconPath .. "tk_kt_128.png",
    ["601"] = raidBossIconPath .. "bt_najentus_128.png",
    ["602"] = raidBossIconPath .. "bt_supremus_128.png",
    ["603"] = raidBossIconPath .. "bt_akama_128.png",
    ["604"] = raidBossIconPath .. "bt_teron_128.png",
    ["605"] = raidBossIconPath .. "bt_gurtogg_128.png",
    ["606"] = raidBossIconPath .. "bt_eos_128.png",
    ["607"] = raidBossIconPath .. "bt_shahraz_128.png",
    ["608"] = raidBossIconPath .. "bt_council_128.png",
    ["609"] = raidBossIconPath .. "bt_illidan_128.png",
  }
  local autoMarkerBossIcons = {
    [22887] = encounterBossIcons["601"], -- High Warlord Naj'entus
    [22898] = encounterBossIcons["602"], -- Supremus
    [22841] = encounterBossIcons["603"], -- Shade of Akama
    [22871] = encounterBossIcons["604"], -- Teron Gorefiend
    [22948] = encounterBossIcons["605"], -- Gurtogg Bloodboil
    [22947] = encounterBossIcons["607"], -- Mother Shahraz
    [22949] = encounterBossIcons["608"], -- Gathios the Shatterer
    [22950] = encounterBossIcons["608"], -- High Nethermancer Zerevor
    [22951] = encounterBossIcons["608"], -- Lady Malande
    [22952] = encounterBossIcons["608"], -- Veras Darkshadow
    [22917] = encounterBossIcons["609"], -- Illidan Stormrage
  }

  local function BossLabel(name, icon)
    return icon and ("|T" .. icon .. ":16:16:0:0|t " .. name) or name
  end

  local encounterOrders = {
    serpentshrineCavern = { "623", "624", "625", "627", "628" },
    tempestKeep = { "730", "731", "732", "733" },
    blackTemple = { "601", "602", "603", "604", "605", "606", "607", "608", "609" },
  }
  local selectedRaidCooldown = {}

  local function GetRaidCooldownDB(raidKey)
    local profile = MerfinPlus.db.profile
    profile.raidCooldowns = profile.raidCooldowns or {}
    profile.raidCooldowns.general = profile.raidCooldowns.general or {}
    profile.raidCooldowns.raids = profile.raidCooldowns.raids or {}
    profile.raidCooldowns.raids[raidKey] = profile.raidCooldowns.raids[raidKey] or {}
    return profile.raidCooldowns.raids[raidKey]
  end

  local function FindRaidCooldown(raidKey, encounterID, cooldownID, npcID)
    for _, cooldown in ipairs(raidCooldownCatalog[raidKey]) do
      if cooldown.encounter == encounterID and cooldown.id == cooldownID and (not npcID or cooldown.npc == npcID) then
        return cooldown
      end
    end
  end

  local function CooldownLabel(cooldown)
    local name = cooldown.name or cooldown.fallbackName
    local icon = cooldown.icon
    if cooldown.spell then
      name = name or (Merfin.GetSpellName and Merfin.GetSpellName(cooldown.spell)) or cooldown.id
      icon = icon or C_Spell.GetSpellTexture(cooldown.spell)
    end
    name = name or cooldown.id
    local texture = icon and ("|T" .. tostring(icon) .. ":16:16:0:0|t ") or ""
    return texture .. name
  end

  local function NotifyRaidCooldownChanged()
    if Merfin and Merfin.NotifyRaidCooldownConfigChanged then
      Merfin.NotifyRaidCooldownConfigChanged()
    end
  end

  local function BuildEncounterCooldownOptions(raidKey, encounterID, npcID)
    local encounterCooldowns = {}
    for _, cooldown in ipairs(raidCooldownCatalog[raidKey]) do
      if cooldown.encounter == encounterID and (not npcID or cooldown.npc == npcID) then
        encounterCooldowns[#encounterCooldowns + 1] = cooldown
      end
    end

    local selectionKey = npcID and (encounterID .. ":" .. npcID) or encounterID
    selectedRaidCooldown[selectionKey] = selectedRaidCooldown[selectionKey] or (encounterCooldowns[1] and encounterCooldowns[1].id)

    local function Selected()
      return FindRaidCooldown(raidKey, encounterID, selectedRaidCooldown[selectionKey], npcID)
    end
    local function Settings()
      local cooldown = Selected()
      if not cooldown then return end
      local raidDB = GetRaidCooldownDB(raidKey)
      raidDB[encounterID] = raidDB[encounterID] or {}
      raidDB[encounterID][cooldown.id] = raidDB[encounterID][cooldown.id] or {}
      return raidDB[encounterID][cooldown.id]
    end
    local function EncounterDisabled()
      local raidDB = GetRaidCooldownDB(raidKey)
      return raidDB[encounterID] and raidDB[encounterID].__disabled == true
    end
    local function SetEncounterDisabled(value)
      local raidDB = GetRaidCooldownDB(raidKey)
      raidDB[encounterID] = raidDB[encounterID] or {}
      raidDB[encounterID].__disabled = value
      NotifyRaidCooldownChanged()
    end

    return {
      cooldown = {
        type = "select", name = L["Cooldown"], order = 1, width = 1.75,
        dialogControl = COOLDOWN_DROPDOWN_TYPE,
        disabled = EncounterDisabled,
        values = function()
          local values = {}
          for _, entry in ipairs(encounterCooldowns) do
            cooldownTooltipSpells[entry.id] = entry.spell
            values[entry.id] = CooldownLabel(entry)
          end
          return values
        end,
        get = function() return selectedRaidCooldown[selectionKey] end,
        set = function(_, value) selectedRaidCooldown[selectionKey] = value end,
      },
      cooldownHeader = { type = "header", name = function() local c = Selected(); return c and CooldownLabel(c) or L["Cooldown Options"] end, order = 2 },
      disableAll = {
        type = "toggle", name = L["Disable All Cooldowns for Boss"], order = 1.5, width = 1.5,
        get = EncounterDisabled,
        set = function(_, value) SetEncounterDisabled(value) end,
      },
      rowAfterDisableAll = { type = "description", name = "", order = 1.6, width = "full" },
      displayBar = {
        type = "toggle", name = L["Display as Bar"], order = 3.1, width = 1,
        disabled = EncounterDisabled,
        get = function() local s = Settings(); return not s or s.displayBar ~= false end,
        set = function(_, value) Settings().displayBar = value; NotifyRaidCooldownChanged() end,
      },
      displayTimeline = {
        type = "toggle", name = L["Display on Timeline"], order = 3.2, width = 1,
        disabled = EncounterDisabled,
        get = function() local s = Settings(); return not s or s.displayTimeline ~= false end,
        set = function(_, value) Settings().displayTimeline = value; NotifyRaidCooldownChanged() end,
      },
      rowAfterEnable = { type = "description", name = "", order = 3.5, width = "full" },
      emphasizedBar = {
        type = "toggle", name = L["Emphasized Bar"], order = 4, width = 1.25,
        disabled = EncounterDisabled,
        get = function() local s = Settings(); return s and s.emphasizedBar or false end,
        set = function(_, value) Settings().emphasizedBar = value; NotifyRaidCooldownChanged() end,
      },
      emphasizedOn = {
        type = "range", name = L["Emphasize when (sec) left"], order = 5, min = 3, max = 30, step = 0.5, width = 1.5,
        disabled = function() local s = Settings(); return EncounterDisabled() or not (s and s.emphasizedBar) end,
        get = function() local s = Settings(); return (s and s.emphasizedOn) or 7 end,
        set = function(_, value) Settings().emphasizedOn = value; NotifyRaidCooldownChanged() end,
      },
      rowAfterEmphasis = { type = "description", name = "", order = 5.5, width = "full" },
      enabledCustom = {
        type = "toggle", name = L["Use Custom Name"], order = 6, width = 1.25,
        disabled = EncounterDisabled,
        get = function() local s = Settings(); return s and s.enabledCustom or false end,
        set = function(_, value) Settings().enabledCustom = value; NotifyRaidCooldownChanged() end,
      },
      customName = {
        type = "input", name = L["Custom Name"], order = 7, width = 1.75,
        disabled = function() local s = Settings(); return EncounterDisabled() or not (s and s.enabledCustom) end,
        get = function() local s = Settings(); return (s and s.customName) or "" end,
        set = function(_, value) Settings().customName = value; NotifyRaidCooldownChanged() end,
      },
    }
  end

  local function BuildTrashCooldownOptions(raidKey, trashEncounterID)
    local mobsByNpc, mobList = {}, {}
    local wingColors = {
      karaborSewers = "5BC0EB",
      illidariTrainingGrounds = "FDE74C",
      shadeOfAkama = "9B5DE5",
      sanctuaryOfShadow = "00BBF9",
      gorefiendsVigil = "F15BB5",
      hallsOfAnguish = "FF9F1C",
      shrineOfLostSouls = "B8F2E6",
      denOfMortalDelights = "FF70A6",
      grandPromenade = "70E000",
      chamberOfCommand = "F94144",
      templeSummit = "C77DFF",
    }
    local npcWing = {}
    if raidKey == "blackTemple" then
      local btMarkerCatalog = MerfinPlus.AutoMarkerCatalog and MerfinPlus.AutoMarkerCatalog["IID564"]
      for wingOrder, section in ipairs(btMarkerCatalog and btMarkerCatalog.sections or {}) do
        for _, npcID in ipairs(section.npcs or {}) do
          npcWing[npcID] = { key = section.key, order = wingOrder }
        end
      end
    end

    for _, cooldown in ipairs(raidCooldownCatalog[raidKey]) do
      if cooldown.encounter == trashEncounterID and not mobsByNpc[cooldown.npc] then
        mobsByNpc[cooldown.npc] = cooldown.mob
        local wing = npcWing[cooldown.npc]
        mobList[#mobList + 1] = {
          npc = cooldown.npc,
          name = cooldown.mob,
          wingKey = wing and wing.key,
          wingOrder = wing and wing.order or 999,
        }
      end
    end
    table.sort(mobList, function(a, b)
      if a.wingOrder ~= b.wingOrder then return a.wingOrder < b.wingOrder end
      return a.name < b.name
    end)

    local mobSorting = {}
    for _, mob in ipairs(mobList) do mobSorting[#mobSorting + 1] = mob.npc end

    local selectedNpc = mobList[1] and mobList[1].npc
    local selectedByNpc = {}

    local function CooldownsForSelectedMob()
      local cooldowns = {}
      for _, cooldown in ipairs(raidCooldownCatalog[raidKey]) do
        if cooldown.encounter == trashEncounterID and cooldown.npc == selectedNpc then
          cooldowns[#cooldowns + 1] = cooldown
        end
      end
      return cooldowns
    end

    local function Selected()
      if not selectedNpc then return end
      local cooldowns = CooldownsForSelectedMob()
      selectedByNpc[selectedNpc] = selectedByNpc[selectedNpc] or (cooldowns[1] and cooldowns[1].id)
      return FindRaidCooldown(raidKey, trashEncounterID, selectedByNpc[selectedNpc], selectedNpc)
    end

    local function Settings()
      local cooldown = Selected()
      if not cooldown then return end
      local raidDB = GetRaidCooldownDB(raidKey)
      raidDB[trashEncounterID] = raidDB[trashEncounterID] or {}
      raidDB[trashEncounterID][cooldown.id] = raidDB[trashEncounterID][cooldown.id] or {}
      return raidDB[trashEncounterID][cooldown.id]
    end
    local function EnemyDisabled()
      if not selectedNpc then return false end
      local raidDB = GetRaidCooldownDB(raidKey)
      local encounter = raidDB[trashEncounterID]
      return encounter and encounter.__disabledNpcs and encounter.__disabledNpcs[selectedNpc] == true
    end
    local function SetEnemyDisabled(value)
      if not selectedNpc then return end
      local raidDB = GetRaidCooldownDB(raidKey)
      raidDB[trashEncounterID] = raidDB[trashEncounterID] or {}
      raidDB[trashEncounterID].__disabledNpcs = raidDB[trashEncounterID].__disabledNpcs or {}
      raidDB[trashEncounterID].__disabledNpcs[selectedNpc] = value or nil
      NotifyRaidCooldownChanged()
    end

    return {
      mob = {
        type = "select", name = L["Enemy"], order = 1, width = 1.35,
        values = function()
          local values = {}
          for _, mob in ipairs(mobList) do
            local color = wingColors[mob.wingKey]
            values[mob.npc] = color and ("|cff" .. color .. mob.name .. "|r") or mob.name
          end
          return values
        end,
        sorting = mobSorting,
        get = function() return selectedNpc end,
        set = function(_, value) selectedNpc = value end,
      },
      cooldown = {
        type = "select", name = L["Cooldown"], order = 2, width = 1.35,
        dialogControl = COOLDOWN_DROPDOWN_TYPE,
        disabled = EnemyDisabled,
        values = function()
          local values = {}
          for _, cooldown in ipairs(CooldownsForSelectedMob()) do
            cooldownTooltipSpells[cooldown.id] = cooldown.spell
            values[cooldown.id] = CooldownLabel(cooldown)
          end
          return values
        end,
        get = function() local cooldown = Selected(); return cooldown and cooldown.id end,
        set = function(_, value)
          if selectedNpc then selectedByNpc[selectedNpc] = value end
        end,
      },
      cooldownHeader = { type = "header", name = function() local c = Selected(); return c and CooldownLabel(c) or L["Cooldown Options"] end, order = 3 },
      disableAll = {
        type = "toggle", name = L["Disable All Cooldowns for Enemy"], order = 2.5, width = 1.5,
        get = EnemyDisabled,
        set = function(_, value) SetEnemyDisabled(value) end,
      },
      rowAfterDisableAll = { type = "description", name = "", order = 2.6, width = "full" },
      displayBar = {
        type = "toggle", name = L["Display as Bar"], order = 4.1, width = 0.9,
        disabled = EnemyDisabled,
        get = function() local s = Settings(); return s and s.displayBar == true end,
        set = function(_, value) Settings().displayBar = value; NotifyRaidCooldownChanged() end,
      },
      displayTimeline = {
        type = "toggle", name = L["Display on Timeline"], order = 4.2, width = 0.9,
        disabled = EnemyDisabled,
        get = function() local s = Settings(); return s and s.displayTimeline == true end,
        set = function(_, value) Settings().displayTimeline = value; NotifyRaidCooldownChanged() end,
      },
      displayNameplate = {
        type = "toggle", name = L["Display on Nameplates"], order = 4.3, width = 1.2,
        disabled = EnemyDisabled,
        get = function() local s = Settings(); return not s or s.displayNameplate ~= false end,
        set = function(_, value) Settings().displayNameplate = value; NotifyRaidCooldownChanged() end,
      },
      rowAfterEnable = { type = "description", name = "", order = 4.5, width = "full" },
      emphasizedBar = {
        type = "toggle", name = L["Emphasized Bar"], order = 5, width = 1.25,
        disabled = EnemyDisabled,
        get = function() local s = Settings(); return s and s.emphasizedBar or false end,
        set = function(_, value) Settings().emphasizedBar = value; NotifyRaidCooldownChanged() end,
      },
      emphasizedOn = {
        type = "range", name = L["Emphasize when (sec) left"], order = 6, min = 3, max = 30, step = 0.5, width = 1.5,
        disabled = function() local s = Settings(); return EnemyDisabled() or not (s and s.emphasizedBar) end,
        get = function() local s = Settings(); return (s and s.emphasizedOn) or 7 end,
        set = function(_, value) Settings().emphasizedOn = value; NotifyRaidCooldownChanged() end,
      },
      rowAfterEmphasis = { type = "description", name = "", order = 6.5, width = "full" },
      enabledCustom = {
        type = "toggle", name = L["Use Custom Name"], order = 7, width = 1.25,
        disabled = EnemyDisabled,
        get = function() local s = Settings(); return s and s.enabledCustom or false end,
        set = function(_, value) Settings().enabledCustom = value; NotifyRaidCooldownChanged() end,
      },
      customName = {
        type = "input", name = L["Custom Name"], order = 8, width = 1.75,
        disabled = function() local s = Settings(); return EnemyDisabled() or not (s and s.enabledCustom) end,
        get = function() local s = Settings(); return (s and s.customName) or "" end,
        set = function(_, value) Settings().customName = value; NotifyRaidCooldownChanged() end,
      },
    }
  end

  local function BuildRaidBosses(raidKey, trashEncounterID)
    local bosses = {
      trash = {
        type = "group",
        name = L["Trash"],
        order = 1,
        args = BuildTrashCooldownOptions(raidKey, trashEncounterID),
      },
    }
    for order, encounterID in ipairs(encounterOrders[raidKey]) do
      bosses["boss" .. encounterID] = {
        type = "group",
        name = BossLabel(encounterNames[encounterID], encounterBossIcons[encounterID]),
        order = order + 1,
        args = BuildEncounterCooldownOptions(raidKey, encounterID),
      }
    end
    return bosses
  end

  local selectedAutoMarkerInstance = "IID564"
  local selectedAutoMarkerSection = {}
  local autoMarkerMarkValues = {
    [0] = NONE,
    [1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t",
    [2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t",
    [3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t",
    [4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t",
    [5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t",
    [6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t",
    [7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t",
    [8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t",
  }

  local function GetAutoMarkerDB()
    local profile = MerfinPlus.db.profile
    profile.raidAutoMarker = profile.raidAutoMarker or { mouseover = 4, instances = {}, mechanics = {} }
    profile.raidAutoMarker.instances = profile.raidAutoMarker.instances or {}
    profile.raidAutoMarker.mechanics = profile.raidAutoMarker.mechanics or {}
    return profile.raidAutoMarker
  end

  local function AutoMarkerCatalogInstance()
    return MerfinPlus.AutoMarkerCatalog and MerfinPlus.AutoMarkerCatalog[selectedAutoMarkerInstance]
  end

  local function EnsureSelectedAutoMarkerSection()
    local catalog = AutoMarkerCatalogInstance()
    if not catalog or not catalog.sections or not catalog.sections[1] then return end
    selectedAutoMarkerSection[selectedAutoMarkerInstance] = selectedAutoMarkerSection[selectedAutoMarkerInstance]
      or catalog.sections[1].key
    return selectedAutoMarkerSection[selectedAutoMarkerInstance]
  end

  local function NotifyAutoMarkerChanged()
    if Merfin and Merfin.NotifyRaidAutoMarkerConfigChanged then
      Merfin.NotifyRaidAutoMarkerConfigChanged()
    end
  end

  local function AutoMarkerSettingsFor(instanceKey, npcID)
    local db = GetAutoMarkerDB()
    db.instances[instanceKey] = db.instances[instanceKey] or {}
    db.instances[instanceKey][npcID] = db.instances[instanceKey][npcID]
      or { enable = true, priority = 1, marks = {} }
    local settings = db.instances[instanceKey][npcID]
    settings.marks = settings.marks or {}
    return settings
  end

  local function FriendlyMarkerSettingsFor(mechanicKey)
    local db = GetAutoMarkerDB()
    local defaults = MerfinPlus.AutoMarkerDefaults.mechanics[mechanicKey] or {}
    if not db.mechanics[mechanicKey] then
      local marks = {}
      for index = 1, 8 do marks[index] = defaults.marks and defaults.marks[index] or nil end
      db.mechanics[mechanicKey] = { enable = defaults.enable ~= false, marks = marks }
    end
    local settings = db.mechanics[mechanicKey]
    settings.marks = settings.marks or {}
    return settings, defaults
  end

  local friendlyMarkerArgs = {
    description = {
      type = "description", order = 1, width = "full",
      name = "Configure raid markers assigned to players targeted by boss mechanics.",
    },
  }

  local selectedFriendlyMarkerRaid = "IID564"
  local selectedFriendlyMarkerBoss = {}

  local function FriendlyBossesForRaid(raidKey)
    local bosses, seen = {}, {}
    for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
      if mechanic.raid == raidKey and not seen[mechanic.boss] then
        seen[mechanic.boss] = true
        bosses[#bosses + 1] = { key = mechanic.boss, name = mechanic.bossName }
      end
    end
    table.sort(bosses, function(a, b)
      return (tonumber(a.key) or math.huge) < (tonumber(b.key) or math.huge)
    end)
    return bosses
  end

  local function EnsureSelectedFriendlyBoss()
    local bosses = FriendlyBossesForRaid(selectedFriendlyMarkerRaid)
    local selected = selectedFriendlyMarkerBoss[selectedFriendlyMarkerRaid]
    for _, boss in ipairs(bosses) do
      if boss.key == selected then return selected end
    end
    selected = bosses[1] and bosses[1].key
    selectedFriendlyMarkerBoss[selectedFriendlyMarkerRaid] = selected
    return selected
  end

  friendlyMarkerArgs.raid = {
    type = "select", name = L["Raid"], order = 2, width = 1.5,
    values = function()
      local values = {}
      for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
        values[mechanic.raid] = mechanic.raidName
      end
      return values
    end,
    get = function() return selectedFriendlyMarkerRaid end,
    set = function(_, value)
      selectedFriendlyMarkerRaid = value
      EnsureSelectedFriendlyBoss()
      AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
    end,
  }

  friendlyMarkerArgs.boss = {
    type = "select", name = "Boss", order = 3, width = 1.5,
    values = function()
      local values = {}
      for _, boss in ipairs(FriendlyBossesForRaid(selectedFriendlyMarkerRaid)) do
        values[boss.key] = boss.name
      end
      return values
    end,
    sorting = function()
      local sorting = {}
      for _, boss in ipairs(FriendlyBossesForRaid(selectedFriendlyMarkerRaid)) do
        sorting[#sorting + 1] = boss.key
      end
      return sorting
    end,
    get = EnsureSelectedFriendlyBoss,
    set = function(_, value)
      selectedFriendlyMarkerBoss[selectedFriendlyMarkerRaid] = value
      AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
    end,
  }

  friendlyMarkerArgs.bossHeader = {
    type = "header", order = 4,
    name = function()
      local selected = EnsureSelectedFriendlyBoss()
      for _, boss in ipairs(FriendlyBossesForRaid(selectedFriendlyMarkerRaid)) do
        if boss.key == selected then return boss.name end
      end
      return "Boss"
    end,
  }

  for mechanicIndex, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
    local rowMechanic = mechanic
    local rowArgs = {
      enable = {
        type = "toggle", order = 1, width = 1.3,
        name = function()
          local texture = rowMechanic.icon
            or rowMechanic.spellID and C_Spell and C_Spell.GetSpellTexture
              and C_Spell.GetSpellTexture(rowMechanic.spellID)
            or rowMechanic.spellID and GetSpellTexture and GetSpellTexture(rowMechanic.spellID)
            or 134400
          return ("|T%s:16:16|t %s"):format(texture, rowMechanic.name)
        end,
        get = function()
          local settings, defaults = FriendlyMarkerSettingsFor(rowMechanic.key)
          if settings.enable == nil then return defaults.enable ~= false end
          return settings.enable
        end,
        set = function(_, value)
          local settings = FriendlyMarkerSettingsFor(rowMechanic.key)
          settings.enable = value
          NotifyAutoMarkerChanged()
        end,
      },
    }

    for markerIndex = 1, rowMechanic.maxMarks do
      local rowMarkerIndex = markerIndex
      rowArgs["mark" .. rowMarkerIndex] = {
        type = "select", name = "", order = 1 + rowMarkerIndex, width = 0.4,
        values = autoMarkerMarkValues,
        get = function()
          local settings, defaults = FriendlyMarkerSettingsFor(rowMechanic.key)
          local mark = tonumber(settings.marks[rowMarkerIndex])
            or tonumber(defaults.marks and defaults.marks[rowMarkerIndex])
          return mark and mark >= 1 and mark <= 8 and mark or 0
        end,
        set = function(_, value)
          local settings = FriendlyMarkerSettingsFor(rowMechanic.key)
          -- Keep 0 explicitly: nil would expose the AceDB default again.
          settings.marks[rowMarkerIndex] = tonumber(value) or 0
          NotifyAutoMarkerChanged()
        end,
      }
    end

    friendlyMarkerArgs["mechanic_" .. rowMechanic.key] = {
      type = "group", name = "", inline = true, order = 10 + mechanicIndex,
      hidden = function()
        return selectedFriendlyMarkerRaid ~= rowMechanic.raid
          or EnsureSelectedFriendlyBoss() ~= rowMechanic.boss
      end,
      args = rowArgs,
    }
  end

  local autoMarkerArgs = {
    mouseoverDescription = {
      type = "description", order = 1, width = "full",
      name = L["Select how mouseover marking is activated."],
    },
    mouseover = {
      type = "select", name = L["Mouseover Marking"], order = 2, width = 1.5,
      values = { [1] = L["Always"], [2] = "Alt", [3] = "Ctrl", [4] = "Shift", [5] = L["Disabled"] },
      get = function() return GetAutoMarkerDB().mouseover or 4 end,
      set = function(_, value) GetAutoMarkerDB().mouseover = value; NotifyAutoMarkerChanged() end,
    },
    rowAfterMouseover = { type = "description", name = " ", order = 3, width = "full" },
    description = {
      type = "description", order = 4, width = "full",
      name = L["Configure automatic raid markers by raid and enemy. Higher priority enemies may reclaim markers from lower priority enemies."],
    },
    raid = {
      type = "select", name = L["Raid"], order = 5, width = 1.5,
      values = function()
        local values = {}
        for key, data in pairs(MerfinPlus.AutoMarkerCatalog or {}) do values[key] = data.name end
        return values
      end,
      get = function() return selectedAutoMarkerInstance end,
      set = function(_, value)
        selectedAutoMarkerInstance = value
        EnsureSelectedAutoMarkerSection()
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    subzone = {
      type = "select", name = L["Subzone"], order = 6, width = 1.5,
      values = function()
        local values = {}
        local catalog = AutoMarkerCatalogInstance()
        for _, section in ipairs(catalog and catalog.sections or {}) do values[section.key] = section.name end
        return values
      end,
      sorting = function()
        local sorting = {}
        local catalog = AutoMarkerCatalogInstance()
        for _, section in ipairs(catalog and catalog.sections or {}) do sorting[#sorting + 1] = section.key end
        return sorting
      end,
      get = EnsureSelectedAutoMarkerSection,
      set = function(_, value)
        selectedAutoMarkerSection[selectedAutoMarkerInstance] = value
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    sectionHeader = {
      type = "header", order = 7,
      name = function()
        local catalog = AutoMarkerCatalogInstance()
        local sectionKey = EnsureSelectedAutoMarkerSection()
        for _, section in ipairs(catalog and catalog.sections or {}) do
          if section.key == sectionKey then return section.name end
        end
        return L["Enemy"]
      end,
    },
  }

  for instanceKey, catalog in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
    local mobByNpcID = {}
    for _, mob in ipairs(catalog.mobs or {}) do mobByNpcID[mob.npc] = mob end

    for _, section in ipairs(catalog.sections or {}) do
      for mobIndex, npcID in ipairs(section.npcs or {}) do
        local rowInstanceKey = instanceKey
        local rowSectionKey = section.key
        local rowNpcID = npcID
        local mob = mobByNpcID[rowNpcID]
        local defaults = MerfinPlus.AutoMarkerDefaults
          and MerfinPlus.AutoMarkerDefaults.instances
          and MerfinPlus.AutoMarkerDefaults.instances[rowInstanceKey]
          and MerfinPlus.AutoMarkerDefaults.instances[rowInstanceKey][rowNpcID]
        local markerCount = math.max(1, defaults and defaults.marks and #defaults.marks or 0)
        local rowArgs = {
          enable = {
            type = "toggle", name = BossLabel(mob and mob.name or tostring(rowNpcID), autoMarkerBossIcons[rowNpcID]), order = 1, width = 1.1,
            get = function() return AutoMarkerSettingsFor(rowInstanceKey, rowNpcID).enable ~= false end,
            set = function(_, value)
              AutoMarkerSettingsFor(rowInstanceKey, rowNpcID).enable = value
              NotifyAutoMarkerChanged()
            end,
          },
          priority = {
            type = "input", name = "", order = 2, width = 0.3,
            get = function() return tostring(AutoMarkerSettingsFor(rowInstanceKey, rowNpcID).priority or 1) end,
            set = function(_, value)
              local priority = math.floor(tonumber(value) or 1)
              AutoMarkerSettingsFor(rowInstanceKey, rowNpcID).priority = math.max(1, math.min(20, priority))
              NotifyAutoMarkerChanged()
            end,
          },
        }

        for markerIndex = 1, markerCount do
          local rowMarkerIndex = markerIndex
          rowArgs["mark" .. rowMarkerIndex] = {
            type = "select", name = "", order = 2 + rowMarkerIndex, width = 0.4,
            values = autoMarkerMarkValues,
            get = function()
              local mark = tonumber(AutoMarkerSettingsFor(rowInstanceKey, rowNpcID).marks[rowMarkerIndex])
              return mark and mark >= 1 and mark <= 8 and mark or 0
            end,
            set = function(_, value)
              AutoMarkerSettingsFor(rowInstanceKey, rowNpcID).marks[rowMarkerIndex] = value ~= 0 and value or nil
              NotifyAutoMarkerChanged()
            end,
          }
        end

        autoMarkerArgs["enemy_" .. rowInstanceKey .. "_" .. rowNpcID] = {
          type = "group",
          name = "",
          inline = true,
          order = 10 + mobIndex,
          hidden = function()
            return selectedAutoMarkerInstance ~= rowInstanceKey
              or EnsureSelectedAutoMarkerSection() ~= rowSectionKey
          end,
          args = rowArgs,
        }
      end
    end
  end

  local transferState = {
    autoMarker = { text = "", status = "" },
    cooldowns = { text = "", status = "" },
  }

  local function CopyMarkerList(source)
    local marks = {}
    for index = 1, 8 do
      local mark = source and tonumber(source[index])
      if mark and mark >= 1 and mark <= 8 then marks[index] = mark end
    end
    return marks
  end

  local function BuildAutoMarkerExport()
    local db = GetAutoMarkerDB()
    local payload = { kind = "autoMarker", version = 1, mouseover = tonumber(db.mouseover) or 4, instances = {}, mechanics = {} }
    for instanceKey, catalog in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
      payload.instances[instanceKey] = {}
      for _, mob in ipairs(catalog.mobs or {}) do
        local settings = AutoMarkerSettingsFor(instanceKey, mob.npc)
        payload.instances[instanceKey][mob.npc] = {
          enable = settings.enable ~= false,
          priority = math.max(1, math.min(20, tonumber(settings.priority) or 1)),
          marks = CopyMarkerList(settings.marks),
        }
      end
    end
    for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
      local settings, defaults = FriendlyMarkerSettingsFor(mechanic.key)
      local marks = {}
      for index = 1, mechanic.maxMarks or 1 do
        local mark = tonumber(settings.marks[index])
        if mark == nil then mark = tonumber(defaults.marks and defaults.marks[index]) or 0 end
        marks[index] = mark
      end
      payload.mechanics[mechanic.key] = {
        enable = settings.enable == nil and defaults.enable ~= false or settings.enable,
        marks = marks,
      }
    end
    return "!MPAM:1!" .. AceSerializer:Serialize(payload)
  end

  local function ImportAutoMarker(text)
    text = type(text) == "string" and text:match("^%s*(.-)%s*$") or ""
    local prefix = "!MPAM:1!"
    if text:sub(1, #prefix) ~= prefix then return false, L["Invalid Auto-Marker export string."] end
    local ok, payload = AceSerializer:Deserialize(text:sub(#prefix + 1))
    if not ok or type(payload) ~= "table" or payload.kind ~= "autoMarker" or payload.version ~= 1 then
      return false, L["Invalid Auto-Marker export string."]
    end

    local imported = { mouseover = math.max(1, math.min(5, tonumber(payload.mouseover) or 4)), instances = {}, mechanics = {} }
    for instanceKey, catalog in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
      imported.instances[instanceKey] = {}
      local sourceInstance = type(payload.instances) == "table" and payload.instances[instanceKey] or nil
      local defaultInstance = MerfinPlus.AutoMarkerDefaults
        and MerfinPlus.AutoMarkerDefaults.instances
        and MerfinPlus.AutoMarkerDefaults.instances[instanceKey]
      for _, mob in ipairs(catalog.mobs or {}) do
        local source = type(sourceInstance) == "table" and sourceInstance[mob.npc] or nil
        local fallback = defaultInstance and defaultInstance[mob.npc] or {}
        if type(source) ~= "table" then source = fallback end
        imported.instances[instanceKey][mob.npc] = {
          enable = type(source.enable) == "boolean" and source.enable or fallback.enable ~= false,
          priority = math.max(1, math.min(20, tonumber(source.priority) or tonumber(fallback.priority) or 1)),
          marks = CopyMarkerList(type(source.marks) == "table" and source.marks or fallback.marks),
        }
      end
    end

    for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
      local source = type(payload.mechanics) == "table" and payload.mechanics[mechanic.key] or nil
      local fallback = MerfinPlus.AutoMarkerDefaults.mechanics[mechanic.key] or {}
      if type(source) ~= "table" then source = fallback end
      local marks = {}
      for index = 1, mechanic.maxMarks or 1 do
        local mark = tonumber(source.marks and source.marks[index])
        if mark == nil then mark = tonumber(fallback.marks and fallback.marks[index]) or 0 end
        marks[index] = mark >= 1 and mark <= 8 and mark or 0
      end
      imported.mechanics[mechanic.key] = {
        enable = type(source.enable) == "boolean" and source.enable or fallback.enable ~= false,
        marks = marks,
      }
    end

    MerfinPlus.db.profile.raidAutoMarker = imported
    NotifyAutoMarkerChanged()
    return true, L["Auto-Marker settings imported successfully."]
  end

  local cooldownGeneralDefaults = {
    enableTimeline = true, disableCD = false, emphasizedBar = true, emphasizedOn = 7,
    berserkOnlyShow = false, berserkShowOn = 60, enableRL = true,
  }

  local function CopyCooldownSettings(source, isTrash)
    source = type(source) == "table" and source or {}
    return {
      displayBar = source.displayBar == nil and not isTrash or source.displayBar == true,
      displayTimeline = source.displayTimeline == nil and not isTrash or source.displayTimeline == true,
      displayNameplate = source.displayNameplate ~= false,
      emphasizedBar = source.emphasizedBar == true,
      emphasizedOn = math.max(3, math.min(30, tonumber(source.emphasizedOn) or 7)),
      enabledCustom = source.enabledCustom == true,
      customName = type(source.customName) == "string" and source.customName:sub(1, 100) or "",
    }
  end

  local function BuildCooldownExport()
    local profile = MerfinPlus.db.profile
    local db = profile.raidCooldowns or {}
    local sourceGeneral = db.general or {}
    local payload = { kind = "cooldowns", version = 1, general = {}, raids = {} }
    for key, fallback in pairs(cooldownGeneralDefaults) do
      local value = sourceGeneral[key]
      payload.general[key] = value == nil and fallback or value
    end
    for raidKey, catalog in pairs(raidCooldownCatalog) do
      payload.raids[raidKey] = {}
      local sourceRaid = db.raids and db.raids[raidKey] or {}
      for _, cooldown in ipairs(catalog) do
        local encounter = cooldown.encounter
        payload.raids[raidKey][encounter] = payload.raids[raidKey][encounter] or {}
        local targetEncounter = payload.raids[raidKey][encounter]
        local sourceEncounter = sourceRaid[encounter] or {}
        targetEncounter.__disabled = sourceEncounter.__disabled == true
        targetEncounter.__disabledNpcs = targetEncounter.__disabledNpcs or {}
        if cooldown.npc and sourceEncounter.__disabledNpcs and sourceEncounter.__disabledNpcs[cooldown.npc] == true then
          targetEncounter.__disabledNpcs[cooldown.npc] = true
        end
        local source = sourceEncounter[cooldown.id]
        payload.raids[raidKey][encounter][cooldown.id] = CopyCooldownSettings(source, encounter:match("^Trash%-") ~= nil)
      end
    end
    return "!MPCD:1!" .. AceSerializer:Serialize(payload)
  end

  local function ImportCooldowns(text)
    text = type(text) == "string" and text:match("^%s*(.-)%s*$") or ""
    local prefix = "!MPCD:1!"
    if text:sub(1, #prefix) ~= prefix then return false, L["Invalid Cooldowns export string."] end
    local ok, payload = AceSerializer:Deserialize(text:sub(#prefix + 1))
    if not ok or type(payload) ~= "table" or payload.kind ~= "cooldowns" or payload.version ~= 1 then
      return false, L["Invalid Cooldowns export string."]
    end

    local imported = { general = {}, raids = {} }
    local sourceGeneral = type(payload.general) == "table" and payload.general or {}
    for key, fallback in pairs(cooldownGeneralDefaults) do
      local value = sourceGeneral[key]
      if type(fallback) == "boolean" then
        imported.general[key] = type(value) == "boolean" and value or fallback
      else
        imported.general[key] = tonumber(value) or fallback
      end
    end
    imported.general.emphasizedOn = math.max(3, math.min(30, imported.general.emphasizedOn))
    imported.general.berserkShowOn = math.max(5, math.min(300, imported.general.berserkShowOn))

    for raidKey, catalog in pairs(raidCooldownCatalog) do
      imported.raids[raidKey] = {}
      local sourceRaid = type(payload.raids) == "table" and payload.raids[raidKey] or nil
      for _, cooldown in ipairs(catalog) do
        local encounter = cooldown.encounter
        imported.raids[raidKey][encounter] = imported.raids[raidKey][encounter] or {}
        local targetEncounter = imported.raids[raidKey][encounter]
        local sourceEncounter = type(sourceRaid) == "table" and sourceRaid[encounter] or nil
        sourceEncounter = type(sourceEncounter) == "table" and sourceEncounter or {}
        targetEncounter.__disabled = sourceEncounter.__disabled == true
        targetEncounter.__disabledNpcs = targetEncounter.__disabledNpcs or {}
        if cooldown.npc and sourceEncounter.__disabledNpcs and sourceEncounter.__disabledNpcs[cooldown.npc] == true then
          targetEncounter.__disabledNpcs[cooldown.npc] = true
        end
        local source = sourceEncounter[cooldown.id]
          imported.raids[raidKey][encounter][cooldown.id] = CopyCooldownSettings(source, encounter:match("^Trash%-") ~= nil)
      end
    end

    MerfinPlus.db.profile.raidCooldowns = imported
    NotifyRaidCooldownChanged()
    return true, L["Cooldown settings imported successfully."]
  end

  local function BuildExportArgs(kind, exportFunction)
    return {
      description = { type = "description", name = L["Copy this string to share or back up these settings."], order = 1, width = "full" },
      exportString = {
        type = "input", name = L["Export String"], order = 2, width = "full", multiline = 12,
        dialogControl = GRAY_MULTILINE_TYPE,
        get = exportFunction,
        set = function() end,
      },
    }
  end

  local function BuildImportArgs(kind, importFunction)
    local state = transferState[kind]
    return {
      description = { type = "description", name = L["Paste an export string below. Importing replaces all settings in this section."], order = 1, width = "full" },
      importString = {
        type = "input", name = L["Import String"], order = 2, width = "full", multiline = 12,
        dialogControl = GRAY_MULTILINE_TYPE,
        get = function() return state.text end,
        set = function(_, value) state.text = value; state.status = "" end,
      },
      importButton = {
        type = "execute", name = L["Import"], order = 3, width = 1,
        disabled = function() return state.text == "" end,
        func = function()
          local ok, message = importFunction(state.text)
          state.status = (ok and "|cff33ff99" or "|cffff5555") .. message .. "|r"
          AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
        end,
      },
      status = { type = "description", name = function() return state.status end, order = 4, width = "full" },
    }
  end

  local function BuildTransferArgs(kind, exportFunction, importFunction)
    return {
      export = {
        type = "group", name = L["Export"], order = 1, inline = true,
        args = BuildExportArgs(kind, exportFunction),
      },
      import = {
        type = "group", name = L["Import"], order = 2, inline = true,
        args = BuildImportArgs(kind, importFunction),
      },
    }
  end

  local function HeaderIcon(texture, text)
    return "|T" .. texture .. ":16:16:0:0|t " .. text
  end

  local raidHeaderIcons = {
    core = "Interface\\Icons\\Trade_Engineering",
    tts = "Interface\\Icons\\Spell_Holy_Silence",
    localization = "Interface\\Icons\\INV_Misc_Book_09",
    media = "Interface\\Icons\\INV_Misc_ScrewDriver_01",
    autoMarker = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
    cooldowns = "Interface\\Icons\\INV_Misc_PocketWatch_01",
  }

  local raidMediaArgs = {
    description = {
      type = "description",
      name = L["Select the fonts and status bar texture used by raid WeakAuras. A UI reload is required."],
      order = 1,
      width = "full",
    },
    font3 = {
      type = "select", name = "Merfin Raid Font", order = 2, width = 1.75,
      values = GetFontList, dialogControl = "LSM30_Font",
      get = function() return self.db.profile.font3 end,
      set = function(_, value) self.db.profile.font3 = value; ConfirmReload() end,
    },
    font4 = {
      type = "select", name = "Merfin Raid Font (Bold)", order = 3, width = 1.75,
      values = GetFontList, dialogControl = "LSM30_Font",
      get = function() return self.db.profile.font4 end,
      set = function(_, value) self.db.profile.font4 = value; ConfirmReload() end,
    },
    rowAfterFonts = { type = "description", name = "", order = 3.5, width = "full" },
    bar3 = {
      type = "select", name = "Merfin Raid Status Bar", order = 4, width = 1.75,
      values = GetStatusBarList, dialogControl = "LSM30_Statusbar",
      get = function() return self.db.profile.bar3 end,
      set = function(_, value) self.db.profile.bar3 = value; ConfirmReload() end,
    },
  }

  -- ==== RaidPack Language, Voice, and Raid Settings ====
  local raidPack = {
    type = "group",
    name = "Raid WA Options",
    childGroups = "tab",
    args = {
      languageVoice = {
        type = "group",
        name = HeaderIcon(raidHeaderIcons.core, L["Core Settings"]),
        order = 1,
        childGroups = "tab",
        args = {
      localeSettings = {
        type = "group",
        name = L["Localization"],
        order = 2,
        get = function(info)
          return MerfinPlus.db.profile[info[#info]]
        end,
        set = function(info, value)
          MerfinPlus.db.profile[info[#info]] = value
        end,
        args = {
          description = {
            type = "description",
            name = L[
              "Here you can change the localization used by Merfin raid and dungeon packs when localization data is available. This is mainly used by Russian-speaking players. For additional localizations, please contact the Merfin staff."
            ],
            order = 1,
            width = "full",
            fontSize = "medium",
          },
          useSpecificLocalization = {
            type = "toggle",
            name = L["Use Specific Localization"],
            order = 2,
            width = 1.75,
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              ConfirmReload()
            end,
          },
          rowAfterSpecificLocalization = {
            type = "description", name = "", order = 2.5, width = "full",
          },
          rpTextLocale = {
            type = "select",
            name = L["Set Text Localization"],
            desc = L["Changes the language of text shown directly on auras, such as icons, bars, labels, and other on-aura elements."],
            order = 3,
            values = raidPackLocaleValues,
            width = 1.5,
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              ConfirmReload()
            end,
            disabled = function()
              return not MerfinPlus.db.profile.useSpecificLocalization
            end,
          },
          rowAfterTextLocale = { type = "description", name = "", order = 3.5, width = "full" },
          rpSoundLocale = {
            type = "select",
            name = L["Set Sound Localization"],
            desc = L["Changes the language used for voice lines and sound callouts."],
            order = 4,
            values = raidPackLocaleValues,
            width = 1.5,
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              ConfirmReload()
            end,
            disabled = function()
              return not MerfinPlus.db.profile.useSpecificLocalization
            end,
          },
          rowAfterSoundLocale = {
            type = "description", name = "", order = 4.5, width = "full",
          },
          rpChatLocale = {
            type = "select",
            name = L["Set Chat Localization"],
            desc = L["Changes the language used when sending Merfin raid and dungeon pack messages to chat."],
            order = 5,
            values = raidPackLocaleValues,
            width = 1.5,
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              ConfirmReload()
            end,
            disabled = function()
              return not MerfinPlus.db.profile.useSpecificLocalization
            end,
          },
        },
      },
      textToSpeech = {
        type = "group",
        name = L["Text to Speech"],
        order = 1,
        get = function(info)
          return MerfinPlus.db.profile[info[#info]]
        end,
        set = function(info, value)
          MerfinPlus.db.profile[info[#info]] = value
        end,
        args = {
          ttsEnabled = {
            type = "toggle",
            name = L["Enable"],
            order = 1,
            width = 1,
          },
          ttsApplyAll = {
            type = "toggle",
            name = L["Apply on All"],
            order = 2,
            width = 1,
          },
          ttsVolume = {
            type = "range",
            name = L["Volume"],
            order = 3,
            min = 0,
            max = 100,
            step = 1,
            width = 1.5,
          },
          rowAfterVolume = { type = "description", name = "", order = 3.5, width = "full" },
          ttsUseSpecificVoiceID = {
            type = "toggle",
            name = L["Use Specific Voice ID"],
            order = 4,
            width = 1.5,
          },
          ttsVoiceID = {
            type = "input",
            name = L["Voice ID"],
            order = 5,
            width = 1.5,
            get = function()
              return tostring(MerfinPlus.db.profile.ttsVoiceID or 1)
            end,
            set = function(_, value)
              MerfinPlus.db.profile.ttsVoiceID = tonumber(value) or 1
            end,
          },
          ttsVoiceRate = {
            type = "range",
            name = L["Voice Rate"],
            order = 6,
            min = 0.1,
            max = 5,
            step = 0.1,
            width = 1.5,
          },
          rowAfterVoice = { type = "description", name = "", order = 6.5, width = "full" },
          voiceIdHelp = {
            type = "description",
            name = L['You can check for available voice IDs by checking "Play Test Sound?" option'],
            order = 7,
            width = "full",
            fontSize = "medium",
          },
          ttsTestText = {
            type = "input",
            name = L["Test Text"],
            order = 8,
            width = 1.5,
          },
          playTestSound = {
            type = "execute",
            name = L["Play Test Sound?"],
            order = 9,
            width = 1,
            func = function()
              if Merfin and Merfin.PlaySound then
                Merfin.PlaySound(MerfinPlus.db.profile.ttsTestText or "Merfin Test Sound")
              end
            end,
          },
        },
      },
      raidMedia = {
        type = "group",
        name = L["Media"],
        order = 3,
        args = raidMediaArgs,
      },
        },
      },
      autoMarker = {
        type = "group",
        name = HeaderIcon(raidHeaderIcons.autoMarker, L["Auto-Marker"]),
        order = 2,
        childGroups = "tab",
        args = {
          enemy = {
            type = "group",
            name = L["Enemy"],
            order = 1,
            args = autoMarkerArgs,
          },
          friendly = {
            type = "group",
            name = "Friendly",
            order = 2,
            args = friendlyMarkerArgs,
          },
          transfer = {
            type = "group",
            name = L["Export / Import"],
            order = 3,
            args = BuildTransferArgs("autoMarker", BuildAutoMarkerExport, ImportAutoMarker),
          },
        },
      },
      cooldowns = {
        type = "group",
        name = HeaderIcon(raidHeaderIcons.cooldowns, L["Cooldowns"]),
        order = 3,
        childGroups = "tab",
        args = {
          general = {
            type = "group", name = L["General"], order = 1,
            get = function(info) return MerfinPlus.db.profile.raidCooldowns.general[info[#info]] end,
            set = function(info, value) MerfinPlus.db.profile.raidCooldowns.general[info[#info]] = value; NotifyRaidCooldownChanged() end,
            args = {
              enableTimeline = { type = "toggle", name = L["Enable Timeline"], order = 1, width = 1.5 },
              disableCD = { type = "toggle", name = L["Disable All Bars"], order = 2, width = 1.5 },
              rowAfterAvailability = { type = "description", name = "", order = 2.5, width = "full" },
              emphasizedBar = { type = "toggle", name = L["Emphasize Cooldowns"], order = 3, width = 1.5 },
              emphasizedOn = { type = "range", name = L["Emphasize when (sec) left"], order = 4, min = 3, max = 30, step = 0.5, width = 1.5 },
              rowAfterEmphasis = { type = "description", name = "", order = 4.5, width = "full" },
              berserkOnlyShow = { type = "toggle", name = L["Show Berserk only near expiration"], order = 5, width = 2 },
              berserkShowOn = { type = "range", name = L["Show Berserk when (sec) left"], order = 6, min = 5, max = 300, step = 5, width = 1.5 },
              rowAfterBerserk = { type = "description", name = "", order = 6.5, width = "full" },
              enableRL = { type = "toggle", name = L["Enable all cooldowns for Raid Leader / Assistant"], order = 7, width = 2.5 },
            },
          },
          raids = {
            type = "group", name = L["Raids"], order = 2, childGroups = "select",
            args = {
              serpentshrineCavern = {
                type = "group", name = L["Serpentshrine Cavern"], order = 1, childGroups = "tree",
                args = BuildRaidBosses("serpentshrineCavern", "Trash-SSC"),
              },
              tempestKeep = {
                type = "group", name = L["Tempest Keep"], order = 2, childGroups = "tree",
                args = BuildRaidBosses("tempestKeep", "Trash-TK"),
              },
              blackTemple = {
                type = "group", name = L["Black Temple"], order = 3, childGroups = "tree",
                args = BuildRaidBosses("blackTemple", "Trash-BT"),
              },
              hyjalSummit = {
                type = "group", name = L["Hyjal Summit"], order = 4,
                args = {
                  empty = { type = "description", name = L["Cooldown settings for this raid will be added later."], order = 1, fontSize = "medium" },
                },
              },
            },
          },
          transfer = {
            type = "group", name = L["Export / Import"], order = 3,
            args = BuildTransferArgs("cooldowns", BuildCooldownExport, ImportCooldowns),
          },
        },
      },
    },
  }

  local currentLocale = GAME_LOCALE or GetLocale()
  local GetRaidPackProfileLocale = function(key)
    local db = MerfinPlus.db.profile
    if not IsRaidPackSpecificLocalizationEnabled(db) then
      return currentLocale
    end

    return db[key] or db.raidLocale or currentLocale
  end

  Merfin.IsRPSpecificLocalization = function()
    local db = MerfinPlus.db.profile
    return IsRaidPackSpecificLocalizationEnabled(db)
  end

  Merfin.GetRPTextLocale = function()
    return GetRaidPackProfileLocale("rpTextLocale")
  end

  Merfin.GetRPSoundLocale = function()
    return GetRaidPackProfileLocale("rpSoundLocale")
  end

  Merfin.GetRPChatLocale = function()
    return GetRaidPackProfileLocale("rpChatLocale")
  end

  -- ==== WoW Sim Importer ====
  local WOWSIM_INDEX_TO_SLOT = {
    [1] = 1, -- Head
    [2] = 2, -- Neck
    [3] = 3, -- Shoulder
    [4] = 15, -- Back
    [5] = 5, -- Chest
    [6] = 9, -- Wrist
    [7] = 10, -- Hands
    [8] = 6, -- Waist
    [9] = 7, -- Legs
    [10] = 8, -- Feet
    [11] = 11, -- Ring 1
    [12] = 12, -- Ring 2
    [13] = 13, -- Trinket 1
    [14] = 14, -- Trinket 2
    [15] = 16, -- Mainhand
    [16] = 17, -- Offhand
    [17] = (IsWrath() or IsTBC() and 18) or nil, -- Relic/Ranged
  }

  local SLOT_NAMES = {
    [1] = _G.INVTYPE_HEAD,
    [2] = _G.INVTYPE_NECK,
    [3] = _G.INVTYPE_SHOULDER,
    [5] = _G.INVTYPE_CHEST,
    [6] = _G.INVTYPE_WAIST,
    [7] = _G.INVTYPE_LEGS,
    [8] = _G.INVTYPE_FEET,
    [9] = _G.INVTYPE_WRIST,
    [10] = _G.INVTYPE_HAND,
    [11] = _G.INVTYPE_FINGER,
    [12] = _G.INVTYPE_FINGER,
    [13] = _G.INVTYPE_TRINKET,
    [14] = _G.INVTYPE_TRINKET,
    [15] = _G.INVTYPE_CLOAK,
    [16] = _G.INVTYPE_WEAPONMAINHAND,
    [17] = _G.INVTYPE_WEAPONOFFHAND,
    [18] = (IsWrath() or IsTBC()) and _G.INVTYPE_RELIC or nil,
  }

  -- -------------------------
  -- Helpers
  -- -------------------------
  local function NormalizeSimClass(simClass)
    if type(simClass) ~= "string" then
      return nil
    end
    --return "PALADIN"
    return strupper(simClass:gsub("^Class", "")) -- "ClassDruid" -> "DRUID"
  end

  local function ExtractSlotItemsFromSim(simData)
    local items = {}
    local suffixes = {}
    local equip = simData and simData.player and simData.player.equipment
    local list = equip and equip.items
    if type(list) ~= "table" then
      return items, suffixes
    end

    for idx, entry in ipairs(list) do
      local slotID = WOWSIM_INDEX_TO_SLOT[idx]
      local itemID = entry and entry.id

      if slotID and type(itemID) == "number" and itemID > 0 then
        items[slotID] = itemID

        if entry.randomSuffix then
          suffixes[slotID] = entry.randomSuffix
        end

        C_Item.RequestLoadItemDataByID(itemID)
      end
    end
    return items, suffixes
  end

  -- SAFE: user can type anything, GetItemInfo might be nil (cache), request load and return nil safely
  local function SafeItemInfo(itemID)
    if type(itemID) ~= "number" or itemID <= 0 then
      return nil
    end
    local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
    if not name then
      C_Item.RequestLoadItemDataByID(itemID)
      return nil
    end
    return name, icon
  end

  local function FindNextFreeProfileIndex(db, spec, class)
    local used = {}
    for k in pairs(db.global.wowSims.profiles) do
      local n = k:match("^" .. spec .. class .. "(%d+)$")
      if n then
        used[tonumber(n)] = true
      end
    end

    local i = 1
    while used[i] do
      i = i + 1
    end
    return i
  end

  local function MakeProfileKey(spec, class)
    local n = FindNextFreeProfileIndex(MerfinPlus.db, spec, class)
    return spec .. class .. n -- FeralDRUID1
  end

  local function PlayerClassMatches(profile)
    local _, playerClass = UnitClass("player") -- playerClass is uppercase token like "DRUID"
    return profile and profile.class == playerClass
  end

  -- -------------------------
  -- Spec lists
  -- -------------------------
  local cataSpecsByClassID = CATA_WOWSIM_SPEC_BY_CLASS_ID

  local mopSpecsByClassID = {
    [1] = { 71, 72, 73 },
    [2] = { 65, 66, 70 },
    [3] = { 253, 254, 255 },
    [4] = { 259, 260, 261 },
    [5] = { 256, 257, 258 },
    [6] = { 250, 251, 252 },
    [7] = { 262, 263, 264 },
    [8] = { 62, 63, 64 },
    [9] = { 265, 266, 267 },
    [10] = { 268, 270, 269 },
    [11] = { 102, 103, 104, 105 },
  }

  local classFileByID = {
    [1] = "WARRIOR",
    [2] = "PALADIN",
    [3] = "HUNTER",
    [4] = "ROGUE",
    [5] = "PRIEST",
    [6] = "DEATHKNIGHT",
    [7] = "SHAMAN",
    [8] = "MAGE",
    [9] = "WARLOCK",
    [10] = IsMoP() and "MONK" or nil,
    [11] = "DRUID",
  }

  local function GetClassPrefixFromFile(classFile)
    if classFile == "DEATHKNIGHT" then
      return "DeathKnight"
    end
    if classFile == "DEMONHUNTER" then
      return "DemonHunter"
    end
    if type(classFile) ~= "string" or classFile == "" then
      return "Class"
    end
    local lower = classFile:lower()
    return lower:sub(1, 1):upper() .. lower:sub(2)
  end

  local function BuildClassSpecIDsFromClient(specsByClassID, useMappedSpecIDs)
    local CLASS_SPEC_IDS = {}

    for classID, list in pairs(specsByClassID) do
      local classFile = classFileByID[classID]
      if classFile then
        local wanted = {}
        for i = 1, #list do
          wanted[list[i]] = true
        end

        local out = {}
        local prefix = GetClassPrefixFromFile(classFile)

        for specIndex = 1, #list do
          local clientSpecID, specName, _, icon = GetSpecializationInfoForClassID(classID, specIndex)
          if not clientSpecID then
            break
          end

          if useMappedSpecIDs or wanted[clientSpecID] then
            local specID = useMappedSpecIDs and list[specIndex] or clientSpecID
            local cleanName = (specName and specName:gsub("%s+", "")) or tostring(specID)
            local specKey = prefix .. cleanName
            out[#out + 1] = { specID = specID, specKey = specKey, icon = icon }
          end
        end

        CLASS_SPEC_IDS[classFile] = out
      end
    end

    return CLASS_SPEC_IDS
  end

  local CLASS_SPEC_IDS = IsWrath()
      and {

        DRUID = {
          { specID = 283, specKey = "DruidBalance", icon = 136096 }, -- Balance
          { specID = 281, specKey = "DruidFeralCombat", icon = 132276 }, -- Feral
          { specID = 282, specKey = "DruidRestoration", icon = 136041 }, -- Restoration
        },

        WARRIOR = {
          { specID = 161, specKey = "WarriorArms", icon = 132292 },
          { specID = 164, specKey = "WarriorFury", icon = 132347 },
          { specID = 163, specKey = "WarriorProtection", icon = 134952 },
        },

        PALADIN = {
          { specID = 381, specKey = "PaladinRetribution", icon = 135873 },
          { specID = 382, specKey = "PaladinHoly", icon = 135920 },
          { specID = 383, specKey = "PaladinProtection", icon = 135893 },
        },

        HUNTER = {
          { specID = 361, specKey = "HunterBeastMastery", icon = 132164 },
          { specID = 363, specKey = "HunterMarksmanship", icon = 132222 },
          { specID = 362, specKey = "HunterSurvival", icon = 132215 },
        },

        ROGUE = {
          { specID = 182, specKey = "RogueAssassination", icon = 132292 },
          { specID = 181, specKey = "RogueCombat", icon = 132090 },
          { specID = 183, specKey = "RogueSubtlety", icon = 132320 },
        },

        PRIEST = {
          { specID = 201, specKey = "PriestDiscipline", icon = 135987 },
          { specID = 202, specKey = "PriestHoly", icon = 237542 },
          { specID = 203, specKey = "PriestShadow", icon = 136207 },
        },

        SHAMAN = {
          { specID = 261, specKey = "ShamanElemental", icon = 136048 },
          { specID = 263, specKey = "ShamanEnhancement", icon = 136051 },
          { specID = 262, specKey = "ShamanRestoration", icon = 136052 },
        },

        MAGE = {
          { specID = 81, specKey = "MageArcane", icon = 135932 },
          { specID = 41, specKey = "MageFire", icon = 135810 },
          { specID = 61, specKey = "MageFrost", icon = 135846 },
        },

        WARLOCK = {
          { specID = 302, specKey = "WarlockAffliction", icon = 136145 },
          { specID = 303, specKey = "WarlockDemonology", icon = 136172 },
          { specID = 301, specKey = "WarlockDestruction", icon = 136186 },
        },

        DEATHKNIGHT = {
          { specID = 250, specKey = "DeathKnightBlood", icon = 135770 },
          { specID = 251, specKey = "DeathKnightFrost", icon = 135773 },
          { specID = 252, specKey = "DeathKnightUnholy", icon = 135775 },
        },
      }
    or IsTBC()
      and {
        DRUID = {
          { specID = 283, specKey = "DruidBalance", icon = 136096 }, -- Balance
          { specID = 281, specKey = "DruidFeralCombat", icon = 132276 }, -- Feral
          { specID = 282, specKey = "DruidRestoration", icon = 136041 }, -- Restoration
        },

        WARRIOR = {
          { specID = 161, specKey = "WarriorArms", icon = 132292 },
          { specID = 164, specKey = "WarriorFury", icon = 132347 },
          { specID = 163, specKey = "WarriorProtection", icon = 134952 },
        },

        PALADIN = {
          { specID = 381, specKey = "PaladinRetribution", icon = 135873 },
          { specID = 382, specKey = "PaladinHoly", icon = 135920 },
          { specID = 383, specKey = "PaladinProtection", icon = 135893 },
        },

        HUNTER = {
          { specID = 361, specKey = "HunterBeastMastery", icon = 132164 },
          { specID = 363, specKey = "HunterMarksmanship", icon = 132222 },
          { specID = 362, specKey = "HunterSurvival", icon = 132215 },
        },

        ROGUE = {
          { specID = 182, specKey = "RogueAssassination", icon = 132292 },
          { specID = 181, specKey = "RogueCombat", icon = 132090 },
          { specID = 183, specKey = "RogueSubtlety", icon = 132320 },
        },

        PRIEST = {
          { specID = 201, specKey = "PriestDiscipline", icon = 135987 },
          { specID = 202, specKey = "PriestHoly", icon = 237542 },
          { specID = 203, specKey = "PriestShadow", icon = 136207 },
        },

        SHAMAN = {
          { specID = 261, specKey = "ShamanElemental", icon = 136048 },
          { specID = 263, specKey = "ShamanEnhancement", icon = 136051 },
          { specID = 262, specKey = "ShamanRestoration", icon = 136052 },
        },

        MAGE = {
          { specID = 81, specKey = "MageArcane", icon = 135932 },
          { specID = 41, specKey = "MageFire", icon = 135810 },
          { specID = 61, specKey = "MageFrost", icon = 135846 },
        },

        WARLOCK = {
          { specID = 302, specKey = "WarlockAffliction", icon = 136145 },
          { specID = 303, specKey = "WarlockDemonology", icon = 136172 },
          { specID = 301, specKey = "WarlockDestruction", icon = 136186 },
        },
      }
    or IsCata() and (function()
      return BuildClassSpecIDsFromClient(cataSpecsByClassID, true)
    end)()
    or IsMoP() and (function()
      return BuildClassSpecIDsFromClient(mopSpecsByClassID)
    end)()
    or {}

  -- -------------------------
  -- Manager: dropdown + rename + items + assign
  -- -------------------------

  local selectedProfileKey = nil

  local function GetAllProfilesSorted(db)
    local out = {}
    local t = db.global.wowSims.profiles or {}
    for k, v in pairs(t) do
      if type(v) == "table" then
        v.key = v.key or k
        table.insert(out, v)
      end
    end
    table.sort(out, function(a, b)
      local an = a.displayName or a.key or ""
      local bn = b.displayName or b.key or ""
      return an < bn
    end)
    return out
  end

  local function BuildProfileDropdownValues(db)
    local vals = {}
    for _, p in ipairs(GetAllProfilesSorted(db)) do
      vals[p.key] = p.displayName or p.key
    end
    return vals
  end

  local wowSimImportBuffer = ""
  local wowSimParsedData = nil
  local wowSimImportStatus = nil

  local selectedSpec = nil
  local previewProfileKey = nil

  local importMode = "json" -- "json" | "empty"
  local selectedClass = nil

  local function NotifySimChanged()
    if WeakAuras and WeakAuras.ScanEvents then
      WeakAuras.ScanEvents("MERFIN_WOWSIM_CHANGED")
    end
  end

  local STAT_BY_ID = {
    [336] = _G.ITEM_MOD_CRIT_RATING_SHORT,
    [337] = _G.ITEM_MOD_HIT_RATING_SHORT,
    [338] = _G.ITEM_MOD_EXPERTISE_RATING_SHORT,
    [339] = _G.ITEM_MOD_MASTERY_RATING_SHORT,
    [340] = _G.ITEM_MOD_HASTE_RATING_SHORT,
    [341] = _G.ITEM_MOD_PARRY_RATING_SHORT,
    [342] = _G.ITEM_MOD_DODGE_RATING_SHORT,
    [343] = _G.ITEM_MOD_SPIRIT_SHORT,
  }

  local CATA_SUFFIX_NAME_BY_ID = {
    [-295] = "of the Zephyr",
    [-294] = "of the Windstorm",
    [-293] = "of the Windflurry",
    [-292] = "of the Stormblast",
    [-291] = "of the Zephyr",
    [-290] = "of the Windstorm",
    [-289] = "of the Windflurry",
    [-288] = "of the Stormblast",
    [-287] = "of the Wavecrest",
    [-286] = "of the Undertow",
    [-285] = "of the Feverflare",
    [-284] = "of the Fireflash",
    [-283] = "of the Wavecrest",
    [-282] = "of the Undertow",
    [-281] = "of the Feverflare",
    [-280] = "of the Fireflash",
    [-277] = "of the Rockslab",
    [-276] = "of the Bouldercrag",
    [-275] = "of the Bedrock",
    [-274] = "of the Rockslab",
    [-273] = "of the Bouldercrag",
    [-272] = "of the Bedrock",
    [-271] = "of the Fireflash",
    [-270] = "of the Wavecrest",
    [-269] = "of the Undertow",
    [-268] = "of the Feverflare",
    [-267] = "of the Fireflash",
    [-266] = "of the Flameblaze",
    [-265] = "of the Wildfire",
    [-262] = "of the Feverflare",
    [-261] = "of the Flameblaze",
    [-236] = "of the Zephyr",
    [-235] = "of the Windstorm",
    [-234] = "of the Windflurry",
    [-233] = "of the Stormblast",
    [-232] = "of the Wavecrest",
    [-231] = "of the Undertow",
    [-230] = "of the Feverflare",
    [-229] = "of the Fireflash",
    [-226] = "of the Rockslab",
    [-225] = "of the Bouldercrag",
    [-224] = "of the Bedrock",
    [-219] = "of the Zephyr",
    [-218] = "of the Windstorm",
    [-217] = "of the Windflurry",
    [-216] = "of the Stormblast",
    [-215] = "of the Wavecrest",
    [-214] = "of the Undertow",
    [-213] = "of the Feverflare",
    [-212] = "of the Fireflash",
    [-209] = "of the Rockslab",
    [-208] = "of the Bouldercrag",
    [-207] = "of the Bedrock",
    [-202] = "of the Zephyr",
    [-201] = "of the Windstorm",
    [-200] = "of the Windflurry",
    [-199] = "of the Stormblast",
    [-198] = "of the Zephyr",
    [-197] = "of the Windstorm",
    [-196] = "of the Windflurry",
    [-195] = "of the Stormblast",
    [-194] = "of the Wavecrest",
    [-193] = "of the Undertow",
    [-192] = "of the Feverflare",
    [-191] = "of the Fireflash",
    [-190] = "of the Flameblaze",
    [-189] = "of the Wildfire",
    [-188] = "of the Wavecrest",
    [-187] = "of the Undertow",
    [-186] = "of the Feverflare",
    [-185] = "of the Fireflash",
    [-184] = "of the Flameblaze",
    [-183] = "of the Wildfire",
    [-182] = "of the Rockslab",
    [-181] = "of the Bouldercrag",
    [-180] = "of the Bedrock",
    [-179] = "of the Rockslab",
    [-178] = "of the Bouldercrag",
    [-177] = "of the Bedrock",
    [-176] = "of the Faultline",
    [-175] = "of the Earthfall",
    [-174] = "of the Landslide",
    [-173] = "of the Earthshaker",
    [-172] = "of the Faultline",
    [-171] = "of the Earthfall",
    [-170] = "of the Earthshaker",
    [-169] = "of the Landslide",
    [-138] = "of the Feverflare",
    [-137] = "of the Windstorm",
    [-136] = "of the Zephyr",
    [-135] = "of the Windflurry",
    [-133] = "of the Stormblast",
    [-132] = "of the Wavecrest",
    [-131] = "of the Undertow",
    [-130] = "of the Fireflash",
    [-129] = "of the Wildfire",
    [-128] = "of the Rockslab",
    [-127] = "of the Bouldercrag",
    [-125] = "of the Bedrock",
    [-122] = "of the Earthfall",
    [-121] = "of the Landslide",
    [-120] = "of the Earthshaker",
    [-118] = "of the Faultline",
    [-114] = "of the Flameblaze",
  }

  function Merfin:GetSuffixName(suffixID)
    if not suffixID then
      return nil
    end
    return CATA_SUFFIX_NAME_BY_ID[suffixID] or STAT_BY_ID[math.abs(suffixID)]
  end

  local function BuildWowSimManagerArgsV2()
    local args = {}
    local db = MerfinPlus.db

    -- auto select active profile into dropdown
    if not selectedProfileKey then
      local active = Merfin.GetActiveSimProfile()
      if active and active.key then
        selectedProfileKey = active.key
      end
    end

    args.header = { type = "header", name = L["Import WoWSim JSON"], order = 0 }

    args.profileSelect = {
      type = "select",
      name = L["Profiles"],
      order = 1,
      width = "full",
      values = function()
        return BuildProfileDropdownValues(MerfinPlus.db)
      end,
      get = function()
        return selectedProfileKey
      end,
      set = function(_, v)
        selectedProfileKey = v
        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    args.assignedInfo = {
      type = "description",
      order = 2,
      name = function()
        local charKey = GetCharKey()
        local assigned = db.global.wowSims.assigned[charKey]
        if not assigned then
          return "|cffff8800" .. L["This character has no assigned profiles."] .. "|r"
        end

        local lines = {}
        for specID, key in pairs(assigned) do
          local p = db.global.wowSims.profiles[key]
          local label = p and p.specKey or tostring(specID)
          local profileName = p and (p.displayName or p.key) or key
          table.insert(lines, label .. ": " .. profileName)
        end

        table.sort(lines)
        return "|cff00ff00" .. L["Assigned profiles:"] .. "|r\n" .. table.concat(lines, "\n")
      end,
    }

    args.assign = {
      type = "execute",
      name = function()
        if not selectedProfileKey then
          return L["Assign to Current Character"]
        end

        local charKey = GetCharKey()
        local assigned = MerfinPlus.db.global.wowSims.assigned[charKey]
        local p = MerfinPlus.db.global.wowSims.profiles[selectedProfileKey]

        if assigned and p and assigned[p.specID] == selectedProfileKey then
          return L["Assigned "] .. "(" .. (p.specKey or p.specID) .. ")"
        end

        return L["Assign to Current Character"]
      end,
      order = 3,
      disabled = function()
        if not selectedProfileKey then
          return true
        end
        local p = db.global.wowSims.profiles[selectedProfileKey]
        if not p then
          return true
        end
        if not PlayerClassMatches(p) then
          return true
        end
        return false
      end,
      func = function()
        local charKey = GetCharKey()
        local p = db.global.wowSims.profiles[selectedProfileKey]
        db.global.wowSims.assigned[charKey] = db.global.wowSims.assigned[charKey] or {}

        db.global.wowSims.assigned[charKey][p.specID] = selectedProfileKey

        NotifySimChanged()

        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    args.rename = {
      type = "input",
      name = L["Rename (display only)"],
      order = 4,
      width = "full",
      disabled = function()
        return not selectedProfileKey
      end,
      get = function()
        local p = db.global.wowSims.profiles[selectedProfileKey]
        return p and (p.displayName or p.key) or ""
      end,
      set = function(_, v)
        local p = db.global.wowSims.profiles[selectedProfileKey]
        if p and v and v ~= "" then
          p.displayName = v
        end

        NotifySimChanged()

        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    args.itemsGroup = {
      type = "group",
      name = "Items",
      order = 10,
      inline = true,
      args = {},
      disabled = function()
        return not selectedProfileKey
      end,
    }

    local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]

    local slotIDs = {}
    for slotID in pairs(SLOT_NAMES) do
      table.insert(slotIDs, slotID)
    end
    table.sort(slotIDs)

    local o = 1
    for _, slotID in ipairs(slotIDs) do
      args.itemsGroup.args["slot_" .. slotID] = {
        type = "input",
        width = "full",
        order = o,
        name = function()
          local label = SLOT_NAMES[slotID]
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          local id = p and p.items and p.items[slotID]

          if not id then
            return label .. " - (" .. L["Empty"] .. ")"
          end

          local name, icon = SafeItemInfo(id)
          if name and icon then
            return ("|T%d:18|t %s - %s (ID: %d)"):format(icon, label, name, id)
          end

          return label .. " - (ID: " .. id .. " - " .. L["loading"] .. "...)"
        end,
        desc = L["Set itemID for "] .. (SLOT_NAMES[slotID] or (L["slot "] .. slotID)),
        get = function()
          local pp = db.global.wowSims.profiles[selectedProfileKey]
          local id = pp and pp.items and pp.items[slotID]
          return id and tostring(id) or ""
        end,
        set = function(_, v)
          local pp = db.global.wowSims.profiles[selectedProfileKey]
          if not pp then
            return
          end
          pp.items = pp.items or {}

          local n = tonumber(v)
          if n and n > 0 then
            pp.items[slotID] = n
            C_Item.RequestLoadItemDataByID(n)
          else
            pp.items[slotID] = nil
          end

          if n and n > 0 then
            pp.items[slotID] = n
            pp.itemSuffixes = pp.itemSuffixes or {}
            pp.itemSuffixes[slotID] = nil
          else
            pp.items[slotID] = nil
            if pp.itemSuffixes then
              pp.itemSuffixes[slotID] = nil
            end
          end

          NotifySimChanged()

          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
          AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
        end,
      }
      args.itemsGroup.args["slot_" .. slotID .. "_suffix"] = {
        type = "select",
        name = L["Suffix"],
        order = o + 0.1,
        width = "full",

        hidden = (IsMoP() or IsCata()) and function()
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          return not p or not p.itemSuffixes or p.itemSuffixes[slotID] == nil
        end or true,

        values = function()
          local vals = {}
          if IsCata() then
            for id, name in pairs(CATA_SUFFIX_NAME_BY_ID) do
              vals[id] = name
            end
          else
            for id, name in pairs(STAT_BY_ID) do
              vals[-id] = name
            end
          end
          return vals
        end,

        get = function()
          local p = db.global.wowSims.profiles[selectedProfileKey]
          return p.itemSuffixes[slotID]
        end,

        set = function(_, v)
          local p = db.global.wowSims.profiles[selectedProfileKey]
          p.itemSuffixes[slotID] = v
          NotifySimChanged()
        end,
      }
      args.itemsGroup.args["slot_" .. slotID .. "_addsuffix"] = {
        type = "execute",
        name = "+ Suffix",
        order = o + 0.05,
        width = 0.8,
        hidden = (IsMoP() or IsCata()) and function()
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          return not p or not p.items or not p.items[slotID] or (p.itemSuffixes and p.itemSuffixes[slotID])
        end or true,
        func = function()
          local p = db.global.wowSims.profiles[selectedProfileKey]
          p.itemSuffixes = p.itemSuffixes or {}

          p.itemSuffixes[slotID] = IsCata() and -129 or -336

          NotifySimChanged()
          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        end,
      }
      args.itemsGroup.args["slot_" .. slotID .. "_suffix_remove"] = {
        type = "execute",
        name = "|cffff4040X|r",
        desc = "|cffff4040" .. L["Delete this item entry."] .. "|r",
        order = o + 0.15,
        width = 0.3,
        hidden = (IsMoP() or IsCata()) and function()
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          return not p or not p.itemSuffixes or p.itemSuffixes[slotID] == nil
        end or true,
        func = function()
          local p = db.global.wowSims.profiles[selectedProfileKey]
          p.itemSuffixes[slotID] = nil
          NotifySimChanged()
          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        end,
      }
      o = o + 1
    end

    args.delete = {
      type = "execute",
      name = L["Delete Profile"],
      order = 999,
      confirm = true,
      confirmText = L["Delete this profile?"],
      disabled = function()
        return not selectedProfileKey
      end,
      func = function()
        db.global.wowSims.profiles[selectedProfileKey] = nil

        -- cleanup assignments
        for ck, specs in pairs(db.global.wowSims.assigned) do
          if type(specs) == "table" then
            for spec, key in pairs(specs) do
              if key == selectedProfileKey then
                specs[spec] = nil
              end
            end
            if next(specs) == nil then
              db.global.wowSims.assigned[ck] = nil
            end
          end
        end

        selectedProfileKey = nil

        NotifySimChanged()

        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    return args
  end

  local CLASS_ICONS = {
    WARRIOR = 626008,
    PALADIN = 626003,
    HUNTER = 626000,
    ROGUE = 626005,
    PRIEST = 626004,
    DEATHKNIGHT = 135771,
    SHAMAN = 626006,
    MAGE = 626001,
    WARLOCK = 626007,
    MONK = 626002,
    DRUID = 625999,
  }

  local function BuildSpecSelectArgs()
    local args = {}

    local class = importMode == "json"
        and wowSimParsedData
        and wowSimParsedData.player
        and NormalizeSimClass(wowSimParsedData.player.class)
      or selectedClass

    local specs = class and CLASS_SPEC_IDS[class]
    if not specs then
      return args
    end

    for _, s in ipairs(specs) do
      args["spec_" .. s.specKey] = {
        type = "execute",
        name = "",
        image = s.icon,
        imageWidth = 32,
        imageHeight = 32,
        func = function()
          selectedSpec = s
          previewProfileKey = MakeProfileKey(s.specKey, class)
          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        end,
      }
    end
    return args
  end
  -- -------------------------
  -- Import state + UI
  -- -------------------------
  -- WoW Sim
  wowSimOptions = {
    type = "group",
    name = "WoW Sim",
    childGroups = "tab",
    hidden = function()
      return not IsWrath() and not IsTBC() and not IsCata() and not IsMoP()
    end,
    args = {

      -- =====================
      -- TAB 1: IMPORT
      -- =====================
      Import = {
        type = "group",
        name = L["Import"],
        order = 1,
        args = {

          header = {
            type = "header",
            name = L["Import WoWSim JSON"],
            order = 1,
          },

          description = {
            type = "description",
            order = 2,
            width = 1.5,
            name = function()
              if importMode == "empty" then
                return L["Create an empty WoWSim profile.\nSelect a class, choose a specialization, then click Import."]
              end
              return L["Paste a WoWSim JSON export below.\nClick Accept, select a specialization icon, then click Import."]
            end,
          },

          emptyProfileBtn = {
            type = "execute",
            name = L["Empty Profile"],
            order = 3,
            width = 0.5,
            func = function()
              importMode = "empty"
              wowSimImportBuffer = ""
              wowSimParsedData = nil
              selectedSpec = nil
              previewProfileKey = nil
              selectedClass = nil

              wowSimOptions.args.Import.args.specSelect.args = {}
              AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
            end,
          },

          jsonInput = {
            type = "input",
            name = "JSON",
            multiline = 18,
            width = "full",
            order = 10,
            get = function()
              return wowSimImportBuffer
            end,
            set = function(_, v)
              importMode = "json"
              wowSimImportBuffer = v

              wowSimParsedData = nil
              selectedSpec = nil
              previewProfileKey = nil

              if not v or v == "" then
                wowSimImportStatus = "empty"
                wowSimOptions.args.Import.args.specSelect.args = {}
                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                return
              end

              local ok, data, status = pcall(DeserializeJSON, v)
              if ok and data == nil then
                wowSimImportStatus = status or "EncodingUtil"
                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                return
              end
              if not ok or type(data) ~= "table" then
                wowSimImportStatus = "error"
                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                return
              end

              local class = data and data.player and NormalizeSimClass(data.player.class)
              if not class or not CLASS_SPEC_IDS[class] then
                wowSimImportStatus = "unknown_class"
                wowSimParsedData = data -- keep for display
                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                return
              end

              wowSimParsedData = data
              wowSimImportStatus = "ready"

              wowSimOptions.args.Import.args.specSelect.args = BuildSpecSelectArgs()

              AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
              AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
            end,
          },

          classSelect = {
            type = "group",
            name = L["Class"],
            order = 12,
            inline = true,
            hidden = function()
              return importMode ~= "empty"
            end,
            args = (function()
              local args = {}

              for classFile, specs in pairs(CLASS_SPEC_IDS) do
                local icon = CLASS_ICONS[classFile]
                if icon then
                  args["class_" .. classFile] = {
                    type = "execute",
                    name = "",
                    image = icon,
                    imageWidth = 32,
                    imageHeight = 32,
                    func = function()
                      selectedClass = classFile
                      selectedSpec = nil
                      previewProfileKey = nil

                      wowSimOptions.args.Import.args.specSelect.args = BuildSpecSelectArgs()
                      AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                    end,
                  }
                end
              end

              return args
            end)(),
          },

          specSelect = {
            type = "group",
            name = L["Specialization"],
            order = 15,
            inline = true,
            hidden = function()
              if importMode == "empty" then
                return not selectedClass
              end
              return not wowSimParsedData or wowSimImportStatus ~= "ready"
            end,
            args = {},
          },

          profileName = {
            type = "description",
            order = 16,
            name = function()
              if previewProfileKey then
                return "|cff00ff00" .. L["Profile: "] .. "|r " .. previewProfileKey
              end
              if wowSimImportStatus == "ready" then
                return "|cffff8800" .. L["Select a specialization."] .. "|r"
              end
              return " "
            end,
          },

          importBtn = {
            type = "execute",
            name = L["Import"],
            order = 20,
            disabled = function()
              if importMode == "empty" then
                return not (selectedClass and selectedSpec)
              end
              return not (wowSimParsedData and selectedSpec and previewProfileKey and wowSimImportStatus == "ready")
            end,
            func = function()
              if importMode == "empty" then
                local class = selectedClass
                local finalKey = MakeProfileKey(selectedSpec.specKey, class)

                MerfinPlus.db.global.wowSims.profiles[finalKey] = {
                  key = finalKey,
                  class = class,
                  specID = selectedSpec.specID,
                  specKey = selectedSpec.specKey,
                  icon = selectedSpec.icon,
                  items = {},
                  importedAt = time(),
                }

                selectedProfileKey = finalKey
                importMode = "json"

                NotifySimChanged()

                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
                return
              end

              local data = wowSimParsedData
              if not data then
                return
              end

              local class = NormalizeSimClass(data.player.class)
              if not class then
                return
              end

              local finalKey = MakeProfileKey(selectedSpec.specKey, class)

              local items, suffixes = ExtractSlotItemsFromSim(data)
              MerfinPlus.db.global.wowSims.profiles[finalKey] = {
                key = finalKey,
                class = class,
                specID = selectedSpec.specID,
                specKey = selectedSpec.specKey,
                icon = selectedSpec.icon,
                items = items,
                itemSuffixes = suffixes,
                importedAt = time(),
              }

              -- AUTO-ASSIGN if same class
              local _, playerClass = UnitClass("player")
              if playerClass == class then
                local charKey = GetCharKey()
                MerfinPlus.db.global.wowSims.assigned[charKey] = MerfinPlus.db.global.wowSims.assigned[charKey] or {}

                MerfinPlus.db.global.wowSims.assigned[charKey][selectedSpec.specID] = finalKey
              end

              wowSimImportBuffer = ""
              wowSimParsedData = nil
              selectedSpec = nil
              previewProfileKey = nil
              wowSimImportStatus = "ok"

              wowSimOptions.args.Manager.args = BuildWowSimManagerArgsV2()

              NotifySimChanged()

              AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
              AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
            end,
          },

          importStatus = {
            type = "description",
            order = 21,
            name = function()
              if wowSimImportStatus == "ok" then
                return "|cff00ff00" .. L["Import successful."] .. "|r"
              elseif wowSimImportStatus == "ready" then
                return "|cff00ff00 " .. L["Ready."] .. "|r"
              elseif wowSimImportStatus == "unknown_class" then
                return "|cffff0000 " .. L["Unknown / unsupported class in JSON."] .. "|r"
              elseif wowSimImportStatus == "error" then
                return "|cffff0000" .. L["Invalid JSON."] .. "|r"
              elseif wowSimImportStatus == "empty" then
                return "|cffff8800" .. L["No JSON provided."] .. "|r"
              elseif wowSimImportStatus == "EncodingUtil" then
                return "|cffff8800 " .. L["C_EncodingUtil not available in this WoW version."] .. "|r"
              end
              return " "
            end,
          },
        },
      },

      -- =====================
      -- TAB 2: IMPORT MANAGER
      -- =====================
      Manager = {
        type = "group",
        name = L["Import Manager"],
        order = 2,
        args = BuildWowSimManagerArgsV2(),
      },
    },
  }

  -- ==== Profiles (AceDB) ====
  local profilesOptions = AceDBOptions:GetOptionsTable(self.db)
  profilesOptions.name = L["Profiles"] or "Profiles" -- ensure the node has a name

  -- ==== Register Blizzard panels (left AddOns pane) ====
  AceConfigRegistry:RegisterOptionsTable("MerfinPlus", mainOptions)
  self.optionsFrame = AceConfigDialog:AddToBlizOptions("MerfinPlus", "MerfinPlus v" .. version)

  if IsTBC() or version == '2.92' then
    AceConfigRegistry:RegisterOptionsTable("MerfinPlus_RaidPack", raidPack)
    AceConfigDialog:AddToBlizOptions("MerfinPlus_RaidPack", "Raid WA Options", "MerfinPlus v" .. version)
  end

  AceConfigRegistry:RegisterOptionsTable("MerfinPlus_Media", mediaOptions)
  AceConfigDialog:AddToBlizOptions("MerfinPlus_Media", "Media", "MerfinPlus v" .. version)

  if IsWrath() or IsTBC() or IsCata() or IsMoP() then
    AceConfigRegistry:RegisterOptionsTable("MerfinPlus_WoWSim", wowSimOptions)
    AceConfigDialog:AddToBlizOptions("MerfinPlus_WoWSim", "WoW Sim", "MerfinPlus v" .. version)
  end

  AceConfigRegistry:RegisterOptionsTable("MerfinPlus_Profiles", profilesOptions)
  AceConfigDialog:AddToBlizOptions("MerfinPlus_Profiles", "Profiles", "MerfinPlus v" .. version)

  -- ==== Standalone window (own AceConfigDialog frame) ====
  -- IMPORTANT: include whole profilesOptions object, not just .args, to keep its handler intact.
  local standaloneOptions = {
    type = "group",
    name = "MerfinPlus v" .. version,
    childGroups = "tree",
    args = {
      media = (function()
        mediaOptions.order = 20
        mediaOptions.name = "Media"
        mediaOptions.childGroups = nil
        return mediaOptions
      end)(),
      profiles = (function()
        profilesOptions.order = 100
        profilesOptions.name = L["Profiles"] or "Profiles"
        return profilesOptions
      end)(),
    },
  }
  if IsTBC() or version == '2.92' then
    standaloneOptions.args.raidPack = (function()
      raidPack.order = 10
      raidPack.name = "Raid WA Options"
      return raidPack
    end)()
  end

  if IsWrath() or IsTBC() or IsCata() or IsMoP() then
    standaloneOptions.args.wowSim = (function()
      wowSimOptions.order = 30
      wowSimOptions.name = "WoW Sim"
      return wowSimOptions
    end)()
  end

  AceConfigRegistry:RegisterOptionsTable("MerfinPlus_Standalone", standaloneOptions)
  -- Keep the 135px navigation tree unchanged and widen only the content area by 5%.
  AceConfigDialog:SetDefaultSize("MerfinPlus_Standalone", 960, 569)
  local standaloneStatus = AceConfigDialog:GetStatusTable("MerfinPlus_Standalone")
  standaloneStatus.groups = standaloneStatus.groups or {}
  standaloneStatus.groups.treewidth = 135
  standaloneStatus.groups.treesizable = true

  -- Toggle standalone and optionally preselect section/subtab
  function MerfinPlus:ToggleStandalone(which, sub)
    local ACD = AceConfigDialog
    if ACD.OpenFrames and ACD.OpenFrames["MerfinPlus_Standalone"] then
      ACD:Close("MerfinPlus_Standalone")
    else
      ACD:Open("MerfinPlus_Standalone")
    end
    if which == "media" or which == "raid" or which == "profiles" then
      if which == "raid" and sub then
        ACD:SelectGroup("MerfinPlus_Standalone", "raidPack", sub)
      elseif which == "raid" then
        ACD:SelectGroup("MerfinPlus_Standalone", "raidPack")
      else
        ACD:SelectGroup("MerfinPlus_Standalone", which)
      end
    end

    if which == "media" or which == "profiles" then
      ACD:SelectGroup("MerfinPlus_Standalone", which)
    end
  end

  -- ==== Slash commands ====
  local function _norm(msg)
    return strlower(strtrim(msg or ""))
  end

  -- /merfinplus [media|profiles]
  AceConsole:RegisterChatCommand("merfinplus", function(msg)
    msg = _norm(msg)
    local which, sub = strmatch(msg, "^(%S+)%s+(%S+)$")
    which = which or msg
    if which == "media" or which == "profiles" then
      MerfinPlus:ToggleStandalone(which)
    else
      MerfinPlus:ToggleStandalone(nil)
    end
  end)

  AceConsole:RegisterChatCommand("mp", function(msg)
    msg = _norm(msg)
    local which, sub = strmatch(msg, "^(%S+)%s+(%S+)$")
    which = which or msg
    if which == "media" or which == "profiles" then
      MerfinPlus:ToggleStandalone(which)
    else
      MerfinPlus:ToggleStandalone(nil)
    end
  end)
end

-- ==== Media registration ====
function MerfinPlus:RegisterCustomFonts()
  local db = self:GetDB()
  local fonts = {
    { key = "font1", name = "Merfin Font 1" },
    { key = "font2", name = "Merfin Font 2" },
    { key = "font3", name = "Merfin Raid Font" },
    { key = "font4", name = "Merfin Raid Font (Bold)" },
  }
  for _, f in ipairs(fonts) do
    local path = LSM:Fetch("font", db[f.key], true)
    if path then
      LSM:Register(
        "font",
        f.name,
        path,
        LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW
      )
    else
      -- print(string.format("|cffff0000[MerfinPlus]|r Failed to register %s - invalid font path", f.name))
    end
  end
end

function MerfinPlus:RegisterCustomBars()
  local db = self:GetDB()
  local bars = {
    { key = "bar1", name = "Merfin Status Bar 1" },
    { key = "bar2", name = "Merfin Status Bar 2" },
    { key = "bar3", name = "Merfin Raid Status Bar" },
  }
  for _, b in ipairs(bars) do
    local path = LSM:Fetch("statusbar", db[b.key], true)
    if path then
      LSM:Register("statusbar", b.name, path)
    else
      -- print(string.format("|cffff0000[MerfinPlus]|r Failed to register %s - invalid status bar path", b.name))
    end
  end
end

-- Mirror current selection under alias names for other addons/WA to consume
function MerfinPlus:RegisterMediaAliasesFromCallback()
  local db = self:GetDB()

  local fontMap = {
    { key = db.font1, alias = "Merfin Font 1" },
    { key = db.font2, alias = "Merfin Font 2" },
    { key = db.font3, alias = "Merfin Raid Font" },
    { key = db.font4, alias = "Merfin Raid Font (Bold)" },
  }
  local barMap = {
    { key = db.bar1, alias = "Merfin Status Bar 1" },
    { key = db.bar2, alias = "Merfin Status Bar 2" },
    { key = db.bar3, alias = "Merfin Raid Status Bar" },
  }

  LSM.RegisterCallback(self, "LibSharedMedia_Registered", function(_, mediatype, key)
    if mediatype == "font" then
      for _, e in ipairs(fontMap) do
        if e.key == key then
          local path = LSM:Fetch("font", e.key)
          if path then
            LSM:Register(
              "font",
              e.alias,
              path,
              LSM.LOCALE_BIT_western
                + LSM.LOCALE_BIT_ruRU
                + LSM.LOCALE_BIT_koKR
                + LSM.LOCALE_BIT_zhCN
                + LSM.LOCALE_BIT_zhTW
            )
          end
        end
      end
    elseif mediatype == "statusbar" or mediatype == "statusbar_atlas" then
      for _, e in ipairs(barMap) do
        if e.key == key then
          local path = LSM:Fetch("statusbar", e.key)
          if path then
            LSM:Register("statusbar", e.alias, path)
          end
        end
      end
    end
  end)
end
