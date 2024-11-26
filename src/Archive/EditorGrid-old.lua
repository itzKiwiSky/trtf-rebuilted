return function(size)
    for y = 0, love.graphics.getHeight() / size, 1 do
        for x = 0, love.graphics.getWidth() / size, 1 do
            love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.points(x * size, y * size)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end