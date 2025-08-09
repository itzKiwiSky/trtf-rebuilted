DebugState = {}

--[[
THIS IS NOT A PLAYABLE State

This state is only there to test things up before implement in a official playable state
like so
]]--

function DebugState:enter()
    registers.devWindowContent = function ()
        Slab.BeginWindow("debugWindow", { Title = "Debug shader"})
            Slab.Text("FOV (fovVar)")
            Slab.SameLine()
            if Slab.InputNumberDrag("fovInput", tostring(tuneConfig.fovVar), -1, 1, 0.01) then
                tuneConfig.fovVar = Slab.GetInputNumber()
            end
            Slab.Text("Latitute (latituteVar)")
            Slab.SameLine()
            if Slab.InputNumberDrag("latituteInput", tostring(tuneConfig.latitudeVar), -200, 200, 0.1) then
                tuneConfig.latitudeVar = Slab.GetInputNumber()
            end
            Slab.Text("Longitude (longitudeVar)")
            Slab.SameLine()
            if Slab.InputNumberDrag("longitudeInput", tostring(tuneConfig.longitudeVar), -200, 200, 0.1) then
                tuneConfig.longitudeVar = Slab.GetInputNumber()
            end

            Slab.Text("Camera X Factor (factorX)")
            Slab.SameLine()
            if Slab.InputNumberDrag("factorXInput", tostring(gameCam.factorX), 0, 20, 0.01) then
                gameCam.factorX = Slab.GetInputNumber()
            end
        Slab.EndWindow()
    end

    roomoff = love.graphics.newImage("assets/images/game/test/room_off.png")
    roomlight = love.graphics.newImage("assets/images/game/test/room_light.png")
    flashlight = love.graphics.newImage("assets/images/game/night8/flashlight.png")
    light = love.graphics.newImage("assets/images/game/night8/lantern_light.png")

    shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    tuneConfig = {
        latitudeVar = 26.6,
        longitudeVar = 40,
        fovVar = 0.263000
    }
    shd_perspective:send("latitudeVar", tuneConfig.latitudeVar)
    shd_perspective:send("longitudeVar", tuneConfig.longitudeVar)
    shd_perspective:send("fovVar", tuneConfig.fovVar)

    -- room --
    roomSize = {
        windowWidth = shove.getViewportWidth(),
        windowHeight = shove.getViewportHeight(),
        width = 2000,
        height = 800,
        compensation = 400,
    }

    flash = {
        x = 0,
        y = 0,
        active = false,
    }

    gameCam = camera.new(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    gameCam.factorX = 2.8
    gameCam.factorY = 25

    X_LEFT_FRAME = gameCam.x
    X_RIGHT_FRAME = gameCam.x + roomSize.width
    Y_TOP_FRAME = gameCam.y
    Y_BOTTOM_FRAME = gameCam.y + roomSize.height

    cnv_mainCanvas = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())
    cnv_invertedRoom = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())
    cnv_flash = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())

    --subtitlesController.clear()
    --subtitlesController.queue(languageRaw.subtitles["call_night" .. NightState.nightID])
    --love.graphics.setBackgroundColor(0.2, 0, 0, 0)
end

function DebugState:draw()

    cnv_mainCanvas:renderTo(function()
        gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        love.graphics.draw(roomlight, 0, 0)
        gameCam:detach()
    end)

    cnv_flash:renderTo(function()
        gameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
            love.graphics.draw(roomoff, 0, 0)
        gameCam:detach()
        if flash.active then
            love.graphics.draw(flashlight, flash.x, flash.y, 0, 1.2, 1.1, flashlight:getWidth() / 2, flashlight:getHeight() / 2)
        end
    end)

    love.graphics.setShader(shd_perspective)
        love.graphics.draw(cnv_mainCanvas, 0, 0)
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(cnv_flash, 0, 0)
        love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
end

function DebugState:update(elapsed)
    local inside, vmx, vmy = shove.mouseToViewport()
    if flash.active then
        flash.x, flash.y = vmx, vmy
    end
    
    shd_perspective:send("latitudeVar", tuneConfig.latitudeVar)
    shd_perspective:send("longitudeVar", tuneConfig.longitudeVar)
    shd_perspective:send("fovVar", tuneConfig.fovVar)

    mx, my = gameCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    gameCam.x = (roomSize.width / 2 + (mx - roomSize.width / 2) / gameCam.factorX)

    -- camera bounds --
    if gameCam.x < X_LEFT_FRAME then
        gameCam.x = X_LEFT_FRAME
    end

    if gameCam.y < Y_TOP_FRAME then
        gameCam.y = Y_TOP_FRAME
    end

    if gameCam.x > X_RIGHT_FRAME then
        gameCam.x = X_RIGHT_FRAME
    end

    if gameCam.y > Y_BOTTOM_FRAME then
        gameCam.y = Y_BOTTOM_FRAME
    end

end

function DebugState:keypressed(k)

end

function DebugState:mousepressed(x, y, button)
    if button == 1 then
        flash.active = not flash.active
    end
end

return DebugState