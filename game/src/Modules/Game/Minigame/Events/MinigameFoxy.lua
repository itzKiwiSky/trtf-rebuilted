local Minigame = {
    assets = {},
    chars = {},
}

function Minigame.init()
    Minigame.statues = require 'src.Modules.Game.Minigame.Statues'
    MinigameSceneState.displayFace.currentFace = "foxy"

    MinigameSceneState.displayText = languageService["minigame_display_foxy_find_office"]
    local playerPos = MinigameSceneState.spawnAreas["foxy"]

    local charsPos = { "freddy", "bonnie", "chica" }

    for _, c in ipairs(charsPos) do
        local char = Minigame.statues:new(MinigameSceneState.animatronicSprites, MinigameSceneState.animSets[c]["idle"],
            MinigameSceneState.spawnAreas[c].centerX, MinigameSceneState.spawnAreas[c].centerY
        )
        table.insert(Minigame.chars, char)
    end

    MinigameSceneState.player.sprite = "foxy"
    MinigameSceneState.player.lastDirection = "right"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)
    -- load this custom state --
    --Minigame.assets.child.img, Minigame.assets.child.quads = love.graphics.newQuadFromImage("hash", "assets/images/game/minigames/kid")
end

function Minigame.draw()
    for _, char in ipairs(Minigame.chars) do
        char:draw()
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