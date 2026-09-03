local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local LSM = LibStub("LibSharedMedia-3.0")

_G.Merfin = _G.Merfin or {}
local Merfin = _G.Merfin

local stformat = string.format
local pairs = pairs
local tonumber = tonumber

---------------------
-- Registering Sounds
---------------------

local lsmSoundFileNames = {}

lsmSoundFileNames.noloc = {
  "Alert Bell",
  "Important Mechanic",
  "Soft Alert",
  "Error",
  "Error 2",
  "Info Beep",
  "Level Up",
  "Spell On You",
  "Alarm",
  "Alert",
  "Pull Timer Start",
  "Boing",
  "Bloop",
  "Frog",
  "Chomp",
  "Bonk",
  "Info",
  "Long",
  "Spell Under You",
  "Victory",
  "Victory 2",
  "Critical Alert 1",
  "Soft Alert 1",
  "Soft Alert 2",
}

local voiceLineFileNames = {
  enUS = {
    "1",
    "2",
    "3",
    "4",
    "5",
    "Add Spawned",
    "Adds Spawned",
    "Air Phase",
    "AOE",
    "Avoid",
    "Bait",
    "Behind",
    "Burst the boss",
    "Close",
    "Dance",
    "Death Blossom Soon",
    "Defensive",
    "Dodge",
    "Double Right",
    "Explosion in",
    "Face away",
    "Far",
    "Forward",
    "Frontal",
    "High Stacks",
    "Interrupt",
    "Knockback",
    "Left",
    "Middle",
    "Move Out",
    "Move the boss",
    "Out",
    "Phase 1",
    "Phase 2",
    "Phase 3",
    "Phase 4",
    "Platform 2",
    "Platform 3",
    "Plus Damage",
    "Prepare for Frontal",
    "Prepare to Dodge",
    "Prepare to throw",
    "Right",
    "Run Away",
    "Run in",
    "Run out",
    "Spread Out",
    "Spread",
    "Stack with raid",
    "Stack",
    "Start in 1",
    "Start in 3",
    "Start in 4",
    "Stop Casting",
    "Switch Targets",
    "Tab",
    "Taunt",
    "Watch your feet",
    'Tank Phase',
    'Kite the boss',
  },
  ruRU = {
    "1",
    "2",
    "3",
    "4",
    "5",
    "Acid Geyser",
    "Agents Spawned",
    "Air Phase",
    "Avoid",
    "Bait",
    "Breath",
    "Burn Shield",
    "Burst the boss",
    "Dance",
    "Death and Decay",
    "Defensive",
    "Defensives",
    "Demon Form",
    "Double Right",
    "Emerge",
    "Enrage",
    "Eye Blast",
    "Face away",
    "Fear",
    "Fel Rage",
    "Frontal",
    "Gravity Lapse",
    "Heal Barrage",
    "Healthstone",
    "Human Form",
    "Interrupt",
    "Jump",
    "Jump Down",
    "Kill Demon",
    "Kill Totem",
    "Kite Phase",
    "Knockback",
    "Left",
    "Left Adds",
    "Loot Core",
    "Max Range",
    "Melee Interrupt",
    "Move Out",
    "Move the boss",
    "Murlocs Incoming",
    "Nature Phase",
    "New Elemental",
    "New Phoenix",
    "New Strider",
    "New Volcano",
    "Phase 1",
    "Phase 2",
    "Phase 3",
    "Phase 4",
    "Phase 5",
    "Platform 2",
    "Platform 3",
    "Plus Damage",
    "Prepare for Frontal",
    "Press Console",
    "Priest Spawned",
    "Range Interrupt",
    "Reflective Shield",
    "Right",
    "Right Adds",
    "Run Away",
    "Run in",
    "Run out",
    "Rune Shield",
    "Shield Stack Removed",
    "Spellsteal",
    "Spread",
    "Stack",
    "Stack with raid",
    "Start in 1",
    "Start in 3",
    "Start in 4",
    "Stop Casting",
    "Submerge",
    "Switch Targets",
    "Tank Phase",
    "Tank Swap",
    "Taunt",
    "Threat Reset",
    "Tranquilize",
    "Transition",
    "Use Shield",
    "Vanish",
    "Watch your feet",
    "Watery Globules",
    "Whirlwind",
    'TAB',
  },
  zhCN = {
    "Behind",
    "Burst the boss",
    "Forward",
    "Frontal",
    "Left",
    "Move Out",
    "Phase 1",
    "Phase 2",
    "Phase 3",
    "Phase 4",
    "Platform 2",
    "Platform 3",
    "Right",
    "Spread Out",
  },
}

local internalSoundFileNames = {}

internalSoundFileNames.Reminders = {
  "DrainSoul",
  "EatFeast",
  "Magefood",
  "Mailbox",
  "Repairbot",
  "SummonStone",
  "TakeHealhtstoneIdiot",
}

local soundPaths = {}
local mainPath = [[Interface\Addons\MerfinPlus\Media\sound]]
local GetSoundPath = function(folderPath, soundFileName)
  return stformat([[%s\%s\%s.mp3]], mainPath, folderPath, soundFileName)
end

local RegisterSounds = function(folderName, folderPath, RegisterLSM)
  for _, soundName in ipairs(lsmSoundFileNames[folderName]) do
    local soundPath = GetSoundPath(folderPath, soundName)
    soundPaths[soundName] = soundPath
    if RegisterLSM then
      LSM:Register("sound", "M: " .. soundName, soundPath)
    end
  end
end

local RegisterInternalSounds = function(fileNames, folderPath)
  for _, soundName in ipairs(fileNames) do
    soundPaths[soundName] = GetSoundPath(folderPath, soundName)
  end
end

local defaultCountdownVoiceActors = {
  enUS = { 1, 2 },
  deDE = { 5, 6 },
  frFR = { 7, 8 },
  ruRU = { 24, 10 },
  zhCN = { 13, 14 },
  zhTW = { 15, 16 },
}

local countdownVoiceActors = {
  [1] = { locale = "enUS", voice = "sally", name = "English (Sally)" },
  [2] = { locale = "enUS", voice = "alex", name = "English (Alex)" },
  [3] = { locale = "enUS", voice = "female", name = "English (female)" },
  [4] = { locale = "enUS", voice = "male", name = "English (male)" },
  [5] = { locale = "deDE", voice = "female", name = "German (female)" },
  [6] = { locale = "deDE", voice = "male", name = "German (male)" },
  [7] = { locale = "frFR", voice = "female", name = "French (female)" },
  [8] = { locale = "frFR", voice = "male", name = "French (male)" },
  [9] = { locale = "ruRU", voice = "female", name = "Russian (female)" },
  [10] = { locale = "ruRU", voice = "male", name = "Russian (male)" },
  [11] = { locale = "koKR", voice = "female", name = "Korean (female)" },
  [12] = { locale = "koKR", voice = "male", name = "Korean (male)" },
  [13] = { locale = "zhCN", voice = "female", name = "Chinese (Simplified) (female)" },
  [14] = { locale = "zhCN", voice = "male", name = "Chinese (Simplified) (male)" },
  [15] = { locale = "zhTW", voice = "female", name = "Chinese (Traditional) (female)" },
  [16] = { locale = "zhTW", voice = "male", name = "Chinese (Traditional) (male)" },
  [17] = { locale = "itIT", voice = "female", name = "Italian (female)" },
  [18] = { locale = "itIT", voice = "male", name = "Italian (male)" },
  [19] = { locale = "ptBR", voice = "female", name = "Portuguese (female)" },
  [20] = { locale = "ptBR", voice = "male", name = "Portuguese (male)" },
  [21] = { locale = "esES", voice = "female", name = "Spanish (Spain) (female)" },
  [22] = { locale = "esES", voice = "male", name = "Spanish (Spain) (male)" },
  [23] = { locale = "esMX", voice = "male", name = "Spanish (Mexico) (male)" },
  [24] = { locale = "ruRU", voice = "tao", extension = "mp3", name = "Russian (female tao)" },
}

local GetCountdownLocale = function()
  local locale = (Merfin.GetRPSoundLocale and Merfin.GetRPSoundLocale()) or (GetLocale and GetLocale()) or "enUS"
  return defaultCountdownVoiceActors[locale] and locale or "enUS"
end

local GetCountdownIndex = function(index)
  index = tonumber(index)
  if not index then
    return
  end

  local localeDefaults = defaultCountdownVoiceActors[GetCountdownLocale()]
  return localeDefaults[index] or index
end

local GetCountdownPath = function(index, second)
  second = tonumber(second)
  if not second or second < 1 or second > 5 or second % 1 ~= 0 then
    return
  end

  local voiceActor = countdownVoiceActors[GetCountdownIndex(index)]
  if not voiceActor then
    return
  end

  return stformat(
    [[Interface\AddOns\MerfinPlus\Media\sound\countdowns\%s\%s\%d.%s]],
    voiceActor.locale,
    voiceActor.voice,
    second,
    voiceActor.extension or "ogg"
  )
end

----------------
-- WeakAuras API
----------------
local reverseSoundKeys = {}

local GetSoundLocale = function()
  local locale = (Merfin.GetRPSoundLocale and Merfin.GetRPSoundLocale())
    or (Merfin.GetLocale and Merfin.GetLocale())
    or GetLocale()
  return (locale == "zhTW" and "zhCN") or locale
end

local BuildReverseSoundKeys = function(locale)
  if reverseSoundKeys[locale] then
    return reverseSoundKeys[locale]
  end

  local map = {}
  local raidLocale = Merfin.RaidLocalizations and Merfin.RaidLocalizations[locale]
  if raidLocale then
    for enUSKey, localizedText in pairs(raidLocale) do
      if type(enUSKey) == "string" and type(localizedText) == "string" then
        map[localizedText] = enUSKey
      end
    end
  end

  reverseSoundKeys[locale] = map
  return map
end

local GetSoundKey = function(text)
  if soundPaths[text] then
    return text
  end

  local locale = GetSoundLocale()
  if locale == "enUS" then
    return text
  end

  return BuildReverseSoundKeys(locale)[text]
end

local GetTTSConfig = function()
  return MerfinPlus.GetDB and MerfinPlus:GetDB() or {}
end

local GetVoiceID = function(voiceId)
  local cfg = GetTTSConfig()
  if cfg.ttsUseSpecificVoiceID then
    return cfg.ttsVoiceID or 1
  end

  if voiceId then
    return voiceId
  end

  if C_TTSSettings and C_TTSSettings.GetVoiceOptionID then
    return C_TTSSettings.GetVoiceOptionID(0)
  end

  return 1
end

local GetTTSText = function(text)
  if type(text) == "string" and Merfin.LRaid then
    return Merfin:LRaid(text)
  end

  return text
end

Merfin.PlaySound = function(text, speed, volume, voiceId)
  if not text then
    return false
  end

  local soundKey = GetSoundKey(text)
  if soundKey then
    local soundPath = soundPaths[soundKey]
    if soundPath then
      if PlaySoundFile(soundPath, "Master") then
        return true
      end
    end
  end

  local fallbackPath = LSM:Fetch("sound", "M: " .. text, true)
  if fallbackPath then
    if PlaySoundFile(fallbackPath, "Master") then
      return true
    end
  end

  local cfg = GetTTSConfig()
  if cfg.ttsEnabled == false then
    return false
  end

  if C_VoiceChat and C_VoiceChat.SpeakText then
    local rate = speed or cfg.ttsVoiceRate or 1
    local vol = (cfg.ttsApplyAll and cfg.ttsVolume) or volume or cfg.ttsVolume or 100

    C_VoiceChat.SpeakText(
      GetVoiceID(voiceId),
      GetTTSText(text),
      rate,
      vol
    )
    return true
  end

  return false
end

Merfin.GetCountdownVoiceActor = function(index)
  local voiceActor = countdownVoiceActors[GetCountdownIndex(index)]
  return voiceActor and voiceActor.name
end

Merfin.PlayCountdownSound = function(index, remainingSeconds)
  local soundPath = GetCountdownPath(index, remainingSeconds)
  if not soundPath then
    return false
  end

  return PlaySoundFile(soundPath, "Master") and true or false
end

MerfinPlus.RegisterSoundPaths = function()
  local locale = GetSoundLocale()
  RegisterSounds("noloc", "noloc", true)
  RegisterInternalSounds(voiceLineFileNames[locale] or {}, locale)
  RegisterInternalSounds(internalSoundFileNames.Reminders, "reminders")
end

--Merfin.RegisterSoundPaths()
