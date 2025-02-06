return function(object)
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
    local back = {0, 0, 0, 1}
    local fore = {1, 1, 1, 1}
    local border = {1, 1, 1, 1}
    
    love.graphics.setFont(font)
    
    if not enabled or not clickable then
        -- button body
        love.graphics.setColor(back)
        love.graphics.rectangle("fill", x, y, width, height)
        -- button text
        love.graphics.setFont(font)
        love.graphics.setColor(skin.controls.color_back3)
        skin.PrintText(text, x + width/2 - twidth/2, y + height/2 - theight/2)
        -- button border
        love.graphics.setColor(border)
        skin.OutlinedRectangle(x, y, width, height)
        return
    end
    
    if object.toggleable then
        if hover then
            if down then
                back   = {0.5, 0.5, 0.5, 1}
                fore   = {1, 1, 1, 1}
                border = {1, 1, 1, 1}
            else
                back   = {0.5, 0.5, 0.5, 1}
                fore   = {1, 1, 1, 1}
                border = {1, 1, 1, 1}
            end
        else
            if object.toggle then
                back   = {0.5, 0.5, 0.5, 1}
                fore   = {1, 1, 1, 1}
                border = {1, 1, 1, 1}
            else
                back   = {0.5, 0.5, 0.5, 1}
                fore   = {1, 1, 1, 1}
                border = {1, 1, 1, 1}
            end
        end
        
        -- button body
        love.graphics.setColor(back)
        love.graphics.rectangle("fill", x, y, width, height)
        -- button text
        love.graphics.setColor(fore)
        skin.PrintText(text, x + width/2 - twidth/2, y + height/2 - theight/2)
        -- button border
        love.graphics.setColor(border)
        skin.OutlinedRectangle(x, y, width, height)
        
    else
        if down or checked then
            back   = {0.5, 0.5, 0.5, 1}
            fore   = {1, 1, 1, 1}
            border = {1, 1, 1, 1}
        elseif hover then
            back   = {0.5, 0.5, 0.5, 1}
            fore   = {1, 1, 1, 1}
            border = {1, 1, 1, 1}
        else
            back   = {0.5, 0.5, 0.5, 1}
            fore   = {1, 1, 1, 1}
            border = {1, 1, 1, 1}
        end
        
        -- button body
        love.graphics.setColor(back)
        love.graphics.rectangle("fill", x, y, width, height)
        -- button text
        if object.image then
            love.graphics.setColor(skin.controls.color_image)
            love.graphics.draw(object.image, x + 5,  y + height/2 - object.image:getHeight()/2)
        end
        
        love.graphics.setColor(fore)
        skin.PrintText(text, x + width/2 - twidth/2, y + height/2 - theight/2)
        -- button border
        love.graphics.setColor(border)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.setLineWidth(1)
        --skin.OutlinedRectangle(x, y, width, height)
    end
    
    love.graphics.setColor(skin.controls.color_back0)
    skin.OutlinedRectangle(x + 1, y + 1, width - 2, height - 2)
end