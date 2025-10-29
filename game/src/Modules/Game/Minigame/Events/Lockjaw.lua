local Minigame = {
    assets = {},
    childs = {},
}

function Minigame.init()
    MinigameSceneState.displayFace.currentFace = "bonnie"
    Minigame.Child = require 'game.src.Modules.Game.Minigame.Child'
    Minigame.allUnhappy = false
    Minigame.showFace = false
    Minigame.flashFace = false
    Minigame.waitTimer = 0
    Minigame.seqPlaying = false
    -- set player pos --
    AudioSources["msc_bg_bonnie"]:play()
    AudioSources["msc_bg_bonnie"]:setLooping(true)
    AudioSources["msc_bg_bonnie"]:setVolume(0.75)

    MinigameSceneState.displayDate = "1-11-2005"
    MinigameSceneState.displayText = languageService["minigame_display_bonnie_entertain_child"]
    local playerPos = MinigameSceneState.spawnAreas["freddy"]
    MinigameSceneState.player.sprite = "lockjaw"
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