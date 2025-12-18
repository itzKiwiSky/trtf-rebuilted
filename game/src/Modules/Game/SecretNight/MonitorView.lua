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
MonitorView.game = {
    boardStart = { x = 480, y = 120 },
    boardOffset = { x = 60, y = 20 },
    hitbox = { w = 24, h = 24 },
    inverted = false,
    playerPos = { x = -1, y = 1 },
    playerAbs = { x = 0, y = 0 },
    canChangeLane = false,
    maxSize = 0,
    lineNum = 1
}
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

---Generate a matrix with ids 1 to 3
---@param matrixSize number
---@param tileSize number
---@return table<table<number>>
local function generateMatrix(matrixSize, tileSize)
    local m = {}

    for y = 1, matrixSize, 1 do
        for x = 1, matrixSize, 1 do
            table.insert(m, {
                pos = { x = x, y = y },
                lastCellID = 0,
                id = tonumber(lume.weightedchoice({ ["1"] = 70, ["2"] = 30 })),
                hitbox = {
                    x = 0,
                    y = 0,
                    w = 3,
                    h = tileSize,
                }
            })
        end
    end

    return m
end

---Draw a box with lil opacity center and border colored
---@param box Box
---@param r number
---@param g number
---@param b number
local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

---@param matrix table<table<number>>
---@param value number
---@return boolean
local function matrixAllEquals(matrix, value)
    for _, m in ipairs(matrix) do
        if m.id ~= value then
            return false
        end
    end

    return true
end

local function createNames(self)
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
local function moveSelection(self, dir, names)
    local id = self.currentSelectionID

    while true do
        id = id + dir

        if id < 1 or id > #names then
            break
        end

        local name = names[id]
        if not self.animatronics[name].hidden then
            self.currentSelectionID = id
            self.currentSelection = name
            return
        end
    end
end

function MonitorView:init()
    self.font = fontcache.getFont("ocrx", 24)
    local startX, startY = self.game.boardStart.x, self.game.boardStart.y
    local offsetX, offsetY = self.game.boardOffset.x, self.game.boardOffset.y
    table.sort(names)

    self.glow                    = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv                 = love.graphics.newCanvas(shove.getViewportDimensions())
    local matrixSize             = 5
    self.game.maxSize            = matrixSize

    for key, value in spairs(self.animatronics) do
        local matrixSize          = 5
        local tileSize            = 38
        local spacing             = 32

        local width               = (matrixSize * tileSize) + ((matrixSize - 1) * spacing)
        local height              = (matrixSize * tileSize) + ((matrixSize - 1) * spacing)

        local m                   = generateMatrix(matrixSize, tileSize)

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

    createNames(self)

    self.currentSelection = names[self.currentSelectionID]
end

function MonitorView:draw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    local function drawShit()
        love.graphics.setColor(0, 0, 0)
        local startX, startY = self.game.boardStart.x, self.game.boardStart.y
        love.graphics.rectangle("fill", startX, startY - 100, 480, 480)
        love.graphics.setColor(1, 1, 1)
        switch(self.currentState, {
            ["idle"] = function()
                local count = 1
                love.graphics.printf(languageService["secret_night_monitor_title"], self.font, startX, startY, 400, "center")
                for name, anim in spairs(self.namesList) do
                    --print(inspect(anim))
                    local drawName = string.format("[%s] %s", self.animatronics[name].complete and "X" or ".", name)
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
end

function MonitorView:postDraw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    love.graphics.setColor(1, 1, 1, 0.75)
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.glowcnv)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)

    --love.graphics.print(inspect(self.game))
end

function MonitorView:update(elapsed)
    if not SecretNightState.officeState.monitor.displayStatic then return end

    local startX, startY = self.game.boardStart.x, self.game.boardStart.y
    local offsetX, offsetY = self.game.boardOffset.x, self.game.boardOffset.y

    switch(self.currentState, {
        ["minigame"] = function()
            local spacing = animatronicsMatrixes[self.currentSelection].space
            local tileSize = animatronicsMatrixes[self.currentSelection].ts
            local boardW = animatronicsMatrixes[self.currentSelection].w
            local boardH = animatronicsMatrixes[self.currentSelection].h


            local cellPosX = self.game.playerPos.x
            if cellPosX > self.game.maxSize + 1 then
                self.game.inverted = true
            elseif cellPosX <= -1 then
                self.game.inverted = false
            end

            if self.game.inverted then
                self.game.playerPos.x = self.game.playerPos.x - elapsed * 0.25
            else
                self.game.playerPos.x = self.game.playerPos.x + elapsed * 0.25
            end

            self.game.playerAbs.x = (startX + offsetX) + self.game.playerPos.x * (tileSize + spacing * 0.5)
            self.game.playerAbs.y = (startY + offsetY) + (self.game.playerPos.y - 1) * (tileSize + spacing)

            local hbox = {
                x = self.game.playerAbs.x + tileSize / 2,
                y = self.game.playerAbs.y + tileSize / 2,
                w = 1,
                h = 1,
            }

            --self.game.playerPos.y = self.game.lineNum

            --local cellX = self.game.inverted and math.ceil(self.game.playerPos.x) or math.floor(self.game.playerPos.x)
            --local cellX = self.game.playerPos.x + tileSize / 2
            --local cellY = self.game.lineNum

            --[[if cellX > 0 and cellX < self.game.maxSize + 1 then
                if cellX ~= self.lastCellX or cellY ~= self.lastCellY then
                    local cell = animatronicsMatrixes[self.currentSelection].mx[cellY][cellX]

                    if cell == 2 then
                        animatronicsMatrixes[self.currentSelection].mx[cellY][cellX] = 1
                    else
                        animatronicsMatrixes[self.currentSelection].mx[cellY][cellX] = 2
                    end

                    self.lastCellX = cellX
                    self.lastCellY = cellY
                end
            end]]
            self.game.canChangeLane = true
            for _, b in ipairs(animatronicsMatrixes[self.currentSelection].mx) do
                local blockX = (startX + offsetX) + (b.pos.x - 1) * (tileSize + spacing)
                local blockY = (startY + offsetY) + (b.pos.y - 1) * (tileSize + spacing)

                b.hitbox.x = blockX + tileSize / 2
                b.hitbox.y = blockY

                local box = {
                    x = blockX,
                    y = blockY,
                    w = tileSize,
                    h = tileSize,
                }

                if collision.rectRect(hbox, box) then
                    self.game.canChangeLane = false
                end

                if collision.rectRect(hbox, b.hitbox) then
                    if b.id ~= b.lastCellID then
                        b.id = (b.id == 2) and 1 or 2
                    end
                    b.lastCellID = b.id
                end
            end


            if matrixAllEquals(animatronicsMatrixes[self.currentSelection].mx, 2) then
                self.animatronics[self.currentSelection].locked = true
                createNames(self)
                self.currentState = "idle"
            end
        end,
    })
end

function MonitorView:keypressed(k)
    if not SecretNightState.officeState.monitor.displayStatic then return end
    switch(self.currentState, {
        ["idle"] = function()
            switch(k, {
                ["w"] = function()
                    moveSelection(self, -1, names)
                end,
                ["s"] = function()
                    moveSelection(self, 1, names)
                end,
                ["up"] = function()
                    moveSelection(self, -1, names)
                end,

                ["down"] = function()
                    moveSelection(self, 1, names)
                end,
                ["return"] = function()
                    local anim = self.animatronics[self.currentSelection]
                    print(inspect(anim))
                    if not anim.locked then
                        self.currentState = "minigame"
                    end
                end
            })
            --self.currentSelection = names[self.currentSelectionID]
        end,
        ["minigame"] = function()
            if not self.game.canChangeLane then return end
            switch(k, {
                ["w"] = function()
                    if self.game.playerPos.y > 1 then
                        self.game.playerPos.y = self.game.playerPos.y - 1
                    end
                end,
                ["s"] = function()
                    if self.game.playerPos.y < self.game.maxSize then
                        self.game.playerPos.y = self.game.playerPos.y + 1
                    end
                end,
            })
        end,
    })
end

return MonitorView
