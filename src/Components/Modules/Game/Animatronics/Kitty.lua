local KittyAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
}

KittyAI.__name__ = "Bonnie" -- Nome da tabela

KittyAI.currentState = 1
KittyAI.metadataCameraID = 0
KittyAI.path = {
    {1064, 256, 6},        -- showstage
    {950, 431, 1},         -- arcade
    {999, 490, 9},         -- left_hall
    {1076, 544, nil},        -- front_office
    {1079, 592, nil},        -- office
}

function KittyAI.init()
    
end

-- just for radar shit --
function KittyAI.draw()
    --[[
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[2], KittyAI.x, KittyAI.y, 0, 2, 2, 16, 16)
    end]]
end

function KittyAI.update(elapsed)
    --[[
    if KittyAI.currentState <= 4 then
        KittyAI.timer = KittyAI.timer + elapsed
        if KittyAI.timer >= 7.3 then
            KittyAI.move = math.random(0, 20)
            if KittyAI.move <= NightState.animatronicsAI.bonnie and NightState.animatronicsAI.bonnie > 0 and not officeState.hasAnimatronicInOffice then
                if officeState.tabletUp then
                    if tabletCameraSubState.camerasID[KittyAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[KittyAI.metadataCameraID] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState.doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                KittyAI.currentState = KittyAI.currentState + 1
                NightState.playWalk()

                if officeState.flashlight.state then
                    if KittyAI.currentState == 4 then
                        officeState.flashlight.isFlicking = true
                    end
                end

                if DEBUG_APP then
                    print(string.format("[%s] Moved | MoveID: %s State: %s", KittyAI.__name__, KittyAI.move, KittyAI.currentState))
                end
            else
                if DEBUG_APP then
                    print(string.format("[%s] Failed to move | MoveID: %s", KittyAI.__name__, KittyAI.move))
                end
            end
            KittyAI.timer = 0
        end
    else
        if not AudioSources["stare"]:isPlaying() then
            AudioSources["stare"]:play()
        end

        KittyAI.timer = KittyAI.timer + elapsed
        if KittyAI.timer >= 0.02 then
            KittyAI.timer = 0
            KittyAI.patience = KittyAI.patience + 1
            officeState.hasAnimatronicInOffice = true
        end

        if officeState.hasAnimatronicInOffice then
            if KittyAI.patience >= 150 and not officeState.maskUp then
                if not NightState.killed then
                    NightState.killed = true
                    jumpscareController:init("bonnie", 35)
                    jumpscareController.onComplete = function()
                        NightState.KilledBy = "bonnie"
                        gamestate.switch(DeathState)
                    end
                end
            elseif KittyAI.patience >= 150 and officeState.maskUp then
                KittyAI.patience = 0
                KittyAI.timer = 0
                KittyAI.currentState = 1
                officeState.hasAnimatronicInOffice = false
                AudioSources["stare"]:stop()
                officeState.fadealpha = 1
            end
        end
    end

    KittyAI.x, KittyAI.y, KittyAI.metadataCameraID = KittyAI.path[KittyAI.currentState][1] + 3, KittyAI.path[KittyAI.currentState][2] + 3, KittyAI.path[KittyAI.currentState][3]
    ]]
end

return KittyAI