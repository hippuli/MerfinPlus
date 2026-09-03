local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local LSM = LibStub("LibSharedMedia-3.0")
local Locale = GetLocale()
local isTitan = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local function GetActiveUILocale()
  return (MerfinPlus.GetUILocale and MerfinPlus:GetUILocale()) or Locale
end

local function UsesChineseFont()
  local locale = GetActiveUILocale()
  return locale == "zhTW" or locale == "zhCN"
end

local function UsesKoreanFont()
  return GetActiveUILocale() == "koKR"
end

local function UsesJapaneseFont()
  return GetActiveUILocale() == "jaJP"
end

-- This is the locale-correct Blizzard font path on a Korean client. Register it
-- as an LSM entry so existing MerfinPlus defaults never select a Latin-only font.
if STANDARD_TEXT_FONT and LSM.LOCALE_BIT_koKR then
  LSM:Register("font", "Korean Client Default", STANDARD_TEXT_FONT, LSM.LOCALE_BIT_koKR)
end

MerfinPlus.GetDefaultFont = function(type)
  if UsesChineseFont() or isTitan then
    return "CN Merged (SF-Yahee)"
  end
  if UsesKoreanFont() then
    return "Noto Sans CJK KR"
  end
  if UsesJapaneseFont() then
    return "CN Merged (SF-Yahee)"
  end
  return type == "bold" and "SFUIDisplayCondensed-Bold" or "SFUIDisplayCondensed-Semibold"
end

MerfinPlus.GetDefaultRaidFont = function(type)
  if UsesChineseFont() or isTitan then
    return "CN Merged (SF-Yahee)"
  end
  if UsesKoreanFont() then
    return "Noto Sans CJK KR"
  end
  if UsesJapaneseFont() then
    return "CN Merged (SF-Yahee)"
  end
  return type == "bold" and "PT Sans Narrow Bold" or "PT Sans Narrow"
end

Merfin.GetDefaultFont = MerfinPlus.GetDefaultFont
Merfin.GetDefaultRaidFont = MerfinPlus.GetDefaultRaidFont

function MerfinPlus:RegisterCustomFonts()
  local db = self:GetDB()
  local fonts = {
    { key = "font1", name = "Merfin Font 1" },
    { key = "font2", name = "Merfin Font 2" },
    { key = "font3", name = "Merfin Raid Font" },
    { key = "font4", name = "Merfin Raid Font (Bold)" },
  }
  for _, f in ipairs(fonts) do
    local path = LSM:Fetch("font", db[f.key], true)
    if path then
      LSM:Register(
        "font",
        f.name,
        path,
        LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW
      )
    else
      -- print(string.format("|cffff0000[MerfinPlus]|r Failed to register %s - invalid font path", f.name))
    end
  end
end

function MerfinPlus:RegisterCustomBars()
  local db = self:GetDB()
  local bars = {
    { key = "bar1", name = "Merfin Status Bar 1" },
    { key = "bar2", name = "Merfin Status Bar 2" },
    { key = "bar3", name = "Merfin Raid Status Bar" },
  }
  for _, b in ipairs(bars) do
    local path = LSM:Fetch("statusbar", db[b.key], true)
    if path then
      LSM:Register("statusbar", b.name, path)
    else
      -- print(string.format("|cffff0000[MerfinPlus]|r Failed to register %s - invalid status bar path", b.name))
    end
  end
end

-- Mirror current selection under alias names for other addons/WA to consume
function MerfinPlus:RegisterMediaAliasesFromCallback()
  local db = self:GetDB()

  local fontMap = {
    { key = db.font1, alias = "Merfin Font 1" },
    { key = db.font2, alias = "Merfin Font 2" },
    { key = db.font3, alias = "Merfin Raid Font" },
    { key = db.font4, alias = "Merfin Raid Font (Bold)" },
  }
  local barMap = {
    { key = db.bar1, alias = "Merfin Status Bar 1" },
    { key = db.bar2, alias = "Merfin Status Bar 2" },
    { key = db.bar3, alias = "Merfin Raid Status Bar" },
  }

  LSM.RegisterCallback(self, "LibSharedMedia_Registered", function(_, mediatype, key)
    if mediatype == "font" then
      for _, e in ipairs(fontMap) do
        if e.key == key then
          local path = LSM:Fetch("font", e.key)
          if path then
            LSM:Register(
              "font",
              e.alias,
              path,
              LSM.LOCALE_BIT_western
                + LSM.LOCALE_BIT_ruRU
                + LSM.LOCALE_BIT_koKR
                + LSM.LOCALE_BIT_zhCN
                + LSM.LOCALE_BIT_zhTW
            )
          end
        end
      end
    elseif mediatype == "statusbar" or mediatype == "statusbar_atlas" then
      for _, e in ipairs(barMap) do
        if e.key == key then
          local path = LSM:Fetch("statusbar", e.key)
          if path then
            LSM:Register("statusbar", e.alias, path)
          end
        end
      end
    end
  end)
end
