local SecretAnimatronic = require 'src.Modules.Game.SecretNight.SecretAnimatronic'
local Frankburt = SecretAnimatronic:extend("Frankburt")

---@class Frankburt : SecretAnimatronic
function Frankburt:__construct()
    SecretAnimatronic.__construct(self, "frankburt", 8)

    self.validStates = { "idle", "front", "right", "office" }
    self.active = false -- Activated after 14 seconds

    -- Hitboxes for defending with lantern
    self.hitboxes = {
        ["front"] = { x = 890, y = 230, w = 280, h = 180 },
        ["right"] = { x = 1390, y = 200, w = 220, h = 230 }
    }

    -- Timer for periodic movement attempts
    self.moveTimer = timer.new()

    -- Set up movement callback
    self.onMove = function()
        self:attemptMove()
    end

    -- Set up timer.every callback for 8 second intervals
    self.moveTimer:every(8, function()
        if self.active and self.currentState == "idle" and SecretNightState.IA.goldenShower.currentState == "idle" then
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
---Ranges from 8 (high integrity) to 16 (low integrity)
function Frankburt:getAI()
    local furnace = SecretNightState.officeState.furnace
    if not furnace then
        return 8
    end

    local vincentIntegrity = furnace.vincentIntegrity or 100
    local ia = math.floor(math.map(vincentIntegrity, 100, 0, 8, 16))

    return math.clamp(ia, 0, 20)
end

---Attempt to move to a new state
function Frankburt:attemptMove()
    -- Only move if can move and not attacking
    if not self.active or self.attacking then
        return
    end

    -- Check if Golden Shower is also idle (don't both attack at same time)
    local goldenShower = SecretNightState.IA.goldenShower
    if goldenShower and goldenShower.attacking then
        return
    end

    self:playWalk()
    SecretNightState.officeState.blink.alpha = 1

    -- Choose new state with weighted random
    local newState = lume.weightedchoice({
        ["front"] = 40,
        ["right"] = 60,
        ["office"] = 10
    })

    self.currentState = newState
    self.patience = math.random(3, 6)
    self.attacking = true
end

---Update state logic with custom office behavior
function Frankburt:updateState(elapsed)
    if self.currentState == "idle" then
        return
    end

    -- Decrement patience
    self.patience = self.patience - elapsed

    -- Check if patience expired
    if self.patience <= 0 then
        if self.currentState == "office" then
            -- In office: immediate death if lantern is active
            if SecretNightState.officeState.flashlight.active then
                self:kill()
            else
                -- No lantern: return to idle
                self.currentState = "idle"
                self.attacking = false
            end
        else
            -- In front or right: check defense
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
end

---Activate Frankburt (called after initial delay)
function Frankburt:activate()
    self.active = true
end

---Update method for timer.every callbacks - must be called from SecretNightState
function Frankburt:onUpdate(elapsed)
    if self.active then
        self.moveTimer:update(elapsed)
    end
end

return Frankburt
