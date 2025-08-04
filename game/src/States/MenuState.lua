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

local function loadRandomBackground()
    local bgs = love.filesystem.getDirectoryItems("assets/images/game/menu/backgrounds")
    return love.graphics.newImage("assets/images/game/menu/backgrounds/" .. bgs[math.random(1, #bgs)])
end

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function MenuState:enter()
    self.settingsSubState = require 'src.States.Substates.SettingsSubstate'

    -- variables --
    self.controllerSelection = 0
    self.canUseMenu = false
    self.configMenu = false

    -- shader configuration --
    self.shd_chromafx = love.graphics.newShader("assets/shaders/Chromatic.glsl")
    self.shd_chromafx:send("distortion", 0)

    self.shd_crt = love.graphics.newShader("assets/shaders/CRT.glsl")

    --self.shd_vignette = love.graphics.newShader("assets/shaders/Vignette.glsl")
    --self.shd_vignette:send("resolution", { shove.getViewportWidth(), shove.getViewportHeight() })
    --self.shd_vignette:send("radius", 0.95)
    --self.shd_vignette:send("softness", 0.7)
    --self.shd_vignette:send("opacity", 0.13)

    self.shd_effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    self.shd_blur = moonshine(moonshine.effects.boxblur)
    self.shd_glowEffect = moonshine(moonshine.effects.glow)
    self.shd_glowEffect.glow.strength = 5

    self.shd_blur.boxblur.radius = {0, 0}

    self.shd_glowEffectText = moonshine(moonshine.effects.glow)
    self.shd_glowEffectText.glow.strength = 5

    -- table config --
    self.mainViewCanvas = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight())

    self.staticAnimationFX = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }
    
    self.logoMenu = {
        x = 200,
        y = 200,
        update = false,
        text = "the\nreturn\nto\nfreddy's\nagain",
        scale = 0.75
    }
    
    self.menuAnimatronic = {
        x = 0,
        frame = 1,
        randFrameValue = 0,
    }

    self.journalScreen = {
        alpha = 0,
        acc = 0,
        size = 1,
    }

    -- timers --

    self.tmr_randFrame = timer.new()
    self.tmr_randPos = timer.new()
    
    self.tmr_randPos:every(0.04, function()
        self.menuAnimatronic.timer = 0
        self.menuAnimatronic.x = math.random(0, 6)
        
        if self.logoMenu.update then
            self.logoMenu.x = math.random(208, 215)
            self.shd_chromafx:send("aberration", 7)
        else
            self.logoMenu.x = 208
            self.shd_chromafx:send("aberration", 0)
        end
    end)

    
    self.tmr_randFrame:every(0.08, function()
        self.menuAnimatronic.randFrameValue = math.random(10, 20)
        if self.menuAnimatronic.randFrameValue == 20 then
            self.menuAnimatronic.frame = 3
        elseif self.menuAnimatronic.randFrameValue == 19 then
            self.menuAnimatronic.frame = 2
        elseif self.menuAnimatronic.randFrameValue == 13 then
            self.logoMenu.update = not self.logoMenu.update
        else
            self.menuAnimatronic.frame = 1
        end
    end)

    -- sprites --
    self.fnt_mainLogo = fontcache.getFont("tnr", 310)
    self.fnt_textWarn = fontcache.getFont("ocrx", 35)
    self.fnt_menu = fontcache.getFont("tnr", 35)

    self.menuBackground = loadRandomBackground()

    self.crtframe = love.graphics.newImage("assets/images/game/effects/perfect_crt.png")

    self.settingsGear = {
        x = shove.getViewportWidth() + 128,
        y = 120,
        offsetX = 40,
        offsetY = 40,
        hitbox = {},
        hovered = false,
        angle = 0,
        alpha = 0,
        size = 128,
        ico = love.graphics.newImage("assets/images/game/menu/UI/settings_ico.png"),
        glow = love.graphics.newImage("assets/images/game/menu/UI/settings_ico_glow.png")
    }

    self.settingsGear.hitbox = newButtonHitbox(
        self.settingsGear.x - self.settingsGear.offsetX, 
        self.settingsGear.y - self.settingsGear.offsetY, 78, 78
    )

    self.spr_logo = love.graphics.newImage("assets/images/game/menu/logo.png")
    self.logoMenu.sprWidth = math.floor(self.logoMenu.scale * self.spr_logo:getWidth())
    self.logoMenu.sprHeight = math.floor(self.logoMenu.scale * self.spr_logo:getHeight())

    self.newGameJournal = gameSave.save.user.settings.misc.language == "English" and love.graphics.newImage("assets/images/game/menu/news/en.png") or love.graphics.newImage("assets/images/game/menu/news/es.png")

    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static")
    for s = 1, #statics, 1 do
        table.insert(self.staticAnimationFX.frames, love.graphics.newImage("assets/images/game/effects/static/" .. statics[s]))
    end

    self.animatronicsAnim = {}

    for a = #self.animatronicsAnim, 1, -1 do
        if self.animatronicsAnim[a] then
            self.animatronicsAnim[a]:release()
        end
    end

    if gameSave.save.user.progress.night < 1 then
        self.animatronicsAnim = loadAnimatronic(1) -- I think is bonnie --
    else
        self.animatronicsAnim = loadAnimatronic(gameSave.save.user.progress.night)
    end

    -- buttons menu --
    self.mainMenuButtons = {
        config = {
            startY = 370,
            paddingElements = 69,       -- :smirk: --
            targetX = 64,
            startX = -480,
            x = -480,
            offsetX = 24
        },
        elements = {
            {
                text = languageService["menu_button_new_game"],
                locked = false,
                action = function()
                    gameSave.save.user.progress.newgame = true
                    gameSave.save.user.progress.night = 1
                    self.canUseMenu = false
                    self.journalConfig.active = true
                end,
            },
            {
                text = languageService["menu_button_continue"],
                locked = gameSave.save.user.progress.night <= 1,
                action = function()
                    
                end,
            },
            {
                text = languageService["menu_button_extras"],
                locked = gameSave.save.user.progress.extras,
                action = function()
                    
                end,
            },
            {
                text = languageService["menu_button_custom_night"],
                locked = false,
                action = function()
                    gamestate.switch(CustomNightState)
                end,
            },
            {
                text = languageService["menu_button_exit"],
                locked = false,
                action = function()
                    love.event.quit()
                end,
            },
        },
    }

    self.journalConfig = {
        alpha = 0,
        zoom = 1,
        angle = 0,
        active = false,
        timer = timer.new(),
        transfade = 0,
        volSong = 1
    }

    self.transitionFade = {
        active = false,
        target = nil,
        fade = 0,
        acc = 0,
        maxTime = 0.12,
    }

    self.journalConfig.timer:after(3.75, function()
        self.fadeTween = flux.to(self.journalConfig, 2, { transfade = 1, volSong = 0 })
        self.fadeTween:ease("linear")
        self.fadeTween:oncomplete(function()
            AudioSources["menu_theme_again"]:stop()
            gamestate.switch(LoadingState)
        end)
    end)


    -- hitboxers

    for _, e in ipairs(self.mainMenuButtons.elements) do
        e.meta = {}
        e.meta.offsetX = 0
        e.hitbox = newButtonHitbox(self.mainMenuButtons.config.targetX, self.mainMenuButtons.config.startY, self.fnt_menu:getWidth(e.text) + 8, self.fnt_menu:getHeight() + 8)
        self.mainMenuButtons.config.startY = self.mainMenuButtons.config.startY + self.mainMenuButtons.config.paddingElements
    end

    -- tweens --
    self.menuText = flux.to(self.mainMenuButtons.config, 2.3, { x = self.mainMenuButtons.config.targetX })
    self.menuText:ease("sineout")
    self.menuText:oncomplete(function()
        --textItems.tween.itemsVisible = true
        self.canUseMenu = true
    end)

    self.settingsIconTween = flux.to(self.settingsGear, 1.5, { x = shove.getViewportWidth() - 128 })

    AudioSources["amb_rainleak"]:play()
    AudioSources["amb_rainleak"]:setLooping(true)
    AudioSources["amb_rainleak"]:setVolume(0.3)
    
    AudioSources["menu_theme_again"]:play()
    AudioSources["menu_theme_again"]:setLooping(true)

    -- sounds sfx --
    --SoundController.getChannel("music"):loadSource("menu_theme_again")
    --SoundController.getChannel("music"):play()
    --SoundController.getChannel("music"):setLooping(true)

    self.settingsSubState:load()
end

function MenuState:draw()

    self.shd_blur(function ()
        self.shd_effect(function ()
            love.graphics.draw(self.menuBackground, 0, 0, 0, shove.getViewportWidth() / self.menuBackground:getWidth(), shove.getViewportHeight() / self.menuBackground:getHeight())
            love.graphics.draw(self.animatronicsAnim[self.menuAnimatronic.frame], self.menuAnimatronic.x, 0)
        end)
    end)


    love.graphics.setShader(self.shd_chromafx)
        love.graphics.setBlendMode("add")
            love.graphics.draw(self.spr_logo, self.logoMenu.x, self.logoMenu.y, 0, self.logoMenu.scale, self.logoMenu.scale, self.spr_logo:getWidth() / 2, self.spr_logo:getHeight() / 2)
        love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
    --love.graphics.setBlendMode("alpha")

    love.graphics.setColor(1, 1, 1, self.settingsGear.alpha)
    love.graphics.draw(
        self.settingsGear.glow, self.settingsGear.x, self.settingsGear.y, math.rad(self.settingsGear.angle), 
        self.settingsGear.size / self.settingsGear.glow:getWidth(), self.settingsGear.size / self.settingsGear.glow:getHeight(), 
        self.settingsGear.glow:getWidth() / 2, self.settingsGear.glow:getHeight() / 2
    )
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(
        self.settingsGear.ico, self.settingsGear.x, self.settingsGear.y, math.rad(self.settingsGear.angle), 
        self.settingsGear.size / self.settingsGear.ico:getWidth(), self.settingsGear.size / self.settingsGear.ico:getHeight(), 
        self.settingsGear.ico:getWidth() / 2, self.settingsGear.ico:getHeight() / 2
    )

    -- static overlay --
    love.graphics.setBlendMode("add")
        love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.draw(self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid], 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")

    for _, e in ipairs(self.mainMenuButtons.elements) do
        if e.locked then
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.print(e.text, self.fnt_menu, self.mainMenuButtons.config.x + e.meta.offsetX, e.hitbox.y)
        love.graphics.setColor(1, 1, 1, 1)
        --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
    end

    if self.configMenu then
        self.settingsSubState:draw()
    end

    -- journal --
    love.graphics.setColor(1, 1, 1, self.journalConfig.alpha)
        love.graphics.draw(self.newGameJournal, shove.getViewportWidth() / 2, shove.getViewportHeight() / 2, math.rad(self.journalConfig.angle), self.journalConfig.zoom, self.journalConfig.zoom, self.newGameJournal:getWidth() / 2, self.newGameJournal:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)

    -- trans fade rectangle --
    love.graphics.setColor(0, 0, 0, self.transitionFade.fade)
        love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    --love.graphics.setColor(0, 0, 0, self.journalScreen.alpha)
    --love.graphics.rectangle("fill", 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
    --love.graphics.setColor(1, 1, 1, 1)

    --love.graphics.print(("%s, %s"):format(love.mouse.getPosition()), 20, 20)
end

function MenuState:update(elapsed)
    local mx, my = love.mouse.getPosition()
    -- static animation --
    self.staticAnimationFX.config.timer = self.staticAnimationFX.config.timer + elapsed
    if self.staticAnimationFX.config.timer >= self.staticAnimationFX.config.speed then
        self.staticAnimationFX.config.timer = 0
        self.staticAnimationFX.config.frameid = self.staticAnimationFX.config.frameid + 1
        if self.staticAnimationFX.config.frameid >= #self.staticAnimationFX.frames then
            self.staticAnimationFX.config.frameid = 1
        end
    end

    self.tmr_randFrame:update(elapsed)
    self.tmr_randPos:update(elapsed)

    if self.configMenu then
        self.settingsSubState:update(elapsed)
    end

    if not self.canUseMenu then
        flux.update(elapsed)
    end

    -- gear effect hover --
    self.settingsGear.hovered = collision.pointRect({ x = mx, y = my }, self.settingsGear.hitbox)
    self.settingsGear.hitbox.x = self.settingsGear.x - self.settingsGear.offsetX
    if self.settingsGear.hovered and self.canUseMenu then
        self.settingsGear.alpha = math.lerp(self.settingsGear.alpha, 1, 0.05)
        self.settingsGear.angle = self.settingsGear.angle + 150 * elapsed

        if self.settingsGear.angle >= 360 then
            self.settingsGear.angle = 0
        end
    else
        self.settingsGear.alpha = math.lerp(self.settingsGear.alpha, 0, 0.05)
        self.settingsGear.angle = math.lerp(self.settingsGear.angle, 0, 0.05)
    end

    if self.journalConfig.active then
        --self.warnItems.songVol = self.journalConfig.volSong
        AudioSources["menu_theme_again"]:setVolume(self.journalConfig.volSong)
        if self.journalConfig.alpha <= 1 then
            self.journalConfig.alpha = self.journalConfig.alpha + 1 * elapsed
        end
        self.journalConfig.zoom = self.journalConfig.zoom + 0.02 * elapsed

        self.journalConfig.timer:update(elapsed)
    end

    if self.transitionFade.active then
        self.transitionFade.fade = self.transitionFade.fade + 0.5 * elapsed 

        if self.transitionFade.fade >= 1 then
            gamestate.switch(self.transitionFade.target)
        end
    end

    -- hover the elements --
    for _, e in ipairs(self.mainMenuButtons.elements) do
        --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
        if collision.pointRect({ x = mx, y = my }, e.hitbox) and self.canUseMenu and not self.configMenu then
            e.meta.offsetX = math.lerp(e.meta.offsetX, self.mainMenuButtons.config.offsetX, 0.1)
        else
            e.meta.offsetX = math.lerp(e.meta.offsetX, 0, 0.1)
        end
        
    end
end

function MenuState:mousepressed(x, y, button)
    local mx, my = love.mouse.getPosition() -- x, y from callback is bugged for some reason, use these instead --

    if self.canUseMenu then
        for _, e in ipairs(self.mainMenuButtons.elements) do
            --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
            if button == 1 then
                if collision.pointRect({ x = mx, y = my }, e.hitbox) then
                    if not e.locked then
                        e.action()
                    end
                end
            end
        end
        if button == 1 then
            if collision.pointRect({ x = mx, y = my }, self.settingsGear.hitbox) then
                self.configMenu = not self.configMenu
                self.canUseMenu = self.configMenu and false or true
            end
        end
    end
end

return MenuState