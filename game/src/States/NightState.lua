NightState = {}
NightState.assets = {}
NightState.KilledBy = ""
NightState.killed = false
NightState.nightID = 1000
NightState.isCustomNight = false
NightState.nightPassed = false
NightState.animatronicsAI = {
    freddy = 0,
    bonnie = 0,
    chica = 0,
    foxy = 0,
    sugar = 0,
    kitty = 0,
    puppet = 0,
}

NightState.AnimatronicControllers = {}

function NightState.playWalk()
    local r = math.random(1, 3)
    if not AudioSources["metalwalk" .. r]:isPlaying() then
        AudioSources["metalwalk" .. r]:play()
    end
end

local function mapToRange(input, min, max, step)
    local clampedInput = math.max(min, math.min(max, input))
    
    local proportion = (clampedInput - min) / (max - min)

    local invertedProportion = 1 - proportion
    
    local range = max - min
    local steppedValue = math.floor(invertedProportion * range / step + 0.5) * step + min
    
    return steppedValue
end

local function convertTime(sc, offset)
    local tSeconds = sc + (offset or 0)
    local minutes = math.floor(tSeconds / 60)
    local leftSecs = tSeconds % 60
    return minutes, leftSecs
end

local function formatAdjustedTimeAMPM(realSeconds, scaleFactor, startHour, startMinute, startPeriod)
    local adjustedSeconds = realSeconds * scaleFactor

    local startSeconds = (startHour % 12) * 3600 + startMinute * 60
    if startPeriod == "PM" then
        startSeconds = startSeconds + 12 * 3600
    end

    local totalSeconds = startSeconds + adjustedSeconds

    local hours = math.floor(totalSeconds / 3600) % 24
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = math.floor(totalSeconds % 60)
    
    local period = hours >= 12 and "PM" or "AM"
    hours = hours % 12
    if hours == 0 then hours = 12 end

    return hours, minutes, seconds, period
end

local function getPowerQueueCount(self)
    local c = 1
    for k, v in pairs(self.officeState.power.powerQueueCount) do
        if v == true then
            c = c + 1
        end
    end
    return c
end


NightState.modifiers = {
    radarMode = true,      -- can be use to debug or just for cheat (I know why u will use it your mf)
}

function NightState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    self.doorController = require 'src.Modules.Game.DoorController'
    self.tabletController = require 'src.Modules.Game.TabletController'
    self.buttonsUI = require 'src.Modules.Game.Utils.ButtonUI'
    self.tabletCameraSubState = require 'src.States.Substates.TabletCameraSubstate'
    self.maskController = require 'src.Modules.Game.MaskController'
    self.phoneController = require 'src.Modules.Game.PhoneController'
    self.shakeController = require 'src.Modules.Game.Utils.ShakeController'
    self.jumpscareController = require 'src.Modules.Game.JumpscareController'
    self.ShakeController = require 'src.Modules.Game.Utils.ShakeController'
    self.doorParticle = require 'src.Modules.Game.Utils.ParticleDoor'

    self.jumpscareController.visible = false

    self.phoneController:init(NightState.assets.phoneModel, 45, "ph")
    self.phoneController.visible = false
    self.phoneController.hitbox = {
        x = 1036, 
        y = 540, 
        w = 48, 
        h = 48
    }

    local aicgf = require 'src.Modules.Game.Utils.AIConfig'

    if aicgf[NightState.nightID] then
        NightState.animatronicsAI = aicgf[NightState.nightID]
    end

    -- import AI --
    local aif = love.filesystem.getDirectoryItems("src/Modules/Game/Animatronics")
    for a = 1, #aif, 1 do
        local filename = aif[a]:gsub("%.[^.]+$", "")
        self.AnimatronicControllers[filename:lower()] = require("src.Modules.Game.Animatronics." .. filename)
    end
    aif = nil
    collectgarbage("collect")

    -- dev mode --
    if FEATURE_FLAGS.developerMode then
        registers.devWindowContent = function()
            Slab.BeginWindow("mainNightDev", { Title = "Night development" })
                Slab.Text("General settings")
                if Slab.CheckBox(registers.showDebugHitbox, "Show mouse hitboxes") then
                    registers.showDebugHitbox = not registers.showDebugHitbox
                end
                if Slab.CheckBox(NightState.modifiers.radarMode, "Show animatronics in camera map") then
                    NightState.modifiers.radarMode = not NightState.modifiers.radarMode
                end
                if Slab.Button("End night") then
                    self.night.time = 298
                end
                Slab.SameLine()
                if Slab.Button("Create random challenge") then
                    --NightState.animatronicsAI[name] = 0
                    self.night.time = 0
                    for name in spairs(NightState.animatronicsAI) do
                        NightState.animatronicsAI[name] = math.random(0, 20)
                    end
                end
                Slab.SameLine()
                if Slab.Button("Reset All AI") then
                    --NightState.animatronicsAI[name] = 0
                    self.night.time = 0
                    for name in spairs(NightState.animatronicsAI) do
                        NightState.animatronicsAI[name] = 0
                    end
                end
                Slab.SameLine()
                if Slab.Button("Test death") then
                    --NightState.animatronicsAI[name] = 0
                end
                Slab.Separator()
                Slab.Text("IA Settings")
                for name in spairs(NightState.animatronicsAI) do
                    Slab.Text(name)
                    if Slab.Button("-") then
                        if NightState.animatronicsAI[name] > 0 then
                            NightState.animatronicsAI[name] = NightState.animatronicsAI[name] - 1
                        end
                    end
                    Slab.SameLine({
                        Pad = 2
                    })
                    Slab.Text(tostring(NightState.animatronicsAI[name]))
                    Slab.SameLine({
                        Pad = 2
                    })
                    if Slab.Button("+") then
                        if NightState.animatronicsAI[name] < 20 then
                            NightState.animatronicsAI[name] = NightState.animatronicsAI[name] + 1
                        end
                    end
                    Slab.SameLine({
                        Pad = 2
                    })
                    if Slab.Button("reset") then
                        NightState.animatronicsAI[name] = 0
                    end
                    Slab.SameLine({
                        Pad = 2
                    })
                    if Slab.Button("move foward") then
                        --NightState.animatronicsAI[name] = 0
                        if NightState.AnimatronicControllers[name].currentState < #NightState.AnimatronicControllers[name].path then
                            NightState.AnimatronicControllers[name].currentState = NightState.AnimatronicControllers[name].currentState + 1
                        end
                    end
                    Slab.SameLine({
                        Pad = 2
                    })
                    if Slab.Button("move backwards") then
                        --NightState.animatronicsAI[name] = 0
                        if NightState.AnimatronicControllers[name].currentState > 1 then 
                            NightState.AnimatronicControllers[name].currentState = NightState.AnimatronicControllers[name].currentState - 1
                        end
                    end
                end
            Slab.EndWindow()
        end
    end

    -- shader stuff --
    self.blurPhoneFX = moonshine(moonshine.effects.gaussianblur)
    self.blurPhoneFX.gaussianblur.sigma = 5

    self.blurVisionFX = moonshine(moonshine.effects.boxblur)
    self.blurVisionFX.boxblur.radius = {0, 0}

    self.fnt_vhs = fontcache.getFont("vcr", 25)
    self.fnt_camfnt = fontcache.getFont("vcr", 16)
    self.fnt_timerfnt = fontcache.getFont("vcr", 28)
    self.fnt_camError = fontcache.getFont("vcr", 30)
    self.fnt_camName = fontcache.getFont("vcr", 24)
    self.fnt_boldtnr = fontcache.getFont("tnr_bold", 20)
    self.fnt_nightDisplay = fontcache.getFont("tnr", 60)

    self.fnt_phoneCallName = fontcache.getFont("ocrx", 25)
    self.fnt_phoneCallFooter = fontcache.getFont("ocrx", 18)

    self.shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    self.shd_perspective:send("latitudeVar", 22.5)
    self.shd_perspective:send("longitudeVar", 45)
    self.shd_perspective:send("fovVar", 0.2630)

    self.cnv_mainCanvas = love.graphics.newCanvas(shove.getViewportDimensions())
    self.cnv_phone = love.graphics.newCanvas(shove.getViewportDimensions())
    self.cnv_blurPhone = love.graphics.newCanvas(shove.getViewportDimensions())
    love.graphics.clear(love.graphics.getBackgroundColor())

    ------------------------------------------

    self.isCustomNight = false
    self.nightPassed = false

    self.gameCam = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)

    -- radar --
    NightState.assets["radar_icons"] = {}
    NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads = love.graphics.newQuadFromImage("array", "assets/images/game/night/cameraUI/radar_animatronics")
    NightState.assets["radar_icons"].image:setFilter("nearest", "nearest")

    NightState.assets.grd_progressBar = love.graphics.newGradient("vertical", {31, 225, 34, 255}, {20, 100, 28, 255})
    NightState.assets.grd_toxicmeter = love.graphics.newGradient("vertical", 
        {130, 129, 158, 255},
        {191, 198, 227, 255},
        {130, 129, 158, 255}
    )
    NightState.assets.grd_bars = love.graphics.newGradient("vertical", 
        {242, 246, 248, 255}, 
        {216, 225, 231, 255},
        {181, 198, 208, 255},
        {193, 211, 222, 255},
        {224, 239, 249, 255}
    )

    -----------------------------------------------

    NightState.KilledBy = ""
    NightState.killed = false

    love.mouse.setVisible(true)

    -- sound config --
    AudioSources["amb_rainleak"]:play()
    AudioSources["amb_rainleak"]:setLooping(true)
    AudioSources["amb_rainleak"]:setVolume(0.38)

    AudioSources["amb_night"]:play()
    AudioSources["amb_night"]:setLooping(true)
    AudioSources["amb_night"]:setVolume(0.68)

    AudioSources["cam_interference"]:setVolume(0.60)

    AudioSources["amb_cam"]:setVolume(0.50)
    AudioSources["amb_cam"]:setLooping(true)

    AudioSources["tab_up"]:setVolume(0.70)
    AudioSources["tab_close"]:setVolume(0.70)

    AudioSources["door_open"]:setVolume(0.36)
    AudioSources["door_close"]:setVolume(0.36)

    AudioSources["cam_animatronic_interference"]:setVolume(0.7)

    AudioSources["stare"]:setLooping(true)

    AudioSources["bells"]:setVolume(0.6)

    AudioSources["msc_puppet_music_box"]:setVolume(0)
    AudioSources["msc_puppet_music_box"]:setLooping(true)
    AudioSources["msc_puppet_music_box"]:play()

    self.doorL = self.doorController.new(NightState.assets.doorsAnim.left, 55, false, "dl_")
    self.doorR = self.doorController.new(NightState.assets.doorsAnim.right, 55, false, "dr_")

    self.doorLFX = self.doorParticle()
    self.doorRFX = self.doorParticle()

    self.roomSize = {
        width = 2000,
        height = 800,
    }

    self.gameCam.factorX = 2.452
    self.gameCam.factorY = 25
    self.cameraObject = {   -- this will allow camera view --
        x = 0,
        y = 0,
    }

    self.tabletController:init(NightState.assets.tablet, 34, "tab_")
    self.tabletController.visible = false

    self.maskController:init(NightState.assets.maskAnim, 34, "mask_")
    self.maskController.visible = false
    self.maskController.timeout = 0.2
    self.maskController.acc = 0

    self.maskBtn = self.buttonsUI.new(NightState.assets.maskButton, 96, (shove.getViewportHeight() - NightState.assets.maskButton:getHeight()) - 24)
    self.camBtn = self.buttonsUI.new(NightState.assets.camButton, (shove.getViewportWidth() - NightState.assets.camButton:getWidth()) - 96, (shove.getViewportHeight() - NightState.assets.camButton:getHeight()) - 24)

    self.X_LEFT_FRAME = self.gameCam.x - 72
    self.X_RIGHT_FRAME = self.gameCam.x + self.roomSize.width
    self.Y_TOP_FRAME = self.gameCam.y
    self.Y_BOTTOM_FRAME = self.gameCam.y + self.roomSize.height

    self.staticfx = {
        timer = 0,
        frameid = 1,
        speed = 1 / 43
    }

    self.deskFan = {
        acc = 0,
        fid = 1,
        speed = 1 / 35
    }


    self.night = {
        time = 0,   -- accumulator --
        speed = 0.4,
        h = 0,
        m = 0,
        s = 0,
        startingHour = 12,
        startingMinute = 0,
        startingPeriod = "AM",
        period = "am",
        text = "",
    }

        -- night text --
    self.nightTextDisplay = {
        text = string.format(languageService["game_night_announce"], NightState.nightID),
        fade = 0,
        scale = 1,
        acc = 0,
        displayNightText = false,
        invert = false
    }

    -- night end text --
    self.nightEndTextDisplay = {
        text = languageService["game_night_shift_end"],
        fade = 0,
        scale = 1,
        acc = 0,
        displayNightText = false,
        invert = false
    }

    self.officeState = {
        _op = false,
        _fc = 0.04,
        _t = 0,
        _f = 0,
        _d = false,
        nightRun = false,
        jumpscareRunning = false,
        dead = false,
        fadealpha = 1,
        tabletFirstBoot = true,
        tabletBootProgress = 0,
        tabletBootProgressAlpha = 1,
        phoneCall = false,
        phoneCallNotRefused = false,
        power = {
            officeFlick = false,
            powerStat = 1000,
            powerDisplay = 100,
            powerQueueCount = {
                doorL = false,
                doorR = false,
                flashlight = false,
                tablet = false,
                leftVent = false,
                rightVent = false,
            },
            powerQueue = 1,
            timeracc = 2.5,
        },
        tabletInformationDisplay = false,
        tabletUp = false,
        maskUp = false,
        flashlight = {
            state = false,
            isFlicking = false,
        },
        lightCam = {
            state = false,
            isFlicking = false,
        },
        vent = {
            direction = "right",
            left = false,
            right = false,
            timerAcc = 0,
            ventMaxTimer = 3.6,
        },
        toxicmeter = 100,
        hasAnimatronicInOffice = false,
        officeFlick = false,
        isOfficeDisabled = false,
        doors = {
            maxDoorTime = 30,
            doorReloadBoost = 3.5,
            doorUsageBoost = 5.5,
            canUseDoorL = true,
            canUseDoorR = true,
            left = false,
            right = false,
            lDoorTimer = 10,
            rDoorTimer = 10,
            hitboxes = {
                right = {
                    x = -32,
                    y = 450,
                    w = 120,
                    h = 130,
                },
                left = {
                    x = 1915,
                    y = 450,
                    w = 120,
                    h = 130,
                },
                center = {
                    x = self.roomSize.width / 2 - 256,
                    y = 220,
                    w = 512,
                    h = 360,
                },
            }
        }
    }

    self.tmr_nightStartPhone = timer.new()
    self.tmr_nightEnd = timer.new()

    self.tabletCameraSubState:load()

    self.officeState.doors.lDoorTimer = self.officeState.doors.maxDoorTime
    self.officeState.doors.rDoorTimer = self.officeState.doors.maxDoorTime

    self.tmr_nightStartPhone:script(function(sleep)
        if self.nightID >= 1 and self.nightID <= 5 then
            sleep(3)
                self.phoneController:setState(true)
                AudioSources["phone_pickup"]:play()
            sleep(0.25)
                AudioSources["sfx_ringphone"]:play()
            sleep(AudioSources["sfx_ringphone"]:getDuration("seconds") - 1)
                self.assets.calls["call_night" .. self.nightID]:play()
                self.officeState.phoneCallNotRefused = true
                self.officeState.phoneCall = true
                self.phoneController.hitbox.x = 1090
            sleep(self.assets.calls["call_night" .. self.nightID]:getDuration("seconds"))
            sleep(AudioSources["sfx_callend"]:getDuration())
                self.phoneController:setState(false)
                AudioSources["phone_pickup"]:play()
                self.nightTextDisplay.displayNightText = true
                self.officeState.phoneCall = false
        elseif self.nightID >= 6 then
            sleep(3)
                self.nightTextDisplay.displayNightText = true
                self.officeState.phoneCall = false
        end
    end)

    self.tmr_nightEnd:script(function(sleep)
        sleep(0.5)
        self.officeState._op = true
        sleep(4)
        for k, v in pairs(AudioSources) do
            v:stop()
        end
        if not FEATURE_FLAGS.isDemo then
            gameSave.save.user.progress.night = gameSave.save.user.progress.night + 1
            gameSave.save.user.progress.newgame = false
            gameSave.save.user.progress.canContinue = true
        end
        gameSave:saveSlot()
        gamestate.switch(WinState)
    end)

    for k, v in pairs(NightState.AnimatronicControllers) do
        if v.init then v.init() end
    end
end

function NightState:draw()
    self.shakeController:prepare()
    self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        self.cnv_mainCanvas:renderTo(function()
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.draw(self.doorLFX, 1700, 178)
            love.graphics.draw(self.doorRFX, 140, 178)
            if self.officeState.isOfficeDisabled then
                if self.AnimatronicControllers["freddy"].currentState == 5 then
                    if self.AnimatronicControllers["freddy"].animState then
                        love.graphics.draw(NightState.assets["door_freddy_attack"], 0, 0)
                    else
                        love.graphics.draw(NightState.assets["door_freddy_idle"], 0, 0)
                    end
                end
            end

            self.doorL:draw(0, 0)
            self.doorR:draw(0, 0)

            -- flicking front XD --
            if self.officeState.flashlight.state then
                if not self.officeState.flashlight.isFlicking then
                    if collision.rectRect(self.AnimatronicControllers["foxy"], self.tabletCameraSubState.areas["front_office"]) then
                        love.graphics.draw(NightState.assets.front_office["foxy" .. self.AnimatronicControllers["foxy"].position], 0, 0)
                    else
                        love.graphics.draw(NightState.assets.front_office.idle, 0, 0)
                    end
                    if collision.rectRect(self.AnimatronicControllers["bonnie"], self.tabletCameraSubState.areas["front_office"]) then
                        love.graphics.draw(NightState.assets["front_office_bonnie"], 0, 0)
                    end
                    if collision.rectRect(self.AnimatronicControllers["chica"], self.tabletCameraSubState.areas["front_office"]) then
                        love.graphics.draw(NightState.assets["front_office_chica"], 0, 0)
                    end
                end
            end

            love.graphics.draw(NightState.assets.office[self.officeState.isOfficeDisabled and "off" or "idle"], 0, 0)
            love.graphics.draw(NightState.assets.fanAnim["fan_" .. self.deskFan.fid], 0, 0)

            if collision.rectRect(self.AnimatronicControllers["bonnie"], self.tabletCameraSubState.areas["office"]) then
                love.graphics.draw(NightState.assets["in_office_bonnie"], 0, 0)
            end
            if collision.rectRect(self.AnimatronicControllers["chica"], self.tabletCameraSubState.areas["office"]) then
                love.graphics.draw(NightState.assets["in_office_chica"], 0, 0)
            end

            if not self.officeState.isOfficeDisabled then
                if not self.officeState.doors.canUseDoorL then
                    love.graphics.draw(NightState.assets.doorButtons.left[love.timer.getTime() % 1 > 0.5 and "not_ok" or "off"], 0, 0)
                else
                    love.graphics.draw(NightState.assets.doorButtons.left[self.officeState.doors.left and "on" or "off"], 0, 0)
                end
    
                if not self.officeState.doors.canUseDoorR then
                    love.graphics.draw(NightState.assets.doorButtons.right[love.timer.getTime() % 1 > 0.5 and "not_ok" or "off"], 0, 0)
                else
                    love.graphics.draw(NightState.assets.doorButtons.right[self.officeState.doors.right and "on" or "off"], 0, 0)
                end
            end
        end)
    self.gameCam:detach()

    -- phone shit --
    self.cnv_phone:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        if self.phoneController.visible and self.phoneController.frame == 1 then
            local btn_refuse = NightState.assets["phone_refuse"]
            local btn_accept = NightState.assets["phone_accept"]
            love.graphics.draw(NightState.assets["phone_bg"], 1010, 375, 0, 200 / NightState.assets["phone_bg"]:getWidth(), 236 / NightState.assets["phone_bg"]:getHeight())
            if self.officeState.phoneCallNotRefused then
                love.graphics.draw(btn_refuse, 1090, 540, 0, 48 / btn_refuse:getWidth(), 48 / btn_refuse:getHeight())
            else
                love.graphics.draw(btn_refuse, 1036, 540, 0, 48 / btn_refuse:getWidth(), 48 / btn_refuse:getHeight())
                love.graphics.draw(btn_accept, 1140, 540, 0, 48 / btn_accept:getWidth(), 48 / btn_accept:getHeight())
            end
            love.graphics.printf(languageService["game_misc_call_name"], self.fnt_phoneCallName, 1011, 430, 193, "center")
            if self.officeState.phoneCallNotRefused then
                local tm, ts = convertTime(NightState.assets.calls["call_night" .. NightState.nightID]:tell("seconds"))
                love.graphics.printf(string.format("%02d:%02d", tm, ts), self.fnt_phoneCallFooter, 1011, 470, 193, "center")
            else
                love.graphics.printf(languageService["game_misc_call_incoming"], self.fnt_phoneCallFooter, 1011, 470, 193, "center")
            end
            love.graphics.setColor(0, 0, 0, 1)
                love.graphics.printf(languageService["game_misc_buttons_exit"], self.fnt_phoneCallFooter, 1011, 590, 193, "left")
                love.graphics.printf(languageService["game_misc_buttons_options"], self.fnt_phoneCallFooter, 1011, 590, 193, "right")
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    self.blurVisionFX(function()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setShader(self.shd_perspective)
            love.graphics.draw(self.cnv_mainCanvas, 0, 0)
        love.graphics.setShader()
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.cnv_phone, 0, 0, 0, shove.getViewportWidth() / self.cnv_phone:getWidth(), shove.getViewportHeight() / self.cnv_phone:getHeight())
    
        self.cnv_blurPhone:renderTo(function()
            love.graphics.clear(0, 0, 0, 0)
            self.blurPhoneFX(function()
                love.graphics.draw(self.cnv_phone, 0, 0)
            end)
        end)
        
        self.phoneController:draw()
    
        love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.setBlendMode("add")
                love.graphics.draw(self.cnv_blurPhone, 0, 0, 0, shove.getViewportWidth() / self.cnv_blurPhone:getWidth(), shove.getViewportHeight() / self.cnv_blurPhone:getHeight())
            love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, 1)
    
            -- tablet --
        self.tabletController:draw()
    
        -- mask --
        self.maskController:draw()
    
        -- toxicmeter --
        if self.officeState.maskUp then
            love.graphics.rectangle("line", 16, 48, 256, 32)
    
            love.graphics.print(languageService["game_mask_toxic"], fnt_boldtnr, 16, 24)
    
            love.graphics.setColor(236 / 255, 56 / 255, 41 / 255, 1)
                love.graphics.draw(NightState.assets.grd_toxicmeter, 16 + 3, 48 + 3, 0, math.floor(250 * (self.officeState.toxicmeter / 100)), 26)
            love.graphics.setColor(1, 1, 1, 1)
        end
    
        -- camera render substate --
        if self.tabletController.tabUp then
            self.tabletCameraSubState:draw()
        end
    end)

        -- screen fade --
    love.graphics.setColor(0, 0, 0, self.officeState._f)
        love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    if not self.officeState.isOfficeDisabled then
        if not self.officeState.tabletUp then
            if self.officeState.maskUp then
                love.graphics.setColor(1, 1, 1, 0.3)
            else
                love.graphics.setColor(1, 1, 1, 0.4)
            end
            self.maskBtn:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
        if not self.officeState.maskUp then
            if self.tabletController.tabUp then
                love.graphics.setColor(1, 1, 1, 0.3)
            else
                love.graphics.setColor(1, 1, 1, 0.4)
            end
            self.camBtn:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    if self.officeState.hasAnimatronicInOffice and not self.officeState.officeFlick then
        love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(0, 0, 0, self.officeState.fadealpha)
        love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
    love.graphics.setColor(1, 1, 1, 1)

    -- jumpscare --
    if NightState.killed then
        love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
    self.jumpscareController.draw()

    -- display --
    if self.nightTextDisplay.displayNightText then
        local txt = NightState.nightID <= 7 and languageService["game_night_announce"]:format(NightState.nightID) or languageService["game_custom_night_announce"]
        love.graphics.setColor(1, 1, 1, self.nightTextDisplay.fade)
            love.graphics.print(txt, self.fnt_nightDisplay, shove.getViewportWidth() / 2, shove.getViewportHeight() / 2 - self.fnt_nightDisplay:getHeight() / 2, 0, self.nightTextDisplay.scale, self.nightTextDisplay.scale, self.fnt_nightDisplay:getWidth(txt) / 2, self.fnt_nightDisplay:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    if self.nightEndTextDisplay.displayNightText then
        love.graphics.setColor(1, 1, 1, self.nightEndTextDisplay.fade)
            love.graphics.print(self.nightEndTextDisplay.text, self.fnt_nightDisplay, shove.getViewportWidth() / 2, shove.getViewportHeight() / 2 - self.fnt_nightDisplay:getHeight() / 2, 0, self.nightEndTextDisplay.scale, self.nightEndTextDisplay.scale, self.fnt_nightDisplay:getWidth(nightEndTextDisplay.text) / 2, self.fnt_nightDisplay:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
    self.shakeController:clear()

    -- debug shit --
    if FEATURE_FLAGS.developerMode then
        --love.graphics.print(debug.formattable(officeState), 90, 90)
        --local mx, my = love.mouse.getPosition() --gameCam:mousePosition()
        --love.graphics.print(string.format("%s, %s", mx, my), 90, 90)
        --love.graphics.print(NightState.AnimatronicControllers["puppet"].musicBoxTimer, 20, 20)
        --love.graphics.print(debug.formattable(NightState.animatronicsAI), 10, 10)
        local inside, mx, my = shove.mouseToViewport()
        mx, my = self.gameCam:worldCoords(mx, my, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
        
        if registers.showDebugHitbox then
            love.graphics.setColor(0.54, 0.3, 0.67, 0.4)
                love.graphics.rectangle("fill", self.phoneController.hitbox.x, self.phoneController.hitbox.y, self.phoneController.hitbox.w, self.phoneController.hitbox.h)
            love.graphics.setColor(1, 1, 1, 1)

            self.gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
                love.graphics.setColor(0.7, 0, 1, 0.4)
                    love.graphics.rectangle("fill", mx, my, 32, 32)
                love.graphics.setColor(1, 1, 1, 1)
            
                for k, h in pairs(self.officeState.doors.hitboxes) do
                    love.graphics.setColor(0, 1, 0.5, 0.4)
                        love.graphics.rectangle("fill", h.x, h.y, h.w, h.h)
                    love.graphics.setColor(1, 1, 1, 1)
                end

            self.gameCam:detach()

            love.graphics.setColor(0.3, 1, 1, 0.4)
                love.graphics.rectangle("fill", self.camBtn.x, self.camBtn.y, self.camBtn.w, self.camBtn.h)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setColor(1, 0.2, 0.6, 0.4)
                love.graphics.rectangle("fill", self.maskBtn.x, self.maskBtn.y, self.maskBtn.w, self.maskBtn.h)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function NightState:update(elapsed)
    local inside, mx, my = shove.mouseToViewport()  -- get the mouse --
    local vmx, vmy = mx, my
    -- convert mouse position from screen to viewport and than the viewport to the world --
    mx, my = self.gameCam:worldCoords(mx, my, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    if self.officeState._op then
        if self.officeState.fadealpha <= 1 then
            self.officeState.fadealpha = self.officeState.fadealpha + 0.4 * elapsed
        end
    else
        if self.officeState.fadealpha >= 0 then
            self.officeState.fadealpha = self.officeState.fadealpha - 0.4 * elapsed
        end
    end

            -- phone shit --
    self.phoneController:update(elapsed)

    -- set the volume of the sources if you have the tablet up --
    for i = 1, 3, 1 do
        AudioSources["metalwalk" .. i]:setVolume(self.officeState.tabletUp and 0.08 or 0.5)
    end
    AudioSources["vent_walk"]:setVolume(self.officeState.tabletUp and 0.3 or 0.67)

    -- hud buttons --
    -- camera --
    if not self.officeState.isOfficeDisabled then
        if collision.pointRect({ x = vmx, y = vmy }, self.camBtn) then
            if not self.officeState.maskUp then
                if not self.camBtn.isHover then
                    self.camBtn.isHover = true
                    if not self.tabletController.animationRunning then
                        if AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:isPlaying() then
                            AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:seek(0)
                        end
                        AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:play()
        
                        if not self.officeState.tabletUp then
                            AudioSources["amb_cam"]:play()
                        else
                            AudioSources["amb_cam"]:pause()
                        end
        
                        self.officeState.tabletUp = not self.officeState.tabletUp
                        self.tabletController:setState(self.officeState.tabletUp)
                    end
                end
            end
        else
            self.camBtn.isHover = false
        end
    end

    -- mask --
    if self.maskController.acc >= self.maskController.timeout and not self.officeState.isOfficeDisabled then
        if collision.pointRect({x = vmx, y = vmy}, self.maskBtn) then
            if not self.officeState.tabletUp then
                if not self.maskBtn.isHover then
                    self.maskBtn.isHover = true
                    self.maskController.acc = 0
                    if not self.maskBtn.animationRunning then
                        if AudioSources["mask_off"]:isPlaying() then
                            AudioSources["mask_off"]:seek(0)
                        end
                        AudioSources["mask_breath"]:setLooping(true)
                        AudioSources["mask_off"]:play()
        
                        if not self.officeState.maskUp then
                            AudioSources["mask_breath"]:play()
                        else
                            AudioSources["mask_breath"]:stop()
                        end
        
                        self.officeState.maskUp = not self.officeState.maskUp
                        self.maskController:setState(self.officeState.maskUp)
                    end
                end
            end
        else
            self.maskBtn.isHover = false
        end
    else
        self.maskController.acc = self.maskController.acc + elapsed
    end

    if self.officeState.maskUp then
        self.officeState.toxicmeter = self.officeState.toxicmeter - 12 * elapsed

        if self.officeState.toxicmeter <= 0 then
            self.officeState.toxicmeter = 0

            -- dead --
            NightState.KilledBy = "oxygen"
            gamestate.switch(DeathState)
        end
    else
        self.officeState.toxicmeter = self.officeState.toxicmeter + 15 * elapsed

        if self.officeState.toxicmeter >= 100 then
            self.officeState.toxicmeter = 100
        end
    end

    local s = mapToRange(self.officeState.toxicmeter, 0, 100, 1) / 10
    self.officeState._f = mapToRange(self.officeState.toxicmeter, 0, 100, 1) / 100
    self.blurVisionFX.boxblur.radius = { s, s }
    if self.officeState.toxicmeter >= 100 then
        self.blurVisionFX.disable("boxblur")
    else
        self.blurVisionFX.enable("boxblur")
    end

    -- animatronic --
    if self.officeState.nightRun and not NightState.killed then
        for k, v in pairs(NightState.AnimatronicControllers) do
            if not self.officeState.isOfficeDisabled and not NightState.nightPassed then
                v.update(elapsed)
            else
                if k == "freddy" then
                    v.update(elapsed)
                end
            end
        end
    end

    -- animatronic in office --
    if self.officeState.hasAnimatronicInOffice then
        self.officeState._t = self.officeState._t + elapsed
        if self.officeState._t >= 0.05 then
            self.officeState.officeFlick = not self.officeState.officeFlick
            self.officeState._t = 0
        end
    end

    -- fan animation --
    if not self.officeState.isOfficeDisabled then
        self.deskFan.acc = self.deskFan.acc + elapsed
        if self.deskFan.acc >= self.deskFan.speed then
            self.deskFan.acc = 0
            self.deskFan.fid = self.deskFan.fid + 1
            if self.deskFan.fid >= NightState.assets["fanAnim"].frameCount then
                self.deskFan.fid = 1
            end
        end
    else
        self.deskFan.fid = 1
    end

    -- night progression --
    -- for now I will enable this for testing but it will disable until the call is complete or refused --
    local day = 0
    switch(NightState.nightID, {
        [1] = function()
            day = 7
        end,
        [2] = function()
            day = 8
        end,
        [3] = function()
            day = 9
        end,
        [4] = function()
            day = 10
        end,
        [5] = function()
            day = 11
        end,
        [6] = function()
            day = 12
        end,
        ["default"] = function()
            day = 13
        end
    })
    
    if self.officeState.nightRun and not NightState.nightPassed then
        self.night.time = self.night.time + elapsed
    end

    self.night.h, self.night.m, self.night.s, self.night.period = formatAdjustedTimeAMPM(self.night.time, 72, self.night.startingHour, self.night.startingMinute, self.night.startingPeriod)
    self.night.text = string.format("%02d/11/2005 - %02d:%02d:%s", day, self.night.h, self.night.m, self.night.period:lower())

    if self.night.time >= 300 then
        -- night end
        self.officeState.isOfficeDisabled = true
        NightState.nightPassed = true
    end

    -- office front flashlight --
    self.officeState.flashlight.state = false
    -- keyboard --
    self.officeState.flashlight.state = Controller:down("game_flashlight") and not self.officeState.maskUp and not self.officeState.tabletUp and not self.officeState.isOfficeDisabled
    -- mouse --
    if love.mouse.isDown(1) then
        for k, h in pairs(self.officeState.doors.hitboxes) do
            if not self.officeState.maskUp and not self.officeState.tabletUp and not self.officeState.isOfficeDisabled then
                if k == "center" then
                    if collision.pointRect({x = mx, y = my}, h) then
                        self.officeState.flashlight.state = true
                    end
                end
            end
        end
    end
    

    if self.officeState.flashlight.state then
        AudioSources["buzzlight"]:setLooping(true)
        AudioSources["buzzlight"]:play()
        for k, v in pairs(NightState.AnimatronicControllers) do
            if v.stared ~= nil and not v.stared then
                v.stared = true
                if not AudioSources["window_stare"]:isPlaying() then
                    AudioSources["window_stare"]:play()
                end
            end
        end
    else
        AudioSources["buzzlight"]:setLooping(false)
        AudioSources["buzzlight"]:stop()
    end

    self.shakeController:update(elapsed)

    -- loigic --
    if self.officeState.flashlight.state then
        self.officeState.flashlight.isFlicking = not (love.timer.getTime() % math.random(2, 5) > 0.6)
    end

    -- door animation controllers --
    self.doorL:update(elapsed)
    self.doorR:update(elapsed)

    self.doorLFX:update(elapsed)
    self.doorRFX:update(elapsed)

    -- door timer --
    if self.officeState.doors.left and self.officeState.doors.canUseDoorL then
        self.officeState.doors.lDoorTimer = self.officeState.doors.lDoorTimer - self.officeState.doors.doorUsageBoost * elapsed
        if self.officeState.doors.lDoorTimer <= 0 then
            self.officeState.doors.left = false
            if AudioSources["door_open"]:isPlaying() then
                AudioSources["door_open"]:seek(0)
            end
            
            AudioSources["door_open"]:play()
            self.doorL:setState(false)
            self.officeState.doors.canUseDoorL = false
            self.officeState.doors.lDoorTimer = 0
            self.doorLFX:start()
            self.doorLFX:emit(154)
        end
    elseif not self.officeState.doors.left or not self.officeState.doors.canUseDoorL then
        self.officeState.doors.lDoorTimer = self.officeState.doors.lDoorTimer + self.officeState.doors.doorReloadBoost * elapsed
        if self.officeState.doors.lDoorTimer >= self.officeState.doors.maxDoorTime then
            self.officeState.doors.lDoorTimer = self.officeState.doors.maxDoorTime
        end
    end

    if not self.officeState.doors.canUseDoorL and self.officeState.doors.lDoorTimer >= self.officeState.doors.maxDoorTime then
        self.officeState.doors.canUseDoorL = true
    end

    if self.officeState.doors.right and self.officeState.doors.canUseDoorR then
        self.officeState.doors.rDoorTimer = self.officeState.doors.rDoorTimer - self.officeState.doors.doorUsageBoost * elapsed
        if self.officeState.doors.rDoorTimer <= 0 then
            self.officeState.doors.right = false
            if AudioSources["door_open"]:isPlaying() then
                AudioSources["door_open"]:seek(0)
            end

            AudioSources["door_open"]:play()
            self.doorR:setState(false)
            self.officeState.doors.canUseDoorR = false
            self.officeState.doors.rDoorTimer = 0
            self.doorRFX:start()
            self.doorRFX:emit(154)
        end
    elseif not self.officeState.doors.right or not self.officeState.doors.canUseDoorR then
        self.officeState.doors.rDoorTimer = self.officeState.doors.rDoorTimer + self.officeState.doors.doorReloadBoost * elapsed
        if self.officeState.doors.rDoorTimer >= self.officeState.doors.maxDoorTime then
            self.officeState.doors.rDoorTimer = self.officeState.doors.maxDoorTime
        end
    end

    if not self.officeState.doors.canUseDoorR and self.officeState.doors.rDoorTimer >= self.officeState.doors.maxDoorTime then
        self.officeState.doors.canUseDoorR = true
    end

    -- vent seal --
    if not self.officeState.isOfficeDisabled then
        if self.officeState.vent.requestClose then
            self.officeState.vent.timerAcc = self.officeState.vent.timerAcc + elapsed
            if not AudioSources["exec_reverb"]:isPlaying() then
                AudioSources["exec_reverb"]:play()
            end
            if self.officeState.vent.timerAcc >= self.officeState.vent.ventMaxTimer then
                if not AudioSources["done_reverb"]:isPlaying() then
                    AudioSources["done_reverb"]:seek(0)
                end
                AudioSources["done_reverb"]:play()

                if self.officeState.vent.direction == "left" then
                    self.officeState.vent["left"] = not self.officeState.vent["left"]
                    if self.officeState.vent["right"] then
                        self.officeState.vent["right"] = false
                    end
                elseif self.officeState.vent.direction == "right" then
                    self.officeState.vent["right"] = not self.officeState.vent["right"]
                    if self.officeState.vent["left"] then
                        self.officeState.vent["left"] = false
                    end
                end

                --officeState.vent[officeState.vent.direction] = not officeState.vent[officeState.vent.direction]
                self.officeState.vent.timerAcc = 0
                self.officeState.vent.requestClose = false
            end
        end
    end

    self.officeState.power.powerQueueCount.leftVent = self.officeState.vent["left"]
    self.officeState.power.powerQueueCount.rightVent = self.officeState.vent["right"]

    -- camera update substate --
    if self.tabletController.tabUp then
        self.tabletCameraSubState:update(elapsed)
    end

    -- tablet animation controller --
    self.tabletController:update(elapsed)

    -- mask animation --
    self.maskController:update(elapsed)

    -- jumpscare --
    self.jumpscareController.update(elapsed)

    local mouseMove = 0

    if inside then
        mouseMove = self.roomSize.width * 0.5 + ((mx - self.roomSize.width * 0.5) / self.gameCam.factorX)
        self.gameCam.x = mouseMove
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

    self.tmr_nightStartPhone:update(elapsed)

    if self.nightTextDisplay.displayNightText and not self.nightTextDisplay.invert then
        if not AudioSources["bells"]:isPlaying() then
            AudioSources["bells"]:play()
        end
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

    if self.nightEndTextDisplay.displayNightText and not nightEndTextDisplay.invert then
        self.nightEndTextDisplay.acc = nightEndTextDisplay.acc + elapsed
        if self.nightEndTextDisplay.acc >= 0.1 then
            self.nightEndTextDisplay.acc = 0
            self.nightEndTextDisplay.fade = nightEndTextDisplay.fade + 8.5 * elapsed
            self.nightEndTextDisplay.scale = nightEndTextDisplay.scale + 0.4 * elapsed
    
            if self.nightEndTextDisplay.fade >= 1.4 then
                self.nightEndTextDisplay.invert = true
            end
        end
    elseif self.nightEndTextDisplay.displayNightText and self.nightEndTextDisplay.invert then
        self.nightEndTextDisplay.acc = self.nightEndTextDisplay.acc + elapsed
        if self.nightEndTextDisplay.acc >= 0.3 then
            self.nightEndTextDisplay.acc = 0
            self.nightEndTextDisplay.fade = self.nightEndTextDisplay.fade - 3.2 * elapsed
            self.nightEndTextDisplay.scale = self.nightEndTextDisplay.scale + 0.2 * elapsed
    
            if self.nightEndTextDisplay.fade <= 0 then
                self.nightEndTextDisplay.displayNightText = false
            end
        end
    end

    if self.officeState.isOfficeDisabled and NightState.nightPassed then
        self.tmr_nightEnd:update(elapsed)
    end

    if self.officeState.isOfficeDisabled and not self.officeState._d then
        AudioSources["office_disable"]:play()

        if self.officeState.tabletUp then
            if AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:isPlaying() then
                AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:seek(0)
            end
            AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:play()
            self.officeState.tabletUp = false
            self.tabletController:setState(false)
        end
        if self.officeState.maskUp then
            if AudioSources["mask_off"]:isPlaying() then
                AudioSources["mask_off"]:seek(0)
            end
            AudioSources["mask_off"]:play()
            self.officeState.maskUp = false
            self.maskController:setState(false)
        end
        if self.officeState.doors.left then
            if AudioSources["door_open"]:isPlaying() then
                AudioSources["door_open"]:seek(0)
            end
            AudioSources["door_open"]:play()
            self.officeState.doors.left = false
            self.doorL:setState(false)
        end
        if self.officeState.doors.right then
            if AudioSources["door_open"]:isPlaying() then
                AudioSources["door_open"]:seek(0)
            end
            
            AudioSources["door_open"]:play()
            self.officeState.doors.right = false
            self.doorR:setState(false)
        end
        
        self.officeState._d = true
    end

    if self.officeState.power.powerStat <= 2 and not self.officeState.isOfficeDisabled then
        self.officeState._t = self.officeState._t + elapsed
        if self.officeState._t >= self.officeState._fc then
            self.officeState.power.officeFlick = not self.officeState.power.officeFlick
            self.officeState._fc = self.officeState._fc - 0.005
            self.officeState._t = 0
        end
    end

    -- office power control --
    self.officeState.power.powerQueue = getPowerQueueCount(self)
    if self.officeState.nightRun and not self.officeState.isOfficeDisabled then
        self.officeState.power.timeracc = self.officeState.power.timeracc + elapsed
        if self.officeState.power.timeracc >= 2.5 then
            self.officeState.power.powerStat = self.officeState.power.powerStat - self.officeState.power.powerQueue
            self.officeState.power.timeracc = 0
        end

        self.officeState.power.powerQueueCount.tablet = self.officeState.tabletUp
        if self.officeState.tabletUp then
            self.officeState.power.powerQueueCount.flashlight = self.officeState.lightCam.state
        else
            self.officeState.power.powerQueueCount.flashlight = self.officeState.flashlight.state
        end
        self.officeState.power.powerQueueCount.doorL = self.officeState.doors.left
        self.officeState.power.powerQueueCount.doorR = self.officeState.doors.right
    end

    if self.officeState.power.powerStat <= 0 then
        self.officeState.isOfficeDisabled = true
    end

    self.officeState.power.powerDisplay = math.floor(self.officeState.power.powerStat / 10)


    -- this part is for more controls stuff --

    -- door shit --
    if not self.officeState.isOfficeDisabled then
        for k, h in pairs(self.officeState.doors.hitboxes) do
            if not self.officeState.maskUp and not self.officeState.tabletUp then
                if Controller:pressed("game_close_door_right") then
                    if k == "left" and self.officeState.doors.canUseDoorL then
                        if not self.doorL.animationRunning then
                            if AudioSources[self.officeState.doors.left and "door_open" or "door_close"]:isPlaying() then
                                AudioSources[self.officeState.doors.left and "door_open" or "door_close"]:seek(0)
                            end
                            AudioSources[self.officeState.doors.left and "door_open" or "door_close"]:play()
                            self.officeState.doors.left = not self.officeState.doors.left
                            self.doorL:setState(self.officeState.doors.left)
                        end
                    end
                end
                if Controller:pressed("game_close_door_left") then
                    if k == "right" and self.officeState.doors.canUseDoorR then
                        if not self.doorR.animationRunning then
                            if AudioSources[self.officeState.doors.right and "door_open" or "door_close"]:isPlaying() then
                                AudioSources[self.officeState.doors.right and "door_open" or "door_close"]:seek(0)
                            end
                            AudioSources[self.officeState.doors.right and "door_open" or "door_close"]:play()
                            self.officeState.doors.right = not self.officeState.doors.right
                            self.doorR:setState(self.officeState.doors.right)
                        end
                    end
                end
            end
        end
    end

    if not self.officeState.isOfficeDisabled then
        if Controller:pressed("game_tablet") then
            if not self.officeState.maskUp then
                if not self.tabletController.animationRunning then
                    if AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:isPlaying() then
                        AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:seek(0)
                    end
                    AudioSources[self.officeState.tabletUp and "tab_close" or "tab_up"]:play()
    
                    if not self.officeState.tabletUp then
                        AudioSources["amb_cam"]:play()
                    else
                        AudioSources["amb_cam"]:pause()
                    end
    
                    self.officeState.tabletUp = not self.officeState.tabletUp
                    self.tabletController:setState(self.officeState.tabletUp)
                end
            end
        end
    end

    if Controller:pressed("game_mask") then
        if not self.officeState.tabletUp then
            self.maskBtn.isHover = true
            self.maskController.acc = 0
            if not self.maskBtn.animationRunning then
                if AudioSources["mask_off"]:isPlaying() then
                    AudioSources["mask_off"]:seek(0)
                end
                AudioSources["mask_breath"]:setLooping(true)
                AudioSources["mask_off"]:play()

                if not self.officeState.maskUp then
                    AudioSources["mask_breath"]:play()
                else
                    AudioSources["mask_breath"]:stop()
                end

                self.officeState.maskUp = not self.officeState.maskUp
                self.maskController:setState(self.officeState.maskUp)
            end
        end
    end

    -- need adapter
    --if self.tabletController.tabUp then
    --    --self.tabletCameraSubState:keypressed(key)
    --end
end

function NightState:mousepressed(x, y, button)
    local inside, vmx, vmy = shove.mouseToViewport()  -- get the mouse --
    -- convert mouse position from screen to viewport and than the viewport to the world --
    mx, my = self.gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    -- camera substate --
    if self.tabletController.tabUp then
        self.tabletCameraSubState:mousepressed(x, y, button)
    end

    -- door buttons --officeState.maskUp
    if button == 1 then
        if not self.officeState.isOfficeDisabled then
            for k, h in pairs(self.officeState.doors.hitboxes) do
                if not self.officeState.maskUp and not self.officeState.tabletUp then
                    if k == "left" and self.officeState.doors.canUseDoorL then
                        if collision.pointRect({x = mx, y = my}, h) then
                            if not self.doorL.animationRunning then
                                if AudioSources[self.officeState.doors.left and "door_open" or "door_close"]:isPlaying() then
                                    AudioSources[self.officeState.doors.left and "door_open" or "door_close"]:seek(0)
                                end
                                AudioSources[self.officeState.doors.left and "door_open" or "door_close"]:play()
                                self.officeState.doors.left = not self.officeState.doors.left
                                self.doorL:setState(self.officeState.doors.left)
                            end
                        end
                    end
                    if k == "right" and self.officeState.doors.canUseDoorR then
                        if collision.pointRect({x = mx, y = my}, h) then
                            if not self.doorR.animationRunning then
                                if AudioSources[self.officeState.doors.right and "door_open" or "door_close"]:isPlaying() then
                                    AudioSources[self.officeState.doors.right and "door_open" or "door_close"]:seek(0)
                                end
                                AudioSources[self.officeState.doors.right and "door_open" or "door_close"]:play()
                                self.officeState.doors.right = not self.officeState.doors.right
                                self.doorR:setState(self.officeState.doors.right)
                            end
                        end
                    end
                end
            end
    
            if self.phoneController.visible and self.officeState.phoneCallNotRefused and not self.nightTextDisplay.displayNightText then
                if collision.pointRect({x = vmx, y = vmy}, self.phoneController.hitbox) then
                    NightState.assets.calls["call_night" .. NightState.nightID]:seek(NightState.assets.calls["call_night" .. NightState.nightID]:getDuration("seconds") - 1)
                    AudioSources["sfx_callend"]:play()
                    self.phoneController:setState(false)
                    AudioSources["phone_pickup"]:play()
                    self.nightTextDisplay.displayNightText = true
                    --subtitlesController.clear()
                    self.officeState.phoneCall = false
                end
            end
        end
    end
end

function NightState:leave()
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

return NightState