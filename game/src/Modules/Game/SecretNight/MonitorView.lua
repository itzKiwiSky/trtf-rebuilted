local utf8 = require 'utf8'
local MonitorView = {}

local Commands = {
    ["dir"] = function (self)
        local animatronics = {
            ["freddy"] = { read = false, write = false, hidden = false },
            ["bonnie"] = { read = false, write = false, hidden = false },
            ["chica"] = { name,  read = false, write = false, hidden = false },
            ["foxy"] = { read = false, write = false, hidden = false },
            ["sugar"] = { read = false, write = false, hidden = false },
            ["kitty"] = { read = false, write = false, hidden = false },
            ["marionette"] = { read = false, write = false, hidden = false },
            ["frankburt"] = { read = false, write = false, hidden = true },
        }

        self.terminal:print("Volume in drive\n")
        self.terminal:print("Listing directory\\\n")
        self.terminal:print(string.complete("─", 14) .. "\n")
        for k, value in pairs(animatronics) do
            --self.terminal:print(" [.WR] " .. value .. ".bin\n")

            if not value.hidden then
                local r = value.read and "R" or "-"
                local w = value.write and "W" or "-"
                --print(r, w, k)
                self.terminal:print("[-" .. r .. w .. "] " .. k .. "\n")
            end
        end
    end,
    ["clear"] = function(self)
        self.terminal:clear()
    end,
    ["man"] = function(self)
        self.terminal:print(string.complete("─", 14) .. "\n")
        for _, value in ipairs(languageRaw["secret_night_manual"]) do
            self.terminal:print(value .. "\n")
        end
        self.terminal:print(string.complete("─", 14) .. "\n")
    end
}

function MonitorView:init()
    local font = fontcache.getFont("phbios", 14)
    --print(font)
    self.terminal = termite.new(460, 460 - font:getHeight(), font)
    self.glow = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv = love.graphics.newCanvas(shove.getViewportDimensions())

    self.textBuffer = ""

    -- init texts --
    self.terminal:print("Starting StarlightDOS...\n")

    self.terminal:print("MEMTEST is testing memory... done.\n")
    self.terminal:setCursorY(4)
    self.terminal:print("> ")
end

function MonitorView:draw()
    if not SecretNightState.officeState.monitor.displayStatic then return end

    local x, y = 490, 96
    self.glowcnv:renderTo(function ()
        self.glow(function ()
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
end

function MonitorView:keypressed(k)
    if not SecretNightState.officeState.monitor.displayStatic then return end
    if k == "backspace" then
        local byteoffset = utf8.offset(self.textBuffer, -1)

        if byteoffset then
            self.textBuffer = string.sub(self.textBuffer, 1, byteoffset - 1)
            if self.terminal.cursorX > 3 then
                self.terminal.cursorX = self.terminal.cursorX - 1
                self.terminal:clear(self.terminal.cursorX, self.terminal.cursorY, 1, 1)
            end
        end
    elseif k == "return" then
        -- command parse --
        self.terminal:setCursorY(self.terminal.cursorY + 1)
        local tokens = string.split(self.textBuffer, " ")
        local cmd = tokens[1]
        table.remove(tokens, 1)
        
        if Commands[cmd] ~= nil then
            Commands[cmd](self)
        else
            self.terminal:setCursorX(1)
            self.terminal:print("Command not found!\n")
        end

        self.textBuffer = ""
        self.terminal:setCursorX(1)
        self.terminal:print("> ")
    end
end

function MonitorView:textinput(t)
    if not SecretNightState.officeState.monitor.displayStatic then return end

    if self.terminal.cursorX < self.terminal.width - 3 then
        self.textBuffer = self.textBuffer .. t
        self.terminal:print(t) 
    end
        
    if self.terminal.cursorX > self.terminal.width - 3 then
        self.terminal:setCursorX(3)
    end
end

return MonitorView