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
    inverted = false,
    playerPos = { x = 0, y = 1 },
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
---@return table<table<number>>
local function generateMatrix(matrixSize)
    local m = {}

    for y = 1, matrixSize, 1 do
        m[y] = {}
        for x = 1, matrixSize, 1 do
            m[y][x] = tonumber(lume.weightedchoice({ ["1"] = 90, ["2"] = 10 }))
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
    for y = 1, #matrix do
        local row = matrix[y]
        for x = 1, #row do
            if row[x] ~= value then
                return false
            end
        end
    end

    return true
end

local function createNames(self)
    table.clear(self.namesList)

    local paddingLeft = 8
    local marginDown = 8
    local count = 1
    local startX, startY = 480, 96

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

function MonitorView:init()
    self.font = fontcache.getFont("ocrx", 24)
    table.sort(names)

    self.glow                    = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv                 = love.graphics.newCanvas(shove.getViewportDimensions())
    local matrixSize             = 8
    self.game.maxSize            = matrixSize
    for key, value in spairs(self.animatronics) do
        local m                   = generateMatrix(matrixSize)

        local tileSize            = 24
        local spacing             = 16

        local width               = (matrixSize * tileSize) + ((matrixSize - 1) * spacing)
        local height              = (matrixSize * tileSize) + ((matrixSize - 1) * spacing)

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
        local startX, startY = 480, 96
        love.graphics.rectangle("fill", startX, startY, 480, 480)
        love.graphics.setColor(1, 1, 1)
        switch(self.currentState, {
            ["idle"] = function()
                local count = 1
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
                local space = animatronicsMatrixes[self.currentSelection].space
                local tileSize = animatronicsMatrixes[self.currentSelection].ts
                local boardW = animatronicsMatrixes[self.currentSelection].w
                local boardH = animatronicsMatrixes[self.currentSelection].h
                local margin = animatronicsMatrixes[self.currentSelection].margin
                local offsetX, offsetY = 42, 36

                for y = 1, #animatronicsMatrixes[self.currentSelection].mx, 1 do
                    for x = 1, #animatronicsMatrixes[self.currentSelection].mx[y], 1 do
                        local cell = animatronicsMatrixes[self.currentSelection].mx[y][x]
                        local box = {
                            x = (startX + offsetX) + x * (tileSize + space),
                            y = (startY + offsetY) + y * (tileSize + space),
                            w = tileSize,
                            h = tileSize
                        }

                        local colors = {
                            { 128, 128, 128 },
                            { 240, 14,  29 },
                        }

                        drawBox(box, colors[cell][1] / 255, colors[cell][2] / 255, colors[cell][3] / 255)
                    end
                end

                love.graphics.draw(
                    SecretNightState.assets.ui["pc_icons"].image,
                    SecretNightState.assets.ui["pc_icons"].quads["player"],
                    (startX + offsetX) + self.game.playerPos.x * (tileSize + space),
                    (startY + offsetY) + self.game.lineNum * (tileSize + space),
                    0, 24 / 32, 24 / 32
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
end

function MonitorView:update(elapsed)
    if not SecretNightState.officeState.monitor.displayStatic then return end

    switch(self.currentState, {
        ["minigame"] = function()
            if math.floor(self.game.playerPos.x) > self.game.maxSize then
                self.game.inverted = true
            elseif math.floor(self.game.playerPos.x) < 0 then
                self.game.inverted = false
            end

            if self.game.inverted then
                self.game.playerPos.x = self.game.playerPos.x - elapsed
            else
                self.game.playerPos.x = self.game.playerPos.x + elapsed
            end

            self.game.playerPos.y = self.game.lineNum

            local cellX = self.game.inverted and math.ceil(self.game.playerPos.x) or math.floor(self.game.playerPos.x)
            local cellY = self.game.lineNum

            if cellX > 0 and cellX < self.game.maxSize + 1 then
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
            end

            if matrixAllEquals(animatronicsMatrixes[self.currentSelection].mx, 2) then
                self.animatronics[self.currentSelection].read = false
                createNames(self)
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
                    if self.currentSelectionID > 1 then
                        self.currentSelectionID = self.currentSelectionID - 1

                        if self.animatronics[self.currentSelection].hidden then
                            self.currentSelectionID = self.currentSelectionID - 1
                        end
                    end
                end,
                ["s"] = function()
                    if self.currentSelectionID < #names then
                        self.currentSelectionID = self.currentSelectionID + 1

                        if self.animatronics[self.currentSelection].hidden then
                            self.currentSelectionID = self.currentSelectionID + 1
                        end
                    end
                end,
                ["return"] = function()
                    self.currentState = "minigame"
                end
            })
            self.currentSelection = names[self.currentSelectionID]
        end,
        ["minigame"] = function()
            switch(k, {
                ["w"] = function()
                    if self.game.lineNum > 1 then
                        self.game.lineNum = self.game.lineNum - 1
                    end
                end,
                ["s"] = function()
                    if self.game.lineNum < self.game.maxSize then
                        self.game.lineNum = self.game.lineNum + 1
                    end
                end,
            })
        end,
    })
end

return MonitorView
