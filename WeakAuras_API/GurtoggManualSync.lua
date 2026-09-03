-- Gurtogg group transport for Guild Manager and manual assignment sources.
local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local PREFIX, MAX_BYTES = "MFGURT1", 4096
local CHUNK_BYTES, MAX_CHUNKS = 160, 32
local incoming, outgoing = {}, {}

local function announce(message)
  local text = "|cff57d9ffMerfinPlus Gurtogg Groups:|r " .. tostring(message)
  if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
    DEFAULT_CHAT_FRAME:AddMessage(text)
  end
end

local function shortName(value)
  local name = tostring(value or ""):match("^([^%-]+)")
  return name and name:lower() or ""
end

local function isAuthorizedSender(sender)
  local wanted = shortName(sender)
  if wanted == "" then return false end
  if UnitIsGroupLeader("player") and wanted == shortName(UnitName("player")) then return true end
  local inRaid = IsInRaid and IsInRaid()
  local count = GetNumGroupMembers and GetNumGroupMembers() or 0
  local prefix = inRaid and "raid" or "party"
  for i = 1, count do
    local unit = prefix .. i
    if shortName(UnitName(unit)) == wanted and (UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)) then return true end
  end
  return false
end

local function canBroadcast()
  return IsInGroup and IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
end

local function unitForName(name)
  local wanted = shortName(name)
  if wanted == "" then return nil end
  if shortName(UnitName("player")) == wanted then return "player" end
  local prefix = IsInRaid and IsInRaid() and "raid" or "party"
  local count = GetNumGroupMembers and GetNumGroupMembers() or 0
  for i = 1, count do
    local unit = prefix .. i
    if shortName(UnitName(unit)) == wanted then return unit end
  end
  return nil
end

local function coloredName(name)
  local unit = unitForName(name)
  local classToken
  if unit then
    classToken = select(2, UnitClass(unit))
  end
  local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
  local colorCode = color and (color.colorStr or string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255))
  local display = tostring(name or ""):match("^([^%-]+)") or tostring(name or "")
  return colorCode and ("|c" .. colorCode .. display .. "|r") or display
end

local function normalize(snapshot, forcedMode)
  if type(MerfinPlus.NormalizeGurtoggAssignmentsSnapshot) ~= "function" then return nil end
  return MerfinPlus:NormalizeGurtoggAssignmentsSnapshot(snapshot, forcedMode)
end

local function encode(snapshot)
  local serializer, deflate = LibStub and LibStub("AceSerializer-3.0", true), LibStub and LibStub("LibDeflate", true)
  if not serializer or not deflate then return nil end
  -- AceSerializer:Serialize returns the encoded string directly.  Only
  -- Deserialize returns a success boolean followed by the decoded value.
  local serialized = serializer:Serialize(snapshot)
  if type(serialized) ~= "string" then return nil end
  local compressed = deflate:CompressDeflate(serialized)
  return compressed and deflate:EncodeForWoWAddonChannel(compressed) or nil
end

local function decode(raw)
  local deflate, serializer = LibStub and LibStub("LibDeflate", true), LibStub and LibStub("AceSerializer-3.0", true)
  if not deflate or not serializer or type(raw) ~= "string" or #raw > MAX_BYTES then return nil end
  local compressed = deflate:DecodeForWoWAddonChannel(raw)
  local serialized = compressed and deflate:DecompressDeflate(compressed)
  if type(serialized) ~= "string" then return nil end
  local ok, value = serializer:Deserialize(serialized)
  return ok and normalize(value) or nil
end

function MerfinPlus:BroadcastGurtoggAssignmentsSnapshot(snapshot, sourceMode, trigger)
  if not canBroadcast() then
    announce("Sync failed — only the group leader or an assistant can send.")
    return false, "Only a group leader or assistant can sync manual groups."
  end
  local normalized = normalize(snapshot, sourceMode)
  if normalized and trigger then normalized.source.trigger = tostring(trigger) end
  local payload = normalized and encode(normalized)
  if not payload or #payload > MAX_BYTES then
    announce("Sync failed — group assignments could not be encoded.")
    return false, "Gurtogg group assignments could not be encoded."
  end
  local register = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix
  local send = C_ChatInfo and C_ChatInfo.SendAddonMessage or SendAddonMessage
  -- The prefix is registered at PLAYER_LOGIN.  Re-registering it here is
  -- harmless, but its return value is not a delivery signal and may be false
  -- when it was already registered.
  if not send then
    announce("Sync failed — addon-message transport is unavailable.")
    return false, "Addon-message transport is unavailable."
  end
  if register then register(PREFIX) end
  local chunks = math.max(1, math.ceil(#payload / CHUNK_BYTES))
  if chunks > MAX_CHUNKS then
    announce("Sync failed — group assignments are too large.")
    return false, "Gurtogg group sync is too large."
  end
  self.gurtoggManualSyncSequence = (self.gurtoggManualSyncSequence or 0) + 1
  local transfer = tostring((GetServerTime and GetServerTime()) or time()) .. "-" .. self.gurtoggManualSyncSequence
  local channel = IsInRaid() and "RAID" or "PARTY"
  outgoing[transfer] = { acknowledged = {}, mode = normalized.source.mode }
  send(PREFIX, table.concat({ "S", transfer, chunks }, "|"), channel)
  for index = 1, chunks do
    send(PREFIX, table.concat({ "D", transfer, index, chunks, payload:sub(((index - 1) * CHUNK_BYTES) + 1, index * CHUNK_BYTES) }, "|"), channel)
  end
  self:PublishReceivedGurtoggAssignmentsSnapshot(normalized, UnitName("player"))
  C_Timer.After(1, function()
    local state = outgoing[transfer]
    if not state then return end
    outgoing[transfer] = nil
    local names = {}
    for _, name in pairs(state.acknowledged) do names[#names + 1] = coloredName(name) end
    table.sort(names)
    announce(#names > 0 and ("received by " .. table.concat(names, ", ") .. ".") or "sent — no receiver confirmation yet.")
  end)
  return true, { transfer = transfer, chunks = chunks, mode = normalized.source.mode, trigger = trigger }
end

function MerfinPlus:BroadcastGurtoggManualGroups(snapshot)
  return self:BroadcastGurtoggAssignmentsSnapshot(snapshot, "manual", "legacy-manual")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
  if event == "PLAYER_LOGIN" then
    local register = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix
    if register then register(PREFIX) end
    return
  end
  local kind, transfer, a, b, data = strsplit("|", message, 5)
  if prefix ~= PREFIX then return end
  if kind == "A" then
    local state = channel == "WHISPER" and outgoing[transfer] or nil
    if state and unitForName(sender) then state.acknowledged[shortName(sender)] = sender end
    return
  end
  if (channel ~= "RAID" and channel ~= "PARTY") or not isAuthorizedSender(sender) then return end
  if kind == "S" then
    local total = tonumber(a)
    if not total or total < 1 or total > MAX_CHUNKS then return end
    incoming[sender] = { id = transfer, total = total, chunks = {} }
    C_Timer.After(10, function() if incoming[sender] and incoming[sender].id == transfer then incoming[sender] = nil end end)
    return
  end
  if kind ~= "D" then return end
  local state, index, total = incoming[sender], tonumber(a), tonumber(b)
  if not state or state.id ~= transfer or state.total ~= total or not index or index < 1 or index > total or type(data) ~= "string" or #data > CHUNK_BYTES then return end
  state.chunks[index] = data
  for i = 1, total do if not state.chunks[i] then return end end
  incoming[sender] = nil
  local snapshot = decode(table.concat(state.chunks))
  if snapshot then
    MerfinPlus:PublishReceivedGurtoggAssignmentsSnapshot(snapshot, sender)
    announce("received and applied from " .. coloredName(sender) .. ".")
    local send = C_ChatInfo and C_ChatInfo.SendAddonMessage or SendAddonMessage
    if send then send(PREFIX, table.concat({ "A", transfer }, "|"), "WHISPER", sender) end
  end
end)
