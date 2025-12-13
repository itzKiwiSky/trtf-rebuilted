local utf8 = require 'utf8'
local MonitorView = {}
MonitorView.sensorMode = false
MonitorView.activeMatrix = ""
MonitorView.sensors = {
    matrixPos = { x = 0, y = 0 },
    directions = { ["up"] = "▲", ["down"] = "▼", ["left"] = "◄", ["right"] = "►" },
    currentDir = "left",
    playerTimer = 0,
    maxPlayerTime = 1,
    cursor = { x = 0, y = 0 },
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
    self.sensors.matrixPos.x, self.sensors.matrixPos.y = sx, sy
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
    self.terminal:setCursorPos(unpack(lastPos))
end

local function drawPlayer(self, x, y)
    --self.terminal:push()
    local sx, sy = self.sensors.matrixPos.x, self.sensors.matrixPos.y
    local cellState = self.terminal:getCellState(sx + x, sy + y)

    self.terminal:setCursorColor("white")
    self.terminal:setCursorBackColor("brightGreen")
    self.terminal:print(x, y, self.sensors.directions[self.sensors.currentDir])
    self.terminal:setCursorBackColor("black")
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
                self.activeMatrix = name
                self.sensorMode = true
                self.terminal.speed = 10000
                self.terminal:setCursorY(3)
                self.terminal:print(string.justify(
                    languageService["secret_night_monitor_hack_minigame_title"],
                    self.terminal.width, " ", "center")
                )

                drawMatrix(self.terminal, animatronicsMatrixes[name])

                --self.terminal:setCursorPos(22, 22)
                printInstructions(self)

                drawPlayer(self, self.sensorMode.cursor.x, self.sensorMode.cursor.y)
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

end

function MonitorView:keypressed(k)
    if not SecretNightState.officeState.monitor.displayStatic then return end
end

return MonitorView
