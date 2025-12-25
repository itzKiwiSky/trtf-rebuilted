SecretNightState = {}
SecretNightState.assets = {}
SecretNightState.forceRestart = false

local function playWalk()
    local audio = "sfx_walk" .. math.random(1, 7)
    AudioSources[audio]:setVolume(0.45)
    AudioSources[audio]:play()
end

local function fearShake(amp)
    return (love.math.random() * 2 - 1) * amp
end

local function convertTime(sc, offset)
    local tSeconds = sc + (offset or 0)
    local minutes = math.floor(tSeconds / 60)
    local leftSecs = tSeconds % 60
    return minutes, leftSecs
end

local function checkAllLocked(self)
    local names = { "freddy", "bonnie", "chica", "foxy", "sugar", "kitty", "marionette", "frankburt" }
    for _, name in ipairs(names) do
        if self.monitorView.animatronics[name].locked ~= true and name ~= "frankburt" then
            return false
        end
    end

    return true
end


function SecretNightState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
    self.beeperController = require 'src.Modules.Game.BeeperController'
    self.beeperView = require 'src.Modules.Game.SecretNight.BeeperView'
    self.monitorView = require 'src.Modules.Game.SecretNight.MonitorView'
    self.buttonsUI = require 'src.Modules.Game.SecretNight.ButtonUI'
    self.animatorController = require 'src.Modules.Game.AnimatorController'
    self.drawQueue = require 'src.Modules.Game.Utils.DrawQueueBar'

    self.fnt_phoneCallName = fontcache.getFont("ocrx", 25)
    self.fnt_displayKill = fontcache.getFont("ocrx", 40)
    self.fnt_phoneCallFooter = fontcache.getFont("ocrx", 18)

    self.forceRestart = false

    self.fnt_nightDisplay = fontcache.getFont("tnr", 60)

    registers.devWindowContent = function()
        Slab.BeginWindow("debugWindow", { Title = "Debug shader" })
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
        Slab.Text('[DANGER]')
        Slab.SameLine()
        if Slab.Button("Restart Scene") then
            self.forceRestart = true
            local preservedAssets = table.deepclone(self.assets)

            local path = "src/States/SecretNightState.lua"

            local ok, chunk = pcall(love.filesystem.load, path)
            if not ok then error(chunk) end

            local ok, newState = pcall(chunk)
            if not ok then error(newState) end

            assert(type(newState) == "table", "State inválido")

            newState.assets = preservedAssets
            gamestate.switch(newState)

            if FEATURE_FLAGS.developerMode then
                collectgarbage("collect")
            end
        end
        if Slab.Button("spawn frankburt challenge") then
            self.officeState.blink.alpha = 1
            for name, anim in pairs(self.monitorView.animatronics) do
                if name ~= "frankburt" then
                    anim.locked = true
                end
            end
            self.monitorView.animatronics["frankburt"].hidden = false
            self.officeState.furnace.vincentIntegrity = 0
            self.monitorView:validateSelection()
            self.monitorView:createNames()
        end
        Slab.Text('[Animatronic stuff]')
        Slab.Separator()
        Slab.Text('Frankburt')
        Slab.SameLine()
        if Slab.Button("front") then
            self.officeState.blink.alpha = 1
            self.IA.frankburt.state = "front"
        end
        Slab.SameLine()
        if Slab.Button("office") then
            self.officeState.blink.alpha = 1
            self.IA.frankburt.state = "office"
        end
        Slab.SameLine()
        if Slab.Button("right") then
            self.officeState.blink.alpha = 1
            self.IA.frankburt.state = "right"
        end
        Slab.Separator()
        Slab.Text('Golden shower')
        if Slab.Button("front") then
            self.officeState.blink.alpha = 1
            self.IA["golden_shower"].state = "front"
        end
        Slab.SameLine()
        if Slab.Button("back") then
            self.officeState.blink.alpha = 1
            self.IA["golden_shower"].state = "back"
        end
        Slab.SameLine()
        if Slab.Button("right") then
            self.officeState.blink.alpha = 1
            self.IA["golden_shower"].state = "right"
        end
        if Slab.Button("trigger end sequence") then
            self.officeState.hideAllShit = true
            self.officeState.nightStarted = false
            self.officeState.blink.alpha = 1
            self.lockjawAttackPose:setState(false)
            SecretNightState.officeState.deathSequence.active = true
            SecretNightState.officeState.deathSequence.finalSequence = true
            self.computerAnim:setState(false)
            AudioSources["sfx_close_panel"]:setVolume(0.75)
            AudioSources["sfx_close_panel"]:play()

            AudioSources["msc_lockjaw_theme"]:stop()
        end
        Slab.EndWindow()
    end

    self.phoneState = "incoming"
    self.blurPhoneFX = moonshine(moonshine.effects.gaussianblur)
    self.blurPhoneFX.gaussianblur.sigma = 5

    self.fearLevel = 0

    self.IA = {
        config = {
            ["frankburt"] = 8,
            ["golden_freddy"] = 8,
            incrementValue = 0,
            tmr = 0,
        },
        ["golden_shower"] = {
            attacking = false,
            state = "idle",
            rng = 0,
            tmr_move = timer.new(),
            patience = 3,
            fade = 0,
            fadeMulti = 1.2,
            hitboxes = {
                ["front"] = {
                    x = 872,
                    y = 362,
                    w = 316,
                    h = 169,
                },
                ["right"] = {
                    x = 1350,
                    y = 200,
                    w = 240,
                    h = 240,
                }
            },
        },
        frankburt = {
            active = false,
            attacking = false,
            hitboxes = {
                ["front"] = {
                    x = 890,
                    y = 230,
                    w = 280,
                    h = 180,
                },
                ["right"] = {
                    x = 1390,
                    y = 200,
                    w = 220,
                    h = 230,
                }
            },
            rng = 0,
            moveTimer = 0,
            moveTimerMax = 16,
            state = "idle",
            patience = 3,
        },
    }

    self.tmr_iaIncrement = timer.new()
    self.tmr_iaIncrement:after(27, function()
        self.IA.config.incrementValue = self.IA.config.incrementValue + 1
        self.IA.config["frankburt"] = self.IA.config["frankburt"] + math.random(1, 3)
        self.IA.config["golden_freddy"] = self.IA.config["golden_freddy"] + math.random(1, 2)
    end)

    self.IA["golden_shower"].tmr_move:after(10, function()
        self.IA["golden_shower"].rng = math.random(1, 20)

        if self.IA["golden_shower"].rng >= self.IA.config["golden_freddy"] and not self.IA.frankburt.attacking then
            self.IA["golden_shower"].attacking = true
            self.officeState.blink.alpha = 1
            self.IA["golden_shower"].state = lume.weightedchoice({ ["front"] = 40, ["right"] = 60, ["back"] = 10 })
            self.patience = math.random(3, 6)
        end
    end)

    SecretNightState.assets.grd_battery = love.graphics.newGradient("horizontal",
        { lume.color('#4322D4') }, { lume.color('#225AD4') }, { lume.color('#22B3D4') }
    )

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
        hideAllShit = false,
        nightStarted = false,
        deathSequence = {
            active = false,
            dead = false,
            tmr_lockjawWaitToKill = timer.new(),
            finalSequence = false,
            showStatic = false,
        },
        killed = false,
        scared = false,
        lookDir = "front",
        blink = {
            alpha = 1
        },
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
            alpha = 1,
            battery = 20,
            maxBattery = 20,
            rechargeMultiplier = 2.4,
            energyConsumeMultiplier = 2.2,
            reloading = false,
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
            vincentIntegrityPenault = 0.25,
            fuelPenalty = 0.3,
            fuelAdd = 20,
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

    local sx, sy = 0.75, 0.75
    self.hoverLookButton = self.buttonsUI:new(self.assets.ui["hover_look"], shove.getViewportWidth() - 96,
        shove.getViewportHeight() / 2, 0, 0.75, 0.75, true)
    self.hoverLookButton.hitbox.w = self.hoverLookButton.image:getWidth() * sx
    self.hoverLookButton.hitbox.h = self.hoverLookButton.image:getHeight() * sy

    self.hoverBackLookButton = self.buttonsUI:new(self.assets.ui["hover_look"], 128, shove.getViewportHeight() / 2, 0,
        -0.75, 0.75, true)
    self.hoverBackLookButton.hitbox.x = (self.hoverBackLookButton.hitbox.x - self.hoverBackLookButton.image:getWidth() / 2) *
        sx
    self.hoverBackLookButton.hitbox.w = self.hoverBackLookButton.image:getWidth() * sx
    self.hoverBackLookButton.hitbox.h = self.hoverBackLookButton.image:getHeight() * sy

    self.computerHackButton = self.buttonsUI:new(self.assets.ui["hover_panel"], shove.getViewportWidth() / 2,
        shove.getViewportHeight() - 96, 0, 0.75, 0.75, true)
    self.computerHackButton.hitbox.w = self.computerHackButton.image:getWidth() * sx
    self.computerHackButton.hitbox.h = self.computerHackButton.image:getHeight() * sy

    self.gameCam = camera.new(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    self.gameCam.factorX = 2.8
    self.gameCam.factorY = 25

    self.activateTmr = timer.new()

    self.activateTmr:after(14, function()
        self.IA.frankburt.active = true
    end)

    self.X_LEFT_FRAME = self.gameCam.x
    self.X_RIGHT_FRAME = self.gameCam.x + self.roomSize.width
    self.Y_TOP_FRAME = self.gameCam.y
    self.Y_BOTTOM_FRAME = self.gameCam.y + self.roomSize.height

    self.cnv_mainCanvas = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())
    self.cnv_invertedRoom = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())
    self.cnv_flash = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())
    self.cnv_lockjawPoses = love.graphics.newCanvas(shove.getViewportDimensions())
    self.cnv_battery = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight(), { readable = true })

    self.maskShader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            if (Texel(texture, texture_coords).rgb == vec3(0.0))
                discard;
            return vec4(1.0);
        }
    ]])

    self.beeperController:init(self.assets.beeper, 34, "beep_")
    self.beeperController.visible = false

    self.beeperView:init()
    self.beeperController.onComplete = function()
        AudioSources["sfx_beeper_use"]:play()
        AudioSources["sfx_beeper_use"]:setVolume(0.87)
    end

    self.turnAnim = self.animatorController:new(self.assets.office.states["look_back"], 35, "lb_")
    self.turnAnim.visible = false

    self.boilerAnim = self.animatorController:new(self.assets.office.states["boiler_open"], 35, "bo_")
    self.boilerAnim.visible = false
    self.boilerAnim.animationRunning = false

    self.computerAnim = self.animatorController:new(self.assets["monitor"], 30, "mon")
    self.computerAnim.visible = false
    self.computerAnim.animationRunning = false

    local function kill()
        DeathState.secretNight = true
        gamestate.switch(DeathState)
    end

    self.fadeTransition = {
        alpha = 0,
    }

    self.jumpscareFront = self.animatorController:new(self.assets["jumpscares"]["frankburt"]["front"], 35, "frankburt_jmp")
    self.jumpscareBack = self.animatorController:new(self.assets["jumpscares"]["frankburt"]["back"], 35, "frankburt_jmp")
    self.jumpscareFront.visible = false
    self.jumpscareFront.animationRunning = false
    self.jumpscareBack.visible = false
    self.jumpscareBack.animationRunning = false
    self.jumpscareFront.onComplete = kill
    self.jumpscareBack.onComplete = kill

    self.lockjawAttackPose = self.animatorController:new(self.assets["ending"]["attack"], 34, "attack")
    self.lockjawAttackPose.visible = false
    self.lockjawAttackPose.loop = true

    self.lockjawDeathPose = self.animatorController:new(self.assets["ending"]["dead"], 34, "dead")
    self.lockjawDeathPose.visible = false

    self.cnv_phone = love.graphics.newCanvas(shove.getViewportDimensions())
    self.cnv_blurPhone = love.graphics.newCanvas(shove.getViewportDimensions())

    self.phoneAnimFinal = self.animatorController:new(self.assets["ending"]["phone"], 28, "phone")
    self.phoneAnimFinal.visible = false
    self.phoneAnimFinal.loop = false
    self.phoneAnimFinal.onComplete = function()
        self.phoneAnimFinal.visible = true
        self.phoneAnimFinal.frame = 1
    end

    AudioSources["sfx_boiler_amb"]:setLooping(true)
    AudioSources["sfx_boiler_amb"]:setVolume(self.officeState.ambienceBoilerVolume)
    AudioSources["sfx_boiler_amb"]:play()

    self.nightTimer = timer.new()
    self.nightTimer:after(2, function(sleep)
        self.beeperController:setState(true)
        AudioSources["sfx_beeper_open"]:play()
        AudioSources["sfx_beeper_open"]:setVolume(0.87)
    end)

    self.tmr_lockjawAttack = timer.new()
    self.tmrH_hand = self.tmr_lockjawAttack:after(37, function()
        self.officeState.killed = true
        for k, v in pairs(AudioSources) do
            v:stop()
        end
        AudioSources["sfx_lockjaw_jumpscare"]:play()
        self.jumpscareFront:setState(false)
    end)


    self.monitorView:init()

    self.tmr_finalScript = timer.new()
    self.tmr_finalScript:script(function(sleep)
        sleep(2)
        self.fearLevel = 0
        AudioSources["sfx_kill"]:stop()
        self.lockjawAttackPose.animationRunning = false
        self.lockjawAttackPose.visible = false
        self.officeState.deathSequence.dead = true
        self.lockjawDeathPose.visible = true
        self.lockjawDeathPose:setState(true)
        AudioSources["sfx_lockjaw_deactivate"]:play()
        sleep(3)
        AudioSources["sfx_phone_pickup"]:play()
        self.phoneAnimFinal:setState(false)
        self.phoneState = "incoming"
        sleep(2)
        AudioSources["sfx_ringphone"]:play()
        sleep(6.75)
        self.phoneState = "call"
        self.assets.calls["callEnd"]:play()
        sleep(self.assets.calls["callEnd"]:getDuration() + 1)
        self.phoneState = "end"
        AudioSources["sfx_callend"]:play()
        sleep(3)
        self.phoneAnimFinal:setState(true)
        self.phoneAnimFinal.onComplete = function()
            self.phoneAnimFinal.visible = false
        end
        AudioSources["sfx_phone_pickup"]:play()
        sleep(1)
        flux.to(self.fadeTransition, 3, { alpha = 1 }):oncomplete(function()
            EndingState.mode = "secret"
            gamestate.switch(EndingState)
        end)
    end)
end

function SecretNightState:draw()
    local inside, vmx, vmy = shove.mouseToViewport()
    local mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
    self.cnv_mainCanvas:renderTo(function()
        love.graphics.clear()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        if self.officeState.lookDir == "front" then
            if self.IA.frankburt.state ~= "idle" then
                local state = self.IA.frankburt.state == "office" and "office_light" or self.IA.frankburt.state
                love.graphics.draw(self.assets.office.animatronic[state], 0, 0)
            elseif self.IA["golden_shower"].state ~= "idle" then
                local state = self.IA["golden_shower"].state
                love.graphics.draw(self.assets.office.hallu[state], 0, 0)
            else
                love.graphics.draw(self.assets.office.states["idle"]["front_light"], 0, 0)
            end
        else
            love.graphics.draw(self.assets.office.states["idle"]["back"], 0, 0)
        end
        self.turnAnim:draw()
        if self.officeState.lookDir == "back" then
            if self.IA["golden_shower"].state ~= "idle" then
                local state = self.IA["golden_shower"].state
                love.graphics.draw(self.assets.office.hallu["back"], 0, 0)
            else
                self.boilerAnim:draw()
            end
        end
        self.gameCam:detach()
    end)

    self.cnv_flash:renderTo(function()
        love.graphics.clear()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        if self.officeState.lookDir == "front" then
            if self.IA.frankburt.state ~= "idle" and self.IA.frankburt.state == "office" then
                love.graphics.draw(self.assets.office.animatronic["office"], 0, 0)
            else
                love.graphics.draw(self.assets.office.states["idle"]["front"], 0, 0)
            end
        end
        self.gameCam:detach()
        if self.officeState.flashlight.active then
            love.graphics.setColor(1, 1, 1, self.officeState.flashlight.alpha)
            local ox, oy = self.assets.effects["light"]["flashlight"]:getWidth() / 2,
                self.assets.effects["light"]["flashlight"]:getHeight() / 2
            love.graphics.draw(self.assets.effects["light"]["flashlight"], self.officeState.flashlight.x,
                self.officeState.flashlight.y, 0, 1.15, 1.15, ox, oy)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    self.cnv_lockjawPoses:renderTo(function()
        love.graphics.clear()
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        if self.officeState.deathSequence.active then
            self.lockjawAttackPose:draw()
        end
        if self.officeState.deathSequence.dead then
            self.lockjawDeathPose:draw()
        end

        if self.officeState.deathSequence.showStatic then
            love.graphics.draw(self.assets["ending"].disabled, 0, 0)
        end
        self.gameCam:detach()
    end)

    love.graphics.setShader(self.shd_perspective)
    love.graphics.draw(self.cnv_mainCanvas, 0, 0)
    if not self.officeState.lookingBack and self.officeState.lookDir == "front" then
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(self.cnv_flash, 0, 0)
        love.graphics.setBlendMode("alpha")
    end
    love.graphics.setShader()

    love.graphics.setShader(self.shd_perspective)
    love.graphics.draw(self.cnv_lockjawPoses, 0, 0)
    love.graphics.setShader()

    self.beeperView:draw()
    self.beeperController:draw()
    self.beeperView:postDraw()

    love.graphics.setColor(0, 0, 0, self.officeState.blink.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    self.monitorView:draw()
    if self.officeState.monitor.displayStatic then
        love.graphics.draw(self.assets["monitor_static"], 0, 0)
    end
    self.computerAnim:draw()
    self.monitorView:postDraw()

    self.cnv_phone:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        local posX = 557
        local posY = 460
        local bg = self.assets["phone"]["phone_bg"]
        local btn_refuse = self.assets["phone"]["phone_refuse"]
        local btn_accept = self.assets["phone"]["phone_accept"]
        love.graphics.draw(bg, posX, shove.getViewportHeight() / 2 + 50, 0, 168 / bg:getWidth(), 200 / bg:getHeight())

        local tm, ts = convertTime(self.assets.calls["callEnd"]:tell("seconds"))
        if self.phoneState == "incoming" then
            love.graphics.printf(languageService["game_misc_call_incoming"], self.fnt_phoneCallFooter, posX, posY + 80, 159, "center")
        else
            love.graphics.printf(string.format("%02d:%02d", tm, ts), self.fnt_phoneCallFooter, posX, posY + 60, 159, "center")
        end
        love.graphics.printf("Carl", self.fnt_phoneCallName, posX, posY + 30, 159, "center")

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf(languageService["game_misc_buttons_exit"], self.fnt_phoneCallFooter, posX, posY + 160, 159, "left")
        love.graphics.printf(languageService["game_misc_buttons_options"], self.fnt_phoneCallFooter, posX, posY + 160, 159, "right")
        love.graphics.setColor(1, 1, 1, 1)
    end)

    self.cnv_blurPhone:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.blurPhoneFX(function()
            love.graphics.draw(self.cnv_phone, 0, 0)
        end)
    end)

    if self.officeState.deathSequence.active and not self.officeState.hideAllShit then
        local value = math.map(
            self.tmr_lockjawAttack:getTime(self.tmrH_hand),
            1, self.tmr_lockjawAttack:getLimit(self.tmrH_hand),
            self.tmr_lockjawAttack:getLimit(self.tmrH_hand), 1
        )
        love.graphics.printf(string.format("%.1f", value), self.fnt_displayKill, 0, 75, shove.getViewportWidth(), "center")
    end

    if registers.showDebugHitbox then
        self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        for k, h in pairs(self.officeState.hitboxes) do
            love.graphics.setColor(0, 1, 0.5, 0.4)
            love.graphics.rectangle("fill", h.x, h.y, h.w, h.h)
            love.graphics.setColor(1, 1, 1, 1)
        end
        for k, h in pairs(self.IA.frankburt.hitboxes) do
            love.graphics.setColor(lume.color("#EEC618A7"))
            love.graphics.rectangle("fill", h.x, h.y, h.w, h.h)
            love.graphics.setColor(1, 1, 1, 1)
        end
        self.gameCam:detach()
    end

    if not self.officeState.hideAllShit then
        if self.officeState.wood.holdingWood then
            love.graphics.draw(self.assets["wood_hold"], 0, 0)
        end

        local loadFrame = math.floor(math.map(self.officeState.wood.fuelTakeTime, 0, self.officeState.wood.fuelMaxTakeTime, 1,
            9))
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
    end

    if not self.officeState.hideAllShit then
        if self.officeState.nightStarted then
            local rangeStart = 20
            local rangeEnd = 300
            local finalOpacity = 0.5
            if self.officeState.lookDir == "back" then
                local dist = math.distance(vmx, vmy, self.hoverBackLookButton.x, self.hoverBackLookButton.y)
                love.graphics.setColor(1, 1, 1, math.map(dist, rangeStart, rangeEnd, 1, finalOpacity))
                self.hoverBackLookButton:draw()
                love.graphics.setColor(1, 1, 1, 1)
            else
                local distHoverLook = math.distance(vmx, vmy, self.hoverLookButton.x, self.hoverLookButton.y)
                love.graphics.setColor(1, 1, 1, math.map(distHoverLook, rangeStart, rangeEnd, 1, finalOpacity))
                self.hoverLookButton:draw()
                love.graphics.setColor(1, 1, 1, 1)

                local distHoverPC = math.distance(vmx, vmy, self.computerHackButton.x, self.computerHackButton.y)
                love.graphics.setColor(1, 1, 1, math.map(distHoverPC, rangeStart, rangeEnd, 1, finalOpacity))
                self.computerHackButton:draw()
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end

    if self.phoneAnimFinal.frame == 1 and self.phoneAnimFinal.visible then
        love.graphics.draw(self.cnv_phone)
    end
    self.phoneAnimFinal:draw()
    if self.phoneAnimFinal.frame == 1 and self.phoneAnimFinal.visible then
        love.graphics.setBlendMode("add")
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.draw(self.cnv_blurPhone)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")
    end


    if self.nightTextDisplay.displayNightText then
        local txt = languageService["game_night_announce"]:format(8)
        love.graphics.setColor(1, 1, 1, self.nightTextDisplay.fade)
        love.graphics.print(txt, self.fnt_nightDisplay, shove.getViewportWidth() / 2,
            shove.getViewportHeight() / 2 - self.fnt_nightDisplay:getHeight() / 2, 0, self.nightTextDisplay.scale,
            self.nightTextDisplay.scale, self.fnt_nightDisplay:getWidth(txt) / 2, self.fnt_nightDisplay:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    if self.officeState.nightStarted then
        if not self.officeState.hideAllShit then
            local icoX, icoY = 96, shove.getViewportHeight() - 96

            love.graphics.setColor(lume.color('#0D1F42'))
            love.graphics.draw(
                self.assets.ui["flashlight_bg"], icoX, icoY, 0,
                128 / self.assets.ui["flashlight_bg"]:getWidth(), 64 / self.assets.ui["flashlight_bg"]:getHeight()
            )
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.stencil(function()
                love.graphics.setShader(self.maskShader)
                love.graphics.draw(
                    self.assets.ui["flashlight_mask"], icoX, icoY, 0,
                    128 / self.assets.ui["flashlight_mask"]:getWidth(), 64 / self.assets.ui["flashlight_mask"]:getHeight()
                )
                love.graphics.setShader()
            end, "replace", 1)

            love.graphics.setStencilTest("equal", 1)
            love.graphics.draw(self.assets.grd_battery, icoX, icoY, 0,
                math.floor(128 * (self.officeState.flashlight.battery / self.officeState.flashlight.maxBattery)), 64)

            love.graphics.setStencilTest()

            love.graphics.draw(
                self.assets.ui["flashlight_icon"], icoX, icoY, 0,
                128 / self.assets.ui["flashlight_icon"]:getWidth(), 64 / self.assets.ui["flashlight_icon"]:getHeight()
            )
        end
    end

    self.jumpscareFront:draw()
    self.jumpscareBack:draw()

    love.graphics.setColor(1, 1, 1, self.IA["golden_shower"].fade)
    love.graphics.draw(self.assets.office.hallu["jmp_fade"], 0, 0)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, self.fadeTransition.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function SecretNightState:update(elapsed)
    local inside, vmx, vmy = shove.mouseToViewport()
    local mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    -- blinkm shit --
    local speed = 4
    self.officeState.blink.alpha = self.officeState.blink.alpha - speed * elapsed

    if self.officeState.flashlight.active then
        self.officeState.flashlight.x, self.officeState.flashlight.y = vmx, vmy
    end

    if FEATURE_FLAGS.developerMode then
        self.shd_perspective:send("latitudeVar", self.tuneConfig.latitudeVar)
        self.shd_perspective:send("longitudeVar", self.tuneConfig.longitudeVar)
        self.shd_perspective:send("fovVar", self.tuneConfig.fovVar)
    end

    local shakeX = fearShake(self.fearLevel)
    if not self.beeperController.tabUp and not self.officeState.monitor.open then
        self.gameCam.x = (self.roomSize.width / 2 + (mx - self.roomSize.width / 2) / self.gameCam.factorX) + shakeX
    end

    -- hitboxes --
    if love.mouse.isDown(1) then
        if self.officeState.nightStarted then
            if collision.pointRect({ x = mx, y = my }, self.officeState.hitboxes["box"]) then
                if self.officeState.hitboxes["box"].condition() then
                    self.officeState.wood.fuelTakeTime = self.officeState.wood.fuelTakeTime + elapsed
                    if not AudioSources["sfx_collect_wood"]:isPlaying() then
                        AudioSources["sfx_collect_wood"]:setVolume(0.45)
                        AudioSources["sfx_collect_wood"]:play()
                    end
                end

                if self.officeState.wood.fuelTakeTime >= self.officeState.wood.fuelMaxTakeTime then
                    if not AudioSources["sfx_collect_wood"]:isPlaying() then
                        AudioSources["sfx_collect_wood"]:stop()
                    end
                    if self.officeState.wood.holdingWood then
                        AudioSources["sfx_finish_wood"]:play()
                    end
                    self.officeState.wood.fuelTakeTime = 0
                    self.officeState.wood.holdingWood = true
                end
            end
        end
    else
        AudioSources["sfx_collect_wood"]:stop()
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

        -- boiler update --
        if self.officeState.furnace.furnaceFuel > 0 and self.officeState.furnace.vincentIntegrity < 0 then
            self.officeState.furnace.vincentIntegrity = self.officeState.furnace.vincentIntegrity - elapsed * self.officeState.furnace.vincentIntegrityPenault
            self.officeState.furnace.furnaceFuel = self.officeState.furnace.furnaceFuel - elapsed * self.officeState.furnace.fuelPenalty
        end

        if self.officeState.furnace.vincentIntegrity <= 0 and not self.officeState.deathSequence.active and checkAllLocked(self) then
            if self.officeState.lookDir == "back" then
                self.turnAnim:setState(false)
                self.turnAnim.onComplete = function()
                    self.officeState.blink.alpha = 1
                    self.officeState.lookDir = "front"
                    --self.turnAnim.visible = false
                    self.officeState.lookingBack = false
                    AudioSources["sfx_kill"]:setLooping(true)
                    AudioSources["sfx_kill"]:play()
                    self.officeState.deathSequence.active = true
                    self.lockjawAttackPose:setState(false)
                end
            else
                AudioSources["sfx_kill"]:setLooping(true)
                AudioSources["sfx_kill"]:play()
                self.officeState.deathSequence.active = true
                self.lockjawAttackPose:setState(false)
            end
            self.fearLevel = 12
        end
    end

    if self.officeState.deathSequence.active and not self.officeState.deathSequence.finalSequence then
        self.tmr_lockjawAttack:update(elapsed)
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
            self.nightTextDisplay.scale = self.nightTextDisplay.scale + 0.75 * elapsed

            if self.nightTextDisplay.fade >= 1.4 then
                self.nightTextDisplay.invert = true
            end
        end
    elseif self.nightTextDisplay.displayNightText and self.nightTextDisplay.invert then
        self.officeState.nightRun = true
        self.nightTextDisplay.acc = self.nightTextDisplay.acc + elapsed
        if self.nightTextDisplay.acc >= 0.05 then
            self.nightTextDisplay.acc = 0
            self.nightTextDisplay.fade = self.nightTextDisplay.fade - 4.2 * elapsed
            self.nightTextDisplay.scale = self.nightTextDisplay.scale + 0.2 * elapsed

            if self.nightTextDisplay.fade <= 0 then
                self.nightTextDisplay.displayNightText = false
            end
        end
    end

    self.officeState.ambienceBoilerVolume = math.lerp(self.officeState.ambienceBoilerVolume, self.officeState.lookDir == "back" and 0.75 or 0.2, 0.075, 0.4)
    AudioSources["sfx_boiler_amb"]:setVolume(self.officeState.ambienceBoilerVolume)

    if self.officeState.nightStarted and not self.officeState.killed then
        if collision.pointRect({ x = vmx, y = vmy }, self.hoverLookButton.hitbox) and not self.officeState.deathSequence.active then
            if self.officeState.lookDir == "front" and not self.officeState.monitor.open and not self.computerAnim.animationRunning then
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
        if collision.pointRect({ x = vmx, y = vmy }, self.hoverBackLookButton.hitbox) and not self.officeState.deathSequence.active then
            if self.officeState.lookDir == "back" and not self.officeState.furnace.open and not self.boilerAnim.animationRunning then
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

        if collision.pointRect({ x = vmx, y = vmy }, self.computerHackButton.hitbox) then
            if self.officeState.lookDir == "front" then
                if not self.computerAnim.animationRunning then
                    if not self.computerHackButton.isHover and not self.officeState.lookingBack then
                        self.computerHackButton.isHover = true
                        if self.officeState.monitor.open then
                            self.officeState.monitor.displayStatic = false
                            self.computerAnim:setState(false)
                            AudioSources["sfx_close_panel"]:setVolume(0.75)
                            AudioSources["sfx_close_panel"]:play()
                            self.computerAnim.onComplete = function()
                                self.computerAnim.visible = false
                                self.officeState.monitor.open = false
                            end
                        else
                            AudioSources["sfx_open_panel"]:setVolume(0.75)
                            AudioSources["sfx_open_panel"]:play()
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

    if self.officeState.deathSequence.active then
        self.officeState.flashlight.active = false
    end

    if self.officeState.flashlight.active then
        self.officeState.flashlight.alpha = math.map(math.min(self.officeState.flashlight.battery, 5), 0, 5, 0, 1)
        self.officeState.flashlight.battery = self.officeState.flashlight.battery - elapsed * self.officeState.flashlight.energyConsumeMultiplier
        if self.officeState.flashlight.battery <= 0 then
            self.officeState.flashlight.active = false
        end
    else
        if self.officeState.flashlight.battery < self.officeState.flashlight.maxBattery then
            self.officeState.flashlight.battery = self.officeState.flashlight.battery + elapsed * self.officeState.flashlight.rechargeMultiplier
        end
    end

    if self.IA["golden_shower"].fade > 0 then
        self.IA["golden_shower"].fade = self.IA["golden_shower"].fade - elapsed * self.IA["golden_shower"].fadeMulti
    end

    if self.officeState.nightStarted and not (self.officeState.deathSequence.active or self.officeState.deathSequence.dead or self.officeState.deathSequence.finalSequence) then
        self.IA.frankburt.moveTimer = self.IA.frankburt.moveTimer - elapsed

        if self.IA.config.incrementValue < 5 then
            self.tmr_iaIncrement:update(elapsed)
        end

        self.IA.config["frankburt"] = math.clamp(self.IA.config["frankburt"], 0, 20)
        self.IA.config["golden_freddy"] = math.clamp(self.IA.config["golden_freddy"], 0, 20)

        self.IA["golden_shower"].tmr_move:update(elapsed)

        if self.IA.frankburt.moveTimer <= 0 and self.IA.frankburt.active then
            self.IA.frankburt.moveTimer = self.IA.frankburt.moveTimerMax

            self.IA.frankburt.rng = math.random(1, 20)

            if self.IA.frankburt.rng >= self.IA.config["frankburt"] and self.IA.config["frankburt"] > 0 and self.IA.frankburt.state == "idle" and not self.IA["golden_shower"].attacking then
                playWalk()
                self.officeState.blink.alpha = 1
                local s = lume.weightedchoice({ ["front"] = 40, ["right"] = 60, ["office"] = 10 })
                if s == "office" and not self.officeState.flashlight.active then
                    self.IA.frankburt.state = "office"
                    self.IA.frankburt.patience = math.random(3, 6) -- reinicia paciência ao entrar no office
                else
                    self.IA.frankburt.state = s
                    self.IA.frankburt.patience = math.random(3, 6) -- reinicia paciência em novo estado
                end
                self.IA.frankburt.attacking = true
            end
        end

        if self.IA["golden_shower"].state ~= "idle" then
            self.IA["golden_shower"].patience = self.IA["golden_shower"].patience - elapsed
            if self.IA["golden_shower"].state == "back" then
                if self.IA["golden_shower"].patience <= 0 and self.officeState.lookDir == "back" then
                    -- jumpscare --
                    --self.IA["golden_shower"].patience = math.random(3, 6)
                    self.IA["golden_shower"].attacking = false
                    self.IA["golden_shower"].fade = 1
                    self.IA["golden_shower"].state = "idle"

                    AudioSources["sfx_golden_freddy_jumpscare"]:play()
                else
                    self.IA["golden_shower"].attacking = false
                    self.IA["golden_shower"].state = "idle"
                end
            else
                if self.IA["golden_shower"].patience <= 0 then
                    if collision.pointRect({ x = mx, y = my }, self.IA["golden_shower"].hitboxes[self.IA["golden_shower"].state]) and self.officeState.flashlight.alpha >= 0.3 then
                        self.officeState.blink.alpha = 1
                        self.IA["golden_shower"].state = "idle"
                        self.IA["golden_shower"].attacking = false
                        playWalk()
                    else
                        self.IA["golden_shower"].attacking = false
                        self.IA["golden_shower"].fade = 1
                        self.IA["golden_shower"].state = "idle"

                        AudioSources["sfx_golden_freddy_jumpscare"]:play()
                    end
                end
            end
        end

        -- Lógica de paciência e ações executadas a cada frame (fora do timer)
        if self.IA.frankburt.state ~= "idle" then
            self.IA.frankburt.patience = self.IA.frankburt.patience - elapsed

            if self.IA.frankburt.state == "office" then
                if self.officeState.flashlight.active then
                    self.officeState.killed = true
                    for k, v in pairs(AudioSources) do
                        v:stop()
                    end
                    AudioSources["sfx_lockjaw_jumpscare"]:play()
                    if self.officeState.lookDir == "front" then
                        self.jumpscareFront:setState(false)
                    else
                        self.jumpscareBack:setState(false)
                    end
                else
                    if self.IA.frankburt.patience <= 0 then
                        self.officeState.blink.alpha = 1
                        playWalk()
                        self.IA.frankburt.state = "idle"
                        self.IA.frankburt.attacking = false
                    end
                end
            else
                -- Estados "front" ou "right"
                -- O jogador pode usar a lanterna para se defender
                if self.IA.frankburt.patience <= 0 then
                    if collision.pointRect({ x = mx, y = my }, self.IA.frankburt.hitboxes[self.IA.frankburt.state]) and self.officeState.flashlight.alpha >= 0.3 then
                        self.officeState.blink.alpha = 1
                        self.IA.frankburt.state = "idle"
                        self.IA.frankburt.attacking = false
                        playWalk()
                    else
                        -- kill shit -- (mata se a paciência acabar)
                        self.officeState.killed = true
                        for k, v in pairs(AudioSources) do
                            v:stop()
                        end
                        AudioSources["sfx_lockjaw_jumpscare"]:play()
                        if self.officeState.lookDir == "front" then
                            self.jumpscareFront:setState(false)
                        else
                            self.jumpscareBack:setState(false)
                        end
                    end
                end
            end
        end
    end

    self.turnAnim:update(elapsed)
    self.boilerAnim:update(elapsed)

    self.computerAnim:update(elapsed)

    self.beeperController:update(elapsed)
    self.beeperView:update(elapsed)

    self.monitorView:update(elapsed)

    self.nightTimer:update(elapsed)

    if self.officeState.nightStarted and not self.IA.frankburt.active then
        self.activateTmr:update(elapsed)
    end

    self.jumpscareFront:update(elapsed)
    self.jumpscareBack:update(elapsed)

    self.lockjawAttackPose:update(elapsed)
    self.lockjawDeathPose:update(elapsed)

    self.phoneAnimFinal:update(elapsed)

    if self.officeState.deathSequence.finalSequence then
        self.tmr_finalScript:update(elapsed)
    end

    flux.update(elapsed)
end

function SecretNightState:mousepressed(x, y, button)
    local inside, vmx, vmy = shove.mouseToViewport()
    local mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    self.beeperView:mousepressed(vmx, vmy, button)

    if not self.officeState.nightStarted then return end

    if self.officeState.killed then return end

    if button == 1 and self.officeState.lookDir == "front"
        and self.officeState.flashlight.battery > 1
        and not self.officeState.monitor.open
        and not self.computerAnim.animationRunning
        and not self.officeState.deathSequence.dead
        and not self.officeState.deathSequence.active
        and self.officeState.lookDir == "front"
        and not collision.pointRect({ x = mx, y = my }, self.officeState.hitboxes["box"])
    then
        if AudioSources["sfx_flashlight"]:isPlaying() then
            AudioSources["sfx_flashlight"]:stop()
        end
        AudioSources["sfx_flashlight"]:play()
        self.officeState.flashlight.active = not self.officeState.flashlight.active
    end

    if button == 1 then
        if collision.pointRect({ x = mx, y = my }, self.officeState.hitboxes["boiler"]) and self.IA["golden_shower"].state == "idle" then
            if not self.boilerAnim.animationRunning then
                if self.officeState.hitboxes["boiler"].condition() then
                    if self.officeState.furnace.open then
                        AudioSources["sfx_boiler_door_open"]:setVolume(0.75)
                        AudioSources["sfx_boiler_door_open"]:play()
                    else
                        AudioSources["sfx_boiler_door_close"]:setVolume(0.75)
                        AudioSources["sfx_boiler_door_close"]:play()
                    end
                    self.boilerAnim:setState(not self.officeState.furnace.open)
                    self.boilerAnim.onComplete = function()
                        self.officeState.furnace.open = not self.officeState.furnace.open
                    end
                end
            end
            if self.officeState.furnace.open then
                if self.officeState.wood.holdingWood and self.officeState.hitboxes["boiler"].condition() then
                    AudioSources["sfx_add_wood_boiler"]:setVolume(0.56)
                    AudioSources["sfx_add_wood_boiler"]:play()
                    self.officeState.furnace.furnaceFuel = self.officeState.furnace.furnaceFuel + self.officeState.furnace.fuelAdd
                    self.officeState.wood.holdingWood = false
                end
            end
        end
    end
end

function SecretNightState:keypressed(k)
    if self.officeState.killed then return end
    self.monitorView:keypressed(k)
end

function SecretNightState:leave()
    flux.removeAll()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    if self.forceRestart then return end

    local function releaseRecursive(tbl)
        for key, value in pairs(tbl) do
            if type(value) == "table" then
                releaseRecursive(value)
            else
                if type(value) == "userdata" and value.release then
                    value:release()
                end
            end
        end
    end

    releaseRecursive(self.assets)
end

return SecretNightState
