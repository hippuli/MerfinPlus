local AceGUI = LibStub("AceGUI-3.0")

local WIDGET_TYPE = "MerfinPlusOptionsContent"
local WIDGET_VERSION = 1

local methods = {
  OnAcquire = function(self)
    self:SetWidth(300)
    self:SetHeight(100)
  end,
  LayoutFinished = function(self, width, height)
    if self.noAutoHeight then
      return
    end

    self:SetHeight(height or 0)
  end,
  OnWidthSet = function(self, width)
    self.content:SetWidth(width)
    self.content.width = width
  end,
  OnHeightSet = function(self, height)
    self.content:SetHeight(height)
    self.content.height = height
  end,
}

local function Constructor()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")

  local content = CreateFrame("Frame", nil, frame)
  content:SetPoint("TOPLEFT")
  content:SetPoint("BOTTOMRIGHT")

  local widget = {
    type = WIDGET_TYPE,
    frame = frame,
    content = content,
  }

  for method, func in pairs(methods) do
    widget[method] = func
  end

  return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(WIDGET_TYPE, Constructor, WIDGET_VERSION)
