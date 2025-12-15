local animatronic = require 'src.Modules.Game.Animatronic'

local Frankburt = animatronic:extend("Frankburt") ---@type Animatronic

function frankburt:__construct()
    Frankburt.super.__construct(self, "frankburt", 0, 0) -- wtf outside the map XDDD

    self.id = "frankburt"
    self.path = {

    }

    self.moveTime = 5

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Frankburt:draw()
    Frankburt.super.draw(self)
end

function Frankburt:update(elapsed)
    if self.currentState <= 4 then
        Frankburt.super.update(self, elapsed)
        self.onMove = function()
            if NightState.officeState.tabletUp then
                self:moveAnimatronic()
            end

            self.currentState = self.currentState + 1
            if NightState.officeState.flashlight.state then
                if self.currentState == 4 then
                    NightState.officeState.flashlight.isFlicking = true
                end
            end
        end

        NightState.officeState.hasAnimatronicInFrontOffice = self.currentState == 4
    else
        if not AudioSources["stare"]:isPlaying() then
            AudioSources["stare"]:play()
        end

        -- in office --
        self.timer = self.timer + elapsed
        if self.timer >= 0.025 then
            self.timer = 0
            self.patience = self.patience + 1
            NightState.officeState.hasAnimatronicInOffice = true
            NightState.officeState.onAnimatronicInOffice()
        end

        if NightState.officeState.hasAnimatronicInOffice then
            if self.patience >= 150 and not NightState.officeState.maskUp then
                self:kill()
            elseif self.patience >= 150 and NightState.officeState.maskUp then
                self.patience = 0
                self.timer = 0
                self.currentState = 1
                NightState.officeState.hasAnimatronicInOffice = false
                AudioSources["stare"]:stop()
                NightState.officeState.fadealpha = 1
            end
        end
    end
end

return Frankburt
