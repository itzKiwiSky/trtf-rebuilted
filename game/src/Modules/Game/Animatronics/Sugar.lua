local animatronic = require 'src.Modules.Game.Animatronic'

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

    self.moveTime = 7.63
    self.nextMoveTime = 7.45
    self.patienceTimer = 0
    self.patience = 0

    self:setupIconPosition()
end

function Sugar:draw()
    Sugar.super.draw(self)
end

function Sugar:update(elapsed)
    if self.active then
        Sugar.super.update(self, elapsed)
        self.onMove = function()
            if self.currentState <= 3 then
                self.currentState = self.currentState + 1
                if not NightState.officeState.hasAnimatronicInOffice and not NightState.officeState.someoneInVent then
                    self:moveAnimatronic()
                end
            elseif self.currentState == 4 then
                NightState.officeState.someoneInVent = true
                AudioSources["sfx_vent_walk"]:seek(0)
                AudioSources["sfx_vent_walk"]:play()
            end
        end

        if self.currentState == 4 then
            self.patienceTimer = self.patienceTimer + elapsed
            if self.patienceTimer >= 0.04 then
                self.patienceTimer = 0
                self.patience = self.patience + 1
            end

            if self.patience >= 450 and not NightState.officeState.vent.right then
                self.currentState = 5
                if not NightState.killed then
                    self:kill()
                end
            elseif self.patience >= 450 and NightState.officeState.vent.right then
                AudioSources["sfx_vent_amb2"]:seek(0)
                AudioSources["sfx_vent_amb2"]:play()
                self.patience = 0
                self.timer = 0
                self.currentState = 2
                NightState.officeState.someoneInVent = false
            end
        end
    else
        Sugar.super.update(self, elapsed)
        self.onMove = function()
            self:moveAnimatronic()
            self.moveTime = 9.52
            self.active = true
            self.timer = 0
        end
    end
end

return Sugar
