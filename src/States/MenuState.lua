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

function MenuState:enter()
    fnt_textWarn = fontcache.getFont("ocrx", 35)
    fnt_menu = fontcache.getFont("tnr", 40)
    fnt_settingsTitle = fontcache.getFont("tnr", 55)
    fnt_settingsDesc = fontcache.getFont("tnr", 20)

    shd_effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    shd_blur = moonshine(moonshine.effects.boxblur)
    shd_chromafx = love.graphics.newShader("assets/shaders/chromatic.glsl")
    shd_chromafx:send("distortion", 0)
    shd_glowEffect = moonshine(moonshine.effects.glow)
    shd_glowEffect.glow.strength = 5

    shd_blur.boxblur.radius = {0, 0}

    spr_logo = love.graphics.newImage("assets/images/game/menu/logo.png")

    menuBackgrounds = {}
    local bgs = love.filesystem.getDirectoryItems("assets/images/game/menu/backgrounds")
    for b = 1, #bgs, 1 do
        table.insert(menuBackgrounds, love.graphics.newImage("assets/images/game/menu/backgrounds/" .. bgs[b]))
    end

    animatronicsAnim = {}

    staticfx = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }
    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static")
    for s = 1, #statics, 1 do
        table.insert(staticfx.frames, love.graphics.newImage("assets/images/game/effects/static/" .. statics[s]))
    end
    
    journal = love.graphics.newImage("assets/images/game/menu/news/en.png")

    gameProgress = {
        initialCutscene = false,
        extras = false,
        night = 0
    }

    settingsSubstate = require 'src.SubStates.SettingsSubState'

    settingsSubstate:load()

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

    gearSettings = {
        x = love.graphics.getWidth() + 128,
        y = 120,
        offsetX = 40,
        offsetY = 40,
        hitbox = {},
        hovered = false,
        angle = 0,
        alpha = 0,
        size = 96,
        ico = love.graphics.newImage("assets/images/game/menu/UI/settings_ico.png"),
        glow = love.graphics.newImage("assets/images/game/menu/UI/settings_ico_glow.png")
    }

    gearSettings.hitbox = {
        x = gearSettings.x - gearSettings.offsetX,
        y = gearSettings.y - gearSettings.offsetY,
        w = 78, 
        h = 78 
    }

    AudioSources["amb_rainleak"]:play()
    AudioSources["amb_rainleak"]:setLooping(true)

    bgID = math.random(1, #menuBackgrounds)

    skippedWarn = false

    warnItems = {
        textAlpha = 1,
        vignetteRadius = 0.1,
        vignetteOpactiy = 1,
        y = 128,
        fade = 0.9,
        songVol = 0,
    }

    journalConfig = {
        alpha = 0,
        zoom = 1,
        angle = 0,
        active = false,
        timer = timer.new(),
        transfade = 0,
        volSong = 1
    }

    journalConfig.timer:after(5, function()
        fadeTween = flux.to(journalConfig, 2, { transfade = 1, volSong = 0 })
        fadeTween:ease("linear")
        fadeTween:oncomplete(function()
            AudioSources["menu_theme_again"]:stop()
            gamestate.switch(LoadingState)
        end)
    end)

    textItems = {
        tween = {
            x = -640,
            y = 360,
            alpha = 0,
            itemsVisible = false,
            target = 32,
        },
        elements = {
            {
                text = languageService["menu_button_new_game"],
                hitbox = {},
                locked = false,
                hovered = false,
                offset = 0,
                action = function()
                    journalConfig.active = true
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
                text = languageService["menu_button_exit"],
                hitbox = {},
                locked = false,
                hovered = false,
                offset = 0,
                action = function()
                    love.event.quit()
                end,
            },
        },
    }

    holdDelete = {
        progress = 0,
        active = false,
    }

    warnFadeInTween = flux.to(warnItems, 3.2, { songVol = 1, fade = 0, textAlpha = 0, vignetteOpactiy = 0.6, y = love.graphics.getWidth() + 200, vignetteRadius = 0.8})
    warnFadeInTween:ease("backin")
    warnFadeInTween:oncomplete(function()
        menuItemsTween = flux.to(textItems.tween, 2.3, { alpha = 1, x = 64 })
        menuItemsTween:ease("sineout")
        menuItemsTween:oncomplete(function()
            textItems.tween.itemsVisible = true
        end)

        settingsIconTween = flux.to(gearSettings, 1.5, { x = love.graphics.getWidth() - 128 })
        menuItemsTween:ease("backout")

        AudioSources["menu_theme_again"]:play()
        AudioSources["menu_theme_again"]:setLooping(true)
        AudioSources["amb_rainleak"]:setVolume(0.3)
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
    shd_blur(function()
        -- shader for menu background and animatronic display --
        shd_effect(function()
            love.graphics.draw(menuBackgrounds[bgID], 0, 0)
            love.graphics.draw(animatronicsAnim[menuAnimatronic.frame], menuAnimatronic.x, 0)
        end)
        -- logo effect --
        love.graphics.setShader(shd_chromafx)
            love.graphics.setBlendMode("add")
                love.graphics.draw(spr_logo, logoMenu.x, 230, 0, 1, 1, spr_logo:getWidth() / 2, spr_logo:getHeight() / 2)
            love.graphics.setBlendMode("alpha")
        love.graphics.setShader()

        -- static overlay --
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.draw(staticfx.frames[staticfx.config.frameid], 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        love.graphics.printf(holdDelete.active and languageService["menu_hold_to_delete_progress"] or languageService["menu_hold_to_delete_data"], fnt_settingsDesc, -48, love.graphics.getHeight() - fnt_settingsDesc:getHeight() - 16, love.graphics.getWidth(), "right")

        -- fade rectangle --
        love.graphics.setColor(0, 0, 0, warnItems.fade)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)

        -- text effects --
        shd_glowEffect(function()
            -- warning --
            love.graphics.setBlendMode("add")
                love.graphics.setColor(1, 1, 1, warnItems.textAlpha)
                    love.graphics.printf(languageService["warn_text"], fnt_textWarn,0, warnItems.y, love.graphics.getWidth(), "center")
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setBlendMode("alpha")
            
            -- menu items --
            for _, t in ipairs(textItems.elements) do
                love.graphics.setColor(1, 1, 1, textItems.tween.alpha)
                    if t.locked then
                        love.graphics.setColor(0.3, 0.3, 0.3, textItems.tween.alpha)
                    end
                    love.graphics.print(t.text, fnt_menu, textItems.tween.x + t.offset, textItems.tween.y + (fnt_menu:getHeight() + 16) * _)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end)
    end)

    -- settings icon --
    love.graphics.setColor(1, 1, 1, gearSettings.alpha)
        love.graphics.draw(
            gearSettings.glow, gearSettings.x, gearSettings.y, math.rad(gearSettings.angle), 
            gearSettings.size / gearSettings.glow:getWidth(), gearSettings.size / gearSettings.glow:getHeight(), 
            gearSettings.glow:getWidth() / 2, gearSettings.glow:getHeight() / 2
        )
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(
        gearSettings.ico, gearSettings.x, gearSettings.y, math.rad(gearSettings.angle), 
        gearSettings.size / gearSettings.ico:getWidth(), gearSettings.size / gearSettings.ico:getHeight(), 
        gearSettings.ico:getWidth() / 2, gearSettings.ico:getHeight() / 2
    )

    settingsSubstate:draw()

    -- journal --
    love.graphics.setColor(1, 1, 1, journalConfig.alpha)
        love.graphics.draw(journal, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, math.rad(journalConfig.angle), journalConfig.zoom, journalConfig.zoom, journal:getWidth() / 2, journal:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)

    -- trans fade rectangle --
    love.graphics.setColor(0, 0, 0, journalConfig.transfade)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end

function MenuState:update(elapsed)
    shd_effect.vignette.radius = warnItems.vignetteRadius

    if AudioSources["menu_theme_again"]:isPlaying() then
        AudioSources["menu_theme_again"]:setVolume(warnItems.songVol)
        AudioSources["amb_rainleak"]:setVolume(warnItems.songVol)
        if AudioSources["menu_theme_again"]:getVolume() <= 0 and journalConfig.active then
            AudioSources["menu_theme_again"]:stop()
            AudioSources["amb_rainleak"]:stop()
        end
    end

    -- static animation --
    staticfx.config.timer = staticfx.config.timer + elapsed
    if staticfx.config.timer >= staticfx.config.speed then
        staticfx.config.timer = 0
        staticfx.config.frameid = staticfx.config.frameid + 1
        if staticfx.config.frameid >= #staticfx.frames then
            staticfx.config.frameid = 1
        end
    end

    if skippedWarn then
        flux.update(elapsed)
    end
    -- animatronic menu anim --
    tmr_randFrame:update(elapsed)
    tmr_randPos:update(elapsed)

    settingsSubstate:update(elapsed)

    -- button check --
    if textItems.tween.itemsVisible and not journalConfig.active and not settingsSubstate.active then
        for _, t in ipairs(textItems.elements) do
            t.hovered = collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, t.hitbox) and not t.locked
            if t.hovered then
                t.offset = math.lerp(t.offset, 32, 0.05)
            else
                t.offset = math.lerp(t.offset, 0, 0.05)
            end
        end

        holdDelete.active = love.keyboard.isDown("delete")
        if holdDelete.active then
            holdDelete.progress = holdDelete.progress + elapsed
            if holdDelete.progress >= 2.5 then
                for k, v in pairs(gameProgress) do
                    gameslot.save.game.user.progress[k] = v
                end
                gameslot:saveSlot()

                for k, v in pairs(AudioSources) do
                    v:stop()
                end

                love.event.quit("restart")
            end
        else
            holdDelete.progress = 0
        end
    end

    gearSettings.hovered = collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, gearSettings.hitbox)
    gearSettings.hitbox.x = gearSettings.x - gearSettings.offsetX
    if gearSettings.hovered and textItems.tween.itemsVisible then
        gearSettings.alpha = math.lerp(gearSettings.alpha, 1, 0.05)
        gearSettings.angle = gearSettings.angle + 150 * elapsed

        if gearSettings.angle >= 360 then
            gearSettings.angle = 0
        end
    else
        gearSettings.alpha = math.lerp(gearSettings.alpha, 0, 0.05)
        gearSettings.angle = math.lerp(gearSettings.angle, 0, 0.05)
    end

    if journalConfig.active then
        warnItems.songVol = journalConfig.volSong
        if journalConfig.alpha <= 1 then
            journalConfig.alpha = journalConfig.alpha + 1 * elapsed
        end
        journalConfig.zoom = journalConfig.zoom + 0.02 * elapsed

        journalConfig.timer:update(elapsed)
    end
end

function MenuState:mousepressed(x, y, button)
    if not skippedWarn then
        skippedWarn = true
    end

    settingsSubstate:mousepressed(x, y, button)

    if gearSettings.hovered then
        if button == 1 then
            settingsSubstate.active = not settingsSubstate.active
        end
    end

    if textItems.tween.itemsVisible and not journalConfig.active and not settingsSubstate.active then
        if button == 1 then
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