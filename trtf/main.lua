love.filesystem.load("src/Modules/System/Run.lua")()
--love.filesystem.load("src/Modules/System/ErrorHandler.lua")()


function love.initialize()
    subtitlesController = require 'src.Modules.System.Utils.Subtitles'
    Discord = require 'src.Modules.Game.API.Discord'
    SoundController = require 'src.Modules.System.Utils.Sound'
    ViewManager = require 'trtf.src.Modules.System.Utils.ViewManager'

    SoundController.defaultPanning = 0
    SoundController.defaultVolume = 45 * 0.01

    SoundController.newChannel("music")
    SoundController.newChannel("sfx")

    subtitlesController.clear()

    love.resconf = {
        replace = {"mouse"},
        width = 1280,
        height = 800,
        aspectRatio = true,
        centered = true,
        clampMouse = true,
        clip = false,
    }

    -- save system --
    gameslot = neuron.new("trtfa")
    gameslot.save.game = {
        user = {
            settings = {
                video = {
                    resolution = 1,
                    fullscreen = false,
                    vsync = false,
                    aspectRatio = false,
                    fpsCap = 200,
                    antialiasing = true,
                },
                audio = {
                    masterVolume = 75,
                    musicVolume = 50,
                    sfxVolume = 50,
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
                currentNight = 1,
                nightPassed = 0,
                stars = 0,
            }
        }
    }
    gameslot:initialize()

    gameslot.save.game.user.settings.video.displayFPS = true

    love.window.setMode(
        love.resconf.width, love.resconf.height,
        { 
            fullscreen = gameslot.save.game.user.settings.video.fullscreen, 
            vsync = gameslot.save.game.user.settings.video.vsync and 1 or 0,
            
        }
    )

    -- volume control --
    love.audio.setVolume(gameslot.save.game.user.settings.audio.masterVolume * 0.01)
    --love.audio.setVolume(0.001)
    SoundController.getChannel("music"):setVolume(gameslot.save.game.user.settings.audio.musicVolume * 0.01)
    SoundController.getChannel("sfx"):setVolume(gameslot.save.game.user.settings.audio.sfxVolume * 0.01)
    
    --gamepad = love.joystick.getJoysticks()[1]   -- load player  1 if exist

    -- api stuff --
    require('src.Modules.Game.API.Gamejolt')()
    require('src.Modules.Game.API.GitDebug')()
    if gameslot.save.game.user.settings.misc.discordRichPresence then
        Discord.init()
    end

    -- language association --
    languageService = LanguageController:getData(gameslot.save.game.user.settings.misc.language)
    languageRaw = LanguageController:getRawData(gameslot.save.game.user.settings.misc.language)

    registers = {
        -- register some values that may change during gameplay --
        system = {
            fullscreen = false,
            videoStats = false,
        },
        user = {
            currentSettingsTab = "video",
            virtualSettings = gameslot.save.game.user.settings,
            videoSettingsChanged = false,
        }
    }

    -- thread ping to send heartbeats on the gamejolt client to ensure the player is connected --
    th_ping = love.thread.newThread("src/Modules/Game/API/GamejoltPingThread.lua")

    tmr_gamejoltHeartbeat = timer.new()
    tmr_gamejoltHeartbeat:every(20, function()
        th_ping:start(
            gameslot.save.game.user.settings.misc.gamejolt.username, 
            gameslot.save.game.user.settings.misc.gamejolt.usertoken
        )
    end)

    -- load states --
    local states = love.filesystem.getDirectoryItems("src/Scenes")
    for s = 1, #states, 1 do
        require("src.Scenes." .. states[s]:gsub(".lua", ""))
    end

    love.graphics.getWidth = function() return love.resconf.width end
    love.graphics.getHeight = function() return love.resconf.height end
    love.graphics.getDimensions = function() return love.resconf.width, love.resconf.height end
    resolution.init(love.resconf)

    gamestate.registerEvents({
        "update",
        "mousepressed",
        "mousereleased",
        "wheelmoved",
        "keyreleased",
        "keypressed",
        "textinput",
        "gamepadpressed",
        "gamepadreleased",
        "gamepadaxis",
        "joystickadded",
        "joystickremoved",
    })
    gamestate.switch(SystemCheckState)
end

function love.draw()
    resolution.start()
        gamestate.current():draw()
        subtitlesController:draw()
    resolution.stop()
    --love.graphics.print(debug.formattable(registers.user.virtualSettings, 1, true), 5, 20)
end

function love.update(elapsed)
    subtitlesController:update(elapsed)
    if gamejolt.isLoggedIn then
        tmr_gamejoltHeartbeat:update(elapsed)
    end
    loveframes.update(elapsed)
end

function love.keypressed(k, scancode, isrepeat)
    if k == "escape" then
        love.event.quit()
        return
    end

    if FEATURE_FLAGS.debug then
        if k == "f11" then      -- debug fullscreen switch --
            registers.system.fullscreen = not registers.system.fullscreen
            love.window.setFullscreen(registers.system.fullscreen, "desktop")
        end
        if k == "f12" then      -- debug fullscreen switch --
            love.resconf.aspectRatio = not love.resconf.aspectRatio
        end
        if k == "f10" then      -- debug fullscreen switch --
            FEATURE_FLAGS.videoStats = not FEATURE_FLAGS.videoStats
        end
    end
end

function love.quit()
    -- clear the mess --
    for s = #SoundController.sources, 1, -1 do
        SoundController.sources[s]:stop()
        SoundController.sources[s]:release()
    end

    if gamejolt.isLoggedIn then
        gamejolt.closeSession()
    end
    discordrpc.shutdown()
end