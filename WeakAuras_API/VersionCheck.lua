local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local ADDON_NAME = "MerfinPlus"
local PREFIX = "MERFIN_VC"
local PACK_KEY = "T5"
local SCAN_SECONDS = 3
local FRAME_WIDTH = 620
local FRAME_HEIGHT = 470
local HEADER_HEIGHT = 70
local ROW_HEIGHT = 28
local LOGO_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\merfinplus_logo_inner.png"
local LOGO_BACKPLATE_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\options\\portrait_backplate_dark.png"
local LOGO_FRAME_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\options\\portrait_frame_gold.png"
local SPINNER_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\textures\\ring_2.png"
local READY_TEXTURE = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
local NOT_READY_TEXTURE = "Interface\\RAIDFRAME\\ReadyCheck-NotReady"
local FONT_FALLBACK = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local LSM = LibStub("LibSharedMedia-3.0", true)
local L = MerfinPlus.L or setmetatable({}, {
  __index = function(_, key)
    return key
  end,
})

local COLORS = {
  bg = { 0.012, 0.012, 0.014, 0.985 },
  panel = { 0.026, 0.025, 0.029, 0.98 },
  header = { 0.018, 0.017, 0.021, 0.995 },
  input = { 0.012, 0.012, 0.014, 0.98 },
  border = { 0.86, 0.58, 0.08, 1 },
  borderSoft = { 0.86, 0.58, 0.08, 0.48 },
  text = { 0.96, 0.94, 0.88, 1 },
  muted = { 0.72, 0.68, 0.58, 1 },
  button = { 0.12, 0.095, 0.045, 1 },
  buttonHover = { 0.25, 0.17, 0.055, 1 },
  buttonPressed = { 0.07, 0.055, 0.028, 1 },
  buttonDisabled = { 0.105, 0.1, 0.09, 1 },
  error = { 1, 0.42, 0.38, 1 },
  ok = { 0.45, 0.92, 0.55, 1 },
  close = { 0.12, 0.025, 0.025, 1 },
  row = { 0.018, 0.017, 0.021, 0.68 },
  rowAlt = { 0.055, 0.046, 0.027, 0.5 },
}

local state = {
  addonVersions = {},
  raidPackVersions = {},
  roster = {},
  rows = {},
  scanningUntil = 0,
}

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

local function RegisterEscClose(frameName)
  if not UISpecialFrames then
    return
  end

  for _, name in ipairs(UISpecialFrames) do
    if name == frameName then
      return
    end
  end

  table.insert(UISpecialFrames, frameName)
end

local function SetTextureColor(texture, color)
  if texture.SetColorTexture then
    texture:SetColorTexture(color[1], color[2], color[3], color[4])
  else
    texture:SetTexture(color[1], color[2], color[3], color[4])
  end
end

local function SetFontColor(fontString, color)
  fontString:SetTextColor(color[1], color[2], color[3], color[4])
end

local function GetVersionCheckFont()
  local profile = MerfinPlus.db and MerfinPlus.db.profile
  local fontName = profile and profile.font1

  if LSM and LSM.Fetch then
    return (fontName and LSM:Fetch("font", fontName, true))
      or LSM:Fetch("font", "Merfin Font 1", true)
      or LSM:Fetch("font", "Expressway", true)
      or FONT_FALLBACK
  end

  return FONT_FALLBACK
end

local function StyleFont(fontString, size, color, isBold)
  local font = GetVersionCheckFont()
  MerfinPlus:ApplyLocalizedFont(fontString, font or FONT_FALLBACK, size)
  SetFontColor(fontString, color)
end

local function SetPanelBackdrop(frame, bgColor, borderColor)
  if not frame.SetBackdrop then
    return
  end

  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })

  if bgColor then
    frame:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
  end

  if borderColor then
    frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
  else
    frame:SetBackdropBorderColor(0, 0, 0, 0)
  end
end

local function CreatePanel(parent, name, bgColor, borderColor)
  local panel = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate")
  SetPanelBackdrop(panel, bgColor, borderColor)
  return panel
end

local function GetAddonVersion()
  if GetAddOnMetadata then
    return GetAddOnMetadata(ADDON_NAME, "Version") or "?"
  end
  return "?"
end

local function SplitVersion(version)
  if not version or version == "" or version == "MISSING" then
    return
  end

  local parts = {}
  for part in tostring(version):gmatch("%d+") do
    parts[#parts + 1] = tonumber(part)
  end

  if #parts == 0 then
    return
  end

  return parts
end

local function CompareVersions(leftVersion, rightVersion)
  local left = SplitVersion(leftVersion)
  local right = SplitVersion(rightVersion)

  if not left or not right then
    return
  end

  local length = math.max(#left, #right)
  for index = 1, length do
    local leftPart = left[index] or 0
    local rightPart = right[index] or 0

    if leftPart < rightPart then
      return -1
    elseif leftPart > rightPart then
      return 1
    end
  end

  return 0
end

local function IsVersionCurrentOrNewer(version, currentVersion)
  if not version or version == "" or version == "MISSING" then
    return false
  end

  if not currentVersion or currentVersion == "" or currentVersion == "?" then
    return false
  end

  local comparison = CompareVersions(version, currentVersion)
  if comparison then
    return comparison >= 0
  end

  return tostring(version) == tostring(currentVersion)
end

local function NormalizeRealm(realm)
  if not realm or realm == "" then
    if GetNormalizedRealmName then
      realm = GetNormalizedRealmName()
    else
      realm = GetRealmName()
    end
  end
  return (realm or ""):gsub("%s+", "")
end

local function GetUnitFullName(unit)
  if not UnitExists(unit) then
    return
  end

  local name, realm = UnitFullName(unit)
  if not name then
    return
  end

  realm = NormalizeRealm(realm)
  return name, name .. "-" .. realm
end

local function StoreVersion(cache, sender, version)
  if not sender or not version or version == "" then
    return
  end

  version = tostring(version)

  local keys = { sender }
  local shortName = Ambiguate and Ambiguate(sender, "none") or sender:match("^[^-]+")
  if shortName and shortName ~= "" then
    table.insert(keys, shortName)
  end

  local name, realm = strsplit("-", sender)
  if name and name ~= "" then
    table.insert(keys, name)
    if realm and realm ~= "" then
      table.insert(keys, name .. "-" .. NormalizeRealm(realm))
    end
  end

  if version == "MISSING" then
    for _, key in ipairs(keys) do
      if cache[key] and cache[key] ~= "MISSING" then
        return
      end
    end
  end

  cache[sender] = version

  if shortName and shortName ~= "" then
    cache[shortName] = version
  end

  if name and name ~= "" then
    cache[name] = version
    if realm and realm ~= "" then
      cache[name .. "-" .. NormalizeRealm(realm)] = version
    end
  end
end

local function LookupCachedVersion(cache, entry)
  if not entry then
    return
  end

  return cache[entry.fullName] or cache[entry.name]
end

local function GetDataVersion(data)
  if type(data) ~= "table" then
    return
  end

  if data.semver and data.semver ~= "" then
    return tostring(data.semver)
  end
end

local function FindRaidPackVersionInDisplays(displays)
  if type(displays) ~= "table" then
    return
  end

  for _, data in pairs(displays) do
    if type(data) == "table" then
      local isT5RaidPack = data.wagoID == "1qyg9npGm"
        or (type(data.url) == "string" and data.url:find("wago.io/merfin_t5", 1, true))
        or data.id == "[T5] Core"
        or data.parent == "[T5] Core"

      if isT5RaidPack then
        local version = GetDataVersion(data)
        if version then
          return version
        end
      end
    end
  end
end

local function GetLocalRaidPackVersion()
  local ids = { "[T5] Core", "[T5] MerfinPlus Check" }

  if WeakAuras and WeakAuras.GetData then
    for _, id in ipairs(ids) do
      local version = GetDataVersion(WeakAuras.GetData(id))
      if version then
        return version
      end
    end
  end

  if WeakAurasSaved and WeakAurasSaved.displays then
    for _, id in ipairs(ids) do
      local version = GetDataVersion(WeakAurasSaved.displays[id])
      if version then
        return version
      end
    end

    return FindRaidPackVersionInDisplays(WeakAurasSaved.displays)
  end
end

local function StoreLocalVersions()
  local playerName, playerFullName = GetUnitFullName("player")
  if not playerName then
    return
  end

  StoreVersion(state.addonVersions, playerFullName or playerName, GetAddonVersion())

  local raidPackVersion = GetLocalRaidPackVersion()
  if raidPackVersion then
    StoreVersion(state.raidPackVersions, playerFullName or playerName, raidPackVersion)
  end
end

local function LookupAddonVersion(entry)
  local version = LookupCachedVersion(state.addonVersions, entry)
  if version then
    return version
  end

  local lib = LibStub and LibStub("LibVersionCheck-1.0", true)
  if not lib or not lib.GetAddonVersionsForAddon then
    return
  end

  local versions = lib:GetAddonVersionsForAddon(ADDON_NAME)
  if not versions then
    return
  end

  version = versions[entry.fullName] or versions[entry.name]
  if not version and Ambiguate then
    for playerName, addonVersion in pairs(versions) do
      if Ambiguate(playerName, "none") == entry.name then
        version = addonVersion
        break
      end
    end
  end

  if version then
    StoreVersion(state.addonVersions, entry.fullName or entry.name, version)
  end

  return version
end

local function GetClassColorString(class)
  local color = class and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
  if not color then
    return "ffffffff"
  end

  if color.colorStr then
    return color.colorStr
  end

  local r = math.floor((color.r or 1) * 255 + 0.5)
  local g = math.floor((color.g or 1) * 255 + 0.5)
  local b = math.floor((color.b or 1) * 255 + 0.5)
  return ("ff%02x%02x%02x"):format(r, g, b)
end

local function GetColoredName(entry)
  return ("|c%s%s|r"):format(GetClassColorString(entry.class), entry.name or "?")
end

local function AddRosterUnit(unit)
  local name, fullName = GetUnitFullName(unit)
  if not name then
    return
  end

  local _, class = UnitClass(unit)
  table.insert(state.roster, {
    unit = unit,
    name = name,
    fullName = fullName or name,
    class = class,
  })
end

local function BuildRoster()
  wipe(state.roster)

  if IsInRaid() then
    local numRaidMembers = 0
    if GetNumGroupMembers then
      numRaidMembers = GetNumGroupMembers()
    elseif GetNumRaidMembers then
      numRaidMembers = GetNumRaidMembers()
    end
    for i = 1, numRaidMembers do
      AddRosterUnit("raid" .. i)
    end
  elseif IsInGroup() then
    AddRosterUnit("player")
    local numPartyMembers = 0
    if GetNumSubgroupMembers then
      numPartyMembers = GetNumSubgroupMembers()
    elseif GetNumPartyMembers then
      numPartyMembers = GetNumPartyMembers()
    end
    for i = 1, numPartyMembers do
      AddRosterUnit("party" .. i)
    end
  else
    AddRosterUnit("player")
  end
end

local function RegisterPrefix()
  if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
  elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(PREFIX)
  end
end

local function SendAddonMessageSafe(prefix, message, channel, target)
  if C_ChatInfo and C_ChatInfo.SendAddonMessage then
    C_ChatInfo.SendAddonMessage(prefix, message, channel, target)
  elseif SendAddonMessage then
    SendAddonMessage(prefix, message, channel, target)
  end
end

local function GetGroupChannel()
  if LE_PARTY_CATEGORY_INSTANCE and (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) then
    return "INSTANCE_CHAT"
  end

  if IsInRaid() then
    return "RAID"
  end

  if IsInGroup() then
    return "PARTY"
  end
end

local function IsSelf(sender)
  if not sender then
    return false
  end

  local playerName = UnitName("player")
  return sender == playerName or (Ambiguate and Ambiguate(sender, "none") == playerName)
end

local function SendOwnVersions(target)
  if target and target ~= "" then
    SendAddonMessageSafe(PREFIX, "MP:" .. GetAddonVersion(), "WHISPER", target)

    local raidPackVersion = GetLocalRaidPackVersion()
    if raidPackVersion then
      SendAddonMessageSafe(PREFIX, "WA:" .. PACK_KEY .. ":" .. raidPackVersion, "WHISPER", target)
    end
  end
end

local function IsScanning()
  return state.scanningUntil and state.scanningUntil > GetTime()
end

local function GetDisplayVersion(version)
  if version and version ~= "" then
    return version
  end

  if IsScanning() then
    return "..."
  end

  return "MISSING"
end

local function CreateModernButton(parent, label, width)
  local button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
  button:SetSize(width, 34)
  SetPanelBackdrop(button, COLORS.button, COLORS.borderSoft)

  button.text = button:CreateFontString(nil, "OVERLAY")
  button.text:SetPoint("CENTER")
  StyleFont(button.text, 15, COLORS.text, true)
  button.text:SetText(label)

  button:SetScript("OnEnter", function(self)
    self.mouseOver = true
    if self:IsEnabled() then
      SetPanelBackdrop(self, COLORS.buttonHover, COLORS.border)
    end
  end)

  button:SetScript("OnLeave", function(self)
    self.mouseOver = false
    if self:IsEnabled() then
      SetPanelBackdrop(self, COLORS.button, COLORS.borderSoft)
    end
  end)

  button:SetScript("OnMouseDown", function(self)
    if self:IsEnabled() then
      SetPanelBackdrop(self, COLORS.buttonPressed, COLORS.border)
      self.text:ClearAllPoints()
      self.text:SetPoint("CENTER", 0, -1)
    end
  end)

  button:SetScript("OnMouseUp", function(self)
    self.text:ClearAllPoints()
    self.text:SetPoint("CENTER", 0, 0)
    if self:IsEnabled() then
      SetPanelBackdrop(self, self.mouseOver and COLORS.buttonHover or COLORS.button, self.mouseOver and COLORS.border or COLORS.borderSoft)
    end
  end)

  button:SetScript("OnDisable", function(self)
    SetPanelBackdrop(self, COLORS.buttonDisabled, COLORS.borderSoft)
    self.text:ClearAllPoints()
    self.text:SetPoint("CENTER", 0, 0)
    self.text:SetAlpha(0.7)
  end)

  button:SetScript("OnEnable", function(self)
    SetPanelBackdrop(self, COLORS.button, COLORS.borderSoft)
    self.text:SetAlpha(1)
  end)

  return button
end

local function SetModernButtonEnabled(button, enabled)
  if button then
    button:SetEnabled(enabled)
  end
end

local function UpdateScrollBar()
  local frame = state.frame
  if not frame or not frame.scroll or not frame.scrollBar then
    return
  end

  local scrollHeight = frame.scroll:GetHeight()
  local contentHeight = state.content and state.content:GetHeight() or 1
  local maxScroll = math.max(0, contentHeight - scrollHeight)

  frame.scrollBar.updating = true
  frame.scrollBar:SetMinMaxValues(0, maxScroll)
  frame.scrollBar:SetValue(math.min(frame.scroll:GetVerticalScroll(), maxScroll))
  frame.scrollBar.updating = false

  if maxScroll <= 0 then
    frame.scroll:SetVerticalScroll(0)
    frame.scrollBar.thumb:SetHeight(frame.scrollBar:GetHeight())
    frame.scrollBar:SetAlpha(0.45)
    return
  end

  local thumbHeight = math.max(32, frame.scrollBar:GetHeight() * scrollHeight / contentHeight)
  frame.scrollBar.thumb:SetHeight(thumbHeight)
  frame.scrollBar:SetAlpha(1)
end

local function CreateCloseButton(parent)
  local button = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
  button:SetSize(28, 28)
  SetPanelBackdrop(button, COLORS.close, COLORS.borderSoft)

  button.icon = button:CreateTexture(nil, "ARTWORK")
  button.icon:SetPoint("CENTER")
  button.icon:SetSize(18, 18)
  button.icon:SetTexture(NOT_READY_TEXTURE)

  button:SetScript("OnEnter", function(self)
    self.mouseOver = true
    SetPanelBackdrop(self, COLORS.buttonHover, COLORS.border)
    self.icon:SetVertexColor(1, 1, 1, 1)
  end)

  button:SetScript("OnLeave", function(self)
    self.mouseOver = false
    SetPanelBackdrop(self, COLORS.close, COLORS.borderSoft)
    self.icon:SetVertexColor(1, 1, 1, 0.95)
  end)

  button:SetScript("OnMouseDown", function(self)
    SetPanelBackdrop(self, COLORS.buttonPressed, COLORS.border)
    self.icon:ClearAllPoints()
    self.icon:SetPoint("CENTER", 0, -1)
  end)

  button:SetScript("OnMouseUp", function(self)
    self.icon:ClearAllPoints()
    self.icon:SetPoint("CENTER", 0, 0)
    SetPanelBackdrop(self, self.mouseOver and COLORS.buttonHover or COLORS.close, self.mouseOver and COLORS.border or COLORS.borderSoft)
  end)

  return button
end

local function SetVersionCell(text, icon, version, currentVersion)
  local displayVersion = GetDisplayVersion(version)
  local isCurrent = IsVersionCurrentOrNewer(version, currentVersion)

  text:SetText(displayVersion)

  if (not version or version == "") and IsScanning() then
    SetFontColor(text, COLORS.muted)
    icon:Hide()
    return
  end

  if isCurrent then
    SetFontColor(text, COLORS.ok)
    icon:SetTexture(READY_TEXTURE)
    icon:Show()
  else
    SetFontColor(text, COLORS.error)
    icon:SetTexture(NOT_READY_TEXTURE)
    icon:Show()
  end
end

local function CreateRow(index)
  local row = {}
  local y = -((index - 1) * ROW_HEIGHT)

  row.frame = CreatePanel(state.content, nil, index % 2 == 0 and COLORS.rowAlt or COLORS.row, nil)
  row.frame:SetPoint("TOPLEFT", state.content, "TOPLEFT", 0, y)
  row.frame:SetSize(552, ROW_HEIGHT - 2)

  row.name = row.frame:CreateFontString(nil, "OVERLAY")
  row.name:SetPoint("LEFT", row.frame, "LEFT", 12, 0)
  row.name:SetWidth(210)
  row.name:SetHeight(ROW_HEIGHT)
  row.name:SetJustifyH("LEFT")
  StyleFont(row.name, 14, COLORS.text, false)

  row.addon = row.frame:CreateFontString(nil, "OVERLAY")
  row.addon:SetPoint("LEFT", row.frame, "LEFT", 250, 0)
  row.addon:SetWidth(82)
  row.addon:SetHeight(ROW_HEIGHT)
  row.addon:SetJustifyH("LEFT")
  StyleFont(row.addon, 14, COLORS.text, false)

  row.addonIcon = row.frame:CreateTexture(nil, "ARTWORK")
  row.addonIcon:SetPoint("LEFT", row.addon, "RIGHT", 4, 0)
  row.addonIcon:SetSize(16, 16)

  row.raidPack = row.frame:CreateFontString(nil, "OVERLAY")
  row.raidPack:SetPoint("LEFT", row.frame, "LEFT", 382, 0)
  row.raidPack:SetWidth(92)
  row.raidPack:SetHeight(ROW_HEIGHT)
  row.raidPack:SetJustifyH("LEFT")
  StyleFont(row.raidPack, 14, COLORS.text, false)

  row.raidPackIcon = row.frame:CreateTexture(nil, "ARTWORK")
  row.raidPackIcon:SetPoint("LEFT", row.raidPack, "RIGHT", 4, 0)
  row.raidPackIcon:SetSize(16, 16)

  return row
end

local function SetRowShown(row, shown)
  row.frame:SetShown(shown)
end

local function CreateVersionCheckFrame()
  if state.frame then
    return state.frame
  end

  local frameName = "MerfinPlusVersionCheckFrame"
  local frame = CreatePanel(UIParent, frameName, COLORS.bg, COLORS.border)
  state.frame = frame
  RegisterEscClose(frameName)
  frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()

  frame.header = CreatePanel(frame, nil, COLORS.header, nil)
  frame.header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
  frame.header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
  frame.header:SetHeight(HEADER_HEIGHT)

  frame.headerLine = frame:CreateTexture(nil, "ARTWORK")
  frame.headerLine:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, 0)
  frame.headerLine:SetPoint("TOPRIGHT", frame.header, "BOTTOMRIGHT", 0, 0)
  frame.headerLine:SetHeight(2)
  SetTextureColor(frame.headerLine, COLORS.border)

  frame.logoBadge = CreateFrame("Frame", nil, frame.header)
  frame.logoBadge:SetPoint("LEFT", frame.header, "LEFT", 14, 0)
  frame.logoBadge:SetSize(58, 58)
  frame.logoBadge:EnableMouse(true)

  frame.logoBackplate = frame.logoBadge:CreateTexture(nil, "ARTWORK", nil, 1)
  frame.logoBackplate:SetTexture(LOGO_BACKPLATE_TEXTURE)
  frame.logoBackplate:SetAllPoints(frame.logoBadge)

  frame.logo = frame.logoBadge:CreateTexture(nil, "OVERLAY", nil, 3)
  frame.logo:SetTexture(LOGO_TEXTURE)
  frame.logo:SetPoint("CENTER", frame.logoBadge, "CENTER", 0, -1)
  frame.logo:SetSize(53, 53)
  frame.logo:SetTexCoord(0, 1, 0, 1)

  frame.logoFrame = frame.logoBadge:CreateTexture(nil, "OVERLAY", nil, 4)
  frame.logoFrame:SetTexture(LOGO_FRAME_TEXTURE)
  frame.logoFrame:SetAllPoints(frame.logoBadge)

  frame.logoSpinOnce = frame.logo:CreateAnimationGroup()
  local logoSpinOnce = frame.logoSpinOnce:CreateAnimation("Rotation")
  logoSpinOnce:SetDegrees(-360)
  logoSpinOnce:SetDuration(0.6)
  logoSpinOnce:SetSmoothing("OUT")

  frame.logoHoverSpin = frame.logo:CreateAnimationGroup()
  frame.logoHoverSpin:SetLooping("REPEAT")
  local logoHoverSpin = frame.logoHoverSpin:CreateAnimation("Rotation")
  logoHoverSpin:SetDegrees(-360)
  logoHoverSpin:SetDuration(0.8)
  logoHoverSpin:SetSmoothing("NONE")
  frame.logoBadge:SetScript("OnEnter", function()
    if frame.logoSpinOnce:IsPlaying() then
      frame.logoSpinOnce:Stop()
    end
    if not frame.logoHoverSpin:IsPlaying() then
      frame.logoHoverSpin:Play()
    end
  end)
  frame.logoBadge:SetScript("OnLeave", function()
    if frame.logoHoverSpin:IsPlaying() then
      frame.logoHoverSpin:Stop()
    end
    if frame.logo.SetRotation then
      frame.logo:SetRotation(0)
    end
  end)

  frame.title = frame.header:CreateFontString(nil, "OVERLAY")
  frame.title:SetPoint("LEFT", frame.logoBadge, "RIGHT", 12, 0)
  frame.title:SetPoint("RIGHT", frame.header, "RIGHT", -62, 0)
  frame.title:SetJustifyH("LEFT")
  StyleFont(frame.title, 22, COLORS.text, true)
  frame.title:SetText(L["MerfinPlus Version Check"])

  frame.closeX = CreateCloseButton(frame.header)
  frame.closeX:SetPoint("RIGHT", frame.header, "RIGHT", -16, 0)
  frame.closeX:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame.body = CreatePanel(frame, nil, COLORS.panel, COLORS.borderSoft)
  frame.body:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -88)
  frame.body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 66)

  frame.headerName = frame.body:CreateFontString(nil, "OVERLAY")
  frame.headerName:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 12, -13)
  frame.headerName:SetWidth(210)
  frame.headerName:SetJustifyH("LEFT")
  StyleFont(frame.headerName, 14, COLORS.muted, true)
  frame.headerName:SetText(L["Player"])

  frame.headerAddon = frame.body:CreateFontString(nil, "OVERLAY")
  frame.headerAddon:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 250, -13)
  frame.headerAddon:SetWidth(110)
  frame.headerAddon:SetJustifyH("LEFT")
  StyleFont(frame.headerAddon, 14, COLORS.muted, true)
  frame.headerAddon:SetText("MerfinPlus")

  frame.headerRaidPack = frame.body:CreateFontString(nil, "OVERLAY")
  frame.headerRaidPack:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 382, -13)
  frame.headerRaidPack:SetWidth(140)
  frame.headerRaidPack:SetJustifyH("LEFT")
  StyleFont(frame.headerRaidPack, 14, COLORS.muted, true)
  frame.headerRaidPack:SetText(L["T5 Raidpack"])

  frame.divider = frame.body:CreateTexture(nil, "ARTWORK")
  frame.divider:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 12, -37)
  frame.divider:SetPoint("TOPRIGHT", frame.body, "TOPRIGHT", -22, -37)
  frame.divider:SetHeight(1)
  SetTextureColor(frame.divider, COLORS.borderSoft)

  frame.scroll = CreateFrame("ScrollFrame", nil, frame.body)
  frame.scroll:SetPoint("TOPLEFT", frame.body, "TOPLEFT", 12, -46)
  frame.scroll:SetPoint("BOTTOMRIGHT", frame.body, "BOTTOMRIGHT", -24, 12)
  frame.scroll:EnableMouseWheel(true)
  frame.scroll:SetScript("OnMouseWheel", function(self, delta)
    local maxScroll = math.max(0, (state.content and state.content:GetHeight() or 0) - self:GetHeight())
    local nextScroll = self:GetVerticalScroll() - delta * ROW_HEIGHT * 3
    self:SetVerticalScroll(math.max(0, math.min(maxScroll, nextScroll)))
    UpdateScrollBar()
  end)

  state.content = CreateFrame("Frame", nil, frame.scroll)
  state.content:SetSize(552, 1)
  state.content:SetPoint("TOPLEFT", frame.scroll, "TOPLEFT", 0, 0)
  frame.scroll:SetScrollChild(state.content)

  frame.scrollBar = CreateFrame("Slider", nil, frame.body, BackdropTemplateMixin and "BackdropTemplate")
  frame.scrollBar:SetPoint("TOPRIGHT", frame.body, "TOPRIGHT", -9, -46)
  frame.scrollBar:SetPoint("BOTTOMRIGHT", frame.body, "BOTTOMRIGHT", -9, 12)
  frame.scrollBar:SetWidth(9)
  frame.scrollBar:SetOrientation("VERTICAL")
  frame.scrollBar:SetMinMaxValues(0, 0)
  frame.scrollBar:SetValue(0)
  frame.scrollBar:SetValueStep(ROW_HEIGHT)
  if frame.scrollBar.SetObeyStepOnDrag then
    frame.scrollBar:SetObeyStepOnDrag(false)
  end
  SetPanelBackdrop(frame.scrollBar, COLORS.input, COLORS.borderSoft)

  frame.scrollBar:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
  frame.scrollBar.thumb = frame.scrollBar:GetThumbTexture()
  frame.scrollBar.thumb:SetSize(9, 40)
  SetTextureColor(frame.scrollBar.thumb, COLORS.border)
  frame.scrollBar:SetScript("OnValueChanged", function(self, value)
    if self.updating then
      return
    end

    frame.scroll:SetVerticalScroll(value)
    UpdateScrollBar()
  end)

  frame.refresh = CreateModernButton(frame, L["Refresh"], 112)
  frame.refresh:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 18)
  frame.refresh:SetScript("OnClick", function()
    MerfinPlus:OpenVersionCheck()
  end)

  frame.closeFooter = CreateModernButton(frame, L["Close"], 100)
  frame.closeFooter:SetPoint("LEFT", frame.refresh, "RIGHT", 10, 0)
  frame.closeFooter:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame.spinner = frame:CreateTexture(nil, "ARTWORK")
  frame.spinner:SetTexture(SPINNER_TEXTURE)
  frame.spinner:SetPoint("LEFT", frame.closeFooter, "RIGHT", 12, 0)
  frame.spinner:SetSize(22, 22)
  frame.spinner:SetBlendMode("ADD")
  frame.spinner:SetVertexColor(COLORS.border[1], COLORS.border[2], COLORS.border[3], 0.95)
  frame.spinner:Hide()

  frame.status = frame:CreateFontString(nil, "OVERLAY")
  frame.status:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 27)
  frame.status:SetJustifyH("RIGHT")
  StyleFont(frame.status, 13, COLORS.muted, false)
  frame.status:SetText("")

  frame:SetScript("OnUpdate", function(self, elapsed)
    if self.spinner and self.spinner:IsShown() and self.spinner.SetRotation then
      self.spinnerAngle = (self.spinnerAngle or 0) + elapsed * 4.5
      self.spinner:SetRotation(self.spinnerAngle)
    end
  end)
  frame:SetScript("OnShow", function()
    if frame.logoHoverSpin:IsPlaying() then
      frame.logoHoverSpin:Stop()
    end
    if frame.logo.SetRotation then
      frame.logo:SetRotation(0)
    end
    if not frame.logoSpinOnce:IsPlaying() then
      frame.logoSpinOnce:Play()
    end
  end)
  frame:SetScript("OnHide", function()
    if frame.logoSpinOnce:IsPlaying() then
      frame.logoSpinOnce:Stop()
    end
    if frame.logoHoverSpin:IsPlaying() then
      frame.logoHoverSpin:Stop()
    end
    if frame.logo.SetRotation then
      frame.logo:SetRotation(0)
    end
  end)

  return frame
end

function MerfinPlus:RefreshVersionCheckLocale()
  local frame = state.frame
  if not frame then
    return
  end
  frame.title:SetText(self:T("MerfinPlus Version Check"))
  frame.headerName:SetText(self:T("Player"))
  frame.headerRaidPack:SetText(self:T("T5 Raidpack"))
  if frame.refresh and frame.refresh.text then
    frame.refresh.text:SetText(self:T("Refresh"))
  end
  if frame.closeFooter and frame.closeFooter.text then
    frame.closeFooter.text:SetText(self:T("Close"))
  end
  if frame:IsShown() then
    frame.status:SetText(IsScanning() and self:T("Scanning group...") or self:T("Done"))
  end
  self:ApplyLocalizedFontsToFrame(frame)
end

local function RefreshFrame()
  if not state.frame or not state.frame:IsShown() then
    return
  end

  StoreLocalVersions()
  BuildRoster()

  local currentAddonVersion = GetAddonVersion()
  local currentRaidPackVersion = GetLocalRaidPackVersion()

  for index, entry in ipairs(state.roster) do
    local row = state.rows[index]
    if not row then
      row = CreateRow(index)
      state.rows[index] = row
    end

    SetRowShown(row, true)
    row.name:SetText(GetColoredName(entry))
    SetVersionCell(row.addon, row.addonIcon, LookupAddonVersion(entry), currentAddonVersion)
    SetVersionCell(
      row.raidPack,
      row.raidPackIcon,
      LookupCachedVersion(state.raidPackVersions, entry),
      currentRaidPackVersion
    )
  end

  for index = #state.roster + 1, #state.rows do
    SetRowShown(state.rows[index], false)
  end

  state.content:SetHeight(math.max(1, #state.roster * ROW_HEIGHT))
  UpdateScrollBar()
  state.frame.spinner:SetShown(IsScanning())
  SetModernButtonEnabled(state.frame.refresh, not IsScanning())
  state.frame.status:SetText(IsScanning() and L["Scanning group..."] or L["Done"])
end

local function ScheduleRefresh(delay)
  if C_Timer and C_Timer.After then
    C_Timer.After(delay, RefreshFrame)
  end
end

local function RequestVersions()
  local channel = GetGroupChannel()
  if channel then
    SendAddonMessageSafe(PREFIX, "REQ:" .. PACK_KEY, channel)

    local lib = LibStub and LibStub("LibVersionCheck-1.0", true)
    if lib and lib.RequestVersion then
      lib:RequestVersion(channel, ADDON_NAME)
    end
  end

  BuildRoster()
  for _, entry in ipairs(state.roster) do
    if entry.fullName and not IsSelf(entry.fullName) then
      SendAddonMessageSafe(PREFIX, "REQ:" .. PACK_KEY, "WHISPER", entry.fullName)
    end
  end
end

local function ScheduleRequest(delay)
  if C_Timer and C_Timer.After then
    C_Timer.After(delay, RequestVersions)
  end
end

local function HandleAddonMessage(prefix, message, channel, sender)
  if prefix ~= PREFIX or type(message) ~= "string" then
    return
  end

  local command, pack, version = strsplit(":", message)
  if command == "REQ" and pack == PACK_KEY then
    if not IsSelf(sender) then
      SendOwnVersions(sender)
    end
    return
  end

  if command == "MP" then
    StoreVersion(state.addonVersions, sender, pack)
    RefreshFrame()
    return
  end

  if command == "WA" and pack == PACK_KEY then
    StoreVersion(state.raidPackVersions, sender, version)
    RefreshFrame()
  end
end

function MerfinPlus:VersionCheckEnable()
  if state.enabled then
    return
  end

  state.enabled = true
  RegisterPrefix()
  StoreLocalVersions()

  state.eventFrame = CreateFrame("Frame")
  state.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
  state.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
  state.eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "CHAT_MSG_ADDON" then
      HandleAddonMessage(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
      RefreshFrame()
    end
  end)

  local lib = LibStub and LibStub("LibVersionCheck-1.0", true)
  if lib and lib.RegisterOnVersionChangedCallback then
    lib:RegisterOnVersionChangedCallback(function(playerName, addonName, version)
      if addonName == ADDON_NAME then
        StoreVersion(state.addonVersions, playerName, version)
        RefreshFrame()
      end
    end, ADDON_NAME)
  end
end

function MerfinPlus:OpenVersionCheck()
  self:VersionCheckEnable()
  wipe(state.addonVersions)
  wipe(state.raidPackVersions)

  local lib = LibStub and LibStub("LibVersionCheck-1.0", true)
  if lib and lib.ResetAddonVersionCache then
    lib:ResetAddonVersionCache(ADDON_NAME)
  end

  StoreLocalVersions()

  state.scanningUntil = GetTime() + SCAN_SECONDS

  local frame = CreateVersionCheckFrame()
  frame:Show()
  RefreshFrame()
  RequestVersions()

  ScheduleRequest(0.5)
  ScheduleRequest(1.5)
  ScheduleRefresh(0.5)
  ScheduleRefresh(1.5)
  ScheduleRefresh(SCAN_SECONDS + 0.1)
end

SLASH_MERFINPLUSVERSIONCHECK1 = "/merfinvc"
SLASH_MERFINPLUSVERSIONCHECK2 = "/mpvc"
SlashCmdList["MERFINPLUSVERSIONCHECK"] = function()
  MerfinPlus:OpenVersionCheck()
end
