if not Merfin._localesFinalized then
  Merfin:FinalizeLocales("enUS")
  Merfin._localesFinalized = true
end

if not Merfin._raidLocalesFinalized then
  Merfin:FinalizeRaidLocales("enUS")
  Merfin._raidLocalesFinalized = true
end
