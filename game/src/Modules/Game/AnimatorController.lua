local AnimatorController = class:extend("AnimatorController")

function AnimatorController:__construct(frames, speed, k)
    self.key = k
    self.frames = frames
    self.tabUp = false
    self.animationRunning = false
    self.acc = 0
    self.speedAnim = speed or 25
    self.frame = 1
    self.visible = true
    self.reverseAnim = false
    self.loop = true
    self.onComplete = function() end
end

local function _playAnimation(self, reverse)
    self.acc = 0
    self.visible = true
    self.reverseAnim = reverse

    self.frame = reverse and self.frames.frameCount or 1
    if reverse then
        self.tabUp = false
    end

    self.animationRunning = true
end

function AnimatorController:setState(reverse)
    if not self.animationRunning then
        _playAnimation(self, not reverse)
    end
end

function AnimatorController:draw(x, y, sx, sy)
    x = x or 0
    y = y or 0
    sx = sx or 1
    sy = sy or 1
    if self.visible then
        love.graphics.draw(self.frames[self.key .. self.frame], 0, 0, 0)
    end
end

function AnimatorController:update(elapsed)
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
                --self.tabUp = false
                self.animationRunning = false
                self.visible = false
                self.onComplete()
            end
        else
            if self.frame > self.frames.frameCount then
                self.frame = self.frames.frameCount
                self.tabUp = true
                self.animationRunning = false
                self.visible = true
                self.onComplete()
            end
        end
    end
end

return AnimatorController
