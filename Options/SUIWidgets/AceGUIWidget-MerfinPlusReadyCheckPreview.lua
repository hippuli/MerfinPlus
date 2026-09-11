-- Interactive 25-player preview for the TBC Ready Check options.

local AceGUI = LibStub("AceGUI-3.0")
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
local WIDGET_TYPE = "MerfinPlusReadyCheckPreview"
local WIDGET_VERSION = 7
local MAX_SCALE = 0.70
local TITLE_HEIGHT, HEADER_HEIGHT, ROW_HEIGHT = 25, 20, 18
local NAME_WIDTH, STATUS_WIDTH = 126, 40
local DURABILITY_WIDTH, PACK_STATUS_WIDTH = 64, 46
local template = BackdropTemplateMixin and "BackdropTemplate" or nil

local NAMES = {
  "Merfin", "Anouschka", "NoMore", "Fondago", "JoeBiden",
  "DonaldusTrumpus", "Ducky", "Putina", "Asthetic", "Menomore",
  "Gigachardo", "Tempestrae", "Holydestiny", "Nymirah", "Daleet",
  "Meowyface", "Darthsin", "Confusion", "Eirissa", "Lumity",
  "Mangeii", "Moonbbark", "Flashymcgee", "Huntsgrl", "Darach",
}
local CLASSES = {
  "MAGE", "PALADIN", "WARRIOR", "PRIEST", "HUNTER",
  "WARLOCK", "ROGUE", "DRUID", "SHAMAN", "WARRIOR",
  "PALADIN", "SHAMAN", "PRIEST", "WARLOCK", "MAGE",
  "DRUID", "ROGUE", "MAGE", "HUNTER", "WARLOCK",
  "PALADIN", "DRUID", "PRIEST", "HUNTER", "SHAMAN",
}
local STATUS_TEXTURES = {
  READY_CHECK_READY_TEXTURE or "Interface\\RaidFrame\\ReadyCheck-Ready",
  READY_CHECK_NOT_READY_TEXTURE or "Interface\\RaidFrame\\ReadyCheck-NotReady",
  READY_CHECK_WAITING_TEXTURE or "Interface\\RaidFrame\\ReadyCheck-Waiting",
}

local function Border(frame, r, g, b, a)
  if not frame.SetBackdrop then return end
  frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
  frame:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.88)
  frame:SetBackdropBorderColor(r or theme.borderSoft[1], g or theme.borderSoft[2], b or theme.borderSoft[3], a or theme.borderSoft[4])
end

local function BorderColor(frame, r, g, b, a)
  frame:SetBackdropBorderColor(r or theme.borderSoft[1], g or theme.borderSoft[2], b or theme.borderSoft[3], a or theme.borderSoft[4])
end

local function Font(parent, size, justify)
  local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetJustifyH(justify or "CENTER")
  local path = MerfinPlus.GetReadyCheckFont and MerfinPlus:GetReadyCheckFont()
  if path then text:SetFont(path, size, "OUTLINE") end
  return text
end

local function CreateCell(parent)
  local cell = CreateFrame("Frame", nil, parent, template)
  Border(cell)
  cell.icon = cell:CreateTexture(nil, "ARTWORK")
  cell.icon:SetPoint("LEFT", cell, "LEFT", 2, 0)
  cell.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  cell.text = Font(cell, 9)
  cell.text:SetPoint("LEFT", cell.icon, "RIGHT", 1, 0)
  cell.text:SetPoint("RIGHT", cell, "RIGHT", -1, 0)
  return cell
end

local function PreviewColumnWidth(column)
  if column.durability then return DURABILITY_WIDTH end
  if column.t5Version or column.t6Version or column.t6AVersion then return PACK_STATUS_WIDTH end
  return column.width or 48
end

local function SetPreviewCell(cell, column, rowIndex, columnIndex)
  local icon = (MerfinPlus.READY_CHECK_OPTION_ICONS or {})[column.key]
  local missing = ((rowIndex + columnIndex) % 6 == 0)
  cell.icon:Show()
  cell.icon:ClearAllPoints()
  cell.icon:SetPoint("LEFT", cell, "LEFT", 2, 0)
  cell.icon:SetSize(12, 12)
  cell.icon:SetVertexColor(1, 1, 1, 1)
  cell.text:SetText("")
  if column.t5Version or column.t6Version or column.t6AVersion then
    cell.icon:ClearAllPoints()
    cell.icon:SetPoint("CENTER", cell, "CENTER", 0, 0)
    if rowIndex % 5 == 0 then
      cell.icon:SetTexture(STATUS_TEXTURES[2])
      cell.text:SetText("")
      cell.text:SetTextColor(1, 0.25, 0.25, 1)
      BorderColor(cell, 0.65, 0.08, 0.08, 1)
    else
      cell.icon:SetTexture(STATUS_TEXTURES[1])
      cell.text:SetText("")
      cell.text:SetTextColor(0.3, 1, 0.4, 1)
      BorderColor(cell, 0.18, 0.62, 0.25, 1)
    end
  elseif column.version then
    cell.icon:SetTexture(rowIndex % 7 == 0 and STATUS_TEXTURES[2] or STATUS_TEXTURES[1])
    cell.text:SetText(rowIndex % 7 == 0 and "v2.8" or "v2.9")
    cell.text:SetTextColor(rowIndex % 7 == 0 and 1 or 0.3, rowIndex % 7 == 0 and 0.25 or 1, 0.3, 1)
  elseif column.durability then
    cell.icon:SetTexture(icon)
    cell.text:SetText(string.format("%d%%", 100 - ((rowIndex * 3) % 52)))
    cell.text:SetTextColor(0.8, 1, 0.35, 1)
  elseif missing then
    cell.icon:SetTexture(STATUS_TEXTURES[2])
    cell.text:SetText("")
    BorderColor(cell, 0.55, 0.08, 0.08, 1)
  else
    cell.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    if (rowIndex + columnIndex) % 9 == 0 then
      cell.icon:SetVertexColor(1, 0.65, 0.15, 1)
      BorderColor(cell, 1, 0.42, 0.05, 1)
    else
      cell.icon:SetVertexColor(1, 1, 1, 1)
      BorderColor(cell, 0.18, 0.62, 0.25, 1)
    end
  end
end

local methods = {
  OnAcquire = function(self)
    self:SetFullWidth(true)
    self:SetHeight(525)
    MerfinPlus.readyCheckPreviewWidgets = MerfinPlus.readyCheckPreviewWidgets or setmetatable({}, { __mode = "k" })
    MerfinPlus.readyCheckPreviewWidgets[self] = true
    self:Refresh()
  end,
  OnRelease = function(self)
    if MerfinPlus.readyCheckPreviewWidgets then MerfinPlus.readyCheckPreviewWidgets[self] = nil end
  end,
  SetText = function() end,
  SetFontObject = function() end,
  SetLabel = function() end,
  SetDisabled = function() end,
  OnWidthSet = function(self, width)
    if width and width > 0 then self.frame:SetWidth(width) end
    self.layoutSignature = nil
    self:Refresh()
  end,
  RefreshTheme = function(self)
    self.preview:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.88)
    self.preview:SetBackdropBorderColor(unpack(theme.border))
    self.titleBar:SetStatusBarColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.52)
    self.responses:SetTextColor(unpack(theme.text))
    self.title:SetTextColor(unpack(theme.accentBright))
    for _, header in ipairs(self.headers or {}) do
      header:SetBackdropColor(theme.surfaceRaised[1], theme.surfaceRaised[2], theme.surfaceRaised[3], 0.88)
      header:SetBackdropBorderColor(unpack(theme.borderSoft))
      header.text:SetTextColor(unpack(theme.accentBright))
    end
    for _, row in ipairs(self.rows or {}) do
      row:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.88)
      row:SetBackdropBorderColor(unpack(theme.borderSoft))
      for _, cell in ipairs(row.cells or {}) do
        cell:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0.88)
      end
    end
  end,
  Refresh = function(self)
    self:RefreshTheme()
    local settings = MerfinPlus:GetReadyCheckSettings()
    local columns = MerfinPlus.READY_CHECK_COLUMNS or {}
    local visible = {}
    local signature = {}
    local naturalGridWidth = NAME_WIDTH + STATUS_WIDTH
    for index, column in ipairs(columns) do
      local isVisible = settings[column.visibleSetting] and true or false
      signature[index] = isVisible and "1" or "0"
      if isVisible then
        visible[#visible + 1] = { index = index, column = column }
        naturalGridWidth = naturalGridWidth + PreviewColumnWidth(column)
      end
    end
    local availableWidth = tonumber(self.frame:GetWidth()) or 0
    if availableWidth <= 20 then availableWidth = (naturalGridWidth * MAX_SCALE) + 8 end
    local scale = math.min(MAX_SCALE, math.max(0.25, (availableWidth - 8) / naturalGridWidth))
    local gridWidth = naturalGridWidth * scale
    signature = table.concat(signature) .. ":" .. tostring(math.floor(availableWidth + 0.5))
    if self.layoutSignature == signature then
      return
    end
    self.layoutSignature = signature
    self.previewScale = scale
    self.preview:SetSize(gridWidth + 4, TITLE_HEIGHT + HEADER_HEIGHT + (#NAMES * ROW_HEIGHT) + 4)
    self.titleBar:SetWidth(gridWidth)
    self.header:SetWidth(gridWidth)
    self.responses:SetText("Responses: 17/25")
    self.title:SetText("MP: Ready Check (12 sec.)")
    for _, header in ipairs(self.headers) do header:Hide() end
    local x = 0
    local function Header(index, width, label, left)
      local header = self.headers[index]
      header:ClearAllPoints();header:SetPoint("LEFT", self.header, "LEFT", x, 0);header:SetSize(width, HEADER_HEIGHT)
      header.text:SetText(label);header.text:SetJustifyH(left and "LEFT" or "CENTER");header:Show();x = x + width
    end
    Header(1, NAME_WIDTH * scale, "Player", true)
    Header(2, STATUS_WIDTH * scale, "RC")
    for _, item in ipairs(visible) do Header(item.index + 2, PreviewColumnWidth(item.column) * scale, item.column.shortLabel or item.column.label) end
    for rowIndex, row in ipairs(self.rows) do
      row:SetSize(gridWidth, ROW_HEIGHT - 1)
      row:ClearAllPoints();row:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, -((rowIndex - 1) * ROW_HEIGHT))
      row.name:SetSize(math.max(24, (NAME_WIDTH * scale) - 6), ROW_HEIGHT)
      row.status:ClearAllPoints()
      row.status:SetPoint("CENTER", row, "LEFT", (NAME_WIDTH * scale) + (STATUS_WIDTH * scale / 2), 0)
      for _, cell in ipairs(row.cells) do cell:Hide() end
      local cellX = (NAME_WIDTH + STATUS_WIDTH) * scale
      for _, item in ipairs(visible) do
        local cell = row.cells[item.index]
        local width = PreviewColumnWidth(item.column) * scale
        cell:ClearAllPoints();cell:SetPoint("LEFT", row, "LEFT", cellX + 1, 0);cell:SetSize(math.max(8, width - 2), ROW_HEIGHT - 2)
        cell:Show();cellX = cellX + width
      end
    end
  end,
}

function MerfinPlus:RefreshReadyCheckPreviewWidgets(forceTheme)
  if self.readyCheckPreviewRefreshPending then
    return
  end
  self.readyCheckPreviewRefreshPending = true

  local function RefreshWidgets()
    MerfinPlus.readyCheckPreviewRefreshPending = nil
    for widget in pairs(MerfinPlus.readyCheckPreviewWidgets or {}) do
      if widget.RefreshTheme then widget:RefreshTheme() end
      if forceTheme then widget.layoutSignature = nil end
      if widget.Refresh then widget:Refresh() end
    end
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(0, RefreshWidgets)
  else
    RefreshWidgets()
  end
end

local function Constructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetHeight(525)
  local preview = CreateFrame("Frame", nil, frame, template)
  preview:SetPoint("TOP", frame, "TOP", 0, 0)
  Border(preview, theme.border[1], theme.border[2], theme.border[3], theme.border[4])
  local titleBar = CreateFrame("StatusBar", nil, preview)
  titleBar:SetPoint("TOPLEFT", preview, "TOPLEFT", 2, -2);titleBar:SetHeight(TITLE_HEIGHT)
  titleBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");titleBar:SetMinMaxValues(0, 15);titleBar:SetValue(12)
  titleBar:SetStatusBarColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.52)
  local responses = Font(titleBar, 10, "LEFT");responses:SetPoint("LEFT", titleBar, "LEFT", 6, 0);responses:SetText("Responses: 17/25")
  local title = Font(titleBar, 10);title:SetPoint("CENTER");title:SetText("MP: Ready Check (12 sec.)")
  local header = CreateFrame("Frame", nil, preview);header:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0);header:SetHeight(HEADER_HEIGHT)
  local columns = MerfinPlus.READY_CHECK_COLUMNS or {}
  local headers = {}
  for index = 1, #columns + 2 do local cell=CreateFrame("Frame",nil,header,template);Border(cell);cell.text=Font(cell,8);cell.text:SetAllPoints();headers[index]=cell end
  local rows = {}
  for rowIndex = 1, #NAMES do
    local row=CreateFrame("Frame",nil,preview,template);Border(row)
    row.name=Font(row,9,"LEFT");row.name:SetPoint("LEFT",row,"LEFT",4,0);row.name:SetSize((NAME_WIDTH*MAX_SCALE)-6,ROW_HEIGHT)
    row.status=row:CreateTexture(nil,"ARTWORK");row.status:SetSize(12,12);row.status:SetPoint("CENTER",row,"LEFT",(NAME_WIDTH*MAX_SCALE)+(STATUS_WIDTH*MAX_SCALE/2),0)
    local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS or {})[CLASSES[rowIndex]]
    row.name:SetText(NAMES[rowIndex]);row.name:SetTextColor(color and color.r or 1, color and color.g or 1, color and color.b or 1, 1)
    row.status:SetTexture(STATUS_TEXTURES[((rowIndex - 1) % 3) + 1])
    row.cells={};for columnIndex,column in ipairs(columns) do
      local cell=CreateCell(row);SetPreviewCell(cell,column,rowIndex,columnIndex);cell:Hide();row.cells[columnIndex]=cell
    end
    rows[rowIndex]=row
  end
  local widget={type=WIDGET_TYPE,frame=frame,preview=preview,titleBar=titleBar,responses=responses,title=title,header=header,headers=headers,rows=rows}
  for name,method in pairs(methods) do widget[name]=method end
  widget:RefreshTheme()
  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)
