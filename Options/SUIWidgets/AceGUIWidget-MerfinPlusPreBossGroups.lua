-- Pre-Boss Groups import and boss-action view.

local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme

local WIDGET_TYPE = "MerfinPlusPreBossGroups"
local WIDGET_VERSION = 2
local DROPDOWN_ARROW_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\options\\dropdown_arrow.tga"
local ROW_HEIGHT = 42
local RAID_HEADING_HEIGHT = 24
local template = BackdropTemplateMixin and "BackdropTemplate" or nil

local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
}

local colors = {
  field = theme.surface,
  row = theme.surfaceRaised,
  hover = theme.hover,
  border = theme.border,
  borderSoft = theme.borderSoft,
  text = theme.text,
  muted = theme.muted,
  success = { 0.36, 0.86, 0.42, 1 },
  warning = { 1, 0.72, 0.18, 1 },
  error = { 1, 0.28, 0.22, 1 },
}

local function SetBackdrop(frame, background, border)
  if not frame.SetBackdrop then
    return
  end
  frame:SetBackdrop(backdrop)
  frame:SetBackdropColor(
    background[1],
    background[2],
    background[3],
    background[4]
  )
  frame:SetBackdropBorderColor(
    border[1],
    border[2],
    border[3],
    border[4]
  )
end

local function SetButtonEnabled(button, enabled)
  button.enabled = enabled == true
  button:SetAlpha(button.enabled and 1 or 0.45)
  button:EnableMouse(button.enabled)
end

local function CreateActionButton(parent, label, width)
  local button = CreateFrame("Button", nil, parent, template)
  button:SetSize(width, 30)
  SetBackdrop(button, colors.row, colors.borderSoft)

  button.label = button:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  button.label:SetPoint("CENTER")
  button.label:SetText(label)
  button.label:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)

  button:SetScript("OnEnter", function(self)
    if self.enabled ~= false then
      SetBackdrop(self, colors.hover, colors.border)
    end
  end)
  button:SetScript("OnLeave", function(self)
    SetBackdrop(self, colors.row, colors.borderSoft)
  end)
  button:SetScript("OnMouseDown", function(self)
    if self.enabled ~= false then
      SetBackdrop(self, colors.field, colors.border)
    end
  end)
  button:SetScript("OnMouseUp", function(self)
    if self:IsMouseOver() then
      SetBackdrop(self, colors.hover, colors.border)
    else
      SetBackdrop(self, colors.row, colors.borderSoft)
    end
  end)
  button.enabled = true
  return button
end

local function AcquireRaidHeading(self, index)
  local heading = self.raidHeadings[index]
  if not heading then
    heading = self.scrollChild:CreateFontString(
      nil,
      "OVERLAY",
      "GameFontNormal"
    )
    heading:SetJustifyH("LEFT")
    heading:SetTextColor(
      colors.border[1],
      colors.border[2],
      colors.border[3],
      1
    )
    self.raidHeadings[index] = heading
  end
  heading:Show()
  return heading
end

local function AcquireBossButton(self, index)
  local button = self.bossButtons[index]
  if button then
    button:Show()
    return button
  end

  button = CreateFrame("Button", nil, self.scrollChild, template)
  button:SetHeight(ROW_HEIGHT)
  SetBackdrop(button, colors.row, colors.borderSoft)

  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetSize(30, 30)
  button.icon:SetPoint("LEFT", button, "LEFT", 8, 0)
  button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

  button.label = button:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
  )
  button.label:SetPoint("LEFT", button.icon, "RIGHT", 10, 0)
  button.label:SetPoint("RIGHT", button, "RIGHT", -12, 0)
  button.label:SetJustifyH("LEFT")
  button.label:SetTextColor(
    colors.text[1],
    colors.text[2],
    colors.text[3],
    1
  )

  button:SetScript("OnEnter", function(row)
    if not self.disabled then
      SetBackdrop(row, colors.hover, colors.border)
    end
  end)
  button:SetScript("OnLeave", function(row)
    SetBackdrop(row, colors.row, colors.borderSoft)
  end)
  button:SetScript("OnMouseDown", function(row)
    if not self.disabled then
      SetBackdrop(row, colors.field, colors.border)
    end
  end)
  button:SetScript("OnMouseUp", function(row)
    if row:IsMouseOver() then
      SetBackdrop(row, colors.hover, colors.border)
    else
      SetBackdrop(row, colors.row, colors.borderSoft)
    end
  end)
  button:SetScript("OnClick", function(row)
    if not self.disabled and row.bossKey then
      MerfinPlus:ApplyPreBossGroupPlan(row.bossKey)
    end
  end)

  self.bossButtons[index] = button
  return button
end

local function RefreshBossButtons(self, plan)
  for _, heading in ipairs(self.raidHeadings) do
    heading:Hide()
  end
  for _, button in ipairs(self.bossButtons) do
    button:Hide()
  end

  if not plan or #(plan.bosses or {}) == 0 then
    self.scrollChild:SetHeight(1)
    return
  end

  local y = 0
  local headingIndex, buttonIndex = 0, 0
  local previousRaid
  for _, boss in ipairs(plan.bosses) do
    if previousRaid ~= boss.raidLocaleID then
      previousRaid = boss.raidLocaleID
      headingIndex = headingIndex + 1
      local heading = AcquireRaidHeading(self, headingIndex)
      heading:ClearAllPoints()
      heading:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 4, -y)
      heading:SetPoint("TOPRIGHT", self.scrollChild, "TOPRIGHT", -4, -y)
      heading:SetText(MerfinPlus:GetPreBossGroupRaidDisplayName(boss))
      y = y + RAID_HEADING_HEIGHT
    end

    buttonIndex = buttonIndex + 1
    local button = AcquireBossButton(self, buttonIndex)
    button.bossKey = boss.key
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -y)
    button:SetPoint("TOPRIGHT", self.scrollChild, "TOPRIGHT", 0, -y)
    button.icon:SetTexture(boss.icon)
    button.label:SetText(MerfinPlus:T("Set %s Group"):format(
      MerfinPlus:GetPreBossGroupBossDisplayName(boss)
    ))
    y = y + ROW_HEIGHT + 5
  end
  self.scrollChild:SetHeight(math.max(1, y))
end

local function ImportInput(self, raw)
  if self.disabled then
    return false, "Pre-Boss Groups is disabled."
  end
  local state = MerfinPlus:GetPreBossGroupUIState()
  local plan, errorText = MerfinPlus:SavePreBossGroupImport(raw, state.selectedRaidGroupID)
  if plan then
    -- Pre-Boss plans are intentionally local.  They control only this
    -- client's raid-group action and are never sent through addon messages.
    state.status = "Pre-Boss Groups import saved locally."
    state.statusTone = "good"
    MerfinPlus:NotifyPreBossGroupsChanged()
    return true
  end
  return false, errorText or "Invalid Pre-Boss Groups string."
end

local function CloseRaidMenu(self)
  self.raidMenu:Hide()
  self.raidMenuOpen = nil
end

local function RefreshRaidMenu(self)
  local groups = MerfinPlus:GetRaidAssignmentGroups()
  local selectedGroupID = MerfinPlus:GetPreBossGroupUIState().selectedRaidGroupID
  for index, option in ipairs(self.raidOptions) do
    local group = groups[index]
    option.groupID = group and group.id or nil
    if group then
      option.label:SetText(MerfinPlus:GetLocalizedRaidName(group.id, group.name))
      option.active = group.id == selectedGroupID
      SetBackdrop(option, option.active and colors.hover or colors.row, option.active and colors.border or colors.borderSoft)
      option:Show()
    else
      option:Hide()
    end
  end
  self.raidMenu:SetHeight(8 + (#groups * 32))
end

local function OpenRaidMenu(self)
  if self.raidMenuOpen then
    CloseRaidMenu(self)
    return
  end
  self.raidMenuOpen = true
  self.raidMenu:ClearAllPoints()
  self.raidMenu:SetPoint("TOPLEFT", self.raidDropdown, "BOTTOMLEFT", 0, -2)
  RefreshRaidMenu(self)
  self.raidMenu:Show()
end

local function CloseSavedImportMenu(self)
  self.savedImportMenu:Hide()
  self.savedImportMenuOpen = nil
end

local function RefreshSavedImportMenu(self)
  local imports = MerfinPlus:GetSavedPreBossGroupImports()
  for index, entry in ipairs(imports) do
    local option = self.savedImportOptions[index]
    if not option then
      option = CreateActionButton(self.savedImportMenu, "", 294)
      option:SetHeight(29)
      option.label:ClearAllPoints()
      option.label:SetPoint("LEFT", option, "LEFT", 9, 0)
      option.label:SetPoint("RIGHT", option, "RIGHT", -9, 0)
      option.label:SetJustifyH("LEFT")
      option:SetScript("OnClick", function(row)
        MerfinPlus:SelectSavedPreBossGroupImport(row.importID)
        CloseSavedImportMenu(self)
      end)
      self.savedImportOptions[index] = option
    end
    option.importID = entry.id
    option.label:SetText(entry.savedLabel or "Saved Pre-Boss Groups")
    option:ClearAllPoints()
    option:SetPoint("TOPLEFT", self.savedImportMenu, "TOPLEFT", 4, -4 - ((index - 1) * 32))
    option:SetPoint("TOPRIGHT", self.savedImportMenu, "TOPRIGHT", -4, -4 - ((index - 1) * 32))
    option:Show()
  end
  for index = #imports + 1, #self.savedImportOptions do
    self.savedImportOptions[index]:Hide()
  end
  self.savedImportMenu:SetHeight(math.max(37, 8 + (#imports * 32)))
end

local function OpenSavedImportMenu(self)
  if self.savedImportMenuOpen then
    CloseSavedImportMenu(self)
    return
  end
  self.savedImportMenuOpen = true
  self.savedImportMenu:ClearAllPoints()
  self.savedImportMenu:SetPoint("TOPLEFT", self.savedImportDropdown, "BOTTOMLEFT", 0, -2)
  RefreshSavedImportMenu(self)
  self.savedImportMenu:Show()
end

local methods = {
  OnAcquire = function(self)
    self:SetWidth(780)
    self:SetHeight(500)
    self.disabled = false
    MerfinPlus:RegisterPreBossGroupsWidget(self)
    self:Refresh()
  end,
  OnRelease = function(self)
    MerfinPlus:UnregisterPreBossGroupsWidget(self)
    CloseRaidMenu(self)
    CloseSavedImportMenu(self)
  end,
  SetText = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled == true
    self.frame:SetAlpha(self.disabled and 0.55 or 1)
    SetButtonEnabled(self.importButton, not self.disabled)
    SetButtonEnabled(self.raidDropdown, not self.disabled)
    SetButtonEnabled(self.savedImportDropdown, not self.disabled)
    SetButtonEnabled(self.removeSavedImportButton, not self.disabled)
  end,
  Refresh = function(self)
    local state = MerfinPlus:GetPreBossGroupUIState()
    local plan = MerfinPlus:GetPreBossGroupPlan()
    local group = MerfinPlus:GetRaidAssignmentGroup(state.selectedRaidGroupID)
    if not group and plan then
      local inferredGroupID = MerfinPlus:GetPreBossGroupRaidGroupID(plan)
      group = MerfinPlus:GetRaidAssignmentGroup(inferredGroupID)
      state.selectedRaidGroupID = group and group.id or nil
    end
    self.raidDropdownText:SetText(group and MerfinPlus:GetLocalizedRaidName(group.id, group.name) or MerfinPlus:T("Select Raid"))
    self.importButton.label:SetText(MerfinPlus:T("Import"))
    local selectedSaved
    for _, entry in ipairs(MerfinPlus:GetSavedPreBossGroupImports()) do
      if entry.id == state.selectedSavedPreBossImportID then
        selectedSaved = entry
        break
      end
    end
    self.savedImportText:SetText(selectedSaved and selectedSaved.savedLabel or MerfinPlus:T("Saved Imports"))
    SetButtonEnabled(self.removeSavedImportButton, not self.disabled and selectedSaved ~= nil)
    self.status:SetText(MerfinPlus:T(state.status or ""))
    local statusColor = colors[state.statusTone or "muted"] or colors.muted
    self.status:SetTextColor(statusColor[1], statusColor[2], statusColor[3], statusColor[4])
    RefreshBossButtons(self, plan)
    if self.raidMenu:IsShown() then RefreshRaidMenu(self) end
    if self.savedImportMenu:IsShown() then RefreshSavedImportMenu(self) end
  end,
}

local function Constructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(500)

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  title:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
  title:Hide()

  local inputWrap = CreateFrame("Frame", nil, frame, template)
  inputWrap:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -34)
  inputWrap:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -98, -34)
  inputWrap:SetHeight(78)
  SetBackdrop(inputWrap, colors.field, colors.borderSoft)

  local inputScroll = CreateFrame("ScrollFrame", nil, inputWrap)
  inputScroll:SetPoint("TOPLEFT", inputWrap, "TOPLEFT", 9, -7)
  inputScroll:SetPoint("BOTTOMRIGHT", inputWrap, "BOTTOMRIGHT", -9, 7)
  inputScroll:EnableMouse(true)
  inputScroll:EnableMouseWheel(true)

  local editBox = CreateFrame("EditBox", nil, inputScroll)
  editBox:SetPoint("TOPLEFT", inputScroll, "TOPLEFT", 0, 0)
  editBox:SetWidth(1)
  editBox:SetHeight(64)
  editBox:SetAutoFocus(false)
  editBox:SetMultiLine(true)
  editBox:SetFontObject(_G.ChatFontNormal or _G.GameFontHighlightSmall)
  editBox:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  MerfinPlus:ConfigureAssignmentImportEditBox(editBox)
  inputScroll:SetScrollChild(editBox)

  local importButton = CreateActionButton(
    frame,
    MerfinPlus:T("Import"),
    80
  )
  local raidDropdown = CreateFrame("Button", nil, frame, template)
  raidDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  raidDropdown:SetSize(260, 30)
  raidDropdown:RegisterForClicks("AnyUp")
  SetBackdrop(raidDropdown, colors.field, colors.border)
  local raidDropdownText = raidDropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  raidDropdownText:SetPoint("LEFT", raidDropdown, "LEFT", 10, 0)
  raidDropdownText:SetPoint("RIGHT", raidDropdown, "RIGHT", -26, 0)
  raidDropdownText:SetJustifyH("LEFT")
  raidDropdownText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  local raidDropdownArrow = raidDropdown:CreateTexture(nil, "OVERLAY")
  raidDropdownArrow:SetTexture(DROPDOWN_ARROW_TEXTURE)
  raidDropdownArrow:SetSize(16, 16)
  raidDropdownArrow:SetPoint("RIGHT", raidDropdown, "RIGHT", -7, 0)
  raidDropdownArrow:SetVertexColor(colors.border[1], colors.border[2], colors.border[3], 1)
  if raidDropdownArrow.SetRotation then
    raidDropdownArrow:SetRotation(math.pi)
  else
    raidDropdownArrow:SetTexCoord(1, 0, 1, 0)
  end
  local raidMenu = CreateFrame("Frame", nil, UIParent, template)
  raidMenu:SetFrameStrata("TOOLTIP")
  raidMenu:SetClampedToScreen(true)
  raidMenu:SetWidth(260)
  SetBackdrop(raidMenu, colors.field, colors.border)
  raidMenu:Hide()
  importButton:SetPoint("LEFT", raidDropdown, "RIGHT", 8, 0)
  local savedImportDropdown = CreateActionButton(frame, MerfinPlus:T("Saved Imports"), 300)
  savedImportDropdown:SetPoint("LEFT", importButton, "RIGHT", 8, 0)
  savedImportDropdown.label:ClearAllPoints()
  savedImportDropdown.label:SetPoint("LEFT", savedImportDropdown, "LEFT", 9, 0)
  savedImportDropdown.label:SetPoint("RIGHT", savedImportDropdown, "RIGHT", -9, 0)
  savedImportDropdown.label:SetJustifyH("LEFT")
  local savedImportMenu = CreateFrame("Frame", nil, UIParent, template)
  savedImportMenu:SetFrameStrata("TOOLTIP")
  savedImportMenu:SetClampedToScreen(true)
  savedImportMenu:SetWidth(302)
  SetBackdrop(savedImportMenu, colors.field, colors.border)
  savedImportMenu:Hide()
  local removeSavedImportButton = CreateActionButton(frame, MerfinPlus:T("Remove"), 76)
  removeSavedImportButton:SetPoint("LEFT", savedImportDropdown, "RIGHT", 8, 0)
  local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  status:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -38)
  status:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -38)
  status:SetJustifyH("LEFT")
  status:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

  local scroll = CreateFrame("ScrollFrame", nil, frame)
  scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -60)
  scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  scroll:EnableMouseWheel(true)

  local scrollChild = CreateFrame("Frame", nil, scroll)
  scrollChild:SetSize(740, 1)
  scroll:SetScrollChild(scrollChild)

  local widget = {
    type = WIDGET_TYPE,
    frame = frame,
    title = title,
    inputWrap = inputWrap,
    inputScroll = inputScroll,
    editBox = editBox,
    raidDropdown = raidDropdown,
    raidDropdownText = raidDropdownText,
    raidMenu = raidMenu,
    raidOptions = {},
    importButton = importButton,
    savedImportDropdown = savedImportDropdown,
    savedImportText = savedImportDropdown.label,
    savedImportMenu = savedImportMenu,
    savedImportOptions = {},
    removeSavedImportButton = removeSavedImportButton,
    status = status,
    scroll = scroll,
    scrollChild = scrollChild,
    raidHeadings = {},
    bossButtons = {},
  }
  for name, method in pairs(methods) do
    widget[name] = method
  end

  inputScroll:SetScript("OnMouseDown", function()
    editBox:SetFocus()
  end)
  inputScroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 36)
    nextValue = math.max(
      0,
      math.min(scrollFrame:GetVerticalScrollRange(), nextValue)
    )
    scrollFrame:SetVerticalScroll(nextValue)
  end)
  editBox:SetScript("OnEscapePressed", function(box)
    box:ClearFocus()
  end)
  editBox:SetScript("OnTextChanged", function(box)
    local text = box:GetText() or ""
    MerfinPlus:GetPreBossGroupUIState().input = text
    local _, newlineCount = text:gsub("\n", "\n")
    box:SetHeight(math.max(
      inputScroll:GetHeight(),
      ((newlineCount + 1) * 14) + 8
    ))
  end)
  inputScroll:SetScript("OnSizeChanged", function(_, width, height)
    editBox:SetWidth(math.max(1, width))
    local text = editBox:GetText() or ""
    local _, newlineCount = text:gsub("\n", "\n")
    editBox:SetHeight(math.max(height, ((newlineCount + 1) * 14) + 8))
  end)
  importButton:SetScript("OnClick", function()
    if not widget.disabled then
      MerfinPlus:ShowAssignmentImportDialog(MerfinPlus:T("Import Pre-Boss Groups"), function(raw)
        return ImportInput(widget, raw)
      end, "Import")
    end
  end)
  for index, group in ipairs(MerfinPlus:GetRaidAssignmentGroups()) do
    local option = CreateActionButton(raidMenu, group.name, 252)
    option:SetHeight(29)
    option:SetPoint("TOPLEFT", raidMenu, "TOPLEFT", 4, -4 - ((index - 1) * 32))
    option:SetPoint("TOPRIGHT", raidMenu, "TOPRIGHT", -4, -4 - ((index - 1) * 32))
    option.label:SetJustifyH("LEFT")
    option.label:ClearAllPoints()
    option.label:SetPoint("LEFT", option, "LEFT", 9, 0)
    option.label:SetPoint("RIGHT", option, "RIGHT", -9, 0)
    option.groupID = group.id
    option:SetScript("OnClick", function(row)
      MerfinPlus:SetPreBossGroupRaidContext(row.groupID)
      CloseRaidMenu(widget)
    end)
    widget.raidOptions[index] = option
  end
  raidDropdown:SetScript("OnClick", function()
    if not widget.disabled then OpenRaidMenu(widget) end
  end)
  raidDropdown:SetScript("OnEnter", function(button)
    if not widget.disabled then SetBackdrop(button, colors.hover, colors.border) end
  end)
  raidDropdown:SetScript("OnLeave", function(button)
    SetBackdrop(button, colors.field, colors.border)
  end)
  savedImportDropdown:SetScript("OnClick", function()
    if not widget.disabled then OpenSavedImportMenu(widget) end
  end)
  removeSavedImportButton:SetScript("OnClick", function()
    local importID = MerfinPlus:GetPreBossGroupUIState().selectedSavedPreBossImportID
    if importID then MerfinPlus:RemoveSavedPreBossGroupImport(importID) end
  end)
  scroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 42)
    nextValue = math.max(
      0,
      math.min(scrollFrame:GetVerticalScrollRange(), nextValue)
    )
    scrollFrame:SetVerticalScroll(nextValue)
  end)
  frame:SetScript("OnSizeChanged", function(_, width)
    scrollChild:SetWidth(math.max(1, width))
  end)
  frame:SetScript("OnHide", function()
    CloseRaidMenu(widget)
    CloseSavedImportMenu(widget)
  end)
  inputWrap:Hide()

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)
