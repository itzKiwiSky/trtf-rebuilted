local animatronic = require 'src.Modules.Game.Animatronic'

local Kitty = animatronic:extend("Kitty")

function Kitty:__construct()
    Kitty.super.__construct(self, "kitty", 0, 0)  -- wtf outside the map XDDD

    self.id = "kitty"

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Kitty:draw()
    Kitty.super.draw(self)
end

function Kitty:update(elapsed)
    
end

return Kitty