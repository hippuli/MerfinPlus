local AceGUI = LibStub("AceGUI-3.0")

local NAV_BUTTON_GAP = 2

local function Layout(content, children)
  local height = 0
  local previousFrame

  for _, child in ipairs(children) do
    local frame = child.frame

    frame:ClearAllPoints()
    frame:Show()

    if previousFrame then
      frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -NAV_BUTTON_GAP)
    else
      frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    end

    frame:SetPoint("RIGHT", content, "RIGHT", 0, 0)

    if child.DoLayout then
      child:DoLayout()
    end

    height = height + (frame.height or frame:GetHeight() or 0)

    if previousFrame then
      height = height + NAV_BUTTON_GAP
    end

    previousFrame = frame
  end

  if content.obj and content.obj.LayoutFinished then
    content.obj:LayoutFinished(nil, height)
  end
end

AceGUI:RegisterLayout("MerfinPlusNavList", Layout)
