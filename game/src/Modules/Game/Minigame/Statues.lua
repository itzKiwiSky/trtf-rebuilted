local Statue = class:extend("Statue")

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function Statue:__construct(img, quad, x, y)
    self.assets = { img = img, quad = quad }
    self.state = "idle"
    self.hitbox = {
        x = x,
        y = y,
        w = 24,
        h = 24,
    }

    self.drawOffset = {
        x = 4,
        y = 4,
    }

    MinigameSceneState.world:add(self.hitbox, self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
end

function Statue:draw()
    love.graphics.draw(self.assets.img, self.assets.quad, 
        self.hitbox.x - self.drawOffset.x, self.hitbox.y - self.drawOffset.y, 0, 1.2, 1.2, 16, 16
    )

    if registers.showDebugHitbox then
        --love.graphics.print(string.format("%.3f", self.happiness), self.hitbox.x, self.hitbox.y - 8, 0, 0.5, 0.5)
        drawBox(self.hitbox, 0.4, 0.5, 0.1)
    end
end

return Statue