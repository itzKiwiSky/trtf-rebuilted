local Minigame = {
    assets = {},
    chars = {},
}

function Minigame.init()
    Minigame.state = {
        guard_view = false,
        guardAction = "idle",
        hitAction = false,
        action_timer = 0,
    }
    Minigame.statues = require 'src.Modules.Game.Minigame.Statues'
    Minigame.guard = require 'src.Modules.Game.Minigame.NightGuard'
    MinigameSceneState.displayFace.currentFace = "foxy"

    AudioSources["msc_bg_foxy"]:play()
    AudioSources["msc_bg_foxy"]:setLooping(true)
    AudioSources["msc_bg_foxy"]:setVolume(0.75)

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

    MinigameSceneState.world:add(barrier.hitbox, barrier.hitbox.x - 8, barrier.hitbox.y - 24, barrier.hitbox.w, barrier.hitbox.h)
    table.insert(Minigame.chars, barrier)

    local guardImg = love.graphics.newImage("assets/images/game/minigames/guard.png")
    local animQuads = love.graphics.getQuads(guardImg, "assets/images/game/minigames/guard.json", "hash")

    local guard = Minigame.guard:new({ img = guardImg, quads = animQuads }, 
        MinigameSceneState.spawnAreas["night_guard"].centerX, MinigameSceneState.spawnAreas["night_guard"].centerY
    )

    table.insert(Minigame.chars, guard)
end

function Minigame.draw()
    for _, char in ipairs(Minigame.chars) do
        char:draw()
    end
end

function Minigame.update(elapsed)
    local guard = Minigame.chars[#Minigame.chars]
    if not MinigameSceneState.isShuttingDown then
        guard:update(elapsed) -- night guard --

        if collision.rectRect(MinigameSceneState.player.hitbox, MinigameSceneState.map.actionAreas["foxy_minigame_guard_action"]) and not Minigame.state.hitAction then
            Minigame.state.guard_view = true
            Minigame.state.hitAction = true
            MinigameSceneState.player.lockCooldownMax = 0.25
            MinigameSceneState.player.lockCooldown = 0.75
            MinigameSceneState.player.locked = true
            MinigameSceneState.player.lastDirection = "right"
            guard.state = "scared"
            AudioSources["msc_bg_foxy"]:stop()
            AudioSources["sfx_guard_scream"]:play()
        end

        if Minigame.state.hitAction and MinigameSceneState.player.locked then
            MinigameSceneState.player.lockCooldown = MinigameSceneState.player.lockCooldown - elapsed
            if MinigameSceneState.player.lockCooldown <= 0 then
                MinigameSceneState.player.locked = false
                guard.state = "attack"
            end
        end

        if Minigame.state.guard_view then
            if collision.rectRect(MinigameSceneState.player.hitbox, guard.hitbox) then
                MinigameSceneState.isShuttingDown = true
                MinigameSceneState.interferenceIntensity = 60
                MinigameSceneState.interferenceSpeed = 150
                MinigameSceneState.interferenceFX:send("intensity", MinigameSceneState.interferenceIntensity)
                MinigameSceneState.interferenceFX:send("speed", MinigameSceneState.interferenceSpeed)

                AudioSources["sfx_minigame_shutdown"]:setLooping(true)
                AudioSources["sfx_minigame_shutdown"]:play()
            end
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