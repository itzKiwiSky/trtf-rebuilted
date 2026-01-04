InstructionsState = {}

function InstructionsState:enter()
    self.bg = love.graphics.newImage("assets/images/game/loading_extras_menu.png")
    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")

    self.fxBlurBG = moonshine(moonshine.effects.boxblur)
    self.fxBlurBG.boxblur.radius = { 7, 7 }
    self.shdFXScreen = moonshine(moonshine.effects.crt)
        .chain(moonshine.effects.pixelate)
        .chain(moonshine.effects.chromasep)

    AudioSources["msc_arcade"]:play()
    AudioSources["msc_arcade"]:setLooping(true)

    self.roomSize = {
        windowWidth = shove.getViewportWidth(),
        windowHeight = shove.getViewportHeight(),
        width = 1600,
        height = 900,
    }

    self.instIcons = {}
    local icfls = love.filesystem.getDirectoryItems("assets/images/game/instructions/icons")
    for c = 1, #icfls, 1 do
        local name = icfls[c]:gsub("%.[^.]+$", "")
        self.instIcons[name] = love.graphics.newImage("assets/images/game/instructions/icons/" .. icfls[c])
    end

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

    loveView.unloadView()

    loveView.registerLoveframesEvents()
    loveView.loadView("src/Modules/Game/Views/InstructionView.lua")
end

function InstructionsState:draw()
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    self.shdFXScreen(function()
        self.fxBlurBG(function()
            love.graphics.draw(self.bg, shove.getViewportWidth() / self.bg:getWidth(), shove.getViewportHeight() / self.bg:getHeight())
        end)

        loveView.draw()

        love.graphics.draw(self.crtOverlay, 0, 0, 0, shove.getViewportWidth() / self.crtOverlay:getWidth(), shove.getViewportHeight() / self.crtOverlay:getHeight())
    end)
end

function InstructionsState:update(elapsed)
    local smx, smy = shove.mouseToViewport()
    local mx, my = self.menuCam:mousePosition()

    loveView.update(elapsed)
end

function InstructionsState:leave()
    flux.removeAll()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    for _, f in ipairs(self.instIcons) do
        if type(f) == "userdata" and f.release then
            f:release()
        end
    end

    loveView.unloadView()

    self.bg:release()
    self.crtOverlay:release()
end

return InstructionsState
