local utf8 = require 'utf8'
local MonitorView = {}
MonitorView.activeMatrix = ""

animatronicsMatrixes = {}
MonitorView.animatronics = {
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

---Generate a matrix with ids 1 to 3
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

function MonitorView:init()
    table.sort(animatronics)

    for key, value in pairs(animatronics) do
        local matrixSize = 14
        local m = generateMatrix(matrixSize)
        animatronicsMatrixes[key] = {
            size = matrixSize,
            mx = m
        }
    end
end

function MonitorView:draw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    local x, y = 483, 96
    self.glowcnv:renderTo(function()
        self.glow(function()

        end)
    end)

    love.graphics.draw(self.glowcnv)
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
