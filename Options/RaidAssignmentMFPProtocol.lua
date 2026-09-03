-- Canonical Raid Assignments clipboard codec and network transport.
--
-- Contract: docs/mfpra-contract.md. MFPRA is the stable canonical clipboard
-- and network protocol. New envelopes have no format-version field. The old
-- MFPRA1 prefix remains receive/import-only so existing exports and addon
-- messages can be migrated without changing SavedVariables in place.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
MerfinPlus.RaidAssignmentStatusUIRevision = "receipt-direction-v3"

local ADDON_PREFIX = "MFPRA" -- C_ChatInfo prefixes are limited to 16 bytes.
local LEGACY_ADDON_PREFIX = "MFPRA1"
local CLIPBOARD_PREFIX = "MFPRA:"
local LEGACY_CLIPBOARD_PREFIX = "MFPRA1:"
local QUICK_CONTEXT_PREFIX = "MFPRAQ:"
local LEGACY_QUICK_CONTEXT_PREFIX = "MFPRAQ1:"
local QUICK_CONTEXT_SCHEMA = "MFPRAQ"
local SCHEMA, EXPANSION = "MFPRA", "tbc"
local EXPANSION_LABEL = "TBC"
local GURTOGG_BOSS_ID = "gurtogg_bloodboil"
local DEFAULT_BLOOD_BOIL_STACK_TARGETS = { 1, 1, 1 }
local CHUNK_BYTES, MAX_CHUNKS = 180, 2048
local LIMITS = {
  base64Bytes = 512 * 1024,
  compressedBytes = 384 * 1024,
  jsonBytes = 2 * 1024 * 1024,
  raids = 8,
  bosses = 64,
  sectionsPerBoss = 128,
  rowsPerSection = 256,
  rowsTotal = 8192,
  plans = 32,
  textBytes = 4096,
}

local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local BASE64_VALUES = {}
for index = 1, #BASE64_ALPHABET do
  BASE64_VALUES[BASE64_ALPHABET:sub(index, index)] = index - 1
end

local function DeepCopy(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}
  if seen[value] then return seen[value] end
  local copy = {}
  seen[value] = copy
  for key, child in pairs(value) do copy[DeepCopy(key, seen)] = DeepCopy(child, seen) end
  return copy
end

local function Trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function Normalize(value)
  local normalized = tostring(value or ""):lower():gsub("[%s%p%c]+", "")
  return normalized
end

local function CleanPlayerName(value)
  local name = tostring(value or "")
  local dash = name:find("-", 1, true)
  return dash and name:sub(1, dash - 1) or name
end

local function IsDenseArray(value, maximum)
  if type(value) ~= "table" then return nil end
  local length = #value
  if maximum and length > maximum then return nil end
  for key in pairs(value) do
    if type(key) ~= "number" or key < 1 or key > length or key % 1 ~= 0 then return nil end
  end
  return length
end

local function IsText(value, maximum, required)
  return type(value) == "string" and (not required or value ~= "") and (not maximum or #value <= maximum)
end

local function IsRevision(value)
  return type(value) == "number" and value == value and value % 1 == 0 and value >= 1 and value <= 9007199254740991
end

local function GetLibDeflate()
  return (LibStub and LibStub("LibDeflate", true)) or _G.LibDeflate
end

local function EncodeCanonicalJSON(value)
  if type(value) ~= "table" then return MerfinPlusJSON.encode(value) end
  local count, maximum, isArray = 0, 0, true
  for key in pairs(value) do
    count = count + 1
    if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then isArray = false
    else maximum = math.max(maximum, key) end
  end
  if isArray and maximum == count then
    local output = {}
    for index = 1, maximum do output[index] = EncodeCanonicalJSON(value[index]) end
    return "[" .. table.concat(output, ",") .. "]"
  end
  local keys = {}
  for key in pairs(value) do
    if type(key) ~= "string" then error("MFPRA JSON objects require string keys.") end
    keys[#keys + 1] = key
  end
  table.sort(keys)
  local fields = {}
  for index, key in ipairs(keys) do
    fields[index] = MerfinPlusJSON.encode(key) .. ":" .. EncodeCanonicalJSON(value[key])
  end
  return "{" .. table.concat(fields, ",") .. "}"
end

local function EncodeBase64(value)
  local output = {}
  for index = 1, #value, 3 do
    local first, second, third = value:byte(index, index + 2)
    local combined = first * 65536 + (second or 0) * 256 + (third or 0)
    local a = math.floor(combined / 262144) % 64
    local b = math.floor(combined / 4096) % 64
    local c = math.floor(combined / 64) % 64
    local d = combined % 64
    output[#output + 1] = BASE64_ALPHABET:sub(a + 1, a + 1)
    output[#output + 1] = BASE64_ALPHABET:sub(b + 1, b + 1)
    output[#output + 1] = second and BASE64_ALPHABET:sub(c + 1, c + 1) or "="
    output[#output + 1] = third and BASE64_ALPHABET:sub(d + 1, d + 1) or "="
  end
  return table.concat(output)
end

local function DecodeBase64(value)
  if value == "" or #value % 4 ~= 0 then return nil, "MFPRA payload is not valid padded Base64." end
  local output = {}
  for index = 1, #value, 4 do
    local c1, c2, c3, c4 = value:sub(index, index), value:sub(index + 1, index + 1), value:sub(index + 2, index + 2), value:sub(index + 3, index + 3)
    local v1, v2 = BASE64_VALUES[c1], BASE64_VALUES[c2]
    local v3, v4 = c3 == "=" and nil or BASE64_VALUES[c3], c4 == "=" and nil or BASE64_VALUES[c4]
    local final = index + 3 == #value
    if v1 == nil or v2 == nil or (c3 ~= "=" and v3 == nil) or (c4 ~= "=" and v4 == nil)
      or (c3 == "=" and c4 ~= "=") or ((c3 == "=" or c4 == "=") and not final)
    then return nil, "MFPRA payload contains invalid Base64 characters or padding." end
    output[#output + 1] = string.char(math.floor(v1 * 4 + v2 / 16))
    if c3 ~= "=" then output[#output + 1] = string.char((v2 % 16) * 16 + math.floor(v3 / 4)) end
    if c4 ~= "=" then output[#output + 1] = string.char((v3 % 4) * 64 + v4) end
  end
  return table.concat(output)
end

local function AdlerHex(value)
  local library = GetLibDeflate()
  if not library or type(library.Adler32) ~= "function" then return nil end
  return string.format("%08x", library:Adler32(value))
end

local ROOT_FIELDS = { s = true, v = true, k = true, r = true, h = true, x = true, g = true, a = true, p = true, b = true, i = true, c = true }
local ASSIGNMENT_FIELDS = { c = true, rs = true, bs = true, pg = true }
local RAID_FIELDS = { i = true, n = true, c = true }
local BOSS_FIELDS = {
  i = true, n = true, q = true, t = true, s = true,
  tg = true, ta = true, tm = true, bb = true,
}
local SECTION_FIELDS = { n = true, o = true, k = true, c = true, w = true }
local PRE_BOSS_FIELDS = { i = true, g = true }
local CONTEXT_FIELDS = { t = true, r = true, b = true, p = true }
local ROW_FIELDS = {
  a = true, d = true, n = true, c = true, s = true, k = true, r = true, i = true,
  m = true, tc = true, ts = true, tn = true, tcs = true, tss = true, l = true, p = true, tk = true, t = true,
  g = true, u = true, bn = true, bi = true, wn = true, wi = true,
  an = true, ai = true, ae = true, cn = true, ci = true, ce = true,
  x = true, v = true,
}
local SECTION_KINDS = {
  ["trash-role"] = true, role = true, position = true, class = true,
  buff = true, additional = true, utility = true,
}
local ROW_KINDS = {
  role = true, position = true, class = true, buff = true,
  additional = true, utility = true,
}
local TARGET_KINDS = {
  player = true, groups = true, worldmarker = true, role = true,
  position = true, state = true, text = true, none = true,
}
local ASSIGNMENT_ROLES = {
  tank = true, heal = true, melee = true, ranged = true, raid = true,
}
local RAID_MARKERS = {
  star = true, circle = true, diamond = true, triangle = true,
  moon = true, square = true, cross = true, skull = true,
}
local ADDITIONAL_VISIBILITY = { assignee = true }

local function IsIconToken(value)
  return type(value) == "string"
    and (value:match("^spell:[1-9][0-9]*$") ~= nil
      or value:match("^icon:[a-z0-9_]+$") ~= nil)
end

local function ValidateGroupSet(value, label)
  if value == nil then return true end
  local count = IsDenseArray(value, 8)
  if not count or count < 1 then return nil, label .. " must be a non-empty dense array." end
  local previous = 0
  for index, group in ipairs(value) do
    if type(group) ~= "number" or group % 1 ~= 0 or group < 1 or group > 8 or group <= previous then
      return nil, label .. " must contain unique ascending group numbers from 1 to 8."
    end
    previous = group
  end
  return true
end

local function ValidateTextList(value, label)
  if value == nil then return 0 end
  local count = IsDenseArray(value, 40)
  if not count or count < 1 then return nil, label .. " must be a non-empty dense array." end
  for index, item in ipairs(value) do
    if not IsText(item, LIMITS.textBytes, true) then
      return nil, label .. "[" .. index .. "] must be non-empty text."
    end
  end
  return count
end

local function RejectUnknown(value, allowed, label)
  if type(value) ~= "table" then return nil, label .. " must be an object." end
  for key in pairs(value) do
    if type(key) ~= "string" or not allowed[key] then return nil, label .. "." .. tostring(key) .. " is unsupported." end
  end
  return true
end

local function ValidatePreBossGroups(value, label)
  if value == nil then return true end
  local bossCount = IsDenseArray(value, LIMITS.bosses)
  if not bossCount or bossCount < 1 then
    return nil, label .. " must be a non-empty dense boss array."
  end
  local seenBosses = {}
  for bossIndex, boss in ipairs(value) do
    local bossLabel = label .. "[" .. bossIndex .. "]"
    local ok, errorText = RejectUnknown(boss, PRE_BOSS_FIELDS, bossLabel)
    if not ok then return nil, errorText end
    if not IsText(boss.i, 180, true) or not boss.i:match("^t6_[a-z0-9_]+$") then
      return nil, bossLabel .. ".i must be a canonical T6 Pre-Boss id."
    end
    local bossKey = Normalize(boss.i)
    if seenBosses[bossKey] then return nil, bossLabel .. ".i is duplicated." end
    seenBosses[bossKey] = true

    local groupCount = IsDenseArray(boss.g, 8)
    if not groupCount or groupCount < 1 then
      return nil, bossLabel .. ".g must contain one to eight dense raid groups."
    end
    local assignedNames = {}
    for groupIndex, group in ipairs(boss.g) do
      local groupLabel = bossLabel .. ".g[" .. groupIndex .. "]"
      local slotCount = IsDenseArray(group, 5)
      if slotCount ~= 5 then return nil, groupLabel .. " must contain exactly five slots." end
      for slotIndex, playerName in ipairs(group) do
        if not IsText(playerName, LIMITS.textBytes, false) then
          return nil, groupLabel .. "[" .. slotIndex .. "] must be text."
        end
        local playerKey = Normalize(playerName)
        if playerKey ~= "" and assignedNames[playerKey] then
          return nil, bossLabel .. " assigns " .. playerName .. " more than once."
        end
        if playerKey ~= "" then assignedNames[playerKey] = true end
      end
    end
  end
  return true
end

local function ValidateBloodBoilStackTargets(value, label)
  if value == nil then return true end
  local count = IsDenseArray(value, 3)
  if count ~= 3 then return nil, label .. " must be a dense [star, diamond, circle] array." end
  for _, target in ipairs(value) do
    if type(target) ~= "number" or target % 1 ~= 0 or target < 1 or target > 10 then
      return nil, label .. " values must be integers from 1 to 10."
    end
  end
  return true
end

local function ValidateAssignments(assignments, kind, groupID)
  local ok, errorText = RejectUnknown(assignments, ASSIGNMENT_FIELDS, "a")
  if not ok then return nil, errorText end
  if not IsText(assignments.c or "", 128, false) then return nil, "a.c must be text." end
  if kind ~= "F" and assignments.pg ~= nil then return nil, "a.pg is supported only in full snapshots." end
  ok, errorText = ValidatePreBossGroups(assignments.pg, "a.pg")
  if not ok then return nil, errorText end
  local raidCount = IsDenseArray(assignments.rs, LIMITS.raids)
  local bossCount = IsDenseArray(assignments.bs, kind == "D" and 1 or LIMITS.bosses)
  if not raidCount or raidCount < 1 then return nil, "a.rs must contain one or more raids." end
  if not bossCount or bossCount < 1 then return nil, "a.bs must contain one or more bosses." end
  local raidIDs = {}
  for index, raid in ipairs(assignments.rs) do
    ok, errorText = RejectUnknown(raid, RAID_FIELDS, "a.rs[" .. index .. "]")
    if not ok then return nil, errorText end
    if not IsText(raid.i, 128, true) or not IsText(raid.n, 128, true) or not IsText(raid.c or "", 128, false) then
      return nil, "a.rs[" .. index .. "] has invalid id, name, or comp text."
    end
    raidIDs[Normalize(raid.i)] = true
  end
  local rowsTotal = 0
  for bossIndex, boss in ipairs(assignments.bs) do
    local label = "a.bs[" .. bossIndex .. "]"
    ok, errorText = RejectUnknown(boss, BOSS_FIELDS, label)
    if not ok then return nil, errorText end
    if not IsText(boss.i, 128, true) or not IsText(boss.n, 128, true) or not IsText(boss.q, 128, true) or (boss.t ~= nil and type(boss.t) ~= "boolean") then
      return nil, label .. " has invalid identity fields."
    end
    ok, errorText = ValidateBloodBoilStackTargets(boss.bb, label .. ".bb")
    if not ok then return nil, errorText end
    if boss.bb ~= nil and Normalize(boss.i) ~= Normalize(GURTOGG_BOSS_ID) then
      return nil, label .. ".bb is supported only for Gurtogg Bloodboil."
    end
    if not raidIDs[Normalize(boss.q)] then return nil, label .. ".q does not identify an a.rs raid." end
    local hasSharedTrash = boss.tg ~= nil or boss.ta ~= nil or boss.tm ~= nil
    if hasSharedTrash then
      if boss.t ~= true or not IsText(boss.tg, 128, true) or not IsText(boss.ta, 128, true) then
        return nil, label .. " shared Trash metadata requires t=true, tg, and ta."
      end
      local memberCount = IsDenseArray(boss.tm, LIMITS.raids)
      if not memberCount or memberCount < 2 then return nil, label .. ".tm must contain at least two ordered raid ids." end
      if Normalize(boss.tg) ~= Normalize(groupID) or Normalize(boss.ta) ~= Normalize(boss.q) then
        return nil, label .. " shared Trash group/anchor does not match root g and q."
      end
      if memberCount ~= #assignments.rs then return nil, label .. ".tm must match the ordered a.rs raids." end
      for memberIndex, member in ipairs(boss.tm) do
        if not IsText(member, 128, true) or Normalize(member) ~= Normalize(assignments.rs[memberIndex].i) then
          return nil, label .. ".tm must match the ordered a.rs raid ids."
        end
      end
    elseif boss.t ~= true and (boss.tg ~= nil or boss.ta ~= nil or boss.tm ~= nil) then
      return nil, label .. " non-Trash bosses cannot define shared Trash metadata."
    end
    local sectionCount = IsDenseArray(boss.s, LIMITS.sectionsPerBoss)
    local configOnlyGurtogg = boss.bb ~= nil and Normalize(boss.i) == Normalize(GURTOGG_BOSS_ID)
    if not sectionCount or (sectionCount < 1 and not configOnlyGurtogg) then
      return nil, label .. ".s must contain sections unless this is a valid Gurtogg Bloodboil configuration."
    end
    for sectionIndex, section in ipairs(boss.s) do
      local sectionLabel = label .. ".s[" .. sectionIndex .. "]"
      ok, errorText = RejectUnknown(section, SECTION_FIELDS, sectionLabel)
      if not ok then return nil, errorText end
      if not IsText(section.n, 256, true) or not IsText(section.o or "", 256, false) then return nil, sectionLabel .. " has invalid text." end
      ok, errorText = RejectUnknown(section.c, CONTEXT_FIELDS, sectionLabel .. ".c")
      if not ok then return nil, errorText end
      if section.k ~= nil and not SECTION_KINDS[section.k] then return nil, sectionLabel .. ".k is unsupported." end
      for _, field in ipairs({ "t", "r", "b", "p" }) do
        if not IsText(section.c[field] or "", 256, false) then return nil, sectionLabel .. ".c." .. field .. " must be text." end
      end
      local rowCount = IsDenseArray(section.w, LIMITS.rowsPerSection)
      if not rowCount or rowCount < 1 then return nil, sectionLabel .. ".w must contain rows." end
      rowsTotal = rowsTotal + rowCount
      if rowsTotal > LIMITS.rowsTotal then return nil, "Assignment rows exceed " .. LIMITS.rowsTotal .. "." end
      for rowIndex, row in ipairs(section.w) do
        local rowLabel = sectionLabel .. ".w[" .. rowIndex .. "]"
        ok, errorText = RejectUnknown(row, ROW_FIELDS, rowLabel)
        if not ok then return nil, errorText end
        for field, value in pairs(row) do
          if field ~= "g" and field ~= "tn" and field ~= "tcs" and field ~= "tss" and field ~= "ae" and field ~= "ce"
            and not IsText(value, LIMITS.textBytes, field == "a" or field == "n")
          then
            return nil, rowLabel .. "." .. field .. " must be text."
          end
        end
        if row.ae ~= nil and type(row.ae) ~= "boolean" then return nil, rowLabel .. ".ae must be boolean." end
        if row.ce ~= nil and type(row.ce) ~= "boolean" then return nil, rowLabel .. ".ce must be boolean." end
        if row.k ~= nil and not ROW_KINDS[row.k] then return nil, rowLabel .. ".k is unsupported." end
        if row.r ~= nil and not ASSIGNMENT_ROLES[row.r] then return nil, rowLabel .. ".r is unsupported." end
        if row.tk ~= nil and not TARGET_KINDS[row.tk] then return nil, rowLabel .. ".tk is unsupported." end
        if row.m ~= nil and not RAID_MARKERS[Normalize(row.m)] then return nil, rowLabel .. ".m is unsupported." end
        ok, errorText = ValidateGroupSet(row.g, rowLabel .. ".g")
        if not ok then return nil, errorText end
        local targetNameCount
        targetNameCount, errorText = ValidateTextList(row.tn, rowLabel .. ".tn")
        if targetNameCount == nil then return nil, errorText end
        local targetClassCount
        targetClassCount, errorText = ValidateTextList(row.tcs, rowLabel .. ".tcs")
        if targetClassCount == nil then return nil, errorText end
        local targetSpecCount
        targetSpecCount, errorText = ValidateTextList(row.tss, rowLabel .. ".tss")
        if targetSpecCount == nil then return nil, errorText end
        if targetNameCount > 0 and ((targetClassCount > 0 and targetClassCount ~= targetNameCount) or (targetSpecCount > 0 and targetSpecCount ~= targetNameCount)) then
          return nil, rowLabel .. " multi-target metadata lengths must match."
        end
        if row.tk == "groups" and row.g == nil then return nil, rowLabel .. ".g is required for a groups target." end
        if row.tk == "worldmarker" and row.m == nil then return nil, rowLabel .. ".m is required for a worldmarker target." end
        if row.tk == "player" and not IsText(row.t, LIMITS.textBytes, true) then return nil, rowLabel .. ".t is required for a player target." end
        if row.k == "additional" then
          if not IsText(row.i, 256, true) then return nil, rowLabel .. ".i is required for an additional assignment." end
          if row.v ~= "assignee" or not ADDITIONAL_VISIBILITY[row.v] then return nil, rowLabel .. ".v must be assignee." end
          if not IsText(row.bn or row.wn or row.an or row.cn or row.x, LIMITS.textBytes, true) then
            return nil, rowLabel .. " requires boss/custom what, ability, cooldown, or custom cooldown text."
          end
          for _, iconField in ipairs({ "bi", "wi", "ai", "ci" }) do
            if row[iconField] ~= nil and not IsIconToken(row[iconField]) then
              return nil, rowLabel .. "." .. iconField .. " is not a canonical icon token."
            end
          end
        else
          if row.bn ~= nil or row.bi ~= nil then
            if row.k ~= "utility" then
              return nil, rowLabel .. " uses boss-spell fields outside k=additional or k=utility."
            end
            if not IsText(row.bn, LIMITS.textBytes, true) then
              return nil, rowLabel .. ".bn must identify the utility boss spell."
            end
            if row.bi ~= nil and not IsIconToken(row.bi) then
              return nil, rowLabel .. ".bi is not a canonical icon token."
            end
          end
          if row.i ~= nil or row.wn ~= nil or row.wi ~= nil
            or row.an ~= nil or row.ai ~= nil or row.ae ~= nil or row.cn ~= nil or row.ci ~= nil
            or row.ce ~= nil or row.x ~= nil or row.v ~= nil
          then
            return nil, rowLabel .. " uses Additional-only fields outside k=additional."
          end
        end
      end
    end
  end
  return rowsTotal
end

local function ValidatePlans(owner, payload)
  local plans, catalogVersion
  if payload.k == "F" then
    if type(payload.p) ~= "table" then return nil, "p must be an object." end
    for key in pairs(payload.p) do if key ~= "c" and key ~= "l" then return nil, "p." .. tostring(key) .. " is unsupported." end end
    catalogVersion, plans = payload.p.c, payload.p.l
  elseif payload.k == "P" then
    catalogVersion, plans = payload.c, { payload.p }
  else
    return true
  end
  if catalogVersion ~= 1 then return nil, "Boss Plan catalog version must be 1." end
  local count = IsDenseArray(plans, LIMITS.plans)
  if not count then return nil, "Boss Plans must be a dense array." end
  local compatibility = {
    schema = "MGMRA", version = 4, catalogVersion = 1, expansion = EXPANSION,
    raidGroup = payload.g, comp = { name = (payload.a and payload.a.c ~= "" and payload.a.c) or "MFPRA" },
    legacyAssignments = "MGMRA|3\n", plans = plans,
  }
  local valid, validationError = owner:ValidateMGMRA4Payload(compatibility)
  if not valid then return nil, validationError end
  return true
end

local function ValidatePayload(owner, payload)
  local ok, errorText = RejectUnknown(payload, ROOT_FIELDS, "root")
  if not ok then return nil, errorText end
  if payload.s ~= SCHEMA or payload.x ~= EXPANSION then
    return nil, "Unsupported MFPRA schema or expansion."
  end
  if payload.v ~= nil and payload.v ~= 1 and payload.v ~= 2 then return nil, "Unsupported legacy MFPRA envelope version." end
  if payload.k ~= "F" and payload.k ~= "D" and payload.k ~= "P" then return nil, "k must be F, D, or P." end
  if not IsRevision(payload.r) then return nil, "r must be a positive integer revision." end
  if not IsText(payload.g, 128, true) then return nil, "g must identify a raid group." end
  if payload.h ~= nil and (type(payload.h) ~= "string" or not payload.h:match("^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$")) then return nil, "h must be an eight-digit lowercase Adler-32 value." end
  if payload.k == "F" then
    if payload.a == nil or payload.p == nil or payload.b ~= nil or payload.i ~= nil or payload.c ~= nil then
      return nil, "Full snapshots require only a and p kind-specific fields."
    end
  elseif payload.k == "D" then
    if payload.a == nil or payload.b == nil or payload.p ~= nil or payload.i ~= nil or payload.c ~= nil then
      return nil, "Boss deltas require only a and b kind-specific fields; Boss Plans are forbidden."
    end
  else
    if payload.a ~= nil or payload.b == nil or payload.i == nil or payload.c == nil or payload.p == nil then
      return nil, "Plan deltas require only b, i, c, and p kind-specific fields."
    end
  end
  if payload.k == "F" or payload.k == "D" then
    local rows
    rows, errorText = ValidateAssignments(payload.a, payload.k, payload.g)
    if not rows then return nil, errorText end
    if payload.k == "D" and (not IsText(payload.b, 128, true) or Normalize(payload.b) ~= Normalize(payload.a.bs[1].i)) then
      return nil, "Boss delta b must match its single boss id."
    end
  else
    if not IsText(payload.b, 180, true) or not IsText(payload.i, 180, true) then return nil, "Plan delta requires b and i." end
    if not payload.i:match("^[a-z0-9._%-]+$") or not payload.b:match("^[a-z0-9._%-]+$") then return nil, "Plan delta ids are not canonical." end
  end
  ok, errorText = ValidatePlans(owner, payload)
  if not ok then return nil, errorText end
  return payload
end

function MerfinPlus:IsCanonicalRaidAssignmentEnvelope(raw)
  return type(raw) == "string" and (raw:sub(1, #CLIPBOARD_PREFIX) == CLIPBOARD_PREFIX
    or raw:sub(1, #LEGACY_CLIPBOARD_PREFIX) == LEGACY_CLIPBOARD_PREFIX)
end

function MerfinPlus:GetCanonicalRaidAssignmentContract()
  return {
    prefix = ADDON_PREFIX, clipboardPrefix = CLIPBOARD_PREFIX, schema = SCHEMA,
    legacyPrefix = LEGACY_ADDON_PREFIX, legacyClipboardPrefix = LEGACY_CLIPBOARD_PREFIX,
    chunkBytes = CHUNK_BYTES, limits = LIMITS,
  }
end

function MerfinPlus:EncodeCanonicalRaidAssignmentEnvelope(payload)
  local candidate = DeepCopy(payload)
  candidate.h = nil
  candidate.v = nil
  local valid, errorText = ValidatePayload(self, candidate)
  if not valid then return nil, errorText end
  local ok, hashSource = pcall(EncodeCanonicalJSON, candidate)
  if not ok then return nil, "MFPRA JSON encoding failed." end
  candidate.h = AdlerHex(hashSource)
  if not candidate.h then return nil, "MFPRA requires LibDeflate Adler32 support." end
  local jsonOK, json = pcall(EncodeCanonicalJSON, candidate)
  if not jsonOK or #json > LIMITS.jsonBytes then return nil, "MFPRA JSON exceeds its limit." end
  local library = GetLibDeflate()
  if not library or type(library.CompressZlib) ~= "function" then return nil, "MFPRA requires LibDeflate CompressZlib support." end
  local compressedOK, compressed = pcall(library.CompressZlib, library, json, { level = 9 })
  if not compressedOK or type(compressed) ~= "string" or #compressed > LIMITS.compressedBytes then return nil, "MFPRA zlib compression failed or exceeds its limit." end
  local envelope = CLIPBOARD_PREFIX .. EncodeBase64(compressed)
  if #envelope - #CLIPBOARD_PREFIX > LIMITS.base64Bytes then return nil, "MFPRA Base64 exceeds its limit." end
  return envelope, candidate
end

function MerfinPlus:DecodeCanonicalRaidAssignmentEnvelope(raw)
  local prefix
  if type(raw) == "string" and raw:sub(1, #CLIPBOARD_PREFIX) == CLIPBOARD_PREFIX then
    prefix = CLIPBOARD_PREFIX
  elseif type(raw) == "string" and raw:sub(1, #LEGACY_CLIPBOARD_PREFIX) == LEGACY_CLIPBOARD_PREFIX then
    prefix = LEGACY_CLIPBOARD_PREFIX
  else
    return nil, "Unsupported Raid Assignments format. Paste an MFPRA: export from the Guild Manager. Existing MFPRA1: exports remain importable; MGMRA clipboard strings are not accepted."
  end
  local encoded = raw:sub(#prefix + 1)
  if #encoded > LIMITS.base64Bytes then return nil, "MFPRA Base64 exceeds its limit." end
  local compressed, decodeError = DecodeBase64(encoded)
  if not compressed then return nil, decodeError end
  if #compressed > LIMITS.compressedBytes then return nil, "MFPRA compressed payload exceeds its limit." end
  local library = GetLibDeflate()
  if not library or type(library.DecompressZlib) ~= "function" then return nil, "MFPRA requires LibDeflate DecompressZlib support." end
  local ok, json = pcall(library.DecompressZlib, library, compressed)
  if not ok or type(json) ~= "string" or #json > LIMITS.jsonBytes then return nil, "MFPRA zlib decompression failed or exceeds its limit." end
  if not self:IsValidRaidAssignmentUTF8(json) then return nil, "MFPRA JSON is not valid UTF-8." end
  if not MerfinPlusJSON or type(MerfinPlusJSON.decode) ~= "function" then return nil, "MFPRA JSON decoder is unavailable." end
  local jsonOK, payload = pcall(MerfinPlusJSON.decode, json)
  if not jsonOK then return nil, "MFPRA JSON is invalid." end
  if prefix == CLIPBOARD_PREFIX and payload.v ~= nil then return nil, "MFPRA envelopes must not contain a format-version field." end
  if prefix == LEGACY_CLIPBOARD_PREFIX and payload.v ~= 1 and payload.v ~= 2 then return nil, "Legacy MFPRA1 envelopes require version 1 or 2." end
  local valid, validationError = ValidatePayload(self, payload)
  if not valid then return nil, validationError end
  if not payload.h then return nil, "MFPRA semantic hash is missing." end
  local expected = payload.h
  local hashPayload = DeepCopy(payload)
  hashPayload.h = nil
  local canonicalOK, canonical = pcall(EncodeCanonicalJSON, hashPayload)
  if not canonicalOK or AdlerHex(canonical) ~= expected then return nil, "MFPRA semantic hash mismatch." end
  payload.v = nil
  return payload
end

local QUICK_CONTEXT_FIELDS = {
  s = true, v = true, k = true, r = true, h = true, x = true,
  g = true, b = true, p = true,
}

local function ValidateQuickPlanContextPayload(owner, payload)
  local ok, errorText = RejectUnknown(payload, QUICK_CONTEXT_FIELDS, "quick")
  if not ok then return nil, errorText end
  if payload.s ~= QUICK_CONTEXT_SCHEMA or payload.k ~= "C" or payload.x ~= EXPANSION then
    return nil, "Unsupported scoped Boss Plan context schema, kind, or expansion."
  end
  if payload.v ~= nil and payload.v ~= 1 then return nil, "Unsupported legacy scoped Boss Plan context version." end
  if not IsRevision(payload.r) then return nil, "Scoped Boss Plan context revision must be positive." end
  if not IsText(payload.g, 128, true) or not IsText(payload.b, 128, true) then
    return nil, "Scoped Boss Plan context requires a raid group and boss id."
  end
  if payload.h ~= nil and (type(payload.h) ~= "string" or not payload.h:match("^[0-9a-f]+$") or #payload.h ~= 8) then
    return nil, "Scoped Boss Plan context hash must be eight lowercase hexadecimal digits."
  end
  if type(payload.p) ~= "table" then return nil, "Scoped Boss Plan context plans must be an object." end
  for key in pairs(payload.p) do
    if key ~= "c" and key ~= "l" then return nil, "Scoped Boss Plan context plans contain an unsupported field." end
  end
  if payload.p.c ~= 1 then return nil, "Scoped Boss Plan context catalog version must be 1." end
  local count = IsDenseArray(payload.p.l, LIMITS.plans)
  if count == nil then return nil, "Scoped Boss Plan context plans must be a dense array." end
  local compatibility = {
    schema = "MGMRA", version = 4, catalogVersion = 1, expansion = EXPANSION,
    raidGroup = payload.g, comp = { name = "MFPRA" },
    legacyAssignments = "MGMRA|3\n", plans = payload.p.l,
  }
  local valid, validationError = owner:ValidateMGMRA4Payload(compatibility)
  if not valid then return nil, validationError end
  return payload
end

function MerfinPlus:EncodeRaidAssignmentQuickPlanContext(payload)
  local candidate = DeepCopy(payload)
  candidate.h = nil
  candidate.v = nil
  local valid, errorText = ValidateQuickPlanContextPayload(self, candidate)
  if not valid then return nil, errorText end
  local hashOK, hashSource = pcall(EncodeCanonicalJSON, candidate)
  if not hashOK then return nil, "Scoped Boss Plan context JSON encoding failed." end
  candidate.h = AdlerHex(hashSource)
  if not candidate.h then return nil, "Scoped Boss Plan context requires LibDeflate Adler32 support." end
  local jsonOK, json = pcall(EncodeCanonicalJSON, candidate)
  if not jsonOK or #json > LIMITS.jsonBytes then return nil, "Scoped Boss Plan context JSON exceeds its limit." end
  local library = GetLibDeflate()
  if not library or type(library.CompressZlib) ~= "function" then
    return nil, "Scoped Boss Plan context requires LibDeflate CompressZlib support."
  end
  local compressedOK, compressed = pcall(library.CompressZlib, library, json, { level = 9 })
  if not compressedOK or type(compressed) ~= "string" or #compressed > LIMITS.compressedBytes then
    return nil, "Scoped Boss Plan context compression failed or exceeds its limit."
  end
  local envelope = QUICK_CONTEXT_PREFIX .. EncodeBase64(compressed)
  if #envelope - #QUICK_CONTEXT_PREFIX > LIMITS.base64Bytes then
    return nil, "Scoped Boss Plan context Base64 exceeds its limit."
  end
  return envelope, candidate
end

function MerfinPlus:DecodeRaidAssignmentQuickPlanContext(raw)
  local prefix
  if type(raw) == "string" and raw:sub(1, #QUICK_CONTEXT_PREFIX) == QUICK_CONTEXT_PREFIX then
    prefix = QUICK_CONTEXT_PREFIX
  elseif type(raw) == "string" and raw:sub(1, #LEGACY_QUICK_CONTEXT_PREFIX) == LEGACY_QUICK_CONTEXT_PREFIX then
    prefix = LEGACY_QUICK_CONTEXT_PREFIX
  else
    return nil, "Expected an MFPRAQ scoped Boss Plan context."
  end
  local encoded = raw:sub(#prefix + 1)
  if #encoded > LIMITS.base64Bytes then return nil, "Scoped Boss Plan context Base64 exceeds its limit." end
  local compressed, decodeError = DecodeBase64(encoded)
  if not compressed then return nil, decodeError end
  if #compressed > LIMITS.compressedBytes then return nil, "Scoped Boss Plan context compressed payload exceeds its limit." end
  local library = GetLibDeflate()
  if not library or type(library.DecompressZlib) ~= "function" then
    return nil, "Scoped Boss Plan context requires LibDeflate DecompressZlib support."
  end
  local ok, json = pcall(library.DecompressZlib, library, compressed)
  if not ok or type(json) ~= "string" or #json > LIMITS.jsonBytes then
    return nil, "Scoped Boss Plan context decompression failed or exceeds its limit."
  end
  if not self:IsValidRaidAssignmentUTF8(json) then return nil, "Scoped Boss Plan context JSON is not valid UTF-8." end
  if not MerfinPlusJSON or type(MerfinPlusJSON.decode) ~= "function" then
    return nil, "Scoped Boss Plan context JSON decoder is unavailable."
  end
  local jsonOK, payload = pcall(MerfinPlusJSON.decode, json)
  if not jsonOK then return nil, "Scoped Boss Plan context JSON is invalid." end
  if prefix == QUICK_CONTEXT_PREFIX and payload.v ~= nil then
    return nil, "MFPRAQ contexts must not contain a format-version field."
  end
  if prefix == LEGACY_QUICK_CONTEXT_PREFIX and payload.v ~= 1 then
    return nil, "Legacy MFPRAQ1 contexts require version 1."
  end
  local valid, validationError = ValidateQuickPlanContextPayload(self, payload)
  if not valid then return nil, validationError end
  if not payload.h then return nil, "Scoped Boss Plan context semantic hash is missing." end
  local expected = payload.h
  local hashPayload = DeepCopy(payload)
  hashPayload.h = nil
  local canonicalOK, canonical = pcall(EncodeCanonicalJSON, hashPayload)
  if not canonicalOK or AdlerHex(canonical) ~= expected then
    return nil, "Scoped Boss Plan context semantic hash mismatch."
  end
  payload.v = nil
  return payload
end

local function PackRow(row)
  local packed = { a = tostring(row.assignment or ""), n = tostring(row.player or "") }
  local fields = {
    d = row.displayLabel, c = row.class, s = row.spec, k = row.kind, r = row.role, i = row.id,
    m = row.marker,
    tc = row.targetClass, ts = row.targetSpec, l = row.slot,
    p = row.position, tk = row.targetKind, t = row.target, u = row.note or row.context,
    bn = row.bossSpellName, bi = row.bossSpellIcon,
    wn = row.customWhat, wi = row.customWhatIcon,
    an = row.abilityName, ai = row.abilityIcon,
    cn = row.cooldownName, ci = row.cooldownIcon,
    x = row.customAbilityCooldown, v = row.visibility,
  }
  for key, value in pairs(fields) do if value ~= nil and tostring(value) ~= "" then packed[key] = tostring(value) end end
  if row.abilitySymbiosis == true then packed.ae = true end
  if row.cooldownSymbiosis == true then packed.ce = true end
  if type(row.groups) == "table" and #row.groups > 0 then packed.g = DeepCopy(row.groups) end
  if type(row.targetNames) == "table" and #row.targetNames > 0 then packed.tn = DeepCopy(row.targetNames) end
  if type(row.targetClasses) == "table" and #row.targetClasses > 0 then packed.tcs = DeepCopy(row.targetClasses) end
  if type(row.targetSpecs) == "table" and #row.targetSpecs > 0 then packed.tss = DeepCopy(row.targetSpecs) end
  return packed
end

local GURTOGG_GROUP_SECTION_KEYS = {
  ["starworldmarkgroup1"] = true,
  ["diamondworldmarkgroup2"] = true,
  ["circleworldmarkgroup3"] = true,
}

local INTERRUPT_ASSIGNMENT_SECTION_KEYS = {
  reliquaryofsouls = {
    ["reliquaryspiritshockinterrupts"] = true,
    ["spiritshockinterruptrotation"] = true,
    ["spiritshockinterrupt"] = true,
    ["runeshieldspellsteal"] = true,
    ["seethetranqshot"] = true,
  },
  reliqofthelost = {
    ["reliquaryspiritshockinterrupts"] = true,
    ["spiritshockinterruptrotation"] = true,
    ["spiritshockinterrupt"] = true,
    ["runeshieldspellsteal"] = true,
    ["seethetranqshot"] = true,
  },
  illidaricouncil = {
    ["councilmalandeinterrupts"] = true,
    ["ladymalandecircleofhealinginterrupts"] = true,
    ["ladymalandeinterrupts"] = true,
    ["prayerofhealing"] = true,
  },
  theillidaricouncil = {
    ["councilmalandeinterrupts"] = true,
    ["ladymalandecircleofhealinginterrupts"] = true,
    ["ladymalandeinterrupts"] = true,
    ["prayerofhealing"] = true,
  },
}

local ILLIDAN_PHASE2_GROUP_SECTION_KEYS = {
  ["diamondworldmarkgroup1"] = true,
  ["phase2diamondworldmarkgroup1"] = true,
  ["phase2group1"] = true,
  ["starworldmarkgroup2"] = true,
  ["phase2starworldmarkgroup2"] = true,
  ["phase2group2"] = true,
  ["circleworldmarkgroup3"] = true,
  ["phase2circleworldmarkgroup3"] = true,
  ["phase2group3"] = true,
}

local function PackAssignments(parsed, selectedBoss, omittedSectionKeys)
  local assignments = { c = tostring(parsed.comp or ""), rs = {}, bs = {} }
  for _, raid in ipairs(parsed.raids or {}) do
    local includeRaid = not selectedBoss or Normalize(raid.key) == Normalize(selectedBoss.raidKey)
    if selectedBoss and selectedBoss.isTrash and type(selectedBoss.trashMembers) == "table" then
      for _, member in ipairs(selectedBoss.trashMembers) do
        if Normalize(raid.key) == Normalize(member) then includeRaid = true end
      end
    end
    if includeRaid then
      assignments.rs[#assignments.rs + 1] = { i = tostring(raid.key or ""), n = tostring(raid.name or raid.key or ""), c = tostring(raid.comp or parsed.comp or "") }
    end
  end
  for _, boss in ipairs(parsed.bosses or {}) do
    if not selectedBoss or boss == selectedBoss then
      local packedBoss = {
        i = tostring(boss.key or ""), n = tostring(boss.name or boss.key or ""),
        q = tostring(boss.raidKey or ""), t = boss.isTrash == true, s = {},
        tg = boss.trashGroup, ta = boss.trashAnchor,
        tm = type(boss.trashMembers) == "table" and #boss.trashMembers > 0 and DeepCopy(boss.trashMembers) or nil,
      }
      local omitGurtoggGroups = omittedSectionKeys == GURTOGG_GROUP_SECTION_KEYS
      if not omitGurtoggGroups and boss.bloodBoilStackTargetsConfigured == true then
        packedBoss.bb = DeepCopy(boss.bloodBoilStackTargets)
      end
      local sourceSections = boss.sections or {}
      if #sourceSections == 0 and #(boss.v2Assignments or {}) > 0 then
        sourceSections = { {
          name = "Assignments", sourceName = "Assignments", rows = boss.v2Assignments,
          context = { type = boss.isTrash and "Trash" or "Boss", raidName = boss.raidKey, bossName = boss.name, phase = "" },
        } }
      end
      for _, section in ipairs(sourceSections) do
        local sectionKey = Normalize(section.sourceName or section.name)
        if not omittedSectionKeys or not omittedSectionKeys[sectionKey] then
          local context = section.context or {}
          local packedSection = {
            n = tostring(section.name or section.sourceName or "Assignments"),
            o = tostring(section.sourceName or section.name or "Assignments"),
            k = section.kind,
            c = { t = tostring(context.type or (boss.isTrash and "Trash" or "Boss")), r = tostring(context.raidName or boss.raidKey or ""), b = tostring(context.bossName or boss.name or ""), p = tostring(context.phase or "") },
            w = {},
          }
          if packedSection.k == nil or packedSection.k == "" then packedSection.k = nil end
          for _, row in ipairs(section.rows or {}) do packedSection.w[#packedSection.w + 1] = PackRow(row) end
          if #packedSection.w > 0 then packedBoss.s[#packedBoss.s + 1] = packedSection end
        end
      end
      if #packedBoss.s > 0 then assignments.bs[#assignments.bs + 1] = packedBoss end
    end
  end
  return assignments
end

local function UnpackAssignments(assignments)
  local parsed = {
    protocol = "MFPRA", expansion = EXPANSION, label = "", comp = assignments.c or "",
    raids = {}, raidMap = {}, bosses = {}, bossMap = {}, v2Assignments = {},
  }
  for _, raid in ipairs(assignments.rs or {}) do
    local entry = { key = raid.i, name = raid.n, comp = raid.c or assignments.c or "" }
    parsed.raids[#parsed.raids + 1] = entry
    parsed.raidMap[Normalize(entry.key)] = entry
    if parsed.label == "" then parsed.label = entry.name end
  end
  for _, packedBoss in ipairs(assignments.bs or {}) do
    local boss = {
      key = packedBoss.i, name = packedBoss.n, raidKey = packedBoss.q,
      isTrash = packedBoss.t == true, trashGroup = packedBoss.tg,
      trashAnchor = packedBoss.ta, trashMembers = DeepCopy(packedBoss.tm or {}),
      bloodBoilStackTargets = DeepCopy(packedBoss.bb or DEFAULT_BLOOD_BOIL_STACK_TARGETS),
      bloodBoilStackTargetsConfigured = packedBoss.bb ~= nil,
      sections = {}, sectionMap = {}, v2Assignments = {},
    }
    for _, packedSection in ipairs(packedBoss.s or {}) do
      local context = { type = packedSection.c.t, raidName = packedSection.c.r, bossName = packedSection.c.b, phase = packedSection.c.p, boss = boss }
      local section = { name = packedSection.n, sourceName = packedSection.o, kind = packedSection.k, context = context, rows = {} }
      for _, packedRow in ipairs(packedSection.w or {}) do
        section.rows[#section.rows + 1] = {
          assignment = packedRow.a, displayLabel = packedRow.d or packedRow.a, player = packedRow.n, id = packedRow.i,
          class = packedRow.c or "", spec = packedRow.s or "", kind = packedRow.k,
          role = packedRow.r, marker = packedRow.m or "",
          targetClass = packedRow.tc or "", targetSpec = packedRow.ts or "", slot = packedRow.l or "",
          targetNames = DeepCopy(packedRow.tn or {}), targetClasses = DeepCopy(packedRow.tcs or {}), targetSpecs = DeepCopy(packedRow.tss or {}),
          position = packedRow.p or "", targetKind = packedRow.tk, target = packedRow.t or "",
          groups = DeepCopy(packedRow.g or {}), note = packedRow.u or "", context = packedRow.u or "",
          bossSpellName = packedRow.bn or "", bossSpellIcon = packedRow.bi or "",
          customWhat = packedRow.wn or "", customWhatIcon = packedRow.wi or "",
          abilityName = packedRow.an or "", abilityIcon = packedRow.ai or "",
          abilitySymbiosis = packedRow.ae == true,
          cooldownName = packedRow.cn or "", cooldownIcon = packedRow.ci or "",
          cooldownSymbiosis = packedRow.ce == true,
          customAbilityCooldown = packedRow.x or "", visibility = packedRow.v,
        }
      end
      boss.sections[#boss.sections + 1] = section
      boss.sectionMap[Normalize(section.name)] = section
    end
    parsed.bosses[#parsed.bosses + 1] = boss
    parsed.bossMap[Normalize(boss.key)] = boss
    parsed.bossMap[Normalize(boss.name)] = boss
  end
  return parsed
end

function MerfinPlus:UnpackCanonicalRaidAssignments(assignments)
  return UnpackAssignments(assignments)
end

local function LegacyEscape(value)
  return tostring(value or ""):gsub("%%", "%%25"):gsub("|", "%%7C"):gsub("\r", "%%0D"):gsub("\n", "%%0A")
end

local function SerializeInternalLegacy(parsed)
  local output = { "MGMRA|3" }
  for _, raid in ipairs(parsed.raids or {}) do
    output[#output + 1] = table.concat({ "RAID", raid.name, "Expansion", EXPANSION_LABEL, "Comp", raid.comp or parsed.comp or "" }, "|")
  end
  for _, boss in ipairs(parsed.bosses or {}) do
    for _, section in ipairs(boss.sections or {}) do
      local context = section.context or {}
      if boss.isTrash then output[#output + 1] = table.concat({ "CONTEXT", "Trash", "Raid", context.raidName or boss.raidKey }, "|")
      else
        local line = table.concat({ "CONTEXT", "Boss", context.bossName or boss.name, "Raid", context.raidName or boss.raidKey }, "|")
        if context.phase and context.phase ~= "" then line = line .. "|Phase|" .. tostring(context.phase) end
        output[#output + 1] = line
      end
      output[#output + 1] = "SECTION|" .. tostring(section.sourceName or section.name)
      for _, row in ipairs(section.rows or {}) do
        output[#output + 1] = table.concat({
          "PLAYER", LegacyEscape(row.player), "Class", LegacyEscape(row.class), "Spec", LegacyEscape(row.spec),
          "Task", LegacyEscape(row.assignment), "WorldMark", LegacyEscape(row.marker), "TargetClass", LegacyEscape(row.targetClass),
          "TargetSpec", LegacyEscape(row.targetSpec), "Slot", LegacyEscape(row.slot), "Position", LegacyEscape(row.position),
          "Target", LegacyEscape(row.target),
        }, "|")
      end
    end
  end
  return table.concat(output, "\n")
end

local function AttachPlans(parsed, payload, legacyRaw)
  local plans = payload.k == "F" and DeepCopy(payload.p.l) or {}
  parsed.bossPlans = plans
  parsed.canonical = payload
  parsed.normalizedRaw = legacyRaw
  parsed.mgmra4 = {
    schema = "MGMRA", version = 4, catalogVersion = payload.k == "F" and payload.p.c or 1,
    expansion = EXPANSION, raidGroup = payload.g, comp = { name = payload.a and payload.a.c or "MFPRA" },
    legacyAssignments = legacyRaw, plans = plans,
  }
  return parsed
end

function MerfinPlus:BuildCanonicalFullPayload(entry, revision)
  local parsed = entry and entry.parsed
  if not parsed then return nil, "No parsed Raid Assignments snapshot is available." end
  local plans = DeepCopy(parsed.bossPlans or (parsed.mgmra4 and parsed.mgmra4.plans) or {})
  return {
    s = SCHEMA, k = "F", r = revision, x = EXPANSION, g = entry.raidGroup,
    a = PackAssignments(parsed, nil), p = { c = 1, l = plans },
  }
end

local function QuickPlanMatchesBoss(plan, boss)
  local planBoss = Normalize(plan and plan.boss)
  if planBoss == "" then return false end
  for _, candidate in ipairs({ boss and boss.key, boss and boss.name }) do
    local selected = Normalize(candidate)
    if selected ~= "" and (planBoss == selected
      or selected:find(planBoss, 1, true))
    then
      return true
    end
  end
  return false
end

function MerfinPlus:BuildRaidAssignmentQuickPlanContextPayload(entry, boss, revision)
  if not entry or not entry.parsed or not boss or not IsRevision(revision) then return nil end
  local plans = {}
  for _, plan in ipairs(entry.parsed.bossPlans or {}) do
    if QuickPlanMatchesBoss(plan, boss) then plans[#plans + 1] = DeepCopy(plan) end
  end
  if #plans == 0 then return nil end
  return {
    s = QUICK_CONTEXT_SCHEMA, k = "C", r = revision, x = EXPANSION,
    g = entry.raidGroup, b = boss.key or boss.name, p = { c = 1, l = plans },
  }
end

function MerfinPlus:ParseCanonicalRaidAssignmentEntry(entry)
  if not entry or not entry.canonicalRaw then return nil end
  local payload, errorText = self:DecodeCanonicalRaidAssignmentEnvelope(entry.canonicalRaw)
  if not payload or payload.k ~= "F" then return nil, errorText or "Stored canonical snapshot is not full." end
  local parsed = UnpackAssignments(payload.a)
  local legacyRaw = SerializeInternalLegacy(parsed)
  AttachPlans(parsed, payload, legacyRaw)
  return parsed
end

local function ContentSignature(value)
  return tostring(#value) .. "-" .. tostring(AdlerHex(value) or "00000000")
end

local function NextRevision(owner)
  local storage = owner:GetRaidAssignmentStorage()
  local now = (GetServerTime and GetServerTime()) or (time and time()) or 1
  storage.mfpRevisionCounter = math.max((tonumber(storage.mfpRevisionCounter) or 0) + 1, now)
  return storage.mfpRevisionCounter
end

local function StoreCanonicalFull(owner, raw, payload, parsed, received, sender, selectedGroup, suppressRefresh)
  local group = owner:GetRaidAssignmentGroup(payload.g)
  if not group then return nil, "MFPRA raid group is not supported by this addon." end
  if selectedGroup and selectedGroup ~= "" and selectedGroup ~= group.id then return nil, "MFPRA raid group does not match the selected raid." end
  local legacyRaw = SerializeInternalLegacy(parsed)
  AttachPlans(parsed, payload, legacyRaw)
  local storage = owner:GetRaidAssignmentStorage()
  local signature = ContentSignature(raw)
  for _, existing in ipairs(storage.raidImports or {}) do
    if existing.raidGroup == group.id and existing.canonicalSignature == signature and existing.canonicalRaw == raw and (existing.receivedBroadcast == true) == (received == true) then
      existing.canonicalRevision = payload.r
      existing.version, existing.envelopeVersion = nil, nil
      if owner.CacheRaidAssignmentEntryParse then owner:CacheRaidAssignmentEntryParse(existing, parsed) else existing.parsed = parsed end
      storage.activeRaidImportByGroup[group.id] = existing.id
      local state = owner:GetRaidAssignmentUIState()
      state.selectedGroup, state.selectedBossKey = group.id, nil
      state.selectedSavedRaidImportID = existing.id
      if not suppressRefresh then owner:NotifyRaidAssignmentsChanged() end
      return existing, nil, true
    end
  end
  local now = (GetServerTime and GetServerTime()) or (time and time()) or 0
  local ordinal, used = #storage.raidImports + 1, {}
  for _, existing in ipairs(storage.raidImports) do used[existing.id] = true end
  local entryID
  repeat entryID, ordinal = tostring(now) .. "-mfpra-" .. tostring(ordinal), ordinal + 1 until not used[entryID]
  local entry = {
    id = entryID,
    protocol = SCHEMA, expansion = EXPANSION,
    raidGroup = group.id, raidGroupName = group.name,
    raw = legacyRaw, canonicalRaw = raw, canonicalSignature = signature, canonicalRevision = payload.r,
    contentSignature = ContentSignature(legacyRaw), parsed = parsed,
    importedAt = now, importedAtText = date and date("%Y-%m-%d %H:%M", now) or tostring(now),
    receivedBroadcast = received == true, broadcastSender = tostring(sender or ""),
  }
  if received then
    for index = #storage.raidImports, 1, -1 do
      local previous = storage.raidImports[index]
      if previous.receivedBroadcast == true and previous.raidGroup == group.id then
        if owner.InvalidateRaidAssignmentEntryParse then owner:InvalidateRaidAssignmentEntryParse(previous) end
        table.remove(storage.raidImports, index)
      end
    end
  end
  storage.raidImports[#storage.raidImports + 1] = entry
  if owner.CacheRaidAssignmentEntryParse then owner:CacheRaidAssignmentEntryParse(entry, parsed) end
  storage.activeRaidImportByGroup[group.id] = entry.id
  local state = owner:GetRaidAssignmentUIState()
  state.selectedGroup, state.selectedBossKey = group.id, nil
  state.selectedSavedRaidImportID = entry.id
  if not suppressRefresh then owner:NotifyRaidAssignmentsChanged() end
  return entry, nil, false
end

function MerfinPlus:ImportCanonicalRaidAssignmentSnapshot(raw, selectedGroup)
  local payload, errorText = self:DecodeCanonicalRaidAssignmentEnvelope(raw)
  if not payload then return nil, errorText end
  if payload.k ~= "F" then return nil, "Clipboard import requires one full MFPRA snapshot (k=F)." end
  local preparedPreBossGroups
  if payload.a.pg ~= nil then
    if type(self.PrepareCanonicalPreBossGroupImport) ~= "function" then
      return nil, "This MFPRA contains Pre-Boss Groups, but this client cannot import them."
    end
    preparedPreBossGroups, errorText = self:PrepareCanonicalPreBossGroupImport(payload)
    if not preparedPreBossGroups then return nil, errorText end
  end
  local parsed = UnpackAssignments(payload.a)
  local entry, storeError, duplicate = StoreCanonicalFull(self, raw, payload, parsed, false, nil, selectedGroup)
  if not entry then return nil, storeError end
  if preparedPreBossGroups then
    local plan, preBossError = self:CommitCanonicalPreBossGroupImport(preparedPreBossGroups)
    if not plan then return nil, "Raid Assignments imported, but Pre-Boss Groups failed: " .. tostring(preBossError or "unknown error") end
  end
  return entry, storeError, duplicate
end

function MerfinPlus:CanCanonicalRaidAssignmentAction()
  return self:CanBroadcastRaidAssignments()
end

function MerfinPlus:RegisterRaidAssignmentPrefix()
  local register = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix
  local ok, result, legacyOK, legacyResult
  if register then
    ok, result = pcall(register, ADDON_PREFIX)
    legacyOK, legacyResult = pcall(register, LEGACY_ADDON_PREFIX)
  end
  self.assignmentPrefixSupport = {
    raid = ok == true and result ~= false,
    canonical = ok == true and result ~= false,
    legacyReceive = legacyOK == true and legacyResult ~= false,
  }
  return self.assignmentPrefixSupport.canonical
end

local function AddonVersion()
  local getter = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
  return getter and tostring(getter("MerfinPlus", "Version") or "unknown") or "unknown"
end

local function RecipientKey(value)
  return Normalize(value)
end

local function QuickPlanContextKey(groupID, bossKey)
  return Normalize(groupID) .. "\001" .. Normalize(bossKey)
end

local function GetQuickPlanContextStorage(owner)
  local storage = owner:GetRaidAssignmentStorage()
  storage.mfpQuickBossPlanContexts = storage.mfpQuickBossPlanContexts or {}
  return storage, storage.mfpQuickBossPlanContexts
end

function MerfinPlus:GetScopedRaidAssignmentBossPlanQuickSelection(groupID, selectedBossKey)
  local storage, contexts = GetQuickPlanContextStorage(self)
  local state = storage.mfpPersonalWidgetState
  local context = contexts[QuickPlanContextKey(groupID, selectedBossKey)]
  if not state or not context
    or Normalize(state.g) ~= Normalize(groupID)
    or tonumber(state.r) ~= tonumber(context.revision)
    or RecipientKey(state.sourceSender) == ""
    or RecipientKey(state.sourceSender) ~= RecipientKey(context.sender)
  then
    return {}, nil
  end
  return context.entry.parsed.bossPlans or {}, context.entry
end

function MerfinPlus:ApplyRaidAssignmentQuickPlanContext(payload, sender)
  local storage, contexts = GetQuickPlanContextStorage(self)
  storage.mfpQuickBossPlanContextOrder = (storage.mfpQuickBossPlanContextOrder or 0) + 1
  local entry = {
    id = "mfpra-quick:" .. tostring(payload.g) .. ":" .. tostring(payload.b),
    raidGroup = payload.g,
    canonicalQuickContext = true,
    receivedBroadcast = true,
    parsed = {
      bossPlans = DeepCopy(payload.p.l),
      bosses = {},
    },
  }
  local key = QuickPlanContextKey(payload.g, payload.b)
  contexts[key] = {
    entry = entry,
    revision = payload.r,
    sender = RecipientKey(sender),
    order = storage.mfpQuickBossPlanContextOrder,
  }
  local count, oldestKey, oldestOrder = 0
  for candidateKey, context in pairs(contexts) do
    count = count + 1
    if not oldestOrder or context.order < oldestOrder then
      oldestKey, oldestOrder = candidateKey, context.order
    end
  end
  if count > LIMITS.bosses and oldestKey ~= key then contexts[oldestKey] = nil end
  if self.MarkAssignmentWidgetContentDirty then self:MarkAssignmentWidgetContentDirty("assignmentWidget") end
  if self.RefreshOpenAssignmentWidgetBossPlanQuickContext then
    self:RefreshOpenAssignmentWidgetBossPlanQuickContext(entry, sender, payload.r)
  end
  return true, entry
end

local function BuildRecipientIndex(recipients)
  local expected, shortKeys = {}, {}
  for _, recipient in ipairs(recipients or {}) do
    local record = { name = recipient.commName, recipient = recipient, confirmed = false }
    expected[RecipientKey(recipient.commName)] = record
    local shortKey = RecipientKey(recipient.name or CleanPlayerName(recipient.commName))
    if shortKeys[shortKey] then shortKeys[shortKey] = false else shortKeys[shortKey] = record end
  end
  for shortKey, record in pairs(shortKeys) do if record then expected[shortKey] = record end end
  return expected
end

local function FindExpectedRecipient(expected, sender)
  if not expected then return nil end
  return expected[RecipientKey(sender)] or expected[RecipientKey(CleanPlayerName(sender))]
end

local function BuildTransportRecipientStatuses(pending, phase)
  local statuses = {}
  for _, participant in ipairs(pending and pending.participants or {}) do
    local status, detail
    if participant.isSelf then
      status, detail = "success", "Completed locally"
    elseif not participant.connected then
      status, detail = "failed", "Offline"
    else
      local record = FindExpectedRecipient(pending.expected, participant.commName)
      if record and record.confirmed then
        status, detail = "success", "Confirmed"
      elseif record and record.rejected then
        status, detail = "failed", "Rejected"
      elseif phase == "partial" or phase == "failed" or phase == "complete" then
        status, detail = "failed", "No confirmation"
      else
        status, detail = "pending", "Sending"
      end
    end
    statuses[#statuses + 1] = {
      name = participant.name or CleanPlayerName(participant.commName),
      commName = participant.commName,
      classToken = participant.classToken,
      connected = participant.connected ~= false,
      isSelf = participant.isSelf == true,
      status = status,
      detail = detail,
    }
  end
  return statuses
end

local function CountRows(parsed)
  local count = 0
  for _, boss in ipairs(parsed and parsed.bosses or {}) do for _, section in ipairs(boss.sections or {}) do count = count + #(section.rows or {}) end end
  return count
end

local function WireHash(raw)
  return AdlerHex(raw)
end

local function PublishTransportProgress(owner, transferID, kind, phase, confirmed, target, detail, recipientStatuses)
  if transferID and owner.mfpActiveUITransferID ~= transferID then return end
  if recipientStatuses == nil then
    local pending = owner.mfpPendingTransfers and owner.mfpPendingTransfers[transferID]
    if pending then recipientStatuses = BuildTransportRecipientStatuses(pending, phase) end
  end
  local progress = {
    transferID = transferID,
    kind = kind,
    phase = phase,
    confirmed = math.max(0, tonumber(confirmed) or 0),
    target = math.max(0, tonumber(target) or 0),
    detail = tostring(detail or ""),
    recipients = recipientStatuses or {},
  }
  owner.mfpRaidAssignmentTransportProgress = progress
  for widget in pairs(owner.raidAssignmentWidgets or {}) do
    if widget.UpdateTransportProgress then widget:UpdateTransportProgress(progress) end
  end
end

local function SetTransportStatus(owner, text, tone)
  local state = owner:GetRaidAssignmentUIState()
  state.status = tostring(text or "")
  state.statusTone = tone or "muted"
  for widget in pairs(owner.raidAssignmentWidgets or {}) do
    if widget.UpdateStatus then widget:UpdateStatus(state) end
  end
end

local function BeginTransportProgress(owner, kind)
  owner.mfpUIProgressSequence = (owner.mfpUIProgressSequence or 0) + 1
  local transferID = "preparing-" .. tostring(kind) .. "-" .. tostring(owner.mfpUIProgressSequence)
  owner.mfpActiveUITransferID = transferID
  PublishTransportProgress(owner, transferID, kind, "preparing", 0, 0, "Preparing the explicit assignment transfer.")
  return transferID
end

local function FailTransportProgress(owner, transferID, kind, reason)
  if transferID then PublishTransportProgress(owner, transferID, kind, "failed", 0, 0, reason) end
end

function MerfinPlus:GetRaidAssignmentTransportProgress()
  return self.mfpRaidAssignmentTransportProgress
end

local function FinalizePendingTransfer(owner, transferID)
  local pending = owner.mfpPendingTransfers and owner.mfpPendingTransfers[transferID]
  if not pending then return end
  if pending.timer and pending.timer.Cancel then pcall(pending.timer.Cancel, pending.timer) end
  local silent = math.max(0, pending.remoteExpectedCount - pending.respondedCount)
  local target = pending.expectedCount
  local phase, detail
  if target == 1 then
    phase = "local"
    detail = "The sender completed the transfer locally; there were no other group participants."
  elseif pending.rejectedCount > 0 or silent > 0 then
    phase = "partial"
    detail = string.format(
      "%d of %d group participants completed the transfer; %d rejected and %d did not confirm. No retry was queued.",
      pending.confirmedCount, target, pending.rejectedCount, silent
    )
  else
    phase = "complete"
    detail = string.format("All %d group participants completed the transfer.", pending.confirmedCount)
  end
  local recipientStatuses = BuildTransportRecipientStatuses(pending, phase)
  owner.mfpPendingTransfers[transferID] = nil
  if pending.showProgress then
    SetTransportStatus(owner, detail, (phase == "complete" or phase == "local") and "good" or "muted")
    PublishTransportProgress(owner, transferID, pending.kind, phase, pending.confirmedCount, target, detail, recipientStatuses)
  end
end

function MerfinPlus:FinalizeRaidAssignmentTransport(transferID)
  FinalizePendingTransfer(self, transferID)
end

local function SchedulePendingFinalization(owner, pending, totalChunks)
  local delay = math.max(6, math.min(30, 6 + ((tonumber(totalChunks) or 1) * 0.08)))
  local callback = function()
    if owner.mfpPendingTransfers and owner.mfpPendingTransfers[pending.id] == pending then
      FinalizePendingTransfer(owner, pending.id)
    end
  end
  if C_Timer and C_Timer.NewTimer then
    pending.timer = C_Timer.NewTimer(delay, callback)
  elseif C_Timer and C_Timer.After then
    C_Timer.After(delay, callback)
  end
end

local function UpdatePendingProgress(owner, pending, detail)
  if pending.showProgress then
    PublishTransportProgress(owner, pending.id, pending.kind, "pending", pending.confirmedCount, pending.expectedCount, detail)
  end
end

local function SendCanonical(owner, kind, revision, raw, showProgress, preparingID, explicitRecipients, explicitDistribution)
  local allowed, reason = owner:CanCanonicalRaidAssignmentAction()
  if not allowed then
    FailTransportProgress(owner, preparingID, kind, reason)
    return false, reason
  end
  if not owner:RegisterRaidAssignmentPrefix() then
    reason = "MFPRA addon-message prefix registration failed."
    FailTransportProgress(owner, preparingID, kind, reason)
    return false, reason
  end
  local distribution = explicitDistribution or owner:GetRaidAssignmentBroadcastChannel()
  if not distribution then
    reason = "No party or raid addon-message channel is available."
    FailTransportProgress(owner, preparingID, kind, reason)
    return false, reason
  end
  local participants = owner:GetRaidAssignmentGroupRecipients()
  local recipients = explicitRecipients or {}
  if not explicitRecipients then
    for _, recipient in ipairs(participants) do
      if not recipient.isSelf then recipients[#recipients + 1] = recipient end
    end
  else
    local explicitParticipants = {}
    for _, participant in ipairs(participants) do
      if participant.isSelf then explicitParticipants[#explicitParticipants + 1] = participant end
    end
    for _, recipient in ipairs(recipients) do explicitParticipants[#explicitParticipants + 1] = recipient end
    participants = explicitParticipants
  end
  local connectedRemoteCount = 0
  for _, recipient in ipairs(recipients) do
    if recipient.connected then connectedRemoteCount = connectedRemoteCount + 1 end
  end
  if #recipients == 0 then
    local detail = "The sender completed the transfer locally; there were no other group participants."
    SetTransportStatus(owner, detail, "good")
    if preparingID then
      local immediate = { participants = participants, expected = {} }
      PublishTransportProgress(owner, preparingID, kind, "local", 1, 1, detail, BuildTransportRecipientStatuses(immediate, "local"))
    end
    return true, { localOnly = true, bytes = #raw, chunks = 0, recipients = 0, participants = 1, confirmed = 1 }
  end
  if connectedRemoteCount == 0 then
    local participantCount = #recipients + 1
    local detail = string.format("1 of %d group participants completed locally; %d offline peer(s) could not confirm. No retry was queued.", participantCount, #recipients)
    SetTransportStatus(owner, detail, "muted")
    if preparingID then
      local immediate = { participants = participants, expected = BuildRecipientIndex(recipients) }
      PublishTransportProgress(owner, preparingID, kind, "partial", 1, participantCount, detail, BuildTransportRecipientStatuses(immediate, "partial"))
    end
    return true, { localOnly = true, partial = true, bytes = #raw, chunks = 0, recipients = #recipients, participants = participantCount, confirmed = 1 }
  end
  local total = math.max(1, math.ceil(#raw / CHUNK_BYTES))
  if total > MAX_CHUNKS then
    reason = "MFPRA transfer exceeds the chunk limit."
    FailTransportProgress(owner, preparingID, kind, reason)
    return false, reason
  end
  owner.mfpTransferSequence = (owner.mfpTransferSequence or 0) + 1
  local transferID = table.concat({ tostring((GetServerTime and GetServerTime()) or (time and time()) or 0), tostring(owner.mfpTransferSequence), kind }, "-")
  local hash = WireHash(raw)
  if not hash then
    reason = "MFPRA wire hash is unavailable."
    FailTransportProgress(owner, preparingID, kind, reason)
    return false, reason
  end
  local expected = BuildRecipientIndex(recipients)
  owner.mfpPendingTransfers = owner.mfpPendingTransfers or {}
  owner.mfpPendingOrder = (owner.mfpPendingOrder or 0) + 1
  local pending = {
    id = transferID, kind = kind, revision = revision, hash = hash,
    expected = expected, recipients = recipients, participants = participants,
    expectedCount = #recipients + 1, remoteExpectedCount = #recipients,
    connectedExpectedCount = connectedRemoteCount,
    respondedCount = 0, confirmedCount = 1, rejectedCount = 0,
    order = owner.mfpPendingOrder, showProgress = showProgress == true,
  }
  owner.mfpPendingTransfers[transferID] = pending
  local pendingCount, oldestID, oldestOrder = 0
  for id, pending in pairs(owner.mfpPendingTransfers) do
    pendingCount = pendingCount + 1
    if not oldestOrder or pending.order < oldestOrder then oldestID, oldestOrder = id, pending.order end
  end
  if pendingCount > 4 and oldestID ~= transferID then owner.mfpPendingTransfers[oldestID] = nil end
  if pending.showProgress then
    owner.mfpActiveUITransferID = transferID
    UpdatePendingProgress(owner, pending, string.format(
      "The sender completed locally; waiting for %d online group peer confirmation(s).",
      pending.connectedExpectedCount
    ))
  end
  local messages = { table.concat({ "S", transferID, kind, revision, total, #raw, hash }, "|") }
  for index = 1, total do messages[#messages + 1] = table.concat({ "D", transferID, index, raw:sub(((index - 1) * CHUNK_BYTES) + 1, index * CHUNK_BYTES) }, "|") end
  messages[#messages + 1] = table.concat({ "E", transferID, hash }, "|")
  local queueName = "MFPRA-" .. transferID
  local function OnWireSubmitted(callbackPending)
    if owner.mfpPendingTransfers and owner.mfpPendingTransfers[callbackPending.id] == callbackPending then
      callbackPending.wireSubmitted = true
      SchedulePendingFinalization(owner, callbackPending, total)
    end
  end
  for index, message in ipairs(messages) do
    local finalFrame = index == #messages
    if not owner:SendAssignmentAddonMessage(
      ADDON_PREFIX, message, nil, distribution, kind == "D" and "ALERT" or "BULK", queueName,
      finalFrame and OnWireSubmitted or nil, finalFrame and pending or nil
    ) then
      owner.mfpPendingTransfers[transferID] = nil
      if pending.showProgress then PublishTransportProgress(owner, transferID, kind, "failed", pending.confirmedCount, pending.expectedCount, "The transfer could not be submitted to the addon-message transport.") end
      return false, "MFPRA transfer could not be submitted to ChatThrottleLib."
    end
  end
  owner:SetRaidAssignmentStatus(kind == "P" and "Sending Boss Plan..." or "Sending assignments...", "muted")
  return true, { transferId = transferID, queueName = queueName, distribution = distribution, bytes = #raw, chunks = total, hash = hash, recipients = #recipients, participants = pending.expectedCount, confirmed = 1 }
end

local function SendQuickPlanContext(owner, revision, raw, distribution, queueName)
  local total = math.max(1, math.ceil(#raw / CHUNK_BYTES))
  if total > MAX_CHUNKS then return false, "Scoped Boss Plan context exceeds the chunk limit." end
  local hash = WireHash(raw)
  if not hash then return false, "Scoped Boss Plan context wire hash is unavailable." end
  owner.mfpTransferSequence = (owner.mfpTransferSequence or 0) + 1
  local transferID = table.concat({
    tostring((GetServerTime and GetServerTime()) or (time and time()) or 0),
    tostring(owner.mfpTransferSequence),
    "C",
  }, "-")
  queueName = queueName or ("MFPRA-" .. transferID)
  local messages = { table.concat({ "S", transferID, "C", revision, total, #raw, hash }, "|") }
  for index = 1, total do
    messages[#messages + 1] = table.concat({
      "D", transferID, index, raw:sub(((index - 1) * CHUNK_BYTES) + 1, index * CHUNK_BYTES),
    }, "|")
  end
  messages[#messages + 1] = table.concat({ "E", transferID, hash }, "|")
  for _, message in ipairs(messages) do
    if not owner:SendAssignmentAddonMessage(
      ADDON_PREFIX, message, nil, distribution, "ALERT", queueName
    ) then
      return false, "Scoped Boss Plan context could not be submitted to the addon-message transport."
    end
  end
  return true, { transferId = transferID, bytes = #raw, chunks = total, hash = hash }
end

MerfinPlus.RaidAssignmentQuickPlanSyncContract = {
  assignmentKind = "D",
  quickContextKind = "C",
  trigger = "explicit-boss-sync-only",
  compatibility = "legacy-clients-ignore-C-frames",
  snapshotScope = "matching-boss-plans-only",
  acknowledgement = false,
}

local function FinalizeFullDiscovery(owner, discoveryID)
  local discovery = owner.mfpPendingDiscoveries and owner.mfpPendingDiscoveries[discoveryID]
  if not discovery then return false, "MFPRA recipient discovery is no longer pending." end
  if discovery.timer and discovery.timer.Cancel then pcall(discovery.timer.Cancel, discovery.timer) end
  owner.mfpPendingDiscoveries[discoveryID] = nil
  owner.mfpLastPresenceDiagnostic = {
    id = discovery.id,
    candidates = discovery.candidateCount,
    responded = discovery.respondedCount,
    currentVersion = discovery.eligibleCount,
  }
  return true, owner.mfpLastPresenceDiagnostic
end

function MerfinPlus:FinalizeRaidAssignmentDiscovery(discoveryID)
  return FinalizeFullDiscovery(self, discoveryID)
end

local function BeginFullDiscovery(owner)
  local distribution = owner:GetRaidAssignmentBroadcastChannel()
  if not distribution then return false end
  local candidates = {}
  for _, recipient in ipairs(owner:GetRaidAssignmentGroupRecipients()) do
    if not recipient.isSelf and recipient.connected then candidates[#candidates + 1] = recipient end
  end
  if #candidates == 0 then return false end
  owner.mfpDiscoverySequence = (owner.mfpDiscoverySequence or 0) + 1
  local discoveryID = table.concat({ "q", tostring((GetServerTime and GetServerTime()) or (time and time()) or 0), tostring(owner.mfpDiscoverySequence) }, "-")
  local version = AddonVersion():gsub("|", "")
  local discovery = {
    id = discoveryID, version = version,
    candidates = candidates, expected = BuildRecipientIndex(candidates), candidateCount = #candidates,
    respondedCount = 0, eligibleCount = 0,
  }
  owner.mfpPendingDiscoveries = owner.mfpPendingDiscoveries or {}
  owner.mfpPendingDiscoveries[discoveryID] = discovery
  if not owner:SendAssignmentAddonMessage(ADDON_PREFIX, table.concat({ "Q", discoveryID, version }, "|"), nil, distribution, "ALERT") then
    owner.mfpPendingDiscoveries[discoveryID] = nil
    return false
  end
  local callback = function()
    if owner.mfpPendingDiscoveries and owner.mfpPendingDiscoveries[discoveryID] == discovery then
      FinalizeFullDiscovery(owner, discoveryID)
    end
  end
  if C_Timer and C_Timer.NewTimer then
    discovery.timer = C_Timer.NewTimer(2, callback)
  elseif C_Timer and C_Timer.After then
    C_Timer.After(2, callback)
  end
  return true, { discovery = true, discoveryId = discoveryID, candidates = #candidates }
end

function MerfinPlus:BroadcastFullRaidAssignments(groupID, showProgress)
  local progressID = showProgress and BeginTransportProgress(self, "F") or nil
  local entry = self:GetRaidAssignmentImportForGroup(groupID)
  if not entry or not entry.parsed then
    local reason = "No imported Raid Assignments exist for the selected raid."
    FailTransportProgress(self, progressID, "F", reason)
    return false, reason
  end
  local revision = NextRevision(self)
  local payload, buildError = self:BuildCanonicalFullPayload(entry, revision)
  if not payload then FailTransportProgress(self, progressID, "F", buildError); return false, buildError end
  local raw, encodeError = self:EncodeCanonicalRaidAssignmentEnvelope(payload)
  if not raw then FailTransportProgress(self, progressID, "F", encodeError); return false, encodeError end
  local sent, metrics = SendCanonical(self, "F", revision, raw, showProgress, progressID)
  if sent and self.ResetPersonalAssignmentWidgetFromFullSync then
    self:ResetPersonalAssignmentWidgetFromFullSync(payload)
    if self.NotifyAssignmentWidgetContentChanged then
      self:NotifyAssignmentWidgetContentChanged()
    elseif self.RefreshAssignmentWidget then
      self:RefreshAssignmentWidget()
    end
  end
  if sent and metrics and not metrics.localOnly then BeginFullDiscovery(self) end
  return sent, metrics
end

function MerfinPlus:BroadcastPersonalRaidAssignments(catalogBoss, showProgress, explicitGroupID)
  local progressID = showProgress and BeginTransportProgress(self, "D") or nil
  local allowed, reason = self:CanCanonicalRaidAssignmentAction()
  if not allowed then self:SetRaidAssignmentStatus(reason, "red"); FailTransportProgress(self, progressID, "D", reason); return false, reason end
  local state = self:GetRaidAssignmentUIState()
  local entry = self:GetRaidAssignmentImportForGroup(explicitGroupID or state.selectedGroup)
  local boss = entry and entry.parsed and self:GetRaidAssignmentBoss(entry.parsed, catalogBoss)
  if not boss then
    reason = "No imported assignments exist for the selected boss."
    FailTransportProgress(self, progressID, "D", reason)
    return false, reason
  end
  local revision = NextRevision(self)
  local omitGurtoggGroups = Normalize(boss.key) == "gurtoggbloodboil"
    and type(self.GetGurtoggAssignmentMode) == "function"
    and self:GetGurtoggAssignmentMode() == self.GURTOGG_ASSIGNMENTS_MANUAL_MODE
  local omittedSectionKeys = omitGurtoggGroups and GURTOGG_GROUP_SECTION_KEYS or nil
  local interruptBossKey = Normalize(boss.key or boss.name)
  if not omittedSectionKeys
    and type(self.GetInterruptAssignmentMode) == "function"
    and self:GetInterruptAssignmentMode(interruptBossKey) == self.INTERRUPT_ASSIGNMENTS_MANUAL_MODE then
    omittedSectionKeys = INTERRUPT_ASSIGNMENT_SECTION_KEYS[interruptBossKey]
  end
  if not omittedSectionKeys
    and (interruptBossKey == "illidan" or interruptBossKey == "illidanstormrage")
    and type(self.GetIllidanPhase2AssignmentMode) == "function"
    and self:GetIllidanPhase2AssignmentMode() == self.ILLIDAN_PHASE2_ASSIGNMENTS_MANUAL_MODE then
    omittedSectionKeys = ILLIDAN_PHASE2_GROUP_SECTION_KEYS
  end
  local payload = {
    s = SCHEMA, k = "D", r = revision, x = EXPANSION,
    g = entry.raidGroup, b = boss.key,
    a = PackAssignments(entry.parsed, boss, omittedSectionKeys),
  }
  local raw, encodeError = self:EncodeCanonicalRaidAssignmentEnvelope(payload)
  if not raw then FailTransportProgress(self, progressID, "D", encodeError); return false, encodeError end
  local quickPayload = self:BuildRaidAssignmentQuickPlanContextPayload(entry, boss, revision)
  local quickRaw
  if quickPayload then
    quickRaw, encodeError = self:EncodeRaidAssignmentQuickPlanContext(quickPayload)
    if not quickRaw then FailTransportProgress(self, progressID, "D", encodeError); return false, encodeError end
  end
  local applied, applyError = self:ApplyLocalCanonicalBossDelta(payload)
  if not applied then FailTransportProgress(self, progressID, "D", applyError); return false, applyError end
  local sent, metrics = SendCanonical(self, "D", revision, raw, showProgress, progressID)
  if sent and quickRaw and metrics and not metrics.localOnly then
    local quickSent, quickMetrics = SendQuickPlanContext(
      self, revision, quickRaw, metrics.distribution, metrics.queueName
    )
    if quickSent then
      quickMetrics.sent = true
      metrics.quickPlanContext = quickMetrics
    else
      metrics.quickPlanContext = { sent = false, error = tostring(quickMetrics or "unknown") }
    end
  elseif metrics then
    metrics.quickPlanContext = { sent = false, unavailable = quickRaw == nil, localOnly = metrics.localOnly == true }
  end
  if sent and type(self.MaybeBroadcastGurtoggAssignmentsForBoss) == "function" then
    local groupSynced, groupMetrics = self:MaybeBroadcastGurtoggAssignmentsForBoss(catalogBoss)
    metrics = type(metrics) == "table" and metrics or {}
    metrics.gurtoggGroupAssignments = type(groupMetrics) == "table" and groupMetrics or {
      sent = groupSynced == true,
      reason = groupMetrics,
    }
  end
  if sent and type(self.MaybeBroadcastInterruptAssignmentsForBoss) == "function" then
    local interruptSynced, interruptMetrics = self:MaybeBroadcastInterruptAssignmentsForBoss(catalogBoss)
    metrics = type(metrics) == "table" and metrics or {}
    metrics.interruptAssignments = type(interruptMetrics) == "table" and interruptMetrics or {
      sent = interruptSynced == true,
      reason = interruptMetrics,
    }
  end
  if sent and type(self.MaybeBroadcastIllidanPhase2AssignmentsForBoss) == "function" then
    local illidanSynced, illidanMetrics = self:MaybeBroadcastIllidanPhase2AssignmentsForBoss(catalogBoss)
    metrics = type(metrics) == "table" and metrics or {}
    metrics.illidanPhase2Assignments = type(illidanMetrics) == "table" and illidanMetrics or {
      sent = illidanSynced == true,
      reason = illidanMetrics,
    }
  end
  return sent, metrics
end

function MerfinPlus:BroadcastCanonicalBossPlan(plan, metadata, entry)
  if type(metadata) ~= "table" or type(plan) ~= "table" then return false, "Boss Plan Send requires one selected saved plan." end
  local revision = tonumber(metadata.revision)
  if not IsRevision(revision) then return false, "Save the selected plan before sending." end
  local payload = { s = SCHEMA, k = "P", r = revision, x = EXPANSION, g = entry and entry.raidGroup or "", b = metadata.bossId, i = metadata.planId, c = 1, p = DeepCopy(plan) }
  local raw, encodeError = self:EncodeCanonicalRaidAssignmentEnvelope(payload)
  if not raw then return false, encodeError end
  return SendCanonical(self, "P", revision, raw)
end

function MerfinPlus:BroadcastBossPlanDocument()
  return false, "MGMRA4 network payloads are no longer accepted. Save and send the selected plan through MFPRA."
end

function MerfinPlus:BroadcastFullAssignmentDocument()
  return false, "Legacy MGMRA network documents are no longer accepted. Use Sync Full Assignments with MFPRA."
end

function MerfinPlus:SendRaidAssignmentAddonMessage()
  return false
end

local function FindPackedRaid(assignments, raidKey)
  local wanted = Normalize(raidKey)
  for _, raid in ipairs(assignments and assignments.rs or {}) do
    if Normalize(raid.i) == wanted then return raid end
  end
end

local function FindPackedTrash(assignments, raidKey)
  local wanted = Normalize(raidKey)
  for _, boss in ipairs(assignments and assignments.bs or {}) do
    if boss.t == true then
      if Normalize(boss.q) == wanted then return boss end
      for _, member in ipairs(type(boss.tm) == "table" and boss.tm or {}) do
        if Normalize(member) == wanted then return boss end
      end
    end
  end
end

local function PersonalTrashMemberKey(groupID, raidKey)
  return Normalize(groupID) .. "\31" .. Normalize(raidKey)
end

local function PersonalTrashCacheKey(groupID, scopeKey)
  return Normalize(groupID) .. "\31" .. tostring(scopeKey or "")
end

local function GetPersonalTrashCache(storage)
  storage.mfpPersonalWidgetTrashByRaid = storage.mfpPersonalWidgetTrashByRaid or {}
  return storage.mfpPersonalWidgetTrashByRaid
end

local function GetPersonalTrashScopes(storage)
  storage.mfpPersonalWidgetTrashScopes = storage.mfpPersonalWidgetTrashScopes or {}
  return storage.mfpPersonalWidgetTrashScopes
end

local function InvalidateCanonicalPersonalImport(owner)
  owner.mfpCanonicalPersonalImportCache = nil
end

local function RegisterPersonalTrashScope(storage, groupID, trash)
  if not trash or trash.t ~= true then return nil end
  local scope = trash.tg and ("shared:" .. Normalize(trash.tg)) or ("raid:" .. Normalize(trash.q))
  local scopes = GetPersonalTrashScopes(storage)
  local members = type(trash.tm) == "table" and trash.tm or { trash.q }
  for _, member in ipairs(members) do scopes[PersonalTrashMemberKey(groupID, member)] = scope end
  GetPersonalTrashCache(storage)[PersonalTrashCacheKey(groupID, scope)] = DeepCopy(trash)
  return scope
end

local function GetStoredFullPayload(owner, groupID)
  local entry = owner:GetRaidAssignmentImportForGroup(groupID)
  if not entry or not entry.canonicalRaw then return nil end
  local cached = entry.parsed and entry.parsed.canonical
  if cached and cached.k == "F" then return cached end
  local payload = owner:DecodeCanonicalRaidAssignmentEnvelope(entry.canonicalRaw)
  return payload and payload.k == "F" and payload or nil
end

local function ResolvePersonalTrashScope(owner, groupID, raidKey, incomingTrash)
  local storage = owner:GetRaidAssignmentStorage()
  if incomingTrash and incomingTrash.t == true then
    return RegisterPersonalTrashScope(storage, groupID, incomingTrash)
  end
  local memberKey = PersonalTrashMemberKey(groupID, raidKey)
  local scope = GetPersonalTrashScopes(storage)[memberKey]
  if scope then return scope end
  local full = GetStoredFullPayload(owner, groupID)
  local trash = full and FindPackedTrash(full.a, raidKey)
  if trash then return RegisterPersonalTrashScope(storage, groupID, trash) end
  scope = "raid:" .. Normalize(raidKey)
  GetPersonalTrashScopes(storage)[memberKey] = scope
  return scope
end

local function SeedPersonalWidgetTrash(owner, state)
  if state.trash then return end
  state.trashScope = state.trashScope or ResolvePersonalTrashScope(owner, state.g, state.q)
  local cached = GetPersonalTrashCache(owner:GetRaidAssignmentStorage())[PersonalTrashCacheKey(state.g, state.trashScope)]
  if cached then
    state.trash = DeepCopy(cached)
    return
  end
  local full = GetStoredFullPayload(owner, state.g)
  local trash = full and FindPackedTrash(full.a, state.q)
  if trash then state.trash = DeepCopy(trash) end
end

local function PersonalPlayerName(owner)
  if owner.GetCanonicalRaidAssignmentPlayerName then
    local value = owner:GetCanonicalRaidAssignmentPlayerName()
    if value and value ~= "" then return CleanPlayerName(value) end
  end
  return CleanPlayerName(UnitName and UnitName("player") or "")
end

local function FilterPersonalAdditionalRows(owner, boss)
  local filtered = DeepCopy(boss)
  local playerName = Normalize(PersonalPlayerName(owner))
  for _, section in ipairs(filtered.s or {}) do
    local rows = {}
    for _, row in ipairs(section.w or {}) do
      if row.k ~= "additional" or (row.v == "assignee" and playerName ~= "" and Normalize(CleanPlayerName(row.n)) == playerName) then
        rows[#rows + 1] = row
      end
    end
    section.w = rows
  end
  return filtered
end

local function UpdatePersonalWidgetState(owner, payload, sender)
  local incoming = payload.a and payload.a.bs and payload.a.bs[1]
  if not incoming then return nil, "Boss assignment delta has no boss." end
  local storage = owner:GetRaidAssignmentStorage()
  local state = storage.mfpPersonalWidgetState
  local incomingTrashScope = incoming.t == true and ResolvePersonalTrashScope(owner, payload.g, incoming.q, incoming) or nil
  local sameSharedContext = state and incomingTrashScope and state.g == payload.g and state.trashScope == incomingTrashScope
  if not state or state.g ~= payload.g or (Normalize(state.q) ~= Normalize(incoming.q) and not sameSharedContext) then
    state = {
      g = payload.g, q = incoming.q, c = payload.a.c or "", r = payload.r,
      trashScope = incomingTrashScope or ResolvePersonalTrashScope(owner, payload.g, incoming.q),
    }
    storage.mfpPersonalWidgetState = state
  end
  state.c, state.r = payload.a.c or state.c or "", payload.r
  if sender and sender ~= "" then state.sourceSender = RecipientKey(sender) end
  local raid = FindPackedRaid(payload.a, incoming.q)
  if raid and not sameSharedContext then state.raid = DeepCopy(raid) end
  if not state.raid then
    local full = GetStoredFullPayload(owner, payload.g)
    state.raid = DeepCopy(full and FindPackedRaid(full.a, incoming.q) or { i = incoming.q, n = incoming.q, c = state.c })
  end
  SeedPersonalWidgetTrash(owner, state)
  if incoming.t == true then
    state.trash = DeepCopy(incoming)
    state.trashScope = RegisterPersonalTrashScope(storage, payload.g, incoming)
  else
    -- The full snapshot remains the all-rows UI source. A targeted boss/widget
    -- delta stores only Additional rows visible to this receiver's assignee;
    -- unrelated personal additions never enter the personal projection.
    state.boss = FilterPersonalAdditionalRows(owner, incoming)
  end
  storage.localPersonalRaidRaw = nil
  if owner.InvalidateLocalPersonalRaidAssignmentParse then owner:InvalidateLocalPersonalRaidAssignmentParse() end
  storage.personalRaidSelection = nil
  storage.activePersonalRaidImportId = nil
  storage.activePersonalRaidBossKey = nil
  InvalidateCanonicalPersonalImport(owner)
  return true
end

function MerfinPlus:ApplyLocalCanonicalBossDelta(payload)
  if type(payload) ~= "table" or payload.k ~= "D" then return nil, "Local widget update requires one canonical boss delta." end
  local merged, mergeError = UpdatePersonalWidgetState(self, payload)
  if not merged then return nil, mergeError end
  if self.NotifyAssignmentWidgetContentChanged then
    self:NotifyAssignmentWidgetContentChanged()
  else
    if self.RefreshAssignmentWidget then self:RefreshAssignmentWidget() end
    if self.RefreshRaidLeaderWidget then self:RefreshRaidLeaderWidget() end
  end
  return true
end

local function ClearPersonalTrashCacheForGroup(storage, groupID)
  local prefix = Normalize(groupID) .. "\31"
  for _, cache in ipairs({ GetPersonalTrashCache(storage), GetPersonalTrashScopes(storage) }) do
    for key in pairs(cache) do
      if tostring(key):sub(1, #prefix) == prefix then cache[key] = nil end
    end
  end
end

local function FindPackedSharedTrash(assignments)
  for _, boss in ipairs(assignments and assignments.bs or {}) do
    if boss.t == true and IsText(boss.tg, 128, true) and IsText(boss.ta, 128, true)
      and type(boss.tm) == "table" and #boss.tm >= 2
    then
      return boss
    end
  end
end

function MerfinPlus:ResetPersonalAssignmentWidgetFromFullSync(payload, sender)
  if type(payload) ~= "table" or payload.k ~= "F" or type(payload.a) ~= "table" then
    return nil, "Personal widget reset requires one canonical full snapshot."
  end

  local storage = self:GetRaidAssignmentStorage()
  ClearPersonalTrashCacheForGroup(storage, payload.g)
  for _, boss in ipairs(payload.a and payload.a.bs or {}) do
    if boss.t == true then RegisterPersonalTrashScope(storage, payload.g, boss) end
  end

  -- A full snapshot is the Addon UI source of truth, never the personal
  -- widget's boss selection. Replace any older personal boss projection and
  -- seed only the explicitly shared Trash assignment. A later D delta adds
  -- exactly one selected boss while retaining this shared Trash entry.
  storage.personalRaidSelection = nil
  storage.activePersonalRaidImportId = nil
  storage.activePersonalRaidBossKey = nil
  storage.localPersonalRaidRaw = nil
  if self.InvalidateLocalPersonalRaidAssignmentParse then self:InvalidateLocalPersonalRaidAssignmentParse() end

  local trash = FindPackedSharedTrash(payload.a)
  local raid = trash and FindPackedRaid(payload.a, trash.q) or nil
  if trash and raid then
    storage.mfpPersonalWidgetState = {
      g = payload.g,
      q = trash.q,
      c = payload.a.c or "",
      r = payload.r,
      trashScope = RegisterPersonalTrashScope(storage, payload.g, trash),
      trash = DeepCopy(trash),
      raid = DeepCopy(raid),
      sourceSender = sender and sender ~= "" and RecipientKey(sender) or nil,
    }
  else
    storage.mfpPersonalWidgetState = nil
  end
  InvalidateCanonicalPersonalImport(self)
  return true
end

function MerfinPlus:BuildCanonicalPersonalRaidAssignmentImport()
  local state = self:GetRaidAssignmentStorage().mfpPersonalWidgetState
  if not state or not state.raid then return nil end
  local cached = self.mfpCanonicalPersonalImportCache
  if cached and cached.state == state then return cached.entry end
  local bosses = {}
  if state.trash then bosses[#bosses + 1] = DeepCopy(state.trash) end
  if state.boss then bosses[#bosses + 1] = DeepCopy(state.boss) end
  if #bosses == 0 then return nil end
  local assignments = { c = state.c or "", rs = { DeepCopy(state.raid) }, bs = bosses }
  local entry = {
    id = "mfpra-personal:" .. tostring(state.g) .. ":" .. tostring(state.q),
    raidGroup = state.g,
    protocol = SCHEMA,
    parsed = UnpackAssignments(assignments),
    receivedBroadcast = true,
    canonicalPersonal = true,
  }
  self.mfpCanonicalPersonalImportCache = { state = state, entry = entry }
  return entry
end

local function ApplyPlanDelta(owner, payload)
  local entry = owner:GetRaidAssignmentImportForGroup(payload.g)
  if not entry or not entry.canonicalRaw then return nil, "A full MFPRA snapshot is required before a Plan delta." end
  local full = entry.parsed and entry.parsed.canonical
  local decodeError
  if not full then full, decodeError = owner:DecodeCanonicalRaidAssignmentEnvelope(entry.canonicalRaw) end
  if not full or full.k ~= "F" then return nil, decodeError or "The local full MFPRA snapshot is invalid." end
  local globalIndex = tonumber(tostring(payload.i):match("%.plan%.(%d+)$"))
  if not globalIndex or not full.p.l[globalIndex] then return nil, "Plan delta planId is not present in the full snapshot." end
  local expectedBoss = table.concat({ "bp", Normalize(payload.p.raid), (Normalize(payload.p.boss)) }, ".")
  if payload.b ~= expectedBoss then return nil, "Plan delta bossId does not match its plan." end
  local replacement = DeepCopy(full)
  replacement.h = nil
  replacement.p.l[globalIndex] = DeepCopy(payload.p)
  local updatedRaw, updatedPayload = owner:EncodeCanonicalRaidAssignmentEnvelope(replacement)
  if not updatedRaw then return nil, updatedPayload end
  local parsed = UnpackAssignments(updatedPayload.a)
  local legacyRaw = SerializeInternalLegacy(parsed)
  AttachPlans(parsed, updatedPayload, legacyRaw)
  entry.canonicalRaw, entry.canonicalSignature, entry.raw = updatedRaw, ContentSignature(updatedRaw), legacyRaw
  if owner.CacheRaidAssignmentEntryParse then owner:CacheRaidAssignmentEntryParse(entry, parsed) else entry.parsed = parsed end
  owner:NotifyRaidAssignmentsChanged()
  return true, entry
end

local function ApplyIncoming(owner, raw, payload, sender)
  local storage = owner:GetRaidAssignmentStorage()
  storage.mfpReceivedRevisions = storage.mfpReceivedRevisions or {}
  local identity = payload.k == "P" and payload.i or payload.k == "D" and payload.b or "full"
  local revisionKey = payload.k .. ":" .. payload.g .. ":" .. tostring(identity)
  local previous = tonumber(storage.mfpReceivedRevisions[revisionKey]) or 0
  if payload.r <= previous then return true, "stale", 0 end
  if payload.k == "F" then
    local parsed = UnpackAssignments(payload.a)
    local entry, errorText = StoreCanonicalFull(owner, raw, payload, parsed, true, sender, nil, true)
    if not entry then return nil, errorText end
    local reset, resetError = owner:ResetPersonalAssignmentWidgetFromFullSync(payload, sender)
    if not reset then return nil, resetError end
    storage.mfpReceivedRevisions[revisionKey] = payload.r
    if owner.RefreshOpenBossPlanFromImport then owner:RefreshOpenBossPlanFromImport(entry, sender, payload.r) end
    owner:NotifyRaidAssignmentsChanged()
    return true, "applied", CountRows(parsed)
  elseif payload.k == "D" then
    local parsed = UnpackAssignments(payload.a)
    local merged, mergeError = UpdatePersonalWidgetState(owner, payload, sender)
    if not merged then return nil, mergeError end
    storage.mfpReceivedRevisions[revisionKey] = payload.r
    if owner.NotifyAssignmentWidgetContentChanged then
      owner:NotifyAssignmentWidgetContentChanged()
    else
      if owner.RefreshAssignmentWidget then owner:RefreshAssignmentWidget() end
      if owner.RefreshRaidLeaderWidget then owner:RefreshRaidLeaderWidget() end
    end
    if type(owner.RecordReceivedGurtoggAssignmentsForBoss) == "function" then
      owner:RecordReceivedGurtoggAssignmentsForBoss(payload.b, sender)
    end
    if type(owner.RecordReceivedInterruptAssignmentsForBoss) == "function" then
      owner:RecordReceivedInterruptAssignmentsForBoss(payload.b, sender)
    end
    if type(owner.RecordReceivedIllidanPhase2AssignmentsForBoss) == "function" then
      owner:RecordReceivedIllidanPhase2AssignmentsForBoss(payload.b, sender)
    end
    return true, "applied", CountRows(parsed)
  end
  local applied, entryOrError = ApplyPlanDelta(owner, payload)
  if not applied then return nil, entryOrError end
  storage.mfpReceivedRevisions[revisionKey] = payload.r
  if owner.RefreshOpenBossPlanFromImport then owner:RefreshOpenBossPlanFromImport(entryOrError, sender, payload.r) end
  return true, "applied", 1
end

local function SendFeedback(owner, sender, fields, responsePrefix)
  owner:SendAssignmentAddonMessage(responsePrefix or ADDON_PREFIX, table.concat(fields, "|"), sender, "WHISPER", "ALERT")
end

function MerfinPlus:HandleRaidAssignmentAddonMessage(_, prefix, message, channel, sender)
  if prefix ~= ADDON_PREFIX and prefix ~= LEGACY_ADDON_PREFIX then return end
  message = tostring(message or "")
  local queryID = message:match("^Q|([^|]+)|[^|]+$")
  if queryID then
    if self:IsAuthorizedRaidAssignmentSender(sender) then
      SendFeedback(self, sender, { "V", queryID, (AddonVersion():gsub("|", "")) }, prefix)
    end
    return
  end
  local discoveryID, discoveredVersion = message:match("^V|([^|]+)|([^|]+)$")
  if discoveryID then
    local discovery = self.mfpPendingDiscoveries and self.mfpPendingDiscoveries[discoveryID]
    local recipient = discovery and FindExpectedRecipient(discovery.expected, sender)
    if discovery and recipient and not recipient.responded then
      recipient.responded, recipient.version = true, discoveredVersion
      discovery.respondedCount = discovery.respondedCount + 1
      if discoveredVersion == discovery.version then discovery.eligibleCount = discovery.eligibleCount + 1 end
      if discovery.respondedCount == discovery.candidateCount then FinalizeFullDiscovery(self, discoveryID) end
    end
    return
  end
  local ackID, ackKind, ackRevision, ackHash, ackStatus, ackVersion = message:match("^A|([^|]+)|([FDP])|(%d+)|(%x+)|([^|]+)|([^|]+)$")
  if not ackID then
    ackID, ackKind, ackRevision, ackHash, ackStatus = message:match("^A|([^|]+)|([FDP])|(%d+)|(%x+)|([^|]+)$")
  end
  if ackID then
    local pending = self.mfpPendingTransfers and self.mfpPendingTransfers[ackID]
    local recipient = pending and FindExpectedRecipient(pending.expected, sender)
    if pending and recipient and pending.kind == ackKind and pending.revision == tonumber(ackRevision) and pending.hash == ackHash:lower() then
      if not recipient.responded then
        recipient.responded, recipient.confirmed = true, true
        pending.respondedCount = pending.respondedCount + 1
        pending.confirmedCount = pending.confirmedCount + 1
      end
      recipient.version, recipient.status = ackVersion, ackStatus
      SetTransportStatus(self, string.format("%s confirmed receipt.", CleanPlayerName(sender)), pending.confirmedCount == pending.expectedCount and "good" or "muted")
      if pending.respondedCount >= pending.connectedExpectedCount then
        FinalizePendingTransfer(self, ackID)
      else
        UpdatePendingProgress(self, pending, string.format("%d of %d group participants completed the transfer.", pending.confirmedCount, pending.expectedCount))
      end
    end
    return
  end
  local nackID, nackKind, nackRevision, nackHash, nackCode = message:match("^N|([^|]+)|([FDP])|(%d+)|(%x+)|([^|]+)$")
  if nackID then
    local pending = self.mfpPendingTransfers and self.mfpPendingTransfers[nackID]
    local recipient = pending and FindExpectedRecipient(pending.expected, sender)
    if pending and recipient and pending.kind == nackKind and pending.revision == tonumber(nackRevision) and pending.hash == nackHash:lower() then
      if not recipient.responded then
        recipient.responded, recipient.rejected = true, true
        pending.respondedCount = pending.respondedCount + 1
        pending.rejectedCount = pending.rejectedCount + 1
      end
      SetTransportStatus(self, "Receiver rejected MFPRA transfer: " .. tostring(nackCode), "red")
      if pending.respondedCount >= pending.connectedExpectedCount then
        FinalizePendingTransfer(self, nackID)
      else
        UpdatePendingProgress(self, pending, string.format("A recipient rejected the transfer; %d of %d candidates have responded.", pending.respondedCount, pending.expectedCount))
      end
    end
    return
  end
  if not self:IsAuthorizedRaidAssignmentSender(sender) then return end
  self.mfpReceiveBuffers = self.mfpReceiveBuffers or {}
  local senderKey = RecipientKey(sender)
  local startID, kind, revisionText, totalText, bytesText, hash = message:match("^S|([^|]+)|([FDPC])|(%d+)|(%d+)|(%d+)|(%x+)$")
  if startID then
    local revision, total, bytes = tonumber(revisionText), tonumber(totalText), tonumber(bytesText)
    local legacyTransport = prefix == LEGACY_ADDON_PREFIX
    local envelopePrefixBytes = kind == "C"
      and (legacyTransport and #LEGACY_QUICK_CONTEXT_PREFIX or #QUICK_CONTEXT_PREFIX)
      or (legacyTransport and #LEGACY_CLIPBOARD_PREFIX or #CLIPBOARD_PREFIX)
    if not IsRevision(revision) or total < 1 or total > MAX_CHUNKS
      or bytes < envelopePrefixBytes or bytes > LIMITS.base64Bytes + envelopePrefixBytes or #hash ~= 8
    then
      if kind ~= "C" then SendFeedback(self, sender, { "N", startID, kind, revisionText, hash, "invalid-start" }, prefix) end
      return
    end
    self.mfpReceiveOrder = (self.mfpReceiveOrder or 0) + 1
    self.mfpReceiveBuffers[senderKey .. "\001" .. startID] = { senderKey = senderKey, id = startID, kind = kind, revision = revision, total = total, bytes = bytes, hash = hash, chunks = {}, order = self.mfpReceiveOrder, prefix = prefix }
    -- Event-driven bounded cleanup. Concurrent explicit transfers can finish,
    -- while abandoned buffers cannot grow without bound and need no timer.
    local senderBuffers, oldestKey, oldestOrder = 0
    for key, buffer in pairs(self.mfpReceiveBuffers) do
      if buffer.senderKey == senderKey then
        senderBuffers = senderBuffers + 1
        if not oldestOrder or buffer.order < oldestOrder then oldestKey, oldestOrder = key, buffer.order end
      end
    end
    if senderBuffers > 4 and oldestKey ~= senderKey .. "\001" .. startID then self.mfpReceiveBuffers[oldestKey] = nil end
    return
  end
  local dataID, indexText, chunk = message:match("^D|([^|]+)|(%d+)|(.*)$")
  if dataID then
    local buffer = self.mfpReceiveBuffers[senderKey .. "\001" .. dataID]
    local index = tonumber(indexText)
    if buffer and index >= 1 and index <= buffer.total and #chunk <= CHUNK_BYTES then buffer.chunks[index] = chunk end
    return
  end
  local endID, endHash = message:match("^E|([^|]+)|(%x+)$")
  if not endID then return end
  local bufferKey = senderKey .. "\001" .. endID
  local buffer = self.mfpReceiveBuffers[bufferKey]
  if not buffer then return end
  self.mfpReceiveBuffers[bufferKey] = nil
  local chunks = {}
  for index = 1, buffer.total do
    if buffer.chunks[index] == nil then
      if buffer.kind ~= "C" then SendFeedback(self, sender, { "N", endID, buffer.kind, buffer.revision, buffer.hash, "missing-chunk" }, buffer.prefix) end
      return
    end
    chunks[index] = buffer.chunks[index]
  end
  local raw = table.concat(chunks)
  if endHash ~= buffer.hash or #raw ~= buffer.bytes or WireHash(raw) ~= buffer.hash then
    if buffer.kind ~= "C" then
      SendFeedback(self, sender, { "N", endID, buffer.kind, buffer.revision, buffer.hash, "wire-integrity" }, buffer.prefix)
    end
    return
  end
  if buffer.kind == "C" then
    local quickPayload = self:DecodeRaidAssignmentQuickPlanContext(raw)
    if not quickPayload or quickPayload.k ~= "C" or quickPayload.r ~= buffer.revision then return end
    self:ApplyRaidAssignmentQuickPlanContext(quickPayload, sender)
    return
  end
  local payload, decodeError = self:DecodeCanonicalRaidAssignmentEnvelope(raw)
  if not payload or payload.k ~= buffer.kind or payload.r ~= buffer.revision then
    SendFeedback(self, sender, { "N", endID, buffer.kind, buffer.revision, buffer.hash, "invalid-payload" }, buffer.prefix)
    self:SetRaidAssignmentStatus(decodeError or "MFPRA frame metadata mismatch.", "red")
    return
  end
  local applied, status = ApplyIncoming(self, raw, payload, sender)
  if not applied then
    SendFeedback(self, sender, { "N", endID, buffer.kind, buffer.revision, buffer.hash, "apply-failed" }, buffer.prefix)
    self:SetRaidAssignmentStatus(status or "MFPRA apply failed.", "red")
    return
  end
  SendFeedback(self, sender, { "A", endID, buffer.kind, buffer.revision, buffer.hash, status, AddonVersion() }, buffer.prefix)
  self:SetRaidAssignmentStatus(string.format("Received from %s.", CleanPlayerName(sender)), "good")
end
