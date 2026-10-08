local _, MerfinPlus = ...
local build = select(4, GetBuildInfo())
if not build or build < 16000 or build >= 20000 then return end
local catalog = MerfinPlus.ForeverAuctionCatalog
if not catalog then return end
local AH = {nodes = {}, categories = {}, config = {}, expanded = {}, offsets = {}, panels = {}, generation = 0}
local ITEM_SIZE, PITCH, PANEL_GAP = 34, 35, 8
local CATEGORY_SIZE, CATEGORY_PITCH = 39, 40
for _, category in ipairs(catalog.categories) do AH.categories[category.key] = category end
local function public(value, kind)
    return (not issecretvalue or not issecretvalue(value)) and type(value) == kind
end
local function visible(frame)
    return frame and type(frame.IsVisible) == "function" and frame:IsVisible()
end
local function loaded(name)
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(name)
end
local function frameObject(frame)
    return frame and type(frame.IsObjectType) == "function" and frame:IsObjectType("Frame")
end
local function scan(event, ...)
    local wa = _G.ForeverAuras
    if wa and type(wa.ScanEvents) == "function" then wa.ScanEvents(event, ...) end
end
local function combat() return InCombatLockdown and InCombatLockdown() end
local function tsmFrame()
    if not loaded("TradeSkillMaster") or not TSM_API or type(TSM_API.IsUIVisible) ~= "function" or not TSM_API.IsUIVisible("AUCTION") then return end
    if visible(AH.tsmFrame) then return AH.tsmFrame end
    if not UIParent or not UIParent.GetChildren then return end
    for _, frame in ipairs({UIParent:GetChildren()}) do
        local name = frame.GetName and frame:GetName()
        if visible(frame) and public(name, "string") and name:match("^TSM_FRAME:LargeApplicationFrame:") then AH.tsmFrame = frame return frame end
    end
end
local function targetFrame()
    local target = tsmFrame()
    if target then return target end
    if visible(AuctionHouseFrame) then return AuctionHouseFrame end
    if visible(AuctionFrame) then return AuctionFrame end
end
local function allowedCategory(key)
    local settings = AH.config.categories
    return not settings or settings[key] ~= false
end
local function visibleColumns()
    local width = UIParent and UIParent:GetWidth()
    local right = AH.anchor and AH.anchor.GetRight and AH.anchor:GetRight()
    if public(width, "number") and public(right, "number") then
        return math.max(1, math.floor((width - right - PANEL_GAP - 8 + PITCH - ITEM_SIZE) / PITCH))
    end
    local maximum = 1
    for _, category in ipairs(catalog.categories) do maximum = math.max(maximum, #category.items) end
    return maximum
end
local function nodeVisible(node)
    if not AH.active or combat() then return false end
    if not allowedCategory(node.category) then return false end
    if not node.item then return true end
    local offset = AH.offsets[node.category] or 0
    return AH.expanded[node.category] == true and node.index > offset and node.index <= offset + AH.visibleColumns
end
local function hideTooltip(node)
    if GameTooltip and node.button and GameTooltip.IsOwned and GameTooltip:IsOwned(node.button) then GameTooltip:Hide() end
end
local function clearInteraction(node)
    node.hover, node.pressed = false, false
    if node.button then node.button:Hide() end
    hideTooltip(node)
end
local function updateVisual(node)
    scan("MERFIN_FOREVER_AH_VISUAL", node.key)
end
local function layout()
    if not AH.anchor then return end
    local row = 0
    local locations = {}
    for _, category in ipairs(catalog.categories) do
        if allowedCategory(category.key) then
            locations[category.key] = {0, -row * CATEGORY_PITCH}
            row = row + 1
        end
    end
    AH.locations = locations
    AH.anchor:SetSize(CATEGORY_SIZE, math.max(CATEGORY_SIZE, (row - 1) * CATEGORY_PITCH + CATEGORY_SIZE))
    AH.visibleColumns = visibleColumns()
    for _, category in ipairs(catalog.categories) do
        local panel = AH.panels[category.key]
        local capacity = math.min(#category.items, AH.visibleColumns)
        local maximum = math.max(0, #category.items - capacity)
        AH.offsets[category.key] = math.max(0, math.min(maximum, AH.offsets[category.key] or 0))
        panel:SetSize(math.max(ITEM_SIZE, capacity * PITCH - (PITCH - ITEM_SIZE)), ITEM_SIZE)
        local where = locations[category.key]
        local y = (where and where[2] or 0) - math.floor((CATEGORY_SIZE - ITEM_SIZE) / 2)
        if panel.layoutY ~= y then
            panel:ClearAllPoints()
            panel:SetPoint("TOPLEFT", AH.anchor, "TOPRIGHT", PANEL_GAP, y)
            panel.layoutY = y
        end
        if AH.active and where and AH.expanded[category.key] and #category.items > 0 then panel:Show() else panel:Hide() end
    end
    for _, node in pairs(AH.nodes) do
        local where = locations[node.category] or {0, 0}
        local parent, x, y = AH.anchor, where[1], where[2]
        if node.item then
            local index = node.index - 1 - (AH.offsets[node.category] or 0)
            parent, x, y = AH.panels[node.category], index * PITCH, 0
        end
        if node.parent ~= parent or node.x ~= x or node.y ~= y then
            node.anchor:ClearAllPoints()
            node.anchor:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
            node.parent, node.x, node.y = parent, x, y
        end
        if not nodeVisible(node) then clearInteraction(node) end
    end
end
function AH.Scroll(categoryKey, delta)
    if not AH.active or not AH.expanded[categoryKey] or not allowedCategory(categoryKey) or not public(delta, "number") then return end
    local previous = AH.offsets[categoryKey] or 0
    AH.offsets[categoryKey] = previous - delta
    layout()
    if AH.offsets[categoryKey] ~= previous then scan("MERFIN_FOREVER_AH_UPDATE") end
end
local function initialize()
    if AH.anchor then return end
    AH.anchor = CreateFrame("Frame", nil, UIParent)
    AH.anchor:SetSize(CATEGORY_SIZE, (#catalog.categories - 1) * CATEGORY_PITCH + CATEGORY_SIZE)
    AH.anchor:SetFrameStrata("HIGH")
    AH.anchor:SetClampedToScreen(true)
    AH.anchor:Hide()
    AH.visibleColumns = visibleColumns()
    for _, category in ipairs(catalog.categories) do
        local key = category.key
        local panel = CreateFrame("Frame", nil, AH.anchor)
        panel:SetSize(ITEM_SIZE, ITEM_SIZE)
        panel:SetClampedToScreen(false)
        panel:EnableMouseWheel(true)
        panel:SetScript("OnMouseWheel", function(_, delta) AH.Scroll(key, delta) end)
        panel:Hide()
        AH.panels[key] = panel
    end
    AH.frame = CreateFrame("Frame")
    for _, event in ipairs({"AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED", "PLAYER_ENTERING_WORLD", "ADDON_LOADED", "BAG_UPDATE_DELAYED", "ITEM_DATA_LOAD_RESULT", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "DISPLAY_SIZE_CHANGED", "UI_SCALE_CHANGED"}) do AH.frame:RegisterEvent(event) end
    AH.frame:SetScript("OnEvent", function(_, event, arg1, arg2)
        if event == "AUCTION_HOUSE_CLOSED" then
            AH.open, AH.active, AH.pending = false, false, nil
            AH.expanded, AH.offsets = {}, {}
            AH.generation = AH.generation + 1
            AH.anchor:Hide()
            if AH.ticker then AH.ticker:Cancel() AH.ticker = nil end
            for _, node in pairs(AH.nodes) do clearInteraction(node) end
            scan("MERFIN_FOREVER_AH_UPDATE")
        elseif event == "AUCTION_HOUSE_SHOW" then
            AH.open = true
            AH.Refresh()
            if C_Timer and C_Timer.NewTicker and not AH.ticker then AH.ticker = C_Timer.NewTicker(0.25, AH.Refresh) end
        elseif event == "ITEM_DATA_LOAD_RESULT" then
            local pending = AH.pending
            if pending and pending.itemID == arg1 then
                AH.pending = nil
                if arg2 and pending.generation == AH.generation and AH.active then AH.Search(arg1) end
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            AH.pending = nil AH.generation = AH.generation + 1 AH.Refresh()
        elseif event == "BAG_UPDATE_DELAYED" then
            if AH.active then scan("MERFIN_FOREVER_AH_UPDATE") end
        else AH.Refresh() end
    end)
    if targetFrame() then
        AH.open = true
        if C_Timer and C_Timer.NewTicker then AH.ticker = C_Timer.NewTicker(0.25, AH.Refresh) end
    end
end
function AH.Refresh()
    if not AH.anchor then return end
    local target = AH.open and not combat() and targetFrame() or nil
    local active = frameObject(target) and true or false
    if active == AH.active and target == AH.target then
        if active and AH.visibleColumns ~= visibleColumns() then layout() scan("MERFIN_FOREVER_AH_UPDATE") end
        return
    end
    AH.active, AH.target = active, target
    if active then
        AH.anchor:ClearAllPoints()
        AH.anchor:SetPoint("TOPLEFT", target, "TOPRIGHT", 6, 0)
        if target.GetFrameLevel then AH.anchor:SetFrameLevel(target:GetFrameLevel() + 20) end
        AH.anchor:Show()
    else
        AH.anchor:Hide()
        AH.pending = nil AH.generation = AH.generation + 1
    end
    layout()
    scan("MERFIN_FOREVER_AH_UPDATE")
end
function AH.SetConfig(config)
    AH.config = config or {}
    for key in pairs(AH.expanded) do
        if not allowedCategory(key) then AH.expanded[key], AH.offsets[key] = nil, nil end
    end
    initialize() layout() AH.Refresh()
    scan("MERFIN_FOREVER_AH_UPDATE")
end
function AH.GetAnchorFrame()
    initialize()
    return AH.anchor
end
function AH.GetNodeAnchor(key, categoryKey, itemID)
    initialize()
    if AH.nodes[key] then return AH.nodes[key].anchor end
    local category = AH.categories[categoryKey]
    if not category then return AH.anchor end
    local item
    if itemID then
        for _, entry in ipairs(category.items) do if entry.itemID == itemID then item = entry break end end
        if not item then return AH.anchor end
    end
    local anchor = CreateFrame("Frame", nil, AH.anchor)
    local node = {key = key, category = categoryKey, item = item, index = item and item.index or category.index, anchor = anchor}
    AH.nodes[key] = node
    local where = AH.locations and AH.locations[categoryKey]
    local row = category.index - 1
    local parent, x, y = AH.anchor, where and where[1] or 0, where and where[2] or -row * CATEGORY_PITCH
    if item then
        local index = node.index - 1 - (AH.offsets[categoryKey] or 0)
        parent, x, y = AH.panels[categoryKey], index * PITCH, 0
    end
    anchor:SetSize(item and ITEM_SIZE or CATEGORY_SIZE, item and ITEM_SIZE or CATEGORY_SIZE)
    anchor:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    node.parent, node.x, node.y = parent, x, y
    return anchor
end
local function walk(frame, visitor, depth)
    if not visible(frame) or depth > 14 then return end
    visitor(frame)
    if frame.GetChildren then for _, child in ipairs({frame:GetChildren()}) do walk(child, visitor, depth + 1) end end
end
local function matches(text, values)
    if not public(text, "string") then return false end
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower()
    for _, candidate in pairs(values) do if public(candidate, "string") and candidate:lower() == text then return true end end
    return false
end
local function searchTSM(name, target, generation)
    local browse
    walk(target, function(frame)
        if frame.GetText and frame.Click and matches(frame:GetText(), {BROWSE, AUCTION_BROWSE, "Browse", "Durchsuchen", "Parcourir", "Examinar", "Sfoglia", "Обзор", "찾아보기", "浏览", "瀏覽"}) then browse = browse or frame end
    end, 0)
    if browse then browse:Click() end
    local function submit()
        if generation ~= AH.generation or not AH.active or combat() or tsmFrame() ~= target then return end
        local input, button, width = nil, nil, 0
        walk(target, function(frame)
            local objectName = frame.GetName and frame:GetName()
            if frame.IsObjectType and frame:IsObjectType("EditBox") and frame.SetText and frame.GetWidth then
                local size = frame:GetWidth()
                if public(objectName, "string") and objectName:match("^TSM_EDIT_BOX:Input:") and public(size, "number") and size >= 280 and size > width then input, width = frame, size end
            elseif frame.GetText and frame.Click and matches(frame:GetText(), {SEARCH, SEARCH_LABEL, "Search", "Search the Auction House", "Suchen", "Suche", "Rechercher", "Buscar", "Cerca", "Поиск", "검색", "搜索", "搜尋"}) then button = button or frame end
        end, 0)
        if not input then return end
        input:SetText(name)
        if input.ClearFocus then input:ClearFocus() end
        if button then button:Click()
        elseif input.GetScript then local enter = input:GetScript("OnEnterPressed") if enter then enter(input) end end
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.1, submit) else submit() end
end
function AH.Search(itemID)
    if not AH.active or not AH.open or combat() or not C_Item or not C_Item.GetItemInfo then return end
    AH.generation = AH.generation + 1
    AH.pending = nil
    local name = C_Item.GetItemInfo(itemID)
    if not public(name, "string") or name == "" then
        if C_Item.RequestLoadItemDataByID then AH.pending = {itemID = itemID, generation = AH.generation} C_Item.RequestLoadItemDataByID(itemID) end
        return
    end
    local tsm = tsmFrame()
    if tsm then searchTSM(name, tsm, AH.generation) return end
    local api = Auctionator and Auctionator.API and Auctionator.API.v1
    if loaded("Auctionator") and api and type(api.MultiSearchExact) == "function"
        and AuctionatorTabs_Shopping and type(AuctionatorTabs_Shopping.Click) == "function"
        and Auctionator.Shopping and Auctionator.Shopping.ListManager then api.MultiSearchExact("MerfinPlus", {name}) return end
    local modern = AuctionHouseFrame
    if visible(modern) and modern.SearchBar and modern.SearchBar.SetSearchText and modern.SearchBar.StartSearch then
        local categories = modern.GetCategoriesList and modern:GetCategoriesList()
        if categories and categories.SetSelectedCategory then categories:SetSelectedCategory(nil) end
        if modern.SetDisplayMode and AuctionHouseFrameDisplayMode and AuctionHouseFrameDisplayMode.Buy then modern:SetDisplayMode(AuctionHouseFrameDisplayMode.Buy) end
        if modern.SearchBar.FilterButton and modern.SearchBar.FilterButton.Reset then modern.SearchBar.FilterButton:Reset() end
        modern.SearchBar:SetSearchText(name) modern.SearchBar:StartSearch() return
    end
    if visible(AuctionFrame) and BrowseName and BrowseName.SetText then
        if AuctionFrameTab1 and AuctionFrameTab1.Click then AuctionFrameTab1:Click()
        elseif AuctionFrameTab_OnClick and AuctionFrameTab1 then AuctionFrameTab_OnClick(AuctionFrameTab1) end
        BrowseName:SetText(name)
        if BrowseName.ClearFocus then BrowseName:ClearFocus() end
        if QueryAuctionItems then
            if CanSendAuctionQuery and not CanSendAuctionQuery() then return end
            QueryAuctionItems(name, nil, nil, 0, false, nil, false, true)
        elseif AuctionFrameBrowse_Search then AuctionFrameBrowse_Search()
        elseif BrowseSearchButton and BrowseSearchButton.Click then BrowseSearchButton:Click() end
    end
end
local function tooltip(node)
    if not GameTooltip or not node.button then return end
    GameTooltip:SetOwner(node.button, "ANCHOR_RIGHT")
    if node.item and GameTooltip.SetHyperlink then GameTooltip:SetHyperlink("item:" .. node.item.itemID)
    else GameTooltip:SetText(AH.categories[node.category].name) end
    GameTooltip:Show()
end
function AH.Attach(env, key, categoryKey, itemID)
    AH.GetNodeAnchor(key, categoryKey, itemID)
    local node = AH.nodes[key]
    if not node or not frameObject(env.region) then return end
    if not node.button then
        local button = CreateFrame("Button", nil, env.region)
        node.button = button
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:EnableMouseWheel(true)
        button:SetScript("OnMouseWheel", function(_, delta) AH.Scroll(node.category, delta) end)
        button:SetScript("OnEnter", function() if nodeVisible(node) then node.hover = true updateVisual(node) tooltip(node) end end)
        button:SetScript("OnLeave", function() node.hover, node.pressed = false, false updateVisual(node) hideTooltip(node) end)
        button:SetScript("OnMouseDown", function() node.pressed = true updateVisual(node) end)
        button:SetScript("OnMouseUp", function() node.pressed = false updateVisual(node) end)
        button:SetScript("OnClick", function(_, mouse)
            if not nodeVisible(node) then return end
            if node.item then if mouse == "LeftButton" then AH.Search(node.item.itemID) end
            else
                AH.expanded[node.category] = not AH.expanded[node.category]
                AH.offsets[node.category] = 0
                layout() scan("MERFIN_FOREVER_AH_UPDATE")
            end
        end)
        button:Hide()
    end
    if node.region ~= env.region then
        node.button:SetParent(env.region)
        node.button:ClearAllPoints() node.button:SetAllPoints(env.region)
        node.button:SetFrameLevel(env.region:GetFrameLevel() + 10)
        node.region = env.region
    end
    env.auctionNode = node
    env.ShowButton = function() if nodeVisible(node) then node.button:Show() end end
    env.HideButton = function() clearInteraction(node) end
    AH.Refresh()
end
function AH.Update(env, states, event, key)
    local node = env.auctionNode
    if not node or event == "MERFIN_FOREVER_AH_VISUAL" and key ~= node.key then return end
    if not nodeVisible(node) then states:Remove("") return end
    local category, item = AH.categories[node.category], node.item
    local count = ""
    if item and C_Item and C_Item.GetItemCount then
        local value = C_Item.GetItemCount(item.itemID, false, false)
        if public(value, "number") and value > 0 then count = tostring(value) end
    end
    states:Update("", {show = true, progressType = "static", value = 1, total = 1,
        name = item and item.name or category.name, icon = item and item.icon or category.icon,
        itemCount = count, hover = node.hover == true, pressed = node.pressed == true, open = node.item ~= nil or AH.expanded[node.category] == true})
end
function MerfinPlus:GetAuctionHelperForever()
    initialize()
    return AH
end
