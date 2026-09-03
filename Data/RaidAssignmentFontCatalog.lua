local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local FONT_ROOT = "Interface\\AddOns\\MerfinPlus\\Media\\font\\"
local ASSIGNMENT_FONT_ROOT = FONT_ROOT .. "assignment\\"

-- These are the original MerfinPlus Boss Plan token mappings. Keep their
-- paths and their shared bold/italic behavior unchanged for existing plans.
local LEGACY_PATHS = {
  Roboto = FONT_ROOT .. "SFUIDisplayCondensed-Semibold.otf",
  Inter = FONT_ROOT .. "PTSansNarrow.ttf",
  Arial = FONT_ROOT .. "ArchivoNarrow-Bold.ttf",
  Georgia = FONT_ROOT .. "ArchivoNarrow-Bold.ttf",
  ["Trebuchet MS"] = FONT_ROOT .. "Expressway.ttf",
  ["Courier New"] = FONT_ROOT .. "HOOGE.TTF",
  Verdana = FONT_ROOT .. "PTSansNarrow-Bold.ttf",
  ["Comic Sans MS"] = FONT_ROOT .. "Caveat-SemiBold.ttf",
}

local LEGACY_BOLD_PATH = FONT_ROOT .. "SFUIDisplayCondensed-Bold.otf"
local LEGACY_ITALIC_PATH = FONT_ROOT .. "Caveat-SemiBold.ttf"

-- These files are copied verbatim from the Guild Manager's OFL-cleared font
-- bundle. Families without a separate italic file deliberately keep their own
-- regular face instead of falling back to a different MerfinPlus family.
local OPEN_FONT_STYLES = {
  Arimo = {
    regular = ASSIGNMENT_FONT_ROOT .. "arimo-variable.ttf",
    italic = ASSIGNMENT_FONT_ROOT .. "arimo-variable-italic.ttf",
  },
  ["Archivo Narrow"] = {
    regular = ASSIGNMENT_FONT_ROOT .. "archivo-narrow-variable.ttf",
    italic = ASSIGNMENT_FONT_ROOT .. "archivo-narrow-variable-italic.ttf",
  },
  Anton = { regular = ASSIGNMENT_FONT_ROOT .. "anton-regular.ttf" },
  Oxanium = { regular = ASSIGNMENT_FONT_ROOT .. "oxanium-variable.ttf" },
  Grandstander = {
    regular = ASSIGNMENT_FONT_ROOT .. "grandstander-variable.ttf",
    italic = ASSIGNMENT_FONT_ROOT .. "grandstander-variable-italic.ttf",
  },
  Michroma = { regular = ASSIGNMENT_FONT_ROOT .. "michroma-regular.ttf" },
  ["Nunito Sans"] = {
    regular = ASSIGNMENT_FONT_ROOT .. "nunito-sans-variable.ttf",
    italic = ASSIGNMENT_FONT_ROOT .. "nunito-sans-variable-italic.ttf",
  },
}

-- Historical Guild Manager tokens remain importable but are not offered as
-- new picker choices. The existing MerfinPlus Arial token above intentionally
-- retains its previous local mapping.
local OPEN_FONT_ALIASES = {
  ["Arial CE"] = "Arimo",
  ["Arial Light"] = "Arimo",
  ["Arial Narrow"] = "Archivo Narrow",
  ["Arial Black"] = "Anton",
  ["Arial CE MT Black"] = "Anton",
  Alkia = "Oxanium",
  Gantians = "Grandstander",
  Redhawk = "Michroma",
  ["Soul Daisy"] = "Nunito Sans",
}

local FONT_CHOICES = {
  { token = "Roboto", path = LEGACY_PATHS.Roboto },
  { token = "Inter", path = LEGACY_PATHS.Inter },
  { token = "Arimo", path = OPEN_FONT_STYLES.Arimo.regular },
  { token = "Archivo Narrow", path = OPEN_FONT_STYLES["Archivo Narrow"].regular },
  { token = "Anton", path = OPEN_FONT_STYLES.Anton.regular },
  { token = "Oxanium", path = OPEN_FONT_STYLES.Oxanium.regular },
  { token = "Grandstander", path = OPEN_FONT_STYLES.Grandstander.regular },
  { token = "Michroma", path = OPEN_FONT_STYLES.Michroma.regular },
  { token = "Nunito Sans", path = OPEN_FONT_STYLES["Nunito Sans"].regular },
  { token = "Georgia", path = LEGACY_PATHS.Georgia },
  { token = "Trebuchet MS", path = LEGACY_PATHS["Trebuchet MS"] },
  { token = "Courier New", path = LEGACY_PATHS["Courier New"] },
  { token = "Verdana", path = LEGACY_PATHS.Verdana },
  { token = "Comic Sans MS", path = LEGACY_PATHS["Comic Sans MS"] },
}

local TOKEN_SET = {}
for _, choice in ipairs(FONT_CHOICES) do
  TOKEN_SET[choice.token] = true
end
-- Arial is no longer offered for new plans because the Guild Manager exposes
-- it only as a historical import alias.  Keep the original MerfinPlus token
-- valid and mapped exactly as before for backwards compatibility.
TOKEN_SET.Arial = true
for token in pairs(OPEN_FONT_ALIASES) do
  TOKEN_SET[token] = true
end

function MerfinPlus:GetRaidAssignmentFontChoices()
  return FONT_CHOICES
end

function MerfinPlus:GetRaidAssignmentFontTokenSet()
  return TOKEN_SET
end

function MerfinPlus:GetRaidAssignmentFontPath(token, italic, bold)
  token = type(token) == "string" and token or "Roboto"
  local openFamily = OPEN_FONT_STYLES[token] or OPEN_FONT_STYLES[OPEN_FONT_ALIASES[token]]
  if openFamily then
    if italic and openFamily.italic then
      return openFamily.italic
    end
    return openFamily.regular
  end
  if italic then return LEGACY_ITALIC_PATH end
  if bold then return LEGACY_BOLD_PATH end
  return LEGACY_PATHS[token] or LEGACY_PATHS.Roboto
end

function MerfinPlus:GetRaidAssignmentFontContract()
  return {
    choices = FONT_CHOICES,
    tokens = TOKEN_SET,
    aliases = OPEN_FONT_ALIASES,
  }
end
