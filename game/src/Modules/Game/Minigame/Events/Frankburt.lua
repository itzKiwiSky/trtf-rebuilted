local Minigame = {
    assets = {},
    childs = {},
}

---@param t table
---@param prefix string
---@return table
local function findByKeyPrefix(t, prefix)
    local result = {}

    for k, v in pairs(t) do
        if type(k) == "string" and k:sub(1, #prefix) == prefix then
            table.insert(result, v)
        end
    end

    return result
end

function Minigame.init()
    MinigameSceneState.displayFace.currentFace = "lockjaw"
    Minigame.statues = require 'src.Modules.Game.Minigame.Statues'
    Minigame.guard = require 'src.Modules.Game.Minigame.NightGuard'

    Minigame.allUnhappy = false
    Minigame.showFace = false
    Minigame.flashFace = false
    Minigame.waitTimer = 0
    Minigame.seqPlaying = false

    state = {
        vincentScream = false,
        vincentPutMask = false,
        vincentMoveCooldown = 0.25,
        lockedExit = false,
        frankInsideOffice = false,
    }

    -- set player pos --/
    AudioSources["msc_bg_lockjaw"]:play()
    AudioSources["msc_bg_lockjaw"]:setLooping(true)
    AudioSources["msc_bg_lockjaw"]:setVolume(0.75)

    Minigame.gifts = {}
    Minigame.assets["collectibles"] = { img = nil, quads = {} }
    Minigame.assets["collectibles"].img = love.graphics.newImage("assets/images/game/minigames/collectibles.png")
    Minigame.assets["collectibles"].quads = love.graphics.getQuads(Minigame.assets["collectibles"].img, "assets/images/game/minigames/collectibles.json", "hash")

    MinigameSceneState.displayDate = "11-11-2005"
    MinigameSceneState.displayText = languageService["minigame_display_lockjaw_kill_purple"]
    local playerPos = MinigameSceneState.spawnAreas["lockjaw"]
    MinigameSceneState.player.sprite = "lockjaw"
    MinigameSceneState.player.lastDirection = "down"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)

    local spawns = findByKeyPrefix(MinigameSceneState.spawnAreas, "spawn_box")
    Minigame.boxes = {}
    for _, spawn in ipairs(spawns) do
        local x = spawn.centerX
        local y = spawn.centerY
        local w = spawn.w
        local h = spawn.h

        local prop = Minigame.statues:new(
            Minigame.assets["collectibles"].img,
            Minigame.assets["collectibles"].quads["box_prop"],
            x, y, false, true
        )

        prop.drawOffset.x = -16
        prop.drawOffset.y = -16

        prop.hitbox.x = spawn.x
        prop.hitbox.y = spawn.y
        prop.hitbox.w = w
        prop.hitbox.h = h

        MinigameSceneState.world:add(prop.hitbox, prop.hitbox.x, prop.hitbox.y, prop.hitbox.w, prop.hitbox.h)
        table.insert(Minigame.boxes, prop)
    end

    Minigame.chars = {}

    local guardImg = love.graphics.newImage("assets/images/game/minigames/vincent.png")
    local animQuads = love.graphics.getQuads(guardImg, "assets/images/game/minigames/vincent.json", "hash")

    local guard = Minigame.guard:new({ img = guardImg, quads = animQuads },
        MinigameSceneState.spawnAreas["vincent_lockjaw"].centerX, MinigameSceneState.spawnAreas["vincent_lockjaw"].centerY,
        true
    )
    guard.flipped = false
    --lockjaw_tp_zone

    Minigame.chars["vincent"] = guard
    --print(inspect(MinigameSceneState.spawnAreas))

    Minigame.tmr_script = timer.new()
    Minigame.tmr_script:script(function(sleep)
        AudioSources["sfx_beep"]:setVolume(1)
        AudioSources["sfx_beep"]:play()
        sleep(2)
        Minigame.chars["vincent"].state = "scared"
        AudioSources["sfx_guard_scream"]:play()
        sleep(1)
        Minigame.chars["vincent"].flipped = true
        sleep(1)
        Minigame.chars["vincent"].flipped = false
        sleep(1)
        Minigame.chars["vincent"].flipped = true
        sleep(1)
        Minigame.chars["vincent"].flipped = false
        sleep(1.1)
        Minigame.chars["vincent"].state = "front"
        sleep(1)
        state.vincentPutMask = true
        sleep(1)
        MinigameSceneState.player.locked = false
    end)
end

function Minigame.draw()
    for _, box in ipairs(Minigame.boxes) do
        box:draw()
    end

    for anim, char in pairs(Minigame.chars) do
        char:draw()
        if anim == "vincent" then
            if state.vincentPutMask then
                love.graphics.draw(Minigame.assets["collectibles"].img, Minigame.assets["collectibles"].quads["freddy_mask"], char.hitbox.x + 4, char.hitbox.y - 8, 0, 1.25, 1.25, 0, 0)
            end
        end
    end
end

function Minigame.update(elapsed)
    if collision.rectRect(MinigameSceneState.player.hitbox, MinigameSceneState.map.actionAreas["lockjaw_minigame_window"]) and not state.frankInsideOffice then
        --state.vincentScream = true
        local tp = MinigameSceneState.spawnAreas["lockjaw_tp_zone"]
        MinigameSceneState.player.locked = true
        MinigameSceneState.player.lastDirection = "down"
        AudioSources["msc_bg_lockjaw"]:stop()
        MinigameSceneState.player.isMoving = false
        state.frankInsideOffice = true
        MinigameSceneState.player.setPos(tp.x, tp.y)
    end

    if collision.rectRect(MinigameSceneState.player.hitbox, Minigame.chars["vincent"].hitbox) and not MinigameSceneState.isShuttingDown then
        MinigameSceneState.isShuttingDown = true
        MinigameSceneState.player.isMoving = false
        MinigameSceneState.player.locked = true
        MinigameSceneState.interferenceIntensity = 60
        MinigameSceneState.interferenceSpeed = 150
        MinigameSceneState.interferenceFX:send("intensity", MinigameSceneState.interferenceIntensity)
        MinigameSceneState.interferenceFX:send("speed", MinigameSceneState.interferenceSpeed)

        AudioSources["sfx_minigame_shutdown"]:setLooping(true)
        AudioSources["sfx_minigame_shutdown"]:play()
    end

    if state.frankInsideOffice then
        Minigame.tmr_script:update(elapsed)
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
