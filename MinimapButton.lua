local _, MerfinPlus = ...

local BUTTON_RADIUS = 80
local DEFAULT_ANGLE = 225
local ICON_PATH = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\merfinui_logo_2"

local function GetSettings()
  local profile = MerfinPlus.db and MerfinPlus.db.profile
  if not profile then
    return
  end

  profile.minimapButton = profile.minimapButton or { angle = DEFAULT_ANGLE }
  return profile.minimapButton
end

function MerfinPlus:GetMinimapButtonVisibleSetting()
  local settings = GetSettings()
  local storedVisibility = settings and rawget(settings, "showIcon")
  if storedVisibility ~= nil then
    return storedVisibility ~= false
  end

  -- Preserve the previous TBC value without requiring AssignmentWidgets.
  local assignments = self.db and self.db.global and self.db.global.assignments
  if assignments and assignments.showMinimapIcon ~= nil then
    return assignments.showMinimapIcon ~= false
  end

  return true
end

function MerfinPlus:SetMinimapButtonVisibleSetting(value)
  local visible = value == true
  local settings = GetSettings()
  if settings then
    settings.showIcon = visible
  end

  -- Keep the legacy TBC setting synchronized for downgrade compatibility.
  if self.IsTBC and self.IsTBC() then
    local assignments = self.db and self.db.global and self.db.global.assignments
    if assignments then
      assignments.showMinimapIcon = visible
    end
  end

  self:UpdateMinimapButtonVisibility()
end

local function UpdatePosition(button)
  local settings = GetSettings()
  local angle = math.rad((settings and settings.angle) or DEFAULT_ANGLE)
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * BUTTON_RADIUS, math.sin(angle) * BUTTON_RADIUS)
end

local function UpdateDragPosition(button)
  local minimapX, minimapY = Minimap:GetCenter()
  if not minimapX or not minimapY then
    return
  end

  local scale = Minimap:GetEffectiveScale()
  local cursorX, cursorY = GetCursorPosition()
  cursorX, cursorY = cursorX / scale, cursorY / scale

  local settings = GetSettings()
  if settings then
    settings.angle = math.deg(math.atan2(cursorY - minimapY, cursorX - minimapX))
  end
  UpdatePosition(button)
end

function MerfinPlus:InitializeMinimapButton()
  if self.minimapButton then
    UpdatePosition(self.minimapButton)
    self:UpdateMinimapButtonVisibility()
    return
  end

  local button = CreateFrame("Button", "MerfinPlusMinimapButton", Minimap)
  button:SetSize(32, 32)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
  button:SetMovable(true)
  button:SetClampedToScreen(true)
  button:RegisterForClicks("LeftButtonUp")
  button:RegisterForDrag("LeftButton")

  local icon = button:CreateTexture(nil, "BACKGROUND")
  icon:SetTexture(ICON_PATH)
  icon:SetSize(20, 20)
  icon:SetPoint("CENTER")
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetSize(54, 54)
  border:SetPoint("TOPLEFT")

  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  button:SetScript("OnClick", function()
    MerfinPlus:ToggleStandalone()
  end)
  button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", UpdateDragPosition)
  end)
  button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
  end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    local accent = MerfinPlus:GetUIThemeColor("accentBright", { 1, 0.82, 0, 1 })
    GameTooltip:AddLine("MerfinPlus", accent[1], accent[2], accent[3])
    GameTooltip:AddLine(MerfinPlus:T("Left-click to open settings"), 1, 1, 1)
    GameTooltip:AddLine(MerfinPlus:T("Drag to move"), 0.75, 0.75, 0.75)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  self.minimapButton = button
  UpdatePosition(button)
  self:UpdateMinimapButtonVisibility()
end

function MerfinPlus:UpdateMinimapButtonVisibility()
  if not self.minimapButton then
    return
  end
  if not self:GetMinimapButtonVisibleSetting() then
    self.minimapButton:Hide()
  else
    self.minimapButton:Show()
  end
end
