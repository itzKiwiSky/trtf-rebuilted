local Player = {}

Player.name = "player"
Player.x = 0
Player.y = 0
Player.dx = 0
Player.dy = 0
Player.w = 24
Player.h = 30
Player.hitbox = {
    x = Player.x,
    y = Player.y,
    w = Player.w - 4,
    h = Player.h - 16,
}
Player.lastDoorID = ""
Player.speed = 900

Player.cooldown = {
    left = 0,
    right = 0,
    up = 0,
    down = 0,
}

Player.maxCooldown = 0.5

local function drawBox(box, r, g, b)
    love.graphics.setLineWidth(3)
    love.graphics.setColor(r / 255, g / 255, b / 255, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r / 255, g / 255, b / 255, 1)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function Player.draw()
    love.graphics.setColor(1, 1, 0, 0.5)
    love.graphics.rectangle("line", Player.x, Player.y, Player.w, Player.h)
    love.graphics.setColor(1, 1, 1, 1)

    --drawBox(Player.hitbox, 127, 100, 0)
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
        Player.x, Player.y, len, col = MinigameSceneState.world:move(Player.hitbox, Player.hitbox.x + dx, Player.hitbox.y + dy, function(item, other)
            --if item.kind == "solid" then
            return other.kind == "solid" and "touch" or "cross"
        end)
    
        Player.hitbox.x = Player.x
        Player.hitbox.y = Player.y
    end
end

return Player