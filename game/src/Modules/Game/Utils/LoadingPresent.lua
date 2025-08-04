return function(clean)
    clean = clean or false
    local ctrEffect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    local glowTextEffect = moonshine(moonshine.effects.glow)
    local textLoadingFont = fontcache.getFont("ocrx", 34)
    local preloadBannerAgain = love.graphics.newImage("assets/images/game/banner.png")
    local clockIcon = love.graphics.newImage("assets/images/game/clockico.png")

    love.graphics.clear(love.graphics.getBackgroundColor())
        ctrEffect(function()
            love.graphics.draw(preloadBannerAgain, 0, 0, 0, shove.getViewportWidth() / preloadBannerAgain:getWidth(), shove.getViewportHeight() / preloadBannerAgain:getHeight())
        end)
        love.graphics.draw(clockIcon, shove.getViewportWidth() - 69, shove.getViewportHeight() - 69, 0, 64 / clockIcon:getWidth(), 64 / clockIcon:getHeight())
        glowTextEffect(function()
            love.graphics.printf("Loading...", textLoadingFont, 0, shove.getViewportHeight() - (textLoadingFont:getHeight() + 16), shove.getViewportWidth(), "center")
        end)
    love.graphics.present()

    if clean then
        ctrEffect = nil
        glowTextEffect = nil
        textLoadingFont:release()
        preloadBannerAgain:release()
        clockIcon:release()
        collectgarbage("collect")
    end
end