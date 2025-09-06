local animatronic = require 'src.Modules.Game.Animatronic'

local Freddy = animatronic:extend("Freddy")

function Freddy:__construct()
    Freddy.super.__construct(self, "freddy", 0, 0)  -- wtf outside the map XDDD
end

function Freddy:draw()
    Freddy.super.draw(self)
end

function Freddy:update(elapsed)
    
end

return Freddy