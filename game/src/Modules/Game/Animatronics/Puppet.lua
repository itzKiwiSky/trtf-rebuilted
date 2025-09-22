local animatronic = require 'src.Modules.Game.Animatronic'

local Puppet = animatronic:extend("Puppet")

function Puppet:__construct()
    Puppet.super.__construct(self, "puppet", 0, 0)  -- wtf outside the map XDDD

    self.id = "puppet"

    self.released = false
    self.currentState = 8
    self.metadataCameraID = 0
    self.maxRewind = 2800
    self.position = 1
    self.musicBoxTimer = self.maxRewind
    self.musicAcc = 0
    self.path = {
        { x = 950, y = 431, camera = 1},          -- arcade
        { x = 1165, y = 432, camera = 2},         -- storage
        { x = 1064, y = 323, camera = 3},         -- dining_area
        { x = 906, y = 339, camera = 4},          -- pirate_cove
        { x = 898, y = 267, camera = 5},          -- parts_and_service
        { x = 1064, y = 256, camera = 6},         -- showstage
        { x = 1018, y = 195, camera = 7},         -- kitchen
        { x = 1168, y = 362, camera = 8},         -- prize_corner
        { x = 999, y = 490, camera = 9},          -- left_hall
        { x = 1127, y = 490, camera = 10},         -- right_hall
    }

    self.moveTime = 7.4
    self.releaseTimer = 8.4

    self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
end

function Puppet:draw()
    Puppet.super.draw(self)
end

function Puppet:update(elapsed)
    if self.released then
        Puppet.super.update(self, elapsed)
        if NightState.officeState.tabletUp then
            if NightState.tabletCameraSubState.camerasID[self.metadataCameraID] then
                AudioSources["msc_puppet_music_box"]:setPosition(0, 0, 0)
                if NightState.tabletCameraSubState.camerasID[self.metadataCameraID] == NightState.tabletCameraSubState.camID then
                    AudioSources["msc_puppet_music_box"]:setVolume(1)
                else
                    AudioSources["msc_puppet_music_box"]:setVolume(0)
                end
            end
        elseif self.currentState == 9 then
            AudioSources["msc_puppet_music_box"]:setPosition(-0.001, 0, 0)
            AudioSources["msc_puppet_music_box"]:setVolume(0.1)
        elseif self.currentState == 10 then
            AudioSources["msc_puppet_music_box"]:setPosition(0.001, 0, 0)
            AudioSources["msc_puppet_music_box"]:setVolume(0.1)
        else
            AudioSources["msc_puppet_music_box"]:setPosition(0, 0, 0)
            AudioSources["msc_puppet_music_box"]:setVolume(0)
        end
        
        self.onMove = function()
            if self.musicBoxTimer >= 0 then
                self.position = math.random(1, 3)
                --self:moveAnimatronic()
                self:interference()
                self.currentState = math.random(1, #self.path)
            end
        end
        if self.musicBoxTimer >= 1 then
            self.musicAcc = self.musicAcc + elapsed
            if self.musicAcc >= 0.075 then
                self.musicAcc = 0
                self.musicBoxTimer = self.musicBoxTimer - math.random(1, 5)
            end
        else
            AudioSources["msc_puppet_music_box"]:stop()
            if not AudioSources["sfx_jackbox"]:isPlaying() then
                AudioSources["sfx_jackbox"]:setLooping(true)
                AudioSources["sfx_jackbox"]:play()
            end
    
            self.timer = self.timer + elapsed
            if self.timer >= 0.02 then
                self.timer = 0
                self.patience = self.patience + 10 * elapsed
            end
            if self.patience >= 5 then
                self:kill()
            end
        end
    else
        if NightState.animatronicsAI[self.id] > 0 then
            self.timer = self.timer + elapsed
            if self.timer >= self.releaseTimer then
                self.released = true
                self.timer = 0
                self.currentState = 8
                self.position = math.random(1, 3)
                self:moveAnimatronic()
            end
        end
    end

    --self:setupIconPosition()
end

return Puppet