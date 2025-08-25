SettingsSubState = {}

function SettingsSubState:load()
    loveView.registerLoveframesEvents()
    loveView.loadView("src/Modules/Game/Views/SettingsMenu.lua")
    self.UICanvas = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight(), { readable = true })
end

function SettingsSubState:draw()
    love.graphics.draw(self.UICanvas)
end

function SettingsSubState:update(elapsed)
    love.graphics.setCanvas({ self.UICanvas, stencil = true })
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
        love.graphics.setColor(1, 1, 1, 1)
        loveView.draw()
    love.graphics.setCanvas()
    loveView.update(elapsed)
end

return SettingsSubState