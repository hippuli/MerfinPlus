local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local aceDbOptions = LibStub("AceDBOptions-3.0")
local aceConfigDialog = LibStub("AceConfigDialog-3.0")
local aceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local aceConsole = LibStub("AceConsole-3.0")
local aceGui = LibStub("AceGUI-3.0")
local locale = MerfinPlus.L

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local standaloneOptionsName = "MerfinPlus_Standalone"
local theme = MerfinPlus.UITheme

-- Standalone options window: central size and layout controls.
-- Change these values instead of scattering offsets through the frame creation code.
local defaultFrameWidth = 1040
local defaultFrameHeight = 700
local logoBadgeSize = 58          -- Header logo width and height.
local containerBorderOverlap = 5  -- Compensates transparent pixels in UI-Tooltip-Border.
local contentLeft = 244           -- Left edge of the AceConfig page area.
local navDividerX = contentLeft   -- Keep navigation flush with the AceConfig page area.
local navLeftInset = 4            -- Align nav buttons with the backdrop's visible inner edge.
local navFlareOverflow = 10       -- Exact right overhang of nav_button_flare.png.
local contentTop = 76             -- Header height and main content starting area.
local navItemHeight = 48          -- Height of one main navigation entry.
local navFooterHeight = 126       -- Minimap toggle, theme selector and language selector.

local standaloneBackdropPath = "Interface\\AddOns\\MerfinPlus\\Media\\options\\merfinplus_backdrop.png"
local standaloneBackdropAspect = 16 / 9
local classHeaderAspect = 16
local languageFlagPaths = {
  enUS = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_enUS.tga",
  deDE = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_deDE.tga",
  frFR = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_frFR.tga",
  esES = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_esES.tga",
  esMX = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_esMX.tga",
  ptBR = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_ptBR.tga",
  itIT = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_itIT.tga",
  ruRU = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_ruRU.tga",
  zhCN = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_zhCN.tga",
  zhTW = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_zhTW.tga",
  koKR = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_koKR.tga",
  jaJP = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\flags\\flag_jaJP.tga",
}

local classIconRoot = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\icons\\Classes\\"
local themeClassIcons = {
  deathknight = { texture = classIconRoot .. "DEATHKNIGHT.tga" },
  demonhunter = { texture = classIconRoot .. "DEMONHUNTER.tga" },
  druid = { texture = classIconRoot .. "DRUID.tga" },
  hunter = { texture = classIconRoot .. "HUNTER.tga" },
  mage = { texture = classIconRoot .. "MAGE.tga" },
  monk = { texture = classIconRoot .. "MONK.tga" },
  paladin = { texture = classIconRoot .. "PALADIN.tga" },
  priest = { texture = classIconRoot .. "PRIEST.tga" },
  rogue = { texture = classIconRoot .. "ROGUE.tga" },
  shaman = { texture = classIconRoot .. "SHAMAN.tga" },
  warlock = { texture = classIconRoot .. "WARLOCK.tga" },
  warrior = { texture = classIconRoot .. "WARRIOR.tga" },
}

local optionPanelBackdrop = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 16,
  insets = { left = 3.5, right = 3.5, top = 3.5, bottom = 1 },
}

local optionPanelBackdrop2 = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local function CreateSolidTexture(parent, layer, r, g, b, a)
  local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
  if texture.SetColorTexture then
    texture:SetColorTexture(r, g, b, a)
  else
    texture:SetTexture(r, g, b, a)
  end
  return texture
end

local function ThemeColorEscape(color)
  local red = math.floor(((color and color[1]) or 1) * 255 + 0.5)
  local green = math.floor(((color and color[2]) or 1) * 255 + 0.5)
  local blue = math.floor(((color and color[3]) or 1) * 255 + 0.5)
  return string.format("|cff%02x%02x%02x", red, green, blue)
end

local function UpdateStandaloneBackdropCrop(texture, width, height)
  width = tonumber(width) or defaultFrameWidth
  height = tonumber(height) or defaultFrameHeight
  if width <= 0 or height <= 0 then return end

  local targetAspect = width / height
  if targetAspect < standaloneBackdropAspect then
    local visibleWidth = targetAspect / standaloneBackdropAspect
    local inset = (1 - visibleWidth) * 0.5
    texture:SetTexCoord(inset, 1 - inset, 0, 1)
  else
    local visibleHeight = standaloneBackdropAspect / targetAspect
    local inset = (1 - visibleHeight) * 0.5
    texture:SetTexCoord(0, 1, inset, 1 - inset)
  end
end

-- Class artwork is deliberately right-weighted. Crop only the empty left side
-- when the header is narrower so the character remains visible at every size.
local function UpdateClassHeaderCrop(texture, width, height)
  width = tonumber(width) or defaultFrameWidth
  height = tonumber(height) or contentTop
  if width <= 0 or height <= 0 then return end

  local targetAspect = width / height
  if targetAspect < classHeaderAspect then
    local visibleWidth = targetAspect / classHeaderAspect
    texture:SetTexCoord(1 - visibleWidth, 1, 0, 1)
  else
    local visibleHeight = classHeaderAspect / targetAspect
    local inset = (1 - visibleHeight) * 0.5
    texture:SetTexCoord(0, 1, inset, 1 - inset)
  end
end

local function CreateStandaloneFrameLayout(frame)
  -- One cover-cropped image spans header, navigation and content. Panel fills
  -- stay translucent so text remains readable without hiding the artwork.
  local backdropTexture = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
  backdropTexture:SetTexture(standaloneBackdropPath)
  backdropTexture:SetAllPoints(frame)
  backdropTexture:SetVertexColor(0.82, 0.78, 0.94, 1)
  backdropTexture:SetAlpha(theme.backdropAlpha or 0)
  UpdateStandaloneBackdropCrop(backdropTexture, frame:GetWidth(), frame:GetHeight())
  frame.BackdropTexture = backdropTexture
  frame:HookScript("OnSizeChanged", function(_, width, height)
    UpdateStandaloneBackdropCrop(backdropTexture, width, height)
  end)

  -- HEADER PANEL
  local headerContainer = CreateFrame("Frame", nil, frame, BackdropTemplate)
  headerContainer:SetPoint("TOPLEFT", frame, "TOPLEFT")
  headerContainer:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
  headerContainer:SetHeight(76)
  headerContainer:SetFrameLevel(frame:GetFrameLevel() + 1)
  headerContainer:SetBackdrop(optionPanelBackdrop)
  headerContainer:SetBackdropColor(unpack(theme.shell))
  headerContainer:SetBackdropBorderColor(unpack(theme.border))
  frame.HeaderContainer = headerContainer

  local classHeaderTexture = headerContainer:CreateTexture(nil, "BACKGROUND", nil, 2)
  classHeaderTexture:SetAllPoints(headerContainer)
  if type(theme.headerAsset) == "string" and theme.headerAsset ~= "" then
    classHeaderTexture:SetTexture(theme.headerAsset)
    classHeaderTexture:SetAlpha(theme.headerTextureAlpha or 0.44)
    classHeaderTexture:Show()
  else
    classHeaderTexture:SetAlpha(0)
    classHeaderTexture:Hide()
  end
  UpdateClassHeaderCrop(classHeaderTexture, headerContainer:GetWidth(), headerContainer:GetHeight())
  headerContainer:HookScript("OnSizeChanged", function(_, width, height)
    UpdateClassHeaderCrop(classHeaderTexture, width, height)
  end)
  frame.ClassHeaderTexture = classHeaderTexture

  local function StartHeaderMove(_, button)
    if button == "LeftButton" then
      frame:StartMoving()
    end
  end
  local function StopHeaderMove(_, button)
    if button == "LeftButton" then
      frame:StopMovingOrSizing()
    end
  end

  headerContainer:EnableMouse(true)
  headerContainer:SetScript("OnMouseDown", StartHeaderMove)
  headerContainer:SetScript("OnMouseUp", StopHeaderMove)
  frame.StartHeaderMove = StartHeaderMove
  frame.StopHeaderMove = StopHeaderMove

  -- MAIN PANEL
  local contentContainer = CreateFrame("Frame", nil, frame, BackdropTemplate)
  contentContainer:SetPoint(
    "TOPLEFT",
    frame,
    "TOPLEFT",
    0,
    -(contentTop - containerBorderOverlap)
  )
  contentContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
  contentContainer:SetBackdrop(optionPanelBackdrop)
  contentContainer:SetBackdropColor(unpack(theme.canvas))
  contentContainer:SetBackdropBorderColor(unpack(theme.border))
  frame.ContentContainer = contentContainer

  -- Header title host. Language lives in the navigation footer, so the title
  -- can use the full header width up to the close button.
  frame.TitleContainer = CreateFrame("Frame", nil, frame)
  frame.TitleContainer:SetPoint("LEFT", headerContainer, "LEFT", 88, 0)
  frame.TitleContainer:SetPoint("RIGHT", headerContainer, "RIGHT", -72, 0)
  frame.TitleContainer:SetHeight(28)
  frame.TitleContainer:SetFrameLevel(headerContainer:GetFrameLevel() + 2)
  frame.TitleContainer:EnableMouse(true)
  frame.TitleContainer:SetScript("OnMouseDown", StartHeaderMove)
  frame.TitleContainer:SetScript("OnMouseUp", StopHeaderMove)

  local titleText = frame.TitleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  MerfinPlus:ApplyLocalizedFont(
    titleText,
    "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Bold.otf",
    21,
    "OUTLINE|SLUG"
  )
  titleText:SetPoint("LEFT", frame.TitleContainer, "LEFT", 0, 0)
  titleText:SetJustifyH("LEFT")
  titleText:SetText("Merfin " .. ThemeColorEscape(theme.accent) .. "Plus|r")
  titleText:SetTextColor(1, 1, 1, 1)
  titleText:SetShadowColor(0, 0, 0, 0.9)
  titleText:SetShadowOffset(0, 0)
  frame.TitleText = titleText

  local versionText = frame.TitleContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  MerfinPlus:ApplyLocalizedFont(
    versionText,
    "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf",
    14,
    "OUTLINE|SLUG"
  )
  versionText:SetPoint("LEFT", titleText, "RIGHT", 10, 0)
  versionText:SetText("v" .. (GetAddOnMetadata("MerfinPlus", "Version") or "???"))
  versionText:SetTextColor(theme.muted[1], theme.muted[2], theme.muted[3], 1)
  frame.VersionText = versionText

  -- LEFT NAVIGATION HOST
  -- Contains the main section buttons and a separate footer at the bottom.
  frame.NavContainer = CreateFrame("Frame", nil, frame)
  frame.NavContainer:SetFrameLevel(frame:GetFrameLevel() + 5)
  frame.NavContainer:SetPoint("TOPLEFT", contentContainer, "TOPLEFT", navLeftInset, -10)
  frame.NavContainer:SetPoint("BOTTOMLEFT", contentContainer, "BOTTOMLEFT", navLeftInset, 10)
  frame.NavContainer:SetWidth(navDividerX - navLeftInset)

  frame.NavFooter = CreateFrame("Frame", nil, frame.NavContainer)
  frame.NavFooter:SetPoint("BOTTOMLEFT", frame.NavContainer, "BOTTOMLEFT", 0, 0)
  frame.NavFooter:SetPoint("BOTTOMRIGHT", frame.NavContainer, "BOTTOMRIGHT", -navFlareOverflow, 0)
  frame.NavFooter:SetHeight(navFooterHeight)
  frame.NavFooter:SetFrameLevel(frame.NavContainer:GetFrameLevel() + 2)

  -- RIGHT PAGE HOST
  -- AceConfig renders the currently selected options page inside this frame.
  frame.ContentContentContainer = CreateFrame("Frame", nil, frame)
  frame.ContentContentContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", contentLeft, -(contentTop + 16))
  frame.ContentContentContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 24)

  -- AceGUI navigation group using the custom vertical navigation layout.
  frame.NavGroup = aceGui:Create("SimpleGroup")
  frame.NavGroup.frame:SetParent(frame.NavContainer)
  frame.NavGroup.frame:SetPoint("TOPLEFT", frame.NavContainer, "TOPLEFT", 0, 0)
  frame.NavGroup.frame:SetPoint(
    "BOTTOMRIGHT",
    frame.NavContainer,
    "BOTTOMRIGHT",
    -navFlareOverflow,
    navFooterHeight
  )
  frame.NavGroup:SetLayout("MerfinPlusNavList")
  frame.NavGroup:SetFullWidth(true)
  frame.NavGroup:SetFullHeight(true)

  -- AceGUI content container filled by AceConfigDialog.
  frame.AceContainer = aceGui:Create("MerfinPlusOptionsContent")
  frame.AceContainer.frame:SetParent(frame.ContentContentContainer)
  frame.AceContainer.frame:SetAllPoints(frame.ContentContentContainer)
  frame.AceContainer:SetLayout("Fill")
  frame.AceContainer:SetFullWidth(true)
  frame.AceContainer:SetFullHeight(true)

  -- Keep AceGUI's cached dimensions synchronized when the root window resizes.
  frame.ContentContentContainer:SetScript("OnSizeChanged", function(self, width, height)
    frame.AceContainer.frame:SetSize(width, height)
    frame.AceContainer:SetWidth(width)
    frame.AceContainer:SetHeight(height)
  end)

  frame.NavContainer:SetScript("OnSizeChanged", function(self, width, height)
    local navHeight = math.max(1, height - navFooterHeight)
    frame.NavGroup.frame:SetSize(width - navFlareOverflow, navHeight)
    frame.NavGroup:SetWidth(width - navFlareOverflow)
    frame.NavGroup:SetHeight(navHeight)
  end)

  return frame
end

-- Restarts the product-logo orbit. The border turns counter-clockwise during
-- the first 18% of each ten-second cycle, matching merfin.app; the watermark
-- itself remains still and readable.
local function PlayLogoSpin(frame)
  frame.LogoOrbitElapsed = 0
end

-- Creates the draggable circular logo badge on the left side of the header.
local function CreateLogoBadge(frame)
  local badge = CreateFrame("Frame", nil, frame.HeaderContainer)
  badge:SetPoint("LEFT", frame.HeaderContainer, "LEFT", 16, 0)
  badge:SetSize(logoBadgeSize, logoBadgeSize)
  badge:EnableMouse(true)
  badge:SetScript("OnMouseDown", frame.StartHeaderMove)
  badge:SetScript("OnMouseUp", frame.StopHeaderMove)

  local logo = badge:CreateTexture(nil, "OVERLAY", nil, 7)
  logo:SetTexture("Interface\\AddOns\\MerfinPlus\\Media\\options\\merfin_watermark.png")
  logo:SetVertexColor(1, 1, 1, 1)
  logo:SetAlpha(1)
  logo:SetTexCoord(0, 1, 0, 1)
  logo:SetPoint("CENTER", badge, "CENTER", 0, 0)
  logo:SetSize(logoBadgeSize * 0.79, logoBadgeSize * 0.79)

  local borderGlow = badge:CreateTexture(nil, "ARTWORK", nil, 4)
  borderGlow:SetTexture("Interface\\AddOns\\MerfinPlus\\Media\\icons\\header_logo_border.tga")
  if borderGlow.SetDesaturated then borderGlow:SetDesaturated(true) end
  borderGlow:SetTexCoord(0, 1, 0, 1)
  borderGlow:SetPoint("CENTER", badge, "CENTER", 0, 0)
  borderGlow:SetSize(logoBadgeSize + 8, logoBadgeSize + 8)
  borderGlow:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  borderGlow:SetAlpha(0.14)

  local portraitFrame = badge:CreateTexture(nil, "ARTWORK", nil, 5)
  portraitFrame:SetTexture("Interface\\AddOns\\MerfinPlus\\Media\\icons\\header_logo_border.tga")
  if portraitFrame.SetDesaturated then portraitFrame:SetDesaturated(true) end
  portraitFrame:SetTexCoord(0, 1, 0, 1)
  portraitFrame:SetPoint("CENTER", badge, "CENTER", 0, 0)
  portraitFrame:SetSize(logoBadgeSize, logoBadgeSize)
  portraitFrame:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  portraitFrame:SetAlpha(1)

  frame.Badge = badge
  badge.Logo = logo
  badge.PortraitFrame = portraitFrame
  badge.BorderGlow = borderGlow

  return badge, logo
end

-- Creates the close button at the far-right side of the header.
local function CreateCloseButton(frame)
  local button = CreateFrame("Button", nil, frame.HeaderContainer, BackdropTemplate)
  button:SetPoint("RIGHT", frame.HeaderContainer, "RIGHT", -15, 0)
  button:SetSize(30, 30)
  button:SetBackdrop(optionPanelBackdrop2)
  button:SetBackdropColor(theme.surface[1], theme.surface[2], theme.surface[3], 0.88)
  button:SetBackdropBorderColor(unpack(theme.border))

  button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  button.Text:SetAllPoints(button)
  button.Text:SetJustifyH("CENTER")
  button.Text:SetJustifyV("MIDDLE")
  button.Text:SetText("X")
  button.Text:SetTextColor(1, 1, 1, 1)
  button.Text:SetShadowColor(0, 0, 0, 0)
  button.Text:SetShadowOffset(0, 0)

  local hoverFillVertical = CreateSolidTexture(button, "BACKGROUND", 0.55, 0.02, 0.02, 0.95)
  hoverFillVertical:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -3)
  hoverFillVertical:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 3)
  hoverFillVertical:Hide()

  local hoverFillHorizontal = CreateSolidTexture(button, "BACKGROUND", 0.55, 0.02, 0.02, 0.95)
  hoverFillHorizontal:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -1)
  hoverFillHorizontal:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 1)
  hoverFillHorizontal:Hide()

  button:SetScript("OnEnter", function(self)
    hoverFillVertical:Show()
    hoverFillHorizontal:Show()
    self.Text:SetTextColor(1, 1, 1, 1)
  end)
  button:SetScript("OnLeave", function(self)
    hoverFillVertical:Hide()
    hoverFillHorizontal:Hide()
    self.Text:SetTextColor(1, 1, 1, 1)
  end)
  button:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame.CloseButton = button
  return button
end

local function CreateResetPromptButton(parent, text, highlighted)
  local button = CreateFrame("Button", nil, parent, BackdropTemplate)
  button:SetSize(190, 36)
  button:SetBackdrop(optionPanelBackdrop2)
  button:SetBackdropBorderColor(theme.accent[1], theme.accent[2], theme.accent[3], highlighted and 1 or 0.72)
  button:SetBackdropColor(
    highlighted and theme.selected[1] or theme.surface[1],
    highlighted and theme.selected[2] or theme.surface[2],
    highlighted and theme.selected[3] or theme.surface[3],
    0.98
  )

  button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  button.Text:SetPoint("CENTER", 0, 0)
  button.Text:SetText(text)
  button.Text:SetTextColor(
    highlighted and theme.accentBright[1] or theme.text[1],
    highlighted and theme.accentBright[2] or theme.text[2],
    highlighted and theme.accentBright[3] or theme.text[3],
    1
  )

  button:SetScript("OnEnter", function(self)
    self:SetBackdropColor(theme.hover[1], theme.hover[2], theme.hover[3], 0.98)
    self.Text:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
  end)
  button:SetScript("OnLeave", function(self)
    self:SetBackdropColor(
      highlighted and theme.selected[1] or theme.surface[1],
      highlighted and theme.selected[2] or theme.surface[2],
      highlighted and theme.selected[3] or theme.surface[3],
      0.98
    )
    self.Text:SetTextColor(
      highlighted and theme.accentBright[1] or theme.text[1],
      highlighted and theme.accentBright[2] or theme.text[2],
      highlighted and theme.accentBright[3] or theme.text[3],
      1
    )
  end)

  return button
end

local RefreshResetPromptTheme

local function GetRaidSettingsResetPrompt()
  if MerfinPlus.raidSettingsResetPrompt then
    return MerfinPlus.raidSettingsResetPrompt
  end

  local frame = CreateFrame("Frame", "MerfinPlusRaidSettingsResetPrompt", UIParent, BackdropTemplate)
  frame:SetSize(560, 300)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(200)
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetBackdrop(optionPanelBackdrop)
  frame:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 1)
  frame:SetBackdropBorderColor(unpack(theme.border))
  frame:Hide()

  local header = CreateFrame("Frame", nil, frame, BackdropTemplate)
  header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  header:SetHeight(52)
  header:SetBackdrop(optionPanelBackdrop2)
  header:SetBackdropColor(theme.shell[1], theme.shell[2], theme.shell[3], 1)
  header:SetBackdropBorderColor(unpack(theme.border))
  header:EnableMouse(true)
  header:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" then frame:StartMoving() end
  end)
  header:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then frame:StopMovingOrSizing() end
  end)

  frame.Title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  frame.Title:SetPoint("LEFT", header, "LEFT", 22, 0)
  frame.Title:SetPoint("RIGHT", header, "RIGHT", -22, 0)
  frame.Title:SetJustifyH("LEFT")
  frame.Title:SetTextColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)

  frame.Message = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.Message:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 26, -22)
  frame.Message:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -26, -22)
  frame.Message:SetJustifyH("LEFT")
  frame.Message:SetJustifyV("TOP")
  frame.Message:SetSpacing(4)
  frame.Message:SetTextColor(0.86, 0.88, 0.9, 1)

  frame.YesButton = CreateResetPromptButton(frame, "", true)
  frame.YesButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 72, 22)
  frame.NoButton = CreateResetPromptButton(frame, "", false)
  frame.NoButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -72, 22)

  frame.YesButton:SetScript("OnClick", function()
    MerfinPlus:ResetRaidSettingsToDefaults()
    MerfinPlus:FinishRaidSettingsResetPrompt(frame.isTestMode)
    frame:Hide()
  end)
  frame.NoButton:SetScript("OnClick", function()
    MerfinPlus:FinishRaidSettingsResetPrompt(frame.isTestMode)
    frame:Hide()
  end)

  MerfinPlus.raidSettingsResetPrompt = frame
  return frame
end

function MerfinPlus:ResetRaidSettingsToDefaults()
  local profiles = self.db and self.db.sv and self.db.sv.profiles
  if type(profiles) == "table" then
    for _, profile in pairs(profiles) do
      if type(profile) == "table" then
        rawset(profile, "raidCooldowns", nil)
        rawset(profile, "raidAutoMarker", nil)
      end
    end
  end
  if self.db and type(self.db.profile) == "table" then
    rawset(self.db.profile, "raidCooldowns", nil)
    rawset(self.db.profile, "raidAutoMarker", nil)
  end

  if Merfin and Merfin.NotifyRaidCooldownConfigChanged then
    Merfin.NotifyRaidCooldownConfigChanged()
  end
  if Merfin and Merfin.NotifyRaidAutoMarkerConfigChanged then
    Merfin.NotifyRaidAutoMarkerConfigChanged()
  end
  aceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
  aceConfigRegistry:NotifyChange(standaloneOptionsName)
  self.PrettyPrint(self:T("Raid Cooldowns and Auto-Marker settings were reset to factory defaults."))
end

function MerfinPlus:FinishRaidSettingsResetPrompt(isTestMode)
  if not isTestMode and self.db and self.db.global then
    self.db.global.raidSettingsResetPromptVersion = self.raidSettingsResetPromptVersion
  end
end

function MerfinPlus:ShowRaidSettingsResetPrompt(isTestMode)
  local frame = GetRaidSettingsResetPrompt()
  frame.isTestMode = isTestMode == true
  frame.Title:SetText(self:T("Recommended settings update"))
  frame.Message:SetText(self:T("A lot has changed in the latest version of MerfinPlus. Merfin recommends resetting your Raid Cooldowns and Auto-Marker settings to the new factory defaults.\n\nReset these settings now?\n\nOnly Raid Cooldowns and Auto-Marker settings in all MerfinPlus profiles will be affected."))
  frame.YesButton.Text:SetText(self:T("Yes, reset"))
  frame.NoButton.Text:SetText(self:T("No, keep settings"))
  RefreshResetPromptTheme(frame)
  frame:Show()
  frame:Raise()
end

function MerfinPlus:InitializeRaidSettingsResetPrompt(hadSavedVariables)
  if not self.db or not self.db.global then return end

  local promptVersion = tonumber(self.raidSettingsResetPromptVersion) or 1
  if not hadSavedVariables then
    self.db.global.raidSettingsResetPromptVersion = promptVersion
    return
  end

  if (tonumber(self.db.global.raidSettingsResetPromptVersion) or 0) >= promptVersion then
    return
  end

  local function ShowPrompt()
    if MerfinPlus and MerfinPlus.ShowRaidSettingsResetPrompt then
      MerfinPlus:ShowRaidSettingsResetPrompt(false)
    end
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(1.5, ShowPrompt)
  else
    ShowPrompt()
  end
end

local function RefreshFooterMinimapOption(frame)
  local button = frame and frame.MinimapIconOption
  if not button then return end
  button:SetChecked(MerfinPlus:GetMinimapButtonVisibleSetting())
  button.Label:SetText(MerfinPlus:T("Show Minimap Icon"))
  local row = frame.MinimapIconRow
  if row then
    local label = button.Label
    label:SetWidth(0)
    local textWidth
    if label.GetUnboundedStringWidth then
      textWidth = label:GetUnboundedStringWidth()
    else
      textWidth = label:GetStringWidth()
    end
    local rowWidth = row:GetWidth()
    if not rowWidth or rowWidth <= 0 then rowWidth = 189 end
    label:SetWidth(math.min(math.ceil(textWidth or 0) + 1, math.max(1, rowWidth - button:GetWidth() - 2)))
    button:ClearAllPoints()
    button:SetPoint("LEFT", row, "CENTER", -(button:GetWidth() + 2 + label:GetWidth()) * 0.5, 0)
  end
end

local function ApplyNativeCheckTheme(button)
  if not button then return end
  local textures = {
    button:GetNormalTexture(),
    button:GetCheckedTexture(),
    button:GetHighlightTexture(),
  }
  if theme.current == "origin" then
    for _, texture in ipairs(textures) do
      if texture.SetDesaturated then texture:SetDesaturated(false) end
      texture:SetVertexColor(1, 1, 1, 1)
    end
    return
  end
  for index, texture in ipairs(textures) do
    if texture.SetDesaturated then texture:SetDesaturated(true) end
    local color = index == 1 and theme.muted or theme.accentBright
    texture:SetVertexColor(color[1], color[2], color[3], index == 3 and 0.85 or 1)
  end
end

local function RefreshFooterThemeOption(frame)
  local dropdown = frame and frame.ThemeDropdown
  if not dropdown then return end
  dropdown:SetList(MerfinPlus:GetUIThemeChoices(), MerfinPlus:GetUIThemeOrder())
  local themeKey = MerfinPlus:GetUIThemeKey()
  dropdown:SetValue(themeKey)
  local icon = frame.ThemeClassIcon
  local iconData = themeClassIcons[themeKey]
  dropdown.frame:ClearAllPoints()
  if icon and iconData then
    icon:SetTexture(iconData.texture)
    if iconData.coords then
      icon:SetTexCoord(unpack(iconData.coords))
    else
      icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
    icon:Show()
  else
    if icon then icon:Hide() end
  end
  -- Keep the field geometry identical to the language selector. The class
  -- icon occupies the permanently reserved space instead of resizing it.
  dropdown.frame:SetPoint("BOTTOMLEFT", frame.NavFooter, "BOTTOMLEFT", 43, 42)
  dropdown.frame:SetPoint("BOTTOMRIGHT", frame.NavFooter, "BOTTOMRIGHT", -12, 42)
  if dropdown.RefreshTheme then dropdown:RefreshTheme() end
  ApplyNativeCheckTheme(frame.MinimapIconOption)
end

-- Creates the persistent minimap-icon checkbox at the bottom of the navigation.
local function CreateFooterMinimapOption(frame)
  local row = CreateFrame("Frame", nil, frame.NavFooter)
  row:SetPoint("BOTTOMLEFT", frame.NavFooter, "BOTTOMLEFT", 43, 80)
  row:SetPoint("BOTTOMRIGHT", frame.NavFooter, "BOTTOMRIGHT", -12, 80)
  row:SetHeight(24)
  frame.MinimapIconRow = row

  local button = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  button:SetSize(24, 24)
  button:SetPoint("LEFT", row, "LEFT", 0, 0)
  button:SetFrameLevel(frame.NavFooter:GetFrameLevel() + 2)

  local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  MerfinPlus:ApplyLocalizedFont(
    label,
    "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf",
    13,
    "OUTLINE"
  )
  label:SetPoint("LEFT", button, "RIGHT", 2, 0)
  if label.SetWordWrap then label:SetWordWrap(false) end
  if label.SetNonSpaceWrap then label:SetNonSpaceWrap(false) end
  label:SetJustifyH("LEFT")
  label:SetTextColor(1, 1, 1, 1)
  button.Label = label

  button:SetScript("OnClick", function(self)
    MerfinPlus:SetMinimapButtonVisibleSetting(self:GetChecked() == true)
    RefreshFooterMinimapOption(frame)
  end)

  frame.MinimapIconOption = button
  RefreshFooterMinimapOption(frame)
  ApplyNativeCheckTheme(button)
  frame:HookScript("OnShow", function()
    RefreshFooterMinimapOption(frame)
    RefreshFooterThemeOption(frame)
  end)
end

local function CreateFooterThemeOption(frame)
  if not aceGui:GetWidgetVersion("MerfinPlusDropdown") then return end
  local dropdown = aceGui:Create("MerfinPlusDropdown")
  dropdown.frame:SetParent(frame.NavFooter)
  dropdown.frame:ClearAllPoints()
  dropdown.frame:SetPoint("BOTTOMLEFT", frame.NavFooter, "BOTTOMLEFT", 43, 42)
  dropdown.frame:SetPoint("BOTTOMRIGHT", frame.NavFooter, "BOTTOMRIGHT", -12, 42)
  dropdown:SetWidth(172)
  dropdown.matchLanguageFieldFont = true
  dropdown:SetLabel("")
  dropdown:SetCallback("OnValueChanged", function(_, _, value)
    MerfinPlus:SetUITheme(value)
  end)
  local icon = frame.NavFooter:CreateTexture(nil, "OVERLAY", nil, 7)
  icon:SetSize(26, 26)
  icon:SetPoint("CENTER", frame.NavFooter, "BOTTOMLEFT", 26, 56)
  icon:Hide()
  frame.ThemeClassIcon = icon
  frame.ThemeDropdown = dropdown
  RefreshFooterThemeOption(frame)
end

-- Updates the language icon shown next to the dropdown. Flags use a wide
-- texture, while the neutral English globe must remain square.
local function UpdateLanguageFlag(frame, localeCode)
  if not frame or not frame.LanguageFlag then
    return
  end
  frame.LanguageFlag:SetSize(localeCode == "enUS" and 22 or 30, 22)
  frame.LanguageFlag:SetTexture(languageFlagPaths[localeCode] or languageFlagPaths.enUS)
  frame.LanguageFlag:SetTexCoord(0, 1, 0, 1)
end

local function RefreshLanguageDropdown(frame)
  local dropdown = frame and frame.LanguageDropdown
  if not dropdown then return end
  local localeCode = MerfinPlus:ApplyUILocaleSelectionToDropdown(dropdown)
  UpdateLanguageFlag(frame, localeCode)
  RefreshFooterMinimapOption(frame)
end

-- Creates the runtime UI-language selector at the bottom of the navigation.
local function CreateLanguageDropdown(frame)
  if not aceGui:GetWidgetVersion("MerfinPlusDropdown") then
    return
  end

  local dropdown = aceGui:Create("MerfinPlusDropdown")
  dropdown.frame:SetParent(frame.NavFooter)
  dropdown.frame:ClearAllPoints()
  dropdown.frame:SetPoint("BOTTOMLEFT", frame.NavFooter, "BOTTOMLEFT", 43, 4)
  dropdown.frame:SetPoint("BOTTOMRIGHT", frame.NavFooter, "BOTTOMRIGHT", -12, 4)
  dropdown:SetWidth(172)
  dropdown:SetLabel("")
  dropdown:SetCallback("OnValueChanged", function(_, _, value)
    MerfinPlus:SetUILocale(value)
    RefreshLanguageDropdown(frame)
  end)

  local flag = frame.NavFooter:CreateTexture(nil, "OVERLAY", nil, 7)
  flag:SetSize(30, 22)
  flag:SetPoint("RIGHT", dropdown.frame, "LEFT", -3, 0)
  frame.LanguageFlag = flag
  frame.LanguageDropdown = dropdown
  RefreshLanguageDropdown(frame)
  frame:HookScript("OnShow", function()
    RefreshLanguageDropdown(frame)
  end)
end

-- Mirrors the merfin.app brand cadence: a 650 ms initial pause, one quick
-- counter-clockwise orbit, then a calm hold until the ten-second cycle repeats.
local function CreateLogoAnimations(frame, texture, glow)
  frame.LogoOrbitElapsed = 0
  frame:SetScript("OnUpdate", function(self, elapsed)
    self.LogoOrbitElapsed = (self.LogoOrbitElapsed or 0) + (elapsed or 0)
    local delayed = self.LogoOrbitElapsed - 0.65
    local cycle = delayed > 0 and (delayed % 10) or 0
    local orbitProgress = math.min(1, cycle / 1.8)
    local angle = -2 * math.pi * orbitProgress

    if texture.SetRotation then texture:SetRotation(angle) end
    if glow and glow.SetRotation then glow:SetRotation(angle) end

    local glowProgress
    if cycle <= 1.8 then
      glowProgress = cycle / 1.8
    else
      glowProgress = 1 - ((cycle - 1.8) / 8.2)
    end
    glowProgress = math.max(0, math.min(1, glowProgress))
    texture:SetVertexColor(
      math.min(1, theme.accent[1] + (0.08 * glowProgress)),
      math.min(1, theme.accent[2] + (0.08 * glowProgress)),
      math.min(1, theme.accent[3] + (0.02 * glowProgress)),
      1
    )
    if glow then glow:SetAlpha(0.14 + (0.18 * glowProgress)) end
  end)

  frame:SetScript("OnShow", function(self)
    self.LogoOrbitElapsed = 0
  end)
  frame:SetScript("OnHide", function(self)
    self.LogoOrbitElapsed = 0
    if texture.SetRotation then texture:SetRotation(0) end
    if glow then
      if glow.SetRotation then glow:SetRotation(0) end
      glow:SetAlpha(0.14)
    end
  end)
end

local function CreateStandaloneFrame()
  -- ROOT WINDOW
  local frame = CreateFrame("Frame", "MerfinPlusOptionsFrame", UIParent, BackdropTemplate)
  frame:SetSize(defaultFrameWidth, defaultFrameHeight)
  frame:SetPoint("CENTER")
  frame:SetAlpha(1)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(500)
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetResizable(true)

  if frame.SetResizeBounds then
    frame:SetResizeBounds(760, 520)
  elseif frame.SetMinResize then
    frame:SetMinResize(760, 520)
  end

  CreateStandaloneFrameLayout(frame)

  frame.Logo, frame.LogoTexture = CreateLogoBadge(frame)
  if frame.Logo and frame.Logo.PortraitFrame then
    CreateLogoAnimations(frame.Logo, frame.Logo.PortraitFrame, frame.Logo.BorderGlow)
  end

  CreateCloseButton(frame)
  CreateLanguageDropdown(frame)
  CreateFooterThemeOption(frame)
  CreateFooterMinimapOption(frame)

  -- BOTTOM-RIGHT RESIZE GRIP
  local resizeGrip = CreateFrame("Button", nil, frame)
  resizeGrip:SetSize(20, 20)
  resizeGrip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)
  resizeGrip:SetFrameLevel(frame:GetFrameLevel() + 80)
  resizeGrip:EnableMouse(true)
  resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  resizeGrip:GetNormalTexture():SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.9)
  resizeGrip:GetHighlightTexture():SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  resizeGrip:GetPushedTexture():SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)

  local sizing
  local function StartResize(_, button)
    if button and button ~= "LeftButton" then
      return
    end
    sizing = true
    frame:StartSizing("BOTTOMRIGHT")
  end
  local function StopResize()
    if sizing then
      frame:StopMovingOrSizing()
      sizing = nil
    end
  end

  resizeGrip:SetScript("OnMouseDown", StartResize)
  resizeGrip:SetScript("OnMouseUp", StopResize)
  frame.ResizeGrip = resizeGrip

  frame:SetScript("OnHide", function(self)
    self:StopMovingOrSizing()
    sizing = nil
  end)

  -- Allows Escape to close the standalone window through WoW's standard UI handling.
  tinsert(UISpecialFrames, frame:GetName())
  return frame
end

RefreshResetPromptTheme = function(frame)
  if not frame then return end
  frame:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 1)
  frame:SetBackdropBorderColor(unpack(theme.border))
  local header = frame.Title and frame.Title:GetParent()
  if header and header.SetBackdropColor then
    header:SetBackdropColor(theme.shell[1], theme.shell[2], theme.shell[3], 1)
    header:SetBackdropBorderColor(unpack(theme.border))
  end
  if frame.Title then frame.Title:SetTextColor(unpack(theme.accentBright)) end
  for _, entry in ipairs({
    { frame.YesButton, theme.selected, theme.accentBright, 1 },
    { frame.NoButton, theme.surface, theme.text, 0.72 },
  }) do
    local button, background, textColor, borderAlpha = unpack(entry)
    if button then
      button:SetBackdropColor(unpack(background))
      button:SetBackdropBorderColor(theme.accent[1], theme.accent[2], theme.accent[3], borderAlpha)
      button.Text:SetTextColor(unpack(textColor))
    end
  end
  MerfinPlus:ApplyUIFontSizeDelta(frame)
end

local function RefreshStandaloneFrameTheme(frame)
  if not frame then return end
  if frame.BackdropTexture then frame.BackdropTexture:SetAlpha(theme.backdropAlpha or 0) end
  if frame.ClassHeaderTexture then
    if type(theme.headerAsset) == "string" and theme.headerAsset ~= "" then
      frame.ClassHeaderTexture:SetTexture(theme.headerAsset)
      frame.ClassHeaderTexture:SetVertexColor(1, 1, 1, 1)
      frame.ClassHeaderTexture:SetAlpha(theme.headerTextureAlpha or 0.44)
      UpdateClassHeaderCrop(
        frame.ClassHeaderTexture,
        frame.HeaderContainer and frame.HeaderContainer:GetWidth(),
        frame.HeaderContainer and frame.HeaderContainer:GetHeight()
      )
      frame.ClassHeaderTexture:Show()
    else
      frame.ClassHeaderTexture:SetAlpha(0)
      frame.ClassHeaderTexture:Hide()
    end
  end
  if frame.HeaderContainer then
    frame.HeaderContainer:SetBackdropColor(unpack(theme.shell))
    frame.HeaderContainer:SetBackdropBorderColor(unpack(theme.border))
  end
  if frame.ContentContainer then
    frame.ContentContainer:SetBackdropColor(unpack(theme.canvas))
    frame.ContentContainer:SetBackdropBorderColor(unpack(theme.border))
  end
  if frame.TitleText then
    frame.TitleText:SetText("Merfin " .. ThemeColorEscape(theme.accent) .. "Plus|r")
  end
  if frame.VersionText then frame.VersionText:SetTextColor(unpack(theme.muted)) end
  if frame.Logo then
    if frame.Logo.PortraitFrame then
      frame.Logo.PortraitFrame:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    end
    if frame.Logo.BorderGlow then
      frame.Logo.BorderGlow:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    end
  end
  if frame.CloseButton then
    frame.CloseButton:SetBackdropColor(unpack(theme.surface))
    frame.CloseButton:SetBackdropBorderColor(unpack(theme.border))
  end
  if frame.ResizeGrip then
    frame.ResizeGrip:GetNormalTexture():SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.9)
    frame.ResizeGrip:GetHighlightTexture():SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    frame.ResizeGrip:GetPushedTexture():SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  end
  for _, widget in pairs(frame.NavWidgets or {}) do
    if widget.RefreshTheme then widget:RefreshTheme() end
  end
  if frame.LanguageDropdown and frame.LanguageDropdown.RefreshTheme then
    frame.LanguageDropdown:RefreshTheme()
  end
  RefreshFooterThemeOption(frame)
  RefreshResetPromptTheme(MerfinPlus.raidSettingsResetPrompt)
end

-- Lazily creates one reusable standalone options window for the addon session.
local function GetStandaloneFrame()
  if not MerfinPlus.optionsStandaloneFrame then
    MerfinPlus.optionsStandaloneFrame = CreateStandaloneFrame()
  end

  return MerfinPlus.optionsStandaloneFrame
end

-- The content frame is already fully anchored when the standalone window is
-- first shown, but AceGUI still holds its 300px OnAcquire width until the
-- outer frame is manually resized. Propagate the resolved host size once
-- before AceConfig builds child tab groups; never trigger a layout from a
-- width callback.
local function SyncStandaloneContentSize(frame)
  local host = frame and frame.ContentContentContainer
  local container = frame and frame.AceContainer
  if not host or not container or container.merfinPlusSyncingSize then
    return
  end

  local width = tonumber(host:GetWidth())
  local height = tonumber(host:GetHeight())
  if not width or width <= 0 or not height or height <= 0 then
    return
  end

  width = math.floor(width + 0.5)
  height = math.floor(height + 0.5)
  if
    container.merfinPlusSyncedWidth == width
    and container.merfinPlusSyncedHeight == height
  then
    return
  end

  container.merfinPlusSyncingSize = true
  if container.frame and container.frame.SetSize then
    container.frame:SetSize(width, height)
  end
  container:SetWidth(width)
  container:SetHeight(height)
  container.merfinPlusSyncedWidth = width
  container.merfinPlusSyncedHeight = height
  container.merfinPlusSyncingSize = nil
end

local function SetStandaloneNavigation(frame, optionSections, selectedKey, onSelect)
  if not frame.NavGroup then
    return
  end

  frame.NavGroup:ReleaseChildren()

  frame.NavWidgets = {}

  for _, section in ipairs(optionSections) do
    if section.options then
      local sectionKey = section.key
      local widget = aceGui:Create("MerfinPlusNavButton")
      widget:SetText(section.label)
      widget:SetFullWidth(true)
      widget:SetHeight(navItemHeight)
      widget:SetIcon(section.icon)

      widget:SetCallback("OnClick", function()
        onSelect(sectionKey)
      end)

      frame.NavGroup:AddChild(widget)
      frame.NavWidgets[sectionKey] = widget
      widget:SetSelected(sectionKey == selectedKey)
    end
  end
end

local function ApplyMerfinPlusDropdowns(option)
  if type(option) ~= "table" then
    return
  end
  if option.type == "select" and not option.dialogControl and not option.control then
    option.dialogControl = "MerfinPlusDropdown"
  end
  if type(option.args) == "table" then
    for _, child in pairs(option.args) do
      ApplyMerfinPlusDropdowns(child)
    end
  end
end

-- Remove AceGUI's opaque group inset fills inside the standalone window.
-- Their borders remain visible while our shared panel texture shows through.
local ApplyStandaloneInsetBackdrops

local function ScheduleStandaloneInsetRefresh(root)
  if not root or root.merfinPlusInsetRefreshScheduled then
    return
  end
  root.merfinPlusInsetRefreshScheduled = true

  local refresh = function()
    root.merfinPlusInsetRefreshScheduled = nil
    ApplyStandaloneInsetBackdrops(root, root)
    if root.frame then MerfinPlus:ApplyUIFontSizeDelta(root.frame) end
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(0, refresh)
  else
    refresh()
  end
end

local function GuardStandaloneInsetRoot(root)
  if not root or root.merfinPlusInsetRootGuarded then
    return
  end

  local AddChild = root.AddChild
  root.AddChild = function(self, ...)
    local child = ...
    local result = AddChild(self, ...)
    -- Apply the no-scrollbar skin before returning control to AceConfig. This
    -- keeps the freshly created ScrollFrame from rendering one gold frame.
    if child then ApplyStandaloneInsetBackdrops(child, self) end
    ScheduleStandaloneInsetRefresh(self)
    return result
  end
  root.merfinPlusInsetRootGuarded = true
end

local function MakeStandaloneInsetTransparent(widget, frame, showBorder)
  if not frame or not frame.SetBackdropColor then
    return
  end

  widget.merfinPlusOriginalInsetColors = widget.merfinPlusOriginalInsetColors or {}
  if not widget.merfinPlusOriginalInsetColors[frame] then
    local red, green, blue, alpha = frame:GetBackdropColor()
    widget.merfinPlusOriginalInsetColors[frame] = { red, green, blue, alpha }
  end
  widget.merfinPlusOriginalInsetBorderColors = widget.merfinPlusOriginalInsetBorderColors or {}
  if not widget.merfinPlusOriginalInsetBorderColors[frame] then
    local red, green, blue, alpha = 1, 1, 1, 1
    if frame.GetBackdropBorderColor then
      red, green, blue, alpha = frame:GetBackdropBorderColor()
    end
    widget.merfinPlusOriginalInsetBorderColors[frame] = { red, green, blue, alpha }
  end
  frame:SetBackdropColor(theme.canvas[1], theme.canvas[2], theme.canvas[3], 0)
  frame:SetBackdropBorderColor(
    theme.accent[1],
    theme.accent[2],
    theme.accent[3],
    showBorder == false and 0 or 0.58
  )
end

local function SetStandaloneTextColor(widget, fontString, color)
  if not fontString then return end
  widget.merfinPlusOriginalTextColors = widget.merfinPlusOriginalTextColors or {}
  if not widget.merfinPlusOriginalTextColors[fontString] then
    widget.merfinPlusOriginalTextColors[fontString] = { fontString:GetTextColor() }
  end
  fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local function SetStandaloneVertexColor(widget, texture, color, alpha)
  if not texture then return end
  widget.merfinPlusOriginalVertexColors = widget.merfinPlusOriginalVertexColors or {}
  if not widget.merfinPlusOriginalVertexColors[texture] then
    widget.merfinPlusOriginalVertexColors[texture] = { texture:GetVertexColor() }
  end
  if texture.SetDesaturated then texture:SetDesaturated(true) end
  texture:SetVertexColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function HideStandaloneScrollbar(widget, scrollbar)
  if not scrollbar then return end
  if widget.merfinPlusOriginalScrollbarAlpha == nil then
    widget.merfinPlusOriginalScrollbarAlpha = scrollbar:GetAlpha()
    widget.merfinPlusOriginalScrollbarMouse = scrollbar.IsMouseEnabled and scrollbar:IsMouseEnabled()
  end
  scrollbar:SetAlpha(0)
  scrollbar:EnableMouse(false)
end

local function GuardStandaloneInsetWidget(widget, root)
  widget.merfinPlusInsetRoot = root
  if widget.merfinPlusInsetReleaseGuarded then
    return
  end

  local OnRelease = widget.OnRelease
  widget.merfinPlusOriginalInsetOnRelease = OnRelease
  widget.OnRelease = function(self, ...)
    if MerfinPlus.RestoreUIFontSizeDelta and self.frame then
      MerfinPlus:RestoreUIFontSizeDelta(self.frame)
    end
    for frame, color in pairs(self.merfinPlusOriginalInsetColors or {}) do
      if frame.SetBackdropColor then
        frame:SetBackdropColor(color[1], color[2], color[3], color[4])
      end
    end
    self.merfinPlusOriginalInsetColors = nil
    for frame, color in pairs(self.merfinPlusOriginalInsetBorderColors or {}) do
      if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
      end
    end
    self.merfinPlusOriginalInsetBorderColors = nil
    for fontString, color in pairs(self.merfinPlusOriginalTextColors or {}) do
      fontString:SetTextColor(color[1], color[2], color[3], color[4])
    end
    self.merfinPlusOriginalTextColors = nil
    for texture, color in pairs(self.merfinPlusOriginalVertexColors or {}) do
      if texture.SetDesaturated then texture:SetDesaturated(false) end
      texture:SetVertexColor(color[1], color[2], color[3], color[4])
    end
    self.merfinPlusOriginalVertexColors = nil
    for texture, alpha in pairs(self.merfinPlusOriginalTextureAlphas or {}) do
      texture:SetAlpha(alpha)
    end
    self.merfinPlusOriginalTextureAlphas = nil
    for texture, source in pairs(self.merfinPlusOriginalTabTextureSources or {}) do
      if source then
        texture:SetTexture(source)
      else
        texture:SetTexture(nil)
      end
    end
    self.merfinPlusOriginalTabTextureSources = nil
    for backdrop, alpha in pairs(self.merfinPlusOriginalTabBackdropAlphas or {}) do
      backdrop:SetAlpha(alpha)
    end
    self.merfinPlusOriginalTabBackdropAlphas = nil
    if self.scrollbar and self.merfinPlusOriginalScrollbarAlpha ~= nil then
      self.scrollbar:SetAlpha(self.merfinPlusOriginalScrollbarAlpha)
      self.scrollbar:EnableMouse(self.merfinPlusOriginalScrollbarMouse ~= false)
    end
    self.merfinPlusOriginalScrollbarAlpha = nil
    self.merfinPlusOriginalScrollbarMouse = nil
    for _, tab in ipairs(self.tabs or {}) do
      if tab.merfinPlusThemeBackground then tab.merfinPlusThemeBackground:Hide() end
      if tab.merfinPlusThemeLine then tab.merfinPlusThemeLine:Hide() end
      for _, border in ipairs(tab.merfinPlusThemeBorders or {}) do border:Hide() end
      tab.merfinPlusThemeOwner = nil
      tab.merfinPlusThemeHovered = nil
    end

    if self.merfinPlusOriginalInsetFire then
      self.Fire = self.merfinPlusOriginalInsetFire
      self.merfinPlusOriginalInsetFire = nil
    end
    if self.merfinPlusOriginalInsetAddChild then
      self.AddChild = self.merfinPlusOriginalInsetAddChild
      self.merfinPlusOriginalInsetAddChild = nil
    end

    local release = self.merfinPlusOriginalInsetOnRelease
    self.merfinPlusOriginalInsetOnRelease = nil
    self.merfinPlusInsetReleaseGuarded = nil
    self.merfinPlusInsetRoot = nil
    self.OnRelease = release
    if release then
      return release(self, ...)
    end
  end
  widget.merfinPlusInsetReleaseGuarded = true

  if widget.AddChild and not widget.merfinPlusOriginalInsetAddChild then
    local AddChild = widget.AddChild
    widget.merfinPlusOriginalInsetAddChild = AddChild
    widget.AddChild = function(self, ...)
      local child = ...
      local result = AddChild(self, ...)
      if child then ApplyStandaloneInsetBackdrops(child, root) end
      return result
    end
  end

  if widget.Fire then
    local Fire = widget.Fire
    widget.merfinPlusOriginalInsetFire = Fire
    widget.Fire = function(self, event, ...)
      Fire(self, event, ...)
      if event == "OnGroupSelected" and self.merfinPlusInsetRoot == root then
        ScheduleStandaloneInsetRefresh(root)
      end
    end
  end
end

local function GetStandaloneTabTextures(tab)
  return {
    tab.Left, tab.Middle, tab.Right,
    tab.LeftDisabled, tab.MiddleDisabled, tab.RightDisabled,
    tab.HighlightTexture,
  }
end

local function SuppressStandaloneNativeTab(tab, widget)
  if not tab or tab.merfinPlusThemeOwner ~= widget then return end
  local backdrop = tab.backdrop
  if backdrop and backdrop.SetAlpha then
    widget.merfinPlusOriginalTabBackdropAlphas = widget.merfinPlusOriginalTabBackdropAlphas or {}
    if widget.merfinPlusOriginalTabBackdropAlphas[backdrop] == nil then
      widget.merfinPlusOriginalTabBackdropAlphas[backdrop] = backdrop:GetAlpha()
    end
    -- ElvUI's Ace3 skin recolors this backdrop gold from its SetSelected hook.
    -- Keep it hidden while MerfinPlus draws its own theme-scoped tab surface.
    backdrop:SetAlpha(0)
  end
  for _, texture in ipairs(GetStandaloneTabTextures(tab)) do
    if texture then
      widget.merfinPlusOriginalTextureAlphas = widget.merfinPlusOriginalTextureAlphas or {}
      if widget.merfinPlusOriginalTextureAlphas[texture] == nil then
        widget.merfinPlusOriginalTextureAlphas[texture] = texture:GetAlpha()
      end
      widget.merfinPlusOriginalTabTextureSources = widget.merfinPlusOriginalTabTextureSources or {}
      if widget.merfinPlusOriginalTabTextureSources[texture] == nil then
        widget.merfinPlusOriginalTabTextureSources[texture] = texture:GetTexture() or false
      end
      texture:SetTexture(nil)
      texture:SetAlpha(0)
    end
  end
end

local function RestoreStandaloneNativeTab(tab, widget)
  if not tab or tab.merfinPlusThemeOwner ~= widget then return end
  local backdrop = tab.backdrop
  local backdropAlphas = widget.merfinPlusOriginalTabBackdropAlphas
  if backdrop and backdropAlphas and backdropAlphas[backdrop] ~= nil then
    backdrop:SetAlpha(backdropAlphas[backdrop])
  end
  local sources = widget.merfinPlusOriginalTabTextureSources
  local alphas = widget.merfinPlusOriginalTextureAlphas
  for _, texture in ipairs(GetStandaloneTabTextures(tab)) do
    if texture then
      local source = sources and sources[texture]
      if source ~= nil then
        if source then
          texture:SetTexture(source)
        else
          texture:SetTexture(nil)
        end
      end
      if alphas and alphas[texture] ~= nil then
        texture:SetAlpha(alphas[texture])
      end
    end
  end
end

local function RefreshStandaloneFlatTab(tab)
  if not tab then return end
  if not tab.merfinPlusThemeBackground then
    local background = tab:CreateTexture(nil, "BACKGROUND", nil, -1)
    background:SetPoint("TOPLEFT", tab, "TOPLEFT", 7, -2)
    background:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -7, 2)
    tab.merfinPlusThemeBackground = background

    local top = tab:CreateTexture(nil, "ARTWORK", nil, 6)
    top:SetPoint("TOPLEFT", tab, "TOPLEFT", 7, -2)
    top:SetPoint("TOPRIGHT", tab, "TOPRIGHT", -7, -2)
    top:SetHeight(1)
    local bottom = tab:CreateTexture(nil, "ARTWORK", nil, 6)
    bottom:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 7, 1)
    bottom:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -7, 1)
    bottom:SetHeight(1)
    local left = tab:CreateTexture(nil, "ARTWORK", nil, 6)
    left:SetPoint("TOPLEFT", tab, "TOPLEFT", 7, -2)
    left:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 7, 1)
    left:SetWidth(1)
    local right = tab:CreateTexture(nil, "ARTWORK", nil, 6)
    right:SetPoint("TOPRIGHT", tab, "TOPRIGHT", -7, -2)
    right:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -7, 1)
    right:SetWidth(1)
    tab.merfinPlusThemeLine = bottom
    tab.merfinPlusThemeBorders = { top, bottom, left, right }
  end
  local active = tab.selected == true
  local hovered = tab.merfinPlusThemeHovered == true
  local background = active and theme.selected or (hovered and theme.hover or theme.surface)
  local border = active and theme.accent or (hovered and theme.accentSoft or theme.borderSoft)
  tab.merfinPlusThemeBackground:SetColorTexture(
    background[1],
    background[2],
    background[3],
    active and math.min(background[4] or 0.28, 0.32) or (hovered and 0.18 or 0.70)
  )
  for _, texture in ipairs(tab.merfinPlusThemeBorders or {}) do
    texture:SetColorTexture(border[1], border[2], border[3], active and 0.72 or (hovered and 0.48 or 0.22))
    texture:Show()
  end
  tab.merfinPlusThemeBackground:Show()

  if not tab.merfinPlusThemeHooked then
    tab:HookScript("OnEnter", function(self)
      self.merfinPlusThemeHovered = true
      if theme.modernTabs and self.merfinPlusThemeOwner then RefreshStandaloneFlatTab(self) end
    end)
    tab:HookScript("OnLeave", function(self)
      self.merfinPlusThemeHovered = nil
      if theme.modernTabs and self.merfinPlusThemeOwner then RefreshStandaloneFlatTab(self) end
    end)
    tab:HookScript("OnShow", function(self)
      local owner = self.merfinPlusThemeOwner
      if theme.modernTabs and owner then
        SuppressStandaloneNativeTab(self, owner)
        RefreshStandaloneFlatTab(self)
      end
    end)
    tab.merfinPlusThemeHooked = true
  end

  if not tab.merfinPlusThemeStateHooked then
    local SetSelected = tab.SetSelected
    tab.SetSelected = function(self, ...)
      local result = SetSelected(self, ...)
      local owner = self.merfinPlusThemeOwner
      if theme.modernTabs and owner then
        SuppressStandaloneNativeTab(self, owner)
        RefreshStandaloneFlatTab(self)
      end
      return result
    end
    local SetDisabled = tab.SetDisabled
    tab.SetDisabled = function(self, ...)
      local result = SetDisabled(self, ...)
      local owner = self.merfinPlusThemeOwner
      if theme.modernTabs and owner then
        SuppressStandaloneNativeTab(self, owner)
        RefreshStandaloneFlatTab(self)
      end
      return result
    end
    tab.merfinPlusThemeStateHooked = true
  end
end

local function SkinStandaloneTabs(widget)
  for _, tab in ipairs(widget.tabs or {}) do
    tab.merfinPlusThemeOwner = widget
    local active = tab.selected == true
    local textures = GetStandaloneTabTextures(tab)
    if theme.modernTabs then
      SuppressStandaloneNativeTab(tab, widget)
      RefreshStandaloneFlatTab(tab)
    else
      RestoreStandaloneNativeTab(tab, widget)
      for _, texture in ipairs(textures) do
        if texture then
          if texture.SetDesaturated then texture:SetDesaturated(false) end
          texture:SetVertexColor(1, 1, 1, 1)
          texture:SetAlpha(
            (widget.merfinPlusOriginalTextureAlphas and widget.merfinPlusOriginalTextureAlphas[texture])
              or 1
          )
        end
      end
      if tab.merfinPlusThemeBackground then tab.merfinPlusThemeBackground:Hide() end
      if tab.merfinPlusThemeLine then tab.merfinPlusThemeLine:Hide() end
      for _, border in ipairs(tab.merfinPlusThemeBorders or {}) do border:Hide() end
    end
    local text = tab.Text or tab:GetFontString()
    if text then
      SetStandaloneTextColor(widget, text, theme.text)
    end
  end
end

ApplyStandaloneInsetBackdrops = function(widget, root)
  if not widget then
    return
  end
  root = root or widget
  GuardStandaloneInsetWidget(widget, root)

  if widget.type == "TabGroup" then
    -- Nested TabGroups previously drew one full frame per tab level. Their
    -- tabs keep the themed borders; only the redundant container outlines go.
    MakeStandaloneInsetTransparent(widget, widget.border, false)
    SkinStandaloneTabs(widget)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "Heading" then
    SetStandaloneTextColor(widget, widget.label, theme.accentBright)
    SetStandaloneVertexColor(widget, widget.left, theme.accent, 0.62)
    SetStandaloneVertexColor(widget, widget.right, theme.accent, 0.62)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "CheckBox" or widget.type == "MerfinPlusNpcToggle" then
    SetStandaloneVertexColor(widget, widget.checkbg, theme.muted, 0.90)
    SetStandaloneVertexColor(widget, widget.check, theme.accentBright, 1)
    SetStandaloneVertexColor(widget, widget.highlight, theme.accent, 0.85)
    SetStandaloneTextColor(widget, widget.text, theme.text)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "Slider" then
    SetStandaloneTextColor(widget, widget.label, theme.accentBright)
    SetStandaloneVertexColor(widget, widget.slider and widget.slider:GetThumbTexture(), theme.accent, 1)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "ScrollFrame" then
    HideStandaloneScrollbar(widget, widget.scrollbar)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "Button" then
    SetStandaloneTextColor(widget, widget.text, theme.text)
    local button = widget.frame
    SetStandaloneVertexColor(widget, button and button:GetNormalTexture(), theme.muted, 0.95)
    SetStandaloneVertexColor(widget, button and button:GetHighlightTexture(), theme.accent, 0.80)
    SetStandaloneVertexColor(widget, button and button:GetPushedTexture(), theme.accentBright, 1)
  elseif widget.type == "Label" then
    SetStandaloneTextColor(widget, widget.label, theme.text)
  elseif widget.type == "ColorPicker" then
    SetStandaloneTextColor(widget, widget.text, theme.text)
  elseif widget.type == "EditBox" or widget.type == "MultiLineEditBox" then
    SetStandaloneTextColor(widget, widget.label, theme.accentBright)
  elseif widget.type == "MerfinPlusIconButton" then
    SetStandaloneVertexColor(widget, widget.image, theme.accentBright, 1)
  elseif widget.type == "InlineGroup" then
    SetStandaloneTextColor(widget, widget.titletext, theme.accentBright)
    MakeStandaloneInsetTransparent(widget, widget.content and widget.content:GetParent())
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "TreeGroup" then
    MakeStandaloneInsetTransparent(widget, widget.treeframe)
    MakeStandaloneInsetTransparent(widget, widget.border)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "DropdownGroup" then
    MakeStandaloneInsetTransparent(widget, widget.border)
    SetStandaloneTextColor(widget, widget.titletext, theme.accentBright)
    GuardStandaloneInsetWidget(widget, root)
  end

  for _, child in ipairs(widget.children or {}) do
    ApplyStandaloneInsetBackdrops(child, root)
  end
end

-- Build and register all options (Blizzard panels + standalone window + slash commands)
function MerfinPlus:SetupOptions()
  local version = GetAddOnMetadata("MerfinPlus", "Version") or "???"
  local capabilities = self:GetCapabilities()
  local mediaOptions = capabilities.mediaOptions and self:BuildMediaOptions() or nil
  local raidPack = capabilities.raidPackOptions and self:BuildRaidPackOptions() or nil
  local wowSimOptions = capabilities.wowSimOptions and self:BuildWoWSimOptions() or nil
  local exportOptions = capabilities.export and self:BuildExportOptions() or nil
  local assignmentsOptions = capabilities.assignmentsOptions and self:BuildAssignmentsOptions() or nil
  local raidCooldownOptions = capabilities.raidCooldowns
    and self:BuildRaidCooldownTrackerOptions()
    or nil

  if assignmentsOptions and exportOptions then
    exportOptions.name = self:T("Loot / Roster Export")
    exportOptions.order = 40
    assignmentsOptions.args.rosterExport = exportOptions
  end

  local mainOptions = {
    type = "group",
    name = "MerfinPlus v" .. version,
    args = {
      version = {
        type = "description",
        name = "|cff00ccff" .. locale["Version:"] .. "|r" .. version,
        fontSize = "medium",
        order = 1,
      },
      author = {
        type = "description",
        name = locale["Author: "] .. "Merfin",
        fontSize = "medium",
        order = 2,
      },
      spacer = { type = "description", name = " ", order = 3 },
      description = {
        type = "description",
        name = locale["MerfinPlus provides custom fonts, textures, and utilities that enhance or support WeakAuras and other Merfin UI components."],
        fontSize = "large",
        order = 4,
      },
      spacer2 = { type = "description", name = " ", order = 5 },
    },
  }

  -- ==== Profiles (AceDB) ====
  local profilesOptions = aceDbOptions:GetOptionsTable(self.db)
  if capabilities.localizedProfiles then
    profilesOptions = self:CreateLocalizedProfilesOptions(profilesOptions)
  end
  profilesOptions.name = locale["Profiles"] or "Profiles"
  profilesOptions.order = 1

  local moduleControlOptions = {
    type = "group",
    name = locale["Module Control"] or "Module Control",
    order = 2,
    args = {},
  }

  local function AppendModuleTools(key, options, order)
    if not options then return end
    moduleControlOptions.args[key .. "Header"] = {
      type = "header",
      name = options.name,
      order = order,
    }
    for optionKey, option in pairs(options.args or {}) do
      option.order = order + 1 + ((tonumber(option.order) or 0) / 10)
      moduleControlOptions.args[key .. optionKey] = option
    end
  end

  AppendModuleTools(
    "cooldowns",
    self.BuildRaidCooldownProfileToolsOptions and self:BuildRaidCooldownProfileToolsOptions(),
    1
  )
  AppendModuleTools(
    "autoMarker",
    self.BuildRaidAutoMarkerProfileToolsOptions and self:BuildRaidAutoMarkerProfileToolsOptions(),
    20
  )

  profilesOptions = {
    type = "group",
    name = locale["Profiles"] or "Profiles",
    childGroups = "tab",
    args = {
      profiles = profilesOptions,
      moduleControl = moduleControlOptions,
    },
  }

  if capabilities.uiLocalization then
    self:LocalizeOptionTree(mainOptions)
    self:LocalizeOptionTree(mediaOptions)
    self:LocalizeOptionTree(wowSimOptions)
    self:LocalizeOptionTree(raidPack)
    self:LocalizeOptionTree(profilesOptions)
    self:LocalizeOptionTree(assignmentsOptions)
    self:LocalizeOptionTree(raidCooldownOptions)
  end

  local registeredLocalizationRoots = {
    MerfinPlus = mainOptions,
    MerfinPlus_Media = mediaOptions,
    MerfinPlus_WoWSim = wowSimOptions,
    MerfinPlus_RaidPack = raidPack,
    MerfinPlus_Profiles = profilesOptions,
    MerfinPlus_Assignments = assignmentsOptions,
    MerfinPlus_RaidCooldowns = raidCooldownOptions,
  }
  local localizationSchemaValid, localizationSchemaError = true
  if capabilities.localizationValidation then
    localizationSchemaValid, localizationSchemaError =
      self:ValidateLocalizedOptionsTrees(registeredLocalizationRoots)
    if not localizationSchemaValid then
      error(localizationSchemaError)
    end
  end

  if aceGui:GetWidgetVersion("MerfinPlusDropdown") then
    ApplyMerfinPlusDropdowns(mainOptions)
    ApplyMerfinPlusDropdowns(mediaOptions)
    ApplyMerfinPlusDropdowns(wowSimOptions)
    ApplyMerfinPlusDropdowns(raidPack)
    ApplyMerfinPlusDropdowns(profilesOptions)
    ApplyMerfinPlusDropdowns(assignmentsOptions)
    ApplyMerfinPlusDropdowns(raidCooldownOptions)
  end

  -- ==== Register Blizzard panels (left AddOns pane) ====
  aceConfigRegistry:RegisterOptionsTable("MerfinPlus", mainOptions)
  self.optionsFrame = aceConfigDialog:AddToBlizOptions("MerfinPlus", "MerfinPlus v" .. version)

  if mediaOptions then
    aceConfigRegistry:RegisterOptionsTable("MerfinPlus_Media", mediaOptions)
    aceConfigDialog:AddToBlizOptions("MerfinPlus_Media", "Media", "MerfinPlus v" .. version)
  end

  if wowSimOptions then
    aceConfigRegistry:RegisterOptionsTable("MerfinPlus_WoWSim", wowSimOptions)
    aceConfigDialog:AddToBlizOptions("MerfinPlus_WoWSim", "WoW Sim", "MerfinPlus v" .. version)
  end

  if raidPack then
    aceConfigRegistry:RegisterOptionsTable("MerfinPlus_RaidPack", raidPack)
    aceConfigDialog:AddToBlizOptions("MerfinPlus_RaidPack", "Raid Settings", "MerfinPlus v" .. version)
  end

  aceConfigRegistry:RegisterOptionsTable("MerfinPlus_Profiles", profilesOptions)
  aceConfigDialog:AddToBlizOptions("MerfinPlus_Profiles", "Profiles", "MerfinPlus v" .. version)

  if assignmentsOptions then
    aceConfigRegistry:RegisterOptionsTable("MerfinPlus_Assignments", assignmentsOptions)
    aceConfigDialog:AddToBlizOptions("MerfinPlus_Assignments", "Assignments", "MerfinPlus v" .. version)
  end

  -- ==== Standalone window (own AceConfigDialog frame) ====
  -- IMPORTANT: include whole profilesOptions object, not just .args, to keep its handler intact.
  local standaloneOptions = {
    type = "group",
    name = "MerfinPlus v" .. version,
    args = {},
  }

  mediaOptions.childGroups = nil

  local optionSections = {}
  registeredLocalizationRoots[standaloneOptionsName] = standaloneOptions

  if raidPack then
    table.insert(optionSections, {
      key = "raidPack",
      labelKey = "Raid Settings",
      label = self:T("Raid Settings"),
      icon = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\nav_raid_settings.tga",
      aliases = { "raidpack", "raid", "rp" },
      options = raidPack,
      order = 20,
    })
  end

  if assignmentsOptions then
    table.insert(optionSections, {
      key = "assignments",
      labelKey = "Assignments",
      label = self:T("Assignments"),
      icon = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\nav_assignments.tga",
      aliases = { "assignments", "assignment", "assigns" },
      options = assignmentsOptions,
      order = 30,
    })
  end

  if raidCooldownOptions then
    table.insert(optionSections, {
      key = "raidCooldowns",
      labelKey = "Raid Cooldowns",
      label = self:T("Raid Cooldowns"),
      icon = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\nav_raid_cooldowns.tga",
      aliases = { "raidcooldowns", "cooldowns", "cooldown", "cds" },
      options = raidCooldownOptions,
      order = 35,
    })
  end

  table.insert(optionSections, {
    key = "wowSim",
    labelKey = "WoW Sim",
    label = self:T("WoW Sim"),
    icon = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\nav_wowsims.tga",
    aliases = { "wowsim", "wow", "sim", "bis" },
    options = wowSimOptions,
    order = 40,
  })

  table.insert(optionSections, {
    key = "media",
    labelKey = "Media",
    label = self:T("Media"),
    icon = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\nav_media.tga",
    aliases = { "media" },
    options = mediaOptions,
    order = 50,
  })

  table.insert(optionSections, {
    key = "profiles",
    labelKey = "Profiles",
    label = self:T("Profiles"),
    icon = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\nav_profiles.tga",
    aliases = { "profiles", "profile" },
    options = profilesOptions,
    order = 60,
  })

  local sectionsByKey = {}
  local sectionByAlias = {}

  for _, section in ipairs(optionSections) do
    if section.options then
      section.options.order = section.order
      standaloneOptions.args[section.key] = section.options
      sectionsByKey[section.key] = section

      for _, alias in ipairs(section.aliases) do
        sectionByAlias[alias] = section
      end
    end
  end

  if capabilities.localizationValidation then
    self:StripOptionLocalizationMetadata(standaloneOptions)
    localizationSchemaValid, localizationSchemaError =
      self:ValidateLocalizedOptionsTrees(registeredLocalizationRoots)
    if not localizationSchemaValid then
      error(localizationSchemaError)
    end
  end

  aceConfigRegistry:RegisterOptionsTable(standaloneOptionsName, standaloneOptions)
  aceConfigDialog:SetDefaultSize(standaloneOptionsName, 1000, 680)

  local defaultSectionKey
  for _, section in ipairs(optionSections) do
    if section.options then
      defaultSectionKey = section.key
      break
    end
  end

  local validAssignmentTabs = {
    raid = true,
    gurtogg = true,
    preboss = true,
    settings = true,
    rosterExport = true,
  }
  local validRaidCooldownTabs = {
    general = true,
    activation = true,
  }

  local function GetStoredViewState()
    local storage
    if capabilities.assignmentsOptions and type(MerfinPlus.GetRaidAssignmentStorage) == "function" then
      storage = MerfinPlus:GetRaidAssignmentStorage()
    else
      local db = MerfinPlus.db
      storage = db and db.global and db.global.assignments
      if type(storage) ~= "table" then
        return {}
      end
    end
    storage.viewState = storage.viewState or {}
    return storage.viewState
  end

  local assignmentTabLayouts = {
    [3] = {
      requiredWidth = 0,
      fixedWidth = true,
      { value = "raid", width = 145 },
      { value = "gurtogg", width = 205 },
      { value = "settings", width = 130 },
    },
    [4] = {
      requiredWidth = 605,
      { value = "raid", width = 145 },
      { value = "gurtogg", width = 165 },
      { value = "preboss", width = 165 },
      { value = "settings", width = 130 },
    },
    [5] = {
      requiredWidth = 650,
      { value = "raid", width = 145 },
      { value = "gurtogg", width = 160 },
      { value = "preboss", width = 155 },
      { value = "settings", width = 125 },
      { value = "rosterExport", width = 160 },
    },
  }

  local function CompactAssignmentTabGroup(tabGroup)
    if
      not tabGroup
      or tabGroup.merfinPlusSingleRowDisabled
      or tabGroup.type ~= "TabGroup"
    then
      return false
    end
    local tabCount = #(tabGroup.tablist or {})
    local layout = assignmentTabLayouts[tabCount]
    if not layout then
      return false
    end
    for index = 1, tabCount do
      if
        not tabGroup.tablist[index]
        or tabGroup.tablist[index].value ~= layout[index].value
      then
        return false
      end
    end

    -- Never compact from BuildTabs/OnWidthSet itself. AceGUI's OnWidthSet calls
    -- BuildTabs, so changing layout dimensions in that callback chain can
    -- recursively re-enter the container layout. At genuinely narrow widths,
    -- leave the native (multi-row) layout untouched as the safe fallback.
    local frameWidth = tabGroup.frame and tabGroup.frame:GetWidth() or 0
    if frameWidth < layout.requiredWidth then
      return false
    end
    if tabGroup.merfinPlusApplyingTabLayout then
      return false
    end
    if not tabGroup.frame or not tabGroup.border or not tabGroup.border.SetPoint then
      tabGroup.merfinPlusSingleRowDisabled = true
      return false
    end
    for index = 1, tabCount do
      local tab = tabGroup.tabs[index]
      if not tab or not tab.ClearAllPoints or not tab.SetPoint or not tab.SetWidth then
        tabGroup.merfinPlusSingleRowDisabled = true
        return false
      end
    end
    tabGroup.merfinPlusApplyingTabLayout = true

    local compacted = pcall(function()
      local overlap = 10
      local availableWidth = frameWidth + overlap * (tabCount - 1)
      local preferredWidth = 0
      for index = 1, tabCount do
        preferredWidth = preferredWidth + layout[index].width
      end
      local targetWidth = layout.fixedWidth and preferredWidth or math.min(availableWidth, preferredWidth)
      local widthScale = targetWidth / preferredWidth
      local remainingWidth = targetWidth
      local previous
      for index = 1, tabCount do
        local tab = tabGroup.tabs[index]
        local width
        if index == tabCount then
          width = remainingWidth
        else
          width = math.floor(layout[index].width * widthScale + 0.5)
          remainingWidth = remainingWidth - width
        end
        tab:ClearAllPoints()
        if previous then
          tab:SetPoint("LEFT", previous, "RIGHT", -overlap, 0)
        else
          local hasTitle = tabGroup.titletext
            and tabGroup.titletext:GetText()
            and tabGroup.titletext:GetText() ~= ""
          tab:SetPoint("TOPLEFT", tabGroup.frame, "TOPLEFT", 0, hasTitle and -14 or -7)
        end
        tab:SetWidth(width)
        local tabText = tab.GetFontString and tab:GetFontString()
        if tabText then
          if tabText.SetWordWrap then tabText:SetWordWrap(false) end
          if tabText.SetNonSpaceWrap then tabText:SetNonSpaceWrap(false) end
        end
        if tab.Middle then
          tab.Middle:SetWidth(math.max(1, width - 40))
        end
        if tab.MiddleDisabled then
          tab.MiddleDisabled:SetWidth(math.max(1, width - 40))
        end
        if tab.HighlightTexture then
          tab.HighlightTexture:SetWidth(width)
        end
        previous = tab
      end

      local hasTitle = tabGroup.titletext
        and tabGroup.titletext:GetText()
        and tabGroup.titletext:GetText() ~= ""
      tabGroup.borderoffset = (hasTitle and 17 or 10) + 20
      tabGroup.border:SetPoint("TOPLEFT", 1, -tabGroup.borderoffset)
    end)
    tabGroup.merfinPlusApplyingTabLayout = false
    if not compacted then
      -- Disable only this optional compaction. AceGUI's already-rendered native
      -- tabs remain the fallback and no retry loop can be entered.
      tabGroup.merfinPlusSingleRowDisabled = true
    end
    return compacted
  end

  local function KeepAssignmentTabsOnOneRow(container)
    local function FindTabGroup(widget)
      for _, child in ipairs(widget and widget.children or {}) do
        if child.type == "TabGroup" then
          local values = {}
          for _, tab in ipairs(child.tabs or {}) do
            values[tab.value] = true
          end
          if values.raid and values.gurtogg and values.settings then
            return child
          end
        end
        local nested = FindTabGroup(child)
        if nested then
          return nested
        end
      end
    end

    local tabGroup = FindTabGroup(container)
    if not tabGroup then
      return
    end

    local function ScheduleCompact()
      tabGroup.merfinPlusTabLayoutGeneration = (tabGroup.merfinPlusTabLayoutGeneration or 0) + 1
      local generation = tabGroup.merfinPlusTabLayoutGeneration
      local apply = function()
        if generation ~= tabGroup.merfinPlusTabLayoutGeneration then
          return
        end
        CompactAssignmentTabGroup(tabGroup)
      end
      if C_Timer and C_Timer.After then
        -- Run after AceGUI's own one-frame BuildTabsOnUpdate pass.
        C_Timer.After(0.01, apply)
      end
    end

    if not tabGroup.merfinPlusSingleRowSizeHooked then
      tabGroup.frame:HookScript("OnSizeChanged", function()
        if not tabGroup.merfinPlusApplyingTabLayout then
          ScheduleCompact()
        end
      end)
      tabGroup.merfinPlusSingleRowSizeHooked = true
    end
    ScheduleCompact()
  end

  function MerfinPlus:SaveAssignmentOptionsViewState()
    local viewState = GetStoredViewState()
    -- AceConfig's status table is rebuilt during a locale refresh and can
    -- briefly report its first group. The selected navigation widget is the
    -- visible source of truth and preserves the page the user is viewing.
    local selectedMain
    local frame = self.optionsStandaloneFrame
    for sectionKey, widget in pairs((frame and frame.NavWidgets) or {}) do
      if widget and widget.selected and sectionsByKey[sectionKey] then
        selectedMain = sectionKey
        break
      end
    end
    if not selectedMain then
      local rootStatus = aceConfigDialog:GetStatusTable(standaloneOptionsName)
      selectedMain = rootStatus and rootStatus.groups and rootStatus.groups.selected
    end
    if selectedMain and sectionsByKey[selectedMain] then
      viewState.activeMainNav = selectedMain
    end
    if assignmentsOptions then
      local assignmentStatus = aceConfigDialog:GetStatusTable(standaloneOptionsName, { "assignments" })
      local selectedTab = assignmentStatus and assignmentStatus.groups and assignmentStatus.groups.selected
      if validAssignmentTabs[selectedTab] then
        viewState.activeAssignmentsTab = selectedTab
      end
    end
    if raidCooldownOptions then
      local raidCooldownStatus = aceConfigDialog:GetStatusTable(
        standaloneOptionsName,
        { "raidCooldowns" }
      )
      local selectedRaidCooldownTab = raidCooldownStatus
        and raidCooldownStatus.groups
        and raidCooldownStatus.groups.selected
      if validRaidCooldownTabs[selectedRaidCooldownTab] then
        viewState.activeRaidCooldownsTab = selectedRaidCooldownTab
      end
    end
  end

  local standaloneFrame = GetStandaloneFrame()
  if not standaloneFrame.merfinPlusViewStateHooked then
    standaloneFrame:HookScript("OnHide", function()
      MerfinPlus:SaveAssignmentOptionsViewState()
    end)
    standaloneFrame.merfinPlusViewStateHooked = true
  end
  self:RegisterEvent("PLAYER_LOGOUT", "SaveAssignmentOptionsViewState")

  -- Toggle standalone and optionally preselect section/subtab
  function MerfinPlus:ToggleStandalone(which, sub)
    local frame = GetStandaloneFrame()
    local viewState = GetStoredViewState()

    if frame:IsShown() and not which then
      self:SaveAssignmentOptionsViewState()
      frame:Hide()
      return
    end

    frame:Show()
    SyncStandaloneContentSize(frame)
    GuardStandaloneInsetRoot(frame.AceContainer)
    if frame.Logo then PlayLogoSpin(frame.Logo) end

    local selectedKey = which and sectionsByKey[which] and which
      or (sectionsByKey[viewState.activeMainNav] and viewState.activeMainNav)
      or defaultSectionKey
    viewState.activeMainNav = selectedKey
    if selectedKey == "assignments" then
      if not validAssignmentTabs[sub] then
        sub = validAssignmentTabs[viewState.activeAssignmentsTab] and viewState.activeAssignmentsTab or "raid"
      end
      viewState.activeAssignmentsTab = sub
    elseif selectedKey == "raidCooldowns" then
      if not validRaidCooldownTabs[sub] then
        sub = validRaidCooldownTabs[viewState.activeRaidCooldownsTab]
          and viewState.activeRaidCooldownsTab
          or "general"
      end
      viewState.activeRaidCooldownsTab = sub
    end
    SetStandaloneNavigation(frame, optionSections, selectedKey, function(key)
      MerfinPlus:SaveAssignmentOptionsViewState()
      GetStoredViewState().activeMainNav = key
      MerfinPlus:ToggleStandalone(key)
    end)

    if selectedKey and sectionsByKey[selectedKey] then
      if sub then
        -- Store the child selection, but render from the parent group. Opening
        -- the full leaf path bypasses AceConfig's TabGroup and hides its tabs.
        aceConfigDialog:SelectGroup(standaloneOptionsName, selectedKey, sub)
      end
      aceConfigDialog:Open(standaloneOptionsName, frame.AceContainer, selectedKey)
      if selectedKey == "assignments" then
        KeepAssignmentTabsOnOneRow(frame.AceContainer)
      end
      self:ApplyLocalizedFontsToFrame(frame)
    else
      aceConfigDialog:Open(standaloneOptionsName, frame.AceContainer)
      self:ApplyLocalizedFontsToFrame(frame)
    end
    ApplyStandaloneInsetBackdrops(frame.AceContainer)
    self:ApplyUIFontSizeDelta(frame)
    -- The first login builds the standalone frame before AceConfig has laid
    -- out its content. Rebind after that initial layout so both the stored
    -- value and its visible top-right label are present on the first open.
    RefreshLanguageDropdown(frame)
    if C_Timer and C_Timer.After then
      -- The host size becomes final one frame after AceConfig creates nested
      -- TabGroups. Run the same one-shot size propagation as a real resize.
      C_Timer.After(0, function()
        if frame:IsShown() then
          SyncStandaloneContentSize(frame)
          ApplyStandaloneInsetBackdrops(frame.AceContainer)
          MerfinPlus:ApplyUIFontSizeDelta(frame)
        end
      end)
    end
  end

  function MerfinPlus:RefreshUITheme()
    local frame = self.optionsStandaloneFrame
    local wasShown = frame and frame:IsShown()
    if wasShown then self:SaveAssignmentOptionsViewState() end

    RefreshStandaloneFrameTheme(frame)
    if self.RefreshReadyCheckTheme then self:RefreshReadyCheckTheme() end
    if self.RefreshReadyCheckPreviewWidgets then self:RefreshReadyCheckPreviewWidgets(true) end
    if self.RefreshRaidAutoMarkerTheme then self:RefreshRaidAutoMarkerTheme() end
    if self.RefreshAssignmentWidgetTheme then self:RefreshAssignmentWidgetTheme() end
    if self.RefreshBossPlanTheme then self:RefreshBossPlanTheme() end

    if not wasShown then return end
    local viewState = GetStoredViewState()
    local selectedKey = sectionsByKey[viewState.activeMainNav]
      and viewState.activeMainNav or defaultSectionKey
    local sub
    if selectedKey == "assignments" then
      sub = validAssignmentTabs[viewState.activeAssignmentsTab]
        and viewState.activeAssignmentsTab or "raid"
    elseif selectedKey == "raidCooldowns" then
      sub = validRaidCooldownTabs[viewState.activeRaidCooldownsTab]
        and viewState.activeRaidCooldownsTab or "general"
    end

    local function RebuildVisiblePage()
      if not frame:IsShown() then return end
      MerfinPlus:ToggleStandalone(selectedKey, sub)
      RefreshStandaloneFrameTheme(frame)
    end
    -- The theme selector is itself an AceGUI control. Rebuild on the next
    -- frame so its callback can finish before AceConfig releases that page.
    if C_Timer and C_Timer.After then
      C_Timer.After(0, RebuildVisiblePage)
    else
      RebuildVisiblePage()
    end
  end

  self.merfinPlusLocalizationRoots = registeredLocalizationRoots
  self.merfinPlusLocalizationSections = optionSections

  function MerfinPlus:RefreshUILocale()
    local frame = self.optionsStandaloneFrame
    local wasShown = frame and frame:IsShown()
    if wasShown then
      self:SaveAssignmentOptionsViewState()
    end

    for _, root in pairs(self.merfinPlusLocalizationRoots or {}) do
      self:StripOptionLocalizationMetadata(root)
      self:LocalizeOptionTree(root)
      self:StripOptionLocalizationMetadata(root)
    end
    for _, section in ipairs(self.merfinPlusLocalizationSections or {}) do
      section.label = self:T(section.labelKey or section.label)
    end

    if frame and frame.LanguageDropdown then
      RefreshLanguageDropdown(frame)
    end
    if self.RefreshAssignmentWidgetLocale then
      self:RefreshAssignmentWidgetLocale()
    end
    if self.RefreshReadyCheckWindow then
      self:RefreshReadyCheckWindow()
    end
    if StaticPopupDialogs.MERFINPLUS_DELETE_RECORDED_RAID then
      StaticPopupDialogs.MERFINPLUS_DELETE_RECORDED_RAID.text =
        self:T("Delete the selected recorded raid?\n\n%s")
      StaticPopupDialogs.MERFINPLUS_DELETE_RECORDED_RAID.button1 = self:T("Delete")
      StaticPopupDialogs.MERFINPLUS_DELETE_RECORDED_RAID.button2 = self:T("Cancel")
    end

    local schemaValid, schemaError =
      self:ValidateLocalizedOptionsTrees(self.merfinPlusLocalizationRoots)
    if not schemaValid then
      self:PrettyPrint("Localization refresh stopped: " .. tostring(schemaError))
      return
    end

    aceConfigRegistry:NotifyChange(standaloneOptionsName)
    if assignmentsOptions then
      aceConfigRegistry:NotifyChange("MerfinPlus_Assignments")
    end
    if wasShown then
      local viewState = GetStoredViewState()
      local selectedKey = sectionsByKey[viewState.activeMainNav] and viewState.activeMainNav or defaultSectionKey
      SetStandaloneNavigation(frame, optionSections, selectedKey, function(key)
        GetStoredViewState().activeMainNav = key
        MerfinPlus:ToggleStandalone(key)
      end)
      local selectedChild
      if selectedKey == "assignments" then
        selectedChild = viewState.activeAssignmentsTab
      elseif selectedKey == "raidCooldowns" then
        selectedChild = viewState.activeRaidCooldownsTab
      end
      self:ToggleStandalone(selectedKey, selectedChild)
    end
  end

  local function PrintSlashHelp()
    local lines = {
      MerfinPlus:T("Commands:"),
      "/mp",
      "/mp help",
      "/mp reset - " .. MerfinPlus:T("Recommended settings update"),
    }

    for _, section in ipairs(optionSections) do
      if sectionsByKey[section.key] then
        table.insert(lines, "/mp " .. section.aliases[1] .. " - " .. section.label)
      end
    end

    MerfinPlus.PrettyPrint(table.concat(lines, "\n"))
  end

  local function RunSlashCommand(msg)
    msg = strlower(strtrim(msg or ""))

    if msg == "" then
      MerfinPlus:ToggleStandalone()
      return
    end

    if msg == "help" or msg == "?" then
      PrintSlashHelp()
      return
    end

    if msg == "reset" then
      MerfinPlus:ShowRaidSettingsResetPrompt(true)
      return
    end

    local which, sub = strmatch(msg, "^(%S+)%s+(%S+)$")
    local section = sectionByAlias[which or msg]

    if section then
      MerfinPlus:ToggleStandalone(section.key, sub)
    else
      PrintSlashHelp()
    end
  end

  function MerfinPlus:OpenOptions(which, sub)
    if which then
      local section = sectionByAlias[strlower(which)]
      which = section and section.key or which
    end

    if which == "help" or which == "?" then
      PrintSlashHelp()
    else
      self:ToggleStandalone(which, sub)
    end
  end

  -- ==== Slash commands ====
  aceConsole:RegisterChatCommand("merfinplus", RunSlashCommand)
  aceConsole:RegisterChatCommand("mp", RunSlashCommand)
end
