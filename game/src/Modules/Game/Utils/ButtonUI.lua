local ButtonUI = class:extend("ButtonUI")

function ButtonUI:__construct(image, x, y, r, sx, sy)
    self.image = image
    self.x = x
    self.y = y
    self.w = image:getWidth()
    self.h = image:getHeight() + 64
    self.r = r or 0
    self.sx = sx or 1
    self.sy = sy or 1
    self.isHover = false
end

function ButtonUI:draw()
    if self.image then
        love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy)
    end
end

return ButtonUI