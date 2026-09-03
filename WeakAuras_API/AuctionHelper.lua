local _, MerfinPlus = ...

local AH = _G.MerfinAuctionHelperTBC or {}
_G.MerfinAuctionHelperTBC = AH
MerfinPlus.AuctionHelperTBC = AH

function MerfinPlus:GetAuctionHelperTBC()
  return AH
end

local Catalog = MerfinPlus.AuctionHelperCatalogTBC or _G.MerfinAuctionHelperCatalogTBC or {
  items = {},
  buttons = {},
}

AH.version = 8
AH.events = AH.events or {}
AH.catalog = Catalog
AH.toggleStates = AH.toggleStates or {}
AH.attachedEnvironments = AH.attachedEnvironments or setmetatable({}, { __mode = "k" })
AH.visualGeneration = AH.visualGeneration or 0
AH.visualRefreshById = AH.visualRefreshById or {}

local CatalogKeyByDisplayID = {
  items = {},
  buttons = {},
}

for key, entry in pairs(Catalog.items or {}) do
  if entry.displayID then
    CatalogKeyByDisplayID.items[entry.displayID] = key
  end
end

for key, entry in pairs(Catalog.buttons or {}) do
  if entry.displayID then
    CatalogKeyByDisplayID.buttons[entry.displayID] = key
  end
end

local API_IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
local UPDATE_EVENT = "MERFIN_AH_UPDATE"
local TSM_FRAME_PREFIX = "^TSM_FRAME:LargeApplicationFrame:"
local MIN_TSM_SEARCH_WIDTH = 280
local UPDATE_INTERVAL = 0.25
local MATERIALS_TSM_ANCHOR_XOFFSET = -97

local TSM_REFRESH_DELAYS = {
  0.02,
  0.12,
  0.35,
}

local browseLabels = {
  BROWSE,
  "Browse",
  "Durchsuchen",
}

local searchLabels = {
  SEARCH,
  "Search",
  "Suche",
  "Suchen",
}

local shoppingLabels = {
  "Shopping",
  "Shop",
  "Einkaufen",
}

local anchor = CreateFrame("Frame", nil, UIParent)
AH.anchor = anchor
local materialsAnchor = CreateFrame("Frame", nil, UIParent)
AH.materialsAnchor = materialsAnchor

anchor:SetSize(750, 450)
anchor:SetFrameStrata("HIGH")
anchor:SetFrameLevel(250)
anchor:EnableMouse(false)
anchor:Hide()

materialsAnchor:SetSize(750, 450)
materialsAnchor:SetFrameStrata("HIGH")
materialsAnchor:SetFrameLevel(250)
materialsAnchor:EnableMouse(false)
materialsAnchor:Hide()

local eventFrame = CreateFrame("Frame")
local elapsedSinceUpdate = 0
local lastOpen = nil
local lastAnchorTarget = nil

local function SafeCall(method, self, ...)
  if type(method) ~= "function" then
    return false
  end
  return pcall(method, self, ...)
end

local function SafeValue(method, self, ...)
  if type(method) ~= "function" then
    return nil
  end
  local ok, value = pcall(method, self, ...)
  if ok then
    return value
  end
  return nil
end

local function IsShown(frame)
  return SafeValue(frame and frame.IsShown, frame) and true or false
end

local function IsVisible(frame)
  return SafeValue(frame and frame.IsVisible, frame) and true or false
end

local function GetName(frame)
  return SafeValue(frame and frame.GetName, frame)
end

local function GetObjectType(frame)
  return SafeValue(frame and frame.GetObjectType, frame)
end

local function GetFrameWidth(frame)
  return SafeValue(frame and frame.GetWidth, frame) or 0
end

local function AddMessage(message, r, g, b)
  if UIErrorsFrame and UIErrorsFrame.AddMessage then
    UIErrorsFrame:AddMessage(message, r or 1, g or 0.82, b or 0, 1)
  else
    print(message)
  end
end

local function CleanText(text)
  if type(text) ~= "string" then
    return ""
  end
  text = gsub(text, "|c%x%x%x%x%x%x%x%x", "")
  text = gsub(text, "|r", "")
  text = gsub(text, "|T.-|t", "")
  text = gsub(text, "^%s+", "")
  text = gsub(text, "%s+$", "")
  return text
end

local function TextMatches(text, labels)
  text = CleanText(text)
  for i = 1, #labels do
    local label = CleanText(labels[i])
    if label ~= "" and text == label then
      return true
    end
  end
  return false
end

local function FrameText(frame)
  local text = SafeValue(frame and frame.GetText, frame)
  if type(text) == "string" and text ~= "" then
    return text
  end
  if frame and frame.text then
    text = SafeValue(frame.text.GetText, frame.text)
    if type(text) == "string" and text ~= "" then
      return text
    end
  end
  return nil
end

local function Children(parent)
  if not parent or type(parent.GetChildren) ~= "function" then
    return nil
  end
  local ok, children = pcall(function()
    return { parent:GetChildren() }
  end)
  if ok then
    return children
  end
  return nil
end

local function WalkChildren(parent, predicate, maxDepth, depth)
  depth = depth or 0
  if depth > (maxDepth or 8) then
    return nil
  end

  local children = Children(parent)
  if not children then
    return nil
  end

  for i = 1, #children do
    local child = children[i]
    if predicate(child) then
      return child
    end
  end

  for i = 1, #children do
    local found = WalkChildren(children[i], predicate, maxDepth, depth + 1)
    if found then
      return found
    end
  end

  return nil
end

local function SafeClick(frame)
  if not frame or type(frame.Click) ~= "function" then
    return false
  end
  return SafeCall(frame.Click, frame) and true or false
end

local function IsVisibleButtonWithText(frame, labels)
  return IsShown(frame) and GetObjectType(frame) == "Button" and TextMatches(FrameText(frame), labels)
end

local function IsVisibleEditBox(frame)
  if not IsShown(frame) or GetObjectType(frame) ~= "EditBox" then
    return false
  end

  local name = GetName(frame)
  if type(name) == "string" and not strmatch(name, "^TSM_EDIT_BOX:Input:") then
    return false
  end

  return true
end

function AH.IsAddonLoaded(name)
  if not API_IsAddOnLoaded then
    return false
  end

  local a, b = API_IsAddOnLoaded(name)
  if type(a) == "boolean" then
    if b ~= nil then
      return a or b
    end
    return a
  end

  return a and true or false
end

local function TSMApiAuctionVisible()
  if not TSM_API or type(TSM_API.IsUIVisible) ~= "function" then
    return nil
  end

  local ok, visible = pcall(TSM_API.IsUIVisible, "AUCTION")
  if ok then
    return visible and true or false
  end
  return nil
end

function AH.FindTSMAuctionFrame()
  if not AH.IsAddonLoaded("TradeSkillMaster") then
    AH.tsmFrameCache = nil
    return nil
  end

  if TSMApiAuctionVisible() == false then
    AH.tsmFrameCache = nil
    return nil
  end

  if
    IsVisible(AH.tsmFrameCache)
    and type(GetName(AH.tsmFrameCache)) == "string"
    and strmatch(GetName(AH.tsmFrameCache), TSM_FRAME_PREFIX)
  then
    return AH.tsmFrameCache
  end

  AH.tsmFrameCache = nil

  local children = Children(UIParent)
  if not children then
    return nil
  end

  for i = 1, #children do
    local child = children[i]
    local name = GetName(child)
    if IsVisible(child) and type(name) == "string" and strmatch(name, TSM_FRAME_PREFIX) then
      AH.tsmFrameCache = child
      return child
    end
  end

  return nil
end

function AH.IsTSMAuctionVisible()
  local visible = TSMApiAuctionVisible()
  if visible == false then
    return false
  end

  return AH.FindTSMAuctionFrame() and true or false
end

function AH.GetDefaultAuctionFrame()
  if IsVisible(AuctionFrame) then
    return AuctionFrame
  end
  if IsVisible(AuctionHouseFrame) then
    return AuctionHouseFrame
  end
  return nil
end

function AH.IsDefaultAuctionVisible()
  return AH.GetDefaultAuctionFrame() and true or false
end

function AH.IsAuctionOpen()
  return AH.IsDefaultAuctionVisible() or AH.IsTSMAuctionVisible()
end

function AH.HasSupportedAddon()
  return AH.IsAuctionatorAvailable()
    or AH.IsAddonLoaded("Auctioneer")
    or AH.IsAddonLoaded("Auc-Advanced")
    or AH.IsAddonLoaded("TradeSkillMaster")
    or AH.IsDefaultAuctionVisible()
end

function AH.GetAuctionAnchorFrame()
  return AH.FindTSMAuctionFrame() or AH.GetDefaultAuctionFrame()
end

function AH.GetAnchorFrame()
  return anchor
end

function AH.GetMaterialsAnchorFrame()
  return materialsAnchor
end

function AH.UpdateAnchor()
  local tsmFrame = AH.FindTSMAuctionFrame()
  local target = tsmFrame or AH.GetDefaultAuctionFrame()
  local useTSMMaterialsOffset = target and tsmFrame and target == tsmFrame
  local useTSMButtonRefresh = target and AH.IsAddonLoaded("TradeSkillMaster")
  local open = target and true or false
  local weakAurasReady = WeakAuras and WeakAuras.ScanEvents
  local needsScan = weakAurasReady and not AH.didWeakAurasScan
  local needsTSMRefresh = useTSMButtonRefresh and not AH.tsmOpenRefreshQueued
  local changed = open ~= lastOpen or target ~= lastAnchorTarget
  local opening = open and (lastOpen ~= true or target ~= lastAnchorTarget)
  local shouldReset = not open and (lastOpen ~= false or next(AH.toggleStates) ~= nil)

  if not weakAurasReady then
    AH.didWeakAurasScan = false
  end

  if not changed and not needsScan and not needsTSMRefresh then
    return
  end

  if shouldReset and AH.ResetRuntimeState then
    AH.ResetRuntimeState()
  end

  lastOpen = open
  lastAnchorTarget = target

  anchor:ClearAllPoints()
  anchor:SetParent(UIParent)
  materialsAnchor:ClearAllPoints()
  materialsAnchor:SetParent(UIParent)

  if target then
    anchor:SetPoint("TOPLEFT", target, "TOPLEFT")
    anchor:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT")
    if useTSMMaterialsOffset then
      materialsAnchor:SetPoint("TOPLEFT", target, "TOPLEFT", MATERIALS_TSM_ANCHOR_XOFFSET, 0)
      materialsAnchor:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", MATERIALS_TSM_ANCHOR_XOFFSET, 0)
    else
      materialsAnchor:SetPoint("TOPLEFT", target, "TOPLEFT")
      materialsAnchor:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT")
    end
    if type(target.GetFrameStrata) == "function" then
      local strata = SafeValue(target.GetFrameStrata, target)
      if strata then
        anchor:SetFrameStrata(strata)
        materialsAnchor:SetFrameStrata(strata)
      end
    end
    if type(target.GetFrameLevel) == "function" then
      local level = (SafeValue(target.GetFrameLevel, target) or 1) + 20
      anchor:SetFrameLevel(level)
      materialsAnchor:SetFrameLevel(level)
    end
    anchor:Show()
    materialsAnchor:Show()
  else
    anchor:Hide()
    materialsAnchor:Hide()
    AH.tsmOpenRefreshQueued = false
    AH.tsmRefreshGeneration = (AH.tsmRefreshGeneration or 0) + 1
  end

  if weakAurasReady then
    AH.didWeakAurasScan = true
    WeakAuras.ScanEvents(UPDATE_EVENT, open, target or anchor)
  end

  -- If MerfinPlus observed the open auction frame before WeakAuras finished
  -- loading, `opening` is already false by the time the first WA scan runs.
  -- Treat that first scan like an opening so the groups get their initial
  -- layout/background pass as well.
  if open and (opening or needsScan) and AH.QueueWeakAuraVisualRefresh then
    AH.QueueWeakAuraVisualRefresh()
  end

  if useTSMButtonRefresh then
    AH.QueueTSMOpenRefresh(target)
  elseif AH.tsmOpenRefreshQueued then
    AH.tsmOpenRefreshQueued = false
    AH.tsmRefreshGeneration = (AH.tsmRefreshGeneration or 0) + 1
  end
end

local function GetItemNameAndLink(item, fallbackName)
  if item ~= nil then
    local name, link = GetItemInfo(item)
    if name then
      return name, link
    end

    if type(item) == "string" then
      local itemId = tonumber(item)
      if itemId then
        name, link = GetItemInfo(itemId)
        if name then
          return name, link
        end
      else
        return item, nil
      end
    end
  end

  return fallbackName, nil
end

function AH.OpenTSMBrowsePage()
  local tsmFrame = AH.FindTSMAuctionFrame()
  if not tsmFrame then
    return false
  end

  local browseButton = WalkChildren(tsmFrame, function(frame)
    return IsVisibleButtonWithText(frame, browseLabels)
  end, 10)

  return browseButton and SafeClick(browseButton) or false
end

function AH.FindTSMSearchInput()
  local tsmFrame = AH.FindTSMAuctionFrame()
  if not tsmFrame then
    return nil
  end

  local bestFrame = nil
  local bestWidth = 0

  WalkChildren(tsmFrame, function(frame)
    if not IsVisibleEditBox(frame) then
      return false
    end

    local width = GetFrameWidth(frame)
    if width > bestWidth then
      bestFrame = frame
      bestWidth = width
    end

    return false
  end, 10)

  if bestFrame and bestWidth >= MIN_TSM_SEARCH_WIDTH then
    return bestFrame
  end

  return nil
end

function AH.FindTSMSearchButton()
  local tsmFrame = AH.FindTSMAuctionFrame()
  if not tsmFrame then
    return nil
  end

  return WalkChildren(tsmFrame, function(frame)
    return IsVisibleButtonWithText(frame, searchLabels)
  end, 10)
end

function AH.SearchTSMFilter(searchText)
  local input = AH.FindTSMSearchInput()
  if not input then
    return false
  end

  if type(input.SetFocus) == "function" then
    SafeCall(input.SetFocus, input)
  end
  if type(input.SetText) == "function" then
    SafeCall(input.SetText, input, "")
    SafeCall(input.SetText, input, searchText)
  end
  if type(input.HighlightText) == "function" then
    SafeCall(input.HighlightText, input, 0, -1)
  end

  local searchButton = AH.FindTSMSearchButton()
  if searchButton and SafeClick(searchButton) then
    return true
  end

  local onEnter = SafeValue(input.GetScript, input, "OnEnterPressed")
  if type(onEnter) == "function" then
    local ok = pcall(onEnter, input)
    return ok and true or false
  end

  return false
end

function AH.GetAuctionatorShoppingFrame()
  return _G.AuctionatorShoppingFrame
end

function AH.GetAuctionatorShoppingTab()
  if _G.AuctionatorShoppingTab then
    return _G.AuctionatorShoppingTab
  end

  return WalkChildren(AuctionFrame, function(frame)
    return IsVisibleButtonWithText(frame, shoppingLabels)
  end, 4)
end

function AH.IsAuctionatorAvailable()
  return AH.IsAddonLoaded("Auctionator")
    or AH.IsAddonLoaded("Auctionator_TBC")
    or AH.IsAddonLoaded("AuctionatorClassic")
    or AH.IsAddonLoaded("Auctionator_Classic")
    or _G.AuctionatorShoppingFrame ~= nil
    or _G.AuctionatorShoppingTab ~= nil
    or _G.Atr_Search_Box ~= nil
    or type(_G.Atr_Search_Onclick) == "function"
    or AH.GetAuctionatorShoppingTab() ~= nil
end

function AH.GetAuctionatorSearchBox()
  local frame = AH.GetAuctionatorShoppingFrame()
  if not frame then
    return _G.Atr_Search_Box
  end

  if frame.SearchOptions and frame.SearchOptions.SearchString then
    return frame.SearchOptions.SearchString
  end

  if frame.SearchString then
    return frame.SearchString
  end

  if _G.Atr_Search_Box then
    return _G.Atr_Search_Box
  end

  return nil
end

function AH.FindAuctionatorSearchButtonByText(parent)
  if not parent then
    return nil
  end

  return WalkChildren(parent, function(frame)
    return IsVisibleButtonWithText(frame, searchLabels)
  end, 5)
end

function AH.GetAuctionatorSearchButton()
  local frame = AH.GetAuctionatorShoppingFrame()
  if not frame then
    return nil
  end

  if frame.SearchButton and type(frame.SearchButton.Click) == "function" then
    return frame.SearchButton
  end

  if
    frame.SearchOptions
    and frame.SearchOptions.SearchButton
    and type(frame.SearchOptions.SearchButton.Click) == "function"
  then
    return frame.SearchOptions.SearchButton
  end

  if _G.AuctionatorShoppingFrameSearchButton and type(_G.AuctionatorShoppingFrameSearchButton.Click) == "function" then
    return _G.AuctionatorShoppingFrameSearchButton
  end

  if _G.Atr_Search_Button and type(_G.Atr_Search_Button.Click) == "function" then
    return _G.Atr_Search_Button
  end

  local button = AH.FindAuctionatorSearchButtonByText(frame)
  if button then
    return button
  end

  if frame.SearchOptions then
    button = AH.FindAuctionatorSearchButtonByText(frame.SearchOptions)
    if button then
      return button
    end
  end

  return nil
end

function AH.OpenAuctionatorShoppingTab()
  local shoppingTab = AH.GetAuctionatorShoppingTab()
  if shoppingTab and SafeClick(shoppingTab) then
    return true
  end

  local frame = AH.GetAuctionatorShoppingFrame()
  if IsShown(frame) then
    return true
  end

  return false
end

function AH.PressAuctionatorSearch(searchBox)
  if type(_G.Atr_Search_Onclick) == "function" then
    local ok = pcall(_G.Atr_Search_Onclick)
    if ok then
      return true
    end
  end

  local button = AH.GetAuctionatorSearchButton()
  if button and SafeClick(button) then
    return true
  end

  local onEnterPressed = SafeValue(searchBox and searchBox.GetScript, searchBox, "OnEnterPressed")
  if type(onEnterPressed) == "function" then
    local ok = pcall(onEnterPressed, searchBox)
    return ok and true or false
  end

  return false
end

function AH.SearchAuctionatorItem(item, fallbackName)
  if not AH.IsAuctionatorAvailable() then
    return false
  end

  local itemName = GetItemNameAndLink(item, fallbackName)
  if not itemName then
    AddMessage("Merfin AH: item info is not loaded yet.", 1, 0.1, 0.1)
    return true
  end

  AH.OpenAuctionatorShoppingTab()

  local function RunSearch()
    local searchBox = AH.GetAuctionatorSearchBox()
    if not searchBox then
      AddMessage("Merfin AH: Auctionator shopping search box not found.", 1, 0.1, 0.1)
      return
    end

    SafeCall(searchBox.SetFocus, searchBox)
    SafeCall(searchBox.SetText, searchBox, "")
    SafeCall(searchBox.SetText, searchBox, itemName)
    SafeCall(searchBox.HighlightText, searchBox, 0, -1)

    if not AH.PressAuctionatorSearch(searchBox) then
      AddMessage("Merfin AH: Auctionator shopping search trigger not found.", 1, 0.1, 0.1)
    end
  end

  C_Timer.After(0.05, RunSearch)
  return true
end

function AH.SearchTSMItem(item, fallbackName)
  if not AH.IsTSMAuctionVisible() then
    return false
  end

  local itemName, itemLink = GetItemNameAndLink(item, fallbackName)
  if not itemName then
    AddMessage("Merfin AH: item info is not loaded yet.", 1, 0.1, 0.1)
    return true
  end

  AH.OpenTSMBrowsePage()

  local function RunSearch()
    if itemLink and HandleModifiedItemClick then
      local ok, handled = pcall(HandleModifiedItemClick, itemLink)
      if ok and handled then
        return
      end
    end

    if not AH.SearchTSMFilter(itemName) then
      AddMessage("Merfin AH: TSM search controls not found.", 1, 0.1, 0.1)
    end
  end

  C_Timer.After(0.05, RunSearch)
  return true
end

function AH.SearchDefaultAuction(itemName)
  if not AH.IsDefaultAuctionVisible() or not QueryAuctionItems then
    return false
  end
  if CanSendAuctionQuery and not CanSendAuctionQuery() then
    AddMessage("Merfin AH: auction query is not ready yet.", 1, 0.1, 0.1)
    return true
  end

  QueryAuctionItems(itemName, nil, nil, 0, false, nil, false, true)
  return true
end

function AH.SearchItem(item, fallbackName)
  if not AH.IsAuctionOpen() then
    return false
  end

  local itemName = GetItemNameAndLink(item, fallbackName)

  if AH.SearchTSMItem(item, itemName) then
    return true
  end

  if AH.SearchAuctionatorItem(item, itemName) then
    return true
  end

  if not itemName then
    AddMessage("Merfin AH: item info is not loaded yet.", 1, 0.1, 0.1)
    return true
  end

  if AH.SearchDefaultAuction(itemName) then
    return true
  end

  return false
end

Merfin.SearchAuctionItem = function(item, fallbackName)
  return AH.SearchItem(item, fallbackName)
end

local function GetCatalogEntry(kind, key, displayID)
  local entries = Catalog and Catalog[kind]
  local entry = entries and key and entries[key]
  if not entry and displayID then
    key = CatalogKeyByDisplayID[kind] and CatalogKeyByDisplayID[kind][displayID]
    entry = entries and key and entries[key]
  end
  if entry then
    return entry, key
  end

  AH.missingCatalogWarnings = AH.missingCatalogWarnings or {}
  local warningKey = tostring(kind) .. ":" .. tostring(key or displayID)
  if not AH.missingCatalogWarnings[warningKey] then
    AH.missingCatalogWarnings[warningKey] = true
    AddMessage("Merfin AH: missing catalog entry " .. warningKey .. ".", 1, 0.1, 0.1)
  end
  return nil
end

function AH.GetCatalogItem(key, displayID)
  return GetCatalogEntry("items", key, displayID)
end

function AH.GetCatalogButton(key, displayID)
  return GetCatalogEntry("buttons", key, displayID)
end

function AH.IsAuraActive()
  return AH.IsAuctionOpen() and AH.HasSupportedAddon()
end

local function SetToggleState(event, open)
  if not event then
    return
  end
  AH.toggleStates[event] = open and true or nil
end

local function GetToggleState(event)
  return event and AH.toggleStates[event] and true or false
end

function AH.ResetToggleStates()
  for event in pairs(AH.toggleStates) do
    AH.toggleStates[event] = nil
  end
end

function AH.ResetRuntimeState()
  AH.ResetToggleStates()
  AH.visualRefreshById = {}

  for env in pairs(AH.attachedEnvironments) do
    env.hover = false
    env.pressed = false
    env.open = false
    env.parentOpen = false
    env.dropdownOpen = false
    if env.HideButton then
      env.HideButton()
    end
  end

  if not (WeakAuras and WeakAuras.ScanEvents) then
    return
  end

  local scanned = {}
  local function ScanOnce(event, ...)
    if not event or scanned[event] then
      return
    end
    scanned[event] = true
    WeakAuras.ScanEvents(event, ...)
  end

  for _, entry in pairs(Catalog.buttons or {}) do
    ScanOnce(entry.stateEvent, false, false, false)
    ScanOnce(entry.toggleEvent, false)
    ScanOnce(entry.parentToggleEvent, false)
    for _, closeEvent in pairs(entry.closeEvents or {}) do
      ScanOnce(closeEvent, false)
    end
  end

  for _, entry in pairs(Catalog.items or {}) do
    ScanOnce(entry.toggleEvent, false)
  end

  WeakAuras.ScanEvents(UPDATE_EVENT, false, anchor)
end

local function WeakAurasVisualRefreshReady()
  return WeakAurasSaved
    and WeakAurasSaved.displays
    and WeakAuras
    and type(WeakAuras.Add) == "function"
    and type(WeakAuras.GetRegion) == "function"
end

function AH.RefreshWeakAuraDisplay(id)
  if not id or not AH.IsAuctionOpen() or not WeakAurasVisualRefreshReady() then
    return false
  end

  local data = WeakAurasSaved.displays[id]
  local region = WeakAuras.GetRegion(id)
  if not data or not region then
    return false
  end

  if AH.visualRefreshById[id] == AH.visualGeneration then
    return true
  end

  -- Mark before Add: UpdatedTriggerState can synchronously revisit the aura.
  AH.visualRefreshById[id] = AH.visualGeneration
  WeakAuras.Add(data, true)
  return true
end

function AH.RefreshWeakAuraBranch(id)
  if not id or not WeakAurasVisualRefreshReady() then
    return false
  end

  local displays = WeakAurasSaved.displays
  local branch = {}
  local seen = {}
  local currentID = id

  -- Refresh the visible leaf first and collect its controlling groups. The
  -- backdrop/border we need is owned by dynamic groups. Normal groups must
  -- not be rebuilt here: the top-level Auction Helper group has no intrinsic
  -- size and WeakAuras otherwise renders its 16x16 fallback border at screen
  -- center.
  while currentID and not seen[currentID] do
    seen[currentID] = true
    branch[#branch + 1] = currentID
    local data = displays[currentID]
    currentID = data and data.parent or nil
  end

  local refreshed = false
  for i = 1, #branch do
    local data = displays[branch[i]]
    if i == 1 or (data and data.regionType == "dynamicgroup") then
      refreshed = AH.RefreshWeakAuraDisplay(branch[i]) or refreshed
    end
  end
  return refreshed
end

function AH.RefreshPrimaryWeakAuraVisuals()
  if not AH.IsAuctionOpen() then
    return false
  end

  local refreshed = false
  for _, entry in pairs(Catalog.buttons or {}) do
    refreshed = AH.RefreshWeakAuraBranch(entry.displayID) or refreshed
  end
  return refreshed
end

function AH.QueueWeakAuraVisualRefresh()
  for _, delay in ipairs({ 0, 0.05, 0.2 }) do
    C_Timer.After(delay, function()
      if AH.IsAuctionOpen() then
        -- Each delayed pass is a real retry. The previous implementation kept
        -- one generation for all timers, which caused the first callback to
        -- suppress the later callbacks even if group layout was not ready yet.
        AH.visualGeneration = AH.visualGeneration + 1
        AH.visualRefreshById = {}
        AH.RefreshPrimaryWeakAuraVisuals()
      end
    end)
  end
end

local function QueueDisplayVisualRefresh(env)
  if not env or not env.id or not C_Timer or not C_Timer.After then
    return
  end

  C_Timer.After(0, function()
    if AH.IsAuctionOpen() then
      AH.RefreshWeakAuraBranch(env.id)
    end
  end)
end

local function SetStaticState(states, show)
  states[""] = states[""] or {}
  local state = states[""]
  state.show = show and true or false
  state.changed = true
  state.progressType = "static"
  state.value = 1
  state.total = 1
  return state
end

function AH.UpdateItemDropdownState(env, states, event, open)
  if not env or not states then
    return false
  end

  if event == env.toggleEvent then
    SetToggleState(env.toggleEvent, open)
    env.dropdownOpen = GetToggleState(env.toggleEvent)
  elseif event == "AUCTION_HOUSE_CLOSED" or event == "PLAYER_ENTERING_WORLD" then
    SetToggleState(env.toggleEvent, false)
    env.dropdownOpen = false
  end

  SetStaticState(states, env.dropdownOpen)
  return true
end

function AH.UpdateItemVisualState(env, states, event, targetId, hover, pressed)
  if not env or not states then
    return false
  end

  if event == "AUCTION_HOUSE_CLOSED" then
    env.hover = false
    env.pressed = false
  elseif event == "MR_AH_ITEM_VISUAL" then
    if targetId ~= env.id then
      return false
    end
    env.hover = hover and true or false
    env.pressed = pressed and true or false
  end

  local state = SetStaticState(states, true)
  state.hover = env.hover and true or false
  state.pressed = env.pressed and true or false
  return true
end

function AH.UpdateItemState(env, states, event, arg1, arg2, arg3)
  if not env or not states then
    return false
  end

  if event == "MR_AH_ITEM_VISUAL" then
    if arg1 ~= env.id then
      return false
    end
    env.hover = arg2 and true or false
    env.pressed = arg3 and true or false
  elseif event == env.toggleEvent then
    SetToggleState(env.toggleEvent, arg1)
    env.dropdownOpen = GetToggleState(env.toggleEvent)
    env.pressed = false
  elseif event == "AUCTION_HOUSE_CLOSED" or event == "PLAYER_ENTERING_WORLD" then
    SetToggleState(env.toggleEvent, false)
    env.dropdownOpen = false
    env.hover = false
    env.pressed = false
  end

  local active = AH.IsAuraActive()
  local state = SetStaticState(states, active and env.dropdownOpen)
  state.hover = env.hover and true or false
  state.pressed = env.pressed and true or false
  return true
end

function AH.UpdateButtonParentState(env, states, event, open)
  if not env or not states then
    return false
  end

  if event == env.parentToggleEvent then
    SetToggleState(env.parentToggleEvent, open)
    env.parentOpen = GetToggleState(env.parentToggleEvent)
    if not env.parentOpen and env.open then
      env.open = false
      SetToggleState(env.toggleEvent, false)
      if WeakAuras and WeakAuras.ScanEvents and env.toggleEvent then
        WeakAuras.ScanEvents(env.toggleEvent, false)
      end
    end
  elseif event == "AUCTION_HOUSE_CLOSED" or event == "PLAYER_ENTERING_WORLD" then
    SetToggleState(env.parentToggleEvent, false)
    SetToggleState(env.toggleEvent, false)
    env.parentOpen = false
    env.open = false
  end

  SetStaticState(states, env.parentOpen)
  return true
end

function AH.UpdateButtonState(env, states, event, arg1, arg2, arg3)
  if not env or not states then
    return false
  end

  if event == "AUCTION_HOUSE_CLOSED" or event == "PLAYER_ENTERING_WORLD" then
    SetToggleState(env.toggleEvent, false)
    env.hover = false
    env.pressed = false
    env.open = false
  elseif event == env.buttonStateEvent then
    env.hover = arg1 and true or false
    env.pressed = arg2 and true or false
    env.open = arg3 and true or false
    SetToggleState(env.toggleEvent, env.open)
  elseif event == env.toggleEvent then
    env.open = arg1 and true or false
    SetToggleState(env.toggleEvent, env.open)
    env.pressed = false
  end

  local state = SetStaticState(states, true)
  state.hover = env.hover and true or false
  state.pressed = env.pressed and true or false
  state.open = env.open and true or false
  return true
end

function AH.AttachCatalogItem(env, key)
  if type(env) ~= "table" then
    return false
  end

  local entry, resolvedKey = AH.GetCatalogItem(key, env.id)
  if not entry then
    return false
  end

  env.merfinAuctionCatalogKey = resolvedKey
  AH.attachedEnvironments[env] = true
  env.itemId = entry.itemID
  env.toggleEvent = entry.toggleEvent
  env.hover = false
  env.pressed = false
  env.dropdownOpen = GetToggleState(env.toggleEvent)
  AH.Attach(env)
  return true
end

function AH.AttachCatalogButton(env, key)
  if type(env) ~= "table" then
    return false
  end

  local entry, resolvedKey = AH.GetCatalogButton(key, env.id)
  if not entry then
    return false
  end

  env.merfinAuctionCatalogKey = resolvedKey
  AH.attachedEnvironments[env] = true
  env.buttonStateEvent = entry.stateEvent
  env.toggleEvent = entry.toggleEvent
  env.parentToggleEvent = entry.parentToggleEvent
  env.closeEvents = entry.closeEvents or {}
  env.hover = false
  env.pressed = false
  env.open = GetToggleState(env.toggleEvent)
  env.parentOpen = GetToggleState(env.parentToggleEvent)
  env.IsAuctionOpen = AH.IsAuctionOpen
  env.HasSupportedAddon = AH.HasSupportedAddon

  env.PushState = function()
    if WeakAuras and WeakAuras.ScanEvents then
      WeakAuras.ScanEvents(env.buttonStateEvent, env.hover, env.pressed, env.open)
    end
  end

  env.GetButtonFrame = function()
    local region = env.region
    if not region then
      return nil
    end
    if not env.button then
      env.button = CreateFrame("Button", nil, region)
    end
    return env.button
  end

  env.HideButton = function()
    local button = env.GetButtonFrame()
    if button then
      button:Hide()
      button:ClearAllPoints()
    end
  end

  env.ShowButton = function()
    local region = env.region
    local button = env.GetButtonFrame()
    if not region or not button then
      return
    end

    button:ClearAllPoints()
    button:SetAllPoints(region)
    button:SetFrameStrata(region:GetFrameStrata())
    button:SetFrameLevel(region:GetFrameLevel() + 10)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:Show()
    QueueDisplayVisualRefresh(env)

    button:SetScript("OnEnter", function()
      env.hover = true
      env.PushState()
    end)
    button:SetScript("OnLeave", function()
      env.hover = false
      env.pressed = false
      env.PushState()
    end)
    button:SetScript("OnMouseDown", function()
      env.pressed = true
      env.PushState()
    end)
    button:SetScript("OnMouseUp", function()
      env.pressed = false
      env.PushState()
    end)
    button:SetScript("OnClick", function()
      if not AH.IsAuraActive() then
        return
      end

      env.open = not env.open
      SetToggleState(env.toggleEvent, env.open)
      if not env.open then
        for _, closeEvent in pairs(env.closeEvents) do
          SetToggleState(closeEvent, false)
          WeakAuras.ScanEvents(closeEvent, false)
        end
      end
      WeakAuras.ScanEvents(env.toggleEvent, env.open)
      env.PushState()
    end)

    env.PushState()
  end

  return true
end

function AH.Attach(env)
  if type(env) ~= "table" or env.MerfinAuctionHelperAttached then
    return
  end

  env.MerfinAuctionHelperAttached = true

  local oldHasSupportedAddon = env.HasSupportedAddon
  local oldSearchItem = env.SearchItem

  env.IsAuctionOpen = function()
    return AH.IsAuctionOpen()
  end

  env.HasSupportedAddon = function()
    if oldHasSupportedAddon and oldHasSupportedAddon() then
      return true
    end
    return AH.HasSupportedAddon()
  end

  env.SearchItem = function()
    if AH.SearchItem(env.itemId, env.itemName) then
      return
    end

    if oldSearchItem then
      return oldSearchItem()
    end
  end

  if env.itemId == nil then
    return
  end

  env.PushVisual = function()
    WeakAuras.ScanEvents("MR_AH_ITEM_VISUAL", env.id, env.hover, env.pressed)
  end

  env.GetButtonFrame = function()
    local region = env.region
    if not region then
      return nil
    end

    local button = env.button
    if not button then
      button = CreateFrame("Button", nil, region)
      env.button = button
    end

    return button
  end

  env.HideButton = function()
    local button = env.GetButtonFrame()
    if button then
      button:Hide()
      button:ClearAllPoints()
    end
  end

  env.ShowButton = function()
    local region = env.region
    local button = env.GetButtonFrame()

    if not region or not button then
      return
    end

    button:ClearAllPoints()
    button:SetAllPoints(region)
    button:SetFrameStrata(region:GetFrameStrata())
    button:SetFrameLevel(region:GetFrameLevel() + 10)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:Show()
    QueueDisplayVisualRefresh(env)

    button:SetScript("OnClick", function()
      env.SearchItem()
    end)

    button:SetScript("OnEnter", function(self)
      env.hover = true
      env.PushVisual()
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetItemByID(env.itemId)
      GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
      env.hover = false
      env.pressed = false
      env.PushVisual()
      GameTooltip:Hide()
    end)

    button:SetScript("OnMouseDown", function()
      env.pressed = true
      env.PushVisual()
    end)

    button:SetScript("OnMouseUp", function()
      env.pressed = false
      env.PushVisual()
    end)

    env.PushVisual()
  end
end

local function ScanWeakAuraOpen(target)
  if not (WeakAuras and WeakAuras.ScanEvents) then
    return false
  end

  local currentTarget = target or AH.GetAuctionAnchorFrame()
  if not currentTarget or not AH.IsAuctionOpen() then
    AH.ResetRuntimeState()
    return false
  end

  WeakAuras.ScanEvents(UPDATE_EVENT, true, currentTarget)
  return true
end

function AH.RefreshTSMButtonAuras(target, generation)
  if not AH.IsAddonLoaded("TradeSkillMaster") or not AH.IsAuctionOpen() then
    return false
  end

  AH.tsmButtonRefreshGeneration = generation or AH.tsmRefreshGeneration
  return ScanWeakAuraOpen(target)
end

function AH.QueueTSMOpenRefresh(target)
  if AH.tsmOpenRefreshQueued then
    return
  end

  AH.tsmOpenRefreshQueued = true
  AH.tsmRefreshGeneration = (AH.tsmRefreshGeneration or 0) + 1
  local generation = AH.tsmRefreshGeneration

  for i = 1, #TSM_REFRESH_DELAYS do
    C_Timer.After(TSM_REFRESH_DELAYS[i], function()
      if
        generation ~= AH.tsmRefreshGeneration
        or not AH.IsAddonLoaded("TradeSkillMaster")
        or not AH.IsAuctionOpen()
      then
        return
      end

      local currentTarget = AH.GetAuctionAnchorFrame() or target
      if AH.tsmButtonRefreshGeneration ~= generation then
        AH.RefreshTSMButtonAuras(currentTarget, generation)
      else
        ScanWeakAuraOpen(currentTarget)
      end
    end)
  end
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
  if event == "AUCTION_HOUSE_CLOSED" or event == "PLAYER_ENTERING_WORLD" then
    AH.ResetRuntimeState()
  end

  C_Timer.After(0.05, AH.UpdateAnchor)
  if event == "AUCTION_HOUSE_SHOW" then
    C_Timer.After(0.15, AH.UpdateAnchor)
    C_Timer.After(0.35, AH.UpdateAnchor)
  end

  if
    event == "PLAYER_LOGIN"
    or event == "PLAYER_ENTERING_WORLD"
    or addonName == "TradeSkillMaster"
    or addonName == "WeakAuras"
  then
    C_Timer.After(0.5, function()
      AH.UpdateAnchor()
      ScanWeakAuraOpen(AH.GetAuctionAnchorFrame())
    end)
  end
end)
eventFrame:SetScript("OnUpdate", function(_, elapsed)
  elapsedSinceUpdate = elapsedSinceUpdate + elapsed
  if elapsedSinceUpdate < UPDATE_INTERVAL then
    return
  end
  elapsedSinceUpdate = 0
  AH.UpdateAnchor()
end)

SLASH_MERFIN_AH_HELPER1 = "/mah"
SlashCmdList.MERFIN_AH_HELPER = function(message)
  message = message or ""
  local command, rest = strmatch(message, "^(%S*)%s*(.-)$")
  if command == "status" or command == "" then
    local target = AH.GetAuctionAnchorFrame()
    local targetName = target and GetName(target) or tostring(target)
    print(
      "Merfin AH: open="
        .. tostring(AH.IsAuctionOpen())
        .. " tsm="
        .. tostring(AH.IsTSMAuctionVisible())
        .. " anchor="
        .. tostring(anchor:IsShown())
        .. " target="
        .. tostring(targetName)
    )
  elseif command == "search" and rest ~= "" then
    AH.SearchItem(rest)
  else
    print("Merfin AH: /mah status, /mah search <itemId or name>")
  end
end

AH.UpdateAnchor()
C_Timer.After(0.1, AH.UpdateAnchor)
