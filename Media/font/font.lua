local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local LSM = LibStub("LibSharedMedia-3.0")

local L = GetLocale()

local localizedFonts = {
  ["enUS"] = "Expressway.ttf",
  ["ruRU"] = "Expressway.ttf",
}

local SetMediaName = function(name)
  return "Merfin: " .. name
end

local RegisterFont = function(name, filename, locales)
  LSM:Register("font", name, ([[Interface\AddOns\MerfinPlus\Media\font\%s]]):format(filename), locales)
end

local LSM = LibStub("LibSharedMedia-3.0")

local RegisterFont = function(name, filename, locales)
  LSM:Register("font", name, ([[Interface\AddOns\MerfinPlus\Media\font\%s]]):format(filename), locales)
end

function MerfinPlus:RegisterFonts()
  local WEST = LSM.LOCALE_BIT_western
  local RU = LSM.LOCALE_BIT_ruRU
  local ZHCN = LSM.LOCALE_BIT_zhCN
  local ZHTW = LSM.LOCALE_BIT_zhTW
  local KOKR = LSM.LOCALE_BIT_koKR

  -- Latin/RU
  RegisterFont("ArchivoNarrow-Bold", "ArchivoNarrow-Bold.ttf", WEST + RU)
  RegisterFont("Expressway", "Expressway.ttf", WEST + RU)
  RegisterFont("HOOGE", "HOOGE.TTF", WEST + RU + ZHCN + ZHTW)
  RegisterFont("SFUIDisplayCondensed-Bold", "SFUIDisplayCondensed-Bold.otf", WEST + RU)
  RegisterFont("SFUIDisplayCondensed-Semibold", "SFUIDisplayCondensed-Semibold.otf", WEST + RU)
  RegisterFont("PT Sans Narrow", "PTSansNarrow.ttf", WEST + RU)
  RegisterFont("PT Sans Narrow Bold", "PTSansNarrow-Bold.ttf", WEST + RU)

  -- OFL-cleared Guild Manager assignment families. Their exact files and
  -- licenses live under Media\font\assignment; existing registrations above
  -- remain unchanged.
  RegisterFont("Arimo", "assignment\\arimo-variable.ttf", WEST + RU)
  RegisterFont("Archivo Narrow", "assignment\\archivo-narrow-variable.ttf", WEST)
  RegisterFont("Anton", "assignment\\anton-regular.ttf", WEST)
  RegisterFont("Oxanium", "assignment\\oxanium-variable.ttf", WEST)
  RegisterFont("Grandstander", "assignment\\grandstander-variable.ttf", WEST)
  RegisterFont("Michroma", "assignment\\michroma-regular.ttf", WEST)
  RegisterFont("Nunito Sans", "assignment\\nunito-sans-variable.ttf", WEST + RU)

  -- Chinese-capable
  --if L == 'zhTW' or L == 'zhCN' then
  RegisterFont("CN Merged (SF-Yahee)", "CN Merged (SF-Yahee).ttf", WEST + ZHCN + ZHTW)
  -- One complete CJK font for the manual language selector: Hangul, Japanese,
  -- simplified Chinese and traditional Chinese are all present in this file.
  RegisterFont("Noto Sans CJK KR", "NotoSansCJKkr-Regular.otf", WEST + KOKR + ZHCN + ZHTW)
  --end
end
