InstructionsState = {}

function InstructionsState:enter()
    self.bg = love.graphics.newImage("assets/images/game/loading_extras_menu.png")
    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")

    self.fxBlurBG = moonshine(moonshine.effects.boxblur)
    self.fxBlurBG.boxblur.radius = { 7, 7 }
    self.shdFXScreen = moonshine(moonshine.effects.crt)
        .chain(moonshine.effects.pixelate)
        .chain(moonshine.effects.chromasep)

    self.shdFXScreen.pixelate.feedback = 0.1
    self.shdFXScreen.pixelate.size = { 1.5, 1.5 }

    self.shdFXScreen.chromasep.radius = 1.25

    self.menuCam = camera.new(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    self.menuCam.factorX = 25
    self.menuCam.factorY = 34

    self.X_LEFT_FRAME = self.menuCam.x - 32
    self.X_RIGHT_FRAME = self.menuCam.x + self.roomSize.width
    self.Y_TOP_FRAME = self.menuCam.y
    self.Y_BOTTOM_FRAME = self.menuCam.y + self.roomSize.height
end

function InstructionsState:draw()
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    self.shdFXScreen(function()
        self.fxBlurBG(function()
            self.menuCam:attach()
            love.graphics.draw(self.bg, shove.getViewportWidth() / self.bg:getWidth(), shove.getViewportHeight() / self.bg:getHeight())
            self.menuCam:detach()
        end)

        love.graphics.draw(self.crtOverlay, 0, 0, 0, shove.getViewportWidth() / self.crtOverlay:getWidth(), shove.getViewportHeight() / self.crtOverlay:getHeight())
        loveView.draw()
    end)
end

function InstructionsState:update(elapsed)

end

function InstructionsState:leave()

end

return InstructionsState
