NightShiftState = {}

function NightShiftState:init()

    -- shader projection --
    shd_projection = love.graphics.newShader("assets/shaders/projection.glsl")

    -- asset loading --
    room = {}   -- room binding --
    local roomStates = love.filesystem.getDirectoryItems("assets/images/games/night8/room")
    for s = 1, #roomStates, 1 do
        if love.filesystem.getInfo("assets/images/games/night8/room/" .. roomStates[s]).type == "directory" then
            room[roomStates[s]:lower()] = {
                ["idle"] = love.graphics.newImage("assets/images/games/night8/room/" .. roomStates[s] .. "/idle.png"),
                ["light"] = love.graphics.newImage("assets/images/games/night8/room/" .. roomStates[s] .. "/light.png")
            }
        end
    end
end

function NightShiftState:enter()

end

function NightShiftState:draw()

end

function NightShiftState:update(elapsed)

end

return NightShiftState 