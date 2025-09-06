local animatronic = require 'src.Modules.Game.Animatronic'

local Chica = animatronic:extend("Chica")

function Chica:__construct()
    Chica.super.__construct(self, "chica", 0, 0)  -- wtf outside the map XDDD
end

function Chica:draw()
    Chica.super.draw(self)
end

function Chica:update(elapsed)
    
end

return Chica