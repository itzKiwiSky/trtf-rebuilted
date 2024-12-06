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

    flareShader = love.graphics.newShader("assets/shaders/LensFlare.glsl")
    flareShader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
    flareShader:send("light_pos", {128, 128}) -- Posição inicial da luz (em pixels)
    flareShader:send("radius", 200)          -- Raio de influência
    flareShader:send("intensity", 1.0)       -- Intensidade base

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
end

function DebugState:draw()
    gameCam:attach()
        cnv_mainCanvas:renderTo(function()
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.draw(tex, 0, 0)
        end)
    gameCam:detach()

    cnv_distcanvas:renderTo(function()
        love.graphics.setShader(shd_perspective)
            love.graphics.draw(cnv_mainCanvas, 0, 0)
        love.graphics.setShader()
    end)

    love.graphics.setShader(flareShader)
        love.graphics.draw(cnv_distcanvas, 0, 0)
    love.graphics.setShader()

    slab.Draw()
end

function DebugState:update(elapsed)
    slab.Update(elapsed)
    dbginterface()

    local light_pos = {love.mouse.getX(), love.mouse.getY()}
    flareShader:send("light_pos", light_pos)
    
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