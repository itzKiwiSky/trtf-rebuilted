local screenShake = {}

function screenShake:start(intensity)
    self.offsets = {
        x = 0,
        y = 0
    }
    self.intensity = intensity
end

function screenShake:update(elapsed)
    if self.intensity >= 0 then
        self.offsets.x = (math.random() * 2 - 1) * self.intensity
        self.offsets.y = (math.random() * 2 - 1) * self.intensity

        --self.duration = self.duration - elapsed
        self.intensity = self.intensity - elapsed
    end
end

function screenShake:getOffsets()
    return self.offsets.x, self.offsets.y
end

return screenShake
