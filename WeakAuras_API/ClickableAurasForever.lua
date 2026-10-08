local _, Addon = ...
local API = { version = 5, entries = {}, menus = {}, serial = 0, fontSerial = 0 }
local function secret(v)
    return issecretvalue and issecretvalue(v)
end
local function number(v)
    return not secret(v) and type(v) == "number"
end
local function text(v)
    return not secret(v) and type(v) == "string" and v or ""
end
local function yes(v)
    return not secret(v) and v == true
end
local function combat()
    return InCombatLockdown()
end
local function options()
    return ForeverAuras and ForeverAuras.IsOptionsOpen()
end
local function notify()
    if ForeverAuras and ForeverAuras.ScanEvents then
        ForeverAuras.ScanEvents("MERFIN_FOREVER_CLICKABLE_UPDATE")
    end
end
local function count(id)
    if not C_Item or not C_Item.GetItemCount then return 0 end
    local n = C_Item.GetItemCount(id, false, true, false, false)
    return number(n) and n or 0
end
local function spell(id)
    if not C_Spell or not C_Spell.GetSpellInfo then return end
    local info = C_Spell.GetSpellInfo(id)
    if not secret(info) and info then return info end
end
local function known(ids)
    if not C_SpellBook or not C_SpellBook.IsSpellKnown then return end
    for _, id in ipairs(ids or {}) do
        if yes(C_SpellBook.IsSpellKnown(id)) then return id end
    end
end
local function itemIcon(id, fallback)
    local icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(id)
    return number(icon) and icon or fallback
end
local function livePet()
    return yes(UnitExists("pet")) and not yes(UnitIsDeadOrGhost("pet"))
end
local function aura(ids, unit)
    if C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret() then return end
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return end
    for index = 1, 255 do
        local info = C_UnitAuras.GetAuraDataByIndex(unit or "player", index, "HELPFUL")
        if secret(info) then return end
        if not info then return false end
        if secret(info.spellId) then return end
        for _, id in ipairs(ids or {}) do
            if info.spellId == id then return true, info end
        end
    end
end
local function casting(ids)
    for pass = 1, 2 do
        local name, display, icon, startMS, endMS, trade, extra, extra2, castID
        if pass == 1 then
            name, display, icon, startMS, endMS, trade, extra, extra2, castID = UnitCastingInfo("player")
        else
            name, display, icon, startMS, endMS, trade, extra, castID = UnitChannelInfo("player")
        end
        if not secret(castID) and number(startMS) and number(endMS) then
            for _, id in ipairs(ids or {}) do
                if castID == id then return true, (endMS - startMS) / 1000, endMS / 1000, icon end
            end
        end
    end
end
local function timed(state, duration, expiration)
    if number(duration) and number(expiration) and duration > 0 and expiration > GetTime() then
        state.progressType, state.duration, state.expirationTime = "timed", duration, expiration
        state.value, state.total = nil, nil
        state.hasDuration = true
    end
end
local function put(states, key, new)
    local old = states[key]
    if old then
        local changed = false
        for k, v in pairs(new) do if old[k] ~= v then changed = true; break end end
        if not changed then
            for k in pairs(old) do
                if k ~= "changed" and new[k] == nil then changed = true; break end
            end
        end
        if not changed then return false end
    end
    new.changed = true
    states[key] = new
    return true
end
local function blank(icon)
    return { show = true, progressType = "static", value = 1, total = 1, autoHide = false,
        icon = icon, hover = false, pressed = false, active = false, usable = true, empty = false,
        stacks = 0, countText = "", name = "", hasDuration = false, duration = nil, expirationTime = nil }
end
local function skill(id)
    if C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID then
        local info = C_SkillInfo.GetSkillLineInfoByID(id)
        if not secret(info) then return info end
    end
end
local function fishingRod()
    local id = GetInventoryItemID("player", 16)
    if not number(id) or not C_Item or not C_Item.GetItemInfoInstant then return end
    local _, _, _, _, _, classID, subClassID = C_Item.GetItemInfoInstant(id)
    if number(classID) and number(subClassID) and classID == 2 and subClassID == 20 then return id end
end
local function enchant()
    if not C_Item or not C_Item.GetWeaponEnchantInfo or not Enum or not Enum.WeaponSlot then return end
    local enchants = C_Item.GetWeaponEnchantInfo(Enum.WeaponSlot.MainHand)
    if secret(enchants) or type(enchants) ~= "table" then return end
    for _, info in pairs(enchants) do
        if not secret(info) and yes(info.hasEnchant) and number(info.enchantID) and number(info.timeLeft) then
            if info.enchantID >= 263 and info.enchantID <= 266 then return info.enchantID, info.timeLeft / 1000 end
        end
    end
end
function API:GetEntry(env, key, def)
    local token = env.foreverUid .. ":" .. key
    local entry = self.entries[token]
    if not entry then
        entry = { uid = env.foreverUid, id = env.id, cloneID = key, def = def, env = env }
        self.entries[token] = entry
    end
    entry.env, entry.def = env, def
    return entry
end
function API:Init(env, def)
    env.foreverUid = def.uid
    env.foreverDefinition = def
    env.foreverSlots = env.foreverSlots or {}
    self:GetEntry(env, "", def)
end
function API:SetHover(entry, value)
    entry.hover = value
    notify()
end
function API:CreateButton(entry)
    if combat() then return end
    self.serial = self.serial + 1
    local menu = entry.def.kind == "menu"
    local button = CreateFrame("Button", nil, UIParent, not menu and "SecureActionButtonTemplate" or nil)
    button:Hide()
    button:EnableMouse(true)
    if menu then button:RegisterForClicks("LeftButtonUp")
    else button:RegisterForClicks("AnyUp", "AnyDown") end
    button:SetScript("OnEnter", function(self)
        API:SetHover(entry, true)
        if entry.itemID or entry.spellID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if entry.itemID then GameTooltip:SetItemByID(entry.itemID)
            elseif entry.spellID then GameTooltip:SetSpellByID(entry.spellID) end
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        API:SetHover(entry, false)
        GameTooltip:Hide()
    end)
    if menu then
        button:SetScript("OnClick", function(_, mouseButton, down)
            if mouseButton ~= "LeftButton" or down or combat() then return end
            local key = entry.def.menu
            API.menus[key] = not API.menus[key]
            notify()
        end)
    end
    entry.button = button
end
function API:Sync(entry)
    if combat() then return end
    local def = entry.def
    if def.kind == "food" and not entry.itemID then return end
    local region = ForeverAuras and ForeverAuras.GetRegion(entry.id, entry.cloneID)
    if entry.cooldown and def.cooldownTextIndex then
        if entry.cooldownPreview ~= (options() == true) then self:Cooldown(entry)
        else self:StyleCooldown(entry, region) end
    end
    local wanted = entry.wanted and region and yes(region:IsVisible()) and (def.kind == "menu" or not options())
    if not wanted then
        if entry.button then
            if def.outOfCombat and entry.visibility ~= "hide" then
                RegisterStateDriver(entry.button, "visibility", "hide")
                entry.visibility = "hide"
            end
            entry.button:Hide()
        end
        return
    end
    if not entry.button then self:CreateButton(entry) end
    local button = entry.button
    if not button then return end
    local left, bottom, width, height = region:GetRect()
    local regionScale, parentScale = region:GetEffectiveScale(), UIParent:GetEffectiveScale()
    if not number(regionScale) or not number(parentScale) or parentScale <= 0 then button:Hide(); return end
    local scale = regionScale / parentScale
    if not number(left) or not number(bottom) or not number(width) or not number(height) or width <= 0 or height <= 0 then
        button:Hide()
        return
    end
    local geometry = table.concat({left, bottom, width, height, scale, region:GetFrameLevel(), region:GetFrameStrata()}, ":")
    if geometry ~= entry.geometry then
        button:ClearAllPoints()
        button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left * scale, bottom * scale)
        button:SetSize(width * scale, height * scale)
        button:SetFrameStrata(region:GetFrameStrata())
        button:SetFrameLevel(region:GetFrameLevel() + 15)
        entry.geometry = geometry
    end
    local actionType, action, unit
    if def.kind == "spell" or def.kind == "fishing" then
        local info = spell(entry.spellID)
        local name = info and text(info.name)
        if name and name ~= "" then
            actionType, action = "macro", "/cast " .. (def.noToggle and "!" or "") .. name
        end
    elseif def.kind == "call" then
        local call, dismiss = spell(883), spell(2641)
        if call and dismiss and text(call.name) ~= "" and text(dismiss.name) ~= "" then
            actionType, action = "macro", "/cast [pet,nodead] " .. dismiss.name .. "; [nopet] " .. call.name
        end
    elseif def.kind == "food" then
        local feed = spell(6991)
        if feed and text(feed.name) ~= "" then
            actionType, action = "macro", "/stopmacro [combat][nopet][@pet,dead]\n/cast " .. feed.name .. "\n/use item:" .. entry.itemID
        end
    elseif def.kind == "lure" then
        actionType, action = "macro", "/stopmacro [combat]\n/use item:" .. entry.itemID .. "\n/use 16"
    elseif def.kind == "petitem" then
        actionType, action = "macro", "/stopmacro [combat][nopet][@pet,dead]\n/use [@pet] item:" .. entry.itemID
    elseif entry.itemID then
        actionType, action, unit = "item", "item:" .. entry.itemID, def.unit
    end
    if def.kind ~= "menu" then
        local signature = (actionType or "") .. ":" .. (action or "") .. ":" .. (unit or "")
        if signature ~= entry.action then
            button:SetAttribute("type", nil)
            button:SetAttribute("item", nil)
            button:SetAttribute("spell", nil)
            button:SetAttribute("macrotext", nil)
            button:SetAttribute("unit", unit)
            button:SetAttribute("useOnKeyDown", true)
            if actionType then
                button:SetAttribute(actionType == "macro" and "macrotext" or actionType, action)
                button:SetAttribute("type", actionType)
            end
            entry.action = signature
        end
        if not actionType then button:Hide(); return end
    end
    if def.outOfCombat and entry.visibility ~= "[combat] hide; show" then
        RegisterStateDriver(button, "visibility", "[combat] hide; show")
        entry.visibility = "[combat] hide; show"
    end
    button:Show()
    if entry.itemID and not entry.cooldown then self:Cooldown(entry) end
end
function API:StyleCooldown(entry, region)
    if combat() or not entry.cooldown or not region then return end
    local index = entry.def.cooldownTextIndex
    local sub = index and region.subRegions and region.subRegions[index]
    local data = ForeverAuras.GetData and ForeverAuras.GetData(entry.id)
    local config = data and data.subRegions and data.subRegions[index]
    if not sub or not sub.text or not config then return end
    local font, size, flags = sub.text:GetFont()
    if secret(font) or type(font) ~= "string" or not number(size) then return end
    flags = text(flags)
    local r, g, b, a = sub.text:GetTextColor()
    if not number(r) or not number(g) or not number(b) or not number(a) then return end
    local shown = yes(sub:IsShown()) and not options()
    local shadow = config.text_shadowColor or {0, 0, 0, 1}
    local x, y = sub.text_anchorXOffset or 0, sub.text_anchorYOffset or 0
    local signature = table.concat({font, size, flags, r, g, b, a,
        shadow[1], shadow[2], shadow[3], shadow[4], config.text_shadowXOffset or 0,
        config.text_shadowYOffset or 0, x, y, config.anchor_point or "CENTER",
        config.text_selfPoint or "AUTO", tostring(shown), tostring(data.cooldownSwipe),
        tostring(data.cooldownEdge), tostring(options())}, ":")
    if entry.countdownStyle == signature and entry.countdownSub == sub then return end
    local cooldown = entry.cooldown
    if cooldown.CanBeAccessedInContext and not yes(cooldown:CanBeAccessedInContext()) then return end
    local countdown = cooldown:GetCountdownFontString()
    if not countdown or (countdown.CanBeAccessedInContext and not yes(countdown:CanBeAccessedInContext())) then return end
    if not entry.countdownFont then
        self.fontSerial = self.fontSerial + 1
        entry.countdownFontName = "MerfinForeverItemCountdown" .. self.fontSerial
        entry.countdownFont = CreateFont(entry.countdownFontName)
    end
    local object = entry.countdownFont
    object:SetFont(font, size, flags)
    object:SetTextColor(r, g, b, a)
    object:SetShadowColor(unpack(shadow))
    object:SetShadowOffset(config.text_shadowXOffset or 0, config.text_shadowYOffset or 0)
    cooldown:SetCountdownFont(entry.countdownFontName)
    countdown:SetFont(font, size, flags)
    countdown:SetTextHeight(size)
    countdown:SetTextColor(r, g, b, a)
    countdown:SetJustifyH(config.text_justify or "CENTER")
    countdown:ClearAllPoints()
    if sub.AnchorNativeText then sub:AnchorNativeText(countdown)
    else countdown:SetPoint("CENTER", region, "CENTER", x, y) end
    cooldown:SetHideCountdownNumbers(not shown)
    cooldown:SetDrawSwipe(not options() and data.cooldownSwipe ~= false)
    cooldown:SetDrawEdge(not options() and data.cooldownEdge == true)
    entry.countdownStyle, entry.countdownSub = signature, sub
end
function API:Cooldown(entry)
    if not entry.itemID or entry.def.kind == "lure" or not C_Item or not C_Item.GetItemCooldown then return end
    local region = ForeverAuras and ForeverAuras.GetRegion(entry.id, entry.cloneID)
    if not region or not region.icon then return end
    if entry.cooldownRegion ~= region then
        if entry.cooldown then entry.cooldown:Hide() end
        entry.cooldown = CreateFrame("Cooldown", nil, region, "CooldownFrameTemplate")
        entry.cooldown:SetAllPoints(region.icon)
        entry.cooldown:SetDrawEdge(false)
        entry.cooldown:SetHideCountdownNumbers(entry.def.cooldownTextIndex ~= nil)
        entry.cooldown.noCooldownCount = true
        entry.cooldown:SetDrawBling(false)
        entry.cooldownRegion = region
        entry.countdownStyle = nil
    end
    if entry.def.cooldownTextIndex then
        self:StyleCooldown(entry, region)
        entry.cooldownPreview = options() == true
        if options() and not combat() then entry.cooldown:SetCooldown(0, 0); return end
    end
    local start, duration = C_Item.GetItemCooldown(entry.itemID)
    if (secret(start) or number(start)) and (secret(duration) or number(duration)) then
        entry.cooldown:SetCooldown(start, duration)
    end
end
function API:One(env, def, key)
    local entry = self:GetEntry(env, key, def)
    local state = blank(def.icon)
    state.hover = entry.hover == true
    entry.itemID = def.itemID
    if def.kind == "spell" then
        if not combat() then entry.spellID = known(def.spells) end
        local info = entry.spellID and spell(entry.spellID)
        state.show = entry.spellID ~= nil
        if info then state.icon, state.name = info.iconID, text(info.name) end
        local present, buffInfo = aura(def.spells, def.buffUnit or "player")
        state.active = present == true
        if buffInfo then timed(state, buffInfo.duration, buffInfo.expirationTime) end
        if def.pet then
            if def.revive then state.usable = not livePet() else state.usable = livePet() end
        end
        local active, duration, expiration = casting(def.spells)
        state.casting = active == true
        if active then timed(state, duration, expiration) end
    elseif def.kind == "call" then
        if not combat() then entry.spellID = known({883}) end
        state.show = entry.spellID ~= nil
        local exists = yes(UnitExists("pet"))
        state.petDead = yes(UnitIsDeadOrGhost("pet"))
        state.isActive = exists and not state.petDead
        state.petName = exists and text(UnitName("pet")) or (spell(883) and text(spell(883).name) or "")
        state.buffName = ""
        if exists and GetPetActionInfo then
            for index = 1, 10 do
                local name, _, token, active = GetPetActionInfo(index)
                if yes(active) and not secret(name) and not secret(token) and token and type(name) == "string" and name:match("^PET_MODE_") then
                    state.buffName = text(_G[name])
                end
            end
        end
        local hp, maxHP = UnitHealth("pet"), UnitHealthMax("pet")
        if exists and number(hp) and number(maxHP) and maxHP > 0 then
            state.value, state.total = hp, maxHP
            state.healthPercent = hp / maxHP * 100
            state.hpGreen = state.healthPercent >= 75
            state.hpYellow = state.healthPercent >= 50 and state.healthPercent < 75
            state.hpOrange = state.healthPercent >= 25 and state.healthPercent < 50
            state.hpRed = state.healthPercent < 25
        end
        local active, duration, expiration = casting({2641})
        state.dismissing = active == true
        if active then timed(state, duration, expiration) end
    elseif def.kind == "happiness" then
        local happiness, damage
        if C_PetInfo and C_PetInfo.GetPetHappiness then happiness, damage = C_PetInfo.GetPetHappiness() end
        state.icon = "Interface\\RaidFrame\\ReadyCheck-Waiting"
        state.show = livePet() and number(happiness) and happiness >= 1 and happiness <= 3 and happiness == math.floor(happiness)
        if state.show then
            local icons = {"Interface\\RaidFrame\\ReadyCheck-NotReady", "Interface\\RaidFrame\\ReadyCheck-Waiting", "Interface\\RaidFrame\\ReadyCheck-Ready"}
            state.icon = icons[happiness]
            state.value, state.total, state.happiness = happiness, 3, happiness
            state.name = text(_G["PET_HAPPINESS" .. happiness])
            if number(damage) then state.name = state.name .. " (" .. damage .. "%)" end
        end
    elseif def.kind == "buff" then
        local present, info = aura(def.spells, "pet")
        state.show = livePet() and present ~= nil
        state.active = present == true
        if info then timed(state, info.duration, info.expirationTime) end
    elseif def.kind == "menu" then
        state.open = self.menus[def.menu] == true
        state.usable = livePet() and not combat()
        state.show = known({6991}) ~= nil
        if def.buffSpells then
            local present, info = aura(def.buffSpells, "pet")
            state.active = present == true
            if info then timed(state, info.duration, info.expirationTime) end
        end
    elseif def.kind == "item" or def.kind == "petitem" or def.kind == "food" or def.kind == "lure" then
        local n = count(def.itemID)
        state.icon, state.stacks, state.countText = itemIcon(def.itemID, def.icon), n, tostring(n)
        state.index = def.index
        if def.consumableBar then
            state.preview, state.cooldownText, state.onCooldown = false, "", false
            if C_Item and C_Item.GetItemCooldown then
                local start, duration = C_Item.GetItemCooldown(def.itemID)
                state.onCooldown = number(start) and number(duration) and start > 0 and duration > 0 and start + duration > GetTime()
            end
        end
        if not combat() then
            local available = n > 0
            if def.menu then available = available and self.menus[def.menu] == true end
            if def.kind == "lure" then available = fishingRod() ~= nil end
            local requirementsMet = true
            if def.requiredSkill then
                local info = skill(def.requiredSkill)
                requirementsMet = info ~= nil and number(info.rank) and info.rank >= (def.requiredSkillRank or 1)
            end
            if def.requiredLevel then
                local level = UnitLevel("player")
                requirementsMet = requirementsMet and number(level) and level >= def.requiredLevel
            end
            entry.requirementsMet = requirementsMet == true
            if def.kind ~= "lure" then available = available and requirementsMet end
            if def.kind == "food" then
                entry.foodUsable = livePet() and C_PetInfo and C_PetInfo.CanPetEatItem and yes(C_PetInfo.CanPetEatItem(def.itemID)) or false
                available = available and entry.foodUsable
            end
            entry.available = available == true
        end
        state.show = entry.available == true and not (def.outOfCombat and combat())
        state.empty = n <= 0
        state.hasItem = n > 0
        if def.kind == "food" then
            state.usable = not combat() and entry.foodUsable == true
        elseif def.kind == "petitem" then
            state.usable = livePet()
        elseif def.kind == "lure" then
            state.usable = n > 0 and entry.requirementsMet == true
        end
        if def.buffSpells then state.active = aura(def.buffSpells, def.unit or "player") == true end
        if def.kind == "lure" then
            local enchantID, remaining = enchant()
            state.applied = enchantID == def.enchantID
            state.needsLure = enchantID == nil and state.usable
            if state.applied then timed(state, remaining, GetTime() + remaining) end
        end
    elseif def.kind == "fishing" then
        if not combat() then entry.spellID = known({18248,7732,7731,7620}) end
        local rod = fishingRod()
        state.show = rod ~= nil and not combat() and entry.spellID ~= nil
        state.icon = rod and itemIcon(rod, def.icon) or def.icon
        local info = skill(356)
        state.mainText = ""
        if info and number(info.rank) and number(info.maxRank) then
            local bonus = number(info.tempPoints) and info.tempPoints or 0
            bonus = bonus + (number(info.modifier) and info.modifier or 0)
            state.mainText = info.rank .. (bonus ~= 0 and string.format(" |cff00ff00%+d|r", bonus) or "") .. " / " .. info.maxRank
        end
        local active, duration, expiration, icon = casting({7620,7731,7732,18248})
        state.casting = active == true
        if active then
            env.foreverFishingUntil = expiration + 5
            timed(state, duration, expiration)
            if not secret(icon) and icon then state.icon = icon end
        end
        state.lootActive = env.foreverLootUntil and env.foreverLootUntil > GetTime() or false
        if state.lootActive then state.mainText, state.icon = env.foreverLootText, env.foreverLootIcon end
    end
    if options() and not combat() then
        if def.consumableBar then
            state.show, state.empty, state.preview, state.cooldownText = true, false, true, "4"
        elseif def.kind == "food" and def.itemID then
            state.show, state.empty = true, false
        elseif def.kind == "food" or def.kind == "petitem" then
            state.empty = not state.show or state.empty
            if state.empty then state.countText = "" end
            state.show = true
        else
            state.show, state.empty = true, false
        end
    end
    entry.wanted = state.show and not state.empty
    if def.kind == "buff" or def.kind == "happiness" then entry.wanted = false end
    return state, entry
end
function API:Update(env, states, event, ...)
    local def = env.foreverDefinition
    if not def then return false end
    if event == "CHAT_MSG_LOOT" and def.kind == "fishing" then
        local message = ...
        if not secret(message) and type(message) == "string" and GetTime() < (env.foreverFishingUntil or 0) then
            local own = false
            for _, formatText in ipairs({LOOT_ITEM_SELF or "", LOOT_ITEM_SELF_MULTIPLE or "", LOOT_ITEM_PUSHED_SELF or "", LOOT_ITEM_PUSHED_SELF_MULTIPLE or ""}) do
                local prefix = formatText:match("^(.-)%%")
                if prefix and prefix ~= "" and message:sub(1, #prefix) == prefix then own = true end
            end
            local itemID = own and tonumber(message:match("item:(%d+)"))
            if itemID then
                env.foreverLootText = message:match("(|Hitem:%d+.-|h%[.-%]|h)") or ""
                local amount = message:match("x(%d+)")
                if amount then env.foreverLootText = env.foreverLootText .. " x" .. amount end
                env.foreverLootIcon = itemIcon(itemID, def.icon)
                env.foreverLootUntil = GetTime() + 3
                C_Timer.After(3.05, notify)
            end
        end
    end
    if def.kind == "food" and not def.itemID then
        local visible, changed = {}, false
        if not combat() and self.menus.food and C_Container then
            local found = {}
            for bag = 0, NUM_BAG_SLOTS or 4 do
                for slot = 1, C_Container.GetContainerNumSlots(bag) do
                    local id = C_Container.GetContainerItemID(bag, slot)
                    if number(id) and not found[id] then
                        local food = def.foodItems and def.foodItems[id]
                        if food or (livePet() and C_PetInfo and C_PetInfo.CanPetEatItem and yes(C_PetInfo.CanPetEatItem(id))) then
                            found[id] = true
                        end
                    end
                end
            end
            local ordered = {}
            for id in pairs(found) do ordered[#ordered + 1] = id end
            table.sort(ordered)
            for index, id in ipairs(ordered) do
                local key = tostring(id)
                local food = {kind = "food", itemID = id, menu = "food", outOfCombat = true, icon = def.icon}
                local state = self:One(env, food, key)
                state.index = index
                visible[key] = true
                changed = put(states, key, state) or changed
            end
        end
        if options() and not combat() and not next(visible) then
            local state = blank(def.icon)
            state.empty = true
            visible[""] = true
            changed = put(states, "", state) or changed
        end
        for key, old in pairs(states) do
            if not visible[key] and old.show then old.show, old.changed, changed = false, true, true end
            local entry = self.entries[env.foreverUid .. ":" .. key]
            if entry and not visible[key] then entry.wanted = false end
        end
        return changed
    end
    local state = self:One(env, def, "")
    return put(states, "", state)
end
function API:Deactivate(env)
    for _, entry in pairs(self.entries) do
        if entry.uid == env.foreverUid and (not env.cloneId or entry.cloneID == env.cloneId) then
            entry.wanted = false
            if not combat() and entry.button then entry.button:Hide() end
        end
    end
end
function Addon:GetClickableAurasForever()
    return API
end
local frame = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "BAG_UPDATE_DELAYED", "SPELL_UPDATE_COOLDOWN", "BAG_UPDATE_COOLDOWN", "SPELLS_CHANGED", "PLAYER_EQUIPMENT_CHANGED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED", "PLAYER_ENTERING_WORLD"}) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        API.menus.food, API.menus.scroll, API.menus.juju = false, false, false
    end
    notify()
    C_Timer.After(0, function()
        for _, entry in pairs(API.entries) do
            API:Sync(entry)
            API:Cooldown(entry)
        end
    end)
end)
local elapsedTotal = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTotal = elapsedTotal + elapsed
    if elapsedTotal < 0.1 then return end
    elapsedTotal = 0
    if not combat() then
        for _, entry in pairs(API.entries) do API:Sync(entry) end
    end
end)
