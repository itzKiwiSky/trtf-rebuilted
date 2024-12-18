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
    preloadAudio()

    introVideo = love.graphics.newVideo("assets/videos/new_intro.ogv")
    canContinue = false

    if introVideo then
        introVideo:play()
    end
    love.mouse.setVisible(false)

    loveloader.start(function()
        canContinue = true
    end, function(k, h, n)
        if DEBUG_APP then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", n))
        end
    end)
end

function SplashState:draw()
    love.graphics.draw(introVideo, 0, 0)
end

function SplashState:update(elapsed)
    if not introVideo:isPlaying() then
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
    if canContinue then
        introVideo:pause()
        introVideo:rewind()
        love.mouse.setVisible(true)
        gamestate.switch(MenuState)
    end
end

function SplashState:leave()
    introVideo:pause()
    introVideo:rewind()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
end

return SplashState