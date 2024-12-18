local TabletCameraSubState = {}

local drawQueue = require 'src.Components.Modules.Game.Utils.DrawQueueBar'

local function changeCamFX()
    TabletCameraSubState.doInterference(0.3, 70, 100, 1.5)
    if AudioSources["cam_interference"]:isPlaying() then
        AudioSources["cam_interference"]:seek(0) 
    end
    AudioSources["cam_interference"]:play()
end

function TabletCameraSubState.doInterference(seconds, intensity, speed, px)
    interferenceData.timer = seconds
    interferenceIntensity = intensity
    interferenceSpeed = speed
    pixelationInterference = px
end

function TabletCameraSubState:load()
    tabletDisplay = require 'src.Components.Modules.Game.TabletInfoDisplay'
    marker = require 'src.Components.Modules.Game.Utils.Marker'
    buttonCamera = require 'src.Components.Modules.Game.Utils.ButtonCamera'
    cameraController = require 'src.Components.Modules.Game.CameraController'

    interferenceData = {
        acc = 0,
        timer = 0.3
    }

    fxTV = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.vignette)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)
    .chain(moonshine.effects.scanlines)

    fxTV.scanlines.width = 1.5
    fxTV.scanlines.opacity = 0.65

    fxTV.pixelate.feedback = 0.1
    fxTV.pixelate.size = {1.5, 1.5}
    fxTV.chromasep.radius = 1

    if gameslot.save.game.user.settings.shaders then
        fxTV.enable("vignette", "chromasep")
    else
        fxTV.disable("vignette", "chromasep")
    end

    interferenceFX = love.graphics.newShader("assets/shaders/Interference.glsl")
    interferenceFX:send("intensity", 0.012)
    interferenceFX:send("speed", 100.0)
    interferenceIntensity = 0.012
    interferenceSpeed = 100.0
    pixelationInterference = 1.5

    fxCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    loadingCanvas = love.graphics.newCanvas(love.graphics.getDimensions())

    self.cameraMeta = require 'src.Components.Modules.Game.CameraConfig'

    self.areas = {
        ["arcade"] = {x = 950, y = 431, w = 72, h = 40},
        ["storage"] = {x = 1165, y = 432, w = 72, h = 40},
        ["dining_area"] = {x = 1064, y = 323, w = 72, h = 40},
        ["pirate_cove"] = {x = 906, y = 339, w = 72, h = 40},
        ["parts_and_service"] = {x = 898, y = 267, w = 72, h = 40},
        ["showstage"] = {x = 1064, y = 256, w = 72, h = 40},
        ["kitchen"] = {x = 1018, y = 195, w = 72, h = 40},
        ["prize_corner"] = {x = 1168, y = 362, w = 72, h = 40},
        ["left_hall"] = {x = 999, y = 490, w = 72, h = 40}, 
        ["right_hall"] = {x = 1127, y = 490, w = 72, h = 40},
        ["left_vent"] = {x = 1004, y = 636, w = 72, h = 40},
        ["right_vent"] = {x = 1116, y = 636, w = 72, h = 40},
        ["front_office"] = {x = 1076, y = 544, w = 72, h = 40},
        ["office"] = {x = 1079, y = 592, w = 72, h = 40},
        ["freddy_hall"] = {x = 1154, y = 569, w = 72, h = 40},
    }

    self.camerasName = {
        "Arcade",
        "Storage",
        "Dining area",
        "Pirate cove",
        "Parts & service",
        "Showstage",
        "Kitchen",
        "Prize corner",
        "Left hall",
        "Right hall",
        "Left vent",
        "Right vent",
    }

    self.camerasID = {
        "arcade",
        "storage",
        "dining_area",
        "pirate_cove",
        "parts_and_service",
        "showstage",
        "kitchen",  -- disabled cam --
        "prize_corner",
        "left_hall",
        "right_hall",
        "vent_sugar",
        "vent_kitty",
    }

    self.camButtonID = 6
    self.camID = self.camerasID[self.camButtonID]

    self.buttons = {
        {btn = buttonCamera(950, 431, 72, 40)},  
        {btn = buttonCamera(1165, 432, 72, 40)}, 
        {btn = buttonCamera(1064, 323, 72, 40)}, 
        {btn = buttonCamera(906, 339, 72, 40)},  
        {btn = buttonCamera(898, 267, 72, 40)},  
        {btn = buttonCamera(1064, 256, 72, 40)}, 
        {btn = buttonCamera(1018, 195, 72, 40)}, 
        {btn = buttonCamera(1168, 362, 72, 40)}, 
        {btn = buttonCamera(999, 490, 72, 40)},  
        {btn = buttonCamera(1127, 490, 72, 40)}, 
        {btn = buttonCamera(1004, 636, 72, 40)}, 
        {btn = buttonCamera(1116, 636, 72, 40)}, 
    }

    self.miscButtons = {
        {
            text = "Info.",
            hitbox = buttonCamera(46, 724, 128, 42),
            action = function()
                
            end
        }
    }

    editBTN = {}

    self.clickArea = {
        x = 128,
        y = 128,
        w = 780,
        h = 512,
    }

    self.camMarker = marker.new(128, 128, 780, 512, 32)
end

function TabletCameraSubState:draw()
    fxCanvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        if NightState.assets.cameras[self.camID] then
            love.graphics.setShader(interferenceFX)
                if officeState.lightCam.state then
                    if not officeState.lightCam.isFlicking then
                        love.graphics.draw(NightState.assets.cameras[self.camID]["cs_" .. self.cameraMeta[self.camID].frame], 0, 0)
                    end
                end
            love.graphics.setShader()
            
            love.graphics.setLineWidth(5)
                love.graphics.setColor(1, 1, 1, 0.7)
                    self.camMarker:draw()
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setLineWidth(1)
        else
            love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.draw(NightState.assets.camSystemError, love.graphics.getWidth() / 2, 200, 0, 0.8, 0.8, NightState.assets.camSystemError:getWidth() / 2, NightState.assets.camSystemError:getHeight() / 2)
            love.graphics.printf(languageService["game_misc_camera_error"], fnt_camError, 0, 450, love.graphics.getWidth(), "center")
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
                love.graphics.printf(languageService["game_misc_camera_error_id"] .. " FAZ-CM08823", fnt_timerfnt, 0, 530, love.graphics.getWidth(), "center")
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    loadingCanvas:renderTo(function()
        love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(NightState.assets.camSystemLogo, love.graphics.getWidth() / 2, love.graphics.getHeight() - 490, 0, 0.7, 0.7, NightState.assets.camSystemLogo:getWidth() / 2, NightState.assets.camSystemLogo:getHeight() / 2)

        if officeState.tabletBootProgress < 100 then
            love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 128, 500, 256, 32)
            drawQueue((love.graphics.getWidth() / 2 - 128), 500, 256, 38, math.floor(officeState.tabletBootProgress * 0.2), 20, 5, 5, {41, 165, 236}, {41, 165, 236})
        end

        love.graphics.printf("Initializing...", fnt_vhs, 0, 550, love.graphics.getWidth(), "center")
        love.graphics.printf("v1.4.34 | Fazbear Ent. 1999 - 2005", fnt_vhs, 0, love.graphics.getHeight() - 32, love.graphics.getWidth(), "center")
    end)

    fxTV(function()
        love.graphics.draw(fxCanvas, 0, 0)
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.14)
                love.graphics.draw(NightState.assets.staticfx["static_" .. staticfx.frameid], 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 32, 32, love.graphics.getWidth() - 64, love.graphics.getHeight() - 64)
        love.graphics.setLineWidth(1)
        if love.timer.getTime() % 1 > 0.5 then
            love.graphics.setColor(1, 0, 0, 1)
                love.graphics.circle("fill", 96, 96, 32)
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.printf(self.camerasName[self.camButtonID], fnt_camName, 2, 34, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(self.camerasName[self.camButtonID], fnt_camName, 0, 32, love.graphics.getWidth(), "center")
        love.graphics.print(night.text, fnt_timerfnt, 64, 37)


        love.graphics.rectangle("line", 64, love.graphics.getHeight() - 110, 128, 48)
        love.graphics.draw(NightState.assets.camMap, love.graphics.getWidth() - 370, 200, 0, 1.5, 1.5)
        for _, b in ipairs(self.buttons) do
            if _ == self.camButtonID  then
                if love.timer.getTime() % 1 > 0.5 then
                    love.graphics.setColor(0, 0, 1, 1)
                else
                    love.graphics.setColor(1, 1, 0, 1)
                end
            else
                love.graphics.setColor(0.5, 0.5, 0.5, 1)
            end
            love.graphics.rectangle("fill", b.btn.x + 8, b.btn.y + 8, b.btn.w - 8, b.btn.h - 8)
            love.graphics.setColor(0.75, 0.75, 0.75, 1)

            love.graphics.rectangle("fill", b.btn.x, b.btn.y, b.btn.w - 8, b.btn.h - 8)
            love.graphics.setColor(1, 1, 1, 1)

            for k, v in pairs(NightState.AnimatronicControllers) do
                v.draw()
            end

            love.graphics.printf(string.upper("cam_" .. _), fnt_camfnt, b.btn.x, b.btn.y, b.btn.w - 8, "center")
        end

        -- info --
        tabletDisplay(self)

        for _, b in ipairs(self.buttons) do
            if _ == self.camButtonID  then
                if love.timer.getTime() % 1 > 0.5 then
                    love.graphics.setColor(0, 0, 1, 1)
                else
                    love.graphics.setColor(1, 1, 0, 1)
                end
            else
                love.graphics.setColor(0.5, 0.5, 0.5, 1)
            end
            love.graphics.rectangle("fill", b.btn.x + 8, b.btn.y + 8, b.btn.w - 8, b.btn.h - 8)
            love.graphics.setColor(0.75, 0.75, 0.75, 1)

            love.graphics.rectangle("fill", b.btn.x, b.btn.y, b.btn.w - 8, b.btn.h - 8)
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.printf(string.upper("cam_" .. _), fnt_camfnt, b.btn.x, b.btn.y, b.btn.w - 8, "center")
        end

        for k, v in pairs(NightState.AnimatronicControllers) do
            v.draw()
        end

        if officeState.tabletFirstBoot then
            love.graphics.setColor(1, 1, 1, officeState.tabletBootProgressAlpha)
                love.graphics.draw(loadingCanvas, 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    if DEBUG_APP then
        if registers.system.showDebugHitbox then
            love.graphics.setColor(0.7, 0.2, 1, 0.4)
                love.graphics.rectangle("fill", self.clickArea.x, self.clickArea.y, self.clickArea.w, self.clickArea.h)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    -- cam editor, I used only one time XD, maybe I will delete this shit --
    if DEBUG_APP then
        if registers.system.camEdit then
            for _, b in ipairs(editBTN) do
                if _ == self.camButtonID then
                    if love.timer.getTime() % 1 > 0.5 then
                        love.graphics.setColor(0, 0, 1, 1)
                    else
                        love.graphics.setColor(1, 1, 0, 1)
                    end
                else
                    love.graphics.setColor(0.5, 0.5, 0.5, 1)
                end
                love.graphics.rectangle("fill", b.btn.x + 8, b.btn.y + 8, b.btn.w - 8, b.btn.h - 8)
                love.graphics.setColor(0.75, 0.75, 0.75, 1)
        
                love.graphics.rectangle("fill", b.btn.x, b.btn.y, b.btn.w - 8, b.btn.h - 8)
                love.graphics.setColor(1, 1, 1, 1)
        
                love.graphics.rectangle("line", b.btn.x, b.btn.y, b.btn.w, b.btn.h)
            end
        
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.rectangle("fill", love.mouse.getX() + 8, love.mouse.getY() + 8, 72 - 8, 40 - 8)
            love.graphics.setColor(0.75, 0.75, 0.75, 1)
        
            love.graphics.rectangle("fill", love.mouse.getX(), love.mouse.getY(), 72 - 8, 40 - 8)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function TabletCameraSubState:update(elapsed)
    local mx, my = love.mouse.getPosition()

    interferenceFX:send("time", love.timer.getTime())
    interferenceFX:send("intensity", interferenceIntensity)
    interferenceFX:send("speed", interferenceSpeed)
    fxTV.pixelate.size = { pixelationInterference, pixelationInterference }

    interferenceIntensity = math.lerp(interferenceIntensity, 0.012, interferenceData.timer)
    pixelationInterference = math.lerp(pixelationInterference, 1.5, interferenceData.timer)

    self.camID = self.camerasID[self.camButtonID]

    if officeState.tabletFirstBoot then
        officeState.tabletBootProgress = officeState.tabletBootProgress + 100 * elapsed
        if officeState.tabletBootProgress >= 100 then
            officeState.tabletBootProgressAlpha = officeState.tabletBootProgressAlpha - 0.6 * elapsed
        end

        if officeState.tabletBootProgress >= 100 and officeState.tabletBootProgressAlpha <= 0 then
            officeState.tabletFirstBoot = false
        end
    end 

    -- cam flashlight --
    officeState.lightCam.state = false
    -- keyboard --
    officeState.lightCam.state = love.keyboard.isDown("lctrl") and officeState.tabletUp

    if love.mouse.isDown(1) then
        if officeState.tabletUp then
            if collision.pointRect({x = mx, y = my}, self.clickArea) then
                officeState.lightCam.state = true
            end
        end
    end

    -- yay --
    officeState.lightCam.isFlicking = not (love.timer.getTime() % math.random(2, 5) > 0.6)

    -- static animation --
    staticfx.timer = staticfx.timer + elapsed
    if staticfx.timer >= staticfx.speed then
        staticfx.timer = 0
        staticfx.frameid = staticfx.frameid + 1
        if staticfx.frameid > NightState.assets.staticfx.frameCount then
            staticfx.frameid = 1
        end
    end

    if self.camButtonID < 1 then
        self.camButtonID = #self.camerasID
    end
    if self.camButtonID > #self.camerasID then
        self.camButtonID = 1
    end

    -- render camera --
    cameraController(self)
end

function TabletCameraSubState:mousepressed(x, y, button)
    if button == 1 then
        for _, b in ipairs(self.buttons) do
            if collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, b.btn) then
                self.camButtonID = _
                changeCamFX()
            end
        end
    end

    if DEBUG_APP then
        if registers.system.camEdit then
            if button == 1 then
                table.insert(editBTN, {btn = buttonCamera(love.mouse.getX(), love.mouse.getY(), 72, 40)})
            end
            if button == 2 then
                lume.clear(editBTN)
            end
        end
    end
end

function TabletCameraSubState:keypressed(k)
    if k == "left" then
        self.camButtonID = self.camButtonID + 1
        changeCamFX()
    end
    if k == "right" then
        self.camButtonID = self.camButtonID - 1
        TabletCameraSubState.doInterference(0.3, 70, 100, 1.5)
        changeCamFX()
    end
end

return TabletCameraSubState