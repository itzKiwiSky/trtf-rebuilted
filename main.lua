love.filesystem.load("src/Modules/System/Run.lua")()
--love.filesystem.load("src/Modules/System/ErrorHandler.lua")()


function love.initialize()
    Discord = require 'src.Modules.Game.API.Discord'

    love.resconf = {
        replace = {},
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight(),
        aspectRatio = true,
        centered = true,
        clampMouse = true,
        clip = true,
    }

    resolution.init(love.resconf)

    -- save system --
    gameslot = neuron.new("trtfa2")
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
    }

    -- load states --
    local states = love.filesystem.getDirectoryItems("src/Scenes")
    for s = 1, #states, 1 do
        require("src.Scenes." .. states[s]:gsub(".lua", ""))
    end

    --gamestate.registerEvents()
    gamestate.switch(PlayState)
end

function love.draw()
    gamestate.current():draw()
end

function love.update(elapsed)
    gamestate.current():update(elapsed)
end

function love.keypressed(k)
    if gamestate.current().keypressed then
        gamestate.current():keypressed(k)
    end

    if k == "space" then
        -- Changes are updated dynamically
        love.resconf.aspectRatio = not love.resconf.aspectRatio
    end
end

function love.keyreleased(k)
    if gamestate.current().keyreleased then
        gamestate.current():keyreleased(k)
    end
end

function love.mousereleased(x, y, button)
    if gamestate.current().mousereleased then
        gamestate.current():mousereleased(x, y, button)
    end
end

function love.textinput(t)
    if gamestate.current().textinput then
        gamestate.current():textinput(t)
    end
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