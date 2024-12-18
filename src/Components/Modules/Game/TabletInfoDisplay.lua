local drawQueue = require 'src.Components.Modules.Game.Utils.DrawQueueBar'
return function(this)
    love.graphics.print(languageService["game_energy"]:format(officeState.power.powerDisplay), fnt_camError, 64, love.graphics.getHeight() - 168)
    love.graphics.print(languageService["game_energy_usage"], fnt_camError, 64, love.graphics.getHeight() - 140)

    drawQueue(64, love.graphics.getHeight() - 110, 128, 48, officeState.power.powerQueue, 5, 5, 5, {0, 255, 0}, {255, 0, 0})
end