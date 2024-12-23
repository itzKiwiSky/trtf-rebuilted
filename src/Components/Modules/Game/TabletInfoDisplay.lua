local drawQueue = require 'src.Components.Modules.Game.Utils.DrawQueueBar'

local function mapValue(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

return function(this)
    love.graphics.print(languageService["game_energy"]:format(officeState.power.powerDisplay), fnt_camError, 64, love.graphics.getHeight() - 174)
    love.graphics.print(languageService["game_energy_usage"], fnt_camError, 64, love.graphics.getHeight() - 144)

    drawQueue(64, love.graphics.getHeight() - 110, 128, 48, officeState.power.powerQueue, 5, 5, 5, {0, 255, 0}, {255, 0, 0})
    
    if tabletCameraSubState.camerasID[NightState.AnimatronicControllers["puppet"].metadataCameraID] == tabletCameraSubState.camID and NightState.AnimatronicControllers["puppet"].released then
        love.graphics.rectangle("line", 360, love.graphics.getHeight() - 110, 128, 50)
        drawQueue(360, love.graphics.getHeight() - 110, 128, 48, mapValue(NightState.AnimatronicControllers["puppet"].musicBoxTimer, 0, 2500, 0, 10), 10, 3, 3, {255,0, 0}, {200, 86, 255})
    end
end 