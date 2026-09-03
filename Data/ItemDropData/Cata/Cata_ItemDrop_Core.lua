-- Merfin Item Source Resolver (Core - Cata)
-- Provides: Merfin.GetItemDropString(itemID) -> string[, meta]

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

_G.Merfin = _G.Merfin or {}
local Merfin = _G.Merfin

local function FormatCustomSource(src)
  if type(src) ~= "table" then
    return ""
  end
  local text = src.sourceText or src.customText
  if not text or text == "" then
    return ""
  end
  local color = src.sourceColor or src.color
  if color and color ~= "" then
    return string.format("|cff%s%s|r", color, text)
  end
  return text
end

local function ApplyRaidTag(instanceName)
  local info = MerfinPlus.InstanceTagInfo and MerfinPlus.InstanceTagInfo[instanceName]
  if not info then
    if instanceName == "VND" then
      return "|cff66cc33Vendor|r"
    end
    if instanceName == "CRF" then
      return "|cffffd100Craft|r"
    end
    return instanceName
  end
  local tag = info.abbr or info.tag or instanceName
  if info.color then
    tag = string.format("|cff%s%s|r", info.color, tag)
  end
  return tag
end

local function ColorizeDifficulty(diff)
  if not diff then
    return nil
  end
  if diff == "H" or diff == "HC" or diff == "Heroic" then
    return "|cffff4040(H)|r"
  end
  if diff == "N" or diff == "NM" or diff == "Normal" then
    return "|cff40ff40(N)|r"
  end
  if diff == "RF" or diff == "Raid Finder" then
    return "|cff80cfff(RF)|r"
  end
  if diff == "ERI" then
    return "|cffff7a00(ERI)|r"
  end
  if diff == "ERT" then
    return "|cff9b59b6(ERT)|r"
  end
  return diff
end

local function ResolvePrettyInstance(raw)
  if not raw or raw == "" then
    return ""
  end
  local map = MerfinPlus.InstanceNameByKey
  return (map and map[raw]) or raw
end

local function ResolvePrettyBoss(raw)
  if not raw or raw == "" then
    return ""
  end
  local map = MerfinPlus.BossNameByKey
  return (map and map[raw]) or raw
end

local function ResolveInstanceName(src)
  if src.instanceEJ and EJ_GetInstanceInfo then
    local name = EJ_GetInstanceInfo(src.instanceEJ)
    if name then
      return name
    end
  end
  return ResolvePrettyInstance(src.instanceKey or src.instance)
end

local function ResolveBossName(src)
  if src.bossEJ and EJ_GetEncounterInfo then
    local name = EJ_GetEncounterInfo(src.bossEJ)
    if name then
      return name
    end
  end
  return ResolvePrettyBoss(src.bossKey or src.boss)
end

local function GetInstanceTagKey(src)
  return src and (src.instanceKey or src.instance) or nil
end

local function HasKey(src, field, key)
  local value = src and src[field]
  return type(value) == "string" and value:lower():find(key, 1, true) ~= nil
end

local function FormatSourcesGrouped(sources)
  if not sources or #sources == 0 then
    return ""
  end

  local customParts, customSeen = {}, {}
  for i = 1, #sources do
    local text = FormatCustomSource(sources[i])
    if text ~= "" and not customSeen[text] then
      customSeen[text] = true
      customParts[#customParts + 1] = text
    end
  end
  if #customParts > 0 then
    return table.concat(customParts, ", ")
  end

  local hasShared, hasTrash, hasWorldBoss, sharedDiff = false, false, false, nil
  local grouped, order = {}, {}
  for i = 1, #sources do
    local s = sources[i]
    if HasKey(s, "bossKey", "shared") then
      hasShared = true
      sharedDiff = sharedDiff or s.difficulty
    elseif HasKey(s, "bossKey", "trash") then
      hasTrash = true
    elseif HasKey(s, "instanceKey", "worldboss") then
      hasWorldBoss = true
    end
    local inst = ResolveInstanceName(s)
    local boss = ResolveBossName(s)
    if inst ~= "" and boss ~= "" then
      local bucket = grouped[inst]
      if not bucket then
        bucket = { bosses = {}, seen = {}, tag = ApplyRaidTag(GetInstanceTagKey(s) or inst) }
        grouped[inst] = bucket
        order[#order + 1] = inst
      end
      local label = boss
      if s.difficulty then
        label = string.format("%s %s", boss, ColorizeDifficulty(s.difficulty))
      end
      if not bucket.seen[label] then
        bucket.seen[label] = true
        bucket.bosses[#bucket.bosses + 1] = label
      end
    end
  end

  local firstInst = ResolveInstanceName(sources[1])
  local firstTag = ApplyRaidTag(GetInstanceTagKey(sources[1]) or firstInst)
  if hasShared then
    local diff = sharedDiff and (" " .. ColorizeDifficulty(sharedDiff)) or ""
    return firstInst ~= "" and string.format("%s: Shared Boss Loot%s", firstTag, diff) or "Shared Boss Loot"
  end
  if hasTrash then
    return firstInst ~= "" and string.format("%s: Trash Loot", firstTag) or "Trash Loot"
  end
  if hasWorldBoss then
    local boss = ResolveBossName(sources[1])
    return boss ~= "" and string.format("%s: %s", firstTag, boss) or string.format("%s Unknown World Boss", firstTag)
  end

  local parts = {}
  for i = 1, #order do
    local inst = order[i]
    local bucket = grouped[inst]
    if bucket and #bucket.bosses > 0 then
      parts[#parts + 1] = string.format("%s: %s", bucket.tag or ApplyRaidTag(inst), table.concat(bucket.bosses, ", "))
    end
  end
  return table.concat(parts, " | ")
end

local function ParseVendorPriceString(priceStr)
  if not priceStr or priceStr == "" then
    return nil
  end

  local out = {}
  for key, amount in priceStr:gmatch("([^:]+):(%d+)") do
    out[#out + 1] = { key = key, amount = tonumber(amount) or 0 }
  end

  return out
end

local function FormatVendorSource(itemID)
  local prices = MerfinPlus.VendorPrices
  if not prices then
    return ""
  end

  local priceStr = prices[itemID]
  if not priceStr then
    return ""
  end

  local parsed = ParseVendorPriceString(priceStr)
  if not parsed or #parsed == 0 then
    return ""
  end

  local keyInfo = MerfinPlus.VendorPriceKeyInfo or {}
  local parts = {}

  for i = 1, #parsed do
    local p = parsed[i]
    local info = keyInfo[p.key]
    local name = (info and info.name) or p.key
    local abbr = (info and info.abbr) or name
    local color = info and info.color

    local piece
    if p.key == "money" then
      if GetCoinTextureString then
        piece = GetCoinTextureString(p.amount)
      else
        local gold = math.floor(p.amount / 10000)
        local silver = math.floor((p.amount % 10000) / 100)
        local copper = p.amount % 100
        piece = string.format("%dg %ds %dc", gold, silver, copper)
      end
    elseif tonumber(p.key) and GetItemInfo then
      piece = string.format("%s x%d", GetItemInfo(tonumber(p.key)) or p.key, p.amount)
    else
      piece = string.format("%s x%d", abbr, p.amount)
    end

    if color then
      piece = string.format("|cff%s%s|r", color, piece)
    end
    parts[#parts + 1] = piece
  end

  return string.format("%s: %s", ApplyRaidTag("Vendor"), table.concat(parts, ", "))
end

local function IsGenericVendorSource(src)
  if type(src) ~= "table" then
    return false
  end
  local boss = src.bossKey or src.boss
  return boss == "Vendor"
end

local function FilterPricedVendorSources(sources, hasVendorPrice)
  if not hasVendorPrice or not sources or #sources == 0 then
    return sources
  end

  local out
  for i = 1, #sources do
    local src = sources[i]
    if not IsGenericVendorSource(src) then
      if not out then
        out = {}
      end
      out[#out + 1] = src
    end
  end

  return out
end

local function FormatProfessionSource(itemID)
  local craft = MerfinPlus.ProfessionCraft
  if not craft then
    return ""
  end

  local profIDs = craft[itemID]
  if not profIDs or #profIDs == 0 then
    return ""
  end

  local profInfo = MerfinPlus.ProfessionInfo or {}
  local parts = {}

  for i = 1, #profIDs do
    local id = profIDs[i]
    local info = profInfo[id]
    local abbr = (info and info.abbr) or tostring(id)
    local color = info and info.color
    if color then
      parts[#parts + 1] = string.format("|cff%s%s|r", color, abbr)
    else
      parts[#parts + 1] = abbr
    end
  end

  return string.format("%s: %s", ApplyRaidTag("Craft"), table.concat(parts, ", "))
end

local function GetEquipSlotKeyCandidates(itemID)
  if not itemID or itemID == 0 then
    return nil
  end
  local equipLoc
  if GetItemInfoInstant then
    local _, _, _, loc = GetItemInfoInstant(itemID)
    equipLoc = loc
  end
  local canonical = {
    INVTYPE_HEAD = "Head",
    INVTYPE_SHOULDER = "Shoulder",
    INVTYPE_CHEST = "Chest",
    INVTYPE_ROBE = "Chest",
    INVTYPE_HAND = "Hands",
    INVTYPE_LEGS = "Legs",
  }
  local base = equipLoc and canonical[equipLoc]
  if not base then
    return nil
  end
  return { base, base:upper() }
end

local function ResolveTierTokenSources(itemID)
  local itemToTier = MerfinPlus.ItemToTier
  local tierTokens = MerfinPlus.TierTokenItems
  local sourceDB = MerfinPlus.ItemSourceDB
  if not itemToTier or not tierTokens or not sourceDB then
    return nil
  end
  local tierKey = itemToTier[itemID]
  if not tierKey then
    return nil
  end
  local out = {}
  local tokenByItem = MerfinPlus.TierTokenByItemID
  local tokenID = tokenByItem and tokenByItem[itemID]
  if tokenID then
    local src = sourceDB[tokenID]
    if src and #src > 0 then
      for i = 1, #src do
        out[#out + 1] = src[i]
      end
    end
  end
  if #out > 0 then
    return out
  end
  local slots = GetEquipSlotKeyCandidates(itemID)
  if not slots then
    return nil
  end
  for i = 1, #slots do
    local list = tierTokens[tierKey] and tierTokens[tierKey][slots[i]]
    if list then
      for j = 1, #list do
        local src = sourceDB[list[j]]
        if src and #src > 0 then
          for k = 1, #src do
            out[#out + 1] = src[k]
          end
        end
      end
      if #out > 0 then
        return out
      end
    end
  end
  return nil
end

function Merfin.GetItemDropString(itemID)
  if type(itemID) ~= "number" then
    return ""
  end
  local vendorText = FormatVendorSource(itemID)
  local sourceDB = MerfinPlus.ItemSourceDB or {}
  local sources = sourceDB[itemID]
  if not sources or #sources == 0 then
    sources = ResolveTierTokenSources(itemID)
  end
  sources = FilterPricedVendorSources(sources, vendorText ~= "")
  local outParts = {}

  if sources and #sources > 0 then
    local sourceText = FormatSourcesGrouped(sources)
    if sourceText ~= "" then
      outParts[#outParts + 1] = sourceText
    end
  end

  local faction = MerfinPlus.FactionSourceDB and MerfinPlus.FactionSourceDB[itemID]
  if faction then
    local factionName = GetFactionInfoByID and GetFactionInfoByID(faction.factionID) or nil
    local repKey = faction.reputation or faction.reputationID
    local repName = (MerfinPlus.REPUTATION_NAMES and MerfinPlus.REPUTATION_NAMES[repKey]) or "Unknown"
    if factionName then
      outParts[#outParts + 1] = string.format("%s (%s)", factionName, repName)
    end
  end

  if vendorText ~= "" then
    outParts[#outParts + 1] = vendorText
  end

  local profText = FormatProfessionSource(itemID)
  if profText ~= "" then
    outParts[#outParts + 1] = profText
  end

  return table.concat(outParts, " | ")
end
