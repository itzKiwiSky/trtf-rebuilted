NightState = {}

NightState.nightID = 1
NightState.isCustomNight = false
NightState.animatronicsAI = {
    freddy = 0,
    bonnie = 0,
    chica = 0,
    foxy = 0,
    sugar = 0,
    kitty = 0,
}

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
    local loadingScreen = require 'src.Components.Modules.Game.Utils.LoadingPresent'
    loadingScreen()

    -- scripts --
    doorController = require 'src.Components.Modules.Game.DoorController'
    tabletController = require 'src.Components.Modules.Game.TabletController'
    buttonsUI = require 'src.Components.Modules.Game.Utils.ButtonUI'
    tabletCameraSubState = require 'src.SubStates.TabletCameraSubState'
    maskController = require 'src.Components.Modules.Game.MaskController'

    fnt_vhs = fontcache.getFont("vcr", 25)
    fnt_camfnt = fontcache.getFont("vcr", 16)
    fnt_timerfnt = fontcache.getFont("vcr", 22)
    fnt_camError = fontcache.getFont("vcr", 30)
    fnt_camName = fontcache.getFont("vcr", 42)
    fnt_boldtnr = fontcache.getFont("tnr_bold", 20)

    -- office --
    NightState.assets.office = {
        ["idle"] = love.graphics.newImage("assets/images/game/night/office/idle.png"),
        ["off"] = love.graphics.newImage("assets/images/game/night/office/off.png")
    }
    loadingScreen()
    -- front office --
    NightState.assets["front_office"] = {
        ["idle"] = love.graphics.newImage("assets/images/game/night/front_office/Empty.png"),
        ["foxy1"] = love.graphics.newImage("assets/images/game/night/front_office/Foxy.png"),
        ["foxy2"] = love.graphics.newImage("assets/images/game/night/front_office/Foxy2.png"),
        ["foxy3"] = love.graphics.newImage("assets/images/game/night/front_office/Foxy3.png"),
        ["foxy4"] = love.graphics.newImage("assets/images/game/night/front_office/Foxy4.png"),
    }
    loadingScreen()
    NightState.assets["front_office_bonnie"] = love.graphics.newImage("assets/images/game/night/front_office/Bonnie.png")
    NightState.assets["front_office_chica"] = love.graphics.newImage("assets/images/game/night/front_office/Chica.png")
    loadingScreen()

    -- door buttons --
    NightState.assets.doorButtons = {
        left = {
            ["on"] = love.graphics.newImage("assets/images/game/night/doors/bl_on.png"),
            ["off"] = love.graphics.newImage("assets/images/game/night/doors/bl_off.png")
        },
        right = {
            ["on"] = love.graphics.newImage("assets/images/game/night/doors/br_on.png"),
            ["off"] = love.graphics.newImage("assets/images/game/night/doors/br_off.png")
        }
    }
    loadingScreen()

    -- doors --
    NightState.assets.doorsAnim = {
        left = {},
        right = {},
    }
    loadingScreen()

    
    local dl = love.filesystem.getDirectoryItems("assets/images/game/night/doors/door_left")
    for a = 1, #dl, 1 do
        table.insert(NightState.assets.doorsAnim.left, love.graphics.newImage("assets/images/game/night/doors/door_left/" .. dl[a]))
    end
    loadingScreen()

    local dr = love.filesystem.getDirectoryItems("assets/images/game/night/doors/door_right")
    for a = 1, #dl, 1 do
        table.insert(NightState.assets.doorsAnim.right, love.graphics.newImage("assets/images/game/night/doors/door_right/" .. dr[a]))
    end
    loadingScreen()
    dl, dr = nil, nil

    -- tablet --
    NightState.assets["maskAnim"] = {}
    local mask = love.filesystem.getDirectoryItems("assets/images/game/night/mask")
    for m = 1, #mask, 1 do
        table.insert(NightState.assets["maskAnim"], love.graphics.newImage("assets/images/game/night/mask/" .. mask[m]))
    end
    loadingScreen()
    mask = nil

    -- mask --
    NightState.assets["tablet"] = {}
    local tab = love.filesystem.getDirectoryItems("assets/images/game/night/tablet")
    for t = 1, #tab, 1 do
        table.insert(NightState.assets["tablet"], love.graphics.newImage("assets/images/game/night/tablet/" .. tab[t]))
    end
    loadingScreen()
    tab = nil

    -- cam ui stuff --
    NightState.assets["camMap"] = love.graphics.newImage("assets/images/game/night/cameraUI/cam_map.png")
    NightState.assets["camSystemLogo"] = love.graphics.newImage("assets/images/game/night/cameraUI/system_logo.png")
    NightState.assets["camSystemError"] = love.graphics.newImage("assets/images/game/night/cameraUI/camera_error.png")
    loadingScreen()

    -- cameras itself --
    NightState.assets["cameras"] = {}
    local cams = fsutil.scanFolder("assets/images/game/night/cameras", true)
    --print(debug.formattable(cameras))
    for _, c in ipairs(cams) do
        local isFolder = love.filesystem.getInfo(c).type == "directory"
        local folderName = c:match("[^/]+$")
        if isFolder then

            NightState.assets["cameras"][folderName] = {}
            local fls = love.filesystem.getDirectoryItems(c)
            for f = 1, #fls, 1 do
                table.insert(NightState.assets["cameras"][folderName], love.graphics.newImage(c .. "/" .. fls[f]))
            end
            fls = nil
        end
    end

    --print(debug.formattable(NightState.assets["cameras"]))

    loadingScreen()

    -- game ui stuff --
    NightState.assets["maskButton"] = love.graphics.newImage("assets/images/game/night/gameUI/mask_hover.png")
    NightState.assets["camButton"] = love.graphics.newImage("assets/images/game/night/gameUI/cam_hover.png")
    loadingScreen()

    NightState.assets["staticfx"] = {}
    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static3")
    for s = 1, #statics, 1 do
        table.insert(NightState.assets["staticfx"], love.graphics.newImage("assets/images/game/effects/static3/" .. statics[s]))
    end
    statics = {}
    loadingScreen()

    NightState.assets.grd_progressBar = love.graphics.newGradient("vertical", {31, 225, 34, 255}, {20, 100, 28, 255})
    NightState.assets.grd_toxicmeter = love.graphics.newGradient("vertical", {255, 255, 255, 255}, {0, 0, 0, 255})

    -- phone shit --
    local phone = love.filesystem.getDirectoryItems("assets/images/game/night/phone/anim")
    NightState.assets["phoneModel"] = {}
    for p = 1, #phone, 1 do
        table.insert(NightState.assets["phoneModel"], love.graphics.newImage("assets/images/game/night/phone/anim/" .. phone[p]))
    end
    phone = nil
    loadingScreen()


    loadingScreen(true)
    shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    shd_perspective:send("latitudeVar", 22.5)
    shd_perspective:send("longitudeVar", 45)
    shd_perspective:send("fovVar", 0.263000)

    cnv_mainCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.clear(love.graphics.getBackgroundColor())
end

function NightState:enter()
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

    -- static shit --
    staticfx = {
        timer = 0,
        frameid = 1,
        speed = 0.05
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

    tabletController:init(NightState.assets.tablet, 34)
    tabletController.visible = false

    maskController:init(NightState.assets.maskAnim, 34)
    maskController.visible = false
    maskController.timeout = 0.2
    maskController.acc = 0

    maskBtn = buttonsUI.new(NightState.assets.maskButton, 96, (love.graphics.getHeight() - NightState.assets.maskButton:getHeight()) - 24)
    camBtn = buttonsUI.new(NightState.assets.camButton, (love.graphics.getWidth() - NightState.assets.camButton:getWidth()) - 96, (love.graphics.getHeight() - NightState.assets.camButton:getHeight()) - 24)

    X_LEFT_FRAME = gameCam.x
    X_RIGHT_FRAME = gameCam.x + roomSize.width
    Y_TOP_FRAME = gameCam.y
    Y_BOTTOM_FRAME = gameCam.y + roomSize.height

    doorL = doorController.new(NightState.assets.doorsAnim.left, 55, false)
    doorR = doorController.new(NightState.assets.doorsAnim.right, 55, false)

    officeState = {
        fadealpha = 1,
        tabletFirstBoot = true,
        tabletBootProgress = 0,
        tabletBootProgressAlpha = 1,
        phoneCall = false,
        power = 100,
        tabletUp = false,
        maskUp = false,
        flashlight = {
            state = false,
            flickAcc = 0,
            flickInterval = 0,
            flickDuration = 0.1,
            isFlicking = false,
        },
        toxicmeter = 0,
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
    tmr_nightStartPhone:after(3, function()
        
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
                if officeState.flashlight.state then
                    if not officeState.flashlight.isFlicking then
                        love.graphics.draw(NightState.assets.front_office.idle, 0, 0)
                    end
                end
                love.graphics.draw(NightState.assets.office[officeState.power > 0 and "idle" or "off"], 0, 0)
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

        love.graphics.print("Toxic", fnt_boldtnr, 16, 24)

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
        maskBtn:draw()
    end
    if  not officeState.maskUp then
        if tabletController.tabUp then
            love.graphics.setColor(1, 1, 1, 0.4)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        camBtn:draw()
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(0, 0, 0, officeState.fadealpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

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

function NightState:update(elapsed)
    local mx, my = gameCam:mousePosition()

    if officeState.fadealpha > 0 then
        officeState.fadealpha = officeState.fadealpha - 0.6 * elapsed
    end

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
    night.h, night.m, night.s, night.period = _formatAdjustedTimeAMPM(night.time, 1.333, night.startingHour, night.startingMinute, night.startingPeriod)
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

return NightState