return function(settings)
    local lfskin = settings.skin 
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
            masterVolSlider:SetValue(registers.user.virtualSettings.audio.masterVolume)
            masterVolSlider.OnValueChanged = function(obj, value)
                registers.user.virtualSettings.audio.masterVolume = math.floor(value)
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(masterVolSlider, 1, 13, "left")
        end,
        function(grid)
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_audio_music"])

            local musicVolSlider = loveframes.Create("slider")
            musicVolSlider:SetPos(5, 30)
            musicVolSlider:SetWidth(164)
            musicVolSlider:SetMinMax(0, 100)
            musicVolSlider:SetValue(registers.user.virtualSettings.audio.musicVolume)
            musicVolSlider.OnValueChanged = function(obj, value)
                registers.user.virtualSettings.audio.musicVolume = math.floor(value)
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(musicVolSlider, 1, 13, "left")
        end,
        function(grid)
            local optionTitle = loveframes.Create("text")
            optionTitle:SetDefaultColor(1, 1, 1, 1)
            optionTitle:SetFont(settings.fonts.optionFont)
            optionTitle:SetText(languageService["menu_settings_audio_sfx"])

            local sfxVolSlider = loveframes.Create("slider")
            sfxVolSlider:SetPos(5, 30)
            sfxVolSlider:SetWidth(164)
            sfxVolSlider:SetMinMax(0, 100)
            sfxVolSlider:SetValue(registers.user.virtualSettings.audio.sfxVolume)
            sfxVolSlider.OnValueChanged = function(obj, value)
                registers.user.virtualSettings.audio.sfxVolume = math.floor(value)
            end

            grid:AddItem(optionTitle, 1, 1, "left")
            grid:AddItem(sfxVolSlider, 1, 13, "left")
        end
    }
end