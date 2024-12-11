EndDemoState = {}

local function map(t, a, b)
    return (math.sin(t) + 1) * 0.5 * (b - a) + a
end

function EndDemoState:enter()
    endScreen = love.graphics.newImage("assets/images/game/end_of_demo_gay_sex.png")
    cnv_noise = love.graphics.newCanvas(love.graphics.getDimensions())
    shd_noise = love.graphics.newShader("assets/shaders/Fract.glsl")
    shd_noise:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
    shd_noise:send("OCTAVES", 9)
    shd_noise:send("LACUNARITY", 2.5)
    shd_noise:send("GAIN", 0.52)
    shd_noise:send("AMPLITUDE", 0.4)
    shd_noise:send("FREQUENCY", 1.5)
    shd_noise:send("SCALE", 2.5)
end

function EndDemoState:draw()
    cnv_noise:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setShader(shd_noise)
            love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1)
        love.graphics.setShader()
    end)

    --love.graphics.
    love.graphics.draw(cnv_noise, 0, 0)
end

function EndDemoState:update(elapsed)
    shd_noise:send("time", love.timer.getTime() * 2)
    shd_noise:send("SCALE", map(love.timer.getTime() * 2, 2.5, 3))
end

return EndDemoState