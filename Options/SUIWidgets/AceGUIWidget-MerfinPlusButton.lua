--[[-----------------------------------------------------------------------------
Button Widget
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "MerfinPlusButton", 2
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
		self:SetHeight(30)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetAutoWidth(false)
		self:SetText()
		self.pressed = nil
		self.hovered = nil
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
buttonFont:SetFont("Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf", 14, "")

local function Constructor()
	local name = "MerfinPlusButton" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  frame:SetFontString(frame:CreateFontString(nil, "OVERLAY"))
  frame:SetNormalFontObject(buttonFont)
  frame:SetHighlightFontObject(buttonFont)
  frame:SetDisabledFontObject(buttonFont)
  frame:SetText("")
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  local accent = frame:CreateTexture(nil, "ARTWORK")
  accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -1)
  accent:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 1)
  accent:SetWidth(2)
  local function RefreshStyle()
    local theme = MerfinPlus.UITheme
    local widget = frame.obj
    local enabled = frame:IsEnabled()
    local background = widget and widget.pressed and theme.pressed
      or widget and widget.hovered and enabled and theme.hover
      or theme.surface
    local border = widget and (widget.pressed or widget.hovered) and enabled and theme.accentSoft
      or theme.borderSoft
    frame:SetBackdropColor(background[1], background[2], background[3], enabled and 0.94 or 0.50)
    frame:SetBackdropBorderColor(border[1], border[2], border[3], enabled and 0.78 or 0.35)
    accent:SetColorTexture(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    if enabled and widget and (widget.hovered or widget.pressed) then accent:Show() else accent:Hide() end
    local textColor = frame:IsEnabled() and theme.text or theme.muted
    frame:GetFontString():SetTextColor(unpack(textColor))
  end
  frame:HookScript("OnShow", RefreshStyle)
  frame:HookScript("OnEnable", RefreshStyle)
  frame:HookScript("OnDisable", RefreshStyle)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnClick", Button_OnClick)
	frame:SetScript("OnEnter", function(button)
		button.obj.hovered = true
		RefreshStyle()
		Control_OnEnter(button)
	end)
	frame:SetScript("OnLeave", function(button)
		button.obj.hovered = nil
		button.obj.pressed = nil
		RefreshStyle()
		Control_OnLeave(button)
	end)
	frame:SetScript("OnMouseDown", function(button)
		if button:IsEnabled() then button.obj.pressed = true; RefreshStyle() end
	end)
	frame:SetScript("OnMouseUp", function(button)
		button.obj.pressed = nil
		RefreshStyle()
	end)

	local text = frame:GetFontString()
	text:ClearAllPoints()
	text:SetPoint("TOPLEFT", 15, -1)
	text:SetPoint("BOTTOMRIGHT", -15, 1)
	text:SetJustifyV("MIDDLE")

	local widget = {
		text  = text,
		frame = frame,
		accent = accent,
		type  = Type
	}
	frame.obj = widget
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
