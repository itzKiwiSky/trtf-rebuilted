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
    -- variables --
    self.controllerSelection = 0

    -- shader configuration --
    self.shd_chromafx = love.graphics.newShader("assets/shaders/Chromatic.glsl")
    self.shd_chromafx:send("distortion", 0)

    self.shd_crt = love.graphics.newShader("assets/shaders/CRT.glsl")

    self.shd_vignette = love.graphics.newShader("assets/shaders/Vignette.glsl")
    self.shd_vignette:send("resolution", { love.resconf.width, love.resconf.height })
    self.shd_vignette:send("radius", 0.95)
    self.shd_vignette:send("softness", 0.7)
    self.shd_vignette:send("opacity", 0.13)

    self.blur = moonshine(moonshine.effects.gaussianblur)
    self.blur.gaussianblur.sigma = 10

    self.viewShader = chainshader(love.resconf.width, love.resconf.height)

    self.viewShader:clearAppended()
    self.viewShader:append(self.shd_vignette)

    -- table config --
    self.mainViewCanvas = love.graphics.newCanvas(love.resconf.width, love.resconf.height)

    self.staticAnimationFX = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }
    
    self.logoMenu = {
        x = 208,
        y = 230,
        update = false,
        text = "the\nreturn\nto\nfreddy's\nagain"
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
    self.fnt_menu = fontcache.getFont("tnr", 40)

    self.menuBackground = loadRandomBackground()

    self.crtframe = love.graphics.newImage("assets/images/game/effects/perfect_crt.png")

    self.settingsGear = {
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

    self.settingsGear.hitbox = newButtonHitbox(
        self.settingsGear.x - self.settingsGear.offsetX, 
        self.settingsGear.y - self.settingsGear.offsetY, 78, 78
    )

    self.spr_logo = love.graphics.newImage("assets/images/game/menu/logo.png")
    self.logoMenu.sprWidth = math.floor(0.15 * self.spr_logo:getWidth())
    self.logoMenu.sprHeight = math.floor(0.15 * self.spr_logo:getHeight())

    self.spr_logo_canvas = love.graphics.newCanvas(self.spr_logo:getWidth() + 256, self.spr_logo:getHeight() + 256)
    self.blur.resize(self.spr_logo_canvas:getDimensions())

    self.spr_logo_canvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setBlendMode("alpha", "alphamultiply")
            self.blur(function()
                love.graphics.draw(self.spr_logo)
                love.graphics.printf(string.upper(self.logoMenu.text), self.fnt_mainLogo, 32, 32, math.floor(0.8 * self.spr_logo:getWidth()), "left")
            end)
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(self.spr_logo)
        love.graphics.printf(string.upper(self.logoMenu.text), self.fnt_mainLogo, 32, 32, math.floor(0.8 * self.spr_logo:getWidth()), "left")
    end)

    self.newGameJournal = gameslot.save.game.user.settings.language == "English" and love.graphics.newImage("assets/images/game/menu/news/en.png") or love.graphics.newImage("assets/images/game/menu/news/es.png")

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

    if gameslot.save.game.user.progress.currentNight < 1 then
        self.animatronicsAnim = loadAnimatronic(1)
    else
        self.animatronicsAnim = loadAnimatronic(gameslot.save.game.user.progress.currentNight)
    end

    -- buttons menu --
    self.mainMenuButtons = {
        config = {
            startY = love.graphics.getHeight() / 2 + 16,
            paddingElements = 76,
            x = 64,
            startX = -480
        },
        elements = {
            {
                text = languageService["menu_button_new_game"],
                locked = false,
                action = function()
                    print("novo jgoo")
                end,
                meta = {},
            },
            {
                text = languageService["menu_button_new_game"],
                locked = false,
                action = function()
                    
                end,
                meta = {},
            },
            {
                text = languageService["menu_button_new_game"],
                locked = false,
                action = function()
                    
                end,
                meta = {},
            },
        },
    }

    -- hitboxers

    for _, e in ipairs(self.mainMenuButtons.elements) do
        e.hitbox = newButtonHitbox(self.mainMenuButtons.config.x, self.mainMenuButtons.config.startY, 172, self.fnt_menu:getHeight() + 8)
        self.mainMenuButtons.config.startY = self.mainMenuButtons.config.startY + self.mainMenuButtons.config.paddingElements
    end

    -- sounds sfx --
    SoundController.getChannel("music"):loadSource("menu_theme_again")
    SoundController.getChannel("music"):setLooping(true)
end

function MenuState:draw()
    self.viewShader:start()
        love.graphics.draw(self.menuBackground, 0, 0, 0, love.resconf.width / self.menuBackground:getWidth(), love.resconf.height / self.menuBackground:getHeight())
        love.graphics.draw(self.animatronicsAnim[self.menuAnimatronic.frame], 
        self.menuAnimatronic.x, 0, 0, 
        love.resconf.width / self.animatronicsAnim[self.menuAnimatronic.frame]:getWidth(), 
        love.resconf.height / self.animatronicsAnim[self.menuAnimatronic.frame]:getHeight())


        love.graphics.setBlendMode("add")
            love.graphics.setShader(self.shd_chromafx)
                love.graphics.draw(self.spr_logo_canvas, self.logoMenu.x, self.logoMenu.y, 0, 0.15, 0.15, self.spr_logo:getWidth() / 2, self.spr_logo:getHeight() / 2)
            love.graphics.setShader()
        love.graphics.setBlendMode("alpha")
        --love.graphics.setBlendMode("alpha")

        -- static overlay --
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.3)
                love.graphics.draw(self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid], 0, 0, 0, 
                    love.resconf.width / self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid]:getWidth(), 
                    love.resconf.height / self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid]:getHeight()
                )
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        for _, e in ipairs(self.mainMenuButtons.elements) do
            love.graphics.print(e.text, self.fnt_menu, self.mainMenuButtons.config.startX, e.hitbox.y)
            love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
        end

        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.draw(self.crtframe, 0, 0, 0, love.resconf.width / self.crtframe:getWidth(), love.resconf.height / self.crtframe:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    self.viewShader:stop()

    --love.graphics.setColor(0, 0, 0, self.journalScreen.alpha)
    --love.graphics.rectangle("fill", 0, 0, love.resconf.width, love.resconf.height)
    --love.graphics.setColor(1, 1, 1, 1)

    --love.graphics.print(("%s, %s"):format(love.mouse.getPosition()), 20, 20)
end

function MenuState:update(elapsed)
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
end

function MenuState:mousepressed(x, y, button)
    local mx, my = love.mouse.getPosition() -- x, y from callback is bugged for some reason, use these instead --

    for _, e in ipairs(self.mainMenuButtons.elements) do
        --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
        if collision.pointRect({ x = mx, y = my }, e.hitbox) then
            if not e.locked then
                e.action()
            end
        end
    end
end

function MenuState:leave()
    -- release all objects from the scene before leave
    for k, v in pairs(self) do
        if type(v) == "userdata" and v.type then
            if v.release then
                v:release()
            end
        end
    end
end

return MenuState