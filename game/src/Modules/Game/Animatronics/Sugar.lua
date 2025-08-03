local tabletCameraSubState = require 'src.States.Substates.TabletCameraSubstate'
local SugarAI = {
    x = 0,
    y = 0,
    w = 32,
    h = 32,
    timer = 0,
    move = 0,
    patience = 0,
}

SugarAI.__name__ = "Kitty"

SugarAI.currentState = 1
SugarAI.metadataCameraID = 0
SugarAI.active = false
SugarAI.path = {
    {898, 267, 5},         -- storage
    {1064, 323, 3},         -- dining_area
    {906, 339, 4},
    {1116, 636, 12},        -- left_vent
    {1116, 636, 12},        -- office
}

function SugarAI.init()
    SugarAI.x, SugarAI.y, SugarAI.metadataCameraID = SugarAI.path[SugarAI.currentState][1] + 16, SugarAI.path[SugarAI.currentState][2] + 13, SugarAI.path[SugarAI.currentState][3]
end

-- just for radar shit --
function SugarAI.draw()
    if NightState.modifiers.radarMode then
        love.graphics.draw(NightState.assets["radar_icons"].image, NightState.assets["radar_icons"].quads[5], SugarAI.x, SugarAI.y, 0, 2, 2, 16, 16)
    end
end

function SugarAI.update(elapsed)
    if SugarAI.active then
        if SugarAI.currentState <= 3 then
            SugarAI.timer = SugarAI.timer + elapsed
            if SugarAI.timer >= 9.7 then
                SugarAI.move = math.random(0, 20)
                if SugarAI.move <= NightState.animatronicsAI.sugar and NightState.animatronicsAI.sugar > 0 and not NightState.officeState.hasAnimatronicInOffice then
                    if NightState.officeState.tabletUp then
                        if tabletCameraSubState.camerasID[SugarAI.metadataCameraID] then
                            if tabletCameraSubState.camerasID[SugarAI.metadataCameraID] == tabletCameraSubState.camID then
                                AudioSources["cam_animatronic_interference"]:seek(0)
                                tabletCameraSubState:doInterference(0.1, 200, 200, 6)
                                AudioSources["cam_animatronic_interference"]:play()
                            end
                        end
                    end
                    if SugarAI.currentState <= 3 then
                        NightState.playWalk()
                    elseif SugarAI.currentState == 4 then
                        AudioSources["vent_walk"]:seek(0)
                        AudioSources["vent_walk"]:play()
                    end

                    if NightState.AnimatronicControllers["kitty"].currentState < 3 then
                        SugarAI.currentState = SugarAI.currentState + 1
                    end
                end
                SugarAI.timer = 0
            end
        elseif SugarAI.currentState == 4 then
            SugarAI.timer = SugarAI.timer + elapsed
            if SugarAI.timer >= 0.04 then
                SugarAI.timer = 0
                SugarAI.patience = SugarAI.patience + 1
            end
    
            if not NightState.officeState.hasAnimatronicInOffice then
                if SugarAI.patience >= 350 and not NightState.officeState.vent.left then
                    if not NightState.killed then
                        NightState.killed = true
                        NightState.jumpscareController:init("sugar", 35)
                        NightState.jumpscareController.onComplete = function()
                            NightState.KilledBy = "sugar"
                            gamestate.switch(DeathState)
                        end
                    end
                elseif SugarAI.patience >= 350 and NightState.officeState.vent.left then
                    AudioSources["vent_amb2"]:seek(0)
                    AudioSources["vent_amb2"]:play()
                    SugarAI.patience = 0
                    SugarAI.timer = 0
                    SugarAI.currentState = 2
                end
            end
        end
    
        SugarAI.x, SugarAI.y, SugarAI.metadataCameraID = SugarAI.path[SugarAI.currentState][1] + 3, SugarAI.path[SugarAI.currentState][2] + 3, SugarAI.path[SugarAI.currentState][3]
    else
        SugarAI.timer = SugarAI.timer + elapsed
        if SugarAI.timer >= math.random(8, 12) then
            SugarAI.move = math.random(0, 20)
            if SugarAI.move <= NightState.animatronicsAI.sugar and NightState.animatronicsAI.sugar > 0 then
                if NightState.officeState.tabletUp then
                    if tabletCameraSubState.camerasID[SugarAI.metadataCameraID] then
                        if tabletCameraSubState.camerasID[9] == tabletCameraSubState.camID then
                            AudioSources["cam_animatronic_interference"]:seek(0)
                            tabletCameraSubState:doInterference(0.1, 200, 200, 6)
                            AudioSources["cam_animatronic_interference"]:play()
                        end
                    end
                end
                SugarAI.active = true
                SugarAI.timer = 0
            end
        end
    end
end

return SugarAI