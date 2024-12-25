WinState = {}

local function renderDigit(x, y, ...)
    local args = {...}
    local c = 1
    assert(#args <= 7, "[ERROR invalid digit")
    for k, q in ipairs(digits.quads) do
        if args[k] == 1 then
            love.graphics.draw(digits.img, q, x, y)
        end
        c = c + 1
    end
end

function WinState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    if not AudioSources["shift_complete"]:isPlaying() then
        AudioSources["shift_complete"]:play()
    end

    digits = {}
    digits.img, digits.quads = love.graphics.getQuads("assets/images/game/display")

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
    }

    flick = false
    fadeOp = 0
    fadeSC = false
    fadeAcc = 0

    tmr_scene = timer.new()
    local c = 0
    tmr_scene:script(function(sleep)
        sleep(0.2)
        while c <= 5 do
            for _, n in ipairs(curNumbers) do
                for i = 1, #n, 1 do
                    n[i] = math.random(0, 1)
                end
            end
            sleep(0.4)
            c = c + 1
        end
        sleep(0.2)
        curNumbers[1] = numbers[0]
        curNumbers[2] = numbers[6]
        curNumbers[3] = numbers[0]
        curNumbers[4] = numbers[0]
        sleep(0.4)
        flick = true
        sleep(3)
        fadeSC = true
    end)
end

function WinState:draw()
    if flick then
        if love.timer.getTime() % 0.9 > 0.6 then
            love.graphics.setColor(1, 1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    for d = 1, #curNumbers, 1 do
        local c = d >= 3 and 64 or 0
        renderDigit(50 + (172 * d) + c, 100, unpack(curNumbers[d]))
    end
    love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 178, 8)
    love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 64, 8)
    love.graphics.setColor(1, 1, 1, 1)


    love.graphics.setColor(0, 0, 0, fadeOp)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function WinState:update(elapsed)
    tmr_scene:update(elapsed)

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