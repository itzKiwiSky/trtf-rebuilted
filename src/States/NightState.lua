NightState = {}

NightState.KilledBy = ""
NightState.killed = false
NightState.nightID = 1000
NightState.isCustomNight = false
NightState.animatronicsAI = {
    freddy = 20,
    bonnie = 0,
    chica = 0,
    foxy = 0,
    sugar = 0,
    kitty = 0,
    puppet = 0,
}
NightState.AnimatronicControllers = {}

local mod = {
    radarMode = false,
}
NightState.modifiers = {
    radarMode = true,      -- can be use to debug or just for cheat (I know why u will use it your mf)
}

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

local function _formatAdjustedTimeAMPM(realSeconds, scaleFactor, startHour, startMinute, startPeriod)
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

local function getPowerQueueCount()
    local c = 1
    for k, v in pairs(officeState.power.powerQueueCount) do
        if v == true then
            c = c + 1
        end
    end
    return c
end

-----------------------------------------------

NightState.assets = {}

-- I had to change the name of the local variables bc the compiler is bitching about it :( --
function NightState:enter()
    doorParticle = require 'src.Components.Modules.Game.Utils.ParticleDoor'

    for k, v in pairs(AudioSources) do
        v:stop()
    end

    -- radar --
    NightState.assets["radar_icons"] = {}
    NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads = love.graphics.getQuads("assets/images/game/night/cameraUI/radar_animatronics")
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

    blurFX = moonshine(moonshine.effects.gaussianblur)
    blurFX.gaussianblur.sigma = 5

    blurVisionFX = moonshine(moonshine.effects.boxblur)
    blurVisionFX.boxblur.radius = {0, 0}

    fnt_vhs = fontcache.getFont("vcr", 25)
    fnt_camfnt = fontcache.getFont("vcr", 16)
    fnt_timerfnt = fontcache.getFont("vcr", 22)
    fnt_camError = fontcache.getFont("vcr", 30)
    fnt_camName = fontcache.getFont("vcr", 42)
    fnt_boldtnr = fontcache.getFont("tnr_bold", 20)
    fnt_nightDisplay = fontcache.getFont("tnr", 60)

    fnt_phoneCallName = fontcache.getFont("ocrx", 25)
    fnt_phoneCallFooter = fontcache.getFont("ocrx", 18)

    shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    shd_perspective:send("latitudeVar", 22.5)
    shd_perspective:send("longitudeVar", 45)
    shd_perspective:send("fovVar", 0.2630)

    cnv_mainCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    cnv_phone = love.graphics.newCanvas(love.graphics.getDimensions())
    cnv_blurPhone = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.clear(love.graphics.getBackgroundColor())

-----------------------------------------------

    NightState.KilledBy = ""
    NightState.killed = false

    love.mouse.setVisible(true)
    -- scripts --
    doorController = require 'src.Components.Modules.Game.DoorController'
    tabletController = require 'src.Components.Modules.Game.TabletController'
    buttonsUI = require 'src.Components.Modules.Game.Utils.ButtonUI'
    tabletCameraSubState = require 'src.SubStates.TabletCameraSubState'
    maskController = require 'src.Components.Modules.Game.MaskController'
    phoneController = require 'src.Components.Modules.Game.PhoneController'
    ShakeController = require 'src.Components.Modules.Game.Utils.ShakeController'
    jumpscareController = require 'src.Components.Modules.Game.JumpscareController'

    -- import AI --
    local aif = love.filesystem.getDirectoryItems("src/Components/Modules/Game/Animatronics")
    for a = 1, #aif, 1 do
        local filename = aif[a]:gsub("%.[^.]+$", "")
        NightState.AnimatronicControllers[filename:lower()] = require("src.Components.Modules.Game.Animatronics." .. filename)
    end
    aif = nil

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

    AudioSources["crank_machine"]:setVolume(0.4)

    -- config for AI --
    local aicgf = require 'src.Components.Modules.Game.Utils.AIConfig'

    if aicgf[NightState.nightID] then
        NightState.animatronicsAI = aicgf[NightState.nightID]
    end

    -- static shit --
    staticfx = {
        timer = 0,
        frameid = 1,
        speed = 0.05
    }

    fanShit = {
        acc = 0,
        fid = 1,
        speed = 1 / 35
    }

    night = {
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
    nightTextDisplay = {
        text = string.format("Night %s", NightState.nightID),
        fade = 0,
        scale = 1,
        acc = 0,
        displayNightText = false,
        invert = false
    }

    -- room --
    roomSize = {
        windowWidth = love.graphics.getWidth(),
        windowHeight = love.graphics.getHeight(),
        width = 2000,
        height = 800,
        compensation = 400,
    }

    tabletCameraSubState:load()

    gameCam = camera.new(0, nil)
    gameCam.factorX = 2.46
    gameCam.factorY = 25

    phoneController:init(NightState.assets.phoneModel, 45, "ph")
    phoneController.visible = false
    phoneController.hitbox = {
        x = 1036, 
        y = 540, 
        w = 48, 
        h = 48
    }

    tabletController:init(NightState.assets.tablet, 34, "tab_")
    tabletController.visible = false

    maskController:init(NightState.assets.maskAnim, 34, "mask_")
    maskController.visible = false
    maskController.timeout = 0.2
    maskController.acc = 0

    maskBtn = buttonsUI.new(NightState.assets.maskButton, 96, (love.graphics.getHeight() - NightState.assets.maskButton:getHeight()) - 24)
    camBtn = buttonsUI.new(NightState.assets.camButton, (love.graphics.getWidth() - NightState.assets.camButton:getWidth()) - 96, (love.graphics.getHeight() - NightState.assets.camButton:getHeight()) - 24)

    X_LEFT_FRAME = gameCam.x
    X_RIGHT_FRAME = gameCam.x + roomSize.width
    Y_TOP_FRAME = gameCam.y
    Y_BOTTOM_FRAME = gameCam.y + roomSize.height

    doorL = doorController.new(NightState.assets.doorsAnim.left, 55, false, "dl_")
    doorR = doorController.new(NightState.assets.doorsAnim.right, 55, false, "dr_")

    doorLFX = doorParticle()
    doorRFX = doorParticle()

    officeState = {
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
        toxicmeter = 100,
        hasAnimatronicInOffice = false,
        officeFlick = false,
        isOfficeDisabled = false,
        doors = {
            maxDoorTime = 25,
            doorReloadBoost = 3,
            doorUsageBoost = 5,
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
                    x = roomSize.width / 2 - 256,
                    y = 220,
                    w = 512,
                    h = 360,
                },
            }
        }
    }

    officeState.doors.lDoorTimer = officeState.doors.maxDoorTime
    officeState.doors.rDoorTimer = officeState.doors.maxDoorTime

    tmr_nightStartPhone = timer.new()

    tmr_nightStartPhone:script(function(sleep)
        if NightState.nightID >= 1 and NightState.nightID <= 5 then
            sleep(3)
                phoneController:setState(true)
                AudioSources["phone_pickup"]:play()
            sleep(0.2)
                NightState.assets.calls["call_night" .. NightState.nightID]:play()
                subtitlesController.clear()
                subtitlesController.queue(languageRaw.subtitles["call_night" .. NightState.nightID])
            sleep(6)
                officeState.phoneCallNotRefused = true
                officeState.phoneCall = true
                phoneController.hitbox.x = 1090
            sleep(NightState.assets.calls["call_night" .. NightState.nightID]:getDuration("seconds") - 6)
                phoneController:setState(false)
                AudioSources["phone_pickup"]:play()
                nightTextDisplay.displayNightText = true
                subtitlesController.clear()
                officeState.phoneCall = false
        elseif NightState.nightID >= 6 then
            sleep(3)
                nightTextDisplay.displayNightText = true
                officeState.phoneCall = false
        end
    end)

    for k, v in pairs(NightState.AnimatronicControllers) do
        if v.init then v.init() end
    end
end

function NightState:draw()
    local mx, my = gameCam:mousePosition()
    gameCam:attach()
        -- canvas to render the game content and apply the shader --
        cnv_mainCanvas:renderTo(function()
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.draw(doorLFX, 1700, 178)
            love.graphics.draw(doorRFX, 140, 178)
            if officeState.isOfficeDisabled then
                if NightState.AnimatronicControllers["freddy"].currentState == 5 then
                    if NightState.AnimatronicControllers["freddy"].animState then
                        love.graphics.draw(NightState.assets["door_freddy_attack"], 0, 0)
                    else
                        love.graphics.draw(NightState.assets["door_freddy_idle"], 0, 0)
                    end
                end
            end
            doorL:draw()
            doorR:draw()
            -- flicking front XD --
            if officeState.flashlight.state then
                if not officeState.flashlight.isFlicking then
                    love.graphics.draw(NightState.assets.front_office.idle, 0, 0)
                    if collision.rectRect(NightState.AnimatronicControllers["bonnie"], tabletCameraSubState.areas["front_office"]) then
                        love.graphics.draw(NightState.assets["front_office_bonnie"], 0, 0)
                    end
                    if collision.rectRect(NightState.AnimatronicControllers["chica"], tabletCameraSubState.areas["front_office"]) then
                        love.graphics.draw(NightState.assets["front_office_chica"], 0, 0)
                    end
                end
            end
            love.graphics.draw(NightState.assets.office[officeState.isOfficeDisabled and "off" or "idle"], 0, 0)
            love.graphics.draw(NightState.assets.fanAnim["fan_" .. fanShit.fid], 0, 0)

            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], tabletCameraSubState.areas["office"]) then
                love.graphics.draw(NightState.assets["in_office_bonnie"], 0, 0)
            end
            if collision.rectRect(NightState.AnimatronicControllers["chica"], tabletCameraSubState.areas["office"]) then
                love.graphics.draw(NightState.assets["in_office_chica"], 0, 0)
            end

            if not officeState.isOfficeDisabled then
                if not officeState.doors.canUseDoorL then
                    love.graphics.draw(NightState.assets.doorButtons.left[love.timer.getTime() % 1 > 0.5 and "not_ok" or "off"], 0, 0)
                else
                    love.graphics.draw(NightState.assets.doorButtons.left[officeState.doors.left and "on" or "off"], 0, 0)
                end
    
                if not officeState.doors.canUseDoorR then
                    love.graphics.draw(NightState.assets.doorButtons.right[love.timer.getTime() % 1 > 0.5 and "not_ok" or "off"], 0, 0)
                else
                    love.graphics.draw(NightState.assets.doorButtons.right[officeState.doors.right and "on" or "off"], 0, 0)
                end
            end
        end)
    gameCam:detach()

    -- phone shit --
    cnv_phone:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        if phoneController.visible and phoneController.frame == 1 then
            local btn_refuse = NightState.assets["phone_refuse"]
            local btn_accept = NightState.assets["phone_accept"]
            love.graphics.draw(NightState.assets["phone_bg"], 1010, 375, 0, 200 / NightState.assets["phone_bg"]:getWidth(), 236 / NightState.assets["phone_bg"]:getHeight())
            if officeState.phoneCallNotRefused then
                love.graphics.draw(btn_refuse, 1090, 540, 0, 48 / btn_refuse:getWidth(), 48 / btn_refuse:getHeight())
            else
                love.graphics.draw(btn_refuse, 1036, 540, 0, 48 / btn_refuse:getWidth(), 48 / btn_refuse:getHeight())
                love.graphics.draw(btn_accept, 1140, 540, 0, 48 / btn_accept:getWidth(), 48 / btn_accept:getHeight())
            end
            love.graphics.printf(languageService["game_misc_call_name"], fnt_phoneCallName, 1011, 430, 193, "center")
            if officeState.phoneCallNotRefused then
                local tm, ts = convertTime(NightState.assets.calls["call_night" .. NightState.nightID]:tell("seconds"), -6)
                love.graphics.printf(string.format("%02d:%02d", tm, ts), fnt_phoneCallFooter, 1011, 470, 193, "center")
            else
                love.graphics.printf(languageService["game_misc_call_incoming"], fnt_phoneCallFooter, 1011, 470, 193, "center")
            end
            love.graphics.setColor(0, 0, 0, 1)
                love.graphics.printf(languageService["game_misc_buttons_exit"], fnt_phoneCallFooter, 1011, 590, 193, "left")
                love.graphics.printf(languageService["game_misc_buttons_options"], fnt_phoneCallFooter, 1011, 590, 193, "right")
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    blurVisionFX(function()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setShader(shd_perspective)
            love.graphics.draw(cnv_mainCanvas, 0, 0)
        love.graphics.setShader()
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(cnv_phone, 0, 0)
    
        cnv_blurPhone:renderTo(function()
            love.graphics.clear(0, 0, 0, 0)
            blurFX(function()
                love.graphics.draw(cnv_phone, 0, 0)
            end)
        end)
        
        phoneController:draw()
    
        love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.setBlendMode("add")
                love.graphics.draw(cnv_blurPhone, 0, 0)
            love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, 1)
    
            -- tablet --
        tabletController:draw()
    
        -- mask --
        maskController:draw()
    
        -- toxicmeter --
        if officeState.maskUp then
            love.graphics.rectangle("line", 16, 48, 256, 32)
    
            love.graphics.print(languageService["game_mask_toxic"], fnt_boldtnr, 16, 24)
    
            love.graphics.setColor(236 / 255, 56 / 255, 41 / 255, 1)
                love.graphics.draw(NightState.assets.grd_toxicmeter, 16 + 3, 48 + 3, 0, math.floor(250 * (officeState.toxicmeter / 100)), 26)
            love.graphics.setColor(1, 1, 1, 1)
        end
    
        -- camera render substate --
        if tabletController.tabUp then
            tabletCameraSubState:draw()
        end
    end)

    love.graphics.setColor(0, 0, 0, officeState._f)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

        -- ui stuff --
    if not officeState.isOfficeDisabled then
        if not officeState.tabletUp then
            if officeState.maskUp then
                love.graphics.setColor(1, 1, 1, 0.3)
            else
                love.graphics.setColor(1, 1, 1, 0.4)
            end
            maskBtn:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
        if not officeState.maskUp then
            if tabletController.tabUp then
                love.graphics.setColor(1, 1, 1, 0.3)
            else
                love.graphics.setColor(1, 1, 1, 0.4)
            end
            camBtn:draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    if officeState.hasAnimatronicInOffice or officeState.power.officeFlick and not officeState.officeFlick then
        love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(0, 0, 0, officeState.fadealpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    -- jumpscare --
    if NightState.killed then
        love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
    jumpscareController:draw()

    -- display --
    if nightTextDisplay.displayNightText then
        local txt = NightState.nightID <= 7 and languageService["game_night_announce"]:format(NightState.nightID) or languageService["game_custom_night_announce"]
        love.graphics.setColor(1, 1, 1, nightTextDisplay.fade)
            love.graphics.print(txt, fnt_nightDisplay, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - fnt_nightDisplay:getHeight() / 2, 0, nightTextDisplay.scale, nightTextDisplay.scale, fnt_nightDisplay:getWidth(txt) / 2, fnt_nightDisplay:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- debug shit --
    if DEBUG_APP then
        --love.graphics.print(debug.formattable(officeState), 90, 90)
        --local mx, my = love.mouse.getPosition() --gameCam:mousePosition()
        --love.graphics.print(string.format("%s, %s", mx, my), 90, 90)
        love.graphics.print(NightState.AnimatronicControllers["freddy"].patience, 20, 20)
        if registers.system.showDebugHitbox then
            gameCam:attach()
                love.graphics.setColor(0.7, 0, 1, 0.4)
                    love.graphics.rectangle("fill", mx, my, 32, 32)
                love.graphics.setColor(1, 1, 1, 1)
            
                for k, h in pairs(officeState.doors.hitboxes) do
                    love.graphics.setColor(0, 1, 0.5, 0.4)
                        love.graphics.rectangle("fill", h.x, h.y, h.w, h.h)
                    love.graphics.setColor(1, 1, 1, 1)
                end

            gameCam:detach()

            love.graphics.setColor(1, 1, 0.6, 0.4)
                love.graphics.rectangle("fill", phoneController.hitbox.x, phoneController.hitbox.y, phoneController.hitbox.w, phoneController.hitbox.h)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setColor(0.3, 1, 1, 0.4)
                love.graphics.rectangle("fill", camBtn.x, camBtn.y, camBtn.w, camBtn.h)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setColor(1, 0.2, 0.6, 0.4)
                love.graphics.rectangle("fill", maskBtn.x, maskBtn.y, maskBtn.w, maskBtn.h)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function NightState:update(elapsed)
    if love.filesystem.isFused() then
        if NightState.nightID <= 7 then
            for k, v in pairs(mod) do
                NightState.modifiers[k] = v
            end
        end
    end

    local mx, my = gameCam:mousePosition()

    if officeState.fadealpha >= 0 then
        officeState.fadealpha = officeState.fadealpha - 0.4 * elapsed
    end
        -- phone shit --
    phoneController:update(elapsed)

    for i = 1, 3, 1 do
        AudioSources["metalwalk" .. i]:setVolume(officeState.tabletUp and 0.08 or 0.5)
    end
    AudioSources["vent_walk"]:setVolume(officeState.tabletUp and 0.3 or 0.67)

    -- hud buttons --
    -- camera --
    if not officeState.isOfficeDisabled then
        if collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, camBtn) then
            if not officeState.maskUp then
                if not camBtn.isHover then
                    camBtn.isHover = true
                    if not tabletController.animationRunning then
                        if AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:isPlaying() then
                            AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:seek(0)
                        end
                        AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:play()
        
                        if not officeState.tabletUp then
                            AudioSources["amb_cam"]:play()
                        else
                            AudioSources["amb_cam"]:pause()
                        end
        
                        officeState.tabletUp = not officeState.tabletUp
                        tabletController:setState(officeState.tabletUp)
                    end
                end
            end
        else
            camBtn.isHover = false
        end
    end

    -- mask --
    if maskController.acc >= maskController.timeout and not officeState.isOfficeDisabled then
        if collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, maskBtn) then
            if not officeState.tabletUp then
                if not maskBtn.isHover then
                    maskBtn.isHover = true
                    maskController.acc = 0
                    if not maskBtn.animationRunning then
                        if AudioSources["mask_off"]:isPlaying() then
                            AudioSources["mask_off"]:seek(0)
                        end
                        AudioSources["mask_breath"]:setLooping(true)
                        AudioSources["mask_off"]:play()
        
                        if not officeState.maskUp then
                            AudioSources["mask_breath"]:play()
                        else
                            AudioSources["mask_breath"]:stop()
                        end
        
                        officeState.maskUp = not officeState.maskUp
                        maskController:setState(officeState.maskUp)
                    end
                end
            end
        else
            maskBtn.isHover = false
        end
    else
        maskController.acc = maskController.acc + elapsed
    end

    if officeState.maskUp then
        officeState.toxicmeter = officeState.toxicmeter - 12 * elapsed

        if officeState.toxicmeter <= 0 then
            officeState.toxicmeter = 0

            -- dead --
            NightState.KilledBy = "oxygen"
            gamestate.switch(DeathState)
        end
    else
        officeState.toxicmeter = officeState.toxicmeter + 15 * elapsed

        if officeState.toxicmeter >= 100 then
            officeState.toxicmeter = 100
        end
    end

    local s = mapToRange(officeState.toxicmeter, 0, 100, 1) / 10
    officeState._f = mapToRange(officeState.toxicmeter, 0, 100, 1) / 100
    blurVisionFX.boxblur.radius = {s, s}
    if officeState.toxicmeter >= 100 then
        blurVisionFX.disable("boxblur")
    else
        blurVisionFX.enable("boxblur")
    end

    -- animatronic --
    if officeState.nightRun then
        for k, v in pairs(NightState.AnimatronicControllers) do
            if not officeState.isOfficeDisabled then
                v.update(elapsed)
            else
                if k == "freddy" then
                    v.update(elapsed)
                end
            end
        end
    end

    -- animatronic in office --
    if officeState.hasAnimatronicInOffice then
        officeState._t = officeState._t + elapsed
        if officeState._t >= 0.02 then
            officeState.officeFlick = not officeState.officeFlick
            officeState._t = 0
        end
    end

    -- fan animation --
    if not officeState.isOfficeDisabled then
        fanShit.acc = fanShit.acc + elapsed
        if fanShit.acc >= fanShit.speed then
            fanShit.acc = 0
            fanShit.fid = fanShit.fid + 1
            if fanShit.fid >= NightState.assets["fanAnim"].frameCount then
                fanShit.fid = 1
            end
        end
    else
        fanShit.fid = 1
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
    
    if officeState.nightRun then
        night.time = night.time + elapsed
    end

    night.h, night.m, night.s, night.period = _formatAdjustedTimeAMPM(night.time, 1.2, night.startingHour, night.startingMinute, night.startingPeriod)
    night.text = string.format("%02d/11/2005 - %02d:%02d:%02d%s", day, night.h, night.m, night.s, night.period:lower())

    -- office front flashlight --
    officeState.flashlight.state = false
    -- keyboard --
    officeState.flashlight.state = love.keyboard.isDown("lctrl") and not officeState.maskUp and not officeState.tabletUp and not officeState.isOfficeDisabled
    -- mouse --
    if love.mouse.isDown(1) then
        for k, h in pairs(officeState.doors.hitboxes) do
            if not officeState.maskUp and not officeState.tabletUp and not officeState.isOfficeDisabled then
                if k == "center" then
                    if collision.pointRect({x = mx, y = my}, h) then
                        officeState.flashlight.state = true
                    end
                end
            end
        end
    end
    

    if officeState.flashlight.state then
        AudioSources["buzzlight"]:setLooping(true)
        AudioSources["buzzlight"]:play()
        for k, v in pairs(NightState.AnimatronicControllers) do
            if v.stared then
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

    -- loigic --
    if officeState.flashlight.state then
        officeState.flashlight.isFlicking = not (love.timer.getTime() % math.random(2, 5) > 0.6)
    end

    -- door animation controllers --
    doorL:update(elapsed)
    doorR:update(elapsed)

    doorLFX:update(elapsed)
    doorRFX:update(elapsed)

    -- door timer --
    if officeState.doors.left and officeState.doors.canUseDoorL then
        officeState.doors.lDoorTimer = officeState.doors.lDoorTimer - officeState.doors.doorUsageBoost * elapsed
        if officeState.doors.lDoorTimer <= 0 then
            officeState.doors.left = false
            doorL:setState(false)
            officeState.doors.canUseDoorL = false
            officeState.doors.lDoorTimer = 0
            doorLFX:start()
            doorLFX:emit(154)
        end
    elseif not officeState.doors.left or not officeState.doors.canUseDoorL then
        officeState.doors.lDoorTimer = officeState.doors.lDoorTimer + officeState.doors.doorReloadBoost * elapsed
        if officeState.doors.lDoorTimer >= officeState.doors.maxDoorTime then
            officeState.doors.lDoorTimer = officeState.doors.maxDoorTime
        end
    end

    if not officeState.doors.canUseDoorL and officeState.doors.lDoorTimer >= officeState.doors.maxDoorTime then
        officeState.doors.canUseDoorL = true
    end

    if officeState.doors.right and officeState.doors.canUseDoorR then
        officeState.doors.rDoorTimer = officeState.doors.rDoorTimer - officeState.doors.doorUsageBoost * elapsed
        if officeState.doors.rDoorTimer <= 0 then
            officeState.doors.right = false
            doorR:setState(false)
            officeState.doors.canUseDoorR = false
            officeState.doors.rDoorTimer = 0
            doorRFX:start()
            doorRFX:emit(154)
        end
    elseif not officeState.doors.right or not officeState.doors.canUseDoorR then
        officeState.doors.rDoorTimer = officeState.doors.rDoorTimer + officeState.doors.doorReloadBoost * elapsed
        if officeState.doors.rDoorTimer >= officeState.doors.maxDoorTime then
            officeState.doors.rDoorTimer = officeState.doors.maxDoorTime
        end
    end

    if not officeState.doors.canUseDoorR and officeState.doors.rDoorTimer >= officeState.doors.maxDoorTime then
        officeState.doors.canUseDoorR = true
    end

    -- tablet animation controller --
    tabletController:update(elapsed)

    -- mask animation --
    maskController:update(elapsed)

    -- jumpscare --
    jumpscareController:update(elapsed)

    -- camera update substate --
    if tabletController.tabUp then
        tabletCameraSubState:update(elapsed)
    end

    -- cam scroll --
    if not tabletController.tabUp then
        gameCam.x = (roomSize.width / 2 + (mx - roomSize.width / 2) / gameCam.factorX)
    end

    -- camera bounds --
    if gameCam.x < X_LEFT_FRAME then
        gameCam.x = X_LEFT_FRAME
    end

    if gameCam.y < Y_TOP_FRAME then
        gameCam.y = Y_TOP_FRAME
    end

    if gameCam.x > X_RIGHT_FRAME then
        gameCam.x = X_RIGHT_FRAME
    end

    if gameCam.y > Y_BOTTOM_FRAME then
        gameCam.y = Y_BOTTOM_FRAME
    end

    tmr_nightStartPhone:update(elapsed)

    if nightTextDisplay.displayNightText and not nightTextDisplay.invert then
        if not AudioSources["bells"]:isPlaying() then
            AudioSources["bells"]:play()
        end
        nightTextDisplay.acc = nightTextDisplay.acc + elapsed
        if nightTextDisplay.acc >= 0.1 then
            nightTextDisplay.acc = 0
            nightTextDisplay.fade = nightTextDisplay.fade + 8.5 * elapsed
            nightTextDisplay.scale = nightTextDisplay.scale + 0.4 * elapsed

            if nightTextDisplay.fade >= 1.4 then
                nightTextDisplay.invert = true
            end
        end
    elseif nightTextDisplay.displayNightText and nightTextDisplay.invert then
        officeState.nightRun = true
        nightTextDisplay.acc = nightTextDisplay.acc + elapsed
        if nightTextDisplay.acc >= 0.1 then
            nightTextDisplay.acc = 0
            nightTextDisplay.fade = nightTextDisplay.fade - 7.2 * elapsed
            nightTextDisplay.scale = nightTextDisplay.scale + 0.2 * elapsed

            if nightTextDisplay.fade <= 0 then
                nightTextDisplay.displayNightText = false
            end
        end
    end

    if officeState.isOfficeDisabled and not officeState._d then
        AudioSources["office_disable"]:play()

        if officeState.tabletUp then
            if AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:isPlaying() then
                AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:seek(0)
            end
            AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:play()
            tabletController:setState(true)
            officeState.tabletUp = false
        end
        if officeState.maskUp then
            if AudioSources["mask_off"]:isPlaying() then
                AudioSources["mask_off"]:seek(0)
            end
            AudioSources["mask_off"]:play()
            officeState.maskUp = false
            maskController:setState(false)
        end
        if officeState.doors.left then
            if AudioSources["door_open"]:isPlaying() then
                AudioSources["door_open"]:seek(0)
            end
            AudioSources["door_open"]:play()
            officeState.doors.left = false
            doorL:setState(false)
        end
        if officeState.doors.right then
            if AudioSources["door_open"]:isPlaying() then
                AudioSources["door_open"]:seek(0)
            end
            
            AudioSources["door_open"]:play()
            officeState.doors.right = false
            doorR:setState(false)
        end
        
        officeState._d = true
    end

    if officeState.power.powerStat <= 2 and not officeState.isOfficeDisabled then
        officeState._t = officeState._t + elapsed
        if officeState._t >= officeState._fc then
            officeState.power.officeFlick = not officeState.power.officeFlick
            officeState._fc = officeState._fc - 0.005
            officeState._t = 0
        end
    end

    -- office power control --
    officeState.power.powerQueue = getPowerQueueCount()
    if officeState.nightRun and not officeState.isOfficeDisabled then
        officeState.power.timeracc = officeState.power.timeracc + elapsed
        if officeState.power.timeracc >= 1.5 then
            officeState.power.powerStat = officeState.power.powerStat - officeState.power.powerQueue
            officeState.power.timeracc = 0
        end

        officeState.power.powerQueueCount.tablet = officeState.tabletUp
        if officeState.tabletUp then
            officeState.power.powerQueueCount.flashlight = officeState.lightCam.state
        else
            officeState.power.powerQueueCount.flashlight = officeState.flashlight.state
        end
        officeState.power.powerQueueCount.doorL = officeState.doors.left
        officeState.power.powerQueueCount.doorR = officeState.doors.right
    end

    if officeState.power.powerStat <= 0 then
        officeState.isOfficeDisabled = true
    end

    officeState.power.powerDisplay = math.floor(officeState.power.powerStat / 10)
end

function NightState:mousepressed(x, y, button)
    local mx, my = gameCam:mousePosition()

    -- camera substate --
    if tabletController.tabUp then
        tabletCameraSubState:mousepressed(x, y, button)
    end

    -- door buttons --officeState.maskUp
    if button == 1 then
        if not officeState.isOfficeDisabled then
            for k, h in pairs(officeState.doors.hitboxes) do
                if not officeState.maskUp and not officeState.tabletUp then
                    if k == "left" and officeState.doors.canUseDoorL then
                        if collision.pointRect({x = mx, y = my}, h) then
                            if not doorL.animationRunning then
                                if AudioSources[officeState.doors.left and "door_open" or "door_close"]:isPlaying() then
                                    AudioSources[officeState.doors.left and "door_open" or "door_close"]:seek(0)
                                end
                                AudioSources[officeState.doors.left and "door_open" or "door_close"]:play()
                                officeState.doors.left = not officeState.doors.left
                                doorL:setState(officeState.doors.left)
                            end
                        end
                    end
                    if k == "right" and officeState.doors.canUseDoorR then
                        if collision.pointRect({x = mx, y = my}, h) then
                            if not doorR.animationRunning then
                                if AudioSources[officeState.doors.right and "door_open" or "door_close"]:isPlaying() then
                                    AudioSources[officeState.doors.right and "door_open" or "door_close"]:seek(0)
                                end
                                AudioSources[officeState.doors.right and "door_open" or "door_close"]:play()
                                officeState.doors.right = not officeState.doors.right
                                doorR:setState(officeState.doors.right)
                            end
                        end
                    end
                end
            end
    
            if phoneController.visible and officeState.phoneCallNotRefused and not nightTextDisplay.displayNightText then
                if collision.pointRect({x = x, y = y}, phoneController.hitbox) then
                    NightState.assets.calls["call_night" .. NightState.nightID]:seek(NightState.assets.calls["call_night" .. NightState.nightID]:getDuration("seconds") - 1)
                    phoneController:setState(false)
                    AudioSources["phone_pickup"]:play()
                    nightTextDisplay.displayNightText = true
                    subtitlesController.clear()
                    officeState.phoneCall = false
                end
            end
        end
    end
end

function NightState:keypressed(key)
    -- door shit --
    if not officeState.isOfficeDisabled then
        for k, h in pairs(officeState.doors.hitboxes) do
            if not officeState.maskUp and not officeState.tabletUp then
                if key == "left" or key == "d" then
                    if k == "left" and officeState.doors.canUseDoorL then
                        if not doorL.animationRunning then
                            if AudioSources[officeState.doors.left and "door_open" or "door_close"]:isPlaying() then
                                AudioSources[officeState.doors.left and "door_open" or "door_close"]:seek(0)
                            end
                            AudioSources[officeState.doors.left and "door_open" or "door_close"]:play()
                            officeState.doors.left = not officeState.doors.left
                            doorL:setState(officeState.doors.left)
                        end
                    end
                end
                if key == "right" or key == "a" then
                        if k == "right" and officeState.doors.canUseDoorR then
                            if not doorR.animationRunning then
                                if AudioSources[officeState.doors.right and "door_open" or "door_close"]:isPlaying() then
                                    AudioSources[officeState.doors.right and "door_open" or "door_close"]:seek(0)
                                end
                                AudioSources[officeState.doors.right and "door_open" or "door_close"]:play()
                                officeState.doors.right = not officeState.doors.right
                                doorR:setState(officeState.doors.right)
                            end
                        end
                end
            end
        end
    end

    if not officeState.isOfficeDisabled then
        if key == "space" or key == "s" or key == "x" then
            if not officeState.maskUp then
                if not tabletController.animationRunning then
                    if AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:isPlaying() then
                        AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:seek(0)
                    end
                    AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:play()
    
                    if not officeState.tabletUp then
                        AudioSources["amb_cam"]:play()
                    else
                        AudioSources["amb_cam"]:pause()
                    end
    
                    officeState.tabletUp = not officeState.tabletUp
                    tabletController:setState(officeState.tabletUp)
                end
            end
        end
    end

    if key == "lalt" or key == "z" or key == "x" then
        if not officeState.tabletUp then
            maskBtn.isHover = true
            maskController.acc = 0
            if not maskBtn.animationRunning then
                if AudioSources["mask_off"]:isPlaying() then
                    AudioSources["mask_off"]:seek(0)
                end
                AudioSources["mask_breath"]:setLooping(true)
                AudioSources["mask_off"]:play()

                if not officeState.maskUp then
                    AudioSources["mask_breath"]:play()
                else
                    AudioSources["mask_breath"]:stop()
                end

                officeState.maskUp = not officeState.maskUp
                maskController:setState(officeState.maskUp)
            end
        end
    end

    if tabletController.tabUp then
        tabletCameraSubState:keypressed(key)
    end

    if DEBUG_APP then
        if love.keyboard.isDown("ralt") and key == "o" then
            officeState.power.powerStat = 2
        end
    end
end

return NightState