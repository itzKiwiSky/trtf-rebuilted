SecretNightState = {}
SecretNightState.assets = {}

function SecretNightState:enter()
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
        Slab.EndWindow()
    end

    self.officeState = {
        flashlight = {
            active = false,
            x = 0,
            y = 0,
            lightBeam = {
                angle = 0,
                
            }
        }
    }

    --roomoff = love.graphics.newImage("assets/images/game/test/room_off.png")
    --roomlight = love.graphics.newImage("assets/images/game/test/room_light.png")
    --flashlight = love.graphics.newImage("assets/images/game/night8/flashlight.png")
    --light = love.graphics.newImage("assets/images/game/night8/lantern_light.png")

    self.shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    self.tuneConfig = {
        latitudeVar = 23.3,
        longitudeVar = 45,
        fovVar = 0.263000
    }
    self.shd_perspective:send("latitudeVar", self.tuneConfig.latitudeVar)
    self.shd_perspective:send("longitudeVar", self.tuneConfig.longitudeVar)
    self.shd_perspective:send("fovVar", self.tuneConfig.fovVar)

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

    print(inspect(self.assets))

    --subtitlesController.clear()
    --subtitlesController.queue(languageRaw.subtitles["call_night" .. NightState.nightID])
    --love.graphics.setBackgroundColor(0.2, 0, 0, 0)
end

function SecretNightState:draw()

    self.cnv_mainCanvas:renderTo(function()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        --love.graphics.draw(self.roomlight, 0, 0)
            love.graphics.draw(self.assets.office.states["idle"]["front_light"], 0, 0)
        self.gameCam:detach()
    end)

    self.cnv_flash:renderTo(function()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
            --love.graphics.draw(roomoff, 0, 0)
            love.graphics.draw(self.assets.office.states["idle"]["front"], 0, 0)
        self.gameCam:detach()
        if self.officeState.flashlight.active then
            --love.graphics.draw(flashlight, flash.x, flash.y, 0, 1.2, 1.1, flashlight:getWidth() / 2, flashlight:getHeight() / 2)
            local ox, oy = self.assets.effects["light"]["flashlight"]:getWidth() / 2, self.assets.effects["light"]["flashlight"]:getHeight() / 2
            love.graphics.draw(self.assets.effects["light"]["flashlight"], self.officeState.flashlight.x, self.officeState.flashlight.y, 0, 1.15, 1.15, ox, oy)
        end
    end)

    love.graphics.setShader(self.shd_perspective)
        love.graphics.draw(self.cnv_mainCanvas, 0, 0)
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(self.cnv_flash, 0, 0)
        love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
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

    self.gameCam.x = (self.roomSize.width / 2 + (mx - self.roomSize.width / 2) / self.gameCam.factorX)

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

end

function SecretNightState:keypressed(k)

end

function SecretNightState:mousepressed(x, y, button)
    if button == 1 then
        self.officeState.flashlight.active = not self.officeState.flashlight.active
    end
end

function SecretNightState:leave()
    if not gameSave.save.user.settings.misc.cacheNight then
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