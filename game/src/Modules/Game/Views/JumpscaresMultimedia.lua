local jumpscaresSubState = require 'src.States.Substates.ExtraSubStates.Jumpscares'

local settings = {--
    lpadding = 24,
    blank = function()end,
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
    local function imgButtonNoteSkin(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local width = object:GetWidth()
        local height = object:GetHeight()
        local text = object:GetText()
        local hover = object:GetHover()
        local image = object:GetImage()
        local imagecolor = object.imagecolor or skin.controls.color_image
        local down = object.down
        local font = object:GetFont() or skin.controls.imagebuttonfont
        local twidth = font:getWidth(object.text)
        local theight = font:getHeight(object.text)
        local checked = object.checked
        local quad = object.quad

        love.graphics.setColor(imagecolor)
        if quad then
            _, _, w, h = quad:getViewport()
            love.graphics.draw(image, quad, x, y, 0, width / w, height / h)
        else
            love.graphics.draw(image, x, y, 0, width / image:getWidth(), height / image:getHeight())
        end
    end

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
    btnHide.drawfunc = imgButtonNoteSkin
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
    btnLeftFrame.drawfunc = imgButtonNoteSkin
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
    btnPlay.drawfunc = imgButtonNoteSkin
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
    btnRightFrame.drawfunc = imgButtonNoteSkin
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
    btnSound.drawfunc = imgButtonNoteSkin
    grid:AddItem(btnSound, 1, 10, "center")
end