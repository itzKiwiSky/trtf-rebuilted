TabletCameraSubState = {}

function TabletCameraSubState:load()
    buttonCamera = require 'src.Components.Modules.Game.Utils.ButtonCamera'

    fxTV = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.vignette)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)

    fxTV.pixelate.feedback = 0.1
    fxTV.pixelate.size = {1.5, 1.5}
    fxTV.chromasep.radius = 1

    interferenceFX = love.graphics.newShader("assets/shaders/Interference.glsl")
    interferenceFX:send("intensity", 0.012)
    interferenceFX:send("speed", 80.0)

    fxCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    fxGlowCanvas = love.graphics.newCanvas(love.graphics.getDimensions())

    self.camerasID = {
        "almacen",
        "arcade",
        "dining_area",
        "left_hall",
        "parts_and_service",
        "pirate_cove",
        "prize_corner",
        "right_hall",
        "showstage",
        "vent_kitty",
        "vent_sugar",
    }

    local btnqx, btnqy, btnqw, btnqh = NightState.assets.camBtnUI.quads[1]:getViewport()

    self.buttons = {
        {
            btn = buttonCamera(90, 90, btnqw, btnqh),
            target = self.camerasID[1],
        },
        {
            btn = buttonCamera(190, 90, btnqw, btnqh),
            target = self.camerasID[7],
        },
    }

    for bt = 1, #self.buttons, 1 do
        local b = self.buttons[bt]
        b.selected = false
    end

    self.camID = "showstage"
end

function TabletCameraSubState:draw()
    fxCanvas:renderTo(function()
        love.graphics.setShader(interferenceFX)
            love.graphics.draw(NightState.assets.cameras[self.camID][1], 0, 0)
        love.graphics.setShader()
    end)

    fxTV(function()
        love.graphics.draw(fxCanvas, 0, 0)
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.1)
                love.graphics.draw(NightState.assets.staticfx[staticfx.frameid], 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 32, 32, love.graphics.getWidth() - 64, love.graphics.getHeight() - 64)
        love.graphics.setLineWidth(1)
        if love.timer.getTime() % 1 > 0.5 then
            love.graphics.setColor(1, 0, 0, 1)
                love.graphics.circle("fill", 96, 96, 32)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    love.graphics.draw(NightState.assets.camMap, love.graphics.getWidth() - 370, 200, 0, 1.5, 1.5)

    for _, b in ipairs(self.buttons) do
        if b.selected then
            love.graphics.draw(NightState.assets.camBtnUI.image, NightState.assets.camBtnUI.quads[love.timer.getTime() % 1 > 0.5 and 2 or 3], b.btn.x, b.btn.y)
        else
            love.graphics.draw(NightState.assets.camBtnUI.image, NightState.assets.camBtnUI.quads[1], b.btn.x, b.btn.y)
        end
        love.graphics.draw(NightState.assets.camBtnText.image, NightState.assets.camBtnText.quads[_], b.btn.x, b.btn.y)
    end
end

function TabletCameraSubState:update(elapsed)
    interferenceFX:send("time", love.timer.getTime()) -- Enviar tempo para animar

    -- static animation --
    staticfx.timer = staticfx.timer + elapsed
    if staticfx.timer >= staticfx.speed then
        staticfx.timer = 0
        staticfx.frameid = staticfx.frameid + 1
        if staticfx.frameid >= #NightState.assets.staticfx then
            staticfx.frameid = 1
        end
    end
end

function TabletCameraSubState:mousepressed(x, y, button)
    for _, b in ipairs(self.buttons) do
        for _, bt in pairs(self.buttons) do
            bt.selected = false
        end
        if button == 1 then
            if collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, b.btn) then
                b.selected = true
                self.camID = b.target
            end
        end
    end
end

return TabletCameraSubState