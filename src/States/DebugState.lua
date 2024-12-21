DebugState = {}

--[[
THIS IS NOT A PLAYABLE MenuState

This state is only there to test things up before implement in a official playable MenuState
like so
]]--

function DebugState:enter()
    dbginterface = require 'src.Components.Modules.Game.Interface.DebugInterface'
    roomoff = love.graphics.newImage("assets/images/game/test/room_off.png")
    roomlight = love.graphics.newImage("assets/images/game/test/room_light.png")
    flashlight = love.graphics.newImage("assets/images/game/night8/flashlight.png")
    light = love.graphics.newImage("assets/images/game/night8/lantern_light.png")

    shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    tuneConfig = {
        latitudeVar = 26.6,
        longitudeVar = 40,
        fovVar = 0.263000
    }
    shd_perspective:send("latitudeVar", tuneConfig.latitudeVar)
    shd_perspective:send("longitudeVar", tuneConfig.longitudeVar)
    shd_perspective:send("fovVar", tuneConfig.fovVar)

    slab.Initialize({"NoDocks"})

    -- room --
    roomSize = {
        windowWidth = love.graphics.getWidth(),
        windowHeight = love.graphics.getHeight(),
        width = 2000,
        height = 800,
        compensation = 400,
    }

    flash = {
        x = 0,
        y = 0
    }

    gameCam = camera.new(0, nil)
    gameCam.factorX = 2.8
    gameCam.factorY = 25

    X_LEFT_FRAME = gameCam.x
    X_RIGHT_FRAME = gameCam.x + roomSize.width
    Y_TOP_FRAME = gameCam.y
    Y_BOTTOM_FRAME = gameCam.y + roomSize.height

    cnv_mainCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    cnv_invertedRoom = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    cnv_flash = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

    --subtitlesController.clear()
    --subtitlesController.queue(languageRaw.subtitles["call_night" .. NightState.nightID])
    love.graphics.setBackgroundColor(0, 0, 0, 0)
end

function DebugState:draw()
    cnv_mainCanvas:renderTo(function()
        gameCam:attach()
        love.graphics.draw(roomlight, 0, 0)
        gameCam:detach()
    end)

    cnv_flash:renderTo(function()
            gameCam:attach()
                love.graphics.draw(roomoff, 0, 0)
            gameCam:detach()
        love.graphics.draw(flashlight, flash.x, flash.y, 0, 1.2, 1.1, flashlight:getWidth() / 2, flashlight:getHeight() / 2)
    end)

    love.graphics.setShader(shd_perspective)
        love.graphics.draw(cnv_mainCanvas, 0, 0)
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(cnv_flash, 0, 0)
        love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
end

function DebugState:update(elapsed)
    slab.Update(elapsed)
    --dbginterface()

    flash.x, flash.y = love.mouse.getPosition()
    
    shd_perspective:send("latitudeVar", tuneConfig.latitudeVar)
    shd_perspective:send("longitudeVar", tuneConfig.longitudeVar)
    shd_perspective:send("fovVar", tuneConfig.fovVar)

    local mx, my = gameCam:mousePosition()

    if slab.IsVoidHovered() then
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

function DebugState:keypressed(k)

end

function DebugState:wheelmoved(x, y)

end

return DebugState