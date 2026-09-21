local _, MerfinPlus = ...

local dbIcon = LibStub("LibDBIcon-1.0")
local ldb = LibStub("LibDataBroker-1.1")
local iconPath = "Interface\\AddOns\\MerfinPlus\\Media\\options\\merfin_watermark.png"
function MerfinPlus:GetMinimapButtonVisibleSetting()
  return self.db.profile.minimapButton.showIcon ~= false
end

function MerfinPlus:SetMinimapButtonVisibleSetting(value)
  self.db.profile.minimapButton.showIcon = value == true
  self:UpdateMinimapButtonVisibility()
end

function MerfinPlus:UpdateMinimapButtonVisibility()
  local settings = self.db.profile.minimapButton
  settings.hide = not self:GetMinimapButtonVisibleSetting()
  settings.showInCompartment = not settings.hide
  dbIcon:Refresh("MerfinPlus", settings)
  if settings.hide then
    dbIcon:RemoveButtonFromCompartment("MerfinPlus")
  else
    dbIcon:AddButtonToCompartment("MerfinPlus")
  end
end

local function onClick()
  GameTooltip:Hide()
  MerfinPlus:OpenFirstOptionsTab()
end

function MerfinPlus:InitializeMinimapButton()
  local broker = ldb:NewDataObject("MerfinPlus", {
    type = "launcher",
    text = "MerfinPlus",
    icon = iconPath,
    OnClick = onClick,
    OnTooltipShow = function(tooltip)
      tooltip:AddLine("Merfin")
    end,
  })
  local settings = self.db.profile.minimapButton
  settings.hide = not self:GetMinimapButtonVisibleSetting()
  settings.showInCompartment = not settings.hide
  dbIcon:Register("MerfinPlus", broker, settings)
  self:UpdateMinimapButtonVisibility()

  for _, event in ipairs({ "OnProfileChanged", "OnProfileCopied", "OnProfileReset" }) do
    self.db.RegisterCallback(self, event, "UpdateMinimapButtonVisibility")
  end
end
