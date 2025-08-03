require('src.Modules.System.Run')
require('src.Modules.System.Utils.ErrHandler')
local gitstuff = require 'src.Modules.System.GitStuff'  -- super important stuff --
local initializeAPI = require 'src.Modules.System.InitializeAPI'

local function preloadAudio(target)
    local files = fsutil.scanFolder("assets/sounds", false, { "assets/sounds/night/calls" })

    for f = 1, #files, 1 do
        local filename = (((files[f]:lower()):gsub(" ", "_")):gsub("%.[^.]+$", "")):match("[^/]+$")
        loveloader.newSource(target, filename, files[f], "stream")
        if FEATURE_FLAGS.debug then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file queue to load with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", filename))
        end
    end
end

function love.initialize()
    SoundManager = require 'src.Modules.System.Utils.Sound'
    AudioSources = {}
    local save = require 'src.Modules.System.Utils.Save'

    love.setDeprecationOutput(false)

    preloadAudio(AudioSources)
    
    fnt_subtitle = fontcache.getFont("tnr", 24)
    bg_subtitles = love.graphics.newGradient("horizontal", 
        {0, 0, 0, 0}, 
        {255, 255, 255, 255},
        {255, 255, 255, 255}, 
        {255, 255, 255, 255}, 
        {0, 0, 0, 0}
    )

    gameSave = save.new("game")

    local effectDensity = {
        REQUIRED_EFFECTS = 0,
        MIN_EFFECTS = 1,
        MAX_EFFECTS = 2,
    }

    gameSave.save = {
        clientID = stid(),
        user = {
            settings = {
                video = {
                    winsize = 1,
                    fullscreen = false,
                    vsync = 0,
                    fpsCap = 200,
                    filter = "nearest",
                    showFPS = false,
                    msaa = 0,
                    effectDensity = effectDensity.MAX_EFFECTS
                },
                audio = {
                    masterVolume = 75,
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

    local languageManager = require 'src.Modules.System.Utils.LanguageManager'
    languageService = languageManager.getData(gameSave.save.user.settings.misc.language)
    languageRaw = languageManager.getRawData(gameSave.save.user.settings.misc.language)

    -- autoload states --
    local states = love.filesystem.getDirectoryItems("src/States")
    for s = 1, #states, 1 do
        if love.filesystem.getInfo("src/States/" .. states[s]).type == "file" then
            require("src.States." .. states[s]:gsub(".lua", ""))
        end
    end

    -- some shit --
    oldGetPosition = love.mouse.getPosition
    --oldGetWidth, oldGetHeight, oldGetDimensions = love.graphics.getWidth, love.graphics.getHeight, love.graphics.getDimensions
    function love.mouse.getPosition()
        local inside, mx, my = shove.mouseToViewport()
        return mx, my
    end

    -- some discord thing callbacks --
    if gameSave.save.user.settings.misc.discordRichPresence then
        --[[
        function discordRPC.ready(userId, username, discriminator, avatar)
            io.printf(string.format("{bgBlue}{brightBlue}{bold}[Discord]{reset}{brightBlue} : Client connected (%s, %s, %s){reset}\n", userId, username, discriminator))
        end

        function discordRPC.disconnected(errorCode, message)
            io.printf(string.format("{bgBlue}{brightBlue}{bold}[Discord]{reset}{brightBlue} : Client disconnected (%d, %s){reset}\n", errorCode, message))
        end

        function discordRPC.errored(errorCode, message)
            io.printf(string.format("{bgBlue}{brightBlue}{bold}[Discord]{reset}{bgRed}{brightWhite}[Error]{reset}{brightWhite} : (%d, %s){reset}\n", errorCode, message))
        end
        ]]--
    end

    love.filesystem.createDirectory("screenshots")

    gamestate.registerEvents()
    gamestate.switch(LoadingState)
end


function love.quit()
    discordRPC.shutdown()
end