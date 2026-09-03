local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme

local WIDGET_TYPE = "MerfinPlusNavButton"
local WIDGET_VERSION = 22

local NAV_ITEM_HEIGHT = 48
local NAV_ICON_SIZE = 24
local NAV_ICON_LEFT = 15
local NAV_ICON_TEXT_GAP = 9
local NAV_FONT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local NAV_TEXTURE_PATH = "Interface\\AddOns\\MerfinPlus\\Media\\options\\"

local function SetTexture(texture, path)
  texture:SetTexture(path)
  texture:SetTexCoord(0, 1, 0, 1)
end

local function ApplyLayout(widget)
  widget.icon:ClearAllPoints()
  widget.text:ClearAllPoints()

  widget.icon:SetSize(NAV_ICON_SIZE, NAV_ICON_SIZE)
  widget.icon:SetPoint("LEFT", widget.frame, "LEFT", NAV_ICON_LEFT, 0)
  widget.text:SetPoint("LEFT", widget.icon, "RIGHT", NAV_ICON_TEXT_GAP, 0)
  widget.text:SetPoint("RIGHT", widget.frame, "RIGHT", -24, 0)
  widget.frame:SetHeight(NAV_ITEM_HEIGHT)
end

local function UpdateNavButtonStyle(widget)
  local bottom = widget.bottomStyle

  if bottom then
    if widget.selected then
      SetTexture(widget.state, NAV_TEXTURE_PATH .. "profile_button_selected.png")
    elseif widget.hovered then
      SetTexture(widget.state, NAV_TEXTURE_PATH .. "profile_button_hover.png")
    else
      SetTexture(widget.state, NAV_TEXTURE_PATH .. "profile_button_normal.png")
    end

    widget.flare:Hide()
    widget.arrow:Show()
  else
    if widget.selected then
      SetTexture(widget.state, NAV_TEXTURE_PATH .. "nav_button_selected.png")
      widget.state:SetAlpha(1)
      widget.flare:SetAlpha(1)
      widget.flare:Show()
    elseif widget.hovered then
      SetTexture(widget.state, NAV_TEXTURE_PATH .. "nav_button_selected.png")
      widget.state:SetAlpha(1)
      widget.flare:SetAlpha(1)
      widget.flare:Show()
    else
      SetTexture(widget.state, NAV_TEXTURE_PATH .. "nav_button_normal.png")
      widget.state:SetAlpha(1)
      widget.flare:Hide()
    end

    widget.arrow:Hide()
  end

  if widget.selected or widget.hovered then
    if widget.state.SetDesaturated then widget.state:SetDesaturated(true) end
    widget.state:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    if widget.flare.SetDesaturated then widget.flare:SetDesaturated(true) end
    widget.flare:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    widget.arrow:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
  else
    if widget.state.SetDesaturated then widget.state:SetDesaturated(false) end
    widget.state:SetVertexColor(1, 1, 1, 1)
    if widget.flare.SetDesaturated then widget.flare:SetDesaturated(false) end
    widget.flare:SetVertexColor(1, 1, 1, 1)
    widget.arrow:SetTextColor(theme.muted[1], theme.muted[2], theme.muted[3], 1)
  end

  if widget.selected or widget.hovered then
    widget.text:SetTextColor(1, 1, 1, 1)
    widget.icon:SetAlpha(1)
  else
    widget.text:SetTextColor(theme.muted[1], theme.muted[2], theme.muted[3], 1)
    widget.icon:SetAlpha(0.82)
  end
end

local function OnClick(frame, button)
  local widget = frame.obj
  if widget.selected then
    return
  end
  widget:Fire("OnClick", button)
end

local function OnEnter(frame)
  local widget = frame.obj
  widget.hovered = true
  UpdateNavButtonStyle(widget)
end

local function OnLeave(frame)
  local widget = frame.obj
  widget.hovered = nil
  UpdateNavButtonStyle(widget)
end

local methods = {
  OnAcquire = function(self)
    self:SetHeight(NAV_ITEM_HEIGHT)
    self:SetFullWidth(true)
    self.hovered = nil
    self.selected = nil
    self.bottomStyle = nil
    ApplyLayout(self)
    self:SetText("")
    self:SetIcon(nil)
    UpdateNavButtonStyle(self)
  end,
  OnRelease = function(self)
    self.frame:ClearAllPoints()
    self.hovered = nil
    self.selected = nil
    self.bottomStyle = nil
  end,
  SetText = function(self, text)
    MerfinPlus:ApplyLocalizedFont(self.text, NAV_FONT, 17)
    self.text:SetText(text or "")
  end,
  SetIcon = function(self, icon)
    if icon then
      self.icon:SetSize(NAV_ICON_SIZE, NAV_ICON_SIZE)
      self.icon:SetTexture(icon)
      self.icon:SetTexCoord(0, 1, 0, 1)
      self.icon:Show()
    else
      self.icon:Hide()
    end
  end,
  SetSelected = function(self, selected)
    self.selected = selected and true or nil
    UpdateNavButtonStyle(self)
  end,
  SetBottomStyle = function(self, enabled)
    self.bottomStyle = enabled and true or nil
    ApplyLayout(self)
    UpdateNavButtonStyle(self)
  end,
  RefreshTheme = function(self)
    UpdateNavButtonStyle(self)
  end,
}

local function Constructor()
  local frame = CreateFrame("Button", nil, UIParent)
  frame:SetHeight(NAV_ITEM_HEIGHT)
  frame:EnableMouse(true)

  local state = frame:CreateTexture(nil, "BACKGROUND")
  state:SetAllPoints(frame)

  local icon = frame:CreateTexture(nil, "ARTWORK")
  icon:SetPoint("LEFT", frame, "LEFT", NAV_ICON_LEFT, 0)
  icon:SetSize(NAV_ICON_SIZE, NAV_ICON_SIZE)

  local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  MerfinPlus:ApplyLocalizedFont(text, NAV_FONT, 17)
  text:SetShadowColor(0, 0, 0, 0.85)
  text:SetShadowOffset(1, -1)
  text:SetJustifyH("LEFT")
  text:SetPoint("LEFT", icon, "RIGHT", NAV_ICON_TEXT_GAP, 0)
  text:SetPoint("RIGHT", frame, "RIGHT", -24, 0)

  local flare = frame:CreateTexture(nil, "ARTWORK", nil, 2)
  flare:SetPoint("RIGHT", frame, "RIGHT", 10, 0)
  flare:SetSize(16, NAV_ITEM_HEIGHT)
  SetTexture(flare, NAV_TEXTURE_PATH .. "nav_button_flare.png")
  flare:Hide()

  local arrow = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  arrow:SetPoint("RIGHT", frame, "RIGHT", -17, 0)
  arrow:SetText(">")
  arrow:SetTextColor(0.78, 0.78, 0.78, 1)
  arrow:Hide()

  local widget = {
    type = WIDGET_TYPE,
    frame = frame,
    state = state,
    icon = icon,
    text = text,
    flare = flare,
    arrow = arrow,
  }

  frame.obj = widget
  frame:SetScript("OnClick", OnClick)
  frame:SetScript("OnEnter", OnEnter)
  frame:SetScript("OnLeave", OnLeave)

  for method, func in pairs(methods) do
    widget[method] = func
  end

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)
