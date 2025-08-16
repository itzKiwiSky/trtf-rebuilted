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
            MinigameSceneState.spawnAreas[c].centerX, MinigameSceneState.spawnAreas[c].centerY, false, true
        )

        char.drawOffset.x = -14
        char.drawOffset.y = -12
        char.hitbox.w = 28
        char.hitbox.h = 24
        char.hitbox.x = MinigameSceneState.spawnAreas[c].centerX - 14
        char.hitbox.y = MinigameSceneState.spawnAreas[c].centerY - 16
        MinigameSceneState.world:add(char.hitbox, char.hitbox.x, char.hitbox.y, char.hitbox.w, char.hitbox.h)
        table.insert(Minigame.chars, char)
    end

    MinigameSceneState.player.sprite = "foxy"
    MinigameSceneState.player.lastDirection = "right"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)

    -- add the barrier statue --
    local barrier = Minigame.statues:new(MinigameSceneState.barrierSprites, MinigameSceneState.animSets["barrier"]["big"], 
        MinigameSceneState.spawnAreas["barrier_big"].centerX, MinigameSceneState.spawnAreas["barrier_big"].centerY, false, false, 1
    )
    barrier.drawOffset.x = -8
    barrier.drawOffset.y = 8

    barrier.hitbox.w = MinigameSceneState.spawnAreas["barrier_big"].w
    barrier.hitbox.h = MinigameSceneState.spawnAreas["barrier_big"].h
    print(inspect(barrier.hitbox))
    MinigameSceneState.world:add(barrier.hitbox, barrier.hitbox.x - 8, barrier.hitbox.y - 24, barrier.hitbox.w, barrier.hitbox.h)
    table.insert(Minigame.chars, barrier)

    --print(inspect(Minigame.chars))
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