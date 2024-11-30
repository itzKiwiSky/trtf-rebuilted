local TabletController = {}
TabletController.__index = TabletController

function TabletController.new(frames, speed, state)
    local self = setmetatable({}, TabletController)
    self.frames = frames
    self.tabUp = state or false
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

function TabletController:setState(closed)
    if not self.animationRunning then
        _playAnimation(self, not closed)
    end
end

function TabletController:draw(x, y)
    x = x or 0
    y = y or 0
    if self.visible then
        love.graphics.draw(self.frames[self.frame], x, y)
    end
end

function TabletController:update(elapsed)
    if self.animationRunning then
        self.acc = self.acc + elapsed
        if self.acc >= self.speedAnim then
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
            if self.frame > #self.frames then
                self.frame = #self.frames
                self.animationRunning = false
            end
        end
    end
end

return TabletController