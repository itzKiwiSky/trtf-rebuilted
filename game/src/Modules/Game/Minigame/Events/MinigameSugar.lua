local Minigame = {
    chars = {},
    objects = {},
    assets = {},
    state = {
        keyCollected = false,
    }
}

function Minigame.init()
    Minigame.statues = require 'src.Modules.Game.Minigame.Statues'
    MinigameSceneState.displayFace.currentFace = "sugar"

    AudioSources["msc_bg_sugar"]:play()
    AudioSources["msc_bg_sugar"]:setLooping(true)
    AudioSources["msc_bg_sugar"]:setVolume(0.75)

    MinigameSceneState.displayDate = "10-21-2006"
    MinigameSceneState.displayText = languageService["minigame_display_sugar_find_key"]

    local charsPos = { "freddy", "bonnie", "chica", "foxy" }

    for _, c in ipairs(charsPos) do
        local char = Minigame.statues:new(MinigameSceneState.animatronicSprites, 
        MinigameSceneState.animSets[c]["idle"],
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

    -- add the barrier statue --
    local barrier = Minigame.statues:new(MinigameSceneState.barrierSprites, MinigameSceneState.animSets["barrier"]["door"], 
        MinigameSceneState.spawnAreas["barrier_big"].centerX, MinigameSceneState.spawnAreas["barrier_big"].centerY, false, false, 1
    )
    barrier.drawOffset.x = -8
    barrier.drawOffset.y = 8

    barrier.hitbox.w = MinigameSceneState.spawnAreas["barrier_big"].w
    barrier.hitbox.h = MinigameSceneState.spawnAreas["barrier_big"].h

    MinigameSceneState.world:add(barrier.hitbox, barrier.hitbox.x - 8, barrier.hitbox.y - 24, barrier.hitbox.w, barrier.hitbox.h)
    Minigame.objects["door"] = barrier

    local playerPos = MinigameSceneState.spawnAreas["sugar"]
    MinigameSceneState.player.sprite = "sugar"
    MinigameSceneState.player.lastDirection = "down"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)
end

function Minigame.draw()
    for _, char in ipairs(Minigame.chars) do
        char:draw()
    end

    for key, obj in pairs(Minigame.objects) do
        obj:draw()
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