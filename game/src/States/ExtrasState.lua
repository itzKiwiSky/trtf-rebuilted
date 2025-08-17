ExtrasState = {}

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function ExtrasState:enter()
    self.fnt_extras = fontcache.getFont("ocrx", 28)

    self.categories = {
        ["animatronics"] = require 'src.States.Substates.ExtraSubStates.Animatronics'
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

    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static3")
    for s = 1, #statics, 1 do
        table.insert(self.staticAnimationFX.frames, love.graphics.newImage("assets/images/game/effects/static3/" .. statics[s]))
    end


    self.shd_effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.vignette)

    self.menuItems = {
        config = {
            startY = 165,
            paddingElements = 69,       -- :smirk: --
            x = 64,
            offsetX = 24
        },
        elements = {
            {
                text = languageService["extras_options_animatronics"],
                action = function()

                end,
            },
            {
                text = languageService["extras_options_jumpscares"],
                action = function()

                end,
            },
            {
                text = languageService["extras_options_dev_content"],
                action = function()

                end,
            },
            {
                text = languageService["extras_options_minigames"],
                action = function()

                end,
            },
            {
                text = languageService["extras_options_replay_night"],
                action = function()

                end,
            },
            {
                text = languageService["extras_options_custom_night"],
                action = function()

                end,
            },
            {
                text = languageService["extras_options_credits"],
                action = function()

                end,
            },
        }
    }

    for _, e in ipairs(self.menuItems.elements) do
        e.meta = {}
        e.meta.offsetX = 0
        e.hitbox = newButtonHitbox(self.menuItems.config.x, self.menuItems.config.startY, self.fnt_extras:getWidth(e.text) + 8, self.fnt_extras:getHeight() + 8)
        self.menuItems.config.startY = self.menuItems.config.startY + self.menuItems.config.paddingElements
    end
end

function ExtrasState:draw()
    self.shd_effect(function ()
        love.graphics.draw(self.bg, 0, 0, 0, shove.getViewportWidth() / self.bg:getWidth(), shove.getViewportHeight() / self.bg:getHeight())
        
        love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, 0.12)
                love.graphics.draw(self.staticAnimationFX.frames[self.staticAnimationFX.config.frameid], 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")

        love.graphics.print("extras", self.fnt_extras, 64, 64)
        for _, e in ipairs(self.menuItems.elements) do
            if e.locked then
                love.graphics.setColor(0.5, 0.5, 0.5, 1)
            end
            love.graphics.print(e.text, self.fnt_extras, self.menuItems.config.x + e.meta.offsetX, e.hitbox.y)
            love.graphics.setColor(1, 1, 1, 1)
            --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
        end

        self.categories[self.currentCategory]:draw()
    end)
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

    for _, e in ipairs(self.menuItems.elements) do
        --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
        if collision.pointRect({ x = mx, y = my }, e.hitbox) then
            e.meta.offsetX = math.lerp(e.meta.offsetX, self.menuItems.config.offsetX, 0.1)
        else
            e.meta.offsetX = math.lerp(e.meta.offsetX, 0, 0.1)
        end
        
    end
end

function ExtrasState:leave()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
    
    for _, f in ipairs(self.staticAnimationFX.frames) do
        f:release()
    end
end

return ExtrasState