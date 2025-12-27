ExtrasState = {}

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function ExtrasState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
    self.isJumpcareLoading = false
    self.showExtrasOptions = true
    self.fnt_extras = fontcache.getFont("ocrx", 28)
    self.fnt_extras_title = fontcache.getFont("ocrx", 38)

    self.categories = {
        ["animatronics"] = require 'src.States.Substates.ExtraSubStates.Animatronics',
        ["jumpscares"] = require 'src.States.Substates.ExtraSubStates.Jumpscares',
        ["bts"] = require 'src.States.Substates.ExtraSubStates.BehindTheScenes',
        ["minigames"] = require 'src.States.Substates.ExtraSubStates.Minigames',
    }

    AudioSources["msc_extras_bg"]:play()
    AudioSources["msc_extras_bg"]:setLooping(true)
    AudioSources["msc_extras_bg"]:setVolume(0.6)

    self.currentCategory = "animatronics"
    self.bg = love.graphics.newImage("assets/images/game/extras/bg.png")

    self.categories[self.currentCategory]:load()

    self.staticAnimationFX = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }

    flux.removeAll()

    self.fade = {
        alpha = 1,
    }

    flux.to(self.fade, 2, { alpha = 0 })

    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static3")
    for s = 1, #statics, 1 do
        table.insert(self.staticAnimationFX.frames, love.graphics.newImage("assets/images/game/effects/static3/" .. statics[s]))
    end

    self.fxBlurBG = moonshine(moonshine.effects.boxblur).chain(moonshine.effects.pixelate)
    self.fxBlurBG.boxblur.radius = { 7, 7 }
    self.shd_effect = moonshine(moonshine.effects.crt)
        .chain(moonshine.effects.chromasep)

    self.fxBlurBG.pixelate.feedback = 0.1
    self.fxBlurBG.pixelate.size = { 1.5, 1.5 }

    self.shd_effect.chromasep.radius = 1.25

    local function doTransition(state)
        flux.to(self.fade, 2, { alpha = 1 }):oncomplete(function()
            gamestate.switch(state)
        end)
    end

    self.menuItems = {
        config = {
            startY = 165,
            paddingElements = 69, -- :smirk: --
            x = 64,
            offsetX = 24
        },
        elements = {
            {
                text = languageService["extras_options_animatronics"],
                action = function()
                    if self.currentCategory == "animatronics" then return end

                    self.currentCategory = "animatronics"
                    self.categories[self.currentCategory]:load()
                end,
            },
            {
                text = languageService["extras_options_jumpscares"],
                action = function()
                    if self.currentCategory == "jumpscares" then return end

                    self.currentCategory = "jumpscares"
                    self.categories[self.currentCategory]:load()
                end,
            },
            {
                text = languageService["extras_options_dev_content"],
                action = function()
                    if self.currentCategory == "bts" then return end

                    self.currentCategory = "bts"
                    self.categories[self.currentCategory]:load()
                end,
            },
            {
                text = languageService["extras_options_minigames"],
                action = function()
                    if self.currentCategory == "minigames" then return end

                    self.currentCategory = "minigames"
                    self.categories[self.currentCategory]:load()
                end,
            },
            {
                text = languageService["extras_options_custom_night"],
                action = function()
                    doTransition(CustomNightState)
                end,
            },
            {
                text = languageService["gameover_button_exit"],
                action = function()
                    doTransition(MenuState)
                end,
            },
            --[[{
                text = languageService["extras_options_credits"],
                action = function()

                end,
            },]]
        }
    }

    for _, e in ipairs(self.menuItems.elements) do
        e.meta = {}
        e.meta.offsetX = 0
        e.hitbox = newButtonHitbox(self.menuItems.config.x, self.menuItems.config.startY, 300, self.fnt_extras:getHeight() + 8)
        self.menuItems.config.startY = self.menuItems.config.startY + self.menuItems.config.paddingElements
    end

    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")
end

function ExtrasState:draw()
    self.shd_effect(function()
        self.fxBlurBG(function()
            love.graphics.draw(self.bg, 0, 0, 0, shove.getViewportWidth() / self.bg:getWidth(), shove.getViewportHeight() / self.bg:getHeight())
        end)

        love.graphics.setBlendMode("add")
        love.graphics.setColor(1, 1, 1, 0.12)
        love.graphics.draw(self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid], 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        love.graphics.draw(self.crtOverlay, 0, 0, 0, shove.getViewportWidth() / self.crtOverlay:getWidth(), shove.getViewportHeight() / self.crtOverlay:getHeight())

        self.categories[self.currentCategory]:draw()

        if self.showExtrasOptions then
            love.graphics.print("Extras", self.fnt_extras_title, 64, 64)
            for _, e in ipairs(self.menuItems.elements) do
                love.graphics.print(e.text, self.fnt_extras, self.menuItems.config.x + e.meta.offsetX, e.hitbox.y)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
            end
        end
    end)

    love.graphics.setColor(0, 0, 0, self.fade.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1)
end

function ExtrasState:update(elapsed)
    local inside, mx, my = shove.mouseToViewport()

    self.categories[self.currentCategory]:update(elapsed)

    -- static animation --
    self.staticAnimationFX.config.timer = self.staticAnimationFX.config.timer + elapsed
    if self.staticAnimationFX.config.timer >= self.staticAnimationFX.config.speed then
        self.staticAnimationFX.config.timer = 0
        self.staticAnimationFX.config.frameid = self.staticAnimationFX.config.frameid + 1
        if self.staticAnimationFX.config.frameid >= #self.staticAnimationFX.frames then
            self.staticAnimationFX.config.frameid = 1
        end
    end

    if Controller:pressed("ui_back") then
        gamestate.switch(MenuState)
    end

    if self.showExtrasOptions then
        for _, e in ipairs(self.menuItems.elements) do
            --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
            if collision.pointRect({ x = mx, y = my }, e.hitbox) then
                e.meta.offsetX = math.lerp(e.meta.offsetX, self.menuItems.config.offsetX, 0.1)
            else
                e.meta.offsetX = math.lerp(e.meta.offsetX, 0, 0.1)
            end
        end
    end

    flux.update(elapsed)
end

function ExtrasState:mousepressed(x, y, button)
    local inside, mx, my = shove.mouseToViewport()

    if self.showExtrasOptions and not self.isJumpcareLoading then
        if button == 1 then
            for _, e in ipairs(self.menuItems.elements) do
                --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
                if collision.pointRect({ x = mx, y = my }, e.hitbox) then
                    if not AudioSources["msc_extras_bg"]:isPlaying() then
                        AudioSources["msc_extras_bg"]:play()
                        AudioSources["msc_extras_bg"]:setLooping(true)
                    end
                    AudioSources["msc_extras_bg"]:setVolume(0.6)

                    e.action()
                end
            end
        end
    end

    if self.categories[self.currentCategory].mousepressed then
        self.categories[self.currentCategory]:mousepressed(x, y, button)
    end
end

function ExtrasState:wheelmoved(x, y)
    if self.categories[self.currentCategory].wheelmoved then
        self.categories[self.currentCategory]:wheelmoved(x, y)
    end
end

function ExtrasState:leave()
    flux.removeAll()

    for k, v in pairs(AudioSources) do
        v:stop()
    end

    for _, f in ipairs(self.staticAnimationFX.frames) do
        f:release()
    end

    for key, value in pairs(self.categories) do
        if value.release ~= nil then
            value:release()
        end
        value.loaded = false
    end


    loveView.unloadView()
end

return ExtrasState
