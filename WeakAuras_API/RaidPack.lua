local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local GetSpellCooldown = GetSpellCooldown

local interruptSpells = {
  [1766] = true, -- Rogue Kick
  [2139] = true, -- Mage Counterspell
  [6552] = true, -- Warrior Pummel
  [15487] = true, -- Priest Silence
  [19647] = true, -- Warlock pet Spell Lock
  [47528] = true, -- Death Knight Mind Freeze
  [57994] = true, -- Shaman Wind Shear
  [78675] = true, -- Druid Solar Beam
  [89766] = true, -- Warlock Pet Axe Toss
  [96231] = true, -- Paldin Rebuke
  [106839] = true, -- Druid Skull Bash
  [116705] = true, -- Monk Spear Hand Strike
  [147362] = true, -- Hunter Countershot
  [183752] = true, -- Demon hunter Disrupt
  [351338] = true, -- Evoker Quell
}

Merfin.RP = {
  cooldowns = {},
}

local raidEncounterMap = {
  ["623"] = "serpentshrineCavern", ["624"] = "serpentshrineCavern",
  ["625"] = "serpentshrineCavern", ["627"] = "serpentshrineCavern",
  ["628"] = "serpentshrineCavern", ["Trash-SSC"] = "serpentshrineCavern",
  ["730"] = "tempestKeep", ["731"] = "tempestKeep", ["732"] = "tempestKeep",
  ["733"] = "tempestKeep", ["Trash-TK"] = "tempestKeep",
  ["601"] = "blackTemple", ["602"] = "blackTemple", ["603"] = "blackTemple",
  ["604"] = "blackTemple", ["605"] = "blackTemple", ["606"] = "blackTemple",
  ["607"] = "blackTemple", ["608"] = "blackTemple", ["609"] = "blackTemple",
  ["Trash-BT"] = "blackTemple",
  ["618"] = "hyjalSummit", ["619"] = "hyjalSummit", ["620"] = "hyjalSummit",
  ["621"] = "hyjalSummit", ["622"] = "hyjalSummit", ["Trash-MH"] = "hyjalSummit",
}

local generalDefaults = {
  enableTimeline = false,
  disableCD = false,
  emphasizedBar = true,
  emphasizedOn = 7,
  berserkOnlyShow = false,
  berserkShowOn = 60,
  enableRL = true,
}

-- Returns the legacy table shape expected by the raid-pack cooldown router.
-- Keeping the adapter here lets WeakAuras consume MerfinPlus settings directly
-- without knowing anything about AceDB or the options UI layout.
Merfin.GetRaidCooldownConfig = function()
  local profile = MerfinPlus and MerfinPlus.db and MerfinPlus.db.profile
  local stored = profile and profile.raidCooldowns or {}
  local general = stored.general or {}
  local config = { default = {} }

  for key, fallback in pairs(generalDefaults) do
    local value = general[key]
    if value == nil then value = fallback end
    config.default[key] = value
  end

  local raids = stored.raids or {}
  for raidKey, cooldownCatalog in pairs(MerfinPlus.RaidCooldownCatalog or {}) do
    local storedRaid = raids[raidKey] or {}
    for _, entry in ipairs(cooldownCatalog) do
      local encounterID = entry.encounter
      local storedEncounter = storedRaid[encounterID] or {}
      local storedCooldown = storedEncounter[entry.id] or {}
      local disabled = storedEncounter.__disabled == true
      local isTrash = encounterID:match("^Trash%-") ~= nil
      if isTrash then
        disabled = storedEncounter.__disabledNpcs and storedEncounter.__disabledNpcs[entry.npc] == true or false
      end
      local displayBar = storedCooldown.displayBar
      if displayBar == nil then displayBar = not isTrash end
      local displayTimeline = storedCooldown.displayTimeline
      if displayTimeline == nil then displayTimeline = not isTrash end

      config[encounterID] = config[encounterID] or {}
      config[encounterID][entry.id] = { cooldown = {
        disabled = disabled,
        displayBar = displayBar,
        displayTimeline = displayTimeline,
        displayNameplate = storedCooldown.displayNameplate ~= false,
        emphasizedBar = storedCooldown.emphasizedBar == true,
        emphasizedOn = tonumber(storedCooldown.emphasizedOn) or 7,
        enabledCustom = storedCooldown.enabledCustom == true,
        customName = storedCooldown.customName,
      } }
    end
  end

  return config
end

Merfin.NotifyRaidCooldownConfigChanged = function()
  local config = Merfin.GetRaidCooldownConfig()
  if WeakAuras and WeakAuras.ScanEvents then
    WeakAuras.ScanEvents("MERFIN_RAID_COOLDOWN_CONFIG_UPDATED", config)
  end
  return config
end

Merfin.GetRaidAutoMarkerConfig = function()
  local profile = MerfinPlus and MerfinPlus.db and MerfinPlus.db.profile
  local stored = profile and profile.raidAutoMarker or {}
  local defaults = MerfinPlus and MerfinPlus.AutoMarkerDefaults or {}
  local catalog = MerfinPlus and MerfinPlus.AutoMarkerCatalog or {}
  local mouseover = stored.mouseover
  if mouseover == nil then mouseover = defaults.mouseover or 4 end
  local nameplates = stored.nameplates
  if nameplates == nil then nameplates = defaults.nameplates == true end
  local enemyEnabled = stored.enemyEnabled
  if enemyEnabled == nil then enemyEnabled = defaults.enemyEnabled ~= false end
  local friendlyEnabled = stored.friendlyEnabled
  if friendlyEnabled == nil then friendlyEnabled = defaults.friendlyEnabled ~= false end
  local config = {
    mouseover = mouseover,
    nameplates = nameplates,
    enemyEnabled = enemyEnabled,
    friendlyEnabled = friendlyEnabled,
    mechanics = {},
  }

  for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
    local key = mechanic.key
    local storedMechanic = stored.mechanics and stored.mechanics[key] or {}
    local defaultMechanic = defaults.mechanics and defaults.mechanics[key] or {}
    local enabled = storedMechanic.enable
    if enabled == nil then enabled = defaultMechanic.enable ~= false end
    local sourceMarks = storedMechanic.marks or {}
    local marks = {}
    for index = 1, mechanic.maxMarks or 1 do
      local mark = tonumber(sourceMarks[index]) or tonumber(defaultMechanic.marks and defaultMechanic.marks[index])
      if mark and mark >= 1 and mark <= 8 then marks[#marks + 1] = mark end
    end
    config.mechanics[key] = {
      enable = friendlyEnabled and enabled,
      marks = marks,
    }
  end

  -- AceDB exposes untouched defaults through metatables, so iterating the
  -- stored table alone omits every NPC which the player has not edited yet.
  -- The catalog is the authoritative list; resolve each setting explicitly.
  for instanceKey, instanceCatalog in pairs(catalog) do
    local storedInstance = stored.instances and stored.instances[instanceKey] or {}
    local defaultInstance = defaults.instances and defaults.instances[instanceKey] or {}
    local instanceConfig = {}

    for _, mob in ipairs(instanceCatalog.mobs or {}) do
      local npcID = mob.npc
      local storedNpc = storedInstance[npcID] or {}
      local defaultNpc = defaultInstance[npcID] or {}
      local enabled = storedNpc.enable
      local priority = storedNpc.priority
      if enabled == nil then enabled = defaultNpc.enable ~= false end
      if priority == nil then priority = defaultNpc.priority or 1 end

      local sourceMarks = storedNpc.marks or defaultNpc.marks or {}
      local marks = {}
      for index = 1, 8 do
        local mark = tonumber(sourceMarks[index])
        if mark and mark >= 1 and mark <= 8 then marks[index] = mark end
      end

      instanceConfig[npcID] = {
        enable = enemyEnabled and enabled,
        priority = priority,
        marks = marks,
      }
    end

    config[instanceKey] = instanceConfig
  end

  return config
end

Merfin.IsRaidAutoMarkerEnabled = function(markerType)
  local normalized = type(markerType) == "string" and markerType:lower() or ""
  local config = Merfin.GetRaidAutoMarkerConfig()

  if normalized == "enemy" then
    return config.enemyEnabled == true
  elseif normalized == "friendly" then
    return config.friendlyEnabled == true
  end

  return false
end

Merfin.NotifyRaidAutoMarkerConfigChanged = function()
  local config = Merfin.GetRaidAutoMarkerConfig()
  if WeakAuras and WeakAuras.ScanEvents then
    WeakAuras.ScanEvents("MERFIN_RAID_AUTO_MARKER_CONFIG_UPDATED", config)
  end
  return config
end

Merfin.InterruptIcon = "|TInterface\\EncounterJournal\\UI-EJ-Icons.blp:16:16:0:0:255:66:198:214:7:27|t"

Merfin.GetCDTime = function(ID)
  if Merfin.RP.cooldowns[ID] and Merfin.RP.cooldowns[ID].expirationTime then
    return Merfin.RP.cooldowns[ID].expirationTime - GetTime()
  end
  return 0
end

Merfin.SaveCD = function(cooldown)
  if cooldown and cooldown.ID then
    local ID = cooldown.ID
    Merfin.RP.cooldowns[ID] = Merfin.RP.cooldowns[ID] or {}
    Merfin.RP.cooldowns[ID].expirationTime = cooldown.expirationTime
  end
end

Merfin.IsBossModOn = function()
  if C_AddOns.IsAddOnLoaded("BigWigs") then
    return true
  end
end

Merfin.CheckInterrupt = function(checkCooldown)
  for spellID in pairs(interruptSpells) do
    if IsSpellKnown(spellID) then
      return not checkCooldown or GetSpellCooldown(spellID) == 0
    end
  end
end

local npcLookupUnits = { "target", "focus", "mouseover", "boss1", "boss2", "boss3", "boss4", "boss5" }

local function FindUnit(matches)
  for _, unit in ipairs(npcLookupUnits) do
    if matches(unit) then return unit end
  end

  local nameplates = C_NamePlate.GetNamePlates()
  for _, nameplate in ipairs(nameplates) do
    local unit = nameplate.namePlateUnitToken or nameplate.UnitFrame and nameplate.UnitFrame.displayedUnit
    if unit and matches(unit) then return unit end
  end

  local groupType, groupSize
  if IsInRaid() then
    groupType = "raid"
    groupSize = GetNumGroupMembers()
  elseif IsInGroup() then
    groupType = "party"
    groupSize = GetNumSubgroupMembers()
  else
    return
  end

  for i = 1, groupSize do
    local unit = groupType .. i .. "target"
    if matches(unit) then return unit end
  end
end

local function FindUnitByGUID(guid)
  if not guid then return end
  return FindUnit(function(unit)
    return UnitGUID(unit) == guid
  end)
end

local function FindUnitByNpcID(npcID)
  npcID = tonumber(npcID)
  if not npcID then return end

  return FindUnit(function(unit)
    local guid = UnitGUID(unit)
    return guid and Merfin.GetNPCIDFromGUID(guid) == npcID
  end)
end

Merfin.FindUnitByGUID = FindUnitByGUID

Merfin.FindUnitByNpcID = FindUnitByNpcID

Merfin.FindGUIDByNpcID = function(npcID)
  local unit = FindUnitByNpcID(npcID)
  if unit then return UnitGUID(unit) end
end

Merfin.FindTargetByNpcID = function(npcID)
  local unit = FindUnitByNpcID(npcID)
  if not unit then return end

  local targetUnit = unit .. "target"
  if UnitExists(targetUnit) then
    return UnitName(targetUnit), targetUnit
  end
end
