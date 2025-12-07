local MonitorView = {}

function MonitorView:init()
    local font = fontcache.getFont("phbios", 14)
    --print(font)
    self.terminal = termite.new(480, 480 - font:getHeight(), font)
    self.glow = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv = love.graphics.newCanvas(shove.getViewportDimensions())
end

function MonitorView:draw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    --self.terminal:draw()

    local x, y = 480, 96
    self.glowcnv:renderTo(function ()
        self.glow(function ()
            self.terminal:draw(x, y)
        end)
    end)

    self.terminal:draw(x, y)
end

function MonitorView:postDraw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.setBlendMode("add")
            love.graphics.draw(self.glowcnv)
        love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
end

function MonitorView:update(elapsed)
    self.terminal:update(elapsed)
end

return MonitorView