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
local names = { "freddy", "bonnie", "chica", "foxy", "sugar", "kitty", "marionette", "frankburt" }

animatronicsMatrixes = {}
MonitorView.animatronics = {
    ["freddy"] = { locked = false, hidden = false },
    ["bonnie"] = { locked = false, hidden = false },
    ["chica"] = { locked = false, hidden = false },
    ["foxy"] = { locked = false, hidden = false },
    ["sugar"] = { locked = false, hidden = false },
    ["kitty"] = { locked = false, hidden = false },
    ["marionette"] = { locked = false, hidden = false },
    ["frankburt"] = { locked = false, hidden = true },
}

MonitorView.namesList = {}


local animatronicsMatrixes = {}

local function checkAllLocked(self)
    for _, name in ipairs(names) do
        if self.animatronics[name].locked ~= true then
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
    local startX, startY = self.game.boardStart.x, self.game.boardStart.y + 64

    for name, anim in spairs(self.animatronics) do
        if not anim.hidden then
            self.namesList[name] = {
                x = startX + paddingLeft,
                y = startY + (self.font:getHeight() + marginDown) * count,
                selected = false
            }
            count = count + 1
        end
    end
end

---move the selection and jumps to the next available one
---@param self MonitorView
---@param dir number
---@param names table<string>
local function moveSelection(self, dir)
    local id = self.currentSelectionID or 0

    repeat
        id = id + dir

        if id < 1 or id > #names then
            return false
        end

        local name = names[id]
        if name and not self.animatronics[name].hidden then
            self.currentSelectionID = id
            self.currentSelection = name
            return true
        end
    until false
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
    self.gradients = {
        ["body_integrity"] = love.graphics.newGradient("horizontal", { lume.color("#521612") }, { lume.color("#E61E1E") }),
        ["fuel"] = love.graphics.newGradient("horizontal", { lume.color("#234214") }, { lume.color("#ABD941") })
    }

    self.static = {
        frames = SecretNightState.assets.effects["static"],
        frame = 1,
        speed = 30,
        acc = 0,
    }

    self.font = fontcache.getFont("ocrx", 24)
    self.fontInt = fontcache.getFont("ocrx", 18)
    local startX, startY = self.game.boardStart.x, self.game.boardStart.y
    local offsetX, offsetY = self.game.boardOffset.x, self.game.boardOffset.y
    table.sort(names)

    self.screen                  = {
        cx = 715.5,
        cy = 326,
        w  = 463,
        h  = 464
    }

    self.glow                    = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.mainCanvas              = love.graphics.newCanvas()
    self.glowcnv                 = love.graphics.newCanvas(shove.getViewportDimensions())
    local matrixSize             = 4
    self.game.maxSize            = matrixSize
    local tileSize               = 64
    local spacing                = 32
    local totalSize              = (matrixSize * tileSize) + ((matrixSize - 1) * spacing)
    local centerX                = startX + 240
    local centerY                = startY + 240
    self.game.boardOffset.x      = centerX - (totalSize / 2) - startX
    self.game.boardOffset.y      = centerY - (totalSize / 2) - startY

    for key, value in spairs(self.animatronics) do
        local tileSize = tileSize
        local spacing  = spacing

        local width    = (matrixSize * tileSize) + ((matrixSize - 1) * spacing)
        local height   = (matrixSize * tileSize) + ((matrixSize - 1) * spacing)

        --local m        = generateMatrix(matrixSize, tileSize)

        if key == "frankburt" then
            for _, b in ipairs(m) do
                b.lastCellID = 2
                b.id = 1
            end
        end

        animatronicsMatrixes[key] = {
            size = matrixSize,
            mx = m,
            ts = tileSize,
            w = width,
            h = height,
            space = spacing,
            margin = (matrixSize * tileSize) + ((matrixSize + 1) * spacing)
        }
    end

    MonitorView:createNames()

    self.currentSelection = names[self.currentSelectionID]
end

function MonitorView:draw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    local startX, startY = self.game.boardStart.x, self.game.boardStart.y
    local function drawShit()
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", startX, startY - 100, 480, 480)
        local lastY = 0
        love.graphics.setColor(1, 1, 1)
        switch(self.currentState, {
            ["idle"] = function()
                local count = 1
                love.graphics.printf(languageService["secret_night_monitor_title"], self.font, startX, startY, 400, "center")
                for name, anim in spairs(self.namesList) do
                    local drawName = string.format("[%s] %s", self.animatronics[name].locked and "X" or ".", name)
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


                love.graphics.print(languageService["secret_night_monitor_body_integrity"], self.fontInt, startX + 10, self.namesList["sugar"].y + 60)
                love.graphics.draw(self.gradients["body_integrity"],
                    startX + 330,
                    self.namesList["sugar"].y + 60, 0,
                    math.floor(128 * SecretNightState.officeState.furnace.vincentIntegrity / 100),
                    self.fontInt:getHeight()
                )
                love.graphics.rectangle("line",
                    startX + 330,
                    self.namesList["sugar"].y + 60, 128, self.fontInt:getHeight()
                )

                love.graphics.print(languageService["secret_night_monitor_boiler_fuel"], self.fontInt, startX + 10, self.namesList["sugar"].y + 90)
                love.graphics.draw(self.gradients["fuel"],
                    startX + 330,
                    self.namesList["sugar"].y + 90, 0,
                    math.floor(128 * SecretNightState.officeState.furnace.furnaceFuel / 100),
                    self.fontInt:getHeight()
                )
                love.graphics.rectangle("line",
                    startX + 330,
                    self.namesList["sugar"].y + 90, 128, self.fontInt:getHeight()
                )
            end,
            ["minigame"] = function()
                local animatronicsColors = {
                    ["freddy"] = { 94, 41, 32 },
                    ["bonnie"] = { 61, 114, 227 },
                    ["chica"] = { 240, 134, 29 },
                    ["foxy"] = { 230, 58, 39 },
                    ["sugar"] = { 92, 41, 153 },
                    ["kitty"] = { 227, 100, 196 },
                    ["marionette"] = { 201, 189, 189 },
                    ["frankburt"] = { 168, 19, 19 },
                }
                local gray = { 128, 128, 128 }

                local spacing = animatronicsMatrixes[self.currentSelection].space
                local tileSize = animatronicsMatrixes[self.currentSelection].ts
                local boardW = animatronicsMatrixes[self.currentSelection].w
                local boardH = animatronicsMatrixes[self.currentSelection].h
                local margin = animatronicsMatrixes[self.currentSelection].margin
                local offsetX, offsetY = self.game.boardOffset.x, self.game.boardOffset.y

                for _, b in ipairs(animatronicsMatrixes[self.currentSelection].mx) do
                    local cell = b.id

                    local blockX = (startX + offsetX) + (b.pos.x - 1) * (tileSize + spacing)
                    local blockY = (startY + offsetY) + (b.pos.y - 1) * (tileSize + spacing)

                    local box = {
                        x = blockX,
                        y = blockY,
                        w = tileSize,
                        h = tileSize,
                    }

                    if b.id == 2 then
                        drawBox(box,
                            animatronicsColors[self.currentSelection][1] / 255,
                            animatronicsColors[self.currentSelection][2] / 255,
                            animatronicsColors[self.currentSelection][3] / 255
                        )
                    else
                        drawBox(box,
                            gray[1] / 255,
                            gray[2] / 255,
                            gray[3] / 255
                        )
                    end
                end

                local px = (startX + offsetX) + self.game.playerPos.x * (tileSize + spacing * 0.5)
                local py = (startY + offsetY) + (self.game.playerPos.y - 1) * (tileSize + spacing)

                love.graphics.draw(
                    SecretNightState.assets.ui["pc_icons"].image,
                    SecretNightState.assets.ui["pc_icons"].quads["player"],
                    px, py, 0, tileSize / 32, tileSize / 32
                )
            end,
        })
    end

    self.glowcnv:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.glow(function()
            drawShit()
        end)
    end)

    drawShit()

    local sx = 512 / SecretNightState.assets.effects["static"]["static_1"]:getWidth()
    local sy = 512 / SecretNightState.assets.effects["static"]["static_1"]:getHeight()
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(self.static.frames["static_" .. self.static.frame], startX - 30, startY - 50, 0, sx, sy)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
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

    local startX, startY = self.game.boardStart.x, self.game.boardStart.y
    local offsetX, offsetY = self.game.boardOffset.x, self.game.boardOffset.y

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

        end,
    })

    --self.game.invertCooldown = math.max(0, self.game.invertCooldown - elapsed)
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
        ["minigame"] = function()

        end,
    })
end

return MonitorView
