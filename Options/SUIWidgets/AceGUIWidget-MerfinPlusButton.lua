--[[-----------------------------------------------------------------------------
Button Widget
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "MerfinPlusButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame, ...)
	AceGUI:ClearFocus()
	PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
	frame.obj:Fire("OnClick", ...)
end

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self:SetHeight(24)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetAutoWidth(false)
		self:SetText()
	end,

	-- ["OnRelease"] = nil,

	["SetText"] = function(self, text)
		self.text:SetText(text)
		if self.autoWidth then
			self:SetWidth(self.text:GetStringWidth() + 30)
		end
	end,

	["SetAutoWidth"] = function(self, autoWidth)
		self.autoWidth = autoWidth
		if self.autoWidth then
			self:SetWidth(self.text:GetStringWidth() + 30)
		end
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
		else
			self.frame:Enable()
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local buttonFont = CreateFont("MerfinPlusOptionsButtonFont")
buttonFont:SetFont("Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf", 13, "")

local function Constructor()
	local name = "MerfinPlusButton" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  frame:SetFontString(frame:CreateFontString(nil, "OVERLAY"))
  frame:SetNormalFontObject(buttonFont)
  frame:SetHighlightFontObject(buttonFont)
  frame:SetDisabledFontObject(buttonFont)
  frame:SetText("")
  frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
  local function RefreshStyle()
    local theme = MerfinPlus.UITheme
    frame:SetBackdropColor(unpack(theme.canvas))
    local color = frame:IsMouseOver() and theme.accent or theme.borderSoft
    frame:SetBackdropBorderColor(color[1], color[2], color[3], 0.6)
    local textColor = frame:IsEnabled() and theme.text or theme.muted
    frame:GetFontString():SetTextColor(unpack(textColor))
  end
  frame:HookScript("OnShow", RefreshStyle)
  frame:HookScript("OnEnable", RefreshStyle)
  frame:HookScript("OnDisable", RefreshStyle)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnClick", Button_OnClick)
	frame:SetScript("OnEnter", function(button) RefreshStyle(); Control_OnEnter(button) end)
	frame:SetScript("OnLeave", function(button) RefreshStyle(); Control_OnLeave(button) end)

	local text = frame:GetFontString()
	text:ClearAllPoints()
	text:SetPoint("TOPLEFT", 15, -1)
	text:SetPoint("BOTTOMRIGHT", -15, 1)
	text:SetJustifyV("MIDDLE")

	local widget = {
		text  = text,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
