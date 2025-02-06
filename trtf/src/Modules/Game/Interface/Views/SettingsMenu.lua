return function()
    local settings = {
        lpadding = 16,
        blank = function()end,
        replaces = {
            button = require 'trtf.src.Modules.Game.Interface.Replaces.Button'
        },
        fonts = {
            title = fontcache.getFont("tnr", 50),
            btnfont = fontcache.getFont("tnr", 26)
        },
        statesName = { "video", "audio", "misc" }
    }

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


    local window = loveframes.Create("panel")
    window:SetSize(love.resconf.width, love.resconf.height)
    window.drawfunc = settings.blank

    local txt = loveframes.Create("text")
    txt:SetDefaultColor(1, 1, 1, 1)
    txt:SetFont(settings.fonts.title)
    txt:SetParent(window)
    txt:SetPos(20, 20)
    txt:SetText(languageService["menu_settings_title"])
    txt:CenterX()

    local buttonCol = loveframes.Create("grid")
    buttonCol:SetParent(window)
    buttonCol:SetY(120)
    buttonCol:SetWidth(love.resconf.width / 2)
    buttonCol:SetHeight(64)
    buttonCol:SetRows(1)
    buttonCol:SetColumns(#settings.statesName)
    buttonCol:SetCellWidth(128)
    buttonCol:SetCellHeight(64)
    buttonCol:SetCellPadding(32)
    buttonCol:SetItemAutoSize(true)
    buttonCol:SetX(love.resconf.width / 2 - buttonCol:GetWidth() / 2 + buttonCol:GetCellPadding())
    buttonCol.drawfunc = settings["blank"]
    
    for b = 1, #settings.statesName, 1 do
        local btn = loveframes.Create("button")
        buttonCol:AddItem(btn, 1, b, "center")
        btn:SetFont(settings.fonts["btnfont"])
        btn:SetText(languageService["menu_settings_categories_" .. settings.statesName[b]])
        --btn.drawfunc = settings.replaces["button"]
    end
end