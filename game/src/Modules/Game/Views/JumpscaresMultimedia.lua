local jumpscaresSubState = require 'src.States.Substates.ExtraSubStates.Jumpscares'

local settings = { --
    lpadding = 24,
    blank = function() end,
    fonts = {
        title = fontcache.getFont("tnr", 50),
        btnfont = fontcache.getFont("tnr", 26),
        subtitleFont = fontcache.getFont("tnr", 32),
        optionFont = fontcache.getFont("tnr", 34),
        mainButtons = fontcache.getFont("tnr", 18),
        multi = fontcache.getFont("tnr", 20)
    },
}

return function()
    local components = require 'src.Modules.Game.Views.SharedComponents'

    local grid = loveframes.Create("grid")
    grid:SetRows(1)
    grid:SetColumns(11)
    grid:SetCellPadding(24)
    grid:CenterX()
    grid:SetY(shove.getViewportHeight() / 2 + 150)
    grid:SetX(grid.x - 348)
    grid.drawfunc = settings.blank


    local btnHide = loveframes.Create("imagebutton")
    btnHide:SetImage(jumpscaresSubState.assets["multimedia"].img)
    btnHide.quad = jumpscaresSubState.assets["multimedia"].quads[ExtrasState.showExtrasOptions and "show" or "hide"]
    btnHide:SetSize(64, 64)
    btnHide:SetAlwaysUpdate(true)
    btnHide.OnClick = function(obj)
        --jumpscaresSubState.Editor.data.objID = i
        ExtrasState.showExtrasOptions = not ExtrasState.showExtrasOptions
        obj.quad = jumpscaresSubState.assets["multimedia"].quads[ExtrasState.showExtrasOptions and "show" or "hide"]
    end
    btnHide.drawfunc = components.imgButtonNoteSkin
    grid:AddItem(btnHide, 1, 2, "center")

    local btnLeftFrame = loveframes.Create("imagebutton")
    btnLeftFrame:SetImage(jumpscaresSubState.assets["multimedia"].img)
    btnLeftFrame.quad = jumpscaresSubState.assets["multimedia"].quads["prev_frame"]
    btnLeftFrame:SetSize(64, 64)
    btnLeftFrame:SetAlwaysUpdate(true)
    btnLeftFrame.OnClick = function(obj)
        if jumpscaresSubState.jumpscaresController.frame > 1 then
            jumpscaresSubState.jumpscaresController.frame = jumpscaresSubState.jumpscaresController.frame - 1
        end
    end
    btnLeftFrame.drawfunc = components.imgButtonNoteSkin
    grid:AddItem(btnLeftFrame, 1, 4, "center")

    local btnPlay = loveframes.Create("imagebutton")
    btnPlay:SetImage(jumpscaresSubState.assets["multimedia"].img)
    btnPlay.quad = jumpscaresSubState.assets["multimedia"].quads[jumpscaresSubState.jumpscaresController.active and "pause" or "play"]
    btnPlay:SetSize(64, 64)
    btnPlay:SetAlwaysUpdate(true)
    btnPlay.OnClick = function(obj)
        if jumpscaresSubState.jumpscaresController.frame == jumpscaresSubState.jumpscaresController.frames[jumpscaresSubState.jumpscaresController.id].frameCount then
            jumpscaresSubState.jumpscaresController.id = jumpscaresSubState.animatronicNames[jumpscaresSubState.animatronicCurrentID]
            jumpscaresSubState.jumpscaresController.speedAnim = 36
            jumpscaresSubState.jumpscaresController.init()
        else
            jumpscaresSubState.jumpscaresController.active = not jumpscaresSubState.jumpscaresController.active
        end
    end
    btnPlay.Update = function(obj, elapsed)
        obj.quad = jumpscaresSubState.assets["multimedia"].quads[jumpscaresSubState.jumpscaresController.active and "pause" or "play"]
    end
    btnPlay.drawfunc = components.imgButtonNoteSkin
    grid:AddItem(btnPlay, 1, 6, "center")

    local btnRightFrame = loveframes.Create("imagebutton")
    btnRightFrame:SetImage(jumpscaresSubState.assets["multimedia"].img)
    btnRightFrame.quad = jumpscaresSubState.assets["multimedia"].quads["next_frame"]
    btnRightFrame:SetSize(64, 64)
    btnRightFrame:SetAlwaysUpdate(true)
    btnRightFrame.OnClick = function(obj)
        if jumpscaresSubState.jumpscaresController.frame < jumpscaresSubState.jumpscaresController.frames[jumpscaresSubState.jumpscaresController.id].frameCount then
            jumpscaresSubState.jumpscaresController.frame = jumpscaresSubState.jumpscaresController.frame + 1
        end
    end
    btnRightFrame.drawfunc = components.imgButtonNoteSkin
    grid:AddItem(btnRightFrame, 1, 8, "center")

    local btnSound = loveframes.Create("imagebutton")
    btnSound:SetImage(jumpscaresSubState.assets["multimedia"].img)
    btnSound.quad = jumpscaresSubState.assets["multimedia"].quads[jumpscaresSubState.jumpscaresController.playAudio and "audio" or "mute"]
    btnSound:SetSize(64, 64)
    btnSound:SetAlwaysUpdate(true)
    btnSound.OnClick = function(obj)
        --jumpscaresSubState.Editor.data.objID = i
        jumpscaresSubState.jumpscaresController.playAudio = not jumpscaresSubState.jumpscaresController.playAudio
        obj.quad = jumpscaresSubState.assets["multimedia"].quads[jumpscaresSubState.jumpscaresController.playAudio and "audio" or "mute"]
    end
    btnSound.drawfunc = components.imgButtonNoteSkin
    grid:AddItem(btnSound, 1, 10, "center")
end
