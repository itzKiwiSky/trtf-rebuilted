local SecretAnimatronic = class:extend("SecretAnimatronic")

---@class SecretAnimatronic
---@id string the animatronic id
---@secretNightState SecretNightState reference to secret night state for dynamic AI
---@moveTime number interval between AI checks in seconds
function SecretAnimatronic:__construct(id, moveTime)
    self.id = id

    -- Timer and movement accumulator (from base Animatronic)
    self.timer = 0
    self.moveTime = moveTime or 8
    self.moveAccumulator = 0

    -- State management
    self.currentState = "idle"
    self.validStates = {} -- Override in subclasses
    self.patience = 0
    self.attacking = false

    -- Combat properties
    self.hitboxes = {} -- Define in subclasses: {["front"] = {x, y, w, h}, ...}

    -- Callback for movement logic (override in subclasses)
    self.onMove = function() end
end

---Get the dynamic AI value (override in subclasses)
---Should return a value between 0-20
function SecretAnimatronic:getAI()
    return 0
end

---Check if player has lantern active and in hitbox
function SecretAnimatronic:isPlayerDefending()
    if not self.hitboxes[self.currentState] then
        return false
    end

    local flashlight = SecretNightState.officeState.flashlight
    local inside, mx, my = shove.mouseToViewport()

    -- Lantern must be active and bright enough
    if flashlight.alpha < 0.3 or flashlight.battery <= 1 then
        return false
    end

    -- Check collision with hitbox
    local hitbox = self.hitboxes[self.currentState]
    return collision.pointRect({ x = mx, y = my }, hitbox)
end

---Play walk sound
function SecretAnimatronic:playWalk()
    local r = math.random(1, 3)
    if not AudioSources["sfx_metalwalk" .. r]:isPlaying() then
        AudioSources["sfx_metalwalk" .. r]:play()
    end
end

---Kill the player (override if custom death sequence needed)
function SecretAnimatronic:kill()
    if not SecretNightState.officeState.killed then
        SecretNightState.officeState.killed = true
        for k, v in pairs(AudioSources) do
            v:stop()
        end
        if SecretNightState.officeState.lookDir == "front" then
            SecretNightState.jumpscareFront:setState(false)
        else
            SecretNightState.jumpscareBack:setState(false)
        end
        AudioSources["sfx_lockjaw_jumpscare"]:setVolume(1.2)
        AudioSources["sfx_lockjaw_jumpscare"]:play()
    end
end

---Update state logic (patience, defense, death) - override in subclasses for custom behavior
function SecretAnimatronic:updateState(elapsed)
    if self.currentState == "idle" then
        return
    end

    -- Decrement patience
    self.patience = self.patience - elapsed

    -- Check if patience expired
    if self.patience <= 0 then
        if self:isPlayerDefending() then
            -- Player defended successfully
            self.currentState = "idle"
            self.attacking = false
            self.patience = 0
        else
            -- Player failed to defend
            self:kill()
        end
    end
end

---Main update loop - handles state-specific logic only
---Timer.every callbacks are handled in subclass timers
---@param elapsed number delta time
function SecretAnimatronic:update(elapsed)
    if not SecretNightState.officeState.nightStarted then
        return
    end

    -- Update state-specific logic (patience, defense, death)
    self:updateState(elapsed)
end

---Draw the animatronic (override in subclasses)
function SecretAnimatronic:draw()
    -- Override in subclasses
end

---Update timers and external callbacks (called separately for timer management)
function SecretAnimatronic:onUpdate(elapsed)
    -- Override in subclasses if needed for timer callbacks
end

return SecretAnimatronic
