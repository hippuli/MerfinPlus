-- MerfinPlus WoW Sim / BiS options.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
-- Keep option labels in sync with a runtime UI-locale change.
local L = setmetatable({}, {
  __index = function(_, key)
    return MerfinPlus:T(key)
  end,
})
local IsWrath = MerfinPlus.IsWrath
local IsMoP = MerfinPlus.IsMoP
local IsCata = MerfinPlus.IsCata
local IsTBC = MerfinPlus.IsTBC

local function DeserializeJSON(source)
  if C_EncodingUtil and C_EncodingUtil.DeserializeJSON then
    return C_EncodingUtil.DeserializeJSON(source)
  end
  if MerfinPlusJSON and MerfinPlusJSON.decode then
    return MerfinPlusJSON.decode(source)
  end
  return nil, "EncodingUtil"
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

function MerfinPlus:BuildWoWSimOptions()
  if not (IsWrath() or IsTBC() or IsCata() or IsMoP()) then
    return nil
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
      name = L["Items"],
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
        name = L["+ Suffix"],
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
  local wowSimOptions
  wowSimOptions = {
    type = "group",
    name = L["WoW Sim"],
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
            name = L["JSON"],
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

  return wowSimOptions
end
