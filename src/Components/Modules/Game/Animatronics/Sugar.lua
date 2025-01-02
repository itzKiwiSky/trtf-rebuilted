local SugarAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
}

SugarAI.__name__ = "Bonnie"

SugarAI.currentState = 1
SugarAI.metadataCameraID = 0
SugarAI.path = {
    {1064, 256, 6},        -- showstage
    {950, 431, 1},         -- arcade
    {999, 490, 9},         -- left_hall
    {1076, 544, nil},        -- front_office
    {1079, 592, nil},        -- office
}

function SugarAI.init()

end

-- just for radar shit --
function SugarAI.draw()
    --[[
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[2], SugarAI.x, SugarAI.y, 0, 2, 2, 16, 16)
    end]]
end

function SugarAI.update(elapsed)
    --[[
    if SugarAI.currentState <= 4 then
        SugarAI.timer = SugarAI.timer + elapsed
        if SugarAI.timer >= 7.3 then
            SugarAI.move = math.random(0, 20)
            if SugarAI.move <= NightState.animatronicsAI.bonnie and NightState.animatronicsAI.bonnie > 0 and not officeState.hasAnimatronicInOffice then
                if officeState.tabletUp then
                    if tabletCameraSubState.camerasID[SugarAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[SugarAI.metadataCameraID] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                SugarAI.currentState = SugarAI.currentState + 1
                NightState.playWalk()

                if officeState.flashlight.state then
                    if SugarAI.currentState == 4 then
                        officeState.flashlight.isFlicking = true
                    end
                end

                if DEBUG_APP then
                    print(string.format("[%s] Moved | MoveID: %s State: %s", SugarAI.__name__, SugarAI.move, SugarAI.currentState))
                end
            else
                if DEBUG_APP then
                    print(string.format("[%s] Failed to move | MoveID: %s", SugarAI.__name__, SugarAI.move))
                end
            end
            SugarAI.timer = 0
        end
    else
        if not AudioSources["stare"]:isPlaying() then
            AudioSources["stare"]:play()
        end

        SugarAI.timer = SugarAI.timer + elapsed
        if SugarAI.timer >= 0.02 then
            SugarAI.timer = 0
            SugarAI.patience = SugarAI.patience + 1
            officeState.hasAnimatronicInOffice = true
        end

        if officeState.hasAnimatronicInOffice then
            if SugarAI.patience >= 150 and not officeState.maskUp then
                if not NightState.killed then
                    NightState.killed = true
                    jumpscareController:init("bonnie", 35)
                    jumpscareController.onComplete = function()
                        NightState.KilledBy = "bonnie"
                        gamestate.switch(DeathState)
                    end
                end
            elseif SugarAI.patience >= 150 and officeState.maskUp then
                SugarAI.patience = 0
                SugarAI.timer = 0
                SugarAI.currentState = 1
                officeState.hasAnimatronicInOffice = false
                AudioSources["stare"]:stop()
                officeState.fadealpha = 1
            end
        end
    end

    SugarAI.x, SugarAI.y, SugarAI.metadataCameraID = SugarAI.path[SugarAI.currentState][1] + 3, SugarAI.path[SugarAI.currentState][2] + 3, SugarAI.path[SugarAI.currentState][3]
    ]]
end

return SugarAI