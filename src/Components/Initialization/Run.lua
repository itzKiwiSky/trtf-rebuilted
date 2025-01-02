local function copyLib()
    love.filesystem.createDirectory("bin")

    if love.system.getOS() == "Windows" then
        --love.filesystem.write("devi.dll", love.filesystem.read("bin/devi.dll"))
        local dlf = love.filesystem.getDirectoryItems("assets/bin/win")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            --local fileExist = love.filesystem.getInfo(filename)
            love.filesystem.write(filename, love.filesystem.read("assets/bin/win/" .. dlf[d]))
        end
    elseif love.system.getOS() == "OS X" then
        --love.filesystem.write("devi.dylib", love.filesystem.read("bin/devi.dylib"))
        local dlf = love.filesystem.getDirectoryItems("assets/bin/macos")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            --local fileExist = love.filesystem.getInfo(filename)
            love.filesystem.write(filename, love.filesystem.read("assets/bin/macos/" .. dlf[d]))
        end
    elseif love.system.getOS() == "Linux" then
        --love.filesystem.write("devi.so", love.filesystem.read("bin/devi.so"))
        local dlf = love.filesystem.getDirectoryItems("assets/bin/linux")
        for d = 1, #dlf, 1 do
            local filename = "/bin/" .. dlf[d]
            --local fileExist = love.filesystem.getInfo(filename)
            love.filesystem.write(filename, love.filesystem.read("assets/bin/linux/" .. dlf[d]))
        end
    end
end

subtitlesController = require 'src.Components.Modules.Game.Utils.Subtitles'
function love.run()
    DEBUG_APP = not love.filesystem.isFused()
    DEMO_APP = true
    
    local sourcePath = love.filesystem.getSaveDirectory() .. "/bin"
    copyLib()

    subtitlesController.clear()

    _G.GLOBAL_BUFFER = {}

    local newCPath = string.format(
        "%s/?.dll;%s/?.so;%s/?.dylib;%s",
        sourcePath,
        sourcePath,
        sourcePath,
        package.cpath)
    package.cpath = newCPath

    require("src.Components.Initialization.AddonLoad")()
    require("src.Components.Initialization.Imports")()

    love.math.setRandomSeed(os.time())
    math.randomseed(os.time())

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
            subtitlesController:update(elapsed)
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then
                love.draw()
            end

            subtitlesController:draw()

            if gameslot.save.game.user.settings.displayFPS then
                love.graphics.print("FPS : " .. love.timer.getFPS(), 5, 5)
            end
            love.graphics.present()
        end

        collectgarbage("collect")

        if love.timer then love.timer.sleep(0.001) end
    end
end