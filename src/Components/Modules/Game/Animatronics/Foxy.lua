local FoxyAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
}

FoxyAI.__name__ = "Foxy" -- Nome da tabela

FoxyAI.currentState = 1
FoxyAI.metadataCameraID = 0
FoxyAI.position = 1
FoxyAI.direction = "none"
FoxyAI.path = {
    {906, 339, 4},  -- pirate_cove
    {1076, 544, nil},        -- front_office
    {1076, 544, nil},        -- front_office
    {1076, 544, nil},        -- front_office
    {1076, 544, nil},        -- front_office
    {1079, 592, nil},        -- office
}

local function kill()
    if not NightState.killed then
        NightState.killed = true
        jumpscareController:init("foxy", 35)
        jumpscareController.onComplete = function()
            NightState.KilledBy = "foxy"
            gamestate.switch(DeathState)
        end
    end
end

function FoxyAI.init()
    FoxyAI.x, FoxyAI.y, FoxyAI.metadataCameraID = FoxyAI.path[FoxyAI.currentState][1] + 7, FoxyAI.path[FoxyAI.currentState][2] + 3, FoxyAI.path[FoxyAI.currentState][3]
end

-- just for radar shit --
function FoxyAI.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[4], FoxyAI.x, FoxyAI.y, 0, 2, 2, 16, 16)
    end
end

function FoxyAI.update(elapsed)
    if FoxyAI.currentState <= 1 then
        FoxyAI.timer = FoxyAI.timer + elapsed
        if FoxyAI.timer >= 7.3 then
            FoxyAI.move = math.random(0, 20)
            if FoxyAI.move <= NightState.animatronicsAI.foxy and NightState.animatronicsAI.foxy > 0 and not officeState.hasAnimatronicInOffice then
                if officeState.tabletUp then
                    if tabletCameraSubState.camerasID[FoxyAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[FoxyAI.metadataCameraID] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                FoxyAI.currentState = 2
                NightState.playWalk()

                if officeState.flashlight.state then
                    officeState.flashlight.isFlicking = true
                end

                if DEBUG_APP then
                    print(string.format("[%s] Moved | MoveID: %s State: %s", FoxyAI.__name__, FoxyAI.move, FoxyAI.currentState))
                end
            else
                FoxyAI.position = math.random(1, 2)
                if DEBUG_APP then
                    print(string.format("[%s] Failed to move | MoveID: %s", FoxyAI.__name__, FoxyAI.move))
                end
            end
            FoxyAI.timer = 0
        end
    elseif FoxyAI.currentState == 2 then
        FoxyAI.timer = FoxyAI.timer + elapsed
        if FoxyAI.timer >= 14.8 then
            FoxyAI.move = math.random(0, 20)
            if FoxyAI.move <= NightState.animatronicsAI.foxy and NightState.animatronicsAI.foxy > 0 and not officeState.hasAnimatronicInOffice then
                if officeState.flashlight.state then
                    officeState.flashlight.isFlicking = true
                end

                if DEBUG_APP then
                    print(string.format("[%s] Moved | MoveID: %s State: %s", FoxyAI.__name__, FoxyAI.move, FoxyAI.currentState))
                end
                FoxyAI.currentState = 3
            else
                if DEBUG_APP then
                    print(string.format("[%s] Failed to move | MoveID: %s", FoxyAI.__name__, FoxyAI.move))
                end
            end
            FoxyAI.timer = 0
        end
    elseif FoxyAI.currentState == 3 then
        FoxyAI.timer = FoxyAI.timer + elapsed
        if FoxyAI.timer >= 0.02 then
            FoxyAI.timer = 0
            FoxyAI.patience = FoxyAI.patience + 1
        end

        if FoxyAI.patience >= 160 - NightState.animatronicsAI.foxy then
            FoxyAI.currentState = math.random(4, 5)
        end
    elseif FoxyAI.currentState == 4 then
        FoxyAI.position = 3
        FoxyAI.timer = FoxyAI.timer + elapsed
        if FoxyAI.timer >= 0.05 then
            FoxyAI.timer = 0
            FoxyAI.patience = FoxyAI.patience + 1
        end

        if FoxyAI.patience >= 180 then
            FoxyAI.direction = "right"
            FoxyAI.patience = 0
            FoxyAI.currentState = 6
        end
    elseif FoxyAI.currentState == 5 then
        FoxyAI.position = 4
        FoxyAI.timer = FoxyAI.timer + elapsed
        if FoxyAI.timer >= 0.02 then
            FoxyAI.timer = 0
            FoxyAI.patience = FoxyAI.patience + 1
        end

        if FoxyAI.patience >= 180 then
            FoxyAI.direction = "left"
            FoxyAI.patience = 0
            FoxyAI.currentState = 6
        end
    elseif FoxyAI.currentState == 6 then
        AudioSources["run"]:setVolume(1)
        FoxyAI.timer = FoxyAI.timer + elapsed
        if FoxyAI.timer >= 0.034 then
            FoxyAI.timer = 0
            FoxyAI.patience = FoxyAI.patience + 1
            if FoxyAI.patience == 20 then
                if not AudioSources["run"]:isPlaying() then
                    if FoxyAI.direction == "right" then
                        AudioSources["run"]:seek(0)
                        AudioSources["run"]:setPosition(-0.001, 0, 0)
                        AudioSources["run"]:play()
                    elseif FoxyAI.direction == "left" then
                        AudioSources["run"]:seek(0)
                        AudioSources["run"]:setPosition(0.001, 0, 0)
                        AudioSources["run"]:play()
                    end
                end
            end
        end

        if FoxyAI.patience >= 90 then
            if FoxyAI.direction == "left" then
                if officeState.doors.left then
                    AudioSources["door_knocking"]:setVolume(1)
                    AudioSources["door_knocking"]:setPosition(0.001, 0, 0)
                    AudioSources["door_knocking"]:play()
                    FoxyAI.currentState = 2
                    FoxyAI.timer = 0
                    FoxyAI.position = math.random(1, 2)
                    FoxyAI.patience = 0
                else
                    kill()
                end
            elseif FoxyAI.direction == "right" then
                if officeState.doors.right then
                    AudioSources["door_knocking"]:setVolume(1)
                    AudioSources["door_knocking"]:setPosition(-0.001, 0, 0)
                    AudioSources["door_knocking"]:play()
                    FoxyAI.currentState = 2
                    FoxyAI.position = math.random(1, 2)
                    FoxyAI.timer = 0
                    FoxyAI.patience = 0
                else
                    kill()
                end
            end
        end
    end
    FoxyAI.x, FoxyAI.y, FoxyAI.metadataCameraID = FoxyAI.path[FoxyAI.currentState][1] + 7, FoxyAI.path[FoxyAI.currentState][2] + 3, FoxyAI.path[FoxyAI.currentState][3]
end

return FoxyAI