local settings = {
    lpadding = 32,
    blank = function()end,
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
    states = { "video", "audio", "misc" },
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

    local buttonSkin = function(object)
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
            back = {0.3, 0.3, 0.3, 1}
            fore = {1, 1, 1, 1}
            border = {1, 1, 0, 1}

            -- button body
            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)
            
            love.graphics.setColor(fore)
            skin.PrintText(text, (x + width / 2 - twidth / 2) + 8, (y + height / 2 - theight / 2) + 8)
        elseif hover then
            back = {0.7, 0.7, 0.7, 1}
            fore = {0, 0, 0, 1}
            border = love.timer.getTime() % 1 > 0.5 and {1, 1, 0, 1} or {0, 0, 1, 1}

            -- button body
            love.graphics.setColor(border)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x, y, width, height)
            
            love.graphics.setColor(fore)
            skin.PrintText(text, x + width / 2 - twidth / 2, y + height / 2 - theight / 2)
        else
            back = {0.7, 0.7, 0.7, 1}
            fore = {0, 0, 0, 1}
            border = {0.3, 0.3, 0.3, 1}

            -- button body
            love.graphics.setColor(border)
            love.graphics.rectangle("fill", x + 8, y + 8, width, height)

            love.graphics.setColor(back)
            love.graphics.rectangle("fill", x, y, width, height)
            
            love.graphics.setColor(fore)
            skin.PrintText(text, x + width / 2 - twidth / 2, y + height / 2 - theight / 2)
        end
    end


    local window = loveframes.Create("panel")
    window:SetSize(shove.getViewportWidth(), shove.getViewportHeight())
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

    local topPortraitGrid = loveframes.Create("grid")
    topPortraitGrid:SetPos(228, 128)
    topPortraitGrid:SetRows(1)
    topPortraitGrid:SetColumns(4)
    topPortraitGrid:SetItemAutoSize(false)
    topPortraitGrid:SetCellPadding(90)
    topPortraitGrid.drawfunc = settings.blank

    local bottomPortraitGrid = loveframes.Create("grid")
    bottomPortraitGrid:CenterWithinArea(180, 100, 450, 300)
    bottomPortraitGrid:SetRows(1)
    bottomPortraitGrid:SetColumns(3)
    bottomPortraitGrid:SetItemAutoSize(false)
    bottomPortraitGrid:SetCellPadding(86)
    bottomPortraitGrid.drawfunc = settings.blank
    --ptgrid:ColSpanAt(2, 1, 2)
    --ptgrid:RowSpanAt(2, 2, 3)

    local exitButton = loveframes.Create("button")
    exitButton:SetFont(settings.fonts.vhsFont)
    exitButton:SetSize(96, 48)
    exitButton:SetText(languageService["menu_settings_buttons_exit"])
    exitButton:SetPos(settings.lpadding, shove.getViewportHeight() - (exitButton:GetHeight() + settings.lpadding))
    exitButton.drawfunc = buttonSkin
    exitButton.OnClick = function(obj)
        gamestate.switch(MenuState)
    end

    local readyButton = loveframes.Create("button")
    readyButton:SetFont(settings.fonts.vhsFont)
    readyButton:SetSize(96, 48)
    readyButton:SetText(languageService["custom_night_menu_ready"])
    readyButton:SetPos((shove.getViewportWidth() - (exitButton:GetWidth() + settings.lpadding)) - 8, shove.getViewportHeight() - (exitButton:GetHeight() + settings.lpadding))
    readyButton.drawfunc = buttonSkin
    readyButton.OnClick = function(obj)
        NightState.animatronicsAI = CustomNightState.animatronicsAI
        NightState.nightID = 2000
        gamestate.switch(LoadingState)
    end

    local function updateValue()
        local i = 1
        if CustomNightState.presets[registers.user.currentChallengeID] then
            for anim, value in spairs(CustomNightState.presets[registers.user.currentChallengeID].values) do
                --createPortrait(k, r, c)
                --CustomNightState.animatronicsAI
                local animatronic = CustomNightState.presets[registers.user.currentChallengeID].values[anim]
                local child = ptgrid.children[i].children[3]
                child:SetText(animatronic)
                child:CenterX()
                CustomNightState.animatronicsAI[anim] = CustomNightState.presets[registers.user.currentChallengeID].values[anim]
                i = i + 1
            end
        end
    end

    local challengeGrid = loveframes.Create("grid")
    challengeGrid:SetRows(1)
    challengeGrid:SetColumns(3)
    challengeGrid:SetItemAutoSize(false)
    challengeGrid:SetCellPadding(128)
    challengeGrid:Center()
    challengeGrid:SetY(challengeGrid:GetY() + shove.getViewportHeight() / 2 - challengeGrid:GetCellPadding() + settings.lpadding)
    challengeGrid.drawfunc = settings.blank

    local textChallenge = loveframes.Create("text")
    textChallenge:SetText(not registers.user.isCustomChallenge and CustomNightState.presets[registers.user.currentChallengeID].displayName or "Custom Challenge")
    textChallenge:SetDefaultColor(1, 1, 1, 1)
    textChallenge:SetFont(settings.fonts.vhsTitle)
    textChallenge:Center()

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
        animatronicName:SetFont(settings.fonts.vhsNameFont)
        animatronicName:SetText(tostring(id))
        animatronicName:SetY(portraitPanel:GetHeight() - 40)
        animatronicName:CenterX()

        local curAILevel = CustomNightState.animatronicsAI[id]
        local AIValue = loveframes.Create("text")
        AIValue:SetParent(portraitPanel)
        AIValue:SetDefaultColor(portraitIcons[id].color)
        AIValue:SetFont(settings.fonts.vhsFont)
        AIValue:SetText(tostring(curAILevel))
        AIValue:SetY(portraitPanel:GetHeight() + 4)
        AIValue:CenterX()
        
        local decButton = loveframes.Create("button")
        decButton:SetParent(portraitPanel)
        decButton:SetText("-")
        decButton:SetSize(32, 32)
        decButton:SetFont(settings.fonts.vhsFont)
        decButton:SetParent(portraitPanel)
        decButton:SetY(portraitPanel:GetHeight())
        decButton.drawfunc = buttonSkin
        decButton.OnClick = function(obj)
            if curAILevel > 0 then
                CustomNightState.animatronicsAI[id] = CustomNightState.animatronicsAI[id] - 1
                AIValue:SetText(tostring(CustomNightState.animatronicsAI[id]))
                AIValue:CenterX()

                registers.user.isCustomChallenge = true
            end

            if registers.user.isCustomChallenge then
                textChallenge:SetText(languageService["custom_night_menu_custom_challenge"])
                textChallenge:Center()
            else
                textChallenge:SetText(CustomNightState.presets[registers.user.currentChallengeID].displayName)
                textChallenge:Center()
            end
        end

        local incButton = loveframes.Create("button")
        incButton:SetParent(portraitPanel)
        incButton:SetSize(32, 32)
        incButton:SetText("+")
        incButton:SetFont(settings.fonts.vhsFont)
        incButton:SetParent(portraitPanel)
        incButton:SetX(portraitPanel:GetWidth() - incButton:GetWidth())
        incButton:SetY(portraitPanel:GetHeight())
        incButton.drawfunc = buttonSkin
        incButton.OnClick = function(obj)
            if curAILevel < 20 then
                CustomNightState.animatronicsAI[id] = CustomNightState.animatronicsAI[id] + 1
                AIValue:SetText(tostring(CustomNightState.animatronicsAI[id]))
                AIValue:CenterX()

                registers.user.isCustomChallenge = true
            end

            if registers.user.isCustomChallenge then
                textChallenge:SetText(languageService["custom_night_menu_custom_challenge"])
                textChallenge:Center()
            else
                textChallenge:SetText(CustomNightState.presets[registers.user.currentChallengeID].displayName)
                textChallenge:Center()
            end
        end

        --ptgrid:AddItem(portraitPanel, r, c)
        if r >= 2 then
            bottomPortraitGrid:AddItem(portraitPanel, r, c)
        else
            topPortraitGrid:AddItem(portraitPanel, r, c)
        end
    end

    local r, c = 1, 1
    for k, v in sortedPairs(portraitIcons) do
        createPortrait(k, c, r)

        c = c + 1
        if c % 5 == 0 then
            c = 1
            r = r + 1
        end
    end

    ptgrid:Center()
    ptgrid:SetY(ptgrid:GetY() - 64)

    local challengeLeftButton = loveframes.Create("button")
    challengeLeftButton:SetFont(settings.fonts.vhsFont)
    challengeLeftButton:SetSize(96, 48)
    challengeLeftButton:SetText("<<")
    challengeLeftButton:SetY(shove.getViewportHeight() - (exitButton:GetHeight() + settings.lpadding))
    challengeLeftButton.drawfunc = buttonSkin
    challengeLeftButton.OnClick = function(obj)
        registers.user.isCustomChallenge = false
        if registers.user.currentChallengeID > 1 then
            registers.user.currentChallengeID = registers.user.currentChallengeID - 1
            if registers.user.isCustomChallenge then
                textChallenge:SetText(languageService["custom_night_menu_custom_challenge"])
                textChallenge:Center()
            else
                textChallenge:SetText(CustomNightState.presets[registers.user.currentChallengeID].displayName)
                textChallenge:Center()
            end
            updateValue()
        end
    end

    local challengeRightButton = loveframes.Create("button")
    challengeRightButton:SetFont(settings.fonts.vhsFont)
    challengeRightButton:SetSize(96, 48)
    challengeRightButton:SetText(">>")
    challengeRightButton:SetY(shove.getViewportHeight() - (exitButton:GetHeight() + settings.lpadding))
    challengeRightButton.drawfunc = buttonSkin
    challengeRightButton.OnClick = function(obj)
        registers.user.isCustomChallenge = false
        if registers.user.currentChallengeID < #CustomNightState.presets then
            registers.user.currentChallengeID = registers.user.currentChallengeID + 1
            if registers.user.isCustomChallenge then
                textChallenge:SetText(languageService["custom_night_menu_custom_challenge"])
                textChallenge:Center()
            else
                textChallenge:SetText(CustomNightState.presets[registers.user.currentChallengeID].displayName)
                textChallenge:Center()
            end
            updateValue()
        end
    end

    challengeGrid:AddItem(challengeLeftButton, 1, 1, "right")
    challengeGrid:AddItem(textChallenge, 1, 2)
    challengeGrid:AddItem(challengeRightButton, 1, 3, "left")
end