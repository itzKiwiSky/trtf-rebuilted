-- ShakeController.lua v0.1

-- Edited for EclipseEngine for TRTF-Rebuilt project
-- 2025 Felicia Schultz (KiwiSky94)

-- Copyright (c) 2015 Ulysse Ramage
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local ShakeController = {
    shaking = 0,
    shakingTarget = 0,

    rotation = 0,
    rotationTarget = 0,

    scale = { x = 1, y = 1 },
    scaleTarget = { x = 1, y = 1 },

    shear = { x = 0, y = 0 },
    shearTarget = { x = 0, y = 0 },

    width = shove.getViewportWidth(),
    height = shove.getViewportHeight()
}
setmetatable(ShakeController, ShakeController)

--[[ Private ]]--

local function lerp(a, b, k) return math.lerp(a, b, k) end

--[[ Public ]]--

function ShakeController:setDimensions(width, height)
    self.width, self.height = width, height
    return self
end

function ShakeController:update(dt)
    local _speed = 7

    self.shaking = lerp(self.shaking, self.shakingTarget, _speed*dt)
    self.rotation = lerp(self.rotation, self.rotationTarget, _speed*dt)

    self.scale.x = lerp(self.scale.x, self.scaleTarget.x, _speed*dt)
    self.scale.y = lerp(self.scale.y, self.scaleTarget.y, _speed*dt)

    self.shear.x = lerp(self.shear.x, self.shearTarget.x, _speed*dt)
    self.shear.y = lerp(self.shear.y, self.shearTarget.y, _speed*dt)

end

function ShakeController:apply()
    love.graphics.translate(self.width*.5, self.height*.5)
    love.graphics.rotate((math.random()-.5)*self.rotation)
    love.graphics.scale(self.scale.x, self.scale.y)
    love.graphics.translate(-self.width*.5, -self.height*.5)

    love.graphics.translate((math.random()-.5)*self.shaking, (math.random()-.5)*self.shaking)

    love.graphics.shear(self.shear.x*.01, self.shear.y*.01)

    return self
end

function ShakeController:prepare()
    love.graphics.push("transform")
    self:apply()
end

function ShakeController:clear()
    love.graphics.pop()
end

--

function ShakeController:setShake(shaking)
    self.shaking = shaking or 0
    return self
end

function ShakeController:setRotation(rotation)
    self.rotation = rotation or 0
    return self
end

function ShakeController:setShear(x, y)
    self.shear = { x = x or 0, y = y or 0 }
    return self
end

function ShakeController:setScale(x, y)
    if not y then
        local _s = x or 1
        self.scale = { x = _s, y = _s }
    else
        self.scale = { x = x or 1, y = y or 1 }
    end
    return self
end

function ShakeController:setShakeTarget(shaking)
    self.shakingTarget = shaking or 0
    return self
end

function ShakeController:setRotationTarget(rotation)
    self.rotationTarget = rotation or 0
    return self
end

function ShakeController:setScaleTarget(x, y)
    if not y then
        local _s = x or 1
        self.scaleTarget = { x = _s, y = _s }
    else
        self.scaleTarget = { x = x or 1, y = y or 1 }
    end
    return self
end

function ShakeController:setShearTarget(x, y)
    self.shearTarget = { x = x or 0, y = y or 0 }
    return self
end

--

function ShakeController:getShake() return self.shaking end
function ShakeController:getShakeTarget() return self.shakingTarget end

function ShakeController:getRotation() return self.rotation end
function ShakeController:getRotationTarget() return self.rotationTarget end

function ShakeController:getScale() return self.scale.x, self.scale.y end
function ShakeController:getScaleTarget() return self.scaleTarget.x, self.scaleTarget.y end

function ShakeController:getShear() return self.shear.x, self.shear.y end
function ShakeController:getShearTarget() return self.shearTarget.x, self.shearTarget.y end

--[[ Aliases ]]--

function ShakeController:shake(...) return self:setShake(...) end
function ShakeController:rotate(...) return self:setRotation(...) end
function ShakeController:zoom(...) return self:setScale(...) end
function ShakeController:tilt(...) return self:setShear(...) end

--[[ End ]]--

return ShakeController