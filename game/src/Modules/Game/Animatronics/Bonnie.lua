local BonnieAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
    stared = false
}

BonnieAI.__name__ = "Bonnie"

BonnieAI.currentState = 1
BonnieAI.metadataCameraID = 0
BonnieAI.path = {
    {1064, 256, 6},        -- showstage
    {950, 431, 1},         -- arcade
    {999, 490, 9},         -- left_hall
    {1076, 544, nil},        -- front_office
    {1079, 592, nil},        -- office
}

function BonnieAI.init()
    BonnieAI.x, BonnieAI.y, BonnieAI.metadataCameraID = BonnieAI.path[BonnieAI.currentState][1] + 3, BonnieAI.path[BonnieAI.currentState][2] + 3, BonnieAI.path[BonnieAI.currentState][3]
end

-- just for radar shit --
function BonnieAI.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[2], BonnieAI.x, BonnieAI.y, 0, 2, 2, 16, 16)
    end
end

function BonnieAI.update(elapsed)
    if BonnieAI.currentState <= 4 then
        BonnieAI.timer = BonnieAI.timer + elapsed
        if BonnieAI.timer >= 7.3 then
            BonnieAI.move = math.random(0, 20)
            if BonnieAI.move <= NightState.animatronicsAI.bonnie and NightState.animatronicsAI.bonnie > 0 and not NightState.officeState.hasAnimatronicInOffice then
                if NightState.officeState.tabletUp then
                    if tabletCameraSubState.camerasID[BonnieAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[BonnieAI.metadataCameraID] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState:doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                BonnieAI.currentState = BonnieAI.currentState + 1
                NightState.playWalk()

                if NightState.officeState.flashlight.state then
                    if BonnieAI.currentState == 4 then
                        NightState.officeState.flashlight.isFlicking = true
                    end
                end
            end
            BonnieAI.timer = 0
        end
    else
        if not AudioSources["stare"]:isPlaying() then
            AudioSources["stare"]:play()
        end

        BonnieAI.timer = BonnieAI.timer + elapsed
        if BonnieAI.timer >= 0.02 then
            BonnieAI.timer = 0
            BonnieAI.patience = BonnieAI.patience + 1
            NightState.officeState.hasAnimatronicInOffice = true
        end

        if NightState.officeState.hasAnimatronicInOffice then
            if BonnieAI.patience >= 150 and not NightState.officeState.maskUp then
                if not NightState.killed then
                    NightState.killed = true
                    NightState.jumpscareController:init("bonnie", 35)
                    NightState.jumpscareController.onComplete = function()
                        NightState.KilledBy = "bonnie"
                        gamestate.switch(DeathState)
                    end
                end
            elseif BonnieAI.patience >= 150 and NightState.officeState.maskUp then
                BonnieAI.patience = 0
                BonnieAI.timer = 0
                BonnieAI.currentState = 1
                NightState.officeState.hasAnimatronicInOffice = false
                AudioSources["stare"]:stop()
                NightState.officeState.fadealpha = 1
            end
        end
    end

    BonnieAI.x, BonnieAI.y, BonnieAI.metadataCameraID = BonnieAI.path[BonnieAI.currentState][1] + 3, BonnieAI.path[BonnieAI.currentState][2] + 3, BonnieAI.path[BonnieAI.currentState][3]
end

return BonnieAI