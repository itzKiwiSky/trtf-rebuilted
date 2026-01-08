DebugState = {}

--[[
THIS IS NOT A PLAYABLE State

This state is only there to test things up before implement in a official playable statelike so
]] --

function DebugState:enter()
    local fanim = fsutil.scanFolder("assets/images/game/test_blink/anim")
    local anim = {}
    for _, file in ipairs(fanim) do
        table.insert(anim, love.graphics.newImage(file))
    end
    local bro = love.graphics.newImage("assets/images/game/test_blink/bro_shadow.png")
    local front = love.graphics.newImage("assets/images/game/test_blink/front.png")
    local left = love.graphics.newImage("assets/images/game/test_blink/left.png")

    self.office = eclipseObject:new(0, 0)
    self.office.debug = true
    self.office.animationSpeed = 20
    self.office:registerAnimation("idle")
    self.office:setFrameAsset("idle", 1, front)
    self.office:registerAnimation("left")
    self.office:setFrameAsset("left", 1, left)
    self.office:registerAnimation("look_left")
    self.office:setFrameAsset("look_left", anim)
end

function DebugState:draw()
    self.office:draw()
end

function DebugState:update(elapsed)
    self.office:update(elapsed)
end

function DebugState:keypressed(k)
    if k == "left" then
        self.office:playAnimation("look_left")
    elseif k == "right" then
    elseif k == "space" then
    end
end

function DebugState:mousepressed(x, y, button)

end

return DebugState
