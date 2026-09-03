-- Runtime-selectable MerfinPlus UI localization.
-- Imported assignment/export payloads never pass through this module.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local LOCALE_ORDER = { "enUS", "deDE", "frFR", "esES", "esMX", "ptBR", "itIT", "ruRU", "zhCN", "zhTW", "koKR", "jaJP" }
local LOCALE_NAMES = {
  enUS = "English",
  deDE = "Deutsch",
  frFR = "Français",
  esES = "Español",
  esMX = "Español (Latinoamérica)",
  ptBR = "Português",
  itIT = "Italiano",
  ruRU = "Русский",
  zhCN = "简体中文",
  zhTW = "繁體中文",
  koKR = "한국어",
  jaJP = "日本語",
}

local enUS = {
  ["Language"] = "Language",
  ["Close"] = "Close",
  ["Export"] = "Export",
  ["Raid Settings"] = "Raid Settings",
  ["Raid Cooldowns"] = "Raid Cooldowns",
  ["The Burning Crusade"] = "The Burning Crusade",
  ["General Settings"] = "General Settings",
  ["Detected Expansion"] = "Detected Expansion",
  ["Select Your Aura"] = "Select Your Aura",
  ["Enable/Disable"] = "Enable/Disable",
  ["Send Message on Click"] = "Send Message on Click",
  ["Display Settings"] = "Display Settings",
  ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
    "These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras.",
  ["Show Yourself"] = "Show Yourself",
  ["Show When Ready"] = "Show When Ready",
  ["Show When Dead"] = "Show When Dead",
  ["Show When Offline"] = "Show When Offline",
  ["Show Buff Duration"] = "Show Buff Duration",
  ["Show Ready Indicator"] = "Show Ready Indicator",
  ["Dead Color"] = "Dead Color",
  ["Raid Subgroups"] = "Raid Subgroups",
  ["Advanced Spell Settings"] = "Advanced Spell Settings",
  ["Specialization Display"] = "Specialization Display",
  ["Select Spell"] = "Select Spell",
  ["Add Spell"] = "Add Spell",
  ["Delete Spell"] = "Delete Spell",
  ["Selected Spell"] = "Selected Spell",
  ["Spell Name (Optional)"] = "Spell Name (Optional)",
  ["Spell ID (Required)"] = "Spell ID (Required)",
  ["Spell ID"] = "Spell ID",
  ["A positive spell ID is required."] = "A positive spell ID is required.",
  ["Show DPS"] = "Show DPS",
  ["Show Tanks"] = "Show Tanks",
  ["Show Healers"] = "Show Healers",
  ["Spell Order"] = "Spell Order",
  ["Index"] = "Index",
  ["Cooldown Activation"] = "Cooldown Activation",
  ["Enable cooldowns by class. Expand a class to configure individual spells."] =
    "Enable cooldowns by class. Expand a class to configure individual spells.",
  ["Expand"] = "Expand",
  ["Collapse"] = "Collapse",
  ["No Raid Cooldown configuration is available for this expansion."] =
    "No Raid Cooldown configuration is available for this expansion.",
  ["Assignments"] = "Assignments",
  ["WoW Sim"] = "WoW Sim",
  ["Media"] = "Media",
  ["Profiles"] = "Profiles",
  ["General Assignments"] = "General Assignments",
  ["Raid Assignments"] = "Raid Assignments",
  ["WA Assignments"] = "WA Assignments",
  ["Gurtogg Bloodboil Assignments"] = "Gurtogg Bloodboil Assignments",
  ["Reliquary of Souls"] = "Reliquary of Souls",
  ["The Illidari Council"] = "The Illidari Council",
  ["Illidan Stormrage"] = "Illidan Stormrage",
  ["Use MerfinPlus Guild Manager Assignments"] = "Use MerfinPlus Guild Manager Assignments",
  ["Use Manual Groups"] = "Use Manual Groups",
  ["Guild Manager assignments are sent automatically with Gurtogg boss assignment syncs."] =
    "Guild Manager assignments are sent automatically with Gurtogg boss assignment syncs.",
  ["Manual groups are sent only by Send Manual Groups or the emergency pull sync."] =
    "Manual groups are sent only by Send Manual Groups or the emergency pull sync.",
  ["Group 1"] = "Group 1",
  ["Group 2"] = "Group 2",
  ["Group 3"] = "Group 3",
  ["Player Names"] = "Player Names",
  ["Blood Boil Stacks"] = "Blood Boil Stacks",
  ["Separate player names with commas, semicolons, spaces, or line breaks."] =
    "Separate player names with commas, semicolons, spaces, or line breaks.",
  ["Send Manual Groups"] = "Send Manual Groups",
  ["Phase 2 Group 1"] = "Phase 2 Group 1",
  ["Phase 2 Group 2"] = "Phase 2 Group 2",
  ["Phase 2 Group 3"] = "Phase 2 Group 3",
  ["Guild Manager Illidan Phase 2 groups are sent automatically with Illidan boss assignment syncs."] =
    "Guild Manager Illidan Phase 2 groups are sent automatically with Illidan boss assignment syncs.",
  ["Manual Illidan Phase 2 groups are sent only by Send Manual Groups or the emergency pull sync."] =
    "Manual Illidan Phase 2 groups are sent only by Send Manual Groups or the emergency pull sync.",
  ["Send Manual Assignments"] = "Send Manual Assignments",
  ["Spirit Shock Interrupt"] = "Spirit Shock Interrupt",
  ["Rune Shield Spell Steal"] = "Rune Shield Spell Steal",
  ["Seethe Tranq Shot"] = "Seethe Tranq Shot",
  ["Prayer of Healing"] = "Prayer of Healing",
  ["Guild Manager WeakAura assignments are sent automatically with this boss assignment sync."] =
    "Guild Manager WeakAura assignments are sent automatically with this boss assignment sync.",
  ["Manual assignments are sent only by Send Manual Assignments or the emergency pull sync."] =
    "Manual assignments are sent only by Send Manual Assignments or the emergency pull sync.",
  ["Gurtogg group assignments synced."] = "Gurtogg group assignments synced.",
  ["Gurtogg group assignments synced with the boss assignments."] =
    "Gurtogg group assignments synced with the boss assignments.",
  ["Settings"] = "Settings",
  ["Widget Settings"] = "Widget Settings",
  ["Loot / Roster Export"] = "Loot / Roster Export",
  ["Pre-Boss Groups"] = "Pre-Boss Groups",
  ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
    "Pre-Boss Groups are not configured yet. This page is reserved for a future update.",
  ["Import replaces the current saved Pre-Boss Groups plan."] =
    "Import replaces the current saved Pre-Boss Groups plan.",
  ["No Pre-Boss Groups plan imported."] = "No Pre-Boss Groups plan imported.",
  ["Pre-Boss Groups import failed: %s"] = "Pre-Boss Groups import failed: %s",
  ["Imported %d bosses for %s."] = "Imported %d bosses for %s.",
  ["Set %s Group"] = "Set %s Group",
  ["Set Group"] = "Set Group",
  ["Raid groups cannot be changed during combat."] =
    "Raid groups cannot be changed during combat.",
  ["You must be in a raid to set groups."] =
    "You must be in a raid to set groups.",
  ["Only the raid leader or a raid assistant can set groups."] =
    "Only the raid leader or a raid assistant can set groups.",
  ["The raid roster APIs are unavailable in this client."] =
    "The raid roster APIs are unavailable in this client.",
  ["No assigned players for %s."] = "No assigned players for %s.",
  ["Group set successful for %s."] = "Group set successful for %s.",
  ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
    "Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d.",
  ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
    "No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d).",
  ["Group set failed for %s: %s"] = "Group set failed for %s: %s",
  ["Another group update is still being verified."] =
    "Another group update is still being verified.",
  ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
    "Roster names could not be resolved (missing %d, ambiguous %d).",
  ["%d roster API request(s) failed."] = "%d roster API request(s) failed.",
  ["%d player(s) left the raid before verification."] =
    "%d player(s) left the raid before verification.",
  ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
    "Roster verification failed (groups %d/%d, slots %d/%d).",
  ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
    "Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying...",
  ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
    "Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d.",
  ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
    "WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported.",
  ["Import"] = "Import",
  ["Broadcast"] = "Broadcast",
  ["Delete"] = "Delete",
  ["Cancel"] = "Cancel",
  ["Copy"] = "Copy",
  ["Generate"] = "Generate",
  ["Press CTRL+C now"] = "Press CTRL+C now",
  ["Select Raid"] = "Select Raid",
  ["Serpentshrine Cavern"] = "Serpentshrine Cavern",
  ["Tempest Keep"] = "Tempest Keep",
  ["Black Temple"] = "Black Temple",
  ["Hyjal Summit"] = "Hyjal Summit",
  ["Select a raid to view WeakAura assignments."] = "Select a raid to view WeakAura assignments.",
  ["No WeakAura assignments are available for the selected raid."] =
    "No WeakAura assignments are available for the selected raid.",
  ["Select a boss"] = "Select a boss",
  ["Choose a boss from the list."] = "Choose a boss from the list.",
  ["No imported assignments exist for this boss."] = "No imported assignments exist for this boss.",
  ["No General Assignments imports saved."] = "No General Assignments imports saved.",
  ["The selected import could not be parsed."] = "The selected import could not be parsed.",
  ["Invalid General Assignments string."] = "Invalid General Assignments string.",
  ["Invalid Raid Assignments string."] = "Invalid Raid Assignments string.",
  ["Identical import already exists; selected the saved import."] =
    "Identical import already exists; selected the saved import.",
  ["General Assignments import saved."] = "General Assignments import saved.",
  ["Raid Assignments import saved."] = "Raid Assignments import saved.",
  ["You need to be in a group."] = "You need to be in a group.",
  ["Only group leaders or raid assistants can broadcast."] = "Only group leaders or raid assistants can broadcast.",
  ["No valid General Assignments import is selected."] = "No valid General Assignments import is selected.",
  ["No imported assignments exist for the selected boss."] = "No imported assignments exist for the selected boss.",
  ["Delete the selected General Assignments import?\n\n%s"] =
    "Delete the selected General Assignments import?\n\n%s",
  ["Delete the selected recorded raid?\n\n%s"] = "Delete the selected recorded raid?\n\n%s",
  ["Loot Tracking"] = "Loot Tracking",
  ["Detected expansion: %s"] = "Detected expansion: %s",
  ["Track Loot"] = "Track Loot",
  ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
    "Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked.",
  ["Recorded Raids"] = "Recorded Raids",
  ["No recorded raids"] = "No recorded raids",
  ["Items:"] = "Items:",
  ["Raid Export"] = "Raid Export",
  ["Guild Export"] = "Guild Export",
  ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
    "Exports only level %s players for %s, using the Guild Manager roster schema.",
  ["Show Minimap Icon"] = "Show Minimap Icon",
  ["Show Assignment Widget"] = "Show Assignment Widget",
  ["Show Raid Leader Widget"] = "Show Raid Leader Widget",
  ["Assignment Widget Visibility"] = "Assignment Widget Visibility",
  ["Raid Leader Widget Visibility"] = "Raid Leader Widget Visibility",
  ["Assignment: Show always"] = "Assignment: Show always",
  ["Assignment: Load only in Raid"] = "Assignment: Load only in Raid",
  ["Raid Leader: Show always"] = "Raid Leader: Show always",
  ["Raid Leader: Load only in Raid"] = "Raid Leader: Load only in Raid",
  ["Assignment Widget"] = "Assignment Widget",
  ["Raid Leader Widget"] = "Raid Leader Widget",
  ["Raid Leader"] = "Raid Leader",
  ["Header Color"] = "Header Color",
  ["Header Width"] = "Header Width",
  ["Header Height"] = "Header Height",
  ["Header Opacity"] = "Header Opacity",
  ["Assignment Background Opacity"] = "Assignment Background Opacity",
  ["Header Title X Offset"] = "Header Title X Offset",
  ["Header Title Y Offset"] = "Header Title Y Offset",
  ["Header Title Size"] = "Header Title Size",
  ["Header Font"] = "Header Font",
  ["Header Title Spacing"] = "Header Title Spacing",
  ["Header Icon X Offset"] = "Header Icon X Offset",
  ["Header Icon Y Offset"] = "Header Icon Y Offset",
  ["Header Icon Size"] = "Header Icon Size",
  ["Show Icon Logo"] = "Show Icon Logo",
  ["Show Border"] = "Show Border",
  ["Border Color"] = "Border Color",
  ["Border Thickness"] = "Border Thickness",
  ["Aligning"] = "Aligning",
  ["Up"] = "Up",
  ["Down"] = "Down",
  ["Left"] = "Left",
  ["Right"] = "Right",
  ["MerfinPlus Version Check"] = "MerfinPlus Version Check",
  ["Player"] = "Player",
  ["T5 Raidpack"] = "T5 Raidpack",
  ["Scanning group..."] = "Scanning group...",
  ["Done"] = "Done",
  ["Refresh"] = "Refresh",
  ["Commands:"] = "Commands:",
  ["Left-click to open settings"] = "Left-click to open settings",
  ["Drag to move"] = "Drag to move",
  ["Players"] = "Players",
  ["Player"] = "Player",
  ["Tank Assignments"] = "Tank Assignments",
  ["Healer Assignments"] = "Healer Assignments",
  ["Melee Positions"] = "Melee Positions",
  ["Ranged Positions"] = "Ranged Positions",
  ["Tank Positions"] = "Tank Positions",
  ["Heal Positions"] = "Heal Positions",
  ["Additional Assignments"] = "Additional Assignments",
  ["Main"] = "Main",
  ["Backup"] = "Backup",
  ["Assigned"] = "Assigned",
  ["Main Target"] = "Main Target",
  ["Off Target"] = "Off Target",
  ["Tank"] = "Tank",
  ["Healer"] = "Healer",
  ["Damage"] = "Damage",
  ["Warrior"] = "Warrior",
  ["Paladin"] = "Paladin",
  ["Hunter"] = "Hunter",
  ["Rogue"] = "Rogue",
  ["Priest"] = "Priest",
  ["Shaman"] = "Shaman",
  ["Mage"] = "Mage",
  ["Warlock"] = "Warlock",
  ["Druid"] = "Druid",
  ["Bloodlust"] = "Bloodlust",
  ["Heroism"] = "Heroism",
  ["Soulstone"] = "Soulstone",
  ["Innervate"] = "Innervate",
  ["Misdirection"] = "Misdirection",
  ["Star"] = "Star",
  ["Circle"] = "Circle",
  ["Diamond"] = "Diamond",
  ["Triangle"] = "Triangle",
  ["Moon"] = "Moon",
  ["Square"] = "Square",
  ["Cross"] = "Cross",
  ["Skull"] = "Skull",
}

local overrides = {
  deDE = {
    ["WoW Sim"] = "WoW Sim",
    ["Language"] = "Sprache", ["Close"] = "Schließen", ["Export"] = "Export",
    ["Raid Settings"] = "Raid-Einstellungen", ["Raid Cooldowns"] = "Raid-Abklingzeiten",
    ["Assignments"] = "Zuweisungen",
    ["Media"] = "Medien", ["Profiles"] = "Profile",
    ["General Assignments"] = "Allgemeine Zuweisungen", ["Raid Assignments"] = "Raid-Zuweisungen",
    ["WA Assignments"] = "WA Assignments",
    ["Settings"] = "Einstellungen", ["Widget Settings"] = "Widget-Einstellungen",
    ["Loot / Roster Export"] = "Loot- / Kaderexport", ["Pre-Boss Groups"] = "Pre-Boss-Gruppen",
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Pre-Boss-Gruppen sind noch nicht konfiguriert. Diese Seite ist für ein zukünftiges Update reserviert.",
    ["Import"] = "Importieren", ["Broadcast"] = "Senden", ["Delete"] = "Löschen",
    ["Copy"] = "Kopieren", ["Generate"] = "Erzeugen", ["Press CTRL+C now"] = "Jetzt STRG+C drücken",
    ["Select Raid"] = "Raid auswählen", ["Select a boss"] = "Boss auswählen",
    ["Serpentshrine Cavern"] = "Höhle des Schlangenschreins", ["Tempest Keep"] = "Festung der Stürme",
    ["Black Temple"] = "Schwarzer Tempel", ["Hyjal Summit"] = "Hyjalgipfel",
    ["Select a raid to view WeakAura assignments."] = "Wähle einen Raid aus, um WeakAura-Zuweisungen anzuzeigen.",
    ["No WeakAura assignments are available for the selected raid."] =
      "Für den ausgewählten Raid sind keine WeakAura-Zuweisungen verfügbar.",
    ["Choose a boss from the list."] = "Wähle einen Boss aus der Liste.",
    ["No imported assignments exist for this boss."] = "Für diesen Boss sind keine importierten Zuweisungen vorhanden.",
    ["No General Assignments imports saved."] = "Keine allgemeinen Zuweisungsimporte gespeichert.",
    ["The selected import could not be parsed."] = "Der ausgewählte Import konnte nicht gelesen werden.",
    ["Invalid General Assignments string."] = "Ungültiger String für allgemeine Zuweisungen.",
    ["Invalid Raid Assignments string."] = "Ungültiger Raid-Zuweisungsstring.",
    ["Identical import already exists; selected the saved import."] = "Ein identischer Import existiert bereits; der gespeicherte Import wurde ausgewählt.",
    ["General Assignments import saved."] = "Allgemeiner Zuweisungsimport gespeichert.",
    ["Raid Assignments import saved."] = "Raid-Zuweisungsimport gespeichert.",
    ["Delete the selected General Assignments import?\n\n%s"] = "Ausgewählten allgemeinen Zuweisungsimport löschen?\n\n%s",
    ["Delete the selected recorded raid?\n\n%s"] = "Ausgewählten aufgezeichneten Raid löschen?\n\n%s",
    ["Loot Tracking"] = "Beuteaufzeichnung", ["Detected expansion: %s"] = "Erkannte Erweiterung: %s",
    ["Track Loot"] = "Beute aufzeichnen", ["Recorded Raids"] = "Aufgezeichnete Raids",
    ["No recorded raids"] = "Keine aufgezeichneten Raids",
    ["Items:"] = "Gegenstände:", ["Raid Export"] = "Raid-Export", ["Guild Export"] = "Gildenexport",
    ["Show Minimap Icon"] = "Minikartensymbol anzeigen",
    ["Show Assignment Widget"] = "Zuweisungs-Widget anzeigen",
    ["Show Raid Leader Widget"] = "Raidleiter-Widget anzeigen",
    ["Assignment Widget Visibility"] = "Sichtbarkeit des Zuweisungs-Widgets",
    ["Raid Leader Widget Visibility"] = "Sichtbarkeit des Raidleiter-Widgets",
    ["Assignment: Show always"] = "Zuweisungen: Immer anzeigen",
    ["Assignment: Load only in Raid"] = "Zuweisungen: Nur im Raid laden",
    ["Raid Leader: Show always"] = "Raidleiter: Immer anzeigen",
    ["Raid Leader: Load only in Raid"] = "Raidleiter: Nur im Raid laden",
    ["Assignment Widget"] = "Zuweisungs-Widget", ["Raid Leader Widget"] = "Raidleiter-Widget",
    ["Raid Leader"] = "Raidleiter", ["Header Color"] = "Headerfarbe",
    ["Header Width"] = "Headerbreite", ["Header Height"] = "Headerhöhe",
    ["Header Opacity"] = "Header-Deckkraft", ["Assignment Background Opacity"] = "Hintergrund-Deckkraft",
    ["Header Title X Offset"] = "Headertitel X-Versatz", ["Header Title Y Offset"] = "Headertitel Y-Versatz",
    ["Header Title Size"] = "Headertitelgröße", ["Header Font"] = "Headerschrift",
    ["Header Title Spacing"] = "Buchstabenabstand", ["Header Icon X Offset"] = "Headericon X-Versatz",
    ["Header Icon Y Offset"] = "Headericon Y-Versatz", ["Header Icon Size"] = "Headericongröße",
    ["Show Icon Logo"] = "Icon-Logo anzeigen", ["Show Border"] = "Rahmen anzeigen",
    ["Border Color"] = "Rahmenfarbe", ["Border Thickness"] = "Rahmenstärke",
    ["Aligning"] = "Ausrichtung", ["Up"] = "Oben", ["Down"] = "Unten", ["Left"] = "Links", ["Right"] = "Rechts",
    ["MerfinPlus Version Check"] = "MerfinPlus-Versionsprüfung", ["Player"] = "Spieler",
    ["T5 Raidpack"] = "T5-Raidpaket", ["Scanning group..."] = "Gruppe wird geprüft...", ["Done"] = "Fertig",
    ["Refresh"] = "Aktualisieren", ["Commands:"] = "Befehle:",
    ["Players"] = "Spieler", ["Tank Assignments"] = "Tank-Zuweisungen",
    ["Healer Assignments"] = "Heiler-Zuweisungen", ["Melee Positions"] = "Nahkampfpositionen",
    ["Ranged Positions"] = "Fernkampfpositionen", ["Tank Positions"] = "Tankpositionen",
    ["Heal Positions"] = "Heilerpositionen", ["Additional Assignments"] = "Zusätzliche Zuweisungen",
    ["Main"] = "Haupt", ["Backup"] = "Ersatz", ["Assigned"] = "Zugewiesen",
    ["Main Target"] = "Hauptziel", ["Off Target"] = "Nebenziel",
    ["Tank"] = "Tank", ["Healer"] = "Heiler", ["Damage"] = "Schaden",
    ["Warrior"] = "Krieger", ["Paladin"] = "Paladin", ["Hunter"] = "Jäger",
    ["Rogue"] = "Schurke", ["Priest"] = "Priester", ["Shaman"] = "Schamane",
    ["Mage"] = "Magier", ["Warlock"] = "Hexenmeister", ["Druid"] = "Druide",
    ["Bloodlust"] = "Kampfrausch", ["Heroism"] = "Heldentum", ["Soulstone"] = "Seelenstein",
    ["Innervate"] = "Anregen", ["Misdirection"] = "Irreführung",
    ["Star"] = "Stern", ["Circle"] = "Kreis", ["Diamond"] = "Diamant", ["Triangle"] = "Dreieck",
    ["Moon"] = "Mond", ["Square"] = "Quadrat", ["Cross"] = "Kreuz", ["Skull"] = "Totenschädel",
  },
  frFR = {
    ["WoW Sim"] = "WoW Sim", ["T5 Raidpack"] = "Pack de raid T5",
    ["Delete the selected General Assignments import?\n\n%s"] = "Supprimer l’import d’affectations générales sélectionné ?\n\n%s",
    ["Delete the selected recorded raid?\n\n%s"] = "Supprimer le raid enregistré sélectionné ?\n\n%s",
    ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
      "Enregistre le butin rare, épique et légendaire dans les raids reconnus. Les donjons ne sont jamais suivis.",
    ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
      "Exporte uniquement les joueurs de niveau %s pour %s selon le schéma de roster Guild Manager.",
    ["Language"] = "Langue", ["Close"] = "Fermer", ["Raid Settings"] = "Paramètres de raid",
    ["Raid Cooldowns"] = "Temps de recharge de raid",
    ["Assignments"] = "Affectations", ["Media"] = "Médias", ["Profiles"] = "Profils",
    ["General Assignments"] = "Affectations générales", ["Raid Assignments"] = "Affectations de raid",
    ["Settings"] = "Paramètres", ["Widget Settings"] = "Paramètres des widgets",
    ["Loot / Roster Export"] = "Export butin / effectif", ["Pre-Boss Groups"] = "Groupes pré-boss",
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Les groupes pré-boss ne sont pas encore configurés. Cette page est réservée à une future mise à jour.",
    ["Import"] = "Importer", ["Broadcast"] = "Diffuser", ["Delete"] = "Supprimer", ["Copy"] = "Copier",
    ["Generate"] = "Générer", ["Press CTRL+C now"] = "Appuyez maintenant sur CTRL+C",
    ["Select Raid"] = "Sélectionner un raid", ["Select a boss"] = "Sélectionner un boss",
    ["Serpentshrine Cavern"] = "Caverne du sanctuaire du Serpent", ["Tempest Keep"] = "Donjon de la Tempête",
    ["Black Temple"] = "Temple noir", ["Hyjal Summit"] = "Sommet d’Hyjal",
    ["Select a raid to view WeakAura assignments."] = "Sélectionnez un raid pour afficher les affectations WeakAura.",
    ["No WeakAura assignments are available for the selected raid."] =
      "Aucune affectation WeakAura n’est disponible pour le raid sélectionné.",
    ["Choose a boss from the list."] = "Choisissez un boss dans la liste.",
    ["Loot Tracking"] = "Suivi du butin", ["Track Loot"] = "Suivre le butin",
    ["Recorded Raids"] = "Raids enregistrés", ["Items:"] = "Objets:",
    ["Raid Export"] = "Export de raid", ["Guild Export"] = "Export de guilde",
    ["Show Minimap Icon"] = "Afficher l’icône de minicarte",
    ["Show Assignment Widget"] = "Afficher le widget d’affectations",
    ["Show Raid Leader Widget"] = "Afficher le widget du chef de raid",
    ["Assignment Widget"] = "Widget d’affectations", ["Raid Leader Widget"] = "Widget du chef de raid",
    ["Raid Leader"] = "Chef de raid", ["Header Color"] = "Couleur de l’en-tête",
    ["Header Width"] = "Largeur de l’en-tête", ["Header Height"] = "Hauteur de l’en-tête",
    ["Header Opacity"] = "Opacité de l’en-tête", ["Header Font"] = "Police de l’en-tête",
    ["Header Title Spacing"] = "Espacement des lettres", ["Show Border"] = "Afficher la bordure",
    ["Border Color"] = "Couleur de bordure", ["Border Thickness"] = "Épaisseur de bordure",
    ["Aligning"] = "Alignement", ["Up"] = "Haut", ["Down"] = "Bas", ["Left"] = "Gauche", ["Right"] = "Droite",
    ["MerfinPlus Version Check"] = "Vérification de version MerfinPlus", ["Player"] = "Joueur",
    ["Scanning group..."] = "Analyse du groupe...", ["Done"] = "Terminé", ["Refresh"] = "Actualiser",
    ["Players"] = "Joueurs", ["Tank Assignments"] = "Affectations des tanks",
    ["Healer Assignments"] = "Affectations des soigneurs", ["Melee Positions"] = "Positions de mêlée",
    ["Ranged Positions"] = "Positions à distance", ["Tank Positions"] = "Positions des tanks",
    ["Heal Positions"] = "Positions des soigneurs", ["Additional Assignments"] = "Affectations supplémentaires",
    ["Main"] = "Principal", ["Backup"] = "Remplaçant", ["Assigned"] = "Assigné",
    ["Tank"] = "Tank", ["Healer"] = "Soigneur", ["Damage"] = "Dégâts",
    ["Warrior"] = "Guerrier", ["Paladin"] = "Paladin", ["Hunter"] = "Chasseur",
    ["Rogue"] = "Voleur", ["Priest"] = "Prêtre", ["Shaman"] = "Chaman",
    ["Mage"] = "Mage", ["Warlock"] = "Démoniste", ["Druid"] = "Druide",
    ["Bloodlust"] = "Furie sanguinaire", ["Heroism"] = "Héroïsme", ["Soulstone"] = "Pierre d’âme",
    ["Innervate"] = "Innervation", ["Misdirection"] = "Détournement",
  },
  esES = {
    ["WoW Sim"] = "WoW Sim", ["T5 Raidpack"] = "Paquete de banda T5",
    ["Delete the selected General Assignments import?\n\n%s"] = "¿Eliminar la importación de asignaciones generales seleccionada?\n\n%s",
    ["Delete the selected recorded raid?\n\n%s"] = "¿Eliminar la banda registrada seleccionada?\n\n%s",
    ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
      "Registra botín raro, épico y legendario en bandas reconocidas. Las mazmorras nunca se registran.",
    ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
      "Exporta solo jugadores de nivel %s para %s con el esquema de plantilla de Guild Manager.",
    ["Language"] = "Idioma", ["Close"] = "Cerrar", ["Raid Settings"] = "Ajustes de banda",
    ["Raid Cooldowns"] = "Tiempos de reutilización de banda",
    ["Assignments"] = "Asignaciones", ["Media"] = "Medios", ["Profiles"] = "Perfiles",
    ["General Assignments"] = "Asignaciones generales", ["Raid Assignments"] = "Asignaciones de banda",
    ["Settings"] = "Ajustes", ["Widget Settings"] = "Ajustes de widgets",
    ["Loot / Roster Export"] = "Exportar botín / plantilla", ["Pre-Boss Groups"] = "Grupos pre-jefe",
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Los grupos pre-jefe aún no están configurados. Esta página está reservada para una actualización futura.",
    ["Import"] = "Importar", ["Broadcast"] = "Transmitir", ["Delete"] = "Eliminar", ["Copy"] = "Copiar",
    ["Generate"] = "Generar", ["Press CTRL+C now"] = "Pulsa CTRL+C ahora",
    ["Select Raid"] = "Seleccionar banda", ["Select a boss"] = "Seleccionar jefe",
    ["Serpentshrine Cavern"] = "Caverna Santuario Serpiente", ["Tempest Keep"] = "El Castillo de la Tempestad",
    ["Black Temple"] = "Templo Oscuro", ["Hyjal Summit"] = "Cima Hyjal",
    ["Select a raid to view WeakAura assignments."] = "Selecciona una banda para ver las asignaciones de WeakAura.",
    ["No WeakAura assignments are available for the selected raid."] =
      "No hay asignaciones de WeakAura disponibles para la banda seleccionada.",
    ["Choose a boss from the list."] = "Elige un jefe de la lista.",
    ["Loot Tracking"] = "Seguimiento de botín", ["Track Loot"] = "Registrar botín",
    ["Recorded Raids"] = "Bandas registradas", ["Items:"] = "Objetos:",
    ["Raid Export"] = "Exportación de banda", ["Guild Export"] = "Exportación de hermandad",
    ["Show Minimap Icon"] = "Mostrar icono del minimapa",
    ["Show Assignment Widget"] = "Mostrar widget de asignaciones",
    ["Show Raid Leader Widget"] = "Mostrar widget del líder de banda",
    ["Assignment Widget"] = "Widget de asignaciones", ["Raid Leader Widget"] = "Widget del líder de banda",
    ["Raid Leader"] = "Líder de banda", ["Header Color"] = "Color del encabezado",
    ["Header Width"] = "Ancho del encabezado", ["Header Height"] = "Alto del encabezado",
    ["Header Opacity"] = "Opacidad del encabezado", ["Header Font"] = "Fuente del encabezado",
    ["Header Title Spacing"] = "Espaciado de letras", ["Show Border"] = "Mostrar borde",
    ["Border Color"] = "Color del borde", ["Border Thickness"] = "Grosor del borde",
    ["Aligning"] = "Alineación", ["Up"] = "Arriba", ["Down"] = "Abajo", ["Left"] = "Izquierda", ["Right"] = "Derecha",
    ["MerfinPlus Version Check"] = "Comprobación de versión de MerfinPlus", ["Player"] = "Jugador",
    ["Scanning group..."] = "Analizando grupo...", ["Done"] = "Listo", ["Refresh"] = "Actualizar",
    ["Players"] = "Jugadores", ["Tank Assignments"] = "Asignaciones de tanques",
    ["Healer Assignments"] = "Asignaciones de sanadores", ["Melee Positions"] = "Posiciones cuerpo a cuerpo",
    ["Ranged Positions"] = "Posiciones a distancia", ["Tank Positions"] = "Posiciones de tanques",
    ["Heal Positions"] = "Posiciones de sanadores", ["Additional Assignments"] = "Asignaciones adicionales",
    ["Main"] = "Principal", ["Backup"] = "Reserva", ["Assigned"] = "Asignado",
    ["Tank"] = "Tanque", ["Healer"] = "Sanador", ["Damage"] = "Daño",
    ["Warrior"] = "Guerrero", ["Paladin"] = "Paladín", ["Hunter"] = "Cazador",
    ["Rogue"] = "Pícaro", ["Priest"] = "Sacerdote", ["Shaman"] = "Chamán",
    ["Mage"] = "Mago", ["Warlock"] = "Brujo", ["Druid"] = "Druida",
    ["Bloodlust"] = "Ansia de sangre", ["Heroism"] = "Heroísmo", ["Soulstone"] = "Piedra de alma",
    ["Innervate"] = "Estimular", ["Misdirection"] = "Redirección",
  },
  esMX = {
    ["WoW Sim"] = "WoW Sim", ["T5 Raidpack"] = "Paquete de banda T5",
    ["Delete the selected General Assignments import?\n\n%s"] = "¿Eliminar la importación de asignaciones generales seleccionada?\n\n%s",
    ["Delete the selected recorded raid?\n\n%s"] = "¿Eliminar la banda registrada seleccionada?\n\n%s",
    ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
      "Registra botín raro, épico y legendario en bandas reconocidas. Las mazmorras nunca se registran.",
    ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
      "Exporta solo jugadores de nivel %s para %s con el esquema de plantilla de Guild Manager.",
    ["Language"] = "Idioma", ["Close"] = "Cerrar", ["Raid Settings"] = "Configuración de banda",
    ["Raid Cooldowns"] = "Tiempos de reutilización de banda",
    ["Assignments"] = "Asignaciones", ["Media"] = "Medios", ["Profiles"] = "Perfiles",
    ["General Assignments"] = "Asignaciones generales", ["Raid Assignments"] = "Asignaciones de banda",
    ["Settings"] = "Configuración", ["Widget Settings"] = "Configuración de widgets",
    ["Loot / Roster Export"] = "Exportar botín / roster", ["Pre-Boss Groups"] = "Grupos previos al jefe",
    ["Import"] = "Importar", ["Broadcast"] = "Transmitir", ["Delete"] = "Eliminar", ["Copy"] = "Copiar",
    ["Generate"] = "Generar", ["Press CTRL+C now"] = "Presiona CTRL+C ahora",
    ["Select Raid"] = "Seleccionar banda", ["Select a boss"] = "Seleccionar jefe",
    ["Serpentshrine Cavern"] = "Caverna Santuario Serpiente", ["Tempest Keep"] = "El Castillo de la Tempestad",
    ["Black Temple"] = "Templo Oscuro", ["Hyjal Summit"] = "Cima Hyjal",
    ["Select a raid to view WeakAura assignments."] = "Selecciona una banda para ver las asignaciones de WeakAura.",
    ["No WeakAura assignments are available for the selected raid."] =
      "No hay asignaciones de WeakAura disponibles para la banda seleccionada.",
    ["Loot Tracking"] = "Seguimiento de botín", ["Track Loot"] = "Registrar botín",
    ["Recorded Raids"] = "Bandas registradas", ["Items:"] = "Objetos:",
    ["Raid Export"] = "Exportación de banda", ["Guild Export"] = "Exportación de hermandad",
    ["Show Minimap Icon"] = "Mostrar ícono del minimapa",
    ["Show Assignment Widget"] = "Mostrar widget de asignaciones",
    ["Show Raid Leader Widget"] = "Mostrar widget del líder de banda",
    ["Assignment Widget"] = "Widget de asignaciones", ["Raid Leader Widget"] = "Widget del líder de banda",
    ["Raid Leader"] = "Líder de banda", ["Header Color"] = "Color del encabezado",
    ["Header Width"] = "Ancho del encabezado", ["Header Height"] = "Alto del encabezado",
    ["Header Opacity"] = "Opacidad del encabezado", ["Header Font"] = "Fuente del encabezado",
    ["Header Title Spacing"] = "Espaciado de letras", ["Show Border"] = "Mostrar borde",
    ["Border Color"] = "Color del borde", ["Border Thickness"] = "Grosor del borde",
    ["Aligning"] = "Alineación", ["Up"] = "Arriba", ["Down"] = "Abajo", ["Left"] = "Izquierda", ["Right"] = "Derecha",
    ["Players"] = "Jugadores", ["Tank Assignments"] = "Asignaciones de tanques",
    ["Healer Assignments"] = "Asignaciones de sanadores", ["Warlock"] = "Brujo",
    ["Warrior"] = "Guerrero", ["Priest"] = "Sacerdote", ["Druid"] = "Druida",
    ["Bloodlust"] = "Ansia de sangre", ["Heroism"] = "Heroísmo",
  },
  ptBR = {
    ["WoW Sim"] = "WoW Sim", ["T5 Raidpack"] = "Pacote de raide T5",
    ["Delete the selected General Assignments import?\n\n%s"] = "Excluir a importação de atribuições gerais selecionada?\n\n%s",
    ["Delete the selected recorded raid?\n\n%s"] = "Excluir o raide registrado selecionado?\n\n%s",
    ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
      "Registra saques raros, épicos e lendários em raides reconhecidos. Masmorras nunca são registradas.",
    ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
      "Exporta somente jogadores de nível %s para %s usando o esquema de elenco do Guild Manager.",
    ["Assignment Background Opacity"] = "Opacidade do fundo das atribuições",
    ["Header Title X Offset"] = "Deslocamento X do título", ["Header Title Y Offset"] = "Deslocamento Y do título",
    ["Header Title Size"] = "Tamanho do título", ["Header Icon X Offset"] = "Deslocamento X do ícone",
    ["Header Icon Y Offset"] = "Deslocamento Y do ícone", ["Header Icon Size"] = "Tamanho do ícone",
    ["Show Icon Logo"] = "Mostrar logotipo",
    ["Language"] = "Idioma", ["Close"] = "Fechar", ["Raid Settings"] = "Configurações de raide",
    ["Raid Cooldowns"] = "Recargas de raide",
    ["Assignments"] = "Atribuições", ["Media"] = "Mídia", ["Profiles"] = "Perfis",
    ["General Assignments"] = "Atribuições gerais", ["Raid Assignments"] = "Atribuições de raide",
    ["Settings"] = "Configurações", ["Widget Settings"] = "Configurações dos widgets",
    ["Loot / Roster Export"] = "Exportar saque / elenco", ["Pre-Boss Groups"] = "Grupos pré-chefe",
    ["Import"] = "Importar", ["Broadcast"] = "Transmitir", ["Delete"] = "Excluir", ["Copy"] = "Copiar",
    ["Generate"] = "Gerar", ["Press CTRL+C now"] = "Pressione CTRL+C agora",
    ["Select Raid"] = "Selecionar raide", ["Select a boss"] = "Selecionar chefe",
    ["Serpentshrine Cavern"] = "Caverna do Serpentário", ["Tempest Keep"] = "Bastilha da Tormenta",
    ["Black Temple"] = "Templo Negro", ["Hyjal Summit"] = "Pico Hyjal",
    ["Select a raid to view WeakAura assignments."] = "Selecione um raide para ver as atribuições de WeakAura.",
    ["No WeakAura assignments are available for the selected raid."] =
      "Nenhuma atribuição de WeakAura está disponível para o raide selecionado.",
    ["Loot Tracking"] = "Rastreamento de saque", ["Track Loot"] = "Rastrear saque",
    ["Recorded Raids"] = "Raides registrados", ["Items:"] = "Itens:",
    ["Raid Export"] = "Exportação de raide", ["Guild Export"] = "Exportação da guilda",
    ["Show Minimap Icon"] = "Mostrar ícone do minimapa",
    ["Show Assignment Widget"] = "Mostrar widget de atribuições",
    ["Show Raid Leader Widget"] = "Mostrar widget do líder do raide",
    ["Assignment Widget"] = "Widget de atribuições", ["Raid Leader Widget"] = "Widget do líder do raide",
    ["Raid Leader"] = "Líder do raide", ["Header Color"] = "Cor do cabeçalho",
    ["Header Width"] = "Largura do cabeçalho", ["Header Height"] = "Altura do cabeçalho",
    ["Header Opacity"] = "Opacidade do cabeçalho", ["Header Font"] = "Fonte do cabeçalho",
    ["Header Title Spacing"] = "Espaçamento das letras", ["Show Border"] = "Mostrar borda",
    ["Border Color"] = "Cor da borda", ["Border Thickness"] = "Espessura da borda",
    ["Aligning"] = "Alinhamento", ["Up"] = "Acima", ["Down"] = "Abaixo", ["Left"] = "Esquerda", ["Right"] = "Direita",
    ["Players"] = "Jogadores", ["Tank Assignments"] = "Atribuições de tanques",
    ["Healer Assignments"] = "Atribuições de curadores", ["Tank"] = "Tanque", ["Healer"] = "Curador",
    ["Warrior"] = "Guerreiro", ["Paladin"] = "Paladino", ["Hunter"] = "Caçador",
    ["Rogue"] = "Ladino", ["Priest"] = "Sacerdote", ["Shaman"] = "Xamã",
    ["Mage"] = "Mago", ["Warlock"] = "Bruxo", ["Druid"] = "Druida",
    ["Bloodlust"] = "Sede de Sangue", ["Heroism"] = "Heroísmo",
  },
  itIT = {
    ["WoW Sim"] = "WoW Sim", ["T5 Raidpack"] = "Pacchetto incursione T5",
    ["Delete the selected General Assignments import?\n\n%s"] = "Eliminare l’importazione di assegnazioni generali selezionata?\n\n%s",
    ["Delete the selected recorded raid?\n\n%s"] = "Eliminare l’incursione registrata selezionata?\n\n%s",
    ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
      "Registra bottino raro, epico e leggendario nelle incursioni riconosciute. Le spedizioni non vengono mai registrate.",
    ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
      "Esporta solo giocatori di livello %s per %s usando lo schema roster di Guild Manager.",
    ["Assignment Background Opacity"] = "Opacità sfondo assegnazioni",
    ["Header Title X Offset"] = "Spostamento X del titolo", ["Header Title Y Offset"] = "Spostamento Y del titolo",
    ["Header Title Size"] = "Dimensione del titolo", ["Header Icon X Offset"] = "Spostamento X dell’icona",
    ["Header Icon Y Offset"] = "Spostamento Y dell’icona", ["Header Icon Size"] = "Dimensione dell’icona",
    ["Show Icon Logo"] = "Mostra logo",
    ["Language"] = "Lingua", ["Close"] = "Chiudi", ["Raid Settings"] = "Impostazioni incursione",
    ["Raid Cooldowns"] = "Tempi di recupero dell'incursione",
    ["Assignments"] = "Assegnazioni", ["Media"] = "Media", ["Profiles"] = "Profili",
    ["General Assignments"] = "Assegnazioni generali", ["Raid Assignments"] = "Assegnazioni incursione",
    ["Settings"] = "Impostazioni", ["Widget Settings"] = "Impostazioni widget",
    ["Loot / Roster Export"] = "Esporta bottino / roster", ["Pre-Boss Groups"] = "Gruppi pre-boss",
    ["Import"] = "Importa", ["Broadcast"] = "Trasmetti", ["Delete"] = "Elimina", ["Copy"] = "Copia",
    ["Generate"] = "Genera", ["Press CTRL+C now"] = "Premi CTRL+C ora",
    ["Select Raid"] = "Seleziona incursione", ["Select a boss"] = "Seleziona boss",
    ["Serpentshrine Cavern"] = "Grotta Serpe", ["Tempest Keep"] = "Forte Tempesta",
    ["Black Temple"] = "Tempio Nero", ["Hyjal Summit"] = "Vetta di Hyjal",
    ["Select a raid to view WeakAura assignments."] = "Seleziona un’incursione per vedere le assegnazioni WeakAura.",
    ["No WeakAura assignments are available for the selected raid."] =
      "Non sono disponibili assegnazioni WeakAura per l’incursione selezionata.",
    ["Loot Tracking"] = "Tracciamento bottino", ["Track Loot"] = "Traccia bottino",
    ["Recorded Raids"] = "Incursioni registrate", ["Items:"] = "Oggetti:",
    ["Raid Export"] = "Esportazione incursione", ["Guild Export"] = "Esportazione gilda",
    ["Show Minimap Icon"] = "Mostra icona minimappa",
    ["Show Assignment Widget"] = "Mostra widget assegnazioni",
    ["Show Raid Leader Widget"] = "Mostra widget capoincursione",
    ["Assignment Widget"] = "Widget assegnazioni", ["Raid Leader Widget"] = "Widget capoincursione",
    ["Raid Leader"] = "Capoincursione", ["Header Color"] = "Colore intestazione",
    ["Header Width"] = "Larghezza intestazione", ["Header Height"] = "Altezza intestazione",
    ["Header Opacity"] = "Opacità intestazione", ["Header Font"] = "Carattere intestazione",
    ["Header Title Spacing"] = "Spaziatura lettere", ["Show Border"] = "Mostra bordo",
    ["Border Color"] = "Colore bordo", ["Border Thickness"] = "Spessore bordo",
    ["Aligning"] = "Allineamento", ["Up"] = "Su", ["Down"] = "Giù", ["Left"] = "Sinistra", ["Right"] = "Destra",
    ["Players"] = "Giocatori", ["Tank Assignments"] = "Assegnazioni tank",
    ["Healer Assignments"] = "Assegnazioni guaritori", ["Tank"] = "Tank", ["Healer"] = "Guaritore",
    ["Warrior"] = "Guerriero", ["Paladin"] = "Paladino", ["Hunter"] = "Cacciatore",
    ["Rogue"] = "Ladro", ["Priest"] = "Sacerdote", ["Shaman"] = "Sciamano",
    ["Mage"] = "Mago", ["Warlock"] = "Stregone", ["Druid"] = "Druido",
    ["Bloodlust"] = "Brama di Sangue", ["Heroism"] = "Eroismo",
  },
  ruRU = {
    ["WoW Sim"] = "WoW Sim", ["T5 Raidpack"] = "Рейд-пакет T5",
    ["Delete the selected General Assignments import?\n\n%s"] = "Удалить выбранный импорт общих назначений?\n\n%s",
    ["Delete the selected recorded raid?\n\n%s"] = "Удалить выбранный записанный рейд?\n\n%s",
    ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
      "Записывает редкую, эпическую и легендарную добычу в распознанных рейдах. Подземелья не отслеживаются.",
    ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
      "Экспортирует только игроков %s-го уровня для %s по схеме состава Guild Manager.",
    ["Assignment Background Opacity"] = "Прозрачность фона назначений",
    ["Header Title X Offset"] = "Смещение заголовка по X", ["Header Title Y Offset"] = "Смещение заголовка по Y",
    ["Header Title Size"] = "Размер заголовка", ["Header Icon X Offset"] = "Смещение значка по X",
    ["Header Icon Y Offset"] = "Смещение значка по Y", ["Header Icon Size"] = "Размер значка",
    ["Show Icon Logo"] = "Показывать логотип",
    ["Language"] = "Язык", ["Close"] = "Закрыть", ["Raid Settings"] = "Настройки рейда",
    ["Raid Cooldowns"] = "Рейдовые восстановления",
    ["Assignments"] = "Назначения", ["Media"] = "Медиа", ["Profiles"] = "Профили",
    ["General Assignments"] = "Общие назначения", ["Raid Assignments"] = "Рейдовые назначения",
    ["Settings"] = "Настройки", ["Widget Settings"] = "Настройки виджетов",
    ["Loot / Roster Export"] = "Экспорт добычи / состава", ["Pre-Boss Groups"] = "Группы перед боссом",
    ["Import"] = "Импорт", ["Broadcast"] = "Отправить", ["Delete"] = "Удалить", ["Copy"] = "Копировать",
    ["Generate"] = "Создать", ["Press CTRL+C now"] = "Нажмите CTRL+C",
    ["Select Raid"] = "Выберите рейд", ["Select a boss"] = "Выберите босса",
    ["Serpentshrine Cavern"] = "Змеиное святилище", ["Tempest Keep"] = "Крепость Бурь",
    ["Black Temple"] = "Чёрный храм", ["Hyjal Summit"] = "Вершина Хиджала",
    ["Select a raid to view WeakAura assignments."] = "Выберите рейд, чтобы просмотреть назначения WeakAura.",
    ["No WeakAura assignments are available for the selected raid."] =
      "Для выбранного рейда нет доступных назначений WeakAura.",
    ["Loot Tracking"] = "Учёт добычи", ["Track Loot"] = "Учитывать добычу",
    ["Recorded Raids"] = "Записанные рейды", ["Items:"] = "Предметы:",
    ["Raid Export"] = "Экспорт рейда", ["Guild Export"] = "Экспорт гильдии",
    ["Show Minimap Icon"] = "Показывать значок миникарты",
    ["Show Assignment Widget"] = "Показывать виджет назначений",
    ["Show Raid Leader Widget"] = "Показывать виджет рейд-лидера",
    ["Assignment Widget"] = "Виджет назначений", ["Raid Leader Widget"] = "Виджет рейд-лидера",
    ["Raid Leader"] = "Рейд-лидер", ["Header Color"] = "Цвет заголовка",
    ["Header Width"] = "Ширина заголовка", ["Header Height"] = "Высота заголовка",
    ["Header Opacity"] = "Прозрачность заголовка", ["Header Font"] = "Шрифт заголовка",
    ["Header Title Spacing"] = "Интервал между буквами", ["Show Border"] = "Показывать рамку",
    ["Border Color"] = "Цвет рамки", ["Border Thickness"] = "Толщина рамки",
    ["Aligning"] = "Выравнивание", ["Up"] = "Вверх", ["Down"] = "Вниз", ["Left"] = "Влево", ["Right"] = "Вправо",
    ["MerfinPlus Version Check"] = "Проверка версии MerfinPlus", ["Player"] = "Игрок",
    ["Scanning group..."] = "Проверка группы...", ["Done"] = "Готово", ["Refresh"] = "Обновить",
    ["Players"] = "Игроки", ["Tank Assignments"] = "Назначения танков",
    ["Healer Assignments"] = "Назначения лекарей", ["Melee Positions"] = "Позиции ближнего боя",
    ["Ranged Positions"] = "Позиции дальнего боя", ["Tank Positions"] = "Позиции танков",
    ["Heal Positions"] = "Позиции лекарей", ["Additional Assignments"] = "Дополнительные назначения",
    ["Main"] = "Основной", ["Backup"] = "Резерв", ["Assigned"] = "Назначено",
    ["Tank"] = "Танк", ["Healer"] = "Лекарь", ["Damage"] = "Урон",
    ["Warrior"] = "Воин", ["Paladin"] = "Паладин", ["Hunter"] = "Охотник",
    ["Rogue"] = "Разбойник", ["Priest"] = "Жрец", ["Shaman"] = "Шаман",
    ["Mage"] = "Маг", ["Warlock"] = "Чернокнижник", ["Druid"] = "Друид",
    ["Bloodlust"] = "Жажда крови", ["Heroism"] = "Героизм", ["Soulstone"] = "Камень души",
    ["Innervate"] = "Озарение", ["Misdirection"] = "Перенаправление",
  },
  zhCN = {},
  zhTW = {},
  koKR = {},
  jaJP = {},
}

local cjkTranslations = MerfinPlus.CJKTranslations or {}
for _, locale in ipairs({ "zhCN", "zhTW", "koKR", "jaJP" }) do
  for key, value in pairs(cjkTranslations[locale] or {}) do
    overrides[locale][key] = value
  end
end

local raidCooldownTranslations = {
  deDE = {
    ["The Burning Crusade"] = "The Burning Crusade",
    ["General Settings"] = "Allgemeine Einstellungen",
    ["Detected Expansion"] = "Erkannte Erweiterung",
    ["Select Your Aura"] = "Wähle deine Aura",
    ["Enable/Disable"] = "Aktivieren/Deaktivieren",
    ["Send Message on Click"] = "Nachricht beim Klicken senden",
    ["Display Settings"] = "Anzeigeeinstellungen",
    ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
      "Dies sind die Standard-Anzeigefilter des Raid-Cooldown-Frontends. Weitere Leistenstile bleiben in WeakAuras.",
    ["Show Yourself"] = "Dich selbst anzeigen",
    ["Show When Ready"] = "Anzeigen, wenn bereit",
    ["Show When Dead"] = "Anzeigen, wenn tot",
    ["Show When Offline"] = "Anzeigen, wenn offline",
    ["Show Buff Duration"] = "Buffdauer anzeigen",
    ["Show Ready Indicator"] = "Bereit-Anzeige anzeigen",
    ["Dead Color"] = "Farbe für Tote",
    ["Raid Subgroups"] = "Raid-Untergruppen",
    ["Advanced Spell Settings"] = "Erweiterte Zaubereinstellungen",
    ["Specialization Display"] = "Spezialisierungsanzeige",
    ["Select Spell"] = "Zauber auswählen",
    ["Add Spell"] = "Zauber hinzufügen",
    ["Delete Spell"] = "Zauber löschen",
    ["Selected Spell"] = "Ausgewählter Zauber",
    ["Spell Name (Optional)"] = "Zaubername (optional)",
    ["Spell ID (Required)"] = "Zauber-ID (erforderlich)",
    ["Spell ID"] = "Zauber-ID",
    ["A positive spell ID is required."] = "Eine positive Zauber-ID ist erforderlich.",
    ["Show DPS"] = "Schadensklassen anzeigen",
    ["Show Tanks"] = "Tanks anzeigen",
    ["Show Healers"] = "Heiler anzeigen",
    ["Spell Order"] = "Zauberreihenfolge",
    ["Index"] = "Index",
    ["Cooldown Activation"] = "Cooldown-Aktivierung",
    ["Enable cooldowns by class. Expand a class to configure individual spells."] =
      "Aktiviere Cooldowns nach Klasse. Klappe eine Klasse auf, um einzelne Zauber zu konfigurieren.",
    ["Expand"] = "Aufklappen",
    ["Collapse"] = "Einklappen",
    ["No Raid Cooldown configuration is available for this expansion."] =
      "Für diese Erweiterung ist keine Raid-Cooldown-Konfiguration verfügbar.",
  },
  frFR = {
    ["The Burning Crusade"] = "The Burning Crusade",
    ["General Settings"] = "Paramètres généraux",
    ["Detected Expansion"] = "Extension détectée",
    ["Select Your Aura"] = "Sélectionnez votre aura",
    ["Enable/Disable"] = "Activer/Désactiver",
    ["Send Message on Click"] = "Envoyer un message au clic",
    ["Display Settings"] = "Paramètres d’affichage",
    ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
      "Ce sont les filtres d’affichage standard du module Raid Cooldown. Le style des barres reste configuré dans WeakAuras.",
    ["Show Yourself"] = "Vous afficher",
    ["Show When Ready"] = "Afficher quand prêt",
    ["Show When Dead"] = "Afficher quand mort",
    ["Show When Offline"] = "Afficher hors ligne",
    ["Show Buff Duration"] = "Afficher la durée du bonus",
    ["Show Ready Indicator"] = "Afficher l’indicateur Prêt",
    ["Dead Color"] = "Couleur des morts",
    ["Raid Subgroups"] = "Sous-groupes de raid",
    ["Advanced Spell Settings"] = "Paramètres avancés des sorts",
    ["Specialization Display"] = "Affichage par spécialisation",
    ["Select Spell"] = "Sélectionner un sort",
    ["Add Spell"] = "Ajouter un sort",
    ["Delete Spell"] = "Supprimer le sort",
    ["Selected Spell"] = "Sort sélectionné",
    ["Spell Name (Optional)"] = "Nom du sort (facultatif)",
    ["Spell ID (Required)"] = "ID du sort (requis)",
    ["Spell ID"] = "ID du sort",
    ["A positive spell ID is required."] = "Un ID de sort positif est requis.",
    ["Show DPS"] = "Afficher les DPS",
    ["Show Tanks"] = "Afficher les tanks",
    ["Show Healers"] = "Afficher les soigneurs",
    ["Spell Order"] = "Ordre des sorts",
    ["Index"] = "Index",
    ["Cooldown Activation"] = "Activation des temps de recharge",
    ["Enable cooldowns by class. Expand a class to configure individual spells."] =
      "Activez les temps de recharge par classe. Développez une classe pour configurer ses sorts.",
    ["Expand"] = "Développer",
    ["Collapse"] = "Réduire",
    ["No Raid Cooldown configuration is available for this expansion."] =
      "Aucune configuration de temps de recharge de raid n’est disponible pour cette extension.",
  },
  esES = {
    ["The Burning Crusade"] = "The Burning Crusade",
    ["General Settings"] = "Ajustes generales",
    ["Detected Expansion"] = "Expansión detectada",
    ["Select Your Aura"] = "Selecciona tu aura",
    ["Enable/Disable"] = "Activar/Desactivar",
    ["Send Message on Click"] = "Enviar mensaje al hacer clic",
    ["Display Settings"] = "Ajustes de visualización",
    ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
      "Estos son los filtros de visualización estándar del módulo de reutilizaciones. El estilo adicional de barras permanece en WeakAuras.",
    ["Show Yourself"] = "Mostrarte",
    ["Show When Ready"] = "Mostrar cuando esté listo",
    ["Show When Dead"] = "Mostrar al morir",
    ["Show When Offline"] = "Mostrar sin conexión",
    ["Show Buff Duration"] = "Mostrar duración del beneficio",
    ["Show Ready Indicator"] = "Mostrar indicador de listo",
    ["Dead Color"] = "Color de muerto",
    ["Raid Subgroups"] = "Subgrupos de banda",
    ["Advanced Spell Settings"] = "Ajustes avanzados de hechizos",
    ["Specialization Display"] = "Visualización por especialización",
    ["Select Spell"] = "Seleccionar hechizo",
    ["Add Spell"] = "Añadir hechizo",
    ["Delete Spell"] = "Eliminar hechizo",
    ["Selected Spell"] = "Hechizo seleccionado",
    ["Spell Name (Optional)"] = "Nombre del hechizo (opcional)",
    ["Spell ID (Required)"] = "ID del hechizo (obligatorio)",
    ["Spell ID"] = "ID del hechizo",
    ["A positive spell ID is required."] = "Se requiere un ID de hechizo positivo.",
    ["Show DPS"] = "Mostrar DPS",
    ["Show Tanks"] = "Mostrar tanques",
    ["Show Healers"] = "Mostrar sanadores",
    ["Spell Order"] = "Orden de hechizos",
    ["Index"] = "Índice",
    ["Cooldown Activation"] = "Activación de reutilizaciones",
    ["Enable cooldowns by class. Expand a class to configure individual spells."] =
      "Activa reutilizaciones por clase. Despliega una clase para configurar hechizos individuales.",
    ["Expand"] = "Desplegar",
    ["Collapse"] = "Contraer",
    ["No Raid Cooldown configuration is available for this expansion."] =
      "No hay una configuración de reutilizaciones de banda para esta expansión.",
  },
  esMX = {
    ["The Burning Crusade"] = "The Burning Crusade",
    ["General Settings"] = "Configuración general",
    ["Detected Expansion"] = "Expansión detectada",
    ["Select Your Aura"] = "Selecciona tu aura",
    ["Enable/Disable"] = "Activar/Desactivar",
    ["Send Message on Click"] = "Enviar mensaje al hacer clic",
    ["Display Settings"] = "Configuración de visualización",
    ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
      "Estos son los filtros de visualización estándar del módulo de reutilizaciones. El estilo adicional de barras permanece en WeakAuras.",
    ["Show Yourself"] = "Mostrarte",
    ["Show When Ready"] = "Mostrar cuando esté listo",
    ["Show When Dead"] = "Mostrar al morir",
    ["Show When Offline"] = "Mostrar sin conexión",
    ["Show Buff Duration"] = "Mostrar duración del beneficio",
    ["Show Ready Indicator"] = "Mostrar indicador de listo",
    ["Dead Color"] = "Color de muerto",
    ["Raid Subgroups"] = "Subgrupos de banda",
    ["Advanced Spell Settings"] = "Configuración avanzada de hechizos",
    ["Specialization Display"] = "Visualización por especialización",
    ["Select Spell"] = "Seleccionar hechizo",
    ["Add Spell"] = "Agregar hechizo",
    ["Delete Spell"] = "Eliminar hechizo",
    ["Selected Spell"] = "Hechizo seleccionado",
    ["Spell Name (Optional)"] = "Nombre del hechizo (opcional)",
    ["Spell ID (Required)"] = "ID del hechizo (obligatorio)",
    ["Spell ID"] = "ID del hechizo",
    ["A positive spell ID is required."] = "Se requiere un ID de hechizo positivo.",
    ["Show DPS"] = "Mostrar DPS",
    ["Show Tanks"] = "Mostrar tanques",
    ["Show Healers"] = "Mostrar sanadores",
    ["Spell Order"] = "Orden de hechizos",
    ["Index"] = "Índice",
    ["Cooldown Activation"] = "Activación de reutilizaciones",
    ["Enable cooldowns by class. Expand a class to configure individual spells."] =
      "Activa reutilizaciones por clase. Expande una clase para configurar hechizos individuales.",
    ["Expand"] = "Expandir",
    ["Collapse"] = "Contraer",
    ["No Raid Cooldown configuration is available for this expansion."] =
      "No hay una configuración de reutilizaciones de banda para esta expansión.",
  },
  ptBR = {
    ["The Burning Crusade"] = "The Burning Crusade",
    ["General Settings"] = "Configurações gerais",
    ["Detected Expansion"] = "Expansão detectada",
    ["Select Your Aura"] = "Selecione sua aura",
    ["Enable/Disable"] = "Ativar/Desativar",
    ["Send Message on Click"] = "Enviar mensagem ao clicar",
    ["Display Settings"] = "Configurações de exibição",
    ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
      "Estes são os filtros de exibição padrão do módulo de recargas. O estilo adicional das barras permanece no WeakAuras.",
    ["Show Yourself"] = "Mostrar você",
    ["Show When Ready"] = "Mostrar quando pronto",
    ["Show When Dead"] = "Mostrar quando morto",
    ["Show When Offline"] = "Mostrar quando offline",
    ["Show Buff Duration"] = "Mostrar duração do bônus",
    ["Show Ready Indicator"] = "Mostrar indicador de pronto",
    ["Dead Color"] = "Cor de morto",
    ["Raid Subgroups"] = "Subgrupos de raide",
    ["Advanced Spell Settings"] = "Configurações avançadas de feitiços",
    ["Specialization Display"] = "Exibição por especialização",
    ["Select Spell"] = "Selecionar feitiço",
    ["Add Spell"] = "Adicionar feitiço",
    ["Delete Spell"] = "Excluir feitiço",
    ["Selected Spell"] = "Feitiço selecionado",
    ["Spell Name (Optional)"] = "Nome do feitiço (opcional)",
    ["Spell ID (Required)"] = "ID do feitiço (obrigatório)",
    ["Spell ID"] = "ID do feitiço",
    ["A positive spell ID is required."] = "É necessário um ID de feitiço positivo.",
    ["Show DPS"] = "Mostrar DPS",
    ["Show Tanks"] = "Mostrar tanques",
    ["Show Healers"] = "Mostrar curadores",
    ["Spell Order"] = "Ordem dos feitiços",
    ["Index"] = "Índice",
    ["Cooldown Activation"] = "Ativação de recargas",
    ["Enable cooldowns by class. Expand a class to configure individual spells."] =
      "Ative recargas por classe. Expanda uma classe para configurar feitiços individuais.",
    ["Expand"] = "Expandir",
    ["Collapse"] = "Recolher",
    ["No Raid Cooldown configuration is available for this expansion."] =
      "Não há configuração de recargas de raide disponível para esta expansão.",
  },
  itIT = {
    ["The Burning Crusade"] = "The Burning Crusade",
    ["General Settings"] = "Impostazioni generali",
    ["Detected Expansion"] = "Espansione rilevata",
    ["Select Your Aura"] = "Seleziona la tua aura",
    ["Enable/Disable"] = "Attiva/Disattiva",
    ["Send Message on Click"] = "Invia messaggio al clic",
    ["Display Settings"] = "Impostazioni di visualizzazione",
    ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
      "Questi sono i filtri di visualizzazione standard del modulo dei recuperi. Lo stile aggiuntivo delle barre resta in WeakAuras.",
    ["Show Yourself"] = "Mostra te stesso",
    ["Show When Ready"] = "Mostra quando pronto",
    ["Show When Dead"] = "Mostra quando morto",
    ["Show When Offline"] = "Mostra quando offline",
    ["Show Buff Duration"] = "Mostra durata beneficio",
    ["Show Ready Indicator"] = "Mostra indicatore pronto",
    ["Dead Color"] = "Colore dei morti",
    ["Raid Subgroups"] = "Sottogruppi incursione",
    ["Advanced Spell Settings"] = "Impostazioni avanzate degli incantesimi",
    ["Specialization Display"] = "Visualizzazione specializzazione",
    ["Select Spell"] = "Seleziona incantesimo",
    ["Add Spell"] = "Aggiungi incantesimo",
    ["Delete Spell"] = "Elimina incantesimo",
    ["Selected Spell"] = "Incantesimo selezionato",
    ["Spell Name (Optional)"] = "Nome incantesimo (facoltativo)",
    ["Spell ID (Required)"] = "ID incantesimo (obbligatorio)",
    ["Spell ID"] = "ID incantesimo",
    ["A positive spell ID is required."] = "È richiesto un ID incantesimo positivo.",
    ["Show DPS"] = "Mostra DPS",
    ["Show Tanks"] = "Mostra difensori",
    ["Show Healers"] = "Mostra guaritori",
    ["Spell Order"] = "Ordine degli incantesimi",
    ["Index"] = "Indice",
    ["Cooldown Activation"] = "Attivazione recuperi",
    ["Enable cooldowns by class. Expand a class to configure individual spells."] =
      "Attiva i recuperi per classe. Espandi una classe per configurare i singoli incantesimi.",
    ["Expand"] = "Espandi",
    ["Collapse"] = "Comprimi",
    ["No Raid Cooldown configuration is available for this expansion."] =
      "Nessuna configurazione dei recuperi da incursione è disponibile per questa espansione.",
  },
  ruRU = {
    ["The Burning Crusade"] = "The Burning Crusade",
    ["General Settings"] = "Общие настройки",
    ["Detected Expansion"] = "Обнаруженное дополнение",
    ["Select Your Aura"] = "Выберите ауру",
    ["Enable/Disable"] = "Включить/Отключить",
    ["Send Message on Click"] = "Отправлять сообщение по щелчку",
    ["Display Settings"] = "Настройки отображения",
    ["These are the standard display filters used by the Raid Cooldown frontend. Additional bar styling remains in WeakAuras."] =
      "Это стандартные фильтры отображения модуля рейдовых восстановлений. Дополнительное оформление полос остаётся в WeakAuras.",
    ["Show Yourself"] = "Показывать себя",
    ["Show When Ready"] = "Показывать готовые",
    ["Show When Dead"] = "Показывать мёртвых",
    ["Show When Offline"] = "Показывать вне сети",
    ["Show Buff Duration"] = "Показывать длительность эффекта",
    ["Show Ready Indicator"] = "Показывать индикатор готовности",
    ["Dead Color"] = "Цвет мёртвых",
    ["Raid Subgroups"] = "Подгруппы рейда",
    ["Advanced Spell Settings"] = "Расширенные настройки заклинаний",
    ["Specialization Display"] = "Отображение по специализации",
    ["Select Spell"] = "Выбрать заклинание",
    ["Add Spell"] = "Добавить заклинание",
    ["Delete Spell"] = "Удалить заклинание",
    ["Selected Spell"] = "Выбранное заклинание",
    ["Spell Name (Optional)"] = "Название заклинания (необязательно)",
    ["Spell ID (Required)"] = "ID заклинания (обязательно)",
    ["Spell ID"] = "ID заклинания",
    ["A positive spell ID is required."] = "Требуется положительный ID заклинания.",
    ["Show DPS"] = "Показывать бойцов",
    ["Show Tanks"] = "Показывать танков",
    ["Show Healers"] = "Показывать лекарей",
    ["Spell Order"] = "Порядок заклинаний",
    ["Index"] = "Индекс",
    ["Cooldown Activation"] = "Активация восстановлений",
    ["Enable cooldowns by class. Expand a class to configure individual spells."] =
      "Включайте восстановления по классам. Разверните класс для настройки отдельных заклинаний.",
    ["Expand"] = "Развернуть",
    ["Collapse"] = "Свернуть",
    ["No Raid Cooldown configuration is available for this expansion."] =
      "Для этого дополнения нет конфигурации рейдовых восстановлений.",
  },
}
for locale, entries in pairs(raidCooldownTranslations) do
  for key, value in pairs(entries) do
    overrides[locale][key] = value
  end
end

local extraTranslations = {
  deDE = {
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Pre-Boss-Gruppen sind noch nicht konfiguriert. Diese Seite ist für eine zukünftige Erweiterung reserviert.",
    ["Left-click to open settings"] = "Linksklick öffnet die Einstellungen",
    ["Drag to move"] = "Ziehen zum Verschieben",
    ["Cancel"] = "Abbrechen",
    ["Record rare, epic, and legendary loot in recognized raids. Dungeons are never tracked."] =
      "Erfasst seltene, epische und legendäre Beute in erkannten Raids. Dungeons werden nie erfasst.",
    ["Exports only level %s players for %s, using the Guild Manager roster schema."] =
      "Exportiert nur Spieler auf Stufe %s für %s nach dem Guild-Manager-Rosterschema.",
  },
  frFR = {
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Les groupes pré-boss ne sont pas encore configurés. Cette page est réservée à une future mise à jour.",
    ["Left-click to open settings"] = "Clic gauche pour ouvrir les paramètres",
    ["Drag to move"] = "Faire glisser pour déplacer",
    ["Cancel"] = "Annuler",
    ["Export"] = "Export", ["No imported assignments exist for this boss."] = "Aucune affectation importée pour ce boss.",
    ["No General Assignments imports saved."] = "Aucun import d’affectations générales enregistré.",
    ["The selected import could not be parsed."] = "L’import sélectionné n’a pas pu être analysé.",
    ["Invalid General Assignments string."] = "Chaîne d’affectations générales invalide.",
    ["Invalid Raid Assignments string."] = "Chaîne d’affectations de raid invalide.",
    ["Identical import already exists; selected the saved import."] = "Un import identique existe déjà ; l’import enregistré a été sélectionné.",
    ["General Assignments import saved."] = "Import d’affectations générales enregistré.",
    ["Raid Assignments import saved."] = "Import d’affectations de raid enregistré.",
    ["Detected expansion: %s"] = "Extension détectée : %s",
    ["Assignment Widget Visibility"] = "Visibilité du widget d’affectations",
    ["Raid Leader Widget Visibility"] = "Visibilité du widget du chef de raid",
    ["Assignment: Show always"] = "Affectations : toujours afficher",
    ["Assignment: Load only in Raid"] = "Affectations : charger uniquement en raid",
    ["Raid Leader: Show always"] = "Chef de raid : toujours afficher",
    ["Raid Leader: Load only in Raid"] = "Chef de raid : charger uniquement en raid",
    ["Assignment Background Opacity"] = "Opacité de l’arrière-plan des affectations",
    ["Header Title X Offset"] = "Décalage X du titre", ["Header Title Y Offset"] = "Décalage Y du titre",
    ["Header Title Size"] = "Taille du titre", ["Header Icon X Offset"] = "Décalage X de l’icône",
    ["Header Icon Y Offset"] = "Décalage Y de l’icône", ["Header Icon Size"] = "Taille de l’icône",
    ["Show Icon Logo"] = "Afficher le logo", ["Commands:"] = "Commandes :",
    ["Main Target"] = "Cible principale", ["Off Target"] = "Cible secondaire",
    ["Star"] = "Étoile", ["Circle"] = "Cercle", ["Diamond"] = "Losange", ["Triangle"] = "Triangle",
    ["Moon"] = "Lune", ["Square"] = "Carré", ["Cross"] = "Croix", ["Skull"] = "Crâne",
  },
  esES = {
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Los grupos pre-jefe aún no están configurados. Esta página queda reservada para una futura actualización.",
    ["Left-click to open settings"] = "Clic izquierdo para abrir los ajustes",
    ["Drag to move"] = "Arrastra para mover",
    ["Cancel"] = "Cancelar",
    ["Export"] = "Exportar", ["No imported assignments exist for this boss."] = "No hay asignaciones importadas para este jefe.",
    ["No General Assignments imports saved."] = "No hay importaciones de asignaciones generales guardadas.",
    ["The selected import could not be parsed."] = "No se pudo analizar la importación seleccionada.",
    ["Invalid General Assignments string."] = "Cadena de asignaciones generales no válida.",
    ["Invalid Raid Assignments string."] = "Cadena de asignaciones de banda no válida.",
    ["Identical import already exists; selected the saved import."] = "Ya existe una importación idéntica; se seleccionó la guardada.",
    ["General Assignments import saved."] = "Importación de asignaciones generales guardada.",
    ["Raid Assignments import saved."] = "Importación de asignaciones de banda guardada.",
    ["Detected expansion: %s"] = "Expansión detectada: %s",
    ["Assignment Widget Visibility"] = "Visibilidad del widget de asignaciones",
    ["Raid Leader Widget Visibility"] = "Visibilidad del widget del líder de banda",
    ["Assignment: Show always"] = "Asignaciones: mostrar siempre",
    ["Assignment: Load only in Raid"] = "Asignaciones: cargar solo en banda",
    ["Raid Leader: Show always"] = "Líder de banda: mostrar siempre",
    ["Raid Leader: Load only in Raid"] = "Líder de banda: cargar solo en banda",
    ["Assignment Background Opacity"] = "Opacidad del fondo de asignaciones",
    ["Header Title X Offset"] = "Desplazamiento X del título", ["Header Title Y Offset"] = "Desplazamiento Y del título",
    ["Header Title Size"] = "Tamaño del título", ["Header Icon X Offset"] = "Desplazamiento X del icono",
    ["Header Icon Y Offset"] = "Desplazamiento Y del icono", ["Header Icon Size"] = "Tamaño del icono",
    ["Show Icon Logo"] = "Mostrar logotipo", ["Commands:"] = "Comandos:",
    ["Main Target"] = "Objetivo principal", ["Off Target"] = "Objetivo secundario",
    ["Star"] = "Estrella", ["Circle"] = "Círculo", ["Diamond"] = "Diamante", ["Triangle"] = "Triángulo",
    ["Moon"] = "Luna", ["Square"] = "Cuadrado", ["Cross"] = "Cruz", ["Skull"] = "Calavera",
  },
  esMX = {
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Los grupos previos al jefe aún no están configurados. Esta página está reservada para una futura actualización.",
    ["Left-click to open settings"] = "Clic izquierdo para abrir la configuración",
    ["Drag to move"] = "Arrastra para mover",
    ["Cancel"] = "Cancelar",
  },
  ptBR = {
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Os grupos pré-chefe ainda não estão configurados. Esta página está reservada para uma atualização futura.",
    ["Left-click to open settings"] = "Clique esquerdo para abrir as configurações",
    ["Drag to move"] = "Arraste para mover",
    ["Cancel"] = "Cancelar",
    ["Export"] = "Exportar", ["Choose a boss from the list."] = "Escolha um chefe na lista.",
    ["No imported assignments exist for this boss."] = "Não há atribuições importadas para este chefe.",
    ["No General Assignments imports saved."] = "Nenhuma importação de atribuições gerais salva.",
    ["The selected import could not be parsed."] = "Não foi possível analisar a importação selecionada.",
    ["Invalid General Assignments string."] = "String de atribuições gerais inválida.",
    ["Invalid Raid Assignments string."] = "String de atribuições de raide inválida.",
    ["Identical import already exists; selected the saved import."] = "Já existe uma importação idêntica; a importação salva foi selecionada.",
    ["General Assignments import saved."] = "Importação de atribuições gerais salva.",
    ["Raid Assignments import saved."] = "Importação de atribuições de raide salva.",
    ["Detected expansion: %s"] = "Expansão detectada: %s",
    ["Assignment Widget Visibility"] = "Visibilidade do widget de atribuições",
    ["Raid Leader Widget Visibility"] = "Visibilidade do widget do líder do raide",
    ["Assignment: Show always"] = "Atribuições: mostrar sempre",
    ["Assignment: Load only in Raid"] = "Atribuições: carregar somente em raide",
    ["Raid Leader: Show always"] = "Líder do raide: mostrar sempre",
    ["Raid Leader: Load only in Raid"] = "Líder do raide: carregar somente em raide",
    ["MerfinPlus Version Check"] = "Verificação de versão do MerfinPlus", ["Player"] = "Jogador",
    ["Scanning group..."] = "Verificando grupo...", ["Done"] = "Concluído", ["Refresh"] = "Atualizar",
    ["Commands:"] = "Comandos:", ["Melee Positions"] = "Posições corpo a corpo",
    ["Ranged Positions"] = "Posições à distância", ["Tank Positions"] = "Posições de tanque",
    ["Heal Positions"] = "Posições de cura", ["Additional Assignments"] = "Atribuições adicionais",
    ["Main"] = "Principal", ["Backup"] = "Reserva", ["Assigned"] = "Atribuído",
    ["Main Target"] = "Alvo principal", ["Off Target"] = "Alvo secundário", ["Damage"] = "Dano",
    ["Soulstone"] = "Pedra da Alma", ["Innervate"] = "Estimular", ["Misdirection"] = "Redirecionar",
    ["Star"] = "Estrela", ["Circle"] = "Círculo", ["Diamond"] = "Losango", ["Triangle"] = "Triângulo",
    ["Moon"] = "Lua", ["Square"] = "Quadrado", ["Cross"] = "Cruz", ["Skull"] = "Caveira",
  },
  itIT = {
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "I gruppi pre-boss non sono ancora configurati. Questa pagina è riservata a un aggiornamento futuro.",
    ["Left-click to open settings"] = "Clic sinistro per aprire le impostazioni",
    ["Drag to move"] = "Trascina per spostare",
    ["Cancel"] = "Annulla",
    ["Export"] = "Esporta", ["Choose a boss from the list."] = "Scegli un boss dall’elenco.",
    ["No imported assignments exist for this boss."] = "Non esistono assegnazioni importate per questo boss.",
    ["No General Assignments imports saved."] = "Nessuna importazione di assegnazioni generali salvata.",
    ["The selected import could not be parsed."] = "Impossibile analizzare l’importazione selezionata.",
    ["Invalid General Assignments string."] = "Stringa di assegnazioni generali non valida.",
    ["Invalid Raid Assignments string."] = "Stringa di assegnazioni incursione non valida.",
    ["Identical import already exists; selected the saved import."] = "Esiste già un’importazione identica; è stata selezionata quella salvata.",
    ["General Assignments import saved."] = "Importazione di assegnazioni generali salvata.",
    ["Raid Assignments import saved."] = "Importazione di assegnazioni incursione salvata.",
    ["Detected expansion: %s"] = "Espansione rilevata: %s",
    ["Assignment Widget Visibility"] = "Visibilità widget assegnazioni",
    ["Raid Leader Widget Visibility"] = "Visibilità widget capoincursione",
    ["Assignment: Show always"] = "Assegnazioni: mostra sempre",
    ["Assignment: Load only in Raid"] = "Assegnazioni: carica solo in incursione",
    ["Raid Leader: Show always"] = "Capoincursione: mostra sempre",
    ["Raid Leader: Load only in Raid"] = "Capoincursione: carica solo in incursione",
    ["MerfinPlus Version Check"] = "Controllo versione MerfinPlus", ["Player"] = "Giocatore",
    ["Scanning group..."] = "Scansione gruppo...", ["Done"] = "Completato", ["Refresh"] = "Aggiorna",
    ["Commands:"] = "Comandi:", ["Melee Positions"] = "Posizioni mischia",
    ["Ranged Positions"] = "Posizioni a distanza", ["Tank Positions"] = "Posizioni tank",
    ["Heal Positions"] = "Posizioni guaritori", ["Additional Assignments"] = "Assegnazioni aggiuntive",
    ["Main"] = "Principale", ["Backup"] = "Riserva", ["Assigned"] = "Assegnato",
    ["Main Target"] = "Bersaglio principale", ["Off Target"] = "Bersaglio secondario", ["Damage"] = "Danno",
    ["Soulstone"] = "Pietra dell’anima", ["Innervate"] = "Innervazione", ["Misdirection"] = "Depistaggio",
    ["Star"] = "Stella", ["Circle"] = "Cerchio", ["Diamond"] = "Rombo", ["Triangle"] = "Triangolo",
    ["Moon"] = "Luna", ["Square"] = "Quadrato", ["Cross"] = "Croce", ["Skull"] = "Teschio",
  },
  ruRU = {
    ["Pre-Boss Groups are not configured yet. This page is reserved for a future update."] =
      "Группы перед боссом пока не настроены. Эта страница зарезервирована для будущего обновления.",
    ["Left-click to open settings"] = "ЛКМ — открыть настройки",
    ["Drag to move"] = "Перетащите для перемещения",
    ["Cancel"] = "Отмена",
    ["Export"] = "Экспорт", ["Choose a boss from the list."] = "Выберите босса из списка.",
    ["No imported assignments exist for this boss."] = "Для этого босса нет импортированных назначений.",
    ["No General Assignments imports saved."] = "Нет сохранённых импортов общих назначений.",
    ["The selected import could not be parsed."] = "Не удалось разобрать выбранный импорт.",
    ["Invalid General Assignments string."] = "Недопустимая строка общих назначений.",
    ["Invalid Raid Assignments string."] = "Недопустимая строка рейдовых назначений.",
    ["Identical import already exists; selected the saved import."] = "Такой импорт уже существует; выбран сохранённый импорт.",
    ["General Assignments import saved."] = "Импорт общих назначений сохранён.",
    ["Raid Assignments import saved."] = "Импорт рейдовых назначений сохранён.",
    ["Detected expansion: %s"] = "Обнаруженное дополнение: %s",
    ["Assignment Widget Visibility"] = "Видимость виджета назначений",
    ["Raid Leader Widget Visibility"] = "Видимость виджета рейд-лидера",
    ["Assignment: Show always"] = "Назначения: показывать всегда",
    ["Assignment: Load only in Raid"] = "Назначения: загружать только в рейде",
    ["Raid Leader: Show always"] = "Рейд-лидер: показывать всегда",
    ["Raid Leader: Load only in Raid"] = "Рейд-лидер: загружать только в рейде",
    ["Commands:"] = "Команды:", ["Main Target"] = "Основная цель", ["Off Target"] = "Дополнительная цель",
    ["Star"] = "Звезда", ["Circle"] = "Круг", ["Diamond"] = "Ромб", ["Triangle"] = "Треугольник",
    ["Moon"] = "Луна", ["Square"] = "Квадрат", ["Cross"] = "Крест", ["Skull"] = "Череп",
  },
}
for locale, entries in pairs(extraTranslations) do
  for key, value in pairs(entries) do
    overrides[locale][key] = value
  end
end

local broadcastTranslations = {
  deDE = {
    ["You need to be in a group."] = "Du musst in einer Gruppe sein.",
    ["Only group leaders or raid assistants can broadcast."] = "Nur Gruppenleiter oder Raidassistenten können senden.",
    ["No valid General Assignments import is selected."] = "Kein gültiger Import für allgemeine Zuweisungen ist ausgewählt.",
    ["No imported assignments exist for the selected boss."] = "Für den ausgewählten Boss sind keine importierten Zuweisungen vorhanden.",
  },
  frFR = {
    ["You need to be in a group."] = "Vous devez être dans un groupe.",
    ["Only group leaders or raid assistants can broadcast."] = "Seuls les chefs de groupe ou assistants de raid peuvent diffuser.",
    ["No valid General Assignments import is selected."] = "Aucun import valide d’affectations générales n’est sélectionné.",
    ["No imported assignments exist for the selected boss."] = "Aucune affectation importée pour le boss sélectionné.",
  },
  esES = {
    ["You need to be in a group."] = "Debes estar en un grupo.",
    ["Only group leaders or raid assistants can broadcast."] = "Solo los líderes de grupo o asistentes de banda pueden transmitir.",
    ["No valid General Assignments import is selected."] = "No hay una importación válida de asignaciones generales seleccionada.",
    ["No imported assignments exist for the selected boss."] = "No hay asignaciones importadas para el jefe seleccionado.",
  },
  esMX = {
    ["You need to be in a group."] = "Debes estar en un grupo.",
    ["Only group leaders or raid assistants can broadcast."] = "Solo los líderes de grupo o asistentes de banda pueden transmitir.",
    ["No valid General Assignments import is selected."] = "No hay una importación válida de asignaciones generales seleccionada.",
    ["No imported assignments exist for the selected boss."] = "No hay asignaciones importadas para el jefe seleccionado.",
  },
  ptBR = {
    ["You need to be in a group."] = "Você precisa estar em um grupo.",
    ["Only group leaders or raid assistants can broadcast."] = "Somente líderes de grupo ou assistentes de raide podem transmitir.",
    ["No valid General Assignments import is selected."] = "Nenhuma importação válida de atribuições gerais está selecionada.",
    ["No imported assignments exist for the selected boss."] = "Não há atribuições importadas para o chefe selecionado.",
  },
  itIT = {
    ["You need to be in a group."] = "Devi essere in un gruppo.",
    ["Only group leaders or raid assistants can broadcast."] = "Solo i capigruppo o gli assistenti incursione possono trasmettere.",
    ["No valid General Assignments import is selected."] = "Nessuna importazione valida di assegnazioni generali è selezionata.",
    ["No imported assignments exist for the selected boss."] = "Non esistono assegnazioni importate per il boss selezionato.",
  },
  ruRU = {
    ["You need to be in a group."] = "Вы должны находиться в группе.",
    ["Only group leaders or raid assistants can broadcast."] = "Отправлять могут только лидеры группы или помощники рейда.",
    ["No valid General Assignments import is selected."] = "Не выбран допустимый импорт общих назначений.",
    ["No imported assignments exist for the selected boss."] = "Для выбранного босса нет импортированных назначений.",
  },
}
for locale, entries in pairs(broadcastTranslations) do
  for key, value in pairs(entries) do
    overrides[locale][key] = value
  end
end

local preBossTranslations = {
  deDE = {
    ["Import replaces the current saved Pre-Boss Groups plan."] =
      "Der Import ersetzt den aktuell gespeicherten Pre-Boss-Gruppenplan.",
    ["No Pre-Boss Groups plan imported."] =
      "Kein Pre-Boss-Gruppenplan importiert.",
    ["Pre-Boss Groups import failed: %s"] =
      "Import der Pre-Boss-Gruppen fehlgeschlagen: %s",
    ["Imported %d bosses for %s."] = "%d Bosse für %s importiert.",
    ["Set %s Group"] = "Gruppe für %s setzen",
    ["Set Group"] = "Gruppe setzen",
    ["Raid groups cannot be changed during combat."] =
      "Raidgruppen können im Kampf nicht geändert werden.",
    ["You must be in a raid to set groups."] =
      "Du musst in einem Raid sein, um Gruppen zu setzen.",
    ["Only the raid leader or a raid assistant can set groups."] =
      "Nur der Raidleiter oder ein Raidassistent kann Gruppen setzen.",
    ["The raid roster APIs are unavailable in this client."] =
      "Die Raidkader-APIs sind in diesem Client nicht verfügbar.",
    ["No assigned players for %s."] =
      "Für %s sind keine Spieler zugewiesen.",
    ["Group set successful for %s."] =
      "Gruppe für %s erfolgreich gesetzt.",
    ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
      "Gruppe für %s erfolgreich gesetzt. Gruppen %d/%d, Plätze %d/%d; verschoben %d, übersprungen %d.",
    ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
      "Keine Planspieler sind derzeit eindeutig als online Raidmitglieder verfügbar (fehlend %d, offline %d, mehrdeutig %d).",
    ["Group set failed for %s: %s"] =
      "Gruppe für %s konnte nicht gesetzt werden: %s",
    ["Another group update is still being verified."] =
      "Eine andere Gruppenänderung wird noch geprüft.",
    ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
      "Kadernamen konnten nicht aufgelöst werden (fehlend %d, mehrdeutig %d).",
    ["%d roster API request(s) failed."] =
      "%d Anfrage(n) an die Kader-API sind fehlgeschlagen.",
    ["%d player(s) left the raid before verification."] =
      "%d Spieler haben den Raid vor der Prüfung verlassen.",
    ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
      "Kaderprüfung fehlgeschlagen (Gruppen %d/%d, Plätze %d/%d).",
    ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
      "Gruppenänderung für %s angefordert: %d Verschiebung(en); fehlend %d; mehrdeutig %d; offline %d. Prüfung läuft...",
    ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
      "Gruppenergebnis für %s: Gruppen %d/%d, Plätze %d/%d; fehlend %d; mehrdeutig %d; API-Fehler %d.",
    ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
      "WoW bietet Untergruppenverschiebungen, aber keine direkte API für Plätze innerhalb einer Gruppe; verbleibende Platzabweichungen werden gemeldet.",
  },
  frFR = {
    ["Import replaces the current saved Pre-Boss Groups plan."] =
      "L’import remplace le plan de groupes pré-boss actuellement enregistré.",
    ["No Pre-Boss Groups plan imported."] =
      "Aucun plan de groupes pré-boss importé.",
    ["Pre-Boss Groups import failed: %s"] =
      "Échec de l’import des groupes pré-boss : %s",
    ["Imported %d bosses for %s."] = "%d boss importés pour %s.",
    ["Set %s Group"] = "Définir le groupe de %s",
    ["Set Group"] = "Définir le groupe",
    ["Raid groups cannot be changed during combat."] =
      "Les groupes de raid ne peuvent pas être modifiés en combat.",
    ["You must be in a raid to set groups."] =
      "Vous devez être dans un raid pour définir les groupes.",
    ["Only the raid leader or a raid assistant can set groups."] =
      "Seul le chef de raid ou un assistant peut définir les groupes.",
    ["The raid roster APIs are unavailable in this client."] =
      "Les API de composition du raid sont indisponibles dans ce client.",
    ["No assigned players for %s."] =
      "Aucun joueur assigné pour %s.",
    ["Group set successful for %s."] =
      "Groupe défini avec succès pour %s.",
    ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
      "Groupe défini avec succès pour %s. Groupes %d/%d, places %d/%d ; déplacés %d, ignorés %d.",
    ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
      "Aucun joueur du plan n’est actuellement disponible comme membre du raid en ligne identifié sans ambiguïté (absents %d, hors ligne %d, ambigus %d).",
    ["Group set failed for %s: %s"] =
      "Échec de la définition du groupe pour %s : %s",
    ["Another group update is still being verified."] =
      "Une autre mise à jour des groupes est encore en cours de vérification.",
    ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
      "Des noms du raid n’ont pas pu être résolus (absents %d, ambigus %d).",
    ["%d roster API request(s) failed."] =
      "%d requête(s) de l’API du raid ont échoué.",
    ["%d player(s) left the raid before verification."] =
      "%d joueur(s) ont quitté le raid avant la vérification.",
    ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
      "Échec de la vérification du raid (groupes %d/%d, places %d/%d).",
    ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
      "Mise à jour des groupes demandée pour %s : %d déplacement(s) ; absents %d ; ambigus %d ; hors ligne %d. Vérification...",
    ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
      "Résultat des groupes pour %s : groupes %d/%d, places %d/%d ; absents %d ; ambigus %d ; erreurs API %d.",
    ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
      "WoW permet de déplacer les sous-groupes mais ne fournit pas d’API directe pour les places internes ; les écarts restants sont signalés.",
  },
  esES = {
    ["Import replaces the current saved Pre-Boss Groups plan."] =
      "La importación reemplaza el plan de grupos pre-jefe guardado actualmente.",
    ["No Pre-Boss Groups plan imported."] =
      "No hay ningún plan de grupos pre-jefe importado.",
    ["Pre-Boss Groups import failed: %s"] =
      "Error al importar los grupos pre-jefe: %s",
    ["Imported %d bosses for %s."] = "Se importaron %d jefes para %s.",
    ["Set %s Group"] = "Establecer grupo de %s",
    ["Set Group"] = "Establecer grupo",
    ["Raid groups cannot be changed during combat."] =
      "Los grupos de banda no se pueden cambiar durante el combate.",
    ["You must be in a raid to set groups."] =
      "Debes estar en una banda para establecer los grupos.",
    ["Only the raid leader or a raid assistant can set groups."] =
      "Solo el líder de banda o un ayudante puede establecer los grupos.",
    ["The raid roster APIs are unavailable in this client."] =
      "Las API de la plantilla de banda no están disponibles en este cliente.",
    ["No assigned players for %s."] =
      "No hay jugadores asignados para %s.",
    ["Group set successful for %s."] =
      "Grupo establecido correctamente para %s.",
    ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
      "Grupo establecido correctamente para %s. Grupos %d/%d, puestos %d/%d; movidos %d, omitidos %d.",
    ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
      "No hay jugadores del plan disponibles como miembros de banda conectados y resueltos de forma única (ausentes %d, desconectados %d, ambiguos %d).",
    ["Group set failed for %s: %s"] =
      "No se pudo establecer el grupo para %s: %s",
    ["Another group update is still being verified."] =
      "Todavía se está verificando otra actualización de grupos.",
    ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
      "No se pudieron resolver nombres de la banda (ausentes %d, ambiguos %d).",
    ["%d roster API request(s) failed."] =
      "Fallaron %d solicitudes a la API de banda.",
    ["%d player(s) left the raid before verification."] =
      "%d jugador(es) abandonaron la banda antes de la verificación.",
    ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
      "Falló la verificación de banda (grupos %d/%d, puestos %d/%d).",
    ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
      "Actualización de grupos solicitada para %s: %d movimiento(s); ausentes %d; ambiguos %d; desconectados %d. Verificando...",
    ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
      "Resultado de grupos para %s: grupos %d/%d, puestos %d/%d; ausentes %d; ambiguos %d; errores de API %d.",
    ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
      "WoW permite mover subgrupos, pero no ofrece una API directa para los puestos internos; se informan las diferencias restantes.",
  },
  esMX = {
    ["Import replaces the current saved Pre-Boss Groups plan."] =
      "La importación reemplaza el plan de grupos previo al jefe guardado actualmente.",
    ["No Pre-Boss Groups plan imported."] =
      "No hay ningún plan de grupos previo al jefe importado.",
    ["Pre-Boss Groups import failed: %s"] =
      "Error al importar los grupos previos al jefe: %s",
    ["Imported %d bosses for %s."] = "Se importaron %d jefes para %s.",
    ["Set %s Group"] = "Establecer grupo de %s",
    ["Set Group"] = "Establecer grupo",
    ["Raid groups cannot be changed during combat."] =
      "Los grupos de banda no se pueden cambiar durante el combate.",
    ["You must be in a raid to set groups."] =
      "Debes estar en una banda para establecer los grupos.",
    ["Only the raid leader or a raid assistant can set groups."] =
      "Solo el líder de banda o un asistente puede establecer los grupos.",
    ["The raid roster APIs are unavailable in this client."] =
      "Las API de la plantilla de banda no están disponibles en este cliente.",
    ["No assigned players for %s."] =
      "No hay jugadores asignados para %s.",
    ["Group set successful for %s."] =
      "Grupo establecido correctamente para %s.",
    ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
      "Grupo establecido correctamente para %s. Grupos %d/%d, puestos %d/%d; movidos %d, omitidos %d.",
    ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
      "No hay jugadores del plan disponibles como miembros de banda conectados y resueltos de forma única (ausentes %d, desconectados %d, ambiguos %d).",
    ["Group set failed for %s: %s"] =
      "No se pudo establecer el grupo para %s: %s",
    ["Another group update is still being verified."] =
      "Todavía se está verificando otra actualización de grupos.",
    ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
      "No se pudieron resolver nombres de la banda (ausentes %d, ambiguos %d).",
    ["%d roster API request(s) failed."] =
      "Fallaron %d solicitudes a la API de banda.",
    ["%d player(s) left the raid before verification."] =
      "%d jugador(es) salieron de la banda antes de la verificación.",
    ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
      "Falló la verificación de banda (grupos %d/%d, puestos %d/%d).",
    ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
      "Actualización de grupos solicitada para %s: %d movimiento(s); ausentes %d; ambiguos %d; desconectados %d. Verificando...",
    ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
      "Resultado de grupos para %s: grupos %d/%d, puestos %d/%d; ausentes %d; ambiguos %d; errores de API %d.",
    ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
      "WoW permite mover subgrupos, pero no ofrece una API directa para los puestos internos; se informan las diferencias restantes.",
  },
  ptBR = {
    ["Import replaces the current saved Pre-Boss Groups plan."] =
      "A importação substitui o plano de grupos pré-chefe salvo atualmente.",
    ["No Pre-Boss Groups plan imported."] =
      "Nenhum plano de grupos pré-chefe foi importado.",
    ["Pre-Boss Groups import failed: %s"] =
      "Falha ao importar grupos pré-chefe: %s",
    ["Imported %d bosses for %s."] = "%d chefes importados para %s.",
    ["Set %s Group"] = "Definir grupo de %s",
    ["Set Group"] = "Definir grupo",
    ["Raid groups cannot be changed during combat."] =
      "Os grupos de raide não podem ser alterados durante o combate.",
    ["You must be in a raid to set groups."] =
      "Você precisa estar em um raide para definir os grupos.",
    ["Only the raid leader or a raid assistant can set groups."] =
      "Somente o líder ou um assistente de raide pode definir os grupos.",
    ["The raid roster APIs are unavailable in this client."] =
      "As APIs da formação do raide não estão disponíveis neste cliente.",
    ["No assigned players for %s."] =
      "Não há jogadores atribuídos para %s.",
    ["Group set successful for %s."] =
      "Grupo definido com sucesso para %s.",
    ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
      "Grupo definido com sucesso para %s. Grupos %d/%d, posições %d/%d; movidos %d, ignorados %d.",
    ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
      "Nenhum jogador do plano está disponível como membro de raide online resolvido de forma única (ausentes %d, offline %d, ambíguos %d).",
    ["Group set failed for %s: %s"] =
      "Falha ao definir o grupo para %s: %s",
    ["Another group update is still being verified."] =
      "Outra atualização de grupos ainda está sendo verificada.",
    ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
      "Não foi possível resolver nomes do raide (ausentes %d, ambíguos %d).",
    ["%d roster API request(s) failed."] =
      "%d solicitação(ões) à API do raide falharam.",
    ["%d player(s) left the raid before verification."] =
      "%d jogador(es) deixaram o raide antes da verificação.",
    ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
      "Falha na verificação do raide (grupos %d/%d, posições %d/%d).",
    ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
      "Atualização de grupos solicitada para %s: %d movimento(s); ausentes %d; ambíguos %d; offline %d. Verificando...",
    ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
      "Resultado dos grupos para %s: grupos %d/%d, posições %d/%d; ausentes %d; ambíguos %d; erros de API %d.",
    ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
      "O WoW permite mover subgrupos, mas não oferece uma API direta para posições internas; diferenças restantes são informadas.",
  },
  itIT = {
    ["Import replaces the current saved Pre-Boss Groups plan."] =
      "L’importazione sostituisce il piano dei gruppi pre-boss attualmente salvato.",
    ["No Pre-Boss Groups plan imported."] =
      "Nessun piano dei gruppi pre-boss importato.",
    ["Pre-Boss Groups import failed: %s"] =
      "Importazione dei gruppi pre-boss non riuscita: %s",
    ["Imported %d bosses for %s."] = "Importati %d boss per %s.",
    ["Set %s Group"] = "Imposta il gruppo di %s",
    ["Set Group"] = "Imposta gruppo",
    ["Raid groups cannot be changed during combat."] =
      "I gruppi del raid non possono essere modificati in combattimento.",
    ["You must be in a raid to set groups."] =
      "Devi essere in un raid per impostare i gruppi.",
    ["Only the raid leader or a raid assistant can set groups."] =
      "Solo il capoincursione o un assistente può impostare i gruppi.",
    ["The raid roster APIs are unavailable in this client."] =
      "Le API della formazione del raid non sono disponibili in questo client.",
    ["No assigned players for %s."] =
      "Nessun giocatore assegnato per %s.",
    ["Group set successful for %s."] =
      "Gruppo impostato correttamente per %s.",
    ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
      "Gruppo impostato correttamente per %s. Gruppi %d/%d, posizioni %d/%d; spostati %d, ignorati %d.",
    ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
      "Nessun giocatore del piano è disponibile come membro del raid online identificato in modo univoco (assenti %d, offline %d, ambigui %d).",
    ["Group set failed for %s: %s"] =
      "Impossibile impostare il gruppo per %s: %s",
    ["Another group update is still being verified."] =
      "È ancora in corso la verifica di un altro aggiornamento dei gruppi.",
    ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
      "Impossibile risolvere alcuni nomi del raid (assenti %d, ambigui %d).",
    ["%d roster API request(s) failed."] =
      "%d richiesta/e all’API del raid non riuscita/e.",
    ["%d player(s) left the raid before verification."] =
      "%d giocatore/i hanno lasciato il raid prima della verifica.",
    ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
      "Verifica del raid non riuscita (gruppi %d/%d, posizioni %d/%d).",
    ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
      "Aggiornamento gruppi richiesto per %s: %d spostamento/i; assenti %d; ambigui %d; offline %d. Verifica...",
    ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
      "Risultato gruppi per %s: gruppi %d/%d, posizioni %d/%d; assenti %d; ambigui %d; errori API %d.",
    ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
      "WoW consente di spostare i sottogruppi ma non offre un’API diretta per le posizioni interne; le differenze restanti vengono segnalate.",
  },
  ruRU = {
    ["Import replaces the current saved Pre-Boss Groups plan."] =
      "Импорт заменяет текущий сохранённый план групп перед боссом.",
    ["No Pre-Boss Groups plan imported."] =
      "План групп перед боссом не импортирован.",
    ["Pre-Boss Groups import failed: %s"] =
      "Не удалось импортировать группы перед боссом: %s",
    ["Imported %d bosses for %s."] = "Импортировано боссов: %d, набор: %s.",
    ["Set %s Group"] = "Установить группу для %s",
    ["Set Group"] = "Установить группу",
    ["Raid groups cannot be changed during combat."] =
      "Рейдовые группы нельзя менять во время боя.",
    ["You must be in a raid to set groups."] =
      "Чтобы распределять группы, необходимо находиться в рейде.",
    ["Only the raid leader or a raid assistant can set groups."] =
      "Распределять группы может только лидер рейда или помощник.",
    ["The raid roster APIs are unavailable in this client."] =
      "API состава рейда недоступны в этом клиенте.",
    ["No assigned players for %s."] =
      "Для %s нет назначенных игроков.",
    ["Group set successful for %s."] =
      "Группа для %s успешно установлена.",
    ["Group set successful for %s. Groups %d/%d, slots %d/%d; moved %d, skipped %d."] =
      "Группа для %s успешно установлена. Группы %d/%d, места %d/%d; перемещено %d, пропущено %d.",
    ["No plan players are currently available as uniquely resolved online raid members (missing %d, offline %d, ambiguous %d)."] =
      "Нет доступных игроков плана, однозначно определённых как находящиеся онлайн в рейде (отсутствуют %d, не в сети %d, неоднозначны %d).",
    ["Group set failed for %s: %s"] =
      "Не удалось установить группу для %s: %s",
    ["Another group update is still being verified."] =
      "Другая смена групп ещё проверяется.",
    ["Roster names could not be resolved (missing %d, ambiguous %d)."] =
      "Не удалось определить имена состава (отсутствуют %d, неоднозначны %d).",
    ["%d roster API request(s) failed."] =
      "Не выполнено запросов API состава: %d.",
    ["%d player(s) left the raid before verification."] =
      "Игроков покинуло рейд до проверки: %d.",
    ["Roster verification failed (groups %d/%d, slots %d/%d)."] =
      "Проверка состава не пройдена (группы %d/%d, места %d/%d).",
    ["Group update requested for %s: %d move(s); missing %d; ambiguous %d; offline %d. Verifying..."] =
      "Запрошено обновление групп для %s: перемещений %d; отсутствуют %d; неоднозначны %d; не в сети %d. Проверка...",
    ["Group result for %s: groups %d/%d, slots %d/%d; missing %d; ambiguous %d; API errors %d."] =
      "Результат для %s: группы %d/%d, места %d/%d; отсутствуют %d; неоднозначны %d; ошибки API %d.",
    ["WoW exposes subgroup moves but no direct intra-group slot API; remaining slot differences are reported."] =
      "WoW позволяет перемещать подгруппы, но не предоставляет прямой API для мест внутри группы; оставшиеся различия отображаются.",
  },
}
for locale, entries in pairs(preBossTranslations) do
  for key, value in pairs(entries) do
    overrides[locale][key] = value
  end
end

-- Ready Check and Raid Assignments own custom frames outside AceConfig. Keep
-- every visible control, status and tooltip in the same runtime locale table
-- so switching language refreshes those frames without a reload.
local function AddFeatureString(key, values)
  enUS[key] = key
  for locale, value in pairs(values or {}) do
    if overrides[locale] and type(value) == "string" and value ~= "" then
      overrides[locale][key] = value
    end
  end
end

local featureStrings = {
  ["Ready Check"] = { deDE = "Bereitschaftscheck", frFR = "Vérification des prêts", esES = "Comprobación de preparación", ptBR = "Verificação de prontidão", itIT = "Controllo di prontezza", ruRU = "Проверка готовности", zhCN = "就绪确认", zhTW = "準備確認", koKR = "전투 준비 확인", jaJP = "準備確認" },
  ["Shows a movable and resizable raid status window when a Blizzard ready check begins."] = { deDE = "Zeigt beim Start eines Blizzard-Bereitschaftschecks ein verschiebbares und skalierbares Raidstatusfenster.", frFR = "Affiche une fenêtre d’état du raid déplaçable et redimensionnable au début d’une vérification des prêts Blizzard.", esES = "Muestra una ventana de estado de banda móvil y redimensionable al iniciar una comprobación de preparación de Blizzard.", ptBR = "Mostra uma janela de status do raide móvel e redimensionável quando uma verificação de prontidão da Blizzard começa.", itIT = "Mostra una finestra di stato del raid spostabile e ridimensionabile all’avvio di un controllo di prontezza Blizzard.", ruRU = "Показывает перемещаемое и масштабируемое окно состояния рейда при начале проверки готовности Blizzard.", zhCN = "当暴雪就绪确认开始时显示可移动、可调整大小的团队状态窗口。", zhTW = "當暴雪準備確認開始時顯示可移動、可調整大小的團隊狀態視窗。", koKR = "블리자드 전투 준비 확인이 시작되면 이동 및 크기 조절 가능한 공격대 상태 창을 표시합니다.", jaJP = "Blizzardの準備確認開始時に、移動・サイズ変更可能なレイド状態ウィンドウを表示します。" },
  ["Enable"] = { deDE = "Aktivieren", frFR = "Activer", esES = "Activar", ptBR = "Ativar", itIT = "Attiva", ruRU = "Включить", zhCN = "启用", zhTW = "啟用", koKR = "활성화", jaJP = "有効化" },
  ["Enable only while group leader"] = { deDE = "Nur als Gruppenleiter aktivieren", frFR = "Activer uniquement en tant que chef de groupe", esES = "Activar solo como líder del grupo", ptBR = "Ativar somente como líder do grupo", itIT = "Attiva solo come capogruppo", ruRU = "Включать только для лидера группы", zhCN = "仅担任队长时启用", zhTW = "僅擔任隊長時啟用", koKR = "파티장일 때만 활성화", jaJP = "グループリーダー時のみ有効" },
  ["Enable only while assistant"] = { deDE = "Nur als Assistent aktivieren", frFR = "Activer uniquement en tant qu’assistant", esES = "Activar solo como ayudante", ptBR = "Ativar somente como assistente", itIT = "Attiva solo come assistente", ruRU = "Включать только для помощника", zhCN = "仅担任助理时启用", zhTW = "僅擔任助理時啟用", koKR = "공격대 지원일 때만 활성화", jaJP = "アシスタント時のみ有効" },
  ["When both role restrictions are selected, either group leader or assistant is allowed."] = { deDE = "Sind beide Rollenbeschränkungen gewählt, ist Gruppenleiter oder Assistent zulässig.", frFR = "Si les deux restrictions sont sélectionnées, le chef de groupe ou un assistant est autorisé.", esES = "Si se seleccionan ambas restricciones, se permite al líder del grupo o a un ayudante.", ptBR = "Quando ambas as restrições estão selecionadas, o líder do grupo ou um assistente é permitido.", itIT = "Se entrambe le restrizioni sono selezionate, sono ammessi il capogruppo o un assistente.", ruRU = "Если выбраны оба ограничения, разрешены лидер группы или помощник.", zhCN = "同时选择两个角色限制时，队长或助理均可使用。", zhTW = "同時選擇兩個角色限制時，隊長或助理均可使用。", koKR = "두 역할 제한을 모두 선택하면 파티장 또는 지원 담당자에게 허용됩니다.", jaJP = "両方の役割制限を選択した場合、リーダーまたはアシスタントが使用できます。" },
  ["Display Duration"] = { deDE = "Anzeigedauer", frFR = "Durée d’affichage", esES = "Duración de visualización", ptBR = "Duração da exibição", itIT = "Durata di visualizzazione", ruRU = "Длительность отображения", zhCN = "显示时长", zhTW = "顯示時間", koKR = "표시 시간", jaJP = "表示時間" },
  ["Seconds to keep the window visible from the moment the ready check starts."] = { deDE = "Sekunden, die das Fenster ab Beginn des Bereitschaftschecks sichtbar bleibt.", frFR = "Secondes pendant lesquelles la fenêtre reste visible dès le début de la vérification.", esES = "Segundos que la ventana permanece visible desde el inicio de la comprobación.", ptBR = "Segundos em que a janela permanece visível desde o início da verificação.", itIT = "Secondi per cui la finestra resta visibile dall’inizio del controllo.", ruRU = "Сколько секунд окно остаётся видимым с начала проверки готовности.", zhCN = "从就绪确认开始起窗口保持可见的秒数。", zhTW = "從準備確認開始起視窗保持可見的秒數。", koKR = "전투 준비 확인 시작부터 창을 표시할 시간(초)입니다.", jaJP = "準備確認開始からウィンドウを表示し続ける秒数です。" },
  ["Font Size"] = { deDE = "Schriftgröße", frFR = "Taille de police", esES = "Tamaño de fuente", ptBR = "Tamanho da fonte", itIT = "Dimensione carattere", ruRU = "Размер шрифта", zhCN = "字体大小", zhTW = "字型大小", koKR = "글꼴 크기", jaJP = "フォントサイズ" },
  ["Width"] = { deDE = "Breite", frFR = "Largeur", esES = "Ancho", ptBR = "Largura", itIT = "Larghezza", ruRU = "Ширина", zhCN = "宽度", zhTW = "寬度", koKR = "너비", jaJP = "幅" },
  ["Height"] = { deDE = "Höhe", frFR = "Hauteur", esES = "Alto", ptBR = "Altura", itIT = "Altezza", ruRU = "Высота", zhCN = "高度", zhTW = "高度", koKR = "높이", jaJP = "高さ" },
  ["Font"] = { deDE = "Schriftart", frFR = "Police", esES = "Fuente", ptBR = "Fonte", itIT = "Carattere", ruRU = "Шрифт", zhCN = "字体", zhTW = "字型", koKR = "글꼴", jaJP = "フォント" },
  ["Controls Ready Check text size independently of window resizing."] = { deDE = "Steuert die Textgröße des Bereitschaftschecks unabhängig von der Fenstergröße.", frFR = "Contrôle la taille du texte indépendamment du redimensionnement de la fenêtre.", esES = "Controla el tamaño del texto independientemente del tamaño de la ventana.", ptBR = "Controla o tamanho do texto independentemente do redimensionamento da janela.", itIT = "Controlla la dimensione del testo indipendentemente dalla finestra.", ruRU = "Управляет размером текста независимо от размера окна.", zhCN = "独立于窗口缩放控制就绪确认文字大小。", zhTW = "獨立於視窗縮放控制準備確認文字大小。", koKR = "창 크기와 별도로 전투 준비 확인 글자 크기를 조절합니다.", jaJP = "ウィンドウサイズとは別に準備確認の文字サイズを調整します。" },
  ["Sort by Name"] = { deDE = "Nach Name sortieren", frFR = "Trier par nom", esES = "Ordenar por nombre", ptBR = "Ordenar por nome", itIT = "Ordina per nome", ruRU = "Сортировать по имени", zhCN = "按名称排序", zhTW = "依名稱排序", koKR = "이름순 정렬", jaJP = "名前順" },
  ["Sort by Class"] = { deDE = "Nach Klasse sortieren", frFR = "Trier par classe", esES = "Ordenar por clase", ptBR = "Ordenar por classe", itIT = "Ordina per classe", ruRU = "Сортировать по классу", zhCN = "按职业排序", zhTW = "依職業排序", koKR = "직업순 정렬", jaJP = "クラス順" },
  ["Show Expiring Buffs, Food and Flask"] = { deDE = "Auslaufende Buffs, Essen und Fläschchen anzeigen", frFR = "Afficher les améliorations, nourritures et flacons expirant bientôt", esES = "Mostrar beneficios, comida y frascos próximos a expirar", ptBR = "Mostrar bônus, comida e frascos expirando", itIT = "Mostra benefici, cibo e tonici in scadenza", ruRU = "Показывать заканчивающиеся эффекты, еду и настои", zhCN = "显示即将到期的增益、食物和合剂", zhTW = "顯示即將到期的增益、食物和精煉藥劑", koKR = "곧 만료되는 강화 효과, 음식 및 영약 표시", jaJP = "期限切れ間近のバフ、食事、フラスコを表示" },
  ["Highlights every tracked aura with 5 minutes or less remaining using an orange cell and hourglass."] = { deDE = "Markiert jede erfasste Aura mit höchstens 5 Minuten Restdauer orange und mit einer Sanduhr.", frFR = "Signale en orange avec un sablier toute aura suivie ayant au plus 5 minutes restantes.", esES = "Resalta en naranja y con un reloj de arena cada aura con 5 minutos o menos.", ptBR = "Destaca em laranja e com ampulheta toda aura com 5 minutos ou menos.", itIT = "Evidenzia in arancione e con una clessidra ogni aura con 5 minuti o meno.", ruRU = "Выделяет оранжевым и песочными часами эффекты с остатком не более 5 минут.", zhCN = "剩余时间不超过5分钟的追踪光环会以橙色单元格和沙漏突出显示。", zhTW = "剩餘時間不超過5分鐘的追蹤光環會以橘色欄位和沙漏突顯。", koKR = "남은 시간이 5분 이하인 추적 오라를 주황색 칸과 모래시계로 강조합니다.", jaJP = "残り5分以下の追跡オーラをオレンジ色のセルと砂時計で強調します。" },
  ["Report in Chat:"] = { deDE = "Im Chat melden:", frFR = "Signaler dans le chat :", esES = "Informar en el chat:", ptBR = "Informar no chat:", itIT = "Segnala in chat:", ruRU = "Сообщать в чат:", zhCN = "在聊天中报告：", zhTW = "在聊天中回報：", koKR = "대화창에 보고:", jaJP = "チャットに報告:" },
  ["Ready Check Frame Settings"] = { deDE = "Fenstereinstellungen für Bereitschaftscheck", frFR = "Réglages de la fenêtre de vérification", esES = "Ajustes de la ventana de preparación", ptBR = "Configurações da janela de prontidão", itIT = "Impostazioni finestra di prontezza", ruRU = "Настройки окна проверки готовности", zhCN = "就绪确认窗口设置", zhTW = "準備確認視窗設定", koKR = "전투 준비 확인 창 설정", jaJP = "準備確認ウィンドウ設定" },
  ["Food"] = { deDE = "Essen", frFR = "Nourriture", esES = "Comida", ptBR = "Comida", itIT = "Cibo", ruRU = "Еда", zhCN = "食物", zhTW = "食物", koKR = "음식", jaJP = "食事" },
  ["Flask / Elixir"] = { deDE = "Fläschchen / Elixier", frFR = "Flacon / Élixir", esES = "Frasco / Elixir", ptBR = "Frasco / Elixir", itIT = "Tonico / Elisir", ruRU = "Настой / Эликсир", zhCN = "合剂 / 药剂", zhTW = "精煉藥劑 / 藥劑", koKR = "영약 / 비약", jaJP = "フラスコ / エリクサー" },
  ["Flask"] = { deDE = "Fläschchen", frFR = "Flacon", esES = "Frasco", ptBR = "Frasco", itIT = "Tonico", ruRU = "Настой", zhCN = "合剂", zhTW = "精煉藥劑", koKR = "영약", jaJP = "フラスコ" },
  ["Battle Elixir"] = { deDE = "Kampfelixier", frFR = "Élixir de bataille", esES = "Elixir de batalla", ptBR = "Elixir de batalha", itIT = "Elisir da battaglia", ruRU = "Боевой эликсир", zhCN = "战斗药剂", zhTW = "戰鬥藥劑", koKR = "전투 비약", jaJP = "バトルエリクサー" },
  ["Guardian Elixir"] = { deDE = "Wächterelixier", frFR = "Élixir du gardien", esES = "Elixir guardián", ptBR = "Elixir guardião", itIT = "Elisir del guardiano", ruRU = "Охранный эликсир", zhCN = "守护药剂", zhTW = "守護藥劑", koKR = "수호 비약", jaJP = "ガーディアンエリクサー" },
  ["Scroll"] = { deDE = "Schriftrolle", frFR = "Parchemin", esES = "Pergamino", ptBR = "Pergaminho", itIT = "Pergamena", ruRU = "Свиток", zhCN = "卷轴", zhTW = "卷軸", koKR = "두루마리", jaJP = "巻物" },
  ["Intellect"] = { deDE = "Intelligenz", frFR = "Intelligence", esES = "Intelecto", ptBR = "Intelecto", itIT = "Intelletto", ruRU = "Интеллект", zhCN = "智力", zhTW = "智力", koKR = "지능", jaJP = "知力" },
  ["Attack Power"] = { deDE = "Angriffskraft", frFR = "Puissance d’attaque", esES = "Poder de ataque", ptBR = "Poder de ataque", itIT = "Potenza d’attacco", ruRU = "Сила атаки", zhCN = "攻击强度", zhTW = "攻擊強度", koKR = "전투력", jaJP = "攻撃力" },
  ["Stamina"] = { deDE = "Ausdauer", frFR = "Endurance", esES = "Aguante", ptBR = "Vigor", itIT = "Tempra", ruRU = "Выносливость", zhCN = "耐力", zhTW = "耐力", koKR = "체력", jaJP = "スタミナ" },
  ["Spirit"] = { deDE = "Willenskraft", frFR = "Esprit", esES = "Espíritu", ptBR = "Espírito", itIT = "Spirito", ruRU = "Дух", zhCN = "精神", zhTW = "精神", koKR = "정신력", jaJP = "精神力" },
  ["Armor"] = { deDE = "Rüstung", frFR = "Armure", esES = "Armadura", ptBR = "Armadura", itIT = "Armatura", ruRU = "Броня", zhCN = "护甲", zhTW = "護甲", koKR = "방어도", jaJP = "防具" },
  ["Shadow Protection"] = { deDE = "Schattenschutz", frFR = "Protection contre l’Ombre", esES = "Protección contra las Sombras", ptBR = "Proteção contra Sombra", itIT = "Protezione dall’Ombra", ruRU = "Защита от темной магии", zhCN = "暗影防护", zhTW = "暗影防護", koKR = "암흑 보호", jaJP = "シャドウ防御" },
  ["Blessing of Might"] = { deDE = "Segen der Macht", frFR = "Bénédiction de puissance", esES = "Bendición de poderío", ptBR = "Bênção do Poder", itIT = "Benedizione del Vigore", ruRU = "Благословение могущества", zhCN = "力量祝福", zhTW = "力量祝福", koKR = "힘의 축복", jaJP = "力の祝福" },
  ["Blessing of Wisdom"] = { deDE = "Segen der Weisheit", frFR = "Bénédiction de sagesse", esES = "Bendición de sabiduría", ptBR = "Bênção da Sabedoria", itIT = "Benedizione della Saggezza", ruRU = "Благословение мудрости", zhCN = "智慧祝福", zhTW = "智慧祝福", koKR = "지혜의 축복", jaJP = "知恵の祝福" },
  ["Blessing of Kings"] = { deDE = "Segen der Könige", frFR = "Bénédiction des rois", esES = "Bendición de reyes", ptBR = "Bênção dos Reis", itIT = "Benedizione dei Re", ruRU = "Благословение королей", zhCN = "王者祝福", zhTW = "王者祝福", koKR = "왕의 축복", jaJP = "王者の祝福" },
  ["Blessing of Salvation"] = { deDE = "Segen der Rettung", frFR = "Bénédiction de salut", esES = "Bendición de salvación", ptBR = "Bênção da Salvação", itIT = "Benedizione della Salvezza", ruRU = "Благословение спасения", zhCN = "拯救祝福", zhTW = "拯救祝福", koKR = "구원의 축복", jaJP = "救済の祝福" },
  ["Mark of the Wild (MotW)"] = { deDE = "Mal der Wildnis (MDW)", frFR = "Marque du fauve (MDF)", esES = "Marca de lo Salvaje (MotW)", ptBR = "Marca do Indomado (MotW)", itIT = "Marchio Selvaggio (MotW)", ruRU = "Знак дикой природы (MotW)", zhCN = "野性印记（MotW）", zhTW = "野性印記（MotW）", koKR = "야생의 징표 (MotW)", jaJP = "野生の印（MotW）" },
  ["Durability"] = { deDE = "Haltbarkeit", frFR = "Durabilité", esES = "Durabilidad", ptBR = "Durabilidade", itIT = "Integrità", ruRU = "Прочность", zhCN = "耐久度", zhTW = "耐久度", koKR = "내구도", jaJP = "耐久度" },
  ["Responses"] = { deDE = "Antworten", frFR = "Réponses", esES = "Respuestas", ptBR = "Respostas", itIT = "Risposte", ruRU = "Ответы", zhCN = "回应", zhTW = "回應", koKR = "응답", jaJP = "応答" },
  ["Grouped player name"] = { deDE = "Name des Gruppenmitglieds", frFR = "Nom du membre du groupe", esES = "Nombre del miembro del grupo", ptBR = "Nome do membro do grupo", itIT = "Nome del membro del gruppo", ruRU = "Имя участника группы", zhCN = "队伍成员名称", zhTW = "隊伍成員名稱", koKR = "파티원 이름", jaJP = "グループメンバー名" },
  ["Ready Status"] = { deDE = "Bereitschaft", frFR = "État de préparation", esES = "Estado de preparación", ptBR = "Status de prontidão", itIT = "Stato di prontezza", ruRU = "Состояние готовности", zhCN = "就绪状态", zhTW = "準備狀態", koKR = "준비 상태", jaJP = "準備状態" },
  ["Waiting, ready, or not ready"] = { deDE = "Wartend, bereit oder nicht bereit", frFR = "En attente, prêt ou pas prêt", esES = "Esperando, listo o no listo", ptBR = "Aguardando, pronto ou não pronto", itIT = "In attesa, pronto o non pronto", ruRU = "Ожидание, готов или не готов", zhCN = "等待、就绪或未就绪", zhTW = "等待、準備或未準備", koKR = "대기, 준비 또는 준비 안 됨", jaJP = "待機、準備完了、未準備" },
  ["Satisfied by a Flask, a Battle Elixir, a Guardian Elixir, or both elixirs."] = { deDE = "Erfüllt durch Fläschchen, Kampf- oder Wächterelixier oder beide Elixiere.", frFR = "Validé par un flacon, un élixir de bataille, un élixir du gardien ou les deux élixirs.", esES = "Se cumple con un frasco, un elixir de batalla, un elixir guardián o ambos elixires.", ptBR = "Atendido por um frasco, elixir de batalha, elixir guardião ou ambos.", itIT = "Soddisfatto da un tonico, un elisir da battaglia, un elisir del guardiano o entrambi.", ruRU = "Учитывается настой, боевой или охранный эликсир либо оба эликсира.", zhCN = "合剂、战斗药剂、守护药剂或两种药剂均可满足。", zhTW = "精煉藥劑、戰鬥藥劑、守護藥劑或兩種藥劑均可滿足。", koKR = "영약, 전투 비약, 수호 비약 또는 두 비약 모두로 충족됩니다.", jaJP = "フラスコ、バトルエリクサー、ガーディアンエリクサー、または両エリクサーで満たされます。" },
  ["Lowest equipped-item durability reported by MerfinPlus."] = { deDE = "Von MerfinPlus gemeldete niedrigste Haltbarkeit angelegter Gegenstände.", frFR = "Durabilité la plus basse de l’équipement signalée par MerfinPlus.", esES = "Durabilidad mínima del equipo informada por MerfinPlus.", ptBR = "Menor durabilidade do equipamento informada pelo MerfinPlus.", itIT = "Integrità minima dell’equipaggiamento segnalata da MerfinPlus.", ruRU = "Минимальная прочность экипировки по данным MerfinPlus.", zhCN = "MerfinPlus报告的已装备物品最低耐久度。", zhTW = "MerfinPlus回報的已裝備物品最低耐久度。", koKR = "MerfinPlus가 보고한 착용 장비의 최저 내구도입니다.", jaJP = "MerfinPlusが報告した装備品の最低耐久度です。" },
  ["MerfinPlus version reported by the player."] = { deDE = "Vom Spieler gemeldete MerfinPlus-Version.", frFR = "Version de MerfinPlus signalée par le joueur.", esES = "Versión de MerfinPlus informada por el jugador.", ptBR = "Versão do MerfinPlus informada pelo jogador.", itIT = "Versione di MerfinPlus segnalata dal giocatore.", ruRU = "Версия MerfinPlus, сообщённая игроком.", zhCN = "玩家报告的MerfinPlus版本。", zhTW = "玩家回報的MerfinPlus版本。", koKR = "플레이어가 보고한 MerfinPlus 버전입니다.", jaJP = "プレイヤーが報告したMerfinPlusのバージョンです。" },
  ["Directly read from visible group auras."] = { deDE = "Direkt aus sichtbaren Gruppenauren gelesen.", frFR = "Lu directement depuis les auras visibles du groupe.", esES = "Leído directamente de las auras visibles del grupo.", ptBR = "Lido diretamente das auras visíveis do grupo.", itIT = "Letto direttamente dalle aure visibili del gruppo.", ruRU = "Считывается напрямую с видимых эффектов группы.", zhCN = "直接读取可见的队伍光环。", zhTW = "直接讀取可見的隊伍光環。", koKR = "표시되는 파티 오라에서 직접 읽습니다.", jaJP = "表示中のグループオーラから直接読み取ります。" },
  ["MP: Ready Check (%d sec.)"] = { deDE = "MP: Bereitschaftscheck (%d Sek.)", frFR = "MP : Vérification des prêts (%d s)", esES = "MP: Comprobación de preparación (%d s)", ptBR = "MP: Verificação de prontidão (%d s)", itIT = "MP: Controllo di prontezza (%d sec.)", ruRU = "MP: Проверка готовности (%d сек.)", zhCN = "MP：就绪确认（%d秒）", zhTW = "MP：準備確認（%d秒）", koKR = "MP: 전투 준비 확인 (%d초)", jaJP = "MP: 準備確認（%d秒）" },
  ["Buff active"] = { deDE = "Buff aktiv", frFR = "Amélioration active", esES = "Beneficio activo", ptBR = "Bônus ativo", itIT = "Beneficio attivo", ruRU = "Эффект активен", zhCN = "增益生效", zhTW = "增益生效", koKR = "강화 효과 활성", jaJP = "バフ有効" },
  ["Remaining: %d:%02d"] = { deDE = "Verbleibend: %d:%02d", frFR = "Restant : %d:%02d", esES = "Restante: %d:%02d", ptBR = "Restante: %d:%02d", itIT = "Rimanente: %d:%02d", ruRU = "Осталось: %d:%02d", zhCN = "剩余：%d:%02d", zhTW = "剩餘：%d:%02d", koKR = "남은 시간: %d:%02d", jaJP = "残り: %d:%02d" },
  ["%s: Missing"] = { deDE = "%s: Fehlt", frFR = "%s : Manquant", esES = "%s: Falta", ptBR = "%s: Ausente", itIT = "%s: Mancante", ruRU = "%s: Отсутствует", zhCN = "%s：缺失", zhTW = "%s：缺少", koKR = "%s: 없음", jaJP = "%s: なし" },
  ["Reported: %s"] = { deDE = "Gemeldet: %s", frFR = "Signalé : %s", esES = "Informado: %s", ptBR = "Informado: %s", itIT = "Segnalato: %s", ruRU = "Сообщено: %s", zhCN = "报告：%s", zhTW = "回報：%s", koKR = "보고됨: %s", jaJP = "報告: %s" },
  ["Local: %s"] = { deDE = "Lokal: %s", frFR = "Local : %s", esES = "Local: %s", ptBR = "Local: %s", itIT = "Locale: %s", ruRU = "Локальная: %s", zhCN = "本地：%s", zhTW = "本機：%s", koKR = "로컬: %s", jaJP = "ローカル: %s" },
  ["Unknown"] = { deDE = "Unbekannt", frFR = "Inconnu", esES = "Desconocido", ptBR = "Desconhecido", itIT = "Sconosciuto", ruRU = "Неизвестно", zhCN = "未知", zhTW = "未知", koKR = "알 수 없음", jaJP = "不明" },
  ["Unknown until the player responds with MerfinPlus."] = { deDE = "Unbekannt, bis der Spieler mit MerfinPlus antwortet.", frFR = "Inconnu jusqu’à ce que le joueur réponde avec MerfinPlus.", esES = "Desconocido hasta que el jugador responda con MerfinPlus.", ptBR = "Desconhecido até o jogador responder com MerfinPlus.", itIT = "Sconosciuto finché il giocatore non risponde con MerfinPlus.", ruRU = "Неизвестно, пока игрок не ответит через MerfinPlus.", zhCN = "在玩家通过MerfinPlus回应前未知。", zhTW = "在玩家透過MerfinPlus回應前未知。", koKR = "플레이어가 MerfinPlus로 응답할 때까지 알 수 없습니다.", jaJP = "プレイヤーがMerfinPlusで応答するまで不明です。" },
  ["Unknown until the player responds."] = { deDE = "Unbekannt, bis der Spieler antwortet.", frFR = "Inconnu jusqu’à la réponse du joueur.", esES = "Desconocido hasta que el jugador responda.", ptBR = "Desconhecido até o jogador responder.", itIT = "Sconosciuto finché il giocatore non risponde.", ruRU = "Неизвестно, пока игрок не ответит.", zhCN = "在玩家回应前未知。", zhTW = "在玩家回應前未知。", koKR = "플레이어가 응답할 때까지 알 수 없습니다.", jaJP = "プレイヤーが応答するまで不明です。" },
  ["Missing"] = { deDE = "Fehlt", frFR = "Manquant", esES = "Falta", ptBR = "Ausente", itIT = "Mancante", ruRU = "Отсутствует", zhCN = "缺失", zhTW = "缺少", koKR = "없음", jaJP = "なし" },
  ["Expiring in 5 minutes or less."] = { deDE = "Läuft in höchstens 5 Minuten ab.", frFR = "Expire dans 5 minutes ou moins.", esES = "Expira en 5 minutos o menos.", ptBR = "Expira em 5 minutos ou menos.", itIT = "Scade tra 5 minuti o meno.", ruRU = "Закончится через 5 минут или раньше.", zhCN = "将在5分钟内到期。", zhTW = "將在5分鐘內到期。", koKR = "5분 이내에 만료됩니다.", jaJP = "5分以内に終了します。" },
  ["Ready Check - Missing %s: "] = { deDE = "Bereitschaftscheck - Fehlend %s: ", frFR = "Vérification - %s manquant : ", esES = "Comprobación - Falta %s: ", ptBR = "Verificação - Ausente %s: ", itIT = "Controllo - %s mancante: ", ruRU = "Проверка готовности — отсутствует %s: ", zhCN = "就绪确认 - 缺少%s：", zhTW = "準備確認 - 缺少%s：", koKR = "전투 준비 확인 - %s 없음: ", jaJP = "準備確認 - %sなし: " },
  ["Saved Imports"] = { deDE = "Gespeicherte Importe", frFR = "Imports enregistrés", esES = "Importaciones guardadas", ptBR = "Importações salvas", itIT = "Importazioni salvate", ruRU = "Сохранённые импорты", zhCN = "已保存导入", zhTW = "已儲存匯入", koKR = "저장된 가져오기", jaJP = "保存済みインポート" },
  ["Remove"] = { deDE = "Entfernen", frFR = "Supprimer", esES = "Eliminar", ptBR = "Remover", itIT = "Rimuovi", ruRU = "Удалить", zhCN = "移除", zhTW = "移除", koKR = "제거", jaJP = "削除" },
  ["Sync Full Assignments"] = { deDE = "Vollständige Zuweisungen synchronisieren", frFR = "Synchroniser toutes les affectations", esES = "Sincronizar todas las asignaciones", ptBR = "Sincronizar todas as atribuições", itIT = "Sincronizza tutte le assegnazioni", ruRU = "Синхронизировать все назначения", zhCN = "同步完整任务", zhTW = "同步完整指派", koKR = "전체 임무 동기화", jaJP = "全割り当てを同期" },
  ["Show Boss Plan"] = { deDE = "Bossplan anzeigen", frFR = "Afficher le plan du boss", esES = "Mostrar plan del jefe", ptBR = "Mostrar plano do chefe", itIT = "Mostra piano del boss", ruRU = "Показать план босса", zhCN = "显示首领计划", zhTW = "顯示首領計畫", koKR = "우두머리 계획 표시", jaJP = "ボスプランを表示" },
  ["Trash Assignments"] = { deDE = "Trash-Zuweisungen", frFR = "Affectations des groupes de monstres", esES = "Asignaciones de enemigos", ptBR = "Atribuições de inimigos", itIT = "Assegnazioni trash", ruRU = "Назначения на треш", zhCN = "小怪任务", zhTW = "小怪指派", koKR = "일반 몬스터 임무", jaJP = "雑魚割り当て" },
  ["Send Boss Assignments"] = { deDE = "Boss-Zuweisungen senden", frFR = "Envoyer les affectations du boss", esES = "Enviar asignaciones del jefe", ptBR = "Enviar atribuições do chefe", itIT = "Invia assegnazioni del boss", ruRU = "Отправить назначения босса", zhCN = "发送首领任务", zhTW = "傳送首領指派", koKR = "우두머리 임무 전송", jaJP = "ボス割り当てを送信" },
  ["Assignment Transport"] = { deDE = "Zuweisungsübertragung", frFR = "Transfert des affectations", esES = "Transferencia de asignaciones", ptBR = "Transferência de atribuições", itIT = "Trasferimento assegnazioni", ruRU = "Передача назначений", zhCN = "任务传输", zhTW = "指派傳輸", koKR = "임무 전송", jaJP = "割り当て転送" },
  ["Players %d/%d%s"] = { deDE = "Spieler %d/%d%s", frFR = "Joueurs %d/%d%s", esES = "Jugadores %d/%d%s", ptBR = "Jogadores %d/%d%s", itIT = "Giocatori %d/%d%s", ruRU = "Игроки %d/%d%s", zhCN = "玩家 %d/%d%s", zhTW = "玩家 %d/%d%s", koKR = "플레이어 %d/%d%s", jaJP = "プレイヤー %d/%d%s" },
  [" (preparing)"] = { deDE = " (wird vorbereitet)", frFR = " (préparation)", esES = " (preparando)", ptBR = " (preparando)", itIT = " (preparazione)", ruRU = " (подготовка)", zhCN = "（准备中）", zhTW = "（準備中）", koKR = " (준비 중)", jaJP = "（準備中）" },
  [" (discovering)"] = { deDE = " (Teilnehmer werden gesucht)", frFR = " (recherche)", esES = " (buscando)", ptBR = " (localizando)", itIT = " (ricerca)", ruRU = " (поиск)", zhCN = "（查找中）", zhTW = "（搜尋中）", koKR = " (검색 중)", jaJP = "（検索中）" },
  [" (complete)"] = { deDE = " (abgeschlossen)", frFR = " (terminé)", esES = " (completo)", ptBR = " (concluído)", itIT = " (completo)", ruRU = " (завершено)", zhCN = "（完成）", zhTW = "（完成）", koKR = " (완료)", jaJP = "（完了）" },
  [" (partial)"] = { deDE = " (teilweise)", frFR = " (partiel)", esES = " (parcial)", ptBR = " (parcial)", itIT = " (parziale)", ruRU = " (частично)", zhCN = "（部分）", zhTW = "（部分）", koKR = " (일부)", jaJP = "（一部）" },
  [" (local)"] = { deDE = " (lokal)", frFR = " (local)", esES = " (local)", ptBR = " (local)", itIT = " (locale)", ruRU = " (локально)", zhCN = "（本地）", zhTW = "（本機）", koKR = " (로컬)", jaJP = "（ローカル）" },
  [" (failed)"] = { deDE = " (fehlgeschlagen)", frFR = " (échec)", esES = " (fallido)", ptBR = " (falhou)", itIT = " (fallito)", ruRU = " (ошибка)", zhCN = "（失败）", zhTW = "（失敗）", koKR = " (실패)", jaJP = "（失敗）" },
  ["Import Raid Assignments"] = { deDE = "Raid-Zuweisungen importieren", frFR = "Importer les affectations de raid", esES = "Importar asignaciones de banda", ptBR = "Importar atribuições de raide", itIT = "Importa assegnazioni raid", ruRU = "Импортировать назначения рейда", zhCN = "导入团队任务", zhTW = "匯入團隊指派", koKR = "공격대 임무 가져오기", jaJP = "レイド割り当てをインポート" },
  ["Import one canonical MFPRA snapshot locally. This never sends addon data and does not require a group."] = { deDE = "Importiert lokal einen kanonischen MFPRA-Snapshot. Es werden keine Addondaten gesendet und keine Gruppe benötigt.", frFR = "Importe localement un instantané MFPRA canonique sans envoyer de données ni nécessiter de groupe.", esES = "Importa localmente una instantánea MFPRA canónica sin enviar datos ni requerir grupo.", ptBR = "Importa localmente um snapshot MFPRA canônico sem enviar dados nem exigir grupo.", itIT = "Importa localmente uno snapshot MFPRA canonico senza inviare dati né richiedere un gruppo.", ruRU = "Локально импортирует канонический снимок MFPRA без отправки данных и без требования группы.", zhCN = "在本地导入一个规范MFPRA快照，不发送插件数据，也不需要队伍。", zhTW = "在本機匯入一個標準MFPRA快照，不傳送插件資料，也不需要隊伍。", koKR = "표준 MFPRA 스냅샷 하나를 로컬로 가져옵니다. 애드온 데이터를 보내지 않으며 파티가 필요하지 않습니다.", jaJP = "正規MFPRAスナップショットをローカルにインポートします。アドオンデータは送信せず、グループも不要です。" },
  ["Explicitly broadcast the complete MFPRA assignment and Boss Plan snapshot."] = { deDE = "Sendet ausdrücklich den vollständigen MFPRA-Zuweisungs- und Bossplan-Snapshot.", frFR = "Diffuse explicitement l’instantané complet des affectations et plans de boss MFPRA.", esES = "Transmite explícitamente la instantánea completa de asignaciones y planes MFPRA.", ptBR = "Transmite explicitamente o snapshot completo de atribuições e planos MFPRA.", itIT = "Trasmette esplicitamente lo snapshot completo di assegnazioni e piani MFPRA.", ruRU = "Явно рассылает полный снимок назначений и планов боссов MFPRA.", zhCN = "明确广播完整的MFPRA任务和首领计划快照。", zhTW = "明確廣播完整的MFPRA指派和首領計畫快照。", koKR = "전체 MFPRA 임무 및 우두머리 계획 스냅샷을 명시적으로 전송합니다.", jaJP = "完全なMFPRA割り当て・ボスプランのスナップショットを明示的に配信します。" },
  ["Broadcast only the selected boss assignment/widget delta. Boss Plans are excluded."] = { deDE = "Sendet nur das Delta der ausgewählten Boss-Zuweisung/des Widgets. Bosspläne sind ausgeschlossen.", frFR = "Diffuse uniquement le delta d’affectation/widget du boss sélectionné, sans plan de boss.", esES = "Transmite solo el delta de asignación/widget del jefe seleccionado, sin planes.", ptBR = "Transmite apenas o delta de atribuição/widget do chefe selecionado, sem planos.", itIT = "Trasmette solo il delta di assegnazione/widget del boss selezionato, senza piani.", ruRU = "Отправляет только дельту назначений/виджета выбранного босса, без планов.", zhCN = "仅广播所选首领的任务/小组件增量，不包含首领计划。", zhTW = "僅廣播所選首領的指派/小工具增量，不包含首領計畫。", koKR = "선택한 우두머리 임무/위젯 변경분만 전송하며 우두머리 계획은 제외합니다.", jaJP = "選択したボスの割り当て/ウィジェット差分のみ配信し、ボスプランは除外します。" },
  ["Only the raid leader or an assistant can sync."] = { deDE = "Nur Raidleiter oder Assistenten können synchronisieren.", frFR = "Seul le chef de raid ou un assistant peut synchroniser.", esES = "Solo el líder de banda o un ayudante puede sincronizar.", ptBR = "Somente o líder ou um assistente pode sincronizar.", itIT = "Solo il capoincursione o un assistente può sincronizzare.", ruRU = "Синхронизацию может выполнять только лидер рейда или помощник.", zhCN = "只有团长或助理可以同步。", zhTW = "只有團長或助理可以同步。", koKR = "공격대장 또는 지원 담당자만 동기화할 수 있습니다.", jaJP = "レイドリーダーまたはアシスタントのみ同期できます。" },
  ["Only the raid leader or an assistant can send."] = { deDE = "Nur Raidleiter oder Assistenten können senden.", frFR = "Seul le chef de raid ou un assistant peut envoyer.", esES = "Solo el líder de banda o un ayudante puede enviar.", ptBR = "Somente o líder ou um assistente pode enviar.", itIT = "Solo il capoincursione o un assistente può inviare.", ruRU = "Отправлять может только лидер рейда или помощник.", zhCN = "只有团长或助理可以发送。", zhTW = "只有團長或助理可以傳送。", koKR = "공격대장 또는 지원 담당자만 전송할 수 있습니다.", jaJP = "レイドリーダーまたはアシスタントのみ送信できます。" },
  ["Select a raid and import an MFPRA snapshot with a Boss Plan to enable this button."] = { deDE = "Wähle einen Raid und importiere einen MFPRA-Snapshot mit Bossplan, um diese Schaltfläche zu aktivieren.", frFR = "Sélectionnez un raid et importez un instantané MFPRA avec plan de boss pour activer ce bouton.", esES = "Selecciona una banda e importa una instantánea MFPRA con plan para activar este botón.", ptBR = "Selecione um raide e importe um snapshot MFPRA com plano para ativar este botão.", itIT = "Seleziona un raid e importa uno snapshot MFPRA con piano per attivare il pulsante.", ruRU = "Выберите рейд и импортируйте снимок MFPRA с планом босса, чтобы включить кнопку.", zhCN = "选择团队副本并导入含首领计划的MFPRA快照以启用此按钮。", zhTW = "選擇團隊副本並匯入含首領計畫的MFPRA快照以啟用此按鈕。", koKR = "공격대를 선택하고 우두머리 계획이 포함된 MFPRA 스냅샷을 가져오면 이 버튼이 활성화됩니다.", jaJP = "レイドを選択し、ボスプラン付きMFPRAスナップショットをインポートすると有効になります。" },
  ["Open the complete imported MFPRA Boss Plan for the selected boss."] = { deDE = "Öffnet den vollständig importierten MFPRA-Bossplan für den ausgewählten Boss.", frFR = "Ouvre le plan de boss MFPRA complet importé pour le boss sélectionné.", esES = "Abre el plan MFPRA completo importado para el jefe seleccionado.", ptBR = "Abre o plano MFPRA completo importado para o chefe selecionado.", itIT = "Apre il piano MFPRA completo importato per il boss selezionato.", ruRU = "Открывает полный импортированный план MFPRA для выбранного босса.", zhCN = "打开所选首领的完整已导入MFPRA首领计划。", zhTW = "開啟所選首領的完整已匯入MFPRA首領計畫。", koKR = "선택한 우두머리의 전체 가져온 MFPRA 우두머리 계획을 엽니다.", jaJP = "選択したボスのインポート済み完全MFPRAボスプランを開きます。" },
  ["No imported MFPRA Boss Plan is available for the selected raid and boss."] = { deDE = "Für den ausgewählten Raid und Boss ist kein importierter MFPRA-Bossplan verfügbar.", frFR = "Aucun plan de boss MFPRA importé n’est disponible pour ce raid et ce boss.", esES = "No hay ningún plan MFPRA importado para la banda y el jefe seleccionados.", ptBR = "Nenhum plano MFPRA importado está disponível para o raide e chefe selecionados.", itIT = "Nessun piano MFPRA importato è disponibile per il raid e il boss selezionati.", ruRU = "Для выбранного рейда и босса нет импортированного плана MFPRA.", zhCN = "所选团队副本和首领没有可用的已导入MFPRA计划。", zhTW = "所選團隊副本和首領沒有可用的已匯入MFPRA計畫。", koKR = "선택한 공격대와 우두머리에 가져온 MFPRA 계획이 없습니다.", jaJP = "選択したレイドとボスに利用可能なインポート済みMFPRAプランがありません。" },
  ["Received from %s"] = { deDE = "Empfangen von %s", frFR = "Reçu de %s", esES = "Recibido de %s", ptBR = "Recebido de %s", itIT = "Ricevuto da %s", ruRU = "Получено от %s", zhCN = "接收自%s", zhTW = "接收自%s", koKR = "%s에게서 받음", jaJP = "%sから受信" },
  ["Received Sync"] = { deDE = "Empfangene Synchronisierung", frFR = "Synchronisation reçue", esES = "Sincronización recibida", ptBR = "Sincronização recebida", itIT = "Sincronizzazione ricevuta", ruRU = "Полученная синхронизация", zhCN = "已接收同步", zhTW = "已接收同步", koKR = "받은 동기화", jaJP = "受信した同期" },
  ["Preparing the explicit assignment transfer."] = { deDE = "Explizite Zuweisungsübertragung wird vorbereitet.", frFR = "Préparation du transfert explicite des affectations.", esES = "Preparando la transferencia explícita de asignaciones.", ptBR = "Preparando a transferência explícita de atribuições.", itIT = "Preparazione del trasferimento esplicito delle assegnazioni.", ruRU = "Подготовка явной передачи назначений.", zhCN = "正在准备显式任务传输。", zhTW = "正在準備明確指派傳輸。", koKR = "명시적 임무 전송을 준비 중입니다.", jaJP = "明示的な割り当て転送を準備しています。" },
  ["The sender completed the transfer locally; there were no other group participants."] = { deDE = "Der Sender hat die Übertragung lokal abgeschlossen; es gab keine weiteren Gruppenteilnehmer.", frFR = "L’expéditeur a terminé le transfert localement ; aucun autre membre du groupe n’était présent.", esES = "El remitente completó la transferencia localmente; no había más miembros del grupo.", ptBR = "O remetente concluiu a transferência localmente; não havia outros participantes.", itIT = "Il mittente ha completato il trasferimento localmente; non c’erano altri membri del gruppo.", ruRU = "Отправитель завершил передачу локально; других участников группы не было.", zhCN = "发送者已在本地完成传输；没有其他队伍成员。", zhTW = "傳送者已在本機完成傳輸；沒有其他隊伍成員。", koKR = "보낸 사람이 로컬 전송을 완료했으며 다른 파티원이 없습니다.", jaJP = "送信者はローカルで転送を完了しました。他のグループ参加者はいません。" },
  ["%d of %d group participants completed the transfer; %d rejected and %d did not confirm. No retry was queued."] = { deDE = "%d von %d Gruppenteilnehmern haben die Übertragung abgeschlossen; %d lehnten ab und %d bestätigten nicht. Keine Wiederholung eingeplant.", frFR = "%d membres sur %d ont terminé le transfert ; %d ont refusé et %d n’ont pas confirmé. Aucun nouvel essai prévu.", esES = "%d de %d miembros completaron la transferencia; %d rechazaron y %d no confirmaron. No se programó reintento.", ptBR = "%d de %d participantes concluíram; %d rejeitaram e %d não confirmaram. Nenhuma nova tentativa foi agendada.", itIT = "%d di %d membri hanno completato; %d hanno rifiutato e %d non hanno confermato. Nessun nuovo tentativo.", ruRU = "%d из %d участников завершили передачу; %d отклонили и %d не подтвердили. Повтор не запланирован.", zhCN = "%d/%d名队伍成员完成传输；%d名拒绝，%d名未确认。未安排重试。", zhTW = "%d/%d名隊伍成員完成傳輸；%d名拒絕，%d名未確認。未安排重試。", koKR = "파티원 %d/%d명이 전송을 완료했고 %d명이 거부했으며 %d명이 확인하지 않았습니다. 재시도하지 않습니다.", jaJP = "%d/%d人が転送を完了し、%d人が拒否、%d人が未確認です。再試行は予約されていません。" },
  ["All %d group participants completed the transfer."] = { deDE = "Alle %d Gruppenteilnehmer haben die Übertragung abgeschlossen.", frFR = "Les %d membres du groupe ont terminé le transfert.", esES = "Los %d miembros del grupo completaron la transferencia.", ptBR = "Todos os %d participantes concluíram a transferência.", itIT = "Tutti i %d membri del gruppo hanno completato il trasferimento.", ruRU = "Все %d участников группы завершили передачу.", zhCN = "全部%d名队伍成员完成传输。", zhTW = "全部%d名隊伍成員完成傳輸。", koKR = "파티원 %d명 모두 전송을 완료했습니다.", jaJP = "グループ参加者%d人全員が転送を完了しました。" },
  ["1 of %d group participants completed locally; %d offline peer(s) could not confirm. No retry was queued."] = { deDE = "1 von %d Gruppenteilnehmern lokal abgeschlossen; %d Offline-Teilnehmer konnten nicht bestätigen. Keine Wiederholung eingeplant.", frFR = "1 membre sur %d a terminé localement ; %d membre(s) hors ligne n’ont pas pu confirmer. Aucun nouvel essai prévu.", esES = "1 de %d miembros completó localmente; %d miembro(s) sin conexión no confirmaron. No se programó reintento.", ptBR = "1 de %d participantes concluiu localmente; %d offline não puderam confirmar. Nenhuma nova tentativa foi agendada.", itIT = "1 di %d membri ha completato localmente; %d offline non hanno potuto confermare. Nessun nuovo tentativo.", ruRU = "1 из %d участников завершил локально; %d офлайн-участников не подтвердили. Повтор не запланирован.", zhCN = "%d名成员中1名在本地完成；%d名离线成员无法确认。未安排重试。", zhTW = "%d名成員中1名在本機完成；%d名離線成員無法確認。未安排重試。", koKR = "파티원 %d명 중 1명이 로컬로 완료했으며 오프라인 %d명은 확인하지 못했습니다. 재시도하지 않습니다.", jaJP = "%d人中1人がローカルで完了し、オフラインの%d人は確認できませんでした。再試行はありません。" },
  ["The sender completed locally; waiting for %d online group peer confirmation(s)."] = { deDE = "Sender lokal abgeschlossen; warte auf Bestätigung von %d Online-Gruppenteilnehmer(n).", frFR = "Expéditeur terminé localement ; attente de %d confirmation(s) en ligne.", esES = "El remitente completó localmente; esperando %d confirmación(es) en línea.", ptBR = "Remetente concluiu localmente; aguardando %d confirmação(ões) online.", itIT = "Mittente completato localmente; attesa di %d conferma/e online.", ruRU = "Отправитель завершил локально; ожидание подтверждений от %d участников онлайн.", zhCN = "发送者已在本地完成；等待%d名在线成员确认。", zhTW = "傳送者已在本機完成；等待%d名線上成員確認。", koKR = "보낸 사람은 로컬로 완료했으며 온라인 파티원 %d명의 확인을 기다립니다.", jaJP = "送信者はローカルで完了し、オンラインメンバー%d人の確認を待っています。" },
  ["The transfer could not be submitted to the addon-message transport."] = { deDE = "Die Übertragung konnte nicht an den Addon-Nachrichtentransport übergeben werden.", frFR = "Le transfert n’a pas pu être soumis au transport de messages d’addon.", esES = "No se pudo enviar la transferencia al transporte de mensajes del addon.", ptBR = "Não foi possível enviar a transferência ao transporte de mensagens do addon.", itIT = "Impossibile inviare il trasferimento al trasporto dei messaggi addon.", ruRU = "Не удалось передать данные в транспорт сообщений аддона.", zhCN = "无法将传输提交到插件消息通道。", zhTW = "無法將傳輸提交到插件訊息通道。", koKR = "애드온 메시지 전송에 제출하지 못했습니다.", jaJP = "アドオンメッセージ転送に送信できませんでした。" },
  ["Sending Boss Plan..."] = { deDE = "Bossplan wird gesendet...", frFR = "Envoi du plan du boss...", esES = "Enviando plan del jefe...", ptBR = "Enviando plano do chefe...", itIT = "Invio piano del boss...", ruRU = "Отправка плана босса...", zhCN = "正在发送首领计划...", zhTW = "正在傳送首領計畫...", koKR = "우두머리 계획 전송 중...", jaJP = "ボスプランを送信中..." },
  ["Sending assignments..."] = { deDE = "Zuweisungen werden gesendet...", frFR = "Envoi des affectations...", esES = "Enviando asignaciones...", ptBR = "Enviando atribuições...", itIT = "Invio assegnazioni...", ruRU = "Отправка назначений...", zhCN = "正在发送任务...", zhTW = "正在傳送指派...", koKR = "임무 전송 중...", jaJP = "割り当てを送信中..." },
  ["%s confirmed receipt."] = { deDE = "%s hat den Empfang bestätigt.", frFR = "%s a confirmé la réception.", esES = "%s confirmó la recepción.", ptBR = "%s confirmou o recebimento.", itIT = "%s ha confermato la ricezione.", ruRU = "%s подтвердил получение.", zhCN = "%s已确认接收。", zhTW = "%s已確認接收。", koKR = "%s님이 수신을 확인했습니다.", jaJP = "%sが受信を確認しました。" },
  ["%d of %d group participants completed the transfer."] = { deDE = "%d von %d Gruppenteilnehmern haben die Übertragung abgeschlossen.", frFR = "%d membres sur %d ont terminé le transfert.", esES = "%d de %d miembros completaron la transferencia.", ptBR = "%d de %d participantes concluíram a transferência.", itIT = "%d di %d membri hanno completato il trasferimento.", ruRU = "%d из %d участников завершили передачу.", zhCN = "%d/%d名队伍成员完成传输。", zhTW = "%d/%d名隊伍成員完成傳輸。", koKR = "파티원 %d/%d명이 전송을 완료했습니다.", jaJP = "%d/%d人が転送を完了しました。" },
  ["Receiver rejected MFPRA transfer: %s"] = { deDE = "Empfänger lehnte die MFPRA-Übertragung ab: %s", frFR = "Le destinataire a refusé le transfert MFPRA : %s", esES = "El receptor rechazó la transferencia MFPRA: %s", ptBR = "O destinatário rejeitou a transferência MFPRA: %s", itIT = "Il destinatario ha rifiutato il trasferimento MFPRA: %s", ruRU = "Получатель отклонил передачу MFPRA: %s", zhCN = "接收者拒绝MFPRA传输：%s", zhTW = "接收者拒絕MFPRA傳輸：%s", koKR = "수신자가 MFPRA 전송을 거부했습니다: %s", jaJP = "受信者がMFPRA転送を拒否しました: %s" },
  ["A recipient rejected the transfer; %d of %d candidates have responded."] = { deDE = "Ein Empfänger lehnte ab; %d von %d Teilnehmern haben geantwortet.", frFR = "Un destinataire a refusé ; %d candidats sur %d ont répondu.", esES = "Un receptor rechazó; respondieron %d de %d candidatos.", ptBR = "Um destinatário rejeitou; %d de %d candidatos responderam.", itIT = "Un destinatario ha rifiutato; hanno risposto %d di %d candidati.", ruRU = "Получатель отклонил передачу; ответили %d из %d кандидатов.", zhCN = "一名接收者拒绝传输；%d/%d名候选者已回应。", zhTW = "一名接收者拒絕傳輸；%d/%d名候選者已回應。", koKR = "수신자 한 명이 전송을 거부했으며 후보 %d/%d명이 응답했습니다.", jaJP = "受信者が転送を拒否し、候補%d/%d人が応答しました。" },
  ["Received from %s."] = { deDE = "Empfangen von %s.", frFR = "Reçu de %s.", esES = "Recibido de %s.", ptBR = "Recebido de %s.", itIT = "Ricevuto da %s.", ruRU = "Получено от %s.", zhCN = "接收自%s。", zhTW = "接收自%s。", koKR = "%s에게서 받았습니다.", jaJP = "%sから受信しました。" },
  ["Saved Raid Assignments"] = { deDE = "Gespeicherte Raid-Zuweisungen", frFR = "Affectations de raid enregistrées", esES = "Asignaciones de banda guardadas", ptBR = "Atribuições de raide salvas", itIT = "Assegnazioni raid salvate", ruRU = "Сохранённые назначения рейда", zhCN = "已保存团队任务", zhTW = "已儲存團隊指派", koKR = "저장된 공격대 임무", jaJP = "保存済みレイド割り当て" },
  ["Raid Assignments entry is unavailable."] = { deDE = "Der Raid-Zuweisungseintrag ist nicht verfügbar.", frFR = "L’entrée d’affectations de raid est indisponible.", esES = "La entrada de asignaciones de banda no está disponible.", ptBR = "A entrada de atribuições de raide não está disponível.", itIT = "La voce delle assegnazioni raid non è disponibile.", ruRU = "Запись назначений рейда недоступна.", zhCN = "团队任务条目不可用。", zhTW = "團隊指派項目不可用。", koKR = "공격대 임무 항목을 사용할 수 없습니다.", jaJP = "レイド割り当て項目を利用できません。" },
  ["Saved Raid Assignments import is unavailable."] = { deDE = "Der gespeicherte Raid-Zuweisungsimport ist nicht verfügbar.", frFR = "L’import d’affectations de raid enregistré est indisponible.", esES = "La importación guardada de asignaciones de banda no está disponible.", ptBR = "A importação salva de atribuições de raide não está disponível.", itIT = "L’importazione salvata delle assegnazioni raid non è disponibile.", ruRU = "Сохранённый импорт назначений рейда недоступен.", zhCN = "已保存的团队任务导入不可用。", zhTW = "已儲存的團隊指派匯入不可用。", koKR = "저장된 공격대 임무 가져오기를 사용할 수 없습니다.", jaJP = "保存済みレイド割り当てインポートを利用できません。" },
  ["No imported assignments exist for this boss."] = { deDE = "Für diesen Boss sind keine importierten Zuweisungen vorhanden.", frFR = "Aucune affectation importée n’existe pour ce boss.", esES = "No hay asignaciones importadas para este jefe.", ptBR = "Não há atribuições importadas para este chefe.", itIT = "Non esistono assegnazioni importate per questo boss.", ruRU = "Для этого босса нет импортированных назначений.", zhCN = "此首领没有已导入任务。", zhTW = "此首領沒有已匯入指派。", koKR = "이 우두머리에 가져온 임무가 없습니다.", jaJP = "このボスにはインポート済み割り当てがありません。" },
  ["Invalid MFPRA Raid Assignments string."] = { deDE = "Ungültiger MFPRA-Raid-Zuweisungsstring.", frFR = "Chaîne d’affectations de raid MFPRA invalide.", esES = "Cadena MFPRA de asignaciones de banda no válida.", ptBR = "String MFPRA de atribuições de raide inválida.", itIT = "Stringa MFPRA delle assegnazioni raid non valida.", ruRU = "Недопустимая строка назначений рейда MFPRA.", zhCN = "无效的MFPRA团队任务字符串。", zhTW = "無效的MFPRA團隊指派字串。", koKR = "잘못된 MFPRA 공격대 임무 문자열입니다.", jaJP = "無効なMFPRAレイド割り当て文字列です。" },
  ["Identical MFPRA snapshot selected locally. Nothing was sent."] = { deDE = "Identischer MFPRA-Snapshot lokal ausgewählt. Nichts wurde gesendet.", frFR = "Instantané MFPRA identique sélectionné localement. Rien n’a été envoyé.", esES = "Instantánea MFPRA idéntica seleccionada localmente. No se envió nada.", ptBR = "Snapshot MFPRA idêntico selecionado localmente. Nada foi enviado.", itIT = "Snapshot MFPRA identico selezionato localmente. Nulla è stato inviato.", ruRU = "Локально выбран идентичный снимок MFPRA. Ничего не отправлено.", zhCN = "已在本地选择相同MFPRA快照，未发送任何内容。", zhTW = "已在本機選擇相同MFPRA快照，未傳送任何內容。", koKR = "동일한 MFPRA 스냅샷을 로컬에서 선택했습니다. 전송된 내용은 없습니다.", jaJP = "同一のMFPRAスナップショットをローカルで選択しました。送信はありません。" },
  ["MFPRA Raid Assignments imported locally. Nothing was sent."] = { deDE = "MFPRA-Raid-Zuweisungen lokal importiert. Nichts wurde gesendet.", frFR = "Affectations de raid MFPRA importées localement. Rien n’a été envoyé.", esES = "Asignaciones MFPRA importadas localmente. No se envió nada.", ptBR = "Atribuições MFPRA importadas localmente. Nada foi enviado.", itIT = "Assegnazioni raid MFPRA importate localmente. Nulla è stato inviato.", ruRU = "Назначения рейда MFPRA импортированы локально. Ничего не отправлено.", zhCN = "已在本地导入MFPRA团队任务，未发送任何内容。", zhTW = "已在本機匯入MFPRA團隊指派，未傳送任何內容。", koKR = "MFPRA 공격대 임무를 로컬로 가져왔습니다. 전송된 내용은 없습니다.", jaJP = "MFPRAレイド割り当てをローカルにインポートしました。送信はありません。" },
  ["Saved Raid Assignments import selected, but it cannot be loaded. You can remove it safely."] = { deDE = "Gespeicherter Raid-Zuweisungsimport ausgewählt, kann aber nicht geladen werden. Er kann sicher entfernt werden.", frFR = "Import enregistré sélectionné, mais impossible à charger. Vous pouvez le supprimer sans risque.", esES = "Importación guardada seleccionada, pero no puede cargarse. Puedes eliminarla con seguridad.", ptBR = "Importação salva selecionada, mas não pode ser carregada. Pode removê-la com segurança.", itIT = "Importazione salvata selezionata, ma non può essere caricata. Puoi rimuoverla in sicurezza.", ruRU = "Сохранённый импорт выбран, но не загружается. Его можно безопасно удалить.", zhCN = "已选择保存的团队任务导入，但无法加载，可安全移除。", zhTW = "已選擇儲存的團隊指派匯入，但無法載入，可安全移除。", koKR = "저장된 공격대 임무 가져오기를 선택했지만 불러올 수 없습니다. 안전하게 제거할 수 있습니다.", jaJP = "保存済みレイド割り当てを選択しましたが読み込めません。安全に削除できます。" },
  ["Saved Raid Assignments import loaded."] = { deDE = "Gespeicherter Raid-Zuweisungsimport geladen.", frFR = "Import d’affectations de raid chargé.", esES = "Importación de asignaciones de banda cargada.", ptBR = "Importação de atribuições de raide carregada.", itIT = "Importazione delle assegnazioni raid caricata.", ruRU = "Сохранённый импорт назначений загружен.", zhCN = "已加载保存的团队任务导入。", zhTW = "已載入儲存的團隊指派匯入。", koKR = "저장된 공격대 임무 가져오기를 불러왔습니다.", jaJP = "保存済みレイド割り当てを読み込みました。" },
  ["Saved Raid Assignments import removed."] = { deDE = "Gespeicherter Raid-Zuweisungsimport entfernt.", frFR = "Import d’affectations de raid supprimé.", esES = "Importación de asignaciones de banda eliminada.", ptBR = "Importação de atribuições de raide removida.", itIT = "Importazione delle assegnazioni raid rimossa.", ruRU = "Сохранённый импорт назначений удалён.", zhCN = "已移除保存的团队任务导入。", zhTW = "已移除儲存的團隊指派匯入。", koKR = "저장된 공격대 임무 가져오기를 제거했습니다.", jaJP = "保存済みレイド割り当てを削除しました。" },
  ["Full Raid Assignments sync is unavailable."] = { deDE = "Die vollständige Raid-Zuweisungssynchronisierung ist nicht verfügbar.", frFR = "La synchronisation complète des affectations est indisponible.", esES = "La sincronización completa de asignaciones no está disponible.", ptBR = "A sincronização completa de atribuições não está disponível.", itIT = "La sincronizzazione completa delle assegnazioni non è disponibile.", ruRU = "Полная синхронизация назначений недоступна.", zhCN = "完整团队任务同步不可用。", zhTW = "完整團隊指派同步不可用。", koKR = "전체 공격대 임무 동기화를 사용할 수 없습니다.", jaJP = "全レイド割り当て同期を利用できません。" },
  ["Boss Plan is unavailable."] = { deDE = "Der Bossplan ist nicht verfügbar.", frFR = "Le plan du boss est indisponible.", esES = "El plan del jefe no está disponible.", ptBR = "O plano do chefe não está disponível.", itIT = "Il piano del boss non è disponibile.", ruRU = "План босса недоступен.", zhCN = "首领计划不可用。", zhTW = "首領計畫不可用。", koKR = "우두머리 계획을 사용할 수 없습니다.", jaJP = "ボスプランを利用できません。" },
  ["Import an MFPRA Boss Plan first."] = { deDE = "Importiere zuerst einen MFPRA-Bossplan.", frFR = "Importez d’abord un plan de boss MFPRA.", esES = "Importa primero un plan MFPRA.", ptBR = "Importe primeiro um plano MFPRA.", itIT = "Importa prima un piano MFPRA.", ruRU = "Сначала импортируйте план босса MFPRA.", zhCN = "请先导入MFPRA首领计划。", zhTW = "請先匯入MFPRA首領計畫。", koKR = "먼저 MFPRA 우두머리 계획을 가져오세요.", jaJP = "先にMFPRAボスプランをインポートしてください。" },
}
for key, values in pairs(featureStrings) do
  AddFeatureString(key, values)
end

local translations = { enUS = enUS }
for _, locale in ipairs(LOCALE_ORDER) do
  if locale ~= "enUS" then
    local fallback = locale == "esMX" and translations.esES or enUS
    translations[locale] = setmetatable(overrides[locale] or {}, { __index = fallback })
  end
end

local reverse = {}
for _, locale in ipairs(LOCALE_ORDER) do
  reverse[locale] = {}
  for key in pairs(enUS) do
    reverse[locale][translations[locale][key]] = key
  end
end

function MerfinPlus:RegisterUIString(key, localized)
  key = tostring(key or "")
  if key == "" then
    return
  end
  enUS[key] = (type(localized) == "table" and localized.enUS) or key
  for _, locale in ipairs(LOCALE_ORDER) do
    if locale ~= "enUS" then
      local cjkValue = cjkTranslations[locale] and cjkTranslations[locale][key]
      if cjkValue then
        overrides[locale][key] = cjkValue
      elseif type(localized) == "table" and localized[locale] then
        overrides[locale][key] = localized[locale]
      end
    end
    reverse[locale][translations[locale][key]] = key
  end
end

local contentNameKeys = { raid = {}, boss = {}, mechanic = {}, enemy = {} }

function MerfinPlus:RegisterLocalizedContentName(kind, id, canonicalName, localized)
  if not contentNameKeys[kind] or id == nil then
    return
  end
  canonicalName = tostring(canonicalName or "")
  contentNameKeys[kind][tostring(id)] = canonicalName
  self:RegisterUIString(canonicalName, localized)
end

function MerfinPlus:RegisterLocalizedContentAlias(kind, id, canonicalName)
  if not contentNameKeys[kind] or id == nil then
    return
  end
  contentNameKeys[kind][tostring(id)] = tostring(canonicalName or "")
end

function MerfinPlus:GetLocalizedContentName(kind, id, fallback)
  local key = contentNameKeys[kind] and contentNameKeys[kind][tostring(id)]
  return self:T(key or fallback or "")
end

function MerfinPlus:GetLocalizedContentKey(kind, id)
  return contentNameKeys[kind] and contentNameKeys[kind][tostring(id)]
end

function MerfinPlus:GetUIStringForLocale(key, locale)
  return (translations[locale] and translations[locale][key]) or enUS[key] or key
end

function MerfinPlus:GetLocalizedRaidName(id, fallback)
  return self:GetLocalizedContentName("raid", id, fallback)
end

function MerfinPlus:GetLocalizedBossName(id, fallback)
  return self:GetLocalizedContentName("boss", id, fallback)
end

function MerfinPlus:GetLocalizedMechanicName(id, fallback)
  return self:GetLocalizedContentName("mechanic", id, fallback)
end

function MerfinPlus:GetLocalizedRaidCooldownName(id, spellID, fallback)
  local locale = self:GetUILocale()
  local manual = self.RaidCooldownManualTranslations
  local manualName = manual and manual[id] and manual[id][locale]
  if manualName and manualName ~= "" then
    return manualName
  end

  local spells = self.RaidCooldownSpellTranslations
  local spellName = spellID and spells and spells[tonumber(spellID)] and spells[tonumber(spellID)][locale]
  if spellName and spellName ~= "" then
    return spellName
  end

  return self:GetLocalizedMechanicName(id, fallback)
end

function MerfinPlus:GetLocalizedEnemyName(id, fallback)
  local locale = self:GetUILocale()
  local npcNames = self.AutoMarkerNPCTranslations
  local localized = npcNames and npcNames[locale] and npcNames[locale][tonumber(id)]
  if localized and localized ~= "" then
    return localized
  end
  return self:GetLocalizedContentName("enemy", id, fallback)
end

local SCRIPT_FALLBACKS = {
  ruRU = "Fonts\\FRIZQT___CYR.TTF",
  latin = "Fonts\\FRIZQT__.TTF",
}
local LOCAL_UNICODE_FALLBACK =
  "Interface\\AddOns\\MerfinPlus\\Media\\font\\PTSansNarrow-Bold.ttf"
local LOCAL_CHINESE_FALLBACK =
  "Interface\\AddOns\\MerfinPlus\\Media\\font\\CN Merged (SF-Yahee).ttf"
local LOCAL_CJK_FALLBACK =
  "Interface\\AddOns\\MerfinPlus\\Media\\font\\NotoSansCJKkr-Regular.otf"
local VERIFIED_CYRILLIC_FONTS = {
  ["archivonarrow-bold.ttf"] = true,
  ["cn merged (sf-yahee).ttf"] = true,
  ["expressway.ttf"] = true,
  ["hooge.ttf"] = true,
  ["ptsansnarrow-bold.ttf"] = true,
  ["ptsansnarrow.ttf"] = true,
  ["sfuidisplaycondensed-bold.otf"] = true,
  ["sfuidisplaycondensed-semibold.otf"] = true,
  ["frizqt___cyr.ttf"] = true,
}
local VERIFIED_LATIN_EXTENDED_FONTS = {
  ["archivonarrow-bold.ttf"] = true,
  ["cn merged (sf-yahee).ttf"] = true,
  ["expressway.ttf"] = true,
  ["ptsansnarrow-bold.ttf"] = true,
  ["ptsansnarrow.ttf"] = true,
  ["sfuidisplaycondensed-bold.otf"] = true,
  ["sfuidisplaycondensed-semibold.otf"] = true,
  ["frizqt__.ttf"] = true,
}

local function FontFileName(path)
  local fileName = tostring(path or ""):gsub("/", "\\"):match("([^\\]+)$")
  return fileName and fileName:lower() or ""
end

local function IsValidFontPath(path)
  if type(path) ~= "string" or path == "" then
    return false
  end
  local lowerPath = path:lower()
  return lowerPath:match("%.ttf$") ~= nil or lowerPath:match("%.otf$") ~= nil
end

local function IsValidFontHeight(height)
  return type(height) == "number" and height == height and height > 0
end

function MerfinPlus:SafeSetFontPath(fontObject, fontFile, height, flags)
  if not fontObject or type(fontObject.SetFont) ~= "function"
    or not IsValidFontPath(fontFile) or not IsValidFontHeight(height)
  then
    return false
  end

  local setter = fontObject.SetFont
  local ok, applied
  if type(flags) == "string" and flags ~= "" then
    ok, applied = pcall(setter, fontObject, fontFile, height, flags)
  else
    ok, applied = pcall(setter, fontObject, fontFile, height)
  end
  return ok and applied ~= false
end

function MerfinPlus:SafeSetFontObject(fontRegion, systemFontObject)
  if not fontRegion or type(fontRegion.SetFontObject) ~= "function" or not systemFontObject then
    return false
  end
  local ok, applied = pcall(fontRegion.SetFontObject, fontRegion, systemFontObject)
  return ok and applied ~= false
end

do
  local calls = {}
  local probe = {
    SetFont = function(_, ...)
      calls[#calls + 1] = { count = select("#", ...), ... }
      return true
    end,
  }
  assert(
    MerfinPlus:SafeSetFontPath(probe, "LeftButton", false, nil) == false and #calls == 0,
    "MerfinPlus font guard must reject button callback values"
  )
  assert(
    MerfinPlus:SafeSetFontPath(probe, SCRIPT_FALLBACKS.ruRU, 14, false) == true
      and calls[1].count == 2 and calls[1][2] == 14,
    "MerfinPlus font guard must accept the Cyrillic fallback with a numeric height"
  )
  assert(
    MerfinPlus:SafeSetFontPath(probe, SCRIPT_FALLBACKS.latin, 14, "") == true
      and calls[2].count == 2 and calls[2][2] == 14,
    "MerfinPlus font guard must accept the Latin fallback with a numeric height"
  )
end

function MerfinPlus:ResolveLocalizedFontPath(requestedPath)
  local locale = self:GetUILocale()
  local clientLocale = (GAME_LOCALE or (GetLocale and GetLocale())) or "enUS"
  if locale == "zhCN" or locale == "zhTW" or locale == "jaJP" then
    -- The bundled CJK font keeps the manual language dropdown readable even
    -- on a non-Chinese client; native Chinese clients retain Blizzard's font.
    if clientLocale ~= "zhCN" and clientLocale ~= "zhTW" then
      return LOCAL_CHINESE_FALLBACK, true
    end
    return STANDARD_TEXT_FONT, true
  end
  if locale == "koKR" then
    return LOCAL_CJK_FALLBACK, true
  end
  local fileName = FontFileName(requestedPath)
  if locale == "ruRU" and not VERIFIED_CYRILLIC_FONTS[fileName] then
    return SCRIPT_FALLBACKS.ruRU, true
  end
  if locale ~= "enUS" and locale ~= "ruRU"
    and not VERIFIED_LATIN_EXTENDED_FONTS[fileName]
  then
    return SCRIPT_FALLBACKS.latin, true
  end
  return requestedPath, false
end

function MerfinPlus:ApplyLocalizedFont(fontObject, requestedPath, size, flags)
  if not fontObject then
    return
  end
  if not IsValidFontHeight(size) then
    self:SafeSetFontObject(fontObject, _G and _G.GameFontNormal)
    return
  end
  local resolved = self:ResolveLocalizedFontPath(requestedPath)
  local function Apply(path)
    return self:SafeSetFontPath(fontObject, path, size, flags)
  end
  if Apply(resolved) then
    return resolved
  end
  local locale = self:GetUILocale()
  if locale == "zhCN" or locale == "zhTW" or locale == "koKR" or locale == "jaJP" then
    if (locale == "zhCN" or locale == "zhTW" or locale == "jaJP") and Apply(LOCAL_CHINESE_FALLBACK) then
      return LOCAL_CHINESE_FALLBACK
    end
    if locale == "koKR" and Apply(LOCAL_CJK_FALLBACK) then
      return LOCAL_CJK_FALLBACK
    end
    if Apply(STANDARD_TEXT_FONT) then
      return STANDARD_TEXT_FONT
    end
    if self:SafeSetFontObject(fontObject, _G and _G.GameFontNormal) then
      return "GameFontNormal"
    end
  end
  local localeFallback = locale == "ruRU" and SCRIPT_FALLBACKS.ruRU or SCRIPT_FALLBACKS.latin
  if Apply(localeFallback) then
    return localeFallback
  end
  if Apply(STANDARD_TEXT_FONT) then
    return STANDARD_TEXT_FONT
  end
  if Apply(LOCAL_UNICODE_FALLBACK) then
    return LOCAL_UNICODE_FALLBACK
  end
  if self:SafeSetFontObject(fontObject, _G and _G.GameFontNormal) then
    return "GameFontNormal"
  end
end

function MerfinPlus:ApplyLocalizedFontsToFrame(root)
  if not root then
    return
  end
  local seen = {}
  local function ApplyObject(object)
    if not object or seen[object] then
      return
    end
    seen[object] = true

    if type(object.GetFont) == "function" and type(object.SetFont) == "function" then
      local ok, fontPath, size, flags = pcall(object.GetFont, object)
      if ok and type(size) == "number" and size > 0 then
        self:ApplyLocalizedFont(object, fontPath, size, flags)
      end
    end
    if type(object.GetRegions) == "function" then
      for _, region in ipairs({ object:GetRegions() }) do
        ApplyObject(region)
      end
    end
    if type(object.GetChildren) == "function" then
      for _, child in ipairs({ object:GetChildren() }) do
        ApplyObject(child)
      end
    end
  end
  ApplyObject(root)
end

function MerfinPlus:UTF8Characters(value)
  local text = tostring(value or "")
  local result, index, length = {}, 1, #text
  while index <= length do
    local byte = text:byte(index)
    local count = 1
    if byte and byte >= 240 then
      count = 4
    elseif byte and byte >= 224 then
      count = 3
    elseif byte and byte >= 192 then
      count = 2
    end
    result[#result + 1] = text:sub(index, math.min(length, index + count - 1))
    index = index + count
  end
  return result
end

local semanticKeys = {
  warrior = "Warrior", paladin = "Paladin", hunter = "Hunter", rogue = "Rogue",
  priest = "Priest", shaman = "Shaman", mage = "Mage", warlock = "Warlock", druid = "Druid",
  tank = "Tank", healer = "Healer", heal = "Healer", dps = "Damage", damage = "Damage",
  players = "Players", main = "Main", backup = "Backup", assigned = "Assigned",
  maintarget = "Main Target", offtarget = "Off Target",
  bloodlust = "Bloodlust", heroism = "Heroism", soulstone = "Soulstone",
  innervate = "Innervate", misdirection = "Misdirection",
  star = "Star", circle = "Circle", diamond = "Diamond", triangle = "Triangle",
  moon = "Moon", square = "Square", cross = "Cross", skull = "Skull",
  tankassignments = "Tank Assignments", healerassignments = "Healer Assignments",
  meleepositions = "Melee Positions", rangedpositions = "Ranged Positions",
  tankpositions = "Tank Positions", healpositions = "Heal Positions",
  additionalassignments = "Additional Assignments",
}

local spellCatalog = {
  [2825] = "Bloodlust",
  [32182] = "Heroism",
  [20707] = "Soulstone",
  [29166] = "Innervate",
  [34477] = "Misdirection",
}

local function Normalize(value)
  return tostring(value or ""):lower():gsub("[%s%p%c]+", "")
end

function MerfinPlus:GetSupportedUILocales()
  return LOCALE_ORDER, LOCALE_NAMES
end

local function GetDefaultUILocale()
  local locale = (GAME_LOCALE or (GetLocale and GetLocale())) or "enUS"
  return LOCALE_NAMES[locale] and locale or "enUS"
end

function MerfinPlus:NormalizeUILocaleSettings()
  local fallback = GetDefaultUILocale()
  local global = self.db and self.db.global
  if type(global) ~= "table" then
    return fallback
  end

  -- AceDB defaults can make uiLocale readable through a metatable while the
  -- actual saved value is still absent. Materialize one valid value before
  -- the standalone frame is created so the selector never starts blank.
  local stored = rawget(global, "uiLocale")
  if not LOCALE_NAMES[stored] then
    stored = fallback
    global.uiLocale = stored
  end
  return stored
end

function MerfinPlus:GetUILocale()
  return self:NormalizeUILocaleSettings()
end

function MerfinPlus:ApplyUILocaleSelectionToDropdown(dropdown)
  if not dropdown then return end
  local order, names = self:GetSupportedUILocales()
  local locale = self:NormalizeUILocaleSettings()
  local displayName = names[locale] or names.enUS or "English"
  dropdown:SetList(names, order)
  dropdown:SetValue(locale)
  -- SetValue updates the custom widget today, but keep the visible label an
  -- explicit part of the controller contract. The standalone options frame is
  -- constructed while hidden and its first AceConfig layout can otherwise
  -- leave the FontString empty even though the stored value is valid.
  dropdown:SetText(displayName)
  return locale, displayName
end

function MerfinPlus:T(key, ...)
  key = tostring(key or "")
  local locale = self:GetUILocale()
  local value = (translations[locale] and translations[locale][key]) or enUS[key] or key
  if select("#", ...) > 0 then
    local ok, formatted = pcall(string.format, value, ...)
    if ok then
      return formatted
    end
  end
  return value
end

function MerfinPlus:LocalizeRaidAssignmentStatus(value)
  local text = tostring(value or "")
  local Unpack = unpack or rawget(table, "unpack")
  local patterns = {
    { "^(.-) confirmed receipt%.$", "%s confirmed receipt." },
    { "^Received from (.-)%.$", "Received from %s." },
    { "^Receiver rejected MFPRA transfer: (.-)$", "Receiver rejected MFPRA transfer: %s" },
    { "^All (%d+) group participants completed the transfer%.$", "All %d group participants completed the transfer.", true },
    { "^(%d+) of (%d+) group participants completed the transfer%.$", "%d of %d group participants completed the transfer.", true, true },
    { "^The sender completed locally; waiting for (%d+) online group peer confirmation%(s%)%.$", "The sender completed locally; waiting for %d online group peer confirmation(s).", true },
    { "^1 of (%d+) group participants completed locally; (%d+) offline peer%(s%) could not confirm%. No retry was queued%.$", "1 of %d group participants completed locally; %d offline peer(s) could not confirm. No retry was queued.", true, true },
    { "^(%d+) of (%d+) group participants completed the transfer; (%d+) rejected and (%d+) did not confirm%. No retry was queued%.$", "%d of %d group participants completed the transfer; %d rejected and %d did not confirm. No retry was queued.", true, true, true, true },
    { "^A recipient rejected the transfer; (%d+) of (%d+) candidates have responded%.$", "A recipient rejected the transfer; %d of %d candidates have responded.", true, true },
  }
  for _, entry in ipairs(patterns) do
    local captures = { text:match(entry[1]) }
    if #captures > 0 then
      for index = 1, #captures do
        if entry[index + 2] then captures[index] = tonumber(captures[index]) or 0 end
      end
      return self:T(entry[2], Unpack(captures))
    end
  end
  return self:T(text)
end

function MerfinPlus:GetCanonicalUIKey(value)
  value = tostring(value or "")
  if enUS[value] then
    return value
  end
  for _, locale in ipairs(LOCALE_ORDER) do
    local key = reverse[locale][value]
    if key then
      return key
    end
  end
end

function MerfinPlus:LocalizeKnownValue(value, spellID)
  local key = spellID and spellCatalog[tonumber(spellID)]
    or semanticKeys[Normalize(value)]
    or self:GetCanonicalUIKey(value)
  return key and self:T(key) or value
end

function MerfinPlus:LocalizeAssignmentSection(value)
  value = tostring(value or "")
  local phase, suffix = value:match("^(P%d+%s*%-%s*)(.+)$")
  if phase and suffix then
    return phase .. self:LocalizeKnownValue(suffix)
  end
  local className = value:match("^([%a]+)%s+[Aa]ssigns?$")
  local classKey = className and semanticKeys[Normalize(className)]
  if classKey then
    return self:T(classKey) .. " " .. self:T("Assignments")
  end
  return self:LocalizeKnownValue(value)
end

-- AceConfig rejects unknown keys anywhere in an options tree. Localization
-- bookkeeping therefore lives entirely outside those trees.
local optionLocaleKeys = setmetatable({}, { __mode = "k" })
local optionLocaleValueKeys = setmetatable({}, { __mode = "k" })

function MerfinPlus:StripOptionLocalizationMetadata(option, seen)
  if type(option) ~= "table" then
    return
  end
  seen = seen or {}
  if seen[option] then
    return
  end
  seen[option] = true

  local legacyKeys = {}
  for key in pairs(option) do
    if type(key) == "string" and key:match("^_merfinPlusLocale") then
      legacyKeys[#legacyKeys + 1] = key
    end
  end
  for _, key in ipairs(legacyKeys) do
    option[key] = nil
  end
  for _, child in pairs(option.args or {}) do
    self:StripOptionLocalizationMetadata(child, seen)
  end
end

function MerfinPlus:LocalizeOptionTree(option, metadataClean)
  if type(option) ~= "table" then
    return
  end
  if not metadataClean then
    self:StripOptionLocalizationMetadata(option)
  end
  local fieldKeys = optionLocaleKeys[option]
  for _, field in ipairs({ "name", "desc", "confirmText" }) do
    if type(option[field]) == "string" then
      fieldKeys = fieldKeys or {}
      optionLocaleKeys[option] = fieldKeys
      local key = fieldKeys[field] or self:GetCanonicalUIKey(option[field])
      if key then
        fieldKeys[field] = key
        option[field] = self:T(key)
      end
    end
  end
  if type(option.values) == "table" then
    local valueKeys = optionLocaleValueKeys[option] or {}
    optionLocaleValueKeys[option] = valueKeys
    for valueKey, label in pairs(option.values) do
      if type(label) == "string" then
        local key = valueKeys[valueKey] or self:GetCanonicalUIKey(label)
        if key then
          valueKeys[valueKey] = key
          option.values[valueKey] = self:T(key)
        end
      end
    end
  end
  for _, child in pairs(option.args or {}) do
    self:LocalizeOptionTree(child, true)
  end
end

function MerfinPlus:ValidateLocalizedOptionsTrees(roots)
  local registry = LibStub("AceConfigRegistry-3.0")
  local failures = {}
  for appName, root in pairs(roots or {}) do
    if type(root) == "table" then
      self:StripOptionLocalizationMetadata(root)
      local ok, errorText = pcall(registry.ValidateOptionsTable, registry, root, appName, 0)
      if not ok then
        failures[#failures + 1] = tostring(errorText)
      end
    end
  end
  if #failures > 0 then
    return false, table.concat(failures, "\n")
  end
  return true
end

function MerfinPlus:CreateLocalizedProfilesOptions(source)
  if type(source) ~= "table" then
    return source
  end
  local root = {}
  for key, value in pairs(source) do
    root[key] = value
  end
  root.args = {}
  for key, option in pairs(source.args or {}) do
    if type(option) == "table" then
      local clone = {}
      for field, value in pairs(option) do
        clone[field] = value
      end
      root.args[key] = clone
    else
      root.args[key] = option
    end
  end
  if root.args.current then
    root.args.current.name = function(info)
      return self:T("Current Profile:") .. " "
        .. NORMAL_FONT_COLOR_CODE .. info.handler:GetCurrentProfile()
        .. FONT_COLOR_CODE_CLOSE
    end
    -- Keep the active profile on one line and separate it visually from the
    -- reset action without wasting a complete AceConfig row.
    root.args.current.width = 1.8
  end
  if root.args.reset then
    root.args.reset.width = 0.85
  end
  root.args.resetSpacer = {
    type = "description",
    name = "",
    order = 10.5,
    width = 0.25,
  }
  self:LocalizeOptionTree(root)
  return root
end

function MerfinPlus:SetUILocale(locale)
  if not LOCALE_NAMES[locale] then
    locale = GetDefaultUILocale()
  end
  local global = self.db and self.db.global
  if type(global) ~= "table" then return false end
  local stored = rawget(global, "uiLocale")
  local current = self:GetUILocale()
  if current == locale and stored == locale then return false end
  self.db.global.uiLocale = locale
  if self.RefreshUILocale then
    self:RefreshUILocale()
  end
  return true
end

-- Existing option modules use MerfinPlus.L. Keep that API, but make lookups
-- follow the saved runtime language instead of the WoW client language.
MerfinPlus.L = setmetatable({}, {
  __index = function(_, key)
    return MerfinPlus:T(key)
  end,
})
