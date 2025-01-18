return function()
    if registers.user.gamejoltUI then
        slab.BeginWindow("gamejoltLoginWindow", { Title = "Login to gamejolt", AllowResize = false })
            slab.Text(languageService["menu_settings_gamejolt_username"])
            if slab.Input("gamejoltLoginUsernameInput", {Text = gameslot.save.game.user.settings.gamejolt.username}) then
                gameslot.save.game.user.settings.gamejolt.username = slab.GetInputText()
            end
            slab.Text(languageService["menu_settings_gamejolt_token"])
            if slab.Input("gamejoltLoginUsertokenInput", {Text = gameslot.save.game.user.settings.gamejolt.usertoken}) then
                gameslot.save.game.user.settings.gamejolt.usertoken = slab.GetInputText()
            end
            if slab.Button(languageService["menu_settings_gamejolt_button_clear"]) then
                gameslot.save.game.user.settings.gamejolt.usertoken = ""
                gameslot.save.game.user.settings.gamejolt.username = ""
            end
            slab.SameLine()
            if slab.Button(languageService["menu_settings_gamejolt_button_cancel"]) then
                gameslot.save.game.user.settings.gamejolt.usertoken = ""
                gameslot.save.game.user.settings.gamejolt.username = ""
                registers.user.gamejoltUI = false
            end
            slab.SameLine()
            if slab.Button(languageService["menu_settings_gamejolt_button_connect"]) then
                if gameslot.save.game.user.settings.gamejolt.username ~= "" and gameslot.save.game.user.settings.gamejolt.usertoken ~= "" then
                    _connectGJ()
                    if gamejolt.isLoggedIn then
                        gameslot:saveSlot()
                        registers.user.gamejoltUI = false
                    else
                        slab.Text(languageService["menu_settings_gamejolt_error"])
                    end
                end
            end
        slab.EndWindow()
    end
end