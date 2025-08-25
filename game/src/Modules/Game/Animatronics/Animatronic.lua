local Animatronic = class:extend("Animatronic")

function Animatronic:__construct(id, x, y)
    self.id = id or 1
    self.name = ""
    self.x = x or 0
    self.y = y or 0
    self.w = 32
    self.h = 32
end

function Animatronic:draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[2], self.x, self.y, 0, 2, 2, 16, 16)
    end
end

function Animatronic:update(elapsed)
    
end

return Animatronic