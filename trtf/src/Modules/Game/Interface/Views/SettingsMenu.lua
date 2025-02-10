local settings = {
    lpadding = 16,
    blank = function()end,
    replaces = {
        button = require 'trtf.src.Modules.Game.Interface.Replaces.Button'
    },
    fonts = {
        title = fontcache.getFont("tnr", 50),
        btnfont = fontcache.getFont("tnr", 26),
        subtitleFont = fontcache.getFont("tnr", 32),
        optionFont = fontcache.getFont("tnr", 34),
        mainButtons = fontcache.getFont("tnr", 18),
        multi = fontcache.getFont("tnr", 20)
    },
    states = { "video", "audio", "misc" },
}

return function()
    local lfskin = loveframes.GetActiveSkin()

    lfskin.controls = {}
    lfskin.controls.smallfont = love.graphics.newFont(11)
    lfskin.controls.imagebuttonfont = love.graphics.newFont(15)
    lfskin.controls.color_image  = {lume.color("#FFFFFF")}
    lfskin.controls.color_back0  = {lume.color("#bcbce4")}
    lfskin.controls.color_back1  = {lume.color("#7a8bc9")}
    lfskin.controls.color_back2  = {lume.color("#4b39a1")}
    lfskin.controls.color_back3  = {lume.color("#5c6eaf")}
    lfskin.controls.color_fore0  = {lume.color("#9d8cf1")}
    lfskin.controls.color_fore1  = {lume.color("#4f467d")}
    lfskin.controls.color_fore2  = {lume.color("#3a3167")}
    lfskin.controls.color_fore3  = {lume.color("#2c2359")}
    lfskin.controls.color_active = {lume.color("#1c1c56")}

    local panelSkin = function(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local w = object:GetWidth()
        local h = object:GetHeight()

        love.graphics.setColor(skin.controls.color_fore2)
        love.graphics.rectangle("fill", x, y, w, h)
        
        love.graphics.setColor(skin.controls.color_fore0)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x, y, w, h)
        love.graphics.setLineWidth(1)
    end

    local window = loveframes.Create("panel")
    window:SetSize(love.resconf.width, love.resconf.height)
    window.drawfunc = settings.blank

    local optionPanel = loveframes.Create("panel")
    optionPanel:SetSize(love.resconf.width / 2, love.resconf.height / 2 + 50)
    optionPanel:CenterX()
    optionPanel:SetY(love.resconf.height / 2 - 100)
    optionPanel:SetAlwaysUpdate(true)
    optionPanel.drawfunc = panelSkin

    local SettingsMenu = {
        ["video"] = function()
            local mainList = loveframes.Create("list")
            mainList:SetParent(optionPanel)
            mainList.drawfunc = function(object)
                local skin = object:GetSkin()
                local x = object:GetX()
                local y = object:GetY()
                local w = object:GetWidth()
                local h = object:GetHeight()

                love.graphics.setColor(0, 0, 0, 0.4)
                love.graphics.rectangle("fill", x, y, w, h)
            end

            mainList.drawoverfunc = function(object)
                local skin = object:GetSkin()
                local x = object:GetX()
                local y = object:GetY()
                local w = object:GetWidth()
                local h = object:GetHeight()

                love.graphics.setColor(skin.controls.color_fore0)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", x, y, w, h)
                love.graphics.setLineWidth(1)
            end

            mainList:SetRetainSize(true)
            mainList:SetSpacing(16)
            mainList:SetPadding(8)
            mainList:SetSize(optionPanel:GetWidth() - 16, optionPanel:GetHeight() - 16)
            mainList:Center()
            mainList:SetAlwaysUpdate(true)
            mainList:SetMouseWheelScrollAmount(6)



            for i = 1, #options, 1 do
                local itemGrid = loveframes.Create("grid")
                itemGrid:SetWidth(mainList:GetWidth() - 8)
                itemGrid:SetHeight(32)
                itemGrid:SetRows(1)
                itemGrid:SetCellWidth(26)
                itemGrid:SetColumns(mainList:GetWidth() / itemGrid:GetCellWidth() - 8)
                itemGrid:SetCellHeight(32)
                itemGrid:SetItemAutoSize(false)
                itemGrid:SetAlwaysUpdate(true)
                itemGrid.drawfunc = settings.blank
                options[i](itemGrid)

                mainList:CalculateSize()
                mainList:RedoLayout()
                mainList:AddItem(itemGrid)
            end
        end,
        ["audio"] = function()
            local mainList = loveframes.Create("list")
            mainList:SetParent(optionPanel)
            mainList.drawfunc = function(object)
                local skin = object:GetSkin()
                local x = object:GetX()
                local y = object:GetY()
                local w = object:GetWidth()
                local h = object:GetHeight()

                love.graphics.setColor(0, 0, 0, 0.4)
                love.graphics.rectangle("fill", x, y, w, h)
            end

            mainList.drawoverfunc = function(object)
                local skin = object:GetSkin()
                local x = object:GetX()
                local y = object:GetY()
                local w = object:GetWidth()
                local h = object:GetHeight()

                love.graphics.setColor(skin.controls.color_fore0)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", x, y, w, h)
                love.graphics.setLineWidth(1)
            end

            mainList:SetRetainSize(true)
            mainList:SetSpacing(16)
            mainList:SetPadding(8)
            mainList:SetSize(optionPanel:GetWidth() - 16, optionPanel:GetHeight() - 16)
            mainList:Center()
            mainList:SetAlwaysUpdate(true)
            mainList:SetMouseWheelScrollAmount(6)

            local options = {}
            
            for i = 1, #options, 1 do
                local itemGrid = loveframes.Create("grid")
                itemGrid:SetWidth(mainList:GetWidth() - 8)
                itemGrid:SetHeight(32)
                itemGrid:SetRows(1)
                itemGrid:SetCellWidth(26)
                itemGrid:SetColumns(mainList:GetWidth() / itemGrid:GetCellWidth() - 8)
                itemGrid:SetCellHeight(32)
                itemGrid:SetItemAutoSize(false)
                itemGrid:SetAlwaysUpdate(true)
                itemGrid.drawfunc = settings.blank
                options[i](itemGrid)

                mainList:CalculateSize()
                mainList:RedoLayout()
                mainList:AddItem(itemGrid)
            end
        end,
        ["misc"] = function()
            local mainList = loveframes.Create("list")
            mainList:SetParent(optionPanel)
            mainList.drawfunc = function(object)
                local skin = object:GetSkin()
                local x = object:GetX()
                local y = object:GetY()
                local w = object:GetWidth()
                local h = object:GetHeight()

                love.graphics.setColor(0, 0, 0, 0.4)
                love.graphics.rectangle("fill", x, y, w, h)
            end

            mainList.drawoverfunc = function(object)
                local skin = object:GetSkin()
                local x = object:GetX()
                local y = object:GetY()
                local w = object:GetWidth()
                local h = object:GetHeight()

                love.graphics.setColor(skin.controls.color_fore0)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", x, y, w, h)
                love.graphics.setLineWidth(1)
            end

            mainList:SetRetainSize(true)
            mainList:SetSpacing(16)
            mainList:SetPadding(8)
            mainList:SetSize(optionPanel:GetWidth() - 16, optionPanel:GetHeight() - 16)
            mainList:Center()
            mainList:SetAlwaysUpdate(true)
            mainList:SetMouseWheelScrollAmount(6)

            local options = {}
            
            for i = 1, #options, 1 do
                local itemGrid = loveframes.Create("grid")
                itemGrid:SetWidth(mainList:GetWidth() - 8)
                itemGrid:SetHeight(32)
                itemGrid:SetRows(1)
                itemGrid:SetCellWidth(26)
                itemGrid:SetColumns(mainList:GetWidth() / itemGrid:GetCellWidth() - 8)
                itemGrid:SetCellHeight(32)
                itemGrid:SetItemAutoSize(false)
                itemGrid:SetAlwaysUpdate(true)
                itemGrid.drawfunc = settings.blank
                options[i](itemGrid)

                mainList:CalculateSize()
                mainList:RedoLayout()
                mainList:AddItem(itemGrid)
            end
        end,
    }


    local txt = loveframes.Create("text")
    txt:SetDefaultColor(1, 1, 1, 1)
    txt:SetFont(settings.fonts.title)
    txt:SetParent(window)
    txt:SetY(20)
    txt:SetText(languageService["menu_settings_title"])
    txt:CenterX()

    local subtxt = loveframes.Create("text")
    subtxt:SetDefaultColor(1, 1, 1, 1)
    subtxt:SetFont(settings.fonts.subtitleFont)
    subtxt:SetParent(window)
    subtxt:SetY(130)
    subtxt:SetAlwaysUpdate(true)
    subtxt:SetText(languageService["menu_settings_categories_subtext_" .. registers.user.currentSettingsTab])
    subtxt:CenterX()

    local buttonCol = loveframes.Create("grid")
    buttonCol:SetParent(window)
    buttonCol:SetY(180)
    buttonCol:SetWidth(love.resconf.width / 2)
    buttonCol:SetHeight(64)
    buttonCol:SetRows(1)
    buttonCol:SetColumns(#settings.states)
    buttonCol:SetCellWidth(128)
    buttonCol:SetCellHeight(64)
    buttonCol:SetCellPadding(32)
    buttonCol:SetItemAutoSize(true)
    buttonCol:SetX(love.resconf.width / 2 - buttonCol:GetWidth() / 2 + buttonCol:GetCellPadding())
    buttonCol.drawfunc = settings["blank"]

    for b = 1, #settings.states, 1 do
        local btn = loveframes.Create("button")
        buttonCol:AddItem(btn, 1, b, "center")
        btn:SetFont(settings.fonts["btnfont"])
        btn:SetText(languageService["menu_settings_categories_" .. settings.states[b]])

        btn.OnClick = function()
            local objs = optionPanel:GetChildren()
            for _, o in ipairs(objs) do
                o:Remove()
            end
            SettingsMenu[settings.states[b]]()
            registers.user.currentSettingsTab = settings.states[b]
            subtxt:SetText(languageService["menu_settings_categories_subtext_" .. registers.user.currentSettingsTab])
            subtxt:CenterX()
        end
    end
    SettingsMenu["video"]()

    local exitButton = loveframes.Create("button")
    exitButton:SetSize(96, 48)
    exitButton:SetText(languageService["menu_settings_buttons_exit"])
    exitButton:SetFont(settings.fonts["mainButtons"])
    exitButton:SetPos(settings.lpadding, love.resconf.height - (exitButton:GetHeight() + settings.lpadding))
    exitButton.OnClick = function(obj)
        MenuState.configMenu = false
    end

    local saveButton = loveframes.Create("button")
    saveButton:SetSize(148, 48)
    saveButton:SetText(languageService["menu_settings_buttons_save"])
    saveButton:SetFont(settings.fonts["mainButtons"])
    saveButton:SetPos((exitButton:GetX() + exitButton:GetWidth()) + settings.lpadding, love.resconf.height - (saveButton:GetHeight() + settings.lpadding))
    saveButton.OnClick = function(obj)

    end
end