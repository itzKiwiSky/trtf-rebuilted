local utf8 = require 'utf8'
local MonitorView = {}
MonitorView.sensorMode = false
MonitorView.sensors = {
    directions = { ["up"] = "▲", ["down"] = "▼", ["left"] = "◄", ["right"] = "►" },
    currentDir = "left",
    playerTimer = 0,
    maxPlayerTime = 1,
    cursor = { 0, 0 },
    mode = "clean"
}

local animatronics = {
    ["freddy"] = { read = true, write = true, hidden = false },
    ["bonnie"] = { read = false, write = false, hidden = false },
    ["chica"] = { name, read = false, write = false, hidden = false },
    ["foxy"] = { read = false, write = false, hidden = false },
    ["sugar"] = { read = false, write = false, hidden = false },
    ["kitty"] = { read = false, write = false, hidden = false },
    ["marionette"] = { read = false, write = false, hidden = false },
    ["frankburt"] = { read = false, write = false, hidden = true },
}

local animatronicsMatrixes = {}

---Generate a matrix with ids 1 to 4
---@param matrixSize number
---@return table<table<number>>
local function generateMatrix(matrixSize)
    local m = {}

    for y = 1, matrixSize * 2, 1 do
        m[y] = {}
        for x = 1, matrixSize * 2, 1 do
            m[y][x] = tonumber(lume.weightedchoice({ ["2"] = 70, ["3"] = 20, ["1"] = 10 }))
        end
    end

    return m
end

---Take a matrix as argument and draw to terminal
---@param matrix table
---@param scale number
function drawMatrix(t, matrix)
    local offset = 0

    local colors = { "brightGreen", "brightYellow", "brightRed" }

    local style = { " ", "▓", "▒" }

    --t:frame("line", 1, t.cursorY, space * 2, space * 2)
    local sx, sy = math.floor(t.width / 2 - matrix.size / 2), math.floor(t.height / 2 - matrix.size / 2)
    t:frame("line", sx, sy, matrix.size + 2, matrix.size + 2)

    t:setCursorColor("brightWhite")
    t:setCursorBackColor("black")
    t:clear(sx + 2, sy + 2, matrix.size - 2, matrix.size - 2)
    for y = 1, matrix.size, 1 do
        for x = 1, matrix.size, 1 do
            t:setCursorColor(colors[matrix.mx[y][x]])
            if matrix.mx[y][x] == 1 then
                t:setCursorBackColor(colors[matrix.mx[y][x]])
                t:print((sx + offset) + x, (sy + offset) + y, style[matrix.mx[y][x]])
            else
                t:print((sx + offset) + x, (sy + offset) + y, style[matrix.mx[y][x]])
            end
            t:setCursorColor("brightWhite")
            t:setCursorBackColor("black")
        end
    end
end

local function printInstructions(self)
    self.terminal:setCursorPos(4, 32)
    self.terminal:print(
        string.format(
            languageService["secret_night_monitor_hack_minigame_instructions"],
            self.sensors.directions[self.sensors.currentDir]
        )
    )
end

local function updateInstructions(self, dir)
    local lastPos = { self.terminal.cursorX, self.terminal.cursorY }
    self.sensors.currentDir = dir
    printInstructions(self)
    self.terminal:setCursorPos(lastPos[1], lastPos[2])
end

local Commands = {
    ["dir"] = function(self)
        self.terminal:print("Volume ----01\n")
        self.terminal:print(languageService["secret_night_monitor_list_dir"])
        self.terminal:print(string.complete("─", 14) .. "\n")
        for k, value in pairs(animatronics) do
            if not value.hidden then
                local r = value.read and "R" or "-"
                local w = value.write and "W" or "-"
                self.terminal:print("[-" .. r .. w .. "] " .. k .. "\n")
            end
        end
    end,
    ["clear"] = function(self)
        self.terminal:clear(1, 1)
    end,
    ["man"] = function(self)
        self.terminal:print(string.complete("─", 14) .. "\n")
        for _, value in ipairs(languageRaw["secret_night_manual"]) do
            self.terminal:print(value .. "\n")
        end
        self.terminal:print(string.complete("─", 14) .. "\n")
    end,
    ["fwedit"] = function(self, name)
        if animatronics[name] ~= nil and not animatronics[name].hidden then
            if animatronics[name].write then
                MonitorView.sensorMode = true
                self.terminal.speed = 10000
                self.terminal:setCursorY(3)
                self.terminal:print(string.justify(
                    languageService["secret_night_monitor_hack_minigame_title"],
                    self.terminal.width, " ", "center")
                )

                drawMatrix(self.terminal, animatronicsMatrixes[name])

                --self.terminal:setCursorPos(22, 22)
                printInstructions(self)
            else
                self.terminal:print(languageService["secret_night_monitor_permission_write"])
            end
        else
            self.terminal:print(languageService["secret_night_monitor_invalid_file"])
        end
    end
}

function MonitorView:init()
    table.sort(animatronics)
    local font = fontcache.getFont("phbios", 14)
    --print(font)
    self.terminal = termite.new(470, 470 - font:getHeight(), font)
    self.oldSpeed = self.terminal.speed
    self.glow = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv = love.graphics.newCanvas(shove.getViewportDimensions())

    for key, value in pairs(animatronics) do
        local matrixSize = 14
        local m = generateMatrix(matrixSize)
        animatronicsMatrixes[key] = {
            size = matrixSize,
            mx = m
        }
    end

    self.textBuffer = ""

    -- init texts --
    self.terminal:print("Starting StarlightDOS...\n")

    self.terminal:print("MEMTEST is testing memory... done.\n")
    self.terminal:setCursorY(4)
    self.terminal:print("> ")
end

function MonitorView:draw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    local x, y = 483, 96
    self.glowcnv:renderTo(function()
        self.glow(function()
            self.terminal:draw(x, y)
        end)
    end)

    self.terminal:draw(x, y)
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
    self.terminal:update(elapsed)

    if self.sensorMode then
        self.sensors.playerTimer = self.sensors.playerTimer + elapsed
        if self.sensors.playerTimer >= self.sensors.maxPlayerTime then
            self.sensors.playerTimer = 0
            switch(self.sensors.currentDir, {
                ["up"] = function()

                end,
                ["down"] = function()

                end,
                ["left"] = function()

                end,
                ["right"] = function()

                end,
                ["default"] = function()

                end
            })
            drawMatrix(self.terminal, animatronicsMatrixes[name])
        end
    end
end

function MonitorView:keypressed(k)
    if not SecretNightState.officeState.monitor.displayStatic then return end
    if k == "backspace" then
        if MonitorView.sensorMode then return end

        local byteoffset = utf8.offset(self.textBuffer, -1)

        if byteoffset then
            self.textBuffer = string.sub(self.textBuffer, 1, byteoffset - 1)
            if self.terminal.cursorX > 3 then
                self.terminal.cursorX = self.terminal.cursorX - 1
                self.terminal:clear(self.terminal.cursorX, self.terminal.cursorY, 1, 1)
            end
        end
    elseif k == "return" then
        if MonitorView.sensorMode then return end

        -- command parse --
        self.terminal:clear()
        self.terminal:setCursorPos(1, 1)
        local tokens = string.split(self.textBuffer, " ")

        local cmd = tokens[1]
        table.remove(tokens, 1)
        local args = tokens

        if Commands[cmd] ~= nil then
            Commands[cmd](self, unpack(args))
        else
            self.terminal:setCursorX(1)
            self.terminal:print(languageService["secret_night_monitor_command_invalid"])
        end

        -- clear and reset --
        self.textBuffer = ""
        if not MonitorView.sensorMode then
            self.terminal:setCursorX(1)
            self.terminal:print("> ")
        end
    end

    if not MonitorView.sensorMode then return end

    if k == "w" then
        updateInstructions(self, "up")
    elseif k == "s" then
        updateInstructions(self, "down")
    elseif k == "a" then
        updateInstructions(self, "left")
    elseif k == "d" then
        updateInstructions(self, "right")
    end
end

function MonitorView:textinput(t)
    if not SecretNightState.officeState.monitor.displayStatic then return end

    if MonitorView.sensorMode then return end
    if self.terminal.cursorX < self.terminal.width - 3 then
        self.textBuffer = self.textBuffer .. t
        self.terminal:print(t)
    end

    if self.terminal.cursorX > self.terminal.width - 3 then
        self.terminal:setCursorX(3)
    end
end

return MonitorView
