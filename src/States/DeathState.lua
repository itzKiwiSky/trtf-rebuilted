DeathState = {}

function DeathState:enter()
    fnt_gameover = fontcache.getFont("tnr", 30)
    fnt_gameoverTitle = fontcache.getFont("tnr", 60)
    fnt_gameoverExplain = fontcache.getFont("tnr", 24)

    screen_effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    blurFX = moonshine(moonshine.effects.gaussianblur)
    blurFX.gaussianblur.sigma = 8

    dicons = {}
    local icfls = love.filesystem.getDirectoryItems("assets/images/game/night/cn_icons")
    for c = 1, #icfls, 1 do
        local name = icfls[c]:gsub("%.[^.]+$", "")
        dicons[name] = love.graphics.newImage("assets/images/game/night/cn_icons/" .. icfls[c])
    end

    bg = love.graphics.newImage("assets/images/game/night/gameover.png")
    bgfade = 0
    startAngle = -30
    startZoom = 5
    AudioSources["boom_death"]:play()

    gameOptions = {
        y = love.graphics.getHeight() * 2,
        clickItems = false,
        textDisplay = 0,
        canDisplay = false,
        color = 1
    }

    explaindeath = {
        y = love.graphics.getHeight() * 2,
        alpha = 0
    }

    gitems = {
        {
            text = languageService["gameover_button_retry"],
            hovered = false,
            hitbox = {},
            action = function()
                
            end
        },
        {
            text = languageService["gameover_button_exit"],
            hovered = false,
            hitbox = {},
            action = function()
                
            end
        },
    }

    for t = 1, #gitems, 1 do
        gitems[t].hitbox = {
            x = love.graphics.getWidth() / 2 - fnt_gameover:getWidth(gitems[t].text) / 2,
            y = ((love.graphics.getHeight() - 400) + (fnt_gameover:getHeight() + 16) * t) - 4,
            w = fnt_gameover:getWidth(gitems[t].text) + 8,
            h = fnt_gameover:getHeight() + 8
        }
        gitems[t].y = gameOptions.y + (fnt_gameover:getHeight() + 16) * t
    end

    gameOptions.y = love.graphics.getHeight() * 2

    tmr_deathbegin = timer.new()
    tmr_deathbegin:after(3.5, function()
        gameOptions.canDisplay = true
        tween_Options = flux.to(gameOptions, 1.5, { y = love.graphics.getHeight() - 400 })
        :ease("sineout")
        :oncomplete(function()
            gameOptions.clickItems = true
        end)
        :after(explaindeath, 2, {y = love.graphics.getHeight() - 120, alpha = 1})
        :ease("sineout")
    end)

end

function DeathState:draw()
    screen_effect(function()
        love.graphics.setColor(0, 0, 0, bgfade)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(bg, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, math.rad(startAngle), startZoom, startZoom, bg:getWidth() / 2, bg:getHeight() / 2)

        for _, i in ipairs(gitems) do
            --love.graphics.rectangle("line", i.hitbox.x, i.hitbox.y, i.hitbox.w, i.hitbox.h)
            if i.hovered then
                love.graphics.setBlendMode("add")
                    blurFX(function()
                        love.graphics.clear(0, 0, 0, 0)
                        love.graphics.print(i.text, fnt_gameover, love.graphics.getWidth() / 2 - fnt_gameover:getWidth(i.text) / 2, gameOptions.y + (fnt_gameover:getHeight() + 16) * _)
                    end)
                love.graphics.setBlendMode("alpha")
            end
            love.graphics.print(i.text, fnt_gameover, love.graphics.getWidth() / 2 - fnt_gameover:getWidth(i.text) / 2, gameOptions.y + (fnt_gameover:getHeight() + 16) * _)
        end

        love.graphics.setColor(1, gameOptions.color, gameOptions.color, gameOptions.textDisplay)
            love.graphics.setBlendMode("add")
                blurFX(function()
                    love.graphics.clear(0, 0, 0, 0)
                    love.graphics.printf(languageService["gameover_title"], fnt_gameoverTitle, 0, 200, love.graphics.getWidth(), "center")
                end)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(languageService["gameover_title"], fnt_gameoverTitle, 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)

        --love.graphics.draw()
        love.graphics.setColor(1, 1, 1, explaindeath.alpha)
        if NightState.KilledBy == "" then
            love.graphics.draw(dicons["dummy"], 24, explaindeath.y, 0, 72 / dicons["dummy"]:getWidth(), 72 / dicons["dummy"]:getHeight())
            love.graphics.setBlendMode("add")
                blurFX(function()
                    love.graphics.clear(0, 0, 0, 0)
                    love.graphics.printf(languageService["gameover_explain_dummy"], fnt_gameoverExplain, 120, explaindeath.y, love.graphics.getWidth() - 260, "left")
                end)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(languageService["gameover_explain_dummy"], fnt_gameoverExplain, 120, explaindeath.y, love.graphics.getWidth() - 260, "left")
        else
            love.graphics.draw(dicons[NightState.KilledBy], 24, explaindeath.y, 0, 72 / dicons[NightState.KilledBy]:getWidth(), 72 / dicons[NightState.KilledBy]:getHeight())
            love.graphics.setBlendMode("add")
                blurFX(function()
                    love.graphics.clear(0, 0, 0, 0)
                    love.graphics.printf(languageService["gameover_explain_" .. NightState.KilledBy], fnt_gameoverExplain, 120, explaindeath.y, love.graphics.getWidth() - 260, "left")
                end)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(languageService["gameover_explain_" .. NightState.KilledBy], fnt_gameoverExplain, 120, explaindeath.y, love.graphics.getWidth() - 260, "left")
        end
        love.graphics.setLineWidth(5)
            blurFX(function()
                love.graphics.clear(0, 0, 0, 0)
                love.graphics.rectangle("line", 24, explaindeath.y, 72, 72)
            end)
            love.graphics.rectangle("line", 24, explaindeath.y, 72, 72)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)
    end)
end

function DeathState:update(elapsed)
    startAngle = math.lerp(startAngle, 0, 0.039)
    startZoom = math.lerp(startZoom, 1, 0.039)

    if gameOptions.canDisplay then
        gameOptions.textDisplay = gameOptions.textDisplay + 0.5 * elapsed
        if gameOptions.textDisplay >= 1 then
            gameOptions.color = gameOptions.color - 0.8 * elapsed
        end
    end

    if gameOptions.clickItems then
        for _, i in ipairs(gitems) do
            local mx, my = love.mouse.getPosition()
            if collision.pointRect({x = mx, y = my}, i.hitbox) then
                i.hovered = true
            else
                i.hovered = false
            end
        end
    end

    tmr_deathbegin:update(elapsed)
    flux.update(elapsed)
end

function DeathState:mousepressed(x, y, button)
    if gameOptions.clickItems then
        for _, i in ipairs(gitems) do
            local mx, my = love.mouse.getPosition()
            if collision.pointRect({x = mx, y = my}, i.hitbox) then
                if i.action then
                    i.action()
                end
            end
        end
    end
end

return DeathState