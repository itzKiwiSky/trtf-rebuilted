local Marker = {}
Marker.__index = Marker

function Marker.new(x, y, w, h, size)
    local self = setmetatable({}, Marker)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.size = size
    return self
end

function Marker:draw()
    -- TR --
    love.graphics.line(self.x, self.y, self.x + self.size, self.y)
    love.graphics.line(self.x, self.y, self.x , self.y + self.size)

    -- TL --
    love.graphics.line((self.x + self.w) - self.size, self.y, self.x + self.w, self.y)
    love.graphics.line(self.x + self.w, self.y, self.x + self.w, self.y + self.size)

    -- BR --
    love.graphics.line(self.x, (self.y + self.h) - self.size, self.x, self.y + self.h)
    love.graphics.line(self.x, self.y + self.h, self.x + self.size, self.y + self.h)

    -- BL --
    love.graphics.line(self.x + self.w, (self.y + self.h) - self.size, self.x + self.w, self.y + self.h)
    love.graphics.line((self.x + self.w) - self.size, self.y + self.h, self.x + self.w, self.y + self.h)
end

return Marker