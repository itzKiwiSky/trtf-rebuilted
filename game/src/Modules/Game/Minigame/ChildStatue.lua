local Statues = require 'src.Modules.Game.Minigame.Statues'
local ChildStatue = Statues:extend("ChildStatue")

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function ChildStatue:__construct(img, quad, x, y, addToWorld, centerOffset, spriteScaleFactor)
    ChildStatue.super.__construct(self, img, quad, x, y, addToWorld, centerOffset, spriteScaleFactor)

    self.animation = {
        canUpdate = true,
        frame = 1,
        acc = 0,
        speed = 1 / 5,
        loop = true,
        maxFrames = 2,
    }
end

function ChildStatue:draw()
    love.graphics.draw(self.assets.img, self.assets.quad[self.animation.frame], 
        self.hitbox.x - self.drawOffset.x, self.hitbox.y - self.drawOffset.y, 0, self.spriteScaleFactor, self.spriteScaleFactor, 
        self.centerOffset and 16 or 0,self.centerOffset and 16 or 0
    )

    if registers.showDebugHitbox then
        --love.graphics.print(string.format("%.3f", self.happiness), self.hitbox.x, self.hitbox.y - 8, 0, 0.5, 0.5)
        ChildStatue.drawBox(self.hitbox, 0.75, 0.5, 0.1)
    end
end

function ChildStatue:update(elapsed)
    if self.animation.canUpdate then
        self.animation.acc = self.animation.acc + elapsed
        if self.animation.acc >= self.animation.speed then
            self.animation.frame = self.animation.frame + 1
            self.animation.acc = 0
            if self.animation.frame > self.animation.maxFrames then
                self.animation.frame = 0
            end
        end
    end
end

return ChildStatue