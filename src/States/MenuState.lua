MenuState = {}

local function loadAnimatronic(id)
    local chars = {"bonnie", "chica", "foxy", "freddy", "sugar", "kitty_fazcat", "lockjaw"}
    local anfiles = {}
    local char = chars[id]
    local charFolder = love.filesystem.getDirectoryItems("assets/images/game/menu/animatronics/" .. char)
    for c = 1, #charFolder, 1 do
        table.insert(anfiles, love.graphics.newImage("assets/images/game/menu/animatronics/" .. char .. "/" .. charFolder[c]))
    end
    return anfiles
end

function MenuState:init()
    fnt_textWarn = fontcache.getFont("ocrx", 35)
    fnt_menu = fontcache.getFont("tnr", 40)

    shd_effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    shd_chromafx = love.graphics.newShader("assets/shaders/chromatic.glsl")
    shd_chromafx:send("distortion", 0)
    shd_glowEffect = moonshine(moonshine.effects.glow)

    spr_logo = love.graphics.newImage("assets/images/game/menu/logo.png")

    menuBackgrounds = {}
    local bgs = love.filesystem.getDirectoryItems("assets/images/game/menu/backgrounds")
    for b = 1, #bgs, 1 do
        table.insert(menuBackgrounds, love.graphics.newImage("assets/images/game/menu/backgrounds/" .. bgs[b]))
    end

    animatronicsAnim = {}
end

function MenuState:enter()
    --loadAnimatronic()
    for a = #animatronicsAnim, 1, -1 do
        if animatronicsAnim[a] then
            animatronicsAnim[a]:release()
        end
    end

    if gameslot.save.game.user.progress.night < 1 then
        animatronicsAnim = loadAnimatronic(1)
    else
        animatronicsAnim = loadAnimatronic(gameslot.save.game.user.progress.night)
    end


    AudioSources["menu_theme_again"]:play()
    AudioSources["menu_theme_again"]:setLooping(true)

    bgID = math.random(1, #menuBackgrounds)

    skippedWarn = false

    warnItems = {
        textAlpha = 1,
        vignetteRadius = 0.1,
        vignetteOpactiy = 1,
        y = 128,
        fade = 0.9
    }

    textItems = {
        tween = {
            x = -640,
            y = 360,
            alpha = 0,
            itemsVisible = false,
            target = 32
        },
        elements = {
            {
                text = languageService["menu_button_new_game"],
                hitbox = {},
                locked = false,
                hovered = false,
                offset = 0,
                action = function()
                    
                end,
            },
            {
                text = languageService["menu_button_continue"],
                hitbox = {},
                locked = gameslot.save.game.user.progress.night < 1,
                hovered = false,
                offset = 0,
                action = function()
                    
                end,
            },
            {
                text = languageService["menu_button_extras"],
                hitbox = {},
                locked = not gameslot.save.game.user.progress.extras,
                hovered = false,
                offset = 0,
                action = function()
                    
                end,
            },
            {
                text = languageService["menu_button_extra_shift"],
                hitbox = {},
                locked = gameslot.save.game.user.progress.night < 7,
                hovered = false,
                offset = 0,
                action = function()
                    
                end,
            },
            {
                text = languageService["menu_button_exit"],
                hitbox = {},
                locked = false,
                hovered = false,
                offset = 0,
                action = function()
                    
                end,
            },
        },
    }

    warnFadeInTween = flux.to(warnItems, 3.2, { fade = 0, textAlpha = 0, vignetteOpactiy = 0.6, y = love.graphics.getWidth() + 200, vignetteRadius = 0.8})
    warnFadeInTween:ease("backin")
    warnFadeInTween:oncomplete(function()
        menuItemsTween = flux.to(textItems.tween, 2.3, { alpha = 1, x = 64 })
        menuItemsTween:ease("sineout")
        menuItemsTween:oncomplete(function()
            textItems.tween.itemsVisible = true
        end)
    end)


    menuAnimatronic = {
        x = 0,
        frame = 1,
        randFrameValue = 0,
    }

    logoMenu = {
        x = 208,
        update = false,
    }

    tmr_randFrame = timer.new()
    tmr_randPos = timer.new()

    tmr_randPos:every(0.04, function()
        menuAnimatronic.timer = 0
        menuAnimatronic.x = math.random(0, 6)
        
        if logoMenu.update then
            logoMenu.x = math.random(208, 215)
            shd_chromafx:send("aberration", 7)
        else
            logoMenu.x = 208
            shd_chromafx:send("aberration", 0)
        end
    end)

    tmr_randFrame:every(0.08, function()
        menuAnimatronic.randFrameValue = math.random(10, 20)
        if menuAnimatronic.randFrameValue == 20 then
            menuAnimatronic.frame = 3
        elseif menuAnimatronic.randFrameValue == 19 then
            menuAnimatronic.frame = 2
        elseif menuAnimatronic.randFrameValue == 13 then
            logoMenu.update = not logoMenu.update
        else
            menuAnimatronic.frame = 1
        end
    end)

    -- create button hitboxes --
    for t = 1, #textItems.elements, 1 do
        textItems.elements[t].hitbox = {
            x = 60,
            y = (textItems.tween.y + (fnt_menu:getHeight() + 16) * t) - 4,
            w = fnt_menu:getWidth(textItems.elements[t].text) + 8,
            h = fnt_menu:getHeight() + 8
        }
    end
end

function MenuState:draw()
    shd_effect(function()
        love.graphics.draw(menuBackgrounds[bgID], 0, 0)
        love.graphics.draw(animatronicsAnim[menuAnimatronic.frame], menuAnimatronic.x, 0)
    end)
    love.graphics.setShader(shd_chromafx)
        love.graphics.setBlendMode("add")
            love.graphics.draw(spr_logo, logoMenu.x, 230, 0, 1, 1, spr_logo:getWidth() / 2, spr_logo:getHeight() / 2)
        love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
    love.graphics.setColor(0, 0, 0, warnItems.fade)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    shd_glowEffect(function()
        love.graphics.setShader(shd_chromafx)
            love.graphics.setBlendMode("add")
                love.graphics.setColor(1, 1, 1, warnItems.textAlpha)
                    love.graphics.printf(languageService["warn_text"], fnt_textWarn,0, warnItems.y, love.graphics.getWidth(), "center")
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setBlendMode("alpha")
        love.graphics.setShader()

        for _, t in ipairs(textItems.elements) do
            love.graphics.setColor(1, 1, 1, textItems.tween.alpha)
                if t.locked then
                    love.graphics.setColor(0.3, 0.3, 0.3, textItems.tween.alpha)
                end
                love.graphics.print(t.text, fnt_menu, textItems.tween.x + t.offset, textItems.tween.y + (fnt_menu:getHeight() + 16) * _)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)
end

function MenuState:update(elapsed)
    shd_effect.vignette.radius = warnItems.vignetteRadius

    if skippedWarn then
        flux.update(elapsed)
    end
    -- animatronic menu anim --
    tmr_randFrame:update(elapsed)
    tmr_randPos:update(elapsed)

    -- button check --
    if textItems.tween.itemsVisible then
        for _, t in ipairs(textItems.elements) do
            if collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, t.hitbox) and not t.locked then
                t.hovered = true
                t.offset = math.lerp(t.offset, 32, 0.05)
            else
                t.offset = math.lerp(t.offset, 0, 0.05)
            end

            t.hovered = false
        end
    end
end

function MenuState:mousepressed(x, y, button)
    if not skippedWarn then
        skippedWarn = true
    end

    if button == 1 then
        if textItems.tween.itemsVisible then
            for _, t in ipairs(textItems.elements) do
                if t.hovered then
                    t.action()
                end
            end
        end
    end
end

function MenuState:keypressed(k)
    if not skippedWarn then
        skippedWarn = true
    end
end

return MenuState