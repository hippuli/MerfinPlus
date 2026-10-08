-- Forever port of TBC.lua's AntiClip; independent of WeakAuras/ForeverAuras.
local function public(value)
  return not (issecretvalue and issecretvalue(value))
end

local function number(value)
  return public(value) and type(value) == "number"
end

-- Filled from the existing Forever channel table (all ranks, including First Aid).
local channelTicks = {
	-- Druid
	[740]	= 5, -- Tranquility (Rank 1)
	[8918]	= 5, -- Tranquility (Rank 2)
	[9862]	= 5, -- Tranquility (Rank 3)
	[9863]	= 5, -- Tranquility (Rank 4)
	[16914]	= 10, -- Hurricane (Rank 1)
	[17401]	= 10, -- Hurricane (Rank 2)
	[17402]	= 10, -- Hurricane (Rank 3)
	-- Hunter
	[1510]	= 6, -- Volley (Rank 1)
	[14294]	= 6, -- Volley (Rank 2)
	[14295]	= 6, -- Volley (Rank 3)
	[136]	= 5, -- Mend Pet (Rank 1)
	[3111]	= 5, -- Mend Pet (Rank 2)
	[3661]	= 5, -- Mend Pet (Rank 3)
	[3662]	= 5, -- Mend Pet (Rank 4)
	[13542]	= 5, -- Mend Pet (Rank 5)
	[13543]	= 5, -- Mend Pet (Rank 6)
	[13544]	= 5, -- Mend Pet (Rank 7)
	-- Mage
	[10]	= 8, -- Blizzard (Rank 1)
	[6141]	= 8, -- Blizzard (Rank 2)
	[8427]	= 8, -- Blizzard (Rank 3)
	[10185]	= 8, -- Blizzard (Rank 4)
	[10186]	= 8, -- Blizzard (Rank 5)
	[10187]	= 8, -- Blizzard (Rank 6)
	[5143]	= 3, -- Arcane Missiles (Rank 1)
	[5144]	= 4, -- Arcane Missiles (Rank 2)
	[5145]	= 5, -- Arcane Missiles (Rank 3)
	[8416]	= 5, -- Arcane Missiles (Rank 4)
	[8417]	= 5, -- Arcane Missiles (Rank 5)
	[10211]	= 5, -- Arcane Missiles (Rank 6)
	[10212]	= 5, -- Arcane Missiles (Rank 7)
	[12051]	= 4, -- Evocation
	-- Priest
	[15407]	= 3, -- Mind Flay (Rank 1)
	[17311]	= 3, -- Mind Flay (Rank 2)
	[17312]	= 3, -- Mind Flay (Rank 3)
	[17313]	= 3, -- Mind Flay (Rank 4)
	[17314]	= 3, -- Mind Flay (Rank 5)
	[18807]	= 3, -- Mind Flay (Rank 6)
	-- Warlock
	[1120]	= 5, -- Drain Soul (Rank 1)
	[8288]	= 5, -- Drain Soul (Rank 2)
	[8289]	= 5, -- Drain Soul (Rank 3)
	[11675]	= 5, -- Drain Soul (Rank 4)
	[755]	= 10, -- Health Funnel (Rank 1)
	[3698]	= 10, -- Health Funnel (Rank 2)
	[3699]	= 10, -- Health Funnel (Rank 3)
	[3700]	= 10, -- Health Funnel (Rank 4)
	[11693]	= 10, -- Health Funnel (Rank 5)
	[11694]	= 10, -- Health Funnel (Rank 6)
	[11695]	= 10, -- Health Funnel (Rank 7)
	[689]	= 5, -- Drain Life (Rank 1)
	[699]	= 5, -- Drain Life (Rank 2)
	[709]	= 5, -- Drain Life (Rank 3)
	[7651]	= 5, -- Drain Life (Rank 4)
	[11699]	= 5, -- Drain Life (Rank 5)
	[11700]	= 5, -- Drain Life (Rank 6)
	[5740]	= 4, -- Rain of Fire (Rank 1)
	[6219]	= 4, -- Rain of Fire (Rank 2)
	[11677]	= 4, -- Rain of Fire (Rank 3)
	[11678]	= 4, -- Rain of Fire (Rank 4)
	[1949]	= 15, -- Hellfire (Rank 1)
	[11683]	= 15, -- Hellfire (Rank 2)
	[11684]	= 15, -- Hellfire (Rank 3)
	[5138]	= 5, -- Drain Mana (Rank 1)
	[6226]	= 5, -- Drain Mana (Rank 2)
	[11703]	= 5, -- Drain Mana (Rank 3)
	[11704]	= 5, -- Drain Mana (Rank 4)
	-- First Aid
	[23567]	= 8, -- Warsong Gulch Runecloth Bandage
	[23696]	= 8, -- Alterac Heavy Runecloth Bandage
	[24414]	= 8, -- Arathi Basin Runecloth Bandage
	[18610]	= 8, -- Heavy Runecloth Bandage
	[18608]	= 8, -- Runecloth Bandage
	[10839]	= 8, -- Heavy Mageweave Bandage
	[10838]	= 8, -- Mageweave Bandage
	[7927]	= 8, -- Heavy Silk Bandage
	[7926]	= 8, -- Silk Bandage
	[3268]	= 7, -- Heavy Wool Bandage
	[3267]	= 7, -- Wool Bandage
	[1159]	= 6, -- Heavy Linen Bandage
	[746]	= 6, -- Linen Bandage
}

-- Return aura data rather than the obsolete UnitAura tuple.
-- Match exact IDs first; the localized name also accepts other ranks, as in TBC.
local function FindPlayerDebuff(unit, spells)
  local ids, names = {}, {}
  for _, spell in ipairs(spells) do
    if type(spell) == "number" then
      ids[spell] = true
      local name = C_Spell.GetSpellName(spell)
      if name then names[name] = true end
    elseif type(spell) == "string" then
      names[spell] = true
    end
  end
  for index = 1, 255 do
    local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, "HARMFUL|PLAYER")
    if not aura then return nil, true end
    if not public(aura.spellId) or not public(aura.name) then return nil, false end
    if ids[aura.spellId] or names[aura.name] then return aura, true end
  end
  return nil, false
end

local function IsSafeToCast(unit, debuffs, isCast)
  if not UnitExists(unit) then return false end
  local aura, readable = FindPlayerDebuff(unit, debuffs)
  if not readable then return false end
  if not aura then return true end
  if not number(aura.expirationTime) then return false end
  if aura.expirationTime == 0 then return false end -- Permanent aura.

  local now = GetTime()
  local remaining = math.max(0, aura.expirationTime - now)
  local castTime = 0
  if isCast then
    local info = C_Spell.GetSpellInfo(aura.spellId or aura.name)
    if not info or not number(info.castTime) then return false end
    castTime = info.castTime / 1000
  end

  local casting, _, _, _, endMS = UnitCastingInfo("player")
  if not public(casting) then return false end
  if casting then
    if not number(endMS) then return false end
    return castTime + math.max(0, endMS / 1000 - now) > remaining
  end

  local channel, _, _, startMS, channelEndMS, _, _, spellID = UnitChannelInfo("player")
  if not public(channel) then return false end
  if channel then
    if not number(startMS) or not number(channelEndMS) then return false end
    local wait = math.max(0, channelEndMS / 1000 - now)
    local ticks = number(spellID) and channelTicks[spellID]
    local duration = (channelEndMS - startMS) / 1000
    if ticks and duration > 0 and wait > 0 then
      local interval = duration / ticks
      wait = wait % interval
      -- At a tick boundary, wait for the following tick instead of reporting zero.
      if wait < 0.000001 then
        wait = math.min(interval, math.max(0, channelEndMS / 1000 - now))
      end
    end
    -- Unknown/non-periodic channels are allowed to finish.
    return castTime + wait > remaining
  end

  local cooldown = C_Spell.GetSpellCooldown(61304)
  if not cooldown or not number(cooldown.startTime) or not number(cooldown.duration) then
    return false
  end
  local gcd = math.max(0, cooldown.startTime + cooldown.duration - now)
  return castTime + gcd > remaining
end

-- Keep the existing public signature used by custom TSU triggers.
Merfin.AnticlipCheck = function(states, unit, debuffs, isCast)
  local show = IsSafeToCast(unit, debuffs, isCast) and true or false
  local state = states[""]
  if not state then
    if not show then return end
    states[""] = { show = true, changed = true }
    return true
  end
  if state.show ~= show then
    state.show = show
    state.changed = true
    return true
  end
end
