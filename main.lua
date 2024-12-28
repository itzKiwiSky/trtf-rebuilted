love.filesystem.load("src/Components/Initialization/Run.lua")()
love.filesystem.load("src/Components/Initialization/ErrorHandler.lua")()

function love.initialize(args)
    --CHEAT = false
    fontcache = require 'src.Components.Modules.System.FontCache'
    LanguageController = require 'src.Components.Modules.System.LanguageManager'
    _connectGJ = require 'src.Components.Modules.API.InitializeGJ'
    fsutil = require 'src.Components.Modules.Utils.FSUtils'

    AudioSources = {}

    fontcache.init()

    globalJoystick = love.joystick.getJoysticks()[1]

    fnt_subtitle = fontcache.getFont("tnr", 24)
    bg_subtitles = love.graphics.newGradient("horizontal", 
        {0, 0, 0, 0}, 
        {255, 255, 255, 255},
        {255, 255, 255, 255}, 
        {255, 255, 255, 255}, 
        {0, 0, 0, 0}
    )

    gameslot = neuron.new("trtfa")

    gameslot.save.game = {
        user = {
            settings = {
                shaders = true,
                language = "English",
                gamejolt = {
                    username = "",
                    usertoken = ""
                },
                fullscreen = false,
                vsync = false,
                antialiasing = true,
                subtitles = true,
                displayFPS = false,
            },
            progress = {
                initialCutscene = false,
                newgame = false,
                extras = false,
                canContinue = false,
                night = 1,
                playingMinigame = false,
                minigameID = 0,
            }
        }
    }
    gameslot:initialize()

    --CHEAT = true --gameslot.save.game.user.canUse

    languageService = LanguageController:getData(gameslot.save.game.user.settings.language)
    languageRaw = LanguageController:getRawData(gameslot.save.game.user.settings.language)

    registers = {
        user = {
            paused = false,
            gamejoltUI = false,
            loggedIn = false,
        },
        system = {
            showDebugHitbox = false,
            gameTime = 0,
            camEdit = false,
        }
    }

    -- do some shit with config --
    --love.window.setFullscreen(gameslot.save.game.user.settings.fullscreen, "exclusive")
    love.window.setVSync(gameslot.save.game.user.settings.vsync and 1 or 0)

    if gameslot.save.game.user.settings.antialiasing then
        love.graphics.setDefaultFilter("linear", "linear")
    else
        love.graphics.setDefaultFilter("nearest", "nearest")
    end

    local gitStuff = require 'src.Components.Initialization.GitStuff'
    _connectGJ()

    if not love.filesystem.isFused() then
        gitStuff.getAll()

        if love.filesystem.getInfo(".commitid") then
            local title = love.window.getTitle()
            love.window.setTitle(title .. " | " .. love.filesystem.read(".commitid"))
        end
    end

    local states = love.filesystem.getDirectoryItems("src/States")
    for s = 1, #states, 1 do
        require("src.States." .. states[s]:gsub(".lua", ""))
    end

    if DEBUG_APP then
        love.filesystem.createDirectory("screenshots")
    end

    th_ping = love.thread.newThread("src/Components/Modules/Game/Utils/ThreadPing.lua")

    tmr_gamejoltHeartbeat = timer.new()
    tmr_gamejoltHeartbeat:every(20, function()
        th_ping:start(
            registers,
            gameslot.save.game.user.settings.gamejolt.username, 
            gameslot.save.game.user.settings.gamejolt.usertoken
        )
    end)

    gamestate.registerEvents()
    --if CHEAT then
        --gamestate.switch(CheatState)
    --else
        gamestate.switch(SplashState)
    --end
end

function love.update(elapsed)
    if gamejolt.isLoggedIn then
        tmr_gamejoltHeartbeat:update(elapsed)
    end
end

function love.keypressed(k)
    if DEBUG_APP then
        if k == "f11" then
            love.graphics.captureScreenshot("screenshots/screen_" .. os.date("%Y-%m-%d %H-%M-%S") .. ".png")
        end
        if k == "f12" then
            error("Crash caused by manual trigger")
        end
        if k == "f9" then
            registers.system.showDebugHitbox = not registers.system.showDebugHitbox
        end
        if k == "f7" then
            registers.system.camEdit = not registers.system.camEdit
        end
        if k == "f4" then
            for k, v in pairs(AudioSources) do
                v:stop()
            end
            gamestate.switch(LoadingState)
        end
        if k == "f6" then
            for k, v in pairs(AudioSources) do
                v:stop()
            end
            gamestate.switch(WinState)
        end
        if registers.system.camEdit then
            if editBTN then
                if k == "f5" then
                    for _, p in ipairs(editBTN) do
                        print(string.format("{btn = buttonCamera(%s, %s, 72, 40)}", p.btn.x, p.btn.y))
                    end
                end
            end
        end
    end
end

function love.quit()
    if gamejolt.isLoggedIn then
        gamejolt.closeSession()
    end
end
