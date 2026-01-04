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
    ptgrid.drawfunc = settings.blank

    local names = {
        "office", "bonnie", "chica", "freddy", "foxy", "puppet", "sugar", "kitty"
    }

    local title = loveframes.Create("text")
    title:SetDefaultColor({ 1, 1, 1, 1 })
    title:SetText(languageService["tutorial_title_book"])
    title:SetFont(settings.fonts.vhsTitle)
    title:SetY(80)
    title:CenterX()
    title.Update = function(self)
        self:SetText(languageService["tutorial_title_book"])
    end

    local function createPortrait(id, c, r)
        local portraitImg = loveframes.Create("image")
        portraitImg:SetImage(InstructionsState.instIcons[id])
        portraitImg:SetScale(0.7, 0.7)
        portraitImg:Center()

        local portraitPanel = loveframes.Create("panel")
        portraitPanel:SetSize(portraitImg.image:getWidth() * portraitImg:GetScaleX(), portraitImg.image:getHeight() * portraitImg:GetScaleY() + 48)
        portraitImg:SetParent(portraitPanel)
        portraitPanel.drawfunc = settings.blank

        local animatronicName = loveframes.Create("text")
        animatronicName:SetParent(portraitPanel)
        animatronicName:SetDefaultColor({ 1, 1, 1, 1 })
        animatronicName:SetFont(settings.fonts.vhsNameFont)
        animatronicName:SetText(tostring(id))
        animatronicName:SetY(portraitPanel:GetHeight() - 40)
        animatronicName:CenterX()

        ptgrid:AddItem(portraitPanel, r, c)

        --[[if r >= 2 then
            bottomPortraitGrid:AddItem(portraitPanel, r, c)
        else
            topPortraitGrid:AddItem(portraitPanel, r, c)
        end]]


        table.insert(portraitObjects, portraitPanel)
    end

    local r, c = 1, 1
    for k, v in sortedPairs(InstructionsState.instIcons) do
        createPortrait(k, c, r)

        c = c + 1
        if c % 5 == 0 then
            c = 1
            r = r + 1
        end
    end

    ptgrid:SetPos(200, 200)
end
