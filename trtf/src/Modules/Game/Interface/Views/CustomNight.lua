local settings = {
    lpadding = 16,
    blank = function()end,
    fonts = {
        title = fontcache.getFont("tnr", 50),
        btnfont = fontcache.getFont("tnr", 26),
        subtitleFont = fontcache.getFont("tnr", 32),
        optionFont = fontcache.getFont("tnr", 34),
        mainButtons = fontcache.getFont("tnr", 18),
        multi = fontcache.getFont("tnr", 20)
    },
    states = { "video", "audio", "misc" },
}

return function()
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

    local portraitIcons = {}
    local icfls = love.filesystem.getDirectoryItems("assets/images/game/night/cn_icons")
    for c = 1, #icfls, 1 do
        local name = icfls[c]:gsub("%.[^.]+$", "")
        if name ~= "dummy" then
            table.insert(portraitIcons, {
                img = love.graphics.newImage("assets/images/game/night/cn_icons/" .. icfls[c]),
                name = name,
            })
        end
    end

    settings.skin = lfskin

    local panelSkin = function(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local w = object:GetWidth()
        local h = object:GetHeight()

        love.graphics.setColor(skin.controls.color_fore2)
        love.graphics.rectangle("fill", x, y, w, h)
        
        love.graphics.setColor(skin.controls.color_fore0)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x, y, w, h)
        love.graphics.setLineWidth(1)
    end

    local window = loveframes.Create("panel")
    window:SetSize(love.resconf.width, love.resconf.height)
    window.drawfunc = settings.blank

    local title = loveframes.Create("text")
    title:SetText(languageService["custom_night_menu_title"])
    title:SetY(32)
    title:SetDefaultColor(1, 1, 1, 1)
    title:SetFont(settings.fonts.title)
    title:CenterX()

    local ptgrid = loveframes.Create("grid")
    ptgrid:SetColumns(4)
end