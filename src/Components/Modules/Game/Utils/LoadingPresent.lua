return function(clean)
    clean = clean or false
    local ctrEffect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    local glowTextEffect = moonshine(moonshine.effects.glow)
    local textLoadingFont = fontcache.getFont("ocrx", 34)
    local preloadBannerAgain = love.graphics.newImage("assets/images/game/banner.png")
    local clockIcon = love.graphics.newImage("assets/images/game/clockico.png")

    love.graphics.clear(love.graphics.getBackgroundColor())
        ctrEffect(function()
            love.graphics.draw(preloadBannerAgain, 0, 0, 0, love.graphics.getWidth() / preloadBannerAgain:getWidth(), love.graphics.getHeight() / preloadBannerAgain:getHeight())
        end)
        love.graphics.draw(clockIcon, love.graphics.getWidth() - 69, love.graphics.getHeight() - 69, 0, 64 / clockIcon:getWidth(), 64 / clockIcon:getHeight())
        glowTextEffect(function()
            love.graphics.printf("Loading...", textLoadingFont, 0, love.graphics.getHeight() - (textLoadingFont:getHeight() + 16), love.graphics.getWidth(), "center")
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