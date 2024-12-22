local ChicaAi = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
    stared = false
}

ChicaAi.__name__ = "Chica" -- Nome da tabela

ChicaAi.currentState = 1
ChicaAi.metadataCameraID = 0
ChicaAi.path = {
    {1124, 256, 6},        -- showstage
    {1064, 323, 3},         -- dining_area
    {1165, 432, 2},         -- storage
    {1127, 490, 10},         -- right_hall
    {1116, 544, nil},        -- front_office
    {1079, 592, nil},        -- office
}

function ChicaAi.init()
    ChicaAi.x, ChicaAi.y, ChicaAi.metadataCameraID = ChicaAi.path[ChicaAi.currentState][1] + 3, ChicaAi.path[ChicaAi.currentState][2] + 3, ChicaAi.path[ChicaAi.currentState][3]
end

-- just for radar shit --
function ChicaAi.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[3], ChicaAi.x, ChicaAi.y, 0, 2, 2, 16, 16)
    end
end

function ChicaAi.update(elapsed)
    if ChicaAi.currentState <= 4 then
        ChicaAi.timer = ChicaAi.timer + elapsed
        if ChicaAi.timer >= 9.3 then
            ChicaAi.move = math.random(0, 20)
            if ChicaAi.move <= NightState.animatronicsAI.chica and NightState.animatronicsAI.chica > 0 and not officeState.hasAnimatronicInOffice then
                if officeState.tabletUp then
                    if tabletCameraSubState.camerasID[ChicaAi.metadataCameraID] then
                        if tabletCameraSubState.camerasID[ChicaAi.metadataCameraID] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                ChicaAi.currentState = ChicaAi.currentState + 1
                NightState.playWalk()

                if officeState.flashlight.state then
                    if ChicaAi.currentState == 4 then
                        officeState.flashlight.isFlicking = true
                    end
                end

                if DEBUG_APP then
                    print(string.format("[%s] Moved | MoveID: %s State: %s", ChicaAi.__name__, ChicaAi.move, ChicaAi.currentState))
                end
            else
                if DEBUG_APP then
                    print(string.format("[%s] Failed to move | MoveID: %s", ChicaAi.__name__, ChicaAi.move))
                end
            end
            ChicaAi.timer = 0
        end
    else
        if not AudioSources["stare"]:isPlaying() then
            AudioSources["stare"]:play()
        end

        ChicaAi.timer = ChicaAi.timer + elapsed
        if ChicaAi.timer >= 0.02 then
            ChicaAi.timer = 0
            ChicaAi.patience = ChicaAi.patience + 1
            officeState.hasAnimatronicInOffice = true
        end

        if officeState.hasAnimatronicInOffice then
            if ChicaAi.patience >= 150 and not officeState.maskUp then
                if not NightState.killed then
                    NightState.killed = true
                    jumpscareController:init("chica", 35)
                    jumpscareController.onComplete = function()
                        NightState.KilledBy = "chica"
                        gamestate.switch(DeathState)
                    end
                end
            elseif ChicaAi.patience >= 150 and officeState.maskUp then
                ChicaAi.patience = 0
                ChicaAi.timer = 0
                ChicaAi.currentState = 1
                officeState.hasAnimatronicInOffice = false
                AudioSources["stare"]:stop()
                officeState.fadealpha = 1
            end
        end
    end

    ChicaAi.x, ChicaAi.y, ChicaAi.metadataCameraID = ChicaAi.path[ChicaAi.currentState][1] + 3, ChicaAi.path[ChicaAi.currentState][2] + 3, ChicaAi.path[ChicaAi.currentState][3]
end

return ChicaAi