local Puppet = {}

function Puppet:init(x, y)
    self.img = love.graphics.newImage("assets/images/game/minigames/puppet.png")
    self.x = x or 0
    self.y = y or 0
    self.puppetMoveCooldown = 0.5
    self.step = 16
    self.moveCooldown = 0.5
    self.currentAreas = { "showstage" }
    self.moveDirection = "left"
end

function Puppet:draw(cam)
    if collision.pointRect(self, cam) then
        love.graphics.draw(self.img, 
            self.x, self.y, 0, 
            self.moveDirection == "left" and -1.2 or 1.2, 1.2, 
            self.img:getWidth() / 2, self.img:getHeight() / 2
        )
    end
end

function Puppet:update(cam, minigame, elapsed)
    if collision.pointRect(self, cam) then
        self.moveCooldown = self.moveCooldown - elapsed
        if self.moveCooldown <= 0 then
            switch(self.moveDirection, {
                ["left"] = function ()
                    self.x = self.x - self.step
                end,
                ["right"] = function ()
                    self.x = self.x + self.step
                end,
                ["up"] = function ()
                    self.y = self.y - self.step
                end,
                ["down"] = function ()
                    self.y = self.y + self.step
                end,
            })
            self.moveCooldown = self.puppetMoveCooldown
        end
    else
        local k, v = next(minigame.giftList, minigame.currentGift)
        self.x = MinigameSceneState.map.areas[k].centerX
        self.y = MinigameSceneState.map.areas[k].centerY
    end
end

function Puppet:updatePos(minigame)
    local k, v = next(minigame.giftList[minigame.currentGift], minigame.currentGift)
    self.x = MinigameSceneState.map.areas[k].centerX
    self.y = MinigameSceneState.map.areas[k].centerY
end

return Puppet