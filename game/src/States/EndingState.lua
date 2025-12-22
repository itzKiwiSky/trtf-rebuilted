EndingState = {}
EndingState.mode = "normal"

function EndingState:enter()
    local lang = gameSave.save.user.settings.misc.language
    self.text = love.filesystem.read("assets/data/language/credits_" .. lang .. ".txt")
    --print(self.text)
    self.font = fontcache.getFont("tnr", 30)
    self.font:setLineHeight(1.3)

    self.textOffset = 16
    self.textSpeed = 16
    self.fade = {
        alpha = 1
    }

    switch(self.mode, {
        ["normal"] = function()
            AudioSources["msc_ending"]:setLooping(true)
            AudioSources["msc_ending"]:setVolume(0.67)
            AudioSources["msc_ending"]:play()
            switch(lang, {
                ["default"] = function()
                    self.bg = love.graphics.newImage("assets/images/game/ending/ending_English.png")
                end,
                ["Espanol"] = function()
                    self.bg = love.graphics.newImage("assets/images/game/ending_/ending_Espanol.png")
                end,
            })
        end,
        ["secret"] = function()
            AudioSources["msc_night8_ending"]:setLooping(true)
            AudioSources["msc_night8_ending"]:setVolume(0.67)
            AudioSources["msc_night8_ending"]:play()
            switch(lang, {
                ["default"] = function()
                    self.bg = love.graphics.newImage("assets/images/game/ending/night8_ending_English.png")
                end,
                ["Espanol"] = function()
                    self.bg = love.graphics.newImage("assets/images/game/ending/night8_ending_Espanol.png")
                end,
            })
        end,
    })

    flux.to(self.fade, 2.5, { alpha = 0 })
end

function EndingState:draw()
    love.graphics.setColor(0.87, 0.87, 0.87)
    love.graphics.draw(self.bg, 0, 0)
    love.graphics.setColor(1, 1, 1)

    love.graphics.printf(self.text, self.font, shove.getViewportWidth() - 450, shove.getViewportHeight() + self.textOffset, 420, "center")

    love.graphics.setColor(1, 1, 1, 0.1)
    love.graphics.print(languageService["credits_speed"], self.font, 16, shove.getViewportHeight() - (self.font:getHeight() + 16))
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, self.fade.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1)
end

function EndingState:update(elapsed)
    self.textOffset = self.textOffset - elapsed * self.textSpeed


    if love.mouse.isDown(1) then
        self.textOffset = self.textOffset - elapsed * 96
    else
        self.textOffset = self.textOffset - elapsed * self.textSpeed
    end

    if self.textOffset < -3750 then
        flux.to(self.text, 3, { alpha = 1 }):oncomplete(function()
            gamestate.switch(MenuState)
        end)
    end

    flux.update(elapsed)
end

function EndingState:leave()
    flux.remove()
    self.bg:release()
end

return EndingState
