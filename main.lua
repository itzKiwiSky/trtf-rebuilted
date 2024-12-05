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
                love.graphics.printf(string.format("Preloading Sounds: %s%%", math.floor((f / #files) * 100)), textFont, 0, love.graphics.getHeight() - (textFont:getHeight() + 48), love.graphics.getWidth(), "center")
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
    love.graphics.clear(love.graphics.getBackgroundColor())
end

function love.initialize(args)
    fontcache = require 'src.Components.Modules.System.FontCache'
    LanguageController = require 'src.Components.Modules.System.LanguageManager'
    local connectGJ = require 'src.Components.Modules.API.InitializeGJ'
    fsutil = require 'src.Components.Modules.Utils.FSUtils'

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
                fullscreen = false,
                vsync = false,
                antialiasing = true,
                windowEffects = true,
            },
            progress = {
                initialCutscene = false,
                extras = false,
                night = 0
            }
        }
    }
    gameslot:initialize()

    languageService = LanguageController(gameslot.save.game.user.settings.language)

    registers = {
        user = {
            paused = false,
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

    tmr_gamejoltHeartbeat = timer.new()
    tmr_gamejoltHeartbeat:every(20, function()
        gamejolt.pingSession(true)
        io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client heartbeated a session (%s, %s){reset}\n", gamejolt.username, gamejolt.userToken))
    end)

    gamestate.registerEvents()
    gamestate.switch(LoadingState)
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
        if k == "f9" then
            registers.system.showDebugHitbox = not registers.system.showDebugHitbox
        end
        if k == "f7" then
            registers.system.camEdit = not registers.system.camEdit
        end
        if registers.system.camEdit then
            if editBTN then
                if k == "f4" then
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
