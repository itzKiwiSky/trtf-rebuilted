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
                resmultichoice:AddChoice(string.format("%s x %s", res.width, res.height))
            end
    
            -- set UI to current value state --
            local curRes = love.window.resolutionModes[registers.user.virtualSettings.video.winsize]
            resmultichoice:SetChoice(string.format("%s x %s", curRes.width, curRes.height))
    
            resmultichoice.OnChoiceSelected = function(object, choice)
                registers.user.virtualSettings.video.winsize = resmultichoice:GetChoiceIndex()
                registers.user.videoSettingsChanged = true
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
                -- change this value to avoid the game to re-create the window even if you change the volume --
                registers.user.videoSettingsChanged = true
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

                -- change this value to avoid the game to re-create the window even if you change the volume --
                registers.user.videoSettingsChanged = true
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
            -- FPS Display  --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_display_fps"])
    
            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(registers.user.virtualSettings.video.displayFPS and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                registers.user.virtualSettings.video.displayFPS = not registers.user.virtualSettings.video.displayFPS
                choiceButton:SetText(registers.user.virtualSettings.video.displayFPS and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
        function(grid)
            -- filter --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_filter"])
    
            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(registers.user.virtualSettings.video.aspectRatio and languageService["menu_settings_buttons_modes_filter_nearest"] or languageService["menu_settings_buttons_modes_filter_linear"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                registers.user.virtualSettings.video.aspectRatio = not registers.user.virtualSettings.video.aspectRatio
                choiceButton:SetText(registers.user.virtualSettings.video.aspectRatio and languageService["menu_settings_buttons_modes_filter_nearest"] or languageService["menu_settings_buttons_modes_filter_linear"])
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
        function(grid)
            -- effect controller
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_video_effect_density"])
    
            local resmultichoice = loveframes.Create("multichoice")
            resmultichoice:SetPadding(5)

            local ogMulChDraw = resmultichoice.drawfunc
            resmultichoice.drawfunc = function(objx)
                objx:GetSkin().controls.smallfont = settings.fonts.multi
                ogMulChDraw(objx)
            end
    
            resmultichoice:SetHeight(38)
            resmultichoice:Clear()
            local c = {
                REQUIRED_EFFECTS = "menu_settings_buttons_modes_effect_density_max",
                MIN_EFFECTS = "menu_settings_buttons_modes_effect_density_min",
                MAX_EFFECTS = "menu_settings_buttons_modes_effect_density_required",
            }
            for fx in spairs(EFFECT_DENSITY) do
                resmultichoice:AddChoice(languageService[c[fx]])
            end
    
            -- set UI to current value state --
            --local curRes = love.window.resolutionModes[registers.user.virtualSettings.video.resolution]
            resmultichoice:SetChoice(registers.user.virtualSettings.video.effectDensity)
    
            resmultichoice.OnChoiceSelected = function(object, choice)
                registers.user.virtualSettings.video.effectDensity = resmultichoice:GetChoiceIndex()
            end
    
            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(resmultichoice, 1, 12, "left")
        end,

    --[[
        [X] - Resolution
        [X] - Mode [Fullscreen, Windowed]
        [X] - V-Sync
        [X] - FPSCap
    ]]
    }
end