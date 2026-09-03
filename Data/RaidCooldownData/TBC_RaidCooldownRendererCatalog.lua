-- TBC-only Raid Cooldown renderer catalog.
-- Preset defaults are derived from the ten user-supplied renderer exports.
-- MerfinPlus owns tracking/configuration; WeakAuras remain renderer-only.

local _, MerfinPlus = ...

local EXPANSION_KEY = "TBC"
local definition = MerfinPlus:GetRaidCooldownTrackerExpansion(EXPANSION_KEY)
if not definition then
  error("TBC Raid Cooldown tracker data must load before its renderer catalog.")
end

local function CopyValue(value, seen)
  if type(value) ~= "table" then
    return value
  end
  seen = seen or {}
  if seen[value] then
    return seen[value]
  end
  local copy = {}
  seen[value] = copy
  for key, child in pairs(value) do
    copy[CopyValue(key, seen)] = CopyValue(child, seen)
  end
  return copy
end

local function BuildBaseConfig(raidSubGroups, allCooldownsEnabled)
  local config = CopyValue(definition.defaultConfig)
  config.display = config.display or {}
  config.display.showMyself = true
  config.display.showReady = true
  config.display.showDead = true
  config.display.showOffline = true
  config.display.showBuff = true
  config.display.showReadySymbol = true
  config.display.colorDead = { 1, 0, 0, 1 }
  config.display.raidSubGroups = raidSubGroups
  config.features = config.features or {}
  config.features.clickMsg = true
  config.ui = config.ui or {}
  config.ui.activationCollapsed = {}

  local sourceCooldowns = config.cds or {}
  config.cds = {}
  for className, spellCatalog in pairs(definition.spellData or {}) do
    config.cds[className] = {}
    for spellID in pairs(spellCatalog) do
      local stringID = tostring(spellID)
      local configured = sourceCooldowns[className]
        and (
          sourceCooldowns[className][stringID]
          or sourceCooldowns[className][spellID]
        )
      if allCooldownsEnabled ~= nil then
        config.cds[className][stringID] = allCooldownsEnabled == true
      else
        config.cds[className][stringID] = configured == true
      end
    end
  end
  return config
end

local function BuildFilteredConfig(allowlist)
  local config = BuildBaseConfig(5, false)
  for className, spellIDs in pairs(allowlist or {}) do
    config.cds[className] = config.cds[className] or {}
    for _, spellID in ipairs(spellIDs) do
      config.cds[className][tostring(spellID)] = true
    end
  end
  return config
end

local TBC_TAUNTS = {
  DRUID = { 5209, 6795 },
  PALADIN = { 31789 },
  WARRIOR = { 1161, 25266, 355 },
}

local function EnableCooldowns(config, allowlist)
  for className, spellIDs in pairs(allowlist or {}) do
    config.cds[className] = config.cds[className] or {}
    for _, spellID in ipairs(spellIDs) do
      config.cds[className][tostring(spellID)] = true
    end
  end
  return config
end

local function RequireTaunts(renderer)
  renderer.requiredCooldowns = TBC_TAUNTS
  -- Versioned so existing saved renderer configs receive the same canonical
  -- TBC taunt coverage once without preventing later per-spell user changes.
  renderer.activationContractVersion = 1
  return renderer
end

local function BuildClassBarPresentation()
  return {
    barColorMode = "class",
  }
end

local renderers = {
  threat = {
    auraName = "[Merfin] RCD: Threat",
    frontendID = "[Merfin] RCD: Threat ",
    frontendIDs = {
      "[Merfin] RCD: Threat ",
      "[Merfin] RCD: Threat",
    },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildFilteredConfig({
      HUNTER = { 34477 },
    }),
  },
  taunts = RequireTaunts({
    auraName = "[Merfin] RCD: Taunts",
    frontendID = "[Merfin] RCD: Taunts ",
    frontendIDs = {
      "[Merfin] RCD: Taunts ",
      "[Merfin] RCD: Taunts",
    },
    regionType = "aurabar",
    presentation = BuildClassBarPresentation(),
    enabledByDefault = false,
    defaultConfig = BuildFilteredConfig(TBC_TAUNTS),
  }),
  mass_defensives = {
    auraName = "[Merfin] RCD: Mass Defensives",
    frontendID = "[Merfin] RCD: Mass Defensives ",
    frontendIDs = {
      "[Merfin] RCD: Mass Defensives ",
      "[Merfin] RCD: Mass Defensives",
    },
    regionType = "aurabar",
    presentation = BuildClassBarPresentation(),
    enabledByDefault = false,
    defaultConfig = BuildFilteredConfig({
      DRUID = { 22812, 22896 },
      PALADIN = { 5573 },
      WARRIOR = { 12975, 871 },
    }),
  },
  mana = {
    auraName = "[Merfin] RCD: Mana",
    frontendID = "[Merfin] RCD: Mana ",
    frontendIDs = {
      "[Merfin] RCD: Mana ",
      "[Merfin] RCD: Mana",
    },
    regionType = "aurabar",
    presentation = BuildClassBarPresentation(),
    enabledByDefault = false,
    defaultConfig = BuildFilteredConfig({
      DRUID = { 29166 },
      PRIEST = { 32548 },
      SHAMAN = { 16190 },
    }),
  },
  external_defensives = {
    auraName = "[Merfin] RCD: External Defensives",
    frontendID = "[Merfin] RCD: External Defensives ",
    frontendIDs = {
      "[Merfin] RCD: External Defensives ",
      "[Merfin] RCD: External Defensives",
    },
    regionType = "aurabar",
    presentation = BuildClassBarPresentation(),
    enabledByDefault = false,
    defaultConfig = BuildFilteredConfig({
      PALADIN = { 20729 },
      PRIEST = { 33206 },
      WARRIOR = { 3411 },
    }),
  },
  crowd_control = {
    auraName = "[Merfin] RCD: Crowd Control",
    frontendID = "[Merfin] RCD: Crowd Control ",
    frontendIDs = {
      "[Merfin] RCD: Crowd Control ",
      "[Merfin] RCD: Crowd Control",
    },
    regionType = "aurabar",
    presentation = BuildClassBarPresentation(),
    enabledByDefault = false,
    defaultConfig = BuildFilteredConfig({
      DRUID = { 20549, 8983 },
      -- The legacy frontend stored Intimidation's aura ID (24394). The
      -- tracker catalog and cast event use the actual TBC spell ID (19577).
      HUNTER = { 19503, 19577, 20549, 27068, 28730 },
      MAGE = { 2139, 28730 },
      PALADIN = { 10308, 20066, 28730 },
      PRIEST = { 15487, 28730 },
      ROGUE = { 2094, 38764, 38768, 8643 },
      SHAMAN = { 20549, 25454 },
      WARLOCK = { 19647, 27223, 28730 },
      WARRIOR = { 12809, 20549, 25266, 29704, 6554 },
    }),
  },
  party_icons = RequireTaunts({
    auraName = "[Merfin] RCD [Party Icons]",
    frontendID = "[Merfin] RCD [Icons Party] ",
    frontendIDs = {
      "[Merfin] RCD [Icons Party] ",
      "[Merfin] RCD [Icons Party]",
    },
    regionType = "icon",
    enabledByDefault = false,
    -- The supplied Party Icons export originally had every cooldown off. The
    -- local TBC contract now enables only the six canonical taunts by default.
    defaultConfig = BuildFilteredConfig(TBC_TAUNTS),
  }),
  icons = RequireTaunts({
    auraName = "[Merfin] RCD [Icons]",
    frontendID = "[Merfin] RCD [Icons] ",
    frontendIDs = {
      "[Merfin] RCD [Icons] ",
      "[Merfin] RCD [Icons]",
    },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildBaseConfig(8, true),
  }),
  bars_dark = RequireTaunts({
    auraName = "[Merfin] RCD [Bars] (Dark Theme)",
    frontendID = "[Merfin] RCD [Bars] (Dark Theme) ",
    frontendIDs = {
      "[Merfin] RCD [Bars] (Dark Theme) ",
      "[Merfin] RCD [Bars] (Dark Theme)",
    },
    regionType = "aurabar",
    presentation = {
      barColorMode = "fixed",
      barColor = {
        0.21960785984993,
        0.21960785984993,
        0.21960785984993,
        1,
      },
      sourceNameColorMode = "class",
      sourceNameSubRegions = { 6, 7 },
    },
    enabledByDefault = false,
    defaultConfig = BuildBaseConfig(8, true),
  }),
  bars = RequireTaunts({
    auraName = "[Merfin] RCD [Bars]",
    frontendID = "[Merfin] RCD [Bars] ",
    frontendIDs = {
      "[Merfin] RCD [Bars] ",
      "[Merfin] RCD [Bars]",
    },
    regionType = "aurabar",
    presentation = BuildClassBarPresentation(),
    enabledByDefault = false,
    -- Preserve the already working Bars behavior and official local defaults.
    defaultConfig = EnableCooldowns(BuildBaseConfig(5, nil), TBC_TAUNTS),
  }),
}

local rendererOrder = {
  "threat",
  "taunts",
  "mass_defensives",
  "mana",
  "external_defensives",
  "crowd_control",
  "party_icons",
  "icons",
  "bars_dark",
  "bars",
}

MerfinPlus:RegisterRaidCooldownRendererCatalog(
  EXPANSION_KEY,
  renderers,
  rendererOrder,
  "bars"
)
