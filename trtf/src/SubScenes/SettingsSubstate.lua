SettingsSubState = {}

function SettingsSubState:load()
    ViewManager.load("src/Modules/Game/Interface/Views/SettingsMenu.lua")
end

function SettingsSubState:draw()
    love.graphics.setBlendMode("alpha", "alphamultiply")
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.resconf.width, love.resconf.height)
    love.graphics.setColor(1, 1, 1, 1)
    ViewManager.draw()
end

function SettingsSubState:update(elapsed)
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