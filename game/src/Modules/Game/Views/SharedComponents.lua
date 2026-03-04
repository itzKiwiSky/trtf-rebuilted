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
    end,

    customScrollbody = function(object)
        local x = object:GetX()
        local y = object:GetY()
        local width = object:GetWidth()
        local height = object:GetHeight()
        local dragging = object:IsDragging()
        local hover = object:GetHover()
        local bartype = object:GetBarType()

        -- Estado: cor muda conforme interação
        local color
        if dragging then
            color = { 1, 1, 1, 0.6 }
        elseif hover then
            color = { 1, 1, 1, 0.8 }
        else
            color = { 1, 1, 1, 0.5 }
        end

        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x, y, width, height, 10, 10, 20)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x, y, width, height, 10, 10, 20)
    end,
    customFrame = function(object)
        local skin   = object:GetSkin()
        local x      = object:GetX()
        local y      = object:GetY()
        local width  = object:GetWidth()
        local height = object:GetHeight()
        local hover  = object:IsTopChild()
        local name   = object:GetName()
        local icon   = object:GetIcon()
        local font   = skin.controls.smallfont

        local body   = skin.controls.color_back0
        local top    = hover and skin.controls.color_active or skin.controls.color_fore0
        local fore   = skin.controls.color_back0
        local border = skin.controls.color_back1

        -- frame body
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", x, y, width, height, 10, 10)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x, y, width, height, 10, 10)
        love.graphics.setLineWidth(1)

        -- frame top bar
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", x, y, width, 25, 10, 10)

        -- frame name section
        love.graphics.setFont(font)

        if icon then
            local iconwidth = icon:getWidth()
            local iconheight = icon:getHeight()
            --icon:setFilter("nearest", "nearest")
            love.graphics.setColor(skin.controls.color_image)
            love.graphics.draw(icon, x + 5, y + 5)
            love.graphics.setColor(1, 1, 1, 1)
            skin.PrintText(name, x + iconwidth + 10, y + 5)
        else
            love.graphics.setColor(1, 1, 1, 1)
            skin.PrintText(name, x + 10, y + 5)
        end

        -- frame border
        --love.graphics.setColor(border)
        --skin.OutlinedRectangle(x, y, width, height)
        --love.graphics.rectangle("line", x, y, width, height, 10, 10)
        --skin.OutlinedRectangle(x, y, width, height)
    end,
    customSlider = function(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local width = object:GetWidth()
        local height = object:GetHeight()
        local slidtype = object:GetSlideType()
        local body = { 1, 1, 1, 1 }
        local border = { 1, 1, 1, 1 }

        if slidtype == "horizontal" then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", x, y + height / 2 - 3, width, 6, 2, 2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", x, y + height / 2 - 3, width, 6, 2, 2)
            love.graphics.setLineWidth(1)

            --love.graphics.setLineWidth(5)
            --love.graphics.rectangle("line", x + 5, y + height / 2 - 1, width - 10, 2, 2, 2)
            --love.graphics.setLineWidth(1)
            --skin.OutlinedRectangle(x, y, width, height)
        elseif slidtype == "vertical" then
            love.graphics.setColor(body)
            love.graphics.rectangle("fill", x + width / 2 - 3, y, 6, height)
            love.graphics.setColor(border)
            love.graphics.rectangle("fill", x + width / 2 - 1, y + 5, 2, height - 10)
        end
    end,
    customSliderButton = function(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local width = object:GetWidth()
        local height = object:GetHeight()
        local hover = object:GetHover()
        local down = object.down
        local parent = object:GetParent()
        local enabled = parent:GetEnabled()

        --[[if not enabled then
            -- button body
            love.graphics.setColor(skin.controls.color_back1)
            love.graphics.rectangle("fill", x, y, width, height)
            -- button border
            love.graphics.setColor(skin.controls.color_back2)
            skin.OutlinedRectangle(x, y, width, height)
            return
        end]]


        local fore
        if down then
            fore = skin.controls.color_fore0
        elseif hover then
            fore = skin.controls.color_active
        else
            fore = skin.controls.color_back3
        end

        love.graphics.circle("fill", x + 4, y + 10, 8)
    end
}
