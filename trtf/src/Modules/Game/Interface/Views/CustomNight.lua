local settings = {
    lpadding = 32,
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

    local portraitIcons = {
        ["bonnie"] = {
            img = love.graphics.newImage("assets/images/game/night/cn_icons/bonnie.png"),
            color = { lume.color("#545ec1") },
        },
        ["chica"] = {
            img = love.graphics.newImage("assets/images/game/night/cn_icons/chica.png"),
            color = { lume.color("#e7bc2e") },
        },
        ["foxy"] = {
            img = love.graphics.newImage("assets/images/game/night/cn_icons/foxy.png"),
            color = { lume.color("#d04f37") },
        },
        ["freddy"] = {
            img = love.graphics.newImage("assets/images/game/night/cn_icons/freddy.png"),
            color = { lume.color("#662b20") },
        },
        ["kitty"] = {
            img = love.graphics.newImage("assets/images/game/night/cn_icons/kitty.png"),
            color = { lume.color("#ec619e") },
        },
        ["puppet"] = {
            img = love.graphics.newImage("assets/images/game/night/cn_icons/puppet.png"),
            color = { lume.color("#ccdece") },
        },
        ["sugar"] = {
            img = love.graphics.newImage("assets/images/game/night/cn_icons/sugar.png"),
            color = { lume.color("#a74fca") },
        },
    }

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
    ptgrid:SetRows(2)
    ptgrid:SetColumns(4)
    ptgrid:SetItemAutoSize(false)
    ptgrid:SetCellPadding(96)
    ptgrid.drawfunc = settings.blank
    --ptgrid:ColSpanAt(2, 1, 2)
    --ptgrid:RowSpanAt(2, 2, 3)

    local function createPortrait(id, c, r)
        local portraitImg = loveframes.Create("image")
        portraitImg:SetImage(portraitIcons[id].img)
        portraitImg:SetScale(0.52, 0.52)
        portraitImg:Center()
        local ogImgDraw = portraitImg.drawfunc

        portraitImg.drawfunc = function(obj)
            local x, y, w, h = obj:GetX(), obj:GetY(), obj.image:getWidth() * obj:GetScaleX(), obj.image:getHeight() * obj:GetScaleY()

            ogImgDraw(obj)

            love.graphics.setLineWidth(3)
                love.graphics.setColor(portraitIcons[id].color)
                    love.graphics.rectangle("line", x, y, w, h)
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setLineWidth(1)
        end

        local portraitPanel = loveframes.Create("panel")
        portraitPanel:SetSize(portraitImg.image:getWidth() * portraitImg:GetScaleX(), portraitImg.image:getHeight() * portraitImg:GetScaleY() + 48)
        portraitImg:SetParent(portraitPanel)
        portraitPanel.drawfunc = settings.blank

        local animatronicName = loveframes.Create("text")
        animatronicName:SetParent(portraitPanel)
        animatronicName:SetDefaultColor(portraitIcons[id].color)
        animatronicName:SetFont(settings.fonts.btnfont)
        animatronicName:SetText(tostring(id))
        animatronicName:SetY(portraitPanel:GetHeight() - 40)
        animatronicName:CenterX()

        local curAILevel = CustomNightState.animatronicsAI[id]
        local AIValue = loveframes.Create("text")
        AIValue:SetParent(portraitPanel)
        AIValue:SetDefaultColor(portraitIcons[id].color)
        AIValue:SetFont(settings.fonts.mainButtons)
        AIValue:SetText(tostring(curAILevel))
        AIValue:SetY(portraitPanel:GetHeight() + 4)
        AIValue:CenterX()
        
        local decButton = loveframes.Create("button")
        decButton:SetParent(portraitPanel)
        decButton:SetText("-")
        decButton:SetSize(32, 32)
        decButton:SetParent(portraitPanel)
        decButton:SetY(portraitPanel:GetHeight())
        decButton.OnClick = function(obj)
            if curAILevel > 0 then
                curAILevel = curAILevel - 1
                AIValue:SetText(tostring(curAILevel))
            end
        end

        local incButton = loveframes.Create("button")
        incButton:SetParent(portraitPanel)
        incButton:SetSize(32, 32)
        incButton:SetText("+")
        incButton:SetParent(portraitPanel)
        incButton:SetX(portraitPanel:GetWidth() - incButton:GetWidth())
        incButton:SetY(portraitPanel:GetHeight())
        incButton.OnClick = function(obj)
            if curAILevel < 20 then
                curAILevel = curAILevel + 1
                AIValue:SetText(tostring(curAILevel))
            end
        end

        --portraitPanel:Center()

        ptgrid:AddItem(portraitPanel, r, c)
    end

    local function sortedPairs(t, sort)
        local function collectKey(t, sort)
            local nk = {}
            for k in pairs(t) do
                nk[#nk + 1] = k 
            end
            table.sort(nk, sort)
            return nk
        end

        local ks = collectKey(t, sort)
        local i = 0
        return function()
            i = i + 1
            if ks[i] then
                return ks[i], t[ks[i]]
            end
        end
    end

    local r, c = 1, 1
    for k, v in sortedPairs(portraitIcons) do
        createPortrait(k, r, c)
        r = r + 1
        if r % 5 == 0 then
            c = c + 1
            r = 1
        end
    end

    ptgrid:Center()
    ptgrid:SetY(ptgrid:GetY() - 64)

    local exitButton = loveframes.Create("button")
    exitButton:SetSize(96, 48)
    exitButton:SetText(languageService["menu_settings_buttons_exit"])
    exitButton:SetFont(settings.fonts["mainButtons"])
    exitButton:SetPos(settings.lpadding, love.resconf.height - (exitButton:GetHeight() + settings.lpadding))
    exitButton.OnClick = function(obj)
        -- rest configs and close menu --
        MenuState:enter()
        gamestate.switch(MenuState)
    end
end