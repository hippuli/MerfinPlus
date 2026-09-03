-- MerfinPlus Item Source Resolver (Data - MoP Faction)

do
  local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

  -- Reputation names (numeric -> string)
  MerfinPlus.REPUTATION_NAMES = MerfinPlus.REPUTATION_NAMES
    or {
      [4] = FACTION_STANDING_LABEL4, -- Neutral
      [5] = FACTION_STANDING_LABEL5, -- Friendly
      [6] = FACTION_STANDING_LABEL6, -- Honored
      [7] = FACTION_STANDING_LABEL7, -- Revered
      [8] = FACTION_STANDING_LABEL8, -- Exalted
    }

  -- Faction item sources
  -- itemID -> factionID + reputationID
  MerfinPlus.FactionSourceDB = MerfinPlus.FactionSourceDB or {}

  -- Shado-Pan Assault (1435)
  MerfinPlus.FactionSourceDB[95101] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95102] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95096] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95097] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95100] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95099] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95095] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95098] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95103] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95104] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[97131] = { factionID = 1435, reputationID = 8 }
  MerfinPlus.FactionSourceDB[95559] = { factionID = 1435, reputationID = 7 }
  MerfinPlus.FactionSourceDB[95081] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95082] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95106] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95105] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95135] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95136] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95090] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95091] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95123] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95122] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95078] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95077] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95134] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95133] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95108] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95107] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95088] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95089] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95125] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95124] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95079] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95080] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95132] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95131] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95109] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95112] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95087] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95086] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95127] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95126] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95076] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95075] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95074] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95129] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95128] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95130] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95111] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95110] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95113] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95084] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95083] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95085] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95120] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95119] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95121] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95118] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95116] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95115] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95117] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95114] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95138] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95137] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95141] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95139] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95140] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[98017] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[94508] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[94509] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[94507] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[94511] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[94510] = { factionID = 1435, reputationID = 5 }
  MerfinPlus.FactionSourceDB[95146] = { factionID = 1435, reputationID = 4 }
  MerfinPlus.FactionSourceDB[95143] = { factionID = 1435, reputationID = 4 }
  MerfinPlus.FactionSourceDB[95145] = { factionID = 1435, reputationID = 4 }
  MerfinPlus.FactionSourceDB[95142] = { factionID = 1435, reputationID = 4 }
  MerfinPlus.FactionSourceDB[95144] = { factionID = 1435, reputationID = 4 }

  -- The August Celestials (1341)
  MerfinPlus.FactionSourceDB[88879] = { factionID = 1341, reputationID = 6 }
  MerfinPlus.FactionSourceDB[88880] = { factionID = 1341, reputationID = 6 }
  MerfinPlus.FactionSourceDB[88892] = { factionID = 1341, reputationID = 6 }
  MerfinPlus.FactionSourceDB[88893] = { factionID = 1341, reputationID = 6 }

  -- The Klaxxi (1337)
  MerfinPlus.FactionSourceDB[89055] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89060] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89062] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89063] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89064] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89066] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89067] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89068] = { factionID = 1337, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89093] = { factionID = 1337, reputationID = 7 }

  -- Golden Lotus (1269)
  MerfinPlus.FactionSourceDB[89069] = { factionID = 1269, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89071] = { factionID = 1269, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89072] = { factionID = 1269, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89073] = { factionID = 1269, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89340] = { factionID = 1269, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89343] = { factionID = 1269, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89345] = { factionID = 1269, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89431] = { factionID = 1269, reputationID = 7 }

  -- Shado-Pan (1270)
  MerfinPlus.FactionSourceDB[89074] = { factionID = 1270, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89076] = { factionID = 1270, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89077] = { factionID = 1270, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89078] = { factionID = 1270, reputationID = 6 }
  MerfinPlus.FactionSourceDB[89296] = { factionID = 1270, reputationID = 7 }

  -- Operation: Shieldwall (1376)
  MerfinPlus.FactionSourceDB[93261] = { factionID = 1376, reputationID = 7 }

  -- Dominance Offensive (1375)
  MerfinPlus.FactionSourceDB[93248] = { factionID = 1375, reputationID = 6 }
  MerfinPlus.FactionSourceDB[93250] = { factionID = 1375, reputationID = 6 }
  MerfinPlus.FactionSourceDB[93251] = { factionID = 1375, reputationID = 6 }
  MerfinPlus.FactionSourceDB[93253] = { factionID = 1375, reputationID = 7 }
  MerfinPlus.FactionSourceDB[93256] = { factionID = 1375, reputationID = 7 }
  MerfinPlus.FactionSourceDB[93264] = { factionID = 1375, reputationID = 7 }
  MerfinPlus.FactionSourceDB[93323] = { factionID = 1375, reputationID = 7 }
end
