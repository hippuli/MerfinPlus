local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local THEME_DEFAULT = "origin"

local palettes = {
  origin = {
    modernTabs = false,
    headerAsset = false,
    headerTextureAlpha = 0,
    backdropAlpha = 0,
    canvas = { 0.014, 0.022, 0.028, 0.98 },
    shell = { 0.014, 0.022, 0.028, 0.96 },
    surface = { 0.035, 0.039, 0.043, 0.99 },
    surfaceRaised = { 0.075, 0.079, 0.075, 1.00 },
    surfaceStrong = { 0.120, 0.100, 0.055, 1.00 },
    hover = { 0.115, 0.095, 0.045, 1.00 },
    selected = { 0.120, 0.100, 0.055, 1.00 },
    pressed = { 0.160, 0.120, 0.035, 1.00 },
    accent = { 0.860, 0.580, 0.080, 1.00 },
    accentBright = { 1.000, 0.820, 0.120, 1.00 },
    accentSoft = { 0.880, 0.740, 0.350, 1.00 },
    border = { 0.860, 0.580, 0.080, 0.95 },
    borderSoft = { 0.340, 0.340, 0.300, 0.90 },
    text = { 0.960, 0.960, 0.930, 1.00 },
    muted = { 0.580, 0.580, 0.540, 1.00 },
    subtle = { 0.500, 0.500, 0.500, 1.00 },
    good = { 0.420, 0.900, 0.460, 1.00 },
    red = { 0.950, 0.220, 0.180, 1.00 },
    info = { 0.240, 0.780, 1.000, 1.00 },
  },
  purple = {
    modernTabs = true,
    headerAsset = false,
    headerTextureAlpha = 0,
    backdropAlpha = 0.64,
    canvas = { 0.020, 0.024, 0.031, 0.58 },
    shell = { 0.031, 0.035, 0.047, 0.64 },
    surface = { 0.051, 0.063, 0.078, 0.78 },
    surfaceRaised = { 0.075, 0.086, 0.106, 0.84 },
    surfaceStrong = { 0.098, 0.114, 0.137, 0.90 },
    hover = { 0.710, 0.545, 0.980, 0.18 },
    selected = { 0.710, 0.545, 0.980, 0.27 },
    pressed = { 0.710, 0.545, 0.980, 0.36 },
    accent = { 0.710, 0.545, 0.980, 1.00 },
    accentBright = { 0.855, 0.780, 1.000, 1.00 },
    accentSoft = { 0.710, 0.545, 0.980, 0.72 },
    border = { 0.710, 0.545, 0.980, 0.92 },
    borderSoft = { 1.000, 1.000, 1.000, 0.16 },
    text = { 0.961, 0.965, 0.973, 1.00 },
    muted = { 0.678, 0.698, 0.737, 1.00 },
    subtle = { 0.455, 0.482, 0.525, 1.00 },
    good = { 0.420, 0.900, 0.460, 1.00 },
    red = { 0.950, 0.220, 0.180, 1.00 },
    info = { 0.420, 0.730, 1.000, 1.00 },
  },
}

local function Lighten(value, amount)
  return math.min(1, value + ((1 - value) * amount))
end

local function CreateClassPalette(red, green, blue, asset)
  local bright = {
    Lighten(red, 0.34),
    Lighten(green, 0.34),
    Lighten(blue, 0.34),
    1,
  }
  return {
    modernTabs = true,
    backdropAlpha = 0,
    headerAsset = asset,
    headerTextureAlpha = 0.44,
    canvas = { 0.010, 0.012, 0.016, 0.86 },
    shell = { 0.014, 0.016, 0.021, 0.88 },
    surface = { 0.028, 0.031, 0.038, 0.88 },
    surfaceRaised = { 0.046, 0.050, 0.060, 0.92 },
    surfaceStrong = { red, green, blue, 0.18 },
    hover = { red, green, blue, 0.18 },
    selected = { red, green, blue, 0.29 },
    pressed = { red, green, blue, 0.40 },
    accent = { red, green, blue, 1.00 },
    accentBright = bright,
    accentSoft = { red, green, blue, 0.72 },
    border = { red, green, blue, 0.92 },
    borderSoft = { red, green, blue, 0.30 },
    text = { 0.961, 0.965, 0.973, 1.00 },
    muted = { 0.678, 0.698, 0.737, 1.00 },
    subtle = { 0.455, 0.482, 0.525, 1.00 },
    good = { 0.420, 0.900, 0.460, 1.00 },
    red = { 0.950, 0.220, 0.180, 1.00 },
    info = bright,
  }
end

local classThemeRoot = "Interface\\AddOns\\MerfinPlus\\Media\\options\\class_themes\\"
palettes.deathknight = CreateClassPalette(196 / 255, 30 / 255, 58 / 255, classThemeRoot .. "deathknight.png")
palettes.demonhunter = CreateClassPalette(163 / 255, 48 / 255, 201 / 255, classThemeRoot .. "demonhunter.png")
palettes.druid = CreateClassPalette(255 / 255, 124 / 255, 10 / 255, classThemeRoot .. "druid.png")
palettes.hunter = CreateClassPalette(170 / 255, 211 / 255, 114 / 255, classThemeRoot .. "hunter.png")
palettes.mage = CreateClassPalette(63 / 255, 199 / 255, 235 / 255, classThemeRoot .. "mage.png")
palettes.monk = CreateClassPalette(0 / 255, 255 / 255, 152 / 255, classThemeRoot .. "monk.png")
palettes.paladin = CreateClassPalette(244 / 255, 140 / 255, 186 / 255, classThemeRoot .. "paladin.png")
palettes.priest = CreateClassPalette(255 / 255, 255 / 255, 255 / 255, classThemeRoot .. "priest.png")
palettes.rogue = CreateClassPalette(255 / 255, 244 / 255, 104 / 255, classThemeRoot .. "rogue.png")
palettes.shaman = CreateClassPalette(0 / 255, 112 / 255, 221 / 255, classThemeRoot .. "shaman.png")
palettes.warlock = CreateClassPalette(135 / 255, 136 / 255, 238 / 255, classThemeRoot .. "warlock.png")
palettes.warrior = CreateClassPalette(198 / 255, 155 / 255, 109 / 255, classThemeRoot .. "warrior.png")

local themeOrder = {
  "origin", "purple",
  "deathknight", "demonhunter", "druid", "hunter", "mage", "monk",
  "paladin", "priest", "rogue", "shaman", "warlock", "warrior",
}

local themeChoices = {
  origin = "Merfin Origin",
  purple = "Merfin Purple",
  deathknight = "Death Knight",
  demonhunter = "Demon Hunter",
  druid = "Druid",
  hunter = "Hunter",
  mage = "Mage",
  monk = "Monk",
  paladin = "Paladin",
  priest = "Priest",
  rogue = "Rogue",
  shaman = "Shaman",
  warlock = "Warlock",
  warrior = "Warrior",
}

-- The table and every color subtable stay stable so widgets that cache a
-- palette reference automatically receive the newly selected theme values.
MerfinPlus.UITheme = MerfinPlus.UITheme or {}
MerfinPlus.UIThemePalettes = palettes

local function CopyColor(target, source)
  for index = 1, 4 do target[index] = source[index] end
end

function MerfinPlus:ApplyUITheme(themeKey)
  themeKey = palettes[themeKey] and themeKey or THEME_DEFAULT
  local palette = palettes[themeKey]
  for name, value in pairs(palette) do
    if type(value) == "table" then
      self.UITheme[name] = self.UITheme[name] or {}
      CopyColor(self.UITheme[name], value)
    else
      self.UITheme[name] = value
    end
  end
  self.UITheme.current = themeKey
  return themeKey
end

function MerfinPlus:GetUIThemeKey()
  local stored = self.db and self.db.global and self.db.global.uiTheme
  return palettes[stored] and stored or self.UITheme.current or THEME_DEFAULT
end

function MerfinPlus:SetUITheme(themeKey)
  themeKey = self:ApplyUITheme(themeKey)
  if self.db and self.db.global then self.db.global.uiTheme = themeKey end
  if self.RefreshUITheme then self:RefreshUITheme() end
  return themeKey
end

function MerfinPlus:GetUIThemeChoices()
  return themeChoices
end

function MerfinPlus:GetUIThemeOrder()
  return themeOrder
end

function MerfinPlus:GetUIThemeColor(name, fallback)
  return (self.UITheme and self.UITheme[name]) or fallback
end

function MerfinPlus:GetUIThemeColorEscape(name)
  local color = self:GetUIThemeColor(name, { 1, 1, 1, 1 })
  return string.format(
    "|cff%02x%02x%02x",
    math.floor((color[1] or 1) * 255 + 0.5),
    math.floor((color[2] or 1) * 255 + 0.5),
    math.floor((color[3] or 1) * 255 + 0.5)
  )
end

function MerfinPlus:ColorizeUIThemeText(text, name)
  return self:GetUIThemeColorEscape(name or "accent") .. tostring(text or "") .. "|r"
end

local adjustedFontSizes = setmetatable({}, { __mode = "k" })

local function VisitFrameTree(root, callback, seen)
  if not root or seen[root] then return end
  seen[root] = true
  callback(root)
  if type(root.GetRegions) == "function" then
    for _, region in ipairs({ root:GetRegions() }) do VisitFrameTree(region, callback, seen) end
  end
  if type(root.GetChildren) == "function" then
    for _, child in ipairs({ root:GetChildren() }) do VisitFrameTree(child, callback, seen) end
  end
end

function MerfinPlus:ApplyUIFontSizeDelta(root)
  VisitFrameTree(root, function(object)
    if type(object.GetFont) ~= "function" or type(object.SetFont) ~= "function" then return end
    local ok, fontPath, currentSize, flags = pcall(object.GetFont, object)
    if not ok or type(fontPath) ~= "string" or type(currentSize) ~= "number" or currentSize <= 0 then return end

    local baseSize = adjustedFontSizes[object]
    if not baseSize then
      baseSize = currentSize
      adjustedFontSizes[object] = baseSize
    elseif math.abs(currentSize - math.max(14, baseSize + 1)) < 0.01 then
      return
    elseif math.abs(currentSize - baseSize) >= 0.01 then
      baseSize = currentSize
      adjustedFontSizes[object] = baseSize
    end
    self:ApplyLocalizedFont(object,
      "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf",
      math.max(14, baseSize + 1), flags)
  end, {})
end

function MerfinPlus:RestoreUIFontSizeDelta(root)
  VisitFrameTree(root, function(object)
    local baseSize = adjustedFontSizes[object]
    if not baseSize or type(object.GetFont) ~= "function" then return end
    local ok, fontPath, _, flags = pcall(object.GetFont, object)
    if ok and type(fontPath) == "string" then
      self:SafeSetFontPath(object, fontPath, baseSize, flags)
    end
    adjustedFontSizes[object] = nil
  end, {})
end

MerfinPlus:ApplyUITheme(THEME_DEFAULT)
