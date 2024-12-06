local PhoneController = {}

function PhoneController:init(frames, speed, k)
    self.key = k
    self.frames = frames
    self.phoneUp = false
    self.animationRunning = false
    self.acc = 0
    self.speedAnim = speed or 25
    self.frame = 1
    self.visible = true
    self.reverseAnim = false
end

local function _playAnimation(this, reverse)
    this.acc = 0
    this.visible = true
    this.reverseAnim = reverse

    this.frame = reverse and this.frames.frameCount or 1
    if reverse then
        this.phoneUp = false
    end

    this.animationRunning = true
end

function PhoneController:setState(closed)
    if not self.animationRunning then
        _playAnimation(self, closed)
    end
end

function PhoneController:draw()
    if self.visible then
        love.graphics.draw(self.frames[self.key .. self.frame], 0, 0)
    end
end

function PhoneController:update(elapsed)
    if self.animationRunning then
        self.acc = self.acc + elapsed
        if self.acc >= (1 / self.speedAnim) then
            if self.reverseAnim then
                self.frame = self.frame - 1
            else
                self.frame = self.frame + 1
            end
            self.acc = 0
        end
        if self.reverseAnim then
            if self.frame < 1 then
                self.frame = 1
                self.animationRunning = false
            end
        else
            if self.frame > self.frames.frameCount then
                self.frame = self.frames.frameCount
                self.animationRunning = false
            end
        end
    end
end

return PhoneController