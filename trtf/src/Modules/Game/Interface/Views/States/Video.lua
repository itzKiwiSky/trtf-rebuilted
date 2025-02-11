return function(settings)
    local lfskin = settings.skin
    return {
        state = "video",
        function(grid)
            -- resolution controller
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_resolution"])
    
            local resmultichoice = loveframes.Create("multichoice")
            resmultichoice:SetPadding(5)
            local ogMulChDraw = resmultichoice.drawfunc
            resmultichoice.drawfunc = function(objx)
                objx:GetSkin().controls.smallfont = settings.fonts.multi
                ogMulChDraw(objx)
            end
    
            resmultichoice:SetHeight(38)
            resmultichoice:Clear()
            for _, res in ipairs(love.window.resolutionModes) do
                resmultichoice:AddChoice(string.format("%s x %s", res[1], res[2]))
            end
    
            -- set UI to current value state --
            local curRes = love.window.resolutionModes[registers.user.virtualSettings.video.resolution]
            resmultichoice:SetChoice(string.format("%s x %s", curRes[1], curRes[2]))
    
            resmultichoice.OnChoiceSelected = function(object, choice)
                registers.user.virtualSettings.video.resolution = resmultichoice:GetChoiceIndex()
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(resmultichoice, 1, 12, "left")
        end,
        function(grid)
            -- mode --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_fullscreen"])
    
            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(registers.user.virtualSettings.video.fullscreen and languageService["menu_settings_buttons_modes_fullscreen"] or languageService["menu_settings_buttons_modes_windowed"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                registers.user.virtualSettings.video.fullscreen = not registers.user.virtualSettings.video.fullscreen
                choiceButton:SetText(registers.user.virtualSettings.video.fullscreen and languageService["menu_settings_buttons_modes_fullscreen"] or languageService["menu_settings_buttons_modes_windowed"])
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
        function(grid)
            -- vsync --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_vsync"])
    
            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(registers.user.virtualSettings.video.vsync and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                registers.user.virtualSettings.video.vsync = not registers.user.virtualSettings.video.vsync
                choiceButton:SetText(registers.user.virtualSettings.video.vsync and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
    
        function(grid)
            -- FFPS Cap --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_fpsCap"])
    
            local numberFPS = loveframes.Create("numberbox")
            numberFPS:SetIncreaseAmount(4)
            numberFPS:SetDecreaseAmount(4)
            numberFPS:SetMinMax(20, 1000)
            numberFPS:SetSize(128, 38)
            numberFPS:SetValue(registers.user.virtualSettings.video.fpsCap)
            local numFPSDraw = numberFPS.internals[1].drawfunc
            numberFPS.internals[1].drawfunc = function(objy)
                objy.font = settings.fonts.multi
                --obj
                objy:GetSkin().controls.color_back0 = lfskin.controls.color_back2
                numFPSDraw(objy)
            end
    
            --print(debug.formattable(numberFPS.internals[1], 1, false))
            numberFPS.OnValueChanged = function(object, value)
                --print("The object's new value is " ..value)
                registers.user.virtualSettings.video.fpsCap = value
            end
    
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(numberFPS, 1, 14, "left")
        end,
    
        function(grid)
            -- aspectRatio --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_aspectRatio"])
    
            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(registers.user.virtualSettings.video.aspectRatio and languageService["menu_settings_buttons_modes_aspect_streched"] or languageService["menu_settings_buttons_modes_aspect_proportional"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                registers.user.virtualSettings.video.aspectRatio = not registers.user.virtualSettings.video.aspectRatio
                choiceButton:SetText(registers.user.virtualSettings.video.aspectRatio and languageService["menu_settings_buttons_modes_aspect_streched"] or languageService["menu_settings_buttons_modes_aspect_proportional"])
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
    
        function(grid)
            -- Antialiasing --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_antialiasing"])
    
            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(registers.user.virtualSettings.video.antialiasing and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                registers.user.virtualSettings.video.antialiasing = not registers.user.virtualSettings.video.antialiasing
                choiceButton:SetText(registers.user.virtualSettings.video.antialiasing and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
    
    --[[
        [X] - Resolution
        [X] - Mode [Fullscreen, Windowed]
        [X] - V-Sync
        [X] - Aspect ratio
        [X] - FPSCap
        [X] - Antialiasing
    ]]
    }
end