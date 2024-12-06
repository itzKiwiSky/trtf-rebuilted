DebugState = {}

--[[
THIS IS NOT A PLAYABLE MenuState

This state is only there to test things up before implement in a official playable MenuState
like so
]]--

function DebugState:enter()
    dbginterface = require 'src.Components.Modules.Game.Interface.DebugInterface'
    tex = love.graphics.newImage("assets/images/game/noname.png")

    shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    tuneConfig = {
        latitudeVar = 22.5,
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
        width = 1600,
        height = 800,
        compensation = 400,
    }

    gameCam = camera.new(0, nil)
    gameCam.factorX = 4.85
    gameCam.factorY = 25

    X_LEFT_FRAME = gameCam.x
    X_RIGHT_FRAME = gameCam.x + roomSize.width
    Y_TOP_FRAME = gameCam.y
    Y_BOTTOM_FRAME = gameCam.y + roomSize.height

    cnv_mainCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    cnv_distcanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.clear(love.graphics.getBackgroundColor())

    subtitlesController.clear()
    subtitlesController.queue(languageRaw.subtitles["call_night" .. NightState.nightID])
end

function DebugState:draw()
    gameCam:attach()
        cnv_mainCanvas:renderTo(function()
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.draw(tex, 0, 0)
        end)
    gameCam:detach()


    love.graphics.setShader(shd_perspective)
        love.graphics.draw(cnv_mainCanvas, 0, 0)
    love.graphics.setShader()


    slab.Draw()
end

function DebugState:update(elapsed)
    slab.Update(elapsed)
    dbginterface()
    
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