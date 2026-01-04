require('src.Modules.System.Run')
require('src.Modules.System.Utils.ErrHandler')
local gitstuff = require 'src.Modules.System.GitStuff' -- super important stuff --
local connectGJ = require 'src.Modules.System.InitializeAPI'

languageService = {}
languageRaw = {}

function love.initialize()
    local settingsController = require 'src.Modules.Game.Utils.SettingsController'
    local languageManager = require 'src.Modules.System.Utils.LanguageManager'
    SoundManager = require 'src.Modules.System.Utils.Sound'
    AudioSources = {}
    local save = require 'src.Modules.System.Utils.Save'

    love.setDeprecationOutput(false)

    fnt_subtitle = fontcache.getFont("tnr", 24)
    bg_subtitles = love.graphics.newGradient("horizontal",
        { 0, 0, 0, 0 },
        { 255, 255, 255, 255 },
        { 255, 255, 255, 255 },
        { 255, 255, 255, 255 },
        { 0, 0, 0, 0 }
    )

    local function findDefault()
        for index, value in ipairs(love.window.resolutionModes) do
            if value.width == 1280 and value.height == 800 then
                return index
            end
        end
        return 1
    end

    gameSave = save.new("game")

    gameSave.save = {
        clientID = stid(),
        user = {
            settings = {
                video = {
                    winsize = findDefault(),
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
                    lockCursor = false,
                }
            },
            progress = {
                warningIgnored = false,
                specialCutsceneSee = false,
                initialCutscene = false,
                newgame = false,
                extras = false,
                canContinue = false,
                night = 1,
                playingMinigame = false,
                showNight8 = false,
                night8 = false,
                minigameID = "",
                stars = {
                    beatNight8 = false,
                    beat20 = false,
                    beatNight6 = false,
                }
            }

        }
    }

    gameSave:initialize()
    love.keyboard.setTextInput(true)
    love.keyboard.setKeyRepeat(true)

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
        isStoryMode = false,
        requireMinigame = false,
        hideTexts = false,
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
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}", n))
        end
    end)

    gitstuff() -- still super important --

    settingsController.syncInternal()
    settingsController.applySettings()

    --languageService = languageManager.getData(gameSave.save.user.settings.misc.language)
    --languageRaw = languageManager.getRawData(gameSave.save.user.settings.misc.language)

    -- autoload states --
    local states = love.filesystem.getDirectoryItems("src/States")
    for s = 1, #states, 1 do
        if love.filesystem.getInfo("src/States/" .. states[s]).type == "file" then
            require("src.States." .. states[s]:gsub(".lua", ""))
            local strName = states[s]:gsub(".lua", "")
            table.insert(registers.statesName, strName)
        end
    end

    if gameSave.save.user.settings.misc.lockCursor then
        love.mouse.setRelativeMode(true)
        fakeCursor.x = love.graphics.getWidth() / 2
        fakeCursor.y = love.graphics.getHeight() / 2
    end

    love.filesystem.createDirectory("screenshots")

    gamestate.registerEvents()
    gamestate.switch(WarningState)
end

function love.quit()
    if gamejolt.isLoggedIn then
        gamejolt.closeSession()
    end
end
