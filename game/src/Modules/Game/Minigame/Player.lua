local Player = {}

Player.name = "player"
Player.x = x
Player.y = y
Player.dx = 0
Player.dy = 0
Player.w = 24
Player.h = 30
Player.speed = 900

Player.cooldown = {
    left = 0,
    right = 0,
    up = 0,
    down = 0,
}

Player.maxCooldown = 0.05

function Player.draw()
    love.graphics.setColor(1, 1, 0.2, 1)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.w, Player.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function Player.update(elapsed)
    for k, v in pairs(Player.cooldown) do
        if Player.cooldown[k] > 0 then
            Player.cooldown[k] = Player.cooldown[k] - elapsed
        end

        --Player.cooldown[k] = math.clamp(Player.cooldown[k], 0, 0.05)
    end

    local dx, dy = 0, 0
    if Controller:down("player_move_left") and Player.cooldown.left <= 0 then
        dx = -Player.speed * elapsed
        Player.cooldown.left = Player.maxCooldown
    end
    if Controller:down("player_move_right") and Player.cooldown.right <= 0 then
        dx = Player.speed * elapsed
        Player.cooldown.right = Player.maxCooldown
    end
    if Controller:down("player_move_up") and Player.cooldown.up <= 0 then
        dy = -Player.speed * elapsed
        Player.cooldown.up = Player.maxCooldown
    end
    if Controller:down("player_move_down") and Player.cooldown.down <= 0 then
        dy = Player.speed * elapsed
        Player.cooldown.down = Player.maxCooldown
    end
    
    if dx ~= 0 or dy ~= 0 then
        Player.x, Player.y = MinigameSceneState.world:move(Player, Player.x + dx, Player.y + dy)
    end
end

return Player