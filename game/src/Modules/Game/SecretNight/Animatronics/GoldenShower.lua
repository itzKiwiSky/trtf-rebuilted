local SecretAnimatronic = require 'src.Modules.Game.SecretNight.SecretAnimatronic'
local GoldenShower = SecretAnimatronic:extend("GoldenShower")

---@class GoldenShower : SecretAnimatronic
function GoldenShower:__construct()
    SecretAnimatronic.__construct(self, "golden_shower", 10)

    self.validStates = { "idle", "front", "right", "back" }
    self.state = "idle"

    -- Visual fade effect for jumpscare
    self.fade = 0
    self.fadeMulti = 1.2

    -- Hitboxes for defending with lantern
    self.hitboxes = {
        ["front"] = { x = 872, y = 362, w = 316, h = 169 },
        ["right"] = { x = 1350, y = 200, w = 240, h = 240 }
    }

    -- Timer for periodic movement attempts
    self.moveTimer = timer.new()

    -- Set up movement callback
    self.onMove = function()
        self:attemptMove()
    end

    -- Set up timer.every callback for 10 second intervals
    self.moveTimer:every(10, function()
        if self.currentState == "idle" and SecretNightState.IA.frankburt.currentState ~= "idle" then
            local ia = self:getAI()
            if ia > 0 then
                -- Roll RNG
                if ia >= math.random(1, 20) then
                    self:onMove()
                end
            end
        end
    end)
end

---Get dynamic IA based on Vincent's integrity
---Ranges from 8 (high integrity) to 20 (low integrity)
function GoldenShower:getAI()
    local furnace = SecretNightState.officeState.furnace
    if not furnace then
        return 8
    end

    local vincentIntegrity = furnace.vincentIntegrity or 100
    local ia = math.floor(math.map(vincentIntegrity, 100, 0, 8, 20))

    return math.clamp(ia, 0, 20)
end

---Attempt to move to a new state
function GoldenShower:attemptMove()
    if self.attacking then
        return
    end

    -- Only move if Frankburt is attacking
    local frankburt = SecretNightState.IA.frankburt
    if not frankburt or not frankburt.attacking then
        return
    end

    SecretNightState.officeState.blink.alpha = 1

    -- Choose new state with weighted random
    local newState = lume.weightedchoice({
        ["front"] = 40,
        ["right"] = 60,
        ["back"] = 10
    })

    self.currentState = newState
    self.patience = math.random(3, 6)
    self.attacking = true
end

---Update state logic with custom back behavior and fade
function GoldenShower:updateState(elapsed)
    -- Update fade effect
    if self.fade > 0 then
        self.fade = self.fade - elapsed * self.fadeMulti
    end

    if self.currentState == "idle" then
        return
    end

    -- Decrement patience
    self.patience = self.patience - elapsed

    -- Check if patience expired
    if self.patience <= 0 then
        if self.currentState == "back" then
            -- Back state: check if player is looking back
            if SecretNightState.officeState.lookDir == "back" then
                -- Auto jumpscare
                self.fade = 1
                self:playJumpscare()
                self.currentState = "idle"
                self.attacking = false
            else
                -- Not looking back, just return to idle
                self.currentState = "idle"
                self.attacking = false
            end
        else
            -- Front or right: check defense
            if self:isPlayerDefending() then
                -- Player defended successfully
                self.currentState = "idle"
                self.attacking = false
                self.patience = 0
            else
                -- Player failed to defend
                self.fade = 1
                self:playJumpscare()
                self.currentState = "idle"
                self.attacking = false
            end
        end
    end
end

---Play the jumpscare effect
function GoldenShower:playJumpscare()
    if AudioSources["sfx_golden_freddy_jumpscare"] then
        AudioSources["sfx_golden_freddy_jumpscare"]:seek(0)
        AudioSources["sfx_golden_freddy_jumpscare"]:play()
    end
end

---Draw the Golden Shower sprite
function GoldenShower:draw()
    local assets = SecretNightState.assets

    if self.currentState == "idle" then
        return
    end

    local lookDir = SecretNightState.officeState.lookDir

    if lookDir == "front" then
        if self.currentState == "front" or self.currentState == "right" then
            local sprite = assets.office.sprites.golden_shower[self.currentState]
            if sprite then
                love.graphics.draw(sprite, 0, 0)
            end
        end
    elseif lookDir == "back" then
        if self.currentState == "back" then
            local halluSprite = assets.office.hallu.golden_shower_back
            if halluSprite then
                love.graphics.draw(halluSprite, 0, 0)
            end
        end
    end
end

---Update method for timer callbacks
function GoldenShower:onUpdate(elapsed)
    self.moveTimer:update(elapsed)
end

return GoldenShower
