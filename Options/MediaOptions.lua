-- MerfinPlus media options.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local LSM = LibStub("LibSharedMedia-3.0")
-- Keep option labels in sync with a runtime UI-locale change.
local L = setmetatable({}, {
  __index = function(_, key)
    return MerfinPlus:T(key)
  end,
})

function MerfinPlus:ConfirmReload()
  StaticPopupDialogs["MERFINPLUS_RELOAD_UI"] = {
    text = L["A reload of the interface is required for this change to take effect.\n\nReload now?"],
    button1 = YES,
    button2 = NO,
    OnAccept = function()
      ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }
  StaticPopup_Show("MERFINPLUS_RELOAD_UI")
end

local function GetFontList()
  local fonts = {}
  local excluded = {
    ["Merfin Font 1"] = true,
    ["Merfin Font 2"] = true,
    ["Merfin Raid Font"] = true,
    ["Merfin Raid Font (Bold)"] = true,
  }
  for name in pairs(LSM:HashTable("font")) do
    if not excluded[name] then
      fonts[name] = name
    end
  end
  return fonts
end

local function GetStatusBarList()
  local bars = {}
  local excluded = {
    ["Merfin Status Bar 1"] = true,
    ["Merfin Status Bar 2"] = true,
    ["Merfin Raid Status Bar"] = true,
  }
  for name in pairs(LSM:HashTable("statusbar")) do
    if not excluded[name] then
      bars[name] = name
    end
  end
  return bars
end

function MerfinPlus:BuildMediaOptions()
  local mediaOptions = {
    type = "group",
    name = L["Media"],
    args = {
      description = {
        type = "description",
        name = L["Change primary fonts and status bar textures used by Merfin features. A UI reload is required."],
        fontSize = "medium",
        order = 0,
      },
    },
  }

  local fontNames = { "Merfin Font 1", "Merfin Font 2", "Merfin Raid Font", "Merfin Raid Font (Bold)" }
  local barNames = { "Merfin Status Bar 1", "Merfin Status Bar 2", "Merfin Raid Status Bar" }

  for i = 1, #fontNames do
    mediaOptions.args["font" .. i] = {
      type = "select",
      name = fontNames[i],
      desc = L["Select font for element "] .. i,
      values = GetFontList,
      get = function()
        return self.db.profile["font" .. i]
      end,
      set = function(_, v)
        self.db.profile["font" .. i] = v
        self:ConfirmReload()
      end,
      dialogControl = "MerfinPlusFontDropdown",
      width = 1.6,
      order = i + 1,
    }
  end

  for i = 1, #barNames do
    mediaOptions.args["bar" .. i] = {
      type = "select",
      name = barNames[i],
      desc = L["Select status bar texture for element "] .. i,
      values = GetStatusBarList,
      get = function()
        return self.db.profile["bar" .. i]
      end,
      set = function(_, v)
        self.db.profile["bar" .. i] = v
        self:ConfirmReload()
      end,
      dialogControl = "MerfinPlusStatusbarDropdown",
      width = 1.6,
      order = i + 10,
    }
  end

  return mediaOptions
end
