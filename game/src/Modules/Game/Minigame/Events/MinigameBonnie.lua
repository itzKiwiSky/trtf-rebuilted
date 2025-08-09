local Minigame = {
    assets = {},
    childs = {},
}

function Minigame.init()
    -- set player pos --
    MinigameSceneState.displayText = languageService["minigame_display_bonnie_entertain_child"]
    local playerPos = MinigameSceneState.spawnAreas["bonnie_child_minigame"]
    MinigameSceneState.player.sprite = "bonnie"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)
    -- load this custom state --
    Minigame.assets.child = {}
    Minigame.assets.child.img, Minigame.assets.child.quads = love.graphics.newQuadFromImage("array", "assets/images/game/minigames/kid")
end

function Minigame.draw()
    
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