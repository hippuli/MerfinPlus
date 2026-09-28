local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local libraries = MerfinPlus.Libs
local aceDbOptions = libraries.AceDBOptions
local aceConfigDialog = libraries.AceConfigDialog
local aceConfigRegistry = libraries.AceConfigRegistry
local aceConsole = libraries.AceConsole
local aceGui = libraries.AceGUI
local locale = MerfinPlus.L

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
local standaloneOptionsName = "MerfinPlus_Standalone"
local theme = MerfinPlus.UITheme

-- Standalone options window: central size and layout controls.
-- Change these values instead of scattering offsets through the frame creation code.
local compactWindow = Merfin.IsRetailOrForever()
local defaultFrameWidth = compactWindow and 860 or 1040
local defaultFrameHeight = compactWindow and 590 or 700
-- Keep enough room for the navigation column and four-option plugin tabs.
-- AceGUI starts truncating and overlapping controls below these dimensions.
local minimumFrameWidth = compactWindow and 820 or 920
local minimumFrameHeight = compactWindow and 560 or 620
local logoBadgeSize = 58          -- Header logo width and height.
local logoTextureSize = 48        -- Integer size keeps the logo edges crisp.
local containerBorderOverlap = 5  -- Compensates transparent pixels in UI-Tooltip-Border.
local contentLeft = 244           -- Left edge of the AceConfig page area.
local navDividerX = contentLeft   -- Keep navigation flush with the AceConfig page area.
local navLeftInset = 4            -- Align nav buttons with the backdrop's visible inner edge.
local navFlareOverflow = 10       -- Exact right overhang of nav_button_flare.png.
local contentTop = 76             -- Header height and main content starting area.
local navItemHeight = 48          -- Height of one main navigation entry.
local useCompactSharedFooter = Merfin.IsTBC() or Merfin.IsMists() or Merfin.IsClassic() or Merfin.IsForever()
local navFooterHeight = useCompactSharedFooter and 35 or 126
local footerLeftInset = 22
local footerControlGap = 10
local footerMinimapWidth = 200
local footerLanguageDropdownWidth = 150
local footerThemeDropdownWidth = 160
local footerControlYOffset = 7

local standaloneBackdropPath = "Interface\\AddOns\\MerfinPlus\\Media\\options\\merfinplus_backdrop.png"
local standaloneLogoPath = "Interface\\AddOns\\MerfinPlus\\Media\\options\\merfin_watermark.png"
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

local languageDropdownIcons = {}
for localeCode, texturePath in pairs(languageFlagPaths) do
  languageDropdownIcons[localeCode] = {
    texture = texturePath,
    width = localeCode == "enUS" and 22 or 26,
    height = 18,
  }
end

local classIconRoot = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\Classes\\"
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

local merfinPlusDropdownLogo = "Interface\\AddOns\\MerfinPlus\\Media\\options\\merfin_watermark.png"
local themeDropdownIcons = {
  origin = { texture = merfinPlusDropdownLogo, width = 20, height = 20 },
  purple = { texture = merfinPlusDropdownLogo, width = 20, height = 20 },
}
for themeKey, iconData in pairs(themeClassIcons) do
  themeDropdownIcons[themeKey] = {
    texture = iconData.texture,
    coords = iconData.coords or { 0.07, 0.93, 0.07, 0.93 },
  }
end

local optionPanelBackdrop = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local optionPanelBackdrop2 = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
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
  titleText:SetText("Merfin" .. ThemeColorEscape(theme.accent) .. "Plus|r")
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
  versionText:SetText(GetAddOnMetadata("MerfinPlus", "Version") or "???")
  versionText:SetTextColor(theme.muted[1], theme.muted[2], theme.muted[3], 1)
  frame.VersionText = versionText

  -- LEFT NAVIGATION HOST
  -- Contains the main section buttons and a separate footer at the bottom.
  frame.NavContainer = CreateFrame("Frame", nil, frame)
  frame.NavContainer:SetFrameLevel(frame:GetFrameLevel() + 5)
  frame.NavContainer:SetPoint("TOPLEFT", contentContainer, "TOPLEFT", navLeftInset, -10)
  frame.NavContainer:SetPoint("BOTTOMLEFT", contentContainer, "BOTTOMLEFT", navLeftInset, 10)
  frame.NavContainer:SetWidth(navDividerX - navLeftInset)

  frame.NavFooter = CreateFrame("Frame", nil, useCompactSharedFooter and contentContainer or frame.NavContainer)
  if useCompactSharedFooter then
    frame.NavFooter:SetPoint("BOTTOMLEFT", contentContainer, "BOTTOMLEFT", 0, 4)
    frame.NavFooter:SetPoint("BOTTOMRIGHT", contentContainer, "BOTTOMRIGHT", 0, 4)
  else
    frame.NavFooter:SetPoint("BOTTOMLEFT", frame.NavContainer, "BOTTOMLEFT", 0, 0)
    frame.NavFooter:SetPoint("BOTTOMRIGHT", frame.NavContainer, "BOTTOMRIGHT", -navFlareOverflow, 0)
  end
  frame.NavFooter:SetHeight(navFooterHeight)
  frame.NavFooter:SetFrameLevel(frame.NavContainer:GetFrameLevel() + (useCompactSharedFooter and 4 or 2))

  -- RIGHT PAGE HOST
  -- AceConfig renders the currently selected options page inside this frame.
  frame.ContentContentContainer = CreateFrame("Frame", nil, frame)
  frame.ContentContentContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", contentLeft, -(contentTop + 16))
  frame.ContentContentContainer:SetPoint(
    "BOTTOMRIGHT",
    frame,
    "BOTTOMRIGHT",
    -24,
    useCompactSharedFooter and (navFooterHeight + 10) or 24
  )

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
  logo:SetTexture(standaloneLogoPath)
  logo:SetVertexColor(1, 1, 1, 1)
  logo:SetAlpha(1)
  logo:SetTexCoord(0, 1, 0, 1)
  logo:SetPoint("CENTER", badge, "CENTER", 0, 0)
  logo:SetSize(logoTextureSize, logoTextureSize)

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
  local row = not useCompactSharedFooter and frame.MinimapIconRow
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
  if useCompactSharedFooter and dropdown.SetIcons then dropdown:SetIcons(themeDropdownIcons) end
  dropdown:SetList(MerfinPlus:GetUIThemeChoices(), MerfinPlus:GetUIThemeOrder())
  local themeKey = MerfinPlus:GetUIThemeKey()
  dropdown:SetValue(themeKey)
  local icon = frame.ThemeClassIcon
  local iconData = themeClassIcons[themeKey]
  if not useCompactSharedFooter then
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
  end
  if dropdown.RefreshTheme then dropdown:RefreshTheme() end
  ApplyNativeCheckTheme(frame.MinimapIconOption)
end

-- Creates the persistent minimap-icon checkbox at the bottom of the navigation.
local function CreateFooterMinimapOption(frame)
  local row = CreateFrame("Frame", nil, frame.NavFooter)
  if useCompactSharedFooter then
    row:SetPoint("LEFT", frame.ThemeDropdown.frame, "RIGHT", footerControlGap, 0)
    row:SetSize(footerMinimapWidth, 30)
  else
    row:SetPoint("BOTTOMLEFT", frame.NavFooter, "BOTTOMLEFT", 43, 80)
    row:SetPoint("BOTTOMRIGHT", frame.NavFooter, "BOTTOMRIGHT", -12, 80)
    row:SetHeight(24)
  end
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
  if useCompactSharedFooter then label:SetPoint("RIGHT", row, "RIGHT", 0, 0) end
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
  if useCompactSharedFooter then
    dropdown.frame:SetPoint("LEFT", frame.LanguageDropdown.frame, "RIGHT", footerControlGap, 0)
    dropdown:SetWidth(footerThemeDropdownWidth)
  else
    dropdown.frame:SetPoint("BOTTOMLEFT", frame.NavFooter, "BOTTOMLEFT", 43, 42)
    dropdown.frame:SetPoint("BOTTOMRIGHT", frame.NavFooter, "BOTTOMRIGHT", -12, 42)
    dropdown:SetWidth(172)
  end
  dropdown.matchLanguageFieldFont = true
  dropdown:SetLabel("")
  dropdown:SetCallback("OnValueChanged", function(_, _, value)
    MerfinPlus:SetUITheme(value)
  end)
  if not useCompactSharedFooter then
    local icon = frame.NavFooter:CreateTexture(nil, "OVERLAY", nil, 7)
    icon:SetSize(26, 26)
    icon:SetPoint("CENTER", frame.NavFooter, "BOTTOMLEFT", 26, 56)
    icon:Hide()
    frame.ThemeClassIcon = icon
  end
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
  if useCompactSharedFooter and dropdown.SetIcons then
    dropdown:SetIcons(languageDropdownIcons)
    MerfinPlus:ApplyUILocaleSelectionToDropdown(dropdown)
  else
    UpdateLanguageFlag(frame, localeCode)
  end
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
  if useCompactSharedFooter then
    dropdown.frame:SetPoint("LEFT", frame.NavFooter, "LEFT", footerLeftInset, footerControlYOffset)
    dropdown:SetWidth(footerLanguageDropdownWidth)
  else
    dropdown.frame:SetPoint("BOTTOMLEFT", frame.NavFooter, "BOTTOMLEFT", 43, 4)
    dropdown.frame:SetPoint("BOTTOMRIGHT", frame.NavFooter, "BOTTOMRIGHT", -12, 4)
    dropdown:SetWidth(172)
  end
  dropdown:SetLabel("")
  dropdown:SetCallback("OnValueChanged", function(_, _, value)
    MerfinPlus:SetUILocale(value)
    RefreshLanguageDropdown(frame)
  end)

  if not useCompactSharedFooter then
    local flag = frame.NavFooter:CreateTexture(nil, "OVERLAY", nil, 7)
    flag:SetSize(30, 22)
    flag:SetPoint("RIGHT", dropdown.frame, "LEFT", -3, 0)
    frame.LanguageFlag = flag
  end
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

local function ScaleStandaloneFrame(frame)
  local E = _G.ElvUI and _G.ElvUI[1]
  if E and E.uiscale then
    frame:SetScale(1)
    return
  end

  local _, screenHeight = GetPhysicalScreenSize()
  if not screenHeight or screenHeight <= 0 then return end
  -- Match ElvUI's automatic UI scale without changing the rest of the game UI.
  frame:SetScale(math.max(0.4, math.min(1.15, 768 / screenHeight)) / UIParent:GetEffectiveScale())
end

local function CreateStandaloneFrame()
  -- ROOT WINDOW
  local frame = CreateFrame("Frame", "MerfinPlusOptionsFrame", UIParent, BackdropTemplate)
  frame:SetSize(defaultFrameWidth, defaultFrameHeight)
  ScaleStandaloneFrame(frame)
  frame:HookScript("OnShow", ScaleStandaloneFrame)
  frame:RegisterEvent("UI_SCALE_CHANGED")
  frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
      if self:IsShown() then
        MerfinPlus.pendingOptionsOpen = {}
        self:Hide()
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
      end
    elseif event == "PLAYER_REGEN_ENABLED" then
      self:UnregisterEvent("PLAYER_REGEN_ENABLED")
      local pending = MerfinPlus.pendingOptionsOpen
      MerfinPlus.pendingOptionsOpen = nil
      if pending then MerfinPlus:ToggleStandalone(pending.which, pending.sub) end
    else
      ScaleStandaloneFrame(self)
    end
  end)
  frame:SetPoint("CENTER")
  frame:SetAlpha(1)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(500)
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetResizable(true)

  if frame.SetResizeBounds then
    frame:SetResizeBounds(minimumFrameWidth, minimumFrameHeight)
  elseif frame.SetMinResize then
    frame:SetMinResize(minimumFrameWidth, minimumFrameHeight)
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

local function ApplyStandaloneSectionBranding(frame, section)
  if not frame then return end
  local branding = section and section.branding
  frame.ActiveOptionsSection = section
  if frame.VersionText then
    frame.VersionText:SetText((branding and branding.version) or Merfin.GetAddOnMetadata("MerfinPlus", "Version") or "???")
  end
  if frame.TitleText then
    frame.TitleText:SetText(
      branding and branding.title
      or ("Merfin" .. ThemeColorEscape(theme.accent) .. "Plus|r")
    )
  end
  if frame.LogoTexture then
    frame.LogoTexture:SetTexture(branding and branding.logo or standaloneLogoPath)
    if branding and type(branding.logoCoords) == "table" then
      frame.LogoTexture:SetTexCoord(unpack(branding.logoCoords))
    else
      frame.LogoTexture:SetTexCoord(0, 1, 0, 1)
    end
  end
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
  ApplyStandaloneSectionBranding(frame, frame.ActiveOptionsSection)
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
  if option.type == "execute" and not option.dialogControl and not option.control then
    option.dialogControl = "MerfinPlusButton"
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
local SkinStandaloneTreeButtons

local function ScheduleStandaloneInsetRefresh(root)
  if not root or root.merfinPlusInsetRefreshScheduled then
    return
  end
  root.merfinPlusInsetRefreshScheduled = true

  local refresh = function()
    root.merfinPlusInsetRefreshScheduled = nil
    ApplyStandaloneInsetBackdrops(root, root)
    if root.frame then MerfinPlus:ApplyUIFontSizeDelta(root.frame) end
    if root.merfinPlusRefreshTabLayout then root.merfinPlusRefreshTabLayout(root) end
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
    if child then
      ApplyStandaloneInsetBackdrops(child, self)
      if child.frame then MerfinPlus:ApplyUIFontSizeDelta(child.frame) end
    end
    ScheduleStandaloneInsetRefresh(self)
    return result
  end
  root.merfinPlusInsetRootGuarded = true
end

local function GetStandaloneWidgetPath(widget)
  local current = widget
  while current do
    if current.GetUserData then
      local path = current:GetUserData("path") or current:GetUserData("basepath")
      if type(path) == "table" and #path > 0 then
        return path
      end
    end
    current = current.merfinPlusInsetParent
  end
end

local function IsStandaloneSection(widget, sectionKey)
  local path = GetStandaloneWidgetPath(widget)
  return path and path[1] == sectionKey or false
end

local function IsStandalonePathValue(widget, value)
  for _, pathValue in ipairs(GetStandaloneWidgetPath(widget) or {}) do
    if pathValue == value then return true end
  end
  return false
end

local function IsRaidSettingsCooldownRaidContainer(widget)
  local path = GetStandaloneWidgetPath(widget)
  return path
    and path[1] == "raidPack"
    and path[2] == "cooldowns"
    and path[3] == "raids"
    or false
end

local function WidenRaidCooldownBossTree(widget)
  if
    not widget
    or not IsRaidSettingsCooldownRaidContainer(widget)
    or type(widget.GetTreeWidth) ~= "function"
    or type(widget.SetTreeWidth) ~= "function"
  then
    return
  end

  local currentWidth = tonumber(widget:GetTreeWidth()) or 0
  if currentWidth < 240 then
    widget:SetTreeWidth(240, false)
  end
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
    theme.borderSoft[1],
    theme.borderSoft[2],
    theme.borderSoft[3],
    showBorder == false and 0 or 0.72
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
    for fontString, layout in pairs(self.merfinPlusOriginalTabTextLayouts or {}) do
      fontString:ClearAllPoints()
      for _, point in ipairs(layout.points) do
        fontString:SetPoint(point[1], point[2], point[3], point[4], point[5])
      end
      fontString:SetJustifyH(layout.justifyH)
      fontString:SetJustifyV(layout.justifyV)
    end
    self.merfinPlusOriginalTabTextLayouts = nil
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
    for _, button in ipairs(self.buttons or {}) do
      if button.merfinPlusTreeBackground then button.merfinPlusTreeBackground:Hide() end
      if button.merfinPlusTreeIndicator then button.merfinPlusTreeIndicator:Hide() end
      if button.merfinPlusOriginalTreeHeight then
        button:SetHeight(button.merfinPlusOriginalTreeHeight)
        button.merfinPlusOriginalTreeHeight = nil
      end
      button.merfinPlusTreeOwner = nil
      button.merfinPlusTreeHovered = nil
    end

    if self.merfinPlusOriginalBuildTabs then
      self.BuildTabs = self.merfinPlusOriginalBuildTabs
      self.merfinPlusOriginalBuildTabs = nil
    end
    if self.merfinPlusOriginalRefreshTree then
      self.RefreshTree = self.merfinPlusOriginalRefreshTree
      self.merfinPlusOriginalRefreshTree = nil
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
    self.merfinPlusInsetParent = nil
    self.OnRelease = release
    if release then
      return release(self, ...)
    end
  end
  widget.merfinPlusInsetReleaseGuarded = true

  if widget.type == "TabGroup" and widget.BuildTabs then
    local BuildTabs = widget.BuildTabs
    widget.merfinPlusOriginalBuildTabs = BuildTabs
    widget.BuildTabs = function(self, ...)
      local result = BuildTabs(self, ...)
      ScheduleStandaloneInsetRefresh(root)
      return result
    end
  end

  if widget.type == "TreeGroup" and widget.RefreshTree and not widget.merfinPlusOriginalRefreshTree then
    local RefreshTree = widget.RefreshTree
    widget.merfinPlusOriginalRefreshTree = RefreshTree
    widget.RefreshTree = function(self, ...)
      local result = RefreshTree(self, ...)
      -- AceGUI resets the tree button colors during every options refresh.
      -- Reapply the theme in the same call so the navigation never renders
      -- one frame with its native style after a checkbox or dropdown change.
      SkinStandaloneTreeButtons(self)
      return result
    end
  end

  if widget.AddChild and not widget.merfinPlusOriginalInsetAddChild then
    local AddChild = widget.AddChild
    widget.merfinPlusOriginalInsetAddChild = AddChild
    widget.AddChild = function(self, ...)
      local child = ...
      local result = AddChild(self, ...)
      if child then
        child.merfinPlusInsetParent = self
        ApplyStandaloneInsetBackdrops(child, root)
        if child.frame then MerfinPlus:ApplyUIFontSizeDelta(child.frame) end
        ScheduleStandaloneInsetRefresh(root)
      end
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

local function CenterStandaloneTabText(widget, tab, text)
  if not widget or not tab or not text then return end
  widget.merfinPlusOriginalTabTextLayouts = widget.merfinPlusOriginalTabTextLayouts or {}
  if not widget.merfinPlusOriginalTabTextLayouts[text] then
    local points = {}
    for index = 1, text:GetNumPoints() do
      points[index] = { text:GetPoint(index) }
    end
    widget.merfinPlusOriginalTabTextLayouts[text] = {
      points = points,
      justifyH = text:GetJustifyH(),
      justifyV = text:GetJustifyV(),
    }
  end
  text:ClearAllPoints()
  text:SetPoint("CENTER", tab, "CENTER", 0, 1)
  text:SetJustifyH("CENTER")
  text:SetJustifyV("MIDDLE")
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

local function RefreshStandaloneFlatTab(tab)
  if not tab then return end
  if not tab.merfinPlusThemeBackground then
    local background = tab:CreateTexture(nil, "BACKGROUND", nil, -1)
    background:SetPoint("TOPLEFT", tab, "TOPLEFT", 7, -1)
    background:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -7, 1)
    tab.merfinPlusThemeBackground = background

    local top = tab:CreateTexture(nil, "ARTWORK", nil, 6)
    top:SetPoint("TOPLEFT", tab, "TOPLEFT", 7, -1)
    top:SetPoint("TOPRIGHT", tab, "TOPRIGHT", -7, -1)
    top:SetHeight(1)
    local bottom = tab:CreateTexture(nil, "ARTWORK", nil, 6)
    bottom:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 7, 0)
    bottom:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -7, 0)
    bottom:SetHeight(2)
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
  tab.merfinPlusThemeBackground:SetColorTexture(
    background[1],
    background[2],
    background[3],
    active and 0.20 or (hovered and 0.10 or 0.025)
  )
  for index, texture in ipairs(tab.merfinPlusThemeBorders or {}) do
    if index == 2 then
      texture:SetColorTexture(
        theme.accent[1],
        theme.accent[2],
        theme.accent[3],
        active and 0.95 or (hovered and 0.34 or 0)
      )
      if active or hovered then texture:Show() else texture:Hide() end
    else
      texture:Hide()
    end
  end

  tab.merfinPlusThemeBackground:Show()

  local text = tab.Text or tab:GetFontString()
  if text then
    -- Blizzard's native tab template offsets labels downward. The custom flat
    -- navigation surface needs the label centered within the whole tab.
    CenterStandaloneTabText(tab.merfinPlusThemeOwner, tab, text)
    SetStandaloneTextColor(tab.merfinPlusThemeOwner, text, active and theme.accentBright or theme.text)
  end

  if not tab.merfinPlusThemeHooked then
    tab:HookScript("OnEnter", function(self)
      self.merfinPlusThemeHovered = true
      if self.merfinPlusThemeOwner then RefreshStandaloneFlatTab(self) end
    end)
    tab:HookScript("OnLeave", function(self)
      self.merfinPlusThemeHovered = nil
      if self.merfinPlusThemeOwner then RefreshStandaloneFlatTab(self) end
    end)
    tab:HookScript("OnShow", function(self)
      local owner = self.merfinPlusThemeOwner
      if owner then
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
      if owner then
        SuppressStandaloneNativeTab(self, owner)
        RefreshStandaloneFlatTab(self)
      end
      return result
    end
    local SetDisabled = tab.SetDisabled
    tab.SetDisabled = function(self, ...)
      local result = SetDisabled(self, ...)
      local owner = self.merfinPlusThemeOwner
      if owner then
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
    SuppressStandaloneNativeTab(tab, widget)
    RefreshStandaloneFlatTab(tab)
    local text = tab.Text or tab:GetFontString()
    if text then
      CenterStandaloneTabText(widget, tab, text)
      SetStandaloneTextColor(widget, text, tab.selected and theme.accentBright or theme.text)
    end
  end
end

local function RefreshStandaloneTreeButton(button)
  local widget = button and button.merfinPlusTreeOwner
  if not widget or not IsStandaloneSection(widget, "plugin:MerfinUI") then return end
  if not button.merfinPlusOriginalTreeHeight then
    button.merfinPlusOriginalTreeHeight = button:GetHeight()
  end
  button:SetHeight(28)
  if button.SetPushedTextOffset then
    button:SetPushedTextOffset(0, 0)
  end
  if not button.merfinPlusTreeBackground then
    local background = button:CreateTexture(nil, "BACKGROUND", nil, -1)
    background:SetAllPoints(button)
    button.merfinPlusTreeBackground = background

    local indicator = button:CreateTexture(nil, "ARTWORK", nil, 4)
    indicator:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -4)
    indicator:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 4)
    indicator:SetWidth(2)
    button.merfinPlusTreeIndicator = indicator
  end

  local selected = button.selected == true
  local hovered = button.merfinPlusTreeHovered == true
  local background = selected and theme.selected or (hovered and theme.hover or theme.surface)
  button.merfinPlusTreeBackground:SetColorTexture(
    background[1], background[2], background[3], selected and 0.56 or (hovered and 0.28 or 0)
  )
  button.merfinPlusTreeBackground:Show()
  button.merfinPlusTreeIndicator:SetColorTexture(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  if selected then button.merfinPlusTreeIndicator:Show() else button.merfinPlusTreeIndicator:Hide() end
  SetStandaloneTextColor(widget, button.text, selected and theme.accentBright or (hovered and theme.text or theme.muted))

  local highlight = button.GetHighlightTexture and button:GetHighlightTexture()
  if highlight then
    widget.merfinPlusOriginalTextureAlphas = widget.merfinPlusOriginalTextureAlphas or {}
    if widget.merfinPlusOriginalTextureAlphas[highlight] == nil then
      widget.merfinPlusOriginalTextureAlphas[highlight] = highlight:GetAlpha()
    end
    highlight:SetAlpha(0)
  end

  if not button.merfinPlusTreeHooked then
    button:HookScript("OnEnter", function(self)
      self.merfinPlusTreeHovered = true
      RefreshStandaloneTreeButton(self)
    end)
    button:HookScript("OnLeave", function(self)
      self.merfinPlusTreeHovered = nil
      RefreshStandaloneTreeButton(self)
    end)
    button.merfinPlusTreeHooked = true
  end
end

SkinStandaloneTreeButtons = function(widget)
  for _, button in ipairs(widget.buttons or {}) do
    button.merfinPlusTreeOwner = widget
    RefreshStandaloneTreeButton(button)
  end
end

local function ColorTexture(texture, color, alpha)
  if texture then
    texture:SetColorTexture(color[1], color[2], color[3], alpha or color[4] or 1)
  end
end

local function CreateControlSurface(control, prefix, trackHeight)
  if not control or control[prefix .. "Background"] then return end
  local background = control:CreateTexture(nil, "BACKGROUND")
  if trackHeight then
    background:SetPoint("LEFT", control, "LEFT", 1, 0)
    background:SetPoint("RIGHT", control, "RIGHT", -1, 0)
    background:SetHeight(trackHeight)
  else
    background:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
    background:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", 0, 0)
  end
  control[prefix .. "Background"] = background

  local top = control:CreateTexture(nil, "ARTWORK")
  local bottom = control:CreateTexture(nil, "ARTWORK")
  local left = control:CreateTexture(nil, "ARTWORK")
  local right = control:CreateTexture(nil, "ARTWORK")
  if trackHeight then
    top:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, 0)
    top:SetPoint("BOTTOMRIGHT", background, "TOPRIGHT", 0, 0)
    bottom:SetPoint("TOPLEFT", background, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("TOPRIGHT", background, "BOTTOMRIGHT", 0, 0)
  else
    top:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", control, "TOPRIGHT", 0, 0)
    bottom:SetPoint("BOTTOMLEFT", control, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", 0, 0)
  end
  top:SetHeight(1)
  bottom:SetHeight(1)
  left:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, 0)
  left:SetPoint("BOTTOMLEFT", bottom, "TOPLEFT", 0, 0)
  right:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT", 0, 0)
  right:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT", 0, 0)
  left:SetWidth(1)
  right:SetWidth(1)
  control[prefix .. "Borders"] = { top, bottom, left, right }
end

local function RefreshInputStyle(editbox)
  if not editbox or not editbox.merfinPlusInputBackground then return end
  ColorTexture(editbox.merfinPlusInputBackground, theme.surface, 0.94)
  local border = (editbox.merfinPlusInputFocused or editbox.merfinPlusInputHovered) and theme.accentSoft or theme.borderSoft
  local alpha = editbox.merfinPlusInputFocused and 1 or (editbox.merfinPlusInputHovered and 0.82 or 0.68)
  for _, texture in ipairs(editbox.merfinPlusInputBorders or {}) do ColorTexture(texture, border, alpha) end
  if editbox.SetTextColor then editbox:SetTextColor(theme.text[1], theme.text[2], theme.text[3], 1) end
end

local function SkinStandaloneInput(widget, editbox)
  if not editbox then return end
  local nativeTextures = {}
  local function AddNativeTexture(texture)
    if texture then nativeTextures[#nativeTextures + 1] = texture end
  end
  AddNativeTexture(editbox.Left)
  AddNativeTexture(editbox.Middle)
  AddNativeTexture(editbox.Right)
  AddNativeTexture(editbox.left)
  AddNativeTexture(editbox.middle)
  AddNativeTexture(editbox.right)
  local name = editbox.GetName and editbox:GetName()
  if name then
    AddNativeTexture(_G[name .. "Left"])
    AddNativeTexture(_G[name .. "Middle"])
    AddNativeTexture(_G[name .. "Right"])
    AddNativeTexture(_G[name .. "Mid"])
  end
  for _, texture in ipairs(nativeTextures) do
    if texture and texture.SetAlpha then
      widget.merfinPlusOriginalTextureAlphas = widget.merfinPlusOriginalTextureAlphas or {}
      if widget.merfinPlusOriginalTextureAlphas[texture] == nil then
        widget.merfinPlusOriginalTextureAlphas[texture] = texture:GetAlpha()
      end
      texture:SetAlpha(0)
    end
  end
  CreateControlSurface(editbox, "merfinPlusInput")
  if not editbox.merfinPlusInputHooked then
    editbox:HookScript("OnEnter", function(self) self.merfinPlusInputHovered = true; RefreshInputStyle(self) end)
    editbox:HookScript("OnLeave", function(self) self.merfinPlusInputHovered = nil; RefreshInputStyle(self) end)
    editbox:HookScript("OnEditFocusGained", function(self) self.merfinPlusInputFocused = true; RefreshInputStyle(self) end)
    editbox:HookScript("OnEditFocusLost", function(self) self.merfinPlusInputFocused = nil; RefreshInputStyle(self) end)
    editbox.merfinPlusInputHooked = true
  end
  RefreshInputStyle(editbox)
end

local function RefreshSliderStyle(slider)
  if not slider or not slider.merfinPlusSliderBackground then return end
  ColorTexture(slider.merfinPlusSliderBackground, theme.surface, 0.94)
  local border = slider.merfinPlusSliderHovered and theme.accentSoft or theme.borderSoft
  for _, texture in ipairs(slider.merfinPlusSliderBorders or {}) do
    ColorTexture(texture, border, slider.merfinPlusSliderHovered and 0.90 or 0.72)
  end
  local thumb = slider:GetThumbTexture()
  if thumb then
    thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    thumb:SetSize(8, 16)
    thumb:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  end
end

local function SkinStandaloneSlider(widget)
  local slider = widget and widget.slider
  if not slider then return end
  CreateControlSurface(slider, "merfinPlusSlider", 6)
  if not slider.merfinPlusSliderHooked then
    slider:HookScript("OnEnter", function(self) self.merfinPlusSliderHovered = true; RefreshSliderStyle(self) end)
    slider:HookScript("OnLeave", function(self) self.merfinPlusSliderHovered = nil; RefreshSliderStyle(self) end)
    slider.merfinPlusSliderHooked = true
  end
  RefreshSliderStyle(slider)
  SkinStandaloneInput(widget, widget.editbox or widget.editBox)
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
    SetStandaloneVertexColor(widget, widget.left, theme.accent, IsStandaloneSection(widget, "plugin:MerfinUI") and 0.32 or 0.62)
    SetStandaloneVertexColor(widget, widget.right, theme.accent, IsStandaloneSection(widget, "plugin:MerfinUI") and 0.32 or 0.62)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "CheckBox" or widget.type == "MerfinPlusNpcToggle" then
    if widget.frame and widget.frame.SetPushedTextOffset then
      widget.frame:SetPushedTextOffset(0, 0)
    end
    if widget.checkbg then
      widget.merfinPlusOriginalTabTextureSources = widget.merfinPlusOriginalTabTextureSources or {}
      if widget.merfinPlusOriginalTabTextureSources[widget.checkbg] == nil then
        widget.merfinPlusOriginalTabTextureSources[widget.checkbg] = widget.checkbg:GetTexture() or false
      end
      widget.checkbg:SetTexture("Interface\\Buttons\\WHITE8X8")
      widget.checkbg:ClearAllPoints()
      widget.checkbg:SetSize(18, 18)
      widget.checkbg:SetPoint("LEFT", widget.frame, "LEFT", 1, 0)
    end
    if widget.check then
      widget.check:SetTexture("Interface\\Buttons\\WHITE8X8")
      widget.check:ClearAllPoints()
      widget.check:SetSize(10, 10)
      widget.check:SetPoint("CENTER", widget.checkbg, "CENTER", 0, 0)
    end
    if widget.highlight then
      widget.highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
      widget.highlight:ClearAllPoints()
      widget.highlight:SetAllPoints(widget.checkbg)
    end
    if widget.text then
      local function RestoreCheckboxTextPosition()
        widget.text:ClearAllPoints()
        widget.text:SetPoint("LEFT", widget.checkbg, "RIGHT", 8, 0)
        widget.text:SetPoint("RIGHT", widget.frame, "RIGHT", -2, 0)
        widget.text:SetJustifyV("MIDDLE")
      end
      RestoreCheckboxTextPosition()
      widget.merfinPlusRestoreCheckboxTextPosition = RestoreCheckboxTextPosition
      if widget.frame and not widget.merfinPlusCheckboxPositionHooked then
        widget.frame:HookScript("OnMouseDown", function(frame)
          local owner = frame.obj
          if owner and owner.merfinPlusRestoreCheckboxTextPosition then
            owner.merfinPlusRestoreCheckboxTextPosition()
          end
        end)
        widget.frame:HookScript("OnMouseUp", function(frame)
          local owner = frame.obj
          if owner and owner.merfinPlusRestoreCheckboxTextPosition then
            owner.merfinPlusRestoreCheckboxTextPosition()
          end
        end)
        widget.merfinPlusCheckboxPositionHooked = true
      end
    end
    SetStandaloneVertexColor(widget, widget.checkbg, theme.surfaceRaised, 1)
    SetStandaloneVertexColor(widget, widget.check, theme.accentBright, 1)
    SetStandaloneVertexColor(widget, widget.highlight, theme.accent, 0.28)
    SetStandaloneTextColor(widget, widget.text, theme.text)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "Slider" then
    SetStandaloneTextColor(widget, widget.label, theme.accentBright)
    SetStandaloneTextColor(widget, widget.lowtext, theme.muted)
    SetStandaloneTextColor(widget, widget.hightext, theme.muted)
    SkinStandaloneSlider(widget)
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
    SkinStandaloneInput(widget, widget.editbox or widget.editBox)
  elseif widget.type == "MerfinPlusIconButton" then
    SetStandaloneVertexColor(widget, widget.image, theme.accentBright, 1)
  elseif widget.type == "InlineGroup" then
    SetStandaloneTextColor(widget, widget.titletext, theme.accentBright)
    local isAddOnCard = IsStandaloneSection(widget, "plugin:MerfinUI")
      and (IsStandalonePathValue(widget, "qolAddOns") or IsStandalonePathValue(widget, "raidAddOns"))
    local hideBorder = IsStandaloneSection(widget, "raidCooldowns")
      or (IsStandaloneSection(widget, "plugin:MerfinUI") and not isAddOnCard)
    MakeStandaloneInsetTransparent(widget, widget.content and widget.content:GetParent(), not hideBorder)
    if isAddOnCard then
      local card = widget.content and widget.content:GetParent()
      if card and card.SetBackdropColor then
        card:SetBackdropColor(theme.surface[1], theme.surface[2], theme.surface[3], 0.46)
        card:SetBackdropBorderColor(theme.borderSoft[1], theme.borderSoft[2], theme.borderSoft[3], 0.82)
      end
      if widget.merfinPlusSectionDivider then
        widget.merfinPlusSectionDivider:Hide()
        if widget.merfinPlusSectionAccent then widget.merfinPlusSectionAccent:Hide() end
      end
    elseif IsStandaloneSection(widget, "plugin:MerfinUI") then
      if not widget.merfinPlusSectionDivider then
        local divider = widget.frame:CreateTexture(nil, "ARTWORK")
        divider:SetPoint("BOTTOMLEFT", widget.frame, "BOTTOMLEFT", 14, 2)
        divider:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -14, 2)
        divider:SetHeight(1)
        widget.merfinPlusSectionDivider = divider

      end
      widget.merfinPlusSectionDivider:SetColorTexture(theme.borderSoft[1], theme.borderSoft[2], theme.borderSoft[3], 0.46)
      widget.merfinPlusSectionDivider:Show()
      if widget.merfinPlusSectionAccent then widget.merfinPlusSectionAccent:Hide() end
    elseif widget.merfinPlusSectionDivider then
      widget.merfinPlusSectionDivider:Hide()
      if widget.merfinPlusSectionAccent then widget.merfinPlusSectionAccent:Hide() end
    end
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "TreeGroup" then
    local hideBorder = IsRaidSettingsCooldownRaidContainer(widget)
      or IsStandaloneSection(widget, "plugin:MerfinUI")
    MakeStandaloneInsetTransparent(widget, widget.treeframe, not hideBorder)
    MakeStandaloneInsetTransparent(widget, widget.border, not hideBorder)
    SkinStandaloneTreeButtons(widget)
    WidenRaidCooldownBossTree(widget)
    GuardStandaloneInsetWidget(widget, root)
  elseif widget.type == "DropdownGroup" then
    local hideBorder = IsRaidSettingsCooldownRaidContainer(widget)
      or IsStandaloneSection(widget, "plugin:MerfinUI")
    MakeStandaloneInsetTransparent(widget, widget.border, not hideBorder)
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


  local raidCooldownOptions = capabilities.raidCooldowns
    and self:BuildRaidCooldownTrackerOptions()
    or nil



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

    self:LocalizeOptionTree(raidCooldownOptions)
  end

  local registeredLocalizationRoots = {
    MerfinPlus = mainOptions,
    MerfinPlus_Media = mediaOptions,
    MerfinPlus_WoWSim = wowSimOptions,
    MerfinPlus_RaidPack = raidPack,
    MerfinPlus_Profiles = profilesOptions,

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



  -- ==== Standalone window (own AceConfigDialog frame) ====
  -- IMPORTANT: include whole profilesOptions object, not just .args, to keep its handler intact.
  local standaloneOptions = {
    type = "group",
    name = "MerfinPlus v" .. version,
    args = {},
  }

  mediaOptions.childGroups = nil

  local optionSections = {}

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
    key = "about",
    labelKey = "About",
    label = self:T("About"),
    icon = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\nav_about.tga",
    aliases = { "about", "links" },
    options = self:BuildAboutOptions(),
    order = 55,
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

  local coreOptionSections = optionSections
  optionSections = {}
  local pluginSections = {}
  local sectionsByKey = {}
  local sectionByAlias = {}

  local function ComparePluginSections(left, right)
    local leftID = strlower(left.pluginID)
    local rightID = strlower(right.pluginID)
    if leftID ~= rightID then return leftID < rightID end
    return left.pluginID < right.pluginID
  end

  local function RebuildOptionSections()
    for index = #optionSections, 1, -1 do
      optionSections[index] = nil
    end
    for key in pairs(standaloneOptions.args) do
      standaloneOptions.args[key] = nil
    end
    for key in pairs(sectionsByKey) do
      sectionsByKey[key] = nil
    end
    for alias in pairs(sectionByAlias) do
      sectionByAlias[alias] = nil
    end

    local firstPlugins = {}
    for _, section in pairs(pluginSections) do
      table.insert(firstPlugins, section)
    end
    table.sort(firstPlugins, ComparePluginSections)

    for _, section in ipairs(firstPlugins) do
      table.insert(optionSections, section)
    end
    for _, section in ipairs(coreOptionSections) do
      if section.key ~= "profiles" then
        table.insert(optionSections, section)
      end
    end
    for _, section in ipairs(coreOptionSections) do
      if section.key == "profiles" then
        table.insert(optionSections, section)
      end
    end

    for _, section in ipairs(optionSections) do
      if section.options then
        if not section.pluginID then section.options.order = section.order end
        standaloneOptions.args[section.key] = section.options
        sectionsByKey[section.key] = section
        for _, alias in ipairs(section.aliases) do
          alias = strlower(alias)
          if not sectionByAlias[alias] then sectionByAlias[alias] = section end
        end
      end
    end
  end

  local function BuildPluginSection(id, plugin)
    if not plugin or not plugin.definition.options then
      pluginSections[id] = nil
      RebuildOptionSections()
      return true
    end

    local definition = plugin.definition
    local options = definition.options
    if type(options) == "function" then
      local succeeded, result = pcall(options, plugin)
      if not succeeded then return false, tostring(result) end
      options = result
    end
    if type(options) ~= "table" or options.type ~= "group" then
      return false, "plugin options must resolve to an AceConfig group table"
    end

    ApplyMerfinPlusDropdowns(options)

    local aliases = {}
    for _, alias in ipairs(definition.aliases or {}) do
      if type(alias) == "string" and alias ~= "" then table.insert(aliases, alias) end
    end
    if #aliases == 0 then table.insert(aliases, strlower(id)) end

    pluginSections[id] = {
      key = "plugin:" .. id,
      pluginID = id,
      label = definition.name or id,
      icon = definition.icon,
      aliases = aliases,
      options = options,
      branding = definition.branding,
    }
    RebuildOptionSections()
    return true
  end

  RebuildOptionSections()
  for id, plugin in pairs(self._plugins) do
    local registered, reason = BuildPluginSection(id, plugin)
    if not registered then
      self.PrettyPrint("Options plugin " .. id .. " was not registered: " .. tostring(reason))
    end
  end

  if capabilities.localizationValidation then
    localizationSchemaValid, localizationSchemaError =
      self:ValidateLocalizedOptionsTrees(registeredLocalizationRoots)
    if not localizationSchemaValid then
      error(localizationSchemaError)
    end
  end

  aceConfigRegistry:RegisterOptionsTable(standaloneOptionsName, standaloneOptions)
  aceConfigDialog:SetDefaultSize(standaloneOptionsName, compactWindow and 860 or 1000, compactWindow and 590 or 680)

  local defaultSectionKey
  for _, section in ipairs(optionSections) do
    if section.options then
      defaultSectionKey = section.key
      break
    end
  end


  local validRaidCooldownTabs = {
    general = true,
    activation = true,
  }

  local function GetStoredViewState()
    local global = MerfinPlus.db.global
    if type(global.optionsViewState) ~= "table" then
      local old = global.assignments and global.assignments.viewState or {}
      global.optionsViewState = { activeMainNav = old.activeMainNav, activeRaidCooldownsTab = old.activeRaidCooldownsTab }
    end
    return global.optionsViewState
  end







  function MerfinPlus:SaveOptionsViewState()
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
      MerfinPlus:SaveOptionsViewState()
    end)
    standaloneFrame.merfinPlusViewStateHooked = true
  end
  self:RegisterEvent("PLAYER_LOGOUT", "SaveOptionsViewState")

  -- Toggle standalone and optionally preselect section/subtab
  function MerfinPlus:ToggleStandalone(which, sub)
    if InCombatLockdown() then
      self.pendingOptionsOpen = { which = which, sub = sub }
      self.optionsStandaloneFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
      return
    end
    local frame = GetStandaloneFrame()
    local viewState = GetStoredViewState()

    if frame:IsShown() and not which then
      self:SaveOptionsViewState()
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
    ApplyStandaloneSectionBranding(frame, sectionsByKey[selectedKey])
    if selectedKey == "raidCooldowns" then
      if not validRaidCooldownTabs[sub] then
        sub = validRaidCooldownTabs[viewState.activeRaidCooldownsTab]
          and viewState.activeRaidCooldownsTab
          or "general"
      end
      viewState.activeRaidCooldownsTab = sub
    end
    SetStandaloneNavigation(frame, optionSections, selectedKey, function(key)
      MerfinPlus:SaveOptionsViewState()
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
    if wasShown then self:SaveOptionsViewState() end

    RefreshStandaloneFrameTheme(frame)
    if self.RefreshReadyCheckTheme then self:RefreshReadyCheckTheme() end
    if self.RefreshReadyCheckPreviewWidgets then self:RefreshReadyCheckPreviewWidgets(true) end
    if self.RefreshRaidAutoMarkerTheme then self:RefreshRaidAutoMarkerTheme() end


    if self.RefreshCompanionBridgeTheme then self:RefreshCompanionBridgeTheme() end

    if not wasShown then return end
    local viewState = GetStoredViewState()
    local selectedKey = sectionsByKey[viewState.activeMainNav]
      and viewState.activeMainNav or defaultSectionKey
    local sub
    if selectedKey == "raidCooldowns" then
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
      self:SaveOptionsViewState()
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

    if self.RefreshReadyCheckWindow then
      self:RefreshReadyCheckWindow()
    end


    local schemaValid, schemaError =
      self:ValidateLocalizedOptionsTrees(self.merfinPlusLocalizationRoots)
    if not schemaValid then
      self:PrettyPrint("Localization refresh stopped: " .. tostring(schemaError))
      return
    end

    aceConfigRegistry:NotifyChange(standaloneOptionsName)

    if wasShown then
      local viewState = GetStoredViewState()
      local selectedKey = sectionsByKey[viewState.activeMainNav] and viewState.activeMainNav or defaultSectionKey
      SetStandaloneNavigation(frame, optionSections, selectedKey, function(key)
        GetStoredViewState().activeMainNav = key
        MerfinPlus:ToggleStandalone(key)
      end)
      local selectedChild
      if selectedKey == "raidCooldowns" then
        selectedChild = viewState.activeRaidCooldownsTab
      end
      self:ToggleStandalone(selectedKey, selectedChild)
    end
  end

  function MerfinPlus:OnOptionsPluginChanged(id, plugin)
    local registered, reason = BuildPluginSection(id, plugin)
    if not registered then return false, reason end

    defaultSectionKey = optionSections[1] and optionSections[1].key or defaultSectionKey
    aceConfigRegistry:NotifyChange(standaloneOptionsName)
    local frame = self.optionsStandaloneFrame
    if frame and frame:IsShown() then
      local viewState = GetStoredViewState()
      local selectedKey = sectionsByKey[viewState.activeMainNav]
        and viewState.activeMainNav or defaultSectionKey
      self:ToggleStandalone(selectedKey)
    end
    return true
  end

  function MerfinPlus:OpenRegisteredOptionsPlugin(id, sub)
    local section = pluginSections[id]
    if not section then return false, "options plugin is not available" end
    self:ToggleStandalone(section.key, sub)
    return true
  end

  local pendingPluginOpen = self.pendingOptionsPluginOpen
  self.pendingOptionsPluginOpen = nil
  if pendingPluginOpen then
    self:OpenRegisteredOptionsPlugin(pendingPluginOpen.id, pendingPluginOpen.sub)
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
      for _, section in ipairs(optionSections) do
        if not section.pluginID then
          MerfinPlus:ToggleStandalone(section.key)
          return
        end
      end
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

  function MerfinPlus:OpenFirstOptionsTab()
    if optionSections[1] then
      self:ToggleStandalone(optionSections[1].key)
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
