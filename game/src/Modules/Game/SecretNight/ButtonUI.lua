local ButtonUI = class:extend("ButtonUI")

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function ButtonUI:__construct(image, x, y, r, sx, sy, centerOrigin)
    self.centerOrigin = centerOrigin or false
    self.image = image
    self.x = x
    self.y = y
    self.hitbox = {
        x = x - (centerOrigin and image:getWidth() / 2 or 0) * sx,
        y = y - (centerOrigin and image:getHeight() / 2 or 0) * sy,
        w = image:getWidth(),
        h = image:getHeight(),
    }
    self.r = r or 0
    self.sx = sx or 1
    self.sy = sy or 1
    self.isHover = false
end

function ButtonUI:draw()
    if self.image then
        love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy,
            self.centerOrigin and self.image:getWidth() / 2 or 0, 
            self.centerOrigin and self.image:getHeight() / 2 or 0
        )
    end

    if registers.showDebugHitbox then
        drawBox(self.hitbox, 0.25, 1, 0.5)
    end
end

function ButtonUI:checkHover(mx, my)
    if collision.pointRect({ x = mx, y = my }, self) then
        self.isHover = true
    else
        self.isHover = false
    end
end

return ButtonUI