SecretNightState = {}
SecretNightState.assets = {}

function SecretNightState:enter()
    self.astray = require 'libraries.astray'
    self.beeperController = require 'src.Modules.Game.BeeperController'
    self.beeperView = require 'src.Modules.Game.SecretNight.BeeperView'
    self.monitorView = require 'src.Modules.Game.SecretNight.MonitorView'
    self.buttonsUI = require 'src.Modules.Game.Utils.ButtonUI'
    self.animatorController = require 'src.Modules.Game.AnimatorController'

    self.fnt_nightDisplay = fontcache.getFont("tnr", 60)

    --self.terminal = termite:new()

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

            Slab.Text("General settings")
            if Slab.CheckBox(registers.showDebugHitbox, "Show mouse hitboxes") then
                registers.showDebugHitbox = not registers.showDebugHitbox
            end
        Slab.EndWindow()
    end

    -- room --
    self.roomSize = {
        windowWidth = shove.getViewportWidth(),
        windowHeight = shove.getViewportHeight(),
        width = 2000,
        height = 800,
        compensation = 400,
    }

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
        lookDir = "front",
        hitboxes = {
            ["box"] = {
                x = self.roomSize.width / 2 - 300,
                y = 380,
                w = 170,
                h = 140,

                condition = function()
                    return self.officeState.lookDir == "front" and not self.officeState.wood.holdingWood
                end,
            },
            ["boiler"] = {
                x = self.roomSize.width / 2 - 512 / 2,
                y = 200,
                w = 512,
                h = 512,

                condition = function()
                    return self.officeState.lookDir == "back"
                end,
            },
        },
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
        monitor = {
            open = false,
            displayStatic = false,
        },
        furnace = {
            open = false,
            vincentIntegrity = 100,
            vincentIntegrityPenault = 0.5,
            furnaceFuel = 20,
        },
        ambienceBoilerVolume = 0.25,
        lookingBack = false,
        lookingState = false,
        wood = {
            fuelTakeTime = 0,
            fuelMaxTakeTime = 20,
            holdingWood = false,
            holdingMouseState = false,
            holdingFX = 0,
        }
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
    self.hoverBackLookButton = self.buttonsUI:new(self.assets.ui["hover_look"], 96, shove.getViewportHeight() / 2, 0, -0.75, 0.75, true)
    self.computerHackButton = self.buttonsUI:new(self.assets.ui["hover_panel"], shove.getViewportWidth() / 2, shove.getViewportHeight() - 96, 0, 0.75, 0.75, true)

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

    self.turnAnim = self.animatorController:new(self.assets.office.states["look_back"], 25, "lb_")
    self.turnAnim.visible = false

    self.boilerAnim = self.animatorController:new(self.assets.office.states["boiler_open"], 25, "bo_")
    self.boilerAnim.visible = false
    self.boilerAnim.animationRunning = false

    self.computerAnim = self.animatorController:new(self.assets["monitor"], 20, "mon")
    self.computerAnim.visible = false
    self.computerAnim.animationRunning = false

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
    local inside, vmx, vmy = shove.mouseToViewport()
    local mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
    self.cnv_mainCanvas:renderTo(function()
        love.graphics.clear()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
            if self.officeState.lookDir == "front" then
                love.graphics.draw(self.assets.office.states["idle"]["front_light"], 0, 0)
            else
                 love.graphics.draw(self.assets.office.states["idle"]["back"], 0, 0)
            end
            self.turnAnim:draw()
            if self.officeState.lookDir == "back" then
                self.boilerAnim:draw()
            end
        self.gameCam:detach()
    end)

    self.cnv_flash:renderTo(function()
        love.graphics.clear()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
            if self.officeState.lookDir == "front" then
                love.graphics.draw(self.assets.office.states["idle"]["front"], 0, 0)
            end
        self.gameCam:detach()
        if self.officeState.flashlight.active then
            local ox, oy = self.assets.effects["light"]["flashlight"]:getWidth() / 2, self.assets.effects["light"]["flashlight"]:getHeight() / 2
            love.graphics.draw(self.assets.effects["light"]["flashlight"], self.officeState.flashlight.x, self.officeState.flashlight.y, 0, 1.15, 1.15, ox, oy)
        end
    end)

    love.graphics.setShader(self.shd_perspective)
        love.graphics.draw(self.cnv_mainCanvas, 0, 0)
        if not self.officeState.lookingBack and self.officeState.lookDir == "front" then
            love.graphics.setBlendMode("multiply", "premultiplied")
            love.graphics.draw(self.cnv_flash, 0, 0)
            love.graphics.setBlendMode("alpha")
        end
    love.graphics.setShader()

    self.beeperView:draw()
    self.beeperController:draw()
    self.beeperView:postDraw()

    self.monitorView:draw()
    if self.officeState.monitor.displayStatic then
        love.graphics.draw(self.assets["monitor_static"], 0, 0)
    end
    self.computerAnim:draw()
    self.monitorView:postDraw()

    if registers.showDebugHitbox then
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
            for k, h in pairs(self.officeState.hitboxes) do
                love.graphics.setColor(0, 1, 0.5, 0.4)
                    love.graphics.rectangle("fill", h.x, h.y, h.w, h.h)
                love.graphics.setColor(1, 1, 1, 1)
            end
        self.gameCam:detach()
    end

    if self.officeState.wood.holdingWood then
        love.graphics.draw(self.assets["wood_hold"], 0, 0)
    end

    local loadFrame = math.floor(math.map(self.officeState.wood.fuelTakeTime, 0, self.officeState.wood.fuelMaxTakeTime, 1, 9))
    love.graphics.setBlendMode("add")
        love.graphics.setColor(1, 1, 1, self.officeState.wood.holdingFX)
            if self.assets["loadUI"]["load" .. loadFrame] ~= nil then
                love.graphics.draw(
                    self.assets["loadUI"]["load" .. loadFrame], vmx, vmy, 0, 0.5, 0.5, 
                    self.assets["loadUI"]["load1"]:getWidth() / 2, self.assets["loadUI"]["load1"]:getHeight() / 2
                )
            end
        love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")

    if self.officeState.nightStarted then
        local rangeStart = 50
        local rangeEnd = 130
        if self.officeState.lookDir == "back" then
            local dist = math.distance(vmx, vmy, self.hoverBackLookButton.x, self.hoverBackLookButton.y)
            love.graphics.setColor(1, 1, 1, math.map(dist, rangeStart, rangeEnd, 1, 0))
                self.hoverBackLookButton:draw()
            love.graphics.setColor(1, 1, 1, 1)
        else
            local distHoverLook = math.distance(vmx, vmy, self.hoverLookButton.x, self.hoverLookButton.y)
            love.graphics.setColor(1, 1, 1, math.map(distHoverLook, rangeStart, rangeEnd, 1, 0))
                self.hoverLookButton:draw()
            love.graphics.setColor(1, 1, 1, 1)

            local distHoverPC = math.distance(vmx, vmy, self.computerHackButton.x, self.computerHackButton.y)
            love.graphics.setColor(1, 1, 1, math.map(distHoverPC, rangeStart, rangeEnd, 1, 0))
                self.computerHackButton:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    end


    if self.nightTextDisplay.displayNightText then
        local txt = languageService["game_night_announce"]:format(8) 
        love.graphics.setColor(1, 1, 1, self.nightTextDisplay.fade)
            love.graphics.print(txt, self.fnt_nightDisplay, shove.getViewportWidth() / 2, shove.getViewportHeight() / 2 - self.fnt_nightDisplay:getHeight() / 2, 0, self.nightTextDisplay.scale, self.nightTextDisplay.scale, self.fnt_nightDisplay:getWidth(txt) / 2, self.fnt_nightDisplay:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end


    love.graphics.print(inspect(self.officeState.wood), 20, 20)
end

function SecretNightState:update(elapsed)
    local inside, vmx, vmy = shove.mouseToViewport()
    local mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    if self.officeState.flashlight.active then
        self.officeState.flashlight.x, self.officeState.flashlight.y = vmx, vmy
    end
    
    self.shd_perspective:send("latitudeVar", self.tuneConfig.latitudeVar)
    self.shd_perspective:send("longitudeVar", self.tuneConfig.longitudeVar)
    self.shd_perspective:send("fovVar", self.tuneConfig.fovVar)

    --self.officeState.flashlight.lightBeam.angle = math.atan2(vmy - shove.getViewportHeight(), vmx - shove.getViewportWidth() - 300)

    if not self.beeperController.tabUp and not self.officeState.monitor.open then
        self.gameCam.x = (self.roomSize.width / 2 + (mx - self.roomSize.width / 2) / self.gameCam.factorX)
    end

    -- hitboxes --
    if love.mouse.isDown(1) then
        if self.officeState.nightStarted then
            if collision.pointRect({ x = mx, y = my }, self.officeState.hitboxes["box"]) then
                if self.officeState.hitboxes["box"].condition() then
                    self.officeState.wood.fuelTakeTime = self.officeState.wood.fuelTakeTime + elapsed
                end

                if self.officeState.wood.fuelTakeTime >= self.officeState.wood.fuelMaxTakeTime then
                    self.officeState.wood.fuelTakeTime = 0
                    self.officeState.wood.holdingWood = true
                end
            end
        end
    end

    if self.officeState.nightStarted then
        if self.officeState.lookDir == "front" then
            if collision.pointRect({ x = mx, y = my }, self.officeState.hitboxes["box"]) then
                self.officeState.wood.holdingFX = math.lerp(self.officeState.wood.holdingFX, 1, 0.05)
            else
                self.officeState.wood.holdingFX = math.lerp(self.officeState.wood.holdingFX, 0, 0.05)
            end
        else
            self.officeState.wood.holdingFX = math.lerp(self.officeState.wood.holdingFX, 0, 0.05)
        end
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

    self.officeState.ambienceBoilerVolume = math.lerp(self.officeState.ambienceBoilerVolume, self.officeState.lookDir == "back" and 0.75 or 0.2, 0.075, 0.9 * elapsed)
    AudioSources["sfx_boiler_amb"]:setVolume(self.officeState.ambienceBoilerVolume)

    if self.officeState.nightStarted then
        if collision.pointRect({ x = vmx, y = vmy }, self.hoverLookButton) then
            if self.officeState.lookDir == "front" then
                if not self.turnAnim.animationRunning then
                    if not self.hoverLookButton.isHover then
                        self.hoverLookButton.isHover = true
                        self.officeState.lookingBack = true
                        self.turnAnim:setState(true)
                        self.turnAnim.onComplete = function()
                            self.turnAnim.visible = false
                            self.officeState.lookDir = "back"
                            self.officeState.lookingBack = false
                        end
                    end
                end
            end
        else
            self.hoverLookButton.isHover = false
        end
        if collision.pointRect({ x = vmx, y = vmy }, self.hoverBackLookButton) then
            if self.officeState.lookDir == "back" and not self.officeState.furnace.open then
                if not self.turnAnim.animationRunning then
                    if not self.hoverBackLookButton.isHover then
                        self.hoverBackLookButton.isHover = true
                        self.officeState.lookingBack = true
                        self.turnAnim:setState(false)
                        self.turnAnim.onComplete = function()
                            self.officeState.lookDir = "front"
                            self.turnAnim.visible = false
                            self.officeState.lookingBack = false
                        end
                    end
                end
            end
        else
            self.hoverBackLookButton.isHover = false
        end

        if collision.pointRect({ x = vmx, y = vmy }, self.computerHackButton) then
            if self.officeState.lookDir == "front" then
                if not self.computerAnim.animationRunning then
                    if not self.computerHackButton.isHover then
                        self.computerHackButton.isHover = true
                        if self.officeState.monitor.open then
                            self.officeState.monitor.displayStatic = false
                            self.computerAnim:setState(false)
                            self.computerAnim.onComplete = function()
                                self.computerAnim.visible = false
                                self.officeState.monitor.open = true
                            end
                        else
                            self.computerAnim:setState(true)
                            self.computerAnim.onComplete = function()
                                self.computerAnim.visible = false
                                self.officeState.monitor.open = true
                                self.officeState.monitor.displayStatic = true
                            end
                        end
                    end
                end
            end
        else
            self.computerHackButton.isHover = false
        end
    end

    self.turnAnim:update(elapsed)
    self.boilerAnim:update(elapsed)

    self.computerAnim:update(elapsed)

    self.beeperController:update(elapsed)
    self.beeperView:update(elapsed)

    self.nightTimer:update(elapsed)
end

function SecretNightState:mousepressed(x, y, button)
    local inside, vmx, vmy = shove.mouseToViewport()
    local mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    self.beeperView:mousepressed(vmx, vmy, button)

    if not self.officeState.nightStarted then return end

    if button == 1 and self.officeState.lookDir == "front" then
        self.officeState.flashlight.active = not self.officeState.flashlight.active
    end
    
    if button == 1 then
        if collision.pointRect({ x = mx, y = my }, self.officeState.hitboxes["boiler"]) then
            if not self.boilerAnim.animationRunning then
                if self.officeState.hitboxes["boiler"].condition() then
                    self.boilerAnim:setState(not self.officeState.furnace.open)
                    self.boilerAnim.onComplete = function()
                        self.officeState.furnace.open = not self.officeState.furnace.open
                    end
                end
            end
        end
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