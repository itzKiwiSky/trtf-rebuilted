local Child = class:extend("Child")

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function Child:__construct(img, quads, x, y, flipped)
    self.state = "idle"
    self.flipped = flipped or false
    self.assets = { img = img, quads = quads or {} }
    self.hitbox = {
        x = x,
        y = y,
        w = 16,
        h = 16,
    }
    self.drawOffset = {
        x = 0,
        y = 0,
    }

    self.decrease = {
        min = 2,
        max = 4,
    }

    self.inCooldown = false
    self.cooldownHappiness = 2
    self.cooldownHappinessMax = 2

    self.canBeHappy = true
    self.happiness = 100
    self.hapDecreaseTimer = 0
    self.hapDecreaseTimerMax = 0.75
    self.childAcc = 0

    self.animation = {
        frame = 0,
        acc = 0,
        speed = 1 / 5,
        loop = true,
        maxFrames = 1,
    }

    MinigameSceneState.world:add(self.hitbox, self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
end

function Child:draw()
    --if type(self.assets.img) == nil or #self.assets.quads <= 0 then return end
    --print(self.state .. self.animation.frame)
    love.graphics.draw(self.assets.img, self.assets.quads[self.state .. self.animation.frame], 
        self.hitbox.x - self.drawOffset.x, self.hitbox.y - self.drawOffset.y, 0, self.flipped and -1 or 1, 1,
        8, 8
    )

    if registers.showDebugHitbox then
        love.graphics.print(string.format("%.3f", self.happiness), self.hitbox.x, self.hitbox.y - 8, 0, 0.5, 0.5)
        drawBox(self.hitbox, 0.4, 0.5, 0.1)
    end
end

function Child:update(elapsed)
    self.childAcc = self.childAcc + 0.0075 * elapsed

    self.animation.acc = self.animation.acc + elapsed
    if self.animation.acc >= self.animation.speed then
        self.animation.frame = self.animation.frame + 1
        self.animation.acc = 0
        if self.animation.frame > self.animation.maxFrames then
            self.animation.frame = 0
        end
    end

    self.hapDecreaseTimer = self.hapDecreaseTimer + elapsed
    if self.hapDecreaseTimer >= self.hapDecreaseTimerMax then
        self.hapDecreaseTimer = 0
        self.happiness = self.happiness - (math.random() + self.childAcc)
    end

    if self.inCooldown then
        self.cooldownHappiness = self.cooldownHappiness - elapsed
        if self.cooldownHappiness <= 0 then
            self.inCooldown = false
            self.cooldownHappiness = self.cooldownHappinessMax
        end
    end

    if self.happiness <= 0 then
        self.canBeHappy = false
    end
    
    if self.happiness >= 75 then
        self.state = "idle"
    elseif self.happiness >= 50 then
        self.state = "midder"
    elseif self.happiness >= 25 then
        self.state = "angry"
    end
end

return Child