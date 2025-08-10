local Minigame = {
    assets = {},
    childs = {},
}

function Minigame.init()
    Minigame.Child = require 'game.src.Modules.Game.Minigame.Child'
    -- set player pos --
    AudioSources["msc_bg_bonnie"]:play()
    AudioSources["msc_bg_bonnie"]:setLooping(true)
    AudioSources["msc_bg_bonnie"]:setVolume(0.75)

    MinigameSceneState.displayText = languageService["minigame_display_bonnie_entertain_child"]
    local playerPos = MinigameSceneState.spawnAreas["bonnie_child_minigame"]
    MinigameSceneState.player.sprite = "bonnie"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)
    -- load this custom state --
    Minigame.assets.child = {}
    Minigame.assets.child.img, Minigame.assets.child.quads = love.graphics.newQuadFromImage("hash", "assets/images/game/minigames/kid")
    
    for i = 1, 6, 1 do
        print(i > 1 and "child" .. i - 1 or "child")
        local c = Minigame.Child:new(
            Minigame.assets.child.img, Minigame.assets.child.quads, 
            MinigameSceneState.spawnAreas[i > 1 and "child" .. i - 1 or "child"].centerX,
            MinigameSceneState.spawnAreas[i > 1 and "child" .. i - 1 or "child"].centerY, (i % 3 == 0 or i >= 5)
        )
        table.insert(Minigame.childs, c)
    end
end

function Minigame.draw()
    for _, c in ipairs(Minigame.childs) do
        c:draw()
    end
end

function Minigame.update(elapsed)
    for _, c in ipairs(Minigame.childs) do
        c:update(elapsed)
        if collision.rectRect(c.hitbox, MinigameSceneState.player.hitbox) then
            c.happiness = 100
        end
    end
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