local animatronic = require 'src.Modules.Game.Animatronic'

local Freddy = animatronic:extend("Freddy")

function Freddy:__construct()
    Freddy.super.__construct(self, "freddy", 0, 0)  -- wtf outside the map XDDD

    self.id = "freddy"
    self.currentState = 1
    self.path = {
        {
            {x = 1064, y = 256, camera = 6},        -- showstage
            {x = 1064, y = 323, camera = 3},         -- dining_area
            {x = 950, y = 431, camera = 1},         -- arcade 
            {x = 999, y = 490, camera = 9},         -- left_hall
            {x = 1154, y = 569, camera = nil},         -- freddy_hall
            {x = 1079, y = 592, camera = nil},        -- office
        },
        {
            {x = 1064, y = 256, camera = 6},        -- showstage
            {x = 1064, y = 323, camera = 3},         -- dining_area
            {x = 1165, y = 432, camera = 2},         -- storage 
            {x = 1127, y = 490, camera = 10},         -- right_hall
            {x = 1154, y = 569, camera = nil},         -- freddy_hall
            {x = 1079, y = 592, camera = nil},        -- office
        }
    }
    self.pathID = 1
    self.laughRand = 0
    self.laughID = 1
    self.flash = 0
    self.animState = false
    self.maxPatience = math.random(180, 280)
    self.updateMoveTimer = true
    self.autoUpdatePos = false
    self.moveTime = 8.5
    self.flashMax = 1200

    self.x, self.y, self.metadataCameraID = self.path[self.pathID][self.currentState].x + 26, self.path[self.pathID][self.currentState].y + 26, self.path[self.pathID][self.currentState].camera

    --self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

local function playLaugh(self)
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
        Freddy.super.update(self, elapsed)
        self.onMove = function()
            if self.currentState <= 4 then  -- when the lights goes off --
                self.currentState = self.currentState + 1
                self.pathID = 2
                self.moveTime = 5.75
                if self.currentState <= 3 then
                    self:playWalk()
                end
            end
        end

        if self.currentState == 5 then
            self.updateMoveTimer = false
            AudioSources["freddy_music_box"]:setVolume(1)
            if not AudioSources["freddy_music_box"]:isPlaying() then
                AudioSources["freddy_music_box"]:play()
            end
            self.timer = self.timer + elapsed
            if self.timer >= 0.05 then
                self.patience = self.patience + 1
                self.timer = 0
                if self.patience % 2 == 0 then
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
            self.id = "freddy_power_out"
            if not NightState.killed then
                NightState.killed = true
                NightState.jumpscareController.id = self.id
                NightState.jumpscareController.speedAnim = 24
                NightState.jumpscareController.init()
                NightState.jumpscareController.onComplete = function()
                    NightState.KilledBy = self.id
                    gamestate.switch(DeathState)
                end
            end
        end
    else
        Freddy.super.update(self, elapsed)
        if self.currentState <= 4 then
            if self.currentState > 2 then
                if self.animatronicOnSameCamera then
                    if NightState.officeState.lightCam.state then
                        self.flash = self.flash + 1
                        if self.flash >= self.flashMax then
                            self.laughRand = math.random(1, 5)
                            if self.laughRand == 2 then
                                playLaugh(self)
                            end
                            self.currentState = self.currentState - 1
                            self.timer = 0
                            self.flash = 0
        
                            self:moveAnimatronic()
                        end
                    end
                end
            end
        end

        self.onMove = function()
            if not NightState.officeState.hasAnimatronicInFrontOffice then
                if self.currentState <= 4 then
                    print("moved")
                    if self.currentState == 1 or self.currentState == 2 then
                        self.pathID = math.random(1, 2)
                    end
                    self.currentState = self.currentState + 1
                    self:moveAnimatronic()
                elseif self.currentState == 5 then
                    if NightState.officeState.tabletUp then
                        if self.pathID == 1 and not NightState.officeState.doors.left then
                            self.currentState = self.currentState + 1
                        elseif self.pathID == 2 and not NightState.officeState.doors.right then
                            self.currentState = self.currentState + 1
                        end
                    end
                elseif self.currentState == 6 then
                    self:kill()
                end
            end
        end
        self.x, self.y, self.metadataCameraID = self.path[self.pathID][self.currentState].x + 26, self.path[self.pathID][self.currentState].y + 26, self.path[self.pathID][self.currentState].camera
    end
end

return Freddy