local SettingsSubState = {}

function SettingsSubState.rebuildUI(this)
    lume.clear(this.options.elements)
    this.options.elements = {}

    this.options.elements[1] = {
        text = languageService["menu_settings_shaders"],
        type = "bool",
        target = false,
        valueTarget = "shaders",
        description = languageService["menu_settings_description_shaders"],
        meta = {},
    }
    this.options.elements[2] = {
        text = languageService["menu_settings_fullscreen"],
        type = "bool",
        target = false,
        valueTarget = "fullscreen",
        description = languageService["menu_settings_description_fullscreen"],
        meta = {},
    }
    this.options.elements[3] = {
        text = languageService["menu_settings_vsync"],
        type = "bool",
        target = false,
        valueTarget = "vsync",
        description = languageService["menu_settings_description_vsync"],
        meta = {},
    }
    this.options.elements[4] = {
        text = languageService["menu_settings_antialiasing"],
        type = "bool",
        target = false,
        valueTarget = "antialiasing",
        description = languageService["menu_settings_description_antialiasing"],
        meta = {},
    }
    this.options.elements[5] = {
        text = languageService["menu_settings_display_fps"],
        type = "bool",
        target = false,
        valueTarget = "displayFPS",
        description = languageService["menu_settings_description_display_fps"],
        meta = {},
    }
    this.options.elements[6] = {
        text = languageService["menu_settings_subtitles"],
        type = "bool",
        target = false,
        valueTarget = "subtitles",
        description = languageService["menu_settings_description_subtitles"],
        meta = {},
    }
    this.options.elements[7] = {
        text = languageService["menu_settings_language"] .. " : " .. this.langFiles[SettingsSubState.currentLangID],
        type = "button",
        target = function()
            SettingsSubState.currentLangID = SettingsSubState.currentLangID + 1
            if SettingsSubState.currentLangID > #this.langFiles then
                SettingsSubState.currentLangID = 1
            end
            gameslot.save.game.user.settings.language = this.langFiles[SettingsSubState.currentLangID]
            languageService = LanguageController:getData(gameslot.save.game.user.settings.language)
            languageRaw = LanguageController:getRawData(gameslot.save.game.user.settings.language)
            SettingsSubState.rebuildUI(this)
        end,
        description = languageService["menu_settings_description_language"],
        meta = {},
    }
    this.options.elements[8] = {
        text = gamejolt.isLoggedIn and languageService["menu_settings_gamejolt_connected"] or languageService["menu_settings_gamejolt_not_connect"],
        type = "button",
        target = function()
            if gamejolt.isLoggedIn then
                gameslot.save.game.user.settings.gamejolt.usertoken = ""
                gameslot.save.game.user.settings.gamejolt.username = ""
                gamejolt.username = ""
                gamejolt.userToken = ""
                gamejolt.isLoggedIn = false
                --gamejolt.authUser("", "")
                gameslot:saveSlot()
            else
                registers.user.gamejoltUI = true
            end
            self.options.elements[7].text = gamejolt.isLoggedIn and languageService["menu_settings_gamejolt_connected"] or languageService["menu_settings_gamejolt_not_connect"] 
            SettingsSubState.rebuildUI(this)
        end,
        description = languageService["menu_settings_description_gamejolt"],
        meta = {},
    }
    this.options.elements[9] = {
        text = languageService["menu_settings_reset_settings"],
        type = "button",
        target = function()
            local defaultSettings = {
                shaders = true,
                language = "English",
                vsync = false,
                antialiasing = true,
                subtitles = true,
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
            SettingsSubState.rebuildUI(this)
        end,
        description = languageService["menu_settings_description_reset_settings"],
        meta = {},
    }

    for _, o in ipairs(this.options.elements) do
        if o.type then
            switch(o.type, {
                ["bool"] = function()
                    o.meta.hitbox = {
                        x = this.options.config.startX - math.floor(this.options.config.lpadding / 2),
                        y = this.options.config.startY + this.options.config.offsetY * _,
                        w = 48,
                        h = 48,
                    }

                    o.target = gameslot.save.game.user.settings[o.valueTarget]
                end,
                ["button"] = function()
                    o.meta.hitbox = {
                        x = (this.options.config.startX + this.options.config.lpadding) - 3,
                        y = (this.options.config.startY + (fnt_menu:getHeight() + this.options.config.padding) * _) - 3,
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

function SettingsSubState:load()
    self.active = false

    slab.Initialize({"NoDocks"})

    gamejoltUI = require 'src.Components.Modules.Game.Interface.GamejoltLoginUI'

    spr_settings = {}
    spr_settings.img, spr_settings.quads = love.graphics.getHashedQuads("assets/images/game/menu/UI/settingsUI")
    spr_arrow = love.graphics.newImage("assets/images/game/menu/UI/arrow.png")

    self.langFiles = love.filesystem.getDirectoryItems("assets/data/language")
    for l = 1, #self.langFiles, 1 do
        self.langFiles[l] = self.langFiles[l]:gsub("%.[^.]+$", "")
    end

    self.blur = 0
    self.currentLangID = 1
    
    self.options = {
        config = {
            padding = 16,
            lpadding = 42,
            startY = 96,
            startX = (love.graphics.getWidth() - 512) / 2,
            offsetY = 61,
        },
        elements = {}
    }
    
    SettingsSubState.rebuildUI(self)
end

function SettingsSubState:draw()
    if self.active then
        love.graphics.printf(languageService["menu_settings_title"], fnt_settingsTitle, 0, 69, love.graphics.getWidth(), "center")
        for _, o in ipairs(self.options.elements) do
            switch(o.type, {
                ["bool"] = function()
                    local qx, qy, qw, qh = spr_settings.quads["settingsBox"]:getViewport()
    
                    love.graphics.setColor(1, 1, 1, o.meta.alpha)
                        love.graphics.draw(spr_settings.img, spr_settings.quads["settingsBoxGlow"], o.meta.hitbox.x, self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                    love.graphics.setColor(1, 1, 1, 1)

                    if type(o.target) == "boolean" and o.target then
                        love.graphics.draw(spr_settings.img, spr_settings.quads["settingsBoxChecked"], o.meta.hitbox.x, self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                        love.graphics.draw(spr_settings.img, spr_settings.quads["checkMark"], o.meta.hitbox.x, self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                    end

                    love.graphics.draw(spr_settings.img, spr_settings.quads["settingsBox"], o.meta.hitbox.x, self.options.config.startY + self.options.config.offsetY * _, 0, 48 / qw, 48 / qh)
                    --love.graphics.print(o.text, fnt_menu, self.options.config.startX + self.options.config.lpadding, self.options.config.startY + (fnt_menu:getHeight() + self.options.config.padding) * _)
                    love.graphics.print(o.text, fnt_menu, o.meta.hitbox.x + 53, self.options.config.startY + (fnt_menu:getHeight() + self.options.config.padding) * _)
                end,
                ["button"] = function()
                    if o.meta.hovered then
                        love.graphics.setColor(0.4, 0.4, 0.4, 1)
                    else
                        love.graphics.setColor(1, 1, 1, 1)
                    end
                    love.graphics.print(o.text, fnt_menu, o.meta.hitbox.x, self.options.config.startY + (fnt_menu:getHeight() + self.options.config.padding) * _)
                    love.graphics.setColor(1, 1, 1, 1)
                end
            })

            if o.description then
                if o.meta.hovered then
                    love.graphics.printf(o.description, fnt_settingsDesc, 0, love.graphics.getHeight() - fnt_settingsDesc:getHeight() - 10, love.graphics.getWidth(), "center")
                end
            end

            love.graphics.rectangle("line", o.meta.hitbox.x, o.meta.hitbox.y, o.meta.hitbox.w, o.meta.hitbox.h)
        end

        slab.Draw()
    end
end

function SettingsSubState:update(elapsed)
    if self.active then
        self.blur = math.lerp(self.blur, 10, 0.05)
        local mx, my = love.mouse.getPosition()

        self.options.config.startX = (love.graphics.getWidth() - 512) / 2

        for _, o in ipairs(self.options.elements) do
            o.meta.hovered = collision.pointRect({ x = mx, y = my }, o.meta.hitbox)
            
            if o.meta.hovered then
                o.meta.alpha = math.lerp(o.meta.alpha, 1, 0.06)
            else
                o.meta.alpha = math.lerp(o.meta.alpha, 0, 0.06)
            end
        end

        slab.Update(elapsed)

        gamejoltUI()
    else
        self.blur = math.lerp(self.blur, 0, 0.05)
    end
    shd_blur.boxblur.radius = {self.blur, self.blur}


end

function SettingsSubState:mousepressed(x, y, button)
    if self.active then
        if not registers.user.gamejoltUI then
            for _, o in ipairs(self.options.elements) do
                if o.meta.hovered then
                    if type(o.target) == "boolean" then
                        o.target = not o.target
                        gameslot.save.game.user.settings[o.valueTarget] = o.target
                    elseif o.type == "button" then
                        o.target()
                    end
                end
            end
    
            love.window.setFullscreen(gameslot.save.game.user.settings.fullscreen, "desktop")
            love.window.setVSync(gameslot.save.game.user.settings.vsync and 1 or 0)
        
            if gameslot.save.game.user.settings.antialiasing then
                love.graphics.setDefaultFilter("linear", "linear")
            else
                love.graphics.setDefaultFilter("nearest", "nearest")
            end

            MenuState.rebuilMenuUI()
            MenuState.rebuildShader()
            gameslot:saveSlot()
        end
    end
end

function SettingsSubState:resize(w, h)
    SettingsSubState.rebuildUI(self)
end

return SettingsSubState