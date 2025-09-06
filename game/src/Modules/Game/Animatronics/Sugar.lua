local animatronic = require 'src.Modules.Game.Animatronic'

local Sugar = animatronic:extend("Sugar")

function Sugar:__construct()
    Sugar.super.__construct(self, "sugar", 0, 0)  -- wtf outside the map XDDD
end

function Sugar:draw()
    Sugar.super.draw(self)
end

function Sugar:update(elapsed)
    
end

return Sugar