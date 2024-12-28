local drawQueue = require 'src.Components.Modules.Game.Utils.DrawQueueBar'

local function mapValue(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

return function(this)
    local cycleDuration = 0.08
    local activeThreshold = 0.5
    love.graphics.print(languageService["game_energy"]:format(officeState.power.powerDisplay), fnt_camError, 64, love.graphics.getHeight() - 174)
    love.graphics.print(languageService["game_energy_usage"], fnt_camError, 64, love.graphics.getHeight() - 144)

    if tabletCameraSubState.camID == "vent_kitty" then
        love.graphics.print(officeState.vent.left and languageService["game_vent_state_closed"] or languageService["game_vent_state_open"], fnt_camError, 64, love.graphics.getHeight() - 204)
    elseif tabletCameraSubState.camID == "vent_sugar" then
        love.graphics.print(officeState.vent.right and languageService["game_vent_state_closed"] or languageService["game_vent_state_open"], fnt_camError, 64, love.graphics.getHeight() - 204)
    end

    if officeState.vent.requestClose then
        if (love.timer.getTime() % cycleDuration) / cycleDuration > activeThreshold then
            if not officeState.vent.right or not officeState.vent.left then
                love.graphics.print(languageService["game_misc_text_sealing"], fnt_camError, 512, love.graphics.getHeight() - 120)
            else
                love.graphics.print(languageService["game_misc_text_unsealing"], fnt_camError, 512, love.graphics.getHeight() - 120)
            end
        end
    end

    drawQueue(64, love.graphics.getHeight() - 110, 128, 48, officeState.power.powerQueue, 7, 5, 5, {0, 255, 0}, {255, 0, 0})
    
    if tabletCameraSubState.camerasID[NightState.AnimatronicControllers["puppet"].metadataCameraID] == tabletCameraSubState.camID and NightState.AnimatronicControllers["puppet"].released then
        love.graphics.rectangle("line", 360, love.graphics.getHeight() - 110, 128, 50)
        drawQueue(360, love.graphics.getHeight() - 110, 128, 48, mapValue(NightState.AnimatronicControllers["puppet"].musicBoxTimer, 0, 2500, 0, 10), 10, 3, 3, {255,0, 0}, {200, 86, 255})
    end
end 