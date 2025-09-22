local animatronic = require 'src.Modules.Game.Animatronic'

local Kitty = animatronic:extend("Kitty")

function Kitty:__construct()
    Kitty.super.__construct(self, "kitty", 0, 0)  -- wtf outside the map XDDD

    self.id = "kitty"

    self.active = false
    self.path = {
        { x = 1165, y = 132, camera = 2 },         -- storage
        { x = 1064, y = 323, camera = 3 },         -- dining_area
        { x = 906, y = 339, camera = 4 },
        { x = 1116, y = 636, camera = 11 },        -- left_vent
        { x = 1004, y = 636, camera = 11 },        -- office
    }

    self.moveTime = 7.35

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Kitty:draw()
    Kitty.super.draw(self)
end

function Kitty:update(elapsed)
    if self.active then
        Kitty.super.update(self. update)
        self.onMove = function()
            if self.currentState <= 3 then
                self.currentState = self.currentState + 1
                self:moveAnimatronic()
            elseif self.currentState == 4 then
                AudioSources["vent_walk"]:seek(0)
                AudioSources["vent_walk"]:play()
            end
        end
    end
end

return Kitty