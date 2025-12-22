EndingState = {}
EndingState.mode = "normal"

function EndingState:enter()
    local lang = gameSave.save.user.settings.misc.language
    self.text = love.filesystem.read("assets/data/language/credits_" .. lang .. ".txt")
    --print(self.text)
    self.font = fontcache.getFont("tnr", 38)

    self.textOffset = -128
    self.textSpeed = 4
    self.blackCatAlpha = 1

    switch(self.mode, {
        ["normal"] = function()
            self.bg = love.graphics.newImage("assets/images/game/ending/ending_" .. lang .. ".png")
        end,
        ["secret"] = function()
            self.bg = love.graphics.newImage("assets/images/game/ending/night8_ending_" .. lang .. ".png")
        end,
    })
end

function EndingState:draw()
    love.graphics.print(self.text, self.font, shove.getViewportWidth() - 480, shove.getViewportHeight() - self.textOffset)

    love.graphics.setColor(0, 0, 0, self.blackCatAlpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(0, 0, 0)
end

function EndingState:update(elapsed)
    --self.text
    self.textOffset = self.textOffset - elapsed * self.textSpeed
end

function EndingState:leave()
    self.bg:release()
end

return EndingState
