WinState = {}

local function renderDigit(img, quads, x, y, ...)
    local args = {...}
    local c = 1
    assert(#args <= 7, "[ERROR invalid digit")
    for k, q in ipairs(quads) do
        if args[k] == 1 then
            love.graphics.draw(img, q, x, y)
        end
        c = c + 1
    end
end

function WinState:enter()
    subtitlesController.clear()
    
    self.ps_confetti = require 'trtf.src.Modules.Game.Particles.Confetti'


    self.ps_confetti:stop(0, 0)

    -- play win
    SoundController.getChannel("music"):stop()
    SoundController.getChannel("music"):loadSource("shift_complete")
    SoundController.getChannel("music"):play()

    self.digits = {
        glow = {}
    }
    self.digits.img, self.digits.quads = love.graphics.getQuads("assets/images/game/display")
    self.digits.glow.img, self.digits.glow.quads = love.graphics.getQuads("assets/images/game/display_glow")

    self.curNumbers = {
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
    }

    self.numbers = {
        [0] = { 1, 1, 1, 1, 1, 1, 0 }, -- 0
        [1] = { 0, 1, 1, 0, 0, 0, 0 }, -- 1
        [2] = { 1, 1, 0, 1, 1, 0, 1 }, -- 2
        [3] = { 1, 1, 1, 1, 0, 0, 1 }, -- 3
        [4] = { 0, 1, 1, 0, 0, 1, 1 }, -- 4
        [5] = { 1, 0, 1, 1, 0, 1, 1 }, -- 5
        [6] = { 1, 0, 1, 1, 1, 1, 1 }, -- 6
        [7] = { 1, 1, 1, 0, 0, 0, 0 }, -- 7
        [8] = { 1, 1, 1, 1, 1, 1, 1 }, -- 8
        [9] = { 1, 1, 1, 1, 0, 1, 1 }, -- 9
        ["h"] = { 0, 1, 1, 0, 1, 1, 1 },
        ["e"] = { 1, 0, 0, 1, 1, 1, 1 },
        ["l"] = { 0, 0, 0, 1, 1, 1, 0 },
        ["p"] = { 1, 1, 0, 0, 1, 1, 1 },
    }

    self.flick = false
    self.fadeOp = 0
    self.fadeSC = false
    self.fadeAcc = 0
    self.addHelp = lume.weightedchoice({[true] = 10, [false] = 90})

    self.tmr_scene = timer.new()
    local c = 0
    self.tmr_scene:script(function(sleep)
        sleep(0.2)
        while c <= 7 do
            for _, n in ipairs(self.curNumbers) do
                for i = 1, #n, 1 do
                    n[i] = math.random(0, 1)
                end
            end
            sleep(0.4)
            c = c + 1
        end
        sleep(0.2)
        if self.addHelp then
            self.curNumbers[1] = self.numbers["h"]
            self.curNumbers[2] = self.numbers["e"]
            self.curNumbers[3] = self.numbers["l"]
            self.curNumbers[4] = self.numbers["p"]
        else
            self.curNumbers[1] = self.numbers[0]
            self.curNumbers[2] = self.numbers[6]
            self.curNumbers[3] = self.numbers[0]
            self.curNumbers[4] = self.numbers[0]
        end
        sleep(0.3)
        self.flick = true
        self.ps_confetti:start()
    end)
end

function WinState:draw()
    love.graphics.draw(self.ps_confetti, love.graphics.getWidth() / 2, -16)

    if not SoundController.getChannel("music").source:isPlaying() then
        self.fadeSC = true
    end

    if self.flick then
        if love.timer.getTime() % 0.9 > 0.6 then
            love.graphics.setColor(1, 1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    
    for d = 1, #self.curNumbers, 1 do
        local c = d >= 3 and 64 or 0
        renderDigit(self.digits.img, self.digits.quads, 50 + (172 * d) + c, 100, unpack(self.curNumbers[d]))
        love.graphics.setBlendMode("add")
        renderDigit(self.digits.glow.img, self.digits.glow.quads, 50 + (172 * d) + c, 100, unpack(self.curNumbers[d]))
        love.graphics.setBlendMode("alpha")
    end
    love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 178, 8)
    love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 64, 8)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, self.fadeOp)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function WinState:update(elapsed)
    self.tmr_scene:update(elapsed)

    self.ps_confetti:update(elapsed)

    if self.fadeSC then
        self.fadeAcc = self.fadeAcc + elapsed
        if self.fadeAcc >= 0.07 then
            self.fadeOp = self.fadeOp + 0.56 * elapsed
            if self.fadeOp >= 1 then
                gamestate.switch(MenuState)
            end
        end
    end
end

return WinState