local Minigames = {}

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function Minigames:load()
    self.assets = {}
    local f = love.filesystem.getDirectoryItems("assets/images/game/extras/thumbs")
    for _, file in ipairs(f) do
        self.assets[file:gsub("%.[^.]+$", "")] = love.graphics.newImage("assets/images/game/extras/thumbs/" .. file)
    end

    print(inspect(self.assets))

    loveView.loadView("src/Modules/Game/Views/MinigameSelector.lua")
end

function Minigames:draw()
    loveView.draw()
end

function Minigames:update(elapsed)
    loveView.update(elapsed)
end

function Minigames:mousepressed(x, y, button)
    
end

return Minigames