local Player = {}

function Player:init(x, y)
    self.x = x
    self.y = y
    self.offsetX = 8
    self.offsetY = 6
    self.w = 24
    self.h = 30
    self.speed = 900

    self.cooldown = {
        left = 0,
        right = 0,
        up = 0,
        down = 0,
    }
    self.maxCooldown = 0.05
end

function Player:draw()
    love.graphics.setColor(1, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1, 1)

    --love.graphics.print(debug.formattable(self.cooldown), self.x + 30, self.y + 30)
end

function Player:update(elapsed)
    for k, v in pairs(self.cooldown) do
        if self.cooldown[k] > 0 then
            self.cooldown[k] = self.cooldown[k] - elapsed
        end
    end
    if love.keyboard.isDown("a", "left") and self.cooldown.left <= 0 then
        self.x = self.x - self.speed * elapsed
        self.cooldown.left = self.maxCooldown
    end
    if love.keyboard.isDown("d", "right") and self.cooldown.right <= 0 then
        self.x = self.x + self.speed * elapsed
        self.cooldown.right = self.maxCooldown
    end
    if love.keyboard.isDown("w", "up") and self.cooldown.up <= 0 then
        self.y = self.y - self.speed * elapsed
        self.cooldown.up = self.maxCooldown
    end
    if love.keyboard.isDown("s", "down") and self.cooldown.down <= 0 then
        self.y = self.y + self.speed * elapsed
        self.cooldown.down = self.maxCooldown
    end
end

return Player