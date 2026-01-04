local connectGJModal = require 'src.Modules.Game.Views.States.ConnectGJModal'
local languageManager = require 'src.Modules.System.Utils.LanguageManager'

return function(settings)
    local lfskin = settings.skin
    local settingsController = settings.settingsController
    return {
        function(grid)
            -- resolution controller
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_misc_language"])

            local resmultichoice = loveframes.Create("multichoice")
            resmultichoice:SetPadding(5)

            local ogMulChDraw = resmultichoice.drawfunc
            resmultichoice.drawfunc = function(objx)
                objx:GetSkin().controls.smallfont = settings.fonts.multi
                ogMulChDraw(objx)
            end

            resmultichoice:SetHeight(38)
            resmultichoice:Clear()
            local langFiles = love.filesystem.getDirectoryItems("assets/data/language")
            for _, lang in ipairs(langFiles) do
                if lang:match("%.json$") then
                    resmultichoice:AddChoice(lang:gsub("%.[^.]+$", ""))
                end
            end

            -- set UI to current value state --
            local curRes = love.window.resolutionModes[settingsController.virtualSettings.video.resolution]
            resmultichoice:SetChoice(settingsController.virtualSettings.misc.language)

            resmultichoice.OnChoiceSelected = function(object, choice)
                settingsController.virtualSettings.misc.language = resmultichoice:GetValue()
                languageService = languageManager.getData(gameSave.save.user.settings.misc.language)
                languageRaw = languageManager.getRawData(gameSave.save.user.settings.misc.language)
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(resmultichoice, 1, 12, "left")
        end, --[[
        function(grid)
            -- Antialiasing --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_misc_discordrpc"])

            local choiceButton = loveframes.Create("button")
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(settingsController.virtualSettings.misc.discordRichPresence and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.OnClick = function(obj)
                settingsController.virtualSettings.misc.discordRichPresence = not settingsController.virtualSettings.misc.discordRichPresence
                choiceButton:SetText(settingsController.virtualSettings.misc.discordRichPresence and languageService["menu_settings_buttons_modes_turn_on"] or languageService["menu_settings_buttons_modes_turn_off"])
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end,]] --
        --[[function(grid)
            -- Antialiasing --
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_misc_gamejolt_title"])

            local choiceButton = loveframes.Create("button")
            choiceButton:SetAlwaysUpdate(true)
            choiceButton:SetSize(128, 38)
            choiceButton:SetText(gamejolt.isLoggedIn and languageService["menu_settings_misc_gamejolt_connected"] or languageService["menu_settings_misc_gamejolt_not_connected"])
            choiceButton:SetFont(settings.fonts["mainButtons"])
            choiceButton.Update = function(obj, elapsed)
                print(tostring(gamejolt.isLoggedIn) .. "is connect")
                obj:SetText(gamejolt.isLoggedIn and languageService["menu_settings_misc_gamejolt_connected"] or languageService["menu_settings_misc_gamejolt_not_connected"])
            end
            choiceButton.OnClick = function(obj)
                if not gamejolt.isLoggedIn then
                    print("lets connect this bitch")
                    if not registers.isConnectWindowOpen then
                        connectGJModal.open()
                        registers.isConnectWindowOpen = true
                    else
                        connectGJModal.close()
                        registers.isConnectWindowOpen = false
                    end
                else
                    gameSave.save.user.settings.misc.gamejolt.username = ""
                    gameSave.save.user.settings.misc.gamejolt.usertoken = ""
                    gamejolt.closeSession()
                    gameSave:saveSlot()
                end
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(choiceButton, 1, 14, "left")
        end]]
    }
end
