-- MerfinPlus Assignments option shell.
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
local LSM = LibStub("LibSharedMedia-3.0", true)
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0", true)
local AceGUI = LibStub("AceGUI-3.0", true)
local DEFAULT_WIDGET_FONT_NAME = "SFUIDisplayCondensed-Semibold"
local MANUAL_GROUPS_WIDGET = "MerfinPlusGurtoggManualGroups"
local MANUAL_GROUPS_HEIGHT = 164
local MANUAL_COLUMN_GAP = 8
local BLOOD_BOIL_ICON_TOKEN = "spell:42005"
local RELIQUARY_MANUAL_WIDGET = "MerfinPlusReliquaryManualAssignments"
local COUNCIL_MANUAL_WIDGET = "MerfinPlusCouncilManualAssignments"
local ILLIDAN_PHASE2_MANUAL_WIDGET = "MerfinPlusIllidanPhase2ManualAssignments"
local INTERRUPT_MANUAL_HEIGHT = 112
local INTERRUPT_COLUMN_GAP = 8
local WEAKAURA_RAID_ORDER = {
  "serpentshrine_cavern",
  "tempest_keep",
  "black_temple",
  "hyjal_summit",
}
local WEAKAURA_RAID_NAMES = {
  serpentshrine_cavern = "Serpentshrine Cavern",
  tempest_keep = "Tempest Keep",
  black_temple = "Black Temple",
  hyjal_summit = "Hyjal Summit",
}
local GURTOGG_GROUPS = {
  { key = "star", label = "Group 1", markerIndex = 1, order = 20 },
  { key = "diamond", label = "Group 2", markerIndex = 3, order = 30 },
  { key = "circle", label = "Group 3", markerIndex = 2, order = 40 },
}
local INTERRUPT_MANUAL_FIELDS = {
  reliquary = {
    { key = "spiritShock", label = "Spirit Shock Interrupt", iconToken = "spell:41426" },
    { key = "runeShield", label = "Rune Shield Spell Steal", iconToken = "spell:41431" },
    { key = "seethe", label = "Seethe Tranq Shot", iconToken = "spell:41520" },
  },
  council = {
    { key = "prayerOfHealing", label = "Prayer of Healing", iconToken = 135943 },
  },
}
local ILLIDAN_PHASE2_MANUAL_FIELDS = {
  { key = "group1", label = "Phase 2 Group 1", markerIndex = 3 },
  { key = "group2", label = "Phase 2 Group 2", markerIndex = 1 },
  { key = "group3", label = "Phase 2 Group 3", markerIndex = 2 },
}

local MANUAL_FIELD_BACKDROP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local function SetManualFieldBackdrop(frame, r, g, b, a)
  if frame.SetBackdrop then
    frame:SetBackdrop(MANUAL_FIELD_BACKDROP)
    frame:SetBackdropColor(r, g, b, a)
    frame:SetBackdropBorderColor(unpack(theme.borderSoft))
  end
end

local function SetManualInputFocus(frame, focused)
  if not frame.SetBackdropBorderColor then return end
  if focused then
    frame:SetBackdropBorderColor(unpack(theme.border))
    frame:SetBackdropColor(unpack(theme.surfaceRaised))
  else
    frame:SetBackdropBorderColor(unpack(theme.borderSoft))
    frame:SetBackdropColor(unpack(theme.surface))
  end
end

local function GetBloodBoilSpellIcon()
  if type(MerfinPlus.ResolveCanonicalRaidAssignmentIcon) == "function" then
    return MerfinPlus:ResolveCanonicalRaidAssignmentIcon(BLOOD_BOIL_ICON_TOKEN)
  end
end

local function GetAssignmentSpellIcon(token)
  if type(token) == "number" then return token end
  if type(MerfinPlus.ResolveCanonicalRaidAssignmentIcon) == "function" then
    return MerfinPlus:ResolveCanonicalRaidAssignmentIcon(token)
  end
end

local function LayoutManualGroupColumns(widget, width)
  width = math.max(1, tonumber(width) or widget.frame:GetWidth() or 1)
  local columnWidth = math.max(1, math.floor((width - (MANUAL_COLUMN_GAP * 2)) / 3))
  for index, column in ipairs(widget.columns) do
    column.frame:ClearAllPoints()
    column.frame:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", (index - 1) * (columnWidth + MANUAL_COLUMN_GAP), 0)
    column.frame:SetSize(columnWidth, MANUAL_GROUPS_HEIGHT)
  end
  widget.renderedColumnWidth = columnWidth
  widget.renderedTotalWidth = (columnWidth * 3) + (MANUAL_COLUMN_GAP * 2)
end

local function RegisterManualGroupsWidget()
  if not AceGUI or not AceGUI.RegisterWidgetType or not AceGUI.RegisterAsWidget then return end
  local frameTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
  local methods = {
    OnAcquire = function(self)
      self:SetHeight(MANUAL_GROUPS_HEIGHT)
      self:Refresh()
    end,
    OnWidthSet = function(self, width)
      LayoutManualGroupColumns(self, width)
    end,
    OnRelease = function(self)
      for _, column in ipairs(self.columns) do column.editBox:ClearFocus() end
    end,
    SetText = function() end,
    SetDisabled = function(self, disabled)
      self.disabled = disabled == true
      for _, column in ipairs(self.columns) do
        column.editBox:SetEnabled(not self.disabled)
        column.slider:EnableMouse(not self.disabled)
        column.frame:SetAlpha(self.disabled and 0.55 or 1)
      end
    end,
    Refresh = function(self)
      for _, column in ipairs(self.columns) do
        local setting = MerfinPlus:GetGurtoggManualGroupSettings(column.definition.key)
        column.refreshing = true
        column.editBox:SetText(setting and setting.players or "")
        column.slider:SetValue(setting and setting.stackTarget or 1)
        column.stackIcon:SetTexture(GetBloodBoilSpellIcon())
        column.stackLabel:SetText(MerfinPlus:T("Blood Boil Stacks") .. ": " .. tostring(setting and setting.stackTarget or 1))
        column.refreshing = nil
      end
    end,
  }

  local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(600, MANUAL_GROUPS_HEIGHT)
    local widget = { type = MANUAL_GROUPS_WIDGET, frame = frame, columns = {} }
    frame.obj = widget

    for index, definition in ipairs(GURTOGG_GROUPS) do
      local columnFrame = CreateFrame("Frame", nil, frame, frameTemplate)
      SetManualFieldBackdrop(columnFrame, 0.035, 0.055, 0.075, 0.94)

      local header = columnFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      header:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", 9, -8)
      header:SetPoint("TOPRIGHT", columnFrame, "TOPRIGHT", -9, -8)
      header:SetJustifyH("LEFT")
      header:SetText(
        "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. definition.markerIndex
          .. ":18:18:0:0|t " .. MerfinPlus:T(definition.label)
      )

      local inputFrame = CreateFrame("Frame", nil, columnFrame, frameTemplate)
      inputFrame:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", 6, -31)
      inputFrame:SetPoint("TOPRIGHT", columnFrame, "TOPRIGHT", -6, -31)
      inputFrame:SetHeight(68)
      SetManualFieldBackdrop(inputFrame, 0.015, 0.025, 0.035, 1)
      inputFrame:EnableMouse(false)

      local scrollFrame = CreateFrame("ScrollFrame", nil, inputFrame)
      scrollFrame:SetPoint("TOPLEFT", inputFrame, "TOPLEFT", 5, -4)
      scrollFrame:SetPoint("BOTTOMRIGHT", inputFrame, "BOTTOMRIGHT", -5, 4)
      scrollFrame:EnableMouse(true)
      if scrollFrame.SetFrameLevel and inputFrame.GetFrameLevel then
        scrollFrame:SetFrameLevel(inputFrame:GetFrameLevel() + 1)
      end
      local editBox = CreateFrame("EditBox", nil, scrollFrame)
      editBox:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
      editBox:SetWidth(1)
      editBox:SetMultiLine(true)
      editBox:SetAutoFocus(false)
      editBox:SetFontObject(ChatFontNormal)
      editBox:SetTextInsets(0, 0, 0, 0)
      editBox:SetTextColor(1, 1, 1, 1)
      editBox:SetHeight(58)
      editBox:EnableKeyboard(true)
      editBox:EnableMouse(true)
      if editBox.SetFrameLevel and scrollFrame.GetFrameLevel then
        editBox:SetFrameLevel(scrollFrame:GetFrameLevel() + 1)
      end
      if editBox.SetMaxLetters then editBox:SetMaxLetters(0) end
      if editBox.SetMaxBytes then editBox:SetMaxBytes(0) end
      scrollFrame:SetScrollChild(editBox)

      local stackRow = CreateFrame("Frame", nil, columnFrame)
      stackRow:SetPoint("TOPLEFT", inputFrame, "BOTTOMLEFT", 2, -7)
      stackRow:SetPoint("TOPRIGHT", inputFrame, "BOTTOMRIGHT", -2, -7)
      stackRow:SetHeight(18)

      local stackIcon = stackRow:CreateTexture(nil, "ARTWORK")
      stackIcon:SetPoint("LEFT", stackRow, "LEFT", 0, 0)
      stackIcon:SetSize(16, 16)
      stackIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      stackIcon:SetTexture(GetBloodBoilSpellIcon())

      local stackLabel = stackRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      stackLabel:SetPoint("LEFT", stackIcon, "RIGHT", 4, 0)
      stackLabel:SetPoint("RIGHT", stackRow, "RIGHT", 0, 0)
      stackLabel:SetJustifyH("LEFT")

      local slider = CreateFrame("Slider", nil, columnFrame, frameTemplate)
      slider:SetPoint("TOPLEFT", stackRow, "BOTTOMLEFT", 0, -5)
      slider:SetPoint("TOPRIGHT", stackRow, "BOTTOMRIGHT", 0, -5)
      slider:SetHeight(14)
      slider:SetOrientation("HORIZONTAL")
      slider:SetMinMaxValues(1, 10)
      slider:SetValueStep(1)
      slider:SetObeyStepOnDrag(true)
      slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
      local thumb = slider:GetThumbTexture()
      if thumb then thumb:SetSize(14, 18) end
      SetManualFieldBackdrop(slider, 0.02, 0.03, 0.04, 1)

      local column = {
        definition = definition,
        frame = columnFrame,
        header = header,
        inputFrame = inputFrame,
        scrollFrame = scrollFrame,
        editBox = editBox,
        stackRow = stackRow,
        stackIcon = stackIcon,
        stackLabel = stackLabel,
        slider = slider,
      }
      widget.columns[index] = column

      editBox:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
      scrollFrame:SetScript("OnMouseDown", function()
        editBox:SetFocus()
        editBox:SetCursorPosition(editBox:GetNumLetters())
      end)
      editBox:SetScript("OnEditFocusGained", function()
        SetManualInputFocus(inputFrame, true)
      end)
      editBox:SetScript("OnEditFocusLost", function()
        SetManualInputFocus(inputFrame, false)
      end)
      editBox:SetScript("OnTextChanged", function(box, userInput)
        local text = box:GetText() or ""
        local _, newlineCount = text:gsub("\n", "\n")
        box:SetHeight(math.max(scrollFrame:GetHeight(), ((newlineCount + 1) * 14) + 6))
        if userInput and not column.refreshing then
          MerfinPlus:SetGurtoggManualGroupPlayers(definition.key, text)
          MerfinPlus:SetGurtoggGroupAssignmentsStatus("", "muted")
        end
      end)
      scrollFrame:SetScript("OnSizeChanged", function(_, scrollWidth, scrollHeight)
        editBox:SetWidth(math.max(1, scrollWidth or 1))
        local text = editBox:GetText() or ""
        local _, newlineCount = text:gsub("\n", "\n")
        editBox:SetHeight(math.max(scrollHeight or 1, ((newlineCount + 1) * 14) + 6))
      end)
      if type(MerfinPlus.ConfigureAssignmentImportEditBox) == "function" then
        MerfinPlus:ConfigureAssignmentImportEditBox(editBox)
      end
      slider:SetScript("OnValueChanged", function(control, value)
        value = math.floor((tonumber(value) or 1) + 0.5)
        column.stackLabel:SetText(MerfinPlus:T("Blood Boil Stacks") .. ": " .. tostring(value))
        if not column.refreshing then
          MerfinPlus:SetGurtoggManualGroupStackTarget(definition.key, value)
          MerfinPlus:SetGurtoggGroupAssignmentsStatus("", "muted")
        end
      end)
    end

    for name, method in pairs(methods) do widget[name] = method end
    LayoutManualGroupColumns(widget, 600)
    return AceGUI:RegisterAsWidget(widget)
  end

  AceGUI:RegisterWidgetType(MANUAL_GROUPS_WIDGET, Constructor, 2)
end

RegisterManualGroupsWidget()

local function RegisterInterruptManualWidget(widgetType, bossKey, fields, adapter)
  if not AceGUI or not AceGUI.RegisterWidgetType or not AceGUI.RegisterAsWidget then return end
  local frameTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
  local function LayoutColumns(widget, width)
    width = math.max(1, tonumber(width) or widget.frame:GetWidth() or 1)
    local count = #widget.columns
    local totalGap = INTERRUPT_COLUMN_GAP * math.max(0, count - 1)
    local columnWidth = count == 1
      and math.min(236, width)
      or math.max(1, math.floor((width - totalGap) / count))
    for index, column in ipairs(widget.columns) do
      column.frame:ClearAllPoints()
      column.frame:SetPoint("TOPLEFT", widget.frame, "TOPLEFT",
        (index - 1) * (columnWidth + INTERRUPT_COLUMN_GAP), 0)
      column.frame:SetSize(columnWidth, INTERRUPT_MANUAL_HEIGHT)
    end
    widget.renderedColumnWidth = columnWidth
    widget.renderedTotalWidth = (columnWidth * count) + totalGap
  end
  local methods = {
    OnAcquire = function(self)
      self:SetHeight(INTERRUPT_MANUAL_HEIGHT)
      self:Refresh()
    end,
    OnWidthSet = function(self, width) LayoutColumns(self, width) end,
    OnRelease = function(self)
      for _, column in ipairs(self.columns) do column.editBox:ClearFocus() end
    end,
    SetText = function() end,
    SetDisabled = function(self, disabled)
      self.disabled = disabled == true
      for _, column in ipairs(self.columns) do
        column.editBox:SetEnabled(not self.disabled)
        column.frame:SetAlpha(self.disabled and 0.55 or 1)
      end
    end,
    Refresh = function(self)
      for _, column in ipairs(self.columns) do
        column.refreshing = true
        local value = adapter and adapter.get(column.definition)
          or MerfinPlus:GetInterruptManualAssignment(bossKey, column.definition.key)
        column.editBox:SetText(value or "")
        column.spellIcon:SetTexture(column.definition.markerIndex
          and ("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. column.definition.markerIndex)
          or GetAssignmentSpellIcon(column.definition.iconToken))
        column.refreshing = nil
      end
    end,
  }

  local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(600, INTERRUPT_MANUAL_HEIGHT)
    local widget = { type = widgetType, frame = frame, columns = {} }
    frame.obj = widget
    for index, definition in ipairs(fields) do
      local columnFrame = CreateFrame("Frame", nil, frame, frameTemplate)
      SetManualFieldBackdrop(columnFrame, 0.035, 0.055, 0.075, 0.94)

      local spellIcon = columnFrame:CreateTexture(nil, "ARTWORK")
      spellIcon:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", 9, -8)
      spellIcon:SetSize(18, 18)
      spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      spellIcon:SetTexture(definition.markerIndex
        and ("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. definition.markerIndex)
        or GetAssignmentSpellIcon(definition.iconToken))

      local header = columnFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      header:SetPoint("LEFT", spellIcon, "RIGHT", 5, 0)
      header:SetPoint("RIGHT", columnFrame, "RIGHT", -7, 0)
      header:SetJustifyH("LEFT")
      header:SetText(MerfinPlus:T(definition.label))

      local inputFrame = CreateFrame("Frame", nil, columnFrame, frameTemplate)
      inputFrame:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", 6, -34)
      inputFrame:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT", -6, 7)
      SetManualFieldBackdrop(inputFrame, 0.015, 0.025, 0.035, 1)
      inputFrame:EnableMouse(false)

      local scrollFrame = CreateFrame("ScrollFrame", nil, inputFrame)
      scrollFrame:SetPoint("TOPLEFT", inputFrame, "TOPLEFT", 5, -4)
      scrollFrame:SetPoint("BOTTOMRIGHT", inputFrame, "BOTTOMRIGHT", -5, 4)
      scrollFrame:EnableMouse(true)
      if scrollFrame.SetFrameLevel and inputFrame.GetFrameLevel then
        scrollFrame:SetFrameLevel(inputFrame:GetFrameLevel() + 1)
      end

      local editBox = CreateFrame("EditBox", nil, scrollFrame)
      editBox:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
      editBox:SetWidth(1)
      editBox:SetMultiLine(true)
      editBox:SetAutoFocus(false)
      editBox:SetFontObject(ChatFontNormal)
      editBox:SetTextInsets(0, 0, 0, 0)
      editBox:SetTextColor(1, 1, 1, 1)
      editBox:SetHeight(66)
      editBox:EnableKeyboard(true)
      editBox:EnableMouse(true)
      if editBox.SetFrameLevel and scrollFrame.GetFrameLevel then
        editBox:SetFrameLevel(scrollFrame:GetFrameLevel() + 1)
      end
      if editBox.SetMaxLetters then editBox:SetMaxLetters(0) end
      if editBox.SetMaxBytes then editBox:SetMaxBytes(0) end
      scrollFrame:SetScrollChild(editBox)

      local column = {
        definition = definition,
        frame = columnFrame,
        spellIcon = spellIcon,
        header = header,
        inputFrame = inputFrame,
        scrollFrame = scrollFrame,
        editBox = editBox,
      }
      widget.columns[index] = column

      editBox:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
      scrollFrame:SetScript("OnMouseDown", function()
        editBox:SetFocus()
        editBox:SetCursorPosition(editBox:GetNumLetters())
      end)
      editBox:SetScript("OnEditFocusGained", function() SetManualInputFocus(inputFrame, true) end)
      editBox:SetScript("OnEditFocusLost", function() SetManualInputFocus(inputFrame, false) end)
      editBox:SetScript("OnTextChanged", function(box, userInput)
        local text = box:GetText() or ""
        local _, newlineCount = text:gsub("\n", "\n")
        box:SetHeight(math.max(scrollFrame:GetHeight(), ((newlineCount + 1) * 14) + 6))
        if userInput and not column.refreshing then
          if adapter then
            adapter.set(definition, text)
            adapter.clearStatus()
          else
            MerfinPlus:SetInterruptManualAssignment(bossKey, definition.key, text)
            MerfinPlus:SetInterruptAssignmentsStatus(bossKey, "", "muted")
          end
        end
      end)
      scrollFrame:SetScript("OnSizeChanged", function(_, scrollWidth, scrollHeight)
        editBox:SetWidth(math.max(1, scrollWidth or 1))
        local text = editBox:GetText() or ""
        local _, newlineCount = text:gsub("\n", "\n")
        editBox:SetHeight(math.max(scrollHeight or 1, ((newlineCount + 1) * 14) + 6))
      end)
      if type(MerfinPlus.ConfigureAssignmentImportEditBox) == "function" then
        MerfinPlus:ConfigureAssignmentImportEditBox(editBox)
      end
    end
    for name, method in pairs(methods) do widget[name] = method end
    LayoutColumns(widget, 600)
    return AceGUI:RegisterAsWidget(widget)
  end

  AceGUI:RegisterWidgetType(widgetType, Constructor, 1)
end

RegisterInterruptManualWidget(RELIQUARY_MANUAL_WIDGET, "reliquary", INTERRUPT_MANUAL_FIELDS.reliquary)
RegisterInterruptManualWidget(COUNCIL_MANUAL_WIDGET, "council", INTERRUPT_MANUAL_FIELDS.council)
RegisterInterruptManualWidget(
  ILLIDAN_PHASE2_MANUAL_WIDGET,
  "illidan",
  ILLIDAN_PHASE2_MANUAL_FIELDS,
  {
    get = function(definition) return MerfinPlus:GetIllidanPhase2ManualGroup(definition.key) end,
    set = function(definition, value) MerfinPlus:SetIllidanPhase2ManualGroup(definition.key, value) end,
    clearStatus = function() MerfinPlus:SetIllidanPhase2AssignmentsStatus("", "muted") end,
  }
)

function MerfinPlus:BuildAssignmentsOptions()
  local isTBC = self.IsTBC and self.IsTBC()
  local showTBCWeakAuraAssignments = isTBC
  local function Settings()
    return self:GetAssignmentSettings()
  end

  local function RefreshWidgets()
    self:ApplyAssignmentWidgetSettings()
    self:UpdateAssignmentWidgetVisibility()
  end

  local function ApplyWidgetOption(key)
    local prefix = type(key) == "string"
      and (key:match("^(assignmentWidget)") or key:match("^(raidLeaderWidget)"))
    if prefix and self.ApplyAssignmentWidgetSetting then
      self:ApplyAssignmentWidgetSetting(prefix)
      return
    end
    RefreshWidgets()
  end

  local function GetWidgetFontValues()
    if not LSM or not LSM.HashTable then
      return { [DEFAULT_WIDGET_FONT_NAME] = DEFAULT_WIDGET_FONT_NAME }
    end
    local registered = LSM:HashTable("font")
    local values = {}
    for name in pairs(registered or {}) do
      values[name] = name
    end
    if not next(values) then
      values[DEFAULT_WIDGET_FONT_NAME] = DEFAULT_WIDGET_FONT_NAME
    end
    return values
  end

  local function ValidWidgetFont(value)
    return type(value) == "string"
      and value ~= ""
      and LSM
      and LSM.Fetch
      and type(LSM:Fetch("font", value, true)) == "string"
  end

  local function ToggleOption(name, key, order, onSet, hidden)
    return {
      type = "toggle",
      name = name,
      order = order,
      width = "full",
      hidden = hidden,
      get = function()
        return Settings()[key] == true
      end,
      set = function(_, value)
        Settings()[key] = value == true
        if onSet then
          onSet(value == true)
        else
          RefreshWidgets()
        end
      end,
    }
  end

  local function RangeOption(name, key, minimum, maximum, step, order, isPercent)
    return {
      type = "range",
      name = name,
      order = order,
      min = minimum,
      max = maximum,
      step = step,
      isPercent = isPercent == true,
      get = function()
        return Settings()[key]
      end,
      set = function(_, value)
        Settings()[key] = value
        ApplyWidgetOption(key)
      end,
    }
  end

  local function ColorOption(name, prefix, order, border)
    local suffix = border and "Border" or "Header"
    return {
      type = "color",
      name = name,
      order = order,
      hasAlpha = false,
      get = function()
        local settings = Settings()
        return settings[prefix .. suffix .. "R"], settings[prefix .. suffix .. "G"], settings[prefix .. suffix .. "B"]
      end,
      set = function(_, r, g, b)
        local settings = Settings()
        settings[prefix .. suffix .. "R"] = r
        settings[prefix .. suffix .. "G"] = g
        settings[prefix .. suffix .. "B"] = b
        ApplyWidgetOption(prefix .. suffix)
      end,
    }
  end

  local function WidgetSettingsGroup(name, prefix, order, hidden)
    return {
      type = "group",
      name = name,
      order = order,
      inline = true,
      width = 0.5,
      hidden = hidden,
      args = {
        headerColor = ColorOption("Header Color", prefix, 10, false),
        width = RangeOption("Width", prefix .. "HeaderWidth", 240, 520, 1, 20),
        height = RangeOption("Height", prefix .. "HeaderHeight", 22, 64, 1, 30),
        headerAlpha = RangeOption("Header Opacity", prefix .. "HeaderAlpha", 0, 1, 0.01, 40, true),
        bodyAlpha = RangeOption("Assignment Background Opacity", prefix .. "BodyAlpha", 0, 1, 0.01, 50, true),
        titleOffsetX = RangeOption("Header Title X Offset", prefix .. "TitleOffsetX", -200, 200, 1, 60),
        titleOffsetY = RangeOption("Header Title Y Offset", prefix .. "TitleOffsetY", -80, 80, 1, 70),
        font = {
          type = "select",
          name = self:T("Font"),
          order = 80,
          values = GetWidgetFontValues,
          dialogControl = "MerfinPlusDropdown",
          get = function()
            local value = Settings()[prefix .. "HeaderFont"]
            return ValidWidgetFont(value) and value or DEFAULT_WIDGET_FONT_NAME
          end,
          set = function(_, value)
            Settings()[prefix .. "HeaderFont"] =
              ValidWidgetFont(value) and value or DEFAULT_WIDGET_FONT_NAME
            ApplyWidgetOption(prefix .. "HeaderFont")
          end,
        },
        fontSize = RangeOption("Font Size", prefix .. "FontSize", 8, 24, 1, 90),
        titleSpacing = RangeOption("Header Title Spacing", prefix .. "TitleSpacing", 0, 20, 1, 100),
        logoOffsetX = RangeOption("Header Icon X Offset", prefix .. "LogoOffsetX", -120, 120, 1, 110),
        logoOffsetY = RangeOption("Header Icon Y Offset", prefix .. "LogoOffsetY", -80, 80, 1, 120),
        logoSize = RangeOption("Header Icon Size", prefix .. "LogoSize", 12, 52, 1, 130),
        showLogo = ToggleOption("Show Icon Logo", prefix .. "ShowLogo", 140, function()
          ApplyWidgetOption(prefix .. "ShowLogo")
        end),
        showBorder = ToggleOption("Show Border", prefix .. "ShowBorder", 150, function()
          ApplyWidgetOption(prefix .. "ShowBorder")
        end),
        borderColor = ColorOption("Border Color", prefix, 160, true),
        borderThickness = RangeOption("Border Thickness", prefix .. "BorderThickness", 1, 6, 1, 170),
        alignment = {
          type = "select",
          name = self:T("Aligning"),
          order = 180,
          values = {
            Up = self:T("Up"),
            Down = self:T("Down"),
            Left = self:T("Left"),
            Right = self:T("Right"),
          },
          sorting = { "Up", "Down", "Left", "Right" },
          get = function()
            return Settings()[prefix .. "Alignment"] or "Down"
          end,
          set = function(_, value)
            Settings()[prefix .. "Alignment"] = value
            ApplyWidgetOption(prefix .. "Alignment")
          end,
        },
      },
    }
  end

  local function NotifyWeakAuraAssignmentOptionsChanged()
    if AceConfigRegistry and AceConfigRegistry.NotifyChange then
      AceConfigRegistry:NotifyChange("MerfinPlus_Assignments")
    end
  end

  local function WeakAuraRaidState()
    local settings = Settings()
    settings.viewState = settings.viewState or {}
    settings.viewState.weakAuraRaidAssignments = settings.viewState.weakAuraRaidAssignments or {}
    local state = settings.viewState.weakAuraRaidAssignments
    if state.selectedRaid and not WEAKAURA_RAID_NAMES[state.selectedRaid] then
      state.selectedRaid = nil
    end
    return state
  end

  local function GetSelectedWeakAuraRaid()
    return WeakAuraRaidState().selectedRaid
  end

  local function SetSelectedWeakAuraRaid(value)
    WeakAuraRaidState().selectedRaid = WEAKAURA_RAID_NAMES[value] and value or nil
    NotifyWeakAuraAssignmentOptionsChanged()
  end

  local function GetWeakAuraRaidValues()
    local values = {}
    for _, raidKey in ipairs(WEAKAURA_RAID_ORDER) do
      values[raidKey] = self:T(WEAKAURA_RAID_NAMES[raidKey])
    end
    return values
  end

  local function IsWeakAuraRaidHidden(raidKey)
    return GetSelectedWeakAuraRaid() ~= raidKey
  end

  local function SetGurtoggMode(mode)
    self:SetGurtoggAssignmentMode(mode)
    NotifyWeakAuraAssignmentOptionsChanged()
  end

  local function GurtoggModeToggle(name, mode, order, width, relWidth)
    return {
      type = "toggle",
      name = self:T(name),
      order = order,
      width = width or "full",
      relWidth = relWidth,
      get = function() return self:GetGurtoggAssignmentMode() == mode end,
      set = function(_, value) if value == true then SetGurtoggMode(mode) end end,
    }
  end

  local function BossHeader(icon, label)
    return "|T" .. tostring(icon or "") .. ":28:28:0:0|t " .. self:T(label)
  end

  local function StatusText(getter)
    local text, tone = getter()
    if text == "" then return " " end
    local color = tone == "green" and "|cff55ff88" or tone == "red" and "|cffff6666" or "|cffb8c6d9"
    return color .. self:T(text) .. "|r"
  end

  local gurtoggSection = {
    type = "group",
    name = BossHeader(self.GURTOGG_ASSIGNMENTS_ICON, "Gurtogg Bloodboil Assignments"),
    inline = true,
    order = 10,
    width = "full",
    args = {
      guildManager = GurtoggModeToggle(
        "Use MerfinPlus Guild Manager Assignments",
        self.GURTOGG_ASSIGNMENTS_GUILD_MANAGER_MODE,
        10,
        "relative",
        2 / 3
      ),
      sendManual = {
        type = "execute",
        name = self:T("Send Manual Groups"),
        order = 11,
        width = "relative",
        relWidth = 1 / 3,
        hidden = function()
          return self:GetGurtoggAssignmentMode() ~= self.GURTOGG_ASSIGNMENTS_MANUAL_MODE
        end,
        disabled = function()
          local allowed = self:CanBroadcastGurtoggAssignments()
          return allowed ~= true
        end,
        func = function()
          self:SyncManualGurtoggGroups()
          NotifyWeakAuraAssignmentOptionsChanged()
        end,
      },
      manual = GurtoggModeToggle("Use Manual Groups", self.GURTOGG_ASSIGNMENTS_MANUAL_MODE, 20),
      guildManagerHelp = {
        type = "description",
        name = self:T("Guild Manager assignments are sent automatically with Gurtogg boss assignment syncs."),
        order = 30,
        width = "full",
        hidden = function()
          return self:GetGurtoggAssignmentMode() ~= self.GURTOGG_ASSIGNMENTS_GUILD_MANAGER_MODE
        end,
      },
      manualHelp = {
        type = "description",
        name = self:T("Manual groups are sent only by Send Manual Groups or the emergency pull sync."),
        order = 40,
        width = "full",
        hidden = function()
          return self:GetGurtoggAssignmentMode() ~= self.GURTOGG_ASSIGNMENTS_MANUAL_MODE
        end,
      },
      manualGroups = {
        type = "execute",
        name = "",
        order = 50,
        width = "full",
        dialogControl = MANUAL_GROUPS_WIDGET,
        hidden = function()
          return self:GetGurtoggAssignmentMode() ~= self.GURTOGG_ASSIGNMENTS_MANUAL_MODE
        end,
        func = function() end,
      },
      status = {
        type = "description",
        name = function() return StatusText(function() return self:GetGurtoggGroupAssignmentsStatus() end) end,
        order = 60,
        width = "full",
      },
    },
  }
  gurtoggSection.hidden = function() return IsWeakAuraRaidHidden("black_temple") end

  local function InterruptModeToggle(bossKey, name, mode, order, width, relWidth)
    return {
      type = "toggle",
      name = self:T(name),
      order = order,
      width = width or "full",
      relWidth = relWidth,
      get = function() return self:GetInterruptAssignmentMode(bossKey) == mode end,
      set = function(_, value)
        if value == true then
          self:SetInterruptAssignmentMode(bossKey, mode)
          NotifyWeakAuraAssignmentOptionsChanged()
        end
      end,
    }
  end

  local function InterruptSection(bossKey, label, icon, widgetType, order)
    return {
      type = "group",
      name = BossHeader(icon, label),
      inline = true,
      order = order,
      width = "full",
      args = {
        guildManager = InterruptModeToggle(
          bossKey,
          "Use MerfinPlus Guild Manager Assignments",
          self.INTERRUPT_ASSIGNMENTS_GUILD_MANAGER_MODE,
          10,
          "relative",
          2 / 3
        ),
        sendManual = {
          type = "execute",
          name = self:T("Send Manual Assignments"),
          order = 11,
          width = "relative",
          relWidth = 1 / 3,
          hidden = function()
            return self:GetInterruptAssignmentMode(bossKey) ~= self.INTERRUPT_ASSIGNMENTS_MANUAL_MODE
          end,
          disabled = function()
            local allowed = self:CanBroadcastInterruptAssignments()
            return allowed ~= true
          end,
          func = function()
            self:SyncManualInterruptAssignments(bossKey)
            NotifyWeakAuraAssignmentOptionsChanged()
          end,
        },
        manual = InterruptModeToggle(
          bossKey,
          "Use Manual Groups",
          self.INTERRUPT_ASSIGNMENTS_MANUAL_MODE,
          20
        ),
        guildManagerHelp = {
          type = "description",
          name = self:T("Guild Manager WeakAura assignments are sent automatically with this boss assignment sync."),
          order = 30,
          width = "full",
          hidden = function()
            return self:GetInterruptAssignmentMode(bossKey) ~= self.INTERRUPT_ASSIGNMENTS_GUILD_MANAGER_MODE
          end,
        },
        manualHelp = {
          type = "description",
          name = self:T("Manual assignments are sent only by Send Manual Assignments or the emergency pull sync."),
          order = 40,
          width = "full",
          hidden = function()
            return self:GetInterruptAssignmentMode(bossKey) ~= self.INTERRUPT_ASSIGNMENTS_MANUAL_MODE
          end,
        },
        manualAssignments = {
          type = "execute",
          name = "",
          order = 50,
          width = "full",
          dialogControl = widgetType,
          hidden = function()
            return self:GetInterruptAssignmentMode(bossKey) ~= self.INTERRUPT_ASSIGNMENTS_MANUAL_MODE
          end,
          func = function() end,
        },
        status = {
          type = "description",
          name = function()
            return StatusText(function() return self:GetInterruptAssignmentsStatus(bossKey) end)
          end,
          order = 60,
          width = "full",
        },
      },
    }
  end

  local function IllidanModeToggle(name, mode, order, width, relWidth)
    return {
      type = "toggle",
      name = self:T(name),
      order = order,
      width = width or "full",
      relWidth = relWidth,
      get = function() return self:GetIllidanPhase2AssignmentMode() == mode end,
      set = function(_, value)
        if value == true then
          self:SetIllidanPhase2AssignmentMode(mode)
          NotifyWeakAuraAssignmentOptionsChanged()
        end
      end,
    }
  end

  local illidanSection = {
    type = "group",
    name = BossHeader(self.ILLIDAN_PHASE2_ASSIGNMENTS_ICON, "Illidan Stormrage"),
    inline = true,
    order = 40,
    width = "full",
    args = {
      guildManager = IllidanModeToggle(
        "Use MerfinPlus Guild Manager Assignments",
        self.ILLIDAN_PHASE2_ASSIGNMENTS_GUILD_MANAGER_MODE,
        10,
        "relative",
        2 / 3
      ),
      sendManual = {
        type = "execute",
        name = self:T("Send Manual Groups"),
        order = 11,
        width = "relative",
        relWidth = 1 / 3,
        hidden = function()
          return self:GetIllidanPhase2AssignmentMode() ~= self.ILLIDAN_PHASE2_ASSIGNMENTS_MANUAL_MODE
        end,
        disabled = function()
          local allowed = self:CanBroadcastIllidanPhase2Assignments()
          return allowed ~= true
        end,
        func = function()
          self:SyncManualIllidanPhase2Assignments()
          NotifyWeakAuraAssignmentOptionsChanged()
        end,
      },
      manual = IllidanModeToggle(
        "Use Manual Groups",
        self.ILLIDAN_PHASE2_ASSIGNMENTS_MANUAL_MODE,
        20
      ),
      guildManagerHelp = {
        type = "description",
        name = self:T("Guild Manager Illidan Phase 2 groups are sent automatically with Illidan boss assignment syncs."),
        order = 30,
        width = "full",
        hidden = function()
          return self:GetIllidanPhase2AssignmentMode() ~= self.ILLIDAN_PHASE2_ASSIGNMENTS_GUILD_MANAGER_MODE
        end,
      },
      manualHelp = {
        type = "description",
        name = self:T("Manual Illidan Phase 2 groups are sent only by Send Manual Groups or the emergency pull sync."),
        order = 40,
        width = "full",
        hidden = function()
          return self:GetIllidanPhase2AssignmentMode() ~= self.ILLIDAN_PHASE2_ASSIGNMENTS_MANUAL_MODE
        end,
      },
      manualGroups = {
        type = "execute",
        name = "",
        order = 50,
        width = "full",
        dialogControl = ILLIDAN_PHASE2_MANUAL_WIDGET,
        hidden = function()
          return self:GetIllidanPhase2AssignmentMode() ~= self.ILLIDAN_PHASE2_ASSIGNMENTS_MANUAL_MODE
        end,
        func = function() end,
      },
      status = {
        type = "description",
        name = function()
          return StatusText(function() return self:GetIllidanPhase2AssignmentsStatus() end)
        end,
        order = 60,
        width = "full",
      },
    },
  }
  illidanSection.hidden = function() return IsWeakAuraRaidHidden("black_temple") end

  local reliquarySection = InterruptSection(
    "reliquary",
    "Reliquary of Souls",
    self.INTERRUPT_ASSIGNMENTS_RELIQUARY_ICON,
    RELIQUARY_MANUAL_WIDGET,
    20
  )
  reliquarySection.hidden = function() return IsWeakAuraRaidHidden("black_temple") end

  local councilSection = InterruptSection(
    "council",
    "The Illidari Council",
    self.INTERRUPT_ASSIGNMENTS_COUNCIL_ICON,
    COUNCIL_MANUAL_WIDGET,
    30
  )
  councilSection.hidden = function() return IsWeakAuraRaidHidden("black_temple") end

  local gurtoggArgs = {
    raidSelect = {
      type = "select",
      name = self:T("Select Raid"),
      order = 1,
      width = 1.5,
      dialogControl = "MerfinPlusDropdown",
      values = GetWeakAuraRaidValues,
      sorting = WEAKAURA_RAID_ORDER,
      get = GetSelectedWeakAuraRaid,
      set = function(_, value) SetSelectedWeakAuraRaid(value) end,
    },
    raidSelectSpacer = {
      type = "description",
      name = " ",
      order = 1.5,
      width = "full",
    },
    selectPrompt = {
      type = "description",
      name = self:T("Select a raid to view WeakAura assignments."),
      order = 2,
      width = "full",
      hidden = function() return GetSelectedWeakAuraRaid() ~= nil end,
    },
    emptyState = {
      type = "description",
      name = self:T("No WeakAura assignments are available for the selected raid."),
      order = 3,
      width = "full",
      hidden = function()
        local raidKey = GetSelectedWeakAuraRaid()
        return raidKey == nil or raidKey == "black_temple"
      end,
    },
    gurtogg = gurtoggSection,
    reliquary = reliquarySection,
    council = councilSection,
    illidan = illidanSection,
  }

  return {
    type = "group",
    name = self:T("Assignments"),
    childGroups = "tab",
    args = {
      raid = {
        type = "group",
        name = self:T("Raid Assignments"),
        order = 10,
        childGroups = "tab",
        args = {
          sync = {
            type = "group",
            name = self:T("Sync Settings"),
            order = 10,
            args = {
              content = {
                type = "execute",
                name = "",
                dialogControl = "MerfinPlusRaidAssignmentSyncSettings",
                func = function() end,
                width = "full",
                order = 10,
              },
            },
          },
          assignments = {
            type = "group",
            name = self:T("Assignments"),
            order = 20,
            args = {
              content = {
                type = "execute",
                name = "",
                dialogControl = "MerfinPlusRaidAssignmentDetails",
                func = function() end,
                width = "full",
                order = 10,
              },
            },
          },
        },
      },
      gurtogg = showTBCWeakAuraAssignments and {
        type = "group",
        name = self:T("WA Assignments"),
        order = 15,
        args = gurtoggArgs,
      } or nil,
      settings = {
        type = "group",
        name = self:T("Widget Settings"),
        order = 30,
        args = {
          general = {
            type = "group",
            name = self:T("Settings"),
            inline = true,
            order = 10,
            width = "full",
            args = {
              showAssignmentWidget = ToggleOption("Show Assignment Widget", "showAssignmentWidget", 20),
              showRaidLeaderWidget = ToggleOption("Show Raid Leader Widget", "showRaidLeaderWidget", 30),
              assignmentDivider = {
                type = "header",
                name = self:T("Assignment Widget Visibility"),
                order = 40,
              },
              assignmentAlways = ToggleOption("Assignment: Show always", "assignmentWidgetShowAlways", 50, function(value)
                local settings = Settings()
                settings.assignmentWidgetLoadOnlyInRaid = not value
                RefreshWidgets()
              end),
              assignmentRaid = ToggleOption("Assignment: Load only in Raid", "assignmentWidgetLoadOnlyInRaid", 60, function(value)
                local settings = Settings()
                settings.assignmentWidgetShowAlways = not value
                RefreshWidgets()
              end),
              raidLeaderDivider = {
                type = "header",
                name = self:T("Raid Leader Widget Visibility"),
                order = 70,
              },
              raidLeaderAlways = ToggleOption("Raid Leader: Show always", "raidLeaderWidgetShowAlways", 80, function(value)
                local settings = Settings()
                settings.raidLeaderWidgetLoadOnlyInRaid = not value
                RefreshWidgets()
              end),
              raidLeaderRaid = ToggleOption("Raid Leader: Load only in Raid", "raidLeaderWidgetLoadOnlyInRaid", 90, function(value)
                local settings = Settings()
                settings.raidLeaderWidgetShowAlways = not value
                RefreshWidgets()
              end),
            },
          },
          assignmentWidget = WidgetSettingsGroup("Assignment Widget", "assignmentWidget", 20),
          raidLeaderWidget = WidgetSettingsGroup("Raid Leader Widget", "raidLeaderWidget", 30),
        },
      },
    },
  }
end
