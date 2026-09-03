-- Raid auto-marker options ported from the post-2.76 main branch.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
-- Auto-Marker options are rebuilt after a runtime locale change; resolve every
-- standard label from the active UI locale instead of the startup locale.
local L = setmetatable({}, {
  __index = function(_, key)
    return MerfinPlus:T(key)
  end,
})
local AceSerializer = LibStub("AceSerializer-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local AUTO_MARKER_INFO = "This module works together with the %s WeakAura included in Merfin's raid packs. The raid packs are freely available and can be downloaded using the public links at %s."
local function AutoMarkerInfoText()
  local bodyColor = "|cffc8c8c8"
  local accentColor = MerfinPlus:GetUIThemeColorEscape("accent")
  return bodyColor .. string.format(
    L[AUTO_MARKER_INFO],
    accentColor .. "Auto-Marker|r" .. bodyColor,
    accentColor .. "discord.gg/merfin|r" .. bodyColor
  ) .. "|r"
end

MerfinPlus.AutoMarkerDefaults = MerfinPlus.AutoMarkerDefaults or {}
MerfinPlus.AutoMarkerDefaults.mouseover = MerfinPlus.AutoMarkerDefaults.mouseover or 4
if MerfinPlus.AutoMarkerDefaults.nameplates == nil then MerfinPlus.AutoMarkerDefaults.nameplates = false end
if MerfinPlus.AutoMarkerDefaults.enemyEnabled == nil then MerfinPlus.AutoMarkerDefaults.enemyEnabled = true end
if MerfinPlus.AutoMarkerDefaults.friendlyEnabled == nil then MerfinPlus.AutoMarkerDefaults.friendlyEnabled = true end
MerfinPlus.AutoMarkerDefaults.instances = MerfinPlus.AutoMarkerDefaults.instances or {}
MerfinPlus.AutoMarkerDefaults.mechanics = MerfinPlus.AutoMarkerDefaults.mechanics or {
  icebolt = { enable = true, marks = { 8 } },
  sleep = { enable = true, marks = { 1, 2, 3 } },
  azgalorDoom = { enable = true, marks = { 8 } },
  archimondeAirBurst = { enable = true, marks = { 8 } },
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
    key = "icebolt", name = "Icebolt", spellID = 31249,
    raid = "IID534", raidName = "Hyjal Summit", boss = "618", bossName = "Rage Winterchill",
    maxMarks = 1,
  },
  {
    key = "sleep", name = "Sleep", spellID = 31298,
    raid = "IID534", raidName = "Hyjal Summit", boss = "619", bossName = "Anetheron",
    maxMarks = 3,
  },
  {
    key = "azgalorDoom", name = "Doom", spellID = 31347,
    raid = "IID534", raidName = "Hyjal Summit", boss = "621", bossName = "Azgalor",
    maxMarks = 1,
  },
  {
    key = "archimondeAirBurst", name = "Air Burst", spellID = 32014,
    raid = "IID534", raidName = "Hyjal Summit", boss = "622", bossName = "Archimonde",
    maxMarks = 1,
  },
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

local markerValues = {
  [0] = NONE or "None",
  [1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t",
  [2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t",
  [3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t",
  [4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t",
  [5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t",
  [6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t",
  [7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t",
  [8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t",
}

local selectedInstance = "IID564"
local selectedSection = {}
local selectedFriendlyRaid = "IID564"
local selectedFriendlyBoss = {}
local transferState = { text = "", status = "" }

local function EnsureDB()
  local profile = MerfinPlus.db.profile
  profile.raidAutoMarker = profile.raidAutoMarker or {
    mouseover = MerfinPlus.AutoMarkerDefaults.mouseover or 4,
    nameplates = MerfinPlus.AutoMarkerDefaults.nameplates == true,
    instances = {},
    mechanics = {},
  }
  profile.raidAutoMarker.instances = profile.raidAutoMarker.instances or {}
  profile.raidAutoMarker.mechanics = profile.raidAutoMarker.mechanics or {}
  if profile.raidAutoMarker.nameplates == nil then profile.raidAutoMarker.nameplates = false end
  if profile.raidAutoMarker.enemyEnabled == nil then profile.raidAutoMarker.enemyEnabled = true end
  if profile.raidAutoMarker.friendlyEnabled == nil then profile.raidAutoMarker.friendlyEnabled = true end
  return profile.raidAutoMarker
end

local function NotifyChanged()
  if Merfin and Merfin.NotifyRaidAutoMarkerConfigChanged then
    Merfin.NotifyRaidAutoMarkerConfigChanged()
  end
end

local function EnemySettings(instanceKey, npcID)
  local db = EnsureDB()
  db.instances[instanceKey] = db.instances[instanceKey] or {}
  if not db.instances[instanceKey][npcID] then
    local defaults = MerfinPlus.AutoMarkerDefaults.instances
      and MerfinPlus.AutoMarkerDefaults.instances[instanceKey]
      and MerfinPlus.AutoMarkerDefaults.instances[instanceKey][npcID] or {}
    local marks = {}
    for index = 1, 8 do marks[index] = defaults.marks and defaults.marks[index] or nil end
    db.instances[instanceKey][npcID] = {
      enable = defaults.enable ~= false,
      priority = tonumber(defaults.priority) or 1,
      marks = marks,
    }
  end
  local settings = db.instances[instanceKey][npcID]
  settings.marks = settings.marks or {}
  return settings
end

local function FriendlySettings(key)
  local db = EnsureDB()
  local defaults = MerfinPlus.AutoMarkerDefaults.mechanics[key] or {}
  if not db.mechanics[key] then
    local marks = {}
    for index = 1, 8 do marks[index] = defaults.marks and defaults.marks[index] or nil end
    db.mechanics[key] = { enable = defaults.enable ~= false, marks = marks }
  end
  db.mechanics[key].marks = db.mechanics[key].marks or {}
  return db.mechanics[key], defaults
end

local function CurrentCatalog()
  return MerfinPlus.AutoMarkerCatalog and MerfinPlus.AutoMarkerCatalog[selectedInstance]
end

local function CurrentSection()
  local catalog = CurrentCatalog()
  if not catalog or not catalog.sections or not catalog.sections[1] then return end
  selectedSection[selectedInstance] = selectedSection[selectedInstance] or catalog.sections[1].key
  return selectedSection[selectedInstance]
end

local function SpellTexture(spellID)
  if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(spellID) end
  if GetSpellTexture then return GetSpellTexture(spellID) end
end

local function NpcSpells(npcID)
  local spells, seen = {}, {}
  for _, ability in ipairs(MerfinPlus.BTTrashCooldownCatalog or {}) do
    local spellID = tonumber(ability.spell)
    if tonumber(ability.npc) == npcID and spellID and not seen[spellID] then
      seen[spellID] = true
      spells[#spells + 1] = spellID
    end
  end
  for _, spellID in ipairs((MerfinPlus.BTNpcModelSpellCatalog or {})[npcID] or {}) do
    spellID = tonumber(spellID)
    if spellID and not seen[spellID] then
      seen[spellID] = true
      spells[#spells + 1] = spellID
    end
  end
  return spells
end

local function SetSpellTooltip(button)
  GameTooltip:Hide()
  GameTooltip:SetOwner(button, "ANCHOR_TOP")
  GameTooltip:SetFrameStrata("TOOLTIP")
  GameTooltip:SetFrameLevel(button:GetFrameLevel() + 100)
  GameTooltip:ClearLines()
  GameTooltip:SetHyperlink("spell:" .. tostring(button.spellID))
  if (GameTooltip:NumLines() or 0) == 0 and GameTooltip.SetSpellByID then
    GameTooltip:SetSpellByID(button.spellID)
  end
  GameTooltip:Show()
end

local function UpdateNpcSpellPanel(frame, npcID)
  local spells = NpcSpells(npcID)
  for index, button in ipairs(frame.spellButtons) do
    button:Hide()
  end

  if #spells == 0 then
    frame.spellPanel:Hide()
    frame.model:SetPoint("BOTTOMRIGHT", -8, 8)
    return
  end

  frame.model:SetPoint("BOTTOMRIGHT", -8, 64)
  frame.spellPanel:Show()
  local iconSize, spacing = 32, 6
  local totalWidth = #spells * iconSize + (#spells - 1) * spacing
  local startX = -totalWidth / 2 + iconSize / 2
  for index, spellID in ipairs(spells) do
    local button = frame.spellButtons[index]
    if not button then
      local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
      button = CreateFrame("Button", nil, frame.spellPanel, backdropTemplate)
      button:SetSize(iconSize, iconSize)
      if button.SetBackdrop then
        button:SetBackdrop({
          bgFile = "Interface\\Buttons\\WHITE8X8",
          edgeFile = "Interface\\Buttons\\WHITE8X8",
          edgeSize = 1,
        })
        button:SetBackdropColor(unpack(theme.surface))
        button:SetBackdropBorderColor(unpack(theme.borderSoft))
      end
      button.icon = button:CreateTexture(nil, "ARTWORK")
      button.icon:SetPoint("TOPLEFT", 2, -2)
      button.icon:SetPoint("BOTTOMRIGHT", -2, 2)
      button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      button:SetScript("OnEnter", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(unpack(theme.border)) end
        SetSpellTooltip(self)
      end)
      button:SetScript("OnLeave", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(unpack(theme.borderSoft)) end
        GameTooltip:Hide()
      end)
      frame.spellButtons[index] = button
    end
    button.spellID = spellID
    button.icon:SetTexture(SpellTexture(spellID) or "Interface\\Icons\\INV_Misc_QuestionMark")
    button:ClearAllPoints()
    button:SetPoint("CENTER", frame.spellPanel, "CENTER", startX + (index - 1) * (iconSize + spacing), 0)
    button:Show()
  end
end

local npcModelFrame
local npcModelHoverFrame

function MerfinPlus:RefreshRaidAutoMarkerTheme()
  if npcModelHoverFrame then
    npcModelHoverFrame:SetBackdropColor(unpack(theme.canvas))
    npcModelHoverFrame:SetBackdropBorderColor(unpack(theme.border))
    npcModelHoverFrame.title:SetTextColor(unpack(theme.text))
    self:ApplyUIFontSizeDelta(npcModelHoverFrame)
  end
  if npcModelFrame then
    npcModelFrame:SetBackdropColor(unpack(theme.canvas))
    npcModelFrame:SetBackdropBorderColor(unpack(theme.border))
    npcModelFrame.header:SetBackdropColor(unpack(theme.shell))
    npcModelFrame.header:SetBackdropBorderColor(unpack(theme.border))
    npcModelFrame.title:SetTextColor(unpack(theme.text))
    npcModelFrame.npcIDText:SetTextColor(unpack(theme.muted))
    npcModelFrame.close:SetBackdropColor(unpack(theme.surface))
    npcModelFrame.close:SetBackdropBorderColor(unpack(theme.borderSoft))
    npcModelFrame.close.text:SetTextColor(unpack(theme.accent))
    npcModelFrame.spellPanel:SetBackdropColor(unpack(theme.canvas))
    npcModelFrame.spellPanel:SetBackdropBorderColor(unpack(theme.border))
    for _, button in ipairs(npcModelFrame.spellButtons or {}) do
      button:SetBackdropColor(unpack(theme.surface))
      button:SetBackdropBorderColor(unpack(theme.borderSoft))
    end
    self:ApplyUIFontSizeDelta(npcModelFrame)
  end
end

local function LoadNpcModel(model, npcID)
  model.merfinLoadToken = (model.merfinLoadToken or 0) + 1
  local loadToken = model.merfinLoadToken
  model:Hide()
  model:ClearModel()
  model:SetCreature(npcID)

  local function FinishLoad()
    if model.merfinLoadToken ~= loadToken then return end
    -- Reassert the requested creature after the client has processed the
    -- previous model load. This prevents a late old request being rendered.
    model:ClearModel()
    model:SetCreature(npcID)
    model:Show()
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(0.05, FinishLoad)
  else
    FinishLoad()
  end
end

local function HideNpcModelHover()
  if npcModelHoverFrame then npcModelHoverFrame:Hide() end
end

local function ShowNpcModelHover(npcID, name, owner)
  npcID = tonumber(npcID)
  if not npcID or not owner then return end

  if not npcModelHoverFrame then
    local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", nil, UIParent, backdropTemplate)
    frame:SetSize(220, 270)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(110)
    if frame.SetFixedFrameStrata then frame:SetFixedFrameStrata(true) end
    frame:SetClampedToScreen(true)
    frame:EnableMouse(false)
    if frame.SetBackdrop then
      frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
      })
      frame:SetBackdropColor(unpack(theme.canvas))
      frame:SetBackdropBorderColor(unpack(theme.border))
    end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 10, -9)
    frame.title:SetPoint("TOPRIGHT", -10, -9)
    frame.title:SetJustifyH("CENTER")
    frame.title:SetTextColor(unpack(theme.text))

    frame.model = CreateFrame("PlayerModel", nil, frame)
    frame.model:SetPoint("TOPLEFT", 7, -30)
    frame.model:SetPoint("BOTTOMRIGHT", -7, 7)
    npcModelHoverFrame = frame
  end

  npcModelHoverFrame:ClearAllPoints()
  local ownerRight = owner:GetRight() or 0
  if ownerRight + npcModelHoverFrame:GetWidth() + 12 <= UIParent:GetWidth() then
    npcModelHoverFrame:SetPoint("TOPLEFT", owner, "TOPRIGHT", 10, 8)
  else
    npcModelHoverFrame:SetPoint("TOPRIGHT", owner, "TOPLEFT", -10, 8)
  end
  npcModelHoverFrame.title:SetText(name or tostring(npcID))
  LoadNpcModel(npcModelHoverFrame.model, npcID)
  MerfinPlus:RefreshRaidAutoMarkerTheme()
  npcModelHoverFrame:Show()
end

local function ShowNpcModel(npcID, name)
  npcID = tonumber(npcID)
  if not npcModelFrame then
    local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", "MerfinPlusNpcModelFrame", UIParent, backdropTemplate)
    frame:SetSize(360, 440)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(100)
    if frame.SetFixedFrameStrata then frame:SetFixedFrameStrata(true) end
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    if frame.SetBackdrop then
      frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
      })
      frame:SetBackdropColor(unpack(theme.canvas))
      frame:SetBackdropBorderColor(unpack(theme.border))
    end

    frame.header = CreateFrame("Frame", nil, frame, backdropTemplate)
    frame.header:SetPoint("TOPLEFT", 1, -1)
    frame.header:SetPoint("TOPRIGHT", -1, -1)
    frame.header:SetHeight(50)
    if frame.header.SetBackdrop then
      frame.header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
      })
      frame.header:SetBackdropColor(unpack(theme.shell))
      frame.header:SetBackdropBorderColor(unpack(theme.border))
    end

    frame.title = frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame.header, "TOPLEFT", 13, -8)
    frame.title:SetPoint("TOPRIGHT", frame.header, "TOPRIGHT", -42, -8)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetTextColor(unpack(theme.text))

    frame.npcIDText = frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.npcIDText:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -3)
    frame.npcIDText:SetPoint("TOPRIGHT", frame.header, "TOPRIGHT", -42, -27)
    frame.npcIDText:SetJustifyH("LEFT")
    frame.npcIDText:SetTextColor(unpack(theme.muted))

    frame.close = CreateFrame("Button", nil, frame.header, backdropTemplate)
    frame.close:SetSize(24, 24)
    frame.close:SetPoint("RIGHT", -10, 0)
    if frame.close.SetBackdrop then
      frame.close:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
      })
      frame.close:SetBackdropColor(unpack(theme.surface))
      frame.close:SetBackdropBorderColor(unpack(theme.borderSoft))
    end
    frame.close.text = frame.close:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.close.text:SetAllPoints()
    frame.close.text:SetJustifyH("CENTER")
    frame.close.text:SetJustifyV("MIDDLE")
    frame.close.text:SetText("×")
    frame.close.text:SetTextColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    frame.close:SetScript("OnClick", function() frame:Hide() end)
    frame.close:SetScript("OnEnter", function(button)
      if button.SetBackdropColor then button:SetBackdropColor(0.24, 0.045, 0.035, 1) end
      if button.SetBackdropBorderColor then button:SetBackdropBorderColor(0.8, 0.12, 0.08, 1) end
      button.text:SetTextColor(1, 0.35, 0.25, 1)
    end)
    frame.close:SetScript("OnLeave", function(button)
      if button.SetBackdropColor then button:SetBackdropColor(unpack(theme.surface)) end
      if button.SetBackdropBorderColor then button:SetBackdropBorderColor(unpack(theme.borderSoft)) end
      button.text:SetTextColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    end)

    frame.model = CreateFrame("PlayerModel", nil, frame)
    frame.model:SetPoint("TOPLEFT", 8, -55)
    frame.model:SetPoint("BOTTOMRIGHT", -8, 8)

    frame.spellPanel = CreateFrame("Frame", nil, frame, backdropTemplate)
    frame.spellPanel:SetPoint("BOTTOMLEFT", 8, 8)
    frame.spellPanel:SetPoint("BOTTOMRIGHT", -8, 8)
    frame.spellPanel:SetHeight(48)
    if frame.spellPanel.SetBackdrop then
      frame.spellPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
      })
      frame.spellPanel:SetBackdropColor(unpack(theme.canvas))
      frame.spellPanel:SetBackdropBorderColor(unpack(theme.border))
    end
    frame.spellButtons = {}
    frame.spellPanel:Hide()

    if UISpecialFrames then
      UISpecialFrames[#UISpecialFrames + 1] = "MerfinPlusNpcModelFrame"
    end
    npcModelFrame = frame
  end

  if npcModelFrame:IsShown() and npcModelFrame.npcID == npcID then
    npcModelFrame:Hide()
    return
  end

  npcModelFrame.npcID = npcID
  npcModelFrame.title:SetText(name or tostring(npcID))
  npcModelFrame.npcIDText:SetText("NPC ID  •  " .. tostring(npcID))
  LoadNpcModel(npcModelFrame.model, npcID)
  UpdateNpcSpellPanel(npcModelFrame, npcID)
  MerfinPlus:RefreshRaidAutoMarkerTheme()
  npcModelFrame:Show()
end

local npcToggleModels = setmetatable({}, { __mode = "k" })

do
  local AceGUI = LibStub("AceGUI-3.0")
  local widgetType, widgetVersion = "MerfinPlusNpcToggle", 1
  if (AceGUI:GetWidgetVersion(widgetType) or 0) < widgetVersion then
    AceGUI:RegisterWidgetType(widgetType, function()
      local widget = AceGUI:Create("CheckBox")
      local BaseFire = widget.Fire
      widget.type = widgetType
      widget.Fire = function(self, event, ...)
        local result = BaseFire(self, event, ...)
        if event == "OnEnter" then
          local option = self:GetUserDataTable().option
          local modelData = option and npcToggleModels[option]
          if modelData then
            local modelName = modelData.name
            if type(modelName) == "function" then modelName = modelName() end
            ShowNpcModelHover(modelData.npcID, modelName, self.frame)
          end
        elseif event == "OnLeave" then
          HideNpcModelHover()
        end
        return result
      end
      return widget
    end, widgetVersion)
  end

  local iconButtonType, iconButtonVersion = "MerfinPlusIconButton", 2
  if (AceGUI:GetWidgetVersion(iconButtonType) or 0) < iconButtonVersion then
    AceGUI:RegisterWidgetType(iconButtonType, function()
      local widget = AceGUI:Create("Icon")
      widget.type = iconButtonType
      widget.SetLabel = function(self)
        self.label:SetText("")
        self.label:Hide()
        self:SetHeight(self.image:GetHeight() + 10)
      end
      return widget
    end, iconButtonVersion)
  end
end

local function BuildEnemyOptions()
  local function EnemyDisabled()
    return EnsureDB().enemyEnabled == false
  end
  local args = {
    globalEnable = {
      type = "toggle", name = L["Enable"], order = 0, width = 1.5,
      get = function() return EnsureDB().enemyEnabled ~= false end,
      set = function(_, value)
        EnsureDB().enemyEnabled = value and true or false
        NotifyChanged()
      end,
    },
    mouseover = {
      type = "select", name = L["Mouseover Marking"], order = 0.5, width = 1.5,
      desc = L["Select how mouseover marking is activated."],
      values = { [1] = L["Always"], [2] = "Alt", [3] = "Ctrl", [4] = "Shift", [5] = L["Disabled"] },
      get = function() return EnsureDB().mouseover or 4 end,
      set = function(_, value) EnsureDB().mouseover = value; NotifyChanged() end,
    },
    nameplates = {
      type = "toggle", name = "Auto Mark Nameplates", order = 1, width = 1.5,
      get = function() return EnsureDB().nameplates == true end,
      set = function(_, value)
        EnsureDB().nameplates = value and true or false
        NotifyChanged()
      end,
    },
    mouseoverRow = {
      type = "description", name = " ", order = 2.5, width = "full",
    },
    raid = {
      type = "select", name = L["Raid"], order = 3, width = 1.5,
      values = function()
        local values = {}
        for key, data in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
          values[key] = MerfinPlus:GetLocalizedRaidName(key, data.name)
        end
        return values
      end,
      get = function() return selectedInstance end,
      set = function(_, value)
        selectedInstance = value
        CurrentSection()
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    subzone = {
      type = "select", name = L["Subzone"], order = 4, width = 1.5,
      values = function()
        local values = {}
        for _, section in ipairs(CurrentCatalog() and CurrentCatalog().sections or {}) do
          values[section.key] = MerfinPlus:LocalizeKnownValue(section.name)
        end
        return values
      end,
      sorting = function()
        local order = {}
        for _, section in ipairs(CurrentCatalog() and CurrentCatalog().sections or {}) do
          order[#order + 1] = section.key
        end
        return order
      end,
      get = CurrentSection,
      set = function(_, value)
        selectedSection[selectedInstance] = value
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    sectionHeader = {
      type = "header", order = 5,
      name = function()
        for _, section in ipairs(CurrentCatalog() and CurrentCatalog().sections or {}) do
          if section.key == CurrentSection() then
            return MerfinPlus:LocalizeKnownValue(section.name)
          end
        end
        return L["Enemy"]
      end,
    },
  }

  local rowOrder = 10
  for instanceKey, catalog in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
    local mobs = {}
    for _, mob in ipairs(catalog.mobs or {}) do mobs[mob.npc] = mob end
    for _, section in ipairs(catalog.sections or {}) do
      for _, npcID in ipairs(section.npcs or {}) do
        local rowInstance, rowSection, rowNpc = instanceKey, section.key, npcID
        local mob = mobs[npcID]
        local defaults = MerfinPlus.AutoMarkerDefaults.instances
          and MerfinPlus.AutoMarkerDefaults.instances[rowInstance]
          and MerfinPlus.AutoMarkerDefaults.instances[rowInstance][rowNpc] or {}
        local markerCount = math.max(1, defaults.marks and #defaults.marks or 0)
        local rowArgs = {
          enable = {
            type = "toggle",
            dialogControl = "MerfinPlusNpcToggle",
            name = function()
              return MerfinPlus:GetLocalizedEnemyName(rowNpc, mob and mob.name or tostring(rowNpc))
            end,
            descStyle = "inline",
            order = 1, width = 1.1,
            get = function() return EnemySettings(rowInstance, rowNpc).enable ~= false end,
            set = function(_, value) EnemySettings(rowInstance, rowNpc).enable = value; NotifyChanged() end,
          },
          showModel = {
            type = "execute", dialogControl = "MerfinPlusIconButton", name = L["Show Model"],
            image = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\model_view_32.png",
            imageWidth = 20, imageHeight = 20,
            order = 1.5, width = 0.35,
            func = function()
              ShowNpcModel(
                rowNpc,
                MerfinPlus:GetLocalizedEnemyName(rowNpc, mob and mob.name or tostring(rowNpc))
              )
            end,
          },
          priority = {
            type = "range", name = L["Priority"], order = 2, width = 0.6,
            min = 1, max = 20, step = 1,
            get = function() return tonumber(EnemySettings(rowInstance, rowNpc).priority) or 1 end,
            set = function(_, value) EnemySettings(rowInstance, rowNpc).priority = value; NotifyChanged() end,
          },
        }
        npcToggleModels[rowArgs.enable] = {
          npcID = rowNpc,
          name = function()
            return MerfinPlus:GetLocalizedEnemyName(rowNpc, mob and mob.name or tostring(rowNpc))
          end,
        }
        for markerIndex = 1, markerCount do
          local index = markerIndex
          rowArgs["mark" .. index] = {
            type = "select", name = "", order = 2 + index, width = 0.4,
            values = markerValues,
            get = function()
              local mark = tonumber(EnemySettings(rowInstance, rowNpc).marks[index])
              return mark and mark >= 1 and mark <= 8 and mark or 0
            end,
            set = function(_, value)
              EnemySettings(rowInstance, rowNpc).marks[index] = value ~= 0 and value or nil
              NotifyChanged()
            end,
          }
        end
        for key, option in pairs(rowArgs) do
          if key ~= "showModel" then option.disabled = EnemyDisabled end
        end
        rowOrder = rowOrder + 1
        args["enemy_" .. rowInstance .. "_" .. rowNpc] = {
          type = "group", name = "", inline = true, order = rowOrder,
          hidden = function() return selectedInstance ~= rowInstance or CurrentSection() ~= rowSection end,
          args = rowArgs,
        }
      end
    end
  end
  for key, option in pairs(args) do
    if key ~= "globalEnable" and not key:find("^enemy_") then option.disabled = EnemyDisabled end
  end
  return args
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

local function FriendlyBosses()
  local bosses, seen = {}, {}
  for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
    if mechanic.raid == selectedFriendlyRaid and not seen[mechanic.boss] then
      seen[mechanic.boss] = true
      bosses[#bosses + 1] = { key = mechanic.boss, name = mechanic.bossName }
    end
  end
  table.sort(bosses, function(a, b) return (tonumber(a.key) or math.huge) < (tonumber(b.key) or math.huge) end)
  return bosses
end

local function CurrentFriendlyBoss()
  local current = selectedFriendlyBoss[selectedFriendlyRaid]
  for _, boss in ipairs(FriendlyBosses()) do
    if boss.key == current then return current end
  end
  current = FriendlyBosses()[1] and FriendlyBosses()[1].key
  selectedFriendlyBoss[selectedFriendlyRaid] = current
  return current
end

local function BuildFriendlyOptions()
  local function FriendlyDisabled()
    return EnsureDB().friendlyEnabled == false
  end
  local args = {
    globalEnable = {
      type = "toggle", name = L["Enable"], order = 0, width = "full",
      get = function() return EnsureDB().friendlyEnabled ~= false end,
      set = function(_, value)
        EnsureDB().friendlyEnabled = value and true or false
        NotifyChanged()
      end,
    },
    enableSpacer = {
      type = "description", name = " ", order = 0.5, width = "full",
    },
    description = {
      type = "description", order = 1, width = "full",
      name = L["Configure raid markers assigned to players targeted by boss mechanics."],
    },
    raid = {
      type = "select", name = L["Raid"], order = 2, width = 1.5,
      values = function()
        local values = {}
        for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
          values[mechanic.raid] = MerfinPlus:GetLocalizedRaidName(mechanic.raid, mechanic.raidName)
        end
        return values
      end,
      get = function() return selectedFriendlyRaid end,
      set = function(_, value)
        selectedFriendlyRaid = value
        CurrentFriendlyBoss()
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
    boss = {
      type = "select", name = L["Boss"], order = 3, width = 1.5,
      values = function()
        local values = {}
        for _, boss in ipairs(FriendlyBosses()) do
          values[boss.key] = MerfinPlus:GetLocalizedBossName(
            boss.localeID or "encounter:" .. tostring(boss.key),
            boss.name
          )
        end
        return values
      end,
      get = CurrentFriendlyBoss,
      set = function(_, value)
        selectedFriendlyBoss[selectedFriendlyRaid] = value
        AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
      end,
    },
  }

  for mechanicIndex, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
    local row = mechanic
    local rowArgs = {
      enable = {
        type = "toggle", order = 1, width = 1.3,
        name = function()
          local icon = row.icon or row.spellID and SpellTexture(row.spellID) or 134400
          return ("|T%s:16:16|t %s"):format(
            icon,
            MerfinPlus:GetLocalizedMechanicName(row.key, row.name)
          )
        end,
        get = function()
          local settings, defaults = FriendlySettings(row.key)
          return settings.enable == nil and defaults.enable ~= false or settings.enable
        end,
        set = function(_, value) FriendlySettings(row.key).enable = value; NotifyChanged() end,
      },
    }
    for markerIndex = 1, row.maxMarks do
      local index = markerIndex
      rowArgs["mark" .. index] = {
        type = "select", name = "", order = 1 + index, width = 0.4,
        values = markerValues,
        get = function()
          local settings, defaults = FriendlySettings(row.key)
          local mark = tonumber(settings.marks[index]) or tonumber(defaults.marks and defaults.marks[index])
          return mark and mark >= 1 and mark <= 8 and mark or 0
        end,
        set = function(_, value)
          FriendlySettings(row.key).marks[index] = tonumber(value) or 0
          NotifyChanged()
        end,
      }
    end
    args["mechanic_" .. row.key] = {
      type = "group", name = "", inline = true, order = 10 + mechanicIndex,
      hidden = function() return selectedFriendlyRaid ~= row.raid or CurrentFriendlyBoss() ~= row.boss end,
      args = rowArgs,
    }
  end
  for key, option in pairs(args) do
    if key ~= "globalEnable" then option.disabled = FriendlyDisabled end
  end
  return args
end

local function CopyMarks(source)
  local marks = {}
  for index = 1, 8 do
    local mark = source and tonumber(source[index])
    if mark and mark >= 1 and mark <= 8 then marks[index] = mark end
  end
  return marks
end

local function BuildExport()
  local db = EnsureDB()
  local payload = {
    kind = "autoMarker", version = 1, mouseover = tonumber(db.mouseover) or 4,
    nameplates = db.nameplates == true,
    enemyEnabled = db.enemyEnabled ~= false,
    friendlyEnabled = db.friendlyEnabled ~= false,
    instances = {}, mechanics = {},
  }
  for instanceKey, catalog in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
    payload.instances[instanceKey] = {}
    for _, mob in ipairs(catalog.mobs or {}) do
      local settings = EnemySettings(instanceKey, mob.npc)
      payload.instances[instanceKey][mob.npc] = {
        enable = settings.enable ~= false,
        priority = math.max(1, math.min(20, tonumber(settings.priority) or 1)),
        marks = CopyMarks(settings.marks),
      }
    end
  end
  for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
    local settings, defaults = FriendlySettings(mechanic.key)
    local marks = {}
    for index = 1, mechanic.maxMarks or 1 do
      marks[index] = tonumber(settings.marks[index])
        or tonumber(defaults.marks and defaults.marks[index]) or 0
    end
    payload.mechanics[mechanic.key] = {
      enable = settings.enable == nil and defaults.enable ~= false or settings.enable,
      marks = marks,
    }
  end
  return "!MPAM:1!" .. AceSerializer:Serialize(payload)
end

local function Import(text)
  text = type(text) == "string" and text:match("^%s*(.-)%s*$") or ""
  local prefix = "!MPAM:1!"
  if text:sub(1, #prefix) ~= prefix then return false, L["Invalid Auto-Marker export string."] end
  local ok, payload = AceSerializer:Deserialize(text:sub(#prefix + 1))
  if not ok or type(payload) ~= "table" or payload.kind ~= "autoMarker" or payload.version ~= 1 then
    return false, L["Invalid Auto-Marker export string."]
  end

  local imported = {
    mouseover = math.max(1, math.min(5, tonumber(payload.mouseover) or 4)),
    nameplates = payload.nameplates == true,
    enemyEnabled = type(payload.enemyEnabled) ~= "boolean" or payload.enemyEnabled,
    friendlyEnabled = type(payload.friendlyEnabled) ~= "boolean" or payload.friendlyEnabled,
    instances = {}, mechanics = {},
  }
  for instanceKey, catalog in pairs(MerfinPlus.AutoMarkerCatalog or {}) do
    imported.instances[instanceKey] = {}
    local sourceInstance = type(payload.instances) == "table" and payload.instances[instanceKey] or {}
    sourceInstance = type(sourceInstance) == "table" and sourceInstance or {}
    local defaultInstance = MerfinPlus.AutoMarkerDefaults.instances
      and MerfinPlus.AutoMarkerDefaults.instances[instanceKey] or {}
    for _, mob in ipairs(catalog.mobs or {}) do
      local fallback = defaultInstance[mob.npc] or {}
      local source = type(sourceInstance[mob.npc]) == "table" and sourceInstance[mob.npc] or fallback
      imported.instances[instanceKey][mob.npc] = {
        enable = type(source.enable) == "boolean" and source.enable or fallback.enable ~= false,
        priority = math.max(1, math.min(20, tonumber(source.priority) or tonumber(fallback.priority) or 1)),
        marks = CopyMarks(type(source.marks) == "table" and source.marks or fallback.marks),
      }
    end
  end
  for _, mechanic in ipairs(MerfinPlus.FriendlyMarkerCatalog or {}) do
    local fallback = MerfinPlus.AutoMarkerDefaults.mechanics[mechanic.key] or {}
    local source = type(payload.mechanics) == "table" and payload.mechanics[mechanic.key] or fallback
    source = type(source) == "table" and source or fallback
    local marks = {}
    for index = 1, mechanic.maxMarks or 1 do
      local mark = tonumber(source.marks and source.marks[index])
        or tonumber(fallback.marks and fallback.marks[index]) or 0
      marks[index] = mark >= 1 and mark <= 8 and mark or 0
    end
    imported.mechanics[mechanic.key] = {
      enable = type(source.enable) == "boolean" and source.enable or fallback.enable ~= false,
      marks = marks,
    }
  end
  MerfinPlus.db.profile.raidAutoMarker = imported
  NotifyChanged()
  return true, L["Auto-Marker settings imported successfully."]
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
        MerfinPlus.db.profile.raidAutoMarker = nil
        transferState.text = ""
        transferState.status = ""
        EnsureDB()
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

function MerfinPlus:BuildRaidAutoMarkerProfileToolsOptions()
  return {
    type = "group",
    name = L["Auto-Marker"],
    order = 2,
    args = BuildTransferOptions(),
  }
end

function MerfinPlus:BuildRaidAutoMarkerOptions()
  EnsureDB()
  local options = {
    type = "group",
    name = L["Auto-Marker"],
    childGroups = "tab",
    args = {
      moduleInfo = {
        type = "description", name = AutoMarkerInfoText, order = 0, width = "full",
        fontSize = "medium",
      },
      enemy = {
        type = "group", name = L["Enemy"], order = 1,
        args = BuildEnemyOptions(),
      },
      friendly = {
        type = "group", name = L["Friendly"], order = 2,
        args = BuildFriendlyOptions(),
      },
    },
  }
  return MakeOptionNamesDynamic(options)
end
