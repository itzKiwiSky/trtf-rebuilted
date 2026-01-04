local settings = {
    lpadding = 32,
    blank = function() end,
    fonts = {
        title = fontcache.getFont("tnr", 50),
        btnfont = fontcache.getFont("tnr", 26),
        subtitleFont = fontcache.getFont("tnr", 32),
        optionFont = fontcache.getFont("tnr", 34),
        mainButtons = fontcache.getFont("tnr", 18),
        multi = fontcache.getFont("tnr", 20),
        vhsFont = fontcache.getFont("vcr", 20),
        vhsTitle = fontcache.getFont("vcr", 42),
        vhsNameFont = fontcache.getFont("vcr", 24)
    },
}

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

return function()
    local lfskin                    = loveframes.GetActiveSkin()
    local portraitObjects           = {}

    lfskin.controls                 = {}
    lfskin.controls.smallfont       = love.graphics.newFont(11)
    lfskin.controls.imagebuttonfont = love.graphics.newFont(15)
    lfskin.controls.color_image     = { lume.color("#FFFFFF") }
    lfskin.controls.color_back0     = { lume.color("#bcbce4") }
    lfskin.controls.color_back1     = { lume.color("#7a8bc9") }
    lfskin.controls.color_back2     = { lume.color("#4b39a1") }
    lfskin.controls.color_back3     = { lume.color("#5c6eaf") }
    lfskin.controls.color_fore0     = { lume.color("#9d8cf1") }
    lfskin.controls.color_fore1     = { lume.color("#4f467d") }
    lfskin.controls.color_fore2     = { lume.color("#3a3167") }
    lfskin.controls.color_fore3     = { lume.color("#2c2359") }
    lfskin.controls.color_active    = { lume.color("#1c1c56") }

    local ptgrid                    = loveframes.Create("grid")
    ptgrid:SetRows(2)
    ptgrid:SetColumns(4)
    ptgrid:SetItemAutoSize(false)
    ptgrid:SetCellPadding(96)
    ptgrid.drawfunc      = settings.blank

    local buttonSkin     = function(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local width = object:GetWidth()
        local height = object:GetHeight()
        local hover = object:GetHover()
        local text = object:GetText()
        local font = object:GetFont() or skin.controls.smallfont
        local twidth = font:getWidth(object.text)
        local theight = font:getHeight(object.text)
        local down = object:GetDown()
        local checked = object.checked
        local enabled = object:GetEnabled()
        local clickable = object:GetClickable()
        local back, fore, border

        love.graphics.setFont(font)

        if down or checked then
            back = { 0.3, 0.3, 0.3, 1 }
            fore = { 1, 1, 1, 1 }
            border = { 1, 1, 0, 1 }

            -- button body
            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(fore)
            skin.PrintText(text, (x + width / 2 - twidth / 2) + 8, (y + height / 2 - theight / 2) + 8)
        elseif hover then
            back = { 0.7, 0.7, 0.7, 1 }
            fore = { 0, 0, 0, 1 }
            border = love.timer.getTime() % 1 > 0.5 and { 1, 1, 0, 1 } or { 0, 0, 1, 1 }

            -- button body
            love.graphics.setColor(border)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x, y, width, height)

            love.graphics.setColor(fore)
            skin.PrintText(text, x + width / 2 - twidth / 2, y + height / 2 - theight / 2)
        else
            back = { 0.7, 0.7, 0.7, 1 }
            fore = { 0, 0, 0, 1 }
            border = { 0.3, 0.3, 0.3, 1 }

            -- button body
            love.graphics.setColor(border)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x, y, width, height)

            love.graphics.setColor(fore)
            skin.PrintText(text, x + width / 2 - twidth / 2, y + height / 2 - theight / 2)
        end

        --love.graphics.rectangle("line", x, y, width, height)
    end

    local currentHovered = ""
    local currentNight   = 1
    local nights         = {
        { office = true, bonnie = true, chica = true, puppet = true, foxy = false, freddy = false, sugar = false, kitty = false },
        { office = true, bonnie = true, chica = true, puppet = true, foxy = true,  freddy = false, sugar = false, kitty = false },
        { office = true, bonnie = true, chica = true, puppet = true, foxy = true,  freddy = true,  sugar = false, kitty = false },
        { office = true, bonnie = true, chica = true, puppet = true, foxy = true,  freddy = true,  sugar = true,  kitty = true },
    }

    local title          = loveframes.Create("text")
    title:SetDefaultColor({ 1, 1, 1, 1 })
    title:SetText(languageService["tutorial_title_book"])
    title:SetFont(settings.fonts.vhsTitle)
    title:SetY(80)
    title:CenterX()
    title.Update = function(self)
        self:SetText(languageService["tutorial_title_book"])
        self:CenterX()
    end

    local desc = loveframes.Create("text")
    desc:SetDefaultColor({ 1, 1, 1, 1 })
    desc:SetMaxWidth(900)
    desc:SetText(languageService["tutorial_title_book"])
    desc:SetFont(settings.fonts.vhsNameFont)
    desc:SetY(shove.getViewportHeight() - 180)
    desc:CenterX()
    desc.Update = function(self)
        if currentHovered == "office" then
            self:SetText(languageService["tutorial_office"])
        elseif currentHovered == "unknown" then
            self:SetText("??????")
        else
            self:SetText(languageService["gameover_explain_" .. currentHovered])
        end

        desc:CenterX()
    end

    local function createPortrait(id, c, r)
        local portraitImg = loveframes.Create("image")
        portraitImg:SetImage(InstructionsState.instIcons[id])
        portraitImg:SetScale(0.7, 0.7)
        portraitImg:Center()
        portraitImg.hoveredName = id
        portraitImg.Update = function(self)
            if self.hover then
                currentHovered = id
                --print(currentHovered)
            end
        end

        local portraitPanel = loveframes.Create("panel")
        portraitPanel:SetSize(portraitImg.image:getWidth() * portraitImg:GetScaleX(), portraitImg.image:getHeight() * portraitImg:GetScaleY() + 48)
        portraitImg:SetParent(portraitPanel)
        portraitPanel.drawfunc = settings.blank

        local animatronicName = loveframes.Create("text")
        animatronicName:SetParent(portraitPanel)
        animatronicName:SetDefaultColor({ 1, 1, 1, 1 })
        animatronicName:SetFont(settings.fonts.vhsNameFont)
        animatronicName:SetText(id == "unknown" and "??????" or tostring(id))
        animatronicName:SetY(portraitPanel:GetHeight() - 40)
        animatronicName:CenterX()

        ptgrid:AddItem(portraitPanel, r, c)
        table.insert(portraitObjects, portraitPanel)
    end

    local r, c = 1, 1
    for k, v in sortedPairs(InstructionsState.instIcons) do
        local name = ""
        if k ~= "unknown" then
            if nights[math.min(gameSave.save.user.progress.night, 4)][k] then
                name = k
            else
                name = "unknown"
            end

            createPortrait(name, c, r)

            c = c + 1
            if c % 5 == 0 then
                c = 1
                r = r + 1
            end
        end
    end

    ptgrid:SetPos(200, 150)

    local exitButton = loveframes.Create("button")
    exitButton:SetFont(settings.fonts.vhsFont)
    exitButton:SetSize(96, 48)
    exitButton:SetText(languageService["menu_settings_buttons_exit"])
    exitButton:SetPos(settings.lpadding, shove.getViewportHeight() - (exitButton:GetHeight() + settings.lpadding))
    exitButton.drawfunc = buttonSkin
    exitButton.Update = function(self)
        self:SetText(languageService["menu_settings_buttons_exit"])
    end
    exitButton.OnClick = function(obj)
        gamestate.switch(MenuState)
    end
end
