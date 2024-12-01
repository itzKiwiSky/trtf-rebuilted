DebugState = {}

--[[
THIS IS NOT A PLAYABLE MenuState

This state is only there to test things up before implement in a official playable MenuState
like so
]]--

function DebugState:enter()
    fxTV = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette).chain(moonshine.effects.pixelate)
    vent = love.graphics.newImage("assets/images/game/night/cameras/showstage/8.png")
    shader = love.graphics.newShader("assets/shaders/Interference.glsl")
    shader:send("intensity", 0.012) -- Intensidade inicial
    shader:send("speed", 80.0)     -- Velocidade inicial

    size = false
    px = 0
    pxsize = 1

    cshader = love.graphics.newShader("assets/shaders/Chromatic.glsl")
    cshader:send("distortion", 0)
    cshader:send("aberration", 0.7)

    staticfx = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }
    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static")
    for s = 1, #statics, 1 do
        table.insert(staticfx.frames, love.graphics.newImage("assets/images/game/effects/static/" .. statics[s]))
    end

    canvas = love.graphics.newCanvas(love.graphics.getDimensions())
    subcanv = love.graphics.newCanvas(love.graphics.getDimensions())
end

function DebugState:draw()
    canvas:renderTo(function()
        love.graphics.setShader(shader)
        love.graphics.draw(vent, 0, 0)
        love.graphics.setShader()
    end)

    subcanv:renderTo(function()
        love.graphics.setShader(cshader)
            love.graphics.draw(canvas, 0, 0)
        love.graphics.setShader()
    end)
    
    -- static overlay --
    fxTV(function()
        love.graphics.draw(subcanv, 0, 0)
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.1)
                love.graphics.draw(staticfx.frames[staticfx.config.frameid], 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")
    end)

    if size then
        love.graphics.print("Size", 90, 90)
    end
end

function DebugState:update(elapsed)
    local time = love.timer.getTime()
    shader:send("time", time) -- Enviar tempo para animar

    -- static animation --
    staticfx.config.timer = staticfx.config.timer + elapsed
    if staticfx.config.timer >= staticfx.config.speed then
        staticfx.config.timer = 0
        staticfx.config.frameid = staticfx.config.frameid + 1
        if staticfx.config.frameid >= #staticfx.frames then
            staticfx.config.frameid = 1
        end
    end

    fxTV.pixelate.feedback = px
    fxTV.pixelate.size = {pxsize, pxsize}
end

function DebugState:keypressed(k)
    if k == "f1" then
        size = not size
    end
end

function DebugState:wheelmoved(x, y)
    if size then
        if y < 0 then
            pxsize = pxsize - 1
        elseif y > 0 then
            pxsize = pxsize + 1
        end
    else
        if y < 0 then
            px = px - 0.01
        elseif y > 0 then
            px = px + 0.01
        end
    end
end

return DebugState