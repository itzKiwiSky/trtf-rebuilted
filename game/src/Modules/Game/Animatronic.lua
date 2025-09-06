local Animatronic = class:extend("Animatronic")

function Animatronic:__construct(id, x, y)
    self.id = id
    self.x = x or 0
    self.y = y or 0
    self.w = 32
    self.h = 32

    self.currentState = 1
    self.path = {}
    self.timer = 0
    self.move = 0
    self.patience = 0
    self.stared = false
    self.metadataCameraID = 0
    self.moveTime = 0

    self.onMove = function()end
end

function Animatronic.playWalk()
    local r = math.random(1, 3)
    if not AudioSources["metalwalk" .. r]:isPlaying() then
        AudioSources["metalwalk" .. r]:play()
    end
end

function Animatronic:draw()
    local scale = 2
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[self.id], self.x, self.y, 0, scale, scale, 16, 16)
    end
end

function Animatronic:kill()
    if not NightState.killed then
        NightState.killed = true
        NightState.jumpscareController.id = self.id
        NightState.jumpscareController.speedAnim = 35
        NightState.jumpscareController.init()
        NightState.jumpscareController.onComplete = function()
            NightState.KilledBy = self.id
            gamestate.switch(DeathState)
        end
    end
end

function Animatronic:interference()
    if NightState.tabletCameraSubState.camerasID[self.metadataCameraID] then
        if NightState.tabletCameraSubState.camerasID[self.metadataCameraID] == NightState.tabletCameraSubState.camID then
            AudioSources["cam_animatronic_interference"]:seek(0)
            NightState.tabletCameraSubState:doInterference(0.1, 200, 200, 6)
            AudioSources["cam_animatronic_interference"]:play()
        end
    end
end

function Animatronic:update(elapsed)
    self.timer = self.timer + elapsed
    if self.timer >= self.moveTime then
        self.move = math.random(0, 20)
        if self.move <= NightState.animatronicsAI[self.id] and NightState.animatronicsAI[self.id] > 0 and not NightState.officeState.hasAnimatronicInOffice then
            self.onMove()
        end
        self.timer = 0
    end
    
    if #self.path > 0 then
        self.x, self.y, self.metadataCameraID = self.path[self.currentState].x + 3, self.path[self.currentState].y + 3, self.path[self.currentState].camera
    end
end

return Animatronic