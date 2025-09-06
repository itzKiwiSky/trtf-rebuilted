local TabletCameraSubState = {}

local drawQueue = require 'src.Modules.Game.Utils.DrawQueueBar'

local function changeCamFX()
    TabletCameraSubState:doInterference(0.3, 70, 100, 1.5)
    if AudioSources["sfx_cam_switch"]:isPlaying() then
        AudioSources["sfx_cam_switch"]:seek(0) 
    end
    AudioSources["sfx_cam_switch"]:play()
end

---Create a intereference in the camera
---@param seconds number
---@param intensity number
---@param speed number
---@param px number
function TabletCameraSubState:doInterference(seconds, intensity, speed, px)
    self.interferenceData.timer = seconds
    self.interferenceIntensity = intensity
    self.interferenceSpeed = speed
    self.pixelationInterference = px
end

function TabletCameraSubState:load()
    self.tabletDisplay = require 'src.Modules.Game.TabletInfoDisplay'
    self.marker = require 'src.Modules.Game.Utils.Marker'
    self.buttonCamera = require 'src.Modules.Game.Utils.ButtonCamera'
    self.cameraController = require 'src.Modules.Game.CameraController'

    self.interferenceData = {
        acc = 0,
        timer = 0.3
    }

    self.fxTV = moonshine(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)
    .chain(moonshine.effects.scanlines)

    self.fxTV.scanlines.width = 1.5
    self.fxTV.scanlines.opacity = 0.35

    self.fxTV.pixelate.feedback = 0.1
    self.fxTV.pixelate.size = {1.5, 1.5}
    self.fxTV.chromasep.radius = 1

    self.crtEffect = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.vignette)


    self.interferenceFX = love.graphics.newShader("assets/shaders/Interference.glsl")
    self.interferenceFX:send("intensity", 0.012)
    self.interferenceFX:send("speed", 100.0)
    self.interferenceIntensity = 0.012
    self.interferenceSpeed = 100.0
    self.pixelationInterference = 1.5


    self.fxCanvas = love.graphics.newCanvas(shove.getViewportDimensions())
    self.loadingCanvas = love.graphics.newCanvas(shove.getViewportDimensions())
    self.viewCanvas = love.graphics.newCanvas(shove.getViewportDimensions())

    self.cameraMeta = require 'src.Modules.Game.CameraConfig'

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
        ["foxy_hall_right"] = {x = 979, y = 545, w = 72, h = 40},
        ["foxy_hall_left"] = {x = 1137, y = 545, w = 72, h = 40},
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
        {btn = self.buttonCamera(950, 431, 72, 40)},  
        {btn = self.buttonCamera(1165, 432, 72, 40)}, 
        {btn = self.buttonCamera(1064, 323, 72, 40)}, 
        {btn = self.buttonCamera(906, 339, 72, 40)},  
        {btn = self.buttonCamera(898, 267, 72, 40)},  
        {btn = self.buttonCamera(1064, 256, 72, 40)}, 
        {btn = self.buttonCamera(1018, 195, 72, 40)}, 
        {btn = self.buttonCamera(1168, 362, 72, 40)}, 
        {btn = self.buttonCamera(999, 490, 72, 40)},  
        {btn = self.buttonCamera(1127, 490, 72, 40)}, 
        {btn = self.buttonCamera(1004, 636, 72, 40)}, 
        {btn = self.buttonCamera(1116, 636, 72, 40)}, 
    }

    self.reloadTimer = 0
    self.miscButtons = {
        reload = {
            text = languageService["game_btn_rewind_box"],
            type = "hold",
            hitbox = self.buttonCamera(546, shove.getViewportHeight() - 110, 128, 48),
            visible = false,
            action = function()
                if NightState.AnimatronicControllers["puppet"] == nil then return end
                self.reloadTimer = self.reloadTimer + love.timer.getDelta()
                if self.reloadTimer >= 0.05 then
                    if NightState.AnimatronicControllers["puppet"].musicBoxTimer <= NightState.AnimatronicControllers["puppet"].maxRewind - 1 then
                        NightState.AnimatronicControllers["puppet"].musicBoxTimer = NightState.AnimatronicControllers["puppet"].musicBoxTimer + math.random(6, 12)
                    end
                    self.reloadTimer = 0
                end
            end
        },
        ["seal_vent"] = {
            text = NightState.officeState.vent.right and languageService["game_btn_unseal_vent"] or languageService["game_btn_seal_vent"],
            type = "click",
            hitbox = self.buttonCamera(486, shove.getViewportHeight() - 110, 128, 48),
            visible = false,
            action = function()
                if not NightState.officeState.vent.requestClose then
                    if self.camID == "vent_kitty" then
                        if NightState.AnimatronicControllers["kitty"] == nil then return end
                        NightState.officeState.vent.timerAcc = 0
                        NightState.officeState.vent.direction = "left"
                        NightState.officeState.vent.requestClose = true
                    elseif self.camID == "vent_sugar" then
                        if NightState.AnimatronicControllers["sugar"] == nil then return end
                        NightState.officeState.vent.timerAcc = 0
                        NightState.officeState.vent.direction = "right"
                        NightState.officeState.vent.requestClose = true
                    end
                end
            end
        },
    }

    for k, b in pairs(self.miscButtons) do
        self.miscButtons[k].active = false 
    end

    self.editBTN = {}

    self.clickArea = {
        x = 128,
        y = 128,
        w = 780,
        h = 512,
    }

    self.camMarker = self.marker.new(128, 128, 780, 512, 32)
end

function TabletCameraSubState:draw()
    self.fxCanvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        if NightState.assets.cameras[self.camID] then
            love.graphics.setShader(self.interferenceFX)
                if NightState.officeState.lightCam.state then
                    if not NightState.officeState.lightCam.isFlicking then
                        love.graphics.draw(NightState.assets.cameras[self.camID]["cs_" .. self.cameraMeta[self.camID].frame], 0, 0)
                        if self.camerasID[NightState.AnimatronicControllers["puppet"].metadataCameraID] == self.camID and NightState.AnimatronicControllers["puppet"].released then
                            love.graphics.draw(NightState.assets.cameras["puppet"]["cs_" .. NightState.AnimatronicControllers["puppet"].position], 0, 0)
                        end
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
                love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.draw(NightState.assets.camSystemError, shove.getViewportWidth() / 2, 200, 0, 0.8, 0.8, NightState.assets.camSystemError:getWidth() / 2, NightState.assets.camSystemError:getHeight() / 2)
            love.graphics.printf(languageService["game_misc_camera_error"], NightState.fnt_camError, 0, 450, shove.getViewportWidth(), "center")
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
                love.graphics.printf(languageService["game_misc_camera_error_id"] .. " FAZ-CM08823", NightState.fnt_timerfnt, 0, 530, shove.getViewportWidth(), "center")
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    self.loadingCanvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(NightState.assets.camSystemLogo, shove.getViewportWidth() / 2, shove.getViewportHeight() - 490, 0, 0.7, 0.7, NightState.assets.camSystemLogo:getWidth() / 2, NightState.assets.camSystemLogo:getHeight() / 2)

        if NightState.officeState.tabletBootProgress < 100 then
            love.graphics.rectangle("line", shove.getViewportWidth() / 2 - 128, 500, 256, 42)
            drawQueue((shove.getViewportWidth() / 2 - 128), 500, 256, 38, math.floor(NightState.officeState.tabletBootProgress * 0.2), 20, 5, 5, {41, 165, 236}, {41, 165, 236})
        end

        love.graphics.printf("Initializing...", NightState.fnt_vhs, 0, 550, shove.getViewportWidth(), "center")
        love.graphics.printf("v1.4.35 | Fazbear Ent. 1998 - 2005", NightState.fnt_vhs, 0, shove.getViewportHeight() - 32, shove.getViewportWidth(), "center")
    end)

    self.viewCanvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.fxTV(function()
            love.graphics.draw(self.fxCanvas, 0, 0)
            --love.graphics.setBlendMode("add")
            --    love.graphics.setColor(1, 1, 1, 0.14)
            --        love.graphics.draw(NightState.assets.staticfx["static_" .. NightState.staticfx.frameid], 0, 0)
            --    love.graphics.setColor(1, 1, 1, 1)
            --love.graphics.setBlendMode("alpha")

            if NightState.officeState.tabletFirstBoot then
                love.graphics.setColor(1, 1, 1, NightState.officeState.tabletBootProgressAlpha)
                    love.graphics.draw(self.loadingCanvas, 0, 0)
                love.graphics.setColor(1, 1, 1, 1)
            end

            local crt = NightState.assets["perfect_crt"]
            love.graphics.draw(crt, 0, 0, 0, shove.getViewportWidth() / crt:getWidth(), shove.getViewportHeight() / crt:getHeight())
        end)
    end)

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)
    self.crtEffect(function()
        love.graphics.draw(self.viewCanvas, 0, 0)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 32, 32, shove.getViewportWidth() - 64, shove.getViewportHeight() - 64)
        love.graphics.setLineWidth(1)
        if love.timer.getTime() % 1 > 0.5 then
            love.graphics.setColor(1, 0, 0, 1)
                love.graphics.circle("fill", shove.getViewportWidth() - 96, 96, 28)
            love.graphics.setColor(1, 1, 1, 1)
        end

        --love.graphics.setColor(0.5, 0.5, 0.5, 1)
        --love.graphics.printf(self.camerasName[self.camButtonID], NightState.fnt_camName, 2, 34, shove.getViewportWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(self.camerasName[self.camButtonID], 
            NightState.fnt_camName, shove.getViewportWidth() - 370, 
            150, NightState.assets.camMap:getWidth(), "center"
        )
        love.graphics.printf(NightState.night.text, NightState.fnt_timerfnt, 0, 37, 
            shove.getViewportWidth(), "center")


        love.graphics.rectangle("line", 64, shove.getViewportHeight() - 110, 128, 48)
        love.graphics.draw(NightState.assets.camMap, shove.getViewportWidth() - 370, 200, 0, 1.5, 1.5)
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

            for k, animatronic in pairs(NightState.AnimatronicControllers) do
                animatronic:draw()
            end

            love.graphics.setColor(0.5, 0.5, 0.5, 1)
            love.graphics.printf(string.upper("cam_" .. _), NightState.fnt_camfnt, b.btn.x, b.btn.y + 3, b.btn.w - 8, "center")
            love.graphics.setColor(1, 1, 1, 1)
        end

        -- info --
        self.tabletDisplay(self)

        for k, b in pairs(self.miscButtons) do
            if b.visible then
                if b.active then
                    if love.timer.getTime() % 1 > 0.5 then
                        love.graphics.setColor(0, 0, 1, 1)
                    else
                        love.graphics.setColor(1, 1, 0, 1)
                    end
                else
                    love.graphics.setColor(0.5, 0.5, 0.5, 1)
                end
                love.graphics.rectangle("fill", b.hitbox.x + 8, b.hitbox.y + 8, b.hitbox.w - 8, b.hitbox.h - 8)
                love.graphics.setColor(0.75, 0.75, 0.75, 1)

                love.graphics.rectangle("fill", b.hitbox.x, b.hitbox.y, b.hitbox.w - 8, b.hitbox.h - 8)
                love.graphics.setColor(1, 1, 1, 1)

                love.graphics.setColor(0.5, 0.5, 0.5, 1)
                love.graphics.printf(b.text, NightState.fnt_camfnt, b.hitbox.x, b.hitbox.y + 3, b.hitbox.w - 8, "center")
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end)

    if FEATURE_FLAGS.developerMode then
        if registers.showDebugHitbox then
            love.graphics.setColor(0.7, 0.2, 1, 0.4)
                love.graphics.rectangle("fill", self.clickArea.x, self.clickArea.y, self.clickArea.w, self.clickArea.h)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function TabletCameraSubState:update(elapsed)
    local inside, mx, my = shove.mouseToViewport()

    self.interferenceFX:send("time", love.timer.getTime())
    self.interferenceFX:send("intensity", self.interferenceIntensity)
    self.interferenceFX:send("speed", self.interferenceSpeed)
    self.fxTV.pixelate.size = { self.pixelationInterference, self.pixelationInterference }

    self.interferenceIntensity = math.lerp(self.interferenceIntensity, 0.012, self.interferenceData.timer)
    self.pixelationInterference = math.lerp(self.pixelationInterference, 1.5, self.interferenceData.timer)

    self.camID = self.camerasID[self.camButtonID]

    if NightState.officeState.tabletFirstBoot then
        NightState.officeState.tabletBootProgress = NightState.officeState.tabletBootProgress + 100 * elapsed
        if NightState.officeState.tabletBootProgress >= 100 then
            NightState.officeState.tabletBootProgressAlpha = NightState.officeState.tabletBootProgressAlpha - 0.6 * elapsed
        end

        if NightState.officeState.tabletBootProgress >= 100 and NightState.officeState.tabletBootProgressAlpha <= 0 then
            NightState.officeState.tabletFirstBoot = false
        end
    end 

    -- cam flashlight --
    NightState.officeState.lightCam.state = false
    -- keyboard --
    NightState.officeState.lightCam.state = Controller:down("game_flashlight") and NightState.officeState.tabletUp

    if NightState.AnimatronicControllers["puppet"] ~= nil then 
        self.miscButtons["reload"].visible = false
        if self.camerasID[NightState.AnimatronicControllers["puppet"].metadataCameraID] == self.camID and NightState.AnimatronicControllers["puppet"].released then
            self.miscButtons["reload"].visible = true
        end
    end

    if NightState.AnimatronicControllers["kitty"] ~= nil or NightState.AnimatronicControllers["sugar"] ~= nil then 
        self.miscButtons["seal_vent"].visible = false
        if self.camID == "vent_kitty" or self.camID == "vent_sugar" then
            self.miscButtons["seal_vent"].visible = true
        end
    end

    if love.mouse.isDown(1) then
        if NightState.officeState.tabletUp then
            if collision.pointRect({x = mx, y = my}, self.clickArea) then
                NightState.officeState.lightCam.state = true

                if not AudioSources["buzzlight"]:isPlaying() then
                    AudioSources["buzzlight"]:play()
                end
            end
        end

        for k, b in pairs(self.miscButtons) do
            b.active = false
            if b.visible and b.type == "hold" then
                if collision.pointRect({x = mx, y = my}, b.hitbox) then
                    b.active = true
                    b.action()
                end
            end
        end
    end

    -- yay --
    NightState.officeState.lightCam.isFlicking = not (love.timer.getTime() % math.random(2, 5) > 0.6)

    -- controllers --
    if Controller:pressed("game_change_cam_left") then
        self.camButtonID = self.camButtonID - 1
        self:doInterference(0.3, 70, 100, 1.5)
        changeCamFX()
    end
    if Controller:pressed("game_change_cam_right") then
        self.camButtonID = self.camButtonID + 1
        self:doInterference(0.3, 70, 100, 1.5)
        changeCamFX()
    end

    if self.camButtonID < 1 then
        self.camButtonID = #self.camerasID
    end
    if self.camButtonID > #self.camerasID then
        self.camButtonID = 1
    end

    -- render camera --
    self.cameraController(self)
end

function TabletCameraSubState:mousepressed(x, y, button)
    local inside, mx, my = shove.mouseToViewport()

    if button == 1 then
        for _, b in ipairs(self.buttons) do
            if collision.pointRect({ x = mx, y = my }, b.btn) then
                self.camButtonID = _
                changeCamFX()
            end
        end

        for k, b in pairs(self.miscButtons) do
            self.active = false
            if b.visible and b.type == "click" then
                if collision.pointRect({ x = mx, y = my }, b.hitbox) then
                    b.active = true
                    b.action()
                end
            end
        end
    end
end

return TabletCameraSubState