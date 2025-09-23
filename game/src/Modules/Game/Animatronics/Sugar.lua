local animatronic = require 'src.Modules.Game.Animatronic'

local Sugar = animatronic:extend("Sugar")

function Sugar:__construct()
    Sugar.super.__construct(self, "sugar", 0, 0)  -- wtf outside the map XDDD

    self.id = "sugar"
    self.active = false
    self.path = {
        { x = 898, y =  267, camera = 5 },         -- storage
        { x = 1064, y =  323, camera = 3 },         -- dining_area
        { x = 906, y =  339, camera = 4 },
        { x = 1116, y =  636, camera = 12 },        -- left_vent
        { x = 1116, y =  636, camera = 12 },        -- office
    }
    
    self.moveTime = 4.3
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
        Kitty.super.update(self, elapsed)
        self.onMove = function()
            if self.currentState <= 3 then
                self.currentState = self.currentState + 1
                self:moveAnimatronic()
            elseif self.currentState == 4 then
                AudioSources["vent_walk"]:seek(0)
                AudioSources["vent_walk"]:play()
            end
        end

        if self.currentState == 4 then
            self.patienceTimer = self.patienceTimer + elapsed
            if self.patienceTimer >= 0.04 then
                self.patienceTimer = 0
                self.patience = self.patience + 1
            end
    
            if not NightState.officeState.hasAnimatronicInOffice then
                if self.patience >= 350 and not NightState.officeState.vent.right then
                    if not NightState.killed then
                        self:kill()
                    end
                elseif self.patience >= 350 and NightState.officeState.vent.right then
                    AudioSources["vent_amb2"]:seek(0)
                    AudioSources["vent_amb2"]:play()
                    self.patience = 0
                    self.timer = 0
                    self.currentState = 2
                end
            end
        end
    else
        Kitty.super.update(self, elapsed)
        self.onMove = function()
            self:moveAnimatronic()
            self.moveTime = 9.52
            self.active = true
            self.timer = 0
        end
    end
end

return Sugar