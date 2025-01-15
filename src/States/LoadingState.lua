LoadingState = {}

local function _checkFiles(tbl, files)
    local filesChecked = 0

end

local function rebuildShaders()
    ctrEffect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    glowTextEffect = moonshine(moonshine.effects.glow)
end

function LoadingState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    subtitlesController.clear()

    local assetThread = require 'src.Components.Modules.Game.Utils.AssetsLoadThread'
    ldBackgrounds = {}
    local bgs = love.filesystem.getDirectoryItems("assets/images/game/menu/backgrounds")
    for b = 1, #bgs, 1 do
        table.insert(ldBackgrounds, love.graphics.newImage("assets/images/game/menu/backgrounds/" .. bgs[b]))
    end
    bgs = nil

    rebuildShaders()

    textLoadingFont = fontcache.getFont("ocrx", 34)

    
    lockjawdance = {
        cfg = {
            acc = 0,
            speed = 35,
            frame = 1
        }
    }
    lockjawdance.image, lockjawdance.quads = love.graphics.getQuads("assets/images/game/loading_lockjaw")

    ready = false
    pressToGO = false
    screen_fade = 0

    _tempAssets = assetThread()

    randBG = math.random(1, #ldBackgrounds)
    if table.compare(NightState.assets, _tempAssets) then
        ready = true
    else
        loveloader.start(function()
            ready = true
        end)

        --[[
        function(k, h, k)
            if DEBUG_APP then
                io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : File loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", k))
            end
        end]]
    end
end

function LoadingState:draw()
    ctrEffect(function()
        love.graphics.draw(ldBackgrounds[randBG], 0, 0, 0, love.graphics.getWidth() / ldBackgrounds[randBG]:getWidth(), love.graphics.getHeight() / ldBackgrounds[randBG]:getHeight())
    end)
    --love.graphics.draw(clockIcon, love.graphics.getWidth() - 69, love.graphics.getHeight() - 69, 0, 64 / clockIcon:getWidth(), 64 / clockIcon:getHeight())
    love.graphics.draw(lockjawdance.image, lockjawdance.quads[lockjawdance.cfg.frame], love.graphics.getWidth() - 135, love.graphics.getHeight() - 135, 0, 128 / 300, 128 / 300)

    glowTextEffect(function()
        love.graphics.clear(0, 0, 0, 0)
        local percent = 0
        if loveloader.resourceCount ~= 0 then percent = loveloader.loadedCount / loveloader.resourceCount end
        love.graphics.printf(string.format(languageService[not ready and "loading_text" or "loading_ready"], (not ready and math.floor(percent * 100) or nil)), textLoadingFont, 0, love.graphics.getHeight() - (textLoadingFont:getHeight() + 16), love.graphics.getWidth(), "center")
    end)

    love.graphics.setColor(0, 0, 0, screen_fade)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

function LoadingState:update(elapsed)
    lockjawdance.cfg.acc = lockjawdance.cfg.acc + elapsed

    if lockjawdance.cfg.acc >= 1 / lockjawdance.cfg.speed then
        lockjawdance.cfg.acc = 0
        lockjawdance.cfg.frame = lockjawdance.cfg.frame + 1
        if lockjawdance.cfg.frame > #lockjawdance.quads then
            lockjawdance.cfg.frame = 1
        end
    end

    if not ready then
        loveloader.update()
    elseif ready and pressToGO then
        screen_fade = screen_fade + 0.4 * elapsed
    end

    if ready and pressToGO and screen_fade > 1 then
        NightState.assets = _tempAssets
        gamestate.switch(NightState)
    end
end

function LoadingState:keypressed(k)
    if ready and not pressToGO then
        pressToGO = true
    end
end

function LoadingState:mousepressed(x, y, button)
    if ready and not pressToGO then
        pressToGO = true
    end
end

return LoadingState