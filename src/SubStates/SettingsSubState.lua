SettingsSubState = {}

function SettingsSubState:load()
    self.active = false
    shd_glowEffectText = moonshine(moonshine.effects.glow)
    shd_glowEffectText.glow.strength = 5

    spr_settings = {}
    spr_settings.img, spr_settings.quads = love.graphics.getHashedQuads("assets/images/game/menu/UI/settingsUI")
    spr_arrow = love.graphics.newImage("assets/images/game/menu/UI/arrow.png")

    local langFiles = love.filesystem.getDirectoryItems("assets/data/language")
    for l = 1, #langFiles, 1 do
        langFiles[l] = langFiles[l]:gsub("%.[^.]+$", "")
    end

    self.blur = 0
    self.currentLangID = 1
    
    self.options = {
        config = {
            padding = 16,
            lpadding = 42,
            startY = 96,
            startX = 426,
            offsetY = 61,
        },
        elements = {
            {
                text = languageService["menu_settings_shaders"],
                type = "bool",
                target = false,
                valueTarget = "shaders",
                description = languageService["menu_settings_description_shaders"],
                meta = {},
            },
            {
                text = languageService["menu_settings_vsync"],
                type = "bool",
                target = false,
                valueTarget = "vsync",
                description = languageService["menu_settings_description_vsync"],
                meta = {},
            },
            {
                text = languageService["menu_settings_antialiasing"],
                type = "bool",
                target = false,
                valueTarget = "antialiasing",
                description = languageService["menu_settings_description_antialiasing"],
                meta = {},
            },
            {
                text = languageService["menu_settings_window_effects"],
                type = "bool",
                target = false,
                valueTarget = "windowEffects",
                description = languageService["menu_settings_description_window_effects"],
                meta = {},
            },
            {
                text = languageService["menu_settings_preserve_assets"],
                type = "bool",
                target = false,
                valueTarget = "preserveAssets",
                description = languageService["menu_settings_description_preserve_assets"],
                meta = {},
            },
            {
                text = languageService["menu_settings_language"] .. " : " .. langFiles[SettingsSubState.currentLangID],
                type = "button",
                target = function()
                    SettingsSubState.currentLangID = SettingsSubState.currentLangID + 1
                    if SettingsSubState.currentLangID > #langFiles then
                        SettingsSubState.currentLangID = 1
                    end
                end,
                description = languageService["menu_settings_description_language"],
                meta = {},
            },
            {
                text = gamejolt.isLoggedIn and languageService["menu_settings_gamejolt_connected"] or languageService["menu_settings_gamejolt_not_connect"] ,
                type = "button",
                target = function()
                    print("Im a button")
                end,
                description = languageService["menu_settings_description_gamejolt"],
                meta = {},
            },
            {
                text = languageService["menu_settings_reset_settings"],
                type = "button",
                target = function()
                    local defaultSettings = {
                        shaders = true,
                        language = "English",
                        preserveAssets = false,
                        vsync = false,
                        antialiasing = true,
                        windowEffects = true,
                    }

                    for k, v in pairs(defaultSettings) do
                        gameslot.save.game.user.settings[k] = v
                    end

                    for _, o in ipairs(self.options.elements) do
                        if o.type then
                            if type(o.target) == "boolean" then
                                o.target = gameslot.save.game.user.settings[o.valueTarget]
                            end
                        end
                    end
                end,
                description = languageService["menu_settings_description_reset_settings"],
                meta = {},
            },
        }
    }

    for _, o in ipairs(self.options.elements) do
        if o.type then
            switch(o.type, {
                ["bool"] = function()
                    o.meta.hitbox = {
                        x = self.options.config.startX - math.floor(self.options.config.lpadding / 2),
                        y = self.options.config.startY + self.options.config.offsetY * _,
                        w = 48,
                        h = 48,
                    }

                    if type(o.target) == "boolean" then
                        o.target = gameslot.save.game.user.settings[o.valueTarget]
                    end
                end,
                ["button"] = function()
                    o.meta.hitbox = {
                        x = (self.options.config.startX + self.options.config.lpadding) - 3,
                        y = (self.options.config.startY + (fnt_menu:getHeight() + self.options.config.padding) * _) - 3,
                        w = fnt_menu:getWidth(o.text) + 6,
                        h = fnt_menu:getHeight() + 6,
                    }
                end
            })
            o.meta.hovered = false
            o.meta.alpha = 0
        end
    end
end

function SettingsSubState:draw()
    if self.active then
        love.graphics.printf(languageService["menu_settings_title"], fnt_settingsTitle, 0, 69, love.graphics.getWidth(), "center")
        for _, o in ipairs(self.options.elements) do
            switch(o.type, {
                ["bool"] = function()
                    local qx, qy, qw, qh = spr_settings.quads["settingsBox"]:getViewport()
    
                    love.graphics.setColor(1, 1, 1, o.meta.alpha)
                        love.graphics.draw(spr_settings.img, spr_settings.quads["settingsBoxGlow"], self.options.config.startX - math.floor(self.options.config.lpadding / 2), self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                    love.graphics.setColor(1, 1, 1, 1)

                    if type(o.target) == "boolean" and o.target then
                        love.graphics.draw(spr_settings.img, spr_settings.quads["settingsBoxChecked"], self.options.config.startX - math.floor(self.options.config.lpadding / 2), self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                        love.graphics.draw(spr_settings.img, spr_settings.quads["checkMark"], self.options.config.startX - math.floor(self.options.config.lpadding / 2), self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                    end

                    love.graphics.draw(spr_settings.img, spr_settings.quads["settingsBox"], self.options.config.startX - math.floor(self.options.config.lpadding / 2), self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                    love.graphics.print(o.text, fnt_menu, self.options.config.startX + self.options.config.lpadding, self.options.config.startY + (fnt_menu:getHeight() + self.options.config.padding) * _)
                    if o.meta.hitbox then
                        --love.graphics.rectangle("line", o.meta.hitbox.x, o.meta.hitbox.y, o.meta.hitbox.w, o.meta.hitbox.h)
                    end
                end,
                ["button"] = function()
                    if o.meta.hovered then
                        love.graphics.setColor(0.4, 0.4, 0.4, 1)
                    else
                        love.graphics.setColor(1, 1, 1, 1)
                    end
                    love.graphics.print(o.text, fnt_menu, self.options.config.startX + self.options.config.lpadding, self.options.config.startY + (fnt_menu:getHeight() + self.options.config.padding) * _)
                    love.graphics.setColor(1, 1, 1, 1)
                    if o.meta.hitbox then
                        --love.graphics.rectangle("line", o.meta.hitbox.x, o.meta.hitbox.y, o.meta.hitbox.w, o.meta.hitbox.h)
                    end
                end
            })

            if o.description then
                if o.meta.hovered then
                    love.graphics.printf(o.description, fnt_settingsDesc, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
                end
            end
        end
    end
end

function SettingsSubState:update(elapsed)
    if self.active then
        self.blur = math.lerp(self.blur, 10, 0.05)
        local mx, my = love.mouse.getPosition()

        for _, o in ipairs(self.options.elements) do
            o.meta.hovered = collision.pointRect({ x = mx, y = my }, o.meta.hitbox)
            
            if o.meta.hovered then
                o.meta.alpha = math.lerp(o.meta.alpha, 1, 0.06)
            else
                o.meta.alpha = math.lerp(o.meta.alpha, 0, 0.06)
            end
        end
    else
        self.blur = math.lerp(self.blur, 0, 0.05)
    end
    shd_blur.boxblur.radius = {self.blur, self.blur}


end

function SettingsSubState:mousepressed(x, y, button)
    if self.active then
        for _, o in ipairs(self.options.elements) do
            if o.meta.hovered then
                if type(o.target) == "boolean" then
                    o.target = not o.target
                    gameslot.save.game.user.settings[o.valueTarget] = o.target
                else
                    o.target()
                end
            end
        end

        --love.window.setFullscreen(gameslot.save.game.user.settings.fullscreen, "exclusive")
        love.window.setVSync(gameslot.save.game.user.settings.vsync and 1 or 0)
    
        if gameslot.save.game.user.settings.antialiasing then
            love.graphics.setDefaultFilter("linear", "linear")
        else
            love.graphics.setDefaultFilter("nearest", "nearest")
        end

        gameslot:saveSlot()
    end
end


function SettingsSubState:wheelmoved(x, y)
    --[[
    if y < 0 then
        self.options.config.offsetY = self.options.config.offsetY - 1
    elseif y > 0 then
        self.options.config.offsetY = self.options.config.offsetY + 1
    end
    ]]--
end

return SettingsSubState