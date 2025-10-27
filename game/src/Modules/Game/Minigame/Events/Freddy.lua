local Minigame = {}

function Minigame.init()
    Minigame.assets = {}
    MinigameSceneState.displayFace.currentFace = "freddy"

    MinigameSceneState.displayDate = "1-11-2006"
    MinigameSceneState.displayText = languageService["minigame_display_freddy_collect_gift"]

    AudioSources["msc_bg_freddy"]:play()
    AudioSources["msc_bg_freddy"]:setLooping(true)
    AudioSources["msc_bg_freddy"]:setVolume(0.75)

    Minigame.gifts = {}
    Minigame.assets["gifts"] = { img = nil, quads = {} }
    Minigame.assets["gifts"].img =  love.graphics.newImage("assets/images/game/minigames/gifts.png")
    Minigame.assets["gifts"].quads = love.graphics.getQuads(Minigame.assets["gifts"].img, "assets/images/game/minigames/gifts.json", "array")

    for i = 0, 4, 1 do
        table.insert(Minigame.gifts, MinigameSceneState.spawnAreas["spawn_gift" .. tostring(i > 0 and i)])
    end

    --MinigameSceneState.spawnAreas["bonnie_child_minigame"] 
    local playerPos = MinigameSceneState.spawnAreas["freddy"]
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)

    -- hopefully the gift will spawn in correct order --
    table.sort(Minigame.gifts, function (a, b)
        return a.y < b.y
    end)


end

function Minigame.draw()
    -- draw gift --
    for _, gift in ipairs(Minigame.gifts) do
        love.graphics.draw(Minigame.assets["gifts"].img, Minigame.assets["gifts"].quads[_], gift.x, gift.y, 0, 1.2, 1.2)
    end
end

function Minigame.update(elapsed)
    
end

function Minigame.shutdown()
    -- release all assets used in the minigame --
    for k, asset in pairs(Minigame.assets) do
        if type(asset) == "userdata" then
            asset:release()
        end
    end
end

return Minigame