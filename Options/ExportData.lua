-- MerfinPlus guild and raid-loot export data.
-- The export schemas and filters intentionally match MerfinUI Guild Manager.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local MAX_LOOT_SESSIONS = 50
local LOOT_SESSION_WINDOW = 21600
local RECENT_ENCOUNTER_WINDOW = 1800
local GUILD_ROSTER_REFRESH_TIMEOUT = 3

local TRACKED_LOOT_QUALITIES = {
  [3] = true,
  [4] = true,
  [5] = true,
}

local TRACKED_LOOT_LINK_COLORS = {
  ["0070dd"] = 3,
  ["a335ee"] = 4,
  ["ff8000"] = 5,
}

local LOOT_ITEM_BLACKLIST = {
  [30311] = true,
  [30312] = true,
  [30313] = true,
  [30314] = true,
  [30316] = true,
  [30317] = true,
  [30318] = true,
  [30319] = true,
  [30320] = true,
}

-- Verdant Sphere begins quest 11007 and is the sole non-quality loot exception.
-- The scope below keeps it tied to Kael'thas (encounter 733) in Tempest Keep.
local TBC_VERDANT_SPHERE_ITEM_ID = 32405
local TBC_KAELTHAS_ENCOUNTER_ID = 733

local RAID_DEFINITIONS = {
  classic = {
    { key = "molten_core", name = "Molten Core", ids = { 409 } },
    { key = "onyxia", name = "Onyxia's Lair", ids = { 249 } },
    { key = "blackwing_lair", name = "Blackwing Lair", ids = { 469 } },
    { key = "zul_gurub", name = "Zul'Gurub", ids = { 309 } },
    { key = "ruins_ahnqiraj", name = "Ruins of Ahn'Qiraj", ids = { 509 } },
    { key = "temple_ahnqiraj", name = "Temple of Ahn'Qiraj", ids = { 531 } },
    { key = "naxxramas", name = "Naxxramas", ids = { 533 } },
  },
  tbc = {
    { key = "karazhan", name = "Karazhan", ids = { 532 } },
    { key = "gruuls_lair", name = "Gruul's Lair", ids = { 565 } },
    { key = "magtheridons_lair", name = "Magtheridon's Lair", ids = { 544 } },
    { key = "serpentshrine_cavern", name = "Serpentshrine Cavern", ids = { 548 } },
    { key = "tempest_keep", name = "Tempest Keep", ids = { 550 } },
    { key = "battle_for_mount_hyjal", name = "Battle for Mount Hyjal", ids = { 534 } },
    { key = "black_temple", name = "Black Temple", ids = { 564 } },
    { key = "zul_aman", name = "Zul'Aman", ids = { 568 } },
    { key = "sunwell_plateau", name = "Sunwell Plateau", ids = { 580 } },
  },
  wotlk = {
    { key = "naxxramas", name = "Naxxramas", ids = { 533 } },
    { key = "eye_of_eternity", name = "The Eye of Eternity", ids = { 616 } },
    { key = "obsidian_sanctum", name = "The Obsidian Sanctum", ids = { 615 } },
    { key = "vault_of_archavon", name = "Vault of Archavon", ids = { 624 } },
    { key = "ulduar", name = "Ulduar", ids = { 603 } },
    { key = "trial_of_the_crusader", name = "Trial of the Crusader", ids = { 649 } },
    { key = "onyxia", name = "Onyxia's Lair", ids = { 249 } },
    { key = "icecrown_citadel", name = "Icecrown Citadel", ids = { 631 } },
    { key = "ruby_sanctum", name = "The Ruby Sanctum", ids = { 724 } },
  },
  cataclysm = {
    { key = "baradin_hold", name = "Baradin Hold", ids = { 757 } },
    { key = "blackwing_descent", name = "Blackwing Descent", ids = { 669 } },
    { key = "bastion_of_twilight", name = "The Bastion of Twilight", ids = { 671 } },
    { key = "throne_of_four_winds", name = "Throne of the Four Winds", ids = { 754 } },
    { key = "firelands", name = "Firelands", ids = { 720 } },
    { key = "dragon_soul", name = "Dragon Soul", ids = { 967 } },
  },
  mop = {
    { key = "mogushan_vaults", name = "Mogu'shan Vaults", ids = { 1008 } },
    { key = "heart_of_fear", name = "Heart of Fear", ids = { 1009 } },
    { key = "terrace_of_endless_spring", name = "Terrace of Endless Spring", ids = { 996 } },
    { key = "throne_of_thunder", name = "Throne of Thunder", ids = { 1098 } },
    { key = "siege_of_orgrimmar", name = "Siege of Orgrimmar", ids = { 1136 } },
  },
}

local function Now()
  if GetServerTime then
    return GetServerTime()
  end
  if time then
    return time()
  end
  return 0
end

local function FormatTimestamp(timestamp, withDay)
  if date then
    if withDay then
      return date("%A, %Y-%m-%d %H:%M:%S", timestamp)
    end
    return date("%Y-%m-%d %H:%M:%S", timestamp)
  end
  return tostring(timestamp or "")
end

local function CleanPlayerName(name)
  local clean = tostring(name or "")
  local dash = clean:find("-", 1, true)
  if dash then
    clean = clean:sub(1, dash - 1)
  end
  return clean
end

local function JsonEscape(value)
  value = value == nil and "" or tostring(value)
  value = value:gsub("\\", "\\\\")
  value = value:gsub("\"", "\\\"")
  value = value:gsub("\n", "\\n")
  value = value:gsub("\r", "\\r")
  value = value:gsub("\t", "\\t")
  value = value:gsub("[%c]", "")
  return value
end

local function NormalizeName(value)
  return tostring(value or ""):lower():gsub("[%s%p%c]+", "")
end

local function CopySavedValue(value, copies)
  if type(value) ~= "table" then
    return value
  end
  copies = copies or {}
  if copies[value] then
    return copies[value]
  end
  local copy = {}
  copies[value] = copy
  for key, nestedValue in pairs(value) do
    copy[CopySavedValue(key, copies)] = CopySavedValue(nestedValue, copies)
  end
  return copy
end

local function LootSessionFingerprint(session)
  local parts = {
    tostring(session and session.expansion or ""),
    tostring(session and session.realm or ""),
    tostring(session and session.raidKey or ""),
    tostring(session and session.raidName or ""),
    tostring(session and session.instanceName or ""),
    tostring(session and session.startedAt or ""),
    tostring(session and session.startedAtText or ""),
    tostring(session and session.displayTimestamp or ""),
  }
  for _, item in ipairs(session and session.items or {}) do
    parts[#parts + 1] = table.concat({
      tostring(item.playerName or ""),
      tostring(item.itemName or ""),
      tostring(item.itemID or ""),
      tostring(item.itemQuality or ""),
      tostring(item.itemLink or ""),
      tostring(item.bossName or ""),
      tostring(item.raidName or ""),
      tostring(item.recordedAt or ""),
    }, "\030")
  end
  return table.concat(parts, "\031")
end

local function EscapePatternChar(char)
  if char:find("[%^%$%(%)%%%.%[%]%*%+%-%?]") then
    return "%" .. char
  end
  return char
end

local function BuildFormatPattern(format)
  if not format or format == "" then
    return nil
  end

  local pattern = "^"
  local index = 1
  while index <= #format do
    local char = format:sub(index, index)
    if char == "%" and index < #format then
      local token = format:sub(index + 1, index + 1)
      if token == "s" then
        pattern = pattern .. "(.+)"
      elseif token == "d" then
        pattern = pattern .. "(%d+)"
      else
        pattern = pattern .. EscapePatternChar(token)
      end
      index = index + 2
    else
      pattern = pattern .. EscapePatternChar(char)
      index = index + 1
    end
  end
  return pattern .. "$"
end

local function RequestGuildRoster()
  if C_GuildInfo and C_GuildInfo.GuildRoster then
    C_GuildInfo.GuildRoster()
    return true
  elseif GuildRoster then
    GuildRoster()
    return true
  end
  return false
end

local function GetGuildMemberCount()
  if not GetNumGuildMembers then
    return 0
  end
  local count = GetNumGuildMembers(true)
  if not count or count <= 0 then
    count = GetNumGuildMembers()
  end
  return tonumber(count) or 0
end

local function NormalizeGuildMemberName(name)
  return CleanPlayerName(name):lower()
end

local function GetGuildProfessionMemberLookup()
  local clubAPI = rawget(_G, "C_Club")
  if not clubAPI or not clubAPI.GetGuildClubId or not clubAPI.GetClubMembers or not clubAPI.GetMemberInfo then
    return nil, "Guild profession API is unavailable.", false
  end

  local clubIDOK, clubID = pcall(clubAPI.GetGuildClubId)
  if not clubIDOK or not clubID then
    return nil, "Guild profession data is still loading.", true
  end

  local membersOK, memberIDs = pcall(clubAPI.GetClubMembers, clubID)
  if not membersOK or type(memberIDs) ~= "table" or #memberIDs <= 0 then
    return nil, "Guild profession data is still loading.", true
  end

  local lookup = {
    byGUID = {},
    byName = {},
  }
  local resolvedMembers = 0

  for _, memberID in ipairs(memberIDs) do
    local memberOK, memberInfo = pcall(clubAPI.GetMemberInfo, clubID, memberID)
    if memberOK and type(memberInfo) == "table" then
      resolvedMembers = resolvedMembers + 1
      if memberInfo.guid and memberInfo.guid ~= "" then
        lookup.byGUID[memberInfo.guid] = memberInfo
      end

      local nameKey = NormalizeGuildMemberName(memberInfo.name)
      if nameKey ~= "" then
        if lookup.byName[nameKey] == nil then
          lookup.byName[nameKey] = memberInfo
        else
          -- Never guess when connected-realm members produce the same short name.
          lookup.byName[nameKey] = false
        end
      end
    end
  end

  if resolvedMembers <= 0 then
    return nil, "Guild profession data is still loading.", true
  end

  return lookup
end

local function GetPrimaryProfessions(memberInfo)
  local professions = {}
  for slot = 1, 2 do
    local prefix = "profession" .. slot
    local skillLineID = tonumber(memberInfo and memberInfo[prefix .. "ID"])
    local name = memberInfo and memberInfo[prefix .. "Name"]
    local rank = tonumber(memberInfo and memberInfo[prefix .. "Rank"])
    if skillLineID or (type(name) == "string" and name ~= "") then
      professions[#professions + 1] = {
        skillLineID = skillLineID,
        name = type(name) == "string" and name or nil,
        rank = rank,
      }
    end
  end
  return professions
end

function MerfinPlus:GetExportExpansionInfo()
  if MerfinPlus.IsMoP() then
    return "mop", "MoP", 90
  elseif MerfinPlus.IsCata() then
    return "cataclysm", "Cataclysm", 85
  elseif MerfinPlus.IsWrath() then
    return "wotlk", "WotLK", 80
  elseif MerfinPlus.IsTBC() then
    return "tbc", "TBC", 70
  elseif MerfinPlus.IsVanilla() then
    return "classic", "Classic", 60
  end
  return nil, "Unknown", nil
end

function MerfinPlus:GetExportStorage()
  if not self.db or not self.db.global then
    return nil
  end
  self.db.global.exports = self.db.global.exports or {}
  local storage = self.db.global.exports
  storage.trackLoot = storage.trackLoot == true
  storage.lootSessions = storage.lootSessions or {}
  return storage
end

function MerfinPlus:GetExportUIState()
  self.exportUIState = self.exportUIState or {
    guildExportText = "",
    guildExportStatus = "Press Generate to read the guild roster.",
    guildExportStatusArgs = nil,
  }
  return self.exportUIState
end

function MerfinPlus:RegisterExportTextWidget(fieldKey, widget)
  if not fieldKey or not widget then
    return
  end
  self.exportTextWidgets = self.exportTextWidgets or {}
  self.exportTextWidgets[fieldKey] = widget
end

function MerfinPlus:UnregisterExportTextWidget(fieldKey, widget)
  if self.exportTextWidgets and fieldKey and self.exportTextWidgets[fieldKey] == widget then
    self.exportTextWidgets[fieldKey] = nil
  end
end

function MerfinPlus:FocusExportTextField(fieldKey)
  local widget = self.exportTextWidgets and self.exportTextWidgets[fieldKey]
  local editBox = widget and widget.editBox
  if not widget or not widget.frame or not widget.frame:IsShown()
    or not editBox or not editBox:IsShown() then
    return false
  end

  local text = editBox:GetText() or ""
  if text == "" then
    return false
  end

  -- Export strings are ASCII-encoded. Use the actual string length instead of
  -- GetNumLetters(), whose editor-side count can stop before a long value ends.
  local textLength = #text
  editBox:SetFocus()
  editBox:SetCursorPosition(0)
  editBox:HighlightText(0, textLength)
  return editBox:HasFocus() == true
end

function MerfinPlus:NotifyExportOptionsChanged()
  local registry = LibStub("AceConfigRegistry-3.0", true)
  if registry then
    registry:NotifyChange("MerfinPlus_Standalone")
    registry:NotifyChange("MerfinPlus_Assignments")
  end
end

function MerfinPlus:ImportGuildManagerLootSessions()
  local sourceDB = _G.MerfinUIGuildManagerDB
  local sourceSessions = sourceDB and sourceDB.lootSessions
  if type(sourceSessions) ~= "table" then
    return 0, nil
  end

  local storage = self:GetExportStorage()
  if not storage then
    return 0, #sourceSessions
  end

  local knownIDs = {}
  local knownSourceIDs = {}
  local knownFingerprints = {}
  for _, session in ipairs(storage.lootSessions) do
    if session.id then
      knownIDs[tostring(session.id)] = true
    end
    if session.sourceAddon == "MerfinUIGuildManager" and session.sourceSessionId then
      knownSourceIDs[tostring(session.sourceSessionId)] = true
    end
    knownFingerprints[LootSessionFingerprint(session)] = true
  end

  local imported = 0
  for _, sourceSession in ipairs(sourceSessions) do
    if type(sourceSession) == "table" then
      local sourceID = tostring(sourceSession.id or "")
      local fingerprint = LootSessionFingerprint(sourceSession)
      local duplicate = knownFingerprints[fingerprint] or (sourceID ~= "" and knownSourceIDs[sourceID])
      if not duplicate then
        local session = CopySavedValue(sourceSession)
        session.sourceAddon = "MerfinUIGuildManager"
        session.sourceSessionId = sourceID ~= "" and sourceID or nil

        local targetID = sourceID
        if targetID == "" then
          targetID = "guild-manager-" .. tostring(session.startedAt or imported + 1)
        end
        if knownIDs[targetID] then
          local suffix = 1
          local candidate = targetID .. "-guild-manager"
          while knownIDs[candidate] do
            suffix = suffix + 1
            candidate = targetID .. "-guild-manager-" .. tostring(suffix)
          end
          targetID = candidate
        end
        session.id = targetID

        table.insert(storage.lootSessions, session)
        knownIDs[targetID] = true
        if sourceID ~= "" then
          knownSourceIDs[sourceID] = true
        end
        knownFingerprints[fingerprint] = true
        imported = imported + 1
      end
    end
  end

  storage.guildManagerImport = {
    version = 1,
    sourceSessions = #sourceSessions,
    importedThisRun = imported,
    checkedAt = Now(),
  }
  if imported > 0 and not storage.activeLootSessionId then
    local latest = storage.lootSessions[#storage.lootSessions]
    storage.activeLootSessionId = latest and latest.id or nil
  end
  if imported > 0 then
    self:NotifyExportOptionsChanged()
  end
  return imported, #sourceSessions
end

function MerfinPlus:GetExpansionRaids()
  local key = self:GetExportExpansionInfo()
  return RAID_DEFINITIONS[key] or {}
end

function MerfinPlus:FindExportRaid(instanceName, instanceID)
  local normalizedName = NormalizeName(instanceName)
  local numericID = tonumber(instanceID)

  for _, raid in ipairs(self:GetExpansionRaids()) do
    for _, raidID in ipairs(raid.ids or {}) do
      if numericID and tonumber(raidID) == numericID then
        return raid
      end
    end
  end

  if normalizedName ~= "" then
    for _, raid in ipairs(self:GetExpansionRaids()) do
      if NormalizeName(raid.name) == normalizedName then
        return raid
      end
      for _, alias in ipairs(raid.aliases or {}) do
        if NormalizeName(alias) == normalizedName then
          return raid
        end
      end
    end
  end
  return nil
end

function MerfinPlus:GetCurrentExportRaid()
  if not GetInstanceInfo then
    return nil
  end
  local instanceName, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
  if instanceType ~= "raid" then
    return nil
  end
  local raid = self:FindExportRaid(instanceName, instanceID)
  if not raid then
    return nil
  end
  return raid, instanceName
end

function MerfinPlus:GetLootPatterns()
  if not self.exportLootPatterns then
    self.exportLootPatterns = {
      { pattern = BuildFormatPattern(LOOT_ITEM_SELF), itemIndex = 1, selfLoot = true },
      { pattern = BuildFormatPattern(LOOT_ITEM_SELF_MULTIPLE), itemIndex = 1, selfLoot = true },
      { pattern = BuildFormatPattern(LOOT_ITEM), playerIndex = 1, itemIndex = 2 },
      { pattern = BuildFormatPattern(LOOT_ITEM_MULTIPLE), playerIndex = 1, itemIndex = 2 },
    }
  end
  return self.exportLootPatterns
end

function MerfinPlus:ParseExportLootMessage(message)
  if not message or message == "" then
    return nil
  end
  for _, definition in ipairs(self:GetLootPatterns()) do
    if definition.pattern then
      local captures = { tostring(message):match(definition.pattern) }
      if captures[definition.itemIndex] then
        local playerName = definition.selfLoot and (UnitName and UnitName("player") or "") or captures[definition.playerIndex]
        return CleanPlayerName(playerName), captures[definition.itemIndex]
      end
    end
  end
  return nil
end

function MerfinPlus:GetExportItemData(itemLink)
  local itemID = tonumber(tostring(itemLink or ""):match("item:(%d+)")) or 0
  local itemName, itemQuality
  if GetItemInfo then
    local resolvedName, _, resolvedQuality = GetItemInfo(itemLink)
    itemName, itemQuality = resolvedName, resolvedQuality
  end
  itemName = itemName or tostring(itemLink or ""):match("%[(.-)%]") or "Unknown Item"
  return itemName, itemID, itemQuality
end

function MerfinPlus:GetExportItemQuality(itemLink, itemID, knownQuality)
  local quality = tonumber(knownQuality)
  if quality then
    return quality
  end
  local color = tostring(itemLink or ""):match("|cff(%x%x%x%x%x%x)")
  if color then
    quality = TRACKED_LOOT_LINK_COLORS[color:lower()]
  end
  if not quality and GetItemInfo then
    local lookup = itemLink
    if (not lookup or lookup == "") and tonumber(itemID) and tonumber(itemID) > 0 then
      lookup = tonumber(itemID)
    end
    if lookup then
      local _, _, cachedQuality = GetItemInfo(lookup)
      quality = tonumber(cachedQuality)
    end
  end
  return quality
end

function MerfinPlus:IsLootExportException(itemID, context)
  return tonumber(itemID) == TBC_VERDANT_SPHERE_ITEM_ID
    and type(context) == "table"
    and context.expansion == "tbc"
    and context.raidKey == "tempest_keep"
    and tonumber(context.bossEncounterID) == TBC_KAELTHAS_ENCOUNTER_ID
end

function MerfinPlus:ShouldTrackExportItem(itemLink, itemID, itemQuality, context)
  local numericID = tonumber(itemID) or tonumber(tostring(itemLink or ""):match("item:(%d+)")) or 0
  if LOOT_ITEM_BLACKLIST[numericID] then
    return false
  end
  return TRACKED_LOOT_QUALITIES[self:GetExportItemQuality(itemLink, numericID, itemQuality)] == true
    or self:IsLootExportException(numericID, context)
end

function MerfinPlus:GetLootSessions()
  local storage = self:GetExportStorage()
  return storage and storage.lootSessions or {}
end

function MerfinPlus:FindLootSession(sessionID)
  for _, session in ipairs(self:GetLootSessions()) do
    if session.id == sessionID then
      return session
    end
  end
  return nil
end

function MerfinPlus:GetSelectedLootSession()
  local storage = self:GetExportStorage()
  if not storage then
    return nil
  end
  local selected = self:FindLootSession(storage.activeLootSessionId)
  if selected then
    return selected
  end
  selected = storage.lootSessions[#storage.lootSessions]
  storage.activeLootSessionId = selected and selected.id or nil
  return selected
end

function MerfinPlus:SelectLootSession(sessionID)
  local storage = self:GetExportStorage()
  if storage and self:FindLootSession(sessionID) then
    storage.activeLootSessionId = sessionID
    self:NotifyExportOptionsChanged()
  end
end

function MerfinPlus:DeleteLootSession(sessionID)
  local storage = self:GetExportStorage()
  if not storage or not sessionID then
    return false
  end
  for index, session in ipairs(storage.lootSessions) do
    if session.id == sessionID then
      table.remove(storage.lootSessions, index)
      if self.currentExportLootSessionId == sessionID then
        self.currentExportLootSessionId = nil
      end
      local nextSession = storage.lootSessions[#storage.lootSessions]
      storage.activeLootSessionId = nextSession and nextSession.id or nil
      self:NotifyExportOptionsChanged()
      return true
    end
  end
  return false
end

function MerfinPlus:GetLootSessionLabel(session)
  if not session then
    return "No recorded raid"
  end
  return tostring(session.displayTimestamp or session.startedAtText or session.startedAt or "") .. " - " .. tostring(session.raidName or "Unknown Raid")
end

function MerfinPlus:GetLootSessionValues()
  local values = {}
  for _, session in ipairs(self:GetLootSessions()) do
    values[session.id] = self:GetLootSessionLabel(session)
  end
  if not next(values) then
    values[""] = self:T("No recorded raids")
  end
  return values
end

function MerfinPlus:GetLootSessionOrder()
  local order = {}
  local sessions = self:GetLootSessions()
  for index = #sessions, 1, -1 do
    order[#order + 1] = sessions[index].id
  end
  if #order == 0 then
    order[1] = ""
  end
  return order
end

function MerfinPlus:GetOrCreateLootSession(raid, instanceName)
  local storage = self:GetExportStorage()
  if not storage or not raid then
    return nil
  end
  local now = Now()
  local active = self:FindLootSession(self.currentExportLootSessionId)
  if active and active.raidKey == raid.key and (now - tonumber(active.startedAt or 0)) <= LOOT_SESSION_WINDOW then
    return active
  end
  local latest = storage.lootSessions[#storage.lootSessions]
  if latest and latest.raidKey == raid.key and (now - tonumber(latest.startedAt or 0)) <= LOOT_SESSION_WINDOW then
    self.currentExportLootSessionId = latest.id
    storage.activeLootSessionId = latest.id
    return latest
  end

  local expansion = self:GetExportExpansionInfo()
  local session = {
    id = tostring(now) .. "-" .. tostring(raid.key) .. "-" .. tostring(#storage.lootSessions + 1),
    expansion = expansion,
    realm = GetRealmName and GetRealmName() or "",
    raidKey = raid.key,
    raidName = raid.name or instanceName,
    instanceName = instanceName or raid.name,
    startedAt = now,
    startedAtText = FormatTimestamp(now, false),
    displayTimestamp = FormatTimestamp(now, true),
    items = {},
  }
  table.insert(storage.lootSessions, session)
  while #storage.lootSessions > MAX_LOOT_SESSIONS do
    table.remove(storage.lootSessions, 1)
  end
  self.currentExportLootSessionId = session.id
  storage.activeLootSessionId = session.id
  return session
end

function MerfinPlus:GetCurrentExportBossContext()
  local now = Now()
  if self.currentExportEncounterName and self.currentExportEncounterName ~= "" then
    return self.currentExportEncounterName, self.currentExportEncounterID
  end
  if self.lastExportEncounterName and self.lastExportEncounterName ~= "" and self.lastExportEncounterAt and (now - self.lastExportEncounterAt) <= RECENT_ENCOUNTER_WINDOW then
    return self.lastExportEncounterName, self.lastExportEncounterID
  end
  return "Unknown Boss", nil
end

function MerfinPlus:GetCurrentExportBossName()
  local bossName = self:GetCurrentExportBossContext()
  return bossName
end

function MerfinPlus:RecordExportLoot(playerName, itemLink)
  local storage = self:GetExportStorage()
  if not storage or not storage.trackLoot then
    return
  end
  local raid, instanceName = self:GetCurrentExportRaid()
  if not raid then
    return
  end
  local itemName, itemID, itemQuality = self:GetExportItemData(itemLink)
  local bossName, bossEncounterID = self:GetCurrentExportBossContext()
  local context = {
    expansion = self:GetExportExpansionInfo(),
    raidKey = raid.key,
    bossEncounterID = bossEncounterID,
  }
  if not self:ShouldTrackExportItem(itemLink, itemID, itemQuality, context) then
    return
  end
  local session = self:GetOrCreateLootSession(raid, instanceName)
  if not session then
    return
  end
  table.insert(session.items, {
    playerName = CleanPlayerName(playerName),
    itemName = itemName,
    itemID = itemID,
    itemQuality = itemQuality,
    itemLink = itemLink,
    bossName = bossName,
    bossEncounterID = bossEncounterID,
    raidName = session.raidName,
    recordedAt = FormatTimestamp(Now(), false),
  })
  self:NotifyExportOptionsChanged()
end

function MerfinPlus:BuildLootExport(session)
  session = session or self:GetSelectedLootSession()
  local expansion = self:GetExportExpansionInfo()
  local items = {}
  for _, item in ipairs(session and session.items or {}) do
    local context = {
      expansion = session.expansion or expansion,
      raidKey = session.raidKey,
      bossEncounterID = item.bossEncounterID,
    }
    if self:ShouldTrackExportItem(item.itemLink, item.itemID, item.itemQuality, context) then
      items[#items + 1] = item
    end
  end

  local output = {
    "{",
    "  \"schema\": \"merfinui.guild-manager.loot\",",
    "  \"version\": 1,",
    "  \"expansion\": \"" .. JsonEscape(session and session.expansion or expansion) .. "\",",
    "  \"realm\": \"" .. JsonEscape(session and session.realm or (GetRealmName and GetRealmName() or "")) .. "\",",
    "  \"raidName\": \"" .. JsonEscape(session and session.raidName or "") .. "\",",
    "  \"recordedAt\": \"" .. JsonEscape(session and session.startedAtText or "") .. "\",",
    "  \"items\": [",
  }
  for index, item in ipairs(items) do
    local suffix = index < #items and "," or ""
    output[#output + 1] = "    {"
    output[#output + 1] = "      \"playerName\": \"" .. JsonEscape(item.playerName) .. "\","
    output[#output + 1] = "      \"itemName\": \"" .. JsonEscape(item.itemName) .. "\","
    output[#output + 1] = "      \"itemID\": " .. tostring(tonumber(item.itemID) or 0) .. ","
    output[#output + 1] = "      \"bossName\": \"" .. JsonEscape(item.bossName) .. "\","
    output[#output + 1] = "      \"raidName\": \"" .. JsonEscape(item.raidName) .. "\""
    output[#output + 1] = "    }" .. suffix
  end
  output[#output + 1] = "  ]"
  output[#output + 1] = "}"
  return table.concat(output, "\n") .. "\n", #items
end

function MerfinPlus:BuildGuildExport()
  local expansion, _, maxLevel = self:GetExportExpansionInfo()
  if not expansion or not maxLevel then
    return nil, 0, "The current expansion is not supported.", false
  end
  if not IsInGuild or not IsInGuild() then
    return nil, 0, "No guild detected.", false
  end

  local memberCount = GetGuildMemberCount()
  if memberCount <= 0 or not GetGuildRosterInfo then
    return nil, 0, "Guild roster data is unavailable.", true
  end

  local professionLookup
  if expansion == "tbc" then
    local professionError, professionRetryable
    professionLookup, professionError, professionRetryable = GetGuildProfessionMemberLookup()
    if not professionLookup then
      return nil, 0, professionError, professionRetryable
    end
  end

  local rows = {}
  for index = 1, memberCount do
    local name, rankName, rankIndex, level, className, _, _, _, _, _, classToken, _, _, _, _, _, guid = GetGuildRosterInfo(index)
    if name and name ~= "" and tonumber(level) == maxLevel then
      local professions
      if professionLookup then
        local professionMember = guid and professionLookup.byGUID[guid] or nil
        if not professionMember then
          professionMember = professionLookup.byName[NormalizeGuildMemberName(name)]
        end
        professions = GetPrimaryProfessions(professionMember)
      end

      rows[#rows + 1] = {
        name = CleanPlayerName(name),
        class = classToken or className or "Player",
        level = maxLevel,
        professions = professions,
        -- Preserve the guild's exact rank text and its zero-based index.
        guildRankName = type(rankName) == "string" and rankName or nil,
        guildRankIndex = tonumber(rankIndex),
      }
    end
  end

  local output = {
    "{",
    "  \"schema\": \"merfinui.guild-manager.roster\",",
    "  \"expansion\": \"" .. JsonEscape(expansion) .. "\",",
    "  \"realm\": \"" .. JsonEscape(GetRealmName and GetRealmName() or "") .. "\",",
    "  \"characters\": [",
  }
  for index, entry in ipairs(rows) do
    local suffix = index < #rows and "," or ""
    local fields = {
      "\"name\": \"" .. JsonEscape(entry.name) .. "\"",
      "\"class\": \"" .. JsonEscape(entry.class) .. "\"",
      "\"level\": " .. tostring(entry.level),
    }
    if entry.guildRankName ~= nil then
      fields[#fields + 1] = "\"guildRankName\": \"" .. JsonEscape(entry.guildRankName) .. "\""
    end
    if entry.guildRankIndex ~= nil then
      fields[#fields + 1] = "\"guildRankIndex\": " .. tostring(entry.guildRankIndex)
    end
    if entry.professions then
      local professionFields = {}
      for _, profession in ipairs(entry.professions) do
        local values = {}
        if profession.skillLineID ~= nil then
          values[#values + 1] = "\"skillLineID\": " .. tostring(profession.skillLineID)
        end
        if profession.name ~= nil then
          values[#values + 1] = "\"name\": \"" .. JsonEscape(profession.name) .. "\""
        end
        if profession.rank ~= nil then
          values[#values + 1] = "\"rank\": " .. tostring(profession.rank)
        end
        professionFields[#professionFields + 1] = "{ " .. table.concat(values, ", ") .. " }"
      end
      fields[#fields + 1] = "\"professions\": [" .. table.concat(professionFields, ", ") .. "]"
    end
    output[#output + 1] = "    { " .. table.concat(fields, ", ") .. " }" .. suffix
  end
  output[#output + 1] = "  ]"
  output[#output + 1] = "}"
  return table.concat(output, "\n") .. "\n", #rows
end

function MerfinPlus:SetGuildExportResult(text, count, errorText, status, statusArgs)
  local state = self:GetExportUIState()
  if text then
    local _, _, maxLevel = self:GetExportExpansionInfo()
    state.guildExportText = text
    if status then
      state.guildExportStatus = status
      state.guildExportStatusArgs = statusArgs
    else
      state.guildExportStatus = "%d players at level %d."
      state.guildExportStatusArgs = { count, maxLevel }
    end
  else
    state.guildExportText = ""
    state.guildExportStatus = status or errorText or "Guild data is unavailable."
    state.guildExportStatusArgs = statusArgs
  end
  self:NotifyExportOptionsChanged()
  return text, count, errorText
end

function MerfinPlus:FinalizeGuildExportRefresh(token, timedOut)
  if token and self.pendingGuildExport ~= token then
    return false
  end
  local text, count, errorText, retryable = self:BuildGuildExport()
  if not timedOut and not text and retryable then
    return false
  end
  self.pendingGuildExport = nil
  if timedOut and text then
    local _, _, maxLevel = self:GetExportExpansionInfo()
    self:SetGuildExportResult(text, count, errorText, "Guild data update timed out; %d cached players at level %d.", {
      count,
      maxLevel,
    })
  elseif timedOut then
    self:SetGuildExportResult(text, count, errorText, errorText or "Guild data update timed out; guild data is unavailable.")
  else
    self:SetGuildExportResult(text, count, errorText)
  end
  return true
end

function MerfinPlus:GenerateGuildExport()
  local text, count, errorText, retryable = self:BuildGuildExport()
  if not IsInGuild or not IsInGuild() then
    self.pendingGuildExport = nil
    return self:SetGuildExportResult(text, count, errorText)
  end
  if not text and not retryable then
    self.pendingGuildExport = nil
    return self:SetGuildExportResult(text, count, errorText)
  end

  self.guildExportRefreshToken = (self.guildExportRefreshToken or 0) + 1
  local token = self.guildExportRefreshToken
  self.pendingGuildExport = token
  local requested = RequestGuildRoster()
  if text then
    self:SetGuildExportResult(text, count, errorText, "Cached roster shown; waiting for fresh guild data.")
  else
    self:SetGuildExportResult(text, count, errorText, requested and "Guild roster and profession data requested. Waiting for guild data." or nil)
  end

  local function TimeoutRefresh()
    if self.pendingGuildExport == token then
      self:FinalizeGuildExportRefresh(token, true)
    end
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(GUILD_ROSTER_REFRESH_TIMEOUT, TimeoutRefresh)
  else
    TimeoutRefresh()
  end
  return text, count, errorText
end

function MerfinPlus:OnExportChatMsgLoot(_, message)
  local playerName, itemLink = self:ParseExportLootMessage(message)
  if playerName and itemLink then
    self:RecordExportLoot(playerName, itemLink)
  end
end

function MerfinPlus:OnExportPlayerEnteringWorld()
  if not GetInstanceInfo then
    self.currentExportLootSessionId = nil
    return
  end
  local _, instanceType = GetInstanceInfo()
  if instanceType ~= "raid" then
    self.currentExportLootSessionId = nil
  end
end

function MerfinPlus:OnExportEncounterStart(_, encounterID, encounterName)
  self.currentExportEncounterName = encounterName
  self.currentExportEncounterID = encounterID
  self.lastExportEncounterName = encounterName
  self.lastExportEncounterID = encounterID
  self.lastExportEncounterAt = Now()
end

function MerfinPlus:OnExportEncounterEnd(_, encounterID, encounterName)
  self.lastExportEncounterName = encounterName or self.currentExportEncounterName
  self.lastExportEncounterID = encounterID or self.currentExportEncounterID
  self.lastExportEncounterAt = Now()
  self.currentExportEncounterName = nil
  self.currentExportEncounterID = nil
end

function MerfinPlus:OnExportBossKill(_, encounterID, encounterName)
  self.currentExportEncounterName = nil
  self.currentExportEncounterID = nil
  self.lastExportEncounterName = encounterName or self.lastExportEncounterName
  self.lastExportEncounterID = encounterID or self.lastExportEncounterID
  self.lastExportEncounterAt = Now()
end

function MerfinPlus:OnExportGuildRosterUpdate()
  local token = self.pendingGuildExport
  if token then
    self:FinalizeGuildExportRefresh(token, false)
  end
end

function MerfinPlus:OnExportAddonLoaded(_, addonName)
  if addonName == "MerfinUIGuildManager" then
    local _, sourceCount = self:ImportGuildManagerLootSessions()
    if sourceCount ~= nil then
      self:UnregisterEvent("ADDON_LOADED")
    end
  end
end

function MerfinPlus:OnExportPlayerLogin()
  self:ImportGuildManagerLootSessions()
end

function MerfinPlus:InitializeExportTracking()
  self:GetExportStorage()
  self:GetExportUIState()
  self:ImportGuildManagerLootSessions()
  self:RegisterEvent("ADDON_LOADED", "OnExportAddonLoaded")
  self:RegisterEvent("PLAYER_LOGIN", "OnExportPlayerLogin")
  self:RegisterEvent("CHAT_MSG_LOOT", "OnExportChatMsgLoot")
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnExportPlayerEnteringWorld")
  self:RegisterEvent("GUILD_ROSTER_UPDATE", "OnExportGuildRosterUpdate")

  local function RegisterOptionalEvent(event, callback)
    pcall(function()
      self:RegisterEvent(event, callback)
    end)
  end
  RegisterOptionalEvent("ENCOUNTER_START", "OnExportEncounterStart")
  RegisterOptionalEvent("ENCOUNTER_END", "OnExportEncounterEnd")
  RegisterOptionalEvent("BOSS_KILL", "OnExportBossKill")
  RegisterOptionalEvent("CLUB_MEMBERS_UPDATED", "OnExportGuildRosterUpdate")
  RegisterOptionalEvent("CLUB_MEMBER_UPDATED", "OnExportGuildRosterUpdate")
  RegisterOptionalEvent("GUILD_TRADESKILL_UPDATE", "OnExportGuildRosterUpdate")
end
