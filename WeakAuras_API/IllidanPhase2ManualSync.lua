local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")
local PREFIX, MAX_BYTES, CHUNK_BYTES, MAX_CHUNKS = "MFILP2", 4096, 160, 32
local incoming, outgoing = {}, {}

local function ShortName(value)
  local name = tostring(value or ""):match("^([^%-]+)")
  return name and name:lower() or ""
end

local function UnitForName(name)
  local wanted = ShortName(name)
  if wanted == ShortName(UnitName and UnitName("player")) then return "player" end
  local prefix = IsInRaid and IsInRaid() and "raid" or "party"
  for index = 1, GetNumGroupMembers and GetNumGroupMembers() or 0 do
    local unit = prefix .. index
    if ShortName(UnitName and UnitName(unit)) == wanted then return unit end
  end
end

local function ColoredName(name)
  local unit = UnitForName(name)
  local classToken = unit and UnitClass and select(2, UnitClass(unit))
  local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
  local code = color and (color.colorStr
    or string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255))
  local display = tostring(name or ""):match("^([^%-]+)") or tostring(name or "")
  return code and "|c" .. code .. display .. "|r" or display
end

local function Announce(message)
  if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
    DEFAULT_CHAT_FRAME:AddMessage("|cff57d9ffMerfinPlus WeakAura Assignments:|r " .. tostring(message))
  end
end

local function CanSend()
  if type(MerfinPlus.CanBroadcastIllidanPhase2Assignments) == "function" then
    return MerfinPlus:CanBroadcastIllidanPhase2Assignments()
  end
  return false, "Illidan Phase 2 assignment sync is unavailable."
end

local function Authorized(sender)
  if type(MerfinPlus.IsAuthorizedRaidAssignmentSender) == "function" then
    return MerfinPlus:IsAuthorizedRaidAssignmentSender(sender)
  end
  return false
end

local function Normalize(snapshot, sourceMode)
  if type(MerfinPlus.NormalizeIllidanPhase2AssignmentsSnapshot) ~= "function" then return nil end
  return MerfinPlus:NormalizeIllidanPhase2AssignmentsSnapshot(snapshot, sourceMode)
end

local function Encode(snapshot)
  local serializer = LibStub("AceSerializer-3.0", true)
  local deflate = LibStub("LibDeflate", true)
  if not serializer or not deflate then return nil end
  local serialized = serializer:Serialize(snapshot)
  local compressed = type(serialized) == "string" and deflate:CompressDeflate(serialized)
  return compressed and deflate:EncodeForWoWAddonChannel(compressed) or nil
end

local function Decode(payload)
  local deflate = LibStub("LibDeflate", true)
  local serializer = LibStub("AceSerializer-3.0", true)
  if not deflate or not serializer or type(payload) ~= "string" or #payload > MAX_BYTES then return nil end
  local compressed = deflate:DecodeForWoWAddonChannel(payload)
  local serialized = compressed and deflate:DecompressDeflate(compressed)
  if type(serialized) ~= "string" then return nil end
  local ok, snapshot = serializer:Deserialize(serialized)
  return ok and Normalize(snapshot) or nil
end

local function RegisterPrefix()
  local register = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix
  if register then return pcall(register, PREFIX) end
  return false
end

local function Send(prefix, message, channel, target)
  local send = C_ChatInfo and C_ChatInfo.SendAddonMessage or SendAddonMessage
  if not send then return false end
  return send(prefix, message, channel, target) ~= false
end

function MerfinPlus:BroadcastIllidanPhase2AssignmentsSnapshot(snapshot, sourceMode, trigger)
  local allowed, reason = CanSend()
  if not allowed then return false, reason end
  local normalized, normalizeError = Normalize(snapshot, sourceMode)
  if not normalized then return false, normalizeError or "Illidan Phase 2 assignments are invalid." end
  local payload = Encode(normalized)
  if not payload or #payload > MAX_BYTES then
    return false, "Illidan Phase 2 assignments could not be encoded."
  end
  RegisterPrefix()
  local total = math.ceil(#payload / CHUNK_BYTES)
  if total < 1 or total > MAX_CHUNKS then return false, "Illidan Phase 2 sync is too large." end
  self.illidanPhase2ManualSequence = (self.illidanPhase2ManualSequence or 0) + 1
  local transfer = tostring((GetServerTime and GetServerTime()) or (time and time()) or 0)
    .. "-" .. tostring(self.illidanPhase2ManualSequence)
  outgoing[transfer] = { acknowledged = {}, rejected = {} }
  local channel = IsInRaid and IsInRaid() and "RAID" or "PARTY"
  if not Send(PREFIX, table.concat({ "S", transfer, total }, "|"), channel) then
    outgoing[transfer] = nil
    return false, "Addon-message transport is unavailable."
  end
  for index = 1, total do
    local chunk = payload:sub((index - 1) * CHUNK_BYTES + 1, index * CHUNK_BYTES)
    if not Send(PREFIX, table.concat({ "D", transfer, index, total, chunk }, "|"), channel) then
      outgoing[transfer] = nil
      return false, "Illidan Phase 2 sync could not be submitted."
    end
  end
  self:PublishReceivedIllidanPhase2ManualSnapshot(normalized, UnitName and UnitName("player"))
  local function FinishFeedback()
    local state = outgoing[transfer]
    if not state then return end
    outgoing[transfer] = nil
    local names = {}
    for _, name in pairs(state.acknowledged) do names[#names + 1] = ColoredName(name) end
    table.sort(names)
    if #names > 0 then
      Announce("received by " .. table.concat(names, ", ") .. ".")
      return
    end
    if next(state.rejected) then
      local failures = {}
      for name, failure in pairs(state.rejected) do
        failures[#failures + 1] = ColoredName(name) .. " (" .. failure .. ")"
      end
      table.sort(failures)
      Announce("not applied by " .. table.concat(failures, ". ") .. ".")
      return
    end
    Announce("sent — no receiver confirmation yet.")
  end
  if C_Timer and type(C_Timer.After) == "function" then C_Timer.After(3, FinishFeedback) end
  return true, {
    transferId = transfer,
    bossKey = "illidan",
    bytes = #payload,
    chunks = total,
    trigger = trigger,
  }
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
  if event == "PLAYER_LOGIN" then
    RegisterPrefix()
    return
  end
  if prefix ~= PREFIX then return end
  local kind, transfer, a, b, data = strsplit("|", message, 5)
  if kind == "A" then
    local state = outgoing[transfer]
    if state and UnitForName(sender) then state.acknowledged[ShortName(sender)] = sender end
    return
  end
  if kind == "N" then
    local state = outgoing[transfer]
    if state and UnitForName(sender) then state.rejected[sender] = tostring(a or "rejected") end
    return
  end
  local function Reject(failure)
    if type(transfer) == "string" and transfer ~= "" then
      Send(PREFIX, table.concat({ "N", transfer, failure }, "|"), "WHISPER", sender)
    end
  end
  if channel ~= "RAID" and channel ~= "PARTY" then return end
  if not Authorized(sender) then Reject("sender-not-authorized") return end
  if kind == "S" then
    local total = tonumber(a)
    if total and total >= 1 and total <= MAX_CHUNKS then
      incoming[sender] = { transfer = transfer, total = total, chunks = {} }
      local function Expire()
        if incoming[sender] and incoming[sender].transfer == transfer then incoming[sender] = nil end
      end
      if C_Timer and type(C_Timer.After) == "function" then C_Timer.After(10, Expire) end
    else
      Reject("invalid-start")
    end
    return
  end
  if kind ~= "D" then return end
  local state, index, total = incoming[sender], tonumber(a), tonumber(b)
  if not state or state.transfer ~= transfer then Reject("missing-start") return end
  if state.total ~= total or not index or index < 1 or index > total
    or type(data) ~= "string" or #data > CHUNK_BYTES then
    Reject("invalid-chunk")
    return
  end
  state.chunks[index] = data
  for item = 1, total do if not state.chunks[item] then return end end
  incoming[sender] = nil
  local snapshot = Decode(table.concat(state.chunks))
  if snapshot and MerfinPlus:PublishReceivedIllidanPhase2ManualSnapshot(snapshot, sender) then
    Announce("received and applied from " .. ColoredName(sender) .. ".")
    Send(PREFIX, table.concat({ "A", transfer }, "|"), "WHISPER", sender)
  else
    Reject("decode-failed")
  end
end)
