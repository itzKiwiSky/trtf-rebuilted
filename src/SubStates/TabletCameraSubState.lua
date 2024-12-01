TabletCameraSubState = {}

function TabletCameraSubState:load()

end

function TabletCameraSubState:draw()
    love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.print("Camera :D", 190, 190)
end

function TabletCameraSubState:update(elapsed)

end

return TabletCameraSubState