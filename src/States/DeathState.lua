DeathState = {}

function DeathState:enter()
    bg = love.graphics.newImage("assets/images/game/night/gameover.png")
    bgfade = 1
end

function DeathState:draw()
    love.graphics.setColor(0, 0, 0, bgfade)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(bg, 0, 0)
end

function DeathState:update(elapsed)
    bgfade = bgfade - 3.3 * elapsed
end

return DeathState