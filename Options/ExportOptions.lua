-- MerfinPlus Export option group.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local function EnsureDeletePopup()
  if StaticPopupDialogs.MERFINPLUS_DELETE_RECORDED_RAID then
    return
  end
  StaticPopupDialogs.MERFINPLUS_DELETE_RECORDED_RAID = {
    text = MerfinPlus:T("Delete the selected recorded raid?\n\n%s"),
    button1 = MerfinPlus:T("Delete"),
    button2 = MerfinPlus:T("Cancel"),
    OnAccept = function(_, sessionID)
      MerfinPlus:DeleteLootSession(sessionID)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }
end

function MerfinPlus:ConfirmDeleteSelectedLootSession()
  EnsureDeletePopup()
  local session = self:GetSelectedLootSession()
  if session then
    StaticPopup_Show("MERFINPLUS_DELETE_RECORDED_RAID", self:GetLootSessionLabel(session), nil, session.id)
  end
end

function MerfinPlus:BuildExportOptions()
  EnsureDeletePopup()

  return {
    type = "group",
    name = MerfinPlus:T("Export"),
    args = {
      lootHeader = {
        type = "header",
        name = MerfinPlus:T("Loot Tracking"),
        order = 10,
      },
      expansion = {
        type = "description",
        name = function()
          local _, label = MerfinPlus:GetExportExpansionInfo()
          return MerfinPlus:T(
            "Detected expansion: %s",
            MerfinPlus:ColorizeUIThemeText(label, "accent")
          )
        end,
        order = 20,
      },
      trackLoot = {
        type = "toggle",
        name = MerfinPlus:T("Track Loot"),
        desc = MerfinPlus:T("Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."),
        get = function()
          local storage = MerfinPlus:GetExportStorage()
          return storage and storage.trackLoot or false
        end,
        set = function(_, value)
          local storage = MerfinPlus:GetExportStorage()
          if storage then
            storage.trackLoot = value and true or false
          end
        end,
        order = 30,
      },
      recordedRaids = {
        type = "select",
        name = MerfinPlus:T("Recorded Raids"),
        values = function()
          return MerfinPlus:GetLootSessionValues()
        end,
        sorting = function()
          return MerfinPlus:GetLootSessionOrder()
        end,
        get = function()
          local session = MerfinPlus:GetSelectedLootSession()
          return session and session.id or ""
        end,
        set = function(_, value)
          if value and value ~= "" then
            MerfinPlus:SelectLootSession(value)
          end
        end,
        width = 2.35,
        order = 40,
      },
      lootItemCount = {
        type = "description",
        name = function()
          local _, count = MerfinPlus:BuildLootExport(MerfinPlus:GetSelectedLootSession())
          return "   " .. MerfinPlus:ColorizeUIThemeText(MerfinPlus:T("Items:"), "accent")
            .. " " .. tostring(count or 0)
        end,
        width = 0.65,
        order = 41,
      },
      lootExport = {
        type = "input",
        name = MerfinPlus:T("Raid Export"),
        multiline = 8,
        dialogControl = "MerfinPlusExportEditBox",
        arg = "loot",
        width = "full",
        get = function()
          return MerfinPlus:BuildLootExport(MerfinPlus:GetSelectedLootSession())
        end,
        set = function() end,
        order = 50,
      },
      lootActions = {
        type = "execute",
        name = "",
        dialogControl = "MerfinPlusLootActions",
        disabled = function()
          return MerfinPlus:GetSelectedLootSession() == nil
        end,
        func = function() end,
        width = "full",
        order = 60,
      },
      guildHeader = {
        type = "header",
        name = MerfinPlus:T("Guild Export"),
        order = 100,
      },
      guildDescription = {
        type = "description",
        name = function()
          local _, label, maxLevel = MerfinPlus:GetExportExpansionInfo()
          return MerfinPlus:T(
            "Exports only level %s players for %s, using the Guild Manager roster schema.",
            tostring(maxLevel or "?"),
            tostring(label)
          )
        end,
        order = 110,
      },
      guildStatus = {
        type = "description",
        name = function()
          local state = MerfinPlus:GetExportUIState()
          if state.guildExportStatusArgs then
            return MerfinPlus:T(
              state.guildExportStatus,
              unpack(state.guildExportStatusArgs)
            )
          end
          return MerfinPlus:T(state.guildExportStatus)
        end,
        order = 120,
      },
      guildExport = {
        type = "input",
        name = MerfinPlus:T("Guild Export"),
        multiline = 8,
        dialogControl = "MerfinPlusExportEditBox",
        arg = "guild",
        width = "full",
        get = function()
          return MerfinPlus:GetExportUIState().guildExportText
        end,
        set = function(_, value)
          MerfinPlus:GetExportUIState().guildExportText = value or ""
        end,
        order = 130,
      },
      guildActions = {
        type = "execute",
        name = "",
        dialogControl = "MerfinPlusGuildActions",
        func = function()
          MerfinPlus:GenerateGuildExport()
        end,
        width = "full",
        order = 140,
      },
    },
  }
end
