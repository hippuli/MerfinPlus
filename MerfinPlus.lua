local _, MerfinPlus = ...
MerfinPlus = LibStub("AceAddon-3.0"):NewAddon(MerfinPlus, "MerfinPlus", "AceEvent-3.0")
Merfin = Merfin or {}

MerfinPlus.BuildInfo = select(4, GetBuildInfo())
MerfinPlus.internalVersion = 1
MerfinPlus.raidSettingsResetPromptVersion = 1

-- SavedVariables are loaded before addon files. Capture this before AceDB creates
-- the database so fresh installs can silently skip the upgrade prompt.
local hadSavedVariablesAtLoad = type(MerfinPlusSaved) == "table"

MerfinPlus.isVanilla = MerfinPlus.BuildInfo >= 11302 and MerfinPlus.BuildInfo < 20000
MerfinPlus.isTBC = MerfinPlus.BuildInfo >= 20505 and MerfinPlus.BuildInfo < 30000
MerfinPlus.isWrath = MerfinPlus.BuildInfo >= 30400 and MerfinPlus.BuildInfo < 40000
MerfinPlus.isCata = MerfinPlus.BuildInfo >= 40400 and MerfinPlus.BuildInfo < 50000
MerfinPlus.isMoP = MerfinPlus.BuildInfo >= 50500 and MerfinPlus.BuildInfo < 60000
MerfinPlus.isRetail = MerfinPlus.BuildInfo >= 100000

local MERFINPLUS_PREFIX = "|cff00ccffMerfinPlus:|r"

function MerfinPlus.PrettyPrint(text)
  print(MERFINPLUS_PREFIX .. " " .. tostring(text or ""))
end

function MerfinPlus.IsVanilla()
  return MerfinPlus.isVanilla
end

function MerfinPlus.IsTBC()
  return MerfinPlus.isTBC
end

function MerfinPlus.IsWrath()
  return MerfinPlus.isWrath
end

function MerfinPlus.IsCata()
  return MerfinPlus.isCata
end

function MerfinPlus.IsMoP()
  return MerfinPlus.isMoP
end

function MerfinPlus.IsRetail()
  return MerfinPlus.isRetail
end

Merfin.IsVanilla = MerfinPlus.IsVanilla
Merfin.IsTBC = MerfinPlus.IsTBC
Merfin.IsWrath = MerfinPlus.IsWrath
Merfin.IsCata = MerfinPlus.IsCata
Merfin.IsMoP = MerfinPlus.IsMoP
Merfin.IsRetail = MerfinPlus.IsRetail

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
  local isTBC = self.IsTBC and self.IsTBC()
  local isMoP = self.IsMoP and self.IsMoP()

  return {
    mediaOptions = type(self.BuildMediaOptions) == "function",
    wowSimOptions = type(self.BuildWoWSimOptions) == "function",
    raidPackOptions = type(self.BuildRaidPackOptions) == "function",
    export = isTBC
      and type(self.BuildExportOptions) == "function"
      and type(self.InitializeExportTracking) == "function",
    raidAssignments = (isTBC or isMoP) and type(self.InitializeRaidAssignments) == "function",
    assignmentsOptions = (isTBC or isMoP) and type(self.BuildAssignmentsOptions) == "function",
    preBossGroups = isTBC and type(self.InitializePreBossGroups) == "function",
    readyCheck = isTBC
      and type(self.InitializeReadyCheck) == "function"
      and type(self.BuildReadyCheckOptions) == "function",
    raidCooldowns = (isTBC or isMoP)
      and type(self.BuildRaidCooldownTrackerOptions) == "function"
      and type(self.InitializeRaidCooldownTracker) == "function",
    assignmentWidgets = (isTBC or isMoP) and type(self.InitializeAssignmentWidgets) == "function",
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
  self.db = LibStub("AceDB-3.0"):New("MerfinPlusSaved", MerfinPlus.defaults, true)
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
  if not MerfinPlus.IsRetail() then
    MerfinPlus:PullTimerEnable()
    MerfinPlus:LFGEnable()
  end
  if MerfinPlus.IsCata() then
    self:FixFontsOnLogin()
  end
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
