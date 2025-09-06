local drawQueue = require 'src.Modules.Game.Utils.DrawQueueBar'
local tabletCameraSubState = require 'src.States.Substates.TabletCameraSubstate'

local function mapValue(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

return function(this)
    local cycleDuration = 0.3
    local activeThreshold = 0.5
    love.graphics.print(languageService["game_energy"]:format(NightState.officeState.power.powerDisplay), NightState.fnt_camError, 64, shove.getViewportHeight() - 174)
    love.graphics.print(languageService["game_energy_usage"], NightState.fnt_camError, 64, shove.getViewportHeight() - 144)

    if tabletCameraSubState.camID == "vent_kitty" and NightState.AnimatronicControllers["kitty"] ~= nil then
        love.graphics.print(NightState.officeState.vent.left and languageService["game_vent_state_closed"] or languageService["game_vent_state_open"], NightState.fnt_camError, 64, shove.getViewportHeight() - 204)
    elseif tabletCameraSubState.camID == "vent_sugar" and NightState.AnimatronicControllers["sugar"] ~= nil then
        love.graphics.print(NightState.officeState.vent.right and languageService["game_vent_state_closed"] or languageService["game_vent_state_open"], NightState.fnt_camError, 64, shove.getViewportHeight() - 204)
    end

    if NightState.officeState.vent.requestClose then
        if (love.timer.getTime() % cycleDuration) / cycleDuration > activeThreshold then
            if not NightState.officeState.vent.right or not NightState.officeState.vent.left then
                love.graphics.print(languageService["game_misc_text_sealing"], NightState.fnt_camError, 430, shove.getViewportHeight() - 150)
            else
                love.graphics.print(languageService["game_misc_text_unsealing"], NightState.fnt_camError, 430, shove.getViewportHeight() - 150)
            end
        end
    end

    drawQueue(64, shove.getViewportHeight() - 110, 128, 48, NightState.officeState.power.powerQueue, 7, 5, 5, {0, 255, 0}, {255, 0, 0})
    
    if NightState.AnimatronicControllers["puppet"] ~= nil then
        if tabletCameraSubState.camerasID[NightState.AnimatronicControllers["puppet"].metadataCameraID] == tabletCameraSubState.camID and NightState.AnimatronicControllers["puppet"].released then
            love.graphics.rectangle("line", 360, shove.getViewportHeight() - 110, 128, 50)
            drawQueue(360, shove.getViewportHeight() - 110, 128, 48, mapValue(NightState.AnimatronicControllers["puppet"].musicBoxTimer, 0, 2485, 0, 10), 10, 3, 3, {255,0, 0}, {200, 86, 255})
        end
    end
end 