SplashState = {}

local function preloadAudio()
    local files = fsutil.scanFolder("assets/sounds", false, {"assets/sounds/night/calls"})

    for f = 1, #files, 1 do
        local filename = (((files[f]:lower()):gsub(" ", "_")):gsub("%.[^.]+$", "")):match("[^/]+$")
        --AudioSources[filename] = love.audio.newSource(files[f], "stream")
        loveloader.newSource(AudioSources, filename, files[f], "stream")
        if DEBUG_APP then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file preloaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", filename))
        end
    end
end

function SplashState:enter()
    preloadAudio()

    introVideo = love.graphics.newVideo("assets/videos/new_intro.ogv")
    canContinue = false

    if introVideo then
        introVideo:play()
    end
    love.mouse.setVisible(false)

    loveloader.start(function()
        canContinue = true
    end)
end

function SplashState:draw()
    love.graphics.draw(introVideo, 0, 0)
end

function SplashState:update(elapsed)
    if not introVideo:isPlaying() and canContinue then
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

return SplashState