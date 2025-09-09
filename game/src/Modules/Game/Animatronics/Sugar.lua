local animatronic = require 'src.Modules.Game.Animatronic'

local Sugar = animatronic:extend("Sugar")

function Sugar:__construct()
    Sugar.super.__construct(self, "sugar", 0, 0)  -- wtf outside the map XDDD

    self.id = "sugar"

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Sugar:draw()
    Sugar.super.draw(self)
end

function Sugar:update(elapsed)
    
end

return Sugar