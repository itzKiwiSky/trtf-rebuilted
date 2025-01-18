EndDemoState = {}

local function map(t, a, b)
    return (math.sin(t) + 1) * 0.5 * (b - a) + a
end

function EndDemoState:enter()
    subtitlesController.clear()

    endScreen = love.graphics.newImage("assets/images/game/end_of_demo_gay_sex.png")
end

function EndDemoState:draw()

end

function EndDemoState:update(elapsed)

end

return EndDemoState