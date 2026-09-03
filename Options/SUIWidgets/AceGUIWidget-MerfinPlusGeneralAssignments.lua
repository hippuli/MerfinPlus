-- Guild-Manager-style General Assignments view for the MerfinPlus AceConfig shell.

local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme

local WIDGET_TYPE = "MerfinPlusGeneralAssignments"
local WIDGET_VERSION = 2
local MAX_VISIBLE_IMPORTS = 8
local IMPORT_ROW_HEIGHT = 30
local FONT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local DROPDOWN_ARROW_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\options\\dropdown_arrow.tga"
local DEFAULT_FONT_HEIGHT = 14
local template = BackdropTemplateMixin and "BackdropTemplate" or nil

local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 14,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local colors = {
  field = theme.surface,
  panel = theme.canvas,
  row = theme.surface,
  heading = theme.selected,
  hover = theme.hover,
  selected = theme.selected,
  pressed = theme.pressed,
  menu = theme.shell,
  border = theme.border,
  borderSoft = theme.borderSoft,
  text = theme.text,
  muted = theme.muted,
  good = { 0.42, 0.90, 0.46, 1 },
  red = { 0.95, 0.22, 0.18, 1 },
  redDark = { 0.18, 0.035, 0.025, 1 },
}

local function SetBackdrop(frame, background, border)
  if frame.SetBackdrop then
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(background[1], background[2], background[3], background[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
  end
end

local function ApplyNativeFont(fontObject, fontFile, height, flags)
  return MerfinPlus:SafeSetFontPath(fontObject, fontFile, height, flags)
end

do
  local nativeCallCount = 0
  local forwardedArgumentCount = 0
  local probe = {
    SetFont = function(_, ...)
      nativeCallCount = nativeCallCount + 1
      forwardedArgumentCount = select("#", ...)
    end,
  }
  local rejected = ApplyNativeFont(probe, "LeftButton", false, nil)
  assert(rejected == false and nativeCallCount == 0, "General Assignments font guard must reject invalid font values")
  local applied = ApplyNativeFont(probe, FONT, DEFAULT_FONT_HEIGHT, false)
  assert(applied == true and nativeCallCount == 1 and forwardedArgumentCount == 2, "General Assignments font guard must forward two valid arguments")
  local cyrillicApplied = ApplyNativeFont(probe, "Fonts\\FRIZQT___CYR.TTF", DEFAULT_FONT_HEIGHT, nil)
  assert(cyrillicApplied == true and nativeCallCount == 2 and forwardedArgumentCount == 2, "General Assignments font guard must accept the Cyrillic fallback")
end

local function ApplyWidgetFont(fontObject, size, flags)
  local height = tonumber(size)
  if not height or height <= 0 then
    height = DEFAULT_FONT_HEIGHT
  end
  local fontPath = MerfinPlus:ResolveLocalizedFontPath(FONT)
  if ApplyNativeFont(fontObject, fontPath, height, flags) then
    return true
  end
  return MerfinPlus:ApplyLocalizedFont(fontObject, FONT, height, flags) ~= nil
end

local function SetIconTexture(texture, value)
  local fallback
  if type(value) == "table" then
    fallback = value.fallback
    value = value.path
  end
  if not value and not fallback then
    texture:SetTexture(nil)
    texture:Hide()
    return false
  end
  local applied
  if value then
    applied = texture:SetTexture(value)
  end
  if (not value or applied == false) and fallback then
    applied = texture:SetTexture(fallback)
  end
  if applied == false then
    texture:SetTexture(nil)
    texture:Hide()
    return false
  end
  texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  texture:Show()
  return true
end

local function SetActionButtonStyle(button, hovered, pressed)
  if button.disabled then
    SetBackdrop(button, colors.field, colors.borderSoft)
    button.label:SetTextColor(0.45, 0.45, 0.43, 1)
  elseif button.danger then
    SetBackdrop(button, pressed and colors.redDark or (hovered and { 0.24, 0.045, 0.035, 1 } or colors.field), colors.red)
    button.label:SetTextColor(1, 0.34, 0.28, 1)
  else
    SetBackdrop(button, pressed and colors.pressed or (hovered and colors.hover or colors.field), hovered and colors.border or colors.borderSoft)
    button.label:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  end
end

local function SetActionButtonEnabled(button, enabled)
  button.disabled = not enabled
  if enabled then
    button:Enable()
  else
    button:Disable()
  end
  SetActionButtonStyle(button, false, false)
end

local function CreateActionButton(parent, label, width, danger)
  local button = CreateFrame("Button", nil, parent, template)
  button:SetSize(width, 30)
  button:RegisterForClicks("AnyUp")
  button.danger = danger == true
  button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(button.label, 14)
  button.label:SetPoint("CENTER")
  button.label:SetText(label)
  SetActionButtonStyle(button, false, false)
  button:SetScript("OnEnter", function(self)
    SetActionButtonStyle(self, true, false)
  end)
  button:SetScript("OnLeave", function(self)
    SetActionButtonStyle(self, false, false)
  end)
  button:SetScript("OnMouseDown", function(self)
    SetActionButtonStyle(self, true, true)
  end)
  button:SetScript("OnMouseUp", function(self)
    SetActionButtonStyle(self, self:IsMouseOver(), false)
  end)
  return button
end

local function CloseImportMenu(self)
  self.importMenu:Hide()
  self.menuOpen = nil
end

local function GetVisibleImport(self, rowIndex)
  local imports = MerfinPlus:GetGeneralAssignmentImports()
  local index = #imports - (self.menuOffset or 0) - rowIndex + 1
  return imports[index]
end

local function RefreshImportMenu(self)
  local imports = MerfinPlus:GetGeneralAssignmentImports()
  local visible = math.min(#imports, MAX_VISIBLE_IMPORTS)
  local maximumOffset = math.max(0, #imports - visible)
  self.menuOffset = math.max(0, math.min(self.menuOffset or 0, maximumOffset))

  for rowIndex, option in ipairs(self.importOptions) do
    local entry = rowIndex <= visible and GetVisibleImport(self, rowIndex) or nil
    if entry then
      option.entryID = entry.id
      option.nameText:SetText(MerfinPlus:GetGeneralAssignmentImportName(entry))
      option.timeText:SetText(MerfinPlus:GetGeneralAssignmentImportTimestamp(entry))
      local selected = MerfinPlus:GetGeneralAssignmentStorage().activeGeneralImportId == entry.id
      SetBackdrop(option, selected and colors.selected or colors.field, selected and colors.border or colors.borderSoft)
      option:Show()
    else
      option.entryID = nil
      option:Hide()
    end
  end

  self.importMenu:SetHeight(8 + (math.max(1, visible) * IMPORT_ROW_HEIGHT))
  self.importMenu:SetWidth(math.max(420, self.frame:GetWidth() - 34))
end

local function OpenImportMenu(self)
  if self.disabled or #MerfinPlus:GetGeneralAssignmentImports() == 0 then
    return
  end
  if self.menuOpen then
    CloseImportMenu(self)
    return
  end
  self.menuOpen = true
  self.menuOffset = 0
  self.importMenu:ClearAllPoints()
  self.importMenu:SetPoint("TOPLEFT", self.dropdown, "BOTTOMLEFT", 0, -2)
  RefreshImportMenu(self)
  self.importMenu:Show()
end

local function ResetRow(row)
  row:EnableMouse(false)
  row:SetScript("OnEnter", nil)
  row:SetScript("OnLeave", nil)
  row:SetScript("OnMouseUp", nil)
  row.section:Hide()
  row.classIcon:Hide()
  row.specIcon:Hide()
  row.roleIcon:Hide()
  row.spellIcon:Hide()
  row.targetIcon:Hide()
  row.name:Hide()
  row.detail:Hide()
  row.target:Hide()
end

local function AcquireRow(self, index)
  local row = self.rows[index]
  if row then
    return row
  end

  row = CreateFrame("Button", nil, self.scrollChild, template)
  SetBackdrop(row, colors.row, colors.borderSoft)

  row.section = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyWidgetFont(row.section, 15)
  row.section:SetJustifyH("LEFT")

  row.classIcon = row:CreateTexture(nil, "ARTWORK")
  row.classIcon:SetSize(23, 23)
  row.classIcon:SetPoint("LEFT", row, "LEFT", 10, 0)

  row.specIcon = row:CreateTexture(nil, "ARTWORK")
  row.specIcon:SetSize(23, 23)
  row.specIcon:SetPoint("LEFT", row.classIcon, "RIGHT", 6, 0)

  row.roleIcon = row:CreateTexture(nil, "ARTWORK")
  row.roleIcon:SetSize(23, 23)
  row.roleIcon:SetPoint("LEFT", row.specIcon, "RIGHT", 6, 0)

  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(row.name, 14)
  row.name:SetPoint("LEFT", row.roleIcon, "RIGHT", 8, 0)
  row.name:SetWidth(96)
  row.name:SetJustifyH("LEFT")

  row.spellIcon = row:CreateTexture(nil, "ARTWORK")
  row.spellIcon:SetSize(23, 23)
  row.spellIcon:SetPoint("LEFT", row, "LEFT", 205, 0)

  row.detail = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(row.detail, 13)
  row.detail:SetPoint("LEFT", row, "LEFT", 236, 0)
  row.detail:SetWidth(158)
  row.detail:SetJustifyH("LEFT")
  if row.detail.SetWordWrap then
    row.detail:SetWordWrap(false)
  end

  row.target = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(row.target, 13)
  row.target:SetPoint("LEFT", row, "LEFT", 405, 0)
  row.target:SetPoint("RIGHT", row, "RIGHT", -10, 0)
  row.target:SetJustifyH("LEFT")
  if row.target.SetWordWrap then
    row.target:SetWordWrap(false)
  end

  row.targetIcon = row:CreateTexture(nil, "ARTWORK")
  row.targetIcon:SetSize(23, 23)
  row.targetIcon:SetPoint("LEFT", row, "LEFT", 405, 0)

  self.rows[index] = row
  return row
end

local function ConfigureSectionRow(self, row, entry, sectionName, count)
  ResetRow(row)
  local collapsed = MerfinPlus:IsGeneralAssignmentSectionCollapsed(entry, sectionName)
  local label, icon = MerfinPlus:GetGeneralAssignmentSectionDisplay(sectionName)
  SetBackdrop(row, colors.heading, collapsed and colors.borderSoft or colors.border)

  row.section:ClearAllPoints()
  if icon then
    row.classIcon:ClearAllPoints()
    row.classIcon:SetPoint("LEFT", row, "LEFT", 10, 0)
    SetIconTexture(row.classIcon, icon)
    row.section:SetPoint("LEFT", row.classIcon, "RIGHT", 8, 0)
  else
    row.section:SetPoint("LEFT", row, "LEFT", 12, 0)
  end
  row.section:SetPoint("RIGHT", row, "RIGHT", -12, 0)
  row.section:SetText((collapsed and "+ " or "- ") .. tostring(label or sectionName) .. "  (" .. tostring(count or 0) .. ")")
  row.section:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
  row.section:Show()
  row:EnableMouse(true)
  row:SetScript("OnEnter", function(selfRow)
    SetBackdrop(selfRow, colors.hover, colors.border)
  end)
  row:SetScript("OnLeave", function(selfRow)
    SetBackdrop(selfRow, colors.heading, collapsed and colors.borderSoft or colors.border)
  end)
  row:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
      MerfinPlus:ToggleGeneralAssignmentSection(entry, sectionName)
    end
  end)
  return collapsed
end

local function ConfigurePlayerRow(row, player)
  ResetRow(row)
  SetBackdrop(row, colors.row, colors.borderSoft)
  local classToken = player.classToken or MerfinPlus:GetGeneralAssignmentClassToken(player.class)
  SetIconTexture(row.classIcon, MerfinPlus:GetGeneralAssignmentClassIcon(classToken))
  SetIconTexture(row.specIcon, MerfinPlus:GetGeneralAssignmentSpecIcon(classToken, player.spec))
  SetIconTexture(row.roleIcon, MerfinPlus:GetGeneralAssignmentRoleIcon(classToken, player.spec))
  local r, g, b = MerfinPlus:GetGeneralAssignmentClassColor(classToken)
  row.name:SetText(player.name or "")
  row.name:SetTextColor(r, g, b, 1)
  row.detail:SetText((player.class or "Player") .. (player.spec and player.spec ~= "" and (" - " .. player.spec) or ""))
  row.detail:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)
  row.detail:ClearAllPoints()
  row.detail:SetPoint("LEFT", row, "LEFT", 205, 0)
  row.detail:SetWidth(260)
  row.name:Show()
  row.detail:Show()
end

local function ConfigureTaskRow(row, task, parsed)
  ResetRow(row)
  SetBackdrop(row, colors.row, colors.borderSoft)
  local player = MerfinPlus:FindGeneralAssignmentPlayer(parsed, task.player)
  local classToken = player and (player.classToken or MerfinPlus:GetGeneralAssignmentClassToken(player.class)) or nil
  local spellLabel, spellIcon = MerfinPlus:GetGeneralAssignmentSpellDisplay(task)
  local targetLabel, targetClassToken, targetIcon, targetIsMarker = MerfinPlus:GetGeneralAssignmentTargetDisplay(task, parsed)

  SetIconTexture(row.classIcon, MerfinPlus:GetGeneralAssignmentClassIcon(classToken))
  SetIconTexture(row.specIcon, player and MerfinPlus:GetGeneralAssignmentSpecIcon(classToken, player.spec) or nil)
  SetIconTexture(row.roleIcon, player and MerfinPlus:GetGeneralAssignmentRoleIcon(classToken, player.spec) or nil)
  SetIconTexture(row.spellIcon, spellIcon)
  SetIconTexture(row.targetIcon, targetIcon)

  local r, g, b = MerfinPlus:GetGeneralAssignmentClassColor(classToken)
  row.name:SetText(task.player or "")
  row.name:SetTextColor(r, g, b, 1)
  row.detail:ClearAllPoints()
  row.detail:SetPoint("LEFT", row, "LEFT", 236, 0)
  row.detail:SetWidth(158)
  row.detail:SetText(spellLabel or task.assignment or "")
  row.detail:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)
  row.target:ClearAllPoints()
  if targetIcon then
    row.target:SetPoint("LEFT", row.targetIcon, "RIGHT", 8, 0)
  else
    row.target:SetPoint("LEFT", row, "LEFT", 405, 0)
  end
  row.target:SetPoint("RIGHT", row, "RIGHT", -10, 0)
  row.target:SetText(targetLabel or "")
  if targetClassToken then
    local tr, tg, tb = MerfinPlus:GetGeneralAssignmentClassColor(targetClassToken)
    row.target:SetTextColor(tr, tg, tb, 1)
  else
    row.target:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  end

  row.name:Show()
  if spellIcon then
    row.spellIcon:Show()
  end
  row.detail:Show()
  if not targetIsMarker and targetLabel and targetLabel ~= "" then
    row.target:Show()
  end
end

local function RefreshRows(self, entry)
  local parsed = entry and entry.parsed
  local rowIndex, y = 0, 0

  local function PlaceRow(row, height)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -y)
    row:SetPoint("TOPRIGHT", self.scrollChild, "TOPRIGHT", 0, -y)
    row:SetHeight(height)
    row:Show()
    y = y + height + 5
  end

  if not parsed then
    self.emptyText:SetText(MerfinPlus:T(entry and (entry.parseError or "The selected import could not be parsed.") or "No General Assignments imports saved."))
    self.emptyText:Show()
    for _, row in ipairs(self.rows) do
      row:Hide()
    end
    self.scrollChild:SetHeight(1)
    return
  end

  self.emptyText:Hide()
  rowIndex = rowIndex + 1
  local playersHeader = AcquireRow(self, rowIndex)
  local playersCollapsed = ConfigureSectionRow(self, playersHeader, entry, "Players", #(parsed.players or {}))
  PlaceRow(playersHeader, 28)
  if not playersCollapsed then
    for _, player in ipairs(parsed.players or {}) do
      rowIndex = rowIndex + 1
      local row = AcquireRow(self, rowIndex)
      ConfigurePlayerRow(row, player)
      PlaceRow(row, 36)
    end
  end

  for _, section in ipairs(parsed.sections or {}) do
    if section.name ~= "Players" and #(section.rows or {}) > 0 then
      rowIndex = rowIndex + 1
      local sectionHeader = AcquireRow(self, rowIndex)
      local collapsed = ConfigureSectionRow(self, sectionHeader, entry, section.name, #section.rows)
      PlaceRow(sectionHeader, 28)
      if not collapsed then
        for _, task in ipairs(section.rows) do
          rowIndex = rowIndex + 1
          local row = AcquireRow(self, rowIndex)
          ConfigureTaskRow(row, task, parsed)
          PlaceRow(row, 36)
        end
      end
    end
  end

  for index = rowIndex + 1, #self.rows do
    self.rows[index]:Hide()
  end
  self.scrollChild:SetHeight(math.max(1, y))
end

local function ImportInput(self)
  if self.disabled then
    return
  end
  local state = MerfinPlus:GetGeneralAssignmentUIState()
  local raw = self.editBox:GetText() or ""
  state.input = raw
  local entry, errorText, duplicate = MerfinPlus:SaveGeneralAssignmentImport(raw)
  if not entry then
    state.status = errorText or "Invalid General Assignments string."
    state.statusTone = "red"
  else
    state.input = ""
    state.status = duplicate and "Identical import already exists; selected the saved import." or "General Assignments import saved."
    state.statusTone = "good"
    self.editBox:SetText("")
    self.editBox:ClearFocus()
  end
  MerfinPlus:NotifyGeneralAssignmentsChanged()
end

local methods = {
  OnAcquire = function(self)
    self:SetWidth(720)
    self:SetHeight(500)
    self.disabled = nil
    self.menuOffset = 0
    MerfinPlus:RegisterGeneralAssignmentsWidget(self)
    self:Refresh()
  end,
  OnRelease = function(self)
    MerfinPlus:UnregisterGeneralAssignmentsWidget(self)
    CloseImportMenu(self)
    self.editBox:ClearFocus()
  end,
  SetText = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled and true or false
    if self.disabled then
      self.editBox:Disable()
      self.dropdown:Disable()
    else
      self.editBox:Enable()
      self.dropdown:Enable()
    end
    SetActionButtonEnabled(self.importButton, not self.disabled)
    SetActionButtonEnabled(self.broadcastButton, not self.disabled and MerfinPlus:GetSelectedGeneralAssignmentImport() ~= nil)
    SetActionButtonEnabled(self.deleteButton, not self.disabled and MerfinPlus:GetSelectedGeneralAssignmentImport() ~= nil)
  end,
  Refresh = function(self)
    local state = MerfinPlus:GetGeneralAssignmentUIState()
    local entry = MerfinPlus:GetSelectedGeneralAssignmentImport()
    if not self.editBox:HasFocus() and self.editBox:GetText() ~= (state.input or "") then
      self.editBox:SetText(state.input or "")
    end
    self.status:SetText(MerfinPlus:T(state.status or ""))
    local tone = colors[state.statusTone or "muted"] or colors.muted
    self.status:SetTextColor(tone[1], tone[2], tone[3], tone[4])
    self.dropdownText:SetText(MerfinPlus:GetGeneralAssignmentImportName(entry))
    self.timestamp:SetText(MerfinPlus:GetGeneralAssignmentImportTimestamp(entry))
    SetActionButtonEnabled(self.deleteButton, not self.disabled and entry ~= nil)
    SetActionButtonEnabled(self.broadcastButton, not self.disabled and entry ~= nil)
    RefreshRows(self, entry)
    if self.importMenu:IsShown() then
      RefreshImportMenu(self)
    end
  end,
}

local function Constructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(500)

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  ApplyWidgetFont(title, 19)
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  title:SetText(MerfinPlus:T("General Assignments"))
  title:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)

  local broadcastButton = CreateActionButton(frame, MerfinPlus:T("Broadcast"), 112, false)
  broadcastButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)

  local inputWrap = CreateFrame("Frame", nil, frame, template)
  inputWrap:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -34)
  inputWrap:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -98, -34)
  inputWrap:SetHeight(30)
  SetBackdrop(inputWrap, colors.field, colors.borderSoft)

  local inputScroll = CreateFrame("ScrollFrame", nil, inputWrap)
  inputScroll:SetPoint("TOPLEFT", inputWrap, "TOPLEFT", 9, -5)
  inputScroll:SetPoint("BOTTOMRIGHT", inputWrap, "BOTTOMRIGHT", -9, 5)

  local editBox = CreateFrame("EditBox", nil, inputScroll)
  editBox:SetPoint("TOPLEFT", inputScroll, "TOPLEFT", 0, 0)
  editBox:SetWidth(1)
  editBox:SetHeight(20)
  editBox:SetAutoFocus(false)
  editBox:SetMultiLine(true)
  editBox:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  ApplyWidgetFont(editBox, DEFAULT_FONT_HEIGHT)
  MerfinPlus:ConfigureAssignmentImportEditBox(editBox)
  editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  inputScroll:SetScrollChild(editBox)
  inputScroll:EnableMouse(true)
  inputScroll:SetScript("OnMouseDown", function()
    editBox:SetFocus()
  end)

  local importButton = CreateActionButton(frame, MerfinPlus:T("Import"), 90, false)
  importButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -34)

  local status = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(status, 12)
  status:SetPoint("TOPLEFT", inputWrap, "BOTTOMLEFT", 2, -5)
  status:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -69)
  status:SetJustifyH("LEFT")

  local dropdown = CreateFrame("Button", nil, frame, template)
  dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -88)
  dropdown:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -205, -88)
  dropdown:SetHeight(30)
  dropdown:RegisterForClicks("AnyUp")
  SetBackdrop(dropdown, colors.field, colors.borderSoft)

  local dropdownText = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(dropdownText, 14)
  dropdownText:SetPoint("LEFT", dropdown, "LEFT", 10, 0)
  dropdownText:SetPoint("RIGHT", dropdown, "RIGHT", -26, 0)
  dropdownText:SetJustifyH("LEFT")

  local arrow = dropdown:CreateTexture(nil, "OVERLAY")
  arrow:SetTexture(DROPDOWN_ARROW_TEXTURE)
  arrow:SetSize(16, 16)
  arrow:SetPoint("RIGHT", dropdown, "RIGHT", -7, 0)
  arrow:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  if arrow.SetRotation then
    arrow:SetRotation(math.pi)
  else
    arrow:SetTexCoord(1, 0, 1, 0)
  end

  local timestamp = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(timestamp, 13)
  timestamp:SetPoint("LEFT", dropdown, "RIGHT", 12, 0)
  timestamp:SetPoint("RIGHT", frame, "RIGHT", -38, 0)
  timestamp:SetJustifyH("LEFT")
  timestamp:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

  local deleteButton = CreateActionButton(frame, "X", 30, true)
  deleteButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -88)

  local importMenu = CreateFrame("Frame", nil, UIParent, template)
  importMenu:SetFrameStrata("TOOLTIP")
  importMenu:SetClampedToScreen(true)
  importMenu:EnableMouseWheel(true)
  SetBackdrop(importMenu, colors.menu, colors.border)
  importMenu:Hide()

  local scroll = CreateFrame("ScrollFrame", nil, frame)
  scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -130)
  scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  scroll:EnableMouseWheel(true)

  local scrollChild = CreateFrame("Frame", nil, scroll)
  scrollChild:SetSize(680, 1)
  scroll:SetScrollChild(scrollChild)

  local emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(emptyText, 14)
  emptyText:SetPoint("CENTER", scroll, "CENTER", 0, 0)
  emptyText:SetWidth(460)
  emptyText:SetJustifyH("CENTER")
  emptyText:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

  local self = {
    type = WIDGET_TYPE,
    frame = frame,
    title = title,
    inputWrap = inputWrap,
    inputScroll = inputScroll,
    editBox = editBox,
    broadcastButton = broadcastButton,
    importButton = importButton,
    status = status,
    dropdown = dropdown,
    dropdownText = dropdownText,
    timestamp = timestamp,
    deleteButton = deleteButton,
    importMenu = importMenu,
    importOptions = {},
    scroll = scroll,
    scrollChild = scrollChild,
    emptyText = emptyText,
    rows = {},
  }
  frame.obj = self
  editBox.obj = self
  importButton.obj = self
  broadcastButton.obj = self
  dropdown.obj = self
  deleteButton.obj = self
  importMenu.obj = self

  for name, method in pairs(methods) do
    self[name] = method
  end

  for rowIndex = 1, MAX_VISIBLE_IMPORTS do
    local option = CreateFrame("Button", nil, importMenu, template)
    option:SetHeight(IMPORT_ROW_HEIGHT - 1)
    option:SetPoint("TOPLEFT", importMenu, "TOPLEFT", 4, -4 - ((rowIndex - 1) * IMPORT_ROW_HEIGHT))
    option:SetPoint("TOPRIGHT", importMenu, "TOPRIGHT", -4, -4 - ((rowIndex - 1) * IMPORT_ROW_HEIGHT))
    SetBackdrop(option, colors.field, colors.borderSoft)

    option.nameText = option:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    ApplyWidgetFont(option.nameText, 14)
    option.nameText:SetPoint("LEFT", option, "LEFT", 9, 0)
    option.nameText:SetPoint("RIGHT", option, "RIGHT", -166, 0)
    option.nameText:SetJustifyH("LEFT")

    option.timeText = option:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ApplyWidgetFont(option.timeText, 12)
    option.timeText:SetPoint("RIGHT", option, "RIGHT", -9, 0)
    option.timeText:SetWidth(150)
    option.timeText:SetJustifyH("RIGHT")
    option.timeText:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

    option:SetScript("OnEnter", function(row)
      SetBackdrop(row, colors.hover, colors.border)
    end)
    option:SetScript("OnLeave", function()
      RefreshImportMenu(self)
    end)
    option:SetScript("OnClick", function(row)
      if row.entryID then
        CloseImportMenu(self)
        MerfinPlus:SetSelectedGeneralAssignmentImport(row.entryID)
      end
    end)
    self.importOptions[rowIndex] = option
  end

  editBox:SetScript("OnTextChanged", function(box)
    local text = box:GetText() or ""
    MerfinPlus:GetGeneralAssignmentUIState().input = text
    local _, newlineCount = text:gsub("\n", "\n")
    box:SetHeight(math.max(inputScroll:GetHeight(), ((newlineCount + 1) * DEFAULT_FONT_HEIGHT) + 6))
  end)
  inputScroll:SetScript("OnSizeChanged", function(scrollFrame, width, height)
    editBox:SetWidth(math.max(1, width))
    local text = editBox:GetText() or ""
    local _, newlineCount = text:gsub("\n", "\n")
    editBox:SetHeight(math.max(height, ((newlineCount + 1) * DEFAULT_FONT_HEIGHT) + 6))
  end)
  importButton:SetScript("OnClick", function()
    ImportInput(self)
  end)
  broadcastButton:SetScript("OnClick", function()
    if not self.disabled then
      MerfinPlus:BroadcastPersonalGeneralAssignments()
    end
  end)
  dropdown:SetScript("OnEnter", function(button)
    if not self.disabled then
      SetBackdrop(button, colors.hover, colors.border)
    end
  end)
  dropdown:SetScript("OnLeave", function(button)
    SetBackdrop(button, colors.field, colors.borderSoft)
  end)
  dropdown:SetScript("OnClick", function()
    OpenImportMenu(self)
  end)
  deleteButton:SetScript("OnClick", function()
    if not self.disabled then
      MerfinPlus:ConfirmDeleteSelectedGeneralAssignmentImport()
    end
  end)
  importMenu:SetScript("OnMouseWheel", function(_, delta)
    local imports = MerfinPlus:GetGeneralAssignmentImports()
    local visible = math.min(#imports, MAX_VISIBLE_IMPORTS)
    local maximumOffset = math.max(0, #imports - visible)
    self.menuOffset = math.max(0, math.min(maximumOffset, (self.menuOffset or 0) - delta))
    RefreshImportMenu(self)
  end)
  scroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 40)
    nextValue = math.max(0, math.min(scrollFrame:GetVerticalScrollRange(), nextValue))
    scrollFrame:SetVerticalScroll(nextValue)
  end)
  frame:SetScript("OnSizeChanged", function(_, width)
    scrollChild:SetWidth(math.max(1, width))
    if importMenu:IsShown() then
      RefreshImportMenu(self)
    end
  end)
  frame:SetScript("OnHide", function()
    CloseImportMenu(self)
  end)

  return AceGUI:RegisterAsWidget(self)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)
