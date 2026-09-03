local BRIDGE = {}

local B64 = {}
local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
for index = 1, #ALPHABET do
  B64[ALPHABET:sub(index, index)] = index - 1
end

local GOLD = { 0.95, 0.72, 0.09, 1 }
local GOLD_SOFT = { 0.72, 0.55, 0.12, 1 }
local PANEL = { 0.035, 0.032, 0.024, 0.96 }
local PANEL_ROW = { 0.075, 0.065, 0.04, 0.94 }
local GREEN = { 0.10, 0.70, 0.38, 1 }
local RED = { 0.88, 0.22, 0.20, 1 }
local TEXT = { 1.00, 0.96, 0.84, 1 }
local MUTED = { 0.76, 0.70, 0.58, 1 }
local BUTTON_BG = { 0.19, 0.15, 0.05, 0.98 }
local BUTTON_HOVER = { 0.32, 0.25, 0.08, 0.98 }
local LOGO_TEXTURE = "Interface\\AddOns\\MerfinPlus\\Media\\icons\\merfin-gchroma-256.png"
local MERFIN_FONT_1_FALLBACK = "Interface\\AddOns\\MerfinPlus\\Media\\font\\SFUIDisplayCondensed-Semibold.otf"
local SIGNATURE_FONT_FALLBACK = "Interface\\AddOns\\MerfinPlus\\Media\\font\\Caveat-SemiBold.ttf"

local function resolveMerfinFont()
  local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
  if lsm and lsm.Fetch then
    local font = lsm:Fetch("font", "Merfin Font 1", true)
    if font then
      return font
    end

    local ace = LibStub and LibStub("AceAddon-3.0", true)
    local addon = ace and ace.GetAddon and ace:GetAddon("MerfinPlus", true)
    local defaultFont = addon and addon.GetDefaultFont and addon.GetDefaultFont()
    if defaultFont then
      font = lsm:Fetch("font", defaultFont, true)
      if font then
        return font
      end
    end
  end

  return MERFIN_FONT_1_FALLBACK
end

local function resolveSignatureFont()
  local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
  if lsm and lsm.Fetch then
    local font = lsm:Fetch("font", "Caveat SemiBold", true)
    if font then
      return font
    end
  end

  return SIGNATURE_FONT_FALLBACK
end

local TRANSLATIONS = {
  en = {
    ready = "Ready",
    opened = "Opened in WeakAuras",
    update = "Update",
    install = "Install",
    openAgain = "Open Again",
    reloadUi = "Reload UI",
    readMe = "Read Me!",
    readMeTitle = "Read Me",
    readMeClose = "Close",
    readMeText = "1) Update all shown WeakAuras, if you want to. Simply press \"Update\".\n\n2) If you already opened or updated a WeakAura, the button will show \"Open Again\" if you missed something and want to update again.\n\n3) After all updates are done, click the Reload UI button for the initial /reload. Then go back to the Companion and press \"Sync again\". If all updates are done, the Companion should show you an empty list.",
    countOne = "1 update",
    countMany = "{count} updates",
    missingPayload = "This update payload is missing.",
    leaveCombat = "Leave combat before opening WeakAuras updates.",
    importUnavailable = "WeakAuras.Import is not available. Open /wa once and try again.",
    updatesAfterCombat = "WeakAura updates are ready. The popup will open after combat.",
    noUpdates = "No prepared WeakAura updates for this WoW account.",
  },
  de = {
    ready = "Bereit",
    opened = "In WeakAuras geoeffnet",
    update = "Update",
    install = "Installieren",
    openAgain = "Erneut oeffnen",
    reloadUi = "Reload UI",
    readMe = "Read Me!",
    readMeTitle = "Read Me",
    readMeClose = "Schliessen",
    readMeText = "1) Aktualisiere alle angezeigten WeakAuras, wenn du moechtest. Druecke einfach \"Update\".\n\n2) Wenn du eine WeakAura bereits geoeffnet oder aktualisiert hast, zeigt der Button \"Erneut oeffnen\", falls du etwas verpasst hast und nochmal aktualisieren moechtest.\n\n3) Wenn alle Updates erledigt sind, klicke den Reload UI Button fuer den ersten /reload. Gehe danach zurueck in den Companion und druecke \"Sync again\". Wenn alle Updates erledigt sind, sollte der Companion eine leere Liste anzeigen.",
    countOne = "1 Update",
    countMany = "{count} Updates",
    missingPayload = "Dieses Update-Paket fehlt.",
    leaveCombat = "Verlasse den Kampf, bevor du WeakAura-Updates oeffnest.",
    importUnavailable = "WeakAuras.Import ist nicht verfuegbar. Oeffne einmal /wa und versuche es erneut.",
    updatesAfterCombat = "WeakAura-Updates sind bereit. Das Fenster oeffnet sich nach dem Kampf.",
    noUpdates = "Keine vorbereiteten WeakAura-Updates fuer diesen WoW-Account.",
  },
  fr = {
    ready = "Pret",
    opened = "Ouvert dans WeakAuras",
    update = "Mettre a jour",
    install = "Installer",
    openAgain = "Rouvrir",
    reloadUi = "Reload UI",
    readMe = "Read Me!",
    readMeTitle = "Read Me",
    readMeClose = "Fermer",
    readMeText = "1) Mets a jour toutes les WeakAuras affichees si tu le souhaites. Appuie simplement sur \"Mettre a jour\".\n\n2) Si tu as deja ouvert ou mis a jour une WeakAura, le bouton affichera \"Rouvrir\" si tu as manque quelque chose et veux recommencer.\n\n3) Une fois toutes les mises a jour terminees, clique sur Reload UI pour le premier /reload. Retourne ensuite dans le Companion et appuie sur \"Sync again\". Si tout est termine, le Companion devrait afficher une liste vide.",
    countOne = "1 mise a jour",
    countMany = "{count} mises a jour",
    missingPayload = "Le paquet de mise a jour est manquant.",
    leaveCombat = "Quitte le combat avant d'ouvrir les mises a jour WeakAuras.",
    importUnavailable = "WeakAuras.Import n'est pas disponible. Ouvre /wa une fois puis reessaie.",
    updatesAfterCombat = "Les mises a jour WeakAura sont pretes. La fenetre s'ouvrira apres le combat.",
    noUpdates = "Aucune mise a jour WeakAura preparee pour ce compte WoW.",
  },
  es = {
    ready = "Listo",
    opened = "Abierto en WeakAuras",
    update = "Actualizar",
    install = "Instalar",
    openAgain = "Abrir otra vez",
    reloadUi = "Reload UI",
    readMe = "Read Me!",
    readMeTitle = "Read Me",
    readMeClose = "Cerrar",
    readMeText = "1) Actualiza todas las WeakAuras mostradas si quieres. Simplemente pulsa \"Actualizar\".\n\n2) Si ya abriste o actualizaste una WeakAura, el boton mostrara \"Abrir otra vez\" por si te falto algo y quieres actualizar de nuevo.\n\n3) Cuando termines todos los updates, pulsa Reload UI para el /reload inicial. Luego vuelve al Companion y pulsa \"Sync again\". Si todo esta terminado, el Companion deberia mostrar una lista vacia.",
    countOne = "1 actualizacion",
    countMany = "{count} actualizaciones",
    missingPayload = "Falta el paquete de actualizacion.",
    leaveCombat = "Sal de combate antes de abrir actualizaciones de WeakAuras.",
    importUnavailable = "WeakAuras.Import no esta disponible. Abre /wa una vez e intentalo de nuevo.",
    updatesAfterCombat = "Las actualizaciones de WeakAura estan listas. La ventana se abrira despues del combate.",
    noUpdates = "No hay actualizaciones WeakAura preparadas para esta cuenta de WoW.",
  },
  pt = {
    ready = "Pronto",
    opened = "Aberto no WeakAuras",
    update = "Atualizar",
    install = "Instalar",
    openAgain = "Abrir novamente",
    reloadUi = "Reload UI",
    readMe = "Read Me!",
    readMeTitle = "Read Me",
    readMeClose = "Fechar",
    readMeText = "1) Atualize todas as WeakAuras mostradas se quiser. Basta clicar em \"Atualizar\".\n\n2) Se voce ja abriu ou atualizou uma WeakAura, o botao mostrara \"Abrir novamente\" caso tenha perdido algo e queira atualizar de novo.\n\n3) Depois que todos os updates estiverem prontos, clique em Reload UI para o /reload inicial. Depois volte ao Companion e clique em \"Sync again\". Se tudo estiver terminado, o Companion deve mostrar uma lista vazia.",
    countOne = "1 atualizacao",
    countMany = "{count} atualizacoes",
    missingPayload = "O pacote de atualizacao esta faltando.",
    leaveCombat = "Saia do combate antes de abrir atualizacoes do WeakAuras.",
    importUnavailable = "WeakAuras.Import nao esta disponivel. Abra /wa uma vez e tente novamente.",
    updatesAfterCombat = "As atualizacoes WeakAura estao prontas. A janela abrira depois do combate.",
    noUpdates = "Nenhuma atualizacao WeakAura preparada para esta conta WoW.",
  },
  ru = {
    ready = "Готово",
    opened = "Открыто в WeakAuras",
    update = "Обновить",
    install = "Установить",
    openAgain = "Открыть снова",
    reloadUi = "Reload UI",
    readMe = "Read Me!",
    readMeTitle = "Read Me",
    readMeClose = "Закрыть",
    readMeText = "1) Обнови все показанные WeakAura, если хочешь. Просто нажми \"Обновить\".\n\n2) Если WeakAura уже была открыта или обновлена, кнопка покажет \"Открыть снова\", чтобы ты мог повторить обновление, если что-то пропустил.\n\n3) Когда все обновления готовы, нажми Reload UI для первого /reload. Затем вернись в Companion и нажми \"Sync again\". Если все обновления завершены, Companion должен показать пустой список.",
    countOne = "1 обновление",
    countMany = "{count} обновлений",
    missingPayload = "Пакет обновления отсутствует.",
    leaveCombat = "Выйди из боя перед открытием обновлений WeakAuras.",
    importUnavailable = "WeakAuras.Import недоступен. Открой /wa один раз и попробуй снова.",
    updatesAfterCombat = "Обновления WeakAura готовы. Окно откроется после боя.",
    noUpdates = "Нет подготовленных обновлений WeakAura для этого аккаунта WoW.",
  },
  zh = {
    ready = "就绪",
    opened = "已在 WeakAuras 中打开",
    update = "更新",
    install = "安装",
    openAgain = "再次打开",
    reloadUi = "Reload UI",
    readMe = "Read Me!",
    readMeTitle = "Read Me",
    readMeClose = "关闭",
    readMeText = "1) 如果你想更新，先更新所有显示的 WeakAura。只需要点击“更新”。\n\n2) 如果你已经打开或更新过某个 WeakAura，按钮会显示“再次打开”，方便你遗漏内容时重新更新。\n\n3) 所有更新完成后，点击 Reload UI 按钮进行第一次 /reload。然后回到 Companion，点击“Sync again”。如果所有更新都完成，Companion 应该显示空列表。",
    countOne = "1 个更新",
    countMany = "{count} 个更新",
    missingPayload = "缺少更新数据。",
    leaveCombat = "请先脱离战斗，再打开 WeakAuras 更新。",
    importUnavailable = "WeakAuras.Import 不可用。请先打开一次 /wa 后重试。",
    updatesAfterCombat = "WeakAura 更新已准备好，战斗结束后会打开窗口。",
    noUpdates = "这个 WoW 账号没有已准备好的 WeakAura 更新。",
  },
}

local function floor(value)
  return value - (value % 1)
end

local bitXor = (bit and bit.bxor) or (bit32 and bit32.bxor)
local function bxor(left, right)
  if bitXor then
    return bitXor(left, right)
  end

  local result = 0
  local value = 1
  left = left or 0
  right = right or 0

  while left > 0 or right > 0 do
    local leftBit = left % 2
    local rightBit = right % 2
    if leftBit ~= rightBit then
      result = result + value
    end
    left = floor(left / 2)
    right = floor(right / 2)
    value = value * 2
  end

  return result
end

local function decode(payload, seed)
  if type(payload) ~= "string" or not string or not string.char then
    return ""
  end

  payload = payload:gsub("[^A-Za-z0-9+/=]", "")
  seed = tonumber(seed or 0) or 0

  local output = {}
  local state = seed
  local position = 0

  local function push(byte)
    state = (state * 73 + 41 + position) % 256
    local mask = bxor(state, (seed + position * 17) % 256)
    output[#output + 1] = string.char(bxor(byte, mask))
    position = position + 1
  end

  for index = 1, #payload, 4 do
    local one = payload:sub(index, index)
    local two = payload:sub(index + 1, index + 1)
    local three = payload:sub(index + 2, index + 2)
    local four = payload:sub(index + 3, index + 3)
    local first = B64[one]
    local second = B64[two]

    if first == nil or second == nil then
      break
    end

    local third = three ~= "=" and (B64[three] or 0) or 0
    local fourth = four ~= "=" and (B64[four] or 0) or 0
    local packed = first * 262144 + second * 4096 + third * 64 + fourth

    push(floor(packed / 65536) % 256)
    if three ~= "=" and three ~= "" then
      push(floor(packed / 256) % 256)
    end
    if four ~= "=" and four ~= "" then
      push(packed % 256)
    end
  end

  return table.concat(output)
end

local function colorText(text, color)
  local r = floor((color[1] or 1) * 255)
  local g = floor((color[2] or 1) * 255)
  local b = floor((color[3] or 1) * 255)
  return string.format("|cff%02x%02x%02x%s|r", r, g, b, text or "")
end

local function printBridge(message, color)
  DEFAULT_CHAT_FRAME:AddMessage(colorText("MerfinPlus WA Updates: ", GOLD) .. colorText(message, color or TEXT))
end

local function activeRoot()
  local root = MerfinPlusCompanionSession
  if type(root) ~= "table" or root.active ~= true then
    return nil
  end

  local expiresAt = tonumber(root.expiresAt or 0) or 0
  if expiresAt > 0 and time and time() > expiresAt then
    return nil
  end

  if root.mode and root.mode ~= "manual-import" then
    return nil
  end

  return root
end

local function normalizeLanguage(value)
  if type(value) ~= "string" then
    return nil
  end

  value = value:lower()
  if value == "de" or value == "dede" then
    return "de"
  end
  if value == "fr" or value == "frfr" then
    return "fr"
  end
  if value == "es" or value == "eses" or value == "esmx" then
    return "es"
  end
  if value == "pt" or value == "ptbr" then
    return "pt"
  end
  if value == "ru" or value == "ruru" then
    return "ru"
  end
  if value == "zh" or value == "zhcn" or value == "zhtw" then
    return "zh"
  end
  return "en"
end

local function currentLanguage()
  local root = activeRoot()
  local language = root and normalizeLanguage(root.language or root.companionLanguage or root.locale)
  if language then
    return language
  end
  return normalizeLanguage(GetLocale and GetLocale() or "enUS") or "en"
end

local function T(key, values)
  local language = currentLanguage()
  local bundle = TRANSLATIONS[language] or TRANSLATIONS.en
  local text = bundle[key] or TRANSLATIONS.en[key] or key
  if type(values) == "table" then
    text = text:gsub("{([%w_]+)}", function(name)
      local value = values[name]
      return value ~= nil and tostring(value) or ""
    end)
  end
  return text
end

local function bridgeSlugFromUrl(url)
  if type(url) ~= "string" then
    return ""
  end

  return url:match("downloads%.merfin%.uk/app/auras/([^/%?#]+)")
    or url:match("merfin%.uk/app/auras/([^/%?#]+)")
    or url:match("wago%.io/([^/%?#]+)")
    or ""
end

local function bridgeVersionFromUrl(url)
  if type(url) ~= "string" then
    return 0
  end

  local version = url:match("downloads%.merfin%.uk/app/auras/[^/%?#]+/([0-9]+)")
    or url:match("merfin%.uk/app/auras/[^/%?#]+/([0-9]+)")
    or url:match("wago%.io/[^/%?#]+/([0-9]+)")
  return tonumber(version or "0") or 0
end

local function currentSlug(aura)
  if type(aura) ~= "table" then
    return ""
  end

  if type(aura.merfinSlug) == "string" and aura.merfinSlug ~= "" then
    return aura.merfinSlug
  end

  return bridgeSlugFromUrl(aura.url)
end

local function merfinMetadataFromDescription(description)
  if type(description) ~= "string" then
    return "", 0
  end

  local uid = description:match("[Mm]erfinUID%s*:%s*(MUIX%d+)") or ""
  local revision = tonumber(description:match("[Mm]erfinRev%s*:%s*(%d+)") or "0") or 0
  return uid, revision
end

local function currentMerfinUid(aura)
  if type(aura) ~= "table" then
    return ""
  end

  if type(aura.merfinUid) == "string" and aura.merfinUid ~= "" then
    return aura.merfinUid
  end

  local uid = merfinMetadataFromDescription(aura.desc)
  return uid
end

local function currentMerfinRevision(aura)
  if type(aura) ~= "table" then
    return 0
  end

  local _, descRevision = merfinMetadataFromDescription(aura.desc)
  local revision = tonumber(aura.merfinRevision or aura.merfinVersion or 0) or 0
  if descRevision > revision then
    revision = descRevision
  end
  return revision
end

local function entryMerfinUid(entry)
  if type(entry) ~= "table" or type(entry.merfinUid) ~= "string" then
    return ""
  end

  return entry.merfinUid:match("^(MUIX%d+)$") or ""
end

local function installedVersionForAura(aura)
  if type(aura) ~= "table" then
    return 0
  end

  local version = tonumber(aura.merfinRevision or aura.merfinVersion or 0) or 0
  local urlVersion = bridgeVersionFromUrl(aura.url)
  if urlVersion > version then
    version = urlVersion
  end

  local displayVersion = tonumber(aura.version or 0) or 0
  if displayVersion > version and currentSlug(aura) ~= "" then
    version = displayVersion
  end

  return version
end

local function targetVersionForEntry(entry)
  if type(entry) ~= "table" then
    return 0
  end

  return tonumber(entry.revision or entry.merfinRevision or entry.version or 0) or 0
end

local function companionSource()
  local root = activeRoot()
  local weakAuras = root and root.WeakAuras
  if type(weakAuras) ~= "table" or type(weakAuras.slugs) ~= "table" then
    return nil, nil
  end

  return root, weakAuras.slugs
end

local function installedVersionsBySlug()
  local versions = {}
  local saved = WeakAurasSaved
  local displays = saved and saved.displays
  if type(displays) ~= "table" then
    return versions
  end

  for _, aura in pairs(displays) do
    if type(aura) == "table" and not aura.parent then
      local slug = currentSlug(aura)
      if slug ~= "" then
        local version = installedVersionForAura(aura)
        if version > (versions[slug] or 0) then
          versions[slug] = version
        end
      end
    end
  end

  return versions
end

local function installedVersionsByMerfinUid()
  local versions = {}
  local saved = WeakAurasSaved
  local displays = saved and saved.displays
  if type(displays) ~= "table" then
    return versions
  end

  for _, aura in pairs(displays) do
    if type(aura) == "table" then
      local uid = currentMerfinUid(aura)
      if uid ~= "" then
        local version = currentMerfinRevision(aura)
        if version <= 0 then
          version = installedVersionForAura(aura)
        end
        if version > (versions[uid] or 0) then
          versions[uid] = version
        end
      end
    end
  end

  return versions
end

local function decodeAuraEntry(slug, entry)
  if type(entry) ~= "table" then
    return nil
  end

  local encoded = decode(entry.encodedPayload or entry.payload, entry.encodedSeed or entry.seed)
  if encoded == "" or not encoded:find("^!WA:") then
    return nil
  end

  local revision = targetVersionForEntry(entry)
  return {
    slug = entry.slug or slug,
    name = entry.name or slug,
    encoded = encoded,
    revision = revision > 0 and revision or 1,
    merfinUid = entry.merfinUid or "",
    merfinRevision = tonumber(entry.merfinRevision or entry.revision or revision or 1) or 1,
    semver = entry.semver or tostring(revision),
    source = entry.expansionLabel or entry.source or "MerfinUI Companion",
    expansion = entry.expansion or "",
    expansionLabel = entry.expansionLabel or entry.source or "",
    category = entry.category or "",
    accounts = type(entry.accounts) == "table" and entry.accounts or nil,
    syncKind = entry.syncKind or "download",
  }
end

local migrationStopWords = {
  merfin = true, merfinui = true, mists = true, mop = true, tbc = true, classic = true,
  weakaura = true, weakauras = true, aura = true, auras = true,
  general = true, classpack = true, classpacks = true, anchor = true, anchors = true,
  string = true, strings = true, raid = true, dungeon = true, additional = true, additionals = true,
  public = true, version = true, full = true, display = true, qhd = true, fhd = true, hd = true,
  ui = true, ["and"] = true, the = true,
}

local function normalizeTokens(value)
  if type(value) ~= "string" then
    return {}
  end

  local tokens = {}
  value = value:lower():gsub("%b[]", " ")
  for token in value:gmatch("[a-z0-9]+") do
    local isRandomToken = token:match("%d") and #token >= 6
    if #token >= 3 and not migrationStopWords[token] and not token:match("^%d+$") and not token:match("^[tv]%d+$") and not isRandomToken then
      tokens[#tokens + 1] = token
    end
  end
  return tokens
end

local function tokenListsOverlap(left, right)
  for _, leftToken in ipairs(left) do
    for _, rightToken in ipairs(right) do
      if leftToken == rightToken then
        return true
      end
      if #leftToken > 3 and rightToken:find(leftToken, 1, true) then
        return true
      end
      if #rightToken > 3 and leftToken:find(rightToken, 1, true) then
        return true
      end
    end
  end
  return false
end

local function slugLooksLikeDisplay(slug, displayId)
  if type(displayId) ~= "string" or displayId == "" then
    return true
  end

  local slugTokens = normalizeTokens(slug)
  local displayTokens = normalizeTokens(displayId)
  if #slugTokens == 0 or #displayTokens == 0 then
    return true
  end

  return tokenListsOverlap(slugTokens, displayTokens)
end

local function findMigrationAura(displays, migration)
  local displayId = migration and migration.displayId
  if displayId and type(displays[displayId]) == "table" then
    return displayId, displays[displayId]
  end

  local uid = migration and migration.uid
  if type(uid) == "string" and uid ~= "" then
    for id, aura in pairs(displays) do
      if type(aura) == "table" and aura.uid == uid and not aura.parent then
        return id, aura
      end
    end
  end

  return displayId, nil
end

local function canApplyMigration(root, aura, migration, displayId)
  if type(root) ~= "table" or type(aura) ~= "table" or type(migration) ~= "table" then
    return false
  end
  if type(migration.slug) ~= "string" or migration.slug == "" then
    return false
  end
  local _, slugs = companionSource()
  local entry = slugs and slugs[migration.slug]
  local latestVersion = targetVersionForEntry(entry)
  if latestVersion <= 0 then
    return false
  end

  if (tonumber(migration.installedVersion or 0) or 0) <= 0 then
    return true
  end

  if not slugLooksLikeDisplay(migration.slug, displayId) then
    return false
  end

  local slug = currentSlug(aura)
  if slug == "" or slug ~= migration.slug then
    return true
  end

  local currentVersion = installedVersionForAura(aura)
  if currentVersion <= 0 then
    currentVersion = tonumber(migration.installedVersion or 0) or 0
  end

  return currentVersion < latestVersion
end

local function openedRevisionForSlug(slug)
  local state = MerfinPlusSaved and MerfinPlusSaved.CompanionUpdates
  local opened = state and state.opened and state.opened[slug]
  return tonumber(opened and opened.revision or 0) or 0
end

local function shouldUseOpenedState(aura)
  if type(aura) ~= "table" then
    return false
  end

  if aura.syncKind == "install" and (tonumber(aura.installedVersion or 0) or 0) <= 0 then
    return false
  end

  local state = MerfinPlusSaved and MerfinPlusSaved.CompanionUpdates
  local opened = state and state.opened and state.opened[aura.slug]
  return opened and tonumber(opened.revision or 0) == tonumber(aura.revision or 0)
end

local function queuedUpdates()
  local root, slugs = companionSource()
  if not root or not slugs then
    return {}
  end

  local pending = {}
  local queued = {}
  local installedVersions = installedVersionsBySlug()
  local installedMerfinVersions = installedVersionsByMerfinUid()

  for slug, entry in pairs(slugs) do
    local targetVersion = targetVersionForEntry(entry)
    local merfinUid = entryMerfinUid(entry)
    local installedVersion = merfinUid ~= "" and installedMerfinVersions[merfinUid] or installedVersions[slug]
    local syncKind = entry and entry.syncKind or ""
    local isInstall = syncKind == "install"
    local effectiveInstalledVersion = installedVersion
    if isInstall and effectiveInstalledVersion == nil then
      effectiveInstalledVersion = 0
    end
    local alreadyInstalled = targetVersion > 0 and effectiveInstalledVersion ~= nil and effectiveInstalledVersion >= targetVersion
    local installCompleted = isInstall and alreadyInstalled and openedRevisionForSlug(slug) >= targetVersion
    if (isInstall and not installCompleted) or (not isInstall and effectiveInstalledVersion ~= nil and targetVersion > effectiveInstalledVersion) then
      local aura = decodeAuraEntry(slug, entry)
      if aura then
        aura.installedVersion = effectiveInstalledVersion or 0
        aura.syncKind = syncKind
        pending[#pending + 1] = aura
        queued[slug] = true
      end
    end
  end

  local saved = WeakAurasSaved
  local displays = saved and saved.displays
  if type(displays) == "table" and type(root.Migrations) == "table" then
    for _, migration in ipairs(root.Migrations) do
      local slug = migration and migration.slug
      if type(slug) == "string" and slug ~= "" and not queued[slug] then
        local displayId, aura = findMigrationAura(displays, migration)
        local uidMatches = type(aura) ~= "table"
          or not migration.uid
          or migration.uid == ""
          or not aura.uid
          or aura.uid == migration.uid

        if uidMatches and canApplyMigration(root, aura, migration, displayId) then
          local entry = slugs[slug]
          local decoded = decodeAuraEntry(slug, entry)
          if decoded then
            decoded.installedVersion = tonumber(migration.installedVersion or 0) or 0
            decoded.legacyDisplayId = displayId
            pending[#pending + 1] = decoded
            queued[slug] = true
          end
        end
      end
    end
  end

  table.sort(pending, function(left, right)
    local leftSource = tostring(left.source or "")
    local rightSource = tostring(right.source or "")
    if leftSource ~= rightSource then
      return leftSource < rightSource
    end
    return tostring(left.name or left.slug) < tostring(right.name or right.slug)
  end)

  return pending
end

local function ensureBridgeState()
  MerfinPlusSaved = MerfinPlusSaved or {}
  MerfinPlusSaved.CompanionUpdates = MerfinPlusSaved.CompanionUpdates or {}
  return MerfinPlusSaved.CompanionUpdates
end

local function applyBackdrop(frame, bg, border)
  if not frame or not frame.SetBackdrop then
    return
  end

  frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
  frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
end

local function setTextColor(fontString, color)
  fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local function styleText(fontString, size, color, flags)
  if not fontString:SetFont(resolveMerfinFont(), size, flags or "") then
    fontString:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, flags or "")
  end
  setTextColor(fontString, color or TEXT)
end

local function styleSignatureText(fontString, size)
  if not fontString:SetFont(resolveSignatureFont(), size, "") then
    styleText(fontString, size, GOLD, "")
    return
  end
  setTextColor(fontString, { 1.00, 0.86, 0.48, 0.92 })
end

local function createBridgeButton(parent, width, height)
  local template = BackdropTemplateMixin and "BackdropTemplate" or nil
  local button = CreateFrame("Button", nil, parent, template)
  button:SetSize(width, height)
  applyBackdrop(button, BUTTON_BG, GOLD_SOFT)

  button.label = button:CreateFontString(nil, "OVERLAY")
  button.label:SetPoint("CENTER", button, "CENTER", 0, 1)
  button.label:SetJustifyH("CENTER")
  styleText(button.label, 12, GOLD, "")

  button.SetText = function(self, text)
    self.label:SetText(text or "")
  end

  button:SetScript("OnEnter", function(self)
    applyBackdrop(self, BUTTON_HOVER, GOLD)
  end)
  button:SetScript("OnLeave", function(self)
    applyBackdrop(self, BUTTON_BG, GOLD_SOFT)
  end)

  return button
end

local function createAnimatedLogo(parent, size, glowSize)
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetSize(size, size)

  local logoGlow = holder:CreateTexture(nil, "ARTWORK")
  logoGlow:SetTexture(LOGO_TEXTURE)
  logoGlow:SetBlendMode("ADD")
  logoGlow:SetAlpha(0)
  logoGlow:SetSize(glowSize, glowSize)
  logoGlow:SetPoint("CENTER", holder, "CENTER", 0, 0)

  local logo = holder:CreateTexture(nil, "ARTWORK")
  logo:SetTexture(LOGO_TEXTURE)
  logo:SetSize(size, size)
  logo:SetPoint("CENTER", holder, "CENTER", 0, 0)

  local function updateLogoAnimation()
    local now = GetTime and GetTime() or 0
    local cycle = (now % 7) / 7
    local scaleX = 1
    local mirrored = false
    local glowAlpha = 0

    if cycle >= 0.42 and cycle <= 0.58 then
      local progress = (cycle - 0.42) / 0.16
      local eased = progress * progress * (3 - 2 * progress)
      local cosine = math.cos(eased * math.pi * 2)
      scaleX = math.max(0.08, math.abs(cosine))
      mirrored = cosine < 0
      glowAlpha = 0.58 * math.sin(eased * math.pi)
    end

    logo:SetSize(size * scaleX, size)
    logo:SetTexCoord(mirrored and 1 or 0, mirrored and 0 or 1, 0, 1)
    logoGlow:SetSize(glowSize * scaleX, glowSize)
    logoGlow:SetTexCoord(mirrored and 1 or 0, mirrored and 0 or 1, 0, 1)
    logoGlow:SetAlpha(glowAlpha)
  end

  holder:SetScript("OnUpdate", updateLogoAnimation)
  updateLogoAnimation()
  holder.logo = logo
  holder.logoGlow = logoGlow
  return holder
end

local function ensureWeakAurasImport()
  if WeakAuras and WeakAuras.Import then
    return true
  end

  if C_AddOns and C_AddOns.LoadAddOn then
    pcall(C_AddOns.LoadAddOn, "WeakAurasOptions")
  elseif LoadAddOn then
    pcall(LoadAddOn, "WeakAurasOptions")
  end

  return WeakAuras and WeakAuras.Import
end

function BRIDGE:MarkOpened(aura)
  local state = ensureBridgeState()
  state.opened = state.opened or {}
  state.opened[aura.slug] = {
    revision = aura.revision,
    openedAt = time and time() or 0,
  }
end

function BRIDGE:OpenAura(aura, row)
  if not aura or not aura.encoded then
    printBridge(T("missingPayload"), RED)
    return
  end

  if InCombatLockdown and InCombatLockdown() then
    printBridge(T("leaveCombat"), RED)
    return
  end

  if not ensureWeakAurasImport() then
    printBridge(T("importUnavailable"), RED)
    return
  end

  self:MarkOpened(aura)
  if row and row.status then
    row.status:SetText(T("opened"))
    setTextColor(row.status, GREEN)
  end
  if row and row.button then
    row.button:SetText(T("openAgain"))
  end

  WeakAuras.Import(aura.encoded)
end

function BRIDGE:CreateReadMeFrame()
  if self.readMeFrame then
    return self.readMeFrame
  end

  local template = BackdropTemplateMixin and "BackdropTemplate" or nil
  local frame = CreateFrame("Frame", "MerfinPlusCompanionReadMeFrame", UIParent, template)
  frame:SetSize(660, 430)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  applyBackdrop(frame, PANEL, GOLD_SOFT)

  local header = CreateFrame("Frame", nil, frame)
  header:SetSize(250, 52)
  header:SetPoint("TOP", frame, "TOP", 0, -22)

  local logoHolder = createAnimatedLogo(header, 46, 56)
  logoHolder:SetPoint("LEFT", header, "LEFT", 0, 0)
  frame.readMeLogoHolder = logoHolder

  local title = header:CreateFontString(nil, "OVERLAY")
  title:SetPoint("LEFT", logoHolder, "RIGHT", 12, 1)
  title:SetPoint("RIGHT", header, "RIGHT", 0, 0)
  title:SetJustifyH("LEFT")
  styleText(title, 24, TEXT, "")
  frame.readMeTitle = title

  local body = frame:CreateFontString(nil, "OVERLAY")
  body:SetPoint("TOPLEFT", frame, "TOPLEFT", 48, -96)
  body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -48, 82)
  body:SetJustifyH("CENTER")
  body:SetJustifyV("TOP")
  styleText(body, 14, TEXT, "")
  if body.SetSpacing then
    body:SetSpacing(6)
  end
  frame.readMeBody = body

  local close = createBridgeButton(frame, 130, 30)
  close:SetPoint("BOTTOM", frame, "BOTTOM", 0, 24)
  close:SetScript("OnClick", function()
    frame:Hide()
  end)
  frame.readMeClose = close

  frame:Hide()
  self.readMeFrame = frame
  return frame
end

function BRIDGE:RefreshReadMeFrame()
  if not self.readMeFrame then
    return
  end

  self.readMeFrame.readMeTitle:SetText(T("readMeTitle"))
  self.readMeFrame.readMeBody:SetText(T("readMeText"))
  self.readMeFrame.readMeClose:SetText(T("readMeClose"))
end

function BRIDGE:ShowReadMe()
  local frame = self:CreateReadMeFrame()
  self:RefreshReadMeFrame()
  frame:Show()
end

function BRIDGE:CreateFrame()
  if self.frame then
    return self.frame
  end

  local template = BackdropTemplateMixin and "BackdropTemplate" or nil
  local frame = CreateFrame("Frame", "MerfinPlusCompanionUpdateFrame", UIParent, template)
  frame:SetSize(780, 520)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  applyBackdrop(frame, PANEL, GOLD_SOFT)

  local logoHolder = CreateFrame("Frame", nil, frame)
  logoHolder:SetSize(50, 50)
  logoHolder:SetPoint("TOPLEFT", 19, -15)
  frame.logoHolder = logoHolder

  local logoGlow = logoHolder:CreateTexture(nil, "ARTWORK")
  logoGlow:SetTexture(LOGO_TEXTURE)
  logoGlow:SetBlendMode("ADD")
  logoGlow:SetAlpha(0)
  logoGlow:SetSize(60, 60)
  logoGlow:SetPoint("CENTER", logoHolder, "CENTER", 0, 0)
  frame.logoGlow = logoGlow

  local logo = logoHolder:CreateTexture(nil, "ARTWORK")
  logo:SetTexture(LOGO_TEXTURE)
  logo:SetSize(50, 50)
  logo:SetPoint("CENTER", logoHolder, "CENTER", 0, 0)
  frame.logo = logo

  local function updateLogoAnimation()
    local now = GetTime and GetTime() or 0
    local cycle = (now % 7) / 7
    local scaleX = 1
    local mirrored = false
    local glowAlpha = 0

    if cycle >= 0.42 and cycle <= 0.58 then
      local progress = (cycle - 0.42) / 0.16
      local eased = progress * progress * (3 - 2 * progress)
      local cosine = math.cos(eased * math.pi * 2)
      scaleX = math.max(0.08, math.abs(cosine))
      mirrored = cosine < 0
      glowAlpha = 0.58 * math.sin(eased * math.pi)
    end

    logo:SetSize(50 * scaleX, 50)
    logo:SetTexCoord(mirrored and 1 or 0, mirrored and 0 or 1, 0, 1)
    logoGlow:SetSize(60 * scaleX, 60)
    logoGlow:SetTexCoord(mirrored and 1 or 0, mirrored and 0 or 1, 0, 1)
    logoGlow:SetAlpha(glowAlpha)
  end
  logoHolder:SetScript("OnUpdate", updateLogoAnimation)
  updateLogoAnimation()

  local title = frame:CreateFontString(nil, "OVERLAY")
  title:SetPoint("LEFT", logoHolder, "RIGHT", 12, 1)
  title:SetWidth(325)
  title:SetJustifyH("LEFT")
  styleText(title, 22, TEXT, "")
  title:SetText("MerfinUI WeakAura Updates")
  frame.title = title

  local closeButton = createBridgeButton(frame, 32, 26)
  closeButton:SetPoint("TOPRIGHT", -16, -14)
  closeButton:SetText("X")
  closeButton:SetScript("OnClick", function()
    frame:Hide()
  end)
  frame.closeButton = closeButton

  local signature = frame:CreateFontString(nil, "OVERLAY")
  signature:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -3)
  signature:SetWidth(220)
  signature:SetJustifyH("CENTER")
  styleSignatureText(signature, 16)
  signature:SetText("© 2026 by Anouschka")
  frame.signature = signature

  local count = frame:CreateFontString(nil, "OVERLAY")
  count:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7)
  count:SetPoint("RIGHT", frame, "RIGHT", -80, 0)
  count:SetJustifyH("LEFT")
  styleText(count, 13, GOLD, "")
  frame.count = count

  local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 24, -86)
  scroll:SetPoint("BOTTOMRIGHT", -40, 64)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)
  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local maxScroll = math.max(0, (content:GetHeight() or 0) - (self:GetHeight() or 0))
    local current = self:GetVerticalScroll() or 0
    local nextScroll = current - (delta or 0) * 36
    if nextScroll < 0 then
      nextScroll = 0
    elseif nextScroll > maxScroll then
      nextScroll = maxScroll
    end
    self:SetVerticalScroll(nextScroll)
  end)
  if scroll.ScrollBar then
    local bar = scroll.ScrollBar
    bar:Hide()
    bar:SetAlpha(0)
    bar:EnableMouse(false)
    bar.Show = function() end
    if bar.ScrollUpButton then
      bar.ScrollUpButton:Hide()
      bar.ScrollUpButton:SetAlpha(0)
      bar.ScrollUpButton:EnableMouse(false)
    end
    if bar.ScrollDownButton then
      bar.ScrollDownButton:Hide()
      bar.ScrollDownButton:SetAlpha(0)
      bar.ScrollDownButton:EnableMouse(false)
    end
    local regions = { bar:GetRegions() }
    for _, region in ipairs(regions) do
      if region and region.SetAlpha then
        region:SetAlpha(0)
      end
      if region and region.Hide then
        region:Hide()
      end
    end
  end
  frame.scroll = scroll
  frame.content = content
  frame.rows = {}

  local reload = createBridgeButton(frame, 130, 30)
  reload:SetPoint("BOTTOMRIGHT", -24, 18)
  reload:SetText(T("reloadUi"))
  reload:SetScript("OnClick", function()
    ReloadUI()
  end)
  frame.reload = reload

  local readMe = createBridgeButton(frame, 130, 30)
  readMe:SetPoint("RIGHT", reload, "LEFT", -12, 0)
  readMe:SetText(T("readMe"))
  readMe:SetScript("OnClick", function()
    BRIDGE:ShowReadMe()
  end)
  frame.readMe = readMe

  frame:Hide()
  self.frame = frame
  return frame
end

local function rowAccountText(aura)
  if type(aura.accounts) ~= "table" or #aura.accounts == 0 then
    return ""
  end
  return table.concat(aura.accounts, ", ")
end

function BRIDGE:CreateRow(parent, index)
  local template = BackdropTemplateMixin and "BackdropTemplate" or nil
  local row = CreateFrame("Frame", nil, parent, template)
  row:SetSize(700, 78)
  applyBackdrop(row, PANEL_ROW, GOLD_SOFT)

  row.name = row:CreateFontString(nil, "OVERLAY")
  row.name:SetPoint("TOPLEFT", 14, -11)
  row.name:SetPoint("RIGHT", -148, 0)
  row.name:SetJustifyH("LEFT")
  styleText(row.name, 15, TEXT, "")

  row.meta = row:CreateFontString(nil, "OVERLAY")
  row.meta:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -4)
  row.meta:SetPoint("RIGHT", -148, 0)
  row.meta:SetJustifyH("LEFT")
  styleText(row.meta, 12, MUTED, "")

  row.status = row:CreateFontString(nil, "OVERLAY")
  row.status:SetPoint("TOPLEFT", row.meta, "BOTTOMLEFT", 0, -6)
  row.status:SetPoint("RIGHT", -148, 0)
  row.status:SetJustifyH("LEFT")
  styleText(row.status, 12, GREEN, "")

  row.button = createBridgeButton(row, 112, 30)
  row.button:SetPoint("RIGHT", -16, 0)

  self.frame.rows[index] = row
  return row
end

function BRIDGE:Render(updates)
  local frame = self:CreateFrame()
  local content = frame.content
  local previous
  frame.reload:SetText(T("reloadUi"))
  frame.readMe:SetText(T("readMe"))

  for index, aura in ipairs(updates) do
    local row = frame.rows[index] or self:CreateRow(content, index)
    row:ClearAllPoints()
    if previous then
      row:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
    else
      row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    end
    row:SetPoint("RIGHT", content, "RIGHT", -4, 0)

    row.name:SetText(aura.name or aura.slug)
    local sourceText = aura.source or aura.expansionLabel or "MerfinUI"
    local uidText = aura.merfinUid or aura.slug or "unknown"
    local revisionText = aura.merfinRevision or aura.revision or 1
    row.meta:SetText(sourceText .. " | UID: " .. tostring(uidText) .. " | Rev: " .. tostring(revisionText))

    if shouldUseOpenedState(aura) then
      row.status:SetText(T("opened"))
      setTextColor(row.status, GREEN)
      row.button:SetText(T("openAgain"))
    else
      row.status:SetText(T("ready"))
      setTextColor(row.status, GREEN)
      row.button:SetText(aura.syncKind == "install" and T("install") or T("update"))
    end

    row.button:SetScript("OnClick", function()
      BRIDGE:OpenAura(aura, row)
    end)
    row:Show()
    previous = row
  end

  for index = #updates + 1, #frame.rows do
    frame.rows[index]:Hide()
  end

  local height = math.max(1, #updates * 84)
  content:SetSize(714, height)
  frame.count:SetText(#updates == 1 and T("countOne") or T("countMany", { count = #updates }))
end

function BRIDGE:Show(force)
  if InCombatLockdown and InCombatLockdown() then
    self.showAfterCombat = force and true or false
    printBridge(T("updatesAfterCombat"), GOLD)
    return
  end

  local updates = queuedUpdates()
  if #updates == 0 then
    if force then
      printBridge(T("noUpdates"), GOLD)
    end
    if self.frame then
      self.frame:Hide()
    end
    return
  end

  self:Render(updates)
  self.frame:Show()
end

function BRIDGE:ScheduleAutoShow()
  if self.autoShowScheduled then
    return
  end
  self.autoShowScheduled = true

  local function show()
    BRIDGE.autoShowScheduled = false
    BRIDGE:Show(false)
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(2, show)
  else
    show()
  end
end

SLASH_MERFINPLUS_WEAKAURA_UPDATES1 = "/merfinupdates"
SLASH_MERFINPLUS_WEAKAURA_UPDATES2 = "/merfinwa"
SlashCmdList.MERFINPLUS_WEAKAURA_UPDATES = function()
  BRIDGE:Show(true)
end

if CreateFrame then
  local eventFrame = CreateFrame("Frame")
  eventFrame:RegisterEvent("ADDON_LOADED")
  eventFrame:RegisterEvent("PLAYER_LOGIN")
  eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
  eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName ~= "WeakAuras" and addonName ~= "WeakAurasOptions" then
      return
    end

    if event == "PLAYER_REGEN_ENABLED" and BRIDGE.showAfterCombat then
      BRIDGE.showAfterCombat = false
      BRIDGE:Show(true)
      return
    end

    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or addonName == "WeakAuras" then
      BRIDGE:ScheduleAutoShow()
    end

    if event == "PLAYER_ENTERING_WORLD" then
      self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
  end)
end
