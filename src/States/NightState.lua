NightState = {}

NightState.nightID = 100
NightState.isCustomNight = false
NightState.animatronicsAI = {
    freddy = 0,
    bonnie = 20,
    chica = 0,
    foxy = 0,
    sugar = 0,
    kitty = 0,
    puppet = 0,
}
NightState.AnimatronicControllers = {}

NightState.modifiers = {
    radarMode = true,      -- can be use to debug or just for cheat (I know why u will use it your mf)
}

function NightState.playWalk()
    local r = math.random(1, 3)
    if not AudioSources["metalwalk" .. r]:isPlaying() then
        AudioSources["metalwalk" .. r]:play()
    end
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

NightState.assets = {}

-- I had to change the name of the local variables bc the compiler is bitching about it :( --
function NightState:init()
    -- radar --
    NightState.assets["radar_icons"] = {}
    NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads = love.graphics.getQuads("assets/images/game/night/cameraUI/radar_animatronics")
    NightState.assets["radar_icons"].image:setFilter("nearest", "nearest")

    NightState.assets.grd_progressBar = love.graphics.newGradient("vertical", {31, 225, 34, 255}, {20, 100, 28, 255})
    NightState.assets.grd_toxicmeter = love.graphics.newGradient("vertical", {255, 255, 255, 255}, {0, 0, 0, 255})

    fnt_vhs = fontcache.getFont("vcr", 25)
    fnt_camfnt = fontcache.getFont("vcr", 16)
    fnt_timerfnt = fontcache.getFont("vcr", 22)
    fnt_camError = fontcache.getFont("vcr", 30)
    fnt_camName = fontcache.getFont("vcr", 42)
    fnt_boldtnr = fontcache.getFont("tnr_bold", 20)

    shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    shd_perspective:send("latitudeVar", 22.5)
    shd_perspective:send("longitudeVar", 45)
    shd_perspective:send("fovVar", 0.263000)

    cnv_mainCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.clear(love.graphics.getBackgroundColor())
end

function NightState:enter()
    -- scripts --
    doorController = require 'src.Components.Modules.Game.DoorController'
    tabletController = require 'src.Components.Modules.Game.TabletController'
    buttonsUI = require 'src.Components.Modules.Game.Utils.ButtonUI'
    tabletCameraSubState = require 'src.SubStates.TabletCameraSubState'
    maskController = require 'src.Components.Modules.Game.MaskController'
    phoneSubState = require 'src.SubStates.PhoneSubstate'
    -- import AI --
    local aif = love.filesystem.getDirectoryItems("src/Components/Modules/Game/Animatronics")
    for a = 1, #aif, 1 do
        local filename = aif[a]:gsub("%.[^.]+$", "")
        NightState.AnimatronicControllers[filename:lower()] = require("src.Components.Modules.Game.Animatronics." .. filename)
    end
    aif = nil

    -- sound config --
    if not AudioSources["amb_rainleak"]:isPlaying() then
        AudioSources["amb_rainleak"]:play()
        AudioSources["amb_rainleak"]:setLooping(true)
        AudioSources["amb_rainleak"]:setVolume(0.38)

        AudioSources["amb_office_lair"]:play()
        AudioSources["amb_office_lair"]:setLooping(true)
        AudioSources["amb_office_lair"]:setVolume(0.48)
    end

    AudioSources["cam_interference"]:setVolume(0.60)

    AudioSources["amb_cam"]:setVolume(0.50)
    AudioSources["amb_cam"]:setLooping(true)

    AudioSources["tab_up"]:setVolume(0.70)
    AudioSources["tab_close"]:setVolume(0.70)

    AudioSources["door_open"]:setVolume(0.36)
    AudioSources["door_close"]:setVolume(0.36)

    AudioSources["cam_animatronic_interference"]:setVolume(0.7)

    AudioSources["stare"]:setLooping(true)

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
        acc = 0
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

    officeState = {
        _t = 0,
        fadealpha = 1,
        tabletFirstBoot = true,
        tabletBootProgress = 0,
        tabletBootProgressAlpha = 1,
        phoneCall = true,
        power = 100,
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
        toxicmeter = 0,
        hasAnimatronicInOffice = false,
        officeFlick = false,
        doors = {
            left = false,
            right = false,

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


    tmr_nightStartPhone = timer.new()
    tmr_nightStartPhone:after(2.5, function()
        
    end)
end

function NightState:draw()
    local mx, my = gameCam:mousePosition()
    gameCam:attach()
        -- canvas to render the game content and apply the shader --
        cnv_mainCanvas:renderTo(function()
            love.graphics.clear(love.graphics.getBackgroundColor())
                doorL:draw()
                doorR:draw()
                -- flicking front XD --
                if officeState.flashlight.state then
                    if not officeState.flashlight.isFlicking then
                        love.graphics.draw(NightState.assets.front_office.idle, 0, 0)
                        if collision.rectRect(NightState.AnimatronicControllers["bonnie"], tabletCameraSubState.areas["front_office"]) then
                            love.graphics.draw(NightState.assets["front_office_bonnie"], 0, 0)
                        end
                    end
                end
                love.graphics.draw(NightState.assets.office[officeState.power > 0 and "idle" or "off"], 0, 0)
                love.graphics.draw(NightState.assets.fanAnim["fan_" .. fanShit.fid], 0, 0)

                if collision.rectRect(NightState.AnimatronicControllers["bonnie"], tabletCameraSubState.areas["office"]) then
                    love.graphics.draw(NightState.assets["in_office_bonnie"], 0, 0)
                end

                love.graphics.draw(NightState.assets.doorButtons.left[officeState.doors.left and "on" or "off"], 0, 0)
                love.graphics.draw(NightState.assets.doorButtons.right[officeState.doors.right and "on" or "off"], 0, 0)
        end)
    gameCam:detach()
    love.graphics.setShader(shd_perspective)
        love.graphics.draw(cnv_mainCanvas, 0, 0)
    love.graphics.setShader()

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

    -- ui stuff --
    if not officeState.tabletUp then
        if officeState.maskUp then
            love.graphics.setColor(1, 1, 1, 0.3)
        else
            love.graphics.setColor(1, 1, 1, 0.6)
        end
        maskBtn:draw()
        love.graphics.setColor(1, 1, 1, 1)
    end
    if not officeState.maskUp then
        if tabletController.tabUp then
            love.graphics.setColor(1, 1, 1, 0.3)
        else
            love.graphics.setColor(1, 1, 1, 0.6)
        end
        camBtn:draw()
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(0, 0, 0, officeState.fadealpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    if officeState.hasAnimatronicInOffice and not officeState.officeFlick then
        love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- debug shit --
    if DEBUG_APP then
        --love.graphics.print(string.format("mask : %s\n tablet : %s", officeState.maskUp, officeState.tabletUp), 90, 90)
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
    local mx, my = gameCam:mousePosition()

    if officeState.fadealpha > 0 then
        officeState.fadealpha = officeState.fadealpha - 0.4 * elapsed
    end

    for i = 1, 3, 1 do
        AudioSources["metalwalk" .. i]:setVolume(officeState.tabletUp and 0.08 or 0.5)
    end
    AudioSources["vent_walk"]:setVolume(officeState.tabletUp and 0.3 or 0.67)

    -- hud buttons --
    -- camera --
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

    -- mask --
    if maskController.acc >= maskController.timeout then
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
        officeState.toxicmeter = officeState.toxicmeter + 25 * elapsed

        if officeState.toxicmeter >= 100 then
            officeState.toxicmeter = 100
        end
    else
        officeState.toxicmeter = math.lerp(officeState.toxicmeter, 0, 0.07)
    end

    -- animatronic --
    for k, v in pairs(NightState.AnimatronicControllers) do
        v.update(elapsed)
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
    fanShit.acc = fanShit.acc + elapsed
    if fanShit.acc >= fanShit.speed then
        fanShit.acc = 0
        fanShit.fid = fanShit.fid + 1
        if fanShit.fid >= NightState.assets["fanAnim"].frameCount then
            fanShit.fid = 1
        end
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
    night.time = night.time + elapsed
    night.h, night.m, night.s, night.period = _formatAdjustedTimeAMPM(night.time, 1.2, night.startingHour, night.startingMinute, night.startingPeriod)
    night.text = string.format("%02d/11/2005 - %02d:%02d:%02d%s", day, night.h, night.m, night.s, night.period:lower())

    -- office front flashlight --
    officeState.flashlight.state = false
    -- keyboard --
    officeState.flashlight.state = love.keyboard.isDown("lctrl") and not officeState.maskUp and not officeState.tabletUp
    -- mouse --
    if love.mouse.isDown(1) then
        for k, h in pairs(officeState.doors.hitboxes) do
            if not officeState.maskUp and not officeState.tabletUp then
                if k == "center" then
                    if collision.pointRect({x = mx, y = my}, h) then
                        officeState.flashlight.state = true
                    end
                end
            end
        end
    end

    -- loigic --
    if officeState.flashlight.state then
        officeState.flashlight.isFlicking = not (love.timer.getTime() % math.random(2, 5) > 0.6)
    end

    -- door animation controllers --
    doorL:update(elapsed)
    doorR:update(elapsed)

    -- tablet animation controller --
    tabletController:update(elapsed)

    -- mask animation --
    maskController:update(elapsed)

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
end

function NightState:mousepressed(x, y, button)
    local mx, my = gameCam:mousePosition()

    -- camera substate --
    if tabletController.tabUp then
        tabletCameraSubState:mousepressed(x, y, button)
    end

    -- door buttons --officeState.maskUp
    if button == 1 then
        for k, h in pairs(officeState.doors.hitboxes) do
            if not officeState.maskUp and not officeState.tabletUp then
                if k == "left" then
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
                if k == "right" then
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
    end
end

function NightState:keypressed(k)
    if DEBUG_APP then
        if k == "=" then
            for k, v in pairs(NightState.AnimatronicControllers) do
                v.currentState = v.currentState + 1
            end
        end
        if k == "-" then
            for k, v in pairs(NightState.AnimatronicControllers) do
                v.currentState = v.currentState - 1
            end
        end
    end
end

return NightState