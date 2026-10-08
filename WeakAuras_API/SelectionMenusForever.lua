-- Shared out-of-combat selectors: one static secure action and one TSU menu.
Merfin = Merfin or {}
local API = { channels = {} }
Merfin.SelectionMenus = API

local spellRefreshEvents = {
    PLAYER_ENTERING_WORLD = true,
    LEARNED_SPELL_IN_SKILL_LINE = true,
    LEARNED_SPELL_IN_TAB = true,
    PLAYER_TALENT_UPDATE = true,
}

local function engine() return ForeverAuras or WeakAuras end
local function notify(event, ...) local wa = engine(); if wa then wa.ScanEvents(event, ...) end end
local function secret(value) return issecretvalue and issecretvalue(value) end
local function known(id)
    local fn = C_SpellBook and (C_SpellBook.IsSpellKnownOrOverridesKnown or C_SpellBook.IsSpellKnown)
    local result = fn and fn(id)
    return not secret(result) and result == true
end
local function count(id, charges)
    local value = C_Item.GetItemCount(id, false, charges == true)
    return not secret(value) and type(value) == "number" and value or 0
end
local function register(key, config)
    local channel = API.channels[key]
    if not channel then
        channel = { key = key, open = false, spells = {} }
        API.channels[key] = channel
    end
    if config then channel.config = config end
    assert(channel.config, "Selection menu has no configuration: " .. key)
    return channel
end

function API.RefreshSpells(key)
    local channel = register(key)
    if channel.config.kind ~= "spell" then return end
    local names, resolved, ranks = {}, {}, {}
    for _, id in ipairs(channel.config.ids) do
        local name = C_Spell.GetSpellName(id)
        if name and not secret(name) then names[name] = id end
        if known(id) then resolved[id] = id end
    end
    if C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookSkillLineInfo
        and C_SpellBook.GetSpellBookItemInfo then
        local bank = Enum.SpellBookSpellBank.Player
        for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local skill = C_SpellBook.GetSpellBookSkillLineInfo(line)
            if skill and skill.itemIndexOffset and skill.numSpellBookItems then
                for slot = skill.itemIndexOffset + 1, skill.itemIndexOffset + skill.numSpellBookItems do
                    local info = C_SpellBook.GetSpellBookItemInfo(slot, bank)
                    local spellId = info and info.spellID
                    if spellId and not secret(spellId) and not info.isPassive and not info.isOffSpec and known(spellId) then
                        local name = C_Spell.GetSpellName(spellId)
                        local baseId = name and not secret(name) and names[name]
                        if baseId then
                            local subtext = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellId)
                            local rank = subtext and not secret(subtext) and tonumber(subtext:match("%d+")) or 0
                            if not ranks[baseId] or rank >= ranks[baseId] then
                                resolved[baseId], ranks[baseId] = spellId, rank
                            end
                        end
                    end
                end
            end
        end
    end
    channel.spells = resolved
end

local function choice(channel, id)
    if not id then return end
    local allowed = false
    for _, candidate in ipairs(channel.config.ids) do if candidate == id then allowed = true; break end end
    if not allowed then return end
    if channel.config.kind == "item" then
        local group = channel.config.groups and channel.config.groups[id]
        local itemId, available = id, count(id, channel.config.countCharges)
        if group then
            itemId, available = nil, nil
            local playerLevel = UnitLevel("player") or 0
            for _, item in ipairs(group) do
                local amount = count(item.id, channel.config.countCharges)
                if amount > 0 then
                    local required = item.level or 0
                    if C_Item.GetItemInfo then
                        local _, _, _, _, requiredLevel = C_Item.GetItemInfo(item.id)
                        if not secret(requiredLevel) and type(requiredLevel) == "number" then required = requiredLevel end
                    end
                    if playerLevel >= required then itemId, available = item.id, amount; break end
                end
            end
            if not itemId then return end
        end
        return { id = id, itemId = itemId, count = available,
            name = C_Item.GetItemNameByID(itemId) or tostring(itemId),
            icon = C_Item.GetItemIconByID(itemId) or channel.config.fallbackIcon or 134400 }
    end
    local spellId = channel.spells[id]
    if not spellId then return end
    return { id = id, spellId = spellId, count = 1,
        name = C_Spell.GetSpellName(spellId) or tostring(spellId),
        icon = C_Spell.GetSpellTexture(spellId) or channel.config.fallbackIcon or 134400 }
end

function API.HasAvailable(key)
    local channel = register(key)
    for _, id in ipairs(channel.config.ids) do
        local info = choice(channel, id)
        if info and info.count > 0 then return true end
    end
    return false
end

function API.Select(key, id)
    if InCombatLockdown() then return false end
    local channel = register(key)
    local info = choice(channel, id)
    if not info or info.count <= 0 then return false end
    channel.selectedId = id
    if channel.main then channel.main.saved.selectedId = id end
    if key == "food" then
        Merfin.WellFed = Merfin.WellFed or {}
        Merfin.WellFed.selectedItemId = id
        if channel.main then channel.main.saved.selectedItemId = id end
    end
    notify("MERFIN_SELECTION_CHANGED", key, id)
    if key == "food" then notify("WA_WELL_FED_ACTIVE", id) end
    notify(channel.config.menuEvent, false)
    return true
end

function API.InitMain(aura_env, key, config)
    local channel = register(key, config)
    aura_env.selectionKey = key
    aura_env.last = 0
    aura_env.saved = aura_env.saved or {}
    channel.main = aura_env
    channel.selectedId = channel.selectedId or aura_env.saved.selectedId
    if key == "food" then
        Merfin.WellFed = Merfin.WellFed or {}
        channel.selectedId = channel.selectedId or Merfin.WellFed.selectedItemId or aura_env.saved.selectedItemId
        Merfin.WellFed.foodItemIds = config.ids
    end
    API.RefreshSpells(key)
    API.UpdateMain(aura_env)
end

function API.UpdateMain(aura_env)
    local channel = register(aura_env.selectionKey)
    local info = choice(channel, channel.selectedId)
    if (not info or info.count <= 0) and (channel.config.kind == "spell" or channel.config.autoSelect) then
        info = nil
        for _, id in ipairs(channel.config.ids) do
            local candidate = choice(channel, id)
            if candidate and candidate.count > 0 then
                info = candidate
                channel.selectedId = id
                aura_env.saved.selectedId = id
                break
            end
        end
    end
    aura_env.selectionIcon = info and info.icon or channel.config.fallbackIcon or 134400
    aura_env.foodIcon = aura_env.selectionIcon
    aura_env.selectedItemId = info and info.itemId
    aura_env.selectedSpellId = info and info.spellId
    local wa, region = engine(), aura_env.region
    if InCombatLockdown() or (wa and wa.IsOptionsOpen()) or not region or not region:IsVisible() then return end
    Merfin.SetCombatHiddenButtonTemplate(aura_env, nil, "macro", "", nil, channel.config.showCloseButton)
    local button = aura_env.button
    if not button then return end
    if not channel.config.showCloseButton and aura_env.sessionHideButton then aura_env.sessionHideButton:Hide() end
    local weaponSlot = channel.config.weaponSlot
    local macro = info and info.itemId and weaponSlot
        and ("/use item:" .. info.itemId .. "\n/use " .. weaponSlot) or nil
    -- No generic type fallback: right click must never use the selected action.
    button:SetAttribute("type", nil)
    button:SetAttribute("type1", info and (macro and "macro" or channel.config.kind) or nil)
    button:SetAttribute("item1", not macro and info and info.itemId and ("item:" .. info.itemId) or nil)
    button:SetAttribute("spell1", info and info.spellId and info.name or nil)
    button:SetAttribute("macrotext1", macro)
    button:SetAttribute("type2", nil)
    button:SetAttribute("item2", nil)
    button:SetAttribute("spell2", nil)
    button:SetScript("PostClick", function(_, mouseButton, down)
        if mouseButton == "RightButton" and not down and not InCombatLockdown() then
            notify(channel.config.menuEvent)
        end
    end)
end

function API.MainEvent(aura_env, event, key, id)
    local channel = register(aura_env.selectionKey)

    if event == "MERFIN_SELECTION_CHANGED" and key ~= channel.key then
        return
    end

    if event == "MERFIN_SELECTION_MENU_CHANGED" and key ~= channel.key then
        return
    end

    if event == "WA_WELL_FED_ACTIVE" and channel.key == "food" then
        local info = choice(channel, key)

        if info then
            channel.selectedId = key
            aura_env.saved.selectedId = key
            aura_env.saved.selectedItemId = key
        end
    end

    if channel.config.kind == "spell" and spellRefreshEvents[event] then
        API.RefreshSpells(channel.key)
    end

    API.UpdateMain(aura_env)
end

-- Reuse the existing arrow trigger index and its display condition.
function API.IndicatorTrigger(aura_env, states, event, key)
    local channel = register(aura_env.selectionKey)
    if event == "MERFIN_SELECTION_MENU_CHANGED" and key ~= channel.key then return end
    if event == channel.config.menuEvent then aura_env.last = GetTime() end
    if channel.open and not InCombatLockdown() then
        states:Replace("", { show = true, progressType = "static", value = 1, total = 1 })
    else
        states:Remove("")
    end
end

function API.HideMain(aura_env)
    local channel = register(aura_env.selectionKey)
    notify(channel.config.menuEvent, false)
end

function API.InitMenu(aura_env, key, config)
    register(key, config)
    aura_env.selectionKey = key
    aura_env.selectionButtonPool = aura_env.selectionButtonPool or {}
    API.RefreshSpells(key)
end

function API.ReleaseMenuButton(region)
    local button = region and region.merfinSelectionButton
    if not button then return end
    region.merfinSelectionButton = nil
    local pool = button.ownerPool
    button:Hide()
    button:EnableMouse(false)
    button:SetScript("OnClick", nil)
    button:SetScript("OnEnter", nil)
    button:SetScript("OnLeave", nil)
    if GameTooltip and GameTooltip:IsOwned(button) then GameTooltip:Hide() end
    button:ClearAllPoints()
    button:SetParent(UIParent)
    button.entryId, button.itemId, button.spellId, button.selectionKey, button.ownerPool = nil, nil, nil, nil, nil
    if pool then pool[#pool + 1] = button end
end

function API.RemoveMenuState(aura_env, states, cloneId)
    local wa = engine()
    API.ReleaseMenuButton(wa and wa.GetRegion(aura_env.id, cloneId))
    states:Remove(cloneId)
end

function API.MenuTrigger(aura_env, states, event, key)
    local channel = register(aura_env.selectionKey)
    local previous = channel.open

    if event == channel.config.menuEvent then
        if type(key) == "boolean" then
            channel.open = key
        else
            channel.open = not channel.open
        end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_ENTERING_WORLD" then
        channel.open = false
    elseif event == "MERFIN_SELECTION_CHANGED" and key ~= channel.key then
        return
    end

    local refreshSpells = spellRefreshEvents[event]
        or (event == channel.config.menuEvent and channel.open)

    if channel.config.kind == "spell" and refreshSpells then
        API.RefreshSpells(channel.key)
    end

    if InCombatLockdown() then channel.open = false end
    if previous ~= channel.open then notify("MERFIN_SELECTION_MENU_CHANGED", channel.key) end
    if not channel.open then
        for cloneId, state in pairs(states) do
            if state.show then API.RemoveMenuState(aura_env, states, cloneId) end
        end
        return
    end
    local present = {}
    for index, id in ipairs(channel.config.ids) do
        local info = choice(channel, id)
        if info and info.count > 0 then
            local cloneId = tostring(id)
            present[cloneId] = true
            states:Replace(cloneId, { show = true, progressType = "static", value = info.count,
                total = math.max(1, info.count), entryId = id, itemId = info.itemId, spellId = info.spellId,
                name = info.name, icon = info.icon, stacks = info.itemId and info.count or nil,
                index = index, selected = channel.selectedId == id })
            local wa = engine()
            local region = wa and wa.GetRegion(aura_env.id, cloneId)
            local button = region and region.merfinSelectionButton
            if button then button.itemId, button.spellId = info.itemId, info.spellId end
        end
    end
    for cloneId, state in pairs(states) do
        if state.show and not present[cloneId] then API.RemoveMenuState(aura_env, states, cloneId) end
    end
end

function API.ShowMenuButton(aura_env)
    local region, state = aura_env.region, aura_env.state
    if not region or not state or not state.entryId or InCombatLockdown() then return end
    local wa = engine()
    if wa and wa.IsOptionsOpen() then return end
    API.ReleaseMenuButton(region)
    local pool = aura_env.selectionButtonPool
    local button = table.remove(pool) or CreateFrame("Button", nil, UIParent)
    button.ownerPool, button.entryId, button.selectionKey = pool, state.entryId, aura_env.selectionKey
    button.itemId, button.spellId = state.itemId, state.spellId
    button:SetParent(region)
    button:ClearAllPoints()
    button:SetAllPoints(region)
    button:SetFrameLevel(region:GetFrameLevel() + 5)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function(self) API.Select(self.selectionKey, self.entryId) end)
    button:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.itemId then GameTooltip:SetItemByID(self.itemId)
        elseif self.spellId then GameTooltip:SetSpellByID(self.spellId) end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    region.merfinSelectionButton = button
    if not region.merfinSelectionHideHook then
        region.merfinSelectionHideHook = true
        region:HookScript("OnHide", function(self) API.ReleaseMenuButton(self) end)
    end
    button:Show()
end
