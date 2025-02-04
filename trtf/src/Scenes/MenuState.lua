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

    self.shd_crt = love.graphics.newShader("assets/shaders/CRT.glsl")

    self.shd_vignette = love.graphics.newShader("assets/shaders/Vignette.glsl")
    self.shd_vignette:send("resolution", { love.resconf.width, love.resconf.height })
    self.shd_vignette:send("radius", 0.4)
    self.shd_vignette:send("softness", 0.5)
    self.shd_vignette:send("opacity", 0.2)

    self.viewShader = chainshader(love.resconf.width, love.resconf.height)

    self.viewShader:clearAppended()
    self.viewShader:append(self.shd_crt, self.shd_vignette)

    -- table config --

    self.mainViewCanvas = love.graphics.newCanvas(love.resconf.width, love.resconf.height)
    self.logoCanvas = love.graphics.newCanvas(love.resconf.width, love.resconf.height)

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
        update = false,
        text = "the\nreturn\nto\nfreddy's\nagain"
    }
    
    self.menuAnimatronic = {
        x = 0,
        frame = 1,
        randFrameValue = 0,
    }


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
    self.menuBackground = loadRandomBackground()

    self.crtframe = love.graphics.newImage("assets/images/game/effects/perfect_crt.png")

    self.spr_logo = love.graphics.newImage("assets/images/game/menu/logo.png")

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
    self.viewShader:start()
        love.graphics.draw(self.menuBackground, 0, 0, 0, love.resconf.width / self.menuBackground:getWidth(), love.resconf.height / self.menuBackground:getHeight())
        love.graphics.draw(self.animatronicsAnim[self.menuAnimatronic.frame], 
        self.menuAnimatronic.x, 0, 0, 
        love.resconf.width / self.animatronicsAnim[self.menuAnimatronic.frame]:getWidth(), 
        love.resconf.height / self.animatronicsAnim[self.menuAnimatronic.frame]:getHeight())

        love.graphics.setShader(self.shd_chromafx)
            love.graphics.setBlendMode("add")
                love.graphics.draw(self.spr_logo, self.logoMenu.x, 230, 0, 0.15, 0.15, self.spr_logo:getWidth() / 2, self.spr_logo:getHeight() / 2)
            love.graphics.setBlendMode("alpha")
        love.graphics.setShader()

        -- static overlay --
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.3)
                love.graphics.draw(self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid], 0, 0, 0, 
                    love.resconf.width / self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid]:getWidth(), 
                    love.resconf.height / self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid]:getHeight()
                )
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.draw(self.crtframe, 0, 0, 0, love.resconf.width / self.crtframe:getWidth(), love.resconf.height / self.crtframe:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    self.viewShader:stop()

    love.graphics.print(("%s, %s"):format(love.mouse.getPosition()), 20, 20)
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
end

function MenuState:leave()
    
end

return MenuState