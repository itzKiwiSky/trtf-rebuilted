love.filesystem.load("src/Components/Initialization/Run.lua")()
love.filesystem.load("src/Components/Initialization/ErrorHandler.lua")()

local function preloadAudio()
    local effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    local glowEffect = moonshine(moonshine.effects.glow)
    local textFont = fontcache.getFont("ocrx", 30)
    local preloadBanner = love.graphics.newImage("assets/images/game/banner.png")

    local files = fsutil.scanFolder("assets/sounds")

    for f = 1, #files, 1 do
        local filename = (((files[f]:lower()):gsub(" ", "_")):gsub("%.[^.]+$", "")):match("[^/]+$")
        local mode = gameslot.save.game.user.settings.streamAudio and "stream" or "static"
        love.graphics.clear()
            effect(function()
                love.graphics.draw(preloadBanner, 0, 0, 0, love.graphics.getWidth() / preloadBanner:getWidth() ,love.graphics.getHeight() / preloadBanner:getHeight())
            end)
            glowEffect(function()
                love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 28, math.floor(love.graphics.getWidth() * (((f / #files) * 100) / 100)), 28)
                love.graphics.printf(string.format("Preloading Sounds: %s%%", ((f / #files) * 100)), textFont, 0, love.graphics.getHeight() - (textFont:getHeight() + 48), love.graphics.getWidth(), "center")
            end)
        love.graphics.present()
        AudioSources[filename] = love.audio.newSource(files[f], mode)
        if DEBUG_APP then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : Audio file preloaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", filename))
        end
    end

    -- clear mess --
    textFont:release()
    preloadBanner:release()
    effect = nil
    glowEffect = nil
    files = nil

    collectgarbage("collect")
end

function love.initialize(args)
    fontcache = require 'src.Components.Modules.System.FontCache'
    Presence = require 'src.Components.Modules.API.Presence'
    LanguageController = require 'src.Components.Modules.System.LanguageManager'
    local connectGJ = require 'src.Components.Modules.API.InitializeGJ'
    fsutil = require 'src.Components.Modules.Utils.FSUtils'
    --audioController = require('src.Components.Modules.System.AudioController')
    --audioController:init()
    
    AudioSources = {}

    fontcache.init()

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
                preserveAssets = false,
                preloadSounds = true,
                streamAudio = false,
            },
            progress = {
                initialCutscene = false,
                extras = false,
                night = 0
            }
        }
    }
    gameslot:initialize()

    love.graphics.setDefaultFilter("nearest", "nearest")

    languageService = LanguageController(gameslot.save.game.user.settings.language)

    registers = {
        user = {
            paused = false,
        },
        system = {
            showDebugHitbox = false,
            gameTime = 0,
        }
    }

    -- audio preloading --
    preloadAudio()

    local gitStuff = require 'src.Components.Initialization.GitStuff'
    connectGJ()

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

    gamestate.registerEvents()
    gamestate.switch(MenuState)
end

function love.update(elapsed)
    if gamejolt.isLoggedIn then
        registers.system.gameTime = registers.system.gameTime + elapsed
        if math.floor(registers.system.gameTime) >= 20 then
            gamejolt.pingSession(true)
            registers.system.gameTime = 0
            io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client heartbeated a session (%s, %s){reset}\n", gamejolt.username, gamejolt.userToken))
        end
    end
end

function love.keypressed(k)
    if DEBUG_APP then
        if k == "f11" then
            love.graphics.captureScreenshot("screenshots/screen_" .. os.date("%Y-%m-%d %H-%M-%S") .. ".png")
        end
    end
end

function love.quit()
    if gamejolt.isLoggedIn then
        gamejolt.closeSession()
    end
end
