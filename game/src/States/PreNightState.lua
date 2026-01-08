PreNightState = {}

function PreNightState:enter()
    self.texture = love.graphics.newImage(languageRaw["__ENGINE__"]["tutorialKeyboardTexture"])
    self.bg = love.graphics.newImage("assets/images/game/extras/bg.png")

    self.fnt_title = fontcache.getFont("tnr", 35)

    self.transition = {
        alpha = 1
    }

    self.canPress = false

    flux.to(self.transition, 1.5, { alpha = 0 })
        :oncomplete(function()
            self.canPress = true
        end)
end

function PreNightState:draw()
    love.graphics.draw(self.bg, 0, 0)
    love.graphics.draw(self.texture, 0, 50)

    love.graphics.printf(string.format("%s\n%s", languageService["tutorial_title"], languageService["tutorial_press"]), self.fnt_title, 0, shove.getViewportHeight() - 128, shove.getViewportWidth(), "center")

    love.graphics.setColor(0, 0, 0, self.transition.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function PreNightState:update(elapsed)
    flux.update(elapsed)
end

function PreNightState:keypressed(k)
    if not self.canPress then return end

    flux.to(self.transition, 1.5, { alpha = 1 })
        :oncomplete(function()
            gameSave.save.user.progress.checkedTutorial = true
            gameSave:saveSlot()
            gamestate.switch(NightState)
        end)
end

function PreNightState:mousepressed(k)
    if not self.canPress then return end

    flux.to(self.transition, 1.5, { alpha = 1 })
        :oncomplete(function()
            gameSave.save.user.progress.checkedTutorial = true
            gameSave:saveSlot()
            gamestate.switch(NightState)
        end)
end

function PreNightState:leave()
    flux.removeAll()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    self.texture:release()
    self.bg:release()
end

return PreNightState
