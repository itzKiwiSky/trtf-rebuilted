local MonitorView = {}

local termite = require 'libraries.Termite'

function MonitorView:init()
    local font = fontcache.getFont("phbios", 26)
    self.term = termite:new(480, 480 - font:getHeight(), font)
    self.glow = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv = love.graphics.newCanvas(shove.getViewportDimensions())
end

function MonitorView:draw()
    if not SecretNightState.beeperController.tabUp then return end

    --self.term:draw()
end

function MonitorView:postDraw()
    if not SecretNightState.beeperController.tabUp then return end
end

function MonitorView:update(elapsed)
    self.term:update(elapsed)
end

return MonitorView