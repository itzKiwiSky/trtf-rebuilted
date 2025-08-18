local settings = {--
    lpadding = 24,
    blank = function()end,
    fonts = {
        title = fontcache.getFont("tnr", 50),
        btnfont = fontcache.getFont("tnr", 26),
        subtitleFont = fontcache.getFont("tnr", 32),
        optionFont = fontcache.getFont("tnr", 34),
        mainButtons = fontcache.getFont("tnr", 18),
        multi = fontcache.getFont("tnr", 20)
    },
}

return function()
    local function imgButtonNoteSkin(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local width = object:GetWidth()
        local height = object:GetHeight()
        local text = object:GetText()
        local hover = object:GetHover()
        local image = object:GetImage()
        local imagecolor = object.imagecolor or skin.controls.color_image
        local down = object.down
        local font = object:GetFont() or skin.controls.imagebuttonfont
        local twidth = font:getWidth(object.text)
        local theight = font:getHeight(object.text)
        local checked = object.checked
        local quad = object.quad

        love.graphics.setColor(imagecolor)
        if quad then
            _, _, w, h = quad:getViewport()
            love.graphics.draw(image, quad, x, y, 0, width / w, height / h)
        else
            love.graphics.draw(image, x, y, 0, width / image:getWidth(), height / image:getHeight())
        end
    end

    
end