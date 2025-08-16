local Minigame = {
    assets = {},
    childs = {},
}

function Minigame.init()
    MinigameSceneState.displayFace.currentFace = "bonnie"
    Minigame.Child = require 'game.src.Modules.Game.Minigame.Child'
    Minigame.allUnhappy = false
    Minigame.showFace = false
    Minigame.flashFace = false
    Minigame.waitTimer = 0
    Minigame.seqPlaying = false
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
    Minigame.assets.bonnieFace = love.graphics.newImage("assets/images/game/minigames/aftergame/bonnie.png")
    
    for i = 1, 6, 1 do
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
        if collision.rectRect(c.hitbox, MinigameSceneState.player.hitbox) and not c.inCooldown then
            if Controller:pressed("player_action") then
                MinigameSceneState.player.lastDirection = "misc"
                MinigameSceneState.player.animation.speed = 1 / 2
                MinigameSceneState.player.locked = true

            end

            if MinigameSceneState.player.locked then
                MinigameSceneState.player.lockCooldown = MinigameSceneState.player.lockCooldown - elapsed
                if MinigameSceneState.player.lockCooldown <= 0 then
                    MinigameSceneState.player.locked = false
                    MinigameSceneState.player.lockCooldown = MinigameSceneState.player.lockCooldownMax
                    MinigameSceneState.player.animation.speed = 1 / 5
                    MinigameSceneState.player.lastDirection = "down"
                    
                    c.happiness = 100
                end
            end
        end
    end

    local allUnhappy = true
    for _, c in ipairs(Minigame.childs) do
        if c.canBeHappy then
            allUnhappy = false
            break
        end
    end

    if allUnhappy and not Minigame.seqPlaying then
        Minigame.seqPlaying = true
        MinigameSceneState.isShuttingDown = true
        MinigameSceneState.interferenceIntensity = 50
        MinigameSceneState.interferenceSpeed = 140
        MinigameSceneState.interferenceFX:send("intensity", MinigameSceneState.interferenceIntensity)
        MinigameSceneState.interferenceFX:send("speed", MinigameSceneState.interferenceSpeed)
        Minigame.allUnhappy = true
        AudioSources["msc_bg_bonnie"]:stop()
        AudioSources["sfx_minigame_shutdown"]:setLooping(true)
        AudioSources["sfx_minigame_shutdown"]:play()
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