local min = ExtrasState.categories["minigames"]

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
    local startX = 480
    local startY = 64
    local padding = 32
    local r, c = 0, 0
    local minigameList = love.filesystem.getDirectoryItems("src/Modules/Game/Minigame/Events")
    for key, value in spairs(min.assets) do
        local img = loveframes.Create("image")
        img:SetImage(min.assets[key])
        img:SetPos(startX + (img:GetWidth() + padding) * c, startY + (img:GetHeight() + padding) * r)
        c = c + 1
        if c > 1 then
            c = 0
            r = r + 1
        end
        local btnhitbox = loveframes.Create("button")
        btnhitbox:SetParent(img)
        btnhitbox:SetPos(img:GetPos())
        btnhitbox:SetText("")
        btnhitbox:SetSize(img:GetSize())
        btnhitbox.drawfunc = settings.blank
        btnhitbox.OnClick = function(obj)
            
        end
    end
end