local animatronic = require 'src.Modules.Game.Animatronic'

local Bonnie = animatronic:extend("Bonnie")

function Bonnie:__construct()
    Bonnie.super.__construct(self, "bonnie", 0, 0)  -- wtf outside the map XDDD

    self.id = "bonnie"
    self.metadataCameraID = 0
    self.path = {
        { x = 1064, y = 256, camera = 6 },        -- showstage
        { x = 950, y = 431, camera = 1 },         -- arcade
        { x = 999, y = 490, camera = 9 },         -- left_hall
        { x = 1076, y = 544, camera = nil },        -- front_office
        { x = 1079, y = 592, camera = nil },        -- office
    }

    self.moveTime = 8.25

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Bonnie:draw()
    Bonnie.super.draw(self)
end

function Bonnie:update(elapsed)
    if self.currentState <= 4 then
        Bonnie.super.update(self, elapsed)
        self.onMove = function()
            if NightState.officeState.tabletUp then
                self:playWalk()
                self:interference()
            end
            self.currentState = self.currentState + 1
            if NightState.officeState.flashlight.state then
                if self.currentState == 4 then
                    NightState.officeState.flashlight.isFlicking = true
                end
            end
        end
    else
        if not AudioSources["stare"]:isPlaying() then
            AudioSources["stare"]:play()
        end

        -- in office --
        self.timer = self.timer + elapsed
        if self.timer >= 0.0075 then
            self.timer = 0
            self.patience = self.patience + 1
            NightState.officeState.hasAnimatronicInOffice = true
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

return Bonnie