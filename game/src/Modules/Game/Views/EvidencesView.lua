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

local function debugScrollStructure(list)
    print("=== SCROLLY (vertical) ===")
    print("Type: " .. (list.scrolly.type or "?"))

    for i, internal in ipairs(list.scrolly.internals) do
        print(string.format("  [%d] type=%s", i, internal.type or "?"))

        if internal.internals then
            for j, subinternal in ipairs(internal.internals) do
                print(string.format("    [%d] type=%s", j, subinternal.type or "?"))
            end
        end
    end
end

return function()
    local gradientBG = love.graphics.newGradient("horizontal",
        { 1, 1, 1, 0 },
        { 1, 1, 1, 0.5 },
        { 1, 1, 1, 1 },
        { 1, 1, 1, 0.5 },
        { 1, 1, 1, 0 }
    )
    local assets = EvidencesState.assets
    local components = love.filesystem.load("src/Modules/Game/Views/SharedComponents.lua")()
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
    --debugScrollStructure(evidenceList)

    local scrollArea = evidenceList.scrolly.internals[1]
    evidenceList.scrolly.drawfunc = settings.blank

    local scrollBar = scrollArea.internals[1]
    scrollBar.drawfunc = components.customScrollbody

    local topButton = evidenceList.scrolly.internals[2]
    topButton.drawfunc = settings.blank

    local botButton = evidenceList.scrolly.internals[3]
    botButton.drawfunc = settings.blank


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
        buttonCollectionLeft.visible = EvidencesState.showCollectionButtons
        buttonCollectionRight.visible = EvidencesState.showCollectionButtons

        EvidencesState.canMoveMouse = not loveframes.hover
    end

    local player = loveframes.Create("frame")
    player:SetSize(640, 128)
    player:Center()
    player:ShowCloseButton(false)
    player.x = player.x + 200
    player.y = player.y + 250
    player:SetName("Audio player")
    player.drawfunc = components.customFrame
    player:SetAlwaysUpdate(true)
    player.Update = function()
        EvidencesState.canMoveMouse = not loveframes.hover
    end

    local gridPlayer = loveframes.Create("grid")
    gridPlayer:SetParent(player)
    gridPlayer:SetRows(2)
    gridPlayer:SetColumns(15)
    gridPlayer:SetCellPadding(9)
    gridPlayer:SetY(gridPlayer.y + 30)
    --gridPlayer.y = gridPlayer.y + 150
    --gridPlayer:CenterX()
    --gridPlayer:SetX(gridPlayer.x - 348)
    --gridPlayer:SetY(shove.getViewportHeight() / 2 + 150)
    gridPlayer.drawfunc = settings.blank

    local btnPlay = loveframes.Create("imagebutton")
    btnPlay:SetImage(EvidencesState.assets["multimedia"].img)
    btnPlay.quad = EvidencesState.assets["multimedia"].quads["play"]
    btnPlay:SetSize(48, 48)
    btnPlay:SetAlwaysUpdate(true)
    btnPlay.OnClick = function(obj)
        --[[if jumpscaresSubState.jumpscaresController.frame == jumpscaresSubState.jumpscaresController.frames[jumpscaresSubState.jumpscaresController.id].frameCount then
            jumpscaresSubState.jumpscaresController.id = jumpscaresSubState.animatronicNames[jumpscaresSubState.animatronicCurrentID]
            jumpscaresSubState.jumpscaresController.speedAnim = 36
            jumpscaresSubState.jumpscaresController.init()
        else
            jumpscaresSubState.jumpscaresController.active = not jumpscaresSubState.jumpscaresController.active
        end]]
    end
    btnPlay.drawfunc = components.imgButtonNoteSkin
    gridPlayer:AddItem(btnPlay, 2, 8)

    local btnPrev = loveframes.Create("imagebutton")
    btnPrev:SetImage(EvidencesState.assets["multimedia"].img)
    btnPrev.quad = EvidencesState.assets["multimedia"].quads["prev_frame"]
    btnPrev:SetSize(48, 48)
    btnPrev:SetAlwaysUpdate(true)
    btnPrev.OnClick = function(obj)
        --[[if jumpscaresSubState.jumpscaresController.frame == jumpscaresSubState.jumpscaresController.frames[jumpscaresSubState.jumpscaresController.id].frameCount then
            jumpscaresSubState.jumpscaresController.id = jumpscaresSubState.animatronicNames[jumpscaresSubState.animatronicCurrentID]
            jumpscaresSubState.jumpscaresController.speedAnim = 36
            jumpscaresSubState.jumpscaresController.init()
        else
            jumpscaresSubState.jumpscaresController.active = not jumpscaresSubState.jumpscaresController.active
        end]]
    end
    btnPrev.drawfunc = components.imgButtonNoteSkin
    gridPlayer:AddItem(btnPrev, 2, 6)

    local btnNext = loveframes.Create("imagebutton")
    btnNext:SetImage(EvidencesState.assets["multimedia"].img)
    btnNext.quad = EvidencesState.assets["multimedia"].quads["next_frame"]
    btnNext:SetSize(48, 48)
    btnNext:SetAlwaysUpdate(true)
    btnNext.OnClick = function(obj)
        --[[if jumpscaresSubState.jumpscaresController.frame == jumpscaresSubState.jumpscaresController.frames[jumpscaresSubState.jumpscaresController.id].frameCount then
            jumpscaresSubState.jumpscaresController.id = jumpscaresSubState.animatronicNames[jumpscaresSubState.animatronicCurrentID]
            jumpscaresSubState.jumpscaresController.speedAnim = 36
            jumpscaresSubState.jumpscaresController.init()
        else
            jumpscaresSubState.jumpscaresController.active = not jumpscaresSubState.jumpscaresController.active
        end]]
    end
    btnNext.drawfunc = components.imgButtonNoteSkin
    gridPlayer:AddItem(btnNext, 2, 10)

    local sliderSound = loveframes.Create("slider")
    sliderSound:SetPos(5, 30)
    sliderSound:SetWidth(290)
    sliderSound:SetMinMax(0, EvidencesState.record:getDuration("seconds"))
    sliderSound:SetWidth(player.width - 96)
    sliderSound.drawfunc = components.customSlider
    --ebugScrollStructure(sliderSound)
    --os.execute("cls")
    --print(inspect(sliderSound.internals))
    sliderSound.internals[1].drawfunc = components.customSliderButton
    --sliderSound:SetValue(90)
    gridPlayer:AddItem(sliderSound, 1, 8)


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
