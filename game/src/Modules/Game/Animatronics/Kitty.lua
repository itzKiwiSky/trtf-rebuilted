local tabletCameraSubState = require 'src.States.Substates.TabletCameraSubstate'
local KittyAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
}

KittyAI.__name__ = "Kitty"

KittyAI.currentState = 1
KittyAI.metadataCameraID = 0
KittyAI.active = false
KittyAI.path = {
    {1165, 432, 2},         -- storage
    {1064, 323, 3},         -- dining_area
    {906, 339, 4},
    {1116, 636, 11},        -- left_vent
    {1004, 636, 11},        -- office
}

function KittyAI.init()
    KittyAI.x, KittyAI.y, KittyAI.metadataCameraID = KittyAI.path[KittyAI.currentState][1] + 16, KittyAI.path[KittyAI.currentState][2] + 93, KittyAI.path[KittyAI.currentState][3]
end

-- just for radar shit --
function KittyAI.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[6], KittyAI.x, KittyAI.y, 0, 2, 2, 16, 16)
    end
end

function KittyAI.update(elapsed)
    if KittyAI.active then
        if KittyAI.currentState <= 3 then
            KittyAI.timer = KittyAI.timer + elapsed
            if KittyAI.timer >= 7.3 then
                KittyAI.move = math.random(0, 20)
                if KittyAI.move <= NightState.animatronicsAI.kitty and NightState.animatronicsAI.kitty > 0 and not NightState.officeState.hasAnimatronicInOffice then
                    if NightState.officeState.tabletUp then
                        if tabletCameraSubState.camerasID[KittyAI.metadataCameraID] then
                            if tabletCameraSubState.camerasID[KittyAI.metadataCameraID] == tabletCameraSubState.camID then
                                AudioSources["cam_animatronic_interference"]:seek(0)
                                tabletCameraSubState:doInterference(0.1, 200, 200, 6)
                                AudioSources["cam_animatronic_interference"]:play()
                            end
                        end
                    end
                    if KittyAI.currentState <= 3 then
                        NightState.playWalk()
                    elseif KittyAI.currentState == 4 then
                        AudioSources["vent_walk"]:seek(0)
                        AudioSources["vent_walk"]:play()
                    end
                    if NightState.AnimatronicControllers["sugar"].currentState < 3 then
                        KittyAI.currentState = KittyAI.currentState + 1
                    end
                end
                KittyAI.timer = 0
            end
        elseif KittyAI.currentState == 4 then
            KittyAI.timer = KittyAI.timer + elapsed
            if KittyAI.timer >= 0.04 then
                KittyAI.timer = 0
                KittyAI.patience = KittyAI.patience + 1
            end
    
            if not NightState.officeState.hasAnimatronicInOffice then
                if KittyAI.patience >= 350 and not NightState.officeState.vent.left then
                    if not NightState.killed then
                        NightState.killed = true
                        NightState.jumpscareController:init("kitty", 35)
                        NightState.jumpscareController.onComplete = function()
                            NightState.KilledBy = "kitty"
                            gamestate.switch(DeathState)
                        end
                    end
                elseif KittyAI.patience >= 350 and NightState.officeState.vent.left then
                    AudioSources["vent_amb2"]:seek(0)
                    AudioSources["vent_amb2"]:play()
                    KittyAI.patience = 0
                    KittyAI.timer = 0
                    KittyAI.currentState = 2
                end
            end
        end
    
        KittyAI.x, KittyAI.y, KittyAI.metadataCameraID = KittyAI.path[KittyAI.currentState][1] + 3, KittyAI.path[KittyAI.currentState][2] + 3, KittyAI.path[KittyAI.currentState][3]
    else
        KittyAI.timer = KittyAI.timer + elapsed
        if KittyAI.timer >= 4.9 then
            KittyAI.move = math.random(0, 20)
            if KittyAI.move <= NightState.animatronicsAI.kitty and NightState.animatronicsAI.kitty > 0 then
                if NightState.officeState.tabletUp then
                    if tabletCameraSubState.camerasID[KittyAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[9] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState:doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                KittyAI.active = true
                KittyAI.timer = 0
            end
        end
    end
end

return KittyAI