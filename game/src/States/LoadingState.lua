LoadingState = {}
LoadingState.mode = "normal"

function LoadingState:enter()
    self.ctrEffect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    self.glowTextEffect = moonshine(moonshine.effects.glow)

    print("why")

    subtitlesController.clear()

    local assetThread = require 'src.Modules.Game.Utils.AssetsLoad'
    self.ldBackgrounds = {}
    local bgs = love.filesystem.getDirectoryItems("assets/images/game/menu/backgrounds")
    for b = 1, #bgs, 1 do
        table.insert(self.ldBackgrounds, love.graphics.newImage("assets/images/game/menu/backgrounds/" .. bgs[b]))
    end
    bgs = nil

    collectgarbage("collect")

    self.textLoadingFont = fontcache.getFont("ocrx", 34)

    self.lockjawdance = {
        cfg = {
            acc = 0,
            speed = 35,
            frame = 1
        }
    }
    self.lockjawdance.image,self.lockjawdance.quads = love.graphics.newQuadFromImage("array", "assets/images/game/loading_lockjaw")

    self.ready = false
    self.pressToGO = false
    self.screen_fade = 0

    self._tempAssets = assetThread(self.mode)

    self.randBG = math.random(1, #self.ldBackgrounds)
    if registers.isNightLoaded then
        self.ready = true
    else
        loveloader.start(function()
            self.ready = true
            registers.isNightLoaded = true

            if self.mode == "secret" then
                self.pressToGO = true
            end
        end, function(k, h, k)
            if FEATURE_FLAGS.debug then
                io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : File loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}", k))
            end
        end)
    end
end

function LoadingState:draw()
    self.ctrEffect(function()
        love.graphics.draw(self.ldBackgrounds[self.randBG], 0, 0, 0, shove.getViewportWidth() / self.ldBackgrounds[self.randBG]:getWidth(), shove.getViewportHeight() / self.ldBackgrounds[self.randBG]:getHeight())
    end)
    --love.graphics.draw(clockIcon, shove.getViewportHeight() - 69, shove.getViewportHeight() - 69, 0, 64 / clockIcon:getWidth(), 64 / clockIcon:getHeight())
    love.graphics.draw(self.lockjawdance.image, self.lockjawdance.quads[self.lockjawdance.cfg.frame], shove.getViewportWidth() - 135, shove.getViewportHeight() - 135, 0, 128 / 300, 128 / 300)

    self.glowTextEffect(function()
        love.graphics.clear(0, 0, 0, 0)
        local percent = 0
        if loveloader.resourceCount > 0 then percent = loveloader.loadedCount / loveloader.resourceCount end
        local loadText = string.format(languageService[not self.ready and "loading_text" or "loading_ready"], (not self.ready and math.floor(percent * 100) or nil))
        love.graphics.printf(loadText, self.textLoadingFont, 0, shove.getViewportHeight() - (self.textLoadingFont:getHeight() + 16), shove.getViewportWidth(), "center")
    end)

    love.graphics.setColor(0, 0, 0, self.screen_fade)
        love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

function LoadingState:update(elapsed)
    self.lockjawdance.cfg.acc = self.lockjawdance.cfg.acc + elapsed

    if self.lockjawdance.cfg.acc >= 1 / self.lockjawdance.cfg.speed then
        self.lockjawdance.cfg.acc = 0
        self.lockjawdance.cfg.frame = self.lockjawdance.cfg.frame + 1
        if self.lockjawdance.cfg.frame > #self.lockjawdance.quads then
            self.lockjawdance.cfg.frame = 1
        end
    end

    if not self.ready then
        loveloader.update()
    elseif self.ready and self.pressToGO then
        self.screen_fade = self.screen_fade + 0.4 * elapsed
    end

    if self.ready and self.pressToGO and self.screen_fade > 1 then
        if self.mode == "normal" then
            NightState.assets = self._tempAssets
            gamestate.switch(NightState)
        elseif self.mode == "secret" then
            SecretNightState.assets = self._tempAssets
            gamestate.switch(SecretNightState)
        end
    end
end

function LoadingState:keypressed(k)
    if self.ready and not self.pressToGO then
        self.pressToGO = true
    end
end

function LoadingState:mousepressed(x, y, button)
    if self.ready and not self.pressToGO then
        self.pressToGO = true
    end
end

function LoadingState:leave()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
    for _, b in ipairs(self.ldBackgrounds) do
        b:release()
    end
end

return LoadingState