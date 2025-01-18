local MaskController = {}

function MaskController:init(frames, speed, k)
    self.key = k
    self.x = -16
    self.y = -64
    self.rx = 0
    self.ry = 0
    self.frames = frames
    self.maskUp = false
    self.animationRunning = false
    self.acc = 0
    self.speedAnim = speed or 25
    self.frame = 1
    self.visible = true
    self.reverseAnim = false
end

local function _circularPath(this, radius, speed, time)
    local angle = speed * time

    local x = radius * math.cos(angle)
    local y = radius * math.sin(angle)
    
    this.rx = this.rx + x
    this.ry = this.ry + y
end

local function _playAnimation(this, reverse)
    this.acc = 0
    this.visible = true
    this.reverseAnim = reverse

    this.frame = reverse and this.frames.frameCount or 1

    this.animationRunning = true
end

function MaskController:setState(closed)
    if not self.animationRunning then
        _playAnimation(self, not closed)
    end
end

function MaskController:draw()
    if self.visible then
        --love.graphics.draw(self.frames[self.key .. self.frame], self.x + self.rx, self.y + self.ry)
        love.graphics.draw(self.frames[self.key .. self.frame], self.x + self.rx, self.y + self.ry, 0, 
            love.graphics.getWidth() / self.frames[self.key .. self.frame]:getWidth(),
            love.graphics.getHeight() / self.frames[self.key .. self.frame]:getHeight()
        )
    end
end

function MaskController:update(elapsed)
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
                self.visible = false
            end
        else
            if self.frame > self.frames.frameCount then
                self.frame = self.frames.frameCount
                self.maskUp = true
                self.animationRunning = false
            end
        end
    end

    if self.maskUp and not self.animationRunning then
        _circularPath(self, 0.2, 6, love.timer.getTime())
    end
end

return MaskController