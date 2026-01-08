EvidencesState = {}

function EvidencesState:enter()
    self.bg = love.graphics.newImage("assets/images/game/bg_evidences.png")
    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")

    self.fxBlurBG = moonshine(moonshine.effects.boxblur)
    self.fxBlurBG.boxblur.radius = { 7, 7 }
    self.shdFXScreen = moonshine(moonshine.effects.crt)
        .chain(moonshine.effects.pixelate)
        .chain(moonshine.effects.chromasep)

    self.shdFXScreen.pixelate.feedback = 0.1
    self.shdFXScreen.pixelate.size = { 1.5, 1.5 }

    self.shdFXScreen.chromasep.radius = 1.25
end

function EvidencesState:draw()
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    self.shdFXScreen(function()
        self.fxBlurBG(function()
            love.graphics.draw(self.bg, shove.getViewportWidth() / self.bg:getWidth(), shove.getViewportHeight() / self.bg:getHeight())
        end)

        love.graphics.draw(self.crtOverlay, 0, 0, 0, shove.getViewportWidth() / self.crtOverlay:getWidth(), shove.getViewportHeight() / self.crtOverlay:getHeight())
    end)
end

function EvidencesState:update(elapsed)

end

return EvidencesState
