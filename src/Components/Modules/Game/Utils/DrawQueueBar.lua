local function interpColors(startCol, endCol, maxSteps)
    local c = {}

    for step = 0, maxSteps, 1 do
        local r, g, b
        local t = step / maxSteps
        r = startCol[1] + (endCol[1] - startCol[1]) * t
        g = startCol[2] + (endCol[2] - startCol[2]) * t
        b = startCol[3] + (endCol[3] - startCol[3]) * t

        table.insert(c, {r, g, b})
    end

    return c
end

return function(x, y, areaWidth, areaHeight, count, maxCount, padding, spacing, ...)
    local col = {...}
    local enterColor = col[1] or {0, 255, 0}
    local endColor = col[2] or {255, 0, 0}

    local lx = x + padding
    local ly = y + padding
    local maxWidth = areaWidth - 2 * padding
    local rectWidth = (maxWidth - (maxCount - 1) * spacing) / maxCount
    local rectHeight = areaHeight - 2 * padding

    assert(rectWidth >= 0 or rectHeight >= 0, "[ERROR] : Can't be less than 0")
    --print(debug.formattable(c))
    local c = interpColors(enterColor, endColor, maxCount)

    for i = 1, maxCount do
        local r, g, b = c[i][1] / 255 or 0, c[i][2] / 255 or 1, c[i][3] / 255 or 0
    
        love.graphics.setColor(r, g, b, 1)
            if i <= count then
                love.graphics.draw(NightState.assets.grd_bars, lx, ly, 0, rectWidth, rectHeight)
            end
        love.graphics.setColor(1, 1, 1, 1)
        lx = lx + rectWidth + spacing
    end
end