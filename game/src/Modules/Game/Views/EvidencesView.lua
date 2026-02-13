local settings = {
    lpadding = 32,
    blank = function() end,
    fonts = {
        vhsFont = fontcache.getFont("vcr", 20),
        vhsTitle = fontcache.getFont("vcr", 42),
        vhsNameFont = fontcache.getFont("vcr", 24),
        fnt_text = fontcache.getFont("ocrx", 28),
        fnt_title = fontcache.getFont("ocrx", 36),
    },
}

return function()
    local gradientBG = love.graphics.newGradient("horizontal",
        { 1, 1, 1, 0 },
        { 1, 1, 1, 0.5 },
        { 1, 1, 1, 1 },
        { 1, 1, 1, 0.5 },
        { 1, 1, 1, 0 }
    )
    local assets = EvidencesState.assets
    local components = require 'src.Modules.Game.Views.SharedComponents'
    local evidenceList = loveframes.Create("list")
    evidenceList.vbar = true
    evidenceList:SetDisplayType("vertical")
    evidenceList:SetX(settings.lpadding)
    evidenceList:SetY(96)
    evidenceList:SetWidth(230)
    evidenceList:SetSpacing(32)
    evidenceList:SetMouseWheelScrollAmount(20)
    evidenceList:SetButtonScrollAmount(3)
    evidenceList:SetHeight(shove.getViewportHeight() - 256)
    --print(inspect(evidenceList))
    --evidenceList.scrolly.drawfunc = settings.blank
    --evidenceList.scrolly.drawpverfunc = settings.blank
    os.execute("cls")

    local scrollbarArea = evidenceList.scrolly.internals[1]
    print(evidenceList:GetScrollBar())
    --local scrollbarButtonTop
    scrollbarArea.drawoverfunc = settings.blank
    print(inspect(scrollbarArea))

    --for index, value in ipairs(scrollbarArea) do
    --    io.write(index .. " - " .. inspect(value.type) .. "\n")
    --end
    --print(inspect(evidenceList.scrolly.internals))
    --evidenceList.scrollx.drawfunc = function(obj)

    --end
    evidenceList.drawfunc = settings.blank
    evidenceList.drawoverfunc = settings.blank


    local topGradient = loveframes.Create("gradient")
    topGradient:SetMesh(gradientBG)
    topGradient:SetX(settings.lpadding)
    topGradient:SetY(96)
    topGradient:SetWidth(evidenceList:GetWidth() + 2)
    topGradient:SetHeight(4)

    local botGradient = loveframes.Create("gradient")
    botGradient:SetMesh(gradientBG)
    botGradient:SetX(settings.lpadding)
    botGradient:SetY(96 + evidenceList:GetHeight() - 2)
    botGradient:SetWidth(evidenceList:GetWidth())
    botGradient:SetHeight(4)

    -- icons --
    for name, img in spairs(assets["icons"].quads) do
        if name ~= "lock" then
            local btnEvidence = loveframes.Create("imagebutton")
            btnEvidence:SetImage(assets["icons"].image)
            btnEvidence.evidenceID = name
            btnEvidence.quad = assets["icons"].quads[name]
            btnEvidence:SetAlwaysUpdate(true)
            btnEvidence.OnClick = function(obj)
                if gameSave.save.user.progress.challenges[obj.evidenceID] then
                    if obj.evidenceID == "double_trouble" then
                        EvidencesState.showCollectionButtons = true
                    else
                        EvidencesState.showCollectionButtons = false
                    end
                    EvidencesState.currentSelection = "trophy_" .. obj.evidenceID
                    print("trophy_" .. obj.evidenceID)
                end
            end
            btnEvidence.Update = function(obj, dt)
                if gameSave.save.user.progress.challenges[obj.evidenceID] then
                    obj.quad = assets["icons"].quads[name]
                    return
                end
                obj.quad = assets["icons"].quads["lock"]
            end
            btnEvidence.drawfunc = components.imgButtonNoteSkin
            evidenceList:AddItem(btnEvidence)
            btnEvidence:SetSize(128, 214)
        end
    end

    -- grid for the collection shit --
    local gridCollection = loveframes.Create("grid")
    gridCollection:SetRows(1)
    gridCollection:SetColumns(9)
    gridCollection:SetCellWidth(96)
    gridCollection:SetCellHeight(96)
    gridCollection:SetPos(shove.getViewportWidth() / 2 - 340, 600)
    gridCollection:SetAlwaysUpdate(true)
    gridCollection.drawfunc = settings.blank

    local buttonCollectionLeft = loveframes.Create("button")
    buttonCollectionLeft:SetFont(settings.fonts.vhsFont)
    buttonCollectionLeft:SetSize(96, 48)
    buttonCollectionLeft:SetText("<<<")
    buttonCollectionLeft.drawfunc = components.ButtonSkin
    buttonCollectionLeft:SetAlwaysUpdate(true)
    buttonCollectionLeft.OnClick = function(obj)
        if EvidencesState.currentCollectionImage > 1 then
            EvidencesState.currentCollectionImage = EvidencesState.currentCollectionImage - 1
        end
    end

    local buttonCollectionRight = loveframes.Create("button")
    buttonCollectionRight:SetFont(settings.fonts.vhsFont)
    buttonCollectionRight:SetSize(96, 48)
    buttonCollectionRight:SetText(">>>")
    buttonCollectionRight:SetAlwaysUpdate(true)
    buttonCollectionRight.drawfunc = components.ButtonSkin
    buttonCollectionRight.OnClick = function(obj)
        if EvidencesState.currentCollectionImage < 7 then
            EvidencesState.currentCollectionImage = EvidencesState.currentCollectionImage + 1
        end
    end

    local gridTextTitle = loveframes.Create("text")
    gridTextTitle:SetAlwaysUpdate(true)
    gridTextTitle:SetDefaultColor(1, 1, 1, 1)
    gridTextTitle:SetFont(settings.fonts.fnt_title)
    gridTextTitle:SetText("This is a test text")
    gridTextTitle:SetShadowOffsets(3, 3)
    gridTextTitle:SetShadowColor(0.25, 0.25, 0.25, 1)
    gridTextTitle:SetShadow(true)
    gridTextTitle:SetMaxWidth(640)
    gridTextTitle.Update = function(obj, elapsed)
        if EvidencesState.currentSelection ~= "" then
            obj:SetText(languageService["evidences_trophies_" .. EvidencesState.currentSelection:gsub("trophy_", "")])
        else
            obj:SetText("")
        end
    end

    gridCollection:AddItem(buttonCollectionLeft, 1, 1, "center")
    gridCollection:AddItem(buttonCollectionRight, 1, 9, "center")
    gridCollection:AddItem(gridTextTitle, 1, 5, "center")

    gridCollection.Update = function(obj, elapsed)
        --gridTextTitle.visible = EvidencesState.showCollectionButtons

        buttonCollectionLeft.visible = EvidencesState.showCollectionButtons
        buttonCollectionRight.visible = EvidencesState.showCollectionButtons

        EvidencesState.canMoveMouse = not loveframes.hover
    end

    local exitButton = loveframes.Create("button")
    exitButton:SetFont(settings.fonts.vhsFont)
    exitButton:SetSize(96, 48)
    exitButton:SetText(languageService["menu_settings_buttons_exit"])
    exitButton:SetPos(settings.lpadding, shove.getViewportHeight() - (exitButton:GetHeight() + settings.lpadding))
    exitButton.drawfunc = components.ButtonSkin
    exitButton.OnClick = function(obj)
        gamestate.switch(MenuState)
    end
end
