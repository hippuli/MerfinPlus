local MerfinPlus = LibStub('AceAddon-3.0'):GetAddon('MerfinPlus')
local L = setmetatable({}, { __index = function(_, key) return MerfinPlus:T(key) end })
local linksMediaPath = 'Interface\\AddOns\\MerfinPlus\\Media\\icons\\Links\\'
local linksWidgetData = {
  socials = {
    heading = L['Socials'],
    links = {
      {
        name = 'Discord',
        icon = linksMediaPath .. 'discord',
        url = 'https://discord.gg/merfin',
      },
      {
        name = 'Patreon',
        badge = L['SUB CONTENT'],
        badgeFontSize = 9,
        icon = linksMediaPath .. 'patreon',
        url = 'https://patreon.com/MerfinUI',
      },
      {
        name = 'Twitch',
        icon = linksMediaPath .. 'twitch',
        url = 'https://twitch.tv/merfin',
      },
      {
        name = 'Boosty',
        badge = L['SUB CONTENT'],
        badgeFontSize = 9,
        icon = linksMediaPath .. 'boosty',
        url = 'https://boosty.to/merfin',
      },
    },
  },
  addons = {
    heading = L['AddOns'],
    links = {
      {
        name = 'MerfinUI',
        badge = L['SUB CONTENT'],
        icon = linksMediaPath .. 'merfinui',
        url = 'https://discord.gg/merfin',
        spinOnHover = true,
        spinInterval = 3,
      },
      {
        name = 'MerfinPlus',
        icon = linksMediaPath .. 'merfinui',
        url = 'https://www.curseforge.com/wow/addons/merfinplus',
        spinOnHover = true,
        spinInterval = 3,
      },
    },
  },
  weakAuras = {
    heading = 'WeakAuras',
    title = L['WeakAuras Package'],
    description = L['Class Auras, General Auras, Raid Packs, and more.'],
    badge = L['SUB CONTENT'],
    icon = linksMediaPath .. 'weakauras',
  },
}

MerfinPlus:RegisterLinksWidget('MerfinPlusLinks', linksWidgetData)

function MerfinPlus:BuildAboutOptions()
  return {
    type = 'group', name = self:T('About'), args = {
      links = { type = 'description', name = '', order = 1, width = 'full', dialogControl = 'MerfinPlusLinks' },
    },
  }
end
