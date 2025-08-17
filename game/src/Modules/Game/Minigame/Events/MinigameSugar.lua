local Minigame = {
    chars = {},
    assets = {},
    state = {
        vincentScream = false,
        vincentAttacking = false,
        vincentMoveCooldown = 0.25,
        lockedExit = false,
    }
}

function Minigame.init()
    Minigame.statues = require 'src.Modules.Game.Minigame.Statues'
    Minigame.guard = require 'src.Modules.Game.Minigame.NightGuard'
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
        --table.insert(Minigame.chars, char)
        Minigame.chars[c] = char
    end

    -- add the barrier statue --
    local barrier = Minigame.statues:new(MinigameSceneState.barrierSprites, MinigameSceneState.animSets["barrier"]["door"], 
        MinigameSceneState.spawnAreas["barrier_big"].centerX, MinigameSceneState.spawnAreas["barrier_big"].centerY, false, false, 1
    )
    barrier.drawOffset.x = -8
    barrier.drawOffset.y = 8

    barrier.hitbox.w = MinigameSceneState.spawnAreas["barrier_big"].w
    barrier.hitbox.h = MinigameSceneState.spawnAreas["barrier_big"].h
    barrier.visible = true

    MinigameSceneState.world:add(barrier.hitbox, barrier.hitbox.x - 8, barrier.hitbox.y - 24, barrier.hitbox.w, barrier.hitbox.h)
    Minigame.door = barrier

    local playerPos = MinigameSceneState.spawnAreas["sugar"]
    MinigameSceneState.player.sprite = "sugar"
    MinigameSceneState.player.lastDirection = "down"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)

    local imgitems = love.graphics.newImage("assets/images/game/minigames/collectibles.png")
    local itemsquad = love.graphics.getQuads(imgitems, "assets/images/game/minigames/collectibles.json", "hash")["key"]

    Minigame.keyobj = {
        x = MinigameSceneState.spawnAreas["spawn_key"].centerX,
        y = MinigameSceneState.spawnAreas["spawn_key"].centerY,
        w = MinigameSceneState.spawnAreas["spawn_key"].w,
        h = MinigameSceneState.spawnAreas["spawn_key"].h,
        img = imgitems,
        quad = itemsquad,
        collected = false,
    }

    local guardImg = love.graphics.newImage("assets/images/game/minigames/vincent.png")
    local animQuads = love.graphics.getQuads(guardImg, "assets/images/game/minigames/vincent.json", "hash")

    local guard = Minigame.guard:new({ img = guardImg, quads = animQuads }, 
        MinigameSceneState.spawnAreas["vincent"].centerX, MinigameSceneState.spawnAreas["vincent"].centerY
    )
    guard.flipped = false

    Minigame.chars["vincent"] = guard
end

function Minigame.draw()
    for anim, char in pairs(Minigame.chars) do
        char:draw()
    end

    if Minigame.door.visible then
        Minigame.door:draw()
    end

    if not Minigame.keyobj.collected then
        love.graphics.draw(Minigame.keyobj.img, Minigame.keyobj.quad, Minigame.keyobj.x, Minigame.keyobj.y, 0, 1.2, 1.2, 8, 8)
    end
end

function Minigame.update(elapsed)
    if not MinigameSceneState.isShuttingDown then
        Minigame.chars["vincent"]:update(elapsed)
        if collision.rectRect(MinigameSceneState.player.hitbox, Minigame.keyobj) and not Minigame.keyobj.collected then
            Minigame.keyobj.collected = true
            AudioSources["sfx_collect"]:setVolume(1)
            AudioSources["sfx_collect"]:play()
            MinigameSceneState.displayText = languageService["minigame_display_sugar_boiler_room"]
        end

        if collision.rectRect(MinigameSceneState.player.hitbox, MinigameSceneState.map.actionAreas["sugar_minigame_door_unlock"]) and Minigame.door.visible then
            if Minigame.keyobj.collected then
                Minigame.door.visible = false
                MinigameSceneState.world:remove(Minigame.door.hitbox)
                AudioSources["sfx_beep"]:play()
            end
        end

        if collision.rectRect(MinigameSceneState.player.hitbox, MinigameSceneState.map.actionAreas["sugar_minigame_vincent_attack"]) and not Minigame.state.vincentScream then
            Minigame.state.vincentScream = true
            AudioSources["msc_bg_sugar"]:stop()
            AudioSources["sfx_guard_scream"]:play()
            MinigameSceneState.player.lockCooldown = 2.5
            Minigame.chars["vincent"].flipped = true
            Minigame.chars["vincent"].state = "scared"
            MinigameSceneState.player.locked = true
        end

        if Minigame.state.vincentScream and not Minigame.state.vincentAttacking then
            MinigameSceneState.player.lockCooldown = MinigameSceneState.player.lockCooldown - elapsed
            if MinigameSceneState.player.lockCooldown <= 0 then
                MinigameSceneState.player.locked = false
                Minigame.chars["vincent"].state = "attack"
                Minigame.chars["vincent"].animation.speed = 1 / 5
                Minigame.state.vincentScream = true
                Minigame.state.vincentAttacking = true
            end
        elseif Minigame.state.vincentScream and Minigame.state.vincentAttacking then
            if not Minigame.state.lockedExit then
                MinigameSceneState.world:add(MinigameSceneState.spawnAreas["sugar_minigame_barrier"], MinigameSceneState.spawnAreas["sugar_minigame_barrier"].x,
                    MinigameSceneState.spawnAreas["sugar_minigame_barrier"].y, MinigameSceneState.spawnAreas["sugar_minigame_barrier"].w, MinigameSceneState.spawnAreas["sugar_minigame_barrier"].h
                )
                Minigame.state.lockedExit = true
            end

            Minigame.state.vincentMoveCooldown = Minigame.state.vincentMoveCooldown - elapsed
            if Minigame.state.vincentMoveCooldown <= 0 then
                -- Calcule direção
                local dx = MinigameSceneState.player.x - Minigame.chars["vincent"].hitbox.x
                local dy = MinigameSceneState.player.y - Minigame.chars["vincent"].hitbox.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist > 0 then
                    local step = 8 -- pixels por passo, ajuste como quiser
                    Minigame.chars["vincent"].hitbox.x = Minigame.chars["vincent"].hitbox.x + (dx / dist) * math.min(step, dist)
                    Minigame.chars["vincent"].hitbox.y = Minigame.chars["vincent"].hitbox.y + (dy / dist) * math.min(step, dist)
                end
                AudioSources["sfx_guard_run"]:play()
                Minigame.state.vincentMoveCooldown = 0.18
            end

            if collision.rectRect(MinigameSceneState.player.hitbox, Minigame.chars["vincent"].hitbox) then
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