LoadingState = {}

function LoadingState:init()

end

function LoadingState:enter()
    local assetThread = require 'src.Components.Modules.Game.Utils.AssetsLoadThread'
    ldBackgrounds = {}
    local bgs = love.filesystem.getDirectoryItems("assets/images/game/menu/backgrounds")
    for b = 1, #bgs, 1 do
        table.insert(ldBackgrounds, love.graphics.newImage("assets/images/game/menu/backgrounds/" .. bgs[b]))
    end
    bgs = nil

    ctrEffect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    glowTextEffect = moonshine(moonshine.effects.glow)
    textLoadingFont = fontcache.getFont("ocrx", 34)
    clockIcon = love.graphics.newImage("assets/images/game/clockico.png")

    ready = false
    pressToGO = false
    screen_fade = 0

    _tempAssets = assetThread()

    if table.compare(NightState.assets, _tempAssets) then
        ready = true
    else
        randBG = math.random(1, #ldBackgrounds)

        collectgarbage("collect")
    
        loveloader.start(function()
            ready = true
        end)
    end
end

function LoadingState:draw()
    ctrEffect(function()
        love.graphics.draw(ldBackgrounds[randBG], 0, 0, 0, love.graphics.getWidth() / ldBackgrounds[randBG]:getWidth(), love.graphics.getHeight() / ldBackgrounds[randBG]:getHeight())
    end)
    love.graphics.draw(clockIcon, love.graphics.getWidth() - 69, love.graphics.getHeight() - 69, 0, 64 / clockIcon:getWidth(), 64 / clockIcon:getHeight())
    
    glowTextEffect(function()
        local percent = 0
        if loveloader.resourceCount ~= 0 then percent = loveloader.loadedCount / loveloader.resourceCount end
        love.graphics.printf(string.format(languageService[not ready and "loading_text" or "loading_ready"], (not ready and math.floor(percent * 100) or nil)), textLoadingFont, 0, love.graphics.getHeight() - (textLoadingFont:getHeight() + 16), love.graphics.getWidth(), "center")
    end)

    love.graphics.setColor(0, 0, 0, screen_fade)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

function LoadingState:update(elapsed)
    if not ready then
        loveloader.update()
    elseif ready and pressToGO then
        screen_fade = screen_fade + 0.4 * elapsed
    end

    if ready and pressToGO and screen_fade > 1 then
        NightState.assets = _tempAssets
        gamestate.switch(NightState)
    end
end

function LoadingState:keypressed(k)
    if ready and not pressToGO then
        pressToGO = true
    end
end

function LoadingState:mousepressed(x, y, button)
    if ready and not pressToGO then
        pressToGO = true
    end
end

function LoadingState:leave()
    if not gameslot.save.game.user.settings.preserveAssets then
        ctrEffect = nil
        glowTextEffect = nil
        textLoadingFont:release()
        clockIcon:release()
        for b = 1, #ldBackgrounds, 1 do
            ldBackgrounds[b]:release()
        end

        collectgarbage("collect")
    end
end

return LoadingState