local animatronic = require 'src.Modules.Game.Animatronic'

local Puppet = animatronic:extend("Puppet")

function Puppet:__construct()
    Puppet.super.__construct(self, "puppet", 0, 0)  -- wtf outside the map XDDD

    self.id = "puppet"

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Puppet:draw()
    Puppet.super.draw(self)
end

function Puppet:update(elapsed)
    
end

return Puppet