local animatronic = require 'src.Modules.Game.Animatronic'

local Freddy = animatronic:extend("Freddy")

function Freddy:__construct()
    Freddy.super.__construct(self, "freddy", 0, 0)  -- wtf outside the map XDDD

    self.id = "freddy"
    self.path = {
        {
            {1064, 256, 6},        -- showstage
            {1064, 323, 3},         -- dining_area
            {950, 431, 1},         -- arcade 
            {999, 490, 9},         -- left_hall
            {1154, 569, nil},         -- freddy_hall
            {1079, 592, nil},        -- office
        },
        {
            {1064, 256, 6},        -- showstage
            {1064, 323, 3},         -- dining_area
            {1165, 432, 2},         -- storage 
            {1127, 490, 10},         -- right_hall
            {1154, 569, nil},         -- freddy_hall
            {1079, 592, nil},        -- office
        }
    }
    self.pathID = 1
    self.laughRand = 0
    self.laughID = 1
    self.flash = 0
    self.animState = false
    self.maxPatience = math.random(120, 230)

    --self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

local function playLaugh()
    self.laughID = math.random(1, 3)
    if AudioSources["laugh" .. self.laughID]:isPlaying() then
        AudioSources["laugh" .. self.laughID]:stop()
        AudioSources["laugh" .. self.laughID]:seek(0)
    end
    AudioSources["laugh" .. self.laughID]:play()
end

function Freddy:draw()
    Freddy.super.draw(self)
end

function Freddy:update(elapsed)
    if NightState.officeState.isOfficeDisabled then
        self.onMove = function()
            if self.currentState <= 4 then  -- when the lights goes off --
                self.currentState = self.currentState + 1
                self.pathID = 2
                self.moveTime = 5.75
                if self.currentState <= 3 then
                    self:playWalk()
                end
            elseif self.currentState == 5 then
                self.updateMoveTimer = false
                AudioSources["freddy_music_box"]:setVolume(1)
                if not AudioSources["freddy_music_box"]:isPlaying() then
                    AudioSources["freddy_music_box"]:play()
                end
                self.timer = self.timer + elapsed
                if self.timer >= 0.05 then
                    self.patience = self.patience + 1
                    self.timer = 0
                    if self.patience % 3 == 0 then
                        self.animState = not self.animState
                    end
                    if self.patience >= self.maxPatience - 15 then
                        NightState.officeState.hasAnimatronicInOffice = true
                    end
                    if self.patience >= self.maxPatience then
                        self.currentState = self.currentState + 1
                    end
                end
            elseif self.currentState == 6 then
                self:kill()
            end
        end
    else
        self.onMove = function()
            if not NightState.officeState.hasAnimatronicInFrontOffice then
                if self.currentState <= 4 then
                    if self.currentState == 1 or self.currentState == 2 then
                        self.pathID = math.random(1, 2)
                    end
                    self:moveAnimatronic()
                    if self.currentState > 2 then
                        if self.animatronicOnSameCamera then
                            if NightState.officeState.lightCam.state then
                                self.flash = self.flash + 1
                                if self.flash >= 100 then
                                    self.laughRand = math.random(1, 5)
                                    if self.laughRand == 2 then
                                        playLaugh()
                                    end
                                    self.currentState = self.currentState - 1
                                    self.timer = 0
                                    self.flash = 0
        
                                    self:moveAnimatronic()
                                end
                            end
                        end
                    end
                elseif self.currentState == 5 then
                    self.onMove = function()
                        if NightState.officeState.tabletUp then
                            if self.pathID == 1 and not NightState.officeState.doors.left then
                                self.currentState = self.currentState + 1
                            elseif self.pathID == 2 and not NightState.officeState.doors.right then
                                self.currentState = self.currentState + 1
                            end
                        end
                    end
                elseif self.currentState == 6 then
                    self:kill()
                end
            end

            self.x, self.y, self.metadataCameraID = self.path[self.pathID][self.currentState].x + 26, self.path[self.pathID][self.currentState].y + 26, self.path[self.pathID][self.currentState].camera
        end
    end
end

return Freddy