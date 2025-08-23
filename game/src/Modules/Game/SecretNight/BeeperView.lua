local BeeperView = {}

function BeeperView:init()
    self.fnt_poop = fontcache.getFont("lcddot", 30)
    self.texts = languageRaw["secret_night"]["beeper_instructions"]
    self.page = 1
    self.maxPage = #self.texts

    self.glow = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv = love.graphics.newCanvas(shove.getViewportDimensions())
end

function BeeperView:draw()
    if not SecretNightState.beeperController.tabUp then return end

    local ox, oy = SecretNightState.assets["ui"]["bg_beeper"]:getWidth() / 2, SecretNightState.assets["ui"]["bg_beeper"]:getHeight() / 2
    love.graphics.draw(SecretNightState.assets["ui"]["bg_beeper"], 0, 0)

    self.glowcnv:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.glow(function()
            love.graphics.draw(SecretNightState.assets["ui"]["bg_beeper"], 0, 0)
        end)
    end)

end

function BeeperView:postDraw()
    if not SecretNightState.beeperController.tabUp then return end

    love.graphics.setColor(1, 1, 1, 0.75)
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.glowcnv)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
end

function BeeperView:update(elapsed)
    
end

return BeeperView