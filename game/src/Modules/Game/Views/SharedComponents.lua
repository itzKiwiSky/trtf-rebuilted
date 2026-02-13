return {
    ButtonSkin = function(object)
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
    end,

    imgButtonNoteSkin = function(object)
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
    end,

    imgQuadSupport = function(obj)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local orientation = object:GetOrientation()
        local scalex = object:GetScaleX()
        local scaley = object:GetScaleY()
        local offsetx = object:GetOffsetX()
        local offsety = object:GetOffsetY()
        local shearx = object:GetShearX()
        local sheary = object:GetShearY()
        local image = object.image
        local imagecolor = object.imagecolor or skin.controls.color_image
        local stretch = object.stretch
        local quad = object.quad

        if stretch then
            scalex, scaley = object:GetWidth() / image:getWidth(), object:GetHeight() / image:getHeight()
        end

        love.graphics.setColor(imagecolor)
        if quad then
            love.graphics.draw(image, quad, x, y, orientation, scalex, scaley, offsetx, offsety, shearx, sheary)
        else
            love.graphics.draw(image, x, y, orientation, scalex, scaley, offsetx, offsety, shearx, sheary)
        end
    end
}
