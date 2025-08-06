CustomNightState = {}

CustomNightState.presets = require 'src.Modules.Game.Utils.CustomNightPresets'

function CustomNightState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end


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
    self.fxBlurBG.boxblur.radius = { 7, 7 }
    self.shdFXScreen = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)

    self.shdFXScreen.pixelate.feedback = 0.1
    self.shdFXScreen.pixelate.size = { 1.5, 1.5 }

    self.shdFXScreen.chromasep.radius = 1.25

    AudioSources["msc_arcade"]:play()
    AudioSources["msc_arcade"]:setLooping(true)

    self.roomSize = {
        windowWidth = shove.getViewportWidth(),
        windowHeight = shove.getViewportHeight(),
        width = 1600,
        height = 900,
    }

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

    self.X_LEFT_FRAME = self.menuCam.x - 32
    self.X_RIGHT_FRAME = self.menuCam.x + self.roomSize.width
    self.Y_TOP_FRAME = self.menuCam.y
    self.Y_BOTTOM_FRAME = self.menuCam.y + self.roomSize.height

    loveView.registerLoveframesEvents()
    loveView.loadView("src/Modules/Game/Views/CustomNight.lua")
end

function CustomNightState:draw()
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    self.shdFXScreen(function()
        self.fxBlurBG(function()
            self.menuCam:attach()
                love.graphics.draw(self.menuBG, shove.getViewportWidth() / self.menuBG:getWidth(), shove.getViewportHeight() / self.menuBG:getHeight())
            self.menuCam:detach()
        end)

        loveView.draw()

        love.graphics.draw(self.crtOverlay, 0, 0, 0, shove.getViewportWidth() / self.crtOverlay:getWidth(), shove.getViewportHeight() / self.crtOverlay:getHeight())
    end)

    --love.graphics.print(debug.formattable(CustomNightState.animatronicsAI), 10, 20)
end

function CustomNightState:update(elapsed)
    local smx, smy = shove.mouseToViewport()
    local mx, my = self.menuCam:mousePosition()

    self.menuCam.x = (self.roomSize.width / 2 + (mx - self.roomSize.width / 2) / self.menuCam.factorX)
    self.menuCam.y = (self.roomSize.height / 2 + (my - self.roomSize.height / 2) / self.menuCam.factorY)

    loveView.update(elapsed)

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

function CustomNightState:leave()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    for _, f in ipairs(self.cnicons) do
        f:release()
    end

    self.menuBG:release()
    self.crtOverlay:release()
end

return CustomNightState