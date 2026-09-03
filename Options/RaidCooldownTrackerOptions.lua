-- Standalone Raid Cooldown frontend configuration.
-- The existing Raid Settings cooldown options remain in RaidCooldownOptions.lua.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local selectedAdvancedByRenderer = {}
local selectedOrderByRenderer = {}
local newAdvanced = { spellID = "", spellName = "" }
local newOrder = { spellID = "", spellName = "", index = 1 }
local deferredTrackerRefreshes = {}

local function T(key)
  return MerfinPlus:T(key)
end

local function SpellName(spellID)
  spellID = tonumber(spellID)
  if not spellID then
    return nil
  end
  if C_Spell and C_Spell.GetSpellName then
    return C_Spell.GetSpellName(spellID)
  end
  if GetSpellInfo then
    return GetSpellInfo(spellID)
  end
end

local function SpellTexture(spellID)
  spellID = tonumber(spellID)
  if not spellID then
    return nil
  end
  if C_Spell and C_Spell.GetSpellTexture then
    return C_Spell.GetSpellTexture(spellID)
  end
  if GetSpellTexture then
    return GetSpellTexture(spellID)
  end
end

local function IsPositiveInteger(value)
  value = tonumber(value)
  return value and value > 0 and value == math.floor(value)
end

local function ValidateSpellID(_, value)
  if value == nil or value == "" or not IsPositiveInteger(value) then
    return T("A positive spell ID is required.")
  end
  return true
end

local function SpellLabel(spellID, customName, className)
  local name = customName
  if type(name) ~= "string" or name == "" then
    name = SpellName(spellID) or (T("Spell ID") .. " " .. tostring(spellID))
  end
  local texture = SpellTexture(spellID)
  local label = texture and ("|T%s:16:16:0:0|t %s"):format(texture, name) or name
  local color = className and RAID_CLASS_COLORS and RAID_CLASS_COLORS[className]
  if color then
    local colorCode = color.colorStr or ("ff%02x%02x%02x"):format(
      math.floor((color.r or 1) * 255 + 0.5),
      math.floor((color.g or 1) * 255 + 0.5),
      math.floor((color.b or 1) * 255 + 0.5)
    )
    return ("|c%s%s|r"):format(colorCode, label)
  end
  return label
end

local function CurrentRendererKey()
  return MerfinPlus:GetRaidCooldownSelectedGeneralRenderer()
end

local function RefreshTracker(scopedPath, deferTrackerRefresh)
  if not deferTrackerRefresh or not (C_Timer and C_Timer.After) then
    MerfinPlus:NotifyRaidCooldownTrackerChanged(scopedPath)
    return
  end

  local generation = (deferredTrackerRefreshes[scopedPath] or 0) + 1
  deferredTrackerRefreshes[scopedPath] = generation
  C_Timer.After(0.05, function()
    if deferredTrackerRefreshes[scopedPath] ~= generation then
      return
    end
    deferredTrackerRefreshes[scopedPath] = nil
    MerfinPlus:NotifyRaidCooldownTrackerChanged(scopedPath)
  end)
end

local function Notify(path, refreshOptions, deferTrackerRefresh)
  local rendererKey = CurrentRendererKey()
  local scopedPath = rendererKey and ("renderers.%s.%s"):format(rendererKey, path) or path
  RefreshTracker(scopedPath, deferTrackerRefresh)
  if refreshOptions then
    AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
  end
end

local function Current(rendererKey)
  rendererKey = rendererKey or CurrentRendererKey()
  return rendererKey
    and MerfinPlus:EnsureRaidCooldownRendererConfig(rendererKey)
    or nil
end

local function SelectedAdvancedIndex(value)
  local rendererKey = CurrentRendererKey()
  if not rendererKey then
    return 1
  end
  if value then
    selectedAdvancedByRenderer[rendererKey] = value
  end
  return selectedAdvancedByRenderer[rendererKey] or 1
end

local function SelectedOrderIndex(value)
  local rendererKey = CurrentRendererKey()
  if not rendererKey then
    return 1
  end
  if value then
    selectedOrderByRenderer[rendererKey] = value
  end
  return selectedOrderByRenderer[rendererKey] or 1
end

local function EntryValues(entries)
  local values = {}
  for index, entry in ipairs(entries or {}) do
    values[index] = SpellLabel(entry.spellID, entry.spellName)
      .. (" |cff888888(#%d)|r"):format(index)
  end
  return values
end

local function FindEntry(entries, spellID)
  spellID = tostring(math.floor(tonumber(spellID) or 0))
  for index, entry in ipairs(entries or {}) do
    if tostring(entry.spellID) == spellID then
      return index
    end
  end
end

local function AddEntry(entries, draft, includeRoles)
  if not IsPositiveInteger(draft.spellID) then
    return nil
  end
  local existing = FindEntry(entries, draft.spellID)
  if existing then
    return existing
  end
  local entry = {
    spellID = tostring(math.floor(tonumber(draft.spellID))),
    spellName = type(draft.spellName) == "string" and draft.spellName or "",
  }
  if includeRoles then
    entry.dps = true
    entry.tank = true
    entry.healer = true
  else
    entry.index = math.max(1, math.floor(tonumber(draft.index) or 1))
  end
  entries[#entries + 1] = entry
  return #entries
end

local function BuildAdvancedDisplayOptions(rendererKey, expansionKey)
  local function Entries()
    local config = rendererKey
      and MerfinPlus:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
      or nil
    return config and config.advanced.display or {}
  end
  local function SelectedIndex(value)
    if not rendererKey then return 1 end
    if value then selectedAdvancedByRenderer[rendererKey] = value end
    return selectedAdvancedByRenderer[rendererKey] or 1
  end
  local function Selected()
    local entries = Entries()
    if #entries == 0 then
      return nil
    end
    local index = math.min(math.max(1, SelectedIndex()), #entries)
    SelectedIndex(index)
    return entries[index]
  end
  local function NotifyAdvanced(path, deferTrackerRefresh)
    local scopedPath = ("renderers.%s.%s"):format(rendererKey, path)
    RefreshTracker(scopedPath, deferTrackerRefresh)
  end

  local function SetSelectedRole(role, value)
    local entry = Selected()
    if not entry then
      return
    end

    entry.dps = entry.dps == true
    entry.tank = entry.tank == true
    entry.healer = entry.healer == true
    entry[role] = value == true
    -- The clicked AceConfig toggle already owns its visual state. Rebuilding
    -- the complete standalone tree here interrupts the click and jumps the
    -- scroll position before the new value can be shown.
    NotifyAdvanced("advanced.display." .. role, true)
  end

  return {
    select = {
      type = "select",
      name = function() return T("Select Spell") end,
      order = 1,
      width = 1.8,
      values = function() return EntryValues(Entries()) end,
      get = function() return Selected() and SelectedIndex() or nil end,
      set = function(_, value)
        SelectedIndex(value)
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    },
    delete = {
      type = "execute",
      name = function() return T("Delete Spell") end,
      order = 2,
      width = 0.8,
      disabled = function() return Selected() == nil end,
      func = function()
        local entries = Entries()
        local index = SelectedIndex()
        if entries[index] then
          table.remove(entries, index)
          SelectedIndex(math.max(1, math.min(index, #entries)))
          NotifyAdvanced("advanced.display")
          AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
        end
      end,
    },
    selectedHeader = {
      type = "header",
      name = function() return T("Selected Spell") end,
      order = 10,
      hidden = function() return Selected() == nil end,
    },
    spellName = {
      type = "input",
      name = function() return T("Spell Name (Optional)") end,
      order = 11,
      width = 1.2,
      hidden = function() return Selected() == nil end,
      get = function() return Selected() and Selected().spellName or "" end,
      set = function(_, value)
        Selected().spellName = value or ""
        NotifyAdvanced("advanced.display.spellName", true)
      end,
    },
    spellID = {
      type = "input",
      name = function() return T("Spell ID (Required)") end,
      order = 12,
      width = 1,
      hidden = function() return Selected() == nil end,
      validate = ValidateSpellID,
      get = function() return Selected() and tostring(Selected().spellID) or "" end,
      set = function(_, value)
        Selected().spellID = tostring(math.floor(tonumber(value)))
        NotifyAdvanced("advanced.display.spellID", true)
      end,
    },
    dps = {
      type = "toggle",
      name = function() return T("Show DPS") end,
      order = 13,
      width = 0.75,
      hidden = function() return Selected() == nil end,
      get = function() return Selected() and Selected().dps == true end,
      set = function(_, value) SetSelectedRole("dps", value) end,
    },
    tank = {
      type = "toggle",
      name = function() return T("Show Tanks") end,
      order = 14,
      width = 0.75,
      hidden = function() return Selected() == nil end,
      get = function() return Selected() and Selected().tank == true end,
      set = function(_, value) SetSelectedRole("tank", value) end,
    },
    healer = {
      type = "toggle",
      name = function() return T("Show Healers") end,
      order = 15,
      width = 0.75,
      hidden = function() return Selected() == nil end,
      get = function() return Selected() and Selected().healer == true end,
      set = function(_, value) SetSelectedRole("healer", value) end,
    },
    addHeader = {
      type = "header",
      name = function() return T("Add Spell") end,
      order = 20,
    },
    newName = {
      type = "input",
      name = function() return T("Spell Name (Optional)") end,
      order = 21,
      width = 1.2,
      get = function() return newAdvanced.spellName end,
      set = function(_, value) newAdvanced.spellName = value or "" end,
    },
    newID = {
      type = "input",
      name = function() return T("Spell ID (Required)") end,
      order = 22,
      width = 1,
      validate = ValidateSpellID,
      get = function() return newAdvanced.spellID end,
      set = function(_, value) newAdvanced.spellID = value or "" end,
    },
    add = {
      type = "execute",
      name = function() return T("Add Spell") end,
      order = 23,
      width = 0.8,
      disabled = function() return not IsPositiveInteger(newAdvanced.spellID) end,
      func = function()
        SelectedIndex(
          AddEntry(Entries(), newAdvanced, true) or SelectedIndex()
        )
        newAdvanced.spellID, newAdvanced.spellName = "", ""
        NotifyAdvanced("advanced.display")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    },
  }
end

local function BuildSpellOrderOptions(rendererKey, expansionKey)
  local function Entries()
    local config = rendererKey
      and MerfinPlus:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
      or nil
    return config and config.advanced.order or {}
  end
  local function SelectedIndex(value)
    if not rendererKey then return 1 end
    if value then selectedOrderByRenderer[rendererKey] = value end
    return selectedOrderByRenderer[rendererKey] or 1
  end
  local function Selected()
    local entries = Entries()
    if #entries == 0 then
      return nil
    end
    local index = math.min(math.max(1, SelectedIndex()), #entries)
    SelectedIndex(index)
    return entries[index]
  end
  local function NotifyOrder(path, deferTrackerRefresh)
    RefreshTracker(
      ("renderers.%s.%s"):format(rendererKey, path),
      deferTrackerRefresh
    )
  end

  return {
    select = {
      type = "select",
      name = function() return T("Select Spell") end,
      order = 1,
      width = 1.8,
      values = function() return EntryValues(Entries()) end,
      get = function() return Selected() and SelectedIndex() or nil end,
      set = function(_, value)
        SelectedIndex(value)
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    },
    delete = {
      type = "execute",
      name = function() return T("Delete Spell") end,
      order = 2,
      width = 0.8,
      disabled = function() return Selected() == nil end,
      func = function()
        local entries = Entries()
        local index = SelectedIndex()
        if entries[index] then
          table.remove(entries, index)
          SelectedIndex(math.max(1, math.min(index, #entries)))
          NotifyOrder("advanced.order")
          AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
        end
      end,
    },
    selectedHeader = {
      type = "header",
      name = function() return T("Selected Spell") end,
      order = 10,
      hidden = function() return Selected() == nil end,
    },
    spellName = {
      type = "input",
      name = function() return T("Spell Name (Optional)") end,
      order = 11,
      width = 1.2,
      hidden = function() return Selected() == nil end,
      get = function() return Selected() and Selected().spellName or "" end,
      set = function(_, value)
        Selected().spellName = value or ""
        NotifyOrder("advanced.order.spellName", true)
      end,
    },
    spellID = {
      type = "input",
      name = function() return T("Spell ID (Required)") end,
      order = 12,
      width = 1,
      hidden = function() return Selected() == nil end,
      validate = ValidateSpellID,
      get = function() return Selected() and tostring(Selected().spellID) or "" end,
      set = function(_, value)
        Selected().spellID = tostring(math.floor(tonumber(value)))
        NotifyOrder("advanced.order.spellID", true)
      end,
    },
    index = {
      type = "range",
      name = function() return T("Index") end,
      order = 13,
      width = 1,
      min = 1,
      max = 100,
      step = 1,
      hidden = function() return Selected() == nil end,
      get = function() return Selected() and tonumber(Selected().index) or 1 end,
      set = function(_, value)
        Selected().index = math.floor(value)
        NotifyOrder("advanced.order.index", true)
      end,
    },
    addHeader = {
      type = "header",
      name = function() return T("Add Spell") end,
      order = 20,
    },
    newName = {
      type = "input",
      name = function() return T("Spell Name (Optional)") end,
      order = 21,
      width = 1.2,
      get = function() return newOrder.spellName end,
      set = function(_, value) newOrder.spellName = value or "" end,
    },
    newID = {
      type = "input",
      name = function() return T("Spell ID (Required)") end,
      order = 22,
      width = 1,
      validate = ValidateSpellID,
      get = function() return newOrder.spellID end,
      set = function(_, value) newOrder.spellID = value or "" end,
    },
    newIndex = {
      type = "range",
      name = function() return T("Index") end,
      order = 23,
      width = 0.8,
      min = 1,
      max = 100,
      step = 1,
      get = function() return newOrder.index end,
      set = function(_, value) newOrder.index = math.floor(value) end,
    },
    add = {
      type = "execute",
      name = function() return T("Add Spell") end,
      order = 24,
      width = 0.8,
      disabled = function() return not IsPositiveInteger(newOrder.spellID) end,
      func = function()
        SelectedIndex(
          AddEntry(Entries(), newOrder, false) or SelectedIndex()
        )
        newOrder.spellID, newOrder.spellName, newOrder.index = "", "", 1
        NotifyOrder("advanced.order")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    },
  }
end

local function BuildDisplayOptions(rendererKey, expansionKey)
  local function Config()
    return rendererKey
      and MerfinPlus:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
      or nil
  end
  local function NotifyDisplay(path)
    MerfinPlus:NotifyRaidCooldownTrackerChanged(("renderers.%s.%s"):format(rendererKey, path))
  end
  local function IsAuraBarRenderer()
    local renderer = rendererKey
      and MerfinPlus:GetRaidCooldownRendererDefinition(rendererKey, expansionKey)
      or nil
    return renderer and renderer.regionType == "aurabar" or false
  end
  return {
    note = {
      type = "description",
      name = function()
        return T("These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras.")
      end,
      order = 1,
      width = "full",
    },
    showMyself = {
      type = "toggle", name = function() return T("Show Yourself") end, order = 10, width = 1.2,
      get = function() return Config().display.showMyself == true end,
      set = function(_, value) Config().display.showMyself = value == true; NotifyDisplay("display.showMyself") end,
    },
    showReady = {
      type = "toggle", name = function() return T("Show When Ready") end, order = 11, width = 1.2,
      get = function() return Config().display.showReady == true end,
      set = function(_, value) Config().display.showReady = value == true; NotifyDisplay("display.showReady") end,
    },
    showDead = {
      type = "toggle", name = function() return T("Show When Dead") end, order = 12, width = 1.2,
      get = function() return Config().display.showDead == true end,
      set = function(_, value) Config().display.showDead = value == true; NotifyDisplay("display.showDead") end,
    },
    showOffline = {
      type = "toggle", name = function() return T("Show When Offline") end, order = 13, width = 1.2,
      get = function() return Config().display.showOffline == true end,
      set = function(_, value) Config().display.showOffline = value == true; NotifyDisplay("display.showOffline") end,
    },
    showBuff = {
      type = "toggle", name = function() return T("Show Buff Duration") end, order = 14, width = 1.2,
      get = function() return Config().display.showBuff == true end,
      set = function(_, value) Config().display.showBuff = value == true; NotifyDisplay("display.showBuff") end,
    },
    showReadySymbol = {
      type = "toggle", name = function() return T("Show Ready Indicator") end, order = 15, width = 1.2,
      hidden = function() return not IsAuraBarRenderer() end,
      get = function() return Config().display.showReadySymbol == true end,
      set = function(_, value) Config().display.showReadySymbol = value == true; NotifyDisplay("display.showReadySymbol") end,
    },
    colorDead = {
      type = "color",
      name = function() return T("Dead Color") end,
      order = 20,
      hasAlpha = true,
      hidden = function() return not IsAuraBarRenderer() end,
      get = function()
        local color = Config().display.colorDead or { 1, 0, 0, 1 }
        return color[1], color[2], color[3], color[4]
      end,
      set = function(_, red, green, blue, alpha)
        Config().display.colorDead = { red, green, blue, alpha }
        RefreshTracker(
          ("renderers.%s.display.colorDead"):format(rendererKey),
          true
        )
      end,
    },
    raidSubGroups = {
      type = "range",
      name = function() return T("Raid Subgroups") end,
      order = 21,
      min = 1,
      max = 8,
      step = 1,
      width = 1.4,
      get = function() return tonumber(Config().display.raidSubGroups) or 5 end,
      set = function(_, value)
        Config().display.raidSubGroups = math.floor(value)
        RefreshTracker(
          ("renderers.%s.display.raidSubGroups"):format(rendererKey),
          true
        )
      end,
    },
  }
end

function MerfinPlus:BuildRaidCooldownTrackerOptions()
  local expansionKey = self:GetRaidCooldownTrackerExpansionKey()
  local definition = expansionKey and self:GetRaidCooldownTrackerExpansion(expansionKey)
  if not definition then
    return {
      type = "group",
      name = function() return T("Raid Cooldowns") end,
      args = {
        unavailable = {
          type = "description",
          name = function() return T("No Raid Cooldown configuration is available for this expansion.") end,
          order = 1,
        },
      },
    }
  end

  self:EnsureRaidCooldownTrackerState(expansionKey)
  local expansionNameKey = definition.displayNameKey or "The Burning Crusade"
  local function ExpansionDescription(order)
    return {
      type = "description",
      name = function()
        return ("%s |cffffffff%s|r"):format(
          MerfinPlus:ColorizeUIThemeText(T("Detected Expansion") .. ":", "accent"),
          T(expansionNameKey)
        )
      end,
      order = order,
      fontSize = "medium",
      width = "full",
    }
  end
  local function GeneralRendererEnabled()
    local rendererKey = self:GetRaidCooldownSelectedGeneralRenderer(expansionKey)
    return rendererKey
      and self:IsRaidCooldownRendererEnabled(rendererKey, expansionKey)
      or false
  end

  return {
    type = "group",
    name = function() return T("Raid Cooldowns") end,
    childGroups = "tab",
    args = {
      general = {
        type = "group",
        name = function() return T("General Settings") end,
        order = 1,
        args = {
          expansion = ExpansionDescription(1),
          selectAura = {
            type = "select",
            name = function() return T("Select Your Aura") end,
            order = 2,
            width = 2,
            values = function()
              return self:GetRaidCooldownRendererValues(false, expansionKey)
            end,
            get = function()
              return self:GetRaidCooldownSelectedGeneralRenderer(expansionKey)
            end,
            set = function(_, rendererKey)
              if self:SetRaidCooldownSelectedGeneralRenderer(
                rendererKey,
                expansionKey
              ) then
                AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
              end
            end,
          },
          enabled = {
            type = "toggle",
            name = function() return T("Enable/Disable") end,
            order = 3,
            width = 1,
            get = function()
              local rendererKey = self:GetRaidCooldownSelectedGeneralRenderer(
                expansionKey
              )
              return rendererKey
                and self:IsRaidCooldownRendererEnabled(rendererKey, expansionKey)
                or false
            end,
            set = function(_, value)
              local rendererKey = self:GetRaidCooldownSelectedGeneralRenderer(
                expansionKey
              )
              if rendererKey
                and self:SetRaidCooldownRendererEnabled(
                  rendererKey,
                  value,
                  expansionKey
                )
              then
                Notify("enabled", true)
              end
            end,
          },
          clickMsg = {
            type = "toggle",
            name = function() return T("Send Message on Click") end,
            order = 10,
            width = "full",
            hidden = function() return not GeneralRendererEnabled() end,
            get = function()
              local rendererKey = self:GetRaidCooldownSelectedGeneralRenderer(expansionKey)
              local config = rendererKey
                and self:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
                or nil
              return config and config.features.clickMsg == true
            end,
            set = function(_, value)
              local rendererKey = self:GetRaidCooldownSelectedGeneralRenderer(expansionKey)
              local config = rendererKey
                and self:EnsureRaidCooldownRendererConfig(rendererKey, expansionKey)
                or nil
              if config then
                config.features.clickMsg = value == true
                self:NotifyRaidCooldownTrackerChanged(
                  ("renderers.%s.features.clickMsg"):format(rendererKey)
                )
              end
            end,
          },
          display = {
            type = "group",
            name = function() return T("Display Settings") end,
            inline = true,
            order = 20,
            hidden = function() return not GeneralRendererEnabled() end,
            args = BuildDisplayOptions(self:GetRaidCooldownSelectedGeneralRenderer(expansionKey), expansionKey),
          },
          advanced = {
            type = "group",
            name = function() return T("Advanced Spell Settings") end,
            inline = true,
            order = 30,
            hidden = function() return not GeneralRendererEnabled() end,
            args = BuildAdvancedDisplayOptions(self:GetRaidCooldownSelectedGeneralRenderer(expansionKey), expansionKey),
          },
          spellOrder = {
            type = "group",
            name = function() return T("Spell Order") end,
            inline = true,
            order = 40,
            hidden = function() return not GeneralRendererEnabled() end,
            args = BuildSpellOrderOptions(self:GetRaidCooldownSelectedGeneralRenderer(expansionKey), expansionKey),
          },
        },
      },
      activation = {
        type = "group",
        name = function() return T("Cooldown Activation") end,
        order = 2,
        args = {
          expansion = ExpansionDescription(1),
          selectAura = {
            type = "select",
            name = function() return T("Select Your Aura") end,
            order = 2,
            width = 2,
            values = function()
              return self:GetRaidCooldownRendererValues(true, expansionKey)
            end,
            get = function()
              return self:GetRaidCooldownSelectedActivationRenderer(expansionKey)
            end,
            set = function(_, rendererKey)
              if self:SetRaidCooldownSelectedActivationRenderer(
                rendererKey,
                expansionKey
              ) then
                AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
              end
            end,
          },
          content = {
            type = "execute",
            name = "",
            dialogControl = "MerfinPlusRaidCooldownActivation",
            func = function() end,
            width = "full",
            order = 10,
            hidden = function()
              return self:GetRaidCooldownSelectedActivationRenderer(
                expansionKey
              ) == nil
            end,
          },
        },
      },
    },
  }
end
