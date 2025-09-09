local animatronic = require 'src.Modules.Game.Animatronic'

local Puppet = animatronic:extend("Puppet")

function Puppet:__construct()
    Puppet.super.__construct(self, "puppet", 0, 0)  -- wtf outside the map XDDD

    self.id = "puppet"

    self:setupIconPosition()
end

function Puppet:draw()
    Puppet.super.draw(self)
end

function Puppet:update(elapsed)
    
end

return Puppet