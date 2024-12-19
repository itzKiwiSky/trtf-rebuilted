local FreddyAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
}

FreddyAI.__name__ = "Freddy" -- Nome da tabela

FreddyAI.currentState = 1
FreddyAI.metadataCameraID = 0
FreddyAI.pathID = 1
FreddyAI.laughRand = 0
FreddyAI.laughID = 1
FreddyAI.flash = 0
FreddyAI.path = {
    {
        {1064, 256, 6},        -- showstage
        {1064, 323, 1},         -- dining_area
        {1165, 432, 3},         -- storage 
        {999, 490, 9},         -- left_hall
        {1154, 569, nil},         -- freddy_hall
        {1079, 592, nil},        -- office
    },
    {
        {1064, 256, 6},        -- showstage
        {1064, 323, 1},         -- dining_area
        {1165, 432, 3},         -- storage 
        {1127, 490, 8},         -- right_hall
        {1154, 569, nil},         -- freddy_hall
        {1079, 592, nil},        -- office
    }
}

-- just for radar shit --
function FreddyAI.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[1], FreddyAI.x, FreddyAI.y, 0, 2, 2, 16, 16)
    end
end

function FreddyAI.update(elapsed)
    if FreddyAI.currentState <= 4 then
        FreddyAI.timer = FreddyAI.timer + elapsed
        if FreddyAI.timer >= 12.5 then
            FreddyAI.move = math.random(0, 20)
            if FreddyAI.move <= NightState.animatronicsAI.freddy and NightState.animatronicsAI.freddy > 0 and not officeState.hasAnimatronicInOffice then
                if FreddyAI.currentState == 1 or FreddyAI.currentState == 2 then
                    FreddyAI.pathID = math.random(1, 2)
                end
                if officeState.tabletUp then
                    if tabletCameraSubState.camerasID[FreddyAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[FreddyAI.metadataCameraID] == tabletCameraSubState.camID then
                            if officeState.lightCam.state then
                                FreddyAI.flash = FreddyAI.flash + 1
                                if FreddyAI.flash > 100 and FreddyAI.currentState > 1 then
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
                                end
                            end
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                FreddyAI.currentState = FreddyAI.currentState + 1
                NightState.playWalk()

                if DEBUG_APP then
                    print(string.format("[%s] Moved | MoveID: %s State: %s", FreddyAI.__name__, FreddyAI.move, FreddyAI.currentState))
                end
            else
                if DEBUG_APP then
                    print(string.format("[%s] Failed to move | MoveID: %s", FreddyAI.__name__, FreddyAI.move))
                end
            end
            FreddyAI.timer = 0
        end
    elseif FreddyAI.currentState == 5 then
        FreddyAI.timer = FreddyAI.timer + elapsed
        if FreddyAI.timer >= 12.5 then
            FreddyAI.move = math.random(0, 20)
            if FreddyAI.move <= NightState.animatronicsAI.freddy and NightState.animatronicsAI.freddy > 0 and not officeState.hasAnimatronicInOffice then
                if officeState.tabletUp then
                    if FreddyAI.pathID == 1 and officeState.doors.left then
                        FreddyAI.currentState = FreddyAI.currentState + 1
                    elseif FreddyAI.pathID == 2 and officeState.doors.right then
                        FreddyAI.currentState = FreddyAI.currentState + 1
                    end
                end
            end
            FreddyAI.timer = 0
        end
    elseif FreddyAI.currentState >= 6 then
        if not NightState.killed then
            NightState.killed = true
            jumpscareController:init("freddy", 35)
            jumpscareController.onComplete = function()
                NightState.KilledBy = "freddy"
                gamestate.switch(DeathState)
            end
        end
    end

    FreddyAI.x, FreddyAI.y, FreddyAI.metadataCameraID = FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][1] + 6, FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][2] + 6, FreddyAI.path[FreddyAI.pathID][FreddyAI.currentState][3]
end

return FreddyAI