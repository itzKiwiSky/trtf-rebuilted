DeathState = {}

function DeathState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    self.staticeffect = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }
    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static")
    for s = 1, #statics, 1 do
        table.insert(self.staticeffect.frames, love.graphics.newImage("assets/images/game/effects/static/" .. statics[s]))
    end

    self.fnt_gameover = fontcache.getFont("tnr", 30)
    self.fnt_gameoverTitle = fontcache.getFont("tnr", 60)
    self.fnt_gameoverExplain = fontcache.getFont("tnr", 24)

    self.screen_effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)

    --if gameslot.save.game.user.settings.shaders then
    --    screen_effect.enable("crt", "vignette")
    --else
    --    screen_effect.disable("crt", "vignette")
    --end

    self.blurFX = moonshine(moonshine.effects.gaussianblur)
    self.blurFX.gaussianblur.sigma = 8

    self.dicons = {}
    local icfls = love.filesystem.getDirectoryItems("assets/images/game/night/cn_icons")
    for c = 1, #icfls, 1 do
        local name = icfls[c]:gsub("%.[^.]+$", "")
        self.dicons[name] = love.graphics.newImage("assets/images/game/night/cn_icons/" .. icfls[c])
    end

    self.bg = love.graphics.newImage("assets/images/game/night/gameover.png")
    self.bgfade = 0
    self.startAngle = -30
    self.startZoom = 5
    AudioSources["boom_death"]:play()

    self.gameOptions = {
        y = shove.getViewportHeight() * 2,
        clickItems = false,
        textDisplay = 0,
        canDisplay = false,
        color = 1
    }

    self.explaindeath = {
        y = shove.getViewportHeight() * 2,
        alpha = 0
    }

    self.gitems = {
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
                for k, v in pairs(AudioSources) do
                    v:stop()
                end
                gamestate.switch(MenuState)
            end
        },
    }

    for t = 1, #self.gitems, 1 do
        self.gitems[t].hitbox = {
            x = shove.getViewportWidth() / 2 - self.fnt_gameover:getWidth(self.gitems[t].text) / 2,
            y = ((shove.getViewportHeight() - 400) + (self.fnt_gameover:getHeight() + 16) * t) - 4,
            w = self.fnt_gameover:getWidth(self.gitems[t].text) + 8,
            h = self.fnt_gameover:getHeight() + 8
        }
        self.gitems[t].y = self.gameOptions.y + (self.fnt_gameover:getHeight() + 16) * t
    end

    self.gameOptions.y = shove.getViewportHeight() * 2

    self.twn_death = flux.group()

    self.tmr_deathbegin = timer.new()
    self.tmr_deathbegin:after(3.5, function()
        self.gameOptions.canDisplay = true
        self.tween_Options = self.twn_death:to(self.gameOptions, 0.8, { y = shove.getViewportHeight() - 400 })
        :ease("sineout")
        :oncomplete(function()
            self.gameOptions.clickItems = true
        end)
        :after(self.explaindeath, 1.2, {y = shove.getViewportHeight() - 120, alpha = 1})
        :ease("sineout")
    end)

end

function DeathState:draw()
    self.screen_effect(function()
        love.graphics.setColor(0, 0, 0, self.bgfade)
            love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.bg, shove.getViewportWidth() / 2, shove.getViewportHeight() / 2, math.rad(self.startAngle), self.startZoom, self.startZoom, self.bg:getWidth() / 2, self.bg:getHeight() / 2)

        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.draw(self.staticeffect.frames[self.staticeffect.config.frameid], 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        for _, i in ipairs(self.gitems) do
            if i.hovered then
                love.graphics.setBlendMode("add")
                    self.blurFX(function()
                        love.graphics.clear(0, 0, 0, 0)
                        love.graphics.print(i.text, self.fnt_gameover, shove.getViewportWidth() / 2 - self.fnt_gameover:getWidth(i.text) / 2, self.gameOptions.y + (self.fnt_gameover:getHeight() + 16) * _)
                    end)
                love.graphics.setBlendMode("alpha")
            end
            love.graphics.print(i.text, self.fnt_gameover, shove.getViewportWidth() / 2 - self.fnt_gameover:getWidth(i.text) / 2, self.gameOptions.y + (self.fnt_gameover:getHeight() + 16) * _)
        end
        
        love.graphics.setColor(1, self.gameOptions.color, self.gameOptions.color, self.gameOptions.textDisplay)
            love.graphics.setBlendMode("add")
                self.blurFX(function()
                    love.graphics.clear(0, 0, 0, 0)
                    love.graphics.printf(languageService["gameover_title"], self.fnt_gameoverTitle, 0, 200, shove.getViewportWidth(), "center")
                end)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(languageService["gameover_title"], self.fnt_gameoverTitle, 0, 200, shove.getViewportWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)

        --love.graphics.draw()
        love.graphics.setColor(1, 1, 1, self.explaindeath.alpha)
        if NightState.KilledBy == "" then
            love.graphics.draw(self.dicons["dummy"], 24, self.explaindeath.y, 0, 72 / self.dicons["dummy"]:getWidth(), 72 / dicons["dummy"]:getHeight())
            love.graphics.setBlendMode("add")
                self.blurFX(function()
                    love.graphics.clear(0, 0, 0, 0)
                    love.graphics.printf(languageService["gameover_explain_dummy"], self.fnt_gameoverExplain, 120, self.explaindeath.y, shove.getViewportWidth() - 260, "left")
                end)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(languageService["gameover_explain_dummy"], self.fnt_gameoverExplain, 120, self.explaindeath.y, shove.getViewportWidth() - 260, "left")
        elseif self.dicons[NightState.KilledBy] then
            love.graphics.draw(self.dicons[NightState.KilledBy], 24, explaindeath.y, 0, 72 / self.dicons[NightState.KilledBy]:getWidth(), 72 / self.dicons[NightState.KilledBy]:getHeight())
            love.graphics.setBlendMode("add")
                self.blurFX(function()
                    love.graphics.clear(0, 0, 0, 0)
                    love.graphics.printf(languageService["gameover_explain_" .. NightState.KilledBy], self.fnt_gameoverExplain, 120, self.explaindeath.y, shove.getViewportWidth() - 260, "left")
                end)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(languageService["gameover_explain_" .. NightState.KilledBy], self.fnt_gameoverExplain, 120, self.explaindeath.y, shove.getViewportWidth() - 260, "left")
        elseif NightState.KilledBy == "oxygen" then
            love.graphics.setBlendMode("add")
                self.blurFX(function()
                    love.graphics.clear(0, 0, 0, 0)
                    love.graphics.printf(languageService["gameover_explain_oxygen"], self.fnt_gameoverExplain, 120, self.explaindeath.y, shove.getViewportWidth() - 260, "left")
                end)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(languageService["gameover_explain_oxygen"], self.fnt_gameoverExplain, 120, self.explaindeath.y, shove.getViewportWidth() - 260, "left")
        end
        love.graphics.setLineWidth(5)
            self.blurFX(function()
                love.graphics.clear(0, 0, 0, 0)
                love.graphics.rectangle("line", 24, self.explaindeath.y, 72, 72)
            end)
            love.graphics.rectangle("line", 24, self.explaindeath.y, 72, 72)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)
    end)
end

function DeathState:update(elapsed)
    self.startAngle = math.lerp(self.startAngle, 0, 0.039)
    self.startZoom = math.lerp(self.startZoom, 1, 0.039)

    if self.gameOptions.canDisplay then
        self.gameOptions.textDisplay = self.gameOptions.textDisplay + 0.5 * elapsed
        if self.gameOptions.textDisplay >= 1 then
            self.gameOptions.color = self.gameOptions.color - 0.8 * elapsed
        end
    end
        -- static animation --
    self.staticeffect.config.timer = self.staticeffect.config.timer + elapsed
    if self.staticeffect.config.timer >= self.staticeffect.config.speed then
        self.staticeffect.config.timer = 0
        self.staticeffect.config.frameid = self.staticeffect.config.frameid + 1
        if self.staticeffect.config.frameid >= #self.staticeffect.frames then
            self.staticeffect.config.frameid = 1
        end
    end
    
    if self.gameOptions.clickItems then
        for _, i in ipairs(self.gitems) do
            local inside, mx, my = shove.mouseToViewport()
            if collision.pointRect({x = mx, y = my}, i.hitbox) then
                i.hovered = true
            else
                i.hovered = false
            end
        end
    end

    self.tmr_deathbegin:update(elapsed)
    self.twn_death:update(elapsed)
end

function DeathState:mousepressed(x, y, button)
    if self.gameOptions.clickItems then
        for _, i in ipairs(self.gitems) do
            local inside, mx, my = shove.mouseToViewport()
            if collision.pointRect({x = mx, y = my}, i.hitbox) then
                if i.action then
                    i.action()
                end
            end
        end
    end
end

return DeathState