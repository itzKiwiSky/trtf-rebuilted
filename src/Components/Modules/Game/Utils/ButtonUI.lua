local ButtonUI = {}
ButtonUI.__index = ButtonUI

function ButtonUI.new(image, x, y)
    local self = setmetatable({}, ButtonUI)
    self.image = image
    self.x = x
    self.y = y
    self.w = image:getWidth()
    self.h = image:getHeight() + 64
    self.isHover = false
    return self
end

function ButtonUI:draw()
    if self.image then
        love.graphics.draw(self.image, self.x, self.y)
    end
end

return ButtonUI