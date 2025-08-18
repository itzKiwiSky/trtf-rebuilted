local tabletCameraSubState = require 'src.States.Substates.TabletCameraSubstate'
local FreddyAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
    maxPatience = math.random(100, 200)
}

FreddyAI.__name__ = "Freddy"

FreddyAI.currentState = 1
FreddyAI.metadataCameraID = 0
FreddyAI.pathID = 1
FreddyAI.laughRand = 0
FreddyAI.laughID = 1
FreddyAI.flash = 0
FreddyAI.animState = false
FreddyAI.path = {
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

function FreddyAI.init()
    FreddyAI.x, FreddyAI.y, FreddyAI.metadataCameraID = FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][1] + 26, FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][2] + 26, FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][3]
end

-- just for radar shit --
function FreddyAI.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[1], FreddyAI.x, FreddyAI.y, 0, 2, 2, 16, 16)
    end
end

function FreddyAI.update(elapsed)
    if NightState.officeState.isOfficeDisabled then
        if FreddyAI.currentState <= 4 then
            FreddyAI.pathID = 2
            FreddyAI.timer = FreddyAI.timer + elapsed
            if FreddyAI.timer >= 5.5 then
                FreddyAI.move = math.random(0, 20)
                if FreddyAI.move <= NightState.animatronicsAI.freddy and NightState.animatronicsAI.freddy > 0 then
                    if FreddyAI.currentState == 4 then
                        FreddyAI.laughID = math.random(1, 3)
                        if AudioSources["laugh" .. FreddyAI.laughID]:isPlaying() then
                            AudioSources["laugh" .. FreddyAI.laughID]:stop()
                            AudioSources["laugh" .. FreddyAI.laughID]:seek(0)
                        end
                        AudioSources["laugh" .. FreddyAI.laughID]:play()
                    end
                    FreddyAI.currentState = FreddyAI.currentState + 1
                    if FreddyAI.currentState <= 3 then
                        NightState.playWalk()
                    end
                end
                FreddyAI.timer = 0
            end
        elseif FreddyAI.currentState == 5 then
            AudioSources["freddy_music_box"]:setVolume(1)
            if not AudioSources["freddy_music_box"]:isPlaying() then
                AudioSources["freddy_music_box"]:play()
            end
            FreddyAI.timer = FreddyAI.timer + elapsed
            if FreddyAI.timer >= 0.05 then
                FreddyAI.patience = FreddyAI.patience + 1
                FreddyAI.timer = 0
                if FreddyAI.patience % 3 == 0 then
                    FreddyAI.animState = not FreddyAI.animState
                end
                if FreddyAI.patience >= FreddyAI.maxPatience - 15 then
                    NightState.officeState.hasAnimatronicInOffice = true
                end
                if FreddyAI.patience >= FreddyAI.maxPatience then
                    FreddyAI.currentState = FreddyAI.currentState + 1
                end
            end
        elseif FreddyAI.currentState >= 6 then
            if not NightState.killed then
                NightState.killed = true
                NightState.jumpscareController.id = "freddy_power_out"
                NightState.jumpscareController.speedAnim = 35
                NightState.jumpscareController.init()
                NightState.jumpscareController.onComplete = function()
                    NightState.KilledBy = "freddy"
                    gamestate.switch(DeathState)
                end
            end
        end
    else
        if FreddyAI.currentState <= 4 then
            FreddyAI.timer = FreddyAI.timer + elapsed
            if FreddyAI.timer >= 12.5 then
                FreddyAI.move = math.random(0, 20)
                if FreddyAI.move <= NightState.animatronicsAI.freddy and NightState.animatronicsAI.freddy > 0 and not NightState.officeState.hasAnimatronicInOffice then
                    if FreddyAI.currentState == 1 or FreddyAI.currentState == 2 then
                        FreddyAI.pathID = math.random(1, 2)
                    end
                    if NightState.officeState.tabletUp then
                        if tabletCameraSubState.camerasID[FreddyAI.metadataCameraID] then
                            if tabletCameraSubState.camerasID[FreddyAI.metadataCameraID] == tabletCameraSubState.camID then
                                AudioSources["cam_animatronic_interference"]:seek(0)
                                tabletCameraSubState:doInterference(0.1, 200, 200, 6)
                                AudioSources["cam_animatronic_interference"]:play()
                            end
                        end
                    end
                    FreddyAI.currentState = FreddyAI.currentState + 1
                    NightState.playWalk()
                end
                FreddyAI.timer = 0
            end
            if FreddyAI.currentState > 2 then
                if NightState.officeState.tabletUp then
                    if tabletCameraSubState.camerasID[FreddyAI.metadataCameraID] == tabletCameraSubState.camID then
                        if NightState.officeState.lightCam.state then
                            FreddyAI.flash = FreddyAI.flash + 1
                            if FreddyAI.flash >= 100 then
                                FreddyAI.laughRand = math.random(1, 5)
                                if FreddyAI.laughRand == 2 then
                                    FreddyAI.laughID = math.random(1, 3)
                                    if AudioSources["laugh" .. FreddyAI.laughID]:isPlaying() then
                                        AudioSources["laugh" .. FreddyAI.laughID]:stop()
                                        AudioSources["laugh" .. FreddyAI.laughID]:seek(0)
                                    end
                                    AudioSources["laugh" .. FreddyAI.laughID]:play()
                                end
                                FreddyAI.currentState = FreddyAI.currentState - 1
                                FreddyAI.timer = 0
                                FreddyAI.flash = 0
    
                                AudioSources["cam_animatronic_interference"]:seek(0)
                                tabletCameraSubState:doInterference(0.1, 200, 200, 6)
                                AudioSources["cam_animatronic_interference"]:play()
                            end
                        end
                    end
                end
            end
        elseif FreddyAI.currentState == 5 then
            FreddyAI.timer = FreddyAI.timer + elapsed
            if FreddyAI.timer >= 3.4 then
                FreddyAI.move = math.random(0, 20)
                if FreddyAI.move <= NightState.animatronicsAI.freddy and NightState.animatronicsAI.freddy > 0 and not NightState.officeState.hasAnimatronicInOffice then
                    if NightState.officeState.tabletUp then
                        if FreddyAI.pathID == 1 and not NightState.officeState.doors.left then
                            FreddyAI.currentState = FreddyAI.currentState + 1
                        elseif FreddyAI.pathID == 2 and not NightState.officeState.doors.right then
                            FreddyAI.currentState = FreddyAI.currentState + 1
                        end
                    end
                end
                FreddyAI.timer = 0
            end
        elseif FreddyAI.currentState >= 6 then
            if not NightState.killed then
                NightState.killed = true
                NightState.jumpscareController.id = "freddy"
                NightState.jumpscareController.speedAnim = 35
                NightState.jumpscareController.init()
                NightState.jumpscareController.onComplete = function()
                    NightState.KilledBy = "freddy"
                    gamestate.switch(DeathState)
                end
            end
        end
        FreddyAI.x, FreddyAI.y, FreddyAI.metadataCameraID = FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][1] + 26, FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][2] + 26, FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][3]
    end
end

return FreddyAI