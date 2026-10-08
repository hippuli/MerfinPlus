local _, Addon = ...
local data = Addon:GetFoodAndDrinkDataForever()
local API = { version = 1, entries = {} }
local function secret(value)
    return issecretvalue and issecretvalue(value)
end
local function number(value)
    return not secret(value) and type(value) == "number"
end
local function yes(value)
    return not secret(value) and value == true
end
local function options()
    return ForeverAuras and ForeverAuras.IsOptionsOpen()
end
local function notify()
    if ForeverAuras and ForeverAuras.ScanEvents then
        ForeverAuras.ScanEvents("MERFIN_FOREVER_EATDRINK_UPDATE")
    end
end
local function put(states, state)
    local old = states[""]
    if old then
        local changed = false
        for key, value in pairs(state) do
            if old[key] ~= value then changed = true; break end
        end
        if not changed then
            for key in pairs(old) do
                if key ~= "changed" and state[key] == nil then changed = true; break end
            end
        end
        if not changed then return false end
    end
    state.changed = true
    states[""] = state
    return true
end
local function resource(kind)
    local current, maximum
    if kind == "food" then
        current, maximum = UnitHealth("player"), UnitHealthMax("player")
    else
        current, maximum = UnitPower("player", 0), UnitPowerMax("player", 0)
    end
    if not number(current) then current = nil end
    if not number(maximum) then maximum = nil end
    local percent
    if current and maximum and maximum > 0 then
        percent = current / maximum * 100
    elseif CurveConstants and CurveConstants.ScaleTo100 then
        if kind == "food" and UnitHealthPercent then
            percent = UnitHealthPercent("player", true, CurveConstants.ScaleTo100)
        elseif kind == "drink" and UnitPowerPercent then
            percent = UnitPowerPercent("player", 0, false, CurveConstants.ScaleTo100)
        end
        if not number(percent) then percent = nil end
    end
    return current, maximum, percent
end
function API:Inventory()
    local inventory = {}
    if not C_Container or not C_Container.GetContainerItemInfo then return inventory end
    for bag = 0, NUM_BAG_SLOTS or 4 do
        local slots = C_Container.GetContainerNumSlots(bag)
        if number(slots) then
            for slot = 1, slots do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if not secret(info) and type(info) == "table" and number(info.itemID) and data.items[info.itemID]
                    and number(info.stackCount) and info.stackCount > 0 then
                    inventory[info.itemID] = (inventory[info.itemID] or 0) + info.stackCount
                end
            end
        end
    end
    return inventory
end
function API:Select(kind, maximum)
    local playerLevel = UnitLevel("player")
    if not number(playerLevel) then return end
    local best, bestScore, bestConjured
    for _, id in ipairs(data[kind]) do
        if (self.inventory[id] or 0) > 0 then
            local record = data.items[id]
            local minimum = record.level
            if C_Item and C_Item.GetItemInfo then
                local _, _, _, _, liveMinimum = C_Item.GetItemInfo(id)
                if number(liveMinimum) then minimum = liveMinimum end
            end
            if number(minimum) and playerLevel >= minimum then
                local score = 0
                for _, restoration in ipairs(record[kind]) do
                    if restoration.percent then
                        if number(maximum) and maximum > 0 then
                            score = score + maximum * restoration.total / 100
                        end
                    else
                        score = score + restoration.total
                    end
                end
                if score > 0 and (not best or score > bestScore or (score == bestScore and record.conjured and not bestConjured)) then
                    best, bestScore, bestConjured = id, score, record.conjured
                end
            end
        end
    end
    return best
end
function API:Active(kind)
    if C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret() then return end
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return end
    for index = 1, 255 do
        local info = C_UnitAuras.GetAuraDataByIndex("player", index, "HELPFUL")
        if secret(info) then return end
        if not info then return end
        if not secret(info.spellId) and data.auras[kind][info.spellId] then
            return info
        end
    end
end
function API:Init(env, kind, passive)
    local entry = self.entries[env.id]
    if not entry then
        entry = { id = env.id, kind = kind, passive = passive }
        self.entries[env.id] = entry
    end
    entry.env, entry.kind, entry.passive = env, kind, passive
    entry.enabled = true
    env.eatDrinkEntry = entry
    self.inventory = self:Inventory()
end
function API:Deactivate(env)
    local entry = env.eatDrinkEntry
    if not entry then return end
    entry.enabled, entry.wanted, entry.hover = false, false, false
    self:Sync(entry)
end
function API:CreateButton(entry)
    if InCombatLockdown() or entry.passive then return end
    local button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
    button:Hide()
    button:EnableMouse(true)
    button:RegisterForClicks("AnyDown", "AnyUp")
    button:SetAttribute("useOnKeyDown", true)
    button:SetScript("OnEnter", function(self)
        entry.hover = true
        if entry.itemID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(entry.itemID)
            GameTooltip:Show()
        end
        notify()
    end)
    button:SetScript("OnLeave", function()
        entry.hover = false
        GameTooltip:Hide()
        notify()
    end)
    button:SetScript("PostClick", function(_, mouseButton, down)
        if mouseButton == "RightButton" and not down and entry.closeOnRight and not InCombatLockdown() then
            entry.dismissed = true
            notify()
        end
    end)
    entry.button = button
end
function API:Sync(entry)
    if InCombatLockdown() or entry.passive then return end
    local region = ForeverAuras and ForeverAuras.GetRegion(entry.id)
    local wanted = entry.enabled and entry.wanted and entry.itemID and region and yes(region:IsVisible()) and not options()
    if not wanted then
        if entry.button then
            if entry.visibility ~= "hide" then
                RegisterStateDriver(entry.button, "visibility", "hide")
                entry.visibility = "hide"
            end
            entry.button:Hide()
        end
        entry.hover = false
        return
    end
    if not entry.button then self:CreateButton(entry) end
    local button = entry.button
    if not button then return end
    local left, bottom, width, height = region:GetRect()
    local regionScale, parentScale = region:GetEffectiveScale(), UIParent:GetEffectiveScale()
    if not number(left) or not number(bottom) or not number(width) or not number(height)
        or not number(regionScale) or not number(parentScale) or parentScale <= 0 or width <= 0 or height <= 0 then
        if entry.visibility ~= "hide" then RegisterStateDriver(button, "visibility", "hide"); entry.visibility = "hide" end
        button:Hide()
        return
    end
    local scale = regionScale / parentScale
    local geometry = table.concat({left, bottom, width, height, scale, region:GetFrameLevel(), region:GetFrameStrata()}, ":")
    if entry.geometry ~= geometry then
        button:ClearAllPoints()
        button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left * scale, bottom * scale)
        button:SetSize(width * scale, height * scale)
        button:SetFrameStrata(region:GetFrameStrata())
        button:SetFrameLevel(region:GetFrameLevel() + 15)
        entry.geometry = geometry
    end
    local signature = tostring(entry.itemID) .. ":" .. tostring(entry.closeOnRight)
    if entry.action ~= signature then
        button:SetAttribute("type1", "item")
        button:SetAttribute("item1", "item:" .. entry.itemID)
        if entry.closeOnRight then
            button:SetAttribute("type2", nil)
            button:SetAttribute("item2", nil)
        else
            button:SetAttribute("type2", "item")
            button:SetAttribute("item2", "item:" .. entry.itemID)
        end
        entry.action = signature
    end
    if entry.visibility ~= "[combat][dead] hide; show" then
        RegisterStateDriver(button, "visibility", "[combat][dead] hide; show")
        entry.visibility = "[combat][dead] hide; show"
    end
    button:Show()
end
function API:Update(env, states, event)
    local entry = env.eatDrinkEntry
    if not entry then return false end
    entry.enabled = true
    local kind, config = entry.kind, env.config or {}
    local preview = event == "OPTIONS" or options()
    local combat = InCombatLockdown()
    if not preview and (combat or entry.passive) then
        entry.wanted = false
        return put(states, {show = false, active = false, hover = false, hasDuration = false})
    end
    local active = not preview and self:Active(kind)
    local current, maximum, percent = resource(kind)
    local threshold = config[kind == "food" and "healthThreshold" or "manaThreshold"]
    if not number(threshold) then threshold = 99 end
    threshold = math.max(1, math.min(100, threshold))
    local unknown = percent == nil
    local need = unknown or percent < threshold
    if not unknown and percent >= 100 then entry.dismissed = false end
    local powerType = UnitPowerType("player")
    if entry.dismissed and unknown then
        entry.dismissedUntil = entry.dismissedUntil or (GetTime() + 30)
        if GetTime() >= entry.dismissedUntil then entry.dismissed, entry.dismissedUntil = false, nil end
    elseif not entry.dismissed then entry.dismissedUntil = nil end
    if not combat then
        if not active or not entry.itemID then entry.itemID = self:Select(kind, maximum) end
        entry.closeOnRight = config[kind .. "RightClickClose"] == true
    end
    local id = entry.itemID
    local record = id and data.items[id]
    local icon = record and record.icon or (kind == "food" and 134062 or 132805)
    if id and C_Item and C_Item.GetItemIconByID then
        local liveIcon = C_Item.GetItemIconByID(id)
        if number(liveIcon) then icon = liveIcon end
    end
    local count = id and self.inventory[id] or 0
    local allowed = not yes(UnitIsDeadOrGhost("player")) and not yes(UnitOnTaxi("player"))
    if not config[kind .. "ShowMounted"] and yes(IsMounted()) then allowed = false end
    if config.HideWhileResting and yes(IsResting()) then allowed = false end
    if kind == "drink" then
        if maximum == 0 then allowed = false end
        if not config.drinkShowCatOrBear and number(powerType) and powerType ~= 0 then allowed = false end
    end
    local shown
    if entry.passive then shown = combat and active ~= nil
    else shown = not combat and allowed and not entry.dismissed and ((need and count > 0) or active ~= nil) end
    local state = {show = preview or shown, progressType = "static", value = 1, total = 1, autoHide = false,
        icon = icon, stacks = preview and 0 or count, itemID = id, active = active ~= nil,
        hover = not preview and entry.hover == true, hasDuration = false, name = "", resourceUnknown = unknown}
    if active and number(active.duration) and number(active.expirationTime) and active.duration > 0 and active.expirationTime > GetTime() then
        state.progressType, state.duration, state.expirationTime = "timed", active.duration, active.expirationTime
        state.value, state.total, state.hasDuration = nil, nil, true
    end
    if preview then
        state.active, state.hover, state.hasDuration = false, false, true
        state.progressType, state.duration, state.expirationTime = "timed", 30, GetTime() + 15
        state.value, state.total = nil, nil
    end
    entry.wanted = state.show and not preview and not entry.passive
    return put(states, state)
end
function Addon:GetEatDrinkForever()
    return API
end
local frame = CreateFrame("Frame")
for _, event in ipairs({"BAG_UPDATE_DELAYED", "PLAYER_ENTERING_WORLD", "PLAYER_LEVEL_UP", "GET_ITEM_INFO_RECEIVED", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "UNIT_AURA", "UNIT_HEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXHEALTH", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "PLAYER_MOUNT_DISPLAY_CHANGED", "UPDATE_SHAPESHIFT_FORM", "PLAYER_UPDATE_RESTING", "ADDON_RESTRICTION_STATE_CHANGED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED"}) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event, unit)
    if event:sub(1, 5) == "UNIT_" and (secret(unit) or unit ~= "player") then return end
    if event == "BAG_UPDATE_DELAYED" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then API.inventory = API:Inventory() end
    if next(API.entries) then notify() end
end)
local elapsedTotal = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTotal = elapsedTotal + elapsed
    if elapsedTotal < 0.2 then return end
    elapsedTotal = 0
    if next(API.entries) then
        if not InCombatLockdown() then notify() end
        for _, entry in pairs(API.entries) do API:Sync(entry) end
    end
end)
