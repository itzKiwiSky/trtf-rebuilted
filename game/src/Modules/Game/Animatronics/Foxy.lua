local animatronic = require 'src.Modules.Game.Animatronic'

local Foxy = animatronic:extend("Foxy")

function Foxy:__construct()
    Foxy.super.__construct(self, "foxy", 0, 0)  -- wtf outside the map XDDD

    self.id = "foxy"

    self.path = {
        {x = 906, y = 339, camera = 4},  -- pirate_cove
        {x = 1076, y = 544, camera = nil},        -- front_office
        {x = 1076, y = 544, camera = nil},        -- front_office
        {x = 1076, y = 544, camera = nil},        -- front_office
        {x = 1076, y = 544, camera = nil},        -- front_office
        {x = 1079, y = 592, camera = nil},        -- office
    }

    self.position = 1
    self.patience = 0
    self.move = 0
    self.timer = 0
    self.direction = "none"
    self.updateMoveTimer = false
    self.autoUpdatePos = false
    self.currentState = NightState.nightID > 1 and 2 or 1

    --self:setupIconPosition()
end

function Foxy:draw()
    Foxy.super.draw(self)
end

function Foxy:update(elapsed)
    if self.currentState <= 1 then
        self.timer = self.timer + elapsed
        if self.timer >= 7.3 then
            self.move = math.random(0, 20)
            if self.move <= NightState.animatronicsAI.foxy and NightState.animatronicsAI.foxy > 0 and not NightState.officeState.hasAnimatronicInOffice then
                self:interference()
                self.currentState = 2
                self.playWalk()

                if NightState.officeState.flashlight.state then
                    NightState.officeState.flashlight.isFlicking = true
                end
            end
            self.timer = 0
        end
    elseif self.currentState == 2 then
        self.timer = self.timer + elapsed
        if self.timer >= 14.8 then
            self.move = math.random(0, 20)
            if self.move <= NightState.animatronicsAI.foxy and NightState.animatronicsAI.foxy > 0 and not NightState.officeState.hasAnimatronicInOffice then
                if NightState.officeState.flashlight.state then
                    NightState.officeState.flashlight.isFlicking = true
                end
                self.currentState = 3
            end
            self.timer = 0
        end
    elseif self.currentState == 3 then
        self.timer = self.timer + elapsed
        if self.timer >= 0.02 then
            self.timer = 0
            self.patience = self.patience + 1
        end

        if self.patience >= 160 - NightState.animatronicsAI.foxy then
            self.currentState = math.random(4, 5)
        end
    elseif self.currentState == 4 then
        self.position = 3
        self.timer = self.timer + elapsed
        if self.timer >= 0.05 then
            self.timer = 0
            self.patience = self.patience + 1
        end

        if self.patience >= 180 then
            self.direction = "right"
            self.patience = 0
            self.currentState = 6
        end
    elseif self.currentState == 5 then
        self.position = 4
        self.timer = self.timer + elapsed
        if self.timer >= 0.02 then
            self.timer = 0
            self.patience = self.patience + 1
        end

        if self.patience >= 180 then
            self.direction = "left"
            self.patience = 0
            self.currentState = 6
        end
    elseif self.currentState == 6 then
        self.timer = self.timer + elapsed
        if self.timer >= 0.034 then
            self.timer = 0
            self.patience = self.patience + 1
            if self.patience == 20 then
                if not AudioSources["run"]:isPlaying() then
                    if self.direction == "right" then
                        AudioSources["run"]:setVolume(1.2)
                        AudioSources["run"]:seek(0)
                        AudioSources["run"]:setPosition(-0.001, 0, 0)
                        AudioSources["run"]:play()
                    elseif self.direction == "left" then
                        AudioSources["run"]:setVolume(1.2)
                        AudioSources["run"]:seek(0)
                        AudioSources["run"]:setPosition(0.001, 0, 0)
                        AudioSources["run"]:play()
                    end
                end
            end
        end

        if self.patience >= 90 then
            if self.direction == "left" then
                if NightState.officeState.doors.left then
                    AudioSources["door_knocking"]:setVolume(1.2)
                    AudioSources["door_knocking"]:setPosition(0.001, 0, 0)
                    AudioSources["door_knocking"]:play()
                    self.currentState = 2
                    self.timer = 0
                    self.position = math.random(1, 2)
                    self.patience = 0
                else
                    self:kill()
                end
            elseif self.direction == "right" then
                if NightState.officeState.doors.right then
                    AudioSources["door_knocking"]:setVolume(1.2)
                    AudioSources["door_knocking"]:setPosition(-0.001, 0, 0)
                    AudioSources["door_knocking"]:play()
                    self.currentState = 2
                    self.position = math.random(1, 2)
                    self.timer = 0
                    self.patience = 0
                else
                    self:kill()
                end
            end
        end
    end
    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 7, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

return Foxy