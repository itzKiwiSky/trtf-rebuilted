PlayState = {}

function PlayState:enter()
    
end

function PlayState:draw()
    love.graphics.setColor(0.4, 0.1, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.rectangle("fill", 90, 90, 128, 128)

    love.graphics.print(("%s, %s"):format(love.mouse.getPosition()))
end

function PlayState:update(elapsed)
    
end

return PlayState