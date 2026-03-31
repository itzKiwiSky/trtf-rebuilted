local animatronic = require 'src.Modules.Game.Animatronic'

local Kitty = animatronic:extend("Kitty")

function Kitty:__construct()
    Kitty.super.__construct(self, "kitty", -128, -128) -- wtf outside the map XDDD

    self.id = "kitty"

    self.currentState = 0
    self.active = false
    self.path = {
        { x = 1165, y = 440, camera = 2 },  -- storage
        { x = 1064, y = 323, camera = 3 },  -- dining_area
        { x = 906,  y = 339, camera = 4 },
        { x = 1116, y = 636, camera = 11 }, -- left_vent
        { x = 1004, y = 636, camera = 11 }, -- office
    }

    self.moveTime = 6.64
    self.patienceTimer = 0
    self.patience = 0

    --self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Kitty:requireSugar()
    sugar = NightState.AnimatronicControllers["sugar"]
end

function Kitty:draw()
    Kitty.super.draw(self)
end

function Kitty:update(elapsed)
    if self.active then
        Kitty.super.update(self, elapsed)
        self.onMove = function()
            if self.currentState <= 3 and not NightState.officeState.someoneInVent and sugar.currentState == 1 then
                self.currentState = self.currentState + 1
                self:moveAnimatronic()
                if self.currentState == 4 then
                    AudioSources["sfx_vent_walk"]:seek(0)
                    AudioSources["sfx_vent_walk"]:play()
                    NightState.officeState.someoneInVent = true
                end
            end
        end

        if self.currentState == 4 then
            self.patienceTimer = self.patienceTimer + elapsed

            if self.patienceTimer >= 0.04 then
                self.patience = self.patience + 1
                self.patienceTimer = 0
            end

            if self.patience >= 200 and self.patience < 500 and NightState.officeState.vent.left then
                self:moveAnimatronic()
                self.patience = 0
                self.timer = 0
                self.currentState = 2
                NightState.officeState.someoneInVent = false
            elseif self.patience >= 500 and not NightState.officeState.vent.left then
                self.currentState = 5
            end
        elseif self.currentState == 5 then
            if not NightState.killed then
                self:kill()
            end
        end
    else
        Kitty.super.update(self, elapsed)
        self.onMove = function()
            self.moveTime = 14.75
            self.active = true
            self.timer = 0
        end
    end
end

return Kitty
