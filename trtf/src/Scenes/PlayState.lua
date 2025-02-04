PlayState = {}

function PlayState:enter()
    self.cavas = love.graphics.newCanvas(love.graphics.getDimensions())
    print(love.graphics.getDimensions())
end

function PlayState:draw()
    local mx, my = love.mouse.getPosition()
    --love.graphics.setColor(0.4, 0.1, 0.6)
    ---love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    --.graphics.setColor(1, 1, 1, 1)


    love.graphics.clear(0.4, 0.1, 0.6)
    love.graphics.rectangle("fill", mx, my, 128, 128)

    --love.graphics.draw(self.cavas)

    love.graphics.print(("%s, %s"):format(mx, my))
end

function PlayState:update(elapsed)
    
end

return PlayState