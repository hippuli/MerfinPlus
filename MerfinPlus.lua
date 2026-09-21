local _, MerfinPlus = ...
local aceAddon = LibStub("AceAddon-3.0")
MerfinPlus = aceAddon:NewAddon(MerfinPlus, "MerfinPlus", "AceEvent-3.0")
Merfin = Merfin or {}

MerfinPlus.IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
MerfinPlus.GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
MerfinPlus.EnableAddOn = C_AddOns and C_AddOns.EnableAddOn or EnableAddOn
MerfinPlus.DisableAddOn = C_AddOns and C_AddOns.DisableAddOn or DisableAddOn

Merfin.IsAddOnLoaded = MerfinPlus.IsAddOnLoaded
Merfin.GetAddOnMetadata = MerfinPlus.GetAddOnMetadata
Merfin.EnableAddOn = MerfinPlus.EnableAddOn
Merfin.DisableAddOn = MerfinPlus.DisableAddOn

MerfinPlus.BuildInfo = select(4, GetBuildInfo())
MerfinPlus.internalVersion = 1
MerfinPlus.raidSettingsResetPromptVersion = 1

MerfinPlus.Libs = {
  AceAddon = aceAddon,
  AceConfig = LibStub("AceConfig-3.0"),
  AceConfigDialog = LibStub("AceConfigDialog-3.0"),
  AceConfigRegistry = LibStub("AceConfigRegistry-3.0"),
  AceConsole = LibStub("AceConsole-3.0"),
  AceDB = LibStub("AceDB-3.0"),
  AceDBOptions = LibStub("AceDBOptions-3.0"),
  AceEvent = LibStub("AceEvent-3.0"),
  AceGUI = LibStub("AceGUI-3.0"),
  AceSerializer = LibStub("AceSerializer-3.0"),
  LDB = LibStub("LibDataBroker-1.1"),
  DBIcon = LibStub("LibDBIcon-1.0"),
  LSM = LibStub("LibSharedMedia-3.0"),
  LibDeflate = LibStub("LibDeflate", true),
}

function MerfinPlus:GetLibrary(name, silent)
  local library = self.Libs[name]
  if not library and not silent then
    error("[MerfinPlus] Unknown library alias: " .. tostring(name), 2)
  end
  return library
end

-- Public plugin host. Options are part of each plugin definition, so lifecycle
-- and navigation always share one registry.
MerfinPlus._plugins = {}
MerfinPlus._pluginOrder = {}

local pluginMixin = {}

function pluginMixin:GetName()
  return self.id
end

function pluginMixin:GetDB()
  return self.db
end

function pluginMixin:GetLibrary(name, silent)
  return self.host:GetLibrary(name, silent)
end

function pluginMixin:IsEnabled()
  return self._isEnabled == true
end

function pluginMixin:GetEnabledState()
  return self._enabledState == true
end

function pluginMixin:SetEnabledState(enabled)
  self._enabledState = enabled == true
end

function pluginMixin:Enable()
  self._enabledState = true
  if self.host._pluginHostInitialized then self.host:_InitializePlugin(self) end
  if self.host._pluginHostEnabled then return self.host:_EnablePlugin(self) end
  return true
end

function pluginMixin:Disable()
  self._enabledState = false
  return self.host:_DisablePlugin(self)
end

function pluginMixin:OpenOptions(sub)
  return self.host:OpenOptionsPlugin(self.id, sub)
end

function MerfinPlus:_CallPlugin(plugin, callback)
  local func = plugin.definition[callback] or plugin["On" .. callback]
  if not func then return true end
  local succeeded, reason = pcall(func, plugin)
  if not succeeded then
    self.PrettyPrint("Plugin " .. plugin.id .. " " .. callback .. " failed: " .. tostring(reason))
  end
  return succeeded, reason
end

function MerfinPlus:_EmbedPluginLibraries(plugin, embeds)
  for _, name in ipairs(embeds or {}) do
    local library = self:GetLibrary(name, true)
    if not library then return false, "unknown plugin library alias: " .. name end
    if type(library.Embed) ~= "function" then return false, "plugin library cannot be embedded: " .. name end
    library:Embed(plugin)
  end
  return true
end

function MerfinPlus:_PreparePluginDB(plugin)
  if plugin.db or not self.db then return plugin.db ~= nil end
  local namespace = "Plugin_" .. plugin.id
  plugin.db = self.db:GetNamespace(namespace, true)
  if plugin.db then
    if plugin.definition.defaults then plugin.db:RegisterDefaults(plugin.definition.defaults) end
  else
    plugin.db = self.db:RegisterNamespace(namespace, plugin.definition.defaults)
  end
  return true
end

function MerfinPlus:_InitializePlugin(plugin)
  if plugin._initialized then return true end
  if not self:_PreparePluginDB(plugin) then return false, "plugin database is not ready" end
  local initialized, reason = self:_CallPlugin(plugin, "Initialize")
  if initialized then plugin._initialized = true end
  return initialized, reason
end

function MerfinPlus:_EnablePlugin(plugin)
  if plugin._isEnabled or not plugin._enabledState then return true end
  local initialized, reason = self:_InitializePlugin(plugin)
  if not initialized then return false, reason end
  local enabled
  enabled, reason = self:_CallPlugin(plugin, "Enable")
  if enabled then plugin._isEnabled = true end
  return enabled, reason
end

function MerfinPlus:_DisablePlugin(plugin)
  if not plugin._isEnabled then return true end
  local disabled, reason = self:_CallPlugin(plugin, "Disable")
  plugin._isEnabled = false
  return disabled, reason
end

function MerfinPlus:_InitializePlugins()
  for _, plugin in ipairs(self._pluginOrder) do
    self:_InitializePlugin(plugin)
  end
end

function MerfinPlus:_EnablePlugins()
  for _, plugin in ipairs(self._pluginOrder) do
    self:_EnablePlugin(plugin)
  end
end

function MerfinPlus:_DisablePlugins()
  for index = #self._pluginOrder, 1, -1 do
    self:_DisablePlugin(self._pluginOrder[index])
  end
end

function MerfinPlus:GetPlugin(id, silent)
  local plugin = self._plugins[id]
  if not plugin and not silent then
    error("[MerfinPlus] Plugin is not registered: " .. tostring(id), 2)
  end
  return plugin
end

function MerfinPlus:RegisterPlugin(id, definition)
  assert(type(id) == "string" and id ~= "", "Plugin name is required")
  assert(type(definition) == "table", "Plugin definition must be a table")
  local reason

  local plugin = self._plugins[id]
  local previous = plugin and plugin.definition
  local previousEnabled = plugin and plugin._enabledState
  if plugin then
    if definition.object and definition.object ~= plugin then
      return nil, "a registered plugin object cannot be replaced"
    end
    plugin.definition = definition
    if definition.enabled ~= nil then plugin._enabledState = definition.enabled end
    if plugin.db and definition.defaults then plugin.db:RegisterDefaults(definition.defaults) end
  else
    plugin = definition.object or {}
    if plugin.host and plugin.host ~= self then return nil, "plugin object already belongs to another host" end
    for name, method in pairs(pluginMixin) do
      if plugin[name] == nil then plugin[name] = method end
    end
    plugin.id = id
    plugin.host = self
    plugin.Libs = self.Libs
    plugin.definition = definition
    plugin._enabledState = definition.enabled ~= false
    local embedded, embedReason = self:_EmbedPluginLibraries(plugin, definition.embeds)
    if not embedded then return nil, embedReason end
    self._plugins[id] = plugin
    table.insert(self._pluginOrder, plugin)
  end

  if self._pluginHostInitialized then
    local initialized
    initialized, reason = self:_InitializePlugin(plugin)
    if not initialized then return nil, reason end
  end

  if self.OnOptionsPluginChanged then
    local registered, optionsReason = self:OnOptionsPluginChanged(id, plugin)
    if registered == false then
      if previous then
        plugin.definition = previous
        plugin._enabledState = previousEnabled
        self:OnOptionsPluginChanged(id, plugin)
      else
        self._plugins[id] = nil
        for index = #self._pluginOrder, 1, -1 do
          if self._pluginOrder[index] == plugin then
            table.remove(self._pluginOrder, index)
            break
          end
        end
      end
      return nil, optionsReason
    end
  end

  if self._pluginHostEnabled then
    if plugin._enabledState then self:_EnablePlugin(plugin) else self:_DisablePlugin(plugin) end
  end
  return plugin
end

function MerfinPlus:RegisterOptionsPlugin(id, definition)
  assert(type(definition) == "table" and definition.options, "Plugin options are required")
  local reason

  local existing = self._plugins[id]
  if existing then
    local merged = {}
    for key, value in pairs(existing.definition) do merged[key] = value end
    for key, value in pairs(definition) do merged[key] = value end
    definition = merged
  end

  local plugin
  plugin, reason = self:RegisterPlugin(id, definition)
  if not plugin then return false, reason end
  return true, plugin
end

function MerfinPlus:OpenOptionsPlugin(id, sub)
  local plugin = type(id) == "string" and self._plugins[id]
  if not plugin or not plugin.definition.options then
    return false, "options plugin is not registered"
  end
  if self.OpenRegisteredOptionsPlugin then
    return self:OpenRegisteredOptionsPlugin(id, sub)
  end
  self.pendingOptionsPluginOpen = { id = id, sub = sub }
  return true
end

-- SavedVariables are loaded before addon files. Capture this before AceDB creates
-- the database so fresh installs can silently skip the upgrade prompt.
local hadSavedVariablesAtLoad = type(MerfinPlusSaved) == "table"

local MERFINPLUS_PREFIX = "|cff00ccffMerfinPlus:|r"

function MerfinPlus.PrettyPrint(text)
  print(MERFINPLUS_PREFIX .. " " .. tostring(text or ""))
end

function Merfin.IsForever()
  return MerfinPlus.BuildInfo >= 16000 and MerfinPlus.BuildInfo <= 19999
end

function Merfin.IsClassic()
  return not Merfin.IsForever() and WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

function Merfin.IsTBC()
  return WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

function Merfin.IsTitan()
  return MerfinPlus.BuildInfo >= 38000 and MerfinPlus.BuildInfo <= 39999
end

function Merfin.IsWrath()
  return not Merfin.IsTitan() and WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
end

function Merfin.IsCata()
  return WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
end

function Merfin.IsMists()
  return WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
end

function Merfin.IsRetail()
  return not Merfin.IsForever() and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

function Merfin.IsRetailOrForever()
  return Merfin.IsRetail() or Merfin.IsForever()
end


Merfin.GetGhostActionButton = function(slot)
  slot = tonumber(slot)

  if not slot then
    return nil
  end

  local button = _G["ElvUI_Bar1Button" .. slot]

  if button then
    return button
  end

  button = _G["BT4PetButton" .. slot]

  if button then
    return button
  end

  button = _G["DominosPetActionButton" .. slot]

  if button then
    return button
  end

  if type(HasOverrideActionBar) == "function" and HasOverrideActionBar() then
    button = _G["OverrideActionBarButton" .. slot]

    if button then
      return button
    end
  end

  if type(HasVehicleActionBar) == "function" and HasVehicleActionBar() then
    button = _G["VehicleMenuBarActionButton" .. slot]

    if button then
      return button
    end
  end

  button = _G["PetActionButton" .. slot]

  if button then
    return button
  end

  button = _G["OverrideActionBarButton" .. slot]

  if button then
    return button
  end

  button = _G["VehicleMenuBarActionButton" .. slot]

  if button then
    return button
  end

  button = _G["PossessButton" .. slot]

  if button then
    return button
  end

  return nil
end

-- Resolve optional feature availability after every file in the active TOC has
-- loaded. Build checks keep expansion-specific modules isolated; method checks
-- make shared initialization/options safe when a builder is intentionally absent.
function MerfinPlus:GetCapabilities()

  return {
    mediaOptions = type(self.BuildMediaOptions) == "function",
    wowSimOptions = type(self.BuildWoWSimOptions) == "function",
    raidPackOptions = type(self.BuildRaidPackOptions) == "function",
    export = (Merfin.IsTBC() or Merfin.IsMists())
      and type(self.BuildExportOptions) == "function"
      and type(self.InitializeExportTracking) == "function",
    raidAssignments = (Merfin.IsTBC() or Merfin.IsMists()) and type(self.InitializeRaidAssignments) == "function",
    assignmentsOptions = (Merfin.IsTBC() or Merfin.IsMists()) and type(self.BuildAssignmentsOptions) == "function",
    preBossGroups = Merfin.IsTBC() and type(self.InitializePreBossGroups) == "function",
    readyCheck = Merfin.IsTBC()
      and type(self.InitializeReadyCheck) == "function"
      and type(self.BuildReadyCheckOptions) == "function",
    raidCooldowns = (Merfin.IsTBC() or Merfin.IsMists())
      and type(self.BuildRaidCooldownTrackerOptions) == "function"
      and type(self.InitializeRaidCooldownTracker) == "function",
    assignmentWidgets = (Merfin.IsTBC() or Merfin.IsMists()) and type(self.InitializeAssignmentWidgets) == "function",
    minimapButton = type(self.InitializeMinimapButton) == "function",
    mainSettings = type(self.GetMinimapButtonVisibleSetting) == "function"
      and type(self.SetMinimapButtonVisibleSetting) == "function"
      and type(self.UpdateMinimapButtonVisibility) == "function",
    uiLocalization = type(self.T) == "function"
      and type(self.LocalizeOptionTree) == "function",
    localizedProfiles = type(self.CreateLocalizedProfilesOptions) == "function",
    localizationValidation = type(self.ValidateLocalizedOptionsTrees) == "function"
      and type(self.StripOptionLocalizationMetadata) == "function",
  }
end

function MerfinPlus:OnInitialize()
  self.db = self.Libs.AceDB:New("MerfinPlusSaved", MerfinPlus.defaults, true)
  if self.ApplyUITheme then self:ApplyUITheme(self.db.global.uiTheme) end
  local capabilities = self:GetCapabilities()
  self:ModernizeSavedVariables()
  if capabilities.uiLocalization and self.NormalizeUILocaleSettings then
    self:NormalizeUILocaleSettings()
  end
  if capabilities.raidPackOptions and self.NormalizeRaidPackLocaleSettings then
    self:NormalizeRaidPackLocaleSettings()
  end
  self:RegisterCustomFonts()
  self:RegisterCustomBars()
  self:RegisterMediaAliasesFromCallback()
  self:RegisterFonts()
  self:RegisterBars()
  if capabilities.export then
    self:InitializeExportTracking()
  end
  if capabilities.raidAssignments then
    self:InitializeRaidAssignments()
  end
  if capabilities.preBossGroups then
    self:InitializePreBossGroups()
  end
  if capabilities.readyCheck then
    self:InitializeReadyCheck()
  end
  if capabilities.raidCooldowns then
    self:InitializeRaidCooldownTracker()
  end
  self._pluginHostInitialized = true
  self:_InitializePlugins()
  self:SetupOptions()
  if self.InitializeRaidSettingsResetPrompt then
    self:InitializeRaidSettingsResetPrompt(hadSavedVariablesAtLoad)
  end
  if capabilities.minimapButton then
    self:InitializeMinimapButton()
  end
  if capabilities.assignmentWidgets then
    self:InitializeAssignmentWidgets()
  end
  self:RegisterSoundPaths()
  if not Merfin.IsRetailOrForever() then
    MerfinPlus:PullTimerEnable()
    MerfinPlus:LFGEnable()
  end
  if Merfin.IsCata() then
    self:FixFontsOnLogin()
  end
end

function MerfinPlus:OnEnable()
  self._pluginHostEnabled = true
  self:_EnablePlugins()
end

function MerfinPlus:OnDisable()
  self.pendingOptionsOpen = nil
  if self.optionsStandaloneFrame then
    self.optionsStandaloneFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self.optionsStandaloneFrame:Hide()
  end
  self._pluginHostEnabled = false
  self:_DisablePlugins()
end

function MerfinPlus:GetDB()
  if not self.db then
    error("[MerfinPlus] Database is not initialized yet!")
  end
  return self.db.profile
end

Merfin.L = GetLocale()
Merfin.ForcedSoundLoc = false

local supportedLoc = {
  ["ruRU"] = true,
  ["enUS"] = true,
  ["zhCN"] = true,
}

Merfin.GetLocale = function()
  if Merfin.ForcedSoundLoc then
    return Merfin.ForcedSoundLoc
  elseif not supportedLoc[Merfin.L] then
    return "enUS"
  else
    return Merfin.L
  end
end
