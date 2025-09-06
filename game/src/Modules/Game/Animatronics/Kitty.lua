local animatronic = require 'src.Modules.Game.Animatronic'

local Kitty = animatronic:extend("Kitty")

function Kitty:__construct()
    Kitty.super.__construct(self, "kitty", 0, 0)  -- wtf outside the map XDDD
end

function Kitty:draw()
    Kitty.super.draw(self)
end

function Kitty:update(elapsed)
    
end

return Kitty