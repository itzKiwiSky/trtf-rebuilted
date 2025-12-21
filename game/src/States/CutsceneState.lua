CutsceneState = {}

local function loadBulk(key, path)
    local b = {}
    b.frameCount = 0
    local a = love.filesystem.getDirectoryItems(path)
    for s = 1, #a, 1 do
        --love.graphics.newImage(b, key .. s, path .. a[s])
        b[key .. s] = love.graphics.newImage(path .. a[s])
        b.frameCount = s
    end
    a = nil
    collectgarbage("collect")
    return b
end

function CutsceneState:enter()
    self.assets = {
        ["mask"] = love.graphics.newImage("assets/images/game/cutscene/mask.png"),
        ["office"] = love.graphics.newImage("assets/images/game/cutscene/mask.png"),
        ["shadow"] = {
            ["saludos"] = {
                ["saludo1"] = loadBulk("hi_", "assets/images/game/cutscene/shadow_hi1/"),
                ["saludo2"] = loadBulk("hi_", "assets/images/game/cutscene/shadow_hi2/"),
                ["saludo3"] = loadBulk("hi_", "assets/images/game/cutscene/shadow_hi3/"),
            }
        }
    }
end

function CutsceneState:draw()

end

function CutsceneState:update(elapsed)

end

return CutsceneState
