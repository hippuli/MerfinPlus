-- Raid cooldown options ported from the post-2.76 main branch.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
-- Raid Settings can switch UI locale while the addon is open. The legacy
-- MerfinPlus.L table is fixed at addon load, so use the live UI registry.
local L = setmetatable({}, {
  __index = function(_, key)
    return MerfinPlus:T(key)
  end,
})
local AceSerializer = LibStub("AceSerializer-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

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
    { encounter = "608", id = "Random", raidLocale = "Random Blessing", icon = 134400 },
    { encounter = "608", id = "SpellWarding", spell = 41451 },
    { encounter = "608", id = "Protection", spell = 41450 },
    { encounter = "608", id = "Vanish", name = "Vanish", spell = 41476 },
    { encounter = "608", id = "VanishEnd", name = "Vanish End", spell = 41476 },
    { encounter = "609", id = "Berserk", name = "Berserk", icon = 136206 },
    { encounter = "609", id = "AgonizingFlames", spell = 40932 },
    { encounter = "609", id = "DarkBarrage", spell = 40585 },
    { encounter = "609", id = "DemonForm", name = "Demon Form", icon = 136172 },
    { encounter = "609", id = "DrawSoul", spell = 40904 },
    { encounter = "609", id = "EyeBlast", spell = 40018, icon = 135780 },
    { encounter = "609", id = "FlameBurst", spell = 41131 },
    { encounter = "609", id = "FlameCrash", spell = 40832 },
    { encounter = "609", id = "ParasiticShadowfiend", spell = 41917 },
    { encounter = "609", id = "Phase4", name = "Phase 4", icon = "Interface\\Addons\\MerfinPlus\\Media\\icons\\raid\\bt_illidan_128.png" },
    { encounter = "609", id = "Shear", spell = 41032 },
  },
  hyjalSummit = {
    { encounter = "618", id = "DeathDecay", spell = 31258 },
    { encounter = "618", id = "FrostNova", spell = 31250 },
    { encounter = "618", id = "FrostArmor", spell = 31256 },
    { encounter = "619", id = "Inferno", spell = 31299 },
    { encounter = "619", id = "CarrionSwarm", spell = 31306 },
    { encounter = "619", id = "Sleep", spell = 31298 },
    { encounter = "620", id = "MalevolentCleave", spell = 31436 },
    { encounter = "620", id = "WarStomp", spell = 31480 },
    { encounter = "620", id = "Cripple", spell = 31477 },
    { encounter = "620", id = "MarkOfKazrogal", spell = 31447 },
    { encounter = "622", id = "DoomfireStrike", raidLocale = "Waves", icon = 135818 },
    { encounter = "622", id = "GripOfTheLegion", spell = 31972 },
    { encounter = "622", id = "AirBurst", spell = 32014 },
    { encounter = "622", id = "Fear", spell = 31970 },
    {
      encounter = "Trash-Hyjal",
      id = "Waves",
      name = "Waves",
      icon = "Interface\\Addons\\MerfinPlus\\Media\\icons\\raid\\hyjal_winterchill_128.png",
      npc = 0,
      mob = "Hyjal Trash",
    },
    {
      encounter = "Trash-Hyjal",
      id = "FrostWyrm",
      name = "Frost Wyrm",
      icon = 135846,
      npc = 0,
      mob = "Hyjal Trash",
    },
  },
}

local function AppendCatalog(target, source)
  for _, cooldown in ipairs(source or {}) do
    target[#target + 1] = cooldown
  end
end

AppendCatalog(raidCooldownCatalog.blackTemple, MerfinPlus.BTTrashCooldownCatalog)
AppendCatalog(raidCooldownCatalog.serpentshrineCavern, MerfinPlus.SSCCooldownCatalog)
AppendCatalog(raidCooldownCatalog.tempestKeep, MerfinPlus.TKCooldownCatalog)
AppendCatalog(raidCooldownCatalog.hyjalSummit, MerfinPlus.HyjalCooldownCatalog)
MerfinPlus.RaidCooldownCatalog = raidCooldownCatalog

local encounterNames = {
  ["623"] = "Hydross the Unstable", ["624"] = "The Lurker Below",
  ["625"] = "Leotheras the Blind", ["627"] = "Morogrim Tidewalker", ["628"] = "Lady Vashj",
  ["730"] = "Al'ar", ["731"] = "Void Reaver", ["732"] = "High Astromancer Solarian",
  ["733"] = "Kael'thas Sunstrider",
  ["601"] = "High Warlord Naj'entus", ["602"] = "Supremus", ["603"] = "Shade of Akama",
  ["604"] = "Teron Gorefiend", ["605"] = "Gurtogg Bloodboil", ["606"] = "Reliquary of Souls",
  ["607"] = "Mother Shahraz", ["608"] = "Illidari Council", ["609"] = "Illidan Stormrage",
  ["618"] = "Rage Winterchill",
  ["619"] = "Anetheron",
  ["620"] = "Kaz'rogal",
  ["622"] = "Archimonde",
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
  ["618"] = raidBossIconPath .. "hyjal_winterchill_128.png",
  ["619"] = raidBossIconPath .. "hyjal_anetheron_128.png",
  ["620"] = raidBossIconPath .. "hyjal_kazrogal_128.png",
  ["622"] = raidBossIconPath .. "hyjal_archimonde_128.png",
}

local encounterOrders = {
  serpentshrineCavern = { "623", "624", "625", "627", "628" },
  tempestKeep = { "730", "731", "732", "733" },
  blackTemple = { "601", "602", "603", "604", "605", "606", "607", "608", "609" },
  hyjalSummit = { "618", "619", "620", "622" },
}

local transferState = { text = "", status = "" }
local generalDefaults = {
  enableTimeline = false,
  disableCD = false,
  emphasizedBar = true,
  emphasizedOn = 7,
  berserkOnlyShow = false,
  berserkShowOn = 60,
  enableRL = true,
}

local function SpellName(spellID)
  if Merfin and Merfin.GetSpellName then
    return Merfin.GetSpellName(spellID)
  end
  if C_Spell and C_Spell.GetSpellName then
    return C_Spell.GetSpellName(spellID)
  end
  if GetSpellInfo then
    return GetSpellInfo(spellID)
  end
end

local function SpellTexture(spellID)
  if C_Spell and C_Spell.GetSpellTexture then
    return C_Spell.GetSpellTexture(spellID)
  end
  if GetSpellTexture then
    return GetSpellTexture(spellID)
  end
end

local function Label(text, icon)
  return icon and ("|T" .. tostring(icon) .. ":16:16:0:0|t " .. text) or text
end

-- AceConfig otherwise snapshots string names while the option tree is built.
-- Keep every label reactive to a later MerfinPlus UI-language change.
local function MakeOptionNamesDynamic(option)
  if type(option) ~= "table" then
    return option
  end
  if type(option.name) == "string" then
    local staticName = option.name
    option.name = function()
      return MerfinPlus:LocalizeKnownValue(staticName)
    end
  end
  for _, child in pairs(option.args or {}) do
    MakeOptionNamesDynamic(child)
  end
  return option
end

local function CooldownLabel(cooldown)
  local name = cooldown.name or cooldown.fallbackName
  local icon = cooldown.icon
  if cooldown.raidLocale and Merfin and Merfin.LRaid then
    name = Merfin:LRaid(cooldown.raidLocale)
  end
  if cooldown.spell then
    name = name or SpellName(cooldown.spell) or cooldown.id
    icon = icon or SpellTexture(cooldown.spell)
  end
  name = MerfinPlus:GetLocalizedRaidCooldownName(cooldown.id, cooldown.spell, name or cooldown.id)
  return Label(name, icon)
end

local function EnsureRaidCooldowns()
  local profile = MerfinPlus.db.profile
  profile.raidCooldowns = profile.raidCooldowns or {}
  profile.raidCooldowns.general = profile.raidCooldowns.general or {}
  profile.raidCooldowns.raids = profile.raidCooldowns.raids or {}
  for key, value in pairs(generalDefaults) do
    if profile.raidCooldowns.general[key] == nil then
      profile.raidCooldowns.general[key] = value
    end
  end
  for raidKey in pairs(raidCooldownCatalog) do
    profile.raidCooldowns.raids[raidKey] = profile.raidCooldowns.raids[raidKey] or {}
  end
  return profile.raidCooldowns
end

local function GetRaidCooldownDB(raidKey)
  return EnsureRaidCooldowns().raids[raidKey]
end

local function NotifyChanged()
  if Merfin and Merfin.NotifyRaidCooldownConfigChanged then
    Merfin.NotifyRaidCooldownConfigChanged()
  end
end

local function BuildEncounterCooldownOptions(raidKey, encounterID)
  local entries = {}
  for _, cooldown in ipairs(raidCooldownCatalog[raidKey] or {}) do
    if cooldown.encounter == encounterID then
      entries[#entries + 1] = cooldown
    end
  end

  local function Settings(cooldown)
    local raidDB = GetRaidCooldownDB(raidKey)
    raidDB[encounterID] = raidDB[encounterID] or {}
    raidDB[encounterID][cooldown.id] = raidDB[encounterID][cooldown.id] or {}
    return raidDB[encounterID][cooldown.id]
  end
  local function Disabled()
    local encounter = GetRaidCooldownDB(raidKey)[encounterID]
    return encounter and encounter.__disabled == true
  end

  local args = {
    disableAll = {
      type = "toggle", name = L["Disable All Cooldowns for Boss"], order = 1, width = 1.5,
      get = Disabled,
      set = function(_, value)
        local raidDB = GetRaidCooldownDB(raidKey)
        raidDB[encounterID] = raidDB[encounterID] or {}
        raidDB[encounterID].__disabled = value and true or false
        NotifyChanged()
      end,
    },
    row = { type = "description", name = "", order = 1.5, width = "full" },
  }

  for index, catalogEntry in ipairs(entries) do
    local cooldown = catalogEntry
    local prefix = "cooldown" .. index
    local order = index * 10
    args[prefix .. "Header"] = {
      type = "header", order = order,
      name = function() return CooldownLabel(cooldown) end,
    }
    args[prefix .. "DisplayBar"] = {
      type = "toggle", name = L["Display as Bar"], order = order + 1, width = 1,
      disabled = Disabled,
      get = function() return Settings(cooldown).displayBar ~= false end,
      set = function(_, value) Settings(cooldown).displayBar = value; NotifyChanged() end,
    }
    args[prefix .. "DisplayTimeline"] = {
      type = "toggle", name = L["Display on Timeline"], order = order + 2, width = 1,
      disabled = Disabled,
      get = function() return Settings(cooldown).displayTimeline ~= false end,
      set = function(_, value) Settings(cooldown).displayTimeline = value; NotifyChanged() end,
    }
    args[prefix .. "DisplayNameplate"] = {
      type = "toggle", name = L["Display on Nameplates"], order = order + 3, width = 1.2,
      hidden = not (cooldown.id and cooldown.id:find("Cleave", 1, true)),
      disabled = Disabled,
      get = function() return Settings(cooldown).displayNameplate ~= false end,
      set = function(_, value) Settings(cooldown).displayNameplate = value; NotifyChanged() end,
    }
    args[prefix .. "EmphasizedBar"] = {
      type = "toggle", name = L["Emphasized Bar"], order = order + 4, width = 1.25,
      disabled = Disabled,
      get = function() return Settings(cooldown).emphasizedBar or false end,
      set = function(_, value) Settings(cooldown).emphasizedBar = value; NotifyChanged() end,
    }
    args[prefix .. "EmphasizedOn"] = {
      type = "range", name = L["Emphasize when (sec) left"], order = order + 5,
      min = 3, max = 30, step = 0.5, width = 1.5,
      disabled = function() return Disabled() or not Settings(cooldown).emphasizedBar end,
      get = function() return Settings(cooldown).emphasizedOn or 7 end,
      set = function(_, value) Settings(cooldown).emphasizedOn = value; NotifyChanged() end,
    }
    args[prefix .. "EnabledCustom"] = {
      type = "toggle", name = L["Use Custom Name"], order = order + 6, width = 1.25,
      disabled = Disabled,
      get = function() return Settings(cooldown).enabledCustom or false end,
      set = function(_, value) Settings(cooldown).enabledCustom = value; NotifyChanged() end,
    }
    args[prefix .. "CustomName"] = {
      type = "input", name = L["Custom Name"], order = order + 7, width = 1.75,
      disabled = function() return Disabled() or not Settings(cooldown).enabledCustom end,
      get = function() return Settings(cooldown).customName or "" end,
      set = function(_, value) Settings(cooldown).customName = value; NotifyChanged() end,
    }
  end

  return args
end

local trashSectionPalette = {
  "5BC0EB", "FDE74C", "9B5DE5", "00BBF9", "F15BB5", "FF9F1C",
  "B8F2E6", "FF70A6", "70E000", "F94144", "C77DFF", "4CC9F0",
}

local function BuildTrashNpcSections(raidKey, encounterID)
  local trackedNpcs = {}
  for _, cooldown in ipairs(raidCooldownCatalog[raidKey] or {}) do
    if cooldown.encounter == encounterID and cooldown.npc then
      trackedNpcs[cooldown.npc] = true
    end
  end

  local bestSections, bestScore
  for _, markerCatalog in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
    local score = 0
    for _, section in ipairs(markerCatalog.sections or {}) do
      for _, npcID in ipairs(section.npcs or {}) do
        if trackedNpcs[npcID] then
          score = score + 1
        end
      end
    end
    if score > (bestScore or 0) then
      bestSections, bestScore = markerCatalog.sections, score
    end
  end

  local presentation = {}
  for sectionOrder, section in ipairs(bestSections or {}) do
    local color = trashSectionPalette[((sectionOrder - 1) % #trashSectionPalette) + 1]
    for _, npcID in ipairs(section.npcs or {}) do
      presentation[npcID] = { color = color, sectionOrder = sectionOrder }
    end
  end
  return presentation
end

local function BuildTrashCooldownOptions(raidKey, encounterID)
  local mobs, mobValues, mobNames, mobSorting = {}, {}, {}, {}
  local npcPresentation = BuildTrashNpcSections(raidKey, encounterID)
  for _, cooldown in ipairs(raidCooldownCatalog[raidKey] or {}) do
    if cooldown.encounter == encounterID and cooldown.npc and not mobs[cooldown.npc] then
      mobs[cooldown.npc] = true
      local mobName = MerfinPlus:T(cooldown.mob or tostring(cooldown.npc))
      local presentation = npcPresentation[cooldown.npc]
      mobNames[cooldown.npc] = mobName
      mobValues[cooldown.npc] = presentation
        and ("|cff" .. presentation.color .. mobName .. "|r") or mobName
      mobSorting[#mobSorting + 1] = cooldown.npc
    end
  end
  table.sort(mobSorting, function(a, b)
    local aSection = npcPresentation[a] and npcPresentation[a].sectionOrder or 999
    local bSection = npcPresentation[b] and npcPresentation[b].sectionOrder or 999
    if aSection ~= bSection then return aSection < bSection end
    return mobNames[a] < mobNames[b]
  end)

  local selectedNpc = mobSorting[1]
  local function Settings(cooldown)
    local raidDB = GetRaidCooldownDB(raidKey)
    raidDB[encounterID] = raidDB[encounterID] or {}
    raidDB[encounterID][cooldown.id] = raidDB[encounterID][cooldown.id] or {}
    return raidDB[encounterID][cooldown.id]
  end
  local function Disabled()
    local encounter = GetRaidCooldownDB(raidKey)[encounterID]
    return selectedNpc and encounter and encounter.__disabledNpcs
      and encounter.__disabledNpcs[selectedNpc] == true or false
  end

  local args = {
    mob = {
      type = "select", name = L["Enemy"], order = 1, width = 1.5,
      values = function()
        local values = {}
        for _, npcID in ipairs(mobSorting) do
          values[npcID] = MerfinPlus:GetLocalizedEnemyName(npcID, mobValues[npcID])
        end
        return values
      end,
      sorting = mobSorting,
      get = function() return selectedNpc end,
      set = function(_, value) selectedNpc = value end,
    },
    disableAll = {
      type = "toggle", name = L["Disable All Cooldowns for Enemy"], order = 2, width = 1.5,
      get = Disabled,
      set = function(_, value)
        if not selectedNpc then return end
        local raidDB = GetRaidCooldownDB(raidKey)
        raidDB[encounterID] = raidDB[encounterID] or {}
        raidDB[encounterID].__disabledNpcs = raidDB[encounterID].__disabledNpcs or {}
        raidDB[encounterID].__disabledNpcs[selectedNpc] = value and true or nil
        NotifyChanged()
      end,
    },
    row = { type = "description", name = "", order = 2.5, width = "full" },
  }

  local entryIndex = 0
  for _, catalogEntry in ipairs(raidCooldownCatalog[raidKey] or {}) do
    if catalogEntry.encounter == encounterID and catalogEntry.npc then
      entryIndex = entryIndex + 1
      local cooldown = catalogEntry
      local prefix = "cooldown" .. entryIndex
      local order = entryIndex * 10
      local function Hidden() return selectedNpc ~= cooldown.npc end
      args[prefix .. "Header"] = {
        type = "header", order = order,
        name = function() return CooldownLabel(cooldown) end,
        hidden = Hidden,
      }
      args[prefix .. "DisplayBar"] = {
        type = "toggle", name = L["Display as Bar"], order = order + 1, width = 0.9,
        hidden = Hidden,
        disabled = Disabled,
        get = function() return Settings(cooldown).displayBar == true end,
        set = function(_, value) Settings(cooldown).displayBar = value; NotifyChanged() end,
      }
      args[prefix .. "DisplayTimeline"] = {
        type = "toggle", name = L["Display on Timeline"], order = order + 2, width = 0.9,
        hidden = Hidden,
        disabled = Disabled,
        get = function() return Settings(cooldown).displayTimeline == true end,
        set = function(_, value) Settings(cooldown).displayTimeline = value; NotifyChanged() end,
      }
      args[prefix .. "DisplayNameplate"] = {
        type = "toggle", name = L["Display on Nameplates"], order = order + 3, width = 1.2,
        hidden = Hidden,
        disabled = Disabled,
        get = function() return Settings(cooldown).displayNameplate ~= false end,
        set = function(_, value) Settings(cooldown).displayNameplate = value; NotifyChanged() end,
      }
      args[prefix .. "EmphasizedBar"] = {
        type = "toggle", name = L["Emphasized Bar"], order = order + 4, width = 1.25,
        hidden = Hidden,
        disabled = Disabled,
        get = function() return Settings(cooldown).emphasizedBar or false end,
        set = function(_, value) Settings(cooldown).emphasizedBar = value; NotifyChanged() end,
      }
      args[prefix .. "EmphasizedOn"] = {
        type = "range", name = L["Emphasize when (sec) left"], order = order + 5,
        min = 3, max = 30, step = 0.5, width = 1.5,
        hidden = Hidden,
        disabled = function() return Disabled() or not Settings(cooldown).emphasizedBar end,
        get = function() return Settings(cooldown).emphasizedOn or 7 end,
        set = function(_, value) Settings(cooldown).emphasizedOn = value; NotifyChanged() end,
      }
      args[prefix .. "EnabledCustom"] = {
        type = "toggle", name = L["Use Custom Name"], order = order + 6, width = 1.25,
        hidden = Hidden,
        disabled = Disabled,
        get = function() return Settings(cooldown).enabledCustom or false end,
        set = function(_, value) Settings(cooldown).enabledCustom = value; NotifyChanged() end,
      }
      args[prefix .. "CustomName"] = {
        type = "input", name = L["Custom Name"], order = order + 7, width = 1.75,
        hidden = Hidden,
        disabled = function() return Disabled() or not Settings(cooldown).enabledCustom end,
        get = function() return Settings(cooldown).customName or "" end,
        set = function(_, value) Settings(cooldown).customName = value; NotifyChanged() end,
      }
    end
  end

  return args
end

local function HasEncounter(raidKey, encounterID)
  for _, cooldown in ipairs(raidCooldownCatalog[raidKey] or {}) do
    if cooldown.encounter == encounterID then return true end
  end
  return false
end

local function BuildRaidBosses(raidKey, trashEncounterID)
  local args = {}
  if HasEncounter(raidKey, trashEncounterID) then
    args.trash = {
      type = "group", name = L["Trash"], order = 1,
      args = BuildTrashCooldownOptions(raidKey, trashEncounterID),
    }
  end
  for order, encounterID in ipairs(encounterOrders[raidKey] or {}) do
    if HasEncounter(raidKey, encounterID) then
      args["boss" .. encounterID] = {
        type = "group",
        name = function()
          return Label(
            MerfinPlus:GetLocalizedBossName("encounter:" .. encounterID, encounterNames[encounterID]),
            encounterBossIcons[encounterID]
          )
        end,
        order = order + 1,
        args = BuildEncounterCooldownOptions(raidKey, encounterID),
      }
    end
  end
  return args
end

local function CopySettings(source, isTrash)
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

local function BuildExport()
  local db = EnsureRaidCooldowns()
  local payload = { kind = "cooldowns", version = 1, general = {}, raids = {} }
  for key, fallback in pairs(generalDefaults) do
    local value = db.general[key]
    payload.general[key] = value == nil and fallback or value
  end
  for raidKey, catalog in pairs(raidCooldownCatalog) do
    payload.raids[raidKey] = {}
    local sourceRaid = db.raids[raidKey] or {}
    for _, cooldown in ipairs(catalog) do
      local encounterID = cooldown.encounter
      local target = payload.raids[raidKey][encounterID] or { __disabledNpcs = {} }
      payload.raids[raidKey][encounterID] = target
      local source = sourceRaid[encounterID] or {}
      target.__disabled = source.__disabled == true
      if cooldown.npc and source.__disabledNpcs and source.__disabledNpcs[cooldown.npc] then
        target.__disabledNpcs[cooldown.npc] = true
      end
      target[cooldown.id] = CopySettings(source[cooldown.id], encounterID:match("^Trash%-") ~= nil)
    end
  end
  return "!MPCD:1!" .. AceSerializer:Serialize(payload)
end

local function Import(text)
  text = type(text) == "string" and text:match("^%s*(.-)%s*$") or ""
  local prefix = "!MPCD:1!"
  if text:sub(1, #prefix) ~= prefix then return false, L["Invalid Cooldowns export string."] end
  local ok, payload = AceSerializer:Deserialize(text:sub(#prefix + 1))
  if not ok or type(payload) ~= "table" or payload.kind ~= "cooldowns" or payload.version ~= 1 then
    return false, L["Invalid Cooldowns export string."]
  end

  local imported = { general = {}, raids = {} }
  local sourceGeneral = type(payload.general) == "table" and payload.general or {}
  for key, fallback in pairs(generalDefaults) do
    local value = sourceGeneral[key]
    imported.general[key] = type(fallback) == "boolean"
      and (type(value) == "boolean" and value or fallback)
      or (tonumber(value) or fallback)
  end
  imported.general.emphasizedOn = math.max(3, math.min(30, imported.general.emphasizedOn))
  imported.general.berserkShowOn = math.max(5, math.min(300, imported.general.berserkShowOn))

  for raidKey, catalog in pairs(raidCooldownCatalog) do
    imported.raids[raidKey] = {}
    local sourceRaid = type(payload.raids) == "table" and payload.raids[raidKey] or {}
    sourceRaid = type(sourceRaid) == "table" and sourceRaid or {}
    for _, cooldown in ipairs(catalog) do
      local encounterID = cooldown.encounter
      local sourceEncounter = type(sourceRaid[encounterID]) == "table" and sourceRaid[encounterID] or {}
      local target = imported.raids[raidKey][encounterID] or { __disabledNpcs = {} }
      imported.raids[raidKey][encounterID] = target
      target.__disabled = sourceEncounter.__disabled == true
      if cooldown.npc and sourceEncounter.__disabledNpcs
        and sourceEncounter.__disabledNpcs[cooldown.npc] == true then
        target.__disabledNpcs[cooldown.npc] = true
      end
      target[cooldown.id] = CopySettings(sourceEncounter[cooldown.id], encounterID:match("^Trash%-") ~= nil)
    end
  end

  MerfinPlus.db.profile.raidCooldowns = imported
  NotifyChanged()
  return true, L["Cooldown settings imported successfully."]
end

local function BuildTransferOptions()
  return {
    generateExport = {
      type = "execute", name = L["Generate Export"], order = 1, width = 1.25,
      func = function()
        transferState.text = BuildExport()
        transferState.status = ""
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    transferString = {
      type = "input", name = L["Export / Import"], order = 2, width = "full", multiline = 10,
      get = function() return transferState.text end,
      set = function(_, value) transferState.text = value or ""; transferState.status = "" end,
    },
    importButton = {
      type = "execute", name = L["Import"], order = 3, width = 1,
      disabled = function() return transferState.text == "" end,
      func = function()
        local ok, message = Import(transferState.text)
        transferState.status = (ok and "|cff33ff99" or "|cffff5555") .. tostring(message) .. "|r"
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    resetButton = {
      type = "execute", name = L["Reset to Default"], order = 4, width = 1.25,
      confirm = true,
      func = function()
        MerfinPlus.db.profile.raidCooldowns = nil
        transferState.text = ""
        transferState.status = ""
        EnsureRaidCooldowns()
        NotifyChanged()
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    status = {
      type = "description", order = 5, width = "full",
      name = function() return transferState.status end,
    },
  }
end

function MerfinPlus:BuildRaidCooldownProfileToolsOptions()
  return {
    type = "group",
    name = L["Cooldowns"],
    order = 1,
    args = BuildTransferOptions(),
  }
end

function MerfinPlus:BuildRaidCooldownOptions()
  EnsureRaidCooldowns()
  local options = {
    type = "group",
    name = L["Cooldowns"],
    childGroups = "tab",
    args = {
      general = {
        type = "group", name = L["General"], order = 1,
        get = function(info) return EnsureRaidCooldowns().general[info[#info]] end,
        set = function(info, value)
          EnsureRaidCooldowns().general[info[#info]] = value
          NotifyChanged()
        end,
        args = {
          enableTimeline = { type = "toggle", name = L["Enable Timeline"], order = 1, width = 1.5 },
          disableCD = { type = "toggle", name = L["Disable All Bars"], order = 2, width = 1.5 },
          mainSpacer = { type = "description", name = "", order = 3, width = "full" },
          emphasizedBar = { type = "toggle", name = L["Emphasize Cooldowns"], order = 4, width = 1.5 },
          emphasizedOn = { type = "range", name = L["Emphasize when (sec) left"], order = 5, min = 3, max = 30, step = 0.5, width = 1.5 },
          berserkOnlyShow = { type = "toggle", name = L["Show Berserk only near expiration"], order = 6, width = 1.5 },
          berserkShowOn = { type = "range", name = L["Show Berserk when (sec) left"], order = 7, min = 5, max = 300, step = 5, width = 1.5 },
          permissionsSpacer = { type = "description", name = "", order = 8, width = "full" },
          enableRL = { type = "toggle", name = L["Enable all cooldowns for Raid Leader / Assistant"], order = 9, width = "full" },
        },
      },
      raids = {
        type = "group", name = L["Raids"], order = 2, childGroups = "select",
        args = {
          serpentshrineCavern = {
            type = "group",
            name = function()
              return MerfinPlus:GetLocalizedRaidName("serpentshrineCavern", "Serpentshrine Cavern")
            end,
            order = 1, childGroups = "tree",
            args = BuildRaidBosses("serpentshrineCavern", "Trash-SSC"),
          },
          tempestKeep = {
            type = "group",
            name = function()
              return MerfinPlus:GetLocalizedRaidName("tempestKeep", "Tempest Keep")
            end,
            order = 2, childGroups = "tree",
            args = BuildRaidBosses("tempestKeep", "Trash-TK"),
          },
          blackTemple = {
            type = "group",
            name = function()
              return MerfinPlus:GetLocalizedRaidName("blackTemple", "Black Temple")
            end,
            order = 3, childGroups = "tree",
            args = BuildRaidBosses("blackTemple", "Trash-BT"),
          },
          hyjalSummit = {
            type = "group",
            name = function()
              return MerfinPlus:GetLocalizedRaidName("hyjalSummit", "Hyjal Summit")
            end,
            order = 4, childGroups = "tree",
            args = BuildRaidBosses("hyjalSummit", "Trash-Hyjal"),
          },
        },
      },
    },
  }
  return MakeOptionNamesDynamic(options)
end
