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
    ps_confetti = require 'src.Components.Modules.Game.Utils.confettiParticles'
    for k, v in pairs(AudioSources) do
        v:stop()
    end
    winCamera = camera.new()
    winCamera:zoomTo(0.67)

    ps_confetti:stop(0, 0)

    if not AudioSources["shift_complete"]:isPlaying() then
        AudioSources["shift_complete"]:play()
    end

    digits = {
        glow = {}
    }
    digits.img, digits.quads = love.graphics.getQuads("assets/images/game/display")
    digits.glow.img, digits.glow.quads = love.graphics.getQuads("assets/images/game/display_glow")

    curNumbers = {
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
    }

    numbers = {
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

    flick = false
    fadeOp = 0
    fadeSC = false
    fadeAcc = 0
    addHelp = lume.weightedchoice({[true] = 10, [false] = 90})

    tmr_scene = timer.new()
    local c = 0
    tmr_scene:script(function(sleep)
        sleep(0.2)
        while c <= 7 do
            for _, n in ipairs(curNumbers) do
                for i = 1, #n, 1 do
                    n[i] = math.random(0, 1)
                end
            end
            sleep(0.4)
            c = c + 1
        end
        sleep(0.2)
        if addHelp then
            curNumbers[1] = numbers["h"]
            curNumbers[2] = numbers["e"]
            curNumbers[3] = numbers["l"]
            curNumbers[4] = numbers["p"]
        else
            curNumbers[1] = numbers[0]
            curNumbers[2] = numbers[6]
            curNumbers[3] = numbers[0]
            curNumbers[4] = numbers[0]
        end
        sleep(0.3)
        flick = true
        ps_confetti:start()
    end)
end

function WinState:draw()
    love.graphics.draw(ps_confetti, love.graphics.getWidth() / 2, -16)

    if not AudioSources["shift_complete"]:isPlaying() then
        fadeSC = true
    end

    if flick then
        if love.timer.getTime() % 0.9 > 0.6 then
            love.graphics.setColor(1, 1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    winCamera:attach()
        for d = 1, #curNumbers, 1 do
            local c = d >= 3 and 64 or 0
            renderDigit(digits.img, digits.quads, 50 + (172 * d) + c, 100, unpack(curNumbers[d]))
            love.graphics.setBlendMode("add")
            renderDigit(digits.glow.img, digits.glow.quads, 50 + (172 * d) + c, 100, unpack(curNumbers[d]))
            love.graphics.setBlendMode("alpha")
        end
        love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 178, 8)
        love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 64, 8)
    winCamera:detach()
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, fadeOp)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function WinState:update(elapsed)
    tmr_scene:update(elapsed)

    ps_confetti:update(elapsed)

    if fadeSC then
        fadeAcc = fadeAcc + elapsed
        if fadeAcc >= 0.07 then
            fadeOp = fadeOp + 0.56 * elapsed
            if fadeOp >= 1 then
                gamestate.switch(MenuState)
            end
        end
    end
end

return WinState