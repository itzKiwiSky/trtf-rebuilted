NightState = {}

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
    doorController = require 'src.Components.Modules.Game.DoorController'

    NightState.assets.office = {
        ["idle"] = love.graphics.newImage("assets/images/game/night/office/idle.png"),
        ["off"] = love.graphics.newImage("assets/images/game/night/office/off.png")
    }
    loadingScreen()

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
    dl, dr = {}, {}

    grd_progressBar = love.graphics.newGradient("vertical", {49, 10, 92, 255}, {19, 0, 37, 255})

    shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    shd_perspective:send("latitudeVar", 22.5)
    shd_perspective:send("longitudeVar", 45)
    shd_perspective:send("fovVar", 0.263000)

    cnv_mainCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.clear(love.graphics.getBackgroundColor())
end

function NightState:enter()
    roomSize = {
        windowWidth = love.graphics.getWidth(),
        windowHeight = love.graphics.getHeight(),
        width = 2000,
        height = 800,
        compensation = 400,
    }

    gameCam = camera.new(0, nil)
    gameCam.factorX = 2.5
    gameCam.factorY = 25

    X_LEFT_FRAME = gameCam.x
    X_RIGHT_FRAME = gameCam.x + roomSize.width
    Y_TOP_FRAME = gameCam.y
    Y_BOTTOM_FRAME = gameCam.y + roomSize.height

    doorL = doorController.new(NightState.assets.doorsAnim.left, 1 / 55, false)
    doorR = doorController.new(NightState.assets.doorsAnim.right, 1 / 55, false)

    officeState = {
        power = 100,
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
end

function NightState:draw()
    local mx, my = gameCam:mousePosition()
    gameCam:attach()
        cnv_mainCanvas:renderTo(function()
            love.graphics.clear(love.graphics.getBackgroundColor())
            --love.graphics.push()
                --love.graphics.translate(0, -(roomSize.windowHeight / 2))
                doorL:draw()
                doorR:draw()
                love.graphics.draw(NightState.assets.office[officeState.power > 0 and "idle" or "off"], 0, 0)
                love.graphics.draw(NightState.assets.doorButtons.left[officeState.doors.left and "on" or "off"], 0, 0)
                love.graphics.draw(NightState.assets.doorButtons.right[officeState.doors.right and "on" or "off"], 0, 0)
            --love.graphics.pop()
        end)
    gameCam:detach()
    love.graphics.setShader(shd_perspective)
        love.graphics.draw(cnv_mainCanvas, 0, 0)
    love.graphics.setShader()

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
end

function NightState:update(elapsed)
    local mx, my = gameCam:mousePosition()

    doorL:update(elapsed)
    doorR:update(elapsed)

    -- cam scroll --
    gameCam.x = (roomSize.width / 2 + (mx - roomSize.width / 2) / gameCam.factorX)

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
    if button == 1 then
        for k, h in pairs(officeState.doors.hitboxes) do
            if k == "left" then
                if collision.pointRect({x = mx, y = my}, h) then
                    if not doorL.animationRunning then
                        officeState.doors.left = not officeState.doors.left
                        doorL:setState(officeState.doors.left)
                    end
                end
            end
            if k == "right" then
                if collision.pointRect({x = mx, y = my}, h) then
                    if not doorL.animationRunning then
                        officeState.doors.right = not officeState.doors.right
                        doorR:setState(officeState.doors.right)
                    end
                end
            end
        end
    end
end

return NightState