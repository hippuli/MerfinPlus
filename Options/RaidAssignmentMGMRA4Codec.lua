local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local PREFIX = "MGMRA4:"
local SCHEMA = "MGMRA"
local SUPPORTED_VERSION = 4
local SUPPORTED_CATALOG_VERSION = 1

local LIMITS = {
  base64Bytes = 512 * 1024,
  compressedBytes = 384 * 1024,
  jsonBytes = 2 * 1024 * 1024,
  legacyAssignmentBytes = 256 * 1024,
  plans = 32,
  elementsPerPlan = 512,
  elementsTotal = 4096,
  drawingPointsPerElement = 2048,
  drawingPointsTotal = 32768,
  planNameBytes = 128,
  textBytes = 4096,
  broadcastWarningChars = 16200,
  broadcastLimitChars = 32400,
  broadcastChunkChars = 180,
}

local ELEMENT_TYPES = {
  player = true, ["position-slot"] = true, text = true, emoji = true, arrow = true, ["arrow-down"] = true,
  line = true, box = true, circle = true, triangle = true, cone = true,
  ["raid-marker"] = true, boss = true, image = true, drawing = true,
}

local CANVAS_GEOMETRY_TYPES = {
  line = true, arrow = true, ["arrow-down"] = true,
  box = true, circle = true, triangle = true, cone = true,
}

local TOP_LEVEL_FIELDS = { schema = true, version = true, catalogVersion = true, expansion = true, raidGroup = true, comp = true, legacyAssignments = true, plans = true }
local COMP_FIELDS = { name = true }
local PLAN_FIELDS = { raid = true, boss = true, phase = true, name = true, backgroundAssetId = true, elements = true }
local PLAYER_FIELDS = { name = true, class = true, spec = true }
local ELEMENT_FIELDS = {}
for _, field in ipairs({
  "type", "x", "y", "player", "playerIconRole", "playerNameVisible", "label", "rotation",
  "shapeGeometry", "coneRadius", "coneAngle", "lineStart", "lineEnd", "lineOpacity",
  "lineOutline", "lineOutlineColor", "lineOutlineWidth", "bossFacingVisible", "bossFacingArrowVisible",
  "bossFacingColor", "bossFacingRingWidth", "color", "marker",
  "assetId", "role", "wowClass", "wowSpec", "wowIcon", "spellId", "size", "arrowLength", "width", "height",
  "fill", "fillColor", "fillOpacity", "strokeColor", "strokeWidth", "textColor", "textFont",
  "textAlign", "textVerticalAlign", "textSizing", "textBackdrop", "textBold", "textItalic",
  "textUnderline", "textStrikethrough", "textSize", "textStroke", "textStrokeColor", "textStrokeWidth",
  "positionRole", "rolePosition", "mapPosition", "positionSlotId", "positionAssignMode", "positionClass",
  "positionLabelPosition", "positionLabelGap", "rolePositionVisible", "specialAssignmentKey", "drawingMode", "drawingPoints", "drawingWidth",
  "drawingHeight", "drawingFadeOut", "centerDot", "polygonSides", "pinnedTo", "facing", "locked",
}) do ELEMENT_FIELDS[field] = true end
local RAID_MARKERS = { star = true, circle = true, diamond = true, triangle = true, moon = true, square = true, cross = true, skull = true }
local RAID_ROLES = { tank = true, heal = true, melee = true, ranged = true }
local TEXT_FONTS = MerfinPlus:GetRaidAssignmentFontTokenSet()
local EMOJI_ASSET_IDS = {}
for _, id in ipairs({
  "smiley", "expressionless", "laugh", "wink", "heart-eyes", "sad", "cry", "angry",
  "surprised", "confused", "cool", "skull", "heart", "warning", "check", "cross",
}) do EMOJI_ASSET_IDS["symbol.emoji." .. id] = true end

local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local BASE64_VALUES = {}
for index = 1, #BASE64_ALPHABET do
  BASE64_VALUES[BASE64_ALPHABET:sub(index, index)] = index - 1
end

local function DecodeBase64(encoded)
  if encoded == "" then
    return nil, "MGMRA4 payload is empty."
  end
  if #encoded % 4 ~= 0 then
    return nil, "MGMRA4 payload is not valid padded Base64."
  end

  local output = {}
  local outputIndex = 1
  for index = 1, #encoded, 4 do
    local c1 = encoded:sub(index, index)
    local c2 = encoded:sub(index + 1, index + 1)
    local c3 = encoded:sub(index + 2, index + 2)
    local c4 = encoded:sub(index + 3, index + 3)
    local v1, v2 = BASE64_VALUES[c1], BASE64_VALUES[c2]
    local v3 = c3 == "=" and nil or BASE64_VALUES[c3]
    local v4 = c4 == "=" and nil or BASE64_VALUES[c4]
    local finalGroup = index + 3 == #encoded

    if v1 == nil or v2 == nil or (c3 ~= "=" and v3 == nil) or (c4 ~= "=" and v4 == nil) then
      return nil, "MGMRA4 payload contains invalid Base64 characters."
    end
    if (c3 == "=" and c4 ~= "=") or ((c3 == "=" or c4 == "=") and not finalGroup) then
      return nil, "MGMRA4 payload contains invalid Base64 padding."
    end

    output[outputIndex] = string.char(math.floor(v1 * 4 + v2 / 16))
    outputIndex = outputIndex + 1
    if c3 ~= "=" then
      output[outputIndex] = string.char((v2 % 16) * 16 + math.floor(v3 / 4))
      outputIndex = outputIndex + 1
    end
    if c4 ~= "=" then
      output[outputIndex] = string.char((v3 % 4) * 64 + v4)
      outputIndex = outputIndex + 1
    end
  end
  return table.concat(output)
end

local function EncodeBase64(value)
  local output = {}
  for index = 1, #value, 3 do
    local first = value:byte(index)
    local second = value:byte(index + 1)
    local third = value:byte(index + 2)
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

local function EncodeCanonicalJSON(value)
  if type(value) ~= "table" then
    return MerfinPlusJSON.encode(value)
  end
  local count, maximum, isArray = 0, 0, true
  for key in pairs(value) do
    count = count + 1
    if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
      isArray = false
    else
      maximum = math.max(maximum, key)
    end
  end
  if isArray and maximum == count then
    local values = {}
    for index = 1, maximum do values[index] = EncodeCanonicalJSON(value[index]) end
    return "[" .. table.concat(values, ",") .. "]"
  end
  local keys = {}
  for key in pairs(value) do
    if type(key) ~= "string" then error("MGMRA4 JSON objects require string keys.") end
    keys[#keys + 1] = key
  end
  table.sort(keys)
  local fields = {}
  for index, key in ipairs(keys) do
    fields[index] = MerfinPlusJSON.encode(key) .. ":" .. EncodeCanonicalJSON(value[key])
  end
  return "{" .. table.concat(fields, ",") .. "}"
end

local function GetLibDeflate()
  if LibStub then
    local library = LibStub("LibDeflate", true)
    if library then
      return library
    end
  end
  return _G.LibDeflate
end

local function IsValidUTF8(value)
  local index, length = 1, #value
  while index <= length do
    local first = value:byte(index)
    if first <= 0x7F then
      index = index + 1
    else
      local continuationCount, minimumCodePoint, codePoint
      if first >= 0xC2 and first <= 0xDF then
        continuationCount, minimumCodePoint, codePoint = 1, 0x80, first - 0xC0
      elseif first >= 0xE0 and first <= 0xEF then
        continuationCount, minimumCodePoint, codePoint = 2, 0x800, first - 0xE0
      elseif first >= 0xF0 and first <= 0xF4 then
        continuationCount, minimumCodePoint, codePoint = 3, 0x10000, first - 0xF0
      else
        return false
      end
      if index + continuationCount > length then return false end
      for offset = 1, continuationCount do
        local continuation = value:byte(index + offset)
        if continuation < 0x80 or continuation > 0xBF then return false end
        codePoint = codePoint * 0x40 + continuation - 0x80
      end
      if codePoint < minimumCodePoint or codePoint > 0x10FFFF
        or (codePoint >= 0xD800 and codePoint <= 0xDFFF) then
        return false
      end
      index = index + continuationCount + 1
    end
  end
  return true
end

local function IsFiniteNumber(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function ValidateText(value, label, limit, required)
  if value == nil and not required then
    return true
  end
  if type(value) ~= "string" or (required and value == "") then
    return nil, label .. " must be text."
  end
  if limit and #value > limit then
    return nil, label .. " exceeds " .. tostring(limit) .. " UTF-8 bytes."
  end
  return true
end

local function ValidateBoundedNumber(value, label, minimum, maximum, required)
  if value == nil and not required then
    return true
  end
  if not IsFiniteNumber(value) or value < minimum or value > maximum then
    return nil, label .. " must be a finite number from " .. tostring(minimum) .. " to " .. tostring(maximum) .. "."
  end
  return true
end

local function ValidateFiniteNumber(value, label)
  if value ~= nil and not IsFiniteNumber(value) then
    return nil, label .. " must be finite."
  end
  return true
end

local function ValidateBoolean(value, label)
  if value ~= nil and type(value) ~= "boolean" then
    return nil, label .. " must be a boolean."
  end
  return true
end

local function ValidateArray(value, label, maximum)
  if type(value) ~= "table" then
    return nil, label .. " must be an array."
  end
  local length = #value
  if maximum and length > maximum then
    return nil, label .. " exceeds " .. tostring(maximum) .. "."
  end
  for key in pairs(value) do
    if type(key) ~= "number" or key < 1 or key > length or key % 1 ~= 0 then
      return nil, label .. " must be a dense JSON array."
    end
  end
  return length
end

local function ValidateEnum(value, label, allowed)
  if value ~= nil and not allowed[value] then
    return nil, label .. " is unsupported."
  end
  return true
end

local function RejectUnknownFields(value, allowed, label)
  for field in pairs(value) do
    if type(field) ~= "string" or not allowed[field] then
      return nil, (label ~= "" and (label .. ".") or "") .. tostring(field) .. " is not supported by MGMRA4."
    end
  end
  return true
end

local function ValidateColor(value, label)
  if value ~= nil and (type(value) ~= "string" or not value:match("^#%x%x%x%x%x%x$")) then
    return nil, label .. " must be #RRGGBB."
  end
  return true
end

local function ValidateDrawingPoints(points, planIndex, elementIndex, totals)
  if points == nil then
    return true
  end
  local label = "plans[" .. planIndex .. "].elements[" .. elementIndex .. "].drawingPoints"
  local count, errorText = ValidateArray(points, label, LIMITS.drawingPointsPerElement)
  if not count then
    return nil, errorText
  end
  totals.drawingPoints = totals.drawingPoints + count
  if totals.drawingPoints > LIMITS.drawingPointsTotal then
    return nil, "drawingPoints exceeds " .. tostring(LIMITS.drawingPointsTotal) .. " total."
  end
  for pointIndex, point in ipairs(points) do
    local pointLabel = label .. "[" .. pointIndex .. "]"
    local pointLength, pointError = ValidateArray(point, pointLabel, 2)
    if not pointLength or pointLength ~= 2 then
      return nil, pointError or (pointLabel .. " must be [x,y].")
    end
    local ok
    ok, pointError = ValidateBoundedNumber(point[1], pointLabel .. "[0]", -50, 150, true)
    if not ok then return nil, pointError end
    ok, pointError = ValidateBoundedNumber(point[2], pointLabel .. "[1]", -50, 150, true)
    if not ok then return nil, pointError end
  end
  return true
end

local function ValidatePlayer(player, label, required)
  if player == nil and not required then
    return true
  end
  if type(player) ~= "table" then
    return nil, label .. " must be an object."
  end
  local fieldsOK, fieldsError = RejectUnknownFields(player, PLAYER_FIELDS, label)
  if not fieldsOK then return nil, fieldsError end
  local ok, errorText = ValidateText(player.name, label .. ".name", 128, true)
  if not ok then return nil, errorText end
  ok, errorText = ValidateText(player.class, label .. ".class", 64, true)
  if not ok then return nil, errorText end
  return ValidateText(player.spec, label .. ".spec", 64, false)
end

local function ValidateElement(element, planIndex, elementIndex, elementCount, totals)
  local label = "plans[" .. planIndex .. "].elements[" .. elementIndex .. "]"
  if type(element) ~= "table" then
    return nil, label .. " must be an object."
  end
  local fieldsOK, fieldsError = RejectUnknownFields(element, ELEMENT_FIELDS, label)
  if not fieldsOK then return nil, fieldsError end
  if type(element.type) ~= "string" or not ELEMENT_TYPES[element.type] then
    return nil, label .. ".type is unsupported."
  end

  local ok, errorText = ValidateBoundedNumber(element.x, label .. ".x", -50, 150, true)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.y, label .. ".y", -50, 150, true)
  if not ok then return nil, errorText end

  ok, errorText = ValidateBoundedNumber(element.size, label .. ".size", 0, 1000, false)
  if not ok then return nil, errorText end
  for _, field in ipairs({ "arrowLength", "width", "height", "drawingWidth", "drawingHeight" }) do
    ok, errorText = ValidateBoundedNumber(element[field], label .. "." .. field, 0.1, 200, false)
    if not ok then return nil, errorText end
  end
  if element.shapeGeometry ~= nil then
    if element.shapeGeometry ~= "canvas" then return nil, label .. ".shapeGeometry is unsupported." end
    if not CANVAS_GEOMETRY_TYPES[element.type] then return nil, label .. ".shapeGeometry requires a shape." end
  end
  ok, errorText = ValidateBoundedNumber(element.coneRadius, label .. ".coneRadius", 0.01, 200, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.coneAngle, label .. ".coneAngle", 1, 359, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.lineOpacity, label .. ".lineOpacity", 0, 100, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.lineOutlineWidth, label .. ".lineOutlineWidth", 0, 200, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.positionLabelGap, label .. ".positionLabelGap", -20, 40, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.fillOpacity, label .. ".fillOpacity", 0, 100, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateFiniteNumber(element.rotation, label .. ".rotation")
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.strokeWidth, label .. ".strokeWidth", 0, 200, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.textSize, label .. ".textSize", 0.1, 200, false)
  if not ok then return nil, errorText end
  ok, errorText = ValidateBoundedNumber(element.textStrokeWidth, label .. ".textStrokeWidth", 0, 200, false)
  if not ok then return nil, errorText end
  if element.rolePosition ~= nil and (not IsFiniteNumber(element.rolePosition) or element.rolePosition % 1 ~= 0 or element.rolePosition < 0 or element.rolePosition > 512) then
    return nil, label .. ".rolePosition must be an integer from 0 to 512."
  end
  if element.mapPosition ~= nil and (not IsFiniteNumber(element.mapPosition) or element.mapPosition % 1 ~= 0 or element.mapPosition < 0 or element.mapPosition > 512) then
    return nil, label .. ".mapPosition must be an integer from 0 to 512."
  end
  if element.polygonSides ~= nil and (not IsFiniteNumber(element.polygonSides) or element.polygonSides % 1 ~= 0 or element.polygonSides < 3 or element.polygonSides > 64) then
    return nil, label .. ".polygonSides must be an integer from 3 to 64."
  end
  if element.spellId ~= nil and (not IsFiniteNumber(element.spellId) or element.spellId % 1 ~= 0 or element.spellId < 1 or element.spellId > 1000000000) then
    return nil, label .. ".spellId must be a positive integer."
  end

  for _, field in ipairs({ "bossFacingColor", "color", "fillColor", "strokeColor", "lineOutlineColor", "textColor", "textStrokeColor" }) do
    ok, errorText = ValidateColor(element[field], label .. "." .. field)
    if not ok then return nil, errorText end
  end
  for _, field in ipairs({ "label", "assetId", "role", "wowClass", "wowSpec", "wowIcon", "marker", "textFont", "positionRole", "positionSlotId", "positionClass", "specialAssignmentKey" }) do
    ok, errorText = ValidateText(element[field], label .. "." .. field, LIMITS.textBytes, false)
    if not ok then return nil, errorText end
  end

  if element.assetId then
    if element.type == "emoji" and EMOJI_ASSET_IDS[element.assetId] then
      -- MerfinPlus-owned symbol IDs are deterministic MGMRA4 extension tokens;
      -- the label stays present as a compatibility fallback for older clients.
    else
      if not element.assetId:match("^bp%.[a-z0-9-]+%.[a-z0-9-]+%.[a-z0-9-]+%.[a-z0-9-]+%.[a-z0-9-]+$") then
        return nil, label .. ".assetId must be a canonical bp.* or supported symbol.emoji.* ID."
      end
      local _, assetError = MerfinPlus:ValidateTBCBossPlanAssetReference(element.assetId)
      if assetError then return nil, assetError end
    end
  end

  ok, errorText = ValidatePlayer(element.player, label .. ".player", element.type == "player")
  if not ok then return nil, errorText end
  for _, field in ipairs({
    "playerNameVisible", "lineOutline", "bossFacingVisible", "bossFacingArrowVisible", "fill", "textBackdrop", "textBold", "textItalic", "textUnderline",
    "textStrikethrough", "textStroke", "rolePositionVisible", "drawingFadeOut", "centerDot", "locked",
  }) do
    ok, errorText = ValidateBoolean(element[field], label .. "." .. field)
    if not ok then return nil, errorText end
  end
  ok, errorText = ValidateBoundedNumber(element.bossFacingRingWidth, label .. ".bossFacingRingWidth", 2, 12, false)
  if not ok then return nil, errorText end

  ok, errorText = ValidateEnum(element.textAlign, label .. ".textAlign", { left = true, center = true, right = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.textVerticalAlign, label .. ".textVerticalAlign", { top = true, middle = true, bottom = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.textSizing, label .. ".textSizing", { auto = true, fixed = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.drawingMode, label .. ".drawingMode", { brush = true, point = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.marker, label .. ".marker", RAID_MARKERS)
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.role, label .. ".role", RAID_ROLES)
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.playerIconRole, label .. ".playerIconRole", RAID_ROLES)
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.positionRole, label .. ".positionRole", RAID_ROLES)
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.lineStart, label .. ".lineStart", { none = true, arrow = true, solid = true, circle = true, bar = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.lineEnd, label .. ".lineEnd", { none = true, arrow = true, solid = true, circle = true, bar = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.positionAssignMode, label .. ".positionAssignMode", { any = true, role = true, class = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.positionLabelPosition, label .. ".positionLabelPosition", { top = true, right = true, bottom = true, left = true })
  if not ok then return nil, errorText end
  ok, errorText = ValidateEnum(element.textFont, label .. ".textFont", TEXT_FONTS)
  if not ok then return nil, errorText end

  if element.type == "raid-marker" and not RAID_MARKERS[element.marker] then
    return nil, label .. ".marker is required for raid-marker elements."
  end
  if element.type == "boss" then
    if not element.assetId then return nil, label .. ".assetId is required for boss elements." end
    local _, assetError = MerfinPlus:ValidateTBCBossPlanAssetReference(element.assetId, "portrait")
    if assetError then return nil, assetError end
  elseif element.type == "image" then
    local sources = 0
    for _, field in ipairs({ "assetId", "role", "wowClass", "wowIcon", "spellId" }) do
      if element[field] ~= nil then sources = sources + 1 end
    end
    if sources ~= 1 then return nil, label .. " must contain exactly one image source token." end
    if element.wowSpec ~= nil and element.wowClass == nil then
      return nil, label .. ".wowSpec requires wowClass."
    end
  end

  for _, field in ipairs({ "pinnedTo", "facing" }) do
    local relation = element[field]
    if relation ~= nil and (not IsFiniteNumber(relation) or relation % 1 ~= 0 or relation < 0 or relation >= elementCount) then
      return nil, label .. "." .. field .. " must reference a local element index."
    end
  end
  return ValidateDrawingPoints(element.drawingPoints, planIndex, elementIndex, totals)
end

local function ValidatePlan(plan, planIndex, totals)
  local label = "plans[" .. planIndex .. "]"
  if type(plan) ~= "table" then
    return nil, label .. " must be an object."
  end
  local fieldsOK, fieldsError = RejectUnknownFields(plan, PLAN_FIELDS, label)
  if not fieldsOK then return nil, fieldsError end
  local ok, errorText = ValidateText(plan.raid, label .. ".raid", 128, true)
  if not ok then return nil, errorText end
  ok, errorText = ValidateText(plan.boss, label .. ".boss", 128, true)
  if not ok then return nil, errorText end
  ok, errorText = ValidateText(plan.name, label .. ".name", LIMITS.planNameBytes, true)
  if not ok then return nil, errorText end
  ok, errorText = ValidateText(plan.backgroundAssetId, label .. ".backgroundAssetId", 256, false)
  if not ok then return nil, errorText end
  if plan.backgroundAssetId then
    if not plan.backgroundAssetId:match("^bp%.") or plan.backgroundAssetId:find("/", 1, true) then
      return nil, label .. ".backgroundAssetId must be a canonical bp.* ID."
    end
    local _, assetError = MerfinPlus:ValidateTBCBossPlanAssetReference(plan.backgroundAssetId, "background")
    if assetError then return nil, assetError end
  end
  if plan.phase ~= nil and (not IsFiniteNumber(plan.phase) or plan.phase % 1 ~= 0 or plan.phase < 1 or plan.phase > 32) then
    return nil, label .. ".phase must be an integer from 1 to 32."
  end

  local elementCount
  elementCount, errorText = ValidateArray(plan.elements, label .. ".elements", LIMITS.elementsPerPlan)
  if not elementCount then return nil, errorText end
  totals.elements = totals.elements + elementCount
  if totals.elements > LIMITS.elementsTotal then
    return nil, "elements exceeds " .. tostring(LIMITS.elementsTotal) .. " total."
  end
  for elementIndex, element in ipairs(plan.elements) do
    ok, errorText = ValidateElement(element, planIndex, elementIndex, elementCount, totals)
    if not ok then return nil, errorText end
  end
  return true
end

local function ValidateEnvelope(payload)
  if type(payload) ~= "table" then
    return nil, "MGMRA4 payload must be an object."
  end
  local fieldsOK, fieldsError = RejectUnknownFields(payload, TOP_LEVEL_FIELDS, "")
  if not fieldsOK then return nil, fieldsError end
  if payload.schema ~= SCHEMA then
    return nil, "schema must be MGMRA."
  end
  if payload.version ~= SUPPORTED_VERSION then
    return nil, "version must be 4."
  end
  if payload.catalogVersion ~= SUPPORTED_CATALOG_VERSION then
    return nil, "Unsupported MGMRA4 catalogVersion. This addon supports catalogVersion 1."
  end
  if payload.expansion ~= "tbc" then
    return nil, "expansion must be tbc for catalog version 1."
  end

  local ok, errorText = ValidateText(payload.raidGroup, "raidGroup", 128, true)
  if not ok then return nil, errorText end
  if type(payload.comp) ~= "table" then
    return nil, "comp must be an object."
  end
  fieldsOK, fieldsError = RejectUnknownFields(payload.comp, COMP_FIELDS, "comp")
  if not fieldsOK then return nil, fieldsError end
  ok, errorText = ValidateText(payload.comp.name, "comp.name", 128, true)
  if not ok then return nil, errorText end
  ok, errorText = ValidateText(payload.legacyAssignments, "legacyAssignments", LIMITS.legacyAssignmentBytes, true)
  if not ok then return nil, errorText end
  if payload.legacyAssignments:sub(1, 8) ~= "MGMRA|3\n" then
    return nil, "legacyAssignments must contain an MGMRA|3 export."
  end

  local planCount
  planCount, errorText = ValidateArray(payload.plans, "plans", LIMITS.plans)
  if not planCount then return nil, errorText end
  local totals = { elements = 0, drawingPoints = 0 }
  for planIndex, plan in ipairs(payload.plans) do
    ok, errorText = ValidatePlan(plan, planIndex, totals)
    if not ok then return nil, errorText end
  end
  return payload
end

function MerfinPlus:IsMGMRA4Envelope(raw)
  return type(raw) == "string" and raw:sub(1, #PREFIX) == PREFIX
end

function MerfinPlus:GetMGMRA4Limits()
  return LIMITS
end

-- MGMRA4 remains an internal SavedVariables/editor compatibility model.  The
-- canonical MFPRA codec reuses its exhaustive Boss Plan validation without
-- accepting MGMRA4 as a clipboard or network protocol.
function MerfinPlus:ValidateMGMRA4Payload(payload)
  return ValidateEnvelope(payload)
end

function MerfinPlus:IsValidRaidAssignmentUTF8(value)
  return type(value) == "string" and IsValidUTF8(value)
end

function MerfinPlus:DecodeAndValidateMGMRA4Envelope(raw)
  if not self:IsMGMRA4Envelope(raw) then
    return nil, "Expected an MGMRA4: payload."
  end
  local encoded = raw:sub(#PREFIX + 1)
  if #encoded > LIMITS.base64Bytes then
    return nil, "MGMRA4 Base64 payload exceeds the 512 KiB limit."
  end
  local compressed, decodeError = DecodeBase64(encoded)
  if not compressed then return nil, decodeError end
  if #compressed > LIMITS.compressedBytes then
    return nil, "MGMRA4 compressed payload exceeds the 384 KiB limit."
  end

  local libDeflate = GetLibDeflate()
  if not libDeflate or type(libDeflate.DecompressZlib) ~= "function" then
    return nil, "MGMRA4 requires LibDeflate with DecompressZlib support."
  end
  local decompressedOK, jsonText, decompressionStatus = pcall(libDeflate.DecompressZlib, libDeflate, compressed)
  if not decompressedOK or type(jsonText) ~= "string" then
    return nil, "MGMRA4 zlib decompression failed (status " .. tostring(decompressionStatus or "unknown") .. ")."
  end
  if #jsonText > LIMITS.jsonBytes then
    return nil, "MGMRA4 decompressed JSON exceeds the 2 MiB limit."
  end
  if not IsValidUTF8(jsonText) then
    return nil, "MGMRA4 JSON is not valid UTF-8."
  end

  if not MerfinPlusJSON or type(MerfinPlusJSON.decode) ~= "function" then
    return nil, "MGMRA4 JSON decoder is unavailable."
  end
  local jsonOK, payload = pcall(MerfinPlusJSON.decode, jsonText)
  if not jsonOK then
    return nil, "MGMRA4 JSON is invalid."
  end
  return ValidateEnvelope(payload)
end

function MerfinPlus:EncodeMGMRA4Envelope(payload)
  local valid, validationError = ValidateEnvelope(payload)
  if not valid then return nil, validationError end
  if not MerfinPlusJSON or type(MerfinPlusJSON.encode) ~= "function" then
    return nil, "MGMRA4 JSON encoder is unavailable."
  end
  local jsonOK, jsonText = pcall(EncodeCanonicalJSON, payload)
  if not jsonOK or type(jsonText) ~= "string" then
    return nil, "MGMRA4 JSON encoding failed."
  end
  if #jsonText > LIMITS.jsonBytes then
    return nil, "MGMRA4 decompressed JSON exceeds the 2 MiB limit."
  end
  local libDeflate = GetLibDeflate()
  if not libDeflate or type(libDeflate.CompressZlib) ~= "function" then
    return nil, "MGMRA4 requires LibDeflate with CompressZlib support."
  end
  local compressedOK, compressed = pcall(libDeflate.CompressZlib, libDeflate, jsonText, { level = 9 })
  if not compressedOK or type(compressed) ~= "string" then
    return nil, "MGMRA4 zlib compression failed."
  end
  if #compressed > LIMITS.compressedBytes then
    return nil, "MGMRA4 compressed payload exceeds the 384 KiB limit."
  end
  local envelope = PREFIX .. EncodeBase64(compressed)
  if #envelope - #PREFIX > LIMITS.base64Bytes then
    return nil, "MGMRA4 Base64 payload exceeds the 512 KiB limit."
  end
  local decoded, decodeError = self:DecodeAndValidateMGMRA4Envelope(envelope)
  if not decoded then return nil, decodeError end
  return envelope
end
