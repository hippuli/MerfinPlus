-- Direct collapsible class cards for Raid Cooldown activation.

local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme

local WIDGET_TYPE = "MerfinPlusRaidCooldownActivation"
local WIDGET_VERSION = 3
local HEADER_HEIGHT = 34
local SPELL_CELL_HEIGHT = 36
local SPELL_CELL_GAP = 5
local SPELL_CELL_MIN_WIDTH = 210
local SPELL_CELL_MAX_COLUMNS = 3
local GAP = 5
local template = BackdropTemplateMixin and "BackdropTemplate" or nil

local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
}

local colors = {
  panel = theme.canvas,
  header = theme.selected,
  headerHover = theme.hover,
  row = theme.surface,
  rowHover = theme.surfaceRaised,
  gold = theme.border,
  borderSoft = theme.borderSoft,
  text = theme.text,
  muted = theme.muted,
}

local function SetBackdrop(frame, background, border)
  if not frame.SetBackdrop then
    return
  end
  frame:SetBackdrop(backdrop)
  frame:SetBackdropColor(background[1], background[2], background[3], background[4])
  frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function ClassDisplayName(className)
  local key = className:sub(1, 1) .. className:sub(2):lower()
  return MerfinPlus:T(key)
end

local function GetClassColor(className)
  local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[className]
  return color and color.r or 1, color and color.g or 1, color and color.b or 1
end

local function SpellName(spellID)
  if C_Spell and C_Spell.GetSpellName then
    return C_Spell.GetSpellName(spellID)
  end
  return GetSpellInfo and GetSpellInfo(spellID)
end

local function SpellTexture(spellID)
  if C_Spell and C_Spell.GetSpellTexture then
    return C_Spell.GetSpellTexture(spellID)
  end
  return GetSpellTexture and GetSpellTexture(spellID)
end

local function GetSelectedRenderer()
  local rendererKey = MerfinPlus:GetRaidCooldownSelectedActivationRenderer()
  if not rendererKey then
    return nil
  end
  local config, renderer = MerfinPlus:EnsureRaidCooldownRendererConfig(rendererKey)
  if not config or not renderer
    or not MerfinPlus:IsRaidCooldownRendererEnabled(rendererKey)
  then
    return nil
  end
  return rendererKey, config, renderer
end

local function IsCollapsed(config, className)
  return config.ui.activationCollapsed[className] ~= false
end

local function SortedSpellIDs(definition, _, className)
  local spellIDs = {}
  for spellID in pairs(definition.spellData[className] or {}) do
    spellID = tonumber(spellID)
    if spellID then
      spellIDs[#spellIDs + 1] = spellID
    end
  end
  table.sort(spellIDs, function(left, right)
    local leftData = definition.spellData[className]
      and definition.spellData[className][left]
    local rightData = definition.spellData[className]
      and definition.spellData[className][right]
    local leftIndex = leftData and tonumber(leftData.index) or math.huge
    local rightIndex = rightData and tonumber(rightData.index) or math.huge
    return leftIndex == rightIndex and left < right or leftIndex < rightIndex
  end)
  return spellIDs
end

local function ScheduleParentLayout(self)
  self.layoutGeneration = (self.layoutGeneration or 0) + 1
  local generation = self.layoutGeneration
  local parent = self.parent
  if not parent or not parent.DoLayout then
    return
  end
  C_Timer.After(0, function()
    if self.layoutGeneration == generation
      and self.parent == parent
      and parent.DoLayout
    then
      parent:DoLayout()
    end
  end)
end

local function GetColumnLayout(self)
  local width = tonumber(self.layoutWidth) or self.frame:GetWidth() or 0
  if width <= 24 then
    width = SPELL_CELL_MIN_WIDTH + 24
  end
  local innerWidth = math.max(1, width - 24)
  local columns = math.floor(
    (innerWidth + SPELL_CELL_GAP) / (SPELL_CELL_MIN_WIDTH + SPELL_CELL_GAP)
  )
  columns = math.max(1, math.min(SPELL_CELL_MAX_COLUMNS, columns))
  local cellWidth = (
    innerWidth - ((columns - 1) * SPELL_CELL_GAP)
  ) / columns
  return columns, cellWidth
end

local function AcquireHeader(self, index)
  local header = self.headers[index]
  if header then
    header:Show()
    return header
  end

  header = CreateFrame("Button", nil, self.frame, template)
  header:SetHeight(HEADER_HEIGHT)
  SetBackdrop(header, colors.header, colors.gold)

  header.arrow = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  header.arrow:SetPoint("LEFT", header, "LEFT", 10, 0)
  header.arrow:SetWidth(14)
  header.arrow:SetJustifyH("CENTER")
  header.arrow:SetTextColor(colors.gold[1], colors.gold[2], colors.gold[3], 1)

  header.icon = header:CreateTexture(nil, "ARTWORK")
  header.icon:SetSize(24, 24)
  header.icon:SetPoint("LEFT", header.arrow, "RIGHT", 7, 0)
  header.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")

  header.label = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  header.label:SetPoint("LEFT", header.icon, "RIGHT", 9, 0)
  header.label:SetPoint("RIGHT", header, "RIGHT", -12, 0)
  header.label:SetJustifyH("LEFT")

  header:SetScript("OnEnter", function(button)
    if not self.disabled then
      SetBackdrop(button, colors.headerHover, colors.gold)
    end
  end)
  header:SetScript("OnLeave", function(button)
    SetBackdrop(button, colors.header, colors.gold)
  end)
  header:SetScript("OnClick", function(button)
    if self.disabled or not button.className then
      return
    end
    local _, config = GetSelectedRenderer()
    if not config then
      return
    end
    local collapsed = IsCollapsed(config, button.className)
    config.ui.activationCollapsed[button.className] = not collapsed
    self:Refresh()
    ScheduleParentLayout(self)
  end)

  self.headers[index] = header
  return header
end

local function SetChecked(cell, checked)
  cell.checked = checked == true
  if cell.checked then
    cell.check:Show()
  else
    cell.check:Hide()
  end
  SetBackdrop(
    cell.checkBox,
    colors.panel,
    cell.checked and colors.gold or colors.borderSoft
  )
end

local function AcquireSpellCell(self, index)
  local cell = self.spellCells[index]
  if cell then
    cell:Show()
    return cell
  end

  cell = CreateFrame("Button", nil, self.frame, template)
  cell:SetHeight(SPELL_CELL_HEIGHT)
  SetBackdrop(cell, colors.row, colors.borderSoft)

  cell.icon = cell:CreateTexture(nil, "ARTWORK")
  cell.icon:SetSize(24, 24)
  cell.icon:SetPoint("LEFT", cell, "LEFT", 8, 0)
  cell.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

  cell.label = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  cell.label:SetPoint("LEFT", cell.icon, "RIGHT", 7, 0)
  cell.label:SetPoint("RIGHT", cell, "RIGHT", -34, 0)
  cell.label:SetJustifyH("LEFT")
  if cell.label.SetWordWrap then
    cell.label:SetWordWrap(false)
  end

  cell.checkBox = CreateFrame("Frame", nil, cell, template)
  cell.checkBox:SetSize(18, 18)
  cell.checkBox:SetPoint("RIGHT", cell, "RIGHT", -8, 0)
  SetBackdrop(cell.checkBox, colors.panel, colors.borderSoft)

  cell.check = cell.checkBox:CreateTexture(nil, "OVERLAY")
  cell.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
  cell.check:SetAllPoints(cell.checkBox)

  cell:SetScript("OnEnter", function(button)
    if not self.disabled then
      SetBackdrop(button, colors.rowHover, colors.gold)
    end
  end)
  cell:SetScript("OnLeave", function(button)
    SetBackdrop(button, colors.row, colors.borderSoft)
  end)
  cell:SetScript("OnClick", function(button)
    if self.disabled or not button.className or not button.spellID then
      return
    end
    local rendererKey, config = GetSelectedRenderer()
    if not rendererKey or not config then
      return
    end
    local stringID = tostring(button.spellID)
    config.cds[button.className] = config.cds[button.className] or {}
    local enabled = config.cds[button.className][stringID] ~= true
    config.cds[button.className][stringID] = enabled
    SetChecked(button, enabled)
    MerfinPlus:NotifyRaidCooldownTrackerChanged(
      ("renderers.%s.cds.%s.%s"):format(
        rendererKey,
        button.className,
        stringID
      )
    )
  end)

  self.spellCells[index] = cell
  return cell
end

local methods = {
  OnAcquire = function(self)
    self.disabled = false
    self:Refresh()
  end,
  OnRelease = function(self)
    self.disabled = false
    self.widthLayoutGeneration = (self.widthLayoutGeneration or 0) + 1
    for _, header in ipairs(self.headers) do
      header:Hide()
    end
    for _, cell in ipairs(self.spellCells) do
      cell:Hide()
    end
  end,
  SetText = function() end,
  SetImage = function() end,
  SetImageSize = function() end,
  SetDisabled = function(self, disabled)
    self.disabled = disabled == true
    self.frame:SetAlpha(self.disabled and 0.55 or 1)
  end,
  OnWidthSet = function(self, width)
    width = tonumber(width)
    if not width or width <= 0 then
      return
    end
    if self.layoutWidth and math.abs(self.layoutWidth - width) < 0.5 then
      return
    end

    self.layoutWidth = width
    self.widthLayoutGeneration = (self.widthLayoutGeneration or 0) + 1
    local generation = self.widthLayoutGeneration
    C_Timer.After(0, function()
      if self.widthLayoutGeneration == generation and self.frame:IsShown() then
        self:Refresh()
        ScheduleParentLayout(self)
      end
    end)
  end,
  Refresh = function(self)
    local definition = MerfinPlus:GetRaidCooldownTrackerExpansion()
    local rendererKey, config = GetSelectedRenderer()
    if not definition or not rendererKey or not config then
      for _, header in ipairs(self.headers) do
        header:Hide()
      end
      for _, cell in ipairs(self.spellCells) do
        cell:Hide()
      end
      self:SetHeight(1)
      return
    end

    for _, header in ipairs(self.headers) do
      header:Hide()
    end
    for _, cell in ipairs(self.spellCells) do
      cell:Hide()
    end

    self.note:SetText(MerfinPlus:T(
      "Enable cooldowns by class. Expand a class to configure individual spells."
    ))

    local columns, cellWidth = GetColumnLayout(self)
    local y = -34
    local headerIndex, cellIndex = 0, 0
    for _, className in ipairs(definition.classOrder or {}) do
      headerIndex = headerIndex + 1
      local header = AcquireHeader(self, headerIndex)
      header.className = className
      header:ClearAllPoints()
      header:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, y)
      header:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, y)

      local collapsed = IsCollapsed(config, className)
      header.arrow:SetText(collapsed and "+" or "-")
      header.label:SetText(ClassDisplayName(className))
      local red, green, blue = GetClassColor(className)
      header.label:SetTextColor(red, green, blue, 1)
      local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[className]
      if coords then
        header.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
      else
        header.icon:SetTexCoord(0, 1, 0, 1)
      end
      y = y - HEADER_HEIGHT - GAP

      if not collapsed then
        local spellIDs = SortedSpellIDs(definition, config, className)
        for spellPosition, spellID in ipairs(spellIDs) do
          cellIndex = cellIndex + 1
          local cell = AcquireSpellCell(self, cellIndex)
          cell.className = className
          cell.spellID = spellID
          cell:ClearAllPoints()
          local column = (spellPosition - 1) % columns
          local row = math.floor((spellPosition - 1) / columns)
          cell:SetWidth(cellWidth)
          cell:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            12 + (column * (cellWidth + SPELL_CELL_GAP)),
            y - (row * (SPELL_CELL_HEIGHT + SPELL_CELL_GAP))
          )
          cell.icon:SetTexture(SpellTexture(spellID))
          cell.label:SetText(
            SpellName(spellID)
              or (MerfinPlus:T("Spell ID") .. " " .. spellID)
          )
          cell.label:SetTextColor(red, green, blue, 1)
          local enabled = config.cds[className]
            and config.cds[className][tostring(spellID)] == true
          SetChecked(cell, enabled)
        end
        if #spellIDs > 0 then
          local rows = math.ceil(#spellIDs / columns)
          y = y - (rows * (SPELL_CELL_HEIGHT + SPELL_CELL_GAP)) - 3
        end
      end
    end
    self:SetHeight(math.max(1, -y + 2))
  end,
}

local function Constructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(1)

  local note = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  note:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
  note:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
  note:SetJustifyH("LEFT")
  note:SetTextColor(colors.muted[1], colors.muted[2], colors.muted[3], 1)

  local widget = {
    type = WIDGET_TYPE,
    frame = frame,
    note = note,
    headers = {},
    spellCells = {},
  }
  for name, method in pairs(methods) do
    widget[name] = method
  end
  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)
