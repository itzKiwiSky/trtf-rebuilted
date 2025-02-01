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

function MenuState:enter()
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

    -- sprites --
    self.menuBackground = loadRandomBackground()
    
    self.staticAnimationFX = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }

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
    
    self.mainMenuButtons = {
        {
            text = "new game",
            hitbox = {
                x = 1000,
                y = 90,
                w = 100,
                h = 100},
            action = function()
                print("hello world")
            end
        }
    }
end

function MenuState:draw()
    self.shd_blur(function()
        -- shader for menu background and animatronic display --
        self.shd_effect(function()
            love.graphics.draw(self.menuBackground, 0, 0, 0, love.graphics.getWidth() / self.menuBackground:getWidth(), love.graphics.getHeight() / self.menuBackground:getHeight())
            --love.graphics.draw(animatronicsAnim[menuAnimatronic.frame], menuAnimatronic.x, 0, 0, love.graphics.getWidth() / animatronicsAnim[menuAnimatronic.frame]:getWidth(), love.graphics.getHeight() / animatronicsAnim[menuAnimatronic.frame]:getHeight())
        end)

        -- logo effect --
        love.graphics.setShader(self.shd_chromafx)
            love.graphics.setBlendMode("add")
                love.graphics.draw(self.spr_logo, self.logoMenu.x, 230, 0, 1, 1, self.spr_logo:getWidth() / 2, self.spr_logo:getHeight() / 2)
            love.graphics.setBlendMode("alpha")
        love.graphics.setShader()

        -- static overlay --
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.draw(self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid], 0, 0, 0, love.graphics.getWidth() / self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid]:getWidth(), love.graphics.getHeight() / self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid]:getHeight())
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")
    end)

    love.graphics.print(("%s, %s"):format(love.mouse.getPosition()), 20, 20)
end

function MenuState:update(elapsed)
    
end

function MenuState:mousepressed(x, y, button)
    local mx, my = love.mouse.getPosition() -- x, y from callback is bugged for some reason, use these instead --
end

function MenuState:leave()
    
end

return MenuState