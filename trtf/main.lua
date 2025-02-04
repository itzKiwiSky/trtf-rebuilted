love.filesystem.load("src/Modules/System/Run.lua")()
--love.filesystem.load("src/Modules/System/ErrorHandler.lua")()


function love.initialize()
    subtitlesController = require 'src.Modules.System.Utils.Subtitles'
    Discord = require 'src.Modules.Game.API.Discord'
    SoundController = require 'src.Modules.System.Utils.Sound'
    kiwires = require 'src.Modules.System.Utils.Resolution'

    SoundController.defaultPanning = 0
    SoundController.defaultVolume = 45 / 100

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
                displayFPS = true,
                discordRichPresence = true,
                gamepadSupport = false,

            },
            progress = {
                currentNight = 1,
                nightPassed = 0,
                stars = 0,
            }
        }
    }
    gameslot:initialize()

    -- api stuff --
    require('src.Modules.Game.API.Gamejolt')()
    require('src.Modules.Game.API.GitDebug')()
    if gameslot.save.game.user.settings.discordRichPresence then
        Discord.init()
    end

    -- language association --
    languageService = LanguageController:getData(gameslot.save.game.user.settings.language)
    languageRaw = LanguageController:getRawData(gameslot.save.game.user.settings.language)

    registers = {
        -- register some values that may change during gameplay --
        system = {
            fullscreen = false
        }
    }

    -- thread ping to send heartbeats on the gamejolt client to ensure the player is connected --
    th_ping = love.thread.newThread("src/Modules/Game/API/GamejoltPingThread.lua")

    tmr_gamejoltHeartbeat = timer.new()
    tmr_gamejoltHeartbeat:every(20, function()
        th_ping:start(
            gameslot.save.game.user.settings.gamejolt.username, 
            gameslot.save.game.user.settings.gamejolt.usertoken
        )
    end)

    -- load states --
    local states = love.filesystem.getDirectoryItems("src/Scenes")
    for s = 1, #states, 1 do
        require("src.Scenes." .. states[s]:gsub(".lua", ""))
    end

    resolution.init(love.resconf)

    --gamestate.registerEvents()
    gamestate.switch(SystemCheckState)
end

function love.draw()
    resolution.start()
    gamestate.current():draw()
    subtitlesController:draw()
    resolution.stop()
    loveframes.draw()
end

function love.update(elapsed)
    gamestate.current():update(elapsed)
    subtitlesController:update(elapsed)
    if gamejolt.isLoggedIn then
        tmr_gamejoltHeartbeat:update(elapsed)
    end
    loveframes.update(elapsed)
end

function love.keypressed(k, scancode, isrepeat)
    if k == "escape" then
        -- Changes are updated dynamically
        --love.resconf.aspectRatio = not love.resconf.aspectRatio
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
    end

    if gamestate.current().keypressed then
        gamestate.current():keypressed(k)
    end

    loveframes.keypressed(k, scancode, isrepeat)
end

function love.keyreleased(k)
    if gamestate.current().keyreleased then
        gamestate.current():keyreleased(k)
    end

    loveframes.keyreleased(k)
end

function love.mousepressed(x, y, button)
    if gamestate.current().mousepressed then
        --local mx, my = kiwires.toViewportCoords(x, y)
        gamestate.current():mousepressed(x, y, button)
    end
    loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    if gamestate.current().mousereleased then
        --local mx, my = kiwires.toViewportCoords(x, y)
        gamestate.current():mousereleased(x, y, button)
    end
    loveframes.mousereleased(x, y, button)
end

function love.textinput(t)
    if gamestate.current().textinput then
        gamestate.current():textinput(t)
    end
    loveframes.textinput(t)
end
function love.wheelmoved(x, y)
    if gamestate.current().wheelmoved then
        gamestate.current():wheelmoved(x, y)
    end
end

function love.mousemoved(x, y, dx, dy)
    if gamestate.current().mousemoved then
        gamestate.current():mousemoved(x, y, dx, dy)
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