-- AceGUI controls for inline MerfinPlus export copying.

local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
local template = BackdropTemplateMixin and "BackdropTemplate" or nil

local EXPORT_EDIT_TYPE = "MerfinPlusExportEditBox"
local EXPORT_EDIT_VERSION = 2
local COPY_BUTTON_TYPE = "MerfinPlusCopyButton"
local COPY_BUTTON_VERSION = 2
local RIGHT_BUTTON_TYPE = "MerfinPlusRightButton"
local RIGHT_BUTTON_VERSION = 1
local LOOT_ACTIONS_TYPE = "MerfinPlusLootActions"
local LOOT_ACTIONS_VERSION = 2
local GUILD_ACTIONS_TYPE = "MerfinPlusGuildActions"
local GUILD_ACTIONS_VERSION = 1
local UI_FONT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"

local function ApplyUIFont(fontObject, size)
  MerfinPlus:ApplyLocalizedFont(fontObject, UI_FONT, size or 13)
end

local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 14,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local function SetBackdrop(frame, background, border)
  if frame.SetBackdrop then
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(background[1], background[2], background[3], background[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
  end
end

local actionButtonColors = {
  normal = {
    background = theme.surface,
    border = theme.border,
    text = theme.text,
  },
  hover = {
    background = theme.hover,
    border = theme.accent,
    text = theme.accentBright,
  },
  pressed = {
    background = theme.pressed,
    border = theme.accentBright,
    text = theme.text,
  },
  disabled = {
    background = { 0.025, 0.028, 0.031, 0.9 },
    border = { 0.30, 0.30, 0.28, 0.65 },
    text = { 0.5, 0.5, 0.5, 1 },
  },
}

local function ApplyActionButtonVisual(button)
  local state
  if not button:IsEnabled() then
    state = actionButtonColors.disabled
  elseif button.actionPressed then
    state = actionButtonColors.pressed
  elseif button.actionHovered then
    state = actionButtonColors.hover
  else
    state = actionButtonColors.normal
  end

  SetBackdrop(button, state.background, state.border)
  if button.actionText then
    button.actionText:SetTextColor(unpack(state.text))
    button.actionText:ClearAllPoints()
    button.actionText:SetPoint("CENTER", button, "CENTER", button.actionPressed and 1 or 0, button.actionPressed and -1 or 0)
  end
end

local function InstallActionButtonVisuals(button, text)
  button.actionText = text
  button:SetScript("OnEnter", function(self)
    self.actionHovered = true
    ApplyActionButtonVisual(self)
  end)
  button:SetScript("OnLeave", function(self)
    self.actionHovered = nil
    self.actionPressed = nil
    ApplyActionButtonVisual(self)
  end)
  button:SetScript("OnMouseDown", function(self, mouseButton)
    if mouseButton == "LeftButton" and self:IsEnabled() then
      self.actionPressed = true
      ApplyActionButtonVisual(self)
    end
  end)
  button:SetScript("OnMouseUp", function(self)
    self.actionPressed = nil
    ApplyActionButtonVisual(self)
  end)
  button:SetScript("OnEnable", function(self)
    ApplyActionButtonVisual(self)
  end)
  button:SetScript("OnDisable", function(self)
    self.actionPressed = nil
    ApplyActionButtonVisual(self)
  end)
  button:SetScript("OnHide", function(self)
    self.actionHovered = nil
    self.actionPressed = nil
  end)
  ApplyActionButtonVisual(button)
end

local function LayoutExportEditBox(self)
  self:SetHeight((self.numlines * 14) + 19 + self.labelHeight)
  if self.labelHeight == 0 then
    self.scrollBar:SetPoint("TOP", self.frame, "TOP", 0, -19)
  else
    self.scrollBar:SetPoint("TOP", self.label, "BOTTOM", 0, -19)
  end
  self.scrollBar:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 21)
  self.scrollBG:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 4)
end

local function OnCursorChanged(editBox, _, y, _, cursorHeight)
  local scrollFrame = editBox.obj.scrollFrame
  y = -y
  local offset = scrollFrame:GetVerticalScroll()
  if y < offset then
    scrollFrame:SetVerticalScroll(y)
  else
    y = y + cursorHeight - scrollFrame:GetHeight()
    if y > offset then
      scrollFrame:SetVerticalScroll(y)
    end
  end
end

local function OnVerticalScroll(scrollFrame, offset)
  local editBox = scrollFrame.obj.editBox
  editBox:SetHitRectInsets(0, 0, offset, editBox:GetHeight() - offset - scrollFrame:GetHeight())
end

local function OnScrollRangeChanged(scrollFrame, _, verticalRange)
  if verticalRange == 0 then
    scrollFrame.obj.editBox:SetHitRectInsets(0, 0, 0, 0)
  else
    OnVerticalScroll(scrollFrame, scrollFrame:GetVerticalScroll())
  end
end

local function OnExportEditFocusGained(editBox)
  AceGUI:SetFocus(editBox.obj)
  editBox.obj:Fire("OnEditFocusGained")
end

local exportEditMethods = {
  OnAcquire = function(self)
    self:SetWidth(200)
    self:SetNumLines(4)
    self:SetLabel("")
    self:SetDisabled(false)
    self:SetMaxLetters(0)
    self:SetText("")
  end,
  OnRelease = function(self)
    self:ClearFocus()
    MerfinPlus:UnregisterExportTextWidget(self.exportFieldKey, self)
    self.exportFieldKey = nil
  end,
  SetCustomData = function(self, fieldKey)
    MerfinPlus:UnregisterExportTextWidget(self.exportFieldKey, self)
    self.exportFieldKey = fieldKey
    MerfinPlus:RegisterExportTextWidget(fieldKey, self)
  end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled and true or false
    if self.disabled then
      self.editBox:ClearFocus()
      self.editBox:EnableMouse(false)
      self.editBox:SetTextColor(0.5, 0.5, 0.5)
      self.label:SetTextColor(0.5, 0.5, 0.5)
      self.scrollFrame:EnableMouse(false)
    else
      self.editBox:EnableMouse(true)
      self.editBox:SetTextColor(0.96, 0.96, 0.93)
      self.label:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3])
      self.scrollFrame:EnableMouse(true)
    end
  end,
  SetLabel = function(self, text)
    if text and text ~= "" then
      self.label:SetText(text)
      self.label:Show()
      self.labelHeight = 10
    else
      self.label:SetText("")
      self.label:Hide()
      self.labelHeight = 0
    end
    LayoutExportEditBox(self)
  end,
  SetNumLines = function(self, value)
    self.numlines = math.max(4, tonumber(value) or 4)
    LayoutExportEditBox(self)
  end,
  SetText = function(self, text)
    self.editBox:SetText(text or "")
  end,
  GetText = function(self)
    return self.editBox:GetText()
  end,
  SetMaxLetters = function(self, value)
    self.editBox:SetMaxLetters(value or 0)
  end,
  DisableButton = function() end,
  ClearFocus = function(self)
    self.editBox:ClearFocus()
  end,
  SetFocus = function(self)
    self.editBox:SetFocus()
  end,
  HighlightText = function(self, from, to)
    self.editBox:HighlightText(from, to)
  end,
  GetCursorPosition = function(self)
    return self.editBox:GetCursorPosition()
  end,
  SetCursorPosition = function(self, ...)
    return self.editBox:SetCursorPosition(...)
  end,
}

local function ExportEditConstructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:Hide()
  local widgetNumber = AceGUI:GetNextWidgetNum(EXPORT_EDIT_TYPE)
  local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  ApplyUIFont(label, 12)
  label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -4)
  label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -4)
  label:SetJustifyH("LEFT")
  label:SetHeight(10)

  local scrollBG = CreateFrame("Frame", nil, frame, template)
  SetBackdrop(scrollBG, theme.shell, theme.border)
  local scrollFrameName = EXPORT_EDIT_TYPE .. tostring(widgetNumber) .. "ScrollFrame"
  local scrollFrame = CreateFrame("ScrollFrame", scrollFrameName, frame, "UIPanelScrollFrameTemplate")
  local scrollBar = _G[scrollFrameName .. "ScrollBar"]
  scrollBar:ClearAllPoints()
  scrollBar:SetPoint("TOP", label, "BOTTOM", 0, -19)
  scrollBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, 21)
  scrollBar:SetPoint("RIGHT", frame, "RIGHT")
  scrollBG:SetPoint("TOPRIGHT", scrollBar, "TOPLEFT", 0, 19)
  scrollBG:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 4)
  scrollFrame:SetPoint("TOPLEFT", scrollBG, "TOPLEFT", 5, -6)
  scrollFrame:SetPoint("BOTTOMRIGHT", scrollBG, "BOTTOMRIGHT", -4, 4)
  scrollFrame:EnableMouseWheel(true)

  -- Keep the template's scrolling behavior, but remove its visual chrome.
  -- Hiding the actual template scrollbar also hides its arrows and thumb.
  scrollBar:SetAlpha(0)
  scrollBar:EnableMouse(false)
  scrollBar:Hide()
  scrollBar:HookScript("OnShow", function(selfScrollBar)
    selfScrollBar:Hide()
  end)

  local editBox = CreateFrame("EditBox", nil, scrollFrame)
  editBox:SetAllPoints()
  editBox:SetFontObject(ChatFontNormal)
  editBox:SetMultiLine(true)
  editBox:EnableMouse(true)
  editBox:SetAutoFocus(false)
  editBox:SetCountInvisibleLetters(false)
  scrollFrame:SetScrollChild(editBox)

  local widget = {
    type = EXPORT_EDIT_TYPE,
    frame = frame,
    label = label,
    labelHeight = 10,
    numlines = 4,
    scrollBG = scrollBG,
    scrollFrame = scrollFrame,
    scrollBar = scrollBar,
    editBox = editBox,
  }
  frame.obj = widget
  scrollFrame.obj = widget
  editBox.obj = widget
  for method, func in pairs(exportEditMethods) do
    widget[method] = func
  end

  scrollFrame:SetScript("OnMouseUp", function(selfFrame)
    local box = selfFrame.obj.editBox
    box:SetFocus()
    box:SetCursorPosition(box:GetNumLetters())
  end)
  scrollFrame:SetScript("OnMouseWheel", function(selfFrame, delta)
    local range = selfFrame:GetVerticalScrollRange() or 0
    local offset = selfFrame:GetVerticalScroll() or 0
    selfFrame:SetVerticalScroll(math.max(0, math.min(range, offset - (delta * 32))))
  end)
  scrollFrame:SetScript("OnSizeChanged", function(selfFrame, width)
    selfFrame.obj.editBox:SetWidth(width)
  end)
  scrollFrame:HookScript("OnVerticalScroll", OnVerticalScroll)
  scrollFrame:HookScript("OnScrollRangeChanged", OnScrollRangeChanged)
  editBox:SetScript("OnCursorChanged", OnCursorChanged)
  editBox:SetScript("OnEditFocusGained", OnExportEditFocusGained)
  editBox:SetScript("OnEditFocusLost", function(selfBox)
    selfBox:HighlightText(0, 0)
    selfBox.obj:Fire("OnEditFocusLost")
  end)
  editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
  editBox:SetScript("OnTextChanged", function(selfBox, userInput)
    if userInput then
      selfBox.obj:Fire("OnTextChanged", selfBox:GetText())
    end
  end)
  editBox:SetScript("OnTextSet", function(selfBox)
    selfBox:HighlightText(0, 0)
    selfBox:SetCursorPosition(0)
  end)

  return AceGUI:RegisterAsWidget(widget)
end

local copyButtonMethods = {
  OnAcquire = function(self)
    self:SetWidth(200)
    self:SetText("")
    self:SetDisabled(false)
    self.feedbackToken = (self.feedbackToken or 0) + 1
    self.feedback:SetText("")
    self.exportFieldKey = nil
  end,
  OnRelease = function(self)
    self.feedbackToken = (self.feedbackToken or 0) + 1
    self.feedback:SetText("")
    self.exportFieldKey = nil
  end,
  SetCustomData = function(self, fieldKey)
    self.exportFieldKey = fieldKey
  end,
  SetText = function(self, text)
    self.text:SetText(text or "")
  end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled and true or false
    if self.disabled then
      self.button:Disable()
      self.text:SetTextColor(0.5, 0.5, 0.5)
    else
      self.button:Enable()
      self.text:SetTextColor(0.96, 0.96, 0.93)
    end
  end,
}

local function CopyButtonConstructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:Hide()
  frame:SetHeight(26)
  local button = CreateFrame("Button", nil, frame, template)
  button:SetPoint("TOPLEFT")
  button:SetPoint("BOTTOMLEFT")
  button:SetWidth(82)
  SetBackdrop(button, theme.surface, theme.border)

  local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(buttonText, 13)
  buttonText:SetPoint("CENTER")
  buttonText:SetText(MerfinPlus:T("Copy"))
  local feedback = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(feedback, 12)
  feedback:SetPoint("LEFT", button, "RIGHT", 8, 0)
  feedback:SetTextColor(0.45, 0.9, 0.45)

  local widget = {
    type = COPY_BUTTON_TYPE,
    frame = frame,
    button = button,
    text = buttonText,
    feedback = feedback,
  }
  frame.obj = widget
  button.obj = widget
  for method, func in pairs(copyButtonMethods) do
    widget[method] = func
  end

  button:SetScript("OnClick", function(selfButton)
    local self = selfButton.obj
    if self.disabled then
      return
    end
    -- Focus and select the concrete visible EditBox from this hardware click.
    -- AceConfig refreshes and releases execute controls after OnClick, which
    -- would also rebuild the target EditBox and discard its selection. Copy is
    -- intentionally handled here without firing that refresh path.
    local selected = self.exportFieldKey
      and MerfinPlus:FocusExportTextField(self.exportFieldKey)
    if selected then
      self.feedbackToken = (self.feedbackToken or 0) + 1
      local token = self.feedbackToken
      self.feedback:SetText(MerfinPlus:T("Press CTRL+C now"))
      if C_Timer and C_Timer.After then
        C_Timer.After(1.5, function()
          if self.feedbackToken == token then
            self.feedback:SetText("")
          end
        end)
      end
    else
      self.feedbackToken = (self.feedbackToken or 0) + 1
      self.feedback:SetText("")
    end
  end)

  return AceGUI:RegisterAsWidget(widget)
end

local rightButtonMethods = {
  OnAcquire = function(self)
    self:SetWidth(200)
    self:SetText("")
    self:SetDisabled(false)
  end,
  SetText = function(self, text)
    self.text:SetText(text or "")
  end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled and true or false
    if self.disabled then
      self.button:Disable()
      self.text:SetTextColor(0.5, 0.5, 0.5)
    else
      self.button:Enable()
      self.text:SetTextColor(0.96, 0.96, 0.93)
    end
  end,
}

local function RightButtonConstructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:Hide()
  frame:SetHeight(26)
  local button = CreateFrame("Button", nil, frame, template)
  button:SetPoint("TOPRIGHT")
  button:SetPoint("BOTTOMRIGHT")
  button:SetWidth(82)
  SetBackdrop(button, theme.surface, theme.border)

  local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(buttonText, 13)
  buttonText:SetPoint("CENTER")

  local widget = {
    type = RIGHT_BUTTON_TYPE,
    frame = frame,
    button = button,
    text = buttonText,
  }
  frame.obj = widget
  button.obj = widget
  for method, func in pairs(rightButtonMethods) do
    widget[method] = func
  end

  button:SetScript("OnClick", function(selfButton)
    local self = selfButton.obj
    if not self.disabled then
      self:Fire("OnClick")
    end
  end)

  return AceGUI:RegisterAsWidget(widget)
end

local lootActionsMethods = {
  OnAcquire = function(self)
    self:SetWidth(200)
    self:SetDisabled(false)
    self.copyText:SetText(MerfinPlus:T("Copy"))
    self.deleteText:SetText(MerfinPlus:T("Delete"))
    self.feedbackToken = (self.feedbackToken or 0) + 1
    self.feedback:SetText("")
  end,
  OnRelease = function(self)
    self.feedbackToken = (self.feedbackToken or 0) + 1
    self.feedback:SetText("")
  end,
  SetText = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled and true or false
    if self.disabled then
      self.copyButton:Disable()
      self.deleteButton:Disable()
    else
      self.copyButton:Enable()
      self.deleteButton:Enable()
    end
    ApplyActionButtonVisual(self.copyButton)
    ApplyActionButtonVisual(self.deleteButton)
  end,
}

local function LootActionsConstructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:Hide()
  frame:SetHeight(26)

  local copyButton = CreateFrame("Button", nil, frame, template)
  copyButton:SetWidth(82)

  local copyText = copyButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(copyText, 13)
  copyText:SetPoint("CENTER")
  copyText:SetText(MerfinPlus:T("Copy"))

  local feedback = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(feedback, 12)
  feedback:SetPoint("LEFT", copyButton, "RIGHT", 8, 0)
  feedback:SetTextColor(0.45, 0.9, 0.45)

  local deleteButton = CreateFrame("Button", nil, frame, template)
  deleteButton:SetPoint("TOPLEFT")
  deleteButton:SetPoint("BOTTOMLEFT")
  deleteButton:SetWidth(82)

  local deleteText = deleteButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(deleteText, 13)
  deleteText:SetPoint("CENTER")
  deleteText:SetText(MerfinPlus:T("Delete"))

  copyButton:SetPoint("TOPLEFT", deleteButton, "TOPRIGHT", 8, 0)
  copyButton:SetPoint("BOTTOMLEFT", deleteButton, "BOTTOMRIGHT", 8, 0)
  InstallActionButtonVisuals(deleteButton, deleteText)
  InstallActionButtonVisuals(copyButton, copyText)

  local widget = {
    type = LOOT_ACTIONS_TYPE,
    frame = frame,
    copyButton = copyButton,
    copyText = copyText,
    feedback = feedback,
    deleteButton = deleteButton,
    deleteText = deleteText,
  }
  frame.obj = widget
  copyButton.obj = widget
  deleteButton.obj = widget
  for method, func in pairs(lootActionsMethods) do
    widget[method] = func
  end

  copyButton:SetScript("OnClick", function(selfButton)
    local self = selfButton.obj
    if self.disabled then return end
    local selected = MerfinPlus:FocusExportTextField("loot")
    self.feedbackToken = (self.feedbackToken or 0) + 1
    local token = self.feedbackToken
    self.feedback:SetText(selected and MerfinPlus:T("Press CTRL+C now") or "")
    if selected and C_Timer and C_Timer.After then
      C_Timer.After(1.5, function()
        if self.feedbackToken == token then
          self.feedback:SetText("")
        end
      end)
    end
  end)

  deleteButton:SetScript("OnClick", function(selfButton)
    local self = selfButton.obj
    if not self.disabled then
      MerfinPlus:ConfirmDeleteSelectedLootSession()
    end
  end)

  return AceGUI:RegisterAsWidget(widget)
end

local function RefreshGuildActionButtons(self)
  if self.disabled then
    self.generateButton:Disable()
    self.copyButton:Disable()
  else
    self.generateButton:Enable()
    if MerfinPlus:GetExportUIState().guildExportText == "" then
      self.copyButton:Disable()
    else
      self.copyButton:Enable()
    end
  end
  ApplyActionButtonVisual(self.generateButton)
  ApplyActionButtonVisual(self.copyButton)
end

local guildActionsMethods = {
  OnAcquire = function(self)
    self:SetWidth(200)
    self.disabled = nil
    self.generateText:SetText(MerfinPlus:T("Generate"))
    self.copyText:SetText(MerfinPlus:T("Copy"))
    self.feedbackToken = (self.feedbackToken or 0) + 1
    self.feedback:SetText("")
    RefreshGuildActionButtons(self)
  end,
  OnRelease = function(self)
    self.feedbackToken = (self.feedbackToken or 0) + 1
    self.feedback:SetText("")
  end,
  SetText = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled and true or false
    RefreshGuildActionButtons(self)
  end,
}

local function GuildActionsConstructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:Hide()
  frame:SetHeight(26)

  local generateButton = CreateFrame("Button", nil, frame, template)
  generateButton:SetPoint("TOPLEFT")
  generateButton:SetPoint("BOTTOMLEFT")
  generateButton:SetWidth(82)

  local generateText = generateButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(generateText, 13)
  generateText:SetPoint("CENTER")
  generateText:SetText(MerfinPlus:T("Generate"))

  local copyButton = CreateFrame("Button", nil, frame, template)
  copyButton:SetPoint("TOPLEFT", generateButton, "TOPRIGHT", 8, 0)
  copyButton:SetPoint("BOTTOMLEFT", generateButton, "BOTTOMRIGHT", 8, 0)
  copyButton:SetWidth(82)

  local copyText = copyButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(copyText, 13)
  copyText:SetPoint("CENTER")
  copyText:SetText(MerfinPlus:T("Copy"))

  local feedback = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyUIFont(feedback, 12)
  feedback:SetPoint("LEFT", copyButton, "RIGHT", 8, 0)
  feedback:SetTextColor(0.45, 0.9, 0.45)

  InstallActionButtonVisuals(generateButton, generateText)
  InstallActionButtonVisuals(copyButton, copyText)

  local widget = {
    type = GUILD_ACTIONS_TYPE,
    frame = frame,
    generateButton = generateButton,
    generateText = generateText,
    copyButton = copyButton,
    copyText = copyText,
    feedback = feedback,
  }
  frame.obj = widget
  generateButton.obj = widget
  copyButton.obj = widget
  for method, func in pairs(guildActionsMethods) do
    widget[method] = func
  end

  generateButton:SetScript("OnClick", function(selfButton)
    local self = selfButton.obj
    if not self.disabled then
      self:Fire("OnClick")
    end
  end)

  copyButton:SetScript("OnClick", function(selfButton)
    local self = selfButton.obj
    if self.disabled or not selfButton:IsEnabled() then return end
    local selected = MerfinPlus:FocusExportTextField("guild")
    self.feedbackToken = (self.feedbackToken or 0) + 1
    local token = self.feedbackToken
    self.feedback:SetText(selected and MerfinPlus:T("Press CTRL+C now") or "")
    if selected and C_Timer and C_Timer.After then
      C_Timer.After(1.5, function()
        if self.feedbackToken == token then
          self.feedback:SetText("")
        end
      end)
    end
  end)

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(EXPORT_EDIT_TYPE, ExportEditConstructor, EXPORT_EDIT_VERSION)
AceGUI:RegisterWidgetType(COPY_BUTTON_TYPE, CopyButtonConstructor, COPY_BUTTON_VERSION)
AceGUI:RegisterWidgetType(RIGHT_BUTTON_TYPE, RightButtonConstructor, RIGHT_BUTTON_VERSION)
AceGUI:RegisterWidgetType(LOOT_ACTIONS_TYPE, LootActionsConstructor, LOOT_ACTIONS_VERSION)
AceGUI:RegisterWidgetType(GUILD_ACTIONS_TYPE, GuildActionsConstructor, GUILD_ACTIONS_VERSION)
