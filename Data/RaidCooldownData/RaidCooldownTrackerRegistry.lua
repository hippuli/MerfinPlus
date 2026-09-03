-- Expansion router and public data/configuration contract for Raid Cooldown frontends.
-- Runtime tracking is implemented by RaidCooldownTracker.lua and exposed here as
-- immutable snapshots so a WeakAura frontend only has to render supplied states.

local _, MerfinPlus = ...

local CONFIG_EVENT = "MERFINPLUS_RAID_COOLDOWNS_CONFIG_CHANGED"
local UPDATE_EVENT = "MERFINPLUS_RAID_COOLDOWNS_UPDATED"
local LEGACY_EVENT = "MERFIN_RAID_CDS"
local registry = {}
local registryOrder = {}

MerfinPlus.RaidCooldownTrackerRegistry = registry
MerfinPlus.RaidCooldownTrackerConfigEvent = CONFIG_EVENT
MerfinPlus.RaidCooldownTrackerUpdateEvent = UPDATE_EVENT

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

local function MergeMissing(target, defaults)
  for key, fallback in pairs(defaults or {}) do
    if target[key] == nil then
      target[key] = CopyValue(fallback)
    elseif type(target[key]) == "table" and type(fallback) == "table" then
      -- Arrays are user-managed collections: deleting an advanced/order entry must persist.
      if fallback[1] == nil then
        MergeMissing(target[key], fallback)
      end
    end
  end
end

local function IsPositiveInteger(value)
  value = tonumber(value)
  return value and value > 0 and value == math.floor(value)
end

local function NormalizeEntryList(entries, includeRoles)
  local normalized = {}
  for _, entry in ipairs(type(entries) == "table" and entries or {}) do
    if type(entry) == "table" and IsPositiveInteger(entry.spellID) then
      local normalizedEntry = {
        spellID = tostring(math.floor(tonumber(entry.spellID))),
        spellName = type(entry.spellName) == "string" and entry.spellName or "",
      }
      if includeRoles then
        normalizedEntry.dps = entry.dps == true
        normalizedEntry.tank = entry.tank == true
        normalizedEntry.healer = entry.healer == true
      else
        normalizedEntry.index = math.max(1, math.floor(tonumber(entry.index) or 1))
      end
      normalized[#normalized + 1] = normalizedEntry
    end
  end
  return normalized
end

local function NormalizeConfig(config, defaults)
  config = type(config) == "table" and config or {}
  MergeMissing(config, defaults or {})
  config.display = type(config.display) == "table" and config.display or {}
  config.features = type(config.features) == "table" and config.features or {}
  config.cds = type(config.cds) == "table" and config.cds or {}
  config.advanced = type(config.advanced) == "table" and config.advanced or {}
  config.ui = type(config.ui) == "table" and config.ui or {}
  config.ui.activationCollapsed = type(config.ui.activationCollapsed) == "table"
    and config.ui.activationCollapsed
    or {}
  config.advanced.display = NormalizeEntryList(config.advanced.display, true)
  config.advanced.order = NormalizeEntryList(config.advanced.order, false)
  return config
end

local function ApplyRequiredCooldowns(config, renderer)
  local requiredCooldowns = renderer and renderer.requiredCooldowns
  if type(config) ~= "table" or type(requiredCooldowns) ~= "table" then
    return
  end

  config.cds = type(config.cds) == "table" and config.cds or {}
  for className, spellIDs in pairs(requiredCooldowns) do
    config.cds[className] = type(config.cds[className]) == "table"
      and config.cds[className]
      or {}
    for _, spellID in ipairs(spellIDs) do
      config.cds[className][tostring(spellID)] = true
    end
  end
end

function MerfinPlus:RegisterRaidCooldownTrackerExpansion(expansionKey, definition)
  if type(expansionKey) ~= "string" or expansionKey == "" or type(definition) ~= "table" then
    error("Invalid Raid Cooldown expansion registration.")
  end
  if registry[expansionKey] then
    error("Raid Cooldown expansion is already registered: " .. expansionKey)
  end
  definition.key = expansionKey
  definition.frontendIDs = definition.frontendIDs or {}
  definition.defaultConfig = definition.defaultConfig or {}
  definition.spellData = definition.spellData or {}
  definition.renderers = definition.renderers or {}
  definition.rendererOrder = definition.rendererOrder or {}
  definition.rendererByFrontendID = definition.rendererByFrontendID or {}
  registry[expansionKey] = definition
  registryOrder[#registryOrder + 1] = expansionKey
end

function MerfinPlus:RegisterRaidCooldownRendererCatalog(
  expansionKey,
  renderers,
  rendererOrder,
  defaultRendererKey
)
  local definition = registry[expansionKey]
  if not definition then
    error("Raid Cooldown expansion must be registered before its renderer catalog.")
  end
  if type(renderers) ~= "table" or type(rendererOrder) ~= "table" then
    error("Invalid Raid Cooldown renderer catalog.")
  end

  definition.renderers = renderers
  definition.rendererOrder = rendererOrder
  definition.defaultRendererKey = defaultRendererKey or rendererOrder[1]
  definition.rendererByFrontendID = {}

  for rendererKey, renderer in pairs(renderers) do
    renderer.key = rendererKey
    renderer.defaultConfig = renderer.defaultConfig or definition.defaultConfig
    renderer.frontendIDs = renderer.frontendIDs or {}
    if renderer.frontendID then
      local found = false
      for _, frontendID in ipairs(renderer.frontendIDs) do
        if frontendID == renderer.frontendID then
          found = true
          break
        end
      end
      if not found then
        table.insert(renderer.frontendIDs, 1, renderer.frontendID)
      end
    end
    for _, frontendID in ipairs(renderer.frontendIDs) do
      definition.frontendIDs[frontendID] = true
      definition.rendererByFrontendID[frontendID] = rendererKey
    end
  end
end

function MerfinPlus:GetRaidCooldownTrackerExpansionKey(frontendID)
  local build = tonumber(self.BuildInfo) or select(4, GetBuildInfo())
  for _, expansionKey in ipairs(registryOrder) do
    local definition = registry[expansionKey]
    local minimum = tonumber(definition.minimumBuild) or 0
    local maximum = tonumber(definition.maximumBuild) or math.huge
    if build >= minimum and build <= maximum then
      if type(frontendID) ~= "string" or frontendID == "" then
        return expansionKey
      end
      return definition.frontendIDs[frontendID] and expansionKey or nil
    end
  end
end

function MerfinPlus:GetRaidCooldownTrackerExpansion(expansionKey)
  expansionKey = expansionKey or self:GetRaidCooldownTrackerExpansionKey()
  return expansionKey and registry[expansionKey] or nil
end

function MerfinPlus:GetRaidCooldownRendererKey(frontendID, expansionKey)
  expansionKey = expansionKey or self:GetRaidCooldownTrackerExpansionKey(frontendID)
  local definition = expansionKey and registry[expansionKey]
  if not definition then
    return nil
  end
  if type(frontendID) == "string" and frontendID ~= "" then
    if definition.renderers[frontendID] then
      return frontendID
    end
    return definition.rendererByFrontendID[frontendID]
  end
  return definition.defaultRendererKey
end

function MerfinPlus:GetRaidCooldownRendererDefinition(rendererKey, expansionKey)
  expansionKey = expansionKey or self:GetRaidCooldownTrackerExpansionKey()
  local definition = expansionKey and registry[expansionKey]
  rendererKey = rendererKey or (definition and definition.defaultRendererKey)
  return definition and rendererKey and definition.renderers[rendererKey] or nil
end

function MerfinPlus:EnsureRaidCooldownTrackerState(expansionKey)
  expansionKey = expansionKey or self:GetRaidCooldownTrackerExpansionKey()
  local definition = expansionKey and registry[expansionKey]
  if not definition or not self.db or not self.db.global then
    return nil, definition
  end

  local root = self.db.global.raidCooldownTracker
  if type(root) ~= "table" then
    root = {}
    self.db.global.raidCooldownTracker = root
  end
  root.schemaVersion = math.max(2, tonumber(root.schemaVersion) or 1)
  root.expansions = type(root.expansions) == "table" and root.expansions or {}

  local state = root.expansions[expansionKey]
  if type(state) ~= "table" then
    state = {}
    root.expansions[expansionKey] = state
  end

  local legacyConfig = state.renderers == nil
    and (state.display or state.features or state.cds or state.advanced)
    and CopyValue(state)
    or nil
  if legacyConfig then
    state = {
      schemaVersion = 2,
      selectedGeneralRenderer = definition.defaultRendererKey,
      renderers = {},
    }
    root.expansions[expansionKey] = state
    state.renderers[definition.defaultRendererKey] = {
      enabled = true,
      config = legacyConfig,
    }
  end

  state.schemaVersion = 2
  state.renderers = type(state.renderers) == "table" and state.renderers or {}

  -- Version 2 enabled one renderer by default. Reset that old implicit
  -- activation once so an update never starts a second RCD backend without
  -- the player explicitly enabling a MerfinPlus frontend.
  local resetLegacyDefaults = state.activationDefaultsVersion == nil

  for _, rendererKey in ipairs(definition.rendererOrder or {}) do
    local renderer = definition.renderers[rendererKey]
    local rendererState = state.renderers[rendererKey]
    if type(rendererState) ~= "table" then
      rendererState = {}
      state.renderers[rendererKey] = rendererState
    end
    if resetLegacyDefaults then
      rendererState.enabled = false
    elseif rendererState.enabled == nil then
      rendererState.enabled = renderer.enabledByDefault == true
    else
      rendererState.enabled = rendererState.enabled == true
    end
    rendererState.config = NormalizeConfig(
      rendererState.config,
      renderer.defaultConfig
    )
    local activationContractVersion = math.max(
      0,
      math.floor(tonumber(renderer.activationContractVersion) or 0)
    )
    if (tonumber(rendererState.activationContractVersion) or 0)
      < activationContractVersion
    then
      ApplyRequiredCooldowns(rendererState.config, renderer)
      rendererState.activationContractVersion = activationContractVersion
    end
  end
  state.activationDefaultsVersion = 2

  if not definition.renderers[state.selectedGeneralRenderer] then
    state.selectedGeneralRenderer = definition.defaultRendererKey
  end
  local activationKey = state.selectedActivationRenderer
  local activationState = activationKey and state.renderers[activationKey]
  if not activationState or activationState.enabled ~= true then
    state.selectedActivationRenderer = nil
  end

  return state, definition
end

function MerfinPlus:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
  local state, definition = self:EnsureRaidCooldownTrackerState(expansionKey)
  rendererKey = rendererKey or (definition and definition.defaultRendererKey)
  local renderer = definition
    and rendererKey
    and definition.renderers[rendererKey]
  local rendererState = state
    and rendererKey
    and state.renderers[rendererKey]
  return rendererState and rendererState.config or nil,
    renderer,
    rendererState,
    state,
    definition
end

function MerfinPlus:EnsureRaidCooldownTrackerConfig(expansionKey)
  local state, definition = self:EnsureRaidCooldownTrackerState(expansionKey)
  local rendererKey = definition and definition.defaultRendererKey
  local rendererState = state and rendererKey and state.renderers[rendererKey]
  return rendererState and rendererState.config or nil, definition
end

function MerfinPlus:GetRaidCooldownTrackerConfig(expansionKey, rendererKey)
  local config
  if rendererKey then
    config = self:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
  else
    config = self:EnsureRaidCooldownTrackerConfig(expansionKey)
  end
  return config and CopyValue(config) or nil
end

function MerfinPlus:GetRaidCooldownRendererConfig(rendererKey, expansionKey)
  local config = self:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
  return config and CopyValue(config) or nil
end

function MerfinPlus:IsRaidCooldownRendererEnabled(rendererKey, expansionKey)
  local _, _, rendererState = self:EnsureRaidCooldownRendererConfig(
    rendererKey,
    expansionKey
  )
  return rendererState and rendererState.enabled == true or false
end

function MerfinPlus:HasEnabledRaidCooldownRenderers(expansionKey)
  local state, definition = self:EnsureRaidCooldownTrackerState(expansionKey)
  if not state or not definition then
    return false
  end
  for _, rendererKey in ipairs(definition.rendererOrder or {}) do
    local rendererState = state.renderers[rendererKey]
    if rendererState and rendererState.enabled == true then
      return true
    end
  end
  return false
end

function MerfinPlus:SetRaidCooldownRendererEnabled(rendererKey, enabled, expansionKey)
  local wasActive = self:HasEnabledRaidCooldownRenderers(expansionKey)
  local _, renderer, rendererState, state = self:EnsureRaidCooldownRendererConfig(
    rendererKey,
    expansionKey
  )
  if not renderer or not rendererState then
    return false
  end
  local wasRendererEnabled = rendererState.enabled == true
  rendererState.enabled = enabled == true
  if not rendererState.enabled and state.selectedActivationRenderer == rendererKey then
    state.selectedActivationRenderer = nil
  end
  local isActive = self:HasEnabledRaidCooldownRenderers(expansionKey)
  if not wasActive and isActive and self.InitializeRaidCooldownTracker then
    self:InitializeRaidCooldownTracker()
  elseif wasActive and not isActive and self.ShutdownRaidCooldownTracker then
    self:ShutdownRaidCooldownTracker()
  end
  if wasRendererEnabled and not rendererState.enabled
    and renderer.frontendID
    and WeakAuras and WeakAuras.ScanEvents
  then
    -- Clear only the disabled frontend once. Its WeakAura removes all cached
    -- clones from this empty, renderer-disabled snapshot.
    WeakAuras.ScanEvents(
      CONFIG_EVENT,
      renderer.frontendID,
      self:GetRaidCooldownTrackerSnapshot(renderer.frontendID),
      "disabled"
    )
  end
  return true
end

function MerfinPlus:GetRaidCooldownRendererValues(enabledOnly, expansionKey)
  local state, definition = self:EnsureRaidCooldownTrackerState(expansionKey)
  local values = {}
  if not state or not definition then
    return values
  end
  for _, rendererKey in ipairs(definition.rendererOrder or {}) do
    local renderer = definition.renderers[rendererKey]
    local rendererState = state.renderers[rendererKey]
    if renderer and rendererState and (not enabledOnly or rendererState.enabled) then
      values[rendererKey] = renderer.auraName or renderer.frontendID or rendererKey
    end
  end
  return values
end

function MerfinPlus:GetRaidCooldownSelectedGeneralRenderer(expansionKey)
  local state = self:EnsureRaidCooldownTrackerState(expansionKey)
  return state and state.selectedGeneralRenderer or nil
end

function MerfinPlus:SetRaidCooldownSelectedGeneralRenderer(rendererKey, expansionKey)
  local state, definition = self:EnsureRaidCooldownTrackerState(expansionKey)
  if not state or not definition or not definition.renderers[rendererKey] then
    return false
  end
  state.selectedGeneralRenderer = rendererKey
  return true
end

function MerfinPlus:GetRaidCooldownSelectedActivationRenderer(expansionKey)
  local state, definition = self:EnsureRaidCooldownTrackerState(expansionKey)
  local rendererKey = state and state.selectedActivationRenderer
  local rendererState = rendererKey and state.renderers[rendererKey]
  if not definition
    or not definition.renderers[rendererKey]
    or not rendererState
    or rendererState.enabled ~= true
  then
    return nil
  end
  return rendererKey
end

function MerfinPlus:SetRaidCooldownSelectedActivationRenderer(rendererKey, expansionKey)
  local state, definition = self:EnsureRaidCooldownTrackerState(expansionKey)
  if rendererKey == nil then
    if state then
      state.selectedActivationRenderer = nil
      return true
    end
    return false
  end
  local rendererState = state and state.renderers[rendererKey]
  if not definition
    or not definition.renderers[rendererKey]
    or not rendererState
    or rendererState.enabled ~= true
  then
    return false
  end
  state.selectedActivationRenderer = rendererKey
  return true
end

function MerfinPlus:GetRaidCooldownTrackerCatalog(expansionKey)
  local definition = self:GetRaidCooldownTrackerExpansion(expansionKey)
  return definition and CopyValue(definition.spellData) or nil
end

function MerfinPlus:GetRaidCooldownTrackerSnapshot(frontendID)
  local expansionKey = self:GetRaidCooldownTrackerExpansionKey(frontendID)
  local definition = expansionKey and registry[expansionKey]
  if not definition then
    return nil
  end
  local rendererKey = self:GetRaidCooldownRendererKey(frontendID, expansionKey)
  local renderer = rendererKey and definition.renderers[rendererKey]
  local supported = renderer ~= nil
  local rendererEnabled = supported
    and self:IsRaidCooldownRendererEnabled(rendererKey, expansionKey)
  local states, revision = {}, 0
  if self.GetRaidCooldownTrackedStates then
    states, revision = self:GetRaidCooldownTrackedStates(frontendID)
  end
  return {
    schemaVersion = 3,
    expansion = expansionKey,
    expansionName = definition.displayName or expansionKey,
    frontendID = frontendID,
    frontendSupported = supported,
    rendererKey = rendererKey,
    rendererName = renderer and renderer.auraName or nil,
    rendererEnabled = rendererEnabled == true,
    configEvent = CONFIG_EVENT,
    updateEvent = UPDATE_EVENT,
    config = supported
      and self:GetRaidCooldownRendererConfig(rendererKey, expansionKey)
      or nil,
    catalog = self:GetRaidCooldownTrackerCatalog(expansionKey),
    states = rendererEnabled and (states or {}) or {},
    revision = tonumber(revision) or 0,
  }
end

function MerfinPlus:DispatchRaidCooldownTrackerSnapshots(eventName, reason, enabledOnly)
  if not (WeakAuras and WeakAuras.ScanEvents) then
    return
  end

  local definition = self:GetRaidCooldownTrackerExpansion()
  if not definition then
    return
  end

  for _, rendererKey in ipairs(definition.rendererOrder or {}) do
    local renderer = definition.renderers and definition.renderers[rendererKey]
    local frontendID = renderer and renderer.frontendID
    if frontendID
      and (not enabledOnly or self:IsRaidCooldownRendererEnabled(rendererKey))
    then
      WeakAuras.ScanEvents(
        eventName,
        frontendID,
        self:GetRaidCooldownTrackerSnapshot(frontendID),
        reason
      )
    end
  end
end

function MerfinPlus:NotifyRaidCooldownTrackerChanged(path)
  if self.RefreshRaidCooldownTrackerConfig then
    self:RefreshRaidCooldownTrackerConfig(path or "config")
  end
  local snapshot = self:GetRaidCooldownTrackerSnapshot()
  if not snapshot then
    return nil
  end
  if self.SendMessage then
    self:SendMessage(CONFIG_EVENT, snapshot, path)
  end
  self:DispatchRaidCooldownTrackerSnapshots(CONFIG_EVENT, path, true)
  if self:HasEnabledRaidCooldownRenderers() and WeakAuras and WeakAuras.ScanEvents then
    WeakAuras.ScanEvents(LEGACY_EVENT, "CONFIG_UPDATED", snapshot.expansion, snapshot, path)
  end
  return snapshot
end

local publicAPI = {
  CONFIG_CHANGED_EVENT = CONFIG_EVENT,
  UPDATED_EVENT = UPDATE_EVENT,
}

function publicAPI.GetCurrentExpansion(frontendID)
  local key = MerfinPlus:GetRaidCooldownTrackerExpansionKey(frontendID)
  local definition = key and registry[key]
  return key, definition and definition.displayName or nil
end

function publicAPI.GetConfig(expansionKey)
  return MerfinPlus:GetRaidCooldownTrackerConfig(expansionKey)
end

function publicAPI.GetRendererConfig(frontendID)
  local expansionKey = MerfinPlus:GetRaidCooldownTrackerExpansionKey(frontendID)
  local rendererKey = MerfinPlus:GetRaidCooldownRendererKey(frontendID, expansionKey)
  return rendererKey
    and MerfinPlus:GetRaidCooldownRendererConfig(rendererKey, expansionKey)
    or nil
end

function publicAPI.GetRenderers(expansionKey)
  local state, definition = MerfinPlus:EnsureRaidCooldownTrackerState(expansionKey)
  local result = {}
  for _, rendererKey in ipairs(definition and definition.rendererOrder or {}) do
    local renderer = definition.renderers[rendererKey]
    local rendererState = state.renderers[rendererKey]
    result[rendererKey] = {
      auraName = renderer.auraName,
      frontendID = renderer.frontendID,
      regionType = renderer.regionType,
      enabled = rendererState and rendererState.enabled == true or false,
    }
  end
  return result
end

function publicAPI.GetCatalog(expansionKey)
  return MerfinPlus:GetRaidCooldownTrackerCatalog(expansionKey)
end

function publicAPI.GetSnapshot(frontendID)
  return MerfinPlus:GetRaidCooldownTrackerSnapshot(frontendID)
end

function publicAPI.GetTrackedStates(frontendID)
  if not MerfinPlus.GetRaidCooldownTrackedStates then
    return {}, 0
  end
  return MerfinPlus:GetRaidCooldownTrackedStates(frontendID)
end

function publicAPI.SupportsFrontend(frontendID)
  local snapshot = MerfinPlus:GetRaidCooldownTrackerSnapshot(frontendID)
  return snapshot and snapshot.frontendSupported == true or false
end

MerfinPlus.RaidCooldowns = publicAPI
Merfin = Merfin or {}
Merfin.RaidCooldowns = publicAPI
