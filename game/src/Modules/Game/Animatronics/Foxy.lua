local animatronic = require 'src.Modules.Game.Animatronic'

local Foxy = animatronic:extend("Foxy")

function Foxy:__construct()
    Foxy.super.__construct(self, "foxy", 0, 0)  -- wtf outside the map XDDD

    self.id = "foxy"

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Foxy:draw()
    Foxy.super.draw(self)
end

function Foxy:update(elapsed)
    
end

return Foxy