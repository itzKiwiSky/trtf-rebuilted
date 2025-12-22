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

    Minigame.allUnhappy = false
    Minigame.showFace = false
    Minigame.flashFace = false
    Minigame.waitTimer = 0
    Minigame.seqPlaying = false
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
    MinigameSceneState.player.lastDirection = "left"
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)

    local spawns = findByKeyPrefix(MinigameSceneState.spawnAreas, "spawn_box")
    Minigame.boxes = {}
    for _, spawn in ipairs(spawns) do
        --print(spawn)
        local x = spawn.centerX
        local y = spawn.centerY
        local w = spawn.w
        local h = spawn.h

        local prop = Minigame.statues:new(
            Minigame.assets["collectibles"].img,
            Minigame.assets["collectibles"].quads["box_prop"],
            x, y, false, true
        )

        prop.hitbox.x = x
        prop.hitbox.y = y
        prop.hitbox.w = w
        prop.hitbox.h = h

        MinigameSceneState.world:add(prop.hitbox, prop.hitbox.x, prop.hitbox.y, prop.hitbox.w, prop.hitbox.h)
        table.insert(Minigame.boxes, prop)
    end
    --print(inspect(MinigameSceneState.spawnAreas))
end

function Minigame.draw()
    for _, box in ipairs(Minigame.boxes) do
        box:draw()
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
