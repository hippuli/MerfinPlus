do
  local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

  MerfinPlus.ItemSourceDB = MerfinPlus.ItemSourceDB or {}

  local DB = MerfinPlus.ItemSourceDB

  local function Add(itemID, src)
    local t = DB[itemID]
    if not t then
      t = {}
      DB[itemID] = t
    end
    t[#t + 1] = src
  end

  Add(33993, {
    instanceKey = "ZulAman",
    bossKey = "ZulAmanTrash",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(52078, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(52078, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(52078, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(52494, {
    instanceKey = "WorldBossesCata",
    bossKey = "Akma'hat",
    difficulty = "N",
  })
  Add(52494, {
    instanceKey = "WorldBossesCata",
    bossKey = "Garr",
    difficulty = "N",
  })
  Add(52494, {
    instanceKey = "WorldBossesCata",
    bossKey = "Julak-Doom",
    difficulty = "N",
  })
  Add(52494, {
    instanceKey = "WorldBossesCata",
    bossKey = "Mobus",
    difficulty = "N",
  })
  Add(52494, {
    instanceKey = "WorldBossesCata",
    bossKey = "Xariona",
    difficulty = "N",
  })
  Add(52494, {
    instanceKey = "WorldBossesCata",
    bossKey = "Poseidus",
    difficulty = "N",
  })
  Add(52495, {
    instanceKey = "WorldBossesCata",
    bossKey = "Akma'hat",
    difficulty = "N",
  })
  Add(52495, {
    instanceKey = "WorldBossesCata",
    bossKey = "Garr",
    difficulty = "N",
  })
  Add(52495, {
    instanceKey = "WorldBossesCata",
    bossKey = "Julak-Doom",
    difficulty = "N",
  })
  Add(52495, {
    instanceKey = "WorldBossesCata",
    bossKey = "Mobus",
    difficulty = "N",
  })
  Add(52495, {
    instanceKey = "WorldBossesCata",
    bossKey = "Xariona",
    difficulty = "N",
  })
  Add(52495, {
    instanceKey = "WorldBossesCata",
    bossKey = "Poseidus",
    difficulty = "N",
  })
  Add(52496, {
    instanceKey = "WorldBossesCata",
    bossKey = "Akma'hat",
    difficulty = "N",
  })
  Add(52496, {
    instanceKey = "WorldBossesCata",
    bossKey = "Garr",
    difficulty = "N",
  })
  Add(52496, {
    instanceKey = "WorldBossesCata",
    bossKey = "Julak-Doom",
    difficulty = "N",
  })
  Add(52496, {
    instanceKey = "WorldBossesCata",
    bossKey = "Mobus",
    difficulty = "N",
  })
  Add(52496, {
    instanceKey = "WorldBossesCata",
    bossKey = "Xariona",
    difficulty = "N",
  })
  Add(52496, {
    instanceKey = "WorldBossesCata",
    bossKey = "Poseidus",
    difficulty = "N",
  })
  Add(55195, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "N",
  })
  Add(55198, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "N",
  })
  Add(55201, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "N",
  })
  Add(55202, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "N",
  })
  Add(55203, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "N",
  })
  Add(55204, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "N",
  })
  Add(55205, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "N",
  })
  Add(55206, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "N",
  })
  Add(55207, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "N",
  })
  Add(55228, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "N",
  })
  Add(55229, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "N",
  })
  Add(55235, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "N",
  })
  Add(55236, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "N",
  })
  Add(55237, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "N",
  })
  Add(55248, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "N",
  })
  Add(55249, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55250, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55251, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55252, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55253, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55254, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55255, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55256, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55258, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55259, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "N",
  })
  Add(55260, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "ThroneOfTheTidesTrash",
    difficulty = "N",
  })
  Add(55261, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "ThroneOfTheTidesTrash",
    difficulty = "N",
  })
  Add(55262, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "ThroneOfTheTidesTrash",
    difficulty = "N",
  })
  Add(55263, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "N",
  })
  Add(55264, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "N",
  })
  Add(55265, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "N",
  })
  Add(55266, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "N",
  })
  Add(55267, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "N",
  })
  Add(55268, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "N",
  })
  Add(55269, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "N",
  })
  Add(55270, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "N",
  })
  Add(55271, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "N",
  })
  Add(55272, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "N",
  })
  Add(55273, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "N",
  })
  Add(55274, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "N",
  })
  Add(55275, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "N",
  })
  Add(55276, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "N",
  })
  Add(55277, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "N",
  })
  Add(55278, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "N",
  })
  Add(55279, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "N",
  })
  Add(55776, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "N",
  })
  Add(55777, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "N",
  })
  Add(55778, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "N",
  })
  Add(55779, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55780, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55781, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55782, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55783, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55784, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55785, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55786, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55787, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55788, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "N",
  })
  Add(55789, {
    instanceKey = "BlackrockCaverns",
    bossKey = "BlackrockCavernsTrash",
    difficulty = "N",
  })
  Add(55790, {
    instanceKey = "BlackrockCaverns",
    bossKey = "BlackrockCavernsTrash",
    difficulty = "N",
  })
  Add(55791, {
    instanceKey = "BlackrockCaverns",
    bossKey = "BlackrockCavernsTrash",
    difficulty = "N",
  })
  Add(55792, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "N",
  })
  Add(55793, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "N",
  })
  Add(55794, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "N",
  })
  Add(55795, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "N",
  })
  Add(55796, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "N",
  })
  Add(55797, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "N",
  })
  Add(55798, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "N",
  })
  Add(55799, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "N",
  })
  Add(55800, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "N",
  })
  Add(55801, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "N",
  })
  Add(55802, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "N",
  })
  Add(55803, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "N",
  })
  Add(55804, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "N",
  })
  Add(55810, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "N",
  })
  Add(55811, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "N",
  })
  Add(55812, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55813, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55814, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55815, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55816, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55817, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55818, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55819, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55820, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55821, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "N",
  })
  Add(55822, {
    instanceKey = "TheStonecore",
    bossKey = "TheStonecoreTrash",
    difficulty = "N",
  })
  Add(55823, {
    instanceKey = "TheStonecore",
    bossKey = "TheStonecoreTrash",
    difficulty = "N",
  })
  Add(55824, {
    instanceKey = "TheStonecore",
    bossKey = "TheStonecoreTrash",
    difficulty = "N",
  })
  Add(55830, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "N",
  })
  Add(55831, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "N",
  })
  Add(55832, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "N",
  })
  Add(55833, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "N",
  })
  Add(55834, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "N",
  })
  Add(55835, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "N",
  })
  Add(55838, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "N",
  })
  Add(55839, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "N",
  })
  Add(55840, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "N",
  })
  Add(55841, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "N",
  })
  Add(55842, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55844, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55845, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55846, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55847, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55848, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55849, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55850, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55851, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55852, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55853, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "N",
  })
  Add(55854, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "TheVortexPinnacleTrash",
    difficulty = "N",
  })
  Add(55855, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "TheVortexPinnacleTrash",
    difficulty = "N",
  })
  Add(55856, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "N",
  })
  Add(55857, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "N",
  })
  Add(55858, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "N",
  })
  Add(55859, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "N",
  })
  Add(55860, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "N",
  })
  Add(55861, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "N",
  })
  Add(55862, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "N",
  })
  Add(55863, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "N",
  })
  Add(55864, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "N",
  })
  Add(55865, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "N",
  })
  Add(55866, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "N",
  })
  Add(55867, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "N",
  })
  Add(55868, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "N",
  })
  Add(55869, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "N",
  })
  Add(55870, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "N",
  })
  Add(55871, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55872, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55873, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55874, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55875, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55876, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55877, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55878, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55879, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55880, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "N",
  })
  Add(55881, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "LostCityOfTolvirTrash",
    difficulty = "N",
  })
  Add(55882, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "LostCityOfTolvirTrash",
    difficulty = "N",
  })
  Add(55884, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "LostCityOfTolvirTrash",
    difficulty = "N",
  })
  Add(55886, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "N",
  })
  Add(55887, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "N",
  })
  Add(55888, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "N",
  })
  Add(55889, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "N",
  })
  Add(55890, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "N",
  })
  Add(55992, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "N",
  })
  Add(55993, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "N",
  })
  Add(55994, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "N",
  })
  Add(55995, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "N",
  })
  Add(55996, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "N",
  })
  Add(55997, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "N",
  })
  Add(55998, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "N",
  })
  Add(55999, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "N",
  })
  Add(56000, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "N",
  })
  Add(56001, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "N",
  })
  Add(56093, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "N",
  })
  Add(56094, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "N",
  })
  Add(56095, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "N",
  })
  Add(56096, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "N",
  })
  Add(56097, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "N",
  })
  Add(56098, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56099, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56100, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56101, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56102, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56104, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56105, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56106, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56107, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56108, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "N",
  })
  Add(56109, {
    instanceKey = "HallsOfOrigination",
    bossKey = "HallsOfOriginationTrash",
    difficulty = "N",
  })
  Add(56110, {
    instanceKey = "HallsOfOrigination",
    bossKey = "HallsOfOriginationTrash",
    difficulty = "N",
  })
  Add(56111, {
    instanceKey = "HallsOfOrigination",
    bossKey = "HallsOfOriginationTrash",
    difficulty = "N",
  })
  Add(56112, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "N",
  })
  Add(56113, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "N",
  })
  Add(56114, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "N",
  })
  Add(56115, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "N",
  })
  Add(56116, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "N",
  })
  Add(56118, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "N",
  })
  Add(56119, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "N",
  })
  Add(56120, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "N",
  })
  Add(56121, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "N",
  })
  Add(56122, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "N",
  })
  Add(56123, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "N",
  })
  Add(56124, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "N",
  })
  Add(56125, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "N",
  })
  Add(56126, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "N",
  })
  Add(56127, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "N",
  })
  Add(56128, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56129, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56130, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56131, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56132, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56133, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56135, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56136, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56137, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56138, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "N",
  })
  Add(56218, {
    instanceKey = "GrimBatol",
    bossKey = "GrimBatolTrash",
    difficulty = "N",
  })
  Add(56219, {
    instanceKey = "GrimBatol",
    bossKey = "GrimBatolTrash",
    difficulty = "N",
  })
  Add(56220, {
    instanceKey = "GrimBatol",
    bossKey = "GrimBatolTrash",
    difficulty = "N",
  })
  Add(56266, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "H",
  })
  Add(56266, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERI",
  })
  Add(56266, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERT",
  })
  Add(56267, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "H",
  })
  Add(56267, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERI",
  })
  Add(56267, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERT",
  })
  Add(56268, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "H",
  })
  Add(56268, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERI",
  })
  Add(56268, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERT",
  })
  Add(56269, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "H",
  })
  Add(56269, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERI",
  })
  Add(56269, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERT",
  })
  Add(56270, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "H",
  })
  Add(56270, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERI",
  })
  Add(56270, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "LadyNaz'jar",
    difficulty = "ERT",
  })
  Add(56271, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "H",
  })
  Add(56271, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERI",
  })
  Add(56271, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERT",
  })
  Add(56272, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "H",
  })
  Add(56272, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERI",
  })
  Add(56272, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERT",
  })
  Add(56273, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "H",
  })
  Add(56273, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERI",
  })
  Add(56273, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERT",
  })
  Add(56274, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "H",
  })
  Add(56274, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERI",
  })
  Add(56274, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERT",
  })
  Add(56275, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "H",
  })
  Add(56275, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERI",
  })
  Add(56275, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "CommanderUlthok,theFesteringPrince",
    difficulty = "ERT",
  })
  Add(56276, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "H",
  })
  Add(56276, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERI",
  })
  Add(56276, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERT",
  })
  Add(56277, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "H",
  })
  Add(56277, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERI",
  })
  Add(56277, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERT",
  })
  Add(56278, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "H",
  })
  Add(56278, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERI",
  })
  Add(56278, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERT",
  })
  Add(56279, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "H",
  })
  Add(56279, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERI",
  })
  Add(56279, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERT",
  })
  Add(56280, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "H",
  })
  Add(56280, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERI",
  })
  Add(56280, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "MindbenderGhur'sha",
    difficulty = "ERT",
  })
  Add(56281, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56281, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56281, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56282, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56282, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56282, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56283, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56283, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56283, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56284, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56284, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56284, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56285, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56285, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56285, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56286, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56286, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56286, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56288, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56288, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56288, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56289, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56289, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56289, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56290, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56290, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56290, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56291, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "H",
  })
  Add(56291, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERI",
  })
  Add(56291, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(56295, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "H",
  })
  Add(56295, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERI",
  })
  Add(56295, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERT",
  })
  Add(56296, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "H",
  })
  Add(56296, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERI",
  })
  Add(56296, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERT",
  })
  Add(56297, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "H",
  })
  Add(56297, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERI",
  })
  Add(56297, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERT",
  })
  Add(56298, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "H",
  })
  Add(56298, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERI",
  })
  Add(56298, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERT",
  })
  Add(56299, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "H",
  })
  Add(56299, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERI",
  })
  Add(56299, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Corla,HeraldofTwilight",
    difficulty = "ERT",
  })
  Add(56300, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "H",
  })
  Add(56300, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERI",
  })
  Add(56300, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERT",
  })
  Add(56301, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "H",
  })
  Add(56301, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERI",
  })
  Add(56301, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERT",
  })
  Add(56302, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "H",
  })
  Add(56302, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERI",
  })
  Add(56302, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERT",
  })
  Add(56303, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "H",
  })
  Add(56303, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERI",
  })
  Add(56303, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERT",
  })
  Add(56304, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "H",
  })
  Add(56304, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERI",
  })
  Add(56304, {
    instanceKey = "BlackrockCaverns",
    bossKey = "KarshSteelbender",
    difficulty = "ERT",
  })
  Add(56305, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "H",
  })
  Add(56305, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERI",
  })
  Add(56305, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERT",
  })
  Add(56306, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "H",
  })
  Add(56306, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERI",
  })
  Add(56306, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERT",
  })
  Add(56307, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "H",
  })
  Add(56307, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERI",
  })
  Add(56307, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERT",
  })
  Add(56308, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "H",
  })
  Add(56308, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERI",
  })
  Add(56308, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERT",
  })
  Add(56309, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "H",
  })
  Add(56309, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERI",
  })
  Add(56309, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Beauty",
    difficulty = "ERT",
  })
  Add(56310, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "H",
  })
  Add(56310, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERI",
  })
  Add(56310, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERT",
  })
  Add(56311, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "H",
  })
  Add(56311, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERI",
  })
  Add(56311, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERT",
  })
  Add(56312, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "H",
  })
  Add(56312, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERI",
  })
  Add(56312, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERT",
  })
  Add(56313, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "H",
  })
  Add(56313, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERI",
  })
  Add(56313, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERT",
  })
  Add(56314, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "H",
  })
  Add(56314, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERI",
  })
  Add(56314, {
    instanceKey = "BlackrockCaverns",
    bossKey = "Rom'oggBonecrusher",
    difficulty = "ERT",
  })
  Add(56315, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56315, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56315, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56316, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56316, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56316, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56317, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56317, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56317, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56318, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56318, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56318, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56319, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56319, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56319, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56320, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56320, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56320, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56321, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56321, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56321, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56322, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56322, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56322, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56323, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56323, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56323, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56324, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "H",
  })
  Add(56324, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERI",
  })
  Add(56324, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(56328, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "H",
  })
  Add(56328, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERI",
  })
  Add(56328, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERT",
  })
  Add(56329, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "H",
  })
  Add(56329, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERI",
  })
  Add(56329, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERT",
  })
  Add(56330, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "H",
  })
  Add(56330, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERI",
  })
  Add(56330, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERT",
  })
  Add(56331, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "H",
  })
  Add(56331, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERI",
  })
  Add(56331, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERT",
  })
  Add(56332, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "H",
  })
  Add(56332, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERI",
  })
  Add(56332, {
    instanceKey = "TheStonecore",
    bossKey = "Corborus",
    difficulty = "ERT",
  })
  Add(56333, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "H",
  })
  Add(56333, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERI",
  })
  Add(56333, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERT",
  })
  Add(56334, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "H",
  })
  Add(56334, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERI",
  })
  Add(56334, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERT",
  })
  Add(56335, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "H",
  })
  Add(56335, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERI",
  })
  Add(56335, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERT",
  })
  Add(56336, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "H",
  })
  Add(56336, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERI",
  })
  Add(56336, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERT",
  })
  Add(56337, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "H",
  })
  Add(56337, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERI",
  })
  Add(56337, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERT",
  })
  Add(56338, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "H",
  })
  Add(56338, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERI",
  })
  Add(56338, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERT",
  })
  Add(56339, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "H",
  })
  Add(56339, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERI",
  })
  Add(56339, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERT",
  })
  Add(56340, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "H",
  })
  Add(56340, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERI",
  })
  Add(56340, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERT",
  })
  Add(56341, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "H",
  })
  Add(56341, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERI",
  })
  Add(56341, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERT",
  })
  Add(56342, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "H",
  })
  Add(56342, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERI",
  })
  Add(56342, {
    instanceKey = "TheStonecore",
    bossKey = "Ozruk",
    difficulty = "ERT",
  })
  Add(56343, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56343, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56343, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56344, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56344, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56344, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56345, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56345, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56345, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56346, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56346, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56346, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56347, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56347, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56347, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56348, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56348, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56348, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56349, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56349, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56349, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56350, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56350, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56350, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56351, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56351, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56351, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56352, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "H",
  })
  Add(56352, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERI",
  })
  Add(56352, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(56356, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "H",
  })
  Add(56356, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERI",
  })
  Add(56356, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERT",
  })
  Add(56357, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "H",
  })
  Add(56357, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERI",
  })
  Add(56357, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERT",
  })
  Add(56358, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "H",
  })
  Add(56358, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERI",
  })
  Add(56358, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERT",
  })
  Add(56359, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "H",
  })
  Add(56359, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERI",
  })
  Add(56359, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERT",
  })
  Add(56360, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "H",
  })
  Add(56360, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERI",
  })
  Add(56360, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERT",
  })
  Add(56361, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "H",
  })
  Add(56361, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERI",
  })
  Add(56361, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERT",
  })
  Add(56362, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "H",
  })
  Add(56362, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERI",
  })
  Add(56362, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERT",
  })
  Add(56363, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "H",
  })
  Add(56363, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERI",
  })
  Add(56363, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERT",
  })
  Add(56364, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "H",
  })
  Add(56364, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERI",
  })
  Add(56364, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERT",
  })
  Add(56365, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "H",
  })
  Add(56365, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERI",
  })
  Add(56365, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERT",
  })
  Add(56366, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56366, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56366, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56367, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56367, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56367, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56368, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56368, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56368, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56369, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56369, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56369, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56370, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56370, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56370, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56371, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56371, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56371, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56372, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56372, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56372, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56373, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56373, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56373, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56374, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56374, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56374, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56375, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56375, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56375, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56376, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "H",
  })
  Add(56376, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERI",
  })
  Add(56376, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(56379, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "H",
  })
  Add(56379, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERI",
  })
  Add(56379, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERT",
  })
  Add(56380, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "H",
  })
  Add(56380, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERI",
  })
  Add(56380, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERT",
  })
  Add(56381, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "H",
  })
  Add(56381, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERI",
  })
  Add(56381, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERT",
  })
  Add(56382, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "H",
  })
  Add(56382, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERI",
  })
  Add(56382, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERT",
  })
  Add(56383, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "H",
  })
  Add(56383, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERI",
  })
  Add(56383, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "GeneralHusam",
    difficulty = "ERT",
  })
  Add(56384, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "H",
  })
  Add(56384, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERI",
  })
  Add(56384, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERT",
  })
  Add(56385, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "H",
  })
  Add(56385, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERI",
  })
  Add(56385, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERT",
  })
  Add(56386, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "H",
  })
  Add(56386, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERI",
  })
  Add(56386, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERT",
  })
  Add(56387, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "H",
  })
  Add(56387, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERI",
  })
  Add(56387, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERT",
  })
  Add(56388, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "H",
  })
  Add(56388, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERI",
  })
  Add(56388, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "HighProphetBarim",
    difficulty = "ERT",
  })
  Add(56389, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "H",
  })
  Add(56389, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERI",
  })
  Add(56389, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERT",
  })
  Add(56390, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "H",
  })
  Add(56390, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERI",
  })
  Add(56390, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERT",
  })
  Add(56391, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "H",
  })
  Add(56391, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERI",
  })
  Add(56391, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERT",
  })
  Add(56392, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "H",
  })
  Add(56392, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERI",
  })
  Add(56392, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERT",
  })
  Add(56393, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "H",
  })
  Add(56393, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERI",
  })
  Add(56393, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Lockmaw",
    difficulty = "ERT",
  })
  Add(56394, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56394, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56394, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56395, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56395, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56395, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56396, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56396, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56396, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56397, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56397, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56397, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56398, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56398, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56398, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56399, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56399, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56399, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56400, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56400, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56400, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56401, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56401, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56401, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56402, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56402, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56402, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56403, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "H",
  })
  Add(56403, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERI",
  })
  Add(56403, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(56407, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "H",
  })
  Add(56407, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERI",
  })
  Add(56407, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERT",
  })
  Add(56408, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "H",
  })
  Add(56408, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERI",
  })
  Add(56408, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERT",
  })
  Add(56409, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "H",
  })
  Add(56409, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERI",
  })
  Add(56409, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERT",
  })
  Add(56410, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "H",
  })
  Add(56410, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERI",
  })
  Add(56410, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERT",
  })
  Add(56411, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "H",
  })
  Add(56411, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERI",
  })
  Add(56411, {
    instanceKey = "HallsOfOrigination",
    bossKey = "TempleGuardianAnhuur",
    difficulty = "ERT",
  })
  Add(56412, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "H",
  })
  Add(56412, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERI",
  })
  Add(56412, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERT",
  })
  Add(56413, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "H",
  })
  Add(56413, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERI",
  })
  Add(56413, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERT",
  })
  Add(56414, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "H",
  })
  Add(56414, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERI",
  })
  Add(56414, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERT",
  })
  Add(56415, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "H",
  })
  Add(56415, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERI",
  })
  Add(56415, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERT",
  })
  Add(56416, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "H",
  })
  Add(56416, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERI",
  })
  Add(56416, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Isiset,ConstructofMagic",
    difficulty = "ERT",
  })
  Add(56417, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "H",
  })
  Add(56417, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERI",
  })
  Add(56417, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERT",
  })
  Add(56418, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "H",
  })
  Add(56418, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERI",
  })
  Add(56418, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERT",
  })
  Add(56419, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "H",
  })
  Add(56419, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERI",
  })
  Add(56419, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERT",
  })
  Add(56420, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "H",
  })
  Add(56420, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERI",
  })
  Add(56420, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERT",
  })
  Add(56421, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "H",
  })
  Add(56421, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERI",
  })
  Add(56421, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Ammunae,ConstructofLife",
    difficulty = "ERT",
  })
  Add(56422, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "H",
  })
  Add(56422, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERI",
  })
  Add(56422, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERT",
  })
  Add(56423, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "H",
  })
  Add(56423, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERI",
  })
  Add(56423, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERT",
  })
  Add(56424, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "H",
  })
  Add(56424, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERI",
  })
  Add(56424, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERT",
  })
  Add(56425, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "H",
  })
  Add(56425, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERI",
  })
  Add(56425, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERT",
  })
  Add(56426, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "H",
  })
  Add(56426, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERI",
  })
  Add(56426, {
    instanceKey = "HallsOfOrigination",
    bossKey = "EarthragerPtah",
    difficulty = "ERT",
  })
  Add(56427, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56427, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56427, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56428, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56428, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56428, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56429, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56429, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56429, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56430, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56430, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56430, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56431, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56431, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56431, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56432, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56432, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56432, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56433, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56433, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56433, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56434, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56434, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56434, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56435, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56435, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56435, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56436, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "H",
  })
  Add(56436, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERI",
  })
  Add(56436, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(56440, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "H",
  })
  Add(56440, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERI",
  })
  Add(56440, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERT",
  })
  Add(56441, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "H",
  })
  Add(56441, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERI",
  })
  Add(56441, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERT",
  })
  Add(56442, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "H",
  })
  Add(56442, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERI",
  })
  Add(56442, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERT",
  })
  Add(56443, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "H",
  })
  Add(56443, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERI",
  })
  Add(56443, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERT",
  })
  Add(56444, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "H",
  })
  Add(56444, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERI",
  })
  Add(56444, {
    instanceKey = "GrimBatol",
    bossKey = "GeneralUmbriss",
    difficulty = "ERT",
  })
  Add(56445, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "H",
  })
  Add(56445, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERI",
  })
  Add(56445, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERT",
  })
  Add(56446, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "H",
  })
  Add(56446, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERI",
  })
  Add(56446, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERT",
  })
  Add(56447, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "H",
  })
  Add(56447, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERI",
  })
  Add(56447, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERT",
  })
  Add(56448, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "H",
  })
  Add(56448, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERI",
  })
  Add(56448, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERT",
  })
  Add(56449, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "H",
  })
  Add(56449, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERI",
  })
  Add(56449, {
    instanceKey = "GrimBatol",
    bossKey = "ForgemasterThrongus",
    difficulty = "ERT",
  })
  Add(56450, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "H",
  })
  Add(56450, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERI",
  })
  Add(56450, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERT",
  })
  Add(56451, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "H",
  })
  Add(56451, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERI",
  })
  Add(56451, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERT",
  })
  Add(56452, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "H",
  })
  Add(56452, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERI",
  })
  Add(56452, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERT",
  })
  Add(56453, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "H",
  })
  Add(56453, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERI",
  })
  Add(56453, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERT",
  })
  Add(56454, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "H",
  })
  Add(56454, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERI",
  })
  Add(56454, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERT",
  })
  Add(56455, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56455, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56455, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56456, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56456, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56456, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56457, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56457, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56457, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56458, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56458, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56458, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56459, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56459, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56459, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56460, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56460, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56460, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56461, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56461, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56461, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56462, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56462, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56462, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56463, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56463, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56463, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(56464, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "H",
  })
  Add(56464, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERI",
  })
  Add(56464, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(57855, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "N",
  })
  Add(57856, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "N",
  })
  Add(57857, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "N",
  })
  Add(57858, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "N",
  })
  Add(57860, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "N",
  })
  Add(57861, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "N",
  })
  Add(57862, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "N",
  })
  Add(57863, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "N",
  })
  Add(57864, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "N",
  })
  Add(57865, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "N",
  })
  Add(57866, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "H",
  })
  Add(57866, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERI",
  })
  Add(57866, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERT",
  })
  Add(57867, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "H",
  })
  Add(57867, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERI",
  })
  Add(57867, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERT",
  })
  Add(57868, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "H",
  })
  Add(57868, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERI",
  })
  Add(57868, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERT",
  })
  Add(57869, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "H",
  })
  Add(57869, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERI",
  })
  Add(57869, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERT",
  })
  Add(57870, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "H",
  })
  Add(57870, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERI",
  })
  Add(57870, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Anraphet",
    difficulty = "ERT",
  })
  Add(57871, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "H",
  })
  Add(57871, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERI",
  })
  Add(57871, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERT",
  })
  Add(57872, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "H",
  })
  Add(57872, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERI",
  })
  Add(57872, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERT",
  })
  Add(57873, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "H",
  })
  Add(57873, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERI",
  })
  Add(57873, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERT",
  })
  Add(57874, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "H",
  })
  Add(57874, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERI",
  })
  Add(57874, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERT",
  })
  Add(57875, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "H",
  })
  Add(57875, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERI",
  })
  Add(57875, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Setesh,ConstructofDestruction",
    difficulty = "ERT",
  })
  Add(59117, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59118, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59119, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59120, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59121, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59122, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59216, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59217, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59218, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59219, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59220, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(59221, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59222, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59223, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59224, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59225, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59233, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59234, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59310, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59311, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59312, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59313, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59314, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59315, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59316, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59317, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59318, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59319, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59320, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59321, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59322, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59324, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59325, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59326, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59327, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "N",
  })
  Add(59328, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59329, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59330, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59331, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59332, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59333, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59334, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59335, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59336, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59337, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59340, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59341, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59342, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59343, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59344, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59346, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59347, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59348, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59349, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59350, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59351, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59352, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59353, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59354, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "N",
  })
  Add(59355, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59356, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59441, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59442, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59443, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59444, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59450, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59451, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "N",
  })
  Add(59452, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59454, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59457, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59459, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(59460, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59461, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59462, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59463, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59464, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59465, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59466, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59467, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59468, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(59469, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59470, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59471, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59472, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59473, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59474, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59475, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59476, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59481, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59482, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59483, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59484, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "N",
  })
  Add(59485, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59486, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59487, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59490, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59492, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "N",
  })
  Add(59494, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59495, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59497, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59498, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59499, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59500, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59501, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(59502, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59503, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59504, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59505, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59506, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59507, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59508, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59509, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59510, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59511, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59512, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(59513, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59514, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "N",
  })
  Add(59515, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(59516, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(59517, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(59518, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(59519, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(59520, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(59521, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(59525, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(59901, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(60201, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(60202, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(60210, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(60211, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(60226, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60227, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60228, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60229, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60230, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60231, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60232, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60233, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60234, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60235, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60236, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60237, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(60238, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Sinestra",
    difficulty = "H",
  })
  Add(63040, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "N",
  })
  Add(63040, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "H",
  })
  Add(63040, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERI",
  })
  Add(63040, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Altairus",
    difficulty = "ERT",
  })
  Add(63041, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63041, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(63043, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "N",
  })
  Add(63043, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "H",
  })
  Add(63043, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERI",
  })
  Add(63043, {
    instanceKey = "TheStonecore",
    bossKey = "Slabhide",
    difficulty = "ERT",
  })
  Add(63433, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "H",
  })
  Add(63433, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERI",
  })
  Add(63433, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERT",
  })
  Add(63434, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "H",
  })
  Add(63434, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERI",
  })
  Add(63434, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERT",
  })
  Add(63435, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "H",
  })
  Add(63435, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERI",
  })
  Add(63435, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERT",
  })
  Add(63436, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "H",
  })
  Add(63436, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERI",
  })
  Add(63436, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERT",
  })
  Add(63437, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "H",
  })
  Add(63437, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERI",
  })
  Add(63437, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronAshbury",
    difficulty = "ERT",
  })
  Add(63438, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "H",
  })
  Add(63438, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERI",
  })
  Add(63438, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERT",
  })
  Add(63439, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "H",
  })
  Add(63439, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERI",
  })
  Add(63439, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERT",
  })
  Add(63440, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "H",
  })
  Add(63440, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERI",
  })
  Add(63440, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERT",
  })
  Add(63441, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "H",
  })
  Add(63441, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERI",
  })
  Add(63441, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERT",
  })
  Add(63444, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "H",
  })
  Add(63444, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERI",
  })
  Add(63444, {
    instanceKey = "ShadowfangKeep",
    bossKey = "BaronSilverlaine",
    difficulty = "ERT",
  })
  Add(63445, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "H",
  })
  Add(63445, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERI",
  })
  Add(63445, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERT",
  })
  Add(63446, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "H",
  })
  Add(63446, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERI",
  })
  Add(63446, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERT",
  })
  Add(63447, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "H",
  })
  Add(63447, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERI",
  })
  Add(63447, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERT",
  })
  Add(63448, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "H",
  })
  Add(63448, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERI",
  })
  Add(63448, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERT",
  })
  Add(63449, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "H",
  })
  Add(63449, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERI",
  })
  Add(63449, {
    instanceKey = "ShadowfangKeep",
    bossKey = "CommanderSpringvale",
    difficulty = "ERT",
  })
  Add(63450, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "H",
  })
  Add(63450, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERI",
  })
  Add(63450, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERT",
  })
  Add(63452, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "H",
  })
  Add(63452, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERI",
  })
  Add(63452, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERT",
  })
  Add(63453, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "H",
  })
  Add(63453, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERI",
  })
  Add(63453, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERT",
  })
  Add(63454, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "H",
  })
  Add(63454, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERI",
  })
  Add(63454, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERT",
  })
  Add(63455, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "H",
  })
  Add(63455, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERI",
  })
  Add(63455, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordWalden",
    difficulty = "ERT",
  })
  Add(63456, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63456, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63456, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63457, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63457, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63457, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63458, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63458, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63458, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63459, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63459, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63459, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63460, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63460, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63460, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63461, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63461, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63461, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63462, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63462, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63462, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63463, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63463, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63463, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63464, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63464, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63464, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63465, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "H",
  })
  Add(63465, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERI",
  })
  Add(63465, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(63467, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "H",
  })
  Add(63467, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERI",
  })
  Add(63467, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERT",
  })
  Add(63468, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "H",
  })
  Add(63468, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERI",
  })
  Add(63468, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERT",
  })
  Add(63470, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "H",
  })
  Add(63470, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERI",
  })
  Add(63470, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERT",
  })
  Add(63471, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "H",
  })
  Add(63471, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERI",
  })
  Add(63471, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERT",
  })
  Add(63473, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "H",
  })
  Add(63473, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERI",
  })
  Add(63473, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERT",
  })
  Add(63474, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "H",
  })
  Add(63474, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERI",
  })
  Add(63474, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERT",
  })
  Add(63475, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "H",
  })
  Add(63475, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERI",
  })
  Add(63475, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERT",
  })
  Add(63476, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "H",
  })
  Add(63476, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERI",
  })
  Add(63476, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERT",
  })
  Add(63478, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63478, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63478, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63479, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63479, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63479, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63480, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63480, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63480, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63482, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63482, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63482, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63483, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63483, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63483, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63484, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63484, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63484, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63485, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63485, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63485, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63486, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63486, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63486, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63487, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(63487, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(63487, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(63488, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63489, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63490, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63491, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63492, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63493, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63494, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63495, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63496, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63497, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63498, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "N",
  })
  Add(63499, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63500, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63501, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63502, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63503, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63504, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63505, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63506, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63507, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63531, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(63532, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(63533, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(63534, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(63535, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(63536, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "N",
  })
  Add(63537, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(63538, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(63540, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "N",
  })
  Add(63679, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(63680, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(63682, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(63682, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63683, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(63683, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(63684, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "N",
  })
  Add(63684, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(64314, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(64314, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(64315, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(64315, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(64316, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "N",
  })
  Add(64316, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(65000, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65000, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65001, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65001, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65002, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65002, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65003, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65004, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65007, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65017, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65018, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65019, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65020, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65021, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65022, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65023, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65024, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65025, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65026, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65027, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65028, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65029, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65030, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65031, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65032, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65033, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65034, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65035, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65036, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65037, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65038, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65039, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65040, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(65041, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65042, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65043, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65044, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65045, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65046, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65047, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65048, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65049, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65050, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65051, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(65052, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65053, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65054, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65055, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65056, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65057, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65058, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65059, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65060, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65061, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65062, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65063, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65064, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65065, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65066, {
    instanceKey = "BlackwingDescent",
    bossKey = "Atramedes",
    difficulty = "H",
  })
  Add(65067, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65068, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65069, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65070, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65071, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65072, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65073, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65074, {
    instanceKey = "BlackwingDescent",
    bossKey = "Nefarian'sEnd",
    difficulty = "H",
  })
  Add(65075, {
    instanceKey = "BlackwingDescent",
    bossKey = "Chimaeron",
    difficulty = "H",
  })
  Add(65076, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65077, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65078, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65079, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65080, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65081, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65082, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65083, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65084, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65085, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65086, {
    instanceKey = "BlackwingDescent",
    bossKey = "OmnotronDefenseSystem",
    difficulty = "H",
  })
  Add(65087, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65087, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65088, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65088, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65089, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65089, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65090, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65091, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65092, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65093, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65094, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65095, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65096, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65105, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65106, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65107, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65108, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65109, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65110, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65111, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65112, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheralionandValiona",
    difficulty = "H",
  })
  Add(65113, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65114, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65115, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65116, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65117, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65118, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65119, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65120, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65121, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65122, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "AscendantCouncil",
    difficulty = "H",
  })
  Add(65123, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65124, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65125, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65126, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65127, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65128, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65129, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65130, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65131, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65132, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65133, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65134, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65135, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65136, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65137, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65138, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65139, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65140, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65141, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65142, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65143, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65144, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(65145, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(65163, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "H",
  })
  Add(65163, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERI",
  })
  Add(65163, {
    instanceKey = "Deadmines",
    bossKey = "Glubtok",
    difficulty = "ERT",
  })
  Add(65164, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "H",
  })
  Add(65164, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERI",
  })
  Add(65164, {
    instanceKey = "Deadmines",
    bossKey = "HelixGearbreaker",
    difficulty = "ERT",
  })
  Add(65165, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "H",
  })
  Add(65165, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "ERI",
  })
  Add(65165, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "ERT",
  })
  Add(65166, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "H",
  })
  Add(65166, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "ERI",
  })
  Add(65166, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "ERT",
  })
  Add(65167, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "H",
  })
  Add(65167, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "ERI",
  })
  Add(65167, {
    instanceKey = "Deadmines",
    bossKey = "FoeReaper5000",
    difficulty = "ERT",
  })
  Add(65168, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "H",
  })
  Add(65168, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "ERI",
  })
  Add(65168, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "ERT",
  })
  Add(65169, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "H",
  })
  Add(65169, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "ERI",
  })
  Add(65169, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "ERT",
  })
  Add(65170, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "H",
  })
  Add(65170, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "ERI",
  })
  Add(65170, {
    instanceKey = "Deadmines",
    bossKey = "AdmiralRipsnarl",
    difficulty = "ERT",
  })
  Add(65171, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "H",
  })
  Add(65171, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERI",
  })
  Add(65171, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERT",
  })
  Add(65172, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "H",
  })
  Add(65172, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERI",
  })
  Add(65172, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERT",
  })
  Add(65173, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "H",
  })
  Add(65173, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERI",
  })
  Add(65173, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERT",
  })
  Add(65174, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "H",
  })
  Add(65174, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERI",
  })
  Add(65174, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERT",
  })
  Add(65177, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "H",
  })
  Add(65177, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERI",
  })
  Add(65177, {
    instanceKey = "Deadmines",
    bossKey = '"Captain"Cookie',
    difficulty = "ERT",
  })
  Add(65178, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "H",
  })
  Add(65178, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERI",
  })
  Add(65178, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(65367, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65368, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65369, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65370, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65371, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65372, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65373, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65374, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65375, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65376, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65377, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "TheConclaveofWind",
    difficulty = "H",
  })
  Add(65378, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65379, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65380, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65381, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65382, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65383, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65384, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65385, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65386, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(65660, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "N",
  })
  Add(65660, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "H",
  })
  Add(65660, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERI",
  })
  Add(65660, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "GrandVizierErtan",
    difficulty = "ERT",
  })
  Add(66927, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "N",
  })
  Add(66927, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "H",
  })
  Add(66927, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERI",
  })
  Add(66927, {
    instanceKey = "GrimBatol",
    bossKey = "DrahgaShadowburner",
    difficulty = "ERT",
  })
  Add(66998, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(67151, {
    instanceKey = "WorldBossesCata",
    bossKey = "Poseidus",
    difficulty = "N",
  })
  Add(67423, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(67424, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(67425, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "HalfusWyrmbreaker",
    difficulty = "H",
  })
  Add(67426, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(67427, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(67428, {
    instanceKey = "BlackwingDescent",
    bossKey = "Maloriak",
    difficulty = "H",
  })
  Add(67429, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(67430, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(67431, {
    instanceKey = "BlackwingDescent",
    bossKey = "Magmaw",
    difficulty = "H",
  })
  Add(67541, {
    instanceKey = "WorldBossesCata",
    bossKey = "Akma'hat",
    difficulty = "N",
  })
  Add(67541, {
    instanceKey = "WorldBossesCata",
    bossKey = "Garr",
    difficulty = "N",
  })
  Add(67541, {
    instanceKey = "WorldBossesCata",
    bossKey = "Julak-Doom",
    difficulty = "N",
  })
  Add(67541, {
    instanceKey = "WorldBossesCata",
    bossKey = "Mobus",
    difficulty = "N",
  })
  Add(67541, {
    instanceKey = "WorldBossesCata",
    bossKey = "Xariona",
    difficulty = "N",
  })
  Add(67541, {
    instanceKey = "WorldBossesCata",
    bossKey = "Poseidus",
    difficulty = "N",
  })
  Add(68127, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(68128, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(68129, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(68130, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(68131, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(68132, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(68600, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "Cho'gall",
    difficulty = "H",
  })
  Add(68601, {
    instanceKey = "BlackwingDescent",
    bossKey = "BlackwingDescentTrash",
    difficulty = "N",
  })
  Add(68608, {
    instanceKey = "TheBastionOfTwilight",
    bossKey = "TheBastionOfTwilightTrash",
    difficulty = "N",
  })
  Add(68823, {
    instanceKey = "ZulGurub",
    bossKey = "BloodlordMandokir",
    difficulty = "H",
  })
  Add(68824, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestessKilnara",
    difficulty = "H",
  })
  Add(68915, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(68925, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(68926, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(68927, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(68972, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(68981, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(68982, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(68983, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(68994, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(68995, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(69109, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(69110, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(69111, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(69112, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(69113, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(69138, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(69139, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(69149, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(69150, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(69167, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(69224, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(69224, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(69237, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(69264, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(69549, {
    instanceKey = "ZulAman",
    bossKey = "Akil'zon",
    difficulty = "H",
  })
  Add(69550, {
    instanceKey = "ZulAman",
    bossKey = "Akil'zon",
    difficulty = "H",
  })
  Add(69551, {
    instanceKey = "ZulAman",
    bossKey = "Akil'zon",
    difficulty = "H",
  })
  Add(69552, {
    instanceKey = "ZulAman",
    bossKey = "Akil'zon",
    difficulty = "H",
  })
  Add(69553, {
    instanceKey = "ZulAman",
    bossKey = "Akil'zon",
    difficulty = "H",
  })
  Add(69554, {
    instanceKey = "ZulAman",
    bossKey = "Nalorakk",
    difficulty = "H",
  })
  Add(69555, {
    instanceKey = "ZulAman",
    bossKey = "Nalorakk",
    difficulty = "H",
  })
  Add(69556, {
    instanceKey = "ZulAman",
    bossKey = "Nalorakk",
    difficulty = "H",
  })
  Add(69557, {
    instanceKey = "ZulAman",
    bossKey = "Nalorakk",
    difficulty = "H",
  })
  Add(69558, {
    instanceKey = "ZulAman",
    bossKey = "Nalorakk",
    difficulty = "H",
  })
  Add(69559, {
    instanceKey = "ZulAman",
    bossKey = "Jan'alai",
    difficulty = "H",
  })
  Add(69560, {
    instanceKey = "ZulAman",
    bossKey = "Jan'alai",
    difficulty = "H",
  })
  Add(69561, {
    instanceKey = "ZulAman",
    bossKey = "Jan'alai",
    difficulty = "H",
  })
  Add(69562, {
    instanceKey = "ZulAman",
    bossKey = "Jan'alai",
    difficulty = "H",
  })
  Add(69563, {
    instanceKey = "ZulAman",
    bossKey = "Jan'alai",
    difficulty = "H",
  })
  Add(69564, {
    instanceKey = "ZulAman",
    bossKey = "Halazzi",
    difficulty = "H",
  })
  Add(69565, {
    instanceKey = "ZulAman",
    bossKey = "Halazzi",
    difficulty = "H",
  })
  Add(69566, {
    instanceKey = "ZulAman",
    bossKey = "Halazzi",
    difficulty = "H",
  })
  Add(69567, {
    instanceKey = "ZulAman",
    bossKey = "Halazzi",
    difficulty = "H",
  })
  Add(69568, {
    instanceKey = "ZulAman",
    bossKey = "Halazzi",
    difficulty = "H",
  })
  Add(69569, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(69570, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(69571, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(69572, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(69573, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(69574, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69575, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69576, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69577, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69578, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69579, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69580, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69581, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69582, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69583, {
    instanceKey = "ZulAman",
    bossKey = "Daakara",
    difficulty = "H",
  })
  Add(69584, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69585, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69586, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69587, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69588, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69589, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69590, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69591, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69592, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69593, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69600, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestVenoxis",
    difficulty = "H",
  })
  Add(69601, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestVenoxis",
    difficulty = "H",
  })
  Add(69602, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestVenoxis",
    difficulty = "H",
  })
  Add(69603, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestVenoxis",
    difficulty = "H",
  })
  Add(69604, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestVenoxis",
    difficulty = "H",
  })
  Add(69605, {
    instanceKey = "ZulGurub",
    bossKey = "BloodlordMandokir",
    difficulty = "H",
  })
  Add(69606, {
    instanceKey = "ZulGurub",
    bossKey = "BloodlordMandokir",
    difficulty = "H",
  })
  Add(69607, {
    instanceKey = "ZulGurub",
    bossKey = "BloodlordMandokir",
    difficulty = "H",
  })
  Add(69608, {
    instanceKey = "ZulGurub",
    bossKey = "BloodlordMandokir",
    difficulty = "H",
  })
  Add(69609, {
    instanceKey = "ZulGurub",
    bossKey = "BloodlordMandokir",
    difficulty = "H",
  })
  Add(69610, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestessKilnara",
    difficulty = "H",
  })
  Add(69611, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestessKilnara",
    difficulty = "H",
  })
  Add(69612, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestessKilnara",
    difficulty = "H",
  })
  Add(69613, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestessKilnara",
    difficulty = "H",
  })
  Add(69614, {
    instanceKey = "ZulGurub",
    bossKey = "HighPriestessKilnara",
    difficulty = "H",
  })
  Add(69615, {
    instanceKey = "ZulGurub",
    bossKey = "Zanzil",
    difficulty = "H",
  })
  Add(69616, {
    instanceKey = "ZulGurub",
    bossKey = "Zanzil",
    difficulty = "H",
  })
  Add(69617, {
    instanceKey = "ZulGurub",
    bossKey = "Zanzil",
    difficulty = "H",
  })
  Add(69618, {
    instanceKey = "ZulGurub",
    bossKey = "Zanzil",
    difficulty = "H",
  })
  Add(69619, {
    instanceKey = "ZulGurub",
    bossKey = "Zanzil",
    difficulty = "H",
  })
  Add(69620, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69621, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69622, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69623, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69624, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69625, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69626, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69627, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69628, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69629, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69747, {
    instanceKey = "ZulAman",
    bossKey = "TimedChest",
    difficulty = "H",
  })
  Add(69762, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(69774, {
    instanceKey = "ZulGurub",
    bossKey = "Jin'dotheGodbreaker",
    difficulty = "H",
  })
  Add(69796, {
    instanceKey = "ZulGurub",
    bossKey = "ZulGurubTrash",
    difficulty = "H",
  })
  Add(69797, {
    instanceKey = "ZulAman",
    bossKey = "ZulAmanTrash",
    difficulty = "H",
  })
  Add(69798, {
    instanceKey = "ZulGurub",
    bossKey = "ZulGurubTrash",
    difficulty = "H",
  })
  Add(69799, {
    instanceKey = "ZulAman",
    bossKey = "ZulAmanTrash",
    difficulty = "H",
  })
  Add(69800, {
    instanceKey = "ZulGurub",
    bossKey = "ZulGurubTrash",
    difficulty = "H",
  })
  Add(69801, {
    instanceKey = "ZulAman",
    bossKey = "ZulAmanTrash",
    difficulty = "H",
  })
  Add(69802, {
    instanceKey = "ZulAman",
    bossKey = "ZulAmanTrash",
    difficulty = "H",
  })
  Add(69803, {
    instanceKey = "ZulGurub",
    bossKey = "ZulGurubTrash",
    difficulty = "H",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(69815, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(69827, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69828, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69829, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69830, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69831, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69833, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69834, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69835, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "N",
  })
  Add(69842, {
    instanceKey = "WorldBossesCata",
    bossKey = "Garr",
    difficulty = "N",
  })
  Add(69843, {
    instanceKey = "WorldBossesCata",
    bossKey = "Mobus",
    difficulty = "N",
  })
  Add(69844, {
    instanceKey = "WorldBossesCata",
    bossKey = "Julak-Doom",
    difficulty = "N",
  })
  Add(69848, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(69848, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(69876, {
    instanceKey = "WorldBossesCata",
    bossKey = "Xariona",
    difficulty = "N",
  })
  Add(69877, {
    instanceKey = "WorldBossesCata",
    bossKey = "Akma'hat",
    difficulty = "N",
  })
  Add(69878, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69879, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69880, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69881, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69882, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69883, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69884, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69885, {
    instanceKey = "ThroneOfTheFourWinds",
    bossKey = "Al'Akir",
    difficulty = "H",
  })
  Add(69897, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(69957, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69958, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69959, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69960, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69961, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69962, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69963, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69965, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69966, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69968, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69969, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69970, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69971, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69972, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69973, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69974, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69975, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(69976, {
    instanceKey = "Firelands",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(70080, {
    instanceKey = "ZulAman",
    bossKey = "HexLordMalacrass",
    difficulty = "H",
  })
  Add(70723, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(70733, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70734, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70735, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70736, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70737, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70738, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70739, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70912, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(70913, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(70914, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(70915, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(70916, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(70917, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(70920, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(70921, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(70922, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(70929, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(70985, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70986, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70987, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70988, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70989, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70990, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(70991, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(70992, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(70993, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71003, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71004, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71005, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71006, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71007, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71009, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71010, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71011, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71012, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71013, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71014, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71018, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71019, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71020, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71021, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71022, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71023, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71024, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71025, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71026, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71027, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71028, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71029, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71030, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71031, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71032, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71038, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71039, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71040, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71041, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71042, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71043, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71044, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71141, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71312, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71313, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71314, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71315, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71323, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71340, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71341, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71342, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71343, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71344, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71345, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "N",
  })
  Add(71346, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71347, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71348, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71349, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71350, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71351, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71352, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71353, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71354, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71355, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71356, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71357, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71358, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71359, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71360, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71361, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71362, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71365, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71366, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71367, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71401, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71402, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71403, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71404, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71405, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71406, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71407, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71408, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71409, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71410, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71411, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71412, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71413, {
    instanceKey = "Firelands",
    bossKey = "Beth'tilac",
    difficulty = "H",
  })
  Add(71414, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71415, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71416, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71417, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71418, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71419, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71420, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71421, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71422, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71423, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71424, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71425, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71426, {
    instanceKey = "Firelands",
    bossKey = "LordRhyolith",
    difficulty = "H",
  })
  Add(71427, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71428, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71429, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71430, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71431, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71432, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71433, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71434, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71435, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71436, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71437, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71438, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71439, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71440, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71441, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71442, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71443, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71444, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71445, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71446, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71447, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71448, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71449, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71450, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71451, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71452, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71453, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71454, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71455, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71456, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71457, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71458, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71459, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71460, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71461, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71462, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71463, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71464, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71465, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71466, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71467, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71468, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71469, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71470, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71471, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71472, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71473, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71474, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71475, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71557, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71558, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71559, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71560, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71561, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71562, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71563, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71564, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71567, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71568, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71575, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71577, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71579, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71580, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71587, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71590, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71592, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71593, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71610, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71611, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71612, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71613, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71614, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71615, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71616, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71617, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71617, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71640, {
    instanceKey = "Firelands",
    bossKey = "FirelandsTrash",
    difficulty = "N",
  })
  Add(71641, {
    instanceKey = "Firelands",
    bossKey = "Firestones",
  })
  Add(71665, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "N",
  })
  Add(71665, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71668, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71669, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71670, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71671, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71672, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71673, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71674, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71675, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71676, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71677, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71678, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71679, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71680, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71681, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71682, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71683, {
    instanceKey = "Firelands",
    bossKey = "Baleroc,theGatekeeper",
    difficulty = "H",
  })
  Add(71684, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71685, {
    instanceKey = "Firelands",
    bossKey = "Shannox",
    difficulty = "H",
  })
  Add(71686, {
    instanceKey = "Firelands",
    bossKey = "Alysrazor",
    difficulty = "H",
  })
  Add(71687, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "H",
  })
  Add(71688, {
    instanceKey = "Firelands",
    bossKey = "MajordomoStaghelm",
    difficulty = "N",
  })
  Add(71774, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71775, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "N",
  })
  Add(71776, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "N",
  })
  Add(71777, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71778, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71779, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "N",
  })
  Add(71780, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "N",
  })
  Add(71781, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71782, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "N",
  })
  Add(71783, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71784, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71785, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "N",
  })
  Add(71786, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "H",
  })
  Add(71787, {
    instanceKey = "Firelands",
    bossKey = "FirelandsShared",
    difficulty = "N",
  })
  Add(71797, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "H",
  })
  Add(71798, {
    instanceKey = "Firelands",
    bossKey = "Ragnaros",
    difficulty = "N",
  })
  Add(71805, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(71806, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(71807, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(71808, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(71809, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(71810, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(71965, {
    instanceKey = "WorldBossesCata",
    bossKey = "Akma'hat",
    difficulty = "N",
  })
  Add(71965, {
    instanceKey = "WorldBossesCata",
    bossKey = "Garr",
    difficulty = "N",
  })
  Add(71965, {
    instanceKey = "WorldBossesCata",
    bossKey = "Julak-Doom",
    difficulty = "N",
  })
  Add(71965, {
    instanceKey = "WorldBossesCata",
    bossKey = "Mobus",
    difficulty = "N",
  })
  Add(71965, {
    instanceKey = "WorldBossesCata",
    bossKey = "Xariona",
    difficulty = "N",
  })
  Add(71965, {
    instanceKey = "WorldBossesCata",
    bossKey = "Poseidus",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(71998, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(71999, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72000, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72001, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72002, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72003, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72004, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72005, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72006, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72007, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72008, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72009, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72010, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72011, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72012, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72013, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72014, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72015, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72016, {
    instanceKey = "DragonSoul",
    bossKey = "Patterns",
    difficulty = "N",
  })
  Add(72816, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72816, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72817, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72817, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72818, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72818, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72819, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72819, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72820, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72820, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72821, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72821, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72822, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72822, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72823, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72823, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72824, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72824, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72825, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72825, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72826, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72826, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72827, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "H",
  })
  Add(72827, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "ERT",
  })
  Add(72828, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "H",
  })
  Add(72828, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "ERT",
  })
  Add(72829, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "H",
  })
  Add(72829, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "ERT",
  })
  Add(72830, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "H",
  })
  Add(72830, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "ERT",
  })
  Add(72831, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "H",
  })
  Add(72831, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "ERT",
  })
  Add(72832, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "H",
  })
  Add(72832, {
    instanceKey = "WellOfEternity",
    bossKey = "Peroth'arn",
    difficulty = "ERT",
  })
  Add(72833, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "H",
  })
  Add(72833, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "ERT",
  })
  Add(72834, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "H",
  })
  Add(72834, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "ERT",
  })
  Add(72835, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "H",
  })
  Add(72835, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "ERT",
  })
  Add(72836, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "H",
  })
  Add(72836, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "ERT",
  })
  Add(72837, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "H",
  })
  Add(72837, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "ERT",
  })
  Add(72838, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "H",
  })
  Add(72838, {
    instanceKey = "WellOfEternity",
    bossKey = "QueenAzshara",
    difficulty = "ERT",
  })
  Add(72839, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72839, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72840, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72840, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72841, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72841, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72842, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72842, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72843, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72843, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72844, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72844, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72845, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72845, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72846, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72846, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72847, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72847, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72848, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72848, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72849, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "H",
  })
  Add(72849, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "ERT",
  })
  Add(72850, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "H",
  })
  Add(72850, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "ERT",
  })
  Add(72851, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "H",
  })
  Add(72851, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "ERT",
  })
  Add(72853, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "H",
  })
  Add(72853, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "ERT",
  })
  Add(72854, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "H",
  })
  Add(72854, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "ERT",
  })
  Add(72855, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "H",
  })
  Add(72855, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "ERT",
  })
  Add(72856, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "H",
  })
  Add(72856, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "ERT",
  })
  Add(72857, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "H",
  })
  Add(72857, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "ERT",
  })
  Add(72859, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "H",
  })
  Add(72859, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "ERT",
  })
  Add(72860, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "H",
  })
  Add(72860, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "ERT",
  })
  Add(72861, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72861, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72862, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72862, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72863, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72863, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72864, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72864, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72865, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72865, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72866, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72866, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72867, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72867, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72868, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72868, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72869, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72869, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72870, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72870, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72897, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "H",
  })
  Add(72897, {
    instanceKey = "EndTime",
    bossKey = "Murozond",
    difficulty = "ERT",
  })
  Add(72898, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72898, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72899, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "H",
  })
  Add(72899, {
    instanceKey = "WellOfEternity",
    bossKey = "MannorothandVaro'then",
    difficulty = "ERT",
  })
  Add(72900, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72900, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(72901, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "H",
  })
  Add(72901, {
    instanceKey = "HourOfTwilight",
    bossKey = "ArchbishopBenedictus",
    difficulty = "ERT",
  })
  Add(76150, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "H",
  })
  Add(76150, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "ERT",
  })
  Add(76151, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "H",
  })
  Add(76151, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "ERT",
  })
  Add(76154, {
    instanceKey = "EndTime",
    bossKey = "EndTimeTrash",
    difficulty = "H",
  })
  Add(76156, {
    instanceKey = "EndTime",
    bossKey = "EndTimeTrash",
    difficulty = "H",
  })
  Add(76157, {
    instanceKey = "WellOfEternity",
    bossKey = "WellOfEternityTrash",
    difficulty = "H",
  })
  Add(76158, {
    instanceKey = "WellOfEternity",
    bossKey = "WellOfEternityTrash",
    difficulty = "H",
  })
  Add(76159, {
    instanceKey = "WellOfEternity",
    bossKey = "WellOfEternityTrash",
    difficulty = "H",
  })
  Add(76160, {
    instanceKey = "HourOfTwilight",
    bossKey = "HourOfTwilightTrash",
    difficulty = "H",
  })
  Add(76161, {
    instanceKey = "HourOfTwilight",
    bossKey = "HourOfTwilightTrash",
    difficulty = "H",
  })
  Add(76162, {
    instanceKey = "HourOfTwilight",
    bossKey = "HourOfTwilightTrash",
    difficulty = "H",
  })
  Add(77067, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77067, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(77069, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(77188, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77189, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77190, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77191, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77192, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(77193, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77194, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77195, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77196, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77197, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77198, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77199, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77200, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77201, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77202, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77203, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77204, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77205, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77206, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77207, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77208, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77209, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77210, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77211, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77212, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77213, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77214, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77215, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77216, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77217, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77218, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77219, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77220, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(77221, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(77223, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77224, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77225, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77226, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77227, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77228, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77229, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77230, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77231, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77232, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "N",
  })
  Add(77234, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77235, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77236, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77237, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77238, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77239, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77240, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77241, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77242, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77243, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77244, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77245, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77246, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77247, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77248, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(77249, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(77250, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(77251, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(77252, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77253, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77254, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77255, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77257, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77258, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77259, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77260, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77261, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77262, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77263, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77265, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77266, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77267, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77268, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77269, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77270, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77271, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77938, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(77952, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(77957, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "H",
  })
  Add(77957, {
    instanceKey = "HourOfTwilight",
    bossKey = "Arcurion",
    difficulty = "ERT",
  })
  Add(77957, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "H",
  })
  Add(77957, {
    instanceKey = "HourOfTwilight",
    bossKey = "AsiraDawnslayer",
    difficulty = "ERT",
  })
  Add(77969, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(77970, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(77971, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(77972, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(77973, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(77974, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(77974, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(77975, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(77975, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(77976, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(77976, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(77977, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(77977, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(77978, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(77978, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(77979, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(77980, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(77981, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(77982, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(77983, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(77989, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(77990, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(77991, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(77992, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(77993, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(77994, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(77995, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(77996, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(77997, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(77998, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(77999, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78000, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78001, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78002, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78003, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78011, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(78012, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(78013, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(78170, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(78171, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(78172, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(78173, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(78174, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(78175, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(78176, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(78177, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(78178, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(78179, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(78180, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "N",
  })
  Add(78181, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "N",
  })
  Add(78182, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "N",
  })
  Add(78183, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "N",
  })
  Add(78184, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(78352, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(78352, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78357, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "N",
  })
  Add(78359, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "N",
  })
  Add(78361, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78362, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78363, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78364, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78365, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78366, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78367, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78368, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78369, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78370, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78371, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78372, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78373, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "H",
  })
  Add(78375, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78376, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78377, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78378, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78380, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78381, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78382, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(78382, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78384, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78385, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78386, {
    instanceKey = "DragonSoul",
    bossKey = "Morchok",
    difficulty = "RF",
  })
  Add(78387, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78388, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78389, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78390, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78391, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78392, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78393, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78395, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78396, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78397, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78398, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78399, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78400, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78401, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78402, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78403, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78404, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78405, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78406, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78408, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(78411, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(78412, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(78413, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78414, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78415, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78416, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78417, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78418, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78419, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78420, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78421, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(78421, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78422, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78423, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78424, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78425, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78427, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(78427, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78428, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78429, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78430, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78431, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78432, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78433, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78434, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78435, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78436, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78438, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78439, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78440, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(78440, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78441, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78442, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78443, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78444, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78445, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78446, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78447, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78448, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78449, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78450, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78451, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78452, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78454, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78455, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78456, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78457, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78458, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78460, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78461, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(78462, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(78463, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(78464, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(78465, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "H",
  })
  Add(78466, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(78467, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(78468, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(78469, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(78470, {
    instanceKey = "DragonSoul",
    bossKey = "SpineofDeathwing",
    difficulty = "RF",
  })
  Add(78471, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78472, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78473, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78474, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78475, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78476, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78477, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78478, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78479, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "H",
  })
  Add(78480, {
    instanceKey = "HallsOfOrigination",
    bossKey = "Rajh,ConstructofSun",
    difficulty = "ERT",
  })
  Add(78480, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78481, {
    instanceKey = "LostCityOfTolvir",
    bossKey = "Siamat",
    difficulty = "ERT",
  })
  Add(78481, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78482, {
    instanceKey = "BlackrockCaverns",
    bossKey = "AscendantLordObsidius",
    difficulty = "ERT",
  })
  Add(78482, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78483, {
    instanceKey = "Deadmines",
    bossKey = "VanessaVanCleef",
    difficulty = "ERT",
  })
  Add(78483, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78484, {
    instanceKey = "GrimBatol",
    bossKey = "Erudax,theDukeofBelow",
    difficulty = "ERT",
  })
  Add(78484, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78485, {
    instanceKey = "TheVortexPinnacle",
    bossKey = "Asaad,CaliphofZephyrs",
    difficulty = "ERT",
  })
  Add(78485, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78486, {
    instanceKey = "ThroneOfTheTides",
    bossKey = "Ozumat",
    difficulty = "ERT",
  })
  Add(78486, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78487, {
    instanceKey = "TheStonecore",
    bossKey = "HighPriestessAzil",
    difficulty = "ERT",
  })
  Add(78487, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78488, {
    instanceKey = "ShadowfangKeep",
    bossKey = "LordGodfrey",
    difficulty = "ERT",
  })
  Add(78488, {
    instanceKey = "DragonSoul",
    bossKey = "MadnessofDeathwing",
    difficulty = "RF",
  })
  Add(78489, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78490, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78491, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78492, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78493, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "H",
  })
  Add(78494, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(78495, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(78496, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(78497, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(78498, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulShared",
    difficulty = "RF",
  })
  Add(78847, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78848, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78849, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(78850, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78851, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78852, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "H",
  })
  Add(78853, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78854, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78855, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "H",
  })
  Add(78856, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78857, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78858, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "H",
  })
  Add(78859, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78860, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78861, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "H",
  })
  Add(78862, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78863, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78864, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "RF",
  })
  Add(78865, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78866, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78867, {
    instanceKey = "DragonSoul",
    bossKey = "WarlordZon'ozz",
    difficulty = "RF",
  })
  Add(78868, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78869, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78870, {
    instanceKey = "DragonSoul",
    bossKey = "WarmasterBlackhorn",
    difficulty = "RF",
  })
  Add(78871, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(78872, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(78873, {
    instanceKey = "DragonSoul",
    bossKey = "Yor'sahjtheUnsleeping",
    difficulty = "RF",
  })
  Add(78874, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78875, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78876, {
    instanceKey = "DragonSoul",
    bossKey = "HagaratheStormbinder",
    difficulty = "RF",
  })
  Add(78878, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78879, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78882, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78884, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78885, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78886, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78887, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78888, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78889, {
    instanceKey = "DragonSoul",
    bossKey = "DragonSoulTrash",
    difficulty = "N",
  })
  Add(78890, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(78891, {
    instanceKey = "DragonSoul",
    bossKey = "GeodeTrader",
    difficulty = "N",
  })
  Add(78919, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "N",
  })
  Add(78919, {
    instanceKey = "DragonSoul",
    bossKey = "Ultraxion",
    difficulty = "H",
  })
  Add(72798, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72799, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72800, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72801, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72802, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72803, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72804, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72805, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72806, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72807, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72808, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72809, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72810, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72811, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72812, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72813, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72814, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(72815, {
    instanceKey = "EndTime",
    bossKey = "EndTimeShared",
    difficulty = "H",
  })
  Add(238334, {
    instanceKey = "ShadowfangKeep",
    bossKey = "ApothecaryHummel",
    difficulty = "N",
  })
  Add(238335, {
    instanceKey = "ShadowfangKeep",
    bossKey = "ApothecaryHummel",
    difficulty = "N",
  })
  Add(238336, {
    instanceKey = "ShadowfangKeep",
    bossKey = "ApothecaryHummel",
    difficulty = "N",
  })
  Add(238337, {
    instanceKey = "ShadowfangKeep",
    bossKey = "ApothecaryHummel",
    difficulty = "N",
  })
  Add(238338, {
    instanceKey = "ShadowfangKeep",
    bossKey = "ApothecaryHummel",
    difficulty = "N",
  })
  local alizabalTokenItems = {
    73479, 73481, 73485, 73487, 73494, 73495, 73497, 73498, 73503, 73505,
    73509, 73511, 73514, 73516, 73520, 73524, 73526, 73542, 73544, 73547,
    73549, 73557, 73559, 73568, 73570, 73574, 73576, 73581, 73583, 73597,
    73599, 73605, 73607, 73613, 73615, 73617, 73619, 73621, 73622, 73623,
    73625, 73626, 73627, 76212, 76214, 76341, 76343, 76346, 76348, 76357,
    76359, 76749, 76751, 76757, 76759, 76766, 76768, 76875, 76877, 76975,
    76977, 76985, 76986, 76989, 76991, 77004, 77006, 77009, 77011, 77014,
    77016, 77018, 77020, 77024, 77026, 77029, 77031, 77036, 77038, 77041,
    77043,
  }
  for i = 1, #alizabalTokenItems do
    Add(alizabalTokenItems[i], {
      instanceKey = "BaradinHold",
      bossKey = "AlizabalMistressofHate",
      difficulty = "H",
    })
  end

  Add(69634, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Gri'lek",
    difficulty = "H",
  })
  Add(69635, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Gri'lek",
    difficulty = "H",
  })
  Add(69636, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Hazza'rah",
    difficulty = "H",
  })
  Add(69637, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Hazza'rah",
    difficulty = "H",
  })
  Add(69638, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Renataki",
    difficulty = "H",
  })
  Add(69639, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Renataki",
    difficulty = "H",
  })
  Add(69640, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Wushoolay",
    difficulty = "H",
  })
  Add(69641, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Wushoolay",
    difficulty = "H",
  })
  Add(69630, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Gri'lek",
    difficulty = "H",
  })
  Add(69630, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Hazza'rah",
    difficulty = "H",
  })
  Add(69630, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Renataki",
    difficulty = "H",
  })
  Add(69630, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Wushoolay",
    difficulty = "H",
  })
  Add(69631, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Gri'lek",
    difficulty = "H",
  })
  Add(69631, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Hazza'rah",
    difficulty = "H",
  })
  Add(69631, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Renataki",
    difficulty = "H",
  })
  Add(69631, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Wushoolay",
    difficulty = "H",
  })
  Add(69632, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Gri'lek",
    difficulty = "H",
  })
  Add(69632, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Hazza'rah",
    difficulty = "H",
  })
  Add(69632, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Renataki",
    difficulty = "H",
  })
  Add(69632, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Wushoolay",
    difficulty = "H",
  })
  Add(69633, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Gri'lek",
    difficulty = "H",
  })
  Add(69633, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Hazza'rah",
    difficulty = "H",
  })
  Add(69633, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Renataki",
    difficulty = "H",
  })
  Add(69633, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Wushoolay",
    difficulty = "H",
  })
  Add(69647, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Gri'lek",
    difficulty = "H",
  })
  Add(69647, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Hazza'rah",
    difficulty = "H",
  })
  Add(69647, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Renataki",
    difficulty = "H",
  })
  Add(69647, {
    instanceKey = "ZulGurub",
    bossKey = "CacheofMadness-Wushoolay",
    difficulty = "H",
  })
  Add(64681, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64682, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64683, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64684, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64685, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64686, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64687, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64688, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64689, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64690, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64691, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64692, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64696, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64697, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64698, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64699, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64702, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64703, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64704, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64705, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64713, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64714, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64715, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64716, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64720, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64721, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64722, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64723, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64724, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64725, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64740, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64741, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64742, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64750, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64751, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64753, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64754, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64756, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64757, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64761, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64762, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64763, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64781, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64782, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64800, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64801, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64807, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64808, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64809, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64832, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64833, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64834, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64835, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64836, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64837, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64851, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64852, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64862, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64863, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64864, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64865, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64866, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64867, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64868, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64869, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64870, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64872, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(64873, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65598, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65599, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65600, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65601, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65602, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65603, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65604, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65605, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65606, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65607, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65608, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65609, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65610, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65611, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(65612, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70178, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70179, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70180, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70181, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70182, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70183, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70184, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70185, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70186, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70187, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70188, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70189, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70190, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70191, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70192, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70193, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70194, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70195, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70196, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70197, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70198, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70199, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70200, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70201, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70202, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70203, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70204, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70205, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70206, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70207, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70208, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70209, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70210, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70211, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70212, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70213, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70214, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70215, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70216, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70217, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70218, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70219, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70220, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70221, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70222, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70223, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70224, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70225, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70226, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70227, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70228, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70229, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70230, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70231, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70232, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70233, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70234, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70235, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70236, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70237, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70238, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70239, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70240, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70241, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70242, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70243, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70319, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70320, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70321, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70322, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70323, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70324, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70325, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70326, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70327, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70328, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70329, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70330, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70331, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70332, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70333, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70334, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70335, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70336, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70337, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70338, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70339, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70340, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70341, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70342, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70343, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70344, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70345, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70346, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70347, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70348, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70349, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70350, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70351, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70352, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70358, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70359, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70360, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70361, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70362, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70363, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70364, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70365, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70366, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70367, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70368, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70369, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70370, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70371, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70372, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70373, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70374, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70375, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70376, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70377, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70378, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70379, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70380, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70381, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70382, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70383, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70384, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70385, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70386, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70387, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70388, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70389, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70390, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70391, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70392, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70393, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70394, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70395, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70396, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70397, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70398, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70399, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70400, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70401, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70402, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70403, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70404, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70405, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70406, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70407, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70408, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70495, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70496, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70497, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70498, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70499, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70500, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70501, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70502, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70503, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70504, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70505, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70506, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70507, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70508, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70509, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70511, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70512, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70513, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70514, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70515, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70516, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70517, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70518, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70519, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70520, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70521, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70522, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70523, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70524, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70525, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70526, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70527, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70528, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70529, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70530, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70531, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70532, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70538, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70539, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70540, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70541, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70542, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70543, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70544, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70545, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70546, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70547, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70548, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70549, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70555, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70556, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70557, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70563, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70564, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70565, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70571, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70572, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70573, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70574, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70575, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70576, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70577, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70578, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70579, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70595, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70596, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70602, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70603, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70604, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70605, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70606, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70607, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70613, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70614, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70620, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70621, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70622, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70628, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70629, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70630, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70631, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70637, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70638, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70639, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70640, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70641, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70642, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70653, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70654, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70660, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70661, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70662, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70663, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70664, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70665, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70666, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70667, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70668, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70669, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70670, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70909, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(70910, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72304, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72305, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72306, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72307, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72308, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72309, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72310, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72311, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72312, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72313, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72314, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72315, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72316, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72317, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72318, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72319, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72320, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72321, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72322, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72323, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72324, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72325, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72326, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72327, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72328, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72329, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72330, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72331, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72342, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72343, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72344, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72350, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72351, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72352, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72358, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72359, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72360, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72361, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72362, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72363, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72364, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72365, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72366, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72367, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72383, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72384, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72385, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72386, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72387, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72388, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72394, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72395, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72396, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72397, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72398, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72399, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72410, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72411, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72412, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72413, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72414, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72415, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72416, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72417, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72418, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72419, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72420, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72421, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72427, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72428, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72429, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72430, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72431, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72442, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72448, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72449, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72450, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72451, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72452, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72453, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72454, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72455, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72456, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72457, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(72458, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73412, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73413, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73414, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73415, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73416, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73417, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73418, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73419, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73420, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73421, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73422, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73423, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73424, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73425, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73426, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73427, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73428, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73429, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73430, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73431, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73432, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73433, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73434, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73435, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73436, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73437, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73438, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73439, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73440, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73441, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73442, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73443, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73444, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73445, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73446, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73447, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73448, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73449, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73450, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73451, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73452, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73453, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73454, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73455, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73456, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73457, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73458, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73459, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73460, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73461, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73462, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73463, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73477, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73488, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73489, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73490, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73491, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73492, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73493, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73496, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73507, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73518, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73519, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73522, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73528, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73529, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73530, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73531, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73532, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73533, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73534, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73535, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73536, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73537, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73538, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73539, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73550, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73551, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73552, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73553, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73554, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73555, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73561, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73562, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73563, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73564, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73565, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73566, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73585, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73586, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73587, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73588, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73589, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73590, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73591, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73592, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73593, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73594, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73600, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73601, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73602, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73608, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73609, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73610, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73624, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73628, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73629, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73630, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73631, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73632, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73633, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73634, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73635, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73636, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73637, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73638, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73639, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73640, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73641, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73642, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73643, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73644, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73645, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73646, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73647, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73648, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73676, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73677, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73683, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73684, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73695, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73696, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73702, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73703, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73719, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73720, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73726, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73732, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73743, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73744, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(73745, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(74783, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(74784, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(74785, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(74786, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77130, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77131, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77132, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77133, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77134, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77136, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77137, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77138, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77139, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77140, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77141, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77142, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77143, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77144, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
  Add(77154, {
    instanceKey = "PvP",
    bossKey = "Vendor",
  })
end
