SettingsSubState = {}

function SettingsSubState:load()
    ViewManager.load("src/Modules/Game/Interface/Views/SettingsMenu.lua")
    self.UICanvas = love.graphics.newCanvas(love.resconf.width, love.resconf.height, { readable = true })
end

function SettingsSubState:draw()
    love.graphics.draw(self.UICanvas)
end

function SettingsSubState:update(elapsed)
    love.graphics.setCanvas({ self.UICanvas, stencil = true })
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", 0, 0, love.resconf.width, love.resconf.height)
        love.graphics.setColor(1, 1, 1, 1)
        ViewManager.draw()
    love.graphics.setCanvas()
    ViewManager.reloadViews()
    ViewManager.update(elapsed)
end

function SettingsSubState:mousepressed(x, y, button)
    ViewManager.mousepressed(x, y, button)
end

function SettingsSubState:mousereleased(x, y, button)
    ViewManager.mousereleased(x, y, button)
end

function SettingsSubState:keypressed(k, scancode, isrepeat)
    ViewManager.keypressed(k, isrepeat)
end

function SettingsSubState:keyreleased(k)
    ViewManager.keyreleased(k)
end

function SettingsSubState:textinput(t)
    ViewManager.textinput(t)
end

return SettingsSubState