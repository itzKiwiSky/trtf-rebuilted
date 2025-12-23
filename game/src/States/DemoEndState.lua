DemoEndState = {}

function DemoEndState:enter()
    self.background = nil
    self.titleFont = fontcache.getFont("tnr", 50)
    self.textFont = fontcache.getFont("tnr", 30)

    self.glowText = moonshine(moonshine.effects.glow)
    local blurredBG = moonshine(moonshine.effects.gaussianblur)
    blurredBG.gaussianblur.sigma = 5

    local bgtexture = love.graphics.newImage("assets/images/game/end_of_demo_gay_sex.png")
    local canvas = love.graphics.newCanvas(bgtexture:getDimensions())
    canvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        blurredBG(function()
            love.graphics.draw(bgtexture)
        end)
    end)
    self.background = love.graphics.newImage(canvas:newImageData())
    canvas:release()
    bgtexture:release()
    blurredBG = nil

    AudioSources["bg_sfx_end_demo"]:setLooping(true)
    AudioSources["bg_sfx_end_demo"]:setVolume(0.35)
    AudioSources["bg_sfx_end_demo"]:play()

    self.textconfig = {
        alpha = 0,
        alphaTitle = 0,
        showTitle = false,
        showText = false,
    }

    self.transition = {
        alpha = 1,
        activeIn = true,
        activeOut = false,
        outState = MenuStates
    }

    self.tmr_countDowm = timer.new()
    self.tmr_countDowm:script(function(sleep)
        sleep(2.5)
        print("sex")
        flux.to(self.textconfig, 2, { alphaTitle = 1 })
        sleep(1.5)
        flux.to(self.textconfig, 2, { alpha = 1 })
        sleep(7)
        self.transition.activeOut = true
    end)
end

function DemoEndState:draw()
    love.graphics.draw(self.background)

    self.glowText(function()
        love.graphics.setColor(1, 1, 1, self.textconfig.alphaTitle)
        love.graphics.printf(languageService["end_demo_title"], self.titleFont, 0, 128, shove.getViewportWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(1, 1, 1, self.textconfig.alpha)
        love.graphics.printf(languageService["end_demo_text"], self.textFont, 64, shove.getViewportHeight() - 128, shove.getViewportWidth() - 128, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end)

    love.graphics.setColor(0, 0, 0, self.transition.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function DemoEndState:update(elapsed)
    if self.transition.activeOut then
        self.transition.alpha = self.transition.alpha + 0.35 * elapsed

        if self.transition.alpha >= 1 then
            self.activeOut = false
            gamestate.switch(self.transition.outState)
        end
    end

    if self.transition.activeIn then
        self.transition.alpha = self.transition.alpha - 0.35 * elapsed

        if self.transition.alpha <= 0 then
            self.activeIn = false
        end
    end

    flux.update(elapsed)

    self.tmr_countDowm:update(elapsed)
end

function DemoEndState:leave(elapsed)
    flux.removeAll()
    self.tmr_countDowm:cancel()
    for key, value in pairs(AudioSources) do
        value:stop()
    end

    self.background:release()
    self.titleFont:release()
    self.textFont:release()
end

return DemoEndState
