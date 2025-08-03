local JumpscareController = {}

function JumpscareController:init(id, speed)
    self.frames = NightState.assets.jumpscares
    self.id = id
    self.frame = 1
    self.acc = 0
    self.speedAnim = speed
    self.active = true
    self.onComplete = function()end

    for k, v in pairs(AudioSources) do
        v:stop()
    end

    ShakeController:setShake(10)
    AudioSources["sfx_jumpscare"]:setVolume(1.5)
    AudioSources["sfx_jumpscare"]:play()
end

function JumpscareController:draw()
    if self.active then
        if self.frames[self.id]["jmp_" .. self.frame] then
            love.graphics.draw(self.frames[self.id]["jmp_" .. self.frame], 0, 0, 0, shove.getViewportWidth() / self.frames[self.id]["jmp_" .. self.frame]:getWidth(), shove.getViewportHeight() / self.frames[self.id]["jmp_" .. self.frame]:getHeight())
        end
    end
end

function JumpscareController:update(elapsed)
    if self.active then    
        self.acc = self.acc + elapsed
        if self.acc >= (1 / self.speedAnim) then
            self.acc = 0
            self.frame = self.frame + 1
            if self.frame >= self.frames[self.id].frameCount - 1 then
                self.frame = self.frames[self.id].frameCount
                self.onComplete()
                self.active = false
            end
        end
    end
end

return JumpscareController