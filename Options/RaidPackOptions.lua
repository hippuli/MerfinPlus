-- MerfinPlus raid pack options.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
-- Raid Pack options must follow a runtime UI-locale change as well.
local L = setmetatable({}, {
  __index = function(_, key)
    return MerfinPlus:T(key)
  end,
})

local IsRaidPackSpecificLocalizationEnabled = function(db)
  if not db then
    return false
  end

  local useSpecificLocalization = rawget(db, "useSpecificLocalization")
  if useSpecificLocalization ~= nil then
    return useSpecificLocalization and true or false
  end

  local oldUseClientLocale = rawget(db, "useClientLocale")
  return oldUseClientLocale == false
end

function MerfinPlus:NormalizeRaidPackLocaleSettings()
  local db = self.db and self.db.profile
  if not db then
    return
  end

  local oldRaidLocale = rawget(db, "raidLocale")
  if oldRaidLocale then
    if rawget(db, "rpTextLocale") == nil then
      db.rpTextLocale = oldRaidLocale
    end
    if rawget(db, "rpSoundLocale") == nil then
      db.rpSoundLocale = oldRaidLocale
    end
    if rawget(db, "rpChatLocale") == nil then
      db.rpChatLocale = oldRaidLocale
    end
  end

  local oldUseClientLocale = rawget(db, "useClientLocale")
  if oldUseClientLocale ~= nil and rawget(db, "useSpecificLocalization") == nil then
    db.useSpecificLocalization = not oldUseClientLocale
  end
end

function MerfinPlus:BuildRaidPackOptions()
  local raidPackLocaleValues = {
    enUS = "enUS",
    deDE = "deDE",
    frFR = "frFR",
    esES = "esES",
    esMX = "esMX",
    itIT = "itIT",
    ptBR = "ptBR",
    ruRU = "ruRU",
    koKR = "koKR",
    zhCN = "zhCN",
    zhTW = "zhTW",
  }

  -- ==== RaidPack Localization ====
  local raidPack = {
    type = "group",
    name = L["Raid Settings"],
    childGroups = "tab",
    args = {
      localeSettings = {
        type = "group",
        name = L["Localization"],
        order = 3,
        get = function(info)
          return MerfinPlus.db.profile[info[#info]]
        end,
        set = function(info, value)
          MerfinPlus.db.profile[info[#info]] = value
        end,
        args = {
          header = {
            type = "header",
            name = L["Localization"],
            order = 0,
          },
          description = {
            type = "description",
            name = L["Here you can change the localization used by Merfin raid and dungeon packs when localization data is available. This is mainly used by Russian-speaking players. For additional localizations, please contact the Merfin staff."],
            order = 1,
            width = "full",
            fontSize = "medium",
          },
          useSpecificLocalization = {
            type = "toggle",
            name = L["Use Specific Localization"],
            order = 2,
            width = "full",
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              MerfinPlus:ConfirmReload()
            end,
          },
          rpTextLocale = {
            type = "select",
            name = L["Set Text Localization"],
            desc = L["Changes the language of text shown directly on auras, such as icons, bars, labels, and other on-aura elements."],
            order = 3,
            values = raidPackLocaleValues,
            width = "full",
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              MerfinPlus:ConfirmReload()
            end,
            disabled = function()
              return not MerfinPlus.db.profile.useSpecificLocalization
            end,
          },
          rpSoundLocale = {
            type = "select",
            name = L["Set Sound Localization"],
            desc = L["Changes the language used for voice lines and sound callouts."],
            order = 4,
            values = raidPackLocaleValues,
            width = "full",
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              MerfinPlus:ConfirmReload()
            end,
            disabled = function()
              return not MerfinPlus.db.profile.useSpecificLocalization
            end,
          },
          rpChatLocale = {
            type = "select",
            name = L["Set Chat Localization"],
            desc = L["Changes the language used when sending Merfin raid and dungeon pack messages to chat."],
            order = 5,
            values = raidPackLocaleValues,
            width = "full",
            set = function(info, value)
              MerfinPlus.db.profile[info[#info]] = value
              MerfinPlus:ConfirmReload()
            end,
            disabled = function()
              return not MerfinPlus.db.profile.useSpecificLocalization
            end,
          },
        },
      },
      textToSpeech = {
        type = "group",
        name = L["Text to Speech"],
        order = 4,
        get = function(info)
          return MerfinPlus.db.profile[info[#info]]
        end,
        set = function(info, value)
          MerfinPlus.db.profile[info[#info]] = value
        end,
        args = {
          header = {
            type = "header",
            name = L["Text to Speech"],
            order = 0,
          },
          ttsEnabled = {
            type = "toggle",
            name = L["Enable"],
            order = 1,
            width = 1,
          },
          ttsApplyAll = {
            type = "toggle",
            name = L["Apply on All"],
            order = 2,
            width = 1,
          },
          ttsVolume = {
            type = "range",
            name = L["Volume"],
            order = 3,
            min = 0,
            max = 100,
            step = 1,
            width = "double",
          },
          ttsUseSpecificVoiceID = {
            type = "toggle",
            name = L["Use Specific Voice ID"],
            order = 4,
            width = "full",
          },
          ttsVoiceID = {
            type = "input",
            name = L["Voice ID"],
            order = 5,
            width = 1.5,
            get = function()
              return tostring(MerfinPlus.db.profile.ttsVoiceID or 1)
            end,
            set = function(_, value)
              MerfinPlus.db.profile.ttsVoiceID = tonumber(value) or 1
            end,
          },
          ttsVoiceRate = {
            type = "range",
            name = L["Voice Rate"],
            order = 6,
            min = 0.1,
            max = 5,
            step = 0.1,
            width = 1.5,
          },
          voiceIdHelp = {
            type = "description",
            name = L["You can check for available voice IDs by checking \"Play Test Sound?\" option"],
            order = 7,
            width = "full",
            fontSize = "medium",
          },
          ttsTestText = {
            type = "input",
            name = L["Test Text"],
            order = 8,
            width = 1.5,
          },
          playTestSound = {
            type = "execute",
            name = L["Play Test Sound?"],
            order = 9,
            width = 1,
            func = function()
              if Merfin and Merfin.PlaySound then
                Merfin.PlaySound(MerfinPlus.db.profile.ttsTestText or "Merfin Test Sound")
              end
            end,
          },
        },
      },
    },
  }

  local currentLocale = GAME_LOCALE or GetLocale()
  local GetRaidPackProfileLocale = function(key)
    local db = MerfinPlus.db.profile
    if not IsRaidPackSpecificLocalizationEnabled(db) then
      return currentLocale
    end

    return db[key] or db.raidLocale or currentLocale
  end

  Merfin.IsRPSpecificLocalization = function()
    local db = MerfinPlus.db.profile
    return IsRaidPackSpecificLocalizationEnabled(db)
  end

  Merfin.GetRPTextLocale = function()
    return GetRaidPackProfileLocale("rpTextLocale")
  end

  Merfin.GetRPSoundLocale = function()
    return GetRaidPackProfileLocale("rpSoundLocale")
  end

  Merfin.GetRPChatLocale = function()
    return GetRaidPackProfileLocale("rpChatLocale")
  end

  local showTBCWaSettings = function()
    return not MerfinPlus:IsMoP()
      or MerfinPlus.db.profile.enableTBCWaSettingsOnMoP
  end

  if MerfinPlus:IsMoP() then
    raidPack.args.mopTBCWaSettings = {
      type = "group",
      name = "MoP Aura Testing",
      order = 3,
      args = {
        description = {
          type = "description",
          name = "Temporarily expose the TBC Auto-Marker and legacy Raid Cooldown settings while testing WeakAuras on MoP. This does not replace the native MoP cooldown tracker.",
          order = 1,
          width = "full",
        },
        enableTBCWaSettingsOnMoP = {
          type = "toggle",
          name = "Show TBC Auto-Marker and Cooldown settings",
          order = 2,
          width = "full",
          get = function()
            return MerfinPlus.db.profile.enableTBCWaSettingsOnMoP
          end,
          set = function(_, value)
            MerfinPlus.db.profile.enableTBCWaSettingsOnMoP = value and true or false
            AceConfigRegistry:NotifyChange("MerfinPlus_RaidPack")
          end,
        },
      },
    }
  end

  if MerfinPlus.BuildReadyCheckOptions then
    local readyCheck = MerfinPlus:BuildReadyCheckOptions()
    readyCheck.order = 5
    raidPack.args.readyCheck = readyCheck
  end

  if MerfinPlus.BuildRaidAutoMarkerOptions then
    local autoMarker = MerfinPlus:BuildRaidAutoMarkerOptions()
    autoMarker.order = 2
    autoMarker.hidden = function()
      return not showTBCWaSettings()
    end
    raidPack.args.autoMarker = autoMarker
  end

  if MerfinPlus.BuildRaidCooldownOptions then
    local cooldowns = MerfinPlus:BuildRaidCooldownOptions()
    cooldowns.order = 1
    cooldowns.hidden = function()
      return not showTBCWaSettings()
    end
    raidPack.args.cooldowns = cooldowns
  end

  return raidPack
end
