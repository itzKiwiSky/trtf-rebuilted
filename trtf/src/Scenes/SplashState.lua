local function preloadAudio()
    local files = fsutil.scanFolder("assets/sounds", false, {"assets/sounds/night/calls"})

    for f = 1, #files, 1 do
        local filename = (((files[f]:lower()):gsub(" ", "_")):gsub("%.[^.]+$", "")):match("[^/]+$")
        loveloader.newSource(SoundController.sources, filename, files[f], "stream")
        if FEATURE_FLAGS.debug then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file queue to load with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", filename))
        end
    end
end

SplashState = {}

function SplashState:enter()
    subtitlesController.clear()
    self.AUDIO_LOADED = false
    preloadAudio()

    loveloader.start(function()
        self.AUDIO_LOADED = true
    end, function(k, h, n)
        if FEATURE_FLAGS.debug then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", n))
        end
    end)

    local introID = lume.weightedchoice({["trtl_meme.ogv"] = 25, ["new_intro.ogv"] = 75}) -- new_intro.ogv
    self.introVideo = love.graphics.newVideo("assets/videos/" .. introID)
    self.canContinue = false

    if self.introVideo then
        self.introVideo:play()
    end
    
    love.mouse.setVisible(false)

    self.VIDEO_WIDTH = love.graphics.getWidth() / self.introVideo:getWidth()
    self.VIDEO_HEIGHT = love.graphics.getHeight() / self.introVideo:getHeight()
end

function SplashState:draw()
    love.graphics.draw(self.introVideo, 0, 0, 0, self.VIDEO_WIDTH, self.VIDEO_HEIGHT)
end

function SplashState:update(elapsed)
    if FEATURE_FLAGS.debug and (self.introVideo:isPlaying() and self.AUDIO_LOADED) or (not self.introVideo:isPlaying() and self.AUDIO_LOADED) then
        --[[
        if not gameslot.save.game.user.progress.initialCutscene then
            VideoSceneState.path = "assets/videos/lockjaw_cinematic.ogv"
            VideoSceneState.onSceneComplete = function()
                gameslot.save.game.user.progress.initialCutscene = true
                gameslot:saveSlot()
            end
            VideoSceneState.targetState = MenuState
            gamestate.switch(VideoSceneState)
        else
            gamestate.switch(MenuState)
        end
        ]]--
        gamestate.switch(MenuState)
    else
        loveloader.update()
    end
end

function SplashState:keypressed(k)
    if self.AUDIO_LOADED then
        gamestate.switch(MenuState)
    end
end

function SplashState:mousepressed(x, y, button)
    if self.AUDIO_LOADED then
        gamestate.switch(MenuState)
    end
end

function SplashState:leave()
    -- release all objects from the scene before leave
    self.introVideo:pause()
    self.introVideo:rewind()
    love.mouse.setVisible(true)
    SoundController.stopAllChannels()
    SoundController.getChannel("music"):stop()
    SoundController.getChannel("sfx"):stop()
end

return SplashState