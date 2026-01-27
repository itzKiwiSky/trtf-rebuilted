---@class MonitorView

---@class Box
---@field x number
---@field y number
---@field w number
---@field h number

local utf8 = require 'utf8'
local MonitorView = {}
MonitorView.currentSelection = ""
MonitorView.currentSelectionID = 1
MonitorView.currentState = "idle"
local names = { "freddy", "bonnie", "chica", "foxy", "sugar_and_kitty", "marionette", "frankburt" }

MonitorView.animatronics = {
    ["freddy"] = { name = "freddy", locked = false, hidden = false },
    ["bonnie"] = { name = "bonnie", locked = false, hidden = false },
    ["chica"] = { name = "chica", locked = false, hidden = false },
    ["foxy"] = { name = "foxy", locked = false, hidden = false },
    ["sugar_and_kitty"] = { name = "sugar and kitty", locked = false, hidden = false },
    ["marionette"] = { name = "marionette", locked = false, hidden = false },
    ["frankburt"] = { name = "frankburt", locked = false, hidden = true },
}

MonitorView.screen = {
    x = 484,
    y = 94,
    w = 464,
    h = 464
}

MonitorView.screen.cx = MonitorView.screen.x + MonitorView.screen.w / 2
MonitorView.screen.cy = MonitorView.screen.y + MonitorView.screen.h / 2

MonitorView.namesList = {}

local function checkAllLocked(self)
    for k, anim in spairs(MonitorView.animatronics) do
        if anim.locked ~= true then
            return false
        end
    end

    return true
end

function MonitorView:createNames()
    table.clear(self.namesList)

    local paddingLeft = 8
    local marginDown = 8
    local count = 1
    local startX, startY = 0, 64

    for name, anim in spairs(self.animatronics) do
        if not anim.hidden then
            self.namesList[name] = {
                x = startX + paddingLeft,
                y = startY + (self.font:getHeight() + marginDown) * count,
                selected = false,
                name = anim.name,
            }
            count = count + 1
        end
    end
end

local function updateCrank(self)
    local function normalizeAngleDelta(a)
        if a > math.pi then
            a = a - math.pi * 2
        elseif a < -math.pi then
            a = a + math.pi * 2
        end
        return a
    end

    local inside, mx, my = shove.mouseToViewport()
    mx = mx - self.screen.x
    my = my - self.screen.y

    -- =========================
    -- CENTRO DA MANIVELA
    -- =========================
    local cx = self.game.crank.x
    local cy = self.game.crank.y

    local dx = mx - cx
    local dy = my - cy

    -- =========================
    -- DRAG DA MANIVELA
    -- =========================
    if love.mouse.isDown(1) then
        if not self.game.crank.dragging then
            self.game.crank.dragging = true
            self.game.crank.mouseStartAngle = math.atan2(dy, dx)
            self.game.crank.startAngle = self.game.crank.angle
            self.game.crank.lastAngle = self.game.crank.angle
        else
            local currentMouseAngle = math.atan2(dy, dx)
            self.game.crank.angle =
                self.game.crank.startAngle +
                (currentMouseAngle - self.game.crank.mouseStartAngle)
        end
    else
        self.game.crank.dragging = false
    end

    -- =========================
    -- DELTA DE ROTAÇÃO
    -- =========================
    local deltaAngle = 0

    if self.game.crank.dragging then
        deltaAngle = self.game.crank.angle - self.game.crank.lastAngle
        deltaAngle = normalizeAngleDelta(deltaAngle)
    end

    self.game.crank.lastAngle = self.game.crank.angle

    -- =========================
    -- DRAG → GERA VALOR
    -- =========================
    if self.game.crank.dragging then
        self.game.value = self.game.value +
            (deltaAngle / (math.pi * 2)) * self.game.valuePerTurn
    end

    -- =========================
    -- SOLTO → DECAY + ROTAÇÃO
    -- =========================
    if not self.game.crank.dragging then
        if self.game.value > 0 then
            local decayPerSecond = self.game.valuePerTurn * 0.8
            local decay = decayPerSecond * elapsed

            self.game.value = math.max(0, self.game.value - decay)

            self.game.crank.angle =
                (self.game.value / self.game.valuePerTurn)
                * (math.pi * 2)
        end
    end
end

local function drawCrank(self, cx, cy)
    -- base
    love.graphics.circle("fill", cx, cy, 20)

    -- posição da manivela
    local hx = cx + math.cos(self.game.crank.angle) * self.game.crank.radius
    local hy = cy + math.sin(self.game.crank.angle) * self.game.crank.radius

    -- braço
    love.graphics.setLineWidth(3)
    love.graphics.line(cx, cy, hx, hy)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(0, 1, 0, 0.25)
    love.graphics.circle("line", cx, cy, self.game.crank.radius - 3)
    love.graphics.circle("line", cx, cy, self.game.crank.radius)
    love.graphics.circle("line", cx, cy, self.game.crank.radius + 3)
    love.graphics.setColor(0, 1, 0, 1)

    -- handle
    love.graphics.circle("fill", hx, hy, 14)
end

local function drawButton(self)
    love.graphics.setColor(0, 0.25, 0, 1)
    love.graphics.rectangle("fill", self.game.button.x, self.game.button.y, self.game.button.w, self.game.button.h, self.game.button.radius)
    love.graphics.setColor(0, 1, 0, 1)

    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.game.button.x, self.game.button.y, self.game.button.w, self.game.button.h, self.game.button.radius)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(0.2, 1, 0.2, 1)
    love.graphics.draw(
        SecretNightState.assets.ui["pc_icons"].image,
        SecretNightState.assets.ui["pc_icons"].quads["player"],
        self.game.button.x + self.game.button.w * 0.5,
        self.game.button.y + self.game.button.h * 0.5, 0,
        3, 3, 16, 16
    )
    love.graphics.setColor(0, 1, 0, 1)

    love.graphics.rectangle("line", self.game.button.x + 5, self.game.button.y + 5, self.game.button.w - 10, self.game.button.h - 10, self.game.button.radius)
end

---move the selection and jumps to the next available one
---@param self MonitorView
---@param dir number
---@param names table<string>
local function moveSelection(self, dir)
    --if not names or #names == 0 then return false end

    local id = self.currentSelectionID or 1
    local count = #names
    local tries = 0

    repeat
        id = id + dir

        -- wrap
        if id < 1 then
            id = count
        elseif id > count then
            id = 1
        end

        local name = names[id]
        local anim = self.animatronics[name]

        if anim and not anim.hidden then
            self.currentSelectionID = id
            self.currentSelection = name
            return true
        end

        tries = tries + 1
    until tries >= count

    return false
end

---@param self MonitorView
---@param names table<string>
function MonitorView:validateSelection()
    local id = self.currentSelectionID
    local name = names[id]

    if name and not self.animatronics[name] then
        return
    end

    if name and not self.animatronics[name].hidden then
        return
    end

    self.currentSelectionID = 0
    moveSelection(self, 1)
end

function MonitorView:init()
    self._frankburtHidden = true
    self.gradients        = {
        ["body_integrity"] = love.graphics.newGradient("horizontal", { lume.color("#521612") }, { lume.color("#E61E1E") }),
        ["fuel"] = love.graphics.newGradient("horizontal", { lume.color("#234214") }, { lume.color("#ABD941") }),
        ["load_bar"] = love.graphics.newGradient("vertical", { lume.color('#ED941F') }, { lume.color('#EBAB21') }, { lume.color('#FFDE3B') })
    }


    self.static           = {
        frames = SecretNightState.assets.effects["static"],
        frame = 1,
        speed = 30,
        acc = 0,
    }

    self.font             = fontcache.getFont("ocrx", 24)
    self.fontInt          = fontcache.getFont("ocrx", 18)
    self.fontMinigameText = fontcache.getFont("ocrx", 25)
    local startX, startY  = self.screen.x, self.screen.y
    table.sort(names)

    local safeAreaStartSize = 50
    local offset            = 10
    self.game               = {
        value = 0,
        valuePerTurn = 0.80,
        valueWhenRelease = 5.2,
        button = {
            x = self.screen.w * 0.5 + 40,
            y = self.screen.h * 0.5,
            w = 128,
            h = 128,
            radius = 8,
            addValue = 0.5,
            removeValue = 1.02,
            timerHold = 0,
            maxTimerHold = 0.3,
        },
        crank = {
            x = self.screen.w * 0.5 + 40,
            y = self.screen.h * 0.5,
            radius = 120,
            angle = 0,
            lastAngle = 0,
            dragging = false,
            startAngle = 0,
            mouseStartAngle = 0
        }
    }

    self.game.button.x      = self.screen.w * 0.5 - self.game.button.w * 0.5
    self.game.button.y      = self.screen.h * 0.5 - self.game.button.h * 0.5


    self.glow                    = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.mainCanvas              = love.graphics.newCanvas(self.screen.w, self.screen.h)
    self.glowcnv                 = love.graphics.newCanvas(shove.getViewportDimensions())

    MonitorView:createNames()

    self.currentSelection = names[self.currentSelectionID]
end

function MonitorView:draw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    local function drawStatic()
        local sx = self.screen.w / SecretNightState.assets.effects["static"]["static_1"]:getWidth()
        local sy = self.screen.h / SecretNightState.assets.effects["static"]["static_1"]:getHeight()
        love.graphics.setBlendMode("add")
        love.graphics.setColor(1, 1, 1, 0.30)
        love.graphics.draw(self.static.frames["static_" .. self.static.frame], 0, 0, 0, sx, sy)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")
    end

    local function drawShit()
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, self.screen.w, self.screen.h)
        local lastY = 0
        love.graphics.setColor(1, 1, 1)
        drawStatic()
        switch(self.currentState, {
            ["idle"] = function()
                local count = 1
                love.graphics.printf(languageService["secret_night_monitor_title"], self.font, 0, 30, self.screen.w, "center")
                for name, anim in spairs(self.namesList) do
                    local drawName = string.format("[%s] %s", self.animatronics[name].locked and "X" or ".", anim.name)
                    if self.currentSelection == name then
                        love.graphics.rectangle(
                            "fill", anim.x, anim.y,
                            self.font:getWidth(drawName) + 4, self.font:getHeight() + 4
                        )
                        love.graphics.setColor(0, 0, 0)
                    end

                    love.graphics.print(drawName, self.font, anim.x, anim.y)
                    love.graphics.setColor(1, 1, 1)
                end


                love.graphics.print(languageService["secret_night_monitor_body_integrity"], self.fontInt, 10, self.namesList["sugar_and_kitty"].y + 60)
                love.graphics.draw(self.gradients["body_integrity"],
                    self.screen.w - 132,
                    self.namesList["sugar_and_kitty"].y + 60, 0,
                    math.floor(128 * SecretNightState.officeState.furnace.vincentIntegrity / 100),
                    self.fontInt:getHeight()
                )
                love.graphics.rectangle("line",
                    self.screen.w - 132,
                    self.namesList["sugar_and_kitty"].y + 60, 128, self.fontInt:getHeight()
                )

                love.graphics.print(languageService["secret_night_monitor_boiler_fuel"], self.fontInt, 10, self.namesList["sugar_and_kitty"].y + 90)
                love.graphics.draw(self.gradients["fuel"],
                    self.screen.w - 132,
                    self.namesList["sugar_and_kitty"].y + 90, 0,
                    math.floor(128 * SecretNightState.officeState.furnace.furnaceFuel / 100),
                    self.fontInt:getHeight()
                )
                love.graphics.rectangle("line",
                    self.screen.w - 132,
                    self.namesList["sugar_and_kitty"].y + 90, 128, self.fontInt:getHeight()
                )
            end,
            ["minigame"] = function()
                love.graphics.setColor(0, 1, 0, 1)
                love.graphics.printf(languageService["secret_night_monitor_minigame"], self.fontMinigameText, 0, 32, self.screen.w, "center")

                local cx = self.game.crank.x
                local cy = self.game.crank.y

                --drawCrank(self, cx, cy)

                drawButton(self)

                -- bar --
                local rx, ry, rw, rh = 32, 96, 48, 256
                local valueY = math.floor(rh * (self.game.value / 100))

                love.graphics.setColor(0, 0.45, 0, 1)
                love.graphics.rectangle("fill", rx, (ry + rh) - valueY, rw, valueY)

                love.graphics.setColor(0, 0.75, 0, 1)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", rx + 3, ry, rw - 6, rh)
                love.graphics.setLineWidth(1)

                love.graphics.setColor(0, 1, 0, 1)

                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", rx, ry, rw, rh)
                love.graphics.setLineWidth(1)

                local char = SecretNightState.assets.ui["char_icons"]
                love.graphics.draw(char.image, char.quads[self.currentSelection], 8, self.screen.h - 100, 0, 4.5, 4.5)

                love.graphics.setColor(1, 1, 1, 1)
            end,
        })
    end


    self.mainCanvas:renderTo(drawShit)

    self.glowcnv:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.glow(function()
            love.graphics.draw(self.mainCanvas, self.screen.x, self.screen.y)
        end)
    end)

    love.graphics.draw(self.mainCanvas, self.screen.x, self.screen.y)
end

function MonitorView:postDraw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    love.graphics.setColor(1, 1, 1, 0.75)
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.glowcnv)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
end

function MonitorView:update(elapsed)
    if not SecretNightState.officeState.monitor.displayStatic then return end

    self.static.acc = self.static.acc + elapsed
    if self.static.acc >= (1 / self.static.speed) then
        self.static.frame = self.static.frame + 1
        self.static.acc = 0
        if self.static.frame > self.static.frames.frameCount then
            self.static.frame = 1
        end
    end

    local shouldBeHidden = not (checkAllLocked(self) and SecretNightState.officeState.furnace.vincentIntegrity <= 0)

    if self._frankburtHidden ~= shouldBeHidden then
        self._frankburtHidden = shouldBeHidden
        self.animatronics["frankburt"].hidden = shouldBeHidden

        MonitorView:validateSelection()
    end

    switch(self.currentState, {
        ["minigame"] = function()
            -- updateCrank(self)

            local inside, mx, my = shove.mouseToViewport()
            mx = mx - self.screen.x
            my = my - self.screen.y

            self.game.button.timerHold = self.game.button.timerHold - elapsed
            if love.mouse.isDown(1) then
                if self.game.button.timerHold <= 0 then
                    if collision.pointRect({ x = mx, y = my }, self.game.button) then
                        self.game.value = self.game.value + self.game.button.addValue
                        self.game.button.timerHold = self.game.button.maxTimerHold
                    end
                end
            else
                if self.game.button.timerHold <= 0 then
                    self.game.value = self.game.value - self.game.button.removeValue
                    self.game.button.timerHold = self.game.button.maxTimerHold
                end
            end

            -- =========================
            -- LIMITES
            -- =========================

            if self.game.value >= 100 then
                self.animatronics[self.currentSelection].locked = true
                self:createNames()
                self.currentState = "idle"
            end

            self.game.value = math.clamp(self.game.value, 0, 100)
        end,
    })
end

function MonitorView:keypressed(k)
    if not SecretNightState.officeState.monitor.displayStatic then return end
    switch(self.currentState, {
        ["idle"] = function()
            switch(k, {
                ["w"] = function()
                    moveSelection(self, -1)
                end,
                ["s"] = function()
                    moveSelection(self, 1)
                end,
                ["up"] = function()
                    moveSelection(self, -1)
                end,
                ["down"] = function()
                    moveSelection(self, 1)
                end,
                ["return"] = function()
                    local anim = self.animatronics[self.currentSelection]
                    if not anim.locked and not anim.hidden then
                        self.currentState = "minigame"
                    end
                end
            })
        end,
    })
end

return MonitorView
