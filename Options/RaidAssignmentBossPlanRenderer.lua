local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local theme = MerfinPlus.UITheme
MerfinPlus.BossPlanTechnicalElementTooltipsDisabled = true

local ADDON_ROOT = "Interface\\AddOns\\MerfinPlus\\Media\\assignments\\"
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local SYMBOL_ROOT = ADDON_ROOT .. "symbols\\"
local DROPDOWN_ARROW_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\options\\dropdown_arrow.tga"
local FONT_REGULAR = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local FONT_BOLD = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Bold.otf"
-- Guild Manager authors and displays every plan in this fixed logical space.
-- Background artwork has its own aspect ratio and is center-cropped to cover
-- this canvas; element percentages must never inherit the artwork dimensions.
local CANVAS_WIDTH = 1350
local CANVAS_HEIGHT = 916
local DRAWING_POINT_LIMIT = 2048
local ERASER_RADIUS_PIXELS = 10
local ERASER_SAMPLE_SPACING_PIXELS = 2
local DEFAULT_TEXT_SIZE = 28
local MIN_TEXT_SIZE = 6
local MAX_TEXT_SIZE = 160
local ADDITIONAL_WOW_ICON_ZOOM = 1.30
local ADDITIONAL_WOW_ICON_INSET = (1 - (1 / ADDITIONAL_WOW_ICON_ZOOM)) / 2
local ADDITIONAL_WOW_ICON_TEXCOORD = {
  ADDITIONAL_WOW_ICON_INSET, 1 - ADDITIONAL_WOW_ICON_INSET,
  ADDITIONAL_WOW_ICON_INSET, 1 - ADDITIONAL_WOW_ICON_INSET,
}
local EDITOR_LAYOUT = {
  toolbarRegion = "canvas-top-left-horizontal",
  contextPanelRegion = "canvas-top-centered-compact",
  persistentRightPanel = false,
  canvasHorizontalChrome = 28,
  canvasVerticalChrome = 64,
  headerRows = 1,
  actionButtonsInHeader = true,
  actionButtonsAdjacent = true,
  buttonTooltips = false,
  navigationRegion = "canvas-top-right",
  responsiveFlow = false,
  toolbarHeight = 36,
  toolButtonSize = 34,
  toolButtonGap = 1,
  paletteIconSize = 32,
  contextPanelHeight = 44,
  contextPanelTop = 54,
  contextPanelMaxWidth = 620,
  paletteCapacity = 42,
}
MerfinPlus.BossPlanEditorLayoutContract = EDITOR_LAYOUT
local VIEWER_HORIZONTAL_CHROME = EDITOR_LAYOUT.canvasHorizontalChrome
local VIEWER_VERTICAL_CHROME = EDITOR_LAYOUT.canvasVerticalChrome
local MIN_VIEWER_SCALE = 0.6
local MAX_VIEWER_SCALE = 1.5
local QUICK_OVERVIEW_CHROME = 8
local MIN_QUICK_OVERVIEW_SCALE = 0.28
local DEFAULT_QUICK_OVERVIEW_SCALE = 0.34
local MAX_QUICK_OVERVIEW_SCALE = 1
local template = BackdropTemplateMixin and "BackdropTemplate" or nil

local function BackgroundCoverTexCoords(sourceWidth, sourceHeight, targetWidth, targetHeight)
  sourceWidth, sourceHeight = tonumber(sourceWidth), tonumber(sourceHeight)
  targetWidth, targetHeight = tonumber(targetWidth), tonumber(targetHeight)
  if not sourceWidth or not sourceHeight or not targetWidth or not targetHeight
    or sourceWidth <= 0 or sourceHeight <= 0 or targetWidth <= 0 or targetHeight <= 0 then
    return 0, 1, 0, 1
  end
  local sourceAspect = sourceWidth / sourceHeight
  local targetAspect = targetWidth / targetHeight
  if sourceAspect > targetAspect then
    local visibleWidth = targetAspect / sourceAspect
    local inset = (1 - visibleWidth) / 2
    return inset, 1 - inset, 0, 1
  elseif sourceAspect < targetAspect then
    local visibleHeight = sourceAspect / targetAspect
    local inset = (1 - visibleHeight) / 2
    return 0, 1, inset, 1 - inset
  end
  return 0, 1, 0, 1
end

MerfinPlus.BossPlanCanvasGeometryContract = {
  width = CANVAS_WIDTH,
  height = CANVAS_HEIGHT,
  backgroundMode = "cover-center",
  BackgroundTexCoords = BackgroundCoverTexCoords,
}

local function ResolveTextSize(element, fallback)
  return math.max(MIN_TEXT_SIZE, math.min(MAX_TEXT_SIZE,
    tonumber(element and element.textSize) or fallback or DEFAULT_TEXT_SIZE))
end

local function ScaleTextSizeForResize(textSize, originalWidth, originalHeight, width, height, direction)
  local base = math.max(MIN_TEXT_SIZE, math.min(MAX_TEXT_SIZE, tonumber(textSize) or DEFAULT_TEXT_SIZE))
  local horizontal = direction and (direction:find("LEFT", 1, true) or direction:find("RIGHT", 1, true))
  local vertical = direction and (direction:find("TOP", 1, true) or direction:find("BOTTOM", 1, true))
  local widthRatio = math.max(0.01, tonumber(width) or 0) / math.max(0.01, tonumber(originalWidth) or 0)
  local heightRatio = math.max(0.01, tonumber(height) or 0) / math.max(0.01, tonumber(originalHeight) or 0)
  local ratio = horizontal and vertical and math.sqrt(widthRatio * heightRatio)
    or (horizontal and widthRatio) or (vertical and heightRatio) or 1
  return math.max(MIN_TEXT_SIZE, math.min(MAX_TEXT_SIZE, base * ratio))
end
MerfinPlus.ScaleBossPlanTextSizeForResize = ScaleTextSizeForResize

local backdrop = {
  bgFile = WHITE_TEXTURE,
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 14,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local CLASS_TOKENS = {
  demonhunter = "DEMONHUNTER", druid = "DRUID", hunter = "HUNTER", mage = "MAGE", paladin = "PALADIN",
  priest = "PRIEST", rogue = "ROGUE", shaman = "SHAMAN", warlock = "WARLOCK",
  warrior = "WARRIOR",
}

local CLASS_TONES = {
  DEMONHUNTER = "#a330c9", DRUID = "#ff7d0a", HUNTER = "#abd473", MAGE = "#69ccf0", PALADIN = "#f58cba",
  PRIEST = "#ffffff", ROGUE = "#fff569", SHAMAN = "#0070de", WARLOCK = "#9482c9",
  WARRIOR = "#c79c6e",
}

local RAID_MARKERS = {
  star = 1, circle = 2, diamond = 3, triangle = 4,
  moon = 5, square = 6, cross = 7, skull = 8,
}

local EMOJI_SPRITE = SYMBOL_ROOT .. "emoji-sprite-v1.tga"
local function SpriteSymbol(id, label, column, row)
  local inset = 2 / 1024
  local left, top = column * 0.25 + inset, row * 0.25 + inset
  return {
    assetId = "symbol.emoji." .. id, elementType = "emoji", runtimePath = EMOJI_SPRITE,
    label = label, texCoord = { left, left + 0.25 - inset * 2, top, top + 0.25 - inset * 2 },
  }
end
local SMILEY_ASSET = SpriteSymbol("smiley", "🙂", 0, 0)
local EXPRESSIONLESS_ASSET = SpriteSymbol("expressionless", "😑", 1, 0)
local FALLBACK_SYMBOL_ASSET = { assetId = "symbol.fallback.question", runtimePath = "Interface\\Icons\\INV_Misc_QuestionMark" }
local SYMBOL_ASSETS = {
  SMILEY_ASSET, EXPRESSIONLESS_ASSET,
  SpriteSymbol("laugh", "😄", 2, 0), SpriteSymbol("wink", "😉", 3, 0),
  SpriteSymbol("heart-eyes", "😍", 0, 1), SpriteSymbol("sad", "🙁", 1, 1),
  SpriteSymbol("cry", "😭", 2, 1), SpriteSymbol("angry", "😠", 3, 1),
  SpriteSymbol("surprised", "😮", 0, 2), SpriteSymbol("confused", "😕", 1, 2),
  SpriteSymbol("cool", "😎", 2, 2), SpriteSymbol("skull", "💀", 3, 2),
  SpriteSymbol("heart", "❤️", 0, 3), SpriteSymbol("warning", "⚠️", 1, 3),
  SpriteSymbol("check", "✅", 2, 3), SpriteSymbol("cross", "❌", 3, 3),
}
local CANONICAL_SYMBOLS = {}
MerfinPlus.BossPlanSymbolCatalog = { [FALLBACK_SYMBOL_ASSET.assetId] = FALLBACK_SYMBOL_ASSET }
for _, asset in ipairs(SYMBOL_ASSETS) do
  MerfinPlus.BossPlanSymbolCatalog[asset.assetId] = asset
  CANONICAL_SYMBOLS[asset.label] = asset
  CANONICAL_SYMBOLS[asset.assetId] = asset
end
for alias, asset in pairs({
  smiley = SMILEY_ASSET, smile = SMILEY_ASSET, [":)"] = SMILEY_ASSET, [":-)"] = SMILEY_ASSET,
  ["😊"] = SMILEY_ASSET, ["😀"] = SMILEY_ASSET, expressionless = EXPRESSIONLESS_ASSET,
  ["😂"] = SYMBOL_ASSETS[3], ["😁"] = SYMBOL_ASSETS[3], ["😢"] = SYMBOL_ASSETS[7],
  ["☠️"] = SYMBOL_ASSETS[12], ["❤"] = SYMBOL_ASSETS[13], ["♥"] = SYMBOL_ASSETS[13],
  ["✔"] = SYMBOL_ASSETS[15], ["✖"] = SYMBOL_ASSETS[16],
}) do CANONICAL_SYMBOLS[alias] = asset end

function MerfinPlus:ResolveBossPlanSymbolAsset(elementType, token)
  if elementType ~= "emoji" then return FALLBACK_SYMBOL_ASSET end
  local normalized = tostring(token or ""):lower():gsub("[^%w]+", "")
  return self.BossPlanSymbolCatalog[token] or CANONICAL_SYMBOLS[token] or CANONICAL_SYMBOLS[normalized]
    or FALLBACK_SYMBOL_ASSET
end

local ADDON_WOW_ICON_PATHS = {}
local CLASS_SPEC_PALETTE = {}
local function AddClassSpecPaletteItem(id, label, runtimePath, element)
  CLASS_SPEC_PALETTE[#CLASS_SPEC_PALETTE + 1] = { id = id, label = label, runtimePath = runtimePath, element = element }
end
local classSpecs = {
  { "demonhunter", "DEMONHUNTER", { "devourer", "havoc", "vengeance" } },
  { "druid", "DRUID", { "balance", "feral", "guardian", "restoration" } },
  { "hunter", "HUNTER", { "beastmastery", "marksmanship", "survival" } },
  { "mage", "MAGE", { "arcane", "fire", "frost" } },
  { "paladin", "PALADIN", { "holy", "protection", "retribution" } },
  { "priest", "PRIEST", { "discipline", "holy", "shadow", "smite" } },
  { "rogue", "ROGUE", { "assassination", "combat", "subtlety" } },
  { "shaman", "SHAMAN", { "elemental", "enhancement", "restoration" } },
  { "warlock", "WARLOCK", { "affliction", "demonology", "destruction" } },
  { "warrior", "WARRIOR", { "arms", "fury", "protection" } },
}
for _, classSpec in ipairs(classSpecs) do
  local class, token, specs = classSpec[1], classSpec[2], classSpec[3]
  AddClassSpecPaletteItem("mp.icon.class." .. class, token, ADDON_ROOT .. "icons\\Classes\\" .. token .. ".tga",
    { type = "image", wowClass = class, size = 100 })
  for _, spec in ipairs(specs) do
    local stableToken = "merfinplus.spec." .. class .. "." .. spec
    local path = MerfinPlus:GetRaidAssignmentSpecIconPath(token, spec)
    ADDON_WOW_ICON_PATHS[stableToken] = path
    AddClassSpecPaletteItem("mp.icon.spec." .. class .. "." .. spec, token .. " " .. spec, path,
      { type = "image", wowIcon = stableToken, size = 100 })
  end
end

local ROLE_PALETTE = {
  { id = "mp.icon.role.tank", label = "Tank", runtimePath = ADDON_ROOT .. "icons\\Roles\\tank.tga", element = { type = "image", role = "tank", size = 100 } },
  { id = "mp.icon.role.heal", label = "Heal", runtimePath = ADDON_ROOT .. "icons\\Roles\\heal.tga", element = { type = "image", role = "heal", size = 100 } },
  { id = "mp.icon.role.melee", label = "Melee", runtimePath = ADDON_ROOT .. "icons\\Roles\\dps.tga", element = { type = "image", role = "melee", size = 100 } },
  { id = "mp.icon.role.ranged", label = "Ranged", runtimePath = ADDON_ROOT .. "icons\\Roles\\dps.tga", element = { type = "image", role = "ranged", size = 100 } },
  { id = "mp.icon.role.raid", label = "Raid role", runtimePath = ADDON_ROOT .. "icons\\Roles\\position_white.tga", element = { type = "image", wowIcon = "merfinplus.role.raid", size = 100 } },
}
ADDON_WOW_ICON_PATHS["merfinplus.role.raid"] = ADDON_ROOT .. "icons\\Roles\\position_white.tga"

local SMILEY_PALETTE = {}
for _, asset in ipairs(SYMBOL_ASSETS) do
  SMILEY_PALETTE[#SMILEY_PALETTE + 1] = {
    id = asset.assetId, label = asset.assetId:gsub("^symbol%.emoji%.", ""), runtimePath = asset.runtimePath,
    texCoord = asset.texCoord, element = { type = "emoji", assetId = asset.assetId, label = asset.label, size = 100 },
  }
end

local FONT_CHOICES = MerfinPlus:GetRaidAssignmentFontChoices()
-- Compact, deliberate colors for the boss-plan tools. These are immediately
-- usable in the header; opening the global WoW color picker is not required
-- for normal planning work.
local EDITOR_COLOR_PALETTE = {
  { label = "White", hex = "#ffffff" }, { label = "Black", hex = "#02060b" },
  { label = "Red", hex = "#ef4444" }, { label = "Orange", hex = "#f97316" },
  { label = "Gold", hex = "#facc15" }, { label = "Green", hex = "#22c55e" },
  { label = "Teal", hex = "#14b8a6" }, { label = "Blue", hex = "#38bdf8" },
  { label = "Purple", hex = "#a855f7" }, { label = "Pink", hex = "#ec4899" },
}
local MARKER_PALETTE = {}
for _, marker in ipairs({ "star", "circle", "diamond", "triangle", "moon", "square", "cross", "skull" }) do
  MARKER_PALETTE[#MARKER_PALETTE + 1] = {
    id = "marker.raid." .. marker, label = marker, runtimePath = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. RAID_MARKERS[marker],
    element = { type = "raid-marker", marker = marker, size = 100 },
  }
end

local function DeepCopy(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}
  if seen[value] then return seen[value] end
  local copy = {}
  seen[value] = copy
  for key, child in pairs(value) do copy[DeepCopy(key, seen)] = DeepCopy(child, seen) end
  return copy
end

local function Clamp(value, minimum, maximum)
  return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
end

-- Guild Manager renders a boss in a 64px visual, with both the 48px artwork
-- and the 48px facing SVG inset by 8px. Keep the in-game line geometry tied
-- to that same artwork box so rotation never pulls the rim away from the icon.
local function BossFacingGeometry(width, height)
  local visualSize = math.min(width, height)
  local artworkSize = visualSize * 0.75
  local left = (width - artworkSize) / 2
  local top = (height - artworkSize) / 2
  return {
    artworkSize = artworkSize,
    centerX = width / 2,
    centerY = top + artworkSize * (17 / 48),
    radius = artworkSize * (23 / 48),
    arrowTipY = top - artworkSize * (4 / 48),
    arrowShoulderY = top + artworkSize * (1 / 48),
    left = left,
    top = top,
  }
end

MerfinPlus.BossPlanFacingGeometryContract = {
  artworkRatio = 0.75,
  Geometry = BossFacingGeometry,
}

-- Every MGMRA4 element field is either rendered or deliberately retained as
-- read-only metadata. No field is removed from the decoded/stored envelope.
MerfinPlus.MGMRA4BossPlanRendererFieldCoverage = {
  type = "rendered", x = "rendered", y = "rendered", player = "rendered",
  label = "rendered", rotation = "rendered", bossFacingVisible = "rendered",
  bossFacingArrowVisible = "rendered", bossFacingColor = "rendered", bossFacingRingWidth = "rendered",
  color = "rendered", marker = "rendered", assetId = "rendered", role = "rendered",
  wowClass = "rendered", wowIcon = "rendered", spellId = "rendered", size = "rendered",
  arrowLength = "rendered", width = "rendered", height = "rendered", fill = "rendered",
  fillColor = "rendered", fillOpacity = "rendered", strokeColor = "rendered",
  strokeWidth = "rendered", textColor = "rendered", textFont = "rendered",
  textAlign = "rendered", textVerticalAlign = "rendered", textSizing = "rendered",
  textBackdrop = "rendered", textBold = "rendered", textItalic = "rendered",
  textUnderline = "rendered", textStrikethrough = "rendered", textSize = "rendered",
  textStroke = "rendered", textStrokeColor = "rendered", textStrokeWidth = "rendered",
  positionRole = "metadata", rolePosition = "rendered", rolePositionVisible = "rendered", specialAssignmentKey = "metadata",
  drawingMode = "rendered", drawingPoints = "rendered", drawingWidth = "rendered",
  drawingHeight = "rendered", drawingFadeOut = "rendered", centerDot = "rendered",
  polygonSides = "rendered", pinnedTo = "rendered", facing = "rendered", locked = "metadata",
}

local function Normalize(value)
  local normalized = tostring(value or ""):lower():gsub("[^%w]+", "")
  return normalized
end

local function ShortPlayerName(value)
  return tostring(value or ""):match("^([^-]+)") or ""
end

local function PlayerNamesMatch(left, right)
  local normalizedLeft = Normalize(ShortPlayerName(left))
  return normalizedLeft ~= "" and normalizedLeft == Normalize(ShortPlayerName(right))
end

MerfinPlus.BossPlanPlayerHighlightContract = {
  label = "YOU",
  ringTexture = "Interface\\AddOns\\MerfinPlus\\Media\\textures\\ring_5.png",
  Match = PlayerNamesMatch,
}

local function HexColor(value, fallback)
  local text = type(value) == "string" and value or fallback
  local red, green, blue = tostring(text or "#ffffff"):match("^#(%x%x)(%x%x)(%x%x)$")
  if not red then
    return 1, 1, 1
  end
  return tonumber(red, 16) / 255, tonumber(green, 16) / 255, tonumber(blue, 16) / 255
end

local function HexFromRGB(red, green, blue)
  return string.format("#%02x%02x%02x", math.floor(Clamp(red, 0, 1) * 255 + 0.5),
    math.floor(Clamp(green, 0, 1) * 255 + 0.5), math.floor(Clamp(blue, 0, 1) * 255 + 0.5))
end

local function Atan2(y, x)
  if math.atan2 then
    return math.atan2(y, x)
  end
  if x > 0 then return math.atan(y / x) end
  if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
  if x < 0 and y < 0 then return math.atan(y / x) - math.pi end
  if x == 0 and y > 0 then return math.pi / 2 end
  if x == 0 and y < 0 then return -math.pi / 2 end
  return 0
end

local function SetBackdrop(frame, background, border)
  if not frame.SetBackdrop then return end
  frame:SetBackdrop(backdrop)
  frame:SetBackdropColor(background[1], background[2], background[3], background[4] or 1)
  frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
end

local function AcquireRegion(frame, kind, creator)
  frame.mgmra4RegionPools = frame.mgmra4RegionPools or {}
  frame.mgmra4RegionCursors = frame.mgmra4RegionCursors or {}
  local pool = frame.mgmra4RegionPools[kind]
  if not pool then pool = {}; frame.mgmra4RegionPools[kind] = pool end
  local index = (frame.mgmra4RegionCursors[kind] or 0) + 1
  frame.mgmra4RegionCursors[kind] = index
  local region = pool[index]
  if not region then
    region = creator()
    pool[index] = region
    frame.mgmra4Regions = frame.mgmra4Regions or {}
    frame.mgmra4Regions[#frame.mgmra4Regions + 1] = region
  end
  return region
end

local function ResetElementFrame(frame)
  frame:Hide()
  frame:ClearAllPoints()
  if frame.EnableMouse then frame:EnableMouse(false) end
  if frame.SetHitRectInsets then frame:SetHitRectInsets(0, 0, 0, 0) end
  frame:SetScript("OnEnter", nil)
  frame:SetScript("OnLeave", nil)
  frame:SetScript("OnMouseDown", nil)
  frame:SetScript("OnMouseUp", nil)
  frame:SetScript("OnUpdate", nil)
  frame.mgmra4RegionCursors = {}
  for _, region in ipairs(frame.mgmra4Regions or {}) do
    region:Hide()
    if region.SetTexture then region:SetTexture(nil) end
  end
  for _, handle in pairs(frame.mgmra4EditHandles or {}) do handle:Hide() end
  if frame.mgmra4RotationStem then frame.mgmra4RotationStem:Hide() end
  local highlight = rawget(frame, "mgmra4SelfHighlight")
  if highlight then
    if highlight.animation and highlight.animation.Stop then highlight.animation:Stop() end
    if highlight.ring then highlight.ring:Hide() end
    if highlight.badge then highlight.badge:Hide() end
  end
  local circularMask = rawget(frame, "mgmra4CircularIconMask")
  local maskedTexture = rawget(frame, "mgmra4CircularIconTexture")
  if circularMask and maskedTexture and maskedTexture.RemoveMaskTexture then
    maskedTexture:RemoveMaskTexture(circularMask)
  end
  if circularMask then circularMask:Hide() end
  frame.mgmra4CircularIconTexture = nil
  frame.mgmra4Element = nil
end

local function AddTexture(frame, subLayer)
  local texture = AcquireRegion(frame, "texture", function() return frame:CreateTexture(nil, "ARTWORK") end)
  texture:ClearAllPoints()
  if texture.SetDrawLayer then texture:SetDrawLayer("ARTWORK", subLayer or 0) end
  if texture.SetRotation then texture:SetRotation(0) end
  texture:SetVertexColor(1, 1, 1, 1)
  if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(false) end
  if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
  return texture
end

local function SetTextureFiltered(texture, path)
  if not path then texture:SetTexture(nil); return end
  local ok = pcall(texture.SetTexture, texture, path, "CLAMP", "CLAMP", "LINEAR")
  if not ok then texture:SetTexture(path) end
end

local function RotateFramePoint(frame, x, y)
  local rotation = frame.mgmra4Rotation or 0
  if rotation == 0 then return x, y end
  local originX, originY = frame:GetWidth() / 2, frame:GetHeight() / 2
  local dx, dy = x - originX, y - originY
  return originX + dx * math.cos(rotation) - dy * math.sin(rotation),
    originY + dx * math.sin(rotation) + dy * math.cos(rotation)
end

local function AddSolidRect(frame, x, y, width, height, color, alpha, subLayer)
  local texture = AddTexture(frame, subLayer)
  local r, g, b = HexColor(color, "#ffffff")
  texture:SetTexture(WHITE_TEXTURE)
  texture:SetVertexColor(r, g, b, alpha or 1)
  texture:SetSize(math.max(0.5, width), math.max(0.5, height))
  local rotation = frame.mgmra4Rotation or 0
  if rotation ~= 0 then
    local centerX, centerY = x + width / 2, y + height / 2
    local rotatedX, rotatedY = RotateFramePoint(frame, centerX, centerY)
    texture:SetPoint("CENTER", frame, "TOPLEFT", rotatedX, -rotatedY)
    if texture.SetRotation then texture:SetRotation(-rotation) end
  else
    texture:SetPoint("TOPLEFT", frame, "TOPLEFT", x, -y)
  end
  texture:Show()
  return texture
end

local function AddLine(frame, x1, y1, x2, y2, thickness, color, alpha, subLayer)
  x1, y1 = RotateFramePoint(frame, x1, y1)
  x2, y2 = RotateFramePoint(frame, x2, y2)
  local r, g, b = HexColor(color, "#02060b")
  if frame.CreateLine then
    local line = AcquireRegion(frame, "line", function() return frame:CreateLine(nil, "ARTWORK") end)
    local ok = pcall(function()
      if line.SetDrawLayer then line:SetDrawLayer("ARTWORK", subLayer or 0) end
      -- Anniversary's Line API uses point, relativeFrame, x, y. Passing a
      -- second anchor token here prevents the native line from being drawn.
      line:SetStartPoint("TOPLEFT", frame, x1, -y1)
      line:SetEndPoint("TOPLEFT", frame, x2, -y2)
      line:SetThickness(math.max(1, thickness or 2))
      line:SetColorTexture(r, g, b, alpha or 1)
      line:Show()
    end)
    if ok then return line end
    line:Hide()
  end
  local dx, dy = x2 - x1, y2 - y1
  local length = math.sqrt((dx * dx) + (dy * dy))
  local texture = AddTexture(frame, subLayer)
  texture:SetTexture(WHITE_TEXTURE)
  texture:SetVertexColor(r, g, b, alpha or 1)
  texture:SetSize(math.max(0.5, length), math.max(1, thickness or 2))
  texture:SetPoint("CENTER", frame, "TOPLEFT", (x1 + x2) / 2, -((y1 + y2) / 2))
  if texture.SetRotation then
    texture:SetRotation(-Atan2(dy, dx))
  end
  texture:Show()
  return texture
end

local function AddEndpoint(frame, x, y, diameter, color, alpha, subLayer)
  local texture = AddTexture(frame, subLayer or 2)
  local r, g, b = HexColor(color, "#02060b")
  SetTextureFiltered(texture, SYMBOL_ROOT .. "circle.tga")
  texture:SetVertexColor(r, g, b, alpha or 1)
  texture:SetSize(math.max(3, diameter or 5), math.max(3, diameter or 5))
  x, y = RotateFramePoint(frame, x, y)
  texture:SetPoint("CENTER", frame, "TOPLEFT", x, -y)
  texture:Show()
  return texture
end

local SHAPE_TEXTURES = {
  box = "box.tga", circle = "circle.tga", triangle = "triangle.tga", cone = "cone.tga",
}

local function AddRoundJoin(frame, x, y, diameter, color, alpha, subLayer)
  local texture = AddTexture(frame, subLayer or 2)
  local r, g, b = HexColor(color, "#02060b")
  SetTextureFiltered(texture, SYMBOL_ROOT .. "circle.tga")
  texture:SetVertexColor(r, g, b, alpha or 1)
  texture:SetSize(math.max(1, diameter or 1), math.max(1, diameter or 1))
  x, y = RotateFramePoint(frame, x, y)
  texture:SetPoint("CENTER", frame, "TOPLEFT", x, -y)
  texture:Show()
  return texture
end

local function AppendArc(points, centerX, centerY, radiusX, radiusY, startAngle, endAngle, segments)
  for index = 1, segments do
    local angle = startAngle + ((endAngle - startAngle) * index / segments)
    points[#points + 1] = { centerX + math.cos(angle) * radiusX, centerY + math.sin(angle) * radiusY }
  end
end

-- These normalized paths mirror Guild Manager's 100x100 SVG primitives.  A
-- single path drives both scanline fill and outline so the stroke is centered
-- on the fill boundary instead of surrounding a separately inset texture.
local function BuildShapePath(kind)
  if kind == "box" then
    local points, segments = { { 13, 6 }, { 87, 6 } }, 8
    AppendArc(points, 87, 13, 7, 7, -math.pi / 2, 0, segments)
    points[#points + 1] = { 94, 87 }
    AppendArc(points, 87, 87, 7, 7, 0, math.pi / 2, segments)
    points[#points + 1] = { 13, 94 }
    AppendArc(points, 13, 87, 7, 7, math.pi / 2, math.pi, segments)
    points[#points + 1] = { 6, 13 }
    AppendArc(points, 13, 13, 7, 7, math.pi, math.pi * 1.5, segments)
    points[#points] = nil -- closure supplies the last rounded-corner segment
    return points
  elseif kind == "circle" then
    local points, segments = {}, 96
    for index = 0, segments - 1 do
      local angle = -math.pi / 2 + (math.pi * 2 * index / segments)
      points[#points + 1] = { 50 + math.cos(angle) * 44, 50 + math.sin(angle) * 44 }
    end
    return points
  elseif kind == "triangle" then
    return { { 50, 5 }, { 95, 92 }, { 5, 92 } }, { 1, 2, 3 }
  elseif kind == "cone" then
    -- SVG contract: M50 50 L95 5 A64 64 0 0 1 95 95 Z.
    local radius, halfChord = 64, 45
    local centerX, centerY = 95 - math.sqrt((radius * radius) - (halfChord * halfChord)), 50
    local startAngle = Atan2(5 - centerY, 95 - centerX)
    local endAngle = Atan2(95 - centerY, 95 - centerX)
    local points = { { 50, 50 }, { 95, 5 } }
    AppendArc(points, centerX, centerY, radius, radius, startAngle, endAngle, 64)
    return points, { 1, 2, #points }
  end
  return { { 0, 0 }, { 100, 0 }, { 100, 100 }, { 0, 100 } }, { 1, 2, 3, 4 }
end

MerfinPlus.BossPlanShapeGeometryContract = {
  BuildPath = BuildShapePath,
  fillMasks = SHAPE_TEXTURES,
}

local function ShapeFillSpans(points, strips)
  local spans = {}
  for index = 1, strips do
    local normalizedY = ((index - 0.5) / strips) * 100
    local intersections = {}
    for pointIndex = 1, #points do
      local first = points[pointIndex]
      local second = points[(pointIndex % #points) + 1]
      if (first[2] <= normalizedY and second[2] > normalizedY)
        or (second[2] <= normalizedY and first[2] > normalizedY) then
        local ratio = (normalizedY - first[2]) / (second[2] - first[2])
        intersections[#intersections + 1] = first[1] + ((second[1] - first[1]) * ratio)
      end
    end
    table.sort(intersections)
    for intersectionIndex = 1, #intersections - 1, 2 do
      spans[#spans + 1] = {
        intersections[intersectionIndex], intersections[intersectionIndex + 1],
        (index - 1) / strips * 100, index / strips * 100,
      }
    end
  end
  return spans
end
MerfinPlus.BossPlanShapeGeometryContract.FillSpans = ShapeFillSpans

local function AddPolygonFill(frame, kind, shapePath, width, height, color, opacity)
  -- The Guild Manager cone arc extends beyond the nominal 100x100 SVG
  -- viewBox. A fixed-size texture clips that outer sector, so render its fill
  -- directly from the same complete path that drives the outline.
  if kind == "cone" then
    for _, span in ipairs(ShapeFillSpans(shapePath, 96)) do
      AddSolidRect(frame, span[1] / 100 * width, span[3] / 100 * height,
        math.max(0.5, (span[2] - span[1]) / 100 * width),
        ((span[4] - span[3]) / 100 * height) + 0.6, color, opacity, -2)
    end
    return
  end
  local textureName = SHAPE_TEXTURES[kind]
  if not textureName then return end
  local texture = AddTexture(frame, -2)
  local r, g, b = HexColor(color, "#ffffff")
  SetTextureFiltered(texture, SYMBOL_ROOT .. textureName)
  texture:SetVertexColor(r, g, b, opacity or 1)
  texture:SetAllPoints(frame)
  if texture.SetRotation then texture:SetRotation(-(frame.mgmra4Rotation or 0)) end
  texture:Show()
  return texture
end

local function AddShapeOutline(frame, points, corners, width, height, strokeWidth, strokeColor)
  for index = 1, #points do
    local first = points[index]
    local second = points[(index % #points) + 1]
    AddLine(frame, first[1] / 100 * width, first[2] / 100 * height,
      second[1] / 100 * width, second[2] / 100 * height, strokeWidth, strokeColor)
  end
  for _, index in ipairs(corners or {}) do
    local point = points[index]
    AddRoundJoin(frame, point[1] / 100 * width, point[2] / 100 * height,
      strokeWidth, strokeColor, 1, 1)
  end
end

local function AddShape(frame, element, width, height)
  local strokeColor = element.strokeColor or "#02060b"
  local strokeWidth = Clamp(element.strokeWidth == nil and 2 or element.strokeWidth, 1, 12)
  local fillColor = element.fillColor or "#ffffff"
  local fillOpacity = math.max(0, math.min(100, element.fillOpacity or 30)) / 100
  local kind = element.type
  local shapePath, corners = BuildShapePath(kind)
  if element.fill then
    AddPolygonFill(frame, kind, shapePath, width, height, fillColor, fillOpacity)
  end
  AddShapeOutline(frame, shapePath, corners, width, height, strokeWidth, strokeColor)
  if element.centerDot then
    AddRoundJoin(frame, width / 2, height / 2, 8, strokeColor, 1, 2)
  end
end

local function ResolveIconPath(element)
  if element.assetId then
    local asset = MerfinPlus:GetTBCBossPlanAsset(element.assetId)
    return asset and asset.runtimePath
  end
  if element.role then
    local role = Normalize(element.role)
    local file = (role == "tank" and "tank") or (role == "heal" and "heal") or "dps"
    return ADDON_ROOT .. "icons\\Roles\\" .. file .. ".tga"
  end
  if element.wowClass then
    local token = CLASS_TOKENS[Normalize(element.wowClass)]
    return token and (ADDON_ROOT .. "icons\\Classes\\" .. token .. ".tga")
  end
  if element.wowIcon then
    local stableToken = tostring(element.wowIcon)
    return ADDON_WOW_ICON_PATHS[stableToken]
      or ("Interface\\Icons\\" .. stableToken:gsub("^Interface[\\/]Icons[\\/]", ""))
  end
  if element.spellId then
    if C_Spell and C_Spell.GetSpellTexture then
      return C_Spell.GetSpellTexture(element.spellId)
    end
    if GetSpellInfo then
      return select(3, GetSpellInfo(element.spellId))
    end
  end
end

local function AddImage(frame, path, width, height, rotate, texCoord)
  local texture = AddTexture(frame, 1)
  SetTextureFiltered(texture, path)
  if texCoord then texture:SetTexCoord(texCoord[1], texCoord[2], texCoord[3], texCoord[4])
  else texture:SetTexCoord(0, 1, 0, 1) end
  texture:SetSize(width, height)
  texture:SetPoint("CENTER", frame, "CENTER", 0, 0)
  if rotate ~= false and texture.SetRotation and frame.mgmra4Rotation and frame.mgmra4Rotation ~= 0 then
    texture:SetRotation(-frame.mgmra4Rotation)
  end
  texture:Show()
  return texture
end

local function AdditionalWowIconTexCoord(element)
  if not element or element.type ~= "image" or element.wowClass or element.role then return nil end
  if element.spellId then return ADDITIONAL_WOW_ICON_TEXCOORD end
  if element.wowIcon and not ADDON_WOW_ICON_PATHS[tostring(element.wowIcon)] then
    return ADDITIONAL_WOW_ICON_TEXCOORD
  end
end

local function ApplyCircularIconMask(frame, texture, width, height)
  if not texture or not texture.AddMaskTexture or not frame.CreateMaskTexture then return false end
  local mask = rawget(frame, "mgmra4CircularIconMask")
  if not mask then
    mask = frame:CreateMaskTexture()
    if not mask then return false end
    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    frame.mgmra4CircularIconMask = mask
  end
  local previousTexture = rawget(frame, "mgmra4CircularIconTexture")
  if previousTexture and previousTexture ~= texture and previousTexture.RemoveMaskTexture then
    previousTexture:RemoveMaskTexture(mask)
  end
  mask:ClearAllPoints()
  mask:SetPoint("CENTER", frame, "CENTER", 0, 0)
  mask:SetSize(width, height)
  texture:AddMaskTexture(mask)
  frame.mgmra4CircularIconTexture = texture
  mask:Show()
  return true
end

local function FontPath(element)
  return MerfinPlus:GetRaidAssignmentFontPath(element.textFont, element.textItalic, element.textBold)
end

local function ShowCurrentPlayerHighlight(frame, width, height)
  local highlight = rawget(frame, "mgmra4SelfHighlight")
  if not highlight then
    highlight = {}
    frame.mgmra4SelfHighlight = highlight

    highlight.ring = frame:CreateTexture(nil, "OVERLAY", nil, 6)
    SetTextureFiltered(highlight.ring, MerfinPlus.BossPlanPlayerHighlightContract.ringTexture)
    highlight.ring:SetVertexColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 0.78)
    if highlight.ring.SetBlendMode then highlight.ring:SetBlendMode("ADD") end

    highlight.badge = CreateFrame("Frame", nil, frame, template)
    highlight.badge:SetSize(50, 22)
    SetBackdrop(highlight.badge, { 0.36, 0.16, 0.56, 0.98 }, { 0.88, 0.73, 1, 1 })
    if highlight.badge.EnableMouse then highlight.badge:EnableMouse(false) end
    highlight.badge.label = highlight.badge:CreateFontString(nil, "OVERLAY")
    highlight.badge.label:SetFont(FONT_BOLD, 13, "OUTLINE")
    highlight.badge.label:SetPoint("CENTER", 0, 0)
    highlight.badge.label:SetText(MerfinPlus.BossPlanPlayerHighlightContract.label)
    highlight.badge.label:SetTextColor(1, 1, 1, 1)

    local animationGroup
    if highlight.ring.CreateAnimationGroup then
      local ok, candidate = pcall(highlight.ring.CreateAnimationGroup, highlight.ring)
      if ok and candidate and candidate.CreateAnimation then animationGroup = candidate end
    end
    if animationGroup then
      highlight.animation = animationGroup
      local fadeDown = highlight.animation:CreateAnimation("Alpha")
      fadeDown:SetFromAlpha(0.82)
      fadeDown:SetToAlpha(0.28)
      fadeDown:SetDuration(0.82)
      fadeDown:SetOrder(1)
      if fadeDown.SetSmoothing then fadeDown:SetSmoothing("IN_OUT") end
      local fadeUp = highlight.animation:CreateAnimation("Alpha")
      fadeUp:SetFromAlpha(0.28)
      fadeUp:SetToAlpha(0.82)
      fadeUp:SetDuration(0.82)
      fadeUp:SetOrder(2)
      if fadeUp.SetSmoothing then fadeUp:SetSmoothing("IN_OUT") end
      highlight.animation:SetLooping("REPEAT")
    end
  end

  local ringSize = math.max(58, math.min(82, math.max(width, height) + 10))
  highlight.ring:ClearAllPoints()
  -- The player element's visual center sits below its frame center because the
  -- character name is rendered beneath the icon.  Center the highlight on the
  -- complete icon-and-name unit so the ring no longer clips or crosses the
  -- name while the YOU badge remains attached above it.
  highlight.ring:SetPoint("CENTER", frame, "CENTER", 0, -6)
  highlight.ring:SetSize(ringSize + 14, ringSize + 14)
  highlight.badge:ClearAllPoints()
  highlight.badge:SetPoint("BOTTOM", frame, "TOP", 0, 4)
  highlight.badge:SetFrameLevel(frame:GetFrameLevel() + 20)
  highlight.ring:SetAlpha(0.82)
  highlight.ring:Show()
  highlight.badge:Show()
  if highlight.animation and highlight.animation.Play then highlight.animation:Play() end
end

local function ApplyFont(fontString, element, size, color, alpha)
  local applied = MerfinPlus:SafeSetFontPath(fontString, FontPath(element), math.max(6, size), nil)
  if not applied then
    fontString:SetFont("Fonts\\FRIZQT__.TTF", math.max(6, size), "")
  end
  local r, g, b = HexColor(color, "#f3f7ff")
  fontString:SetTextColor(r, g, b, alpha or 1)
  fontString:SetJustifyH((element.textAlign or "center"):upper())
  local vertical = element.textVerticalAlign == "top" and "TOP"
    or element.textVerticalAlign == "bottom" and "BOTTOM" or "MIDDLE"
  fontString:SetJustifyV(vertical)
end

local function LayoutText(font, frame, text, width, height, fixedSize, offsetX, offsetY)
  font:SetText(text or "")
  font:SetPoint("CENTER", frame, "CENTER", offsetX or 0, offsetY or 0)
  if fixedSize then
    font:SetSize(math.max(1, width - 4), math.max(1, height - 4))
  else
    font:SetWidth(math.max(width, CANVAS_WIDTH * 0.8))
  end
  if font.SetRotation then font:SetRotation(-(frame.mgmra4Rotation or 0)) end
  font:Show()
end

local function AddStyledText(frame, element, text, width, height, fallbackSize)
  local fontSize = ResolveTextSize(element, fallbackSize)
  local fixedSize = element.textSizing == "fixed" or element.width or element.height
  if element.textBackdrop then
    AddSolidRect(frame, 0, 0, width, height, "#02060b", 0.7, -3)
  end
  if element.textStroke and (element.textStrokeWidth or 2) > 0 then
    local radius = math.max(0.5, math.min(8, element.textStrokeWidth or 2))
    for _, offset in ipairs({
      { -radius, 0 }, { radius, 0 }, { 0, -radius }, { 0, radius },
      { -radius * 0.72, -radius * 0.72 }, { radius * 0.72, -radius * 0.72 },
      { -radius * 0.72, radius * 0.72 }, { radius * 0.72, radius * 0.72 },
    }) do
      local stroke = AcquireRegion(frame, "font", function() return frame:CreateFontString(nil, "ARTWORK") end)
      stroke:ClearAllPoints()
      if stroke.SetDrawLayer then stroke:SetDrawLayer("ARTWORK") end
      ApplyFont(stroke, element, fontSize, element.textStrokeColor or "#02060b", 1)
      LayoutText(stroke, frame, text, width, height, fixedSize, offset[1], -offset[2])
    end
  end
  local font = AcquireRegion(frame, "font", function() return frame:CreateFontString(nil, "OVERLAY") end)
  font:ClearAllPoints()
  if font.SetDrawLayer then font:SetDrawLayer("OVERLAY") end
  ApplyFont(font, element, fontSize, element.textColor or "#f3f7ff", 1)
  LayoutText(font, frame, text, width, height, fixedSize, 0, 0)
  if element.textUnderline then
    AddSolidRect(frame, 2, height - 2, math.max(1, width - 4), 1.5, element.textColor or "#f3f7ff", 1, 3)
  end
  if element.textStrikethrough then
    AddSolidRect(frame, 2, height / 2, math.max(1, width - 4), 1.5, element.textColor or "#f3f7ff", 1, 3)
  end
  return font
end

local function AddNumberOverlay(frame, value, anchor)
  local label = AcquireRegion(frame, "font", function() return frame:CreateFontString(nil, "OVERLAY") end)
  label:ClearAllPoints()
  if label.SetDrawLayer then label:SetDrawLayer("OVERLAY") end
  label:SetFont(FONT_BOLD, math.max(10, 14 * ((frame.mgmra4Element and frame.mgmra4Element.size or 100) / 100)), "THICKOUTLINE")
  label:SetTextColor(1, 1, 1, 1)
  label:SetText(tostring(value))
  label:SetPoint("CENTER", anchor or frame, "CENTER", 0, 0)
  if label.SetRotation then label:SetRotation(-(frame.mgmra4Rotation or 0)) end
  label:Show()
end

local function ResolveElementTransform(elements, sourceIndex)
  local element = elements[sourceIndex]
  local x, y = element.x, element.y
  if element.pinnedTo ~= nil then
    local target = elements[element.pinnedTo + 1]
    if target then x, y = target.x, target.y end
  end
  local rotation = element.rotation or 0
  if element.facing ~= nil then
    local target = elements[element.facing + 1]
    if target then
      rotation = Atan2(target.y - y, target.x - x) * 180 / math.pi
    end
  end
  return x, y, rotation
end

local function ElementDimensions(element)
  local scale = (element.size or 100) / 100
  if element.width ~= nil or element.height ~= nil then
    local widthPercent = math.max(1, element.width or element.height or 8)
    local heightPercent = math.max(1, element.height or element.width or 8)
    return CANVAS_WIDTH * widthPercent / 100 * scale, CANVAS_HEIGHT * heightPercent / 100 * scale
  end
  if (element.type == "arrow" or element.type == "arrow-down" or element.type == "line") and element.arrowLength then
    local hitHeight = math.max(24, 24 * scale, (element.strokeWidth or 2) + 12)
    return CANVAS_WIDTH * element.arrowLength / 100 * scale, hitHeight
  end
  if element.type == "drawing" then
    if element.drawingMode == "point" then
      local diameter = math.max(6, (element.strokeWidth or 6) * 1.8) * scale
      return diameter, diameter
    end
    return CANVAS_WIDTH * math.max(0.6, element.drawingWidth or 0.6) / 100 * scale,
      CANVAS_HEIGHT * math.max(0.8, element.drawingHeight or 0.8) / 100 * scale
  end
  local sizes = {
    player = { 56, 52 }, text = { 160, 36 }, emoji = { 48, 48 }, arrow = { 48, 48 },
    ["arrow-down"] = { 48, 48 }, line = { 48, 24 }, box = { 48, 48 }, circle = { 48, 48 },
    triangle = { 48, 48 }, cone = { 48, 48 }, ["raid-marker"] = { 32, 32 },
    boss = { 64, 64 }, image = { 52, 52 }, drawing = { 6, 6 },
  }
  local base = sizes[element.type] or { 48, 48 }
  return base[1] * scale, base[2] * scale
end

local function RenderDrawing(frame, element, width, height)
  local color = element.color or "#ff4f52"
  local strokeWidth = math.max(2, element.strokeWidth or 6)
  local alpha = element.drawingFadeOut and 0.62 or 1
  if element.drawingMode == "point" then
    AddPolygonFill(frame, "circle", width, height, color, alpha)
    return
  end
  local points = element.drawingPoints or {}
  if #points == 0 then return end
  local first = points[1]
  AddEndpoint(frame, first[1] / 100 * width, first[2] / 100 * height, strokeWidth, color, alpha, 1)
  for index = 2, #points do
    local previous, current = points[index - 1], points[index]
    AddLine(
      frame,
      previous[1] / 100 * width,
      previous[2] / 100 * height,
      current[1] / 100 * width,
      current[2] / 100 * height,
      strokeWidth,
      color,
      alpha
    )
    -- Native Line regions have flat caps. A small filled joint at every
    -- sampled point keeps a multi-segment brush stroke visually continuous
    -- at sharp turns and under canvas scaling.
    AddEndpoint(frame, current[1] / 100 * width, current[2] / 100 * height, strokeWidth, color, alpha, 1)
  end
end

local function RenderArrow(frame, element, width, height)
  local color = element.strokeColor or element.color or "#02060b"
  local thickness = Clamp(element.strokeWidth == nil and 2 or element.strokeWidth, 0, 12)
  if thickness <= 0 then return end
  -- MGMRA4 has no separate stroke-alpha field. Guild Manager preserves the
  -- visual alpha for arrows in fillOpacity, so use that contract field for the
  -- complete shaft and head as well as for addon-created arrows.
  local alpha = Clamp((element.fillOpacity == nil and 30 or element.fillOpacity) / 100, 0, 1)
  local x1, y1, x2, y2
  if element.arrowLength then
    local inset = math.min(math.max(2, thickness), math.max(0, width / 4))
    x1, y1, x2, y2 = inset, height / 2, math.max(inset + 0.5, width - inset), height / 2
  elseif element.type == "arrow-down" then
    x1, y1, x2, y2 = width / 2, 3, width / 2, height - 3
  elseif element.type == "arrow" then
    x1, y1, x2, y2 = 5, height - 5, width - 5, 5
  else
    x1, y1, x2, y2 = 2, height / 2, width - 2, height / 2
  end
  AddLine(frame, x1, y1, x2, y2, thickness, color, alpha)
  local endpointSize = math.max(4, thickness + 2)
  if element.type == "line" then
    AddEndpoint(frame, x1, y1, endpointSize, color, alpha, 2)
    AddEndpoint(frame, x2, y2, endpointSize, color, alpha, 2)
  else
    AddEndpoint(frame, x1, y1, endpointSize, color, alpha, 2)
    local angle = Atan2(y2 - y1, x2 - x1)
    local shaftLength = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    local head = math.max(6, math.min(22, shaftLength * 0.34, 8 + thickness * 1.5))
    AddLine(frame, x2, y2, x2 - math.cos(angle - 0.65) * head, y2 - math.sin(angle - 0.65) * head, thickness, color, alpha)
    AddLine(frame, x2, y2, x2 - math.cos(angle + 0.65) * head, y2 - math.sin(angle + 0.65) * head, thickness, color, alpha)
  end
end

local function CursorCanvasPosition(viewer)
  if not GetCursorPosition then return nil end
  local scale = viewer.canvas.GetEffectiveScale and viewer.canvas:GetEffectiveScale() or 1
  local cursorX, cursorY = GetCursorPosition()
  local left, bottom = viewer.canvas:GetLeft(), viewer.canvas:GetBottom()
  if not left or not bottom or scale == 0 then return nil end
  local x = (cursorX / scale) - left
  local y = CANVAS_HEIGHT - ((cursorY / scale) - bottom)
  return Clamp(x / CANVAS_WIDTH * 100, 0, 100), Clamp(y / CANVAS_HEIGHT * 100, 0, 100)
end

local function CanvasAngleDegrees(centerX, centerY, cursorX, cursorY)
  local pixelX = (cursorX - centerX) * CANVAS_WIDTH / 100
  local pixelY = (cursorY - centerY) * CANVAS_HEIGHT / 100
  return Atan2(pixelY, pixelX) * 180 / math.pi
end

local DIMENSION_RESIZE_TYPES = {
  text = true, emoji = true, box = true, circle = true, triangle = true,
  cone = true, drawing = true, arrow = true, ["arrow-down"] = true, line = true,
}

local function ReleaseEditorCapture(viewer)
  viewer.editorDragState = false
  if viewer.dragCapture then
    viewer.dragCapture:SetScript("OnUpdate", nil)
    if viewer.dragCapture:IsShown() then viewer.dragCapture:Hide() end
  end
end

local function ActivateEditorCapture(viewer, state)
  viewer.editorDragState = state
  if viewer.dragCapture then
    viewer.dragCapture:SetScript("OnUpdate", viewer.editorCaptureOnUpdate)
    viewer.dragCapture:Show()
  end
end

local function BeginElementDrag(viewer, element, sourceIndex, mode, direction, handle, elementFrame)
  local cursorX, cursorY = CursorCanvasPosition(viewer)
  if not cursorX then return end
  if viewer.editorTool ~= "select" and viewer.CompleteCreateTool then viewer:CompleteCreateTool() end
  local width, height = ElementDimensions(element)
  local effectiveWidth = width / CANVAS_WIDTH * 100
  local effectiveHeight = height / CANVAS_HEIGHT * 100
  local centerX, centerY = element.x, element.y
  if viewer.currentPlan and viewer.currentPlan.elements then
    centerX, centerY = ResolveElementTransform(viewer.currentPlan.elements, sourceIndex)
  end
  viewer.selectedElementIndex = sourceIndex
  viewer.elementDrag = {
    index = sourceIndex, element = element, mode = mode, direction = direction, handle = handle, frame = elementFrame or handle,
    startX = cursorX, startY = cursorY, x = element.x, y = element.y,
    size = element.size == nil and 100 or element.size, rotation = element.rotation or 0,
    originalSize = element.size, originalRotation = element.rotation,
    originalWidth = element.width, originalHeight = element.height,
    originalTextSize = element.textSize, textSize = ResolveTextSize(element),
    pixelWidth = width, pixelHeight = height,
    originalPinnedTo = element.pinnedTo, originalFacing = element.facing,
    centerX = centerX, centerY = centerY,
    startCursorAngle = CanvasAngleDegrees(centerX, centerY, cursorX, cursorY),
    effectiveWidth = effectiveWidth, effectiveHeight = effectiveHeight,
    left = element.x - effectiveWidth / 2, right = element.x + effectiveWidth / 2,
    top = element.y - effectiveHeight / 2, bottom = element.y + effectiveHeight / 2,
    dimensionResize = element.width ~= nil or element.height ~= nil or DIMENSION_RESIZE_TYPES[element.type] == true,
  }
  viewer.drawCapture = false
  viewer.eraseCapture = false
  ActivateEditorCapture(viewer, "element")
end

local function UpdateElementDrag(viewer, frame)
  local drag = viewer.elementDrag
  if not drag then return end
  local cursorX, cursorY = CursorCanvasPosition(viewer)
  if not cursorX then return end
  local element = drag.element
  if drag.mode == "move" then
    element.x = Clamp(drag.x + cursorX - drag.startX, 0, 100)
    element.y = Clamp(drag.y + cursorY - drag.startY, 0, 100)
    element.pinnedTo = nil
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", viewer.canvas, "TOPLEFT", element.x / 100 * CANVAS_WIDTH, -(element.y / 100 * CANVAS_HEIGHT))
    return
  end
  if drag.mode == "rotate" then
    local cursorAngle = CanvasAngleDegrees(drag.centerX, drag.centerY, cursorX, cursorY)
    element.rotation = (drag.rotation + cursorAngle - drag.startCursorAngle) % 360
    element.facing = nil
  elseif drag.dimensionResize then
    local left, right, top, bottom = drag.left, drag.right, drag.top, drag.bottom
    if drag.direction:find("LEFT", 1, true) then left = math.min(cursorX, right - 0.1) end
    if drag.direction:find("RIGHT", 1, true) then right = math.max(cursorX, left + 0.1) end
    if drag.direction:find("TOP", 1, true) then top = math.min(cursorY, bottom - 0.1) end
    if drag.direction:find("BOTTOM", 1, true) then bottom = math.max(cursorY, top + 0.1) end
    local scale = math.max(0.001, (element.size == nil and 100 or element.size) / 100)
    -- Legacy/auto text elements have no explicit dimensions. Materialize their
    -- current box only once resizing begins so a one-axis drag cannot collapse
    -- the untouched axis, while untouched saved elements retain their old form.
    if element.type == "text" then
      element.width = element.width or (drag.effectiveWidth / scale)
      element.height = element.height or (drag.effectiveHeight / scale)
    end
    if drag.direction:find("LEFT", 1, true) or drag.direction:find("RIGHT", 1, true) then
      element.x = Clamp((left + right) / 2, 0, 100)
      element.width = Clamp((right - left) / scale, 0.1, 200)
    end
    if drag.direction:find("TOP", 1, true) or drag.direction:find("BOTTOM", 1, true) then
      element.y = Clamp((top + bottom) / 2, 0, 100)
      element.height = Clamp((bottom - top) / scale, 0.1, 200)
    end
    if element.type == "text" then
      local resizedWidth, resizedHeight = ElementDimensions(element)
      element.textSize = ScaleTextSizeForResize(drag.textSize, drag.pixelWidth, drag.pixelHeight,
        resizedWidth, resizedHeight, drag.direction)
    end
  else
    local startDistance = math.max(0.01, math.sqrt((drag.startX - drag.x) ^ 2 + (drag.startY - drag.y) ^ 2))
    local distance = math.sqrt((cursorX - drag.x) ^ 2 + (cursorY - drag.y) ^ 2)
    element.size = Clamp(drag.size * distance / startDistance, 0, 1000)
  end
  if viewer.RefreshSelectedElement then viewer:RefreshSelectedElement() end
end

local function FinishElementDrag(viewer, skipRender)
  if not viewer.elementDrag then ReleaseEditorCapture(viewer); return end
  viewer.elementDrag = false
  ReleaseEditorCapture(viewer)
  if viewer.StashCurrentDraft then viewer:StashCurrentDraft() end
  if not skipRender then viewer:Render(viewer.planIndex, true) end
end

local function CancelElementDrag(viewer, skipRender)
  local drag = viewer.elementDrag
  if drag then
    local element = drag.element
    element.x, element.y = drag.x, drag.y
    element.size, element.rotation = drag.originalSize, drag.originalRotation
    element.width, element.height = drag.originalWidth, drag.originalHeight
    element.textSize = drag.originalTextSize
    element.pinnedTo, element.facing = drag.originalPinnedTo, drag.originalFacing
  end
  viewer.elementDrag = false
  ReleaseEditorCapture(viewer)
  if drag and not skipRender then viewer:Render(viewer.planIndex, true) end
end

local function LimitDrawingCapturePoints(captured)
  if not captured or #captured <= DRAWING_POINT_LIMIT then return captured end
  local limited = {}
  local sourceCount = #captured
  for outputIndex = 1, DRAWING_POINT_LIMIT do
    local sourceIndex = math.floor(((outputIndex - 1) * (sourceCount - 1) / (DRAWING_POINT_LIMIT - 1)) + 1.5)
    limited[outputIndex] = captured[sourceIndex]
  end
  return limited
end

local function DrawingElementFromCapture(captured, style)
  if not captured or #captured == 0 then return nil end
  local minX, maxX, minY, maxY = 100, 0, 100, 0
  for _, point in ipairs(captured) do
    minX, maxX = math.min(minX, point[1]), math.max(maxX, point[1])
    minY, maxY = math.min(minY, point[2]), math.max(maxY, point[2])
  end
  local rawRangeX, rawRangeY = maxX - minX, maxY - minY
  local rangeX, rangeY = math.max(0.1, rawRangeX), math.max(0.1, rawRangeY)
  local sampled = LimitDrawingCapturePoints(captured)
  local points = {}
  for _, point in ipairs(sampled) do
    points[#points + 1] = {
      rawRangeX < 0.000001 and 50 or ((point[1] - minX) / rawRangeX * 100),
      rawRangeY < 0.000001 and 50 or ((point[2] - minY) / rawRangeY * 100),
    }
  end
  local element = DeepCopy(style or {})
  element.type, element.x, element.y = "drawing", (minX + maxX) / 2, (minY + maxY) / 2
  element.drawingMode = #points == 1 and "point" or "brush"
  element.drawingPoints, element.drawingWidth, element.drawingHeight = points, rangeX, rangeY
  element.color = element.color or "#ff4f52"
  element.strokeWidth = element.strokeWidth or 6
  element.size = element.size == nil and 100 or element.size
  return element
end

-- Versions that predate whole-stroke storage wrote every adjacent point pair
-- as a separate two-point drawing element. Coalesce only the exact shape of
-- those locally generated records, and only while preparing an editable copy.
-- Imported/saved source data is never mutated in place.
local LEGACY_DRAWING_SEGMENT_FIELDS = {
  type = true, x = true, y = true, drawingMode = true, drawingPoints = true,
  drawingWidth = true, drawingHeight = true, color = true, strokeWidth = true, size = true,
}

local function IsLegacyDrawingSegment(element)
  if type(element) ~= "table" or element.type ~= "drawing" or element.drawingMode ~= "brush"
    or type(element.drawingPoints) ~= "table" or #element.drawingPoints ~= 2
    or type(element.x) ~= "number" or type(element.y) ~= "number"
    or type(element.drawingWidth) ~= "number" or type(element.drawingHeight) ~= "number"
    or (element.size ~= nil and element.size ~= 100)
  then
    return false
  end
  for field in pairs(element) do
    if not LEGACY_DRAWING_SEGMENT_FIELDS[field] then return false end
  end
  for _, point in ipairs(element.drawingPoints) do
    if type(point) ~= "table" or #point ~= 2 or type(point[1]) ~= "number" or type(point[2]) ~= "number" then
      return false
    end
  end
  return true
end

local function LegacySegmentEndpoints(element)
  local first, second = element.drawingPoints[1], element.drawingPoints[2]
  local function ResolveAxis(center, extent, firstValue, secondValue, value)
    -- The old writer clamped a zero-size axis to 0.1 and stored both local
    -- coordinates as zero. Its actual captured coordinate was the center.
    if math.abs(firstValue - secondValue) < 0.000001 then return center end
    return center + ((value / 100) - 0.5) * extent
  end
  return {
    ResolveAxis(element.x, element.drawingWidth, first[1], second[1], first[1]),
    ResolveAxis(element.y, element.drawingHeight, first[2], second[2], first[2]),
  }, {
    ResolveAxis(element.x, element.drawingWidth, first[1], second[1], second[1]),
    ResolveAxis(element.y, element.drawingHeight, first[2], second[2], second[2]),
  }
end

local function LegacyDrawingStylesMatch(first, second)
  return first.color == second.color and first.strokeWidth == second.strokeWidth and first.size == second.size
end

local function CanvasPointsNear(first, second)
  local dx = (first[1] - second[1]) * CANVAS_WIDTH / 100
  local dy = (first[2] - second[2]) * CANVAS_HEIGHT / 100
  return (dx * dx) + (dy * dy) <= 9
end

local function CoalesceLegacyDrawingSegments(plan)
  local elements = plan and plan.elements
  if type(elements) ~= "table" or #elements < 2 then return 0, 0 end
  local mergedElements, oldToNew = {}, {}
  local mergedRuns, removedSegments, sourceIndex = 0, 0, 1
  while sourceIndex <= #elements do
    local first = elements[sourceIndex]
    if IsLegacyDrawingSegment(first) then
      local startPoint, endPoint = LegacySegmentEndpoints(first)
      local captured, lastIndex = { startPoint, endPoint }, sourceIndex
      while lastIndex < #elements do
        local candidate = elements[lastIndex + 1]
        if not IsLegacyDrawingSegment(candidate) or not LegacyDrawingStylesMatch(first, candidate) then break end
        local candidateStart, candidateEnd = LegacySegmentEndpoints(candidate)
        if not CanvasPointsNear(captured[#captured], candidateStart) then break end
        captured[#captured + 1] = candidateEnd
        lastIndex = lastIndex + 1
      end
      if lastIndex > sourceIndex then
        local outputIndex = #mergedElements + 1
        mergedElements[outputIndex] = DrawingElementFromCapture(captured, {
          color = first.color, strokeWidth = first.strokeWidth, size = first.size,
        })
        for oldIndex = sourceIndex, lastIndex do oldToNew[oldIndex - 1] = outputIndex - 1 end
        mergedRuns = mergedRuns + 1
        removedSegments = removedSegments + (lastIndex - sourceIndex)
        sourceIndex = lastIndex + 1
      else
        mergedElements[#mergedElements + 1] = first
        oldToNew[sourceIndex - 1] = #mergedElements - 1
        sourceIndex = sourceIndex + 1
      end
    else
      mergedElements[#mergedElements + 1] = first
      oldToNew[sourceIndex - 1] = #mergedElements - 1
      sourceIndex = sourceIndex + 1
    end
  end
  if mergedRuns == 0 then return 0, 0 end
  for _, element in ipairs(mergedElements) do
    for _, field in ipairs({ "pinnedTo", "facing" }) do
      if type(element[field]) == "number" then element[field] = oldToNew[element[field]] end
    end
  end
  plan.elements = mergedElements
  return mergedRuns, removedSegments
end

local function RemovePlanElement(plan, index)
  if type(plan) ~= "table" or type(plan.elements) ~= "table" or type(index) ~= "number"
    or index < 1 or index > #plan.elements
  then
    return false
  end
  local removed = index - 1
  table.remove(plan.elements, index)
  for _, element in ipairs(plan.elements) do
    for _, field in ipairs({ "pinnedTo", "facing" }) do
      if element[field] == removed then element[field] = nil
      elseif type(element[field]) == "number" and element[field] > removed then element[field] = element[field] - 1 end
    end
  end
  return true
end

local DRAWING_GEOMETRY_FIELDS = {
  x = true, y = true, drawingMode = true, drawingPoints = true, drawingWidth = true, drawingHeight = true,
  width = true, height = true, rotation = true, size = true, pinnedTo = true, facing = true,
}

local function DrawingRemainderStyle(element)
  local style = {}
  for field, value in pairs(element) do
    if not DRAWING_GEOMETRY_FIELDS[field] then style[field] = DeepCopy(value) end
  end
  style.size = 100
  return style
end

local function DrawingCanvasPoints(elements, sourceIndex)
  local element = elements[sourceIndex]
  if not element or element.type ~= "drawing" or element.size == 0 then return {} end
  local x, y, rotation = ResolveElementTransform(elements, sourceIndex)
  local centerX, centerY = x / 100 * CANVAS_WIDTH, y / 100 * CANVAS_HEIGHT
  local width, height = ElementDimensions(element)
  local radians = (rotation or 0) * math.pi / 180
  local cosine, sine = math.cos(radians), math.sin(radians)
  local points = element.drawingPoints or {}
  if element.drawingMode == "point" or #points == 0 then points = { { 50, 50 } } end
  local canvasPoints = {}
  for _, point in ipairs(points) do
    local localX = point[1] / 100 * width - width / 2
    local localY = point[2] / 100 * height - height / 2
    local pixelX = centerX + localX * cosine - localY * sine
    local pixelY = centerY + localX * sine + localY * cosine
    canvasPoints[#canvasPoints + 1] = { pixelX / CANVAS_WIDTH * 100, pixelY / CANVAS_HEIGHT * 100 }
  end
  return canvasPoints
end

local function DensifyCanvasPolyline(points)
  if #points < 2 then return points end
  local dense = { { points[1][1], points[1][2] } }
  for index = 2, #points do
    local first, second = points[index - 1], points[index]
    local dx = (second[1] - first[1]) * CANVAS_WIDTH / 100
    local dy = (second[2] - first[2]) * CANVAS_HEIGHT / 100
    local steps = math.max(1, math.ceil(math.sqrt(dx * dx + dy * dy) / ERASER_SAMPLE_SPACING_PIXELS))
    for step = 1, steps do
      local ratio = step / steps
      dense[#dense + 1] = {
        first[1] + (second[1] - first[1]) * ratio,
        first[2] + (second[2] - first[2]) * ratio,
      }
    end
  end
  return dense
end

local function PointSegmentDistanceSquared(pointX, pointY, startX, startY, endX, endY)
  local dx, dy = endX - startX, endY - startY
  if dx == 0 and dy == 0 then
    local pointDX, pointDY = pointX - startX, pointY - startY
    return pointDX * pointDX + pointDY * pointDY
  end
  local ratio = Clamp(((pointX - startX) * dx + (pointY - startY) * dy) / (dx * dx + dy * dy), 0, 1)
  local nearestX, nearestY = startX + ratio * dx, startY + ratio * dy
  local pointDX, pointDY = pointX - nearestX, pointY - nearestY
  return pointDX * pointDX + pointDY * pointDY
end

local function PointTouchesEraser(point, eraserPixels, radiusSquared)
  local pointX, pointY = point[1] / 100 * CANVAS_WIDTH, point[2] / 100 * CANVAS_HEIGHT
  if #eraserPixels == 1 then
    local dx, dy = pointX - eraserPixels[1][1], pointY - eraserPixels[1][2]
    return dx * dx + dy * dy <= radiusSquared
  end
  for index = 2, #eraserPixels do
    local first, second = eraserPixels[index - 1], eraserPixels[index]
    if PointSegmentDistanceSquared(pointX, pointY, first[1], first[2], second[1], second[2]) <= radiusSquared then
      return true
    end
  end
  return false
end

local function EraseDrawingElement(elements, sourceIndex, eraserPixels)
  local element = elements[sourceIndex]
  local points = DrawingCanvasPoints(elements, sourceIndex)
  if #points == 0 then return nil, false end
  local dense = DensifyCanvasPolyline(points)
  local radius = ERASER_RADIUS_PIXELS + math.max(1, element.strokeWidth or 6) / 2
  local radiusSquared = radius * radius
  local pieces, current, touched = {}, {}, false
  local function FinishPiece()
    if #current > 0 then pieces[#pieces + 1] = DrawingElementFromCapture(current, DrawingRemainderStyle(element)) end
    current = {}
  end
  for _, point in ipairs(dense) do
    if PointTouchesEraser(point, eraserPixels, radiusSquared) then
      touched = true
      FinishPiece()
    else
      current[#current + 1] = point
    end
  end
  FinishPiece()
  return pieces, touched
end

local function EraseDrawingsAtCapture(plan, captured)
  local elements = plan and plan.elements
  if type(elements) ~= "table" or type(captured) ~= "table" or #captured == 0 then return 0, 0 end
  local eraserPixels = {}
  for _, point in ipairs(captured) do
    eraserPixels[#eraserPixels + 1] = { point[1] / 100 * CANVAS_WIDTH, point[2] / 100 * CANVAS_HEIGHT }
  end
  local replacements, oldToNew = {}, {}
  local touchedDrawings, remainderCount = 0, 0
  for sourceIndex, element in ipairs(elements) do
    if element.type == "drawing" then
      local pieces, touched = EraseDrawingElement(elements, sourceIndex, eraserPixels)
      if touched then
        touchedDrawings = touchedDrawings + 1
        oldToNew[sourceIndex - 1] = #pieces > 0 and #replacements or nil
        for _, piece in ipairs(pieces) do
          replacements[#replacements + 1] = piece
          remainderCount = remainderCount + 1
        end
      else
        oldToNew[sourceIndex - 1] = #replacements
        replacements[#replacements + 1] = element
      end
    else
      oldToNew[sourceIndex - 1] = #replacements
      replacements[#replacements + 1] = element
    end
  end
  if touchedDrawings == 0 then return 0, 0 end
  for _, element in ipairs(replacements) do
    for _, field in ipairs({ "pinnedTo", "facing" }) do
      if type(element[field]) == "number" then element[field] = oldToNew[element[field]] end
    end
  end
  plan.elements = replacements
  return touchedDrawings, remainderCount
end

MerfinPlus.BossPlanFreehandContract = {
  pointLimit = DRAWING_POINT_LIMIT,
  eraserRadiusPixels = ERASER_RADIUS_PIXELS,
  BuildElement = DrawingElementFromCapture,
  CoalesceLegacySegments = CoalesceLegacyDrawingSegments,
  EraseDrawings = EraseDrawingsAtCapture,
  RemoveElement = RemovePlanElement,
  RenderDrawing = RenderDrawing,
}

local function HideDrawPreview(viewer)
  if viewer.drawPreview then
    ResetElementFrame(viewer.drawPreview)
    viewer.drawPreview:Hide()
  end
end

local function RenderDrawPreview(viewer)
  local element = DrawingElementFromCapture(viewer.drawCapture)
  if not element then HideDrawPreview(viewer); return end
  local frame = viewer.drawPreview
  if not frame then
    frame = CreateFrame("Frame", nil, viewer.canvas)
    frame.mgmra4Regions, frame.mgmra4RegionPools, frame.mgmra4RegionCursors = {}, {}, {}
    frame.mgmra4EditHandles, frame.mgmra4RotationStem = {}, false
    if frame.EnableMouse then frame:EnableMouse(false) end
    viewer.drawPreview = frame
  end
  ResetElementFrame(frame)
  local width, height = ElementDimensions(element)
  frame:SetSize(math.max(1, width), math.max(1, height))
  frame:SetPoint("CENTER", viewer.canvas, "TOPLEFT", element.x / 100 * CANVAS_WIDTH, -(element.y / 100 * CANVAS_HEIGHT))
  frame:SetFrameLevel(viewer.canvas:GetFrameLevel() + 900)
  frame.mgmra4Rotation = 0
  RenderDrawing(frame, element, width, height)
  frame:Show()
end

local function AppendDrawCapture(viewer)
  if not viewer.drawCapture then return end
  local x, y = CursorCanvasPosition(viewer)
  local last = viewer.drawCapture[#viewer.drawCapture]
  if x and (math.abs(x - last[1]) + math.abs(y - last[2])) >= 0.08 then
    viewer.drawCapture[#viewer.drawCapture + 1] = { x, y }
    RenderDrawPreview(viewer)
  end
end

local function BeginDrawCapture(viewer)
  local x, y = CursorCanvasPosition(viewer)
  if not x then return end
  viewer.elementDrag, viewer.eraseCapture = false, false
  viewer.drawCapture = { { x, y } }
  ActivateEditorCapture(viewer, "draw")
  RenderDrawPreview(viewer)
end

local function AppendEraseCapture(viewer)
  if not viewer.eraseCapture then return end
  local x, y = CursorCanvasPosition(viewer)
  local last = viewer.eraseCapture[#viewer.eraseCapture]
  if x and (math.abs(x - last[1]) + math.abs(y - last[2])) >= 0.08 then
    viewer.eraseCapture[#viewer.eraseCapture + 1] = { x, y }
  end
end

local function BeginEraseCapture(viewer)
  local x, y = CursorCanvasPosition(viewer)
  if not x then return end
  viewer.elementDrag, viewer.drawCapture, viewer.arrowCapture = false, false, false
  viewer.eraseCapture = { { x, y } }
  ActivateEditorCapture(viewer, "erase")
end

local UpdateArrowCapture

local function BeginArrowCapture(viewer)
  local x, y = CursorCanvasPosition(viewer)
  if not x then return end
  viewer.elementDrag, viewer.drawCapture, viewer.eraseCapture = false, false, false
  viewer.arrowCapture = {
    startX = x, startY = y, endX = x, endY = y,
    style = DeepCopy(viewer.createTemplate or {}),
  }
  ActivateEditorCapture(viewer, "arrow")
  UpdateArrowCapture(viewer)
end

local function ArrowElementFromCapture(capture)
  if not capture then return nil end
  local deltaX, deltaY = capture.endX - capture.startX, capture.endY - capture.startY
  local pixelX = deltaX * CANVAS_WIDTH / 100
  local pixelY = deltaY * CANVAS_HEIGHT / 100
  local length = math.sqrt(pixelX * pixelX + pixelY * pixelY) / CANVAS_WIDTH * 100
  local style = capture.style or {}
  return {
    type = style.type == "line" and "line" or "arrow",
    -- MGMRA4 represents both endpoints losslessly as center + visual length +
    -- rotation. The end coordinate is reconstructed from these wire fields.
    x = (capture.startX + capture.endX) / 2,
    y = (capture.startY + capture.endY) / 2,
    arrowLength = length,
    rotation = Atan2(pixelY, pixelX) * 180 / math.pi,
    size = style.size == nil and 100 or style.size,
    color = style.color or style.strokeColor or "#ff4f52",
    strokeColor = style.strokeColor or style.color or "#ff4f52",
    strokeWidth = style.strokeWidth or 4,
    fillOpacity = style.fillOpacity == nil and 100 or style.fillOpacity,
  }
end

local function HideArrowPreview(viewer)
  if viewer.arrowPreview then
    ResetElementFrame(viewer.arrowPreview)
    viewer.arrowPreview:Hide()
  end
end

local function RenderArrowPreview(viewer)
  local element = ArrowElementFromCapture(viewer.arrowCapture)
  if not element or element.arrowLength < 0.02 then HideArrowPreview(viewer); return end
  local frame = viewer.arrowPreview
  if not frame then
    frame = CreateFrame("Frame", nil, viewer.canvas)
    frame.mgmra4Regions, frame.mgmra4RegionPools, frame.mgmra4RegionCursors = {}, {}, {}
    frame.mgmra4EditHandles, frame.mgmra4RotationStem = {}, false
    if frame.EnableMouse then frame:EnableMouse(false) end
    viewer.arrowPreview = frame
  end
  ResetElementFrame(frame)
  local width, height = ElementDimensions(element)
  frame:SetSize(math.max(1, width), math.max(1, height))
  frame:SetPoint("CENTER", viewer.canvas, "TOPLEFT", element.x / 100 * CANVAS_WIDTH, -(element.y / 100 * CANVAS_HEIGHT))
  frame:SetFrameLevel(viewer.canvas:GetFrameLevel() + 900)
  frame.mgmra4Rotation = element.rotation * math.pi / 180
  RenderArrow(frame, element, width, height)
  frame:Show()
end

UpdateArrowCapture = function(viewer)
  local capture = viewer.arrowCapture
  if not capture then return end
  local x, y = CursorCanvasPosition(viewer)
  if x then capture.endX, capture.endY = x, y end
  RenderArrowPreview(viewer)
end

local function FinishArrowCapture(viewer, commit)
  local capture = viewer.arrowCapture
  viewer.arrowCapture = false
  HideArrowPreview(viewer)
  ReleaseEditorCapture(viewer)
  if not commit or not capture then return end
  local element = ArrowElementFromCapture(capture)
  if not element or element.arrowLength < 0.2 then
    if viewer.SetStatus then viewer:SetStatus("Drag from start to end; no zero-length arrow or line was created.", "error") end
    return
  end
  viewer:AddElement(element.type, element.x, element.y, element)
end

local function FinishDrawCapture(viewer, commit, skipRender)
  local captured = viewer.drawCapture
  viewer.drawCapture = false
  HideDrawPreview(viewer)
  ReleaseEditorCapture(viewer)
  if not commit or not captured or #captured == 0 then return end
  -- One pointer gesture is one MGMRA4 element. Rendering still uses its
  -- sampled polyline, while selection, transforms, and persistence operate on
  -- the complete stroke; the eraser can later split that polyline geometrically.
  local element = DrawingElementFromCapture(captured, viewer.createTemplate)
  viewer.currentPlan.elements[#viewer.currentPlan.elements + 1] = element
  -- Freehand is a persistent paint tool: committing a stroke neither selects
  -- it nor leaves draw mode, so the next press immediately starts a new one.
  viewer.selectedElementIndex = false
  if viewer.StashCurrentDraft then viewer:StashCurrentDraft() end
  if not skipRender then viewer:Render(viewer.planIndex, true) end
end

local function FinishEraseCapture(viewer, commit, skipRender)
  local captured = viewer.eraseCapture
  viewer.eraseCapture = false
  ReleaseEditorCapture(viewer)
  if not commit or not captured or #captured == 0 then return end
  local touched, remainders = EraseDrawingsAtCapture(viewer.currentPlan, captured)
  viewer.selectedElementIndex = false
  if touched == 0 then
    if viewer.SetStatus then viewer:SetStatus("Eraser did not touch a freehand stroke.") end
    return
  end
  if viewer.StashCurrentDraft then viewer:StashCurrentDraft() end
  if not skipRender then viewer:Render(viewer.planIndex, true) end
  if viewer.SetStatus then
    viewer:SetStatus(string.format("Partially erased %d freehand stroke%s; %d remainder%s retained.",
      touched, touched == 1 and "" or "s", remainders, remainders == 1 and "" or "s"), "good")
  end
end

local function FinishEditorInteraction(viewer, skipRender)
  if viewer.elementDrag then FinishElementDrag(viewer, skipRender)
  elseif viewer.drawCapture then FinishDrawCapture(viewer, true, skipRender)
  elseif viewer.eraseCapture then FinishEraseCapture(viewer, true, skipRender)
  elseif viewer.arrowCapture then FinishArrowCapture(viewer, true)
  else ReleaseEditorCapture(viewer) end
end

local function CancelEditorInteraction(viewer, skipRender)
  if viewer.elementDrag then CancelElementDrag(viewer, skipRender)
  elseif viewer.drawCapture then FinishDrawCapture(viewer, false, skipRender)
  elseif viewer.eraseCapture then FinishEraseCapture(viewer, false, skipRender)
  elseif viewer.arrowCapture then FinishArrowCapture(viewer, false)
  else ReleaseEditorCapture(viewer) end
end

local function EnsureSelectionHandles(viewer, frame, element, sourceIndex)
  frame.mgmra4EditHandles = frame.mgmra4EditHandles or {}
  local specs = {
    { "TOPLEFT", "TOPLEFT" }, { "TOP", "TOP" }, { "TOPRIGHT", "TOPRIGHT" },
    { "RIGHT", "RIGHT" }, { "BOTTOMRIGHT", "BOTTOMRIGHT" }, { "BOTTOM", "BOTTOM" },
    { "BOTTOMLEFT", "BOTTOMLEFT" }, { "LEFT", "LEFT" },
  }
  local inverseScale = 1 / math.max(0.01, viewer.canvasScale or 1)
  for _, spec in ipairs(specs) do
    local direction, point = spec[1], spec[2]
    local handle = frame.mgmra4EditHandles[direction]
    if not handle then
      handle = CreateFrame("Button", nil, frame)
      handle.outer = handle:CreateTexture(nil, "OVERLAY")
      handle.outer:SetAllPoints()
      handle.outer:SetColorTexture(0.03, 0.04, 0.06, 1)
      handle.inner = handle:CreateTexture(nil, "OVERLAY")
      handle.inner:SetPoint("TOPLEFT", 2, -2)
      handle.inner:SetPoint("BOTTOMRIGHT", -2, 2)
      handle.inner:SetColorTexture(theme.accent[1], theme.accent[2], theme.accent[3], 1)
      frame.mgmra4EditHandles[direction] = handle
    end
    handle:ClearAllPoints()
    handle:SetPoint("CENTER", frame, point, 0, 0)
    if direction == "TOP" or direction == "BOTTOM" then handle:SetSize(14 * inverseScale, 8 * inverseScale)
    elseif direction == "LEFT" or direction == "RIGHT" then handle:SetSize(8 * inverseScale, 14 * inverseScale)
    else handle:SetSize(11 * inverseScale, 11 * inverseScale) end
    handle:SetFrameLevel(frame:GetFrameLevel() + 100)
    handle:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then BeginElementDrag(viewer, element, sourceIndex, "resize", direction, self, frame) end
    end)
    handle:SetScript("OnUpdate", nil)
    handle:SetScript("OnMouseUp", function(self, button)
      if button == "LeftButton" and viewer.elementDrag and viewer.elementDrag.handle == self then FinishElementDrag(viewer) end
    end)
    handle:Show()
  end
  local rotate = frame.mgmra4EditHandles.ROTATE
  if not rotate then
    rotate = CreateFrame("Button", nil, frame)
    rotate.icon = rotate:CreateTexture(nil, "OVERLAY")
    rotate.icon:SetAllPoints()
    SetTextureFiltered(rotate.icon, SYMBOL_ROOT .. "circle.tga")
    rotate.icon:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    frame.mgmra4EditHandles.ROTATE = rotate
    frame.mgmra4RotationStem = frame:CreateTexture(nil, "OVERLAY")
    frame.mgmra4RotationStem:SetColorTexture(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  end
  rotate:ClearAllPoints()
  rotate:SetPoint("BOTTOM", frame, "TOP", 0, 24 * inverseScale)
  rotate:SetSize(13 * inverseScale, 13 * inverseScale)
  rotate:SetFrameLevel(frame:GetFrameLevel() + 100)
  rotate:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then BeginElementDrag(viewer, element, sourceIndex, "rotate", "ROTATE", self, frame) end
  end)
  rotate:SetScript("OnUpdate", nil)
  rotate:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and viewer.elementDrag and viewer.elementDrag.handle == self then FinishElementDrag(viewer) end
  end)
  rotate:Show()
  frame.mgmra4RotationStem:ClearAllPoints()
  frame.mgmra4RotationStem:SetPoint("BOTTOM", frame, "TOP", 0, 0)
  frame.mgmra4RotationStem:SetSize(2 * inverseScale, 24 * inverseScale)
  frame.mgmra4RotationStem:Show()
end

local function AttachElementEditor(viewer, frame, element, sourceIndex)
  if not viewer.editing then return end
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnMouseDown", function(_, button)
    if button ~= "LeftButton" then return end
    if viewer.editorTool == "erase" then
      BeginEraseCapture(viewer)
      return
    end
    if viewer.editorTool == "draw" and viewer.createTemplate then
      BeginDrawCapture(viewer)
      return
    end
    viewer.selectedElementIndex = sourceIndex
    if viewer.editorTool ~= "select" and viewer.CompleteCreateTool then viewer:CompleteCreateTool() end
    if element.type == "text" and viewer.OpenTextEditor then viewer:OpenTextEditor(sourceIndex, true) end
    BeginElementDrag(viewer, element, sourceIndex, "move", nil, frame, frame)
    viewer:RefreshSelectedElement(true)
  end)
  frame:SetScript("OnUpdate", nil)
  frame:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" and viewer.elementDrag and viewer.elementDrag.handle == frame then FinishElementDrag(viewer) end
  end)
end

local function RenderElement(viewer, element, sourceIndex, elements)
  local frame = viewer.elementFrames[sourceIndex]
  if not frame then
    frame = CreateFrame("Frame", nil, viewer.canvas)
    frame.mgmra4Regions = {}
    frame.mgmra4RegionPools = {}
    frame.mgmra4RegionCursors = {}
    frame.mgmra4EditHandles = {}
    frame.mgmra4RotationStem = false
    viewer.elementFrames[sourceIndex] = frame
  end
  ResetElementFrame(frame)
  -- MGMRA4 preserves explicit size=0. The web renderer scales the complete
  -- element to zero, so keep its relationship coordinates but draw nothing.
  if element.size == 0 then return end
  local x, y, rotation = ResolveElementTransform(elements, sourceIndex)
  local width, height = ElementDimensions(element)
  frame:SetSize(math.max(1, width), math.max(1, height))
  if element.type == "drawing" and frame.SetHitRectInsets then
    local minimumHitSize = math.max(14, (element.strokeWidth or 6) + 8)
    local horizontalExpansion = math.max(0, (minimumHitSize - width) / 2)
    local verticalExpansion = math.max(0, (minimumHitSize - height) / 2)
    frame:SetHitRectInsets(-horizontalExpansion, -horizontalExpansion, -verticalExpansion, -verticalExpansion)
  end
  frame:SetPoint("CENTER", viewer.canvas, "TOPLEFT", x / 100 * CANVAS_WIDTH, -(y / 100 * CANVAS_HEIGHT))
  frame:SetFrameLevel(viewer.canvas:GetFrameLevel() + sourceIndex + 2)
  frame.mgmra4Element = element
  frame.mgmra4Rotation = rotation * math.pi / 180

  if element.type == "player" then
    local player = element.player or {}
    local token = CLASS_TOKENS[Normalize(player.class)]
    local iconPath
    if token and Normalize(player.spec) ~= "" then
      iconPath = MerfinPlus:GetRaidAssignmentSpecIconPath(token, player.spec)
    elseif token then
      iconPath = ADDON_ROOT .. "icons\\Classes\\" .. token .. ".tga"
    end
    local iconSize = 34 * (element.size or 100) / 100
    local icon = AddImage(frame, iconPath or "Interface\\Icons\\INV_Misc_QuestionMark", iconSize, iconSize)
    ApplyCircularIconMask(frame, icon, iconSize, iconSize)
    local labelElement = { textBold = true, textColor = CLASS_TONES[token] or "#c7d7eb", textSize = 11 * (element.size or 100) / 100, textAlign = "center" }
    local label = AddStyledText(frame, labelElement, player.name or "Player", width, 16, 11)
    label:ClearAllPoints()
    label:SetPoint("TOP", frame, "CENTER", 0, -(18 * (element.size or 100) / 100))
    if element.rolePosition and element.rolePositionVisible ~= false then AddNumberOverlay(frame, element.rolePosition, icon) end
    if not viewer.editing and not viewer.selfHighlightAssigned
      and PlayerNamesMatch(player.name, UnitName and UnitName("player")) then
      viewer.selfHighlightAssigned = true
      ShowCurrentPlayerHighlight(frame, width, height)
    end
  elseif element.type == "text" then
    AddStyledText(frame, element, element.label or "", width, height, 28)
  elseif element.type == "emoji" then
    local symbol = MerfinPlus:ResolveBossPlanSymbolAsset(element.type, element.assetId or element.label)
    AddImage(frame, symbol.runtimePath, width, height, true, symbol.texCoord)
  elseif element.type == "box" or element.type == "circle" or element.type == "triangle" or element.type == "cone" then
    AddShape(frame, element, width, height)
    if element.label and element.label ~= "" then
      AddStyledText(frame, element, element.label, width * 0.88, height * 0.88, 14)
    end
  elseif element.type == "arrow" or element.type == "arrow-down" or element.type == "line" then
    RenderArrow(frame, element, width, height)
  elseif element.type == "raid-marker" then
    local marker = RAID_MARKERS[Normalize(element.marker)]
    AddImage(frame, marker and ("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. marker) or "Interface\\Icons\\INV_Misc_QuestionMark", width, height)
  elseif element.type == "boss" or element.type == "image" then
    local facing = element.type == "boss" and BossFacingGeometry(width, height)
    local iconWidth = facing and facing.artworkSize or width
    local iconHeight = facing and facing.artworkSize or height
    local icon = AddImage(frame, ResolveIconPath(element) or "Interface\\Icons\\INV_Misc_QuestionMark",
      iconWidth, iconHeight, true, AdditionalWowIconTexCoord(element))
    if element.type == "boss" then ApplyCircularIconMask(frame, icon, iconWidth, iconHeight) end
    if element.type == "boss" and element.bossFacingVisible ~= false then
      local color = element.bossFacingColor or "#d7180b"
      local ringWidth = Clamp(element.bossFacingRingWidth == nil and 5 or element.bossFacingRingWidth, 1, 4)
      local radius = facing.radius
      local centerX, centerY = facing.centerX, facing.centerY
      local previousX, previousY
      for segment = 0, 16 do
        local angle = math.pi + (math.pi * segment / 16)
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        if previousX then AddLine(frame, previousX, previousY, x, y, ringWidth, color, 0.8, 3) end
        previousX, previousY = x, y
      end
      if element.bossFacingArrowVisible ~= false then
        local arrowHalfWidth = facing.artworkSize * (8 / 48)
        AddLine(frame, centerX, facing.arrowTipY, centerX - arrowHalfWidth,
          facing.arrowShoulderY, ringWidth, color, 0.8, 4)
        AddLine(frame, centerX, facing.arrowTipY, centerX + arrowHalfWidth,
          facing.arrowShoulderY, ringWidth, color, 0.8, 4)
      end
    end
    if element.rolePosition and element.rolePositionVisible ~= false then AddNumberOverlay(frame, element.rolePosition, icon) end
  elseif element.type == "drawing" then
    RenderDrawing(frame, element, width, height)
  end

  AttachElementEditor(viewer, frame, element, sourceIndex)
  if viewer.editing and viewer.selectedElementIndex == sourceIndex then
    AddLine(frame, 0, 0, width, 0, 2, "#ffd166", 1, 7)
    AddLine(frame, width, 0, width, height, 2, "#ffd166", 1, 7)
    AddLine(frame, width, height, 0, height, 2, "#ffd166", 1, 7)
    AddLine(frame, 0, height, 0, 0, 2, "#ffd166", 1, 7)
    EnsureSelectionHandles(viewer, frame, element, sourceIndex)
  end
  frame:Show()
end

local function PlanMatchesBoss(plan, selectedBossKey, selectedBossName)
  if (not selectedBossKey or selectedBossKey == "")
    and (not selectedBossName or selectedBossName == "")
  then
    return true
  end
  local planBoss = Normalize(plan.boss)
  if planBoss == "" then return false end
  local candidates = {}
  if selectedBossKey and selectedBossKey ~= "" then
    candidates[#candidates + 1] = selectedBossKey:match("::(.+)$") or selectedBossKey
  end
  if selectedBossName and selectedBossName ~= "" then
    candidates[#candidates + 1] = selectedBossName
  end
  for _, candidate in ipairs(candidates) do
    local selected = Normalize(candidate)
    if selected ~= "" and (planBoss == selected or selected:find(planBoss, 1, true) ~= nil) then
      return true
    end
  end
  return false
end

function MerfinPlus:GetRaidAssignmentBossPlansForSelection(groupID, selectedBossKey, selectedBossName)
  local entry = self:GetRaidAssignmentImportForGroup(groupID)
  local plans = entry and entry.parsed and entry.parsed.bossPlans or {}
  local matches = {}
  for _, plan in ipairs(plans) do
    if PlanMatchesBoss(plan, selectedBossKey, selectedBossName) then
      matches[#matches + 1] = plan
    end
  end
  if #matches == 0 and not selectedBossKey and #plans == 1 then
    matches[1] = plans[1]
  end
  return matches, entry
end

function MerfinPlus:HasRaidAssignmentBossPlan(groupID, selectedBossKey)
  local plans = self:GetRaidAssignmentBossPlansForSelection(groupID, selectedBossKey)
  return #plans > 0
end

function MerfinPlus:GetAssignmentWidgetBossPlanQuickSelection(groupID, selectedBossKey, selectedBossName)
  local plans, entry = self:GetRaidAssignmentBossPlansForSelection(groupID, selectedBossKey, selectedBossName)
  if entry and #plans > 0 then return plans, entry, "full" end
  if self.GetScopedRaidAssignmentBossPlanQuickSelection then
    plans, entry = self:GetScopedRaidAssignmentBossPlanQuickSelection(groupID, selectedBossKey)
    if entry and #plans > 0 then return plans, entry, "scoped" end
  end
  return {}, nil, nil
end

function MerfinPlus:GetAssignmentWidgetBossPlanQuickContext(raidEntry, boss)
  if not raidEntry or not boss or boss.isTrash then return nil end
  local groupID = raidEntry.raidGroup
  local selectedBossKey = boss.key or boss.name
  if not groupID or groupID == "" or not selectedBossKey or selectedBossKey == "" then return nil end
  local selectedBossName = boss.name
  local plans, planEntry = self:GetAssignmentWidgetBossPlanQuickSelection(
    groupID, selectedBossKey, selectedBossName
  )
  if not planEntry or #plans == 0 then return nil end
  local header = self:ResolveRaidAssignmentBossPlanHeader(planEntry, plans[1])
  return {
    groupID = groupID,
    selectedBossKey = selectedBossKey,
    selectedBossName = selectedBossName,
    bossIcon = header and header.icon or boss.icon,
  }
end

local function EnvelopeFingerprint(entry)
  local raw = tostring(entry and (entry.canonicalRaw or entry.mgmra4Raw) or "")
  local hash = 5381
  for index = 1, #raw do hash = (hash * 33 + raw:byte(index)) % 2147483647 end
  return tostring(entry and entry.contentSignature or "") .. ":" .. tostring(#raw) .. ":" .. tostring(hash)
end

local function PlanIdentity(plan, index)
  return table.concat({ Normalize(plan.raid), Normalize(plan.boss), tostring(plan.phase or 0), Normalize(plan.name), tostring(index) }, "|")
end

local function FindCanonicalBoss(entry, plan)
  local wanted = Normalize(plan and plan.boss)
  for _, boss in ipairs(entry and entry.parsed and entry.parsed.bosses or {}) do
    local key, name = Normalize(boss.key), Normalize(boss.name)
    if wanted == key or wanted == name or (wanted ~= "" and (key:find(wanted, 1, true) or wanted:find(key, 1, true))) then
      return boss
    end
  end
  return { name = plan and plan.boss or "Boss Plan" }
end

function MerfinPlus:ResolveRaidAssignmentBossPlanHeader(entry, plan)
  local boss = FindCanonicalBoss(entry, plan)
  local portrait
  local background = plan and plan.backgroundAssetId and self:GetTBCBossPlanAsset(plan.backgroundAssetId)
  if background and background.kind == "background" and background.encounter ~= "shared" then
    local primaryID = tostring(background.id):gsub("%.background%.[^.]+$", ".portrait.primary")
    portrait = self:GetTBCBossPlanAsset(primaryID)
  end
  if not portrait then
    local wantedRaid = Normalize((background and background.raid) or (plan and plan.raid))
    local wantedBosses = {
      Normalize(plan and plan.boss), Normalize(boss and boss.key), Normalize(boss and boss.name),
    }
    local function MatchesWantedBoss(asset)
      local candidates = { Normalize(asset.encounter) }
      for _, bossKey in ipairs(asset.bossKeys or {}) do candidates[#candidates + 1] = Normalize(bossKey) end
      for _, wanted in ipairs(wantedBosses) do
        if wanted ~= "" then
          for _, candidate in ipairs(candidates) do
            if wanted == candidate or candidate:find(wanted, 1, true) or wanted:find(candidate, 1, true) then
              return true
            end
          end
        end
      end
      return false
    end
    for _, asset in ipairs((self:GetTBCBossPlanAssetCatalog() or {}).assets or {}) do
      if asset.kind == "portrait" and asset.bundled ~= false
        and Normalize(asset.raid) == wantedRaid and MatchesWantedBoss(asset)
      then
        if not portrait or asset.variant == "primary" or asset.id:match("%.portrait%.primary$") then
          portrait = asset
        end
        if asset.variant == "primary" or asset.id:match("%.portrait%.primary$") then break end
      end
    end
  end
  local icon = portrait and portrait.runtimePath or boss.icon
  if not icon or tostring(icon):find("INV_Misc_QuestionMark", 1, true) then
    icon = portrait and portrait.runtimePath or "Interface\\Icons\\INV_Misc_QuestionMark"
  end
  return {
    name = boss.name or (plan and plan.boss) or "Boss Plan",
    icon = icon,
    assetId = portrait and portrait.id or nil,
    known = portrait ~= nil,
  }
end

local function CreateViewer(owner)
  local viewer = CreateFrame("Frame", "MerfinPlusBossPlanViewer", UIParent, template)
  viewer:SetFrameStrata("DIALOG")
  viewer:SetClampedToScreen(true)
  viewer:SetMovable(true)
  viewer.editing = false
  viewer.draftPlan = false
  viewer.pendingIncomingEntry = false
  viewer.selectedElementIndex = false
  viewer.elementDrag = false
  viewer.drawCapture = false
  viewer.drawPreview = false
  viewer.eraseCapture = false
  viewer.arrowCapture = false
  viewer.arrowPreview = false
  viewer.editorDragState = false
  viewer.editorTool = false
  viewer.createTemplate = false
  viewer.createAssetId = false
  viewer.paletteMode, viewer.paletteItems, viewer.palettePage = false, {}, 1
  viewer.bossPaletteItems = false
  viewer.textEditorMode, viewer.textEditorTargetIndex = false, false
  viewer.committingTextEdit = false
  if viewer.SetResizable then viewer:SetResizable(true) end
  viewer:EnableMouse(true)
  viewer:RegisterForDrag("LeftButton")

  viewer.dragCapture = CreateFrame("Frame", nil, UIParent)
  viewer.dragCapture:SetAllPoints(UIParent)
  viewer.dragCapture:SetFrameStrata("TOOLTIP")
  viewer.dragCapture:SetFrameLevel(10000)
  viewer.dragCapture:EnableMouse(true)
  viewer.dragCapture:EnableKeyboard(true)
  -- Keyboard input does not propagate by default.  Calling the setter while
  -- the viewer is first created in combat is protected on Anniversary.
  viewer.editorCaptureOnUpdate = function()
    if not viewer.elementDrag and not viewer.drawCapture and not viewer.eraseCapture and not viewer.arrowCapture then ReleaseEditorCapture(viewer); return end
    if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then FinishEditorInteraction(viewer); return end
    if viewer.elementDrag then UpdateElementDrag(viewer, viewer.elementDrag.frame)
    elseif viewer.drawCapture then AppendDrawCapture(viewer)
    elseif viewer.eraseCapture then AppendEraseCapture(viewer)
    elseif viewer.arrowCapture then UpdateArrowCapture(viewer) end
  end
  viewer.dragCapture:SetScript("OnUpdate", nil)
  viewer.dragCapture:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then FinishEditorInteraction(viewer) end
  end)
  viewer.dragCapture:SetScript("OnLeave", function() FinishEditorInteraction(viewer) end)
  viewer.dragCapture:SetScript("OnKeyDown", function(_, key)
    if key == "ESCAPE" then CancelEditorInteraction(viewer); viewer:SetEditorTool("select") end
  end)
  viewer.dragCapture:Hide()
  SetBackdrop(viewer, theme.canvas, theme.border)

  local function Button(parent, label, width, height)
    local button = CreateFrame("Button", nil, parent or viewer, template)
    button:SetSize(width, height or 25)
    button.normalBackground = theme.surface
    button.normalBorder = theme.borderSoft
    button.hoverBackground = theme.hover
    button.hoverBorder = theme.border
    SetBackdrop(button, button.normalBackground, button.normalBorder)
    button.label = button:CreateFontString(nil, "OVERLAY")
    button.label:SetFont(FONT_BOLD, 11, "")
    button.label:SetPoint("CENTER")
    button.label:SetText(label)
    button:SetScript("OnEnter", function(self)
      SetBackdrop(self, self.hoverBackground, self.hoverBorder)
    end)
    button:SetScript("OnLeave", function(self)
      SetBackdrop(self, self.normalBackground, self.normalBorder)
    end)
    return button
  end
  local function SetEnabled(button, enabled, tooltip)
    button.enabled = enabled == true
    button:SetAlpha(button.enabled and 1 or 0.42)
    local actionIcon = rawget(button, "actionIcon")
    if actionIcon and actionIcon.SetDesaturated then actionIcon:SetDesaturated(not button.enabled) end
    button.disabledReason = tooltip
  end
  local function IconButton(parent, iconPath, tooltip, size)
    local button = CreateFrame("Button", nil, parent, template)
    button:SetSize(size or 30, size or 30)
    SetBackdrop(button, theme.surface, theme.borderSoft)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint("TOPLEFT", 4, -4)
    button.icon:SetPoint("BOTTOMRIGHT", -4, 4)
    SetTextureFiltered(button.icon, iconPath)
    button.preserveIconColor = tostring(iconPath or ""):find("smiley", 1, true)
      or tostring(iconPath or ""):find("expressionless", 1, true)
      or tostring(iconPath or ""):find("UI%-RaidTargeting")
    button.tooltipText, button.baseTooltip = tooltip, tooltip
    button.SetActive = function(self, active)
      self.active = active == true
      SetBackdrop(self, self.active and theme.selected or theme.surface,
        self.active and theme.border or theme.borderSoft)
      local iconColor = rawget(self, "iconColor")
      if iconColor then self.icon:SetVertexColor(iconColor[1], iconColor[2], iconColor[3], 1)
      elseif rawget(self, "preserveIconColor") then self.icon:SetVertexColor(1, 1, 1, 1)
      else
        local color = self.active and theme.accentBright or theme.muted
        self.icon:SetVertexColor(color[1], color[2], color[3], 1)
      end
    end
    button:SetScript("OnEnter", function(self)
      SetBackdrop(self, theme.hover, theme.border)
      if not rawget(self, "preserveIconColor") and not rawget(self, "iconColor") then
        self.icon:SetVertexColor(theme.accentBright[1], theme.accentBright[2], theme.accentBright[3], 1)
      end
    end)
    button:SetScript("OnLeave", function(self)
      self:SetActive(self.active)
    end)
    return button
  end
  local function ActionTextureButton(parent, label, width, iconPath, tooltip)
    local button = Button(parent, label, width, 26)
    button.normalBackground = theme.surface
    button.normalBorder = theme.borderSoft
    button.hoverBackground = theme.hover
    button.hoverBorder = theme.border
    SetBackdrop(button, button.normalBackground, button.normalBorder)
    button.actionIcon = button:CreateTexture(nil, "ARTWORK")
    button.actionIcon:SetSize(16, 16)
    button.actionIcon:SetPoint("LEFT", button, "LEFT", 5, 0)
    button.label:ClearAllPoints()
    button.label:SetPoint("LEFT", button.actionIcon, "RIGHT", 4, 0)
    button.label:SetPoint("RIGHT", button, "RIGHT", -5, 0)
    button.label:SetJustifyH("CENTER")
    button.actionDescription = tooltip
    button.SetActionIcon = function(self, path)
      self.actionIconPath = path
      SetTextureFiltered(self.actionIcon, path)
    end
    button:SetActionIcon(iconPath)
    return button
  end
  local function OpenColorPicker(hex, alpha, callback)
    if not ColorPickerFrame then return end
    local red, green, blue = HexColor(hex, "#ffffff")
    local original = { red, green, blue, alpha }
    local function CurrentAlpha()
      if alpha == nil then return nil end
      if ColorPickerFrame.GetColorAlpha then return ColorPickerFrame:GetColorAlpha() end
      if OpacitySliderFrame and OpacitySliderFrame.GetValue then return 1 - OpacitySliderFrame:GetValue() end
      return alpha
    end
    local function Apply()
      local r, g, b = ColorPickerFrame:GetColorRGB()
      callback(HexFromRGB(r, g, b), CurrentAlpha())
    end
    if ColorPickerFrame.SetupColorPickerAndShow then
      ColorPickerFrame:SetupColorPickerAndShow({
        r = red, g = green, b = blue, hasOpacity = alpha ~= nil,
        opacity = alpha and (1 - alpha) or nil,
        swatchFunc = Apply, opacityFunc = Apply,
        cancelFunc = function() callback(HexFromRGB(original[1], original[2], original[3]), original[4]) end,
      })
    else
      ColorPickerFrame:Hide()
      ColorPickerFrame.hasOpacity = alpha ~= nil
      ColorPickerFrame.opacity = alpha and (1 - alpha) or 0
      ColorPickerFrame.previousValues = original
      ColorPickerFrame.func, ColorPickerFrame.opacityFunc = Apply, Apply
      ColorPickerFrame.cancelFunc = function() callback(HexFromRGB(original[1], original[2], original[3]), original[4]) end
      ColorPickerFrame:SetColorRGB(red, green, blue)
      ColorPickerFrame:Show()
    end
  end

  viewer.bossIcon = viewer:CreateTexture(nil, "ARTWORK")
  viewer.bossIcon:SetSize(32, 32)
  viewer.bossIcon:SetPoint("TOPLEFT", viewer, "TOPLEFT", 12, -7)
  viewer.bossName = viewer:CreateFontString(nil, "OVERLAY")
  viewer.bossName:SetFont(FONT_BOLD, 16, "OUTLINE")
  viewer.bossName:SetPoint("TOPLEFT", viewer.bossIcon, "TOPRIGHT", 8, 1)
  viewer.bossName:SetWidth(140)
  viewer.bossName:SetJustifyH("LEFT")
  viewer.planName = viewer:CreateFontString(nil, "OVERLAY")
  viewer.planName:SetFont(FONT_REGULAR, 11, "")
  viewer.planName:SetTextColor(0.72, 0.79, 0.88, 1)
  viewer.planName:SetPoint("TOPLEFT", viewer.bossName, "BOTTOMLEFT", 0, -3)
  viewer.planName:SetWidth(140)
  viewer.planName:SetJustifyH("LEFT")

  viewer.close = Button(viewer, "X", 26, 26)
  viewer.close.label:SetFont(FONT_BOLD, 15, "OUTLINE")
  viewer.close.hoverBackground = { 0.55, 0.02, 0.02, 0.95 }
  viewer.close.hoverBorder = { 0.92, 0.18, 0.12, 1 }
  viewer.close:SetPoint("TOPRIGHT", viewer, "TOPRIGHT", -7, -7)
  viewer.next = Button(viewer, "Next", 46, 24)
  viewer.previous = Button(viewer, "Previous", 64, 24)
  viewer.previous:SetPoint("RIGHT", viewer.next, "LEFT", -4, 0)
  viewer.dropdown = Button(viewer, "Choose Plan", 156, 24)
  viewer.dropdown:SetPoint("RIGHT", viewer.previous, "LEFT", -8, 0)
  viewer.dropdown.label:ClearAllPoints()
  viewer.dropdown.label:SetPoint("LEFT", viewer.dropdown, "LEFT", 8, 0)
  viewer.dropdown.label:SetPoint("RIGHT", viewer.dropdown, "RIGHT", -24, 0)
  viewer.dropdown.label:SetJustifyH("CENTER")
  viewer.dropdown.arrow = viewer.dropdown:CreateTexture(nil, "OVERLAY")
  viewer.dropdown.arrow:SetTexture(DROPDOWN_ARROW_TEXTURE)
  viewer.dropdown.arrow:SetSize(14, 14)
  viewer.dropdown.arrow:SetPoint("RIGHT", viewer.dropdown, "RIGHT", -5, 0)
  viewer.dropdown.arrow:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
  if viewer.dropdown.arrow.SetRotation then
    viewer.dropdown.arrow:SetRotation(math.pi)
  else
    viewer.dropdown.arrow:SetTexCoord(1, 0, 1, 0)
  end

  viewer.restore = ActionTextureButton(viewer, "Restore Default", 100,
    "Interface\\Icons\\Spell_Holy_Renew", "Restore the imported default for this plan")
  viewer.unlock = ActionTextureButton(viewer, "Unlock Editing", 108,
    "Interface\\Icons\\INV_Misc_Key_04", "Unlock this plan for local editing")
  viewer.save = ActionTextureButton(viewer, "Save", 58,
    "Interface\\Icons\\INV_Misc_Note_01", "Save this locally edited plan")
  viewer.send = ActionTextureButton(viewer, "Send", 58,
    "Interface\\Icons\\INV_Letter_15", "Send the selected saved plan")
  viewer.remove = ActionTextureButton(viewer, "Remove", 72,
    SYMBOL_ROOT .. "tool-delete.tga", "Remove the selected element")
  viewer.clear = ActionTextureButton(viewer, "Clear", 62,
    SYMBOL_ROOT .. "tool-eraser.tga", "Clear the local plan")
  viewer.headerActionButtons = { viewer.restore, viewer.unlock, viewer.save, viewer.send, viewer.remove, viewer.clear }
  viewer.inspector = CreateFrame("Frame", nil, viewer, template)
  viewer.inspector:SetSize(360, EDITOR_LAYOUT.contextPanelHeight)
  SetBackdrop(viewer.inspector, theme.surface, theme.borderSoft)
  viewer.inspectorLabel = viewer.inspector:CreateFontString(nil, "OVERLAY")
  viewer.inspectorLabel:SetFont(FONT_BOLD, 11, "")
  viewer.inspectorLabel:SetPoint("LEFT", 8, 0)
  viewer.inspectorLabel:SetWidth(70)
  viewer.inspectorLabel:SetJustifyH("LEFT")
  viewer.sizeMinus = Button(viewer.inspector, "−", 20, 20)
  viewer.sizeMinus:SetPoint("LEFT", viewer.inspectorLabel, "RIGHT", 4, 0)
  viewer.sizeValue = viewer.inspector:CreateFontString(nil, "OVERLAY")
  viewer.sizeValue:SetFont(FONT_BOLD, 10, "")
  viewer.sizeValue:SetPoint("LEFT", viewer.sizeMinus, "RIGHT", 3, 0)
  viewer.sizeValue:SetWidth(42)
  viewer.sizePlus = Button(viewer.inspector, "+", 20, 20)
  viewer.sizePlus:SetPoint("LEFT", viewer.sizeValue, "RIGHT", 3, 0)
  viewer.alphaMinus = Button(viewer.inspector, "−", 20, 20)
  viewer.alphaMinus:SetPoint("LEFT", viewer.sizePlus, "RIGHT", 8, 0)
  viewer.alphaValue = viewer.inspector:CreateFontString(nil, "OVERLAY")
  viewer.alphaValue:SetFont(FONT_BOLD, 10, "")
  viewer.alphaValue:SetPoint("LEFT", viewer.alphaMinus, "RIGHT", 3, 0)
  viewer.alphaValue:SetWidth(50)
  viewer.alphaPlus = Button(viewer.inspector, "+", 20, 20)
  viewer.alphaPlus:SetPoint("LEFT", viewer.alphaValue, "RIGHT", 3, 0)
  viewer.fillColor = IconButton(viewer.inspector, SYMBOL_ROOT .. "circle.tga", "Fill color and alpha", 22)
  viewer.fillColor:SetPoint("LEFT", viewer.alphaPlus, "RIGHT", 8, 0)
  viewer.borderColor = IconButton(viewer.inspector, SYMBOL_ROOT .. "tool-box.tga", "Border or stroke color", 22)
  viewer.borderColor:SetPoint("LEFT", viewer.fillColor, "RIGHT", 5, 0)
  viewer.borderWidthMinus = Button(viewer.inspector, "−", 20, 20)
  viewer.borderWidthValue = viewer.inspector:CreateFontString(nil, "OVERLAY")
  viewer.borderWidthValue:SetFont(FONT_BOLD, 10, "")
  viewer.borderWidthValue:SetWidth(82)
  viewer.borderWidthPlus = Button(viewer.inspector, "+", 20, 20)
  viewer.textEdit = CreateFrame("EditBox", nil, viewer.inspector, template)
  viewer.textEdit:SetSize(110, 20)
  viewer.textEdit:SetPoint("LEFT", viewer.borderColor, "RIGHT", 8, 0)
  viewer.textEdit:SetAutoFocus(false)
  viewer.textEdit:SetFont(FONT_REGULAR, 11, "")
  viewer.textEdit:SetTextInsets(5, 5, 0, 0)
  SetBackdrop(viewer.textEdit, theme.surfaceRaised, theme.borderSoft)
  viewer.textApply = Button(viewer.inspector, "Apply", 62, 20)
  viewer.textCancel = Button(viewer.inspector, "Cancel", 62, 20)
  viewer.fontPicker = Button(viewer.inspector, "Font: Roboto", 132, 20)
  viewer.fontSizeMinus = Button(viewer.inspector, "−", 18, 20)
  viewer.fontSizeMinus.tooltipText = "Decrease text font size"
  viewer.fontSizeValue = viewer.inspector:CreateFontString(nil, "OVERLAY")
  viewer.fontSizeValue:SetFont(FONT_BOLD, 10, "")
  viewer.fontSizeValue:SetWidth(58)
  viewer.fontSizePlus = Button(viewer.inspector, "+", 18, 20)
  viewer.fontSizePlus.tooltipText = "Increase text font size"
  -- The picker must outlive the compact header inspector's clipping/layering.
  -- It is owned by the viewer so it can open over the plan, not behind it.
  viewer.fontMenu = CreateFrame("Frame", nil, viewer, template)
  viewer.fontMenu:SetFrameStrata("TOOLTIP")
  viewer.fontMenu:SetFrameLevel(viewer:GetFrameLevel() + 500)
  viewer.fontMenu:SetSize(132, #FONT_CHOICES * 22 + 4)
  SetBackdrop(viewer.fontMenu, theme.surface, theme.borderSoft)
  viewer.fontRows = {}
  for index, choice in ipairs(FONT_CHOICES) do
    local row = Button(viewer.fontMenu, choice.token, 124, 20)
    row:SetPoint("TOPLEFT", viewer.fontMenu, "TOPLEFT", 4, -2 - ((index - 1) * 22))
    owner:SafeSetFontPath(row.label, choice.path, 10, "")
    row.fontChoice = choice
    viewer.fontRows[index] = row
  end
  viewer.fontMenu:Hide()
  viewer.emojiSmile = IconButton(viewer.inspector, SYMBOL_ROOT .. "smiley.tga", "Smiley", 22)
  viewer.emojiFlat = IconButton(viewer.inspector, SYMBOL_ROOT .. "expressionless.tga", "Expressionless face", 22)
  viewer.emojiSmile:SetPoint("LEFT", viewer.borderColor, "RIGHT", 8, 0)
  viewer.emojiFlat:SetPoint("LEFT", viewer.emojiSmile, "RIGHT", 4, 0)
  viewer.colorSwatches = {}
  for index, color in ipairs(EDITOR_COLOR_PALETTE) do
    local swatch = IconButton(viewer.inspector, WHITE_TEXTURE, color.label .. " color", 22)
    swatch.preserveIconColor = true
    swatch.colorHex = color.hex
    local red, green, blue = HexColor(color.hex)
    swatch.iconColor = { red, green, blue }
    swatch.icon:SetVertexColor(red, green, blue, 1)
    viewer.colorSwatches[index] = swatch
  end
  viewer.status = viewer:CreateFontString(nil, "OVERLAY")
  viewer.status:SetFont(FONT_REGULAR, 11, "")
  viewer.status:SetTextColor(0.65, 0.78, 0.92, 1)
  viewer.status:SetPoint("TOPLEFT", viewer, "TOPLEFT", 16, -151)
  viewer.status:SetPoint("TOPRIGHT", viewer, "TOPRIGHT", -16, -151)
  viewer.status:SetJustifyH("LEFT")
  -- Editor state is represented by the active tool and inspector.
  viewer.status:Hide()

  viewer.canvas = CreateFrame("Frame", nil, viewer)
  viewer.canvas:SetSize(CANVAS_WIDTH, CANVAS_HEIGHT)
  viewer.canvas:SetPoint("BOTTOMLEFT", viewer, "BOTTOMLEFT", 14, 14)
  viewer.canvas:EnableMouse(true)
  viewer.background = viewer.canvas:CreateTexture(nil, "BACKGROUND")
  viewer.background:SetAllPoints(viewer.canvas)
  viewer.background:SetTexCoord(0, 1, 0, 1)
  if viewer.background.SetSnapToPixelGrid then viewer.background:SetSnapToPixelGrid(false) end
  if viewer.background.SetTexelSnappingBias then viewer.background:SetTexelSnappingBias(0) end
  viewer.elementFrames = {}

  for _, navigationButton in ipairs({ viewer.dropdown, viewer.previous, viewer.next }) do
    navigationButton:SetParent(viewer.canvas)
    navigationButton:SetFrameLevel(viewer.canvas:GetFrameLevel() + 420)
  end

  -- Editing chrome lives on the plan itself: tools hug the upper-left edge,
  -- while the selected tool's compact settings strip opens centered below it.
  viewer.toolbar = CreateFrame("Frame", nil, viewer.canvas)
  viewer.toolbar:SetHeight(EDITOR_LAYOUT.toolbarHeight)
  viewer.toolbar:SetPoint("TOPLEFT", viewer.canvas, "TOPLEFT", 10, -10)
  viewer.toolbar:SetWidth(1)
  viewer.toolbar:SetFrameLevel(viewer.canvas:GetFrameLevel() + 410)
  viewer.toolbarContent = CreateFrame("Frame", nil, viewer.toolbar)
  viewer.toolbarContent:SetAllPoints(viewer.toolbar)
  viewer.toolButtons = {}
  local tools = {
    { "Select and edit", "select", SYMBOL_ROOT .. "tool-select.tga" },
    { "Place text", "text", SYMBOL_ROOT .. "tool-text.tga" },
    { "Place smiley", "emoji", SYMBOL_ROOT .. "smiley.tga" },
    { "Place raid marker", "raid-marker", SYMBOL_ROOT .. "tool-marker.tga" },
    { "Place boss portrait", "boss", ADDON_ROOT .. "bosses\\tbc\\catalog\\serpentshrine-cavern\\hydross\\primary.blp" },
    { "Place class or spec icon", "class-spec", ADDON_ROOT .. "icons\\Classes\\DRUID.tga" },
    { "Place role icon", "role", ADDON_ROOT .. "icons\\Roles\\tank.tga" },
    { "Place circle", "circle", SYMBOL_ROOT .. "circle.tga" },
    { "Place box", "box", SYMBOL_ROOT .. "tool-box.tga" },
    { "Drag an arrow", "arrow", SYMBOL_ROOT .. "tool-arrow.tga" },
    { "Drag a line", "line", SYMBOL_ROOT .. "tool-arrow.tga" },
    { "Freehand draw", "draw", SYMBOL_ROOT .. "tool-brush.tga" },
    { "Partially erase freehand", "erase", SYMBOL_ROOT .. "tool-eraser.tga" },
  }
  for index, spec in ipairs(tools) do
    local button = IconButton(viewer.toolbarContent, spec[3], spec[1], EDITOR_LAYOUT.toolButtonSize)
    button:SetPoint("TOPLEFT", viewer.toolbarContent, "TOPLEFT",
      (index - 1) * (EDITOR_LAYOUT.toolButtonSize + EDITOR_LAYOUT.toolButtonGap), 0)
    button.tool = spec[2]
    viewer.toolButtons[#viewer.toolButtons + 1] = button
  end

  viewer.inspector:SetParent(viewer.canvas)
  viewer.inspector:ClearAllPoints()
  viewer.inspector:SetPoint("TOP", viewer.canvas, "TOP", 0, -EDITOR_LAYOUT.contextPanelTop)
  viewer.inspector:SetWidth(360)
  viewer.inspector:SetHeight(EDITOR_LAYOUT.contextPanelHeight)
  viewer.inspector:SetFrameLevel(viewer.canvas:GetFrameLevel() + 400)
  viewer.inspectorLabel:ClearAllPoints()
  viewer.inspectorLabel:SetPoint("LEFT", viewer.inspector, "LEFT", 4, 0)
  viewer.inspectorLabel:SetWidth(52)
  viewer.inspectorLabel:Show()
  viewer.sizeMinus:SetSize(18, 20); viewer.sizeMinus:ClearAllPoints(); viewer.sizeMinus:SetPoint("LEFT", viewer.inspector, "LEFT", 58, 0)
  viewer.sizeValue:ClearAllPoints(); viewer.sizeValue:SetPoint("LEFT", viewer.sizeMinus, "RIGHT", 2, 0); viewer.sizeValue:SetWidth(50)
  viewer.sizePlus:SetSize(18, 20); viewer.sizePlus:ClearAllPoints(); viewer.sizePlus:SetPoint("LEFT", viewer.sizeValue, "RIGHT", 2, 0)
  viewer.alphaMinus:SetSize(18, 20); viewer.alphaMinus:ClearAllPoints(); viewer.alphaMinus:SetPoint("LEFT", viewer.sizePlus, "RIGHT", 4, 0)
  viewer.alphaValue:ClearAllPoints(); viewer.alphaValue:SetPoint("LEFT", viewer.alphaMinus, "RIGHT", 2, 0); viewer.alphaValue:SetWidth(42)
  viewer.alphaPlus:SetSize(18, 20); viewer.alphaPlus:ClearAllPoints(); viewer.alphaPlus:SetPoint("LEFT", viewer.alphaValue, "RIGHT", 2, 0)
  viewer.fillColor:SetSize(22, 22); viewer.fillColor:ClearAllPoints(); viewer.fillColor:SetPoint("LEFT", viewer.alphaPlus, "RIGHT", 4, 0)
  viewer.borderColor:SetSize(22, 22)
  viewer.borderColor:ClearAllPoints(); viewer.borderColor:SetPoint("LEFT", viewer.fillColor, "RIGHT", 3, 0)
  viewer.borderWidthMinus:SetSize(18, 20); viewer.borderWidthMinus:ClearAllPoints(); viewer.borderWidthMinus:SetPoint("LEFT", viewer.borderColor, "RIGHT", 4, 0)
  viewer.borderWidthValue:ClearAllPoints()
  viewer.borderWidthValue:SetPoint("LEFT", viewer.borderWidthMinus, "RIGHT", 2, 0)
  viewer.borderWidthValue:SetWidth(42)
  viewer.borderWidthPlus:SetSize(18, 20)
  viewer.borderWidthPlus:ClearAllPoints()
  viewer.borderWidthPlus:SetPoint("LEFT", viewer.borderWidthValue, "RIGHT", 2, 0)
  -- Text editing starts after the size controls; never overlap them.
  viewer.textEdit:SetSize(140, 20); viewer.textEdit:ClearAllPoints(); viewer.textEdit:SetPoint("LEFT", viewer.sizePlus, "RIGHT", 12, 0)
  viewer.textApply:SetSize(50, 20); viewer.textApply:ClearAllPoints(); viewer.textApply:SetPoint("LEFT", viewer.textEdit, "RIGHT", 4, 0)
  viewer.textCancel:SetSize(50, 20)
  viewer.textCancel:ClearAllPoints()
  viewer.textCancel:SetPoint("LEFT", viewer.textApply, "RIGHT", 4, 0)
  viewer.fontPicker:SetSize(98, 20); viewer.fontPicker:ClearAllPoints(); viewer.fontPicker:SetPoint("LEFT", viewer.textCancel, "RIGHT", 4, 0)
  viewer.fontSizeMinus:ClearAllPoints(); viewer.fontSizeMinus:SetPoint("LEFT", viewer.fontPicker, "RIGHT", 4, 0)
  viewer.fontSizeValue:ClearAllPoints(); viewer.fontSizeValue:SetPoint("LEFT", viewer.fontSizeMinus, "RIGHT", 2, 0)
  viewer.fontSizePlus:ClearAllPoints(); viewer.fontSizePlus:SetPoint("LEFT", viewer.fontSizeValue, "RIGHT", 2, 0)
  viewer.fontMenu:ClearAllPoints(); viewer.fontMenu:SetPoint("TOPLEFT", viewer.fontPicker, "BOTTOMLEFT", 0, -2)
  viewer.emojiSmile:ClearAllPoints(); viewer.emojiSmile:SetPoint("LEFT", viewer.inspector, "LEFT", 58, 0)
  viewer.emojiFlat:ClearAllPoints(); viewer.emojiFlat:SetPoint("LEFT", viewer.emojiSmile, "RIGHT", 5, 0)
  viewer.paletteScroll = CreateFrame("ScrollFrame", nil, viewer.inspector)
  viewer.paletteScroll:SetPoint("TOPLEFT", viewer.inspector, "TOPLEFT", 6, -6)
  viewer.paletteScroll:SetPoint("BOTTOMRIGHT", viewer.inspector, "BOTTOMRIGHT", -6, 6)
  viewer.paletteScroll:EnableMouseWheel(true)
  viewer.paletteChild = CreateFrame("Frame", nil, viewer.paletteScroll)
  viewer.paletteChild:SetSize(1, EDITOR_LAYOUT.paletteIconSize)
  viewer.paletteScroll:SetScrollChild(viewer.paletteChild)
  viewer.paletteButtons = {}
  for index = 1, 42 do
    local paletteButton = IconButton(viewer.paletteChild, "Interface\\Icons\\INV_Misc_QuestionMark", "Asset",
      EDITOR_LAYOUT.paletteIconSize)
    paletteButton:SetPoint("TOPLEFT", viewer.paletteChild, "TOPLEFT",
      (index - 1) * (EDITOR_LAYOUT.paletteIconSize + EDITOR_LAYOUT.toolButtonGap), 0)
    viewer.paletteButtons[index] = paletteButton
  end
  viewer.palettePrevious = Button(viewer.inspector, "◀", 28, 20); viewer.palettePrevious:Hide()
  viewer.palettePageText = viewer.inspector:CreateFontString(nil, "OVERLAY")
  viewer.palettePageText:SetFont(FONT_BOLD, 10, "")
  viewer.palettePageText:Hide()
  viewer.paletteNext = Button(viewer.inspector, "▶", 28, 20); viewer.paletteNext:Hide()

  function viewer:LayoutInspectorControls()
    if self.paletteScroll:IsShown() then return end
    local controls = {
      self.inspectorLabel, self.sizeMinus, self.sizeValue, self.sizePlus,
      self.alphaMinus, self.alphaValue, self.alphaPlus, self.fillColor, self.borderColor,
      self.borderWidthMinus, self.borderWidthValue, self.borderWidthPlus,
      self.textEdit, self.textApply, self.textCancel, self.fontPicker,
      self.fontSizeMinus, self.fontSizeValue, self.fontSizePlus,
      self.emojiSmile, self.emojiFlat,
    }
    for _, swatch in ipairs(self.colorSwatches or {}) do controls[#controls + 1] = swatch end
    local visible, totalWidth, gap = {}, 0, 4
    for _, control in ipairs(controls) do
      if control:IsShown() then
        local controlWidth = math.max(1, control:GetWidth() or 1)
        visible[#visible + 1] = control
        totalWidth = totalWidth + controlWidth + (#visible > 1 and gap or 0)
      end
    end
    local width = Clamp(totalWidth + 16, 140, 940)
    local available = width - 16
    local x, y, rowHeight, rows = 8, 6, 22, 1
    for _, control in ipairs(visible) do
      local controlWidth = math.max(1, control:GetWidth() or 1)
      if x > 8 and x - 8 + controlWidth > available then
        x, y, rows = 8, y + rowHeight + 2, rows + 1
      end
      control:ClearAllPoints()
      control:SetPoint("TOPLEFT", self.inspector, "TOPLEFT", x, -y)
      x = x + controlWidth + gap
    end
    self.inspector:ClearAllPoints()
    self.inspector:SetPoint("TOP", self.canvas, "TOP", 0, -EDITOR_LAYOUT.contextPanelTop)
    self.inspector:SetSize(width, rows * rowHeight + 12 + ((rows - 1) * 2))
    self.fontMenu:ClearAllPoints()
    self.fontMenu:SetPoint("TOPLEFT", self.fontPicker, "BOTTOMLEFT", 0, -2)
  end

  function viewer:LayoutPalette()
    if not self.paletteScroll:IsShown() then return end
    local iconSize, gap = EDITOR_LAYOUT.paletteIconSize, EDITOR_LAYOUT.toolButtonGap
    local itemCount = math.max(1, #(self.paletteItems or {}))
    local contentWidth = itemCount * (iconSize + gap) - gap
    local width = Clamp(contentWidth + 12, iconSize + 12, EDITOR_LAYOUT.contextPanelMaxWidth)
    self.inspector:ClearAllPoints()
    self.inspector:SetPoint("TOP", self.canvas, "TOP", 0, -EDITOR_LAYOUT.contextPanelTop)
    self.inspector:SetSize(width, iconSize + 12)
    self.paletteChild:SetSize(contentWidth, iconSize)
    for index, button in ipairs(self.paletteButtons) do
      button:ClearAllPoints()
      button:SetPoint("TOPLEFT", self.paletteChild, "TOPLEFT", (index - 1) * (iconSize + gap), 0)
    end
  end

  function viewer:LayoutEditorChrome()
    local width = math.max((CANVAS_WIDTH * MIN_VIEWER_SCALE) + VIEWER_HORIZONTAL_CHROME, self:GetWidth() or 0)
    local identityWidth = Clamp(math.floor(width * 0.17), 120, 185)
    self.bossName:SetWidth(identityWidth)
    self.planName:SetWidth(identityWidth)

    local x, y = 52 + identityWidth + 6, 9
    local function PlaceHeaderButton(button)
      button:ClearAllPoints()
      button:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
      x = x + (button:GetWidth() or 0)
    end
    for _, button in ipairs(self.headerActionButtons) do PlaceHeaderButton(button) end
    self.headerFlowRows = 1

    self.next:ClearAllPoints()
    self.next:SetPoint("TOPRIGHT", self.canvas, "TOPRIGHT", -10, -10)
    self.previous:ClearAllPoints()
    self.previous:SetPoint("RIGHT", self.next, "LEFT", -3, 0)
    self.dropdown:ClearAllPoints()
    self.dropdown:SetPoint("RIGHT", self.previous, "LEFT", -6, 0)

    local toolSize, toolGap = EDITOR_LAYOUT.toolButtonSize, EDITOR_LAYOUT.toolButtonGap
    local toolbarWidth = (#self.toolButtons * toolSize) + (math.max(0, #self.toolButtons - 1) * toolGap)
    self.toolbar:SetSize(toolbarWidth, EDITOR_LAYOUT.toolbarHeight)
    self.toolbarContent:SetSize(toolbarWidth, EDITOR_LAYOUT.toolbarHeight)
    for index, button in ipairs(self.toolButtons) do
      button:ClearAllPoints()
      button:SetPoint("TOPLEFT", self.toolbarContent, "TOPLEFT", (index - 1) * (toolSize + toolGap), -1)
    end
    self.inspector:ClearAllPoints()
    self.inspector:SetPoint("TOP", self.canvas, "TOP", 0, -EDITOR_LAYOUT.contextPanelTop)
    if self.paletteScroll:IsShown() then self:LayoutPalette() else self:LayoutInspectorControls() end
  end

  local validAnchors = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true,
    RIGHT = true, BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
  }
  local function GeometryStorage()
    local storage = owner:GetRaidAssignmentStorage()
    storage.bossPlanViewerGeometry = storage.bossPlanViewerGeometry or {}
    return storage.bossPlanViewerGeometry
  end
  local function EditStorage()
    local storage = owner:GetRaidAssignmentStorage()
    storage.bossPlanLocalEdits = storage.bossPlanLocalEdits or {}
    return storage.bossPlanLocalEdits
  end
  local function WorkingDraftStorage()
    local storage = owner:GetRaidAssignmentStorage()
    storage.bossPlanWorkingDrafts = storage.bossPlanWorkingDrafts or {}
    return storage.bossPlanWorkingDrafts
  end
  local function MaximumViewerScale()
    local screenWidth = UIParent and UIParent.GetWidth and UIParent:GetWidth() or 1920
    local screenHeight = UIParent and UIParent.GetHeight and UIParent:GetHeight() or 1080
    return math.max(MIN_VIEWER_SCALE, math.min(MAX_VIEWER_SCALE,
      (screenWidth - 40 - VIEWER_HORIZONTAL_CHROME) / CANVAS_WIDTH,
      (screenHeight - 40 - VIEWER_VERTICAL_CHROME) / CANVAS_HEIGHT))
  end
  local function SaveGeometry()
    local geometry = GeometryStorage()
    local point, _, relativePoint, x, y = viewer:GetPoint(1)
    geometry.scale = viewer.canvasScale or 1
    geometry.point = validAnchors[point] and point or "CENTER"
    geometry.relativePoint = validAnchors[relativePoint] and relativePoint or geometry.point
    geometry.x, geometry.y = tonumber(x) or 0, tonumber(y) or 0
  end
  local function ApplyScale(requestedScale, persist)
    local scale = Clamp(requestedScale, MIN_VIEWER_SCALE, MaximumViewerScale())
    viewer.applyingGeometry = true
    viewer.canvasScale = scale
    viewer.canvas:SetScale(scale)
    viewer:SetSize((CANVAS_WIDTH * scale) + VIEWER_HORIZONTAL_CHROME, (CANVAS_HEIGHT * scale) + VIEWER_VERTICAL_CHROME)
    viewer:LayoutEditorChrome()
    viewer.applyingGeometry = nil
    if persist then SaveGeometry() end
  end

  local maximumScale = MaximumViewerScale()
  if viewer.SetResizeBounds then
    viewer:SetResizeBounds((CANVAS_WIDTH * MIN_VIEWER_SCALE) + VIEWER_HORIZONTAL_CHROME,
      (CANVAS_HEIGHT * MIN_VIEWER_SCALE) + VIEWER_VERTICAL_CHROME,
      (CANVAS_WIDTH * maximumScale) + VIEWER_HORIZONTAL_CHROME,
      (CANVAS_HEIGHT * maximumScale) + VIEWER_VERTICAL_CHROME)
  end
  viewer:SetScript("OnSizeChanged", function(_, width, height)
    if viewer.applyingGeometry then return end
    ApplyScale(math.min((width - VIEWER_HORIZONTAL_CHROME) / CANVAS_WIDTH,
      (height - VIEWER_VERTICAL_CHROME) / CANVAS_HEIGHT), false)
    viewer:LayoutEditorChrome()
  end)
  viewer:SetScript("OnDragStart", function() viewer:StartMoving() end)
  viewer:SetScript("OnDragStop", function() viewer:StopMovingOrSizing(); SaveGeometry() end)
  viewer:SetScript("OnHide", function()
    CancelEditorInteraction(viewer, true)
    viewer:StopMovingOrSizing()
    if viewer.StashCurrentDraft then viewer:StashCurrentDraft() end
    SaveGeometry()
    viewer.dropdownMenu:Hide()
    viewer.background:SetTexture(nil)
    HideArrowPreview(viewer)
    for _, frame in ipairs(viewer.elementFrames) do ResetElementFrame(frame) end
    if owner.CancelActiveBossPlanDelivery then owner:CancelActiveBossPlanDelivery() end
  end)

  viewer.resizeHandle = CreateFrame("Button", nil, viewer)
  viewer.resizeHandle:SetSize(22, 22)
  viewer.resizeHandle:SetPoint("BOTTOMRIGHT", viewer, "BOTTOMRIGHT", -3, 3)
  for index = 0, 2 do
    local line = viewer.resizeHandle:CreateTexture(nil, "OVERLAY")
    line:SetTexture(WHITE_TEXTURE)
    line:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.9)
    line:SetSize(12 - (index * 3), 1.5)
    line:SetPoint("BOTTOMRIGHT", viewer.resizeHandle, "BOTTOMRIGHT", -2, 4 + (index * 4))
    if line.SetRotation then line:SetRotation(math.pi / 4) end
  end
  viewer.resizeHandle:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then viewer:StartSizing("BOTTOMRIGHT") end end)
  viewer.resizeHandle:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then viewer:StopMovingOrSizing(); ApplyScale(viewer.canvasScale, true) end
  end)

  viewer.dropdownMenu = CreateFrame("Frame", nil, UIParent, template)
  viewer.dropdownMenu:SetFrameStrata("TOOLTIP")
  viewer.dropdownMenu:SetWidth(260)
  SetBackdrop(viewer.dropdownMenu, theme.surface, theme.border)
  viewer.dropdownMenu.items = {}
  viewer.dropdownMenu:Hide()

  viewer.confirmation = CreateFrame("Frame", nil, viewer, template)
  viewer.confirmation:SetFrameStrata("TOOLTIP")
  viewer.confirmation:SetSize(390, 104)
  viewer.confirmation:SetPoint("CENTER", viewer, "CENTER", 0, 0)
  SetBackdrop(viewer.confirmation, theme.surface, theme.border)
  viewer.confirmation.text = viewer.confirmation:CreateFontString(nil, "OVERLAY")
  viewer.confirmation.text:SetFont(FONT_REGULAR, 13, "")
  viewer.confirmation.text:SetPoint("TOPLEFT", 16, -16)
  viewer.confirmation.text:SetPoint("TOPRIGHT", -16, -16)
  viewer.confirmation.text:SetJustifyH("LEFT")
  viewer.confirmation.text:SetWordWrap(true)
  viewer.confirmation.accept = Button(viewer.confirmation, "Confirm", 72, 24)
  viewer.confirmation.accept:SetPoint("BOTTOMRIGHT", viewer.confirmation, "BOTTOMRIGHT", -92, 12)
  viewer.confirmation.cancel = Button(viewer.confirmation, "Cancel", 72, 24)
  viewer.confirmation.cancel:SetPoint("LEFT", viewer.confirmation.accept, "RIGHT", 8, 0)
  viewer.confirmation.cancel:SetScript("OnClick", function() viewer.confirmation:Hide() end)
  viewer.confirmation:Hide()

  function viewer:SetStatus(text, tone)
    self.status:SetText(text or "")
    if tone == "error" then self.status:SetTextColor(1, 0.35, 0.35, 1)
    elseif tone == "good" then self.status:SetTextColor(0.35, 1, 0.55, 1)
    else self.status:SetTextColor(0.65, 0.78, 0.92, 1) end
    self.status:Hide()
  end
  function viewer:Confirm(text, callback)
    self.confirmation.text:SetText(text)
    self.confirmation.accept:SetScript("OnClick", function()
      self.confirmation:Hide()
      callback()
    end)
    self.confirmation:Show()
  end

  function viewer:GetSourceKey() return EnvelopeFingerprint(self.entry) end
  function viewer:GetPlanKey(index)
    return PlanIdentity(self.sourcePlans[index], self.sourcePlanGlobalIndices[index])
  end
  function viewer:GetWireBossID(index)
    local plan = self.sourcePlans[index]
    return table.concat({ "bp", Normalize(plan and plan.raid), (Normalize(plan and plan.boss)) }, ".")
  end
  function viewer:GetWirePlanID(index)
    -- MGMRA4 v4 intentionally has no planId field. The full snapshot order is
    -- therefore the shared stable instance discriminator for a later delta.
    return table.concat({ self:GetWireBossID(index), "plan", tostring(self.sourcePlanGlobalIndices[index] or index) }, ".")
  end
  function viewer:GetSavedEdit(index)
    local bucket = EditStorage()[self:GetSourceKey()]
    local record = bucket and bucket[self:GetPlanKey(index)]
    return record and record.plan, record
  end
  function viewer:GetWorkingDraft(index)
    local bucket = WorkingDraftStorage()[self:GetSourceKey()]
    local record = bucket and bucket[self:GetPlanKey(index)]
    return record and record.plan, record
  end
  function viewer:StashCurrentDraft()
    if not self.editing or not self.draftPlan or not self.planIndex then return end
    local storage = WorkingDraftStorage()
    local sourceKey = self:GetSourceKey()
    storage[sourceKey] = storage[sourceKey] or {}
    storage[sourceKey][self:GetPlanKey(self.planIndex)] = {
      plan = DeepCopy(self.draftPlan), updatedAt = time and time() or 0,
    }
  end
  function viewer:ClearWorkingDraft(index)
    local bucket = WorkingDraftStorage()[self:GetSourceKey()]
    if bucket then bucket[self:GetPlanKey(index)] = nil end
  end
  function viewer:EffectivePlan(index)
    if self.editing and self.draftPlan and index == self.planIndex then return self.draftPlan end
    local working = self:GetWorkingDraft(index)
    if working then return working end
    local saved = self:GetSavedEdit(index)
    return saved or self.sourcePlans[index]
  end
  function viewer:BuildPayload(includeDraft)
    local payload = DeepCopy(self.entry and self.entry.parsed and self.entry.parsed.mgmra4)
    if not payload then return nil, "This import has no validated Boss Plan snapshot." end
    local edits = EditStorage()[self:GetSourceKey()] or {}
    for globalIndex, plan in ipairs(payload.plans or {}) do
      local record = edits[PlanIdentity(plan, globalIndex)]
      if record then payload.plans[globalIndex] = DeepCopy(record.plan) end
    end
    if includeDraft and self.editing and self.draftPlan then
      payload.plans[self.sourcePlanGlobalIndices[self.planIndex]] = DeepCopy(self.draftPlan)
    end
    return payload
  end
  function viewer:GetSelectedElement()
    return self.editing and self.selectedElementIndex and self.currentPlan
      and self.currentPlan.elements[self.selectedElementIndex] or nil
  end
  function viewer:GetBossPaletteItems()
    local plan = self.currentPlan or (self.sourcePlans and self.sourcePlans[self.planIndex])
    local wantedRaid, wantedBoss = Normalize(plan and plan.raid), Normalize(plan and plan.boss)
    local cacheKey = wantedRaid .. "|" .. wantedBoss
    if self.bossPaletteItems and self.bossPaletteCacheKey == cacheKey then return self.bossPaletteItems end
    self.bossPaletteItems, self.bossPaletteCacheKey = {}, cacheKey
    local catalog = owner:GetTBCBossPlanAssetCatalog()
    local fallback
    for _, asset in ipairs(catalog and catalog.assets or {}) do
      local assetRaid, encounter = Normalize(asset.raid), Normalize(asset.encounter)
      local bossMatches = encounter == wantedBoss
        or (encounter ~= "" and wantedBoss ~= "" and (encounter:find(wantedBoss, 1, true) or wantedBoss:find(encounter, 1, true)))
      if asset.kind == "portrait" and asset.bundled ~= false and assetRaid == wantedRaid and bossMatches then
        local item = {
          id = asset.id, label = asset.id, runtimePath = asset.runtimePath,
          element = { type = "boss", assetId = asset.id, size = 100, bossFacingVisible = false },
        }
        fallback = fallback or item
        if asset.variant == "primary" or asset.id:match("%.portrait%.primary$") then
          self.bossPaletteItems[1] = item
          break
        end
      end
    end
    if #self.bossPaletteItems == 0 and fallback then self.bossPaletteItems[1] = fallback end
    return self.bossPaletteItems
  end
  function viewer:HidePalette()
    for _, button in ipairs(self.paletteButtons) do button:Hide(); button.paletteItem = nil end
    self.paletteScroll:Hide()
    self.inspectorLabel:Show()
    self.palettePrevious:Hide(); self.palettePageText:Hide(); self.paletteNext:Hide()
  end
  function viewer:ShowPalette(mode, items)
    local changed = self.paletteMode ~= mode
    if changed then self.paletteMode, self.palettePage = mode, 1 end
    self.paletteItems = items or {}
    self.inspectorLabel:Hide()
    self.paletteScroll:Show()
    if changed and self.paletteScroll.SetHorizontalScroll then self.paletteScroll:SetHorizontalScroll(0) end
    for index, button in ipairs(self.paletteButtons) do
      local item = self.paletteItems[index]
      button.paletteItem = item
      button:SetShown(item ~= nil)
      if item then
        SetTextureFiltered(button.icon, item.runtimePath or "Interface\\Icons\\INV_Misc_QuestionMark")
        local coord = item.texCoord
        if coord then button.icon:SetTexCoord(coord[1], coord[2], coord[3], coord[4])
        else button.icon:SetTexCoord(0, 1, 0, 1) end
        button.tooltipText = item.label or item.id
        button:SetActive(self.createAssetId == item.id)
      end
    end
    self.palettePrevious:Hide(); self.palettePageText:Hide(); self.paletteNext:Hide()
    self:LayoutPalette()
  end
  function viewer:ChoosePaletteItem(item)
    if not item or not item.element then return end
    local selected = self:GetSelectedElement()
    if selected and self.editorTool == "select" then
      for _, field in ipairs({ "assetId", "role", "wowClass", "wowIcon", "spellId", "marker" }) do selected[field] = nil end
      for field, value in pairs(item.element) do
        if field ~= "x" and field ~= "y" and field ~= "size" then selected[field] = DeepCopy(value) end
      end
      self.createAssetId = item.id
      self:StashCurrentDraft()
      self:RefreshSelectedElement(true)
      self:SetStatus("Selected element updated from the header asset palette.", "good")
      return
    end
    self.createTemplate = DeepCopy(item.element)
    self.createAssetId = item.id
    self:SetStatus("Asset selected. Click the map once to place it; Select resumes automatically.", "good")
    self:UpdateInspector()
  end
  function viewer:OpenTextEditor(index, focus)
    local element = index and self.currentPlan and self.currentPlan.elements[index]
    self.textEditorTargetIndex = element and element.type == "text" and index or false
    self.textEditorMode = self.textEditorTargetIndex and "edit" or "create"
    self.textEditOriginal = self.textEditorTargetIndex and (element.label or "") or ""
    self.pendingTextFont = self.textEditorTargetIndex and (element.textFont or "Roboto") or (self.pendingTextFont or "Roboto")
    self.pendingTextSize = self.textEditorTargetIndex and ResolveTextSize(element)
      or ResolveTextSize({ textSize = self.pendingTextSize })
    self.textEdit:SetText(self.textEditOriginal)
    self.textEdit:HighlightText()
    if focus then self.textEdit:SetFocus() end
    self:UpdateInspector()
  end
  function viewer:CompleteCreateTool()
    self.editorTool = "select"
    self.createTemplate, self.createAssetId = false, false
    if self.textEditorMode == "create" then self.textEditorMode, self.textEditorTargetIndex = false, false end
    self.paletteMode, self.paletteItems = false, false
  end
  function viewer:UpdateInspector()
    local element = self:GetSelectedElement()
    local creating = self.editing and self.editorTool and self.editorTool ~= "select" and self.editorTool ~= "erase"
    local show = self.editing and (element ~= nil or creating)
    self.inspector:SetShown(show)
    self.inspector:SetAlpha(1)
    self.inspectorLabel:SetText(element and ((element.type or "element"):gsub("^%l", string.upper))
      or (creating and ((self.editorTool or "tool"):gsub("^%l", string.upper)) or "SELECT / EDIT"))
    for _, control in ipairs({ self.sizeMinus, self.sizeValue, self.sizePlus, self.alphaMinus, self.alphaValue,
      self.alphaPlus, self.fillColor, self.borderColor, self.borderWidthMinus, self.borderWidthValue,
      self.borderWidthPlus, self.textEdit, self.textApply, self.textCancel, self.fontPicker,
      self.fontSizeMinus, self.fontSizeValue, self.fontSizePlus, self.emojiSmile, self.emojiFlat }) do
      control:SetShown(false)
    end
    for _, swatch in ipairs(self.colorSwatches or {}) do swatch:Hide() end
    self.fontMenu:Hide()
    self:HidePalette()
    local function ConfigureColors(target)
      if not target then return end
      local fillField, borderField, alphaField
      if target.type == "box" or target.type == "circle" or target.type == "triangle" or target.type == "cone" then
        fillField, borderField, alphaField = "fillColor", "strokeColor", "fillOpacity"
      elseif target.type == "drawing" then
        fillField = "color"
      elseif target.type == "text" then
        fillField = "textColor"
        if target.textStroke then borderField = "textStrokeColor" end
      elseif target.type == "arrow" or target.type == "arrow-down" or target.type == "line" then
        fillField, borderField, alphaField = "strokeColor", "strokeColor", "fillOpacity"
      end
      self.inspectorFillField, self.inspectorBorderField, self.inspectorAlphaField = fillField, borderField, alphaField
      self.activeColorTarget = (self.activeColorTarget == "border" and borderField) and "border" or "fill"
      if alphaField then
        self.alphaMinus:Show(); self.alphaValue:Show(); self.alphaPlus:Show()
        self.alphaValue:SetText(string.format("Alpha %d%%", math.floor((target[alphaField] == nil and 30 or target[alphaField]) + 0.5)))
      end
      if fillField then
        self.fillColor:Show()
        local red, green, blue = HexColor(target[fillField], "#ffffff")
        self.fillColor.icon:SetVertexColor(red, green, blue, 1)
      end
      if borderField then
        self.borderColor:Show()
        self.borderWidthMinus:Show(); self.borderWidthValue:Show(); self.borderWidthPlus:Show()
        self.borderWidthValue:SetText(string.format("Border %g", target.strokeWidth == nil and 2 or target.strokeWidth))
        local red, green, blue = HexColor(target[borderField], "#02060b")
        self.borderColor.icon:SetVertexColor(red, green, blue, 1)
      end
      if fillField or borderField then
        for _, swatch in ipairs(self.colorSwatches or {}) do
          swatch:SetShown(true)
          swatch:SetActive((self.activeColorTarget == "border" and borderField or fillField)
            and target[(self.activeColorTarget == "border" and borderField or fillField)] == swatch.colorHex)
        end
      end
    end
    if creating and not element then
      if self.editorTool == "text" then
        self.pendingTextSize = ResolveTextSize({ textSize = self.pendingTextSize })
        self.textEdit:Show(); self.textApply:Show(); self.textCancel:Show(); self.fontPicker:Show()
        self.fontSizeMinus:Show(); self.fontSizeValue:Show(); self.fontSizePlus:Show()
        self.fontSizeValue:SetText(string.format("Font %d", math.floor(self.pendingTextSize + 0.5)))
        self.fontPicker.label:SetText("Font: " .. tostring(self.pendingTextFont or "Roboto"))
      elseif self.editorTool == "emoji" then self:ShowPalette("create-emoji", SMILEY_PALETTE)
      elseif self.editorTool == "raid-marker" then self:ShowPalette("create-marker", MARKER_PALETTE)
      elseif self.editorTool == "boss" then self:ShowPalette("create-boss", self:GetBossPaletteItems())
      elseif self.editorTool == "class-spec" then self:ShowPalette("create-class-spec", CLASS_SPEC_PALETTE)
      elseif self.editorTool == "role" then self:ShowPalette("create-role", ROLE_PALETTE)
      else ConfigureColors(self.createTemplate) end
      self:LayoutEditorChrome()
      return
    end
    if not element then self:LayoutEditorChrome(); return end
    self.sizeMinus:Show(); self.sizeValue:Show(); self.sizePlus:Show()
    self.sizeValue:SetText(string.format("Size %d%%", math.floor((element.size == nil and 100 or element.size) + 0.5)))
    ConfigureColors(element)
    if element.type == "text" then
      if self.textEditorTargetIndex ~= self.selectedElementIndex then
        self.textEditorMode, self.textEditorTargetIndex = "edit", self.selectedElementIndex
        self.textEditOriginal = element.label or ""
        self.textEdit:SetText(self.textEditOriginal)
      end
      self.pendingTextFont = element.textFont or "Roboto"
      self.pendingTextSize = ResolveTextSize(element)
      self.textEdit:Show(); self.textApply:Show(); self.textCancel:Show(); self.fontPicker:Show()
      self.fontSizeMinus:Show(); self.fontSizeValue:Show(); self.fontSizePlus:Show()
      self.fontSizeValue:SetText(string.format("Font %d", math.floor(self.pendingTextSize + 0.5)))
      self.fontPicker.label:SetText("Font: " .. self.pendingTextFont)
    elseif element.type == "emoji" then
      self:ShowPalette("edit-emoji", SMILEY_PALETTE)
    elseif element.type == "raid-marker" then
      self:ShowPalette("edit-marker", MARKER_PALETTE)
    elseif element.type == "boss" then
      self:ShowPalette("edit-boss", self:GetBossPaletteItems())
    elseif element.type == "image" and element.role then
      self:ShowPalette("edit-role", ROLE_PALETTE)
    elseif element.type == "image" and (element.wowClass or (element.wowIcon and element.wowIcon:match("^merfinplus%.spec%."))) then
      self:ShowPalette("edit-class-spec", CLASS_SPEC_PALETTE)
    end
    self:LayoutEditorChrome()
  end
  function viewer:UpdateControls()
    self.unlock.label:SetText(self.editing and "Lock Editing" or "Unlock Editing")
    self.unlock:SetActionIcon(self.editing and "Interface\\Icons\\INV_Misc_Key_03"
      or "Interface\\Icons\\INV_Misc_Key_04")
    SetEnabled(self.save, self.editing, self.editing and "Save this plan locally without changing the imported envelope." or "Unlock the plan before saving.")
    local allowed, reason = owner:CanBroadcastRaidAssignments()
    local saved = self:GetSavedEdit(self.planIndex)
    SetEnabled(self.send, allowed and saved ~= nil and not self.editing,
      self.editing and "Save the plan before sending." or (not allowed and reason or (not saved and "Save a local edit before sending." or "Broadcast only this selected saved plan revision.")))
    self.toolbar:SetShown(self.editing)
    SetEnabled(self.restore, self.sourcePlans and self.sourcePlans[self.planIndex] ~= nil,
      self.sourcePlans and self.sourcePlans[self.planIndex] and "Restore only this plan to the latest imported or received snapshot." or "No imported original exists for this plan.")
    SetEnabled(self.remove, self:GetSelectedElement() ~= nil, self:GetSelectedElement() and "Remove the selected element." or "Select an element first.")
    SetEnabled(self.clear, self.editing, self.editing and "Clear this local plan after confirmation." or "Unlock the plan before clearing it.")
    for _, button in ipairs(self.toolButtons) do
      SetEnabled(button, self.editing, self.editing and button.baseTooltip or "Unlock the plan to edit.")
      button:SetActive(self.editing and self.editorTool == button.tool)
    end
    self:UpdateInspector()
  end
  function viewer:BuildMenu()
    for _, item in ipairs(self.dropdownMenu.items) do item:Hide() end
    for index, plan in ipairs(self.sourcePlans) do
      local item = self.dropdownMenu.items[index]
      if not item then
        item = Button(self.dropdownMenu, "", 244, 24)
        self.dropdownMenu.items[index] = item
      end
      item:ClearAllPoints()
      item:SetPoint("TOP", self.dropdownMenu, "TOP", 0, -8 - ((index - 1) * 26))
      item.label:SetText(string.format("%s%s  (%d/%d)", plan.name, plan.phase and (" · Phase " .. plan.phase) or "", index, #self.sourcePlans))
      item:SetScript("OnClick", function() self.dropdownMenu:Hide(); self:Render(index) end)
      item:Show()
    end
    self.dropdownMenu:SetHeight(16 + (#self.sourcePlans * 26))
  end
  function viewer:RefreshSelectedElement(refreshControls)
    local index = self.selectedElementIndex
    local element = index and self.currentPlan and self.currentPlan.elements[index]
    if element then RenderElement(self, element, index, self.currentPlan.elements) end
    if refreshControls then self:UpdateControls() else self:UpdateInspector() end
  end
  function viewer:Render(index, preserveDraft)
    if #self.sourcePlans == 0 then return end
    local nextIndex = Clamp(index or 1, 1, #self.sourcePlans)
    local switchingPlans = self.editing and self.planIndex and nextIndex ~= self.planIndex
    if switchingPlans then
      self:StashCurrentDraft()
      CancelEditorInteraction(self, true)
      self.selectedElementIndex = false
      self.editorTool = self.editorTool or "select"
    end
    self.planIndex = nextIndex
    if self.editing and (switchingPlans or not preserveDraft or not self.draftPlan) then
      self.draftPlan = DeepCopy(self:GetWorkingDraft(nextIndex) or self:GetSavedEdit(nextIndex) or self.sourcePlans[nextIndex])
      CoalesceLegacyDrawingSegments(self.draftPlan)
    end
    self.currentPlan = self:EffectivePlan(self.planIndex)
    local plan = self.currentPlan
    local boss = owner:ResolveRaidAssignmentBossPlanHeader(self.entry, plan)
    self.bossName:SetText((boss.name or plan.boss) .. (plan.phase and (" · Phase " .. plan.phase) or ""))
    self.planName:SetText(string.format("%s  ·  %d/%d", plan.name, self.planIndex, #self.sourcePlans))
    SetTextureFiltered(self.bossIcon, boss.icon)
    local hasMultiplePlans = #self.sourcePlans > 1
    self.dropdown.label:SetText(hasMultiplePlans and "Choose Plan" or "Single Plan")
    self.dropdown.arrow:SetShown(hasMultiplePlans)
    local asset = plan.backgroundAssetId and owner:GetTBCBossPlanAsset(plan.backgroundAssetId)
    local left, right, top, bottom = BackgroundCoverTexCoords(
      asset and asset.width, asset and asset.height, CANVAS_WIDTH, CANVAS_HEIGHT)
    self.background:SetTexCoord(left, right, top, bottom)
    SetTextureFiltered(self.background, asset and asset.runtimePath or nil)
    if asset then self.background:SetVertexColor(1, 1, 1, 1) else self.background:SetColorTexture(0.015, 0.02, 0.028, 1) end
    self.selfHighlightAssigned = false
    for _, frame in ipairs(self.elementFrames) do ResetElementFrame(frame) end
    for sourceIndex, element in ipairs(plan.elements or {}) do RenderElement(self, element, sourceIndex, plan.elements) end
    self.previous:SetShown(#self.sourcePlans > 1)
    self.next:SetShown(#self.sourcePlans > 1)
    self.dropdown:SetShown(#self.sourcePlans > 1)
    self:BuildMenu()
    self:UpdateControls()
    if switchingPlans then self:SetStatus("Working draft retained locally; selected plan opened.", "good") end
  end
  function viewer:LoadEntry(entry, groupID, selectedBossKey, preserveIdentity)
    local previousIdentity = preserveIdentity and self.sourcePlans and self.planIndex
      and PlanIdentity(self.sourcePlans[self.planIndex], self.sourcePlanGlobalIndices[self.planIndex])
    self.entry, self.groupID, self.selectedBossKey = entry, groupID, selectedBossKey
    self.sourcePlans, self.sourcePlanGlobalIndices = {}, {}
    for globalIndex, plan in ipairs(entry and entry.parsed and entry.parsed.bossPlans or {}) do
      if PlanMatchesBoss(plan, selectedBossKey) then
        self.sourcePlans[#self.sourcePlans + 1] = plan
        self.sourcePlanGlobalIndices[#self.sourcePlanGlobalIndices + 1] = globalIndex
      end
    end
    local target = 1
    if previousIdentity then
      for index, plan in ipairs(self.sourcePlans) do
        if PlanIdentity(plan, self.sourcePlanGlobalIndices[index]) == previousIdentity then target = index; break end
      end
    end
    self:Render(target)
  end
  function viewer:ApplyPendingIncoming(message)
    local pending = self.pendingIncomingEntry
    if not pending then return false end
    self.pendingIncomingEntry = false
    self:LoadEntry(pending, pending.raidGroup, self.selectedBossKey, true)
    self:SetStatus(message or "Pending group update applied automatically.", "good")
    return true
  end
  function viewer:UnlockPlan()
    if self.editing then
      self:StashCurrentDraft()
      self.editing, self.draftPlan, self.selectedElementIndex, self.editorTool = false, false, false, false
      if not self:ApplyPendingIncoming("Working draft retained against the prior revision; pending group update applied.") then
        self:SetStatus("Editing locked; working drafts retained locally.")
        self:Render(self.planIndex)
      end
      return
    end
    self.draftPlan = DeepCopy(self:GetWorkingDraft(self.planIndex) or self:GetSavedEdit(self.planIndex) or self.sourcePlans[self.planIndex])
    local mergedRuns, removedSegments = CoalesceLegacyDrawingSegments(self.draftPlan)
    self.currentPlan = self.draftPlan
    self.editing = true
    self.editorTool = "select"
    if mergedRuns > 0 then
      self:SetStatus(string.format("Editing locally · restored %d legacy freehand stroke%s from %d stored segments.",
        mergedRuns, mergedRuns == 1 and "" or "s", removedSegments + mergedRuns), "good")
    else
      self:SetStatus("Editing locally · drag to move · use visible handles to resize or rotate · Delete removes.")
    end
    self:Render(self.planIndex, true)
  end
  function viewer:SavePlan()
    if not self.editing or not self.draftPlan then return end
    local payload, payloadError = self:BuildPayload(true)
    local envelope, encodeError
    if payload then envelope, encodeError = owner:EncodeMGMRA4Envelope(payload) end
    if not envelope then self:SetStatus(payloadError or encodeError or "Plan validation failed.", "error"); return end
    local storage = owner:GetRaidAssignmentStorage()
    storage.bossPlanLocalEdits = storage.bossPlanLocalEdits or {}
    local sourceKey = self:GetSourceKey()
    storage.bossPlanLocalEdits[sourceKey] = storage.bossPlanLocalEdits[sourceKey] or {}
    storage.bossPlanRevisionCounter = math.max((storage.bossPlanRevisionCounter or 0) + 1, time and time() or 0)
    storage.bossPlanLocalEdits[sourceKey][self:GetPlanKey(self.planIndex)] = {
      plan = DeepCopy(self.draftPlan), revision = storage.bossPlanRevisionCounter, savedAt = time and time() or 0,
    }
    self:ClearWorkingDraft(self.planIndex)
    self.editing, self.draftPlan, self.selectedElementIndex, self.editorTool = false, false, false, false
    if not self:ApplyPendingIncoming("Local edit saved against the prior revision; pending group update applied.") then
      self:SetStatus("Plan saved locally. Imported source remains unchanged.", "good")
      self:Render(self.planIndex)
    end
  end
  function viewer:RestoreCurrentPlan()
    local original = self.sourcePlans and self.sourcePlans[self.planIndex]
    if not original then self:SetStatus("No imported original exists for this plan.", "error"); return end
    self:Confirm("Restore this plan to the latest imported or received original? Only this plan's local draft and saved override will be removed. Nothing is broadcast.", function()
      self:ClearWorkingDraft(self.planIndex)
      local bucket = EditStorage()[self:GetSourceKey()]
      if bucket then bucket[self:GetPlanKey(self.planIndex)] = nil end
      if self.pendingIncomingEntry then
        local pending = self.pendingIncomingEntry
        self.pendingIncomingEntry = false
        self:LoadEntry(pending, pending.raidGroup, self.selectedBossKey, true)
        original = self.sourcePlans and self.sourcePlans[self.planIndex]
        self:ClearWorkingDraft(self.planIndex)
        bucket = EditStorage()[self:GetSourceKey()]
        if bucket then bucket[self:GetPlanKey(self.planIndex)] = nil end
      end
      self.selectedElementIndex, self.elementDrag, self.editorTool = false, false, self.editing and "select" or false
      self.draftPlan = self.editing and DeepCopy(original) or false
      if self.draftPlan then CoalesceLegacyDrawingSegments(self.draftPlan) end
      self:SetStatus("This plan was restored to its imported original. No broadcast was sent.", "good")
      self:Render(self.planIndex, true)
    end)
  end
  function viewer:ClearCurrentPlan()
    if not self.editing then return end
    self:Confirm("Clear every element from this local plan? Other plans and the imported original are not changed.", function()
      self.currentPlan.elements = {}
      self.selectedElementIndex, self.elementDrag = false, false
      self:StashCurrentDraft()
      self:SetStatus("Current local plan cleared. Save explicitly to make it broadcast-ready.", "good")
      self:Render(self.planIndex, true)
    end)
  end
  function viewer:SetEditorTool(tool)
    CancelEditorInteraction(self, true)
    self.editorTool = tool or "select"
    self.createTemplate, self.createAssetId = false, false
    self.textEditorMode, self.textEditorTargetIndex = false, false
    self.selectedElementIndex = false
    if self.editorTool == "circle" then
      self.createTemplate = { type = "circle", size = 100, fill = true, fillColor = "#ffffff", fillOpacity = 30, strokeColor = "#02060b", strokeWidth = 2 }
    elseif self.editorTool == "box" then
      self.createTemplate = { type = "box", size = 100, fill = true, fillColor = "#ffffff", fillOpacity = 30, strokeColor = "#02060b", strokeWidth = 2 }
    elseif self.editorTool == "arrow" then
      self.createTemplate = { type = "arrow", size = 100, color = "#ff4f52", strokeColor = "#ff4f52", strokeWidth = 4, fillOpacity = 100 }
    elseif self.editorTool == "line" then
      self.createTemplate = { type = "line", size = 100, color = "#ff4f52", strokeColor = "#ff4f52", strokeWidth = 4, fillOpacity = 100 }
    elseif self.editorTool == "draw" then
      self.createTemplate = { type = "drawing", color = "#ff4f52", strokeWidth = 6, size = 100 }
    elseif self.editorTool == "text" then
      self:OpenTextEditor(false, true)
    end
    for _, button in ipairs(self.toolButtons) do button:SetActive(self.editing and button.tool == self.editorTool) end
    local messages = {
      select = "Select an element, then drag to move or use its visible handles.",
      text = "Enter text in the header inspector and choose Apply, then click the map once.",
      emoji = "Choose a smiley in the header inspector, then click the map once.",
      ["raid-marker"] = "Choose one of all eight raid markers in the header inspector.",
      boss = "Choose the canonical boss portrait in the header inspector.",
      ["class-spec"] = "Choose a bundled class or spec icon in the header inspector.",
      role = "Choose Tank, Heal, Melee, Ranged, or Raid role in the header inspector.",
      circle = "Click the map once to place one circle.", box = "Click the map once to place one box.",
      arrow = "Drag from arrow start to arrow end.", draw = "Hold and drag freehand lines; the tool stays active after MouseUp.",
      line = "Drag from line start to line end.",
      erase = "Hold and drag over freehand strokes to remove only the touched parts; the tool stays active.",
    }
    self:SetStatus(messages[self.editorTool] or "Boss Plan tool selected.")
    self:UpdateControls()
  end
  function viewer:SendPlan()
    local allowed, reason = owner:CanBroadcastRaidAssignments()
    if not allowed then self:SetStatus(reason, "error"); return end
    if self.editing then self:SetStatus("Save the current plan before sending.", "error"); return end
    local plan, savedRecord = self:GetSavedEdit(self.planIndex)
    if not plan or not savedRecord then self:SetStatus("Save this selected plan before sending.", "error"); return end
    local revision = tonumber(savedRecord.revision) or 0
    local bossID, planID = self:GetWireBossID(self.planIndex), self:GetWirePlanID(self.planIndex)
    local sent, sendError = owner:BroadcastCanonicalBossPlan(DeepCopy(plan), {
      bossId = bossID, planId = planID, revision = revision,
    }, self.entry)
    self:SetStatus(sent and ("Sending saved plan " .. planID .. " revision " .. tostring(revision) .. "; waiting for a receiver receipt.") or sendError, sent and "muted" or "error")
  end
  function viewer:AddElement(kind, x, y, override)
    if not self.editing then return end
    local defaults = {
      circle = { type = "circle", size = 100, fill = true, fillColor = "#ffffff", fillOpacity = 30, strokeColor = "#02060b", strokeWidth = 2 },
      box = { type = "box", size = 100, fill = true, fillColor = "#ffffff", fillOpacity = 30, strokeColor = "#02060b", strokeWidth = 2 },
      arrow = { type = "arrow", size = 100, strokeColor = "#ff4f52", strokeWidth = 4 },
    }
    local element = DeepCopy(override or self.createTemplate or defaults[kind])
    if not element then self:SetStatus("Choose the asset or enter text in the header inspector first.", "error"); return false end
    element.x, element.y = Clamp(x or 50, 0, 100), Clamp(y or 50, 0, 100)
    self.currentPlan.elements[#self.currentPlan.elements + 1] = element
    self.selectedElementIndex = #self.currentPlan.elements
    self:CompleteCreateTool()
    self:StashCurrentDraft()
    self:Render(self.planIndex, true)
    self:SetStatus("Element placed once and selected. SELECT / EDIT is active.", "good")
    return true
  end
  function viewer:DeleteSelected()
    if not self.editing or not self.selectedElementIndex then return end
    self:RemoveElement(self.selectedElementIndex)
  end
  function viewer:RemoveElement(index)
    if not self.editing or not index then return end
    if not RemovePlanElement(self.currentPlan, index) then return end
    self.selectedElementIndex = false
    self:StashCurrentDraft()
    self:Render(self.planIndex, true)
  end
  function viewer:OnIncomingEntry(entry, sender, revision)
    if not self:IsShown() or not entry or entry.raidGroup ~= self.groupID then return end
    if self.editing then
      self.pendingIncomingEntry = entry
      self:SetStatus("Newer plan received from " .. tostring(sender or "group") .. "; unsaved local edit retained.", "error")
      return
    end
    self:LoadEntry(entry, entry.raidGroup, self.selectedBossKey, true)
    self:SetStatus("Boss Plan updated automatically from " .. tostring(sender or "group") .. " (revision " .. tostring(revision or "new") .. ").", "good")
  end

  viewer.close:SetScript("OnClick", function() viewer:Hide() end)
  viewer.previous:SetScript("OnClick", function() viewer:Render(viewer.planIndex > 1 and viewer.planIndex - 1 or #viewer.sourcePlans) end)
  viewer.next:SetScript("OnClick", function() viewer:Render(viewer.planIndex < #viewer.sourcePlans and viewer.planIndex + 1 or 1) end)
  viewer.dropdown:SetScript("OnClick", function()
    if viewer.dropdownMenu:IsShown() then viewer.dropdownMenu:Hide() else
      viewer.dropdownMenu:ClearAllPoints(); viewer.dropdownMenu:SetPoint("TOPRIGHT", viewer.dropdown, "BOTTOMRIGHT", 0, -3); viewer.dropdownMenu:Show()
    end
  end)
  viewer.unlock:SetScript("OnClick", function() viewer:UnlockPlan() end)
  viewer.save:SetScript("OnClick", function() if viewer.save.enabled then viewer:SavePlan() end end)
  viewer.send:SetScript("OnClick", function() if viewer.send.enabled then viewer:SendPlan() end end)
  viewer.restore:SetScript("OnClick", function() if viewer.restore.enabled then viewer:RestoreCurrentPlan() end end)
  viewer.remove:SetScript("OnClick", function() if viewer.remove.enabled then viewer:DeleteSelected() end end)
  viewer.clear:SetScript("OnClick", function() if viewer.clear.enabled then viewer:ClearCurrentPlan() end end)
  local function MutateSelected(callback)
    local element = viewer:GetSelectedElement()
    if not element then return end
    callback(element)
    viewer:StashCurrentDraft()
    viewer:RefreshSelectedElement(true)
  end
  viewer.sizeMinus:SetScript("OnClick", function() MutateSelected(function(element)
    element.size = Clamp((element.size == nil and 100 or element.size) - 10, 0, 1000)
  end) end)
  viewer.sizePlus:SetScript("OnClick", function() MutateSelected(function(element)
    element.size = Clamp((element.size == nil and 100 or element.size) + 10, 0, 1000)
  end) end)
  viewer.alphaMinus:SetScript("OnClick", function() MutateSelected(function(element)
    local field = viewer.inspectorAlphaField
    if field then element[field] = Clamp((element[field] == nil and 30 or element[field]) - 5, 0, 100) end
  end) end)
  viewer.alphaPlus:SetScript("OnClick", function() MutateSelected(function(element)
    local field = viewer.inspectorAlphaField
    if field then element[field] = Clamp((element[field] == nil and 30 or element[field]) + 5, 0, 100) end
  end) end)
  viewer.borderWidthMinus:SetScript("OnClick", function() MutateSelected(function(element)
    element.strokeWidth = Clamp((element.strokeWidth == nil and 2 or element.strokeWidth) - 1, 0, 12)
  end) end)
  viewer.borderWidthPlus:SetScript("OnClick", function() MutateSelected(function(element)
    element.strokeWidth = Clamp((element.strokeWidth == nil and 2 or element.strokeWidth) + 1, 0, 12)
  end) end)
  local function AdjustTextFontSize(delta)
    local element = viewer:GetSelectedElement()
    if element and element.type == "text" then
      element.textSize = Clamp(ResolveTextSize(element) + delta, MIN_TEXT_SIZE, MAX_TEXT_SIZE)
      viewer.pendingTextSize = element.textSize
      viewer:StashCurrentDraft()
      viewer:RefreshSelectedElement(true)
      return
    end
    if viewer.editing and viewer.editorTool == "text" then
      viewer.pendingTextSize = Clamp(ResolveTextSize({ textSize = viewer.pendingTextSize }) + delta,
        MIN_TEXT_SIZE, MAX_TEXT_SIZE)
      viewer:UpdateInspector()
    end
  end
  viewer.fontSizeMinus:SetScript("OnClick", function() AdjustTextFontSize(-1) end)
  viewer.fontSizePlus:SetScript("OnClick", function() AdjustTextFontSize(1) end)
  function viewer:ApplyEditorColor(hex)
    local element = self:GetSelectedElement()
    local target = element or self.createTemplate
    local field = self.activeColorTarget == "border" and self.inspectorBorderField or self.inspectorFillField
    if not target or not field or not hex then return end
    target[field] = hex
    -- Arrow, line and drawing renderers retain both legacy aliases. Keep them
    -- in lockstep so a clicked swatch always affects the visible stroke.
    if target.type == "drawing" then target.color = hex end
    if target.type == "arrow" or target.type == "arrow-down" or target.type == "line" then
      target.color, target.strokeColor = hex, hex
    end
    if field == "fillColor" then target.fill = true end
    if element then
      self:StashCurrentDraft()
      self:RefreshSelectedElement(true)
    else
      self:UpdateInspector()
    end
  end
  viewer.fillColor:SetScript("OnClick", function()
    viewer.activeColorTarget = "fill"
    viewer:UpdateInspector()
  end)
  viewer.borderColor:SetScript("OnClick", function()
    if viewer.inspectorBorderField then
      viewer.activeColorTarget = "border"
      viewer:UpdateInspector()
    end
  end)
  for _, swatch in ipairs(viewer.colorSwatches) do
    swatch:SetScript("OnClick", function(self) viewer:ApplyEditorColor(self.colorHex) end)
  end
  local function ApplyTextEdit()
    if viewer.committingTextEdit then return end
    viewer.committingTextEdit = true
    local value = viewer.textEdit:GetText() or ""
    if not value:match("%S") then
      viewer:SetStatus("Enter text before applying it.", "error")
      viewer.committingTextEdit = false
      viewer.textEdit:SetFocus()
      return
    end
    local element = viewer.textEditorTargetIndex and viewer.currentPlan.elements[viewer.textEditorTargetIndex]
    if element and element.type == "text" then
      element.label = value
      element.textFont = viewer.pendingTextFont or element.textFont or "Roboto"
      element.textSize = ResolveTextSize({ textSize = viewer.pendingTextSize or element.textSize })
      viewer.textEditOriginal = value
      viewer:StashCurrentDraft()
      viewer:RefreshSelectedElement(true)
      viewer:SetStatus("Text updated. The element remains selected in SELECT / EDIT.", "good")
    else
      viewer.createTemplate = {
        type = "text", label = value, textSize = ResolveTextSize({ textSize = viewer.pendingTextSize }), textColor = "#f3f7ff",
        textFont = viewer.pendingTextFont or "Roboto", textAlign = "center", textSizing = "auto", size = 100,
      }
      viewer.createAssetId = "mp.text.custom"
      viewer:SetStatus("Text applied. Click the map once to place it; Select resumes automatically.", "good")
    end
    viewer.textEdit:ClearFocus()
    viewer.committingTextEdit = false
  end
  local function CancelTextEdit()
    viewer.textEdit:SetText(viewer.textEditOriginal or "")
    viewer.textEdit:ClearFocus()
    if viewer.textEditorMode == "create" then
      viewer:CompleteCreateTool()
      viewer:SetStatus("Text placement cancelled. SELECT / EDIT is active.")
      viewer:UpdateControls()
    else
      viewer:SetStatus("Text changes cancelled; the element was not modified.")
    end
  end
  viewer.textApply:SetScript("OnClick", ApplyTextEdit)
  viewer.textCancel:SetScript("OnClick", CancelTextEdit)
  viewer.textEdit:SetScript("OnEnterPressed", ApplyTextEdit)
  viewer.textEdit:SetScript("OnEscapePressed", CancelTextEdit)
  viewer.textEdit:SetScript("OnEditFocusLost", function() end)
  viewer.fontPicker:SetScript("OnClick", function()
    viewer.fontMenu:SetShown(not viewer.fontMenu:IsShown())
    if viewer.fontMenu:IsShown() then
      viewer.fontMenu:Raise()
    end
  end)
  for _, row in ipairs(viewer.fontRows) do
    row:SetScript("OnClick", function(self)
      local choice = self.fontChoice
      viewer.pendingTextFont = choice.token
      local element = viewer:GetSelectedElement()
      if element and element.type == "text" then
        element.textFont = choice.token
        viewer:StashCurrentDraft()
        viewer:RefreshSelectedElement(true)
      else
        viewer.fontPicker.label:SetText("Font: " .. choice.token)
      end
      viewer.fontMenu:Hide()
    end)
  end
  for _, button in ipairs(viewer.paletteButtons) do
    button:SetScript("OnClick", function(self) if self.paletteItem then viewer:ChoosePaletteItem(self.paletteItem) end end)
  end
  viewer.paletteScroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self.GetHorizontalScroll and self:GetHorizontalScroll() or 0
    local maximum = self.GetHorizontalScrollRange and self:GetHorizontalScrollRange() or 0
    if self.SetHorizontalScroll then self:SetHorizontalScroll(Clamp(current - delta * 72, 0, maximum)) end
  end)
  viewer.palettePrevious:SetScript("OnClick", function()
    viewer.palettePage = math.max(1, (viewer.palettePage or 1) - 1)
    viewer:ShowPalette(viewer.paletteMode, viewer.paletteItems)
  end)
  viewer.paletteNext:SetScript("OnClick", function()
    local pages = math.max(1, math.ceil(#(viewer.paletteItems or {}) / #viewer.paletteButtons))
    viewer.palettePage = math.min(pages, (viewer.palettePage or 1) + 1)
    viewer:ShowPalette(viewer.paletteMode, viewer.paletteItems)
  end)
  for _, button in ipairs(viewer.toolButtons) do
    button:SetScript("OnClick", function(self)
      if not self.enabled then return end
      viewer:SetEditorTool(self.tool)
    end)
  end
  viewer.canvas:SetScript("OnMouseDown", function(_, button)
    if button ~= "LeftButton" or not viewer.editing then return end
    local x, y = CursorCanvasPosition(viewer)
    if not x then return end
    if (viewer.editorTool == "arrow" or viewer.editorTool == "line") and viewer.createTemplate then
      BeginArrowCapture(viewer)
    elseif viewer.editorTool == "draw" and viewer.createTemplate then
      BeginDrawCapture(viewer)
    elseif viewer.editorTool == "erase" then
      BeginEraseCapture(viewer)
    elseif viewer.editorTool and viewer.editorTool ~= "select" and viewer.editorTool ~= "erase" then
      viewer:AddElement(viewer.editorTool, x, y, viewer.createTemplate)
    else
      viewer.selectedElementIndex = false
      viewer:Render(viewer.planIndex, true)
    end
  end)
  viewer.canvas:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" and viewer.drawCapture then FinishDrawCapture(viewer, true)
    elseif button == "LeftButton" and viewer.eraseCapture then FinishEraseCapture(viewer, true) end
  end)
  local function ConfigureViewerKeyboard()
    if InCombatLockdown and InCombatLockdown() then
      viewer:RegisterEvent("PLAYER_REGEN_ENABLED")
      return
    end
    viewer:EnableKeyboard(true)
    if viewer.SetPropagateKeyboardInput then viewer:SetPropagateKeyboardInput(true) end
    viewer:UnregisterEvent("PLAYER_REGEN_ENABLED")
  end
  viewer:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" then ConfigureViewerKeyboard() end
  end)
  ConfigureViewerKeyboard()
  viewer:SetScript("OnKeyDown", function(_, key)
    if key == "ESCAPE" and (viewer.elementDrag or viewer.drawCapture or viewer.eraseCapture or viewer.arrowCapture or viewer.editorDragState) then
      CancelEditorInteraction(viewer)
      viewer:SetEditorTool("select")
    elseif key == "ESCAPE" and viewer.editing and viewer.editorTool ~= "select" then viewer:SetEditorTool("select")
    elseif key == "DELETE" and viewer.editing then viewer:DeleteSelected() end
  end)

  local geometry = GeometryStorage()
  local point = validAnchors[geometry.point] and geometry.point or "CENTER"
  local relativePoint = validAnchors[geometry.relativePoint] and geometry.relativePoint or point
  viewer:SetPoint(point, UIParent, relativePoint, tonumber(geometry.x) or 0, tonumber(geometry.y) or 0)
  ApplyScale(geometry.scale or 1, false)
  viewer:Hide()
  return viewer
end

local function CreateQuickOverview(owner)
  local quick = CreateFrame("Frame", "MerfinPlusBossPlanQuickOverview", UIParent, template)
  quick:SetFrameStrata("DIALOG")
  quick:SetClampedToScreen(true)
  quick:SetMovable(true)
  quick.editing = false
  quick.elementFrames = {}
  if quick.SetResizable then quick:SetResizable(true) end
  quick:EnableMouse(true)
  quick:RegisterForDrag("LeftButton")
  SetBackdrop(quick, theme.canvas, theme.border)

  quick.canvas = CreateFrame("Frame", nil, quick)
  quick.canvas:SetSize(CANVAS_WIDTH, CANVAS_HEIGHT)
  quick.canvas:SetPoint("BOTTOMLEFT", quick, "BOTTOMLEFT", QUICK_OVERVIEW_CHROME / 2, QUICK_OVERVIEW_CHROME / 2)
  quick.background = quick.canvas:CreateTexture(nil, "BACKGROUND")
  quick.background:SetAllPoints(quick.canvas)

  quick.close = CreateFrame("Button", nil, quick, template)
  quick.close:SetSize(24, 24)
  quick.close:SetPoint("TOPRIGHT", quick, "TOPRIGHT", -4, -4)
  quick.close:SetFrameLevel(quick:GetFrameLevel() + 1000)
  SetBackdrop(quick.close, theme.surface, theme.border)
  quick.close.label = quick.close:CreateFontString(nil, "OVERLAY")
  quick.close.label:SetFont(FONT_BOLD, 13, "OUTLINE")
  quick.close.label:SetPoint("CENTER", quick.close, "CENTER", 0, 0)
  quick.close.label:SetText("X")
  quick.close:SetScript("OnClick", function() quick:Hide() end)

  local function NavigationButton(label, width)
    local button = CreateFrame("Button", nil, quick, template)
    button:SetSize(width, 24)
    button:SetFrameLevel(quick:GetFrameLevel() + 1000)
    SetBackdrop(button, theme.surface, theme.border)
    button.label = button:CreateFontString(nil, "OVERLAY")
    button.label:SetFont(FONT_BOLD, 11, "OUTLINE")
    button.label:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.label:SetText(label)
    button:SetScript("OnEnter", function(self)
      if not GameTooltip or not self.tooltipText then return end
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:SetText(self.tooltipText, theme.accentBright[1], theme.accentBright[2], theme.accentBright[3])
      GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
      if GameTooltip then GameTooltip:Hide() end
    end)
    button:Hide()
    return button
  end
  quick.next = NavigationButton("Next", 46)
  quick.next:SetPoint("RIGHT", quick.close, "LEFT", -4, 0)
  quick.previous = NavigationButton("Previous", 64)
  quick.previous:SetPoint("RIGHT", quick.next, "LEFT", -4, 0)

  quick.resizeHandle = CreateFrame("Button", nil, quick)
  quick.resizeHandle:SetSize(22, 22)
  quick.resizeHandle:SetPoint("BOTTOMRIGHT", quick, "BOTTOMRIGHT", -3, 3)
  quick.resizeHandle:SetFrameLevel(quick:GetFrameLevel() + 1000)
  for index = 0, 2 do
    local line = quick.resizeHandle:CreateTexture(nil, "OVERLAY")
    line:SetTexture(WHITE_TEXTURE)
    line:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.9)
    line:SetSize(12 - (index * 3), 1.5)
    line:SetPoint("BOTTOMRIGHT", quick.resizeHandle, "BOTTOMRIGHT", -2, 4 + (index * 4))
    if line.SetRotation then line:SetRotation(math.pi / 4) end
  end

  local validAnchors = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true,
    RIGHT = true, BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
  }
  local function GeometryStorage()
    local storage = owner:GetRaidAssignmentStorage()
    storage.bossPlanQuickOverviewGeometry = storage.bossPlanQuickOverviewGeometry or {}
    return storage.bossPlanQuickOverviewGeometry
  end
  local function MaximumScale()
    local screenWidth = UIParent and UIParent.GetWidth and UIParent:GetWidth() or 1920
    local screenHeight = UIParent and UIParent.GetHeight and UIParent:GetHeight() or 1080
    return math.max(MIN_QUICK_OVERVIEW_SCALE, math.min(MAX_QUICK_OVERVIEW_SCALE,
      (screenWidth - 40 - QUICK_OVERVIEW_CHROME) / CANVAS_WIDTH,
      (screenHeight - 40 - QUICK_OVERVIEW_CHROME) / CANVAS_HEIGHT))
  end
  local function SaveGeometry()
    local geometry = GeometryStorage()
    local point, _, relativePoint, x, y = quick:GetPoint(1)
    geometry.scale = quick.canvasScale or DEFAULT_QUICK_OVERVIEW_SCALE
    geometry.point = validAnchors[point] and point or "CENTER"
    geometry.relativePoint = validAnchors[relativePoint] and relativePoint or geometry.point
    geometry.x, geometry.y = tonumber(x) or 0, tonumber(y) or 0
  end
  local function ApplyScale(requestedScale, persist)
    local scale = Clamp(tonumber(requestedScale) or DEFAULT_QUICK_OVERVIEW_SCALE,
      MIN_QUICK_OVERVIEW_SCALE, MaximumScale())
    quick.applyingGeometry = true
    quick.canvasScale = scale
    quick.canvas:SetScale(scale)
    quick:SetSize((CANVAS_WIDTH * scale) + QUICK_OVERVIEW_CHROME,
      (CANVAS_HEIGHT * scale) + QUICK_OVERVIEW_CHROME)
    quick.applyingGeometry = nil
    if persist then SaveGeometry() end
  end
  local maximumScale = MaximumScale()
  local minimumWidth = (CANVAS_WIDTH * MIN_QUICK_OVERVIEW_SCALE) + QUICK_OVERVIEW_CHROME
  local minimumHeight = (CANVAS_HEIGHT * MIN_QUICK_OVERVIEW_SCALE) + QUICK_OVERVIEW_CHROME
  local maximumWidth = (CANVAS_WIDTH * maximumScale) + QUICK_OVERVIEW_CHROME
  local maximumHeight = (CANVAS_HEIGHT * maximumScale) + QUICK_OVERVIEW_CHROME
  if quick.SetResizeBounds then
    quick:SetResizeBounds(minimumWidth, minimumHeight, maximumWidth, maximumHeight)
  else
    if quick.SetMinResize then quick:SetMinResize(minimumWidth, minimumHeight) end
    if quick.SetMaxResize then quick:SetMaxResize(maximumWidth, maximumHeight) end
  end
  quick:SetScript("OnSizeChanged", function(_, width, height)
    if quick.applyingGeometry then return end
    ApplyScale(math.min((width - QUICK_OVERVIEW_CHROME) / CANVAS_WIDTH,
      (height - QUICK_OVERVIEW_CHROME) / CANVAS_HEIGHT), false)
  end)
  quick:SetScript("OnDragStart", function() quick:StartMoving() end)
  quick:SetScript("OnDragStop", function()
    quick:StopMovingOrSizing()
    SaveGeometry()
  end)
  quick.resizeHandle:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" then quick:StartSizing("BOTTOMRIGHT") end
  end)
  quick.resizeHandle:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
      quick:StopMovingOrSizing()
      ApplyScale(quick.canvasScale, true)
    end
  end)

  local function ClearRenderedPlan()
    quick.background:SetTexture(nil)
    for _, frame in ipairs(quick.elementFrames) do
      ResetElementFrame(frame)
      for _, region in ipairs(frame.mgmra4Regions or {}) do
        if region.SetText then region:SetText("") end
      end
    end
  end
  local function UpdateNavigation()
    local sourcePlans = rawget(quick, "sourcePlans")
    local count = type(sourcePlans) == "table" and #sourcePlans or 0
    if count <= 1 then
      quick.previous.tooltipText, quick.next.tooltipText = nil, nil
      quick.previous:Hide()
      quick.next:Hide()
      return
    end
    local currentIndex = Clamp(quick.planIndex or 1, 1, count)
    local previousIndex = currentIndex > 1 and currentIndex - 1 or count
    local nextIndex = currentIndex < count and currentIndex + 1 or 1
    local previousPlan = sourcePlans[previousIndex]
    local nextPlan = sourcePlans[nextIndex]
    quick.previous.tooltipText = string.format("Previous: %s (%d/%d)",
      tostring(previousPlan and previousPlan.name or "Boss Plan"), previousIndex, count)
    quick.next.tooltipText = string.format("Next: %s (%d/%d)",
      tostring(nextPlan and nextPlan.name or "Boss Plan"), nextIndex, count)
    quick.previous:Show()
    quick.next:Show()
  end
  quick:SetScript("OnHide", function()
    quick:StopMovingOrSizing()
    SaveGeometry()
    ClearRenderedPlan()
    quick.entry, quick.sourcePlans, quick.sourcePlanGlobalIndices, quick.currentPlan = nil, nil, nil, nil
    quick.groupID, quick.selectedBossKey, quick.selectedBossName, quick.planIndex = nil, nil, nil, nil
    UpdateNavigation()
  end)

  function quick:Render(index)
    if not self.sourcePlans or #self.sourcePlans == 0 then
      UpdateNavigation()
      return false
    end
    self.planIndex = Clamp(index or 1, 1, #self.sourcePlans)
    self.currentPlan = self.sourcePlans[self.planIndex]
    ClearRenderedPlan()
    UpdateNavigation()
    local plan = self.currentPlan
    local asset = plan.backgroundAssetId and owner:GetTBCBossPlanAsset(plan.backgroundAssetId)
    local left, right, top, bottom = BackgroundCoverTexCoords(
      asset and asset.width, asset and asset.height, CANVAS_WIDTH, CANVAS_HEIGHT)
    self.background:SetTexCoord(left, right, top, bottom)
    SetTextureFiltered(self.background, asset and asset.runtimePath or nil)
    if asset then
      self.background:SetVertexColor(1, 1, 1, 1)
    else
      self.background:SetColorTexture(0.015, 0.02, 0.028, 1)
    end
    self.selfHighlightAssigned = false
    for _, frame in ipairs(self.elementFrames) do ResetElementFrame(frame) end
    for sourceIndex, element in ipairs(plan.elements or {}) do
      RenderElement(self, element, sourceIndex, plan.elements)
    end
    return true
  end

  quick.previous:SetScript("OnClick", function()
    local sourcePlans = rawget(quick, "sourcePlans")
    local count = type(sourcePlans) == "table" and #sourcePlans or 0
    if count > 1 then quick:Render((quick.planIndex or 1) > 1 and quick.planIndex - 1 or count) end
  end)
  quick.next:SetScript("OnClick", function()
    local sourcePlans = rawget(quick, "sourcePlans")
    local count = type(sourcePlans) == "table" and #sourcePlans or 0
    if count > 1 then quick:Render((quick.planIndex or 1) < count and quick.planIndex + 1 or 1) end
  end)

  function quick:LoadEntry(entry, groupID, selectedBossKey, preserveIdentity, selectedBossName)
    local previousIdentity = preserveIdentity and self.sourcePlans and self.planIndex
      and PlanIdentity(self.sourcePlans[self.planIndex], self.sourcePlanGlobalIndices[self.planIndex])
    self.entry, self.groupID, self.selectedBossKey, self.selectedBossName =
      entry, groupID, selectedBossKey, selectedBossName
    self.sourcePlans, self.sourcePlanGlobalIndices = {}, {}
    for globalIndex, plan in ipairs(entry and entry.parsed and entry.parsed.bossPlans or {}) do
      if PlanMatchesBoss(plan, selectedBossKey, selectedBossName) then
        self.sourcePlans[#self.sourcePlans + 1] = plan
        self.sourcePlanGlobalIndices[#self.sourcePlanGlobalIndices + 1] = globalIndex
      end
    end
    if #self.sourcePlans == 0 then
      self:Hide()
      return false
    end
    local target = 1
    if previousIdentity then
      for planIndex, plan in ipairs(self.sourcePlans) do
        if PlanIdentity(plan, self.sourcePlanGlobalIndices[planIndex]) == previousIdentity then
          target = planIndex
          break
        end
      end
    end
    return self:Render(target)
  end

  local geometry = GeometryStorage()
  local point = validAnchors[geometry.point] and geometry.point or "CENTER"
  local relativePoint = validAnchors[geometry.relativePoint] and geometry.relativePoint or point
  quick:SetPoint(point, UIParent, relativePoint, tonumber(geometry.x) or 0, tonumber(geometry.y) or 0)
  ApplyScale(geometry.scale or DEFAULT_QUICK_OVERVIEW_SCALE, false)
  if UISpecialFrames then
    local registered = false
    for _, frameName in ipairs(UISpecialFrames) do
      if frameName == "MerfinPlusBossPlanQuickOverview" then registered = true; break end
    end
    if not registered then table.insert(UISpecialFrames, "MerfinPlusBossPlanQuickOverview") end
  end
  quick:Hide()
  return quick
end

local function RefreshBossPlanButton(button)
  if not button then return end
  local background = button.active and theme.selected or theme.surface
  local border = button.active and theme.border or theme.borderSoft
  SetBackdrop(button, background, border)
  if button.label then button.label:SetTextColor(unpack(theme.text)) end
  MerfinPlus:ApplyUIFontSizeDelta(button)
end

function MerfinPlus:RefreshBossPlanTheme()
  local viewer = self.bossPlanViewer
  if viewer then
    SetBackdrop(viewer, theme.canvas, theme.border)
    SetBackdrop(viewer.inspector, theme.surface, theme.borderSoft)
    SetBackdrop(viewer.textEdit, theme.surfaceRaised, theme.borderSoft)
    SetBackdrop(viewer.fontMenu, theme.surface, theme.borderSoft)
    SetBackdrop(viewer.dropdownMenu, theme.surface, theme.border)
    SetBackdrop(viewer.confirmation, theme.surface, theme.border)
    for _, button in ipairs({
      viewer.close, viewer.next, viewer.previous, viewer.dropdown,
      viewer.restore, viewer.unlock, viewer.save, viewer.send, viewer.remove, viewer.clear,
      viewer.sizeMinus, viewer.sizePlus, viewer.alphaMinus, viewer.alphaPlus,
      viewer.borderWidthMinus, viewer.borderWidthPlus, viewer.textApply, viewer.textCancel,
      viewer.fontPicker, viewer.fontSizeMinus, viewer.fontSizePlus,
      viewer.palettePrevious, viewer.paletteNext,
    }) do
      RefreshBossPlanButton(button)
    end
    for _, button in ipairs(viewer.toolButtons or {}) do
      if button.SetActive then button:SetActive(button.active) else RefreshBossPlanButton(button) end
    end
    for _, button in ipairs(viewer.paletteButtons or {}) do RefreshBossPlanButton(button) end
    for _, text in ipairs({
      viewer.bossName, viewer.planName, viewer.inspectorLabel, viewer.sizeValue,
      viewer.alphaValue, viewer.borderWidthValue, viewer.fontSizeValue,
      viewer.palettePageText, viewer.status,
    }) do
      if text then self:ApplyUIFontSizeDelta(text) end
    end
  end

  local quick = self.bossPlanQuickOverview
  if quick then
    SetBackdrop(quick, theme.canvas, theme.border)
    for _, button in ipairs({ quick.close, quick.previous, quick.next }) do
      RefreshBossPlanButton(button)
    end
    for _, region in ipairs({ quick.resizeHandle:GetRegions() }) do
      if region.SetVertexColor then
        region:SetVertexColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.9)
      end
    end
  end
end

function MerfinPlus:ShowAssignmentWidgetBossPlanQuickOverview(groupID, selectedBossKey, selectedBossName)
  local plans, entry = self:GetAssignmentWidgetBossPlanQuickSelection(
    groupID, selectedBossKey, selectedBossName
  )
  if not entry or #plans == 0 then return false end
  self.bossPlanQuickOverview = self.bossPlanQuickOverview or CreateQuickOverview(self)
  self:RefreshBossPlanTheme()
  if not self.bossPlanQuickOverview:LoadEntry(
    entry, groupID, selectedBossKey, false, selectedBossName
  ) then return false end
  self.bossPlanQuickOverview:Show()
  self.bossPlanQuickOverview:Raise()
  return true
end

function MerfinPlus:ShowCurrentRaidAssignmentBossPlan(groupID, selectedBossKey)
  local plans, entry = self:GetRaidAssignmentBossPlansForSelection(groupID, selectedBossKey)
  if #plans == 0 then
    return false, selectedBossKey
      and "No imported MFPRA Boss Plan matches the selected boss."
      or "Select a boss with an imported MFPRA Boss Plan first."
  end
  self.bossPlanViewer = self.bossPlanViewer or CreateViewer(self)
  self:RefreshBossPlanTheme()
  self.bossPlanViewer:LoadEntry(entry, groupID, selectedBossKey, false)
  self.bossPlanViewer:Show()
  return true
end

function MerfinPlus:RefreshOpenBossPlanFromImport(entry, sender, revision)
  if self.bossPlanViewer and self.bossPlanViewer.OnIncomingEntry then
    self.bossPlanViewer:OnIncomingEntry(entry, sender, revision)
  end
  local quick = self.bossPlanQuickOverview
  if quick and quick:IsShown() and Normalize(quick.groupID) == Normalize(entry and entry.raidGroup) then
    quick:LoadEntry(entry, entry.raidGroup, quick.selectedBossKey, true, quick.selectedBossName)
  end
end

function MerfinPlus:RefreshOpenAssignmentWidgetBossPlanQuickContext(entry, sender, revision)
  local quick = self.bossPlanQuickOverview
  if quick and quick:IsShown() and Normalize(quick.groupID) == Normalize(entry and entry.raidGroup) then
    quick:LoadEntry(entry, entry.raidGroup, quick.selectedBossKey, true, quick.selectedBossName)
  end
end
