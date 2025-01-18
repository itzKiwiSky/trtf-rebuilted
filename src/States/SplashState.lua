SplashState = {}

local function preloadAudio()
    local files = fsutil.scanFolder("assets/sounds", false, {"assets/sounds/night/calls"})

    for f = 1, #files, 1 do
        local filename = (((files[f]:lower()):gsub(" ", "_")):gsub("%.[^.]+$", "")):match("[^/]+$")
        loveloader.newSource(AudioSources, filename, files[f], "stream")
        if DEBUG_APP then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file queue to load with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", filename))
        end
    end
end

function SplashState:enter()
    subtitlesController.clear()

    preloadAudio()

    local introID = lume.weightedchoice({["trtl_meme.ogv"] = 25, ["new_intro.ogv"] = 75}) -- new_intro.ogv
    introVideo = love.graphics.newVideo("assets/videos/" .. introID)
    canContinue = false

    if introVideo then
        introVideo:play()
    end
    love.mouse.setVisible(false)

    VIDEO_WIDTH = love.graphics.getWidth() / introVideo:getWidth()
    VIDEO_HEIGHT = love.graphics.getHeight() / introVideo:getHeight()
end

function SplashState:draw()
    love.graphics.draw(introVideo, 0, 0, 0, VIDEO_WIDTH, VIDEO_HEIGHT)
end

function SplashState:update(elapsed)
    if not introVideo:isPlaying() and AUDIO_LOADED then
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
        love.mouse.setVisible(true)
        gamestate.switch(MenuState)
    else
        loveloader.update()
    end
end

function SplashState:keypressed(k)
    if AUDIO_LOADED then
        love.mouse.setVisible(true)
        gamestate.switch(MenuState)
    end
end

function SplashState:mousepressed(x, y, button)
    if AUDIO_LOADED then
        love.mouse.setVisible(true)
        gamestate.switch(MenuState)
    end
end

function SplashState:leave()
    introVideo:pause()
    introVideo:rewind()
    love.mouse.setVisible(true)
    for k, v in pairs(AudioSources) do
        v:stop()
    end
end

return SplashState