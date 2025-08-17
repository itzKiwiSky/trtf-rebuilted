require('src.Modules.System.Run')
require('src.Modules.System.Utils.ErrHandler')
local gitstuff = require 'src.Modules.System.GitStuff'  -- super important stuff --
local connectGJ = require 'src.Modules.System.InitializeAPI'

languageService = {}
languageRaw = {}

local function loadSettings()
    local languageManager = require 'src.Modules.System.Utils.LanguageManager'
    -- commit all changes from virtual settings to the actual settings --
    gameSave.save.user.settings = registers.user.virtualSettings

    local winSize = love.window.resolutionModes[gameSave.save.user.settings.video.winsize]

    --love.window.updateMode(winSize.width, winSize.height, { 
    --    fullscreen = gameSave.save.user.settings.video.fullscreen, 
    --    vsync = gameSave.save.user.settings.video.vsync,
    --})
    --shove.resize(winSize.width, winSize.height)

    love.window.setVSync(gameSave.save.user.settings.video.vsync and 1 or 0)
    love.window.setFullscreen(gameSave.save.user.settings.video.fullscreen)

    love._FPSCap = gameSave.save.user.settings.video.fpsCap
    love.graphics.setDefaultFilter(
        gameSave.save.user.settings.video.filter and "linear" or "nearest",
        gameSave.save.user.settings.video.filter and "linear" or "nearest"
    )

    -- audio --
    love.audio.setVolume(gameSave.save.user.settings.audio.masterVolume * 0.01)

    -- misc stuff --
    languageService = languageManager.getData(gameSave.save.user.settings.misc.language)
    languageRaw = languageManager.getRawData(gameSave.save.user.settings.misc.language)
end

function love.initialize()
    local languageManager = require 'src.Modules.System.Utils.LanguageManager'
    SoundManager = require 'src.Modules.System.Utils.Sound'
    AudioSources = {}
    local save = require 'src.Modules.System.Utils.Save'

    love.setDeprecationOutput(false)

    fnt_subtitle = fontcache.getFont("tnr", 24)
    bg_subtitles = love.graphics.newGradient("horizontal", 
        {0, 0, 0, 0}, 
        {255, 255, 255, 255},
        {255, 255, 255, 255}, 
        {255, 255, 255, 255}, 
        {0, 0, 0, 0}
    )

    gameSave = save.new("game")

    gameSave.save = {
        clientID = stid(),
        user = {
            settings = {
                video = {
                    winsize = 1,
                    fullscreen = false,
                    vsync = false,
                    fpsCap = 200,
                    filter = "nearest",
                    showFPS = false,
                },
                audio = {
                    masterVolume = 75,
                    sfxVolume = 60,
                    musicVolume = 60,
                },
                misc = {
                    language = "English",
                    gamejolt = {
                        username = "",
                        usertoken = ""
                    },
                    subtitles = true,
                    discordRichPresence = true,
                    gamepadSupport = false,
                    cacheNight = false,
                }
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

    gameSave:initialize()
    love.keyboard.setTextInput( true )

    local Controls = json.decode(love.filesystem.read("Controls.json"))
    Controller = baton.new({
        controls = Controls,
        joystick = love.joystick.getJoysticks()[1],
    })

    registers = {
        isSessionOpen = false,
        isConnectWindowOpen = false,
        isNightLoaded = false,
        devWindow = false,
        devWindowContent = function() return end,
        showDebugHitbox = false,
        statesName = {},
        user = {
            currentSettingsTab = "video",
            virtualSettings = gameSave.save.user.settings,
            videoSettingsChanged = false,
            currentChallengeID = 1,
            isCustomChallenge = true,
        }
    }

    loveloader.start(function()
        AUDIO_LOADED = true
    end, function(k, h, n)
        if FEATURE_FLAGS.debug then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", n))
        end
    end)

    gitstuff()      -- still super important --

    languageService = languageManager.getData(gameSave.save.user.settings.misc.language)
    languageRaw = languageManager.getRawData(gameSave.save.user.settings.misc.language)

    loadSettings()

    -- autoload states --
    local states = love.filesystem.getDirectoryItems("src/States")
    for s = 1, #states, 1 do
        if love.filesystem.getInfo("src/States/" .. states[s]).type == "file" then
            require("src.States." .. states[s]:gsub(".lua", ""))
            local strName = states[s]:gsub(".lua", "")
            table.insert(registers.statesName, strName)
        end
    end

    -- create a thread for ping into gamejolt --
    local GJPing = love.thread.newThread("src/Modules/Game/Utils/ThreadPing.lua")

    GJPing:start(
        gameSave.save.user.settings.misc.gamejolt.username,
        gameSave.save.user.settings.misc.gamejolt.usertoken
    )

    if gamejolt.isLoggedIn then
        heartbeatTimer = timer.new()
        heartbeatTimer:every(20, function ()
            GJPing:start(
                gameSave.save.user.settings.misc.gamejolt.username,
                gameSave.save.user.settings.misc.gamejolt.usertoken
            )
        end)
    end

    
    love.filesystem.createDirectory("screenshots")

    gamestate.registerEvents()
    gamestate.switch(SplashState)
end

function love.update(elapsed)
    if gamejolt.isLoggedIn then
        heartbeatTimer:update(elapsed)
    end
end

function love.quit()
    if gamejolt.isLoggedIn then
        gamejolt.closeSession()
    end
end