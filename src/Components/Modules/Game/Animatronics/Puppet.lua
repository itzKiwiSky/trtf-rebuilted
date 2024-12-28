local PuppetAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
}

PuppetAI.__name__ = "Puppet" -- Nome da tabela

PuppetAI.released = false
PuppetAI.currentState = 8
PuppetAI.metadataCameraID = 0
PuppetAI.maxRewind = 2500
PuppetAI.position = 1
PuppetAI.musicBoxTimer = 2500
PuppetAI.musicAcc = 0
PuppetAI.path = {
    {950, 431, 1},          -- arcade
    {1165, 432, 2},         -- storage
    {1064, 323, 3},         -- dining_area
    {906, 339, 4},          -- pirate_cove
    {898, 267, 5},          -- parts_and_service
    {1064, 256, 6},         -- showstage
    {1018, 195, 7},         -- kitchen
    {1168, 362, 8},         -- prize_corner
    {999, 490, 9},          -- left_hall
    {1127, 490, 10},         -- right_hall
}

function PuppetAI.init()
    PuppetAI.x, PuppetAI.y, PuppetAI.metadataCameraID = PuppetAI.path[PuppetAI.currentState][1] + 23, PuppetAI.path[PuppetAI.currentState][2] + 3, PuppetAI.path[PuppetAI.currentState][3]
end

-- just for radar shit --
function PuppetAI.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[7], PuppetAI.x, PuppetAI.y, 0, 2, 2, 16, 16)
    end
end

function PuppetAI.update(elapsed)
    if PuppetAI.released then
        if officeState.tabletUp then
            if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] then
                AudioSources["msc_puppet_music_box"]:setPosition(0, 0, 0)
                if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] == tabletCameraSubState.camID then
                    AudioSources["msc_puppet_music_box"]:setVolume(1)
                else
                    AudioSources["msc_puppet_music_box"]:setVolume(0)
                end
            end
        elseif PuppetAI.currentState == 9 then
            AudioSources["msc_puppet_music_box"]:setPosition(-0.001, 0, 0)
            AudioSources["msc_puppet_music_box"]:setVolume(0.1)
        elseif PuppetAI.currentState == 10 then
            AudioSources["msc_puppet_music_box"]:setPosition(0.001, 0, 0)
            AudioSources["msc_puppet_music_box"]:setVolume(0.1)
        else
            AudioSources["msc_puppet_music_box"]:setPosition(0, 0, 0)
            AudioSources["msc_puppet_music_box"]:setVolume(0)
        end
    
        if PuppetAI.musicBoxTimer >= 1 then
            PuppetAI.musicAcc = PuppetAI.musicAcc + elapsed
            if PuppetAI.musicAcc >= 0.1 then
                PuppetAI.musicAcc = 0
                PuppetAI.musicBoxTimer = PuppetAI.musicBoxTimer - math.random(1, 6)
            end
            PuppetAI.timer = PuppetAI.timer + elapsed
            if PuppetAI.timer >= 7.3 then
                PuppetAI.move = math.random(0, 20)
                if PuppetAI.move <= NightState.animatronicsAI.puppet and NightState.animatronicsAI.puppet > 0 and not officeState.hasAnimatronicInOffice then
                    PuppetAI.position = math.random(1, 3)
                    if officeState.tabletUp then
                        if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] then
                            if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] == tabletCameraSubState.camID then
                                AudioSources["cam_animatronic_interference"]:seek(0)
                                tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                                AudioSources["cam_animatronic_interference"]:play()
                            end
                        end
                    end
                    PuppetAI.currentState = math.random(1, #PuppetAI.path)
                end
                PuppetAI.timer = 0
            end
        else
            if not AudioSources["sfx_jackbox"]:isPlaying() then
                AudioSources["sfx_jackbox"]:setLooping(true)
                AudioSources["sfx_jackbox"]:play()
            end
    
            PuppetAI.timer = PuppetAI.timer + elapsed
            if PuppetAI.timer >= 0.02 then
                PuppetAI.timer = 0
                PuppetAI.patience = PuppetAI.patience + 1
            end
            if PuppetAI.patience >= 150 then
                if not NightState.killed then
                    NightState.killed = true
                    jumpscareController:init("puppet", 35)
                    jumpscareController.onComplete = function()
                        NightState.KilledBy = "puppet"
                        gamestate.switch(DeathState)
                    end
                end
            end
        end
    else
        PuppetAI.timer = PuppetAI.timer + elapsed
        if PuppetAI.timer >= 4.3 then
            PuppetAI.move = math.random(0, 20)
            if PuppetAI.move <= NightState.animatronicsAI.puppet and NightState.animatronicsAI.puppet > 0 and not officeState.hasAnimatronicInOffice then
                PuppetAI.position = math.random(1, 3)
                if officeState.tabletUp then
                    if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                PuppetAI.released = true
                PuppetAI.timer = 0
                PuppetAI.currentState = 8
            end
        end
    end

    PuppetAI.x, PuppetAI.y, PuppetAI.metadataCameraID = PuppetAI.path[PuppetAI.currentState][1] + 3, PuppetAI.path[PuppetAI.currentState][2] + 3, PuppetAI.path[PuppetAI.currentState][3]
end

return PuppetAI