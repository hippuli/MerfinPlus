-- Guild-Manager-style TBC Raid Assignments view for the MerfinPlus AceConfig shell.

local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme

local WIDGET_TYPE = "MerfinPlusRaidAssignments"
local WIDGET_VERSION = 3
local SYNC_WIDGET_TYPE = "MerfinPlusRaidAssignmentSyncSettings"
local DETAILS_WIDGET_TYPE = "MerfinPlusRaidAssignmentDetails"
local SUBTAB_WIDGET_VERSION = 2
local FONT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local DROPDOWN_ARROW_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\options\\dropdown_arrow.tga"
local DEFAULT_FONT_HEIGHT = 14
local SECTION_ROW_HEIGHT = 32
local TASK_ROW_HEIGHT = 42
local MULTI_TARGET_TASK_ROW_HEIGHT = 52
local ROW_GAP = 6
local POSITION_COLUMN_GAP = 8
local POSITION_COLUMN_TANK_RATIO = 0.42
local POSITION_COLUMNS_MIN_WIDTH = 780
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
  cyan = { 0.24, 0.78, 1.00, 1 },
  good = { 0.42, 0.90, 0.46, 1 },
  red = { 0.95, 0.22, 0.18, 1 },
}

local function NormalizeKey(value)
  return tostring(value or ""):lower():gsub("[%s%p%c]+", "")
end

local CLASS_TOKENS = {
  demonhunter = "DEMONHUNTER",
  druid = "DRUID",
  hunter = "HUNTER",
  mage = "MAGE",
  paladin = "PALADIN",
  priest = "PRIEST",
  rogue = "ROGUE",
  shaman = "SHAMAN",
  warlock = "WARLOCK",
  warrior = "WARRIOR",
}

local function GetClassToken(className)
  return CLASS_TOKENS[NormalizeKey(className)]
end

local ASSIGNMENT_POSITION_ROLES = {
  tank = true,
  heal = true,
  melee = true,
  ranged = true,
}

local function GetSectionAssignmentRole(section)
  local sectionRole
  for _, rowData in ipairs(section and section.rows or {}) do
    local task = rowData.task or rowData
    local role = NormalizeKey(task and task.role)
    if ASSIGNMENT_POSITION_ROLES[role] then
      if sectionRole and sectionRole ~= role then return nil end
      sectionRole = role
    end
  end
  return sectionRole
end

local function GetClassIcon(classToken)
  return classToken and "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\" .. classToken .. ".tga" or nil
end

local function GetClassAssignmentSectionIcon(section)
  if not section or section.kind ~= "class" then return nil end
  local classToken = GetClassToken(section.sourceName)
  if not classToken then
    local sectionKey = NormalizeKey(section.name)
    for className, token in pairs(CLASS_TOKENS) do
      if sectionKey == className or sectionKey == className .. "assignments" or sectionKey == className .. "assigns" then
        classToken = token
        break
      end
    end
  end
  if not classToken then
    local rowClassToken
    for _, rowData in ipairs(section.rows or {}) do
      local task = rowData.task or rowData
      local token = GetClassToken(task.class)
      if not token or (rowClassToken and rowClassToken ~= token) then return nil end
      rowClassToken = token
    end
    classToken = rowClassToken
  end
  return GetClassIcon(classToken)
end

local SPECIAL_ASSIGNMENT_SECTION_ICON_KEYS = {
  spiritshockinterruptrotation = true,
  deadenspellreflection = true,
  runeshieldspellsteal = true,
  seethetranqshot = true,
}

local function GetSpecialAssignmentSectionIcon(section)
  if not section or section.kind ~= "utility"
    or not SPECIAL_ASSIGNMENT_SECTION_ICON_KEYS[NormalizeKey(section.name)] then
    return nil
  end
  local sectionIcon
  for _, rowData in ipairs(section.rows or {}) do
    local task = rowData.task or rowData
    local display = MerfinPlus:BuildRaidAssignmentRowDisplay(
      task,
      rowData.sectionName or section.name,
      nil
    )
    if not display or not display.icon then return nil end
    if sectionIcon and sectionIcon ~= display.icon then return nil end
    sectionIcon = display.icon
  end
  return sectionIcon
end

local BUFF_ASSIGNMENT_SECTION_ICONS = {
  buffassignments = { 135898, 135987, 135869, 136078 },
  mage = { 135869 },
  druid = { 136078 },
  priest = { 135898, 135987 },
}

local function GetBuffAssignmentSectionIcons(section, isBuffClassSection)
  if not section then return {} end
  local sectionKey
  if section.isBuffGroup and NormalizeKey(section.name) == "buffassignments" then
    sectionKey = "buffassignments"
  elseif isBuffClassSection then
    sectionKey = NormalizeKey(section.name)
  end
  local configuredIcons = BUFF_ASSIGNMENT_SECTION_ICONS[sectionKey]
  if not configuredIcons then return {} end
  local icons = {}
  for index, fileDataID in ipairs(configuredIcons) do icons[index] = fileDataID end
  return icons
end

local function GetSpecIcon(classToken, spec)
  return MerfinPlus:GetRaidAssignmentSpecIconPath(classToken, spec)
end

local function GetRoleIcon(spec)
  local key = NormalizeKey(spec)
  if key:find("tank", 1, true) or key == "protection" or key == "guardian" then
    return "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\tank.tga"
  end
  if key:find("heal", 1, true) or key == "holy" or key == "discipline" or key == "restoration" then
    return "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\heal.tga"
  end
  return "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Roles\\dps.tga"
end

local function GetClassColor(classToken)
  local classColor = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken])
    or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken])
    or { r = colors.text[1], g = colors.text[2], b = colors.text[3] }
  return classColor.r or classColor[1], classColor.g or classColor[2], classColor.b or classColor[3]
end

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
  assert(rejected == false and nativeCallCount == 0, "Raid Assignments font guard must reject invalid font values")
  local latinApplied = ApplyNativeFont(probe, "Fonts\\FRIZQT__.TTF", DEFAULT_FONT_HEIGHT, false)
  assert(latinApplied == true and nativeCallCount == 1 and forwardedArgumentCount == 2, "Raid Assignments font guard must accept the Latin fallback")
  local cyrillicApplied = ApplyNativeFont(probe, "Fonts\\FRIZQT___CYR.TTF", DEFAULT_FONT_HEIGHT, nil)
  assert(cyrillicApplied == true and nativeCallCount == 2 and forwardedArgumentCount == 2, "Raid Assignments font guard must accept the Cyrillic fallback")
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

local function SetIconTexture(texture, value, fullTexture)
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
  if fullTexture then
    texture:SetTexCoord(0, 1, 0, 1)
  else
    texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
  texture:Show()
  return true
end

local function SetButtonStyle(button, hovered, pressed, active)
  if button.disabled then
    SetBackdrop(button, colors.field, colors.borderSoft)
    button.label:SetTextColor(0.45, 0.45, 0.43, 1)
    return
  end
  local idleBackground = button.opaqueMenuRow and colors.menu or colors.field
  local background = active and colors.selected or (pressed and colors.pressed or (hovered and colors.hover or idleBackground))
  local border = button.danger and colors.red or ((active or hovered) and colors.border or colors.borderSoft)
  SetBackdrop(button, background, border)
  local labelColor = button.danger and colors.red or colors.text
  button.label:SetTextColor(labelColor[1], labelColor[2], labelColor[3], 1)
end

local function SetButtonEnabled(button, enabled)
  button.disabled = not enabled
  if enabled or button.keepMouseWhenDisabled then
    button:Enable()
  else
    button:Disable()
  end
  SetButtonStyle(button, false, false, button.active)
end

local function CreateButton(parent, label, width)
  local button = CreateFrame("Button", nil, parent, template)
  button:SetSize(width, 30)
  button:RegisterForClicks("AnyUp")
  button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(button.label, 14)
  button.label:SetPoint("CENTER")
  button.label:SetText(label)
  SetButtonStyle(button, false, false, false)
  button:SetScript("OnEnter", function(self)
    SetButtonStyle(self, true, false, self.active)
    if self.tooltipText and self.tooltipText ~= "" and GameTooltip then
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:SetText(self.tooltipTitle or self.label:GetText() or "", theme.accentBright[1], theme.accentBright[2], theme.accentBright[3])
      GameTooltip:AddLine(self.tooltipText, 0.88, 0.9, 0.94, true)
      GameTooltip:Show()
    end
  end)
  button:SetScript("OnLeave", function(self)
    SetButtonStyle(self, false, false, self.active)
    if GameTooltip then GameTooltip:Hide() end
  end)
  button:SetScript("OnMouseDown", function(self)
    SetButtonStyle(self, true, true, self.active)
  end)
  button:SetScript("OnMouseUp", function(self)
    SetButtonStyle(self, self:IsMouseOver(), false, self.active)
  end)
  return button
end

local function CloseRaidMenu(self)
  self.raidMenu:Hide()
  self.raidMenuOpen = nil
end

local function RefreshRaidMenu(self)
  local groups = MerfinPlus:GetRaidAssignmentGroups()
  local selectedGroup = MerfinPlus:GetRaidAssignmentUIState().selectedGroup
  for index, option in ipairs(self.raidOptions) do
    local group = groups[index]
    option.groupID = group and group.id or nil
    if group then
      option.label:SetText(MerfinPlus:GetLocalizedRaidName(group.id, group.name))
      option.active = group.id == selectedGroup
      SetButtonStyle(option, false, false, option.active)
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
  local imports = MerfinPlus:GetSavedRaidAssignmentImports()
  for index, entry in ipairs(imports) do
    local option = self.savedImportOptions[index]
    if not option then
      option = CreateButton(self.savedImportMenu, "", 294)
      option:SetHeight(29)
      option.opaqueMenuRow = true
      option.label:SetJustifyH("LEFT")
      option.label:ClearAllPoints()
      option.label:SetPoint("LEFT", option, "LEFT", 9, 0)
      option.label:SetPoint("RIGHT", option, "RIGHT", -9, 0)
      option:SetScript("OnClick", function(row)
        CloseSavedImportMenu(self)
        local selected, selectError = MerfinPlus:SelectSavedRaidAssignmentImport(row.importID)
        if not selected then
          local state = MerfinPlus:GetRaidAssignmentUIState()
          state.status = MerfinPlus:T(selectError or "Saved Raid Assignments import is unavailable.")
          state.statusTone = "red"
          MerfinPlus:NotifyRaidAssignmentStatusChanged()
        end
      end)
      self.savedImportOptions[index] = option
    end
    option.importID = entry.id
    option:SetFrameLevel(self.savedImportMenu:GetFrameLevel() + 2)
    option:SetAlpha(1)
    option:EnableMouse(true)
    SetButtonEnabled(option, true)
    option.label:SetText(entry.savedLabel or MerfinPlus:T("Saved Raid Assignments"))
    option.active = entry.id == MerfinPlus:GetRaidAssignmentUIState().selectedSavedRaidImportID
    SetButtonStyle(option, false, false, option.active)
    option:ClearAllPoints()
    option:SetPoint("TOPLEFT", self.savedImportMenu, "TOPLEFT", 4, -4 - ((index - 1) * 32))
    option:SetPoint("TOPRIGHT", self.savedImportMenu, "TOPRIGHT", -4, -4 - ((index - 1) * 32))
    option:Show()
  end
  for index = #imports + 1, #self.savedImportOptions do
    local option = self.savedImportOptions[index]
    option.importID = nil
    option.active = false
    SetButtonEnabled(option, false)
    option:Hide()
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
  self.savedImportMenu:SetFrameStrata("TOOLTIP")
  self.savedImportMenu:SetFrameLevel(math.max(100, (self.frame:GetFrameLevel() or 0) + 50))
  self.savedImportMenu:SetAlpha(1)
  SetBackdrop(self.savedImportMenu, colors.menu, colors.border)
  RefreshSavedImportMenu(self)
  self.savedImportMenu:Show()
  if self.savedImportMenu.Raise then self.savedImportMenu:Raise() end
end

local function StopSelfAssignmentHighlight(row)
  local highlight = row and row.selfAssignmentHighlight
  if not highlight then return end
  if highlight.animation and highlight.animation.IsPlaying and highlight.animation:IsPlaying() then
    highlight.animation:Stop()
  end
  highlight:SetAlpha(0.92)
  highlight:Hide()
end

local function ConfigureSelfAssignmentHighlight(row, task)
  local playerName = UnitName and UnitName("player")
  local isSelf = playerName and MerfinPlus:IsRaidAssignmentTaskVisibleToPlayer(task, playerName)
  if not isSelf then
    StopSelfAssignmentHighlight(row)
    return
  end

  local highlight = row.selfAssignmentHighlight
  if not highlight then
    highlight = CreateFrame("Frame", nil, row, template)
    highlight:SetPoint("TOPLEFT", row, "TOPLEFT", 1, -1)
    highlight:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -1, 1)
    if highlight.SetBackdrop then
      highlight:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
      highlight:SetBackdropBorderColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.92)
    end
    if highlight.EnableMouse then highlight:EnableMouse(false) end
    highlight:SetFrameLevel(row:GetFrameLevel() + 5)
    if highlight.CreateAnimationGroup then
      local ok, animation = pcall(highlight.CreateAnimationGroup, highlight)
      if ok and animation and animation.CreateAnimation then
        highlight.animation = animation
        local fadeDown = animation:CreateAnimation("Alpha")
        fadeDown:SetFromAlpha(0.92)
        fadeDown:SetToAlpha(0.30)
        fadeDown:SetDuration(0.82)
        fadeDown:SetOrder(1)
        if fadeDown.SetSmoothing then fadeDown:SetSmoothing("IN_OUT") end
        local fadeUp = animation:CreateAnimation("Alpha")
        fadeUp:SetFromAlpha(0.30)
        fadeUp:SetToAlpha(0.92)
        fadeUp:SetDuration(0.82)
        fadeUp:SetOrder(2)
        if fadeUp.SetSmoothing then fadeUp:SetSmoothing("IN_OUT") end
        animation:SetLooping("REPEAT")
      end
    end
    row.selfAssignmentHighlight = highlight
  end
  highlight:SetAlpha(0.92)
  highlight:Show()
  if highlight.animation and highlight.animation.Play then highlight.animation:Play() end
end

local function ResetDetailRow(row)
  StopSelfAssignmentHighlight(row)
  row:ClearAllPoints()
  row:EnableMouse(false)
  row:SetScript("OnEnter", nil)
  row:SetScript("OnLeave", nil)
  row:SetScript("OnMouseUp", nil)
  row.section:Hide()
  row.classIcon:Hide()
  row.specIcon:Hide()
  row.roleIcon:Hide()
  row.spellIcon:Hide()
  row.secondarySpellIcon:Hide()
  row.assignmentMarkerIcon:Hide()
  row.targetIcon:Hide()
  row.targetSpecIcon:Hide()
  row.name:Hide()
  row.detail:Hide()
  row.target:Hide()
  for _, texture in ipairs(row.sectionIcons or {}) do
    texture:ClearAllPoints()
    texture:Hide()
  end
end

local function GetTaskRowGeometry(row)
  local parentWidth = row:GetParent() and row:GetParent():GetWidth()
  local rowWidth = tonumber(row.layoutWidthOverride) or math.max(460, parentWidth or row:GetWidth() or 460)
  -- Reserve enough room for three player icons plus a complete character name
  -- before placing the assignment. The old percentage-only split left fewer
  -- than 65 pixels for names inside the default two-column Tank/Heal layout.
  local assignmentLeft = math.max(170, math.floor(rowWidth * 0.27))
  assignmentLeft = math.min(math.max(140, rowWidth - 136), assignmentLeft)
  local targetLeft = math.max(assignmentLeft + 106, math.floor(rowWidth * 0.58))
  targetLeft = math.min(math.max(assignmentLeft + 72, rowWidth - 42), targetLeft)
  return rowWidth, assignmentLeft, targetLeft
end

local function ApplyTaskRowGeometry(row)
  local _, assignmentLeft, targetLeft = GetTaskRowGeometry(row)
  row.classIcon:ClearAllPoints()
  row.classIcon:SetPoint("LEFT", row, "LEFT", 5, 0)
  row.specIcon:ClearAllPoints()
  row.specIcon:SetPoint("LEFT", row.classIcon, "RIGHT", 2, 0)
  row.roleIcon:ClearAllPoints()
  row.roleIcon:SetPoint("LEFT", row.specIcon, "RIGHT", 2, 0)
  row.name:ClearAllPoints()
  row.name:SetPoint("LEFT", row.roleIcon, "RIGHT", 4, 0)
  row.name:SetPoint("RIGHT", row, "LEFT", assignmentLeft - 5, 0)
  row.spellIcon:ClearAllPoints()
  row.spellIcon:SetPoint("LEFT", row, "LEFT", assignmentLeft, 0)
  row.secondarySpellIcon:ClearAllPoints()
  row.secondarySpellIcon:SetPoint("LEFT", row.spellIcon, "RIGHT", 3, 0)
  row.assignmentMarkerIcon:ClearAllPoints()
  row.assignmentMarkerIcon:SetPoint("LEFT", row.secondarySpellIcon, "RIGHT", 3, 0)
  row.detail:ClearAllPoints()
  row.detail:SetPoint("LEFT", row.assignmentMarkerIcon, "RIGHT", 5, 0)
  row.detail:SetPoint("RIGHT", row, "RIGHT", -8, 0)
  row.targetIcon:ClearAllPoints()
  row.targetIcon:SetPoint("LEFT", row, "LEFT", targetLeft, 0)
  row.targetSpecIcon:ClearAllPoints()
  row.targetSpecIcon:SetPoint("LEFT", row.targetIcon, "RIGHT", 3, 0)
  row.target:ClearAllPoints()
  row.target:SetPoint("LEFT", row.targetSpecIcon, "RIGHT", 5, 0)
  row.target:SetPoint("RIGHT", row, "RIGHT", -8, 0)
end

local function ApplyTaskAssignmentIconGeometry(row, hasSpellIcon, hasSecondarySpellIcon, hasAssignmentMarkerIcon, hasTargetIcon, hasTargetSpecIcon, hasTargetText)
  local rowWidth, assignmentLeft, targetLeft = GetTaskRowGeometry(row)
  local hasTargetContent = hasTargetIcon or hasTargetSpecIcon or hasTargetText
  local previous
  for _, entry in ipairs({
    { row.spellIcon, hasSpellIcon },
    { row.secondarySpellIcon, hasSecondarySpellIcon },
    { row.assignmentMarkerIcon, hasAssignmentMarkerIcon },
  }) do
    local texture, shown = entry[1], entry[2]
    texture:ClearAllPoints()
    if shown then
      if previous then texture:SetPoint("LEFT", previous, "RIGHT", 3, 0)
      else texture:SetPoint("LEFT", row, "LEFT", assignmentLeft, 0) end
      previous = texture
    end
  end
  row.detail:ClearAllPoints()
  if previous then row.detail:SetPoint("LEFT", previous, "RIGHT", 5, 0)
  else row.detail:SetPoint("LEFT", row, "LEFT", assignmentLeft, 0) end
  row.detail:SetPoint("RIGHT", row, "LEFT", hasTargetContent and (targetLeft - 5) or (rowWidth - 8), 0)

  local previousTarget
  row.targetIcon:ClearAllPoints()
  if hasTargetIcon then
    row.targetIcon:SetPoint("LEFT", row, "LEFT", targetLeft, 0)
    previousTarget = row.targetIcon
  end
  row.targetSpecIcon:ClearAllPoints()
  if hasTargetSpecIcon then
    if previousTarget then
      row.targetSpecIcon:SetPoint("LEFT", previousTarget, "RIGHT", 3, 0)
    else
      row.targetSpecIcon:SetPoint("LEFT", row, "LEFT", targetLeft, 0)
    end
    previousTarget = row.targetSpecIcon
  end
  row.target:ClearAllPoints()
  if previousTarget then
    row.target:SetPoint("LEFT", previousTarget, "RIGHT", 5, 0)
  else
    row.target:SetPoint("LEFT", row, "LEFT", targetLeft, 0)
  end
  row.target:SetPoint("RIGHT", row, "RIGHT", -8, 0)
end

local function ApplyMultiTargetTaskRowGeometry(row)
  -- Multi-target assignments use a second text line. Preserve every existing
  -- horizontal anchor and only lift points that are attached directly to the
  -- row. Replacing the first point used to discard RIGHT anchors and also
  -- compounded the offset across class/spec/name and spell/detail chains.
  for _, region in ipairs({ row.classIcon, row.specIcon, row.roleIcon, row.name, row.spellIcon, row.secondarySpellIcon, row.assignmentMarkerIcon, row.detail }) do
    local points = {}
    for pointIndex = 1, region:GetNumPoints() do
      local point, relativeTo, relativePoint, x, y = region:GetPoint(pointIndex)
      points[#points + 1] = { point, relativeTo, relativePoint, x, y }
    end
    if #points > 0 then
      region:ClearAllPoints()
      for _, anchor in ipairs(points) do
        local point, relativeTo, relativePoint, x, y = unpack(anchor)
        if relativeTo == row then y = (y or 0) + 11 end
        region:SetPoint(point, relativeTo, relativePoint, x, y)
      end
    end
  end
  row.targetIcon:Hide()
  row.targetSpecIcon:Hide()
  row.target:ClearAllPoints()
  row.target:SetPoint("LEFT", row, "LEFT", 8, -16)
  row.target:SetPoint("RIGHT", row, "RIGHT", -8, -16)
  row.target:SetJustifyH("LEFT")
end

local function ApplyAdditionalTaskRowGeometry(row)
  ApplyTaskRowGeometry(row)
  row.specIcon:ClearAllPoints()
  row.specIcon:SetPoint("LEFT", row, "LEFT", 8, 0)
  row.name:ClearAllPoints()
  row.name:SetPoint("LEFT", row.specIcon, "RIGHT", 5, 0)
  local parentWidth = row:GetParent() and row:GetParent():GetWidth()
  local rowWidth = tonumber(row.layoutWidthOverride) or math.max(460, parentWidth or row:GetWidth() or 460)
  local assignmentLeft = math.max(174, math.floor(rowWidth * 0.37))
  row.name:SetPoint("RIGHT", row, "LEFT", assignmentLeft - 5, 0)
end

local function AcquireDetailRow(self, index)
  local row = self.detailRows[index]
  if row then
    return row
  end
  row = CreateFrame("Button", nil, self.detailChild, template)
  if row.SetClipsChildren then
    row:SetClipsChildren(true)
  end
  SetBackdrop(row, colors.row, colors.borderSoft)

  row.section = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  ApplyWidgetFont(row.section, 15)
  row.section:SetHeight(18)
  row.section:SetJustifyH("LEFT")
  if row.section.SetWordWrap then
    row.section:SetWordWrap(false)
  end

  row.classIcon = row:CreateTexture(nil, "ARTWORK")
  row.classIcon:SetSize(22, 22)
  row.classIcon:SetPoint("LEFT", row, "LEFT", 10, 0)
  row.specIcon = row:CreateTexture(nil, "ARTWORK")
  row.specIcon:SetSize(22, 22)
  row.specIcon:SetPoint("LEFT", row.classIcon, "RIGHT", 5, 0)
  row.roleIcon = row:CreateTexture(nil, "ARTWORK")
  row.roleIcon:SetSize(22, 22)
  row.roleIcon:SetPoint("LEFT", row.specIcon, "RIGHT", 5, 0)

  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(row.name, 13)
  row.name:SetPoint("LEFT", row.roleIcon, "RIGHT", 7, 0)
  row.name:SetJustifyH("LEFT")
  if row.name.SetWordWrap then
    row.name:SetWordWrap(false)
  end

  row.spellIcon = row:CreateTexture(nil, "ARTWORK")
  row.spellIcon:SetSize(22, 22)
  row.spellIcon:SetPoint("LEFT", row, "LEFT", 194, 0)
  row.secondarySpellIcon = row:CreateTexture(nil, "ARTWORK")
  row.secondarySpellIcon:SetSize(22, 22)
  row.assignmentMarkerIcon = row:CreateTexture(nil, "ARTWORK")
  row.assignmentMarkerIcon:SetSize(18, 18)
  row.detail = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(row.detail, 12)
  row.detail:SetPoint("LEFT", row.spellIcon, "RIGHT", 7, 0)
  row.detail:SetJustifyH("LEFT")
  if row.detail.SetWordWrap then
    row.detail:SetWordWrap(false)
  end

  row.targetIcon = row:CreateTexture(nil, "ARTWORK")
  row.targetIcon:SetSize(22, 22)
  row.targetIcon:SetPoint("LEFT", row, "LEFT", 368, 0)
  row.targetSpecIcon = row:CreateTexture(nil, "ARTWORK")
  row.targetSpecIcon:SetSize(22, 22)
  row.target = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(row.target, 12)
  row.target:SetPoint("LEFT", row.targetIcon, "RIGHT", 7, 0)
  row.target:SetPoint("RIGHT", row, "RIGHT", -9, 0)
  row.target:SetJustifyH("LEFT")
  if row.target.SetWordWrap then
    row.target:SetWordWrap(false)
  end
  ApplyTaskRowGeometry(row)
  self.detailRows[index] = row
  return row
end

local RefreshDetail

local MAX_SECTION_HEADER_ICONS = 4

local function ApplySectionHeaderIcons(row, icons, indent)
  row.sectionIcons = row.sectionIcons or {}
  local previous
  for index = 1, MAX_SECTION_HEADER_ICONS do
    local value = icons and icons[index]
    local texture = row.sectionIcons[index]
    if value and not texture then
      texture = row:CreateTexture(nil, "ARTWORK")
      texture:SetSize(22, 22)
      row.sectionIcons[index] = texture
    end
    if texture then
      texture:ClearAllPoints()
      if value and SetIconTexture(texture, value) then
        if previous then
          texture:SetPoint("LEFT", previous, "RIGHT", 4, 0)
        else
          texture:SetPoint("LEFT", row, "LEFT", 10 + indent, 0)
        end
        previous = texture
      else
        texture:Hide()
      end
    end
  end
  row.section:ClearAllPoints()
  if previous then
    row.section:SetPoint("LEFT", previous, "RIGHT", 8, 0)
  else
    row.section:SetPoint("LEFT", row, "LEFT", 12 + indent, 0)
  end
  row.section:SetPoint("RIGHT", row, "RIGHT", -12, 0)
end

local function ConfigureSectionRow(self, row, entry, boss, section, collapseKey, indent, isBuffClassSection)
  ResetDetailRow(row)
  collapseKey = collapseKey or section.name
  indent = indent or 0
  local collapsed = MerfinPlus:IsRaidAssignmentSectionCollapsed(entry, boss, collapseKey)
  local label, icon = MerfinPlus:GetRaidAssignmentSectionDisplay(
    section.displayName or section.name,
    section.kind,
    GetSectionAssignmentRole(section)
  )
  -- Section chrome owns these class/special icons. Keep them out of the shared
  -- display so Soulstone, Curse, and other task spell icons remain authoritative.
  icon = icon or GetClassAssignmentSectionIcon(section) or GetSpecialAssignmentSectionIcon(section)
  local icons = icon and { icon } or GetBuffAssignmentSectionIcons(section, isBuffClassSection)
  SetBackdrop(row, colors.heading, collapsed and colors.borderSoft or colors.border)
  ApplySectionHeaderIcons(row, icons, indent)
  row.section:SetText((collapsed and "+ " or "- ") .. tostring(label or section.name) .. "  (" .. tostring(#(section.rows or {})) .. ")")
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
      MerfinPlus:ToggleRaidAssignmentSection(entry, boss, collapseKey, true)
      RefreshDetail(self, self.navigation)
    end
  end)
  return collapsed
end

local function ConfigureTaskRow(row, task, playerMap, sectionName, sectionKind)
  ResetDetailRow(row)
  local display = MerfinPlus:BuildRaidAssignmentRowDisplay(task, sectionName, playerMap)
  if display.isAdditional then ApplyAdditionalTaskRowGeometry(row) else ApplyTaskRowGeometry(row) end
  SetBackdrop(row, colors.row, colors.borderSoft)
  -- The imported row is authoritative for class/spec.  A single placeholder
  -- name can legitimately represent many class/spec rows and must never make
  -- the UI reuse one arbitrary player's icons for every row.
  local classToken = GetClassToken(task.class)
  local spec = task.spec
  local spellLabel, spellIcon, secondarySpellIcon = display.label, display.icon, display.secondaryIcon
  local assignmentMarkerIcon = display.assignmentMarkerIcon
  local targetLabel, targetClassToken, targetIcon = display.target, display.targetClass, display.targetIcon
  local targetIsMarker, targetSpec = display.targetIsMarker, display.targetSpec
  local _, sectionIcon = MerfinPlus:GetRaidAssignmentSectionDisplay(sectionName, sectionKind, task and task.role)
  if not display.isAdditional then spellIcon = sectionIcon or spellIcon end
  if assignmentMarkerIcon == sectionIcon then assignmentMarkerIcon = nil end
  if targetIsMarker and targetIcon == spellIcon then
    targetIcon = nil
  end

  local hasClassIcon = SetIconTexture(row.classIcon, GetClassIcon(classToken))
  local hasSpecIcon = SetIconTexture(row.specIcon, GetSpecIcon(classToken, spec))
  local hasRoleIcon = SetIconTexture(row.roleIcon, GetRoleIcon(spec))
  -- SetIconTexture shows successful textures immediately. Additional rows use
  -- the compact spec-only player layout, so explicitly suppress the class and
  -- role textures before positioning the name after the spec icon.
  if display.isAdditional then
    row.classIcon:Hide()
    row.roleIcon:Hide()
  end
  local hasSpellIcon = SetIconTexture(row.spellIcon, spellIcon)
  local hasSecondarySpellIcon = SetIconTexture(row.secondarySpellIcon, secondarySpellIcon)
  local hasAssignmentMarkerIcon = SetIconTexture(row.assignmentMarkerIcon, assignmentMarkerIcon)
  local hasTargetIcon = SetIconTexture(row.targetIcon, targetIcon)
  local hasTargetSpecIcon = SetIconTexture(row.targetSpecIcon, GetSpecIcon(targetClassToken, targetSpec))

  local r, g, b = GetClassColor(classToken)
  row.name:SetText(task.player or "")
  row.name:SetTextColor(r, g, b, 1)
  local detailLabel = (spellLabel or task.assignment or "")
  row.detail:SetText(detailLabel .. (display.note and display.note ~= "" and (" — " .. display.note) or ""))
  row.detail:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)
  row.target:SetText(targetLabel or "")
  if targetClassToken then
    local tr, tg, tb = GetClassColor(targetClassToken)
    row.target:SetTextColor(tr, tg, tb, 1)
  else
    row.target:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  end

  if not display.isAdditional and hasClassIcon then row.classIcon:Show() end
  if hasSpecIcon then row.specIcon:Show() end
  if not display.isAdditional and hasRoleIcon then row.roleIcon:Show() end
  row.name:Show()
  if hasSpellIcon then
    row.spellIcon:Show()
  end
  if hasSecondarySpellIcon then
    row.secondarySpellIcon:Show()
  end
  if hasAssignmentMarkerIcon then row.assignmentMarkerIcon:Show() end
  row.detail:Show()
  if hasTargetIcon then
    row.targetIcon:Show()
  end
  if hasTargetSpecIcon then
    row.targetSpecIcon:Show()
  end
  local hasTargetText = not targetIsMarker and targetLabel and targetLabel ~= ""
  ApplyTaskAssignmentIconGeometry(
    row,
    hasSpellIcon,
    hasSecondarySpellIcon,
    hasAssignmentMarkerIcon,
    hasTargetIcon,
    hasTargetSpecIcon,
    hasTargetText
  )
  local stackedMultiTarget = false
  if display.multiTarget then
    local rowWidth, _, targetLeft = GetTaskRowGeometry(row)
    local targetWidth = math.max(1, rowWidth - targetLeft - 8)
    local targetTextWidth = row.target.GetStringWidth and row.target:GetStringWidth() or (targetWidth + 1)
    if targetTextWidth > targetWidth then
      ApplyMultiTargetTaskRowGeometry(row)
      stackedMultiTarget = true
    end
  end
  if hasTargetText then
    row.target:Show()
  end
  return stackedMultiTarget and MULTI_TARGET_TASK_ROW_HEIGHT or TASK_ROW_HEIGHT
end

local function GetDetailContentWidth(self)
  local width = tonumber(self.detailScroll and self.detailScroll:GetWidth()) or 0
  if width <= 1 then
    width = tonumber(self.detailPanel and self.detailPanel:GetWidth()) or 0
    if width > 20 then width = width - 20 end
  end
  if width <= 1 then
    width = tonumber(self.frame and self.frame:GetWidth()) or 0
    if width > 20 then width = width - 20 end
  end
  if width <= 1 then width = tonumber(self.detailChild and self.detailChild:GetWidth()) or 520 end
  return math.max(520, math.floor(width + 0.5))
end

local function UpdateDetailScrollGeometry(self, contentHeight)
  local childWidth = GetDetailContentWidth(self)
  self.detailChild:SetWidth(childWidth)
  self.detailChild:SetHeight(math.max(1, contentHeight or 1))
  if self.detailScroll.UpdateScrollChildRect then
    self.detailScroll:UpdateScrollChildRect()
  end

  self.detailLayoutGeneration = (self.detailLayoutGeneration or 0) + 1
  local generation = self.detailLayoutGeneration
  local function ClampScroll()
    if self.detailLayoutGeneration ~= generation then
      return
    end
    if self.detailScroll.UpdateScrollChildRect then
      self.detailScroll:UpdateScrollChildRect()
    end
    local maximum = math.max(0, self.detailScroll:GetVerticalScrollRange() or 0)
    if self.detailScroll:GetVerticalScroll() > maximum then
      self.detailScroll:SetVerticalScroll(maximum)
    end
  end
  ClampScroll()
end

local function GetCatalogBoss(self, navigation)
  local state = MerfinPlus:GetRaidAssignmentUIState()
  if not state.selectedGroup or not state.selectedBossKey then return nil end
  local item
  for _, candidate in ipairs(navigation or {}) do
    if candidate.kind ~= "heading" and candidate.key == state.selectedBossKey then
      item = candidate
      break
    end
  end
  if navigation == nil then
    item = MerfinPlus:GetRaidAssignmentNavigationEntry(state.selectedGroup, state.selectedBossKey)
  end
  if item then return item.boss, item.raid, item.importedBoss, item end
end

RefreshDetail = function(self, navigation)
  local state = MerfinPlus:GetRaidAssignmentUIState()
  local catalogBoss, catalogRaid, navigationBoss, navigationItem = GetCatalogBoss(self, navigation)
  local entry = state.selectedGroup and MerfinPlus:GetRaidAssignmentImportForGroup(state.selectedGroup)
  local importedBoss = navigationBoss
    or (catalogBoss and entry and entry.parsed and MerfinPlus:GetRaidAssignmentBoss(entry.parsed, catalogBoss))

  if not catalogBoss then
    self.detailHeaderIcon:Hide()
    self.detailTitle:SetText(MerfinPlus:T("Select a boss"))
    self.detailSubtitle:SetText("")
    self.detailEmpty:SetText(MerfinPlus:T("Choose a boss from the list."))
    self.detailEmpty:Show()
    self.broadcastButton:Hide()
  else
    local hasHeaderIcon = SetIconTexture(self.detailHeaderIcon, catalogBoss.icon, true)
    self.detailTitle:SetText(catalogBoss.localeID
      and MerfinPlus:GetLocalizedBossName(catalogBoss.localeID, catalogBoss.name)
      or MerfinPlus:T(catalogBoss.name or "Trash"))
    self.detailSubtitle:SetText(
      catalogRaid and MerfinPlus:GetLocalizedRaidName(catalogRaid.localeID, catalogRaid.name) or ""
    )
    self.detailHeaderIcon:SetShown(hasHeaderIcon == true)
    if importedBoss then
      self.detailEmpty:Hide()
      if navigationItem and navigationItem.kind == "additional" then
        self.broadcastButton:Hide()
      else
        self.broadcastButton:Show()
        SetButtonEnabled(self.broadcastButton, true)
      end
    else
      self.detailEmpty:SetText(MerfinPlus:T("No imported assignments exist for this boss."))
      self.detailEmpty:Show()
      self.broadcastButton:Hide()
    end
  end

  local rowIndex, contentHeight = 0, 0
  local previousRow
  local function PlaceRow(row, height)
    row:ClearAllPoints()
    if previousRow then
      row:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", 0, -ROW_GAP)
      row:SetPoint("TOPRIGHT", previousRow, "BOTTOMRIGHT", 0, -ROW_GAP)
      contentHeight = contentHeight + ROW_GAP
    else
      row:SetPoint("TOPLEFT", self.detailChild, "TOPLEFT", 0, 0)
      row:SetPoint("TOPRIGHT", self.detailChild, "TOPRIGHT", 0, 0)
    end
    row:SetHeight(height)
    row:Show()
    previousRow = row
    contentHeight = contentHeight + height
  end

  if importedBoss then
    local playerMap = MerfinPlus:BuildRaidAssignmentPlayerMap(importedBoss)
    for _, section in ipairs(MerfinPlus:GetRaidAssignmentDetailSections(importedBoss)) do
      if #(section.rows or {}) > 0 then
        rowIndex = rowIndex + 1
        local header = AcquireDetailRow(self, rowIndex)
        local collapsed = ConfigureSectionRow(self, header, entry, importedBoss, section)
        PlaceRow(header, SECTION_ROW_HEIGHT)
        if not collapsed then
          local nestedSections = section.isBuffGroup and section.rows or { section }
          for _, nestedSection in ipairs(nestedSections) do
            local nestedCollapsed = false
            if section.isBuffGroup then
              rowIndex = rowIndex + 1
              local classHeader = AcquireDetailRow(self, rowIndex)
              nestedCollapsed = ConfigureSectionRow(
                self,
                classHeader,
                entry,
                importedBoss,
                nestedSection,
                section.name .. "::" .. nestedSection.name,
                16,
                true
              )
              PlaceRow(classHeader, SECTION_ROW_HEIGHT)
            end
            if not nestedCollapsed then
              for _, rowData in ipairs(nestedSection.rows or {}) do
                rowIndex = rowIndex + 1
                local row = AcquireDetailRow(self, rowIndex)
                local task = rowData.task or rowData
                local rowHeight = ConfigureTaskRow(
                  row,
                  task,
                  playerMap,
                  rowData.sectionName or nestedSection.name,
                  nestedSection.kind
                )
                PlaceRow(row, rowHeight)
              end
            end
          end
        end
      end
    end
  end
  for index = rowIndex + 1, #self.detailRows do
    self.detailRows[index]:ClearAllPoints()
    self.detailRows[index]:Hide()
  end
  UpdateDetailScrollGeometry(self, contentHeight)
end

local function AcquireRaidHeading(self, index)
  local heading = self.raidHeadings[index]
  if heading then
    return heading
  end
  heading = CreateFrame("Frame", nil, self.bossChild, template)
  heading:SetHeight(24)
  SetBackdrop(heading, colors.heading, colors.borderSoft)
  heading.label = heading:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(heading.label, 13)
  heading.label:SetPoint("LEFT", heading, "LEFT", 9, 0)
  heading.label:SetPoint("RIGHT", heading, "RIGHT", -9, 0)
  heading.label:SetJustifyH("LEFT")
  heading.label:SetTextColor(colors.cyan[1], colors.cyan[2], colors.cyan[3], 1)
  self.raidHeadings[index] = heading
  return heading
end

local function AcquireBossButton(self, index)
  local button = self.bossButtons[index]
  if button then
    return button
  end
  button = CreateButton(self.bossChild, "", 220)
  button:SetHeight(34)
  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetSize(44, 22)
  button.icon:SetPoint("LEFT", button, "LEFT", 7, 0)
  button.label:ClearAllPoints()
  button.label:SetPoint("LEFT", button.icon, "RIGHT", 7, 0)
  button.label:SetPoint("RIGHT", button, "RIGHT", -7, 0)
  button.label:SetJustifyH("LEFT")
  self.bossButtons[index] = button
  return button
end

local function RefreshBossList(self, navigation)
  local state = MerfinPlus:GetRaidAssignmentUIState()
  local group = MerfinPlus:GetRaidAssignmentGroup(state.selectedGroup)
  local entry = group and MerfinPlus:GetRaidAssignmentImportForGroup(group.id)
  local parsed = entry and entry.parsed
  local y, bossIndex, headingIndex = 0, 0, 0
  local selectedBossIsValid = state.selectedBossKey == nil
  navigation = navigation or MerfinPlus:BuildRaidAssignmentNavigation(parsed, group)
  local function AddBossButton(item)
    bossIndex = bossIndex + 1
    local button = AcquireBossButton(self, bossIndex)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", self.bossChild, "TOPLEFT", 0, -y)
    button:SetPoint("TOPRIGHT", self.bossChild, "TOPRIGHT", 0, -y)
    button.label:SetText(MerfinPlus:T(item.title or "Raid Assignments"))
    SetIconTexture(button.icon, item.boss and item.boss.icon, true)
    if state.selectedBossKey == item.key then selectedBossIsValid = true end
    button.active = state.selectedBossKey == item.key
    SetButtonStyle(button, false, false, button.active)
    button.navigationGroupID = state.selectedGroup
    button.navigationKey = item.key
    button.navigationItem = item
    button:SetScript("OnClick", function(row)
      local selected, selectError = MerfinPlus:SelectRaidAssignmentNavigationEntry(row.navigationGroupID, row.navigationKey, row.navigationItem, true)
      if not selected then
        local currentState = MerfinPlus:GetRaidAssignmentUIState()
        currentState.status = MerfinPlus:T(selectError or "Raid Assignments entry is unavailable.")
        currentState.statusTone = "red"
        self:UpdateStatus(currentState)
        return
      end
      local currentState = MerfinPlus:GetRaidAssignmentUIState()
      for _, bossButton in ipairs(self.bossButtons) do
        if bossButton:IsShown() and bossButton.navigationKey then
          bossButton.active = bossButton.navigationKey == currentState.selectedBossKey
          SetButtonStyle(bossButton, false, false, bossButton.active)
        end
      end
      self.showBossPlanButton.hasPlan = MerfinPlus:HasRaidAssignmentBossPlan(currentState.selectedGroup, currentState.selectedBossKey)
      self.showBossPlanButton.tooltipText = self.showBossPlanButton.hasPlan
        and MerfinPlus:T("Open the complete imported MFPRA Boss Plan for the selected boss.")
        or MerfinPlus:T("No imported MFPRA Boss Plan is available for the selected raid and boss.")
      SetButtonEnabled(self.showBossPlanButton, not self.disabled and self.showBossPlanButton.hasPlan)
      if self.detailScroll then self.detailScroll:SetVerticalScroll(0) end
      RefreshDetail(self, self.navigation)
    end)
    button:Show()
    y = y + 39
  end
  for _, item in ipairs(navigation) do
    if item.kind == "heading" then
      headingIndex = headingIndex + 1
      local heading = AcquireRaidHeading(self, headingIndex)
      heading:ClearAllPoints()
      heading:SetPoint("TOPLEFT", self.bossChild, "TOPLEFT", 0, -y)
      heading:SetPoint("TOPRIGHT", self.bossChild, "TOPRIGHT", 0, -y)
      heading.label:SetText(MerfinPlus:T(item.title))
      heading:Show()
      y = y + 29
    elseif item.kind ~= "additional" then
      AddBossButton(item)
    end
  end
  if not selectedBossIsValid then
    state.selectedBossKey = nil
  end
  for index = bossIndex + 1, #self.bossButtons do
    self.bossButtons[index]:Hide()
  end
  for index = headingIndex + 1, #self.raidHeadings do
    self.raidHeadings[index]:Hide()
  end
  self.bossChild:SetHeight(math.max(1, y))
end

local function SetSecondaryVisible(self, visible)
  local frames = {
    self.bossPanel,
    self.detailPanel,
  }
  for _, frame in ipairs(frames) do
    if visible then
      frame:Show()
    else
      frame:Hide()
    end
  end
end

local function ImportInput(self, raw)
  local state = MerfinPlus:GetRaidAssignmentUIState()
  local entry, errorText, duplicate = MerfinPlus:ImportCanonicalRaidAssignmentSnapshot(raw, state.selectedGroup)
  if not entry then
    state.status = errorText or "Invalid MFPRA Raid Assignments string."
    state.statusTone = "red"
    return false, state.status
  else
    state.input = ""
    state.status = duplicate
      and "Identical MFPRA snapshot selected locally. Nothing was sent."
      or "MFPRA Raid Assignments imported locally. Nothing was sent."
    state.statusTone = "good"
    return true
  end
end

local methods = {
  OnAcquire = function(self)
    self:SetWidth(900)
    self:SetHeight(580)
    MerfinPlus:RegisterRaidAssignmentsWidget(self)
    self:Refresh()
  end,
  OnRelease = function(self)
    MerfinPlus:UnregisterRaidAssignmentsWidget(self)
    CloseRaidMenu(self)
    CloseSavedImportMenu(self)
  end,
  SetText = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled == true
    SetButtonEnabled(self.importButton, not self.disabled)
    SetButtonEnabled(self.savedImportDropdown, not self.disabled)
    SetButtonEnabled(self.removeSavedImportButton, not self.disabled)
    SetButtonEnabled(self.broadcastButton, not self.disabled)
    SetButtonEnabled(self.syncFullButton, not self.disabled)
    SetButtonEnabled(self.showBossPlanButton, not self.disabled and self.showBossPlanButton.hasPlan)
  end,
  UpdateStatus = function(self, state)
    state = state or MerfinPlus:GetRaidAssignmentUIState()
    self.status:SetText(MerfinPlus:LocalizeRaidAssignmentStatus(state.status))
    local tone = colors[state.statusTone or "muted"] or colors.muted
    self.status:SetTextColor(tone[1], tone[2], tone[3], tone[4])
  end,
  UpdateTransportProgress = function(self, progress)
    if not self.transportProgress then return end
    if not progress or progress.phase == "idle" then
      self.transportProgress:Hide()
      return
    end
    local confirmed = math.max(0, tonumber(progress.confirmed) or 0)
    local target = math.max(0, tonumber(progress.target) or 0)
    local phase = tostring(progress.phase or "pending")
    local suffix = phase == "preparing" and MerfinPlus:T(" (preparing)")
      or phase == "discovering" and MerfinPlus:T(" (discovering)")
      or phase == "complete" and MerfinPlus:T(" (complete)")
      or phase == "partial" and MerfinPlus:T(" (partial)")
      or phase == "local" and MerfinPlus:T(" (local)")
      or phase == "failed" and MerfinPlus:T(" (failed)")
      or ""
    local texture = phase == "failed" and "Interface\\RaidFrame\\ReadyCheck-NotReady"
      or (phase == "complete" or phase == "local") and "Interface\\RaidFrame\\ReadyCheck-Ready"
      or "Interface\\Icons\\INV_Misc_PocketWatch_01"
    local tone = phase == "failed" and colors.red
      or (phase == "complete" or phase == "local") and colors.good
      or phase == "partial" and colors.border
      or colors.cyan
    self.transportProgressIcon:SetTexture(texture)
    self.transportProgressText:SetText(MerfinPlus:T("Players %d/%d%s", confirmed, target, suffix))
    self.transportProgressText:SetTextColor(tone[1], tone[2], tone[3], 1)
    self.transportProgress.tooltipText = MerfinPlus:LocalizeRaidAssignmentStatus(progress.detail)
    self.transportProgress:Show()
  end,
  Refresh = function(self)
    local state = MerfinPlus:GetRaidAssignmentUIState()
    local group = MerfinPlus:GetRaidAssignmentGroup(state.selectedGroup)
    local entry = group and MerfinPlus:GetRaidAssignmentImportForGroup(group.id)
    local navigation = MerfinPlus:BuildRaidAssignmentNavigation(entry and entry.parsed, group)
    self.navigation = navigation
    local canTransfer, transferReason = MerfinPlus:CanCanonicalRaidAssignmentAction()
    self:UpdateTransportProgress(MerfinPlus:GetRaidAssignmentTransportProgress())
    self.importButton.label:SetText(MerfinPlus:T("Import"))
    self.savedImportText:SetText(MerfinPlus:T("Saved Imports"))
    self.removeSavedImportButton.label:SetText(MerfinPlus:T("Remove"))
    self.syncFullButton.label:SetText(MerfinPlus:T("Sync Full Assignments"))
    self.showBossPlanButton.label:SetText(MerfinPlus:T("Show Boss Plan"))
    self.broadcastButton.label:SetText(MerfinPlus:T("Send Boss Assignments"))
    self.importButton.tooltipTitle = MerfinPlus:T("Import Raid Assignments")
    self.importButton.tooltipText = MerfinPlus:T("Import one canonical MFPRA snapshot locally. This never sends addon data and does not require a group.")
    self.syncFullButton.tooltipTitle = MerfinPlus:T("Sync Full Assignments")
    self.syncFullButton.tooltipText = canTransfer
      and MerfinPlus:T("Explicitly broadcast the complete MFPRA assignment and Boss Plan snapshot.")
      or MerfinPlus:T(transferReason or "Only the raid leader or an assistant can sync.")
    self.broadcastButton.tooltipTitle = MerfinPlus:T("Send Boss Assignments")
    self.broadcastButton.tooltipText = canTransfer
      and MerfinPlus:T("Broadcast the selected boss assignment/widget delta and any matching Quick Overview Boss Plans.")
      or MerfinPlus:T(transferReason or "Only the raid leader or an assistant can send.")
    SetButtonEnabled(self.importButton, not self.disabled)
    SetButtonEnabled(self.syncFullButton, not self.disabled and canTransfer and group ~= nil)
    self.raidDropdownText:SetText(group
      and MerfinPlus:GetLocalizedRaidName(group.id, group.name)
      or MerfinPlus:T("Select Raid"))
    local selectedSaved
    for _, entry in ipairs(MerfinPlus:GetSavedRaidAssignmentImports()) do
      if entry.id == state.selectedSavedRaidImportID then
        selectedSaved = entry
        break
      end
    end
    if state.selectedSavedRaidImportID and not selectedSaved then
      state.selectedSavedRaidImportID = nil
    end
    self.savedImportText:SetText(selectedSaved and selectedSaved.savedLabel or MerfinPlus:T("Saved Imports"))
    SetButtonEnabled(self.removeSavedImportButton, not self.disabled and selectedSaved ~= nil)
    SetSecondaryVisible(self, group ~= nil)
    self:UpdateStatus(state)
    if not group then
      self.showBossPlanButton.hasPlan = false
      self.showBossPlanButton.tooltipText = MerfinPlus:T("Select a raid and import an MFPRA snapshot with a Boss Plan to enable this button.")
      self.showBossPlanButton:Show()
      SetButtonEnabled(self.showBossPlanButton, false)
      return
    end
    RefreshBossList(self, navigation)
    self.showBossPlanButton.hasPlan = MerfinPlus:HasRaidAssignmentBossPlan(group.id, state.selectedBossKey)
    self.showBossPlanButton.tooltipText = self.showBossPlanButton.hasPlan
      and MerfinPlus:T("Open the complete imported MFPRA Boss Plan for the selected boss.")
      or MerfinPlus:T("No imported MFPRA Boss Plan is available for the selected raid and boss.")
    self.showBossPlanButton:Show()
    SetButtonEnabled(self.showBossPlanButton, not self.disabled and self.showBossPlanButton.hasPlan)
    RefreshDetail(self, navigation)
    if self.broadcastButton:IsShown() then SetButtonEnabled(self.broadcastButton, not self.disabled and canTransfer) end
    if self.raidMenu:IsShown() then
      RefreshRaidMenu(self)
    end
    if self.savedImportMenu:IsShown() then
      RefreshSavedImportMenu(self)
    end
  end,
}

local function Constructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(580)

  local raidDropdown = CreateFrame("Button", nil, frame, template)
  raidDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  raidDropdown:SetSize(260, 30)
  raidDropdown:RegisterForClicks("AnyUp")
  SetBackdrop(raidDropdown, colors.field, colors.border)
  local raidDropdownText = raidDropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(raidDropdownText, 14)
  raidDropdownText:SetPoint("LEFT", raidDropdown, "LEFT", 10, 0)
  raidDropdownText:SetPoint("RIGHT", raidDropdown, "RIGHT", -26, 0)
  raidDropdownText:SetJustifyH("LEFT")
  local arrow = raidDropdown:CreateTexture(nil, "OVERLAY")
  arrow:SetTexture(DROPDOWN_ARROW_TEXTURE)
  arrow:SetSize(16, 16)
  arrow:SetPoint("RIGHT", raidDropdown, "RIGHT", -7, 0)
  arrow:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  if arrow.SetRotation then
    arrow:SetRotation(math.pi)
  else
    arrow:SetTexCoord(1, 0, 1, 0)
  end

  local raidMenu = CreateFrame("Frame", nil, UIParent, template)
  raidMenu:SetFrameStrata("TOOLTIP")
  raidMenu:SetClampedToScreen(true)
  raidMenu:SetWidth(260)
  SetBackdrop(raidMenu, colors.menu, colors.border)
  raidMenu:Hide()

  local inputWrap = CreateFrame("Frame", nil, frame, template)
  inputWrap:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -40)
  inputWrap:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -98, -40)
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
  if editBox.SetMaxLetters then
    editBox:SetMaxLetters(0)
  end
  if editBox.SetMaxBytes then
    editBox:SetMaxBytes(0)
  end
  editBox:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  ApplyWidgetFont(editBox, DEFAULT_FONT_HEIGHT)
  MerfinPlus:ConfigureAssignmentImportEditBox(editBox)
  inputScroll:SetScrollChild(editBox)
  inputScroll:EnableMouse(true)
  inputScroll:SetScript("OnMouseDown", function()
    editBox:SetFocus()
  end)
  editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)

  local importButton = CreateButton(frame, MerfinPlus:T("Import"), 80)
  importButton:SetPoint("LEFT", raidDropdown, "RIGHT", 8, 0)
  local savedImportDropdown = CreateButton(frame, MerfinPlus:T("Saved Imports"), 300)
  savedImportDropdown:SetPoint("LEFT", importButton, "RIGHT", 8, 0)
  savedImportDropdown.label:ClearAllPoints()
  savedImportDropdown.label:SetPoint("LEFT", savedImportDropdown, "LEFT", 9, 0)
  savedImportDropdown.label:SetPoint("RIGHT", savedImportDropdown, "RIGHT", -9, 0)
  savedImportDropdown.label:SetJustifyH("LEFT")
  local savedImportMenu = CreateFrame("Frame", nil, UIParent, template)
  savedImportMenu:SetFrameStrata("TOOLTIP")
  savedImportMenu:SetFrameLevel(100)
  savedImportMenu:SetClampedToScreen(true)
  savedImportMenu:SetWidth(302)
  savedImportMenu:EnableMouse(true)
  savedImportMenu:SetAlpha(1)
  SetBackdrop(savedImportMenu, colors.menu, colors.border)
  savedImportMenu:Hide()
  local removeSavedImportButton = CreateButton(frame, MerfinPlus:T("Remove"), 76)
  removeSavedImportButton:SetPoint("LEFT", savedImportDropdown, "RIGHT", 8, 0)
  local syncFullButton = CreateButton(frame, MerfinPlus:T("Sync Full Assignments"), 260)
  syncFullButton:SetPoint("TOPLEFT", raidDropdown, "BOTTOMLEFT", 0, -8)
  local showBossPlanButton = CreateButton(frame, MerfinPlus:T("Show Boss Plan"), 180)
  showBossPlanButton:SetPoint("LEFT", syncFullButton, "RIGHT", 8, 0)
  showBossPlanButton.keepMouseWhenDisabled = true
  showBossPlanButton.tooltipTitle = MerfinPlus:T("Show Boss Plan")
  showBossPlanButton.tooltipText = MerfinPlus:T("Select a raid and import an MFPRA snapshot with a Boss Plan to enable this button.")
  showBossPlanButton:Show()
  local transportProgress = CreateFrame("Frame", nil, frame)
  transportProgress:SetPoint("LEFT", showBossPlanButton, "RIGHT", 8, 0)
  transportProgress:SetSize(280, 30)
  transportProgress:EnableMouse(true)
  transportProgress:Hide()
  local transportProgressIcon = transportProgress:CreateTexture(nil, "ARTWORK")
  transportProgressIcon:SetSize(18, 18)
  transportProgressIcon:SetPoint("LEFT", transportProgress, "LEFT", 0, 0)
  transportProgressIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  local transportProgressText = transportProgress:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(transportProgressText, 12)
  transportProgressText:SetPoint("LEFT", transportProgressIcon, "RIGHT", 5, 0)
  transportProgressText:SetPoint("RIGHT", transportProgress, "RIGHT", 0, 0)
  transportProgressText:SetJustifyH("LEFT")
  transportProgress:SetScript("OnEnter", function(progressFrame)
    if progressFrame.tooltipText and progressFrame.tooltipText ~= "" and GameTooltip then
      GameTooltip:SetOwner(progressFrame, "ANCHOR_TOP")
      GameTooltip:SetText(MerfinPlus:T("Assignment Transport"), theme.accentBright[1], theme.accentBright[2], theme.accentBright[3])
      GameTooltip:AddLine(progressFrame.tooltipText, 0.88, 0.9, 0.94, true)
      GameTooltip:Show()
    end
  end)
  transportProgress:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  local status = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(status, 12)
  status:SetPoint("TOPLEFT", syncFullButton, "BOTTOMLEFT", 2, -4)
  status:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -74)
  status:SetJustifyH("LEFT")

  local bossPanel = CreateFrame("Frame", nil, frame, template)
  bossPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -94)
  bossPanel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  bossPanel:SetWidth(246)
  SetBackdrop(bossPanel, colors.panel, colors.borderSoft)
  local bossScroll = CreateFrame("ScrollFrame", nil, bossPanel)
  bossScroll:SetPoint("TOPLEFT", bossPanel, "TOPLEFT", 9, -9)
  bossScroll:SetPoint("BOTTOMRIGHT", bossPanel, "BOTTOMRIGHT", -9, 9)
  bossScroll:EnableMouseWheel(true)
  local bossChild = CreateFrame("Frame", nil, bossScroll)
  bossChild:SetSize(228, 1)
  bossScroll:SetScrollChild(bossChild)

  local detailPanel = CreateFrame("Frame", nil, frame, template)
  detailPanel:SetPoint("TOPLEFT", bossPanel, "TOPRIGHT", 10, 0)
  detailPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  SetBackdrop(detailPanel, colors.panel, colors.borderSoft)
  local detailHeaderIcon = detailPanel:CreateTexture(nil, "ARTWORK")
  detailHeaderIcon:SetSize(80, 40)
  detailHeaderIcon:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 14, -14)
  local detailTitle = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  ApplyWidgetFont(detailTitle, 18)
  detailTitle:SetPoint("TOPLEFT", detailHeaderIcon, "TOPRIGHT", 11, -1)
  detailTitle:SetPoint("RIGHT", detailPanel, "RIGHT", -130, -1)
  detailTitle:SetJustifyH("LEFT")
  detailTitle:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  local detailSubtitle = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(detailSubtitle, 13)
  detailSubtitle:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -5)
  detailSubtitle:SetPoint("RIGHT", detailPanel, "RIGHT", -130, -5)
  detailSubtitle:SetJustifyH("LEFT")
  detailSubtitle:SetTextColor(colors.cyan[1], colors.cyan[2], colors.cyan[3], 1)
  local broadcastButton = CreateButton(detailPanel, MerfinPlus:T("Send Boss Assignments"), 150)
  broadcastButton:SetPoint("TOPRIGHT", detailPanel, "TOPRIGHT", -12, -14)

  local detailScroll = CreateFrame("ScrollFrame", nil, detailPanel)
  detailScroll:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 10, -66)
  detailScroll:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", -10, 10)
  detailScroll:EnableMouseWheel(true)
  local detailChild = CreateFrame("Frame", nil, detailScroll)
  detailChild:SetSize(520, 1)
  detailChild:SetPoint("TOPLEFT", detailScroll, "TOPLEFT", 0, 0)
  detailScroll:SetScrollChild(detailChild)
  local detailEmpty = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(detailEmpty, 14)
  detailEmpty:SetPoint("CENTER", detailScroll, "CENTER", 0, 0)
  detailEmpty:SetWidth(360)
  detailEmpty:SetJustifyH("CENTER")
  detailEmpty:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

  local self = {
    type = WIDGET_TYPE,
    frame = frame,
    raidDropdown = raidDropdown,
    raidDropdownText = raidDropdownText,
    raidMenu = raidMenu,
    raidOptions = {},
    inputWrap = inputWrap,
    inputScroll = inputScroll,
    editBox = editBox,
    importButton = importButton,
    savedImportDropdown = savedImportDropdown,
    savedImportText = savedImportDropdown.label,
    savedImportMenu = savedImportMenu,
    savedImportOptions = {},
    removeSavedImportButton = removeSavedImportButton,
    syncFullButton = syncFullButton,
    showBossPlanButton = showBossPlanButton,
    transportProgress = transportProgress,
    transportProgressIcon = transportProgressIcon,
    transportProgressText = transportProgressText,
    status = status,
    bossPanel = bossPanel,
    bossScroll = bossScroll,
    bossChild = bossChild,
    bossButtons = {},
    raidHeadings = {},
    detailPanel = detailPanel,
    detailHeaderIcon = detailHeaderIcon,
    detailTitle = detailTitle,
    detailSubtitle = detailSubtitle,
    broadcastButton = broadcastButton,
    detailScroll = detailScroll,
    detailChild = detailChild,
    detailEmpty = detailEmpty,
    detailRows = {},
  }
  frame.obj = self
  raidDropdown.obj = self
  importButton.obj = self
  savedImportDropdown.obj = self
  removeSavedImportButton.obj = self
  syncFullButton.obj = self
  showBossPlanButton.obj = self
  broadcastButton.obj = self

  for name, method in pairs(methods) do
    self[name] = method
  end

  for index, group in ipairs(MerfinPlus:GetRaidAssignmentGroups()) do
    local option = CreateButton(raidMenu, group.name, 252)
    option:SetHeight(29)
    option:SetPoint("TOPLEFT", raidMenu, "TOPLEFT", 4, -4 - ((index - 1) * 32))
    option:SetPoint("TOPRIGHT", raidMenu, "TOPRIGHT", -4, -4 - ((index - 1) * 32))
    option.label:SetJustifyH("LEFT")
    option.label:ClearAllPoints()
    option.label:SetPoint("LEFT", option, "LEFT", 9, 0)
    option.label:SetPoint("RIGHT", option, "RIGHT", -9, 0)
    option.groupID = group.id
    option:SetScript("OnClick", function(row)
      local state = MerfinPlus:GetRaidAssignmentUIState()
      state.selectedGroup = row.groupID
      state.selectedBossKey = nil
      state.input = ""
      state.status = ""
      state.statusTone = "muted"
      editBox:SetText("")
      CloseRaidMenu(self)
      MerfinPlus:NotifyRaidAssignmentsChanged()
    end)
    self.raidOptions[index] = option
  end

  raidDropdown:SetScript("OnClick", function()
    OpenRaidMenu(self)
  end)
  raidDropdown:SetScript("OnEnter", function(button)
    SetBackdrop(button, colors.hover, colors.border)
  end)
  raidDropdown:SetScript("OnLeave", function(button)
    SetBackdrop(button, colors.field, colors.border)
  end)
  importButton:SetScript("OnClick", function()
    if not self.disabled then
      MerfinPlus:ShowAssignmentImportDialog(MerfinPlus:T("Import Raid Assignments"), function(raw)
        return ImportInput(self, raw)
      end, MerfinPlus:T("Import"))
    end
  end)
  savedImportDropdown:SetScript("OnClick", function()
    if not self.disabled then
      OpenSavedImportMenu(self)
    end
  end)
  removeSavedImportButton:SetScript("OnClick", function()
    local importID = MerfinPlus:GetRaidAssignmentUIState().selectedSavedRaidImportID
    if importID then
      local removed, removeError = MerfinPlus:RemoveSavedRaidAssignmentImport(importID)
      if not removed then
        local state = MerfinPlus:GetRaidAssignmentUIState()
        state.status = MerfinPlus:T(removeError or "Saved Raid Assignments import is unavailable.")
        state.statusTone = "red"
        MerfinPlus:NotifyRaidAssignmentStatusChanged()
      end
    end
  end)
  syncFullButton:SetScript("OnClick", function()
    if not self.disabled then
      local state = MerfinPlus:GetRaidAssignmentUIState()
      local sent, reason = MerfinPlus:BroadcastFullRaidAssignments(state.selectedGroup, true)
      if not sent then
        state.status = MerfinPlus:T(reason or "Full Raid Assignments sync is unavailable.")
        state.statusTone = "red"
        self:UpdateStatus(state)
      end
    end
  end)
  showBossPlanButton:SetScript("OnClick", function()
    local state = MerfinPlus:GetRaidAssignmentUIState()
    if self.disabled or showBossPlanButton.disabled then
      state.status = showBossPlanButton.tooltipText or MerfinPlus:T("Import an MFPRA Boss Plan first.")
      state.statusTone = "muted"
      MerfinPlus:NotifyRaidAssignmentStatusChanged()
      return
    end
    local shown, reason = MerfinPlus:ShowCurrentRaidAssignmentBossPlan(state.selectedGroup, state.selectedBossKey)
    if not shown then
      state.status = MerfinPlus:T(reason or "Boss Plan is unavailable.")
      state.statusTone = "red"
      MerfinPlus:NotifyRaidAssignmentStatusChanged()
    end
  end)
  broadcastButton:SetScript("OnClick", function()
    if not self.disabled then
      local boss = GetCatalogBoss(self, self.navigation)
      if boss then
        MerfinPlus:BroadcastPersonalRaidAssignments(boss, true)
      end
    end
  end)
  editBox:SetScript("OnTextChanged", function(box)
    local text = box:GetText() or ""
    MerfinPlus:GetRaidAssignmentUIState().input = text
    local _, newlineCount = text:gsub("\n", "\n")
    box:SetHeight(math.max(inputScroll:GetHeight(), ((newlineCount + 1) * DEFAULT_FONT_HEIGHT) + 6))
  end)
  inputScroll:SetScript("OnSizeChanged", function(scrollFrame, width, height)
    editBox:SetWidth(math.max(1, width))
    local text = editBox:GetText() or ""
    local _, newlineCount = text:gsub("\n", "\n")
    editBox:SetHeight(math.max(height, ((newlineCount + 1) * DEFAULT_FONT_HEIGHT) + 6))
  end)
  bossScroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 40)
    scrollFrame:SetVerticalScroll(math.max(0, math.min(scrollFrame:GetVerticalScrollRange(), nextValue)))
  end)
  detailScroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 40)
    scrollFrame:SetVerticalScroll(math.max(0, math.min(scrollFrame:GetVerticalScrollRange(), nextValue)))
  end)
  detailScroll:SetScript("OnSizeChanged", function(_, width)
    local layoutWidth = math.floor(math.max(1, width or 1) + 0.5)
    detailChild:SetWidth(layoutWidth)
    if self.detailLayoutWidth == layoutWidth then return end
    self.detailLayoutWidth = layoutWidth
    RefreshDetail(self, self.navigation)
  end)
  frame:SetScript("OnSizeChanged", function(_, width)
    bossChild:SetWidth(math.max(1, bossPanel:GetWidth() - 18))
    if detailScroll:GetWidth() and detailScroll:GetWidth() > 0 then
      detailChild:SetWidth(detailScroll:GetWidth())
    else
      detailChild:SetWidth(math.max(1, width - bossPanel:GetWidth() - 40))
    end
  end)
  frame:SetScript("OnHide", function()
    CloseRaidMenu(self)
    CloseSavedImportMenu(self)
  end)
  inputWrap:Hide()

  return AceGUI:RegisterAsWidget(self)
end

local function CreateRaidSelector(parent, width)
  local dropdown = CreateFrame("Button", nil, parent, template)
  dropdown:SetSize(width or 300, 30)
  dropdown:RegisterForClicks("AnyUp")
  SetBackdrop(dropdown, colors.field, colors.border)
  local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(label, 14)
  label:SetPoint("LEFT", dropdown, "LEFT", 10, 0)
  label:SetPoint("RIGHT", dropdown, "RIGHT", -26, 0)
  label:SetJustifyH("LEFT")
  local arrow = dropdown:CreateTexture(nil, "OVERLAY")
  arrow:SetTexture(DROPDOWN_ARROW_TEXTURE)
  arrow:SetSize(16, 16)
  arrow:SetPoint("RIGHT", dropdown, "RIGHT", -7, 0)
  arrow:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  if arrow.SetRotation then arrow:SetRotation(math.pi) else arrow:SetTexCoord(1, 0, 1, 0) end

  local menu = CreateFrame("Frame", nil, UIParent, template)
  menu:SetFrameStrata("TOOLTIP")
  menu:SetClampedToScreen(true)
  menu:SetWidth(width or 300)
  SetBackdrop(menu, colors.menu, colors.border)
  menu:Hide()
  return dropdown, label, menu
end

local function PopulateRaidSelector(self, onSelected)
  for index, group in ipairs(MerfinPlus:GetRaidAssignmentGroups()) do
    local option = CreateButton(self.raidMenu, group.name, self.raidMenu:GetWidth() - 8)
    option:SetHeight(29)
    option:SetPoint("TOPLEFT", self.raidMenu, "TOPLEFT", 4, -4 - ((index - 1) * 32))
    option:SetPoint("TOPRIGHT", self.raidMenu, "TOPRIGHT", -4, -4 - ((index - 1) * 32))
    option.label:SetJustifyH("LEFT")
    option.label:ClearAllPoints()
    option.label:SetPoint("LEFT", option, "LEFT", 9, 0)
    option.label:SetPoint("RIGHT", option, "RIGHT", -9, 0)
    option.groupID = group.id
    option:SetScript("OnClick", function(row)
      local state = MerfinPlus:GetRaidAssignmentUIState()
      state.selectedGroup = row.groupID
      state.selectedBossKey = nil
      state.status = ""
      state.statusTone = "muted"
      CloseRaidMenu(self)
      if onSelected then onSelected(self, row.groupID) end
      if self.detailScroll then self.detailScroll:SetVerticalScroll(0) end
      MerfinPlus:NotifyRaidAssignmentsChanged()
    end)
    self.raidOptions[index] = option
  end
  self.raidDropdown:SetScript("OnClick", function() OpenRaidMenu(self) end)
  self.raidDropdown:SetScript("OnEnter", function(button) SetBackdrop(button, colors.hover, colors.border) end)
  self.raidDropdown:SetScript("OnLeave", function(button) SetBackdrop(button, colors.field, colors.border) end)
end

local function CreateImportEditBox(parent, height)
  local wrap = CreateFrame("Frame", nil, parent, template)
  wrap:SetHeight(height or 100)
  SetBackdrop(wrap, colors.field, colors.borderSoft)
  local scroll = CreateFrame("ScrollFrame", nil, wrap)
  scroll:SetPoint("TOPLEFT", wrap, "TOPLEFT", 9, -7)
  scroll:SetPoint("BOTTOMRIGHT", wrap, "BOTTOMRIGHT", -9, 7)
  scroll:EnableMouseWheel(true)
  local editBox = CreateFrame("EditBox", nil, scroll)
  editBox:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
  editBox:SetWidth(1)
  editBox:SetHeight(height or 100)
  editBox:SetAutoFocus(false)
  editBox:SetMultiLine(true)
  if editBox.SetMaxLetters then editBox:SetMaxLetters(0) end
  if editBox.SetMaxBytes then editBox:SetMaxBytes(0) end
  editBox:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  ApplyWidgetFont(editBox, DEFAULT_FONT_HEIGHT)
  MerfinPlus:ConfigureAssignmentImportEditBox(editBox)
  scroll:SetScrollChild(editBox)
  scroll:SetScript("OnMouseDown", function() editBox:SetFocus() end)
  scroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 28)
    scrollFrame:SetVerticalScroll(math.max(0, math.min(scrollFrame:GetVerticalScrollRange(), nextValue)))
  end)
  editBox:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
  editBox:SetScript("OnTextChanged", function(box)
    local text = box:GetText() or ""
    MerfinPlus:GetRaidAssignmentUIState().input = text
    local _, newlineCount = text:gsub("\n", "\n")
    box:SetHeight(math.max(scroll:GetHeight(), ((newlineCount + 1) * DEFAULT_FONT_HEIGHT) + 8))
  end)
  scroll:SetScript("OnSizeChanged", function(_, width, scrollHeight)
    editBox:SetWidth(math.max(1, width))
    local text = editBox:GetText() or ""
    local _, newlineCount = text:gsub("\n", "\n")
    editBox:SetHeight(math.max(scrollHeight, ((newlineCount + 1) * DEFAULT_FONT_HEIGHT) + 8))
  end)
  return wrap, scroll, editBox
end

local function StopRecipientSpinner(row)
  if row.spinner and row.spinner.IsPlaying and row.spinner:IsPlaying() then row.spinner:Stop() end
  if row.statusIcon.SetRotation then row.statusIcon:SetRotation(0) end
end

local function StartRecipientSpinner(row)
  if not row.spinner and row.statusIcon.CreateAnimationGroup then
    local ok, group = pcall(row.statusIcon.CreateAnimationGroup, row.statusIcon)
    if ok and group then
      local animation = group:CreateAnimation("Rotation")
      animation:SetDegrees(-360)
      animation:SetDuration(1.1)
      animation:SetOrder(1)
      group:SetLooping("REPEAT")
      row.spinner = group
    end
  end
  if row.spinner and row.spinner.Play then row.spinner:Play() end
end

local function AcquireRecipientRow(self, index)
  local row = self.recipientRows[index]
  if row then return row end
  row = CreateFrame("Frame", nil, self.recipientChild, template)
  row:SetHeight(25)
  SetBackdrop(row, colors.row, colors.borderSoft)
  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(row.name, 13)
  row.name:SetPoint("LEFT", row, "LEFT", 9, 0)
  row.name:SetPoint("RIGHT", row, "RIGHT", -122, 0)
  row.name:SetJustifyH("LEFT")
  row.statusIcon = row:CreateTexture(nil, "ARTWORK")
  row.statusIcon:SetSize(17, 17)
  row.statusIcon:SetPoint("RIGHT", row, "RIGHT", -92, 0)
  row.statusIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  row.detail = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(row.detail, 11)
  row.detail:SetPoint("LEFT", row.statusIcon, "RIGHT", 6, 0)
  row.detail:SetPoint("RIGHT", row, "RIGHT", -8, 0)
  row.detail:SetJustifyH("LEFT")
  self.recipientRows[index] = row
  return row
end

local function RefreshRecipientRows(self, progress)
  local recipients = progress and progress.recipients or {}
  local y = 0
  for index, recipient in ipairs(recipients) do
    local row = AcquireRecipientRow(self, index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", self.recipientChild, "TOPLEFT", 0, -y)
    row:SetPoint("TOPRIGHT", self.recipientChild, "TOPRIGHT", 0, -y)
    row.name:SetText(recipient.name or recipient.commName or "Unknown")
    local r, g, b = GetClassColor(recipient.classToken)
    row.name:SetTextColor(r, g, b, 1)
    local status = tostring(recipient.status or "pending")
    if status == "success" then
      StopRecipientSpinner(row)
      row.statusIcon:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
      row.statusIcon:SetVertexColor(1, 1, 1, 1)
      row.detail:SetText(MerfinPlus:T(recipient.detail or "Confirmed"))
      row.detail:SetTextColor(colors.good[1], colors.good[2], colors.good[3], 1)
    elseif status == "failed" then
      StopRecipientSpinner(row)
      row.statusIcon:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
      row.statusIcon:SetVertexColor(1, 1, 1, 1)
      row.detail:SetText(MerfinPlus:T(recipient.detail or "Failed"))
      row.detail:SetTextColor(colors.red[1], colors.red[2], colors.red[3], 1)
    else
      row.statusIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
      row.statusIcon:SetVertexColor(colors.cyan[1], colors.cyan[2], colors.cyan[3], 1)
      row.detail:SetText(MerfinPlus:T(recipient.detail or "Sending"))
      row.detail:SetTextColor(colors.cyan[1], colors.cyan[2], colors.cyan[3], 1)
      StartRecipientSpinner(row)
    end
    row:Show()
    y = y + 28
  end
  for index = #recipients + 1, #self.recipientRows do
    StopRecipientSpinner(self.recipientRows[index])
    self.recipientRows[index]:Hide()
  end
  self.recipientChild:SetHeight(math.max(1, y))
  self.recipientEmpty:SetShown(#recipients == 0)
end

local syncMethods = {
  OnAcquire = function(self)
    self:SetWidth(900)
    self:SetHeight(580)
    MerfinPlus:RegisterRaidAssignmentsWidget(self)
    self:Refresh()
  end,
  OnRelease = function(self)
    MerfinPlus:UnregisterRaidAssignmentsWidget(self)
    CloseRaidMenu(self)
    CloseSavedImportMenu(self)
    for _, row in ipairs(self.recipientRows) do StopRecipientSpinner(row) end
  end,
  SetText = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled == true
    SetButtonEnabled(self.importButton, not self.disabled and MerfinPlus:GetRaidAssignmentUIState().selectedGroup ~= nil)
    SetButtonEnabled(self.savedImportDropdown, not self.disabled)
    SetButtonEnabled(self.removeSavedImportButton, not self.disabled and self.selectedSavedImport ~= nil)
    local canTransfer = MerfinPlus:CanCanonicalRaidAssignmentAction()
    SetButtonEnabled(self.syncFullButton, not self.disabled and canTransfer and MerfinPlus:GetRaidAssignmentUIState().selectedGroup ~= nil)
  end,
  UpdateStatus = function(self, state)
    state = state or MerfinPlus:GetRaidAssignmentUIState()
    self.status:SetText(MerfinPlus:LocalizeRaidAssignmentStatus(state.status))
    local tone = colors[state.statusTone or "muted"] or colors.muted
    self.status:SetTextColor(tone[1], tone[2], tone[3], tone[4])
  end,
  UpdateTransportProgress = function(self, progress)
    if progress and progress.kind ~= "F" then return end
    self.transportProgress = progress
    RefreshRecipientRows(self, progress)
  end,
  Refresh = function(self)
    local state = MerfinPlus:GetRaidAssignmentUIState()
    local group = MerfinPlus:GetRaidAssignmentGroup(state.selectedGroup)
    local canTransfer, transferReason = MerfinPlus:CanCanonicalRaidAssignmentAction()
    self.raidDropdownText:SetText(group and MerfinPlus:GetLocalizedRaidName(group.id, group.name) or MerfinPlus:T("Select Raid"))
    if not self.editBox:HasFocus() and self.editBox:GetText() ~= tostring(state.input or "") then
      self.editBox:SetText(state.input or "")
    end
    self.importButton.label:SetText(MerfinPlus:T("Import"))
    self.syncFullButton.label:SetText(MerfinPlus:T("Sync Full Assignments"))
    self.removeSavedImportButton.label:SetText(MerfinPlus:T("Remove"))
    local selectedSaved
    for _, entry in ipairs(MerfinPlus:GetSavedRaidAssignmentImports()) do
      if entry.id == state.selectedSavedRaidImportID then selectedSaved = entry break end
    end
    if state.selectedSavedRaidImportID and not selectedSaved then state.selectedSavedRaidImportID = nil end
    self.selectedSavedImport = selectedSaved
    self.savedImportText:SetText(selectedSaved and selectedSaved.savedLabel or MerfinPlus:T("Saved Imports"))
    SetButtonEnabled(self.importButton, not self.disabled and group ~= nil)
    SetButtonEnabled(self.savedImportDropdown, not self.disabled)
    SetButtonEnabled(self.removeSavedImportButton, not self.disabled and selectedSaved ~= nil)
    SetButtonEnabled(self.syncFullButton, not self.disabled and canTransfer and group ~= nil)
    self.syncFullButton.tooltipTitle = MerfinPlus:T("Sync Full Assignments")
    self.syncFullButton.tooltipText = canTransfer
      and MerfinPlus:T("Explicitly broadcast the complete MFPRA assignment and Boss Plan snapshot.")
      or MerfinPlus:T(transferReason or "Only the raid leader or an assistant can sync.")
    self:UpdateStatus(state)
    self:UpdateTransportProgress(MerfinPlus:GetRaidAssignmentTransportProgress())
    if self.raidMenu:IsShown() then RefreshRaidMenu(self) end
    if self.savedImportMenu:IsShown() then RefreshSavedImportMenu(self) end
  end,
}

local function SyncConstructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(580)
  local raidDropdown, raidDropdownText, raidMenu = CreateRaidSelector(frame, 300)
  raidDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

  local inputWrap, inputScroll, editBox = CreateImportEditBox(frame, 100)
  inputWrap:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -40)
  inputWrap:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -40)
  local importButton = CreateButton(frame, MerfinPlus:T("Import"), 120)
  importButton:SetPoint("TOPLEFT", inputWrap, "BOTTOMLEFT", 0, -8)

  local removeSavedImportButton = CreateButton(frame, MerfinPlus:T("Remove"), 90)
  removeSavedImportButton.danger = true
  removeSavedImportButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -188)
  SetButtonStyle(removeSavedImportButton, false, false, false)
  local savedImportDropdown = CreateButton(frame, MerfinPlus:T("Saved Imports"), 300)
  savedImportDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -188)
  savedImportDropdown:SetPoint("RIGHT", removeSavedImportButton, "LEFT", -8, 0)
  savedImportDropdown.label:ClearAllPoints()
  savedImportDropdown.label:SetPoint("LEFT", savedImportDropdown, "LEFT", 9, 0)
  savedImportDropdown.label:SetPoint("RIGHT", savedImportDropdown, "RIGHT", -9, 0)
  savedImportDropdown.label:SetJustifyH("LEFT")
  local savedImportMenu = CreateFrame("Frame", nil, UIParent, template)
  savedImportMenu:SetFrameStrata("TOOLTIP")
  savedImportMenu:SetFrameLevel(100)
  savedImportMenu:SetClampedToScreen(true)
  savedImportMenu:SetWidth(620)
  savedImportMenu:EnableMouse(true)
  savedImportMenu:SetAlpha(1)
  SetBackdrop(savedImportMenu, colors.menu, colors.border)
  savedImportMenu:Hide()

  local syncFullButton = CreateButton(frame, MerfinPlus:T("Sync Full Assignments"), 230)
  syncFullButton:SetPoint("TOPLEFT", savedImportDropdown, "BOTTOMLEFT", 0, -10)
  local status = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(status, 12)
  status:SetPoint("LEFT", syncFullButton, "RIGHT", 10, 0)
  status:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
  status:SetJustifyH("LEFT")

  local recipientPanel = CreateFrame("Frame", nil, frame, template)
  recipientPanel:SetPoint("TOPLEFT", syncFullButton, "BOTTOMLEFT", 0, -10)
  recipientPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  SetBackdrop(recipientPanel, colors.panel, colors.borderSoft)
  local recipientScroll = CreateFrame("ScrollFrame", nil, recipientPanel)
  recipientScroll:SetPoint("TOPLEFT", recipientPanel, "TOPLEFT", 8, -8)
  recipientScroll:SetPoint("BOTTOMRIGHT", recipientPanel, "BOTTOMRIGHT", -8, 8)
  recipientScroll:EnableMouseWheel(true)
  local recipientChild = CreateFrame("Frame", nil, recipientScroll)
  recipientChild:SetSize(860, 1)
  recipientScroll:SetScrollChild(recipientChild)
  local recipientEmpty = recipientPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(recipientEmpty, 13)
  recipientEmpty:SetPoint("CENTER", recipientPanel, "CENTER", 0, 0)
  recipientEmpty:SetText(MerfinPlus:T("Start a full assignment sync to see delivery status for every group member."))
  recipientEmpty:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

  local self = {
    type = SYNC_WIDGET_TYPE, frame = frame,
    raidDropdown = raidDropdown, raidDropdownText = raidDropdownText, raidMenu = raidMenu, raidOptions = {},
    inputWrap = inputWrap, inputScroll = inputScroll, editBox = editBox, importButton = importButton,
    savedImportDropdown = savedImportDropdown, savedImportText = savedImportDropdown.label,
    savedImportMenu = savedImportMenu, savedImportOptions = {}, removeSavedImportButton = removeSavedImportButton,
    syncFullButton = syncFullButton, status = status,
    recipientPanel = recipientPanel, recipientScroll = recipientScroll, recipientChild = recipientChild,
    recipientEmpty = recipientEmpty, recipientRows = {},
  }
  frame.obj = self
  for name, method in pairs(syncMethods) do self[name] = method end
  PopulateRaidSelector(self)

  importButton:SetScript("OnClick", function()
    if self.disabled then return end
    local imported = ImportInput(self, editBox:GetText() or "")
    if imported then
      editBox:SetText("")
      editBox:ClearFocus()
      MerfinPlus:NotifyRaidAssignmentsChanged()
    else
      self:UpdateStatus()
    end
  end)
  savedImportDropdown:SetScript("OnClick", function() if not self.disabled then OpenSavedImportMenu(self) end end)
  removeSavedImportButton:SetScript("OnClick", function()
    local importID = MerfinPlus:GetRaidAssignmentUIState().selectedSavedRaidImportID
    if importID then
      local removed, removeError = MerfinPlus:RemoveSavedRaidAssignmentImport(importID)
      if not removed then
        local state = MerfinPlus:GetRaidAssignmentUIState()
        state.status = MerfinPlus:T(removeError or "Saved Raid Assignments import is unavailable.")
        state.statusTone = "red"
        MerfinPlus:NotifyRaidAssignmentStatusChanged()
      end
    end
  end)
  syncFullButton:SetScript("OnClick", function()
    if self.disabled then return end
    local state = MerfinPlus:GetRaidAssignmentUIState()
    local sent, reason = MerfinPlus:BroadcastFullRaidAssignments(state.selectedGroup, true)
    if not sent then
      state.status = MerfinPlus:T(reason or "Full Raid Assignments sync is unavailable.")
      state.statusTone = "red"
      self:UpdateStatus(state)
    end
  end)
  recipientScroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 36)
    scrollFrame:SetVerticalScroll(math.max(0, math.min(scrollFrame:GetVerticalScrollRange(), nextValue)))
  end)
  recipientScroll:SetScript("OnSizeChanged", function(_, width) recipientChild:SetWidth(math.max(1, width)) end)
  frame:SetScript("OnHide", function() CloseRaidMenu(self); CloseSavedImportMenu(self) end)
  return AceGUI:RegisterAsWidget(self)
end

local function CloseBossMenu(self)
  self.bossMenu:Hide()
  self.bossMenuOpen = nil
end

local function AcquireBossMenuOption(self, index)
  local option = self.bossOptions[index]
  if option then return option end
  option = CreateButton(self.bossMenu, "", self.bossMenu:GetWidth() - 8)
  option:SetHeight(31)
  option.icon = option:CreateTexture(nil, "ARTWORK")
  option.icon:SetSize(44, 22)
  option.icon:SetPoint("LEFT", option, "LEFT", 7, 0)
  option.label:ClearAllPoints()
  option.label:SetPoint("LEFT", option.icon, "RIGHT", 7, 0)
  option.label:SetPoint("RIGHT", option, "RIGHT", -7, 0)
  option.label:SetJustifyH("LEFT")
  option:SetScript("OnClick", function(row)
    CloseBossMenu(self)
    local state = MerfinPlus:GetRaidAssignmentUIState()
    local selected, selectError = MerfinPlus:SelectRaidAssignmentNavigationEntry(state.selectedGroup, row.navigationKey, row.navigationItem, true)
    if not selected then
      state.status = MerfinPlus:T(selectError or "Raid Assignments entry is unavailable.")
      state.statusTone = "red"
      return
    end
    if self.detailScroll then self.detailScroll:SetVerticalScroll(0) end
    self:Refresh()
  end)
  self.bossOptions[index] = option
  return option
end

local function RefreshBossDropdown(self, navigation)
  local state = MerfinPlus:GetRaidAssignmentUIState()
  local optionIndex, selectedItem = 0
  for _, item in ipairs(navigation or {}) do
    if item.kind ~= "heading" and item.kind ~= "additional" then
      optionIndex = optionIndex + 1
      local option = AcquireBossMenuOption(self, optionIndex)
      option.navigationKey = item.key
      option.navigationItem = item
      option.label:SetText(MerfinPlus:T(item.title or "Raid Assignments"))
      SetIconTexture(option.icon, item.boss and item.boss.icon, true)
      option.active = state.selectedBossKey == item.key
      SetButtonStyle(option, false, false, option.active)
      option:ClearAllPoints()
      option:SetPoint("TOPLEFT", self.bossMenu, "TOPLEFT", 4, -4 - ((optionIndex - 1) * 34))
      option:SetPoint("TOPRIGHT", self.bossMenu, "TOPRIGHT", -4, -4 - ((optionIndex - 1) * 34))
      option:Show()
      if option.active then selectedItem = item end
    end
  end
  for index = optionIndex + 1, #self.bossOptions do self.bossOptions[index]:Hide() end
  self.bossMenu:SetHeight(math.max(39, 8 + (optionIndex * 34)))
  if selectedItem then
    self.bossDropdownText:SetText(MerfinPlus:T(selectedItem.title or "Select Boss"))
    SetIconTexture(self.bossDropdownIcon, selectedItem.boss and selectedItem.boss.icon, true)
  else
    self.bossDropdownText:SetText(MerfinPlus:T("Select Boss"))
    self.bossDropdownIcon:Hide()
  end
  SetButtonEnabled(self.bossDropdown, not self.disabled and optionIndex > 0)
end

local function ConfigureStaticSectionRow(row, section, indent, isBuffClassSection)
  ResetDetailRow(row)
  local label, icon = MerfinPlus:GetRaidAssignmentSectionDisplay(
    section.displayName or section.name,
    section.kind,
    GetSectionAssignmentRole(section)
  )
  icon = icon or GetClassAssignmentSectionIcon(section) or GetSpecialAssignmentSectionIcon(section)
  local icons = icon and { icon } or GetBuffAssignmentSectionIcons(section, isBuffClassSection)
  SetBackdrop(row, colors.heading, colors.borderSoft)
  ApplySectionHeaderIcons(row, icons, indent or 0)
  row.section:SetText(tostring(label or section.name))
  row.section:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
  row.section:Show()
  row:EnableMouse(false)
end

local function IsTankPositionSection(section)
  local key = NormalizeKey(section and (section.displayName or section.name))
  return (section and section.kind == "position" and GetSectionAssignmentRole(section) == "tank")
    or (key:find("tank", 1, true) and key:find("position", 1, true))
end

local function IsHealPositionSection(section)
  local key = NormalizeKey(section and (section.displayName or section.name))
  return (section and section.kind == "position" and GetSectionAssignmentRole(section) == "heal")
    or ((key:find("heal", 1, true) or key:find("healer", 1, true)) and key:find("position", 1, true))
end

local function PositionSectionsSharePhase(left, right)
  local leftPhase = NormalizeKey(left and left.context and left.context.phase)
  local rightPhase = NormalizeKey(right and right.context and right.context.phase)
  return leftPhase == "" or rightPhase == "" or leftPhase == rightPhase
end

local function RefreshFlatAssignmentDetail(self, navigation)
  local state = MerfinPlus:GetRaidAssignmentUIState()
  local catalogBoss, catalogRaid, navigationBoss, navigationItem = GetCatalogBoss(self, navigation)
  local entry = state.selectedGroup and MerfinPlus:GetRaidAssignmentImportForGroup(state.selectedGroup)
  local importedBoss = navigationBoss or (catalogBoss and entry and entry.parsed and MerfinPlus:GetRaidAssignmentBoss(entry.parsed, catalogBoss))
  if not catalogBoss then
    self.detailHeaderIcon:Hide()
    self.detailTitle:SetText(MerfinPlus:T("Select a boss"))
    self.detailSubtitle:SetText("")
    self.detailEmpty:SetText(MerfinPlus:T("Choose a boss from the dropdown."))
    self.detailEmpty:Show()
    self.broadcastButton:Hide()
    self.showBossPlanButton:Show()
    self.showBossPlanButton.hasPlan = false
    SetButtonEnabled(self.showBossPlanButton, false)
  else
    local isTrash = navigationItem and navigationItem.kind == "trash"
      or importedBoss and importedBoss.isTrash == true
      or catalogBoss.isTrash == true
    local supportsBossPlan = navigationItem and navigationItem.kind == "boss" and not isTrash
    local hasHeaderIcon = SetIconTexture(self.detailHeaderIcon, catalogBoss.icon, true)
    self.detailHeaderIcon:SetShown(hasHeaderIcon == true)
    self.detailTitle:SetText(catalogBoss.localeID and MerfinPlus:GetLocalizedBossName(catalogBoss.localeID, catalogBoss.name) or MerfinPlus:T(catalogBoss.name or "Trash"))
    self.detailSubtitle:SetText(catalogRaid and MerfinPlus:GetLocalizedRaidName(catalogRaid.localeID, catalogRaid.name) or "")
    self.broadcastButton.label:SetText(MerfinPlus:T(isTrash and "Send Trash Assignments" or "Send Boss Assignments"))
    self.showBossPlanButton.hasPlan = supportsBossPlan
      and MerfinPlus:HasRaidAssignmentBossPlan(state.selectedGroup, state.selectedBossKey)
      or false
    self.showBossPlanButton:SetShown(supportsBossPlan == true)
    SetButtonEnabled(self.showBossPlanButton, supportsBossPlan and not self.disabled and self.showBossPlanButton.hasPlan)
    self.broadcastButton:ClearAllPoints()
    if supportsBossPlan then
      self.broadcastButton:SetPoint("RIGHT", self.showBossPlanButton, "LEFT", -8, 0)
    else
      self.broadcastButton:SetPoint("TOPRIGHT", self.detailPanel, "TOPRIGHT", -12, -12)
    end
    self.detailEmpty:SetShown(importedBoss == nil)
    if importedBoss then
      self.detailEmpty:SetText("")
      self.broadcastButton:SetShown(not (navigationItem and navigationItem.kind == "additional"))
    else
      self.detailEmpty:SetText(MerfinPlus:T("No imported assignments exist for this boss."))
      self.broadcastButton:Hide()
    end
  end

  local rowIndex, top = 0, 0
  local childWidth = GetDetailContentWidth(self)
  self.detailChild:SetWidth(childWidth)
  local playerMap = importedBoss and MerfinPlus:BuildRaidAssignmentPlayerMap(importedBoss) or nil
  local sections = importedBoss and MerfinPlus:GetRaidAssignmentDetailSections(importedBoss) or {}
  local function AnchorRow(row, x, width, y, height)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", self.detailChild, "TOPLEFT", x, -y)
    row:SetSize(width, height)
    row:Show()
  end
  local function NextRow()
    rowIndex = rowIndex + 1
    return AcquireDetailRow(self, rowIndex)
  end
  local function RenderSection(section, x, width, startTop)
    local y = startTop
    local header = NextRow()
    ConfigureStaticSectionRow(header, section)
    AnchorRow(header, x, width, y, 30)
    y = y + 32
    local nestedSections = section.isBuffGroup and section.rows or { section }
    for _, nestedSection in ipairs(nestedSections) do
      if section.isBuffGroup then
        local classHeader = NextRow()
        ConfigureStaticSectionRow(classHeader, nestedSection, 12, true)
        AnchorRow(classHeader, x, width, y, 28)
        y = y + 30
      end
      for _, rowData in ipairs(nestedSection.rows or {}) do
        local row = NextRow()
        local task = rowData.task or rowData
        row.layoutWidthOverride = width
        local rowHeight = ConfigureTaskRow(row, task, playerMap, rowData.sectionName or nestedSection.name, nestedSection.kind)
        if row.SetBackdrop then row:SetBackdrop(nil) end
        ConfigureSelfAssignmentHighlight(row, task)
        rowHeight = rowHeight == MULTI_TARGET_TASK_ROW_HEIGHT and MULTI_TARGET_TASK_ROW_HEIGHT or 36
        AnchorRow(row, x, width, y, rowHeight)
        y = y + rowHeight + 2
      end
    end
    return y - startTop
  end

  local consumed = {}
  for index, section in ipairs(sections) do
    if not consumed[index] and #(section.rows or {}) > 0 then
      local pairIndex
      if IsTankPositionSection(section) or IsHealPositionSection(section) then
        for candidateIndex = index + 1, #sections do
          local candidate = sections[candidateIndex]
          if not consumed[candidateIndex] and #(candidate.rows or {}) > 0
            and ((IsTankPositionSection(section) and IsHealPositionSection(candidate))
              or (IsHealPositionSection(section) and IsTankPositionSection(candidate)))
            and PositionSectionsSharePhase(section, candidate)
          then
            pairIndex = candidateIndex
            break
          end
        end
      end
      if pairIndex then
        consumed[pairIndex] = true
        if childWidth < POSITION_COLUMNS_MIN_WIDTH then
          local firstHeight = RenderSection(section, 0, childWidth, top)
          local secondTop = top + firstHeight + 6
          local secondHeight = RenderSection(sections[pairIndex], 0, childWidth, secondTop)
          top = secondTop + secondHeight + 6
        else
          local availableWidth = childWidth - POSITION_COLUMN_GAP
          local tankWidth = math.floor(availableWidth * POSITION_COLUMN_TANK_RATIO)
          local healWidth = availableWidth - tankWidth
          local leftWidth = IsTankPositionSection(section) and tankWidth or healWidth
          local rightWidth = availableWidth - leftWidth
          local leftHeight = RenderSection(section, 0, leftWidth, top)
          local rightHeight = RenderSection(sections[pairIndex], leftWidth + POSITION_COLUMN_GAP, rightWidth, top)
          top = top + math.max(leftHeight, rightHeight) + 6
        end
      else
        top = top + RenderSection(section, 0, childWidth, top) + 6
      end
    end
  end
  for index = rowIndex + 1, #self.detailRows do
    StopSelfAssignmentHighlight(self.detailRows[index])
    self.detailRows[index]:Hide()
  end
  UpdateDetailScrollGeometry(self, top)
  local canTransfer = MerfinPlus:CanCanonicalRaidAssignmentAction()
  if self.broadcastButton:IsShown() then SetButtonEnabled(self.broadcastButton, not self.disabled and canTransfer and importedBoss ~= nil) end
end

local detailsMethods = {
  OnAcquire = function(self)
    self:SetWidth(900)
    self:SetHeight(580)
    MerfinPlus:RegisterRaidAssignmentsWidget(self)
    self:Refresh()
  end,
  OnRelease = function(self)
    MerfinPlus:UnregisterRaidAssignmentsWidget(self)
    CloseRaidMenu(self)
    CloseBossMenu(self)
    for _, row in ipairs(self.detailRows) do StopSelfAssignmentHighlight(row) end
  end,
  SetText = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled == true
    self:Refresh()
  end,
  UpdateStatus = function() end,
  UpdateTransportProgress = function() end,
  Refresh = function(self)
    local state = MerfinPlus:GetRaidAssignmentUIState()
    local group = MerfinPlus:GetRaidAssignmentGroup(state.selectedGroup)
    local entry = group and MerfinPlus:GetRaidAssignmentImportForGroup(group.id)
    local navigation = MerfinPlus:BuildRaidAssignmentNavigation(entry and entry.parsed, group)
    self.navigation = navigation
    self.raidDropdownText:SetText(group and MerfinPlus:GetLocalizedRaidName(group.id, group.name) or MerfinPlus:T("Select Raid"))
    RefreshBossDropdown(self, navigation)
    RefreshFlatAssignmentDetail(self, navigation)
    if self.raidMenu:IsShown() then RefreshRaidMenu(self) end
    if self.bossMenu:IsShown() then RefreshBossDropdown(self, navigation) end
  end,
}

local function DetailsConstructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(580)
  local raidDropdown, raidDropdownText, raidMenu = CreateRaidSelector(frame, 300)
  raidDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  local bossDropdown = CreateFrame("Button", nil, frame, template)
  bossDropdown:SetPoint("TOPLEFT", raidDropdown, "TOPRIGHT", 8, 0)
  bossDropdown:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
  bossDropdown:SetHeight(30)
  bossDropdown:RegisterForClicks("AnyUp")
  SetBackdrop(bossDropdown, colors.field, colors.border)
  local bossDropdownIcon = bossDropdown:CreateTexture(nil, "ARTWORK")
  bossDropdownIcon:SetSize(44, 22)
  bossDropdownIcon:SetPoint("LEFT", bossDropdown, "LEFT", 7, 0)
  local bossDropdownText = bossDropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(bossDropdownText, 14)
  bossDropdownText:SetPoint("LEFT", bossDropdownIcon, "RIGHT", 7, 0)
  bossDropdownText:SetPoint("RIGHT", bossDropdown, "RIGHT", -26, 0)
  bossDropdownText:SetJustifyH("LEFT")
  bossDropdown.label = bossDropdownText
  local bossArrow = bossDropdown:CreateTexture(nil, "OVERLAY")
  bossArrow:SetTexture(DROPDOWN_ARROW_TEXTURE)
  bossArrow:SetSize(16, 16)
  bossArrow:SetPoint("RIGHT", bossDropdown, "RIGHT", -7, 0)
  bossArrow:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  if bossArrow.SetRotation then bossArrow:SetRotation(math.pi) else bossArrow:SetTexCoord(1, 0, 1, 0) end
  local bossMenu = CreateFrame("Frame", nil, UIParent, template)
  bossMenu:SetFrameStrata("TOOLTIP")
  bossMenu:SetClampedToScreen(true)
  bossMenu:SetWidth(430)
  SetBackdrop(bossMenu, colors.menu, colors.border)
  bossMenu:Hide()

  local detailPanel = CreateFrame("Frame", nil, frame, template)
  detailPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -40)
  detailPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  SetBackdrop(detailPanel, colors.panel, colors.borderSoft)
  local detailHeaderIcon = detailPanel:CreateTexture(nil, "ARTWORK")
  detailHeaderIcon:SetSize(80, 40)
  detailHeaderIcon:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 12, -12)
  local detailTitle = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  ApplyWidgetFont(detailTitle, 18)
  detailTitle:SetPoint("TOPLEFT", detailHeaderIcon, "TOPRIGHT", 10, -1)
  detailTitle:SetJustifyH("LEFT")
  detailTitle:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  local detailSubtitle = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ApplyWidgetFont(detailSubtitle, 13)
  detailSubtitle:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -4)
  detailSubtitle:SetJustifyH("LEFT")
  detailSubtitle:SetTextColor(colors.cyan[1], colors.cyan[2], colors.cyan[3], 1)
  local showBossPlanButton = CreateButton(detailPanel, MerfinPlus:T("Show Boss Plan"), 150)
  showBossPlanButton:SetPoint("TOPRIGHT", detailPanel, "TOPRIGHT", -12, -12)
  showBossPlanButton.keepMouseWhenDisabled = true
  local broadcastButton = CreateButton(detailPanel, MerfinPlus:T("Send Boss Assignments"), 180)
  broadcastButton:SetPoint("RIGHT", showBossPlanButton, "LEFT", -8, 0)
  detailTitle:SetPoint("RIGHT", broadcastButton, "LEFT", -12, 0)
  detailSubtitle:SetPoint("RIGHT", broadcastButton, "LEFT", -12, 0)

  local detailScroll = CreateFrame("ScrollFrame", nil, detailPanel)
  detailScroll:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 10, -62)
  detailScroll:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", -10, 10)
  detailScroll:EnableMouseWheel(true)
  local detailChild = CreateFrame("Frame", nil, detailScroll)
  detailChild:SetSize(860, 1)
  detailScroll:SetScrollChild(detailChild)
  local detailEmpty = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  ApplyWidgetFont(detailEmpty, 14)
  detailEmpty:SetPoint("CENTER", detailScroll, "CENTER", 0, 0)
  detailEmpty:SetWidth(420)
  detailEmpty:SetJustifyH("CENTER")
  detailEmpty:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

  local self = {
    type = DETAILS_WIDGET_TYPE, frame = frame,
    raidDropdown = raidDropdown, raidDropdownText = raidDropdownText, raidMenu = raidMenu, raidOptions = {},
    bossDropdown = bossDropdown, bossDropdownText = bossDropdownText, bossDropdownIcon = bossDropdownIcon,
    bossMenu = bossMenu, bossOptions = {},
    detailPanel = detailPanel, detailHeaderIcon = detailHeaderIcon, detailTitle = detailTitle,
    detailSubtitle = detailSubtitle, broadcastButton = broadcastButton, showBossPlanButton = showBossPlanButton,
    detailScroll = detailScroll, detailChild = detailChild, detailEmpty = detailEmpty, detailRows = {},
  }
  frame.obj = self
  for name, method in pairs(detailsMethods) do self[name] = method end
  PopulateRaidSelector(self)
  bossDropdown:SetScript("OnClick", function()
    if bossDropdown.disabled then return end
    if self.bossMenuOpen then CloseBossMenu(self) return end
    self.bossMenuOpen = true
    bossMenu:ClearAllPoints()
    bossMenu:SetPoint("TOPLEFT", bossDropdown, "BOTTOMLEFT", 0, -2)
    RefreshBossDropdown(self, self.navigation)
    bossMenu:Show()
  end)
  bossDropdown:SetScript("OnEnter", function(button) if not button.disabled then SetBackdrop(button, colors.hover, colors.border) end end)
  bossDropdown:SetScript("OnLeave", function(button) SetBackdrop(button, colors.field, colors.border) end)
  showBossPlanButton:SetScript("OnClick", function()
    local state = MerfinPlus:GetRaidAssignmentUIState()
    if showBossPlanButton.disabled then return end
    local shown, reason = MerfinPlus:ShowCurrentRaidAssignmentBossPlan(state.selectedGroup, state.selectedBossKey)
    if not shown then
      state.status = MerfinPlus:T(reason or "Boss Plan is unavailable.")
      state.statusTone = "red"
      MerfinPlus:NotifyRaidAssignmentStatusChanged()
    end
  end)
  broadcastButton:SetScript("OnClick", function()
    if self.disabled or broadcastButton.disabled then return end
    local boss = GetCatalogBoss(self, self.navigation)
    if boss then MerfinPlus:BroadcastPersonalRaidAssignments(boss, true) end
  end)
  detailScroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
    local nextValue = scrollFrame:GetVerticalScroll() - (delta * 38)
    scrollFrame:SetVerticalScroll(math.max(0, math.min(scrollFrame:GetVerticalScrollRange(), nextValue)))
  end)
  detailScroll:SetScript("OnSizeChanged", function(_, width)
    local layoutWidth = math.max(520, math.floor(math.max(1, width or 1) + 0.5))
    detailChild:SetWidth(layoutWidth)
    if self.detailLayoutWidth ~= layoutWidth then
      self.detailLayoutWidth = layoutWidth
      RefreshFlatAssignmentDetail(self, self.navigation)
    end
  end)
  frame:SetScript("OnSizeChanged", function(_, width)
    local layoutWidth = math.max(520, math.floor(math.max(1, (width or 1) - 20) + 0.5))
    detailChild:SetWidth(layoutWidth)
    if self.detailLayoutWidth ~= layoutWidth then
      self.detailLayoutWidth = layoutWidth
      RefreshFlatAssignmentDetail(self, self.navigation)
    end
  end)
  frame:SetScript("OnHide", function() CloseRaidMenu(self); CloseBossMenu(self) end)
  return AceGUI:RegisterAsWidget(self)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)
AceGUI:RegisterWidgetType(SYNC_WIDGET_TYPE, SyncConstructor, SUBTAB_WIDGET_VERSION)
AceGUI:RegisterWidgetType(DETAILS_WIDGET_TYPE, DetailsConstructor, SUBTAB_WIDGET_VERSION)
