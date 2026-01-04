MenuState = {}

local function loadAnimatronic(id)
    local chars = { "bonnie", "chica", "foxy", "freddy", "sugar", "kitty_fazcat", "lockjaw" }
    local anfiles = {}
    local char = chars[id]
    local charFolder = love.filesystem.getDirectoryItems("assets/images/game/menu/animatronics/" .. char)
    for c = 1, #charFolder, 1 do
        table.insert(anfiles, love.graphics.newImage("assets/images/game/menu/animatronics/" .. char .. "/" .. charFolder[c]))
    end
    return anfiles
end

local function updateTexts(t)
    for _, element in ipairs(t) do
        element.text = languageService[element.key]
    end
end

local function loadRandomBackground()
    local bgs = love.filesystem.getDirectoryItems("assets/images/game/menu/backgrounds")
    return love.graphics.newImage("assets/images/game/menu/backgrounds/" .. bgs[math.random(1, #bgs)])
end

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function MenuState:enter()
    registers.isStoryMode = false

    flux.removeAll()
    MenuState.saveState = gameSave.save.user.progress
    self.settingsSubState = require 'src.States.Substates.SettingsSubstate'
    self.settingsSubState:load()

    if FEATURE_FLAGS.developerMode then
        registers.devWindowContent = function()
            Slab.BeginWindow("menuNightDev", { Title = "Development" })
            Slab.Text("Save editor | progress")

            for key, value in spairs(gameSave.save.user.progress) do
                switch(type(value), {
                    ["boolean"] = function()
                        if Slab.CheckBox(value, tostring(key)) then
                            gameSave.save.user.progress[key] = not gameSave.save.user.progress[key]
                        end
                    end,
                    ["number"] = function()
                        Slab.Text(key)
                        Slab.SameLine()
                        if Slab.Input("inputNumberKey_" .. tostring(key), { Text = tostring(value), ReturnOnText = false, NumbersOnly = true }) then
                            gameSave.save.user.progress[key] = Slab.GetInputNumber()
                        end
                    end
                })
            end

            if Slab.Button("Save slot") then
                gameSave:saveSlot()
            end

            Slab.Separator()
            for _, value in ipairs(registers.statesName) do
                if Slab.Button(value) then
                    loadstring("gamestate.switch(" .. value .. ")")()
                end
            end

            Slab.Separator()

            if Slab.Button("Load cutscene") then
                LoadingState.mode = "cutscene"
                --table.clear(LoadingState._tempAssets)
                gamestate.switch(LoadingState)
            end

            Slab.Separator()

            if Slab.Button("Load ending [NORMAL]") then
                gamestate.switch(EndingState)
            end

            if Slab.Button("Load ending [SECRET]") then
                EndingState.mode = "secret"
                gamestate.switch(EndingState)
            end

            if Slab.Button("Load ending [Night 6]") then
                EndingState.mode = "night6"
                gamestate.switch(EndingState)
            end

            Slab.EndWindow()
        end
    end

    -- variables --
    self.controllerSelection = 0
    self.canUseMenu = false
    self.configMenu = false

    -- shader configuration --
    self.shd_chromafx = love.graphics.newShader("assets/shaders/Chromatic.glsl")
    self.shd_chromafx:send("distortion", 0)

    self.shd_effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)
    self.shd_blur = moonshine(moonshine.effects.boxblur)
    self.shd_glowEffect = moonshine(moonshine.effects.glow)
    self.shd_glowEffect.glow.strength = 5
    self.shd_blur.boxblur.radius = { 0, 0 }

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

    self.textAcc = ""

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
        left = false,
        journalText = 0,
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
    self.fnt_menu_low = fontcache.getFont("tnr", 20)

    self.menuBackground = loadRandomBackground()

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

    self.instructionsIcon = {
        x = shove.getViewportWidth() + 128,
        y = 270,
        offsetX = 40,
        offsetY = 40,
        hitbox = {},
        hovered = false,
        angle = 0,
        alpha = 0,
        size = 128,
        ico = love.graphics.newImage("assets/images/game/menu/UI/instruction_icon.png"),
        glow = love.graphics.newImage("assets/images/game/menu/UI/instruction_icon_glow.png")
    }

    self.instructionsIcon.hitbox = newButtonHitbox(
        self.instructionsIcon.x - self.instructionsIcon.offsetX,
        self.instructionsIcon.y - self.instructionsIcon.offsetY, 78, 78
    )

    self.spr_logo = love.graphics.newImage("assets/images/game/menu/logo.png")
    self.logoMenu.sprWidth = math.floor(self.logoMenu.scale * self.spr_logo:getWidth())
    self.logoMenu.sprHeight = math.floor(self.logoMenu.scale * self.spr_logo:getHeight())

    self.newGameJournal = gameSave.save.user.settings.misc.language == "Espanol" and love.graphics.newImage("assets/images/game/menu/news/es.png") or love.graphics.newImage("assets/images/game/menu/news/en.png")

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

    self.transitionFade = {
        active = false,
        target = nil,
        fade = 0,
        acc = 0,
        maxTime = 0.12,
    }

    -- buttons menu --
    self.mainMenuButtons = {
        config = {
            startY = 400,
            paddingElements = 69, -- :smirk: --
            targetX = 64,
            startX = -480,
            x = -480,
            offsetX = 24
        },
        elements = {
            {
                key = "menu_button_new_game",
                text = "",
                locked = false,
                action = function()
                    progress = {
                        specialCutsceneSee = false,
                        initialCutscene = false,
                        newgame = true,
                        extras = false,
                        canContinue = false,
                        night = 1,
                        playingMinigame = false,
                        showNight8 = false,
                        night8 = false,
                        minigameID = "",
                        stars = {
                            beatNight8 = false,
                            beat20 = false,
                            beatNight6 = false,
                        }
                    }

                    for key, value in pairs(progress) do
                        gameSave.save.user.progress[key] = value
                    end

                    --gameSave.save.user.progress = progress
                    self.canUseMenu = false
                    self.journalConfig.active = true
                    registers.isStoryMode = true
                    NightState.nightID = gameSave.save.user.progress.night
                    gameSave:saveSlot()
                end,
            },
            {
                key = "menu_button_continue",
                text = "",
                locked = gameSave.save.user.progress.canContinue,
                action = function()
                    registers.isStoryMode = true
                    NightState.nightID = gameSave.save.user.progress.night
                    self.transitionFade.target = LoadingState
                    self.transitionFade.active = true
                end,
            },
            {
                key = "menu_button_extras",
                text = "",
                locked = not gameSave.save.user.progress.extras,
                action = function()
                    registers.isStoryMode = false
                    self.transitionFade.target = ExtrasState
                    self.transitionFade.active = true
                end,
            },
            {
                key = "menu_button_exit",
                text = "",
                locked = false,
                action = function()
                    love.event.quit()
                end,
            },
        },
    }

    if gameSave.save.user.progress.showNight8 then
        --self.mainMenuButtons.elements[#self.mainMenuButtons.elements + 1] =
        table.insert(self.mainMenuButtons.elements, #self.mainMenuButtons.elements, {
            key = "menu_button_night_secret",
            locked = false,
            action = function()
                LoadingState.mode = "secret"
                self.transitionFade.target = LoadingState
                self.transitionFade.active = true
            end,
        })

        updateTexts(self.mainMenuButtons.elements)
    end

    self.journalConfig = {
        alpha = 0,
        zoom = 1,
        angle = 0,
        active = false,
        clicked = false,
        timer = timer.new(),
        transfade = 0,
        volSong = 1,
        blackFade = 0,
        doTween = false,
    }

    self.fadeTween = {}
    self.journalConfig.timer:after(3.75, function()
        self.fadeTween = flux.to(self.journalConfig, 4, { transfade = 1, volSong = 0 })
            :ease("linear")
            :oncomplete(function()
                VideoPlayerState.path = gameSave.save.user.settings.misc.language == "Espanol" and "assets/videos/intro_cutscene_es.ogv" or "assets/videos/intro_cutscene_en.ogv"
                VideoPlayerState.onSceneComplete = function()
                    LoadingState.mode = "cutscene"
                    gamestate.switch(LoadingState)
                end
                gamestate.switch(VideoPlayerState)
            end)
    end)


    -- hitboxers
    for _, e in ipairs(self.mainMenuButtons.elements) do
        e.meta = {}
        e.meta.offsetX = 0
        e.hovered = false
        e.hitbox = newButtonHitbox(self.mainMenuButtons.config.targetX, self.mainMenuButtons.config.startY, 180, self.fnt_menu:getHeight() + 8)
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
    self.instructionTween = flux.to(self.instructionsIcon, 1.5, { x = shove.getViewportWidth() - 128 })

    if not AudioSources["sfx_rainleak"]:isPlaying() then
        AudioSources["sfx_rainleak"]:play()
        AudioSources["sfx_rainleak"]:setLooping(true)
        AudioSources["sfx_rainleak"]:setVolume(0.3)
    end

    AudioSources["msc_menu_theme_again"]:setLooping(true)
    AudioSources["msc_menu_theme_again"]:play()
end

function MenuState:draw()
    self.shd_blur(function()
        self.shd_effect(function()
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

    love.graphics.setColor(1, 1, 1, self.instructionsIcon.alpha)
    love.graphics.draw(
        self.instructionsIcon.glow, self.instructionsIcon.x, self.instructionsIcon.y, math.rad(self.instructionsIcon.angle),
        self.instructionsIcon.size / self.instructionsIcon.glow:getWidth(), self.instructionsIcon.size / self.instructionsIcon.glow:getHeight(),
        self.instructionsIcon.glow:getWidth() / 2, self.instructionsIcon.glow:getHeight() / 2
    )
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(
        self.instructionsIcon.ico, self.instructionsIcon.x, self.instructionsIcon.y, math.rad(self.instructionsIcon.angle),
        self.instructionsIcon.size / self.instructionsIcon.ico:getWidth(), self.instructionsIcon.size / self.instructionsIcon.ico:getHeight(),
        self.instructionsIcon.ico:getWidth() / 2, self.instructionsIcon.ico:getHeight() / 2
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
        --if registers.showDebugHitbox then
        --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
        --end
    end

    if self.configMenu then
        self.settingsSubState:draw()
    end

    -- journal --
    love.graphics.printf("@ 2025 BrightSmileTeam", self.fnt_menu_low, -32, shove.getViewportHeight() - (self.fnt_menu_low:getHeight() + 5), shove.getViewportWidth(), "right")

    love.graphics.setColor(1, 1, 1, self.journalConfig.alpha)
    love.graphics.draw(self.newGameJournal, shove.getViewportWidth() / 2, shove.getViewportHeight() / 2, math.rad(self.journalConfig.angle), self.journalConfig.zoom, self.journalConfig.zoom, self.newGameJournal:getWidth() / 2, self.newGameJournal:getHeight() / 2)
    love.graphics.printf("Click to continue", self.fnt_menu_low, -32, shove.getViewportHeight() - (self.fnt_menu_low:getHeight() + 5), shove.getViewportWidth(), "right")
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, self.journalConfig.transfade)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    --if gamejolt.isLoggedIn then
    --    love.graphics.printf("Connected as " .. gamejolt.username, self.fnt_menu_low, -32, shove.getViewportHeight() - (self.fnt_menu_low:getHeight() * 2.3), shove.getViewportWidth(), "right")
    --end

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
    local inside, mx, my = shove.mouseToViewport()
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

    -- update all texts --
    updateTexts(self.mainMenuButtons.elements)


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

    self.instructionsIcon.hovered = collision.pointRect({ x = mx, y = my }, self.instructionsIcon.hitbox)
    self.instructionsIcon.hitbox.x = self.instructionsIcon.x - self.instructionsIcon.offsetX

    if self.instructionsIcon.hovered and self.canUseMenu then
        self.instructionsIcon.alpha = math.lerp(self.instructionsIcon.alpha, 1, 0.05)
    else
        self.instructionsIcon.alpha = math.lerp(self.instructionsIcon.alpha, 0, 0.05)
    end

    if self.journalConfig.active then
        --self.warnItems.songVol = self.journalConfig.volSong
        AudioSources["msc_menu_theme_again"]:setVolume(self.journalConfig.volSong)
        if self.journalConfig.alpha <= 1 then
            self.journalConfig.alpha = self.journalConfig.alpha + 1 * elapsed
        end
    end

    if gameSave.save.user.progress.night > 5 then
        if self.textAcc == "lockjaw" then
            gameSave.save.user.progress.showNight8 = true
            gameSave:saveSlot()

            gamestate.switch(MenuState)
        end
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
            e.meta.hovered = true
        else
            e.meta.offsetX = math.lerp(e.meta.offsetX, 0, 0.1)
            e.meta.hovered = false
        end
    end
end

function MenuState:mousepressed(x, y, button)
    local inside, mx, my = shove.mouseToViewport() -- x, y from callback is bugged for some reason, use these instead --

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
                self.canUseMenu = false
            end
            if collision.pointRect({ x = mx, y = my }, self.instructionsIcon.hitbox) then
                self.configMenu = not self.configMenu
                self.canUseMenu = false
            end
        end
    else
        if self.journalConfig.active then
            self.journalConfig.clicked = true
            self.fadeTween = flux.to(self.journalConfig, 4, { transfade = 1, volSong = 0 })
            self.fadeTween:ease("linear")
            self.fadeTween:oncomplete(function()
                VideoPlayerState.path = gameSave.save.user.settings.misc.language == "Espanol" and "assets/videos/intro_cutscene_es.ogv" or "assets/videos/intro_cutscene_en.ogv"
                VideoPlayerState.onSceneComplete = function()
                    LoadingState.mode = "cutscene"
                    gameSave.save.user.progress.canContinue = true
                    gameSave:saveSlot()
                    gamestate.switch(LoadingState)
                end
                gamestate.switch(VideoPlayerState)
            end)
        end
    end
end

function MenuState:textinput(t)
    self.textAcc = self.textAcc .. t
end

function MenuState:leave()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    for _, f in ipairs(self.animatronicsAnim) do
        f:release()
    end

    for _, f in ipairs(self.staticAnimationFX.frames) do
        f:release()
    end

    flux.removeAll()

    self.menuBackground:release()
end

return MenuState
