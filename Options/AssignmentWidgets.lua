-- Read-only Assignment and Raid Leader widget shells, adapted from the local
-- MerfinUI Guild Manager settings/runtime conventions.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
local LSM = LibStub("LibSharedMedia-3.0", true)

local template = BackdropTemplateMixin and "BackdropTemplate" or nil
local LOGO = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\merfinplus_widget_logo"
local WHITE = "Interface\\Buttons\\WHITE8X8"
local FONT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local DEFAULT_HEADER_FONT_NAME = "SFUIDisplayCondensed-Semibold"
local DEFAULT_WIDGET_HEIGHT = 25
local DEFAULT_WIDGET_FONT_SIZE = 14
local MIN_WIDGET_WIDTH = 240

local backdrop = {
  bgFile = WHITE,
  tile = false,
  edgeSize = 0,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

local colors = {
  text = theme.text,
  muted = theme.muted,
  heading = theme.selected,
  row = theme.surface,
  gold = theme.accentBright,
  border = theme.border,
}

local function Clamp(value, minimum, maximum)
  value = tonumber(value) or minimum
  return math.max(minimum, math.min(maximum, value))
end

local function NormalizeName(value)
  return tostring(value or ""):lower():gsub("[%s%p%c]+", "")
end

local function SetBackdrop(frame, r, g, b, a)
  if frame and frame.SetBackdrop then
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(r or 0, g or 0, b or 0, a or 0)
  end
end

local function SetTexture(texture, value)
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

local function ResolveHeaderFont(fontName)
  if LSM and LSM.Fetch and type(fontName) == "string" and fontName ~= "" then
    local path = LSM:Fetch("font", fontName, true)
    if type(path) == "string" and path ~= "" then
      return path, fontName
    end
  end
  if LSM and LSM.Fetch then
    local defaultPath = LSM:Fetch("font", DEFAULT_HEADER_FONT_NAME, true)
    if type(defaultPath) == "string" and defaultPath ~= "" then
      return defaultPath, DEFAULT_HEADER_FONT_NAME
    end
  end
  return FONT, DEFAULT_HEADER_FONT_NAME
end

local function SetFont(fontObject, size, fontPath)
  if not fontObject or type(fontObject.SetFont) ~= "function" then
    return
  end
  size = Clamp(size, 8, 30)
  fontPath = type(fontPath) == "string" and fontPath ~= "" and fontPath or FONT
  MerfinPlus:ApplyLocalizedFont(fontObject, fontPath, size)
end

local function ScaleWidgetPixel(value, scale)
  return math.max(1, math.floor((tonumber(value) or 0) * (tonumber(scale) or 1) + 0.5))
end

local function GetPersistedWidgetFontSize(settings, prefix)
  local fontSizeKey = prefix .. "FontSize"
  if rawget(settings, fontSizeKey) == nil then
    -- Older saved data exposed only Header Title Size. Preserve an explicitly
    -- stored value by promoting it once to the new all-text font-size setting.
    local legacyTitleSize = rawget(settings, prefix .. "TitleSize")
    if legacyTitleSize ~= nil then
      settings[fontSizeKey] = Clamp(legacyTitleSize, 8, 24)
    end
  end
  return Clamp(settings[fontSizeKey] or settings[prefix .. "TitleSize"] or DEFAULT_WIDGET_FONT_SIZE, 8, 24)
end

function MerfinPlus:ConfigureAssignmentImportEditBox(editBox)
  if not editBox or editBox.merfinPlusCaretConfigured then
    return
  end
  editBox.merfinPlusCaretConfigured = true
  editBox:EnableKeyboard(true)
  editBox:EnableMouse(true)
  if editBox.SetBlinkSpeed then
    editBox:SetBlinkSpeed(0.45)
  end

  local caret = editBox:CreateTexture(nil, "OVERLAY", nil, 7)
  caret:SetTexture(WHITE)
  caret:SetVertexColor(colors.gold[1], colors.gold[2], colors.gold[3], 1)
  caret:SetSize(2, 14)
  caret:SetPoint("TOPLEFT", editBox, "TOPLEFT", 1, -1)
  caret:Hide()

  local blink = caret:CreateAnimationGroup()
  blink:SetLooping("REPEAT")
  local fadeOut = blink:CreateAnimation("Alpha")
  fadeOut:SetOrder(1)
  fadeOut:SetFromAlpha(1)
  fadeOut:SetToAlpha(0.12)
  fadeOut:SetDuration(0.38)
  local fadeIn = blink:CreateAnimation("Alpha")
  fadeIn:SetOrder(2)
  fadeIn:SetFromAlpha(0.12)
  fadeIn:SetToAlpha(1)
  fadeIn:SetDuration(0.38)

  editBox.merfinPlusCaret = caret
  editBox.merfinPlusCaretBlink = blink

  local function ShowCaret(box)
    caret:SetAlpha(1)
    caret:Show()
    if not blink:IsPlaying() then
      blink:Play()
    end
  end

  local function HideCaret()
    if blink:IsPlaying() then
      blink:Stop()
    end
    caret:SetAlpha(1)
    caret:Hide()
  end

  editBox:HookScript("OnCursorChanged", function(box, x, y, _, cursorHeight)
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    cursorHeight = tonumber(cursorHeight)
    if not cursorHeight or cursorHeight <= 0 then
      cursorHeight = 14
    end
    caret:ClearAllPoints()
    caret:SetPoint(
      "TOPLEFT",
      box,
      "TOPLEFT",
      math.floor(x + 0.5) + 1,
      math.floor(y + 0.5)
    )
    caret:SetHeight(math.max(10, cursorHeight))
    if box:HasFocus() then
      ShowCaret(box)
    end
  end)

  editBox:HookScript("OnEditFocusGained", function(box)
    if box.SetBlinkSpeed then
      box:SetBlinkSpeed(0.45)
    end
    local text = box:GetText() or ""
    local cursor = tonumber(box:GetCursorPosition())
    if not cursor or cursor < 0 or cursor > #text then
      cursor = #text
    end
    box:SetCursorPosition(cursor)
    ShowCaret(box)
  end)
  editBox:HookScript("OnEditFocusLost", HideCaret)
end

local function VerticalTitle(text)
  local characters = {}
  for _, character in ipairs(MerfinPlus:UTF8Characters(text)) do
    characters[#characters + 1] = character == " " and "" or character
  end
  return table.concat(characters, "\n")
end

local function HideTitleGlyphs(frame)
  for _, glyph in ipairs(frame.titleGlyphs or {}) do
    glyph:Hide()
  end
end

local function AcquireTitleGlyph(frame, index)
  frame.titleGlyphs = frame.titleGlyphs or {}
  local glyph = frame.titleGlyphs[index]
  if glyph then
    return glyph
  end
  glyph = frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  glyph:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  glyph:SetJustifyH("CENTER")
  if glyph.SetJustifyV then
    glyph:SetJustifyV("MIDDLE")
  end
  frame.titleGlyphs[index] = glyph
  return glyph
end

local function ApplyTitleLetterSpacing(frame, settings, sideAligned, logoSpace)
  local spacing = Clamp(settings.titleSpacing, 0, 20)
  local titleText = tostring(frame.title.baseText or "")
  if spacing <= 0 or titleText == "" then
    HideTitleGlyphs(frame)
    frame.title:Show()
    return
  end

  -- WoW FontStrings expose line spacing, but no letter-spacing API. Render the
  -- short header title as individual glyph FontStrings so the slider changes
  -- only the gap between letters, never the title anchor or line spacing.
  frame.title:Hide()
  local glyphs, metrics = {}, {}
  for _, character in ipairs(MerfinPlus:UTF8Characters(titleText)) do
    local glyph = AcquireTitleGlyph(frame, #glyphs + 1)
    glyph:ClearAllPoints()
    SetFont(glyph, settings.fontSize, settings.font)
    glyph:SetText(character)
    glyph:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
    glyphs[#glyphs + 1] = glyph
    if sideAligned then
      local height = glyph:GetStringHeight()
      metrics[#metrics + 1] = math.max(1, tonumber(height) or settings.fontSize)
    else
      local width = glyph:GetStringWidth()
      if character == " " then
        width = math.max(tonumber(width) or 0, settings.fontSize * 0.34)
      end
      metrics[#metrics + 1] = math.max(1, tonumber(width) or settings.fontSize)
    end
  end

  if sideAligned then
    local y = -(logoSpace or 8) + settings.titleOffsetY
    for index, glyph in ipairs(glyphs) do
      glyph:SetPoint("TOP", frame.header, "TOP", settings.titleOffsetX, y)
      glyph:Show()
      y = y - metrics[index] - spacing
    end
  else
    local totalWidth = spacing * math.max(0, #glyphs - 1)
    for _, width in ipairs(metrics) do
      totalWidth = totalWidth + width
    end
    local x = settings.titleOffsetX - (totalWidth * 0.5)
    for index, glyph in ipairs(glyphs) do
      local width = metrics[index]
      glyph:SetPoint("CENTER", frame.header, "CENTER", x + (width * 0.5), settings.titleOffsetY)
      glyph:Show()
      x = x + width + spacing
    end
  end

  for index = #glyphs + 1, #(frame.titleGlyphs or {}) do
    frame.titleGlyphs[index]:Hide()
  end
end

local function IsSideAlignment(alignment)
  return alignment == "Left" or alignment == "Right"
end

local function InRaidInstance()
  if not GetInstanceInfo then
    return false
  end
  local _, instanceType = GetInstanceInfo()
  return instanceType == "raid"
end

function MerfinPlus:GetAssignmentSettings()
  return self:GetRaidAssignmentStorage()
end

function MerfinPlus:CanUseRaidLeaderWidget()
  local raidCount = (GetNumRaidMembers and GetNumRaidMembers()) or 0
  local groupCount = (GetNumGroupMembers and GetNumGroupMembers()) or 0
  local partyCount = (GetNumSubgroupMembers and GetNumSubgroupMembers())
    or (GetNumPartyMembers and GetNumPartyMembers())
    or 0
  local inRaid = (IsInRaid and IsInRaid()) or raidCount > 0
  local inGroup = (IsInGroup and IsInGroup()) or inRaid or groupCount > 0 or partyCount > 0
  if not inGroup then
    return false
  end
  local isLeader = (UnitIsGroupLeader and UnitIsGroupLeader("player"))
    or (inRaid and IsRaidLeader and IsRaidLeader())
    or (not inRaid and IsPartyLeader and IsPartyLeader())
  local isAssistant = inRaid and ((UnitIsGroupAssistant and UnitIsGroupAssistant("player"))
    or (IsRaidOfficer and IsRaidOfficer()))
  return (isLeader or isAssistant) and true or false
end

function MerfinPlus:GetAssignmentWidgetSettings(prefix)
  local settings = self:GetAssignmentSettings()
  prefix = prefix or "assignmentWidget"
  local headerFont, headerFontName = ResolveHeaderFont(settings[prefix .. "HeaderFont"])
  local height = Clamp(settings[prefix .. "HeaderHeight"], 22, 64)
  local widthKey = prefix .. "HeaderWidth"
  local width = Clamp(settings[widthKey], MIN_WIDGET_WIDTH, 520)
  if tonumber(settings[widthKey]) and tonumber(settings[widthKey]) < MIN_WIDGET_WIDTH then
    -- 240px is the smallest width that can retain three left icons plus a
    -- readable wrapped label at the supported 24px font-size maximum.
    settings[widthKey] = width
  end
  return {
    width = width,
    height = height,
    heightScale = height / DEFAULT_WIDGET_HEIGHT,
    alpha = Clamp(settings[prefix .. "HeaderAlpha"], 0, 1),
    bodyAlpha = Clamp(settings[prefix .. "BodyAlpha"], 0, 1),
    r = Clamp(settings[prefix .. "HeaderR"], 0, 1),
    g = Clamp(settings[prefix .. "HeaderG"], 0, 1),
    b = Clamp(settings[prefix .. "HeaderB"], 0, 1),
    titleOffsetX = Clamp(settings[prefix .. "TitleOffsetX"], -200, 200),
    titleOffsetY = Clamp(settings[prefix .. "TitleOffsetY"], -80, 80),
    fontSize = GetPersistedWidgetFontSize(settings, prefix),
    titleSpacing = Clamp(settings[prefix .. "TitleSpacing"], 0, 20),
    font = headerFont,
    fontName = headerFontName,
    -- Retain aliases for callers outside this file while expanding the
    -- existing HeaderFont setting to every text element in the widget.
    headerFont = headerFont,
    headerFontName = headerFontName,
    logoOffsetX = Clamp(settings[prefix .. "LogoOffsetX"], -120, 120),
    logoOffsetY = Clamp(settings[prefix .. "LogoOffsetY"], -80, 80),
    logoSize = Clamp(settings[prefix .. "LogoSize"], 12, 52),
    showLogo = settings[prefix .. "ShowLogo"] ~= false,
    showBorder = settings[prefix .. "ShowBorder"] == true,
    borderR = Clamp(settings[prefix .. "BorderR"], 0, 1),
    borderG = Clamp(settings[prefix .. "BorderG"], 0, 1),
    borderB = Clamp(settings[prefix .. "BorderB"], 0, 1),
    borderThickness = Clamp(settings[prefix .. "BorderThickness"], 1, 6),
  }
end

local function EnsurePixelBorder(header)
  if header.merfinPlusPixelBorder then
    return header.merfinPlusPixelBorder
  end
  local border = {}
  for _, side in ipairs({ "top", "bottom", "left", "right" }) do
    border[side] = header:CreateTexture(nil, "OVERLAY")
    border[side]:SetTexture(WHITE)
  end
  header.merfinPlusPixelBorder = border
  return border
end

local function ApplyPixelBorder(header, settings)
  local border = EnsurePixelBorder(header)
  local size = settings.borderThickness
  border.top:ClearAllPoints()
  border.top:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
  border.top:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, 0)
  border.top:SetHeight(size)
  border.bottom:ClearAllPoints()
  border.bottom:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
  border.bottom:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
  border.bottom:SetHeight(size)
  border.left:ClearAllPoints()
  border.left:SetPoint("TOPLEFT", header, "TOPLEFT", 0, -size)
  border.left:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, size)
  border.left:SetWidth(size)
  border.right:ClearAllPoints()
  border.right:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, -size)
  border.right:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, size)
  border.right:SetWidth(size)
  for _, texture in pairs(border) do
    texture:SetVertexColor(settings.borderR, settings.borderG, settings.borderB, 1)
    if settings.showBorder then
      texture:Show()
    else
      texture:Hide()
    end
  end
end

local function SaveWidgetPosition(prefix)
  local frame = MerfinPlus[prefix]
  local settings = MerfinPlus:GetAssignmentSettings()
  if not frame or not UIParent then
    return
  end
  local centerX, centerY = UIParent:GetCenter()
  settings[prefix .. "X"] = (frame:GetLeft() or centerX or 0) - (centerX or 0)
  settings[prefix .. "Y"] = (frame:GetTop() or centerY or 0) - (centerY or 0)
end

local function PositionWidget(prefix)
  local frame = MerfinPlus[prefix]
  if not frame or not UIParent then
    return
  end
  local settings = MerfinPlus:GetAssignmentSettings()
  local defaultX = prefix == "assignmentWidget" and 260 or -360
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", UIParent, "CENTER", settings[prefix .. "X"] or defaultX, settings[prefix .. "Y"] or -120)
end

function MerfinPlus:ShowAssignmentImportDialog(title, onAccept, acceptLabel)
  local dialog = self.assignmentImportDialog
  if not dialog then
    local dialogTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
    dialog = CreateFrame("Frame", "MerfinPlusAssignmentImportDialog", UIParent, dialogTemplate)
    dialog:SetSize(700, 500)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("FULLSCREEN_DIALOG")
    dialog:SetFrameLevel(1000)
    dialog:SetToplevel(true)
    dialog:SetMovable(true)
    dialog:SetClampedToScreen(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
    dialog:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)
    if dialog.SetBackdrop then
      dialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
      })
      dialog:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.96)
      dialog:SetBackdropBorderColor(unpack(theme.border))
    end
    dialog.title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dialog.title:SetPoint("TOPLEFT", dialog, "TOPLEFT", 18, -18)
    dialog.title:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
    dialog.status = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dialog.status:SetPoint("TOPLEFT", dialog.title, "BOTTOMLEFT", 0, -8)
    dialog.status:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", -18, -8)
    dialog.status:SetJustifyH("LEFT")
    dialog.inputPanel = CreateFrame("Frame", nil, dialog, dialogTemplate)
    dialog.inputPanel:SetPoint("TOPLEFT", dialog, "TOPLEFT", 18, -64)
    dialog.inputPanel:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -18, 56)
    if dialog.inputPanel.SetBackdrop then
      dialog.inputPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
      })
      dialog.inputPanel:SetBackdropColor(unpack(theme.surfaceRaised))
      dialog.inputPanel:SetBackdropBorderColor(unpack(theme.border))
    end
    dialog.inputScroll = CreateFrame("ScrollFrame", nil, dialog.inputPanel)
    dialog.inputScroll:SetPoint("TOPLEFT", dialog.inputPanel, "TOPLEFT", 8, -8)
    dialog.inputScroll:SetPoint("BOTTOMRIGHT", dialog.inputPanel, "BOTTOMRIGHT", -8, 8)
    dialog.inputScroll:EnableMouse(true)
    dialog.inputScroll:EnableMouseWheel(true)
    dialog.editBox = CreateFrame("EditBox", nil, dialog.inputScroll)
    dialog.editBox:SetMultiLine(true)
    dialog.editBox:SetAutoFocus(false)
    dialog.editBox:SetFontObject(_G.ChatFontNormal or _G.GameFontHighlightSmall)
    dialog.editBox:SetTextColor(0.96, 0.96, 0.93, 1)
    dialog.editBox:SetPoint("TOPLEFT", dialog.inputScroll, "TOPLEFT", 4, -4)
    dialog.editBox:SetWidth(1)
    dialog.editBox:SetHeight(1)
    if dialog.editBox.SetMaxLetters then dialog.editBox:SetMaxLetters(0) end
    if dialog.editBox.SetMaxBytes then dialog.editBox:SetMaxBytes(0) end
    self:ConfigureAssignmentImportEditBox(dialog.editBox)
    dialog.inputScroll:SetScrollChild(dialog.editBox)
    dialog.accept = CreateFrame("Button", nil, dialog, dialogTemplate)
    dialog.accept:SetSize(110, 30)
    dialog.accept:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -18, 16)
    dialog.cancel = CreateFrame("Button", nil, dialog, dialogTemplate)
    dialog.cancel:SetSize(90, 30)
    dialog.cancel:SetPoint("RIGHT", dialog.accept, "LEFT", -8, 0)
    for _, button in ipairs({ dialog.accept, dialog.cancel }) do
      if button.SetBackdrop then
        button:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        button:SetBackdropColor(unpack(theme.surfaceRaised))
        button:SetBackdropBorderColor(unpack(theme.border))
      end
      button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      button.label:SetPoint("CENTER")
      button.label:SetTextColor(0.96, 0.96, 0.93, 1)
    end
    dialog.accept.label:SetText(self:T("Import"))
    dialog.cancel.label:SetText(self:T("Cancel"))
    dialog.cancel:SetScript("OnClick", function() dialog:Hide() end)
    dialog.accept:SetScript("OnClick", function()
      local ok, errorText
      if dialog.onAccept then
        ok, errorText = dialog.onAccept(dialog.editBox:GetText() or "")
      end
      if ok then
        dialog:Hide()
      else
        dialog.status:SetText(self:T(errorText or "Import failed."))
        dialog.status:SetTextColor(0.95, 0.22, 0.18, 1)
      end
    end)
    dialog.inputScroll:SetScript("OnMouseWheel", function(scrollFrame, delta)
      local value = scrollFrame:GetVerticalScroll() - (delta * 42)
      scrollFrame:SetVerticalScroll(math.max(0, math.min(scrollFrame:GetVerticalScrollRange(), value)))
    end)
    dialog.editBox:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
    dialog.inputScroll:SetScript("OnSizeChanged", function(_, width, height)
      dialog.editBox:SetWidth(math.max(1, width - 8))
      dialog.editBox:SetHeight(math.max(height, 1))
    end)
    self.assignmentImportDialog = dialog
  end
  dialog.title:SetText(title or self:T("Import"))
  dialog.accept.label:SetText(acceptLabel and self:T(acceptLabel) or self:T("Import"))
  dialog.status:SetText("")
  dialog.onAccept = onAccept
  dialog.editBox:SetText("")
  dialog.editBox:ClearFocus()
  self:RefreshAssignmentWidgetTheme()
  -- The options container also uses FULLSCREEN_DIALOG. Reassert the modal's
  -- level and raise it on every opening so close/reopen cannot leave it behind.
  dialog:SetFrameStrata("FULLSCREEN_DIALOG")
  dialog:SetFrameLevel(1000)
  dialog:Show()
  if dialog.Raise then dialog:Raise() end
  dialog.editBox:SetFocus()
  return dialog
end

function MerfinPlus:RefreshAssignmentWidgetTheme()
  local dialog = self.assignmentImportDialog
  if dialog then
    dialog:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.96)
    dialog:SetBackdropBorderColor(unpack(theme.border))
    dialog.title:SetTextColor(unpack(theme.accentBright))
    dialog.inputPanel:SetBackdropColor(unpack(theme.surfaceRaised))
    dialog.inputPanel:SetBackdropBorderColor(unpack(theme.border))
    for _, button in ipairs({ dialog.accept, dialog.cancel }) do
      button:SetBackdropColor(unpack(theme.surfaceRaised))
      button:SetBackdropBorderColor(unpack(theme.border))
      button.label:SetTextColor(unpack(theme.text))
    end
    self:ApplyUIFontSizeDelta(dialog)
  end
end

local function CreateWidget(prefix, titleKey)
  if MerfinPlus[prefix] or not UIParent then
    return MerfinPlus[prefix]
  end

  local globalName = prefix == "assignmentWidget" and "MerfinPlusAssignmentWidget" or "MerfinPlusRaidLeaderWidget"
  local frame = CreateFrame("Frame", globalName, UIParent, template)
  frame:Hide()
  frame:SetFrameStrata("DIALOG")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  SetBackdrop(frame, 0, 0, 0, 0.04)

  local header = CreateFrame("Button", nil, frame, template)
  header:RegisterForClicks("LeftButtonUp")
  header:RegisterForDrag("LeftButton")
  SetBackdrop(header, 0, 0, 0, 0.92)

  local logo = header:CreateTexture(nil, "ARTWORK")
  logo:SetTexture(LOGO)
  logo:SetTexCoord(0, 1, 0, 1)

  local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title.localeKey = titleKey
  title.baseText = MerfinPlus:T(titleKey)
  title:SetText(title.baseText)
  title:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
  title:SetJustifyH("CENTER")

  local body = CreateFrame("Frame", nil, frame, template)
  body:EnableMouse(true)
  SetBackdrop(body, 0, 0, 0, 0.28)
  body:Hide()

  frame.header = header
  frame.logo = logo
  frame.title = title
  frame.body = body
  frame.rows = {}
  frame.contentDirty = true
  frame.isPinned = MerfinPlus:GetAssignmentSettings()[prefix .. "Pinned"] == true
  MerfinPlus[prefix] = frame

  local function RefreshHover(hovered)
    local isHovered = hovered == true
    if header.isHovered == isHovered then
      return
    end
    header.isHovered = isHovered
    if prefix == "raidLeaderWidget" then
      if header.isHovered or frame.isPinned then
        if frame.contentDirty ~= false then
          MerfinPlus:RefreshRaidLeaderWidget()
        elseif frame.hasRows then
          body:Show()
        else
          body:Hide()
        end
      else
        body:Hide()
      end
      return
    end
    if prefix == "assignmentWidget" then
      MerfinPlus:RefreshAssignmentWidget()
    else
      MerfinPlus:RefreshRaidLeaderWidget()
    end
  end

  local function CheckHover()
    if prefix == "raidLeaderWidget" then
      local overHeader = header.IsMouseOver and header:IsMouseOver()
      local overBody = body.IsMouseOver and body:IsMouseOver()
      local overSubmenu = false
      for index = 1, #frame.rows do
        local button = frame.rows[index].setGroupButton
        if button and button:IsShown() and button:IsMouseOver() then
          overSubmenu = true
          break
        end
      end
      if not overHeader and not overBody and not overSubmenu then
        RefreshHover(false)
      end
      return
    end
    if C_Timer and C_Timer.After then
      C_Timer.After(0.05, function()
        local overHeader = header.IsMouseOver and header:IsMouseOver()
        local overBody = body.IsMouseOver and body:IsMouseOver()
        if not overHeader and not overBody then
          RefreshHover(false)
        end
  end)
end

  end

  header:SetScript("OnDragStart", function()
    frame:StartMoving()
  end)
  header:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    SaveWidgetPosition(prefix)
    if prefix == "raidLeaderWidget"
      and MerfinPlus.PositionRaidLeaderSetGroupButtons
    then
      MerfinPlus:PositionRaidLeaderSetGroupButtons()
    end
  end)
  header:SetScript("OnEnter", function()
    RefreshHover(true)
  end)
  header:SetScript("OnLeave", CheckHover)
  header:SetScript("OnClick", function()
    local settings = MerfinPlus:GetAssignmentSettings()
    settings[prefix .. "Pinned"] = not settings[prefix .. "Pinned"]
    frame.isPinned = settings[prefix .. "Pinned"]
    if prefix == "assignmentWidget" then
      MerfinPlus:RefreshAssignmentWidget()
    elseif frame.isPinned then
      if frame.contentDirty ~= false then
        MerfinPlus:RefreshRaidLeaderWidget()
      elseif frame.hasRows then
        body:Show()
      else
        body:Hide()
      end
    else
      body:Hide()
    end
  end)
  body:SetScript("OnEnter", function()
    RefreshHover(true)
  end)
  body:SetScript("OnLeave", CheckHover)

  PositionWidget(prefix)
  return frame
end

local function ApplyWidgetSettings(prefix)
  local frame = MerfinPlus[prefix]
  if not frame then
    return
  end
  local stored = MerfinPlus:GetAssignmentSettings()
  local settings = MerfinPlus:GetAssignmentWidgetSettings(prefix)
  local alignment = stored[prefix .. "Alignment"] or "Down"
  local sideAligned = IsSideAlignment(alignment)

  frame:SetSize(sideAligned and settings.height or settings.width, sideAligned and settings.width or settings.height)
  frame.header:ClearAllPoints()
  frame.header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  if sideAligned then
    frame.header:SetSize(settings.height, settings.width)
  else
    frame.header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    frame.header:SetHeight(settings.height)
  end
  SetBackdrop(frame.header, settings.r, settings.g, settings.b, settings.alpha)
  ApplyPixelBorder(frame.header, settings)

  frame.logo:ClearAllPoints()
  if sideAligned then
    frame.logo:SetPoint("TOP", frame.header, "TOP", settings.logoOffsetX, -5 + settings.logoOffsetY)
  else
    frame.logo:SetPoint("LEFT", frame.header, "LEFT", 7 + settings.logoOffsetX, settings.logoOffsetY)
  end
  frame.logo:SetSize(settings.logoSize, settings.logoSize)
  if settings.showLogo then frame.logo:Show() else frame.logo:Hide() end

  SetFont(frame.title, settings.fontSize, settings.font)
  if frame.title.SetSpacing then
    -- This API controls line spacing. Letter spacing is handled independently
    -- by ApplyTitleLetterSpacing below.
    frame.title:SetSpacing(0)
  end
  frame.title:ClearAllPoints()
  local logoSpace
  if sideAligned then
    logoSpace = settings.showLogo and (settings.logoSize + 8) or 8
    frame.title:SetPoint("TOP", frame.header, "TOP", settings.titleOffsetX, -logoSpace + settings.titleOffsetY)
    frame.title:SetWidth(math.max(12, settings.height - 4))
    frame.title:SetText(VerticalTitle(frame.title.baseText))
    if frame.title.SetJustifyV then frame.title:SetJustifyV("TOP") end
  else
    frame.title:SetPoint("CENTER", frame.header, "CENTER", settings.titleOffsetX, settings.titleOffsetY)
    frame.title:SetWidth(settings.width - 70)
    frame.title:SetText(frame.title.baseText)
    if frame.title.SetJustifyV then frame.title:SetJustifyV("MIDDLE") end
  end
  ApplyTitleLetterSpacing(frame, settings, sideAligned, logoSpace)

  frame.body:ClearAllPoints()
  if alignment == "Up" then
    frame.body:SetPoint("BOTTOMLEFT", frame.header, "TOPLEFT", 0, 0)
    frame.body:SetPoint("BOTTOMRIGHT", frame.header, "TOPRIGHT", 0, 0)
  elseif alignment == "Left" then
    frame.body:SetPoint("TOPRIGHT", frame.header, "TOPLEFT", 0, 0)
  elseif alignment == "Right" then
    frame.body:SetPoint("TOPLEFT", frame.header, "TOPRIGHT", 0, 0)
  else
    frame.body:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, 0)
    frame.body:SetPoint("TOPRIGHT", frame.header, "BOTTOMRIGHT", 0, 0)
  end
  frame.body:SetWidth(settings.width)
  SetBackdrop(frame.body, 0, 0, 0, settings.bodyAlpha)
end

local function PositionRaidLeaderSetGroupButton(row, alignment)
  local button = row and row.setGroupButton
  if not button then
    return
  end

  local preferLeft = alignment == "Left"
  local rowLeft, rowRight = row:GetLeft(), row:GetRight()
  local screenLeft = UIParent and UIParent:GetLeft()
  local screenRight = UIParent and UIParent:GetRight()
  if rowLeft and rowRight and screenLeft and screenRight then
    local needed = button:GetWidth() or 112
    local leftSpace = rowLeft - screenLeft
    local rightSpace = screenRight - rowRight
    if preferLeft and leftSpace < needed and rightSpace >= needed then
      preferLeft = false
    elseif not preferLeft and rightSpace < needed and leftSpace >= needed then
      preferLeft = true
    elseif leftSpace < needed and rightSpace < needed then
      preferLeft = leftSpace > rightSpace
    end
  end

  button:ClearAllPoints()
  if preferLeft then
    button:SetPoint("RIGHT", row, "LEFT", 0, 0)
  else
    button:SetPoint("LEFT", row, "RIGHT", 0, 0)
  end
end

function MerfinPlus:PositionRaidLeaderSetGroupButtons()
  local frame = self.raidLeaderWidget
  if not frame then
    return
  end
  local stored = self:GetAssignmentSettings()
  local alignment = stored.raidLeaderWidgetAlignment or "Down"
  for index = 1, #frame.rows do
    PositionRaidLeaderSetGroupButton(frame.rows[index], alignment)
  end
end

local function PreferredTextWidth(fontString, fallback)
  local width
  if fontString and fontString.GetUnboundedStringWidth then
    width = fontString:GetUnboundedStringWidth()
  elseif fontString and fontString.GetStringWidth then
    width = fontString:GetStringWidth()
  end
  return math.max(tonumber(fallback) or 1, math.ceil(tonumber(width) or 0))
end

local function WrappedTextHeight(fontString, width, fallback)
  width = math.max(1, math.floor(tonumber(width) or 1))
  fontString:SetWidth(width)
  fontString:SetHeight(10000)
  local height = fontString.GetStringHeight and fontString:GetStringHeight()
  return math.max(tonumber(fallback) or 1, math.ceil(tonumber(height) or 0))
end

local function ComputeAssignmentRowColumns(innerWidth, fontSize, leftChrome, targetChrome,
    leftPreferredText, targetPreferredText, hasTarget)
  innerWidth = math.max(1, tonumber(innerWidth) or 1)
  fontSize = Clamp(fontSize, 8, 24)
  leftChrome, targetChrome = math.max(0, leftChrome or 0), math.max(0, targetChrome or 0)
  local columnGap = math.max(8, math.floor(fontSize * 0.7 + 0.5))
  local minimumLeftText = math.max(56, math.floor(fontSize * 4.2 + 0.5))
  local minimumTargetText = math.max(48, math.floor(fontSize * 3.4 + 0.5))
  local leftIdeal = leftChrome + math.max(minimumLeftText,
    math.min(tonumber(leftPreferredText) or minimumLeftText, innerWidth * 0.56))
  local targetIdeal = targetChrome + math.max(minimumTargetText,
    math.min(tonumber(targetPreferredText) or minimumTargetText, innerWidth * 0.40))
  local wide = hasTarget == true and leftIdeal + columnGap + targetIdeal <= innerWidth
  if wide then
    local targetWidth = math.min(targetIdeal, math.floor(innerWidth * 0.44))
    local leftWidth = innerWidth - columnGap - targetWidth
    if leftWidth >= leftChrome + minimumLeftText and targetWidth >= targetChrome + minimumTargetText then
      return {
        wide = true,
        columnGap = columnGap,
        leftWidth = leftWidth,
        targetWidth = targetWidth,
      }
    end
  end
  return {
    wide = false,
    columnGap = columnGap,
    leftWidth = innerWidth,
    targetWidth = innerWidth,
  }
end
MerfinPlus.ComputeAssignmentWidgetRowColumns = ComputeAssignmentRowColumns
MerfinPlus.AssignmentWidgetResponsiveLayoutContract = {
  minimumWidth = MIN_WIDGET_WIDTH,
  narrowTargetFlow = "below",
  wideTargetFlow = "right",
  rowHeight = "content-driven",
}

local function VisibleTextureCount(textures)
  local count = 0
  for _, texture in ipairs(textures) do
    if texture and texture:IsShown() then count = count + 1 end
  end
  return count
end

local function TextureRunWidth(textures, iconSize, gap)
  local count = VisibleTextureCount(textures)
  return count > 0 and ((count * iconSize) + (count * gap)) or 0
end

local function PositionTextureRun(textures, row, startX, topY, contentHeight, iconSize, gap)
  local x = startX
  for _, texture in ipairs(textures) do
    texture:ClearAllPoints()
    if texture:IsShown() then
      texture:SetSize(iconSize, iconSize)
      texture:SetPoint("TOPLEFT", row, "TOPLEFT", x, -(topY + math.max(0, (contentHeight - iconSize) / 2)))
      x = x + iconSize + gap
    end
  end
  return x
end

local function LayoutAssignmentWidgetRows(frame, settings)
  local bodyMargin = Clamp(ScaleWidgetPixel(6, settings.heightScale), 5, 18)
  local horizontalMargin = Clamp(ScaleWidgetPixel(8, settings.heightScale), 6, 18)
  local rowGap = Clamp(ScaleWidgetPixel(3, settings.heightScale), 2, 10)
  local verticalPadding = Clamp(ScaleWidgetPixel(4, settings.heightScale), 3, 12)
  local iconGap = Clamp(ScaleWidgetPixel(4, settings.heightScale), 3, 10)
  local lineGap = Clamp(ScaleWidgetPixel(3, settings.heightScale), 3, 10)
  local innerWidth = math.max(1, settings.width - (horizontalMargin * 2))
  local maximumIconSize = math.max(18, math.floor(innerWidth / 6))
  local taskIconSize = math.min(ScaleWidgetPixel(20, settings.heightScale), maximumIconSize)
  local targetIconSize = math.min(ScaleWidgetPixel(18, settings.heightScale), maximumIconSize)
  local lineHeight = math.max(10, math.ceil(settings.fontSize * 1.25))
  local bodyY = bodyMargin

  for _, row in ipairs(frame.rows or {}) do
    SetFont(row.label, settings.fontSize, settings.font)
    SetFont(row.target, settings.fontSize, settings.font)
    if row:IsShown() then
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 0, -bodyY)
      row:SetPoint("TOPRIGHT", frame.body, "TOPRIGHT", 0, -bodyY)
      row.label:ClearAllPoints()
      row.target:ClearAllPoints()

      local rowHeight
      if row.merfinPlusHeading then
        local headingTextures = { row.icon }
        local headingChrome = TextureRunWidth(headingTextures, taskIconSize, iconGap)
        local labelWidth = math.max(1, innerWidth - headingChrome)
        local labelHeight = WrappedTextHeight(row.label, labelWidth, lineHeight)
        local contentHeight = math.max(labelHeight, VisibleTextureCount(headingTextures) > 0 and taskIconSize or 0)
        rowHeight = math.max(ScaleWidgetPixel(22, settings.heightScale), contentHeight + (verticalPadding * 2))
        local textX = PositionTextureRun(headingTextures, row, horizontalMargin, verticalPadding,
          contentHeight, taskIconSize, iconGap)
        row.label:SetPoint("TOPLEFT", row, "TOPLEFT", textX, -verticalPadding)
        row.label:SetSize(math.max(1, settings.width - horizontalMargin - textX), contentHeight)
        row.label:SetJustifyV("MIDDLE")
        SetBackdrop(row, colors.heading[1], colors.heading[2], colors.heading[3], settings.bodyAlpha)
      else
        local leftTextures = { row.icon, row.secondaryIcon, row.assignmentMarkerIcon }
        local targetTextures = { row.targetIcon, row.targetSpecIcon }
        local leftChrome = TextureRunWidth(leftTextures, taskIconSize, iconGap)
        local targetChrome = TextureRunWidth(targetTextures, targetIconSize, iconGap)
        local hasTarget = row.merfinPlusTargetVisible == true
        local columns = ComputeAssignmentRowColumns(
          innerWidth,
          settings.fontSize,
          leftChrome,
          targetChrome,
          PreferredTextWidth(row.label, settings.fontSize * 4.2),
          PreferredTextWidth(row.target, settings.fontSize * 3.4),
          hasTarget
        )
        if row.merfinPlusForceStacked and hasTarget then
          columns.wide = false
          columns.leftWidth = innerWidth
          columns.targetWidth = innerWidth
          columns.columnGap = 0
        end
        local leftTextWidth = math.max(1, columns.leftWidth - leftChrome)
        local targetTextWidth = math.max(1, columns.targetWidth - targetChrome)
        local leftTextHeight = WrappedTextHeight(row.label, leftTextWidth, lineHeight)
        local targetTextHeight = hasTarget and row.target:IsShown()
          and WrappedTextHeight(row.target, targetTextWidth, lineHeight) or lineHeight
        local leftHeight = math.max(leftTextHeight, VisibleTextureCount(leftTextures) > 0 and taskIconSize or 0)
        local targetHeight = hasTarget and math.max(
          row.target:IsShown() and targetTextHeight or 0,
          VisibleTextureCount(targetTextures) > 0 and targetIconSize or 0
        ) or 0
        local targetTop = verticalPadding
        local contentHeight
        if hasTarget and not columns.wide then
          targetTop = verticalPadding + leftHeight + lineGap
          contentHeight = leftHeight + lineGap + targetHeight
        else
          contentHeight = math.max(leftHeight, targetHeight)
        end
        rowHeight = math.max(ScaleWidgetPixel(26, settings.heightScale), contentHeight + (verticalPadding * 2))

        local leftX = PositionTextureRun(leftTextures, row, horizontalMargin, verticalPadding,
          leftHeight, taskIconSize, iconGap)
        row.label:SetPoint("TOPLEFT", row, "TOPLEFT", leftX, -verticalPadding)
        row.label:SetSize(leftTextWidth, leftHeight)
        row.label:SetJustifyV("MIDDLE")

        if hasTarget then
          local targetStartX = columns.wide
            and (horizontalMargin + columns.leftWidth + columns.columnGap) or horizontalMargin
          local targetX = PositionTextureRun(targetTextures, row, targetStartX, targetTop,
            targetHeight, targetIconSize, iconGap)
          row.target:SetPoint("TOPLEFT", row, "TOPLEFT", targetX, -targetTop)
          row.target:SetSize(targetTextWidth, targetHeight)
          row.target:SetJustifyV("MIDDLE")
        end
        row.merfinPlusResponsiveFlow = hasTarget and (columns.wide and "right" or "below") or "left-only"
        SetBackdrop(row, colors.row[1], colors.row[2], colors.row[3], settings.bodyAlpha)
      end
      row:SetHeight(rowHeight)
      row.merfinPlusComputedHeight = rowHeight
      bodyY = bodyY + rowHeight + rowGap
    end
  end
  if frame.hasRows then frame.body:SetHeight(bodyY + bodyMargin) end
  frame.merfinPlusComputedBodyHeight = frame.hasRows and (bodyY + bodyMargin) or 0
end

local function ApplyVisibleWidgetRowSettings(prefix)
  local frame = MerfinPlus[prefix]
  if not frame then
    return
  end
  local settings = MerfinPlus:GetAssignmentWidgetSettings(prefix)
  if prefix == "assignmentWidget" then
    LayoutAssignmentWidgetRows(frame, settings)
  else
    local bodyY = ScaleWidgetPixel(6, settings.heightScale)
    for _, row in ipairs(frame.rows or {}) do
      row.normalAlpha = settings.bodyAlpha
      SetFont(row.label, settings.fontSize, settings.font)
      SetFont(row.setGroupButton and row.setGroupButton.label, settings.fontSize, settings.font)
      if row.setGroupButton then
        row.setGroupButton:SetHeight(ScaleWidgetPixel(26, settings.heightScale))
      end
      if row:IsShown() then
        local rowHeight = ScaleWidgetPixel(32, settings.heightScale)
        row:SetHeight(rowHeight)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 0, -bodyY)
        row:SetPoint("TOPRIGHT", frame.body, "TOPRIGHT", 0, -bodyY)
        SetBackdrop(row, colors.row[1], colors.row[2], colors.row[3], settings.bodyAlpha)
        bodyY = bodyY + rowHeight + ScaleWidgetPixel(3, settings.heightScale)
      end
    end
    if frame.hasRows then
      frame.body:SetHeight(bodyY + ScaleWidgetPixel(3, settings.heightScale))
    end
    MerfinPlus:PositionRaidLeaderSetGroupButtons()
  end
end

function MerfinPlus:ApplyAssignmentWidgetSetting(prefix)
  if prefix ~= "assignmentWidget" and prefix ~= "raidLeaderWidget" then
    return
  end
  -- Slider/color/select updates land here. This deliberately does not parse an
  -- import, rebuild rows, refresh AceConfig, or touch the other widget.
  ApplyWidgetSettings(prefix)
  ApplyVisibleWidgetRowSettings(prefix)
end

local function AcquireAssignmentWidgetRow(index)
  local frame = MerfinPlus.assignmentWidget
  local row = frame.rows[index]
  if row then
    return row
  end
  row = CreateFrame("Button", nil, frame.body, template)
  row:RegisterForClicks("LeftButtonUp")
  row:SetHeight(26)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(20, 20)
  row.icon:SetPoint("LEFT", row, "LEFT", 8, 0)
  row.secondaryIcon = row:CreateTexture(nil, "ARTWORK")
  row.secondaryIcon:SetSize(20, 20)
  row.assignmentMarkerIcon = row:CreateTexture(nil, "ARTWORK")
  row.assignmentMarkerIcon:SetSize(18, 18)
  row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.label:SetPoint("LEFT", row.icon, "RIGHT", 7, 0)
  row.label:SetJustifyH("LEFT")
  row.label:SetWordWrap(true)
  if row.label.SetNonSpaceWrap then row.label:SetNonSpaceWrap(true) end
  row.targetIcon = row:CreateTexture(nil, "ARTWORK")
  row.targetIcon:SetSize(18, 18)
  row.targetSpecIcon = row:CreateTexture(nil, "ARTWORK")
  row.targetSpecIcon:SetSize(18, 18)
  row.target = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.target:SetJustifyH("LEFT")
  row.target:SetWordWrap(true)
  if row.target.SetNonSpaceWrap then row.target:SetNonSpaceWrap(true) end
  row.quickPlanHighlight = row:CreateTexture(nil, "HIGHLIGHT")
  row.quickPlanHighlight:SetAllPoints(row)
  row.quickPlanHighlight:SetColorTexture(theme.accent[1], theme.accent[2], theme.accent[3], 0.14)
  row:SetScript("OnClick", function(self, button)
    if button == "LeftButton" and self.quickBossPlanContext
      and MerfinPlus.ShowAssignmentWidgetBossPlanQuickOverview
    then
      MerfinPlus:ShowAssignmentWidgetBossPlanQuickOverview(
        self.quickBossPlanContext.groupID,
        self.quickBossPlanContext.selectedBossKey,
        self.quickBossPlanContext.selectedBossName
      )
    end
  end)
  row:EnableMouse(false)
  frame.rows[index] = row
  return row
end

local function GetAssignmentWidgetSpecIcon(classToken, spec)
  return MerfinPlus:GetRaidAssignmentSpecIconPath(classToken, spec)
end

local function GetCurrentPlayerAssignmentRows()
  local playerName = UnitName and UnitName("player") or ""
  local playerKey = NormalizeName(playerName)
  local output = {}
  if playerKey == "" then
    return output
  end

  local raidEntry = MerfinPlus:GetActivePersonalRaidAssignmentImport()
  local selectedBoss
  local selectedBosses
  if raidEntry and raidEntry.parsed then
    selectedBoss = MerfinPlus:GetActivePersonalRaidAssignmentBoss(raidEntry)
    selectedBosses = MerfinPlus:GetActivePersonalRaidAssignmentBosses(raidEntry)
  else
    local state = MerfinPlus:GetRaidAssignmentUIState()
    raidEntry = state.selectedGroup and MerfinPlus:GetRaidAssignmentImportForGroup(state.selectedGroup)
    local group = MerfinPlus:GetRaidAssignmentGroup(state.selectedGroup)
    if raidEntry and group and state.selectedBossKey then
      for _, raid in ipairs(group.raids or {}) do
        for _, catalogBoss in ipairs(raid.bosses or {}) do
          if state.selectedBossKey == raid.name .. "::" .. catalogBoss.key then
            selectedBoss = MerfinPlus:GetRaidAssignmentBoss(raidEntry.parsed, catalogBoss)
          end
        end
      end
    end
  end
  selectedBosses = selectedBosses or (selectedBoss and { selectedBoss } or {})
  if raidEntry then
    for _, boss in ipairs(selectedBosses) do
      local playerMap = MerfinPlus:BuildRaidAssignmentPlayerMap(boss)
      local visibleSections = {}
      for _, section in ipairs(MerfinPlus:GetRaidAssignmentSections(boss)) do
        local personalRows = {}
        for _, task in ipairs(section.rows or {}) do
          if MerfinPlus:IsRaidAssignmentTaskVisibleToPlayer(task, playerName) then
            personalRows[#personalRows + 1] = task
          end
        end
        if #personalRows > 0 then
          visibleSections[#visibleSections + 1] = { section = section, rows = personalRows }
        end
      end
      if #visibleSections > 0 then
        local quickBossPlanContext = MerfinPlus.GetAssignmentWidgetBossPlanQuickContext
          and MerfinPlus:GetAssignmentWidgetBossPlanQuickContext(raidEntry, boss)
          or nil
        output[#output + 1] = {
          heading = true,
          bossHeading = true,
          label = MerfinPlus:GetLocalizedBossName(
            MerfinPlus:GetRaidAssignmentBossLocaleID(boss),
            boss.name or "Raid Assignments"
          ),
          icon = quickBossPlanContext and quickBossPlanContext.bossIcon or nil,
          quickBossPlanContext = quickBossPlanContext,
        }
      end
      for _, visible in ipairs(visibleSections) do
        local section, personalRows = visible.section, visible.rows
        local label, icon, headerHasWorldmark = MerfinPlus:GetRaidAssignmentSectionDisplay(section.name, section.kind)
        output[#output + 1] = { heading = true, label = label, icon = icon }
        for _, task in ipairs(personalRows) do
          local display = MerfinPlus:BuildRaidAssignmentRowDisplay(task, section.name, playerMap)
          local spellLabel, spellIcon, secondarySpellIcon = display.label, display.icon, display.secondaryIcon
          local assignmentMarkerIcon = display.assignmentMarkerIcon
          local targetLabel, targetClass, targetIcon = display.target, display.targetClass, display.targetIcon
          local targetIsMarker, targetSpec = display.targetIsMarker, display.targetSpec
          if headerHasWorldmark then
            -- The header owns a section Worldmark.  Keep the row's useful
            -- label, but never render that same marker a second time below it.
            local withoutWorldmark = spellLabel:gsub(
              "^%s*%a+%s+[Ww][Oo][Rr][Ll][Dd][Mm][Aa][Rr][Kk]%s*[%-%:]*%s*",
              ""
            )
            if withoutWorldmark ~= "" then
              spellLabel = withoutWorldmark
            end
            if spellIcon == icon then
              spellIcon = nil
            end
            if assignmentMarkerIcon == icon then
              assignmentMarkerIcon = nil
            end
            if targetIsMarker then
              targetIcon = nil
              targetIsMarker = false
            end
          end
          output[#output + 1] = {
            label = spellLabel .. (display.note and display.note ~= "" and (" — " .. display.note) or ""),
            icon = spellIcon,
            secondaryIcon = secondarySpellIcon,
            assignmentMarkerIcon = assignmentMarkerIcon,
            target = targetLabel,
            targetClass = targetClass,
            targetIcon = targetIcon,
            targetSpec = targetSpec,
            targetIsMarker = targetIsMarker,
            forceStacked = display.multiTarget == true,
            note = display.note,
          }
        end
      end
    end
  end
  return output
end

function MerfinPlus:RefreshAssignmentWidget()
  local frame = self.assignmentWidget
  if not frame then
    return
  end
  ApplyWidgetSettings("assignmentWidget")
  ApplyVisibleWidgetRowSettings("assignmentWidget")
  local stored = self:GetAssignmentSettings()
  frame.isPinned = stored.assignmentWidgetPinned == true
  local expanded = frame.header.isHovered or stored.assignmentWidgetPinned
  if not frame:IsShown() or not expanded then
    frame.body:Hide()
    return
  end
  if frame.contentDirty == false then
    if frame.hasRows then frame.body:Show() else frame.body:Hide() end
    return
  end
  local rows = GetCurrentPlayerAssignmentRows()
  local showBody = #rows > 0
  local used = 0

  if showBody then
    for _, data in ipairs(rows) do
      used = used + 1
      local row = AcquireAssignmentWidgetRow(used)
      row.merfinPlusHeading = data.heading == true
      row.merfinPlusForceStacked = data.forceStacked == true
      row.quickBossPlanContext = data.bossHeading and data.quickBossPlanContext or nil
      row:EnableMouse(row.quickBossPlanContext ~= nil)
      if data.heading then
        SetTexture(row.icon, data.icon)
        row.label:SetText(data.label or "")
        row.label:SetTextColor(colors.gold[1], colors.gold[2], colors.gold[3], 1)
        row.targetIcon:Hide()
        row.targetSpecIcon:Hide()
        row.target:Hide()
        row.secondaryIcon:Hide()
        row.assignmentMarkerIcon:Hide()
        row.merfinPlusTargetVisible = false
      else
        SetTexture(row.icon, data.icon)
        SetTexture(row.secondaryIcon, data.secondaryIcon)
        SetTexture(row.assignmentMarkerIcon, data.assignmentMarkerIcon)
        row.label:SetText(data.label or "")
        row.label:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        local hasTargetIcon = SetTexture(row.targetIcon, data.targetIcon)
        local hasTargetSpecIcon = hasTargetIcon
          and SetTexture(row.targetSpecIcon, GetAssignmentWidgetSpecIcon(data.targetClass, data.targetSpec))
          or false
        if not hasTargetIcon then
          row.targetSpecIcon:Hide()
        end
        row.target:SetText(data.target or "")
        if data.targetClass then
          local classColor = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[data.targetClass])
            or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[data.targetClass])
            or { r = colors.text[1], g = colors.text[2], b = colors.text[3] }
          row.target:SetTextColor(
            classColor.r or classColor[1],
            classColor.g or classColor[2],
            classColor.b or classColor[3],
            1
          )
        else
          row.target:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)
        end
        if not data.targetIsMarker and data.target and data.target ~= "" then
          row.target:Show()
        else
          row.target:Hide()
        end
        row.merfinPlusTargetVisible = hasTargetIcon or hasTargetSpecIcon or row.target:IsShown()
      end
      row:Show()
    end
  end

  for index = used + 1, #frame.rows do
    frame.rows[index]:Hide()
  end
  if showBody then
    frame.body:Show()
  else
    frame.body:Hide()
  end
  frame.hasRows = #rows > 0
  frame.contentDirty = false
  ApplyVisibleWidgetRowSettings("assignmentWidget")
end

local function AcquireRaidLeaderWidgetRow(index)
  local frame = MerfinPlus.raidLeaderWidget
  local row = frame.rows[index]
  if row then
    return row
  end
  row = CreateFrame("Button", nil, frame.body, template)
  row:RegisterForClicks("LeftButtonUp")
  row:SetHeight(32)
  row.normalAlpha = 0.86
  SetBackdrop(row, colors.row[1], colors.row[2], colors.row[3], row.normalAlpha)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(44, 22)
  row.icon:SetPoint("LEFT", row, "LEFT", 8, 0)
  row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  SetFont(row.label, 13)
  row.label:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
  row.label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
  row.label:SetJustifyH("LEFT")

  row.setGroupButton = CreateFrame("Button", nil, row, template)
  row.setGroupButton:SetSize(112, 26)
  row.setGroupButton:SetPoint("LEFT", row, "RIGHT", 0, 0)
  row.setGroupButton:SetFrameLevel(row:GetFrameLevel() + 4)
  row.setGroupButton:RegisterForClicks("LeftButtonUp")
  SetBackdrop(
    row.setGroupButton,
    colors.heading[1],
    colors.heading[2],
    colors.heading[3],
    0.98
  )
  row.setGroupButton.label = row.setGroupButton:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  SetFont(row.setGroupButton.label, 11)
  row.setGroupButton.label:SetPoint("CENTER")
  row.setGroupButton.label:SetText(MerfinPlus:T("Set Group"))
  row.setGroupButton.label:SetTextColor(
    colors.gold[1],
    colors.gold[2],
    colors.gold[3],
    1
  )
  row.setGroupButton.hover = row.setGroupButton:CreateTexture(
    nil,
    "BACKGROUND",
    nil,
    2
  )
  row.setGroupButton.hover:SetTexture(WHITE)
  row.setGroupButton.hover:SetVertexColor(
    colors.gold[1],
    colors.gold[2],
    colors.gold[3],
    0.14
  )
  row.setGroupButton.hover:SetAllPoints()
  row.setGroupButton.hover:Hide()
  row.setGroupButton:Hide()

  row.hoverFill = row:CreateTexture(nil, "BACKGROUND", nil, 1)
  row.hoverFill:SetTexture(WHITE)
  row.hoverFill:SetVertexColor(theme.hover[1], theme.hover[2], theme.hover[3], 0.96)
  row.hoverFill:SetAllPoints(row)
  row.hoverFill:Hide()
  row.hoverBorder = {}
  local hoverBorderColor = colors.border or colors.gold or { 0.710, 0.545, 0.980, 1 }
  for _, side in ipairs({ "top", "bottom", "left", "right" }) do
    local edge = row:CreateTexture(nil, "BORDER")
    edge:SetTexture(WHITE)
    edge:SetVertexColor(
      hoverBorderColor[1], hoverBorderColor[2], hoverBorderColor[3],
      hoverBorderColor[4] or 0.95
    )
    row.hoverBorder[side] = edge
  end
  row.hoverBorder.top:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
  row.hoverBorder.top:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
  row.hoverBorder.top:SetHeight(1)
  row.hoverBorder.bottom:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
  row.hoverBorder.bottom:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
  row.hoverBorder.bottom:SetHeight(1)
  row.hoverBorder.left:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -1)
  row.hoverBorder.left:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 1)
  row.hoverBorder.left:SetWidth(1)
  row.hoverBorder.right:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -1)
  row.hoverBorder.right:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 1)
  row.hoverBorder.right:SetWidth(1)
  for _, edge in pairs(row.hoverBorder) do
    edge:Hide()
  end

  local hoverFill = row.hoverFill
  local hoverTop = row.hoverBorder.top
  local hoverBottom = row.hoverBorder.bottom
  local hoverLeft = row.hoverBorder.left
  local hoverRight = row.hoverBorder.right
  local setGroupButton = row.setGroupButton
  local function SetHoverVisible(visible)
    if visible then
      hoverFill:Show()
      hoverTop:Show()
      hoverBottom:Show()
      hoverLeft:Show()
      hoverRight:Show()
      if setGroupButton.bossKey then
        setGroupButton:Show()
      end
    else
      hoverFill:Hide()
      hoverTop:Hide()
      hoverBottom:Hide()
      hoverLeft:Hide()
      hoverRight:Hide()
      setGroupButton:Hide()
    end
  end
  row.SetHoverVisible = SetHoverVisible
  row:SetScript("OnEnter", function()
    SetHoverVisible(true)
  end)
  row:SetScript("OnLeave", function()
    if not (setGroupButton:IsShown() and setGroupButton:IsMouseOver()) then
      SetHoverVisible(false)
    end
  end)
  row.setGroupButton:SetScript("OnEnter", function()
    row.setGroupButton.hover:Show()
    SetHoverVisible(true)
  end)
  row.setGroupButton:SetScript("OnLeave", function()
    row.setGroupButton.hover:Hide()
    if not row:IsMouseOver() then
      SetHoverVisible(false)
    end
  end)
  row.setGroupButton:SetScript("OnClick", function(button)
    if button.preBossRaid and button.preBossCatalogBoss then
      MerfinPlus:ApplyPreBossGroupPlanForCatalogBoss(
        button.preBossRaid,
        button.preBossCatalogBoss
      )
    end
  end)
  frame.rows[index] = row
  return row
end

local function GetImportedRaidTrashBoss(parsed, raid)
  if not parsed or not raid then
    return nil
  end
  local raidKey = NormalizeName(tostring(raid.localeID or ""):match(":(.+)$") or raid.name)
  for _, boss in ipairs(parsed.bosses or {}) do
    if boss.isTrash and MerfinPlus:RaidAssignmentTrashAppliesToRaid(boss, raidKey) then
      return boss
    end
  end
  return nil
end

function MerfinPlus:RefreshRaidLeaderWidget()
  local frame = self.raidLeaderWidget
  if not frame then
    return
  end
  ApplyWidgetSettings("raidLeaderWidget")
  local widgetSettings = self:GetAssignmentWidgetSettings("raidLeaderWidget")
  ApplyVisibleWidgetRowSettings("raidLeaderWidget")
  local stored = self:GetAssignmentSettings()
  frame.isPinned = stored.raidLeaderWidgetPinned == true
  local expanded = frame.header.isHovered or frame.isPinned
  if not frame:IsShown() or not expanded then
    frame.body:Hide()
    return
  end
  if frame.contentDirty == false then
    if frame.hasRows then frame.body:Show() else frame.body:Hide() end
    return
  end
  local state = self:GetRaidAssignmentUIState()
  local group = self:GetRaidAssignmentGroup(state.selectedGroup)
  local entry = group and self:GetRaidAssignmentImportForGroup(group.id)
  local used, y = 0, 6

  if group and entry and entry.parsed then
    local function AddBroadcastRow(bossForRow, raidForRow, label, icon, preBossPlanBoss)
      local raidNameForRow = raidForRow.name
      local groupIDForRow = group.id
      used = used + 1
      local row = AcquireRaidLeaderWidgetRow(used)
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 0, -y)
      row:SetPoint("TOPRIGHT", frame.body, "TOPRIGHT", 0, -y)
      row.label:SetText(label)
      SetTexture(row.icon, icon)
      row.icon:SetTexCoord(0, 1, 0, 1)
      row.setGroupButton.bossKey = preBossPlanBoss and preBossPlanBoss.key or nil
      row.setGroupButton.preBossRaid = preBossPlanBoss and raidForRow or nil
      -- Keep the catalog boss for the later click.  Passing the already
      -- resolved plan boss back into the resolver used its stable storage key
      -- instead of its catalog boss key and falsely produced "no plan".
      row.setGroupButton.preBossCatalogBoss = preBossPlanBoss and bossForRow or nil
      row.setGroupButton.label:SetText(self:T("Set Group"))
      row.label:ClearAllPoints()
      if row.icon:IsShown() then
        row.label:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
      else
        row.label:SetPoint("LEFT", row, "LEFT", 8, 0)
      end
      row.label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
      PositionRaidLeaderSetGroupButton(
        row,
        stored.raidLeaderWidgetAlignment or "Down"
      )
      row.normalAlpha = widgetSettings.bodyAlpha
      SetBackdrop(row, colors.row[1], colors.row[2], colors.row[3], row.normalAlpha)
      row.SetHoverVisible(false)
      row:SetScript("OnClick", function()
        local currentState = MerfinPlus:GetRaidAssignmentUIState()
        currentState.selectedGroup = groupIDForRow
        currentState.selectedBossKey = raidNameForRow .. "::" .. bossForRow.key
        MerfinPlus:NotifyRaidAssignmentOptionsChanged()
        MerfinPlus:BroadcastPersonalRaidAssignments(bossForRow)
      end)
      row:Show()
      y = y + 35
    end
    local sharedTrash, sharedTrashAnchor = self:GetRaidAssignmentSharedTrashNavigation(entry.parsed, group)
    if sharedTrash and sharedTrashAnchor then
      AddBroadcastRow(
        sharedTrash,
        sharedTrashAnchor,
        self:T("Trash Assignments"),
        sharedTrash.icon,
        nil
      )
    end
    for _, raid in ipairs(group.raids or {}) do
      local trashBoss = GetImportedRaidTrashBoss(entry.parsed, raid)
      if trashBoss and trashBoss ~= sharedTrash then
        AddBroadcastRow(
          trashBoss,
          raid,
          self:GetRaidAssignmentAbbreviation(raid) .. " - " .. self:T("Trash Assignments"),
          trashBoss.icon,
          nil
        )
      end
      for _, catalogBoss in ipairs(raid.bosses or {}) do
        if self:GetRaidAssignmentBoss(entry.parsed, catalogBoss) then
          local preBossPlanBoss = self:GetPreBossGroupPlanBoss(raid, catalogBoss)
          AddBroadcastRow(
            catalogBoss,
            raid,
            self:GetLocalizedBossName(catalogBoss.localeID, catalogBoss.name),
            catalogBoss.icon,
            preBossPlanBoss
          )
        end
      end
    end
  end
  for index = used + 1, #frame.rows do
    frame.rows[index]:Hide()
  end
  frame.hasRows = used > 0
  frame.contentDirty = false
  frame.body:SetHeight(y + 3)
  ApplyVisibleWidgetRowSettings("raidLeaderWidget")
  if expanded and frame.hasRows then
    frame.body:Show()
  else
    frame.body:Hide()
  end
end

function MerfinPlus:MarkAssignmentWidgetContentDirty(prefix)
  local frame = self[prefix]
  if not frame then return end
  frame.contentDirty = true
  if not frame:IsShown() then return end
  local stored = self:GetAssignmentSettings()
  local expanded = frame.header.isHovered or stored[prefix .. "Pinned"] == true
  if not expanded then return end
  if prefix == "assignmentWidget" then
    self:RefreshAssignmentWidget()
  elseif prefix == "raidLeaderWidget" then
    self:RefreshRaidLeaderWidget()
  end
end

function MerfinPlus:NotifyAssignmentWidgetContentChanged(refreshPersonalWidget)
  if refreshPersonalWidget ~= false then
    self:MarkAssignmentWidgetContentDirty("assignmentWidget")
  end
  self:MarkAssignmentWidgetContentDirty("raidLeaderWidget")
end

function MerfinPlus:ApplyAssignmentWidgetSettings()
  ApplyWidgetSettings("assignmentWidget")
  ApplyWidgetSettings("raidLeaderWidget")
end

function MerfinPlus:RefreshAssignmentWidgetLocale()
  for _, prefix in ipairs({ "assignmentWidget", "raidLeaderWidget" }) do
    local frame = self[prefix]
    if frame and frame.title and frame.title.localeKey then
      frame.title.baseText = self:T(frame.title.localeKey)
      ApplyWidgetSettings(prefix)
    end
  end
  self:NotifyAssignmentWidgetContentChanged()
end

function MerfinPlus:UpdateRaidLeaderWidgetVisibility()
  local settings = self:GetAssignmentSettings()
  local loadOnlyInRaid = settings.raidLeaderWidgetLoadOnlyInRaid
  local shouldShow = settings.showRaidLeaderWidget
    and (not loadOnlyInRaid or (InRaidInstance() and self:CanUseRaidLeaderWidget()))
  if shouldShow then
    local frame = self.raidLeaderWidget
    local wasShown = frame and frame:IsShown()
    frame = CreateWidget("raidLeaderWidget", "Raid Leader")
    if not wasShown then
      PositionWidget("raidLeaderWidget")
      ApplyWidgetSettings("raidLeaderWidget")
      frame:Show()
      if frame.header.isHovered or settings.raidLeaderWidgetPinned == true then
        self:RefreshRaidLeaderWidget()
      end
    end
  elseif self.raidLeaderWidget and self.raidLeaderWidget:IsShown() then
    self.raidLeaderWidget:Hide()
  end
end

function MerfinPlus:UpdateAssignmentWidgetVisibility()
  local settings = self:GetAssignmentSettings()
  local loadOnlyInRaid = settings.assignmentWidgetLoadOnlyInRaid
  local shouldShow = settings.showAssignmentWidget and (not loadOnlyInRaid or InRaidInstance())
  if shouldShow then
    local frame = self.assignmentWidget
    local wasShown = frame and frame:IsShown()
    frame = CreateWidget("assignmentWidget", "Assignments")
    if not wasShown then
      PositionWidget("assignmentWidget")
      ApplyWidgetSettings("assignmentWidget")
      frame:Show()
      if frame.header.isHovered or settings.assignmentWidgetPinned == true then
        self:RefreshAssignmentWidget()
      end
    end
  elseif self.assignmentWidget and self.assignmentWidget:IsShown() then
    self.assignmentWidget:Hide()
  end
  self:UpdateRaidLeaderWidgetVisibility()
end

function MerfinPlus:InitializeAssignmentWidgets()
  if self.assignmentWidgetEventFrame then
    self:UpdateAssignmentWidgetVisibility()
    return
  end
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("GROUP_ROSTER_UPDATE")
  frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  frame:SetScript("OnEvent", function()
    MerfinPlus:UpdateAssignmentWidgetVisibility()
    local registry = LibStub("AceConfigRegistry-3.0", true)
    if registry then
      registry:NotifyChange("MerfinPlus_Assignments")
    end
  end)
  self.assignmentWidgetEventFrame = frame
  self:UpdateAssignmentWidgetVisibility()
end
