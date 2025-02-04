local Resolution = {}

Resolution.targetWidth = 1920
Resolution.targetHeight = 1080
Resolution.scale = 1
Resolution.offsetX = 0
Resolution.offsetY = 0
Resolution.viewport = nil

function Resolution.init(c)
    if c.replace then
        Resolution.replace(c.replace)
    end

    Resolution.targetWidth = c.width or love.graphics.getWidth()
    Resolution.targetHeight = c.height or love.graphics.getHeight()
    Resolution.viewport = love.graphics.newCanvas(c.width or love.graphics.getWidth(), c.height or love.graphics.getHeight())

    Resolution.update(love.graphics.getWidth(), love.graphics.getHeight())
end

function Resolution.update(windowWidth, windowHeight)
    local scaleX = windowWidth / Resolution.targetWidth
    local scaleY = windowHeight / Resolution.targetHeight
    Resolution.scale = math.min(scaleX, scaleY)

    Resolution.offsetX = (windowWidth - Resolution.targetWidth * Resolution.scale) / 2
    Resolution.offsetY = (windowHeight - Resolution.targetHeight * Resolution.scale) / 2
end


function Resolution.apply()
    love.graphics.setCanvas(Resolution.viewport)
    love.graphics.push()
    love.graphics.translate(Resolution.offsetX, Resolution.offsetY)
    love.graphics.scale(Resolution.scale)
end

function Resolution.reset()
    love.graphics.pop()
    love.graphics.setCanvas()
end

function Resolution.draw()
    love.graphics.draw(Resolution.viewport, Resolution.offsetX, Resolution.offsetY, 0, Resolution.scale)
end

function Resolution.toViewportCoords(x, y)
    return (x - Resolution.offsetX) / Resolution.scale, (y - Resolution.offsetY) / Resolution.scale
end

return Resolution