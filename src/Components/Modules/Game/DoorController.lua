local DoorController = {}
DoorController.__index = DoorController

function DoorController.new(frames, speed, state, k)
    local self = setmetatable({}, DoorController)
    self.key = k
    self.frames = frames
    self.closed = state or false
    self.animationRunning = false
    self.acc = 0
    self.speedAnim = speed or 1 / 25
    self.frame = 1
    self.visible = true
    self.reverseAnim = false
    return self
end

local function _playAnimation(this, reverse)
    this.acc = 0
    this.visible = true
    this.reverseAnim = reverse

    this.frame = reverse and #this.frames or 1

    this.animationRunning = true
end

function DoorController:setState(closed)
    if not self.animationRunning then
        _playAnimation(self, not closed)
    end
end

function DoorController:draw(x, y)
    x = x or 0
    y = y or 0
    if self.visible then
        love.graphics.draw(self.frames[self.key .. self.frame], x, y)
    end
end

function DoorController:update(elapsed)
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
                self.closed = true
                self.animationRunning = false
            end
        else
            if self.frame > #self.frames then
                self.frame = #self.frames
                self.closed = false
                self.animationRunning = false
            end
        end
    end
end

return DoorController