local NightGuard = class:extend("NightGuard")

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function NightGuard:__construct(assets, x, y)
    self.assets = assets
    self.flipped = false
    self.state = "idle"
    self.spriteScaleFactor = 1.2
    self.centerOffset = false
    self.hitbox = {
        x = x,
        y = y,
        w = 20,
        h = 41,
    }

    self.drawOffset = {
        x = -10,
        y = 0,
    }

    self.cooldown = 0.75


    self.animation = {
        canUpdate = true,
        frame = 0,
        acc = 0,
        speed = 1 / 2,
        loop = true,
        maxFrames = 1,
    }
end

function NightGuard:draw()
    love.graphics.draw(self.assets.img, self.assets.quads[self.state .. self.animation.frame], 
        self.hitbox.x - self.drawOffset.x, self.hitbox.y - self.drawOffset.y, 0, 
        self.flipped and -self.spriteScaleFactor or self.spriteScaleFactor, self.spriteScaleFactor, 10, 0)

    if registers.showDebugHitbox then
        drawBox(self.hitbox, 0.75, 0.5, 0.1)
    end
end

function NightGuard:update(elapsed)
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

return NightGuard