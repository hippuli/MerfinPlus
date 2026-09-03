-- MerfinPlus saved variable modernization.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

function MerfinPlus:ModernizeSavedVariables()
  if not self.db or not self.db.global then
    return
  end

  local global = self.db.global
  global.internalVersion = tonumber(global.internalVersion) or 0

  if type(global.wowSims) ~= "table" then
    global.wowSims = {}
  end

  local wowSims = global.wowSims
  wowSims.internalVersion = tonumber(wowSims.internalVersion) or 0

  -- Modernize WoWSims defaults
  if global.internalVersion < 1 then
    -- Legacy bridge: keep the old WoWSim default state, but move it into the new marker.
    if type(wowSims.defaultsVersion) == "number" then
      if wowSims.defaultsVersion >= 2 and wowSims.internalVersion < 1 then
        wowSims.internalVersion = 1
      end
      wowSims.defaultsVersion = nil
    end
  end

  global.internalVersion = math.max(global.internalVersion, tonumber(MerfinPlus.internalVersion) or 0)

  if self.ModernizeTBCWoWSimDefaults then
    self:ModernizeTBCWoWSimDefaults()
  end
end
