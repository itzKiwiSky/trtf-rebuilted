require('src.Modules.System.Run')
require('src.Modules.System.Utils.ErrHandler')
local gitstuff = require 'src.Modules.System.GitStuff'  -- super important stuff --
local initializeAPI = require 'src.Modules.System.InitializeAPI'

languageService = {}
languageRaw = {}

local function loadSettings()
    local languageManager = require 'src.Modules.System.Utils.LanguageManager'
    -- commit all changes from virtual settings to the actual settings --
    gameSave.save.user.settings = registers.user.virtualSettings

    local winSize = love.window.resolutionModes[gameSave.save.user.settings.video.winsize]
    love.window.updateMode(winSize.width, winSize.height,
        { 
            fullscreen = gameSave.save.user.settings.video.fullscreen, 
            vsync = gameSave.save.user.settings.video.vsync,
        }
    )
    
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

    EFFECT_DENSITY = {
        REQUIRED_EFFECTS = 1,
        MIN_EFFECTS = 2,
        MAX_EFFECTS = 3,
    }

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
                    msaa = 0,
                    effectDensity = EFFECT_DENSITY.MAX_EFFECTS
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
                },
                controls = {
                    ["game_move_left"] = { "axis:rightx-" },
                    ["game_move_right"] = { "axis:rightx+" },
                    ["game_close_door_left"] = { "button:leftshoulder", "key:left", "key:a" },
                    ["game_close_door_right"] = { "button:rightshoulder", "key:right", "key:d" },
                    ["game_mask"] = { "key:lshift", "key:x", "button:y" },
                    ["game_tablet"] = { "key:space", "key:up", "button:a" },
                    ["game_flashlight"] = { "key:z", "key:lctrl", "button:x" },
                    ["game_change_cam_left"] = { "key:left", "key:a", "button:leftshoulder", "button:dpleft" },
                    ["game_change_cam_right"] = { "key:right", "key:d", "button:rightshoulder", "button:dpright" },
                    ["ui_left"] = { "key:left", "key:a", "axis:leftx-" },
                    ["ui_right"] = { "key:right", "key:d", "axis:leftx+" },
                    ["ui_up"] = { "key:left", "key:a", "axis:lefty+" },
                    ["ui_down"] = { "key:left", "key:a", "axis:lefty-" },
                    ["ui_accept"] = { "key:return", "button:a", "button:start" },
                    ["ui_back"] = { "key:escape", "key:backspace", "button:b" }
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

    Controller = baton.new({
        controls = gameSave.save.user.settings.controls,
        joystick = love.joystick.getJoysticks()[1],
    })

    registers = {
        isNightLoaded = false,
        devWindow = false,
        devWindowContent = function() return end,
        showDebugHitbox = false,
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

    if gameSave.save.user.settings.misc.discordRichPresence then
        initializeAPI()
    end

    languageService = languageManager.getData(gameSave.save.user.settings.misc.language)
    languageRaw = languageManager.getRawData(gameSave.save.user.settings.misc.language)

    loadSettings()

    -- autoload states --
    local states = love.filesystem.getDirectoryItems("src/States")
    for s = 1, #states, 1 do
        if love.filesystem.getInfo("src/States/" .. states[s]).type == "file" then
            require("src.States." .. states[s]:gsub(".lua", ""))
        end
    end

    -- some discord thing callbacks --
    if gameSave.save.user.settings.misc.discordRichPresence then
        function discordRPC.ready(userId, username, discriminator, avatar)
            io.printf(string.format("{bgBlue}{brightBlue}{bold}[Discord]{reset}{brightBlue} : Client connected (%s, %s, %s){reset}\n", userId, username, discriminator))
        end

        function discordRPC.disconnected(errorCode, message)
            io.printf(string.format("{bgBlue}{brightBlue}{bold}[Discord]{reset}{brightBlue} : Client disconnected (%d, %s){reset}\n", errorCode, message))
        end

        function discordRPC.errored(errorCode, message)
            io.printf(string.format("{bgBlue}{brightBlue}{bold}[Discord]{reset}{bgRed}{brightWhite}[Error]{reset}{brightWhite} : (%d, %s){reset}\n", errorCode, message))
        end
    end

    
    love.filesystem.createDirectory("screenshots")

    gamestate.registerEvents()
    gamestate.switch(SplashState)
end


function love.quit()
    discordRPC.shutdown()
end