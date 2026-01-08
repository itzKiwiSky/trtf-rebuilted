---@class EclipseObject
---@field debug boolean
local EclipseObject = class:extend("EclipseObject")

local function assertByType(value, t)
    assert(type(value) == t, "[EclipseRuntimeError] : Invalid type, expected type \"" .. tostring(t) .. "\" got type \"" .. type(value) .. "\".")
end

local function getTableSize(t)
    local count = 0
    for _, _ in pairs(t) do -- The underscores mean we don't need the key/value data
        count = count + 1
    end
    return count
end

function EclipseObject:__construct(x, y)
    self.debug = false
    self.x = x or 0
    self.y = y or 0
    self.angle = 0
    self.scaleX = 1
    self.scaleY = 1
    self.w = 0
    self.h = 0
    self.originX = 0
    self.originY = 0
    -- metadata --
    self.reverseAnimation = false
    self.animationSpeed = 48
    self.currentActiveAnimation = ""
    self.frame = 1
    self.allowOverlap = false
    self.iTimer = 0
    self.isAnimationRunning = false
    self.loop = false
    self.animations = {}

    self.onAnimationComplete = function() end
end

function EclipseObject:playAnimation(name)
    assertByType(name, "string")
    self.frame = 1
    self.iTimer = 0
    self.currentActiveAnimation = name
    self.isAnimationRunning = true
end

---register a new animation on the object
---@param name any
---@param assets any
function EclipseObject:registerAnimation(name, assets)
    assertByType(name, "string")

    local function registerAnimationKey()
        if self.animations[name] == nil then
            self.animations[name] = {} -- allocate a new array to store animation assets --
        else
            error("[EclipseRuntimeError] : Trying to overwrite a existent animation key!")
        end
    end

    if type(assets) == "nil" then
        registerAnimationKey()
    else
        assertByType(assets, "table")
        registerAnimationKey()
        table.deepmerge(self.animations[name], assets)
        self.animations[name].frameCount = getTableSize(assets)
    end

    -- define the first registered animation as default --
    if self.currentActiveAnimation == "" then
        self.currentActiveAnimation = name
    end
end

---Set a asset data as a frame on a object
---@overload fun(name: string, assets: table<Drawable>)
---@overload fun(name: string, frame: number, asset: Drawable)
---@param name string
---@param frame number
---@param asset love.Drawable
function EclipseObject:setFrameAsset(name, frame, asset)
    local function checkKey(n)
        if type(self.animations[n]) == "nil" then
            error("[EclipseRuntimeError] : Trying to write a non existent key!")
        end
    end

    assertByType(name, "string")

    if type(frame) == "table" then
        self.animations[name].frameCount = getTableSize(frame)
        --self.animations[name] = frame
        table.deepmerge(self.animations[name], frame)
    else
        print("num")
        checkKey(name)
        table.insert(self.animations[name], frame, asset)
    end
end

function EclipseObject:draw()
    local function rdraw(frame)
        love.graphics.draw(
            self.animations[self.currentActiveAnimation][1],
            self.x, self.y, self.angle, self.scaleX, self.scaleY, self.originX, self.originY
        )
    end

    -- only draw if have more than 0 frames --
    if #self.animations[self.currentActiveAnimation] > 0 then
        if self.isAnimationRunning then
            rdraw(self.frame)
        else
            rdraw(1)
        end
    end

    if self.debug then
        love.graphics.print(inspect(self), 4, 4)
    end
end

function EclipseObject:update(elapsed)
    if self.isAnimationRunning then
        self.iTimer = self.iTimer + elapsed
        if self.iTimer >= (1 / self.animationSpeed) then
            if self.reverseAnimation then
                self.frame = self.frame - 1
            else
                self.frame = self.frame + 1
            end
            self.iTimer = 0
        end
        if self.loop then
            if self.reverseAnimation then
                if self.frame < 1 then
                    self.frame = self.animations[self.currentActiveAnimation].frameCount
                end
            else
                if self.frame > self.animations[self.currentActiveAnimation].frameCount then
                    self.frame = 1
                end
            end
        else
            if self.reverseAnimation then
                if self.frame < 1 then
                    self.frame = 1
                    self.animationRunning = false
                    self.visible = false
                    self.onAnimationComplete()
                end
            else
                if self.frame > self.animations[self.currentActiveAnimation].frameCount then
                    self.frame = self.animations[self.currentActiveAnimation].frameCount
                    self.animationRunning = false
                    self.visible = true
                    self.onAnimationComplete()
                end
            end
        end
    end
end

return EclipseObject
