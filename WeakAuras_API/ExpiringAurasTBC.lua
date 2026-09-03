Merfin = Merfin or {}
Merfin.ExpiringAurasTBC = Merfin.ExpiringAurasTBC or {}

local API = Merfin.ExpiringAurasTBC

local UnitExists          = UnitExists
local UnitIsVisible       = UnitIsVisible
local UnitIsDeadOrGhost   = UnitIsDeadOrGhost
local UnitCanAssist       = UnitCanAssist
local UnitIsUnit          = UnitIsUnit
local UnitInRange         = UnitInRange
local UnitInRaid          = UnitInRaid
local UnitAura            = UnitAura
local GetNumGroupMembers  = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local GetNumRaidMembers   = GetNumRaidMembers
local GetNumPartyMembers  = GetNumPartyMembers
local GetRaidRosterInfo   = GetRaidRosterInfo
local IsInRaid            = IsInRaid
local IsInInstance        = IsInInstance
local UnitAffectingCombat = UnitAffectingCombat
local GetSpellInfo        = GetSpellInfo
local GetTime             = GetTime
local UnitClass           = UnitClass
local UnitClassBase       = UnitClassBase or function(unit)
  local _, classFile = UnitClass(unit)
  return classFile
end

local DEFAULT_CLASS_FILTER = {
  ["DRUID"]   = true,
  ["HUNTER"]  = true,
  ["MAGE"]    = true,
  ["PALADIN"] = true,
  ["PRIEST"]  = true,
  ["ROGUE"]   = true,
  ["SHAMAN"]  = true,
  ["WARLOCK"] = true,
  ["WARRIOR"] = true,
}

local function CopyDefaultClassFilter()
  local classFilter = {}
  for class, enabled in pairs(DEFAULT_CLASS_FILTER) do
    classFilter[class] = enabled
  end
  return classFilter
end

local function Debug(aura_env, ...)
  if aura_env and aura_env.debugExpiringAurasTBC then
    print("|cff66ccffMerfin.ExpiringAurasTBC:|r", ...)
  end
end

local function GetRaidSize()
  if GetNumGroupMembers then
    return GetNumGroupMembers()
  end
  if GetNumRaidMembers then
    return GetNumRaidMembers()
  end
  return 0
end

local function GetPartySize()
  if GetNumSubgroupMembers then
    return GetNumSubgroupMembers()
  end
  if GetNumPartyMembers then
    return GetNumPartyMembers()
  end
  return 0
end

local function IterateGroupMembers()
  local index = 0
  local inRaid = IsInRaid()
  local count = inRaid and GetRaidSize() or GetPartySize()

  return function()
    while true do
      index = index + 1

      if index == 1 then
        return "player"
      end

      local unitIndex = index - 1
      if unitIndex > count then
        return
      end

      local unit = inRaid and ("raid" .. unitIndex) or ("party" .. unitIndex)
      if unit ~= "player" and (not UnitIsUnit or not UnitIsUnit(unit, "player")) then
        return unit
      end
    end
  end
end

local function GetUnitBuff(unit, spell, filter)
  filter = filter and (filter .. "|HELPFUL") or "HELPFUL"

  for i = 1, 255 do
    local name, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = UnitAura(unit, i, filter)
    if not name then
      return
    end

    local spellId = v11 or v10
    if spell == name or spell == spellId then
      return name, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11
    end
  end
end

function API.OnInit(aura_env)
  aura_env.buffSpellIds = aura_env.buffSpellIds or {}
  aura_env.buffNames = {}
  aura_env.expiringSoonThreshold = aura_env.expiringSoonThreshold or 600
  aura_env.expiringVerySoonThreshold = aura_env.expiringVerySoonThreshold or 60
  aura_env.classFilter = aura_env.classFilter or CopyDefaultClassFilter()

  aura_env.UnitAffectingCombat = UnitAffectingCombat
  aura_env.currentUnit  = nil
  aura_env.lastCastUnit = nil
  aura_env._lastMacroUnit = nil

  for _, spellId in ipairs(aura_env.buffSpellIds) do
    local name = GetSpellInfo(spellId)
    if name then
      aura_env.buffNames[name] = true
    end
  end

  aura_env.bigSpellName   = GetSpellInfo(aura_env.buffSpellIds[1])
  aura_env.smallSpellName = GetSpellInfo(aura_env.buffSpellIds[2])

  Debug(aura_env, "OnInit", "big=", aura_env.bigSpellName or "nil", "small=", aura_env.smallSpellName or "nil")

  aura_env.UnitBuffInfo = function(unit, expiringThreshold)
    if expiringThreshold == nil then
      expiringThreshold = aura_env.expiringSoonThreshold
    end

    local bestRemaining

    for name in pairs(aura_env.buffNames) do
      local buffName, _, _, _, duration, expirationTime = GetUnitBuff(unit, name)

      if buffName then
        if not expirationTime or expirationTime == 0 then
          return true, false, nil
        end

        local remaining = expirationTime - GetTime()

        if not bestRemaining or remaining > bestRemaining then
          bestRemaining = remaining
        end
      end
    end

    if not bestRemaining then
      return false, false, nil
    end

    return true,
      expiringThreshold ~= false and bestRemaining <= expiringThreshold,
      bestRemaining
  end

  aura_env.UnitHasBuff = function(unit)
    local hasBuff = aura_env.UnitBuffInfo(unit)
    return hasBuff
  end

  aura_env.UnitBuffIsOk = function(unit, expiringThreshold)
    local hasBuff, expiringSoon = aura_env.UnitBuffInfo(unit, expiringThreshold)
    return hasBuff and not expiringSoon
  end

  aura_env.FormatRemainingTime = function(seconds)
    if not seconds then
      return ""
    end

    seconds = math.max(0, math.floor(seconds + 0.5))

    if seconds > 60 then
      return string.format("%dm", math.floor(seconds / 60))
    end

    return string.format("%ds", seconds)
  end

  aura_env.UnitClassAllowed = function(unit)
    local class = UnitClassBase(unit)
    return aura_env.classFilter[class] == true
  end

  aura_env.UnitIsBuffable = function(unit)
    return UnitExists(unit)
    and aura_env.UnitClassAllowed(unit)
    and UnitIsVisible(unit)
    and not UnitIsDeadOrGhost(unit)
    and UnitCanAssist("player", unit)
    and (UnitInRange(unit) or unit == "player")
  end

  aura_env.GetMacroUnit = function(unit)
    if unit == "player" then
      return "player"
    end

    local p = unit:match("^party(%d)$")
    if p then
      return "party" .. p
    end

    local r = unit:match("^raid(%d+)$")
    if r then
      return "raid" .. r
    end

    return "player"
  end

  aura_env.playerSubgroup = nil

  aura_env.UpdatePlayerSubgroup = function()
    if not IsInRaid() then
      aura_env.playerSubgroup = nil
      return
    end

    local idx = UnitInRaid("player")
    if not idx then return end

    aura_env.playerSubgroup = select(3, GetRaidRosterInfo(idx))
  end

  aura_env.GetUnitSubgroup = function(unit)
    local idx = UnitInRaid(unit)
    if not idx then return end

    return select(3, GetRaidRosterInfo(idx))
  end

  aura_env.UpdatePlayerSubgroup()

  aura_env.GetNextBuffUnit = function(hasBuff, missingUnits, expiringUnits)
    if aura_env.UnitIsBuffable("player")
    and missingUnits["player"]
    then
      return "player"
    end

    for unit in IterateGroupMembers() do
      if unit ~= "player"
      and aura_env.UnitIsBuffable(unit)
      and missingUnits[unit]
      and aura_env.lastCastUnit ~= unit
      then
        return unit
      end
    end

    if aura_env.UnitIsBuffable("player")
    and expiringUnits["player"]
    then
      return "player"
    end

    for unit in IterateGroupMembers() do
      if unit ~= "player"
      and aura_env.UnitIsBuffable(unit)
      and expiringUnits[unit]
      and aura_env.lastCastUnit ~= unit
      then
        return unit
      end
    end
  end

  aura_env.UpdateButtonUnit = function()
    if not aura_env.button then return end
    if aura_env.UnitAffectingCombat("player") then return end

    local unit = aura_env.currentUnit or "player"
    local macroUnit = aura_env.GetMacroUnit(unit)

    local macro1 = string.format(
      "/cast [@%s,exists,nodead,help] %s",
      macroUnit,
      aura_env.bigSpellName
    )

    local macro2 = string.format(
      "/cast [@%s,exists,nodead,help] %s",
      macroUnit,
      aura_env.smallSpellName
    )

    if aura_env._lastMacroUnit == macroUnit
    and aura_env.button:GetAttribute("macrotext1") == macro1
    and aura_env.button:GetAttribute("macrotext2") == macro2
    then
      return
    end

    aura_env._lastMacroUnit = macroUnit

    aura_env.button:SetAttribute("type", "macro")
    aura_env.button:SetAttribute("type1", "macro")
    aura_env.button:SetAttribute("type2", "macro")

    aura_env.button:SetAttribute("macrotext1", macro1)
    aura_env.button:SetAttribute("macrotext2", macro2)

    Debug(aura_env, "UpdateButtonUnit", "unit=", unit or "nil", "macroUnit=", macroUnit or "nil", "macro1=", macro1, "macro2=", macro2)
  end

  aura_env.BuildPartyStatusText = function(nextUnit, hasBuff)
    if not IsInRaid() then return "" end

    local parts = {}
    local nextGroup = aura_env.GetUnitSubgroup(nextUnit)

    for party = 1, 8 do
      local hasUnit, hasMissing = false, false

      for unit in IterateGroupMembers() do
        if aura_env.GetUnitSubgroup(unit) == party then
          hasUnit = true

          if aura_env.UnitIsBuffable(unit) and not hasBuff[unit] then
            hasMissing = true
            break
          end
        end
      end

      if hasUnit and hasMissing then
        local color = (party == nextGroup) and "|cff66ccff" or "|cffffffff"
        parts[#parts + 1] = color .. party .. "|r"
      end
    end

    return table.concat(parts, ",")
  end
end

function API.Trigger(aura_env, states, event, dismissedAuraID)
  if event == Merfin.REMINDER_SESSION_HIDE_EVENT and dismissedAuraID ~= aura_env.id then
    return false
  end

  if aura_env.sessionHidden then
    states:Remove("")
    return true
  end

  local playerInCombat = aura_env.UnitAffectingCombat("player")
  local inInstance, instanceType = IsInInstance()
  local soloOutsideInstance = not inInstance
    and not IsInRaid()
    and GetPartySize() == 0

  local expiringThreshold = false
  if not playerInCombat then
    if soloOutsideInstance or instanceType == "party" then
      expiringThreshold = aura_env.expiringVerySoonThreshold
    elseif IsInRaid() then
      expiringThreshold = aura_env.expiringSoonThreshold
    end
  end

  if aura_env.lastCastUnit
  and aura_env.UnitBuffIsOk(aura_env.lastCastUnit, expiringThreshold)
  then
    aura_env.lastCastUnit = nil
  end

  local hasBuff = {}
  local missingUnits = {}
  local expiringUnits = {}

  local missingN = 0
  local expiringN = 0
  local expiringMinRemaining

  for unit in IterateGroupMembers() do
    if aura_env.UnitIsBuffable(unit) then
      local hasRealBuff, expiringSoon, remaining = aura_env.UnitBuffInfo(unit, expiringThreshold)
      local buffOk = hasRealBuff and not expiringSoon

      hasBuff[unit] = buffOk

      if not hasRealBuff then
        missingUnits[unit] = true
        missingN = missingN + 1
      elseif expiringSoon then
        expiringUnits[unit] = true
        expiringN = expiringN + 1

        if remaining
        and (not expiringMinRemaining or remaining < expiringMinRemaining)
        then
          expiringMinRemaining = remaining
        end
      end
    end
  end

  if missingN == 0 and expiringN == 0 then
    aura_env.lastCastUnit = nil
    states:Remove("")
    return true
  end

  aura_env.currentUnit = aura_env.GetNextBuffUnit(hasBuff, missingUnits, expiringUnits)

  Debug(aura_env, "Trigger", "currentUnit=", aura_env.currentUnit or "nil", "missingN=", missingN, "expiringN=", expiringN)

  states:Update("", {
    show         = true,
    progressType = "static",
    value        = 1,
    total        = 1,
    unit         = aura_env.currentUnit,
    party        = aura_env.BuildPartyStatusText(aura_env.currentUnit, hasBuff),

    missingN     = missingN,
    expiringN    = expiringN,
    expiringMin  = aura_env.FormatRemainingTime(expiringMinRemaining),
  })

  aura_env.UpdateButtonUnit()
  return true
end

function API.OnShow(aura_env)
  C_Timer.After(0.1, function()
    if not aura_env then return end

    local unit = aura_env.currentUnit or "player"
    local macroUnit = aura_env.GetMacroUnit(unit)

    local macro = string.format(
      "/cast [@%s,exists,nodead,help] %s",
      macroUnit,
      aura_env.bigSpellName
    )

    Merfin.SetCombatHiddenButtonTemplate(
      aura_env,
      nil,
      "macro",
      macro,
      nil,
      true
    )

    aura_env.UpdateButtonUnit()

    if aura_env.button then
      Debug(
        aura_env,
        "OnShow",
        "button=yes",
        "type=", aura_env.button:GetAttribute("type") or "nil",
        "type1=", aura_env.button:GetAttribute("type1") or "nil",
        "type2=", aura_env.button:GetAttribute("type2") or "nil",
        "macrotext1=", aura_env.button:GetAttribute("macrotext1") or "nil",
        "macrotext2=", aura_env.button:GetAttribute("macrotext2") or "nil"
      )
    else
      Debug(aura_env, "OnShow", "button=nil")
    end

    if aura_env.button and not aura_env.button:GetScript("PostClick") then
      aura_env.button:SetScript("PostClick", function(self, button)
        local clickedUnit = aura_env.currentUnit

        Debug(aura_env, "PostClick", "button=", button or "nil", "clickedUnit=", clickedUnit or "nil")

        C_Timer.After(0.1, function()
          if aura_env then
            aura_env.lastCastUnit = clickedUnit
          end
        end)
      end)
    end
  end)
end

Merfin.ExpiringAurasTBC_OnInit = API.OnInit
Merfin.ExpiringAurasTBC_Trigger = API.Trigger
Merfin.ExpiringAurasTBC_OnShow = API.OnShow
