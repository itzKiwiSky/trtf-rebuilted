NightState = {}

NightState.isCustomNight = false
NightState.animatronicsAI = {
    freddy = 0,
    bonnie = 0,
    chica = 0,
    foxy = 0,
    sugar = 0,
    kitty = 0,
}

NightState.assets = {}

-- I had to change the name of the local variables bc the compiler is bitching about it :( --
local function loadingScreen(clean)
    clean = clean or false
    local ctrEffect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    local glowTextEffect = moonshine(moonshine.effects.glow)
    local textLoadingFont = fontcache.getFont("ocrx", 34)
    local preloadBannerAgain = love.graphics.newImage("assets/images/game/banner.png")
    local clockIcon = love.graphics.newImage("assets/images/game/clockico.png")

    love.graphics.clear(love.graphics.getBackgroundColor())
        ctrEffect(function()
            love.graphics.draw(preloadBannerAgain, 0, 0, 0, love.graphics.getWidth() / preloadBannerAgain:getWidth(), love.graphics.getHeight() / preloadBannerAgain:getHeight())
        end)
        love.graphics.draw(clockIcon, love.graphics.getWidth() - 69, love.graphics.getHeight() - 69, 0, 64 / clockIcon:getWidth(), 64 / clockIcon:getHeight())
        glowTextEffect(function()
            love.graphics.printf("Loading...", textLoadingFont, 0, love.graphics.getHeight() - (textLoadingFont:getHeight() + 16), love.graphics.getWidth(), "center")
        end)
    love.graphics.present()

    if clean then
        ctrEffect = nil
        glowTextEffect = nil
        textLoadingFont:release()
        preloadBannerAgain:release()
        clockIcon:release()
        collectgarbage("collect")
    end
end

function NightState:init()
    loadingScreen()

    -- scripts --
    doorController = require 'src.Components.Modules.Game.DoorController'
    tabletController = require 'src.Components.Modules.Game.TabletController'
    buttonsUI = require 'src.Components.Modules.Game.Utils.ButtonUI'
    tabletCameraSubState = require 'src.SubStates.TabletCameraSubState'
    maskController = require 'src.Components.Modules.Game.MaskController'

    -- office --
    NightState.assets.office = {
        ["idle"] = love.graphics.newImage("assets/images/game/night/office/idle.png"),
        ["off"] = love.graphics.newImage("assets/images/game/night/office/off.png")
    }
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
    NightState.assets["camBtnUI"] = {}
    NightState.assets["camBtnUI"].image, NightState.assets["camBtnUI"].quads = love.graphics.getQuads("assets/images/game/night/cameraUI/btnIcon")
    NightState.assets["camMap"] = love.graphics.newImage("assets/images/game/night/cameraUI/cam_map.png")
    NightState.assets["camSystemLogo"] = love.graphics.newImage("assets/images/game/night/cameraUI/system_logo.png")
    NightState.assets["camBtnText"] = {}
    NightState.assets["camBtnText"].image, NightState.assets["camBtnText"].quads = love.graphics.getQuads("assets/images/game/night/cameraUI/camText")
    loadingScreen()

    -- game ui stuff --
    NightState.assets["maskButton"] = love.graphics.newImage("assets/images/game/night/gameUI/mask_hover.png")
    NightState.assets["camButton"] = love.graphics.newImage("assets/images/game/night/gameUI/cam_hover.png")
    loadingScreen()

    NightState.assets.grd_progressBar = love.graphics.newGradient("vertical", {49, 10, 92, 255}, {19, 0, 37, 255})

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

    AudioSources["amb_cam"]:setVolume(0.50)
    AudioSources["amb_cam"]:setLooping(true)

    AudioSources["tab_up"]:setVolume(0.70)
    AudioSources["tab_close"]:setVolume(0.70)

    AudioSources["door_open"]:setVolume(0.36)
    AudioSources["door_close"]:setVolume(0.36)

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
        tabletFirstBoot = false,
        phoneCall = false,
        power = 100,
        tabletUp = false,
        maskUp = false,
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

    -- camera render substate --
    if tabletController.tabUp then
        tabletCameraSubState:draw()
    end

    -- ui stuff --
    if not officeState.tabletUp then
        maskBtn:draw()
    end
    if  not officeState.maskUp then
        camBtn:draw()
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
        if not camBtn.isHover then
            camBtn.isHover = true
            if not tabletController.animationRunning then
                if AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:isPlaying() then
                    AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:seek(0)
                end
                AudioSources[officeState.tabletUp and "tab_close" or "tab_up"]:play()

                if officeState.tabletUp then
                    AudioSources["amb_cam"]:play()
                else
                    AudioSources["amb_cam"]:pause()
                end

                officeState.tabletUp = not officeState.tabletUp
                tabletController:setState(officeState.tabletUp)
            end
        end
    else
        camBtn.isHover = false
    end

    -- mask --
    if collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, maskBtn) then
        if not maskBtn.isHover then
            maskBtn.isHover = true
            if not tabletController.animationRunning then
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
    else
        maskBtn.isHover = false
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
    -- door buttons --
    if button == 1 then
        for k, h in pairs(officeState.doors.hitboxes) do
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

return NightState