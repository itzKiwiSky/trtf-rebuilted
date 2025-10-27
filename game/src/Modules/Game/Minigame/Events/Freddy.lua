local Minigame = {}

function Minigame.init()
    MinigameSceneState.displayFace.currentFace = "freddy"

    MinigameSceneState.displayDate = "1-11-2006"
    MinigameSceneState.displayText = languageService["minigame_display_freddy_collect_gift"]

    AudioSources["msc_bg_freddy"]:play()
    AudioSources["msc_bg_freddy"]:setLooping(true)
    AudioSources["msc_bg_freddy"]:setVolume(0.75)

    local gifts = {}

    --MinigameSceneState.spawnAreas["bonnie_child_minigame"] 
    local playerPos = MinigameSceneState.spawnAreas["freddy"]
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)
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