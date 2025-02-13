CustomNightState = {}

CustomNightState.presets = require 'trtf.src.Modules.Game.Utils.CustomNightPresets'

function CustomNightState:enter()
    self.animatronicsAI = {
        bonnie = 0,
        chica = 0,
        foxy = 0,
        freddy = 0,
        kitty = 0,
        puppet = 0,
        sugar = 0,
    }


    self.fxBlurBG = moonshine(moonshine.effects.boxblur)
    self.fxBlurBG.boxblur.radius = {7, 7}
    self.shdFXScreen = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)

    self.shdFXScreen.pixelate.feedback = 0.1
    self.shdFXScreen.pixelate.size = {1.5, 1.5}

    self.shdFXScreen.chromasep.radius = 1.25

    SoundController.stopAllChannels()
    SoundController.getChannel("music"):stop()
    SoundController.getChannel("music"):loadSource("msc_arcade")
    SoundController.getChannel("music"):play()
    SoundController.getChannel("music"):setLooping(true)

    self.staticTextureFX = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }

    self.roomSize = {
        windowWidth = love.graphics.getWidth(),
        windowHeight = love.graphics.getHeight(),
        width = 1600,
        height = 900,
    }

    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static")
    for s = 1, #statics, 1 do
        table.insert(self.staticTextureFX.frames, love.graphics.newImage("assets/images/game/effects/static/" .. statics[s]))
    end

    self.cnicons = {}
    local icfls = love.filesystem.getDirectoryItems("assets/images/game/night/cn_icons")
    for c = 1, #icfls, 1 do
        local name = icfls[c]:gsub("%.[^.]+$", "")
        if name ~= "dummy" then
            table.insert(self.cnicons, {
                img = love.graphics.newImage("assets/images/game/night/cn_icons/" .. icfls[c]),
                name = name,
            })
        end
    end

    self.menuBG = love.graphics.newImage("assets/images/game/cn_menu.png")

    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")
    
    self.menuCam = camera.new(0, nil)
    self.menuCam.factorX = 25
    self.menuCam.factorY = 34

    self.X_LEFT_FRAME = self.menuCam.x
    self.X_RIGHT_FRAME = self.menuCam.x + self.roomSize.width
    self.Y_TOP_FRAME = self.menuCam.y
    self.Y_BOTTOM_FRAME = self.menuCam.y + self.roomSize.height

    ViewManager.clear()
    ViewManager.load("src/Modules/Game/Interface/Views/CustomNight.lua")
    self.UICanvas = love.graphics.newCanvas(love.resconf.width, love.resconf.height, { readable = true })

    self.blurBGCanvas = love.graphics.newCanvas(love.resconf.width, love.resconf.height, { readable = true })
end

function CustomNightState:draw()
    love.graphics.draw(self.blurBGCanvas)
end

function CustomNightState:update(elapsed)
    local smx, smy = love.mouse.getPosition()
    local mx, my = self.menuCam:mousePosition()

    self.menuCam.x = (self.roomSize.width / 2 + (mx - self.roomSize.width / 2) / self.menuCam.factorX)
    self.menuCam.y = (self.roomSize.height / 2 + (my - self.roomSize.height / 2) / self.menuCam.factorY)

    love.graphics.setCanvas({ self.blurBGCanvas, stencil = true })
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
        self.shdFXScreen(function()
            self.fxBlurBG(function()
                self.menuCam:attach()
                    love.graphics.draw(self.menuBG)
                self.menuCam:detach()
            end)

            love.graphics.draw(self.UICanvas)
    
            love.graphics.draw(self.crtOverlay, 0, 0, 0, love.resconf.width / self.crtOverlay:getWidth(), love.resconf.height / self.crtOverlay:getHeight())
        end)
    love.graphics.setCanvas()

    -- update canvases --
    love.graphics.setCanvas({ self.UICanvas, stencil = true })
        love.graphics.clear(0, 0, 0, 0)
        ViewManager.draw()
    love.graphics.setCanvas()

    ViewManager.reloadViews()
    ViewManager.update(elapsed)

        -- camera bounds --
    if self.menuCam.x < self.X_LEFT_FRAME then
        self.menuCam.x = self.X_LEFT_FRAME
    end

    if self.menuCam.y < self.Y_TOP_FRAME then
        self.menuCam.y = self.Y_TOP_FRAME
    end

    if self.menuCam.x > self.X_RIGHT_FRAME then
        self.menuCam.x = self.X_RIGHT_FRAME
    end

    if self.menuCam.y > self.Y_BOTTOM_FRAME then
        self.menuCam.y = self.Y_BOTTOM_FRAME
    end
end

function CustomNightState:mousepressed(x, y, button)
    ViewManager.mousepressed(x, y, button)
end

function CustomNightState:mousereleased(x, y, button)
    ViewManager.mousereleased(x, y, button)
end

function CustomNightState:keypressed(k, scancode, isrepeat)
    ViewManager.keypressed(k, isrepeat)
end

function CustomNightState:keyreleased(k)
    ViewManager.keyreleased(k)
end

function CustomNightState:textinput(t)
    ViewManager.textinput(t)
end

return CustomNightState