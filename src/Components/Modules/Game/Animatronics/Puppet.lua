local PuppetAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
}

PuppetAI.__name__ = "Bonnie" -- Nome da tabela

PuppetAI.currentState = 1
PuppetAI.metadataCameraID = 0
PuppetAI.path = {
    {1064, 256, 6},        -- showstage
    {950, 431, 1},         -- arcade
    {999, 490, 9},         -- left_hall
    {1076, 544, nil},        -- front_office
    {1079, 592, nil},        -- office
}

-- just for radar shit --
function PuppetAI.draw()
    --[[
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[2], PuppetAI.x, PuppetAI.y, 0, 2, 2, 16, 16)
    end]]
end

function PuppetAI.update(elapsed)
    --[[
    if PuppetAI.currentState <= 4 then
        PuppetAI.timer = PuppetAI.timer + elapsed
        if PuppetAI.timer >= 7.3 then
            PuppetAI.move = math.random(0, 20)
            if PuppetAI.move <= NightState.animatronicsAI.bonnie and NightState.animatronicsAI.bonnie > 0 and not officeState.hasAnimatronicInOffice then
                if officeState.tabletUp then
                    if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[PuppetAI.metadataCameraID] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                PuppetAI.currentState = PuppetAI.currentState + 1
                NightState.playWalk()

                if officeState.flashlight.state then
                    if PuppetAI.currentState == 4 then
                        officeState.flashlight.isFlicking = true
                    end
                end

                if DEBUG_APP then
                    print(string.format("[%s] Moved | MoveID: %s State: %s", PuppetAI.__name__, PuppetAI.move, PuppetAI.currentState))
                end
            else
                if DEBUG_APP then
                    print(string.format("[%s] Failed to move | MoveID: %s", PuppetAI.__name__, PuppetAI.move))
                end
            end
            PuppetAI.timer = 0
        end
    else
        if not AudioSources["stare"]:isPlaying() then
            AudioSources["stare"]:play()
        end

        PuppetAI.timer = PuppetAI.timer + elapsed
        if PuppetAI.timer >= 0.02 then
            PuppetAI.timer = 0
            PuppetAI.patience = PuppetAI.patience + 1
            officeState.hasAnimatronicInOffice = true
        end

        if officeState.hasAnimatronicInOffice then
            if PuppetAI.patience >= 150 and not officeState.maskUp then
                if not NightState.killed then
                    NightState.killed = true
                    jumpscareController:init("bonnie", 35)
                    jumpscareController.onComplete = function()
                        NightState.KilledBy = "bonnie"
                        gamestate.switch(DeathState)
                    end
                end
            elseif PuppetAI.patience >= 150 and officeState.maskUp then
                PuppetAI.patience = 0
                PuppetAI.timer = 0
                PuppetAI.currentState = 1
                officeState.hasAnimatronicInOffice = false
                AudioSources["stare"]:stop()
                officeState.fadealpha = 1
            end
        end
    end

    PuppetAI.x, PuppetAI.y, PuppetAI.metadataCameraID = PuppetAI.path[PuppetAI.currentState][1] + 3, PuppetAI.path[PuppetAI.currentState][2] + 3, PuppetAI.path[PuppetAI.currentState][3]
    ]]
end

return PuppetAI