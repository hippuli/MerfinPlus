Merfin = Merfin or {}
Merfin.Localizations = Merfin.Localizations or {}
Merfin.RaidLocalizations = Merfin.RaidLocalizations or {}
Merfin.RaidChatLocalizations = Merfin.RaidChatLocalizations or {}
Merfin.RaidSpellLocalizations = Merfin.RaidSpellLocalizations or {}

-- Add or override keys for a specific locale
function Merfin:AddLocaleLang(locale, data)
  local dst = self.Localizations[locale] or {}
  for k, v in pairs(data) do
    dst[k] = v
  end
  self.Localizations[locale] = dst
end

function Merfin:AddRaidLocaleLang(locale, data)
  local dst = self.RaidLocalizations[locale] or {}
  for k, v in pairs(data) do
    dst[k] = v
  end
  self.RaidLocalizations[locale] = dst
end

function Merfin:AddRaidChatLocaleLang(locale, data)
  local dst = self.RaidChatLocalizations[locale] or {}
  for k, v in pairs(data) do
    dst[k] = v
  end
  self.RaidChatLocalizations[locale] = dst
end

function Merfin:AddRaidSpellLocaleLang(locale, data)
  local dst = self.RaidSpellLocalizations[locale] or {}
  for k, v in pairs(data) do
    dst[k] = v
  end
  self.RaidSpellLocalizations[locale] = dst
end

local function BuildLowerKeyMap(src)
  if not src then
    return
  end

  local map = {}
  for k in pairs(src) do
    if type(k) == "string" then
      map[k:lower()] = k
    end
  end

  return map
end

local function FinalizeLocaleTable(localizations, defaultLocale)
  local baseLocale = defaultLocale or "enUS"
  local base = localizations[baseLocale] or {}
  for locale, tbl in pairs(localizations) do
    if locale ~= baseLocale then
      setmetatable(tbl, { __index = base })
    end
  end
end

-- Set fallback to enUS for any missing keys
function Merfin:FinalizeLocales(defaultLocale)
  FinalizeLocaleTable(self.Localizations, defaultLocale)

  -- build lowercase maps after all locales are finalized
  self.LocaleKeyMap = self.LocaleKeyMap or {}
  for locale in pairs(self.Localizations) do
    self:BuildLowerKeyMap(locale)
  end
end

function Merfin:FinalizeRaidLocales(defaultLocale)
  FinalizeLocaleTable(self.RaidLocalizations, defaultLocale)

  self.RaidLocaleKeyMap = self.RaidLocaleKeyMap or {}
  for locale in pairs(self.RaidLocalizations) do
    self:BuildRaidLowerKeyMap(locale)
  end

  self.RaidChatLocaleKeyMap = self.RaidChatLocaleKeyMap or {}
  for locale in pairs(self.RaidChatLocalizations) do
    self:BuildRaidChatLowerKeyMap(locale)
  end
end

Merfin.LocaleKeyMap = Merfin.LocaleKeyMap or {}
Merfin.RaidLocaleKeyMap = Merfin.RaidLocaleKeyMap or {}
Merfin.RaidChatLocaleKeyMap = Merfin.RaidChatLocaleKeyMap or {}

function Merfin:BuildLowerKeyMap(locale)
  local locs = self.Localizations or {}
  self.LocaleKeyMap[locale] = BuildLowerKeyMap(locs[locale])
end

function Merfin:BuildRaidLowerKeyMap(locale)
  local locs = self.RaidLocalizations or {}
  self.RaidLocaleKeyMap[locale] = BuildLowerKeyMap(locs[locale])
end

function Merfin:BuildRaidChatLowerKeyMap(locale)
  local locs = self.RaidChatLocalizations or {}
  self.RaidChatLocaleKeyMap[locale] = BuildLowerKeyMap(locs[locale])
end

local function GetLocalizedValue(self, key, vars, locale, localizations, keyMap, buildMap, useBaseFallback)
  local locs = localizations or {}
  local cur = locs[locale] or {}
  local base = locs.enUS or {}

  -- Lowercase maps (lazy build if needed)
  if not keyMap[locale] then
    buildMap(self, locale)
  end
  if useBaseFallback and not keyMap["enUS"] then
    buildMap(self, "enUS")
  end

  local curMap = keyMap[locale]
  local baseMap = useBaseFallback and keyMap["enUS"] or nil

  local s

  -- exact match first (fastest)
  s = rawget(cur, key)
  if not s and useBaseFallback then
    s = rawget(base, key)
  end

  -- case-insensitive lookup (also fast)
  if not s and type(key) == "string" then
    local lk = key:lower()

    local realKey = (curMap and curMap[lk]) or (baseMap and baseMap[lk])

    if realKey then
      s = rawget(cur, realKey)
      if not s and useBaseFallback then
        s = rawget(base, realKey)
      end
    end
  end

  -- fallback to key itself
  if not s then
    s = key
  end

  -- variable replacement logic remains unchanged
  if not vars then
    return s
  end

  if type(vars) == "table" then
    s = s:gsub("%%{(%w+)}", function(k)
      local v = vars[k]
      return v ~= nil and tostring(v) or ""
    end)

    if vars[1] ~= nil then
      s = string.format(s, unpack(vars))
    end
  end

  return s
end

function Merfin:L(key, vars, localeOverride)
  local locale = localeOverride or (GetLocale and GetLocale()) or "enUS"
  self.LocaleKeyMap = self.LocaleKeyMap or {}
  return GetLocalizedValue(self, key, vars, locale, self.Localizations, self.LocaleKeyMap, self.BuildLowerKeyMap, true)
end

function Merfin:LRaid(key, vars, localeOverride)
  local locale = localeOverride
    or (Merfin.GetRPTextLocale and Merfin.GetRPTextLocale())
    or (GetLocale and GetLocale())
    or "enUS"
  self.RaidLocaleKeyMap = self.RaidLocaleKeyMap or {}
  return GetLocalizedValue(
    self,
    key,
    vars,
    locale,
    self.RaidLocalizations,
    self.RaidLocaleKeyMap,
    self.BuildRaidLowerKeyMap,
    false
  )
end

function Merfin.ChatMessage(msg, chatType, ...)
  if msg == nil then
    return
  end

  local locale = (Merfin.GetRPChatLocale and Merfin.GetRPChatLocale()) or (GetLocale and GetLocale()) or "enUS"
  Merfin.RaidChatLocaleKeyMap = Merfin.RaidChatLocaleKeyMap or {}
  local message = GetLocalizedValue(
    Merfin,
    msg,
    nil,
    locale,
    Merfin.RaidChatLocalizations,
    Merfin.RaidChatLocaleKeyMap,
    Merfin.BuildRaidChatLowerKeyMap,
    false
  )
  message = tostring(message)

  if select("#", ...) > 0 then
    message = string.format(message, ...)
  end

  SendChatMessage(message, chatType or "SAY")
end
