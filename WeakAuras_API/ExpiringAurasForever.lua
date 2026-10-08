Merfin = Merfin or {}
Merfin.ExpiringAurasForever = Merfin.ExpiringAurasForever or {}

local API = Merfin.ExpiringAurasForever

local UnitExists          = UnitExists
local UnitIsVisible       = UnitIsVisible
local UnitIsDeadOrGhost   = UnitIsDeadOrGhost
local UnitCanAssist       = UnitCanAssist
local UnitIsUnit          = UnitIsUnit
local UnitInRange         = UnitInRange
local UnitInRaid          = UnitInRaid
local GetNumGroupMembers  = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local GetRaidRosterInfo   = GetRaidRosterInfo
local IsInRaid            = IsInRaid
local IsInInstance        = IsInInstance
local UnitAffectingCombat = UnitAffectingCombat
local GetSpellName        = C_Spell.GetSpellName
local GetTime             = GetTime
local UnitClass           = UnitClass
local UnitClassBase       = UnitClassBase or function(unit)
  local _, classFile = UnitClass(unit)
  return classFile
end

local function Public(value)
  return not (issecretvalue and issecretvalue(value))
end

local function Number(value)
  return Public(value) and type(value) == "number"
end

local function Yes(value)
  return Public(value) and value == true
end

local function UnitRangeAllowsBuff(aura_env, unit)
  if unit == "player" then return true, "self" end
  if C_Spell.IsSpellInRange then
    -- Prefer the single-target buff; group buffs may not have a valid target check.
    local ids = aura_env.buffSpellIds
    local first = ids[2] or ids[1]
    if first then
      local result = C_Spell.IsSpellInRange(first, unit)
      if Public(result) and type(result) == "boolean" then
        return result, "spell", first
      end
    end
    if ids[2] and ids[1] then
      local result = C_Spell.IsSpellInRange(ids[1], unit)
      if Public(result) and type(result) == "boolean" then
        return result, "spell", ids[1]
      end
    end
  end
  local inRange, checked = UnitInRange(unit)
  -- Forever can conceal both results outside combat. Unknown range must not
  -- exclude an otherwise visible ally. Secure casting still enforces range.
  if not Public(inRange) then return true, "unknown" end
  if inRange == true then return true, "unit" end
  if Public(checked) and checked == false then return true, "unknown" end
  if inRange == nil then return true, "unknown" end
  return false, "unit"
end

local function InCombat()
  if InCombatLockdown() then return true end
  local combat = UnitAffectingCombat("player")
  return not Public(combat) or combat == true
end

local pendingShows = setmetatable({}, { __mode = "k" })
local debugUntil, debugInterval, debugGeneration = 0, 5, 0

local function Describe(value)
  if not Public(value) then return "<secret>" end
  if value == nil then return "nil" end
  return tostring(value)
end

local function DebugEnabled(aura_env)
  return GetTime() < debugUntil or aura_env.debugExpiringAurasForever
    or aura_env.debugExpiringAurasTBC
end

-- Enable diagnostics without editing every reminder. Automatically stops.
function API.SetDebug(enabled, seconds, interval)
  debugGeneration = debugGeneration + 1
  debugInterval = Number(interval) and math.max(2, interval) or 5
  debugUntil = enabled and (GetTime() + (Number(seconds) and math.max(1, seconds) or 60)) or 0
  print("Merfin.ExpiringAurasForever: diagnostics", enabled and "ON" or "OFF")
end

-- Verify actual function availability in the running Forever build.
-- This checks API presence, not whether a particular unit's values are public.
function API.CheckCompatibility()
  local required = {
    "UnitExists", "UnitIsVisible", "UnitIsDeadOrGhost", "UnitCanAssist",
    "UnitIsUnit", "UnitInRange", "UnitInRaid", "GetNumGroupMembers",
    "GetNumSubgroupMembers", "GetRaidRosterInfo", "IsInRaid", "IsInInstance",
    "UnitAffectingCombat", "InCombatLockdown", "GetTime", "CreateFrame",
    "issecretvalue", "C_Spell.GetSpellName", "C_UnitAuras.GetAuraDataByIndex",
    "C_Timer.After", "Merfin.AddSessionHideButton", "Merfin.SetCombatHiddenButtonTemplate",
  }
  local function Resolve(path)
    local value = _G
    for key in path:gmatch("[^.]+") do
      if type(value) ~= "table" then return end
      value = value[key]
    end
    return value
  end
  local missing = {}
  for _, name in ipairs(required) do
    if type(Resolve(name)) ~= "function" then missing[#missing + 1] = name end
  end
  if type(_G.UnitClassBase) ~= "function" and type(_G.UnitClass) ~= "function" then
    missing[#missing + 1] = "UnitClassBase / UnitClass"
  end
  local rangeAPI = type(C_Spell.IsSpellInRange) == "function"
  print("Merfin.ExpiringAurasForever: required APIs", #missing == 0 and "OK" or table.concat(missing, ", "))
  print("Merfin.ExpiringAurasForever: C_Spell.IsSpellInRange", rangeAPI and "OK" or "unavailable; using fallback")
  return #missing == 0, missing
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
  if aura_env and DebugEnabled(aura_env) then
    -- Existing FRAME_UPDATE triggers must not print on every update.
    local key = select(1, ...)
    aura_env._debugLogTimes = aura_env._debugLogTimes or {}
    local now = GetTime()
    if aura_env._debugLogTimes[key] and now - aura_env._debugLogTimes[key] < debugInterval then return end
    aura_env._debugLogTimes[key] = now
    print("|cff66ccffExpiringForever [" .. (aura_env.id or "?") .. "]:|r", ...)
  end
end

local function Trace(aura_env, ...)
  print("|cff66ccffExpiringForever [" .. (aura_env.id or "?") .. "]:|r", ...)
end

local function TraceEligibility(aura_env, unit)
  local exists = UnitExists(unit)
  if not Yes(exists) then
    Trace(aura_env, unit, "exists=" .. Describe(exists), "SKIP: unit does not exist")
    return
  end
  local class = UnitClassBase(unit)
  local visible = UnitIsVisible(unit)
  local dead = UnitIsDeadOrGhost(unit)
  local assist = UnitCanAssist("player", unit)
  local inRange, checked = UnitInRange(unit)
  local allowed, rangeSource, rangeSpell = UnitRangeAllowsBuff(aura_env, unit)
  local reason = "OK"
  if not aura_env.UnitClassAllowed(unit) then reason = "SKIP: class filter"
  elseif not Yes(visible) then reason = "SKIP: visibility"
  elseif not Public(dead) or dead then reason = "SKIP: dead/hidden life status"
  elseif not Yes(assist) then reason = "SKIP: cannot assist"
  elseif not allowed then reason = "SKIP: range"
  elseif rangeSource == "unknown" then reason = "OK: range unknown (visible ally included)" end
  Trace(aura_env, unit,
    "class=" .. Describe(class), "visible=" .. Describe(visible),
    "classAllowed=" .. Describe(Public(class) and aura_env.classFilter[class]),
    "dead=" .. Describe(dead), "assist=" .. Describe(assist),
    "range=" .. Describe(inRange), "checked=" .. Describe(checked),
    "rangeSource=" .. rangeSource, "rangeSpell=" .. Describe(rangeSpell),
    "rangeAllowed=" .. Describe(allowed), reason)
end

local function GetRaidSize()
  local count = GetNumGroupMembers()
  return Number(count) and count or 0
end

local function GetPartySize()
  local count = GetNumSubgroupMembers()
  return Number(count) and count or 0
end

local function IterateGroupMembers()
  local index = 0
  local inRaid = IsInRaid()
  local count = inRaid and GetRaidSize() or GetPartySize()
  local playerRaidIndex = inRaid and UnitInRaid("player") or nil
  if not Number(playerRaidIndex) then playerRaidIndex = nil end

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
      local isPlayer
      if playerRaidIndex then
        isPlayer = unitIndex == playerRaidIndex
      else
        isPlayer = Yes(UnitIsUnit(unit, "player"))
      end
      if not isPlayer then
        return unit
      end
    end
  end
end

function API.OnInit(aura_env, showCloseButton)
  aura_env.showCloseButton = showCloseButton == true
  -- OnInit can run again when editing an existing aura.
  if not aura_env.showCloseButton and aura_env.sessionHideButton then
    aura_env.sessionHideButton:Hide()
  end
  aura_env.buffSpellIds = aura_env.buffSpellIds or {}
  aura_env.buffNames = {}
  aura_env.expiringSoonThreshold = aura_env.expiringSoonThreshold or 600
  aura_env.expiringVerySoonThreshold = aura_env.expiringVerySoonThreshold or 60
  aura_env.classFilter = aura_env.classFilter or CopyDefaultClassFilter()

  aura_env.UnitAffectingCombat = function(unit)
    if unit == "player" then return InCombat() end
    return Yes(UnitAffectingCombat(unit))
  end
  aura_env.currentUnit  = nil
  aura_env.lastCastUnit = nil
  aura_env._lastMacroUnit = nil

  aura_env.buffIdLookup = {}
  for _, spellId in ipairs(aura_env.buffSpellIds) do
    aura_env.buffIdLookup[spellId] = true
    local name = GetSpellName(spellId)
    if name then
      aura_env.buffNames[name] = true
    end
  end

  local bigSpellId = aura_env.buffSpellIds[1]
  aura_env.bigSpellName = bigSpellId and GetSpellName(bigSpellId) or nil

  -- With one configured buff (e.g. Thorns), both mouse buttons cast it.
  local smallSpellId = aura_env.buffSpellIds[2] or bigSpellId
  aura_env.smallSpellName = smallSpellId and GetSpellName(smallSpellId) or nil

  Debug(aura_env, "OnInit", "big=", aura_env.bigSpellName or "nil", "small=", aura_env.smallSpellName or "nil")

  aura_env.UnitBuffInfo = function(unit, expiringThreshold)
    if expiringThreshold == nil then
      expiringThreshold = aura_env.expiringSoonThreshold
    end

    local bestRemaining, unknown
    local diagnostics = aura_env._debugScan and {} or nil
    local scanned, hidden = 0, 0
    local now = GetTime()

    -- Match names as well as IDs so all ranks count. Scan the unit once.
    for index = 1, 255 do
      local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, "HELPFUL")
      if not aura then break end
      scanned = scanned + 1
      local idReadable, nameReadable = Public(aura.spellId), Public(aura.name)
      local matches = (idReadable and aura_env.buffIdLookup[aura.spellId])
        or (nameReadable and aura_env.buffNames[aura.name])
      if diagnostics and (scanned <= 8 or matches) then
        diagnostics[#diagnostics + 1] = Describe(aura.spellId) .. ":" .. Describe(aura.name)
          .. (matches and " [MATCH]" or "")
      end
      if matches then
        local expirationTime = aura.expirationTime
        -- Presence is known, but hidden timing cannot safely be compared.
        if not Number(expirationTime) or expirationTime == 0 then
          if diagnostics then
            Trace(aura_env, unit, "BUFF: present, timing=" .. Describe(expirationTime),
              "sample=" .. table.concat(diagnostics, "; "))
          end
          return true, false, nil
        end
        local remaining = math.max(0, expirationTime - now)
        if not bestRemaining or remaining > bestRemaining then
          bestRemaining = remaining
        end
      elseif not idReadable or not nameReadable then
        unknown = true
        hidden = hidden + 1
      end
    end

    -- Do not report a missing/expiring buff when another hidden aura may cover it.
    if diagnostics then
      Trace(aura_env, unit, "scanned=" .. scanned, "hidden=" .. hidden,
        "remaining=" .. Describe(bestRemaining),
        unknown and "BUFF: UNKNOWN (not counted as missing)"
          or (bestRemaining and "BUFF: FOUND" or "BUFF: MISSING"),
        "sample=" .. table.concat(diagnostics, "; "))
    end
    if unknown then return true, false, nil end
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
    if not Number(seconds) then
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
    return Public(class) and aura_env.classFilter[class] == true
  end

  aura_env.UnitIsBuffable = function(unit)
    return Yes(UnitExists(unit))
    and aura_env.UnitClassAllowed(unit)
    and Yes(UnitIsVisible(unit))
    and Public(UnitIsDeadOrGhost(unit)) and not UnitIsDeadOrGhost(unit)
    and Yes(UnitCanAssist("player", unit))
    and UnitRangeAllowsBuff(aura_env, unit)
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
    if not Number(idx) then return end

    local subgroup = select(3, GetRaidRosterInfo(idx))
    aura_env.playerSubgroup = Number(subgroup) and subgroup or nil
  end

  aura_env.GetUnitSubgroup = function(unit)
    if not unit then return end
    local idx = UnitInRaid(unit)
    if not Number(idx) then return end

    local subgroup = select(3, GetRaidRosterInfo(idx))
    return Number(subgroup) and subgroup or nil
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

    -- Retry the previous target if it is the only unit still needing the buff.
    local last = aura_env.lastCastUnit
    if last and (missingUnits[last] or expiringUnits[last])
    and aura_env.UnitIsBuffable(last) then
      return last
    end
  end

  aura_env.UpdateButtonUnit = function()
    if not aura_env.button then return end
    if aura_env.UnitAffectingCombat("player") then return end
    if not aura_env.bigSpellName then return end

    local unit = aura_env.currentUnit or "player"
    local macroUnit = aura_env.GetMacroUnit(unit)

    local macro1 = string.format(
      "/cast [@%s,exists,nodead,help] %s",
      macroUnit,
      aura_env.smallSpellName or aura_env.bigSpellName
    )

    -- Single-spell reminders use the same spell for both mouse buttons.
    local macro2
    if aura_env.bigSpellName then
      macro2 = string.format(
        "/cast [@%s,exists,nodead,help] %s",
        macroUnit,
        aura_env.bigSpellName
      )
    end

    if aura_env._lastMacroUnit == macroUnit
    and aura_env.button:GetAttribute("macrotext1") == macro1
    and aura_env.button:GetAttribute("macrotext2") == macro2
    then
      return
    end

    aura_env._lastMacroUnit = macroUnit

    aura_env.button:SetAttribute("type", "macro")
    aura_env.button:SetAttribute("type1", "macro")
    aura_env.button:SetAttribute("type2", macro2 and "macro" or nil)

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
    aura_env.currentUnit = nil
    pendingShows[aura_env] = nil
    states:Remove("")
    return true
  end

  local now = GetTime()
  local debugScan = DebugEnabled(aura_env) and (
    aura_env._debugGeneration ~= debugGeneration
    or not aura_env._debugLastScan or now - aura_env._debugLastScan >= debugInterval)
  aura_env._debugScan = debugScan and true or false
  if debugScan then
    aura_env._debugGeneration = debugGeneration
    aura_env._debugLastScan = now
    Trace(aura_env, "SCAN", "event=" .. Describe(event),
      "raid=" .. Describe(IsInRaid()), "raidSize=" .. Describe(GetRaidSize()),
      "partySize=" .. Describe(GetPartySize()), "combat=" .. Describe(InCombat()),
      "buffIDs=" .. table.concat(aura_env.buffSpellIds, ","),
      "big=" .. Describe(aura_env.bigSpellName), "small=" .. Describe(aura_env.smallSpellName))
    local probes = {}
    for index = 1, 4 do
      probes[#probes + 1] = "party" .. index .. "=" .. Describe(UnitExists("party" .. index))
    end
    probes[#probes + 1] = "raid1=" .. Describe(UnitExists("raid1"))
    Trace(aura_env, "GROUP PROBE", table.concat(probes, " "))
  end

  aura_env.UpdatePlayerSubgroup()

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
    if debugScan then TraceEligibility(aura_env, unit) end
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

  if debugScan then
    Trace(aura_env, "RESULT", "missing=" .. missingN, "expiring=" .. expiringN,
      "threshold=" .. Describe(expiringThreshold))
  end
  aura_env._debugScan = false

  if missingN == 0 and expiringN == 0 then
    aura_env.currentUnit = nil
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

local function SetupButton(aura_env)
    local region = aura_env.region
    if not region or not region:IsVisible() or aura_env.sessionHidden then return end
    if not aura_env.bigSpellName then return end
    if InCombat() then
      pendingShows[aura_env] = true
      if aura_env.showCloseButton then
        Merfin.AddSessionHideButton(aura_env)
      end
      return
    end
    pendingShows[aura_env] = nil

    local unit = aura_env.currentUnit or "player"
    local macroUnit = aura_env.GetMacroUnit(unit)

    local macro = string.format(
      "/cast [@%s,exists,nodead,help] %s",
      macroUnit,
      aura_env.smallSpellName or aura_env.bigSpellName
    )

    Merfin.SetCombatHiddenButtonTemplate(
      aura_env,
      nil,
      "macro",
      macro,
      nil,
      aura_env.showCloseButton
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

    if aura_env.button then
      aura_env.button:SetScript("PostClick", function(self, button, down)
        if down or InCombat() then return end
        if button ~= "LeftButton" and button ~= "RightButton" then return end
        if button == "RightButton" and not aura_env.bigSpellName then return end
        local clickedUnit = aura_env.currentUnit

        Debug(aura_env, "PostClick", "button=", button or "nil", "clickedUnit=", clickedUnit or "nil")

        C_Timer.After(0.1, function()
          if aura_env and not aura_env.sessionHidden then
            aura_env.lastCastUnit = clickedUnit
          end
        end)
      end)
    end
end

function API.OnShow(aura_env)
  C_Timer.After(0.1, function()
    SetupButton(aura_env)
  end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function()
  for aura_env in pairs(pendingShows) do
    pendingShows[aura_env] = nil
    SetupButton(aura_env)
  end
end)

Merfin.ExpiringAurasForever_OnInit = API.OnInit
Merfin.ExpiringAurasForever_Trigger = API.Trigger
Merfin.ExpiringAurasForever_OnShow = API.OnShow

-- Forever TOC does not load the TBC implementation. Existing reminders can
-- therefore keep their old calls while new reminders use the Forever name.
Merfin.ExpiringAurasTBC = API
Merfin.ExpiringAurasTBC_OnInit = API.OnInit
Merfin.ExpiringAurasTBC_Trigger = API.Trigger
Merfin.ExpiringAurasTBC_OnShow = API.OnShow
