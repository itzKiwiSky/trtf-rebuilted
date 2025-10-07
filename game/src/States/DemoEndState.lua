DemoEndState = {}

function DemoEndState:enter()
    self.background = love.graphics.newImage("assets/images/game/end_of_demo_gay_sex.png")
    self.titleFont = fontcache.getFont("tnr", 50)
    self.textFont = fontcache.getFont("tnr", 36)

    self.glowText = moonshine(moonshine.effects.glow)

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
        self.textconfig.showTitle = true
        sleep(1.5)
        self.textconfig.showText = true
        sleep(7)
        self.transition.activeOut = true
    end)
end

function DemoEndState:draw()
    love.graphics.draw(self.background)

    self.glowText(function()
        love.graphics.setColor(0, 0, 0, self.textconfig.alphaTitle)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setColor(0, 0, 0, self.textconfig.alpha)
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

    if self.textconfig.showTitle then
        self.textconfig.alphaTitle = self.textconfig.alphaTitle + 0.35 * elapsed
        
        if textconfig.alphaTitle >= 1 then
            self.textconfig.showTitle = false
        end 
    end

    if self.textconfig.showText then
        self.textconfig.alpha = self.textconfig.alpha + 0.35 * elapsed
        
        if textconfig.alpha >= 1 then
            self.textconfig.showText = false
        end 
    end

    self.tmr_countDowm:update(elapsed)
end

function DemoEndState:leave(elapsed)
    self.tmr_countDowm:cancel()
    for key, value in pairs(AudioSources) do
        value:stop()
    end

    self.background:release()
end

return DemoEndState