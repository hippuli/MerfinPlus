-- MoP-only renderer catalog derived from the twelve supplied frontend exports.
-- Renderer IDs remain exact so each WeakAura can request only its own config
-- and state subset from the MerfinPlus backend.

local _, MerfinPlus = ...

local EXPANSION_KEY = "MISTS"
local definition = MerfinPlus:GetRaidCooldownTrackerExpansion(EXPANSION_KEY)
if not definition then
  error("Mists Raid Cooldown tracker data must load before its renderer catalog.")
end

local function CopyValue(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}
  if seen[value] then return seen[value] end
  local copy = {}
  seen[value] = copy
  for key, child in pairs(value) do
    copy[CopyValue(key, seen)] = CopyValue(child, seen)
  end
  return copy
end

local function BuildConfig(raidSubGroups, allowlist, order, advancedDisplay)
  local config = CopyValue(definition.defaultConfig)
  config.display.raidSubGroups = raidSubGroups or 5
  config.advanced.order = CopyValue(order or {})
  config.advanced.display = CopyValue(advancedDisplay or {})
  for className, spellIDs in pairs(allowlist or {}) do
    config.cds[className] = config.cds[className] or {}
    for _, spellID in ipairs(spellIDs) do
      if definition.spellData[className]
        and definition.spellData[className][spellID]
      then
        config.cds[className][tostring(spellID)] = true
      end
    end
  end
  return config
end

local commonOrder = {
  { index = 4, spellID = "20484", spellName = "Rebirth" },
  { index = 2, spellID = "31821", spellName = "Devotion Aura" },
  { index = 3, spellID = "64843", spellName = "Divine Hymn" },
}

local partyAllowlist = {
  DEATHKNIGHT = { 42650, 48707, 48792, 51052, 55233, 81164, 108199 },
  DRUID = { 22812, 50334, 61336, 102359, 106898 },
  HUNTER = { 109304 },
  MAGE = { 11958, 108978 },
  MONK = { 115213, 116849 },
  PALADIN = { 498, 642, 1022, 6940, 31821, 31850, 114039 },
  PRIEST = { 724, 6346, 8122, 19236, 33206, 47585, 47788, 62618, 64044, 109964 },
  ROGUE = { 76577 },
  SHAMAN = { 16190, 98008, 108270, 108271, 108273, 108280, 120668 },
  WARLOCK = { 6229, 20707, 103958, 104773, 110913 },
  WARRIOR = { 871, 12975, 97462, 114203, 114207 },
}

local tankSelfAdvanced = {
  { spellID = "48707", spellName = "AMS", dps = false, tank = true, healer = false },
  { spellID = "55233", spellName = "Vampiric Blood", dps = false, tank = true, healer = false },
  { spellID = "48792", spellName = "IBF", dps = false, tank = true, healer = false },
  { spellID = "871", spellName = "Shield Wall", dps = false, tank = true, healer = false },
  { spellID = "12975", spellName = "Last Stand", dps = false, tank = true, healer = false },
  { spellID = "31850", spellName = "Ardent", dps = false, tank = true, healer = false },
  { spellID = "102342", spellName = "Ironbark", dps = false, tank = true, healer = false },
  { spellID = "61336", spellName = "Survival Instincts", dps = false, tank = true, healer = false },
  { spellID = "22812", spellName = "Barkskin", dps = false, tank = true, healer = false },
  { spellID = "115203", spellName = "Fortifying Brew", dps = false, tank = true, healer = false },
  { spellID = "115176", spellName = "Zen Meditation", dps = false, tank = true, healer = false },
}

local renderers = {
  merfin_icon = {
    auraName = "[Merfin] RCD - Icon",
    frontendID = "[Merfin] RCD - Icon",
    frontendIDs = { "[Merfin] RCD - Icon", "7FiQVMQO(LA" },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildConfig(5, {}, commonOrder),
  },
  merfin_bar = {
    auraName = "[Merfin] Raid Cooldowns - Bar",
    frontendID = "[Merfin] Raid Cooldowns - Bar",
    frontendIDs = { "[Merfin] Raid Cooldowns - Bar", "LpSslr3mV1I" },
    regionType = "aurabar",
    enabledByDefault = false,
    defaultConfig = BuildConfig(5, {}, commonOrder),
  },
  banner_icon = {
    auraName = "[RCD] Banner [Icon]",
    frontendID = "[RCD] Banner [Icon]",
    frontendIDs = { "[RCD] Banner [Icon]", "QRLGmT130mj" },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildConfig(5, { WARRIOR = { 114207 } }),
  },
  stormlash_icon = {
    auraName = "[RCD] Stormlash Totem [Icon]",
    frontendID = "[RCD] Stormlash Totem [Icon]",
    frontendIDs = { "[RCD] Stormlash Totem [Icon]", "wClMrjFU17r" },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildConfig(5, { SHAMAN = { 120668 } }),
  },
  party_vertical = {
    auraName = "[RCD] Party Tracker V [Icon]",
    frontendID = "[RCD] Party Tracker V [Icon]",
    frontendIDs = { "[RCD] Party Tracker V [Icon]", "ZdxRrBSFkvI" },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildConfig(5, partyAllowlist, {
      { index = 3, spellID = "64843", spellName = "Divine Hymn" },
    }),
  },
  party_horizontal = {
    auraName = "[RCD] Party Tracker H [Icon]",
    frontendID = "[RCD] Party Tracker H [Icon]",
    frontendIDs = { "[RCD] Party Tracker H [Icon]", "zz)mVmITzTb" },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildConfig(5, partyAllowlist, {
      { index = 3, spellID = "64843", spellName = "Divine Hymn" },
    }),
  },
  mass_defensives_bar = {
    auraName = "[RCD] Mass Defensives [Bar]",
    frontendID = "[RCD] Mass Defensives [Bar]",
    frontendIDs = { "[RCD] Mass Defensives [Bar]", "6znRm7zTNX)" },
    regionType = "aurabar",
    enabledByDefault = false,
    defaultConfig = BuildConfig(7, {
      MONK = { 115213 }, PALADIN = { 31821 }, PRIEST = { 62618 },
      ROGUE = { 76577 }, SHAMAN = { 98008 }, WARRIOR = { 97462 },
    }),
  },
  party_interrupts = {
    auraName = "[RCD] Party Interrupts [Bars]",
    frontendID = "[RCD] Party Interrupts [Bars]",
    frontendIDs = { "[RCD] Party Interrupts [Bars]", "w7CpVzi5FY7" },
    regionType = "aurabar",
    enabledByDefault = false,
    defaultConfig = BuildConfig(7, {
      DEATHKNIGHT = { 47528 }, DRUID = { 78675, 106839 },
      HUNTER = { 147362 }, MAGE = { 2139 }, PALADIN = { 96231 },
      PRIEST = { 15487 }, ROGUE = { 1766 }, SHAMAN = { 57994 },
    }),
  },
  external_defensives = {
    auraName = "[RCD] External Defensives [Bar]",
    frontendID = "[RCD] External Defensives [Bar]",
    frontendIDs = { "[RCD] External Defensives [Bar]", "uHKvzHgY9uM" },
    regionType = "aurabar",
    enabledByDefault = false,
    defaultConfig = BuildConfig(7, {
      DRUID = { 102342 }, MONK = { 116849 },
      PALADIN = { 6940 }, PRIEST = { 33206 },
    }),
  },
  mana = {
    auraName = "[RCD] Mana [Bar]",
    frontendID = "[RCD] Mana [Bar]",
    frontendIDs = { "[RCD] Mana [Bar]", "sgHyT8Rs1iV" },
    regionType = "aurabar",
    enabledByDefault = false,
    defaultConfig = BuildConfig(7, {
      PRIEST = { 64901 }, SHAMAN = { 16190 },
    }),
  },
  tank_self = {
    auraName = "[RCD] Tank-Self Defensives [Bar]",
    frontendID = "[RCD] Tank-Self Defensives [Bar]",
    frontendIDs = { "[RCD] Tank-Self Defensives [Bar]", "(Sqkqz)yuPl" },
    regionType = "aurabar",
    enabledByDefault = false,
    defaultConfig = BuildConfig(8, {
      DEATHKNIGHT = { 48707, 48792, 55233 },
      DRUID = { 22812, 61336, 102342 },
      MONK = { 115203, 115213 },
      PALADIN = { 31850 },
      WARRIOR = { 871, 12975 },
    }, nil, tankSelfAdvanced),
  },
  mass_defensives_icon = {
    auraName = "[RCD] Mass Defensives Icon",
    frontendID = "[RCD] Mass Defensives Icon",
    frontendIDs = { "[RCD] Mass Defensives Icon", "YlNJmhaqd3r" },
    regionType = "icon",
    enabledByDefault = false,
    defaultConfig = BuildConfig(7, {
      DEATHKNIGHT = { 51052 }, MONK = { 115213 },
      PALADIN = { 31821 }, PRIEST = { 62618 }, ROGUE = { 76577 },
      SHAMAN = { 98008 }, WARRIOR = { 97462 },
    }),
  },
}

local rendererOrder = {
  "merfin_icon",
  "merfin_bar",
  "banner_icon",
  "stormlash_icon",
  "party_vertical",
  "party_horizontal",
  "mass_defensives_bar",
  "party_interrupts",
  "external_defensives",
  "mana",
  "tank_self",
  "mass_defensives_icon",
}

MerfinPlus:RegisterRaidCooldownRendererCatalog(
  EXPANSION_KEY,
  renderers,
  rendererOrder,
  "merfin_bar"
)
