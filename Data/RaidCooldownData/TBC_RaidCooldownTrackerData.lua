-- Generated data-only catalog from the two user-supplied WeakAura exports.
-- Source: [Merfin] Raid Cooldowns backend spellData and [Merfin] RCD [Bars] frontend config.
-- Generated 2026-07-27. No WeakAura execution, roster, inspect, combat-log, or tracking code is included.

local _, MerfinPlus = ...

local definition = {
  displayName = EXPANSION_NAME1 or "The Burning Crusade",
  displayNameKey = "The Burning Crusade",
  minimumBuild = 20505,
  maximumBuild = 29999,
  frontendIDs = {
    ["[Merfin] RCD [Bars] "] = true,
    ["[Merfin] RCD [Bars]"] = true,
  },
  classOrder = {
    "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST",
    "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
  },
  spellData = {
    ["DRUID"] = {
        -- Innervate
        [29166] = {
            ["dur"] = 360,
            ["index"] = 1,
            ["enc_reset"] = true,
        },

        -- Rebirth
        [26994] = {
            ["dur"] = 1200,
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        -- Tranquility
        [9863] = { --48447
            ["dur"] = 600,
            ["index"] = 3,
            ["enc_reset"] = true,
        },

        -- Barkskin
        [22812] = {
            ["dur"] = 60,
            ["index"] = 4,
        },

        -- Frenzied Regeneration
        [22896] = {
            ["dur"] = 180,
            ["index"] = 5,
            ["enc_reset"] = true,
        },

        [33831] = { -- FoN
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 9,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 6,
            ["enc_reset"] = true,
        },

        [17329] = { -- Nature's Grasp -- 27009
            ["dur"] = 60,
            ["index"] = 7,
        },

        [8983] = { -- Bash
            ["dur"] = 60,
            ["minus"] = true,
            ["minusTabIndex"] = { 2 },
            ["minusTalentRow"] = { 2 },
            ["minusTalentColumn"] = { 2 },
            ["minusPerPoint"] = { 15 },
            ["index"] = 8,
        },

        [17116] = { -- Nature's Swiftness
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 5,
            ["talentColumn"] = 1,
            ["dur"] = 180,
            ["index"] = 9,
            ["enc_reset"] = true,
        },

        [18562] = { -- Swiftmend
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 15,
            ["index"] = 10,
        },

        [6795] = { -- Growl
            ["dur"] = 10,
            ["index"] = 11,
            -- Taunts are explicit user selections, not tank-role displays.
            ["roleIndependent"] = true,
        },

        [5209] = { -- Challenging Roar
            ["dur"] = 600,
            ["index"] = 12,
            ["enc_reset"] = true,
            ["roleIndependent"] = true,
        },

        [16979] = { -- Feral Charge
            ["tReq"] = true,
            ["tabIndex"] = 2,
            ["talentRow"] = 3,
            ["talentColumn"] = 2,
            ["dur"] = 15,
            ["index"] = 13,
        },
    },

    ["HUNTER"] = {
        -- Deterrence
        [19263] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 3,
            ["talentColumn"] = 3,
            ["dur"] = 300,
            ["index"] = 1,
        },

        -- Misdirection
        [34477] = {
            ["dur"] = 120,
            ["index"] = 2,
        },

        -- Readiness
        [23989] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 9,
            ["talentColumn"] = 2,
            ["dur"] = 300,
            ["index"] = 3,
            ["enc_reset"] = true,
        },

        -- Rapid Fire
        [3045] = {
            ["dur"] = 300,
            ["minus"] = true,
            ["minusTabIndex"] = { 2 },
            ["minusTalentRow"] = { 3 },
            ["minusTalentColumn"] = { 4 },
            ["minusPerPoint"] = { 60 },
            ["index"] = 4,
            ["enc_reset"] = true,
        },

        -- Bestial Wrath
        [19574] = {
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 120,
            ["index"] = 5,
        },

        -- Frost Trap
        [13809] = {
            ["dur"] = 26,
            ["tabIndex"] = 5,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["index"] = 6,
        },

        -- Freezing Trap
        [14311] = {
            ["dur"] = 26,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 6 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 2 },
            ["index"] = 8,
        },

        -- Immolation Trap
        [14305] = { -- 27023
            ["dur"] = 26,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 6 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 2 },
            ["index"] = 9,
        },

        -- Explosive Trap
        [14317] = { -- 27025
            ["dur"] = 26,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 6 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 2 },
            ["index"] = 10,
        },

        -- Snake Trap
        [34600] = {
            ["dur"] = 26,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 6 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 2 },
            ["index"] = 11,
        },

        [27020] = { -- Distracting Shot
            ["dur"] = 8,
            ["index"] = 12,
        },

        [5384] = { -- Feign Death
            ["dur"] = 30,
            ["index"] = 13,
        },
        [19577] = { -- Intimidation
            ["dur"] = 60,
            ["index"] = 14,
        },

        [27068] = { -- Wyvern Sting
            ["tReq"] = true,
            ["tabIndex"] = 2,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 120,
            ["index"] = 15,
        },

        [19503] = { -- Scatter Shot
            ["tReq"] = true,
            ["tabIndex"] = 2,
            ["talentRow"] = 5,
            ["talentColumn"] = 2,
            ["dur"] = 30,
            ["index"] = 16,
        },

    },

    ["MAGE"] = {
        -- Ice Block
        [45438] = {
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 1 },
            ["minusTalentColumn"] = { 3 },
            ["minusPerPoint"] = { 30 },
            ["dur"] = 300,
            ["index"] = 1,
            ["enc_reset"] = true,
        },

        -- Invisibility
        [66] = {
            ["dur"] = 300,
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        -- Blink
        [1953] = {
            ["dur"] = 15,
            ["index"] = 4,
        },

        -- Evocation
        [12051] = {
            ["dur"] = 480,
            ["index"] = 5,
            ["enc_reset"] = true,
        },

        -- Combustion
        [11129] = {
            ["tReq"] = true,
            ["tabIndex"] = 2,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 7,
            ["enc_reset"] = true,
        },

        -- Arcane Power
        [12042] = {
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 8,
            ["enc_reset"] = true,
        },

        -- Presence of Mind
        [12043] = {
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 5,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 9,
            ["enc_reset"] = true,
        },

        -- Icy Veins
        [12472] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 3,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 10,
            ["enc_reset"] = true,
        },

        -- Cold Snap
        [11958] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 5,
            ["talentColumn"] = 2,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 6 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 48 },
            ["dur"] = 480,
            ["index"] = 11,
            ["enc_reset"] = true,
        },

        -- Ice Barrier
        [11426] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 6 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 3 },
            ["dur"] = 30,
            ["index"] = 12,
        },

        -- Summon Water Elemental
        [31687] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 9,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 14,
            ["enc_reset"] = true,
        },

        -- Frost Nova
        [10230] = { -- 27088
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 2 },
            ["minusTalentColumn"] = { 3 },
            ["minusPerPoint"] = { 2 },
            ["dur"] = 25,
            ["index"] = 15,
        },

        [2139] = { -- Counterspell
            ["dur"] = 24,
            ["index"] = 16,
        },

    },

    ["PALADIN"] = {
        -- Divine Protection
        [5573] = {
            ["dur"] = 300,
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        -- Divine Shield
        [1020] = {
            ["dur"] = 300,
            ["index"] = 4,
            ["enc_reset"] = true,
        },

        -- Lay on Hands
        [10310] = { -- 27154
            ["dur"] = 3600, -- 1h
            ["minus"] = true,
            ["minusTabIndex"] = { 1 },
            ["minusTalentRow"] = { 3 },
            ["minusTalentColumn"] = { 3 },
            ["minusPerPoint"] = { 600 },
            ["index"] = 5,
            ["enc_reset"] = false, -- check
        },

        -- Blessing of Freedom
        [1044] = {
            ["dur"] = 25,
            ["index"] = 6,
            ["enc_reset"] = false, -- check
        },

        -- Blessing of Protection
        [10278] = {
            ["dur"] = 300,
            ["minus"] = true,
            ["minusTabIndex"] = { 2 },
            ["minusTalentRow"] = { 2 },
            ["minusTalentColumn"] = { 2 },
            ["minusPerPoint"] = { 60 },
            ["index"] = 7,
            ["enc_reset"] = true,
        },

        -- Blessing of Sacrifice
        [20729] = { -- 27148
            ["dur"] = 30,
            ["index"] = 8,
            ["enc_reset"] = true,
        },

        -- Avenging Wrath
        [31884] = {
            ["dur"] = 180,
            ["index"] = 9,
            ["enc_reset"] = true,
        },

        -- Hammer of Justice
        [10308] = {
            ["dur"] = 60,
            ["minus"] = true,
            ["minusTabIndex"] = { 2 },
            ["minusTalentRow"] = { 4 },
            ["minusTalentColumn"] = { 2 },
            ["minusPerPoint"] = { 5 },
            ["index"] = 10,
        },

        -- Holy Wrath
        [10318] = { -- 27139
            ["dur"] = 60,
            ["index"] = 11,
        },

        [31789] = { -- Righteous Defense
            ["dur"] = 15,
            ["index"] = 12,
            ["roleIndependent"] = true,
        },

        [20066] = { -- Repentance
            ["dur"] = 60,
            ["index"] = 13,
        },
    },

    ["PRIEST"] = {
        -- Fear Ward
        [6346] = {
            ["dur"] = 180,
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        -- Pain Suppression
        [33206] = {
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 9,
            ["talentColumn"] = 2,
            ["dur"] = 120,
            ["index"] = 5,
            ["enc_reset"] = true,
        },

        -- Power Infusion
        [10060] = {
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 6,
            ["enc_reset"] = true,
        },

        -- Inner Focus
        [14751] = {
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 3,
            ["talentColumn"] = 2,
            ["dur"] = 180,
            ["index"] = 7,
            ["enc_reset"] = true,
        },

        -- Psychic Scream
        [10890] = {
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 3 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 2 },
            ["dur"] = 30,
            ["index"] = 8,
        },

        -- Lightwell
        [724] = {
            ["tReq"] = true,
            ["tabIndex"] = 2,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 360,
            ["index"] = 9,
            ["enc_reset"] = true,
        },

        -- Silence
        [15487] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 5,
            ["talentColumn"] = 1,
            ["dur"] = 45,
            ["index"] = 12,
        },

        -- Shadowfiend
        [34433] = {
            ["dur"] = 300,
            ["index"] = 13,
            ["enc_reset"] = true,
        },
    },

    ["ROGUE"] = {
        -- Cloak of Shadows
        [31224] = {
            ["dur"] = 60,
            ["index"] = 1,
        },

        -- Evasion
        [26669] = {
            ["dur"] = 300,
            ["minus"] = true,
            ["minusTabIndex"] = { 2 },
            ["minusTalentRow"] = { 3 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 45 },
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        -- Vanish
        [1857] = { -- 26889
            ["dur"] = 300,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 4 },
            ["minusTalentColumn"] = { 2 },
            ["minusPerPoint"] = { 45 },
            ["index"] = 4,
            ["enc_reset"] = true,
        },

        [38768] = { -- Kick
            ["dur"] = 10,
            ["index"] = 5,
        },

        [8643] = { -- Kidney Shot
            ["dur"] = 20,
            ["index"] = 6,
        },

        [38764] = { -- Gouge
            ["dur"] = 10,
            ["index"] = 7,
        },

        [2094] = { -- Blind
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 4 },
            ["minusTalentColumn"] = { 2 },
            ["minusPerPoint"] = { 45 },
            ["dur"] = 180,
            ["index"] = 8,
        },
    },

    ["SHAMAN"] = {
        -- Bloodlust (Horde)
        [2825] = {
            ["dur"] = 600,
            ["index"] = 1,
            ["enc_reset"] = true,
        },

        -- Heroism (Alliance)
        [32182] = {
            ["dur"] = 600,
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        -- Mana Tide Totem
        [16190] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 7,
            ["talentColumn"] = 2,
            ["dur"] = 300,
            ["index"] = 3,
            ["enc_reset"] = true,
        },

        -- Reincarnation
        [21169] = {
            ["dur"] = 3600,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 2 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 600 },
            ["index"] = 4,
        },

        -- Shamanistic Rage
        [30823] = {
            ["tReq"] = true,
            ["tabIndex"] = 2,
            ["talentRow"] = 9,
            ["talentColumn"] = 2,
            ["dur"] = 120,
            ["index"] = 5,
        },

        -- Nature's Swifness
        [16188] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 5,
            ["talentColumn"] = 3,
            ["dur"] = 180,
            ["index"] = 6,
            ["enc_reset"] = true,
        },

        -- Elemental Mastery
        [16166] = {
            ["tReq"] = true,
            ["tabIndex"] = 1,
            ["talentRow"] = 6,
            ["talentColumn"] = 3,
            ["dur"] = 180,
            ["index"] = 9,
            ["enc_reset"] = true,
        },

        -- Frost Shock
        [10473] = {
            ["dur"] = 6,
            ["minus"] = true,
            ["minusTabIndex"] = { 1 },
            ["minusTalentRow"] = { 3 },
            ["minusTalentColumn"] = { 2 },
            ["minusPerPoint"] = { 0.2 },
            ["index"] = 10,
        },

        -- Earth Shock
        [25454] = {
            ["dur"] = 6,
            ["minus"] = true,
            ["minusTabIndex"] = { 1 },
            ["minusTalentRow"] = { 3 },
            ["minusTalentColumn"] = { 2 },
            ["minusPerPoint"] = { 0.2 },
            ["index"] = 11,
        },
    },

    ["WARLOCK"] = {
        -- Soulstone Resurrection
        [27239] = {
            ["dur"] = 1800,
            ["index"] = 1,
            ["enc_reset"] = true,
        },

        -- Soulshatter
        [29858] = {
            ["dur"] = 300,
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        -- Shadow Ward
        [28610] = {
            ["dur"] = 30,
            ["index"] = 3,
        },

        -- Howl of Terror
        [17928] = {
            ["dur"] = 40,
            ["index"] = 4,
        },

        -- Inferno
        [1122] = {
            ["dur"] = 3600,
            ["index"] = 6,
            ["enc_reset"] = true,
        },

        -- Shadowfurry
        [30413] = { -- 30283
            ["dur"] = 20,
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 9,
            ["talentColumn"] = 2,
            ["index"] = 7,
        },

        [27223] = { -- Death Coil
            ["dur"] = 120,
            ["index"] = 8,
        },

        [19647] = { -- Spell Lock
            ["dur"] = 24,
            ["index"] = 9,
        },
    },

    ["WARRIOR"] = {
        -- Last Stand
        [12975] = {
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 3,
            ["talentColumn"] = 1,
            ["dur"] = 480,
            ["index"] = 1,
            ["enc_reset"] = true,
        },

        -- Shield Wall
        [871] = {
            ["dur"] = 1800,
            ["index"] = 2,
            ["enc_reset"] = true,
        },

        [355] = { -- Taunt
            ["dur"] = 10,
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 4 },
            ["minusTalentColumn"] = { 3 },
            ["minusPerPoint"] = { 1 },
            ["index"] = 3,
            ["roleIndependent"] = true,
        },

        [1161] = { -- Challenging Shout
            ["dur"] = 600,
            ["index"] = 4,
            ["enc_reset"] = true,
            ["roleIndependent"] = true,
        },

        [25266] = { -- Mocking Blow
            ["dur"] = 120,
            ["index"] = 5,
            ["roleIndependent"] = true,
        },

        [3411] = { -- Intervene
            ["dur"] = 30,
            ["index"] = 6,
        },

        [5246] = { -- Intimidating Shout
            ["dur"] = 180,
            ["index"] = 7,
        },

        [6554] = { -- Pummel
            ["dur"] = 10,
            ["index"] = 8,
        },

        [1719] = { -- Recklessness
            ["dur"] = 1800,
            ["index"] = 9,
            ["enc_reset"] = true,
        },

        [20230] = { -- Retaliation
            ["dur"] = 600,
            ["index"] = 10,
            ["enc_reset"] = true,
        },

        [29704] = { -- Shield Bash
            ["dur"] = 12,
            ["index"] = 11,
        },

        [12809] = { -- Concussion Blow
            ["tReq"] = true,
            ["tabIndex"] = 3,
            ["talentRow"] = 5,
            ["talentColumn"] = 2,
            ["dur"] = 45,
            ["index"] = 12,
        },

        [11578] = { -- Charge Stun
            ["dur"] = 15,
            ["index"] = 13,
        },

        [25275] = { -- Intercept
            ["minus"] = true,
            ["minusTabIndex"] = { 3 },
            ["minusTalentRow"] = { 6 },
            ["minusTalentColumn"] = { 1 },
            ["minusPerPoint"] = { 5 },
            ["dur"] = 30,
            ["index"] = 14,
        },

        [23920] = { -- Spell Reflection
            ["dur"] = 10,
            ["index"] = 15,
        },

        [676] = { -- Disarm
            ["dur"] = 60,
            ["index"] = 16,
        },
    },
},
  defaultConfig = {
        ["advanced"] = {
            ["display"] = {
                [1] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "22812",
                    ["spellName"] = "Barkskin (Druid)",
                    ["tank"] = true,
                },
                [2] = {
                    ["dps"] = false,
                    ["healer"] = true,
                    ["spellID"] = "1020",
                    ["spellName"] = "Divine Shield (Paladin)",
                    ["tank"] = true,
                },
                [3] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "12975",
                    ["spellName"] = "Last Stand (Warrior)",
                    ["tank"] = true,
                },
                [4] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "5573",
                    ["spellName"] = "Divine Protection (Paladin)",
                    ["tank"] = true,
                },
                [5] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "871",
                    ["spellName"] = "Shield Wall (Warrior)",
                    ["tank"] = true,
                },
                [6] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "27148",
                    ["spellName"] = "Hand of Sacrifice (Paladin)",
                    ["tank"] = true,
                },
                [7] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "2565",
                    ["spellName"] = "Shield Block (Warrior)",
                    ["tank"] = true,
                },
                [8] = {
                    ["dps"] = true,
                    ["healer"] = false,
                    ["spellID"] = "1719",
                    ["spellName"] = "Recklessness (Warrior)",
                    ["tank"] = false,
                },
                [9] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "6795",
                    ["spellName"] = "Growl (Druid)",
                    ["tank"] = true,
                },
                [10] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "5209",
                    ["spellName"] = "Challenging Roar (Druid)",
                    ["tank"] = true,
                },
                [11] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "31789",
                    ["spellName"] = "Righteous Defense (Paladin)",
                    ["tank"] = true,
                },
                [12] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "355",
                    ["spellName"] = "Taunt (Warrior)",
                    ["tank"] = true,
                },
                [13] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "1161",
                    ["spellName"] = "Challenging Shout (Warrior)",
                    ["tank"] = true,
                },
                [14] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "25266",
                    ["spellName"] = "Mocking Blow (Warrior)",
                    ["tank"] = true,
                },
                [15] = {
                    ["dps"] = false,
                    ["healer"] = false,
                    ["spellID"] = "20594",
                    ["spellName"] = "Stoneform (Racial)",
                    ["tank"] = true,
                },
            },
            ["order"] = {
                [1] = {
                    ["index"] = 4,
                    ["spellID"] = "48477",
                    ["spellName"] = "Rebirth",
                },
            },
        },
        ["cds"] = {
            ["DRUID"] = {
                ["16979"] = false,
                ["17116"] = false,
                ["17329"] = false,
                ["18562"] = false,
                ["20549"] = false,
                ["20580"] = false,
                ["22812"] = true,
                ["22896"] = true,
                ["26994"] = true,
                ["29166"] = true,
                ["33831"] = false,
                ["5209"] = false,
                ["6795"] = false,
                ["8983"] = false,
                ["9863"] = true,
            },
            ["HUNTER"] = {
                ["13809"] = false,
                ["14305"] = false,
                ["14311"] = false,
                ["14317"] = false,
                ["19263"] = false,
                ["19503"] = false,
                ["19574"] = false,
                ["20549"] = false,
                ["20554"] = false,
                ["20572"] = false,
                ["20600"] = false,
                ["23989"] = false,
                ["24394"] = false,
                ["27020"] = false,
                ["27068"] = false,
                ["28730"] = false,
                ["28734"] = false,
                ["28880"] = false,
                ["3045"] = false,
                ["34477"] = true,
                ["34600"] = false,
                ["5384"] = false,
            },
            ["MAGE"] = {
                ["10230"] = false,
                ["11129"] = false,
                ["11426"] = false,
                ["11958"] = false,
                ["12042"] = false,
                ["12043"] = false,
                ["12051"] = false,
                ["12472"] = false,
                ["1953"] = false,
                ["20554"] = false,
                ["20589"] = false,
                ["20600"] = false,
                ["2139"] = false,
                ["28730"] = false,
                ["28734"] = false,
                ["28880"] = false,
                ["31687"] = false,
                ["45438"] = false,
                ["66"] = false,
                ["7744"] = false,
            },
            ["PALADIN"] = {
                ["1020"] = true,
                ["10278"] = true,
                ["10308"] = false,
                ["10310"] = true,
                ["10318"] = false,
                ["1044"] = true,
                ["20066"] = false,
                ["20594"] = false,
                ["20600"] = false,
                ["20729"] = true,
                ["28730"] = false,
                ["28734"] = false,
                ["28880"] = false,
                ["31789"] = false,
                ["31884"] = true,
                ["5573"] = true,
            },
            ["PRIEST"] = {
                ["10060"] = true,
                ["10890"] = false,
                ["13896"] = false,
                ["13908"] = false,
                ["14751"] = false,
                ["15487"] = false,
                ["20554"] = false,
                ["20580"] = false,
                ["20594"] = false,
                ["20600"] = false,
                ["25446"] = false,
                ["25467"] = false,
                ["2651"] = false,
                ["28730"] = false,
                ["28734"] = false,
                ["28880"] = false,
                ["32548"] = false,
                ["33206"] = true,
                ["34433"] = true,
                ["44047"] = false,
                ["6346"] = true,
                ["724"] = false,
                ["7744"] = false,
            },
            ["ROGUE"] = {
                ["1857"] = false,
                ["20554"] = false,
                ["20572"] = false,
                ["20580"] = false,
                ["20589"] = false,
                ["20594"] = false,
                ["20600"] = false,
                ["2094"] = false,
                ["26669"] = false,
                ["31224"] = false,
                ["38764"] = false,
                ["38768"] = false,
                ["7744"] = false,
                ["8643"] = false,
            },
            ["SHAMAN"] = {
                ["10473"] = false,
                ["16166"] = false,
                ["16188"] = false,
                ["16190"] = true,
                ["20549"] = false,
                ["20554"] = false,
                ["20572"] = false,
                ["21169"] = false,
                ["25454"] = false,
                ["2825"] = true,
                ["28880"] = false,
                ["30823"] = false,
                ["32182"] = true,
            },
            ["WARLOCK"] = {
                ["1122"] = false,
                ["17928"] = false,
                ["19647"] = false,
                ["20572"] = false,
                ["20589"] = false,
                ["20600"] = false,
                ["27223"] = false,
                ["27239"] = true,
                ["28610"] = false,
                ["28730"] = false,
                ["28734"] = false,
                ["29858"] = true,
                ["30413"] = false,
                ["32676"] = false,
                ["7744"] = false,
            },
            ["WARRIOR"] = {
                ["11578"] = false,
                ["1161"] = false,
                ["12809"] = false,
                ["12975"] = true,
                ["1719"] = false,
                ["20230"] = false,
                ["20549"] = false,
                ["20554"] = false,
                ["20572"] = false,
                ["20594"] = false,
                ["20600"] = false,
                ["23920"] = false,
                ["25266"] = false,
                ["25275"] = false,
                ["29704"] = false,
                ["3411"] = false,
                ["355"] = false,
                ["5246"] = false,
                ["6554"] = false,
                ["676"] = false,
                ["7744"] = false,
                ["871"] = true,
            },
        },
        ["display"] = {
            ["colorDead"] = {
                [1] = 1,
                [2] = 0,
                [3] = 0,
                [4] = 1,
            },
            ["raidSubGroups"] = 5,
            ["showBuff"] = true,
            ["showDead"] = true,
            ["showMyself"] = true,
            ["showOffline"] = true,
            ["showReady"] = true,
            ["showReadySymbol"] = true,
        },
        ["features"] = {
            ["clickMsg"] = true,
        },
    },
  provenance = {
    backend = "User-supplied [Merfin] Raid Cooldowns WeakAura export",
    frontend = "User-supplied [Merfin] RCD [Bars] WeakAura export",
    received = "2026-07-27",
  },
}

-- The supplied backend augments spellData with faction-valid racials before any
-- frontend registers. Keep the same data transformation here without copying
-- its inspect, roster, or combat-log execution backend.
local RACIALS = {
  [28730] = { raceReq = true, race = { BloodElf = true }, dur = 120, index = 90 },
  [32676] = { raceReq = true, race = { BloodElf = true }, dur = 120, index = 91 },
  [28734] = { raceReq = true, race = { BloodElf = true }, dur = 30, index = 92 },
  [20572] = { raceReq = true, race = { Orc = true }, dur = 120, index = 93 },
  [20549] = { raceReq = true, race = { Tauren = true }, dur = 120, index = 94 },
  [20554] = { raceReq = true, race = { Troll = true }, dur = 180, index = 95 },
  [7744] = { raceReq = true, race = { Scourge = true }, dur = 120, index = 96 },
  [20577] = { raceReq = true, race = { Scourge = true }, dur = 120, index = 97 },
  [20589] = { raceReq = true, race = { Gnome = true }, dur = 105, index = 98 },
  [20580] = { raceReq = true, race = { NightElf = true }, dur = 10, index = 99 },
  [20594] = { raceReq = true, race = { Dwarf = true }, dur = 180, index = 100 },
  [20600] = { raceReq = true, race = { Human = true }, dur = 180, index = 101 },
  [28880] = { raceReq = true, race = { Draenei = true }, dur = 180, index = 102 },
}

local PRIEST_RACIALS = {
  [13896] = { raceReq = true, race = { Human = true }, dur = 180, index = 110 },
  [13908] = { raceReq = true, race = { Human = true, Dwarf = true }, dur = 600, index = 111 },
  [2651] = { raceReq = true, race = { NightElf = true }, dur = 180, index = 112 },
  [25446] = { raceReq = true, race = { NightElf = true }, dur = 30, index = 113 },
  [44047] = { raceReq = true, race = { Dwarf = true, Draenei = true }, dur = 30, index = 114 },
  [32548] = { raceReq = true, race = { Draenei = true }, dur = 300, index = 115 },
  [25467] = { raceReq = true, race = { Scourge = true }, dur = 180, index = 116 },
}

local HORDE_RACES = {
  BloodElf = true,
  Orc = true,
  Tauren = true,
  Troll = true,
  Scourge = true,
}

local RACE_CLASSES = {
  BloodElf = { PALADIN = true, PRIEST = true, MAGE = true, WARLOCK = true, HUNTER = true, ROGUE = true },
  Orc = { WARRIOR = true, HUNTER = true, ROGUE = true, SHAMAN = true, WARLOCK = true },
  Tauren = { WARRIOR = true, DRUID = true, SHAMAN = true, HUNTER = true },
  Troll = { WARRIOR = true, HUNTER = true, ROGUE = true, PRIEST = true, MAGE = true, SHAMAN = true },
  Scourge = { WARRIOR = true, ROGUE = true, PRIEST = true, MAGE = true, WARLOCK = true },
  Gnome = { WARRIOR = true, ROGUE = true, MAGE = true, WARLOCK = true },
  NightElf = { WARRIOR = true, DRUID = true, HUNTER = true, PRIEST = true, ROGUE = true },
  Dwarf = { WARRIOR = true, PALADIN = true, HUNTER = true, PRIEST = true, ROGUE = true },
  Human = { WARRIOR = true, PALADIN = true, MAGE = true, WARLOCK = true, PRIEST = true, ROGUE = true },
  Draenei = { WARRIOR = true, PALADIN = true, PRIEST = true, SHAMAN = true, HUNTER = true, MAGE = true },
}

local faction = UnitFactionGroup and UnitFactionGroup("player")

local function AddFactionRacials(spells, racials, className)
  for spellID, data in pairs(racials) do
    for raceName in pairs(data.race) do
      local classAllowed = RACE_CLASSES[raceName] and RACE_CLASSES[raceName][className]
      local factionAllowed = (HORDE_RACES[raceName] and faction == "Horde")
        or (not HORDE_RACES[raceName] and faction == "Alliance")
      if classAllowed and factionAllowed then
        spells[spellID] = data
        break
      end
    end
  end
end

for className, spells in pairs(definition.spellData) do
  AddFactionRacials(spells, RACIALS, className)
end
AddFactionRacials(definition.spellData.PRIEST, PRIEST_RACIALS, "PRIEST")

if faction == "Horde" then
  definition.spellData.SHAMAN[32182] = nil
elseif faction == "Alliance" then
  definition.spellData.SHAMAN[2825] = nil
end

MerfinPlus:RegisterRaidCooldownTrackerExpansion("TBC", definition)
