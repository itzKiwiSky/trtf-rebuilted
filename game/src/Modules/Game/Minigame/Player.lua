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

Player.cooldown = {
    left = 0,
    right = 0,
    up = 0,
    down = 0,
}

Player.isMoving = false
Player.animation = {
    frame = 1,
    acc = 0,
    speed = 1 / 20,
    loop = true,
    maxFrames = 2,
}

Player.maxCooldown = 0.13

function Player.draw()
    love.graphics.draw(MinigameSceneState.animatronicSprites, 
        MinigameSceneState.animSets[Player.sprite][Player.lastDirection][Player.animation.frame], 
        Player.x - Player.drawOffset.x, Player.y - Player.drawOffset.y, 0, 1.2, 1.2
    )

end

function Player.update(elapsed)
    for k, v in pairs(Player.cooldown) do
        if Player.cooldown[k] > 0 then
            Player.cooldown[k] = Player.cooldown[k] - elapsed
        end
    end

    -- animation shit --
    Player.animation.acc = Player.animation.acc + elapsed
    if Player.isMoving then
        if Player.animation.acc >= Player.animation.speed then
            Player.animation.frame = Player.animation.frame + 1
            Player.animation.acc = 0
            if Player.animation.frame > Player.animation.maxFrames then
                Player.animation.frame = 1
            end
        end
    end

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
    
    if dx ~= 0 or dy ~= 0 then
        Player.isMoving = true
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

return Player