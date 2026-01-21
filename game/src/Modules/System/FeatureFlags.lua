-- change some flags to change the engine behavior

local featureFlags = {}
featureFlags.debug = true --not love.filesystem.isFused() -- debug stuff will not appear on compiled games --
featureFlags.videoStats = false
featureFlags.captureScreenshot = true
featureFlags.developerMode = featureFlags.debug
featureFlags.isDemo = true
featureFlags.nightExtraDemo = false

return featureFlags
