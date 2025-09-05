SecretNightState = {}
SecretNightState.assets = {}

function SecretNightState:enter()
    self.beeperController = require 'src.Modules.Game.BeeperController'
    self.beeperView = require 'src.Modules.Game.SecretNight.BeeperView'
    self.tabletController = require 'src.Modules.Game.TabletController'
    self.buttonsUI = require 'src.Modules.Game.Utils.ButtonUI'

    self.fnt_nightDisplay = fontcache.getFont("tnr", 60)

    registers.devWindowContent = function ()
        Slab.BeginWindow("debugWindow", { Title = "Debug shader"})
            Slab.Text("FOV (fovVar)")
            Slab.SameLine()
            if Slab.InputNumberDrag("fovInput", tostring(self.tuneConfig.fovVar), -1, 1, 0.01) then
                self.tuneConfig.fovVar = Slab.GetInputNumber()
            end
            Slab.Text("Latitute (latituteVar)")
            Slab.SameLine()
            if Slab.InputNumberDrag("latituteInput", tostring(self.tuneConfig.latitudeVar), -200, 200, 0.1) then
                self.tuneConfig.latitudeVar = Slab.GetInputNumber()
            end
            Slab.Text("Longitude (longitudeVar)")
            Slab.SameLine()
            if Slab.InputNumberDrag("longitudeInput", tostring(self.tuneConfig.longitudeVar), -200, 200, 0.1) then
                self.tuneConfig.longitudeVar = Slab.GetInputNumber()
            end

            Slab.Text("Camera X Factor (factorX)")
            Slab.SameLine()
            if Slab.InputNumberDrag("factorXInput", tostring(self.gameCam.factorX), 0, 20, 0.01) then
                self.gameCam.factorX = Slab.GetInputNumber()
            end

            if Slab.Button("Re-import beeper") then
                self.beeperView = love.filesystem.load("src/Modules/Game/SecretNight/BeeperView.lua")()
                self.beeperView:init()
            end
        Slab.EndWindow()
    end

    self.nightTextDisplay = {
        text = string.format(languageService["game_night_announce"], 8),
        fade = 0,
        scale = 1,
        acc = 0,
        displayNightText = false,
        invert = false
    }

    self.officeState = {
        nightStarted = false,
        flashlight = {
            active = false,
            x = 0,
            y = 0,
            lightGlare = {
                x = 749, y = 164,
                alpha = 0,
            },
            lightBeam = {
                alpha = 0,
            }
        },
        beeper = {
            open = false,
        },
        ambienceBoilerVolume = 0.25,
        lookingBack = false,
    }

    self.shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    self.tuneConfig = {
        latitudeVar = 23.3,
        longitudeVar = 45,
        fovVar = 0.263000
    }
    self.shd_perspective:send("latitudeVar", self.tuneConfig.latitudeVar)
    self.shd_perspective:send("longitudeVar", self.tuneConfig.longitudeVar)
    self.shd_perspective:send("fovVar", self.tuneConfig.fovVar)

    self.hoverLookButton = self.buttonsUI:new(self.assets.ui["hover_look"], shove.getViewportWidth() - 96, shove.getViewportHeight() / 2, 0, 0.75, 0.75, true)

    -- room --
    self.roomSize = {
        windowWidth = shove.getViewportWidth(),
        windowHeight = shove.getViewportHeight(),
        width = 2000,
        height = 800,
        compensation = 400,
    }

    self.gameCam = camera.new(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    self.gameCam.factorX = 2.8
    self.gameCam.factorY = 25

    self.X_LEFT_FRAME = self.gameCam.x
    self.X_RIGHT_FRAME = self.gameCam.x + self.roomSize.width
    self.Y_TOP_FRAME = self.gameCam.y
    self.Y_BOTTOM_FRAME = self.gameCam.y + self.roomSize.height

    self.cnv_mainCanvas = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())
    self.cnv_invertedRoom = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())
    self.cnv_flash = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())

    self.beeperController:init(SecretNightState.assets.beeper, 34, "beep_")
    self.beeperController.visible = false

    self.beeperView:init()
    self.beeperController.onComplete = function()
        AudioSources["sfx_beeper_use"]:play()
        AudioSources["sfx_beeper_use"]:setVolume(0.87)
    end

    AudioSources["sfx_boiler_amb"]:setLooping(true)
    AudioSources["sfx_boiler_amb"]:setVolume(self.officeState.ambienceBoilerVolume)
    AudioSources["sfx_boiler_amb"]:play()

    self.nightTimer = timer.new()
    self.nightTimer:script(function(sleep)
        sleep(2)
        self.beeperController:setState(true)
        AudioSources["sfx_beeper_open"]:play()
        AudioSources["sfx_beeper_open"]:setVolume(0.87)
    end)
end

function SecretNightState:draw()

    self.cnv_mainCanvas:renderTo(function()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
            love.graphics.draw(self.assets.office.states["idle"]["front_light"], 0, 0)
        self.gameCam:detach()
    end)

    self.cnv_flash:renderTo(function()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
            love.graphics.draw(self.assets.office.states["idle"]["front"], 0, 0)
        self.gameCam:detach()
        if self.officeState.flashlight.active then
            local ox, oy = self.assets.effects["light"]["flashlight"]:getWidth() / 2, self.assets.effects["light"]["flashlight"]:getHeight() / 2
            love.graphics.draw(self.assets.effects["light"]["flashlight"], self.officeState.flashlight.x, self.officeState.flashlight.y, 0, 1.15, 1.15, ox, oy)

            love.graphics.setBlendMode("add", "premultiplied")
            love.graphics.draw(self.assets.effects["light"]["light_beam"], 
                shove.getViewportWidth() - 300, shove.getViewportHeight(), self.officeState.flashlight.lightBeam.angle - math.pi * 0.053, 0.5, 1.25,
                self.assets.effects["light"]["light_beam"]:getWidth(), self.assets.effects["light"]["light_beam"]:getHeight() / 2
            )
            love.graphics.setBlendMode("alpha")
        end
    end)

    -- 482 175

    love.graphics.setShader(self.shd_perspective)
        love.graphics.draw(self.cnv_mainCanvas, 0, 0)
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(self.cnv_flash, 0, 0)
        love.graphics.setBlendMode("alpha")
    love.graphics.setShader()

    self.beeperView:draw()
    self.beeperController:draw()
    self.beeperView:postDraw()

    if self.officeState.nightStarted then
        self.hoverLookButton:draw()
    end


    if self.nightTextDisplay.displayNightText then
        local txt = languageService["game_night_announce"]:format(8) 
        love.graphics.setColor(1, 1, 1, self.nightTextDisplay.fade)
            love.graphics.print(txt, self.fnt_nightDisplay, shove.getViewportWidth() / 2, shove.getViewportHeight() / 2 - self.fnt_nightDisplay:getHeight() / 2, 0, self.nightTextDisplay.scale, self.nightTextDisplay.scale, self.fnt_nightDisplay:getWidth(txt) / 2, self.fnt_nightDisplay:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end


    love.graphics.print(inspect(self.officeState), 20, 20)
end

function SecretNightState:update(elapsed)
    local inside, vmx, vmy = shove.mouseToViewport()
    if self.officeState.flashlight.active then
        self.officeState.flashlight.x, self.officeState.flashlight.y = vmx, vmy
    end
    
    self.shd_perspective:send("latitudeVar", self.tuneConfig.latitudeVar)
    self.shd_perspective:send("longitudeVar", self.tuneConfig.longitudeVar)
    self.shd_perspective:send("fovVar", self.tuneConfig.fovVar)

    mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    self.officeState.flashlight.lightBeam.angle = math.atan2(my - shove.getViewportHeight(), mx - shove.getViewportWidth() - 300)

    if not self.beeperController.tabUp then
        self.gameCam.x = (self.roomSize.width / 2 + (mx - self.roomSize.width / 2) / self.gameCam.factorX)
    end

    -- camera bounds --
    if self.gameCam.x < self.X_LEFT_FRAME then
        self.gameCam.x = self.X_LEFT_FRAME
    end

    if self.gameCam.y < self.Y_TOP_FRAME then
        self.gameCam.y = self.Y_TOP_FRAME
    end

    if self.gameCam.x > self.X_RIGHT_FRAME then
        self.gameCam.x = self.X_RIGHT_FRAME
    end

    if self.gameCam.y > self.Y_BOTTOM_FRAME then
        self.gameCam.y = self.Y_BOTTOM_FRAME
    end

    if self.nightTextDisplay.displayNightText and not self.nightTextDisplay.invert then
        self.nightTextDisplay.acc = self.nightTextDisplay.acc + elapsed
        if self.nightTextDisplay.acc >= 0.1 then
            self.nightTextDisplay.acc = 0
            self.nightTextDisplay.fade = self.nightTextDisplay.fade + 8.5 * elapsed
            self.nightTextDisplay.scale = self.nightTextDisplay.scale + 0.4 * elapsed

            if self.nightTextDisplay.fade >= 1.4 then
                self.nightTextDisplay.invert = true
            end
        end
    elseif self.nightTextDisplay.displayNightText and self.nightTextDisplay.invert then
        self.officeState.nightRun = true
        self.nightTextDisplay.acc = self.nightTextDisplay.acc + elapsed
        if self.nightTextDisplay.acc >= 0.3 then
            self.nightTextDisplay.acc = 0
            self.nightTextDisplay.fade = self.nightTextDisplay.fade - 3.2 * elapsed
            self.nightTextDisplay.scale = self.nightTextDisplay.scale + 0.2 * elapsed

            if self.nightTextDisplay.fade <= 0 then
                self.nightTextDisplay.displayNightText = false
            end
        end
    end
    

    self.officeState.ambienceBoilerVolume = math.lerp(self.officeState.ambienceBoilerVolume, self.officeState.lookingBack and 0.75 or 0.2, 0.075)
    AudioSources["sfx_boiler_amb"]:setVolume(self.officeState.ambienceBoilerVolume)

    if self.officeState.nightStarted then
        if collision.pointRect({ x = vmx, y = vmy }, self.hoverLookButton) then
            self.officeState.lookingBack = true
            
        end
    end

    self.beeperController:update(elapsed)
    self.beeperView:update(elapsed)

    self.nightTimer:update(elapsed)
end

function SecretNightState:mousepressed(x, y, button)
    local inside, vmx, vmy = shove.mouseToViewport()
    self.beeperView:mousepressed(vmx, vmy, button)

    if not self.officeState.nightStarted then return end

    if button == 1 then
        self.officeState.flashlight.active = not self.officeState.flashlight.active
    end
end

function SecretNightState:leave()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    if gameSave.save.user.settings.misc.cacheNight then
        local function releaseRecursive(tbl)
            for key, value in pairs(tbl) do
                if type(value) == "table" then
                    releaseRecursive(value)
                else
                    if type(value) == "userdata" then
                        value:release()
                    end
                end
            end
        end

        releaseRecursive(self.assets)
    end
end

return SecretNightState