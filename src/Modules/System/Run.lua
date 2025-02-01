fsutil = require 'src.Modules.System.Utils.FSUtil'
fontcache = require 'src.Modules.System.Utils.FontCache'
LanguageController = require 'src.Modules.System.Utils.LanguageManager'

-- copy all the need libraries for game to work --
local function copyLib()
    love.filesystem.createDirectory("bin")

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
    FEATURE_FLAGS = {
        debug = not love.filesystem.isFused(),   -- debug stuff will not appear on compiled games --
        demo = false,
    }

    local sourcePath = love.filesystem.getSaveDirectory() .. "/bin"
    copyLib()

    FazKiwi_LOGBUFFER = {}
    local newCPath = string.format(
        "%s/?.dll;%s/?.so;%s/?.dylib;%s",
        sourcePath,
        sourcePath,
        sourcePath,
        package.cpath)
        --print(newCPath)
    package.cpath = newCPath

    fontcache.init()

    local addons = fsutil.scanFolder("src/Modules/System/Addons")
    for a = 1, #addons, 1 do
        local ad = addons[a]:gsub(".lua", "")
        require(ad:gsub("/", "%."))
    end

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
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        if love.timer then 
            elapsed = love.timer.step()
        end

        if love.update then 
            love.update(elapsed)
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()

            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then
                love.draw()
            end


            if gameslot.save.game.user.settings.displayFPS then
                love.graphics.print("FPS : " .. love.timer.getFPS(), fpsfont, 5, 5)
            end

            love.graphics.present()
        end

        collectgarbage("collect")

        if love.timer then love.timer.sleep(0.001) end
    end
end