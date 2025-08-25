local animatronic = require 'src.Modules.Game.Animatronics.Animatronic'

local Bonnie = animatronic:extend("Bonnie")

function Bonnie:__construct()
    Bonnie.super.__construct(self, 2, 0, 0)
end

function Bonnie:draw()
    Bonnie.super.draw(self)
end

function Bonnie:update(elapsed)
    Bonnie.super.update(self, elapsed)
end

return Bonnie