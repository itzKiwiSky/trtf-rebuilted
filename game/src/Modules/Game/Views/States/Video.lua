return function(settings)
    local lfskin = settings.skin
    local settingsController = settings.settingsController
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
            local curRes = love.window.resolutionModes[settingsController.virtualSettings.video.winsize]
            resmultichoice:SetChoice(string.format("%s x %s", curRes.width, curRes.height))

            resmultichoice.OnChoiceSelected = function(object, choice)
                settingsController.virtualSettings.video.winsize = resmultichoice:GetChoiceIndex()
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
            choiceButton:SetText(settingsController.virtualSettings.video.fullscreen and languageService["menu_settings_buttons_modes_fullscreen"] or languageService["menu_settings_buttons_modes_windowed"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                settingsController.virtualSettings.video.fullscreen = not settingsController.virtualSettings.video.fullscreen
                choiceButton:SetText(settingsController.virtualSettings.video.fullscreen and languageService["menu_settings_buttons_modes_fullscreen"] or languageService["menu_settings_buttons_modes_windowed"])
                -- change this value to avoid the game to re-create the window even if you change the volume --
                registers.user.videoSettingsChanged = true
            end

            choiceButton.Update(function(obj, elapsed)
                obj:SetText(settingsController.virtualSettings.video.fullscreen and languageService["menu_settings_buttons_modes_fullscreen"] or languageService["menu_settings_buttons_modes_windowed"])
            end)

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
            choiceButton:SetText(settingsController.virtualSettings.video.vsync and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                --settingsController.virtualSettings.video.vsync = not settingsController.virtualSettings.video.vsync
                settingsController.virtualSettings.video.vsync = not settingsController.virtualSettings.video.vsync
                choiceButton:SetText(settingsController.virtualSettings.video.vsync and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
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
            numberFPS:SetValue(settingsController.virtualSettings.video.fpsCap)
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
                --settingsController.virtualSettings.video.fpsCap = value
                settingsController.virtualSettings.video.fpsCap = value
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
            choiceButton:SetText(settingsController.virtualSettings.video.displayFPS and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                settingsController.virtualSettings.video.displayFPS = not settingsController.virtualSettings.video.displayFPS
                choiceButton:SetText(settingsController.virtualSettings.video.displayFPS and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
        function(grid)
            -- Antialiasing --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText("Lock cursor on window")

            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(settingsController.virtualSettings.misc.lockCursor and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                settingsController.virtualSettings.misc.lockCursor = not settingsController.virtualSettings.misc.lockCursor
                choiceButton:SetText(settingsController.virtualSettings.misc.lockCursor and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,
        --[[
        [X] - Resolution
        [X] - Mode [Fullscreen, Windowed]
        [X] - V-Sync
        [X] - FPSCap
    ]]
    }
end
