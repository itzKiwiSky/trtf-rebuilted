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
            optionTitle.Update = function(obj)
                obj:SetText(languageService["menu_settings_misc_language"])
            end

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
        end,
    }
end
