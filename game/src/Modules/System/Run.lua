fsutil = require 'src.Modules.System.Utils.FSUtil'
fontcache = require 'src.Modules.System.Utils.FontCache'
shove = require 'src.Modules.System.Shove'
gamestate = require 'src.Modules.System.Utils.GameState'
json = require 'src.Modules.System.Utils.JSON'
class = require 'src.Modules.System.Utils.Classic'
gamejolt = require 'src.Modules.System.Utils.Gamejolt'
baton = require 'src.Modules.System.Utils.Baton'
Slab = require 'src.Modules.System.Slab'
moonshine = require 'src.Modules.System.Moonshine'
loveloader = require 'src.Modules.System.Utils.loveloader'

love._FPSCap = 1000
love._unfocusedFPSCap = 60
local flashOpacity = 0

local oldGraphics = love.graphics
--love.graphics = require 'src.Modules.System.Utils.autobatch'

local modes = love.window.getFullscreenModes()
table.sort(modes, function(a, b) return a.width * a.height > b.width * b.height end) -- Ordena da maior para a menor
love.window.resolutionModes = {}

for i, mode in ipairs(modes) do
    love.window.resolutionModes[i] = {mode.width, mode.height}
end

FazKiwi_LOGBUFFER = {}

local ogprint = print
print = function(...)
    table.insert(_G.FazKiwi_LOGBUFFER, ("[%s] %s"):format(os.date("%Y/%m/%d %H:%M:%S"), table.concat({ tostring(...) }, " ")))
    ogprint(...)
end

local function getKeys()
    local keys = {}
    for k, v in pairs(love.graphics.getStats()) do
        table.insert(keys, k)
    end
    return keys
end

-- copy all the need libraries for game to work --
local function copyLib()
    love.filesystem.createDirectory("bin")
    if type(love.filesystem.getInfo("bin")) ~= nil then return end

    print("[ENGINE] : Libraries copied with sucess")

    if love.system.getOS() == "Windows" then
        local dlf = love.filesystem.getDirectoryItems("assets/bin/win")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            love.filesystem.write(filename, love.filesystem.read("assets/bin/win/" .. dlf[d]))
        end
    elseif love.system.getOS() == "OS X" then
        local dlf = love.filesystem.getDirectoryItems("assets/bin/macos")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            love.filesystem.write(filename, love.filesystem.read("assets/bin/macos/" .. dlf[d]))
        end
    elseif love.system.getOS() == "Linux" then
        local dlf = love.filesystem.getDirectoryItems("assets/bin/linux")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            love.filesystem.write(filename, love.filesystem.read("assets/bin/linux/" .. dlf[d]))
        end
    end
end

function love.run()
    FEATURE_FLAGS = require 'src.Modules.System.FeatureFlags'

    love.keys = {}
    love.keys.videoStats = getKeys()

    local sourcePath = love.filesystem.getSaveDirectory() .. "/bin"
    local newCPath = string.format(
        "%s/?.dll;%s/?.so;%s/?.dylib;%s",
        sourcePath,
        sourcePath,
        sourcePath,
        package.cpath)
        --print(newCPath)
    package.cpath = newCPath
    copyLib()

    discordRPC = require 'src.Modules.System.Utils.DiscordRPC'
    https = require 'https'

    fontcache.init()
    subtitlesController = require 'src.Modules.System.Utils.Subtitles'

    local addons = fsutil.scanFolder("src/Modules/System/Addons")
    for a = 1, #addons, 1 do
        local ad = addons[a]:gsub(".lua", "")
        require(ad:gsub("/", "%."))
    end

    love.graphics.setDefaultFilter("nearest", "nearest")

    local libs = love.filesystem.getDirectoryItems("libraries")
    for l = 1, #libs, 1 do
        if love.filesystem.getInfo("libraries/" .. libs[l]).type == "directory" then
            local libname = libs[l]
            _G[libname:lower()] = require("libraries." .. libname)
        else
            local libname = libs[l]:gsub(".lua", "")
            _G[libname:lower()] = require("libraries." .. libname:gsub(".lua", ""))
        end
    end

    love.math.setRandomSeed(os.time())
    math.randomseed(os.time())

    -- Initialize Shöve with fixed game resolution and options
    shove.setResolution(1280, 800, { fitMethod = "aspect", renderMode = "layer" })
    -- Set up a resizable window
    shove.setWindowMode(1280, 800, {resizable = true, vsync = 0})

    shove.createLayer("mainView")
    shove.createLayer("effects")
    shove.createLayer("DevUI")
    shove.createLayer("fps")

    Slab.Initialize({"NoDocks"})
    Slab.LoadStyle("Pinky")

    local fpsfont = love.graphics.newFont(16)

    if love.initialize then  
        love.initialize(love.arg.parseGameArguments(arg), arg)
    end

    if love.timer then love.timer.step() end

    local elapsed = 0

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                elseif name == "keypressed" then
                    if FEATURE_FLAGS.developerMode then
                        if a == "f12" then
                            FEATURE_FLAGS.videoStats = not FEATURE_FLAGS.videoStats
                        end
                        if a == "f6" then
                            registers.devWindow = not registers.devWindow
                        end
                    end
                    if FEATURE_FLAGS.captureScreenshot then
                        if love.keyboard.isDown("lctrl") and a == "f1" then
                            love.graphics.captureScreenshot("screenshots/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png")
                        end
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        local isFocused = love.window.hasFocus()

        local fpsCap = isFocused and love._FPSCap or love._unfocusedFPSCap
        if love.timer then 
            elapsed = love.timer.step()
        end

        if love.update then 
            love.update(elapsed)
            Controller:update()
            if FEATURE_FLAGS.developerMode then
                Slab.Update(elapsed)
                if registers.devWindow then
                    if registers.devWindowContent then
                        registers.devWindowContent()
                    end
                end
            end
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()

            shove.beginDraw()

                shove.beginLayer("mainView")
                    if love.draw then
                        love.draw()
                    end
                shove.endLayer()

                if FEATURE_FLAGS.developerMode then
                    shove.beginLayer("DevUI")
                        Slab.Draw()
                    shove.endLayer()
                end

                shove.beginLayer("fps")
                    love.graphics.print("FPS : " .. love.timer.getFPS(), fpsfont, 5, 5)
                    if FEATURE_FLAGS.videoStats then
                        local strs = {}
                        for k = 1, #love.keys.videoStats, 1 do
                            local st = love.keys.videoStats[k] .. " = " .. love.graphics.getStats()[love.keys.videoStats[k]]
                            if love.keys.videoStats[k] == "texturememory" then
                                st = love.keys.videoStats[k] .. " = " .. string.format("%.2f mb", love.graphics.getStats()["texturememory"] / 1024 / 1024)
                            end
                            strs[k] = st
                        end
                        love.graphics.print(table.concat(strs, "\n"), fpsfont, 5, 20)
                    end
                shove.endLayer()
            shove.endDraw()
            love.graphics.present()
        end

        collectgarbage("collect")

        if love.timer then love.timer.sleep(1 / fpsCap - elapsed) end
    end
end