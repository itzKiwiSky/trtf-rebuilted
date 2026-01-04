return function(settings)
    local lfskin = settings.skin
    local settingsController = settings.settingsController
    return {
        function(grid)
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_audio_master"])

            local masterVolSlider = loveframes.Create("slider")
            masterVolSlider:SetPos(5, 30)
            masterVolSlider:SetWidth(164)
            masterVolSlider:SetMinMax(0, 100)
            masterVolSlider:SetValue(settingsController.virtualSettings.audio.masterVolume)
            masterVolSlider.OnValueChanged = function(obj, value)
                settingsController.virtualSettings.audio.masterVolume = math.floor(value)
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(masterVolSlider, 1, 13, "left")
        end,
    }
end
