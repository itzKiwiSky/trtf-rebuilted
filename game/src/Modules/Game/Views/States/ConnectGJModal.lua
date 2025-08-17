local connectGJ = require 'src.Modules.System.InitializeAPI'
local settings = {--
    lpadding = 8,
    blank = function()end,
    fonts = {
        title = fontcache.getFont("tnr", 50),
        btnfont = fontcache.getFont("tnr", 26),
        subtitleFont = fontcache.getFont("tnr", 32),
        optionFont = fontcache.getFont("tnr", 34),
        mainButtons = fontcache.getFont("tnr", 18),
        multi = fontcache.getFont("tnr", 20),
        small = fontcache.getFont("tnr", 11),
        big = fontcache.getFont("tnr", 16),
    },
}

local Modal = {}

function Modal.open()
    local lfskin = loveframes.GetActiveSkin()

    lfskin.controls = {}
    lfskin.controls.smallfont = settings.fonts.small
    lfskin.controls.imagebuttonfont = settings.fonts.big
    lfskin.controls.color_image  = {lume.color("#FFFFFF")}
    lfskin.controls.color_back0  = {lume.color("#bcbce4")}
    lfskin.controls.color_back1  = {lume.color("#7a8bc9")}
    lfskin.controls.color_back2  = {lume.color("#4b39a1")}
    lfskin.controls.color_back3  = {lume.color("#5c6eaf")}
    lfskin.controls.color_fore0  = {lume.color("#9d8cf1")}
    lfskin.controls.color_fore1  = {lume.color("#4f467d")}
    lfskin.controls.color_fore2  = {lume.color("#3a3167")}
    lfskin.controls.color_fore3  = {lume.color("#2c2359")}
    lfskin.controls.color_active = {lume.color("#141436")}

    settings.skin = lfskin

    Modal.win = loveframes.Create("frame")
    Modal.win:SetSize(480, 140)
    Modal.win:CenterWithinArea(0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    local username = loveframes.Create("text", Modal.win)
    username:SetFont(settings.fonts.big)
    username:SetText(languageService["menu_settings_gamejolt_username"])
    username:SetPos(settings.lpadding, 35)

    local usernameInput = loveframes.Create("textinput", Modal.win)
    usernameInput:SetFont(settings.fonts.big)
    usernameInput:SetPos(125, 30)
    usernameInput:SetWidth(320)

    local token = loveframes.Create("text", Modal.win)
    token:SetFont(settings.fonts.big)
    token:SetText(languageService["menu_settings_gamejolt_token"])
    token:SetPos(settings.lpadding, 65)

    local tokenInput = loveframes.Create("textinput", Modal.win)
    tokenInput:SetFont(settings.fonts.big)
    tokenInput:SetPos(125, 65)
    tokenInput:SetWidth(320)

    local btnGrid = loveframes.Create("grid", Modal.win)
    btnGrid:SetPos(24, Modal.win:GetHeight() - 48)
    btnGrid:SetRows(1)
    btnGrid:SetColumns(8)
    btnGrid:SetCellPadding(14)
    btnGrid.drawfunc = settings.blank

    local cancelButton = loveframes.Create("button", Modal.win)
    cancelButton:SetWidth(120)
    cancelButton:SetHeight(32)
    cancelButton:SetText(languageService["menu_settings_gamejolt_button_cancel"])
    cancelButton.OnClick = function()
        usernameInput:Clear()
        tokenInput:Clear()
        Modal.close()
        registers.isConnectWindowOpen = false
    end

    local connectButton = loveframes.Create("button", Modal.win)
    connectButton:SetWidth(120)
    connectButton:SetHeight(32)
    connectButton:SetText(languageService["menu_settings_gamejolt_button_connect"])
    connectButton.OnClick = function()
        gameSave.save.user.settings.misc.gamejolt.username = usernameInput:GetValue()
        gameSave.save.user.settings.misc.gamejolt.usertoken = tokenInput:GetValue()

        local GJPing = love.thread.newThread("src/Modules/Game/Utils/ThreadPing.lua")

        GJPing:start(
            gameSave.save.user.settings.misc.gamejolt.username,
            gameSave.save.user.settings.misc.gamejolt.usertoken
        )

        gameSave:saveSlot()

        Modal.close()
        registers.isConnectWindowOpen = false
    end
    btnGrid:AddItem(cancelButton, 1, 2, "center")
    btnGrid:AddItem(connectButton, 1, 7, "center")

    Modal.win.OnClose = function(obj)
        usernameInput:Clear()
        tokenInput:Clear()
        Modal.close()
        registers.isConnectWindowOpen = false
    end
end

function Modal.close()
    Modal.win:Remove()
end

return Modal