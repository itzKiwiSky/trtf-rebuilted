local Minigame = {}

function Minigame.init()
    
end

function Minigame.draw()
    
end

function Minigame.update(elapsed)
    
end

function Minigame.shutdown()
    -- release all assets used in the minigame --
    for k, asset in pairs(Minigame.assets) do
        if type(asset) == "userdata" then
            asset:release()
        end
    end
end

return Minigame