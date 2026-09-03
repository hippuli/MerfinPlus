Merfin = Merfin or {}
local expansion = math.floor(select(4, GetBuildInfo()) / 10000)

local UnitAffectingCombat = UnitAffectingCombat
local GetSpellInfo = GetSpellInfo
local SESSION_HIDE_EVENT = "MERFIN_REMINDER_SESSION_HIDE"

local pendingCombatHiddenButtons = setmetatable({}, { __mode = "k" })
local combatHiddenButtons = setmetatable({}, { __mode = "k" })
local hookedGroups = setmetatable({}, { __mode = "k" })
local syncPending = false

local function SyncCombatHiddenButtons()
  if InCombatLockdown() then return end

  for aura_env, state in pairs(combatHiddenButtons) do
    local button = state.button
    local region = aura_env.region

    if aura_env.button ~= button or not region then
      button:Hide()
      combatHiddenButtons[aura_env] = nil
    elseif not region:IsVisible() then
      button:Hide()
    else
      local left, bottom, width, height = region:GetRect()
      if left then
        local strata = region:GetFrameStrata()
        local level = region:GetFrameLevel() + 1

        if state.left ~= left
          or state.bottom ~= bottom
          or state.width ~= width
          or state.height ~= height
          or state.strata ~= strata
          or state.level ~= level
        then
          button:ClearAllPoints()
          button:SetSize(width, height)
          button:SetFrameStrata(strata)
          button:SetFrameLevel(level)
          button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)

          state.left = left
          state.bottom = bottom
          state.width = width
          state.height = height
          state.strata = strata
          state.level = level
        end

        button:Show()
      else
        button:Hide()
      end
    end
  end
end

local function ScheduleCombatHiddenButtonSync()
  if syncPending then return end
  syncPending = true

  C_Timer.After(0, function()
    syncPending = false
    SyncCombatHiddenButtons()
  end)
end

local function HookAuraGroup(aura_env)
  local data = WeakAuras.GetData(aura_env.id)
  local group = data and data.parent and WeakAuras.GetRegion(data.parent)
  if not group or type(group.PositionChildren) ~= "function" then return end

  local positionChildren = group.PositionChildren
  if hookedGroups[group] == positionChildren then return end

  hooksecurefunc(group, "PositionChildren", ScheduleCombatHiddenButtonSync)
  hookedGroups[group] = group.PositionChildren
end

local SetClickAnimation = function(aura_env)
  local r = WeakAuras.GetRegion(aura_env.id)
  if not r or not aura_env.button then
    return
  end

  aura_env.button:SetScript("OnMouseDown", function()
    r:SetAlpha(0.65)
  end)

  aura_env.button:SetScript("OnMouseUp", function()
    r:SetAlpha(1)
  end)

  aura_env.button:SetScript("OnLeave", function()
    r:SetAlpha(1)
    GameTooltip:Hide()
  end)
end

local function AddSessionHideButton(aura_env)
  local region = aura_env.region
  if not region then return end

  local closeButton = aura_env.sessionHideButton
  if not closeButton then
    closeButton = CreateFrame("Button", nil, region)
    closeButton:SetSize(16, 16)
    closeButton:RegisterForClicks("LeftButtonUp")

    local icon = closeButton:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetAtlas("common-icon-redx")

    -- Tooltip temporarily disabled.
    --[[
    closeButton:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_NONE")
      GameTooltip:ClearAllPoints()
      GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
      GameTooltip:SetText("Hide Reminder")
      GameTooltip:AddLine("Shown again after reload", 0.7, 0.7, 0.7)
      GameTooltip:Show()
    end)

    closeButton:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    ]]

    closeButton:SetScript("OnClick", function()
      aura_env.sessionHidden = true
      WeakAuras.ScanEvents(SESSION_HIDE_EVENT, aura_env.id)
    end)

    aura_env.sessionHideButton = closeButton
  end

  closeButton:ClearAllPoints()
  closeButton:SetPoint("TOPRIGHT", region, "TOPRIGHT", 0, 0)
  closeButton:SetFrameLevel(region:GetFrameLevel() + 2)
  closeButton:Show()
end

Merfin.AddSessionHideButton = AddSessionHideButton

local SetButtonTemplate = function(aura_env, buttonName, type, context, context2)
  if WeakAuras.IsOptionsOpen() then
    return
  end
  if UnitAffectingCombat("player") then
    return
  end

  local region = WeakAuras.GetRegion(aura_env.id)
  if not region then return end

  if not aura_env.button then
    aura_env.button = CreateFrame("Button", buttonName, region, "SecureActionButtonTemplate")
  end

  SetClickAnimation(aura_env)
  aura_env.button:SetAllPoints()

  if expansion == 2 or expansion == 3 or expansion == 5 then
    aura_env.button:RegisterForClicks("AnyUp", "AnyDown") -- TBC and WotLK are special
  else
    aura_env.button:RegisterForClicks("AnyUp")
  end
  aura_env.button:SetAttribute("type", type)
  if type == "macro" then
    aura_env.button:SetAttribute("macrotext1", context)
  elseif type == "item" then
    aura_env.button:SetAttribute("item", "item:" .. context)
  elseif type == "spell" then
    local spell = (context2 and select(1, GetSpellInfo(context))) or context
    aura_env.button:SetAttribute("spell", spell)
  end
end

local function SetCombatHiddenButtonTemplate(aura_env, buttonName, type, context, context2)
  if WeakAuras.IsOptionsOpen() then return end

  if UnitAffectingCombat("player") or InCombatLockdown() then
    local args = pendingCombatHiddenButtons[aura_env]
    if not args then
      args = {}
      pendingCombatHiddenButtons[aura_env] = args
    end
    args[1], args[2], args[3], args[4] = buttonName, type, context, context2
    return
  end

  local region = aura_env.region
  if not region then return end

  local state = combatHiddenButtons[aura_env]
  if not state then
    local button = aura_env.button
    if not button then
      button = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
      aura_env.button = button
    else
      button:Hide()
      button:ClearAllPoints()
      button:SetParent(UIParent)
    end

    state = { button = button }
    combatHiddenButtons[aura_env] = state

    button:SetScript("OnShow", function(self)
      local currentRegion = aura_env.region
      if not currentRegion or not currentRegion:IsVisible() then
        self:Hide()
      end
    end)

    RegisterStateDriver(button, "visibility", "[combat] hide; show")
  end

  local button = state.button
  SetClickAnimation(aura_env)

  if expansion == 2 or expansion == 3 or expansion == 5 then
    button:RegisterForClicks("AnyUp", "AnyDown") -- TBC and WotLK are special
  else
    button:RegisterForClicks("AnyUp")
  end

  button:SetAttribute("type", type)
  if type == "macro" then
    button:SetAttribute("macrotext1", context)
  elseif type == "item" then
    button:SetAttribute("item", "item:" .. context)
  elseif type == "spell" then
    local spell = (context2 and select(1, GetSpellInfo(context))) or context
    button:SetAttribute("spell", spell)
  end

  if state.region ~= region then
    state.region = region
    region:HookScript("OnShow", ScheduleCombatHiddenButtonSync)
    region:HookScript("OnHide", ScheduleCombatHiddenButtonSync)
  end

  HookAuraGroup(aura_env)
  ScheduleCombatHiddenButtonSync()
end

local function ProcessPendingCombatHiddenButtons()
  for aura_env, args in pairs(pendingCombatHiddenButtons) do
    pendingCombatHiddenButtons[aura_env] = nil
    SetCombatHiddenButtonTemplate(aura_env, args[1], args[2], args[3], args[4])
  end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function()
  ProcessPendingCombatHiddenButtons()
  for aura_env in pairs(combatHiddenButtons) do
    HookAuraGroup(aura_env)
  end
  ScheduleCombatHiddenButtonSync()
end)

-- Clickable Reminder
Merfin.SetButtonTemplate = function(aura_env, buttonName, type, context, context2)
  SetButtonTemplate(aura_env, buttonName, type, context, context2)
end

-- Clickable Reminder whose independent secure overlay is hidden during combat.
Merfin.SetCombatHiddenButtonTemplate = function(aura_env, buttonName, type, context, context2, showCloseButton)
  SetCombatHiddenButtonTemplate(aura_env, buttonName, type, context, context2)
  if showCloseButton then
    AddSessionHideButton(aura_env)
  end
end

Merfin.REMINDER_SESSION_HIDE_EVENT = SESSION_HIDE_EVENT

-- Sets Tooltip
Merfin.SetButtonTooltipItem = function(aura_env, buttonName, itemId)
  if not aura_env.button then
    local r = WeakAuras.GetRegion(aura_env.id)
    aura_env.button = CreateFrame("Button", buttonName, r, "SecureActionButtonTemplate")
  end

  SetClickAnimation(aura_env)

  aura_env.button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetItemByID(itemId)
    GameTooltip:Show()
  end)

  aura_env.button:SetScript("OnLeave", function(self)
    local r = WeakAuras.GetRegion(aura_env.id)
    if r then
      r:SetAlpha(1)
    end

    GameTooltip:Hide()
  end)
end

Merfin.SetCallbackButtonTemplate = function(aura_env, buttonName, callback, showCloseButton)
  local region = aura_env.region
  if not region or type(callback) ~= "function" then return false end
  if not aura_env.button then
    aura_env.button = CreateFrame("Button", buttonName, region)
  end
  local button = aura_env.button
  button:SetAllPoints()
  button:Enable()
  SetClickAnimation(aura_env)
  button:SetScript("OnClick", function(_, mouseButton) callback(mouseButton) end)
  if showCloseButton then
    AddSessionHideButton(aura_env)
  end
  return true
end
