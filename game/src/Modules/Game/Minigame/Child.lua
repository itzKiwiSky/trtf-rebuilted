local Child = {}

Child.state = "idle"
Child.assets = {img = nil, quads = {}}
Child.hitbox = {
    x = 0,
    y = 0,
    w = 16,
    h = 16,
}
Child.drawOffset = {
    x = 0,
    y = 0,
}

Child.happiness = 100
Child.hapDecreaseTimer = 0
Child.hapDecreaseTimerMax = 0.75

Child.animation = {
    frame = 1,
    acc = 0,
    speed = 1 / 20,
    loop = true,
    maxFrames = 2,
}

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function Child.draw()
    if type(Child.assets.img) == nil or #Child.assets.quads <= 0 then return end
    love.graphics.draw(Child.assets.img, Child.assets.quads[Child.state][Child.frame], Child.hitbox.x - Child.drawOffset.x, Child.hitbox.y - Child.drawOffset.y, 0, 1, 1)

    if registers.showDebugHitbox then
        drawBox(Child.hitbox, 0.4, 0.5, 0.1)
    end
end

function Child.update(elapsed)
    Child.animation.acc = Child.animation.acc + elapsed
    if Child.animation.acc >= Child.animation.speed then
        Child.animation.frame = Child.animation.frame + 1
        Child.animation.acc = 0
        if Child.animation.frame > Child.animation.maxFrames then
            Child.animation.frame = 1
        end
    end

    Child.hapDecreaseTimer = Child.hapDecreaseTimer + elapsed
    if Child.hapDecreaseTimer >= Child.hapDecreaseTimerMax then
        Child.hapDecreaseTimer = 0
        Child.happiness = Child.happiness - math.random(2, 4)
    end
    
    if Child.happiness >= 75 then
        Child.state = "idle"
    elseif Child.happiness >= 50 then
        Child.state = "midder"
    elseif Child.happiness >= 25 then
        Child.state = "angry"
    end
end

return Child