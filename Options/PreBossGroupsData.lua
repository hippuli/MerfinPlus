-- Pre-Boss Groups import, catalog resolution, persistence, and secure roster moves.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local SCHEMA = "merfinui.pre-group-boss"
local VERSION = 1
local MAX_RAID_GROUPS = 8
local MAX_GROUP_SIZE = 5
local VERIFY_DELAY = 1.25
local CHAT_GREEN = "|cff59e66f"
local CHAT_RED = "|cffff5c5c"

local function Now()
  return GetServerTime and GetServerTime() or (time and time() or 0)
end

local function FormatTimestamp(timestamp)
  return date and date("%Y-%m-%d %H:%M", timestamp) or tostring(timestamp or "")
end

local function Trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function NormalizeToken(value)
  return Trim(value):lower():gsub("[%s%p%c]+", "")
end

local CANONICAL_COMP_LABELS = {
  ["tbc-tk-ssc"] = "tbc-ssc-tk",
  ["tbc-ssc-tk"] = "tbc-ssc-tk",
  ["tbc-mh-bt"] = "tbc-bt-mh",
  ["tbc-bt-mh"] = "tbc-bt-mh",
}

local CANONICAL_MFPRA_PRE_BOSS_IDS = {
  t6_hyjal_rage_winterchill = { raidKey = "mount_hyjal", bossKey = "rage_winterchill" },
  t6_hyjal_anetheron = { raidKey = "mount_hyjal", bossKey = "anetheron" },
  t6_hyjal_kazrogal = { raidKey = "mount_hyjal", bossKey = "kaz_rogal" },
  t6_hyjal_azgalor = { raidKey = "mount_hyjal", bossKey = "azgalor" },
  t6_hyjal_archimonde = { raidKey = "mount_hyjal", bossKey = "archimonde" },
  t6_black_temple_najentus = { raidKey = "black_temple", bossKey = "high_warlord_naj_entus" },
  t6_black_temple_supremus = { raidKey = "black_temple", bossKey = "supremus" },
  t6_black_temple_shade_of_akama = { raidKey = "black_temple", bossKey = "shade_of_akama" },
  t6_black_temple_teron_gorefiend = { raidKey = "black_temple", bossKey = "teron_gorefiend" },
  t6_black_temple_gurtogg_bloodboil = { raidKey = "black_temple", bossKey = "gurtogg_bloodboil" },
  t6_black_temple_reliquary_of_souls = { raidKey = "black_temple", bossKey = "reliquary_of_souls" },
  t6_black_temple_mother_shahraz = { raidKey = "black_temple", bossKey = "mother_shahraz" },
  t6_black_temple_illidari_council = { raidKey = "black_temple", bossKey = "the_illidari_council" },
  t6_black_temple_illidan_stormrage = { raidKey = "black_temple", bossKey = "illidan_stormrage" },
}

local function NormalizeCompLabel(value)
  local label = Trim(value):lower():gsub("[%s_]+", "-"):gsub("%-+", "-")
  label = label:gsub("^%-+", ""):gsub("%-+$", "")
  return CANONICAL_COMP_LABELS[label] or label
end

local function IsOpaqueCompID(value)
  return type(value) == "string"
    and value:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

local function GetDocumentCompLabel(document)
  local comp = type(document) == "table" and document.comp or nil
  local candidates = {
    type(document) == "table" and document.compName,
    type(document) == "table" and document.compLabel,
    type(comp) == "table" and comp.name,
    type(comp) == "table" and comp.label,
  }
  for _, candidate in ipairs(candidates) do
    local label = type(candidate) == "string" and Trim(candidate) or ""
    if label ~= "" and not IsOpaqueCompID(label) then
      return label
    end
  end
  return NormalizeCompLabel(type(document) == "table" and document.raidGroup)
end

local function IsPositiveInteger(value)
  return type(value) == "number" and value > 0 and value % 1 == 0
end

local function DecodeJSON(raw)
  if C_EncodingUtil and C_EncodingUtil.DeserializeJSON then
    return C_EncodingUtil.DeserializeJSON(raw)
  end
  if MerfinPlusJSON and MerfinPlusJSON.decode then
    return MerfinPlusJSON.decode(raw)
  end
  error("No JSON decoder is available.")
end

local function EncodeJSON(value)
  if MerfinPlusJSON and MerfinPlusJSON.encode then
    return MerfinPlusJSON.encode(value)
  end
  if C_EncodingUtil and C_EncodingUtil.SerializeJSON then
    return C_EncodingUtil.SerializeJSON(value)
  end
  error("No JSON encoder is available.")
end

local function GetAddonMetadata(field)
  local getter = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
  return getter and getter("MerfinPlus", field)
end

local function GetExpansionKey()
  if MerfinPlus.GetRaidCooldownTrackerExpansionKey then
    local key = MerfinPlus:GetRaidCooldownTrackerExpansionKey()
    if type(key) == "string" and key ~= "" then
      return key
    end
  end
  local flavor = NormalizeToken(GetAddonMetadata("X-Flavor"))
  return flavor ~= "" and flavor or "unknown"
end

local function BuildCatalog()
  local catalog = {}
  local expansionKey = GetExpansionKey()
  for _, group in ipairs(MerfinPlus:GetRaidAssignmentGroups() or {}) do
    for _, raid in ipairs(group.raids or {}) do
      for _, boss in ipairs(raid.bosses or {}) do
        catalog[#catalog + 1] = {
          expansionKey = expansionKey,
          groupID = group.id,
          groupName = group.name,
          raidLocaleID = raid.localeID,
          raidName = raid.name,
          bossLocaleID = boss.localeID,
          bossKey = boss.key,
          bossName = boss.name,
          icon = boss.icon,
          stableKey = table.concat({
            expansionKey,
            tostring(raid.localeID or raid.name or ""),
            tostring(boss.key or boss.name or ""),
          }, ":"),
        }
      end
    end
  end
  return catalog
end

local function ResolveCanonicalMFPRACompactBoss(catalog, compactID)
  local mapping = CANONICAL_MFPRA_PRE_BOSS_IDS[tostring(compactID or "")]
  if not mapping then return nil, "unsupported canonical Pre-Boss id" end
  local matches = {}
  for _, entry in ipairs(catalog or {}) do
    if entry.groupID == "bt_mh"
      and entry.bossKey == mapping.bossKey
      and tostring(entry.raidLocaleID or ""):match("([^:]+)$") == mapping.raidKey
    then
      matches[#matches + 1] = entry
    end
  end
  if #matches == 1 then return matches[1] end
  return nil, #matches > 1 and "ambiguous canonical Pre-Boss id" or "canonical Pre-Boss boss is unavailable"
end

local function RaidMatches(entry, raidName)
  local needle = NormalizeToken(raidName)
  if needle == "" then
    return false
  end
  local candidates = {
    entry.raidName,
    entry.raidLocaleID,
    entry.groupName,
    entry.groupID,
  }
  for _, candidate in ipairs(candidates) do
    local normalized = NormalizeToken(candidate)
    if normalized == needle
      or (normalized ~= "" and normalized:find(needle, 1, true))
      or (needle ~= "" and needle:find(normalized, 1, true))
    then
      return true
    end
  end
  return false
end

local function ResolveCatalogBoss(catalog, raidName, bossName)
  local bossNeedle = NormalizeToken(bossName)
  local bossMatches = {}
  for _, entry in ipairs(catalog) do
    if bossNeedle ~= "" and (
      NormalizeToken(entry.bossName) == bossNeedle
      or NormalizeToken(entry.bossKey) == bossNeedle
      or NormalizeToken(entry.bossLocaleID) == bossNeedle
    ) then
      bossMatches[#bossMatches + 1] = entry
    end
  end

  if #bossMatches == 1 then
    return bossMatches[1]
  end

  local raidMatches = {}
  for _, entry in ipairs(bossMatches) do
    if RaidMatches(entry, raidName) then
      raidMatches[#raidMatches + 1] = entry
    end
  end
  if #raidMatches == 1 then
    return raidMatches[1]
  end
  if #raidMatches > 1 or #bossMatches > 1 then
    return nil, "ambiguous raid/boss catalog match"
  end
  return nil, "raid/boss is not present in the active expansion catalog"
end

local function CopyPlayer(player)
  return {
    group = player.group,
    slot = player.slot,
    playerName = player.playerName,
  }
end

local function SortPlayers(left, right)
  if left.group == right.group then
    return left.slot < right.slot
  end
  return left.group < right.group
end

local function ParseDocument(raw)
  raw = Trim(raw):gsub("^\239\187\191", "")
  if raw == "" then
    return nil, "no JSON was provided"
  end

  local ok, document = pcall(DecodeJSON, raw)
  if not ok or type(document) ~= "table" then
    return nil, "invalid JSON"
  end
  if document.schema ~= SCHEMA then
    return nil, ("schema must be %s"):format(SCHEMA)
  end
  if document.version ~= VERSION then
    return nil, ("version must be %d"):format(VERSION)
  end
  if type(document.raidGroup) ~= "string"
    or Trim(document.raidGroup) == ""
  then
    return nil, "raidGroup is required"
  end
  if type(document.compId) ~= "string" or Trim(document.compId) == "" then
    return nil, "compId is required"
  end
  if type(document.bosses) ~= "table" or #document.bosses == 0 then
    return nil, "bosses must be a non-empty array"
  end

  local catalog = BuildCatalog()
  if #catalog == 0 then
    return nil, "the active expansion has no Raid Assignments catalog"
  end

  local plan = {
    schema = SCHEMA,
    version = VERSION,
    raidGroup = Trim(document.raidGroup),
    compId = Trim(document.compId),
    compLabel = GetDocumentCompLabel(document),
    expansionKey = GetExpansionKey(),
    importedAt = GetServerTime and GetServerTime() or (time and time() or 0),
    raw = raw,
    bosses = {},
  }
  local seenBosses = {}

  for bossIndex, sourceBoss in ipairs(document.bosses) do
    if type(sourceBoss) ~= "table" then
      return nil, ("bosses[%d] must be an object"):format(bossIndex)
    end
    local raidName = Trim(sourceBoss.raidName)
    local bossName = Trim(sourceBoss.bossName)
    if type(sourceBoss.raidName) ~= "string"
      or type(sourceBoss.bossName) ~= "string"
      or raidName == ""
      or bossName == ""
    then
      return nil, ("bosses[%d] requires raidName and bossName"):format(bossIndex)
    end
    local catalogBoss, resolveError =
      ResolveCatalogBoss(catalog, raidName, bossName)
    if not catalogBoss then
      return nil, ("%s / %s: %s"):format(
        raidName,
        bossName,
        resolveError
      )
    end
    if seenBosses[catalogBoss.stableKey] then
      return nil, ("duplicate boss: %s"):format(bossName)
    end
    seenBosses[catalogBoss.stableKey] = true

    if type(sourceBoss.players) ~= "table" then
      return nil, ("%s: players must be an array"):format(bossName)
    end
    local players = {}
    local occupiedSlots = {}
    local assignedNames = {}
    for playerIndex, sourcePlayer in ipairs(sourceBoss.players) do
      if type(sourcePlayer) ~= "table" then
        return nil, ("%s players[%d] must be an object"):format(
          bossName,
          playerIndex
        )
      end
      local group = sourcePlayer.group
      local slot = sourcePlayer.slot
      if not IsPositiveInteger(group) or group > MAX_RAID_GROUPS then
        return nil, ("%s players[%d] has an invalid group"):format(
          bossName,
          playerIndex
        )
      end
      if not IsPositiveInteger(slot) or slot > MAX_GROUP_SIZE then
        return nil, ("%s players[%d] has an invalid slot"):format(
          bossName,
          playerIndex
        )
      end
      local slotKey = ("%d:%d"):format(group, slot)
      if occupiedSlots[slotKey] then
        return nil, ("%s has duplicate group/slot %s"):format(
          bossName,
          slotKey
        )
      end
      occupiedSlots[slotKey] = true

      if type(sourcePlayer.playerName) ~= "string" then
        return nil, ("%s players[%d] requires playerName"):format(
          bossName,
          playerIndex
        )
      end
      local playerName = Trim(sourcePlayer.playerName)
      local normalizedName = NormalizeToken(playerName)
      if normalizedName ~= "" and assignedNames[normalizedName] then
        return nil, ("%s assigns %s more than once"):format(
          bossName,
          playerName
        )
      end
      if normalizedName ~= "" then
        assignedNames[normalizedName] = true
      end
      players[#players + 1] = CopyPlayer({
        group = group,
        slot = slot,
        playerName = playerName,
      })
    end
    table.sort(players, SortPlayers)

    plan.bosses[#plan.bosses + 1] = {
      key = catalogBoss.stableKey,
      expansionKey = catalogBoss.expansionKey,
      catalogGroupID = catalogBoss.groupID,
      raidLocaleID = catalogBoss.raidLocaleID,
      raidName = catalogBoss.raidName,
      sourceRaidName = raidName,
      bossLocaleID = catalogBoss.bossLocaleID,
      bossKey = catalogBoss.bossKey,
      bossName = catalogBoss.bossName,
      sourceBossName = bossName,
      icon = catalogBoss.icon,
      players = players,
    }
  end

  return plan
end

local function BuildStoredPlan(plan)
  return {
    schemaVersion = VERSION,
    schema = plan.schema,
    version = plan.version,
    raw = plan.raw,
    importedAt = plan.importedAt,
    parsed = plan,
  }
end

function MerfinPlus:PrepareCanonicalPreBossGroupImport(payload)
  local compact = type(payload) == "table" and type(payload.a) == "table" and payload.a.pg or nil
  if type(compact) ~= "table" or #compact == 0 then
    return nil, "MFPRA Pre-Boss Groups are missing."
  end
  local group = self:GetRaidAssignmentGroup(payload.g)
  if not group or group.id ~= "bt_mh" then
    return nil, "MFPRA Pre-Boss Groups currently require the BT/MH raid context."
  end

  local catalog = BuildCatalog()
  local document = {
    schema = SCHEMA,
    version = VERSION,
    raidGroup = group.id,
    compId = "mfpra:" .. group.id,
    compName = type(payload.a.c) == "string" and payload.a.c or "MFPRA",
    bosses = {},
  }
  for bossIndex, compactBoss in ipairs(compact) do
    local catalogBoss, resolveError = ResolveCanonicalMFPRACompactBoss(catalog, compactBoss.i)
    if not catalogBoss then
      return nil, ("a.pg[%d] %s: %s"):format(bossIndex, tostring(compactBoss.i or ""), resolveError)
    end
    local players = {}
    for groupIndex, slots in ipairs(compactBoss.g or {}) do
      for slotIndex, playerName in ipairs(slots) do
        players[#players + 1] = {
          group = groupIndex,
          slot = slotIndex,
          playerName = tostring(playerName or ""),
        }
      end
    end
    document.bosses[#document.bosses + 1] = {
      raidName = catalogBoss.raidName,
      bossName = catalogBoss.bossName,
      players = players,
    }
  end

  local encodeOK, raw = pcall(EncodeJSON, document)
  if not encodeOK or type(raw) ~= "string" or raw == "" then
    return nil, "MFPRA Pre-Boss Groups could not be converted to the local document."
  end
  local plan, errorText = ParseDocument(raw)
  if not plan then return nil, "MFPRA Pre-Boss Groups are invalid: " .. tostring(errorText) end
  plan.raidGroupID = group.id
  return {
    raw = raw,
    plan = plan,
    raidGroupID = group.id,
    revision = payload.r,
  }
end

function MerfinPlus:CommitCanonicalPreBossGroupImport(prepared)
  if type(prepared) ~= "table" or type(prepared.plan) ~= "table"
    or type(prepared.raw) ~= "string" or type(prepared.raidGroupID) ~= "string"
  then
    return nil, "Prepared MFPRA Pre-Boss Groups are invalid."
  end
  local storage = self:GetPreBossGroupStorage()
  local plan = prepared.plan
  local now = Now()
  plan.importedAt = now
  plan.raidGroupID = prepared.raidGroupID

  local entry
  for _, candidate in ipairs(storage.preBossImports) do
    if candidate.canonicalMFPRA == true and candidate.raidGroupID == prepared.raidGroupID then
      entry = candidate
      break
    end
  end
  if not entry then
    entry = {
      id = tostring(now) .. "-mfpra-preboss-" .. tostring(#storage.preBossImports + 1),
      canonicalMFPRA = true,
    }
    storage.preBossImports[#storage.preBossImports + 1] = entry
  end
  entry.raw = prepared.raw
  entry.compId = plan.compId
  entry.compLabel = plan.compLabel
  entry.raidGroup = plan.raidGroup
  entry.raidGroupID = prepared.raidGroupID
  entry.importedAt = now
  entry.importedAtText = FormatTimestamp(now)
  entry.canonicalRevision = prepared.revision

  storage.preBossPlanStore = BuildStoredPlan(plan)
  storage.activePreBossImportId = entry.id
  storage.preBossPlan = nil
  self.preBossGroupPlan = plan
  self.preBossGroupPlanHydrated = true
  self.preBossGroupHydrationError = nil
  local state = self:GetPreBossGroupUIState()
  state.input = ""
  state.selectedSavedPreBossImportID = entry.id
  state.selectedRaidGroupID = prepared.raidGroupID
  self:NotifyPreBossGroupsChanged()
  return plan
end

function MerfinPlus:GetPreBossGroupStorage()
  local storage = self:GetRaidAssignmentStorage()
  if type(storage.preBossPlanStore) ~= "table" then
    storage.preBossPlanStore = {
      schemaVersion = VERSION,
    }
  end
  storage.preBossImports = storage.preBossImports or {}
  return storage
end

function MerfinPlus:InitializePreBossGroups()
  if self.preBossGroupPlanHydrated then
    return self.preBossGroupPlan
  end
  self.preBossGroupPlanHydrated = true

  local storage = self:GetPreBossGroupStorage()
  local stored = storage.preBossPlanStore
  local legacy = type(storage.preBossPlan) == "table"
    and storage.preBossPlan
    or nil
  local raw = type(stored.raw) == "string" and stored.raw
    or (legacy and type(legacy.raw) == "string" and legacy.raw)

  if not raw then
    self.preBossGroupPlan = nil
    return nil
  end

  local plan, errorText = ParseDocument(raw)
  if not plan then
    self.preBossGroupPlan = nil
    self.preBossGroupHydrationError = errorText
    return nil, errorText
  end

  local importedAt = tonumber(stored.importedAt)
    or (legacy and tonumber(legacy.importedAt))
  if importedAt then
    plan.importedAt = importedAt
  end

  -- Rebuild derived catalog references from the persisted source on every
  -- startup.  The single assignment below also migrates the legacy
  -- assignments.preBossPlan representation atomically.
  storage.preBossPlanStore = BuildStoredPlan(plan)
  storage.preBossPlan = nil
  self.preBossGroupPlan = plan
  self.preBossGroupHydrationError = nil
  return plan
end

function MerfinPlus:GetPreBossGroupPlan()
  if not self.preBossGroupPlanHydrated then
    self:InitializePreBossGroups()
  end
  return self.preBossGroupPlan
end

function MerfinPlus:GetPreBossGroupRaidGroupID(plan)
  local groupID
  for _, boss in ipairs(plan and plan.bosses or {}) do
    local candidate = boss.catalogGroupID
    if candidate and self:GetRaidAssignmentGroup(candidate) then
      if groupID and groupID ~= candidate then
        return nil
      end
      groupID = candidate
    end
  end
  return groupID
end

function MerfinPlus:GetPreBossGroupPlanBoss(raid, catalogBoss)
  if type(raid) ~= "table" or type(catalogBoss) ~= "table" then
    return nil
  end
  local expansionKey = GetExpansionKey()
  local plan = self:GetPreBossGroupPlan()
  -- The Raid Leader widget can be opened before its first Pre-Boss refresh.
  -- Retry the persisted raw plan once so its Set Group action uses the same
  -- hydrated state as the dedicated Pre-Boss Groups view.
  if not plan then
    self.preBossGroupPlanHydrated = nil
    plan = self:GetPreBossGroupPlan()
  end
  local raidKey = NormalizeToken(raid.localeID or raid.name)
  local bossKey = NormalizeToken(catalogBoss.key or catalogBoss.name)
  for _, boss in ipairs(plan and plan.bosses or {}) do
    if boss.expansionKey == expansionKey
      and NormalizeToken(boss.raidLocaleID or boss.raidName) == raidKey
      and NormalizeToken(boss.bossKey or boss.bossName) == bossKey
    then
      return boss
    end
  end
end

function MerfinPlus:ApplyPreBossGroupPlanForCatalogBoss(raid, catalogBoss)
  local boss = self:GetPreBossGroupPlanBoss(raid, catalogBoss)
  if not boss then
    return self:ApplyPreBossGroupPlan(nil)
  end
  return self:ApplyPreBossGroupPlan(boss.key)
end

function MerfinPlus:GetPreBossGroupUIState()
  self.preBossGroupUIState = self.preBossGroupUIState or {
    input = "",
    status = "",
    statusTone = "muted",
  }
  if self.preBossGroupUIState.selectedRaidGroupID
    and not self:GetRaidAssignmentGroup(self.preBossGroupUIState.selectedRaidGroupID)
  then
    self.preBossGroupUIState.selectedRaidGroupID = nil
  end
  return self.preBossGroupUIState
end

function MerfinPlus:SetPreBossGroupRaidContext(groupID)
  if groupID and not self:GetRaidAssignmentGroup(groupID) then
    return false, "Unsupported Pre-Boss Groups raid."
  end
  local state = self:GetPreBossGroupUIState()
  state.selectedRaidGroupID = groupID
  self:NotifyPreBossGroupsChanged()
  return true
end

function MerfinPlus:GetSavedPreBossGroupImports()
  local saved = {}
  for _, entry in ipairs(self:GetPreBossGroupStorage().preBossImports or {}) do
    if type(entry.raw) == "string" and entry.raw ~= "" then
      if Trim(entry.compLabel) == "" or IsOpaqueCompID(Trim(entry.compLabel)) then
        local plan = ParseDocument(entry.raw)
        if plan then
          entry.compLabel = plan.compLabel
          entry.raidGroup = entry.raidGroup or plan.raidGroup
        end
      end
      local compLabel = Trim(entry.compLabel)
      if IsOpaqueCompID(compLabel) then
        compLabel = ""
      end
      if compLabel == "" then
        compLabel = NormalizeCompLabel(entry.raidGroup)
      end
      if compLabel == "" then
        compLabel = "Comp"
      end
      entry.importedAtText = FormatTimestamp(entry.importedAt)
      entry.savedLabel = compLabel .. " - " .. tostring(entry.importedAtText or "")
      saved[#saved + 1] = entry
    end
  end
  table.sort(saved, function(left, right)
    local leftAt, rightAt = tonumber(left.importedAt) or 0, tonumber(right.importedAt) or 0
    if leftAt == rightAt then
      return tostring(left.id) > tostring(right.id)
    end
    return leftAt > rightAt
  end)
  return saved
end

function MerfinPlus:SelectSavedPreBossGroupImport(importID)
  for _, entry in ipairs(self:GetSavedPreBossGroupImports()) do
    if entry.id == importID then
      local plan, errorText = ParseDocument(entry.raw)
      if not plan then
        return nil, errorText
      end
      local groupID = entry.raidGroupID
        or self:GetPreBossGroupRaidGroupID(plan)
      if groupID and not self:GetRaidAssignmentGroup(groupID) then
        return nil, "Saved Pre-Boss Groups import has an unsupported raid context."
      end
      entry.raidGroupID = groupID
      entry.compLabel = plan.compLabel
      entry.raidGroup = plan.raidGroup
      plan.raidGroupID = groupID
      plan.importedAt = tonumber(entry.importedAt) or plan.importedAt
      local storage = self:GetPreBossGroupStorage()
      storage.preBossPlanStore = BuildStoredPlan(plan)
      storage.activePreBossImportId = entry.id
      self.preBossGroupPlan = plan
      self.preBossGroupPlanHydrated = true
      self.preBossGroupHydrationError = nil
      local state = self:GetPreBossGroupUIState()
      state.selectedSavedPreBossImportID = entry.id
      state.selectedRaidGroupID = groupID
      self:NotifyPreBossGroupsChanged()
      return plan
    end
  end
  return nil, "Saved Pre-Boss Groups import is unavailable."
end

function MerfinPlus:RemoveSavedPreBossGroupImport(importID)
  local storage = self:GetPreBossGroupStorage()
  for index, entry in ipairs(storage.preBossImports or {}) do
    if entry.id == importID then
      table.remove(storage.preBossImports, index)
      if storage.activePreBossImportId == importID then
        storage.activePreBossImportId = nil
        storage.preBossPlanStore = { schemaVersion = VERSION }
        self.preBossGroupPlan = nil
        self.preBossGroupPlanHydrated = true
      end
      local state = self:GetPreBossGroupUIState()
      if state.selectedSavedPreBossImportID == importID then
        state.selectedSavedPreBossImportID = nil
      end
      self:NotifyPreBossGroupsChanged()
      return true
    end
  end
  return false, "Saved Pre-Boss Groups import is unavailable."
end

function MerfinPlus:GetPreBossGroupBossDisplayName(boss)
  return self:GetLocalizedBossName(
    boss and boss.bossLocaleID,
    boss and boss.bossName or ""
  )
end

function MerfinPlus:GetPreBossGroupRaidDisplayName(boss)
  return self:GetLocalizedRaidName(
    boss and boss.raidLocaleID,
    boss and boss.raidName or ""
  )
end

local function PrintPreBossChat(color, text)
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(
      color .. "[Merfin Plus] " .. tostring(text or "") .. "|r"
    )
  end
end

local function PrintGroupError(bossName, reason)
  PrintPreBossChat(CHAT_RED, MerfinPlus:T(
    "Group set failed for %s: %s"
  ):format(bossName, reason))
end

local function PrintGroupSuccess(
  bossName,
  groupsMatched,
  desiredCount,
  slotsMatched,
  moves,
  skipped
)
  PrintPreBossChat(CHAT_GREEN, MerfinPlus:T(
    "Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."
  ):format(
    bossName,
    groupsMatched,
    desiredCount,
    slotsMatched,
    desiredCount,
    moves,
    skipped
  ))
end

function MerfinPlus:SavePreBossGroupImport(raw, selectedGroupID)
  local plan, errorText = ParseDocument(raw)
  if not plan then
    PrintPreBossChat(CHAT_RED, self:T(
      "Pre-Boss Groups import failed: %s"
    ):format(errorText))
    return nil, errorText
  end

  local inferredGroupID = self:GetPreBossGroupRaidGroupID(plan)
  local groupID = selectedGroupID or inferredGroupID
  if groupID and not self:GetRaidAssignmentGroup(groupID) then
    return nil, "Unsupported Pre-Boss Groups raid."
  end
  if inferredGroupID and groupID and inferredGroupID ~= groupID then
    return nil, "This Pre-Boss Groups import belongs to a different raid context."
  end
  if not groupID then
    return nil, "Unable to determine the Pre-Boss Groups raid context."
  end
  plan.raidGroupID = groupID

  local storage = self:GetPreBossGroupStorage()
  local storedPlan = BuildStoredPlan(plan)

  for _, entry in ipairs(storage.preBossImports) do
    if entry.raw == plan.raw then
      entry.raidGroupID = groupID
      entry.compLabel = plan.compLabel
      entry.raidGroup = plan.raidGroup
      storage.preBossPlanStore = storedPlan
      storage.activePreBossImportId = entry.id
      self.preBossGroupPlan = plan
      self.preBossGroupPlanHydrated = true
      self.preBossGroupHydrationError = nil
      local state = self:GetPreBossGroupUIState()
      state.input = ""
      state.selectedSavedPreBossImportID = entry.id
      state.selectedRaidGroupID = groupID
      self:NotifyPreBossGroupsChanged()
      return plan, nil, true
    end
  end

  local now, ordinal, used = Now(), #storage.preBossImports + 1, {}
  for _, entry in ipairs(storage.preBossImports) do
    used[entry.id] = true
  end
  local importID
  repeat
    importID = tostring(now) .. "-preboss-" .. tostring(ordinal)
    ordinal = ordinal + 1
  until not used[importID]
  storage.preBossImports[#storage.preBossImports + 1] = {
    id = importID,
    raw = plan.raw,
    compId = plan.compId,
    compLabel = plan.compLabel,
    raidGroup = plan.raidGroup,
    raidGroupID = groupID,
    importedAt = now,
    importedAtText = FormatTimestamp(now),
  }

  -- Parse and build completely before replacing the persisted plan.  An
  -- invalid import returns above and can therefore never destroy the last
  -- valid saved plan.
  storage.preBossPlanStore = storedPlan
  storage.activePreBossImportId = importID
  storage.preBossPlan = nil
  self.preBossGroupPlan = plan
  self.preBossGroupPlanHydrated = true
  self.preBossGroupHydrationError = nil
  local state = self:GetPreBossGroupUIState()
  state.input = ""
  state.selectedSavedPreBossImportID = importID
  state.selectedRaidGroupID = groupID
  self:NotifyPreBossGroupsChanged()
  return plan, nil, false
end

local function SplitPlayerName(name)
  name = Trim(name)
  local base, realm = name:match("^([^%-]+)%-(.+)$")
  return base or name, realm
end

local function NormalizeRealm(realm)
  return NormalizeToken(realm)
end

local function GetLocalRealm()
  if GetNormalizedRealmName then
    return GetNormalizedRealmName()
  end
  return GetRealmName and GetRealmName() or ""
end

local function BuildRoster()
  local roster = {}
  local groupSlots = {}
  local localRealm = GetLocalRealm()
  local memberCount = GetNumGroupMembers and GetNumGroupMembers() or 0
  for index = 1, memberCount do
    local name, _, subgroup, _, _, _, _, online =
      GetRaidRosterInfo(index)
    if name then
      local base, realm = SplitPlayerName(name)
      realm = realm or localRealm
      groupSlots[subgroup] = (groupSlots[subgroup] or 0) + 1
      roster[#roster + 1] = {
        index = index,
        name = name,
        baseKey = NormalizeToken(base),
        realmKey = NormalizeRealm(realm),
        fullKey = NormalizeToken(base) .. "-" .. NormalizeRealm(realm),
        group = subgroup,
        slot = groupSlots[subgroup],
        online = online ~= false,
      }
    end
  end
  return roster
end

local function ResolveRosterPlayer(roster, importedName)
  local base, realm = SplitPlayerName(importedName)
  local baseKey = NormalizeToken(base)
  local realmKey = realm and NormalizeRealm(realm) or nil
  local matches = {}
  for _, member in ipairs(roster) do
    if member.baseKey == baseKey
      and (not realmKey or member.realmKey == realmKey)
    then
      matches[#matches + 1] = member
    end
  end
  if #matches == 1 then
    return matches[1]
  end
  return nil, #matches > 1 and "ambiguous" or "missing", matches
end

local function RemoveGroupMember(groupMembers, group, index)
  for position, memberIndex in ipairs(groupMembers[group] or {}) do
    if memberIndex == index then
      table.remove(groupMembers[group], position)
      return
    end
  end
end

local function AddGroupMember(groupMembers, group, index)
  groupMembers[group] = groupMembers[group] or {}
  groupMembers[group][#groupMembers[group] + 1] = index
end

local function CallRosterAPI(func, ...)
  if type(func) ~= "function" then
    return false, "required roster API is unavailable"
  end
  local ok, errorText = pcall(func, ...)
  return ok, ok and nil or tostring(errorText)
end

local function ApplyGroupMoves(roster, desired)
  local currentGroup = {}
  local groupMembers = {}
  local groupCount = {}
  local rosterByIndex = {}
  for _, member in ipairs(roster) do
    rosterByIndex[member.index] = member
    currentGroup[member.index] = member.group
    AddGroupMember(groupMembers, member.group, member.index)
    groupCount[member.group] = (groupCount[member.group] or 0) + 1
  end

  local moves, apiErrors, apiErrorByIndex = 0, {}, {}
  local maximumPasses = math.max(1, #desired + 1)
  for _ = 1, maximumPasses do
    local changed = false
    for _, target in ipairs(desired) do
      local sourceGroup = currentGroup[target.index]
      local targetGroup = target.group
      if sourceGroup and sourceGroup ~= targetGroup then
        local ok, errorText
        if (groupCount[targetGroup] or 0) < MAX_GROUP_SIZE then
          ok, errorText = CallRosterAPI(
            SetRaidSubgroup,
            target.index,
            targetGroup
          )
          if ok then
            RemoveGroupMember(groupMembers, sourceGroup, target.index)
            AddGroupMember(groupMembers, targetGroup, target.index)
            groupCount[sourceGroup] = (groupCount[sourceGroup] or 1) - 1
            groupCount[targetGroup] = (groupCount[targetGroup] or 0) + 1
            currentGroup[target.index] = targetGroup
          end
        else
          local swapIndex
          for _, candidateIndex in ipairs(groupMembers[targetGroup] or {}) do
            local candidateTarget = desired.byIndex[candidateIndex]
            local candidate = rosterByIndex[candidateIndex]
            if candidate and candidate.online
              and not desired.protectedByIndex[candidateIndex]
              and (not candidateTarget or candidateTarget.group ~= targetGroup)
            then
              swapIndex = candidateIndex
              break
            end
          end
          if swapIndex then
            ok, errorText = CallRosterAPI(
              SwapRaidSubgroup,
              target.index,
              swapIndex
            )
            if ok then
              RemoveGroupMember(groupMembers, sourceGroup, target.index)
              RemoveGroupMember(groupMembers, targetGroup, swapIndex)
              AddGroupMember(groupMembers, targetGroup, target.index)
              AddGroupMember(groupMembers, sourceGroup, swapIndex)
              currentGroup[target.index] = targetGroup
              currentGroup[swapIndex] = sourceGroup
            end
          else
            ok, errorText = false, "target subgroup is full"
          end
        end

        if ok then
          moves = moves + 1
          changed = true
        elseif not apiErrorByIndex[target.index] then
          apiErrorByIndex[target.index] = true
          apiErrors[#apiErrors + 1] = errorText or "roster API failed"
        end
      end
    end
    if not changed then
      break
    end
  end

  return moves, apiErrors
end

local function FindPlanBoss(plan, bossKey)
  for _, boss in ipairs(plan and plan.bosses or {}) do
    if boss.key == bossKey then
      return boss
    end
  end
end

local function BuildDesiredRoster(boss, roster)
  local desired = { byIndex = {}, protectedByIndex = {} }
  local missing, ambiguous, offline = 0, 0, 0
  for _, player in ipairs(boss.players or {}) do
    if player.playerName ~= "" then
      local member, failure, matches =
        ResolveRosterPlayer(roster, player.playerName)
      if not member then
        if failure == "ambiguous" then
          ambiguous = ambiguous + 1
          for _, match in ipairs(matches or {}) do
            desired.protectedByIndex[match.index] = true
          end
        else
          missing = missing + 1
        end
      elseif not member.online then
        offline = offline + 1
        desired.protectedByIndex[member.index] = true
      elseif desired.protectedByIndex[member.index] then
        ambiguous = ambiguous + 1
      elseif desired.byIndex[member.index] then
        ambiguous = ambiguous + 1
        desired.protectedByIndex[member.index] = true
        desired.byIndex[member.index] = nil
        for index = #desired, 1, -1 do
          if desired[index].index == member.index then
            table.remove(desired, index)
            break
          end
        end
      else
        local target = {
          index = member.index,
          importedName = player.playerName,
          group = player.group,
          slot = player.slot,
          online = member.online,
        }
        desired[#desired + 1] = target
        desired.byIndex[member.index] = target
      end
    end
  end
  table.sort(desired, SortPlayers)
  return desired, missing, ambiguous, offline
end

local function VerifyDesiredRoster(desired)
  local roster = BuildRoster()
  local groupsMatched, slotsMatched = 0, 0
  local missing = 0
  for _, target in ipairs(desired) do
    local member = ResolveRosterPlayer(roster, target.importedName)
    if not member then
      missing = missing + 1
    else
      if member.group == target.group then
        groupsMatched = groupsMatched + 1
      end
      if member.group == target.group and member.slot == target.slot then
        slotsMatched = slotsMatched + 1
      end
    end
  end
  return groupsMatched, slotsMatched, missing
end

function MerfinPlus:ApplyPreBossGroupPlan(bossKey)
  local plan = self:GetPreBossGroupPlan()
  local boss = FindPlanBoss(plan, bossKey)
  if not boss then
    PrintGroupError(
      self:T("Pre-Boss Groups"),
      self:T("No Pre-Boss Groups plan imported.")
    )
    return
  end

  local displayName = self:GetPreBossGroupBossDisplayName(boss)
  if self.preBossActionPending then
    PrintGroupError(
      displayName,
      self:T("Another group update is still being verified.")
    )
    return
  end
  if InCombatLockdown and InCombatLockdown() then
    PrintGroupError(
      displayName,
      self:T("Raid groups cannot be changed during combat.")
    )
    return
  end
  if not IsInRaid or not IsInRaid() then
    PrintGroupError(
      displayName,
      self:T("You must be in a raid to set groups.")
    )
    return
  end
  if not (
    UnitIsGroupLeader and UnitIsGroupLeader("player")
    or UnitIsGroupAssistant and UnitIsGroupAssistant("player")
  ) then
    PrintGroupError(
      displayName,
      self:T("Only the raid leader or a raid assistant can set groups.")
    )
    return
  end
  if type(SetRaidSubgroup) ~= "function"
    or type(SwapRaidSubgroup) ~= "function"
  then
    PrintGroupError(
      displayName,
      self:T("The raid roster APIs are unavailable in this client.")
    )
    return
  end

  local roster = BuildRoster()
  local desired, missing, ambiguous, offline =
    BuildDesiredRoster(boss, roster)
  if #desired == 0 then
    PrintGroupError(
      displayName,
      self:T(
        "No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."
      ):format(missing, offline, ambiguous)
    )
    return
  end

  local moves = ApplyGroupMoves(roster, desired)
  self.preBossActionPending = true

  local function FinishVerification()
    MerfinPlus.preBossActionPending = false
    local groupsMatched, slotsMatched =
      VerifyDesiredRoster(desired)
    local skipped = missing + offline + ambiguous
      + math.max(0, #desired - groupsMatched)
    if groupsMatched == 0 then
      PrintGroupError(
        displayName,
        MerfinPlus:T(
          "Roster verification failed (groups %d/%d, slots %d/%d)."
        ):format(groupsMatched, #desired, slotsMatched, #desired)
      )
    else
      PrintGroupSuccess(
        displayName,
        groupsMatched,
        #desired,
        slotsMatched,
        moves,
        skipped
      )
    end
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(VERIFY_DELAY, FinishVerification)
  else
    FinishVerification()
  end
end

function MerfinPlus:RegisterPreBossGroupsWidget(widget)
  self.preBossGroupWidgets = self.preBossGroupWidgets or {}
  self.preBossGroupWidgets[widget] = true
end

function MerfinPlus:UnregisterPreBossGroupsWidget(widget)
  if self.preBossGroupWidgets then
    self.preBossGroupWidgets[widget] = nil
  end
end

function MerfinPlus:NotifyPreBossGroupsChanged()
  for widget in pairs(self.preBossGroupWidgets or {}) do
    if widget.Refresh then
      widget:Refresh()
    end
  end
  -- The Raid Leader rows cache whether their Set Group control has a local
  -- plan. Refresh them whenever this client's plan is imported, selected, or
  -- removed so the click always resolves through the same hydrated plan.
  if self.MarkAssignmentWidgetContentDirty then
    self:MarkAssignmentWidgetContentDirty("raidLeaderWidget")
  elseif self.RefreshRaidLeaderWidget then
    self:RefreshRaidLeaderWidget()
  end
end
