local Player = {}

Player.sprite = "freddy"
Player.name = "player"
Player.drawOffset = {
    x = 12,
    y = 16,
}
Player.x = 0
Player.y = 0
Player.dx = 0
Player.dy = 0
Player.w = 32
Player.h = 32
Player.hitbox = {
    x = Player.x,
    y = Player.y,
    w = 16,
    h = 20,
}
Player.lastDirection = "down"
Player.speed = 900
Player.locked = false
Player.lastLockState = Player.locked
Player.lockCooldown = 2
Player.lockCooldownMax = 2

Player.cooldown = {
    left = 0,
    right = 0,
    up = 0,
    down = 0,
}

Player.teleported = false
Player.isMoving = false
Player.animation = {
    frame = 1,
    acc = 0,
    speed = 1 / 5,
    loop = true,
    maxFrames = 2,
}

Player.maxCooldown = 0.45

---Define the player position
---@param x number
---@param y number
function Player.setPos(x, y)
    -- destroy the old hitbox and add to the world with the new position --
    MinigameSceneState.world:update(Player.hitbox, x, y, Player.hitbox.w, Player.hitbox.h)
    Player.x, Player.y, len, col = MinigameSceneState.world:move(Player.hitbox, x, y, function(item, other)
        --if item.kind == "solid" then
        return other.kind == "solid" and "cross" or "cross"
    end)

    Player.hitbox.x = Player.x
    Player.hitbox.y = Player.y
    Player.teleported = true
    --Player.hitbox.x = Player.x
    --Player.hitbox.y = Player.y
end

function Player.draw()
    love.graphics.draw(MinigameSceneState.animatronicSprites, 
        MinigameSceneState.animSets[Player.sprite][Player.lastDirection][Player.animation.frame], 
        Player.x - Player.drawOffset.x, Player.y - Player.drawOffset.y, 0, 1.2, 1.2
    )

    if registers.showDebugHitbox then
        love.graphics.print(string.format("locked:%s\ncooldownLock:%s", tostring(Player.locked), Player.lockCooldown), Player.x + 32, Player.y - 32, 0, 0.6, 0.6)
    end
end

function Player.update(elapsed)
    for k, v in pairs(Player.cooldown) do
        if Player.cooldown[k] > 0 then
            Player.cooldown[k] = Player.cooldown[k] - elapsed
        end
    end

    -- animation shit --
    Player.animation.acc = Player.animation.acc + elapsed
    if Player.isMoving or Player.lastDirection == "misc" then
        if Player.animation.acc >= Player.animation.speed then
            Player.animation.frame = Player.animation.frame + 1
            Player.animation.acc = 0
            if Player.animation.frame > Player.animation.maxFrames then
                Player.animation.frame = 1
            end
        end
        AudioSources["sfx_animatronic_step"]:setVolume(0.25)
        AudioSources["sfx_animatronic_step"]:play()
    end

    if not Player.locked then
        local dx, dy = 0, 0
        if Controller:down("player_move_left") and Player.cooldown.left <= 0 then
            dx = -Player.speed * elapsed
            Player.lastDirection = "left"
            Player.cooldown.left = Player.maxCooldown
        end
        if Controller:down("player_move_right") and Player.cooldown.right <= 0 then
            dx = Player.speed * elapsed
            Player.lastDirection = "right"
            Player.cooldown.right = Player.maxCooldown
        end
        if Controller:down("player_move_up") and Player.cooldown.up <= 0 then
            dy = -Player.speed * elapsed
            Player.lastDirection = "up"
            Player.cooldown.up = Player.maxCooldown
        end
        if Controller:down("player_move_down") and Player.cooldown.down <= 0 then
            dy = Player.speed * elapsed
            Player.lastDirection = "down"
            Player.cooldown.down = Player.maxCooldown
        end
        
        if dx ~= 0 or dy ~= 0 or Player.teleported then
            Player.isMoving = true
            Player.teleported = false
            Player.x, Player.y, len, col = MinigameSceneState.world:move(Player.hitbox, Player.hitbox.x + dx, Player.hitbox.y + dy, function(item, other)
                --if item.kind == "solid" then
                return other.kind == "solid" and "touch" or "cross"
            end)
        
            Player.hitbox.x = Player.x
            Player.hitbox.y = Player.y
        else
            Player.isMoving = false
        end
    end
end

return Player