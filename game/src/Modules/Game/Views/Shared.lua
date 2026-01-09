local settings = {
    lpadding = 32,
    blank = function() end,
    fonts = {
        title = fontcache.getFont("tnr", 50),
        btnfont = fontcache.getFont("tnr", 26),
        subtitleFont = fontcache.getFont("tnr", 32),
        optionFont = fontcache.getFont("tnr", 34),
        mainButtons = fontcache.getFont("tnr", 18),
        multi = fontcache.getFont("tnr", 20),
        vhsFont = fontcache.getFont("vcr", 20),
        vhsTitle = fontcache.getFont("vcr", 42),
        vhsNameFont = fontcache.getFont("vcr", 24)
    },
}

return function()
    local buttonSkin = function(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local width = object:GetWidth()
        local height = object:GetHeight()
        local hover = object:GetHover()
        local text = object:GetText()
        local font = object:GetFont() or skin.controls.smallfont
        local twidth = font:getWidth(object.text)
        local theight = font:getHeight(object.text)
        local down = object:GetDown()
        local checked = object.checked
        local enabled = object:GetEnabled()
        local clickable = object:GetClickable()
        local back, fore, border

        love.graphics.setFont(font)

        if down or checked then
            back = { 0.3, 0.3, 0.3, 1 }
            fore = { 1, 1, 1, 1 }
            border = { 1, 1, 0, 1 }

            -- button body
            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(fore)
            skin.PrintText(text, (x + width / 2 - twidth / 2) + 8, (y + height / 2 - theight / 2) + 8)
        elseif hover then
            back = { 0.7, 0.7, 0.7, 1 }
            fore = { 0, 0, 0, 1 }
            border = love.timer.getTime() % 1 > 0.5 and { 1, 1, 0, 1 } or { 0, 0, 1, 1 }

            -- button body
            love.graphics.setColor(border)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x, y, width, height)

            love.graphics.setColor(fore)
            skin.PrintText(text, x + width / 2 - twidth / 2, y + height / 2 - theight / 2)
        else
            back = { 0.7, 0.7, 0.7, 1 }
            fore = { 0, 0, 0, 1 }
            border = { 0.3, 0.3, 0.3, 1 }

            -- button body
            love.graphics.setColor(border)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x, y, width, height)

            love.graphics.setColor(fore)
            skin.PrintText(text, x + width / 2 - twidth / 2, y + height / 2 - theight / 2)
        end

        --love.graphics.rectangle("line", x, y, width, height)
    end

    local exitButton = loveframes.Create("button")
    exitButton:SetFont(settings.fonts.vhsFont)
    exitButton:SetSize(96, 48)
    exitButton:SetText(languageService["menu_settings_buttons_exit"])
    exitButton:SetPos(settings.lpadding, shove.getViewportHeight() - (exitButton:GetHeight() + settings.lpadding))
    exitButton.drawfunc = buttonSkin
    exitButton.OnClick = function(obj)
        gamestate.switch(MenuState)
    end
end
