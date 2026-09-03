-- Guild-Manager-style AceGUI dropdown used by MerfinPlus option tables.

local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
local LSM = LibStub("LibSharedMedia-3.0", true)

local WIDGET_TYPE = "MerfinPlusDropdown"
local FONT_WIDGET_TYPE = "MerfinPlusFontDropdown"
local STATUSBAR_WIDGET_TYPE = "MerfinPlusStatusbarDropdown"
local WIDGET_VERSION = 13
-- MerfinPlus currently exposes twelve UI locales. Keep every language visible
-- in the language selector without requiring a mouse-wheel scroll.
local MAX_VISIBLE_ROWS = 12
local ROW_HEIGHT = 28
local FONT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local CJK_MENU_FONT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\NotoSansCJKkr-Regular.otf"
local LATIN_MENU_FONT = "Fonts\\FRIZQT__.TTF"
local CYRILLIC_MENU_FONT = "Fonts\\FRIZQT___CYR.TTF"
local DROPDOWN_ARROW_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\options\\dropdown_arrow.tga"
local template = BackdropTemplateMixin and "BackdropTemplate" or nil

local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 14,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local colors = {
  field = theme.surface,
  hover = theme.hover,
  selected = theme.selected,
  menu = theme.shell,
  border = theme.border,
  borderSoft = theme.borderSoft,
  text = theme.text,
  muted = theme.subtle,
}

local function SetBackdrop(frame, background, border)
  if frame.SetBackdrop then
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(background[1], background[2], background[3], background[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
  end
end

local function SortKeys(list)
  local keys = {}
  for key in pairs(list or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys, function(left, right)
    local leftNumber, rightNumber = tonumber(left), tonumber(right)
    if leftNumber and rightNumber then
      return leftNumber < rightNumber
    end
    return tostring(left) < tostring(right)
  end)
  return keys
end

local function UpdateControlStyle(self, hovered)
  local disabled = self.disabled
  SetBackdrop(self.control, hovered and not disabled and colors.hover or colors.field, hovered and not disabled and colors.border or colors.borderSoft)
  local color = disabled and colors.muted or colors.text
  self.text:SetTextColor(color[1], color[2], color[3], color[4])
  self.arrow:SetVertexColor(
    disabled and theme.subtle[1] or theme.accent[1],
    disabled and theme.subtle[2] or theme.accent[2],
    disabled and theme.subtle[3] or theme.accent[3],
    1
  )
end

local function SetSelectedText(self, value)
  self.text:SetText(value or "")
  self.text:Show()
end

local function NeedsCJKFont(value)
  return value == "zhCN" or value == "zhTW" or value == "koKR" or value == "jaJP"
end

local function IsLanguageList(list)
  return type(list) == "table" and list.enUS ~= nil and list.deDE ~= nil and list.jaJP ~= nil
end

local function FetchMediaPath(mediaType, value)
  if not LSM or type(value) ~= "string" or value == "" then
    return nil
  end
  return LSM:Fetch(mediaType, value, true)
end

local function ApplySelectedFont(label, value, list, mediaPreviewType, matchLanguageFieldFont)
  if mediaPreviewType == "font" then
    local path = FetchMediaPath("font", value)
    if path and MerfinPlus:SafeSetFontPath(label, path, 15) then
      return
    end
  end
  if matchLanguageFieldFont then
    MerfinPlus:SafeSetFontObject(label, GameFontHighlightSmall or GameFontNormal)
    return
  end
  if not next(list or {}) or IsLanguageList(list) then
    if NeedsCJKFont(value) then
      MerfinPlus:SafeSetFontPath(label, CJK_MENU_FONT, 15)
    elseif value == "ruRU" then
      MerfinPlus:SafeSetFontPath(label, CYRILLIC_MENU_FONT, 15)
    else
      -- The visible selected field is proven to render this loaded font object
      -- correctly on a fresh Classic login.
      MerfinPlus:SafeSetFontObject(label, GameFontHighlightSmall or GameFontNormal)
    end
    return
  end
  MerfinPlus:ApplyLocalizedFont(label, FONT, 15)
end

local function ApplyMenuFont(label, value, list, mediaPreviewType)
  if mediaPreviewType == "font" then
    local path = FetchMediaPath("font", value)
    if path and MerfinPlus:SafeSetFontPath(label, path, 15) then
      return
    end
  end
  -- Do not route every language through the 16 MB CJK font merely because the
  -- list contains CJK entries. On a cold client start that made all twelve
  -- rows wait for the large font to load. The actual client also proved that
  -- SetFontObject works for the visible selected field but not for these
  -- initially hidden rows, so every language row receives a direct font path.
  if IsLanguageList(list) then
    if NeedsCJKFont(value) then
      MerfinPlus:SafeSetFontPath(label, CJK_MENU_FONT, 15)
    elseif value == "ruRU" then
      MerfinPlus:SafeSetFontPath(label, CYRILLIC_MENU_FONT, 15)
    else
      MerfinPlus:SafeSetFontPath(label, LATIN_MENU_FONT, 15)
    end
    return
  end
  MerfinPlus:ApplyLocalizedFont(label, FONT, 15)
end

local function UpdateStatusBarPreview(texture, value)
  local path = FetchMediaPath("statusbar", value)
  if not texture or not path then
    if texture then
      texture:Hide()
    end
    return
  end
  texture:SetTexture(path)
  texture:SetTexCoord(0, 1, 0, 1)
  texture:SetVertexColor(1, 1, 1, 0.82)
  texture:Show()
end

local function UpdateSelectedText(self)
  if not self.multiselect then
    ApplySelectedFont(
      self.text,
      self.value,
      self.list,
      self.mediaPreviewType,
      self.matchLanguageFieldFont
    )
    SetSelectedText(self, self.list and self.list[self.value] or "")
    if self.mediaPreviewType == "statusbar" then
      UpdateStatusBarPreview(self.preview, self.value)
    elseif self.preview then
      self.preview:Hide()
    end
    return
  end
  MerfinPlus:ApplyLocalizedFont(self.text, FONT, 15)
  local selected = {}
  for _, key in ipairs(self.order or {}) do
    if self.itemValues[key] then
      selected[#selected + 1] = tostring(self.list[key] or key)
    end
  end
  SetSelectedText(self, table.concat(selected, ", "))
end

local function CloseMenu(self, fireEvent)
  local wasOpen = self.open
  if self.menu:IsShown() then
    self.menu:Hide()
  end
  self.open = nil
  if fireEvent and wasOpen then
    self:Fire("OnClosed")
  end
end

local function RefreshMenu(self)
  local count = #(self.order or {})
  local visible = math.min(count, MAX_VISIBLE_ROWS)
  local maximumOffset = math.max(0, count - visible)
  self.menuOffset = math.max(0, math.min(self.menuOffset or 0, maximumOffset))

  for rowIndex, button in ipairs(self.menuButtons) do
    local itemIndex = self.menuOffset + rowIndex
    local value = self.order[itemIndex]
    if rowIndex <= visible and value ~= nil then
      button.value = value
      ApplyMenuFont(button.label, value, self.list, self.mediaPreviewType)
      button.label:SetText(tostring(self.list[value] or value))
      if self.mediaPreviewType == "statusbar" then
        UpdateStatusBarPreview(button.preview, value)
      elseif button.preview then
        button.preview:Hide()
      end
      button.disabled = self.disabledItems[value] == true
      local selected = self.multiselect and self.itemValues[value] or self.value == value
      SetBackdrop(button, selected and colors.selected or colors.field, selected and colors.border or colors.borderSoft)
      local color = button.disabled and colors.muted or colors.text
      button.label:SetTextColor(color[1], color[2], color[3], color[4])
      button:Show()
    else
      button.value = nil
      if button.preview then
        button.preview:Hide()
      end
      button:Hide()
    end
  end

  self.menu:SetHeight(8 + (math.max(1, visible) * ROW_HEIGHT))
  -- The pullout is parented to UIParent, so it is not reached by the main
  -- options-frame font walk. Apply the same global +1 rule explicitly.
  MerfinPlus:ApplyUIFontSizeDelta(self.menu)
end

local function OpenMenu(self)
  if self.disabled then
    return
  end
  if self.open then
    CloseMenu(self, true)
    AceGUI:ClearFocus()
    return
  end
  self.open = true
  self.menuOffset = 0
  self.menu:ClearAllPoints()
  local visibleRows = math.min(#(self.order or {}), MAX_VISIBLE_ROWS)
  local estimatedHeight = 8 + (math.max(1, visibleRows) * ROW_HEIGHT)
  local controlBottom = self.control:GetBottom()
  if controlBottom and controlBottom < estimatedHeight + 12 then
    self.menu:SetPoint("BOTTOMLEFT", self.control, "TOPLEFT", 0, 2)
  else
    self.menu:SetPoint("TOPLEFT", self.control, "BOTTOMLEFT", 0, -2)
  end
  self.menu:SetWidth(self.pulloutWidth or self.control:GetWidth())
  self.menu:Show()
  RefreshMenu(self)
  AceGUI:SetFocus(self)
  self:Fire("OnOpened")
end

local methods = {
  OnAcquire = function(self)
    self:SetWidth(200)
    self:SetLabel()
    self:SetDisabled(false)
    self:SetMultiselect(false)
    self:SetPulloutWidth(nil)
    self.list = {}
    self.order = {}
    self.itemValues = {}
    self.disabledItems = {}
    self.value = nil
    self.matchLanguageFieldFont = nil
    self.menuOffset = 0
    if self.preview then
      self.preview:Hide()
    end
    SetSelectedText(self, "")
    CloseMenu(self)
  end,
  OnRelease = function(self)
    CloseMenu(self)
    MerfinPlus:RestoreUIFontSizeDelta(self.menu)
    self.frame:ClearAllPoints()
    self.list = nil
    self.order = nil
    self.itemValues = nil
    self.disabledItems = nil
    self.value = nil
    self.matchLanguageFieldFont = nil
  end,
  ClearFocus = function(self)
    if self.open then
      CloseMenu(self, true)
    end
  end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled and true or false
    if self.disabled then
      self.control:Disable()
      CloseMenu(self)
      self.label:SetTextColor(0.5, 0.5, 0.5)
    else
      self.control:Enable()
      self.label:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3])
    end
    UpdateControlStyle(self, false)
  end,
  SetText = function(self, text)
    SetSelectedText(self, text)
  end,
  SetLabel = function(self, text)
    MerfinPlus:ApplyLocalizedFont(self.label, FONT, 14)
    self.control:ClearAllPoints()
    if text and text ~= "" then
      self.label:SetText(text)
      self.label:Show()
      self.control:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -16)
      self.control:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, -16)
      self:SetHeight(48)
      self.alignoffset = 30
    else
      self.label:SetText("")
      self.label:Hide()
      self.control:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
      self.control:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
      self:SetHeight(30)
      self.alignoffset = 14
    end
  end,
  SetValue = function(self, value)
    self.value = value
    UpdateSelectedText(self)
    if self.open then
      RefreshMenu(self)
    end
  end,
  GetValue = function(self)
    return self.value
  end,
  RefreshTheme = function(self)
    UpdateControlStyle(self, false)
    RefreshMenu(self)
  end,
  SetList = function(self, list, order)
    self.list = list or {}
    self.order = {}
    if type(order) == "table" and #order > 0 then
      for _, value in ipairs(order) do
        if self.list[value] ~= nil then
          self.order[#self.order + 1] = value
        end
      end
    else
      self.order = SortKeys(self.list)
    end
    UpdateSelectedText(self)
    -- Populate hidden rows immediately. Besides making the first click
    -- deterministic, this starts loading the few CJK glyph rows during addon
    -- initialization instead of blocking the first menu open.
    RefreshMenu(self)
  end,
  AddItem = function(self, value, text)
    self.list[value] = text
    local found
    for _, key in ipairs(self.order) do
      if key == value then
        found = true
        break
      end
    end
    if not found then
      self.order[#self.order + 1] = value
    end
  end,
  SetMultiselect = function(self, enabled)
    self.multiselect = enabled and true or false
    UpdateSelectedText(self)
  end,
  GetMultiselect = function(self)
    return self.multiselect
  end,
  SetItemValue = function(self, value, checked)
    self.itemValues[value] = checked and true or nil
    UpdateSelectedText(self)
    if self.open then
      RefreshMenu(self)
    end
  end,
  SetItemDisabled = function(self, value, disabled)
    self.disabledItems[value] = disabled and true or nil
    if self.open then
      RefreshMenu(self)
    end
  end,
  SetPulloutWidth = function(self, width)
    self.pulloutWidth = width
  end,
}

local function Constructor(widgetType, mediaPreviewType)
  local frame = CreateFrame("Frame", nil, UIParent)
  local control = CreateFrame("Button", nil, frame, template)
  control:SetHeight(30)
  control:RegisterForClicks("AnyUp")
  SetBackdrop(control, colors.field, colors.borderSoft)

  local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  label:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, 0)
  label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, 0)
  label:SetJustifyH("LEFT")
  label:SetHeight(16)

  local preview = control:CreateTexture(nil, "ARTWORK", nil, 1)
  preview:SetPoint("TOPLEFT", control, "TOPLEFT", 5, -5)
  preview:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", -26, 5)
  preview:Hide()

  local text = control:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetPoint("TOPLEFT", control, "TOPLEFT", 10, -5)
  text:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", -28, 5)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("MIDDLE")
  text:SetShadowColor(0, 0, 0, 1)
  text:SetShadowOffset(1, -1)

  -- The project-local glyph points upward and is rotated for dropdown use.
  local arrow = control:CreateTexture(nil, "OVERLAY")
  arrow:SetTexture(DROPDOWN_ARROW_TEXTURE)
  arrow:SetSize(16, 16)
  arrow:SetPoint("RIGHT", control, "RIGHT", -7, 0)
  if arrow.SetRotation then
    arrow:SetRotation(math.pi)
  else
    arrow:SetTexCoord(1, 0, 1, 0)
  end

  local menu = CreateFrame("Frame", nil, UIParent, template)
  menu:SetFrameStrata("TOOLTIP")
  menu:SetClampedToScreen(true)
  menu:EnableMouseWheel(true)
  SetBackdrop(menu, colors.menu, colors.border)
  menu:Hide()

  local self = {
    type = widgetType,
    mediaPreviewType = mediaPreviewType,
    frame = frame,
    control = control,
    label = label,
    text = text,
    preview = preview,
    arrow = arrow,
    menu = menu,
    menuButtons = {},
  }
  frame.obj = self
  control.obj = self
  menu.obj = self

  for name, method in pairs(methods) do
    self[name] = method
  end

  for rowIndex = 1, MAX_VISIBLE_ROWS do
    local button = CreateFrame("Button", nil, menu, template)
    button:SetHeight(ROW_HEIGHT - 1)
    button:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -4 - ((rowIndex - 1) * ROW_HEIGHT))
    button:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -4, -4 - ((rowIndex - 1) * ROW_HEIGHT))
    SetBackdrop(button, colors.field, colors.borderSoft)

    button.preview = button:CreateTexture(nil, "ARTWORK", nil, 1)
    button.preview:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
    button.preview:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
    button.preview:Hide()

    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    MerfinPlus:ApplyLocalizedFont(button.label, FONT, 15)
    button.label:SetPoint("TOPLEFT", button, "TOPLEFT", 9, -4)
    button.label:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -9, 4)
    button.label:SetJustifyH("LEFT")
    button.label:SetJustifyV("MIDDLE")
    button.label:SetShadowColor(0, 0, 0, 1)
    button.label:SetShadowOffset(1, -1)

    button:SetScript("OnEnter", function(row)
      if not row.disabled then
        SetBackdrop(row, colors.hover, colors.border)
      end
    end)
    button:SetScript("OnLeave", function()
      RefreshMenu(self)
    end)
    button:SetScript("OnClick", function(row)
      local value = row.value
      if value == nil or row.disabled then
        return
      end
      if self.multiselect then
        local checked = not self.itemValues[value]
        self.itemValues[value] = checked and true or nil
        UpdateSelectedText(self)
        self:Fire("OnValueChanged", value, checked)
        RefreshMenu(self)
      else
        self:SetValue(value)
        self:Fire("OnValueChanged", value)
        CloseMenu(self, true)
        AceGUI:ClearFocus()
      end
    end)
    self.menuButtons[rowIndex] = button
  end

  control:SetScript("OnEnter", function()
    UpdateControlStyle(self, true)
    self:Fire("OnEnter")
  end)
  control:SetScript("OnLeave", function()
    UpdateControlStyle(self, false)
    self:Fire("OnLeave")
  end)
  control:SetScript("OnClick", function()
    OpenMenu(self)
  end)
  frame:SetScript("OnShow", function()
    -- Rebind after the widget becomes effectively visible. Classic can retain
    -- an empty render state for text assigned while an ancestor was hidden.
    UpdateSelectedText(self)
  end)
  menu:SetScript("OnMouseWheel", function(_, delta)
    local count = #(self.order or {})
    local maximumOffset = math.max(0, count - math.min(count, MAX_VISIBLE_ROWS))
    self.menuOffset = math.max(0, math.min(maximumOffset, (self.menuOffset or 0) - delta))
    RefreshMenu(self)
  end)
  frame:SetScript("OnHide", function()
    CloseMenu(self, true)
  end)

  AceGUI:RegisterAsWidget(self)
  return self
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, function()
  return Constructor(WIDGET_TYPE)
end, WIDGET_VERSION)
AceGUI:RegisterWidgetType(FONT_WIDGET_TYPE, function()
  return Constructor(FONT_WIDGET_TYPE, "font")
end, WIDGET_VERSION)
AceGUI:RegisterWidgetType(STATUSBAR_WIDGET_TYPE, function()
  return Constructor(STATUSBAR_WIDGET_TYPE, "statusbar")
end, WIDGET_VERSION)
