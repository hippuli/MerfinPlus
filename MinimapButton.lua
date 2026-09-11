local _, MerfinPlus = ...

local dbIcon = LibStub("LibDBIcon-1.0")
local ldb = LibStub("LibDataBroker-1.1")
local iconPath = "Interface\\AddOns\\MerfinPlus\\Media\\options\\merfin_watermark.png"
local isAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local icon = "|T" .. iconPath .. ":18:18:0:0|t "
local uiLabel = icon .. "|cff40c7ebMerfinUI|r"

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

local function openMerfinPlus()
  MerfinPlus:ToggleStandalone()
end

local function openMerfinUI()
  local engine = _G.ElvUI and _G.ElvUI[1]
  if engine then
    engine:ToggleOptions()
    engine.Libs.AceConfigDialog:SelectGroup("ElvUI", "MUI")
  end
end

local function onClick(button)
  GameTooltip:Hide()
  if not isAddOnLoaded("MerfinUI") then
    openMerfinPlus()
    return
  end

  if MenuUtil and MenuUtil.CreateContextMenu then
    MenuUtil.CreateContextMenu(button, function(_, rootDescription)
      rootDescription:CreateButton(
        icon .. "|cffffffffMerfin|r" .. MerfinPlus:ColorizeUIThemeText("Plus", "accent"),
        openMerfinPlus
      )
      rootDescription:CreateButton(uiLabel, openMerfinUI)
    end)
  else
    -- Classic clients without the modern Blizzard menu API.
    if not MerfinPlus.minimapMenu then
      local menu = CreateFrame("Frame", "MerfinPlusMinimapMenu", UIParent, "UIDropDownMenuTemplate")
      UIDropDownMenu_Initialize(menu, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true
        info.text, info.func =
          icon .. "|cffffffffMerfin|r" .. MerfinPlus:ColorizeUIThemeText("Plus", "accent"), openMerfinPlus
        UIDropDownMenu_AddButton(info, level)
        info.text, info.func = uiLabel, openMerfinUI
        UIDropDownMenu_AddButton(info, level)
      end, "MENU")
      MerfinPlus.minimapMenu = menu
    end
    ToggleDropDownMenu(1, nil, MerfinPlus.minimapMenu, button, 0, 0)
  end
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
