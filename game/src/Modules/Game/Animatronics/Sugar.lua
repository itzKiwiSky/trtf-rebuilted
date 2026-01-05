local animatronic = require 'src.Modules.Game.Animatronic'
local kitty = NightState.AnimatronicControllers["kitty"]

local Sugar = animatronic:extend("Sugar")

function Sugar:__construct()
    Sugar.super.__construct(self, "sugar", 0, 0) -- wtf outside the map XDDD

    self.id = "sugar"
    self.active = false
    self.path = {
        { x = 898,  y = 267, camera = 5 },  -- storage
        { x = 906,  y = 339, camera = 4 },
        { x = 1004, y = 636, camera = 12 }, -- right_vent
        { x = 1004, y = 636, camera = 12 }, -- office
    }

    self.moveTime = 8.87
    self.patienceTimer = 0
    self.patience = 0

    self:setupIconPosition()
end

function Sugar:requireKitty()
    kitty = NightState.AnimatronicControllers["kitty"]
end

function Sugar:draw()
    Sugar.super.draw(self)
end

function Sugar:update(elapsed)
    if self.active then
        Sugar.super.update(self, elapsed)
        self.onMove = function()
            if self.currentState <= 2 and not NightState.officeState.someoneInVent and kitty.currentState < 4 then
                self.currentState = self.currentState + 1
                self:moveAnimatronic()
                if self.currentState == 3 then
                    AudioSources["sfx_vent_walk"]:seek(0)
                    AudioSources["sfx_vent_walk"]:play()
                    NightState.officeState.someoneInVent = true
                end
            end
        end

        if self.currentState == 3 then
            self.patienceTimer = self.patienceTimer + elapsed

            if self.patienceTimer >= 0.04 then
                self.patience = self.patience + 1
                self.patienceTimer = 0
            end

            if self.patience >= 200 and self.patience < 500 and NightState.officeState.vent.right then
                self:moveAnimatronic()
                self.patience = 0
                self.timer = 0
                self.currentState = 1
                NightState.officeState.someoneInVent = false
            elseif self.patience >= 500 and not NightState.officeState.vent.right then
                self.currentState = 4
            end
        elseif self.currentState == 4 then
            if not NightState.killed then
                self:kill()
            end
        end
    else
        Sugar.super.update(self, elapsed)
        self.onMove = function()
            self.moveTime = 14.75
            self.active = true
            self.timer = 0
        end
    end
end

return Sugar
