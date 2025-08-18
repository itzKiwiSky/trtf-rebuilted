local JumpscareController = {}

JumpscareController.frames = NightState.assets.jumpscares
JumpscareController.visible = false
JumpscareController.id = ""
JumpscareController.frame = 1
JumpscareController.acc = 0
JumpscareController.speedAnim = 32
JumpscareController.active = false
JumpscareController.playAudio = true
JumpscareController.audioVolume = 1.5
JumpscareController.stopAllAudio = true
JumpscareController.onComplete = function()end

function JumpscareController.init()
    JumpscareController.frame = 1
    JumpscareController.active = true
    JumpscareController.visible = true

    if JumpscareController.stopAllAudio then
        for k, v in pairs(AudioSources) do
            v:stop()
        end
    end

    if JumpscareController.playAudio then
        AudioSources["sfx_jumpscare"]:setVolume(JumpscareController.audioVolume)
        AudioSources["sfx_jumpscare"]:play()
    end
end

function JumpscareController.draw()
    if JumpscareController.visible then
        if JumpscareController.frames[JumpscareController.id]["jmp_" .. JumpscareController.frame] then
            love.graphics.draw(JumpscareController.frames[JumpscareController.id]["jmp_" .. JumpscareController.frame], 0, 0, 0, 
                shove.getViewportWidth() / JumpscareController.frames[JumpscareController.id]["jmp_" .. JumpscareController.frame]:getWidth(), 
                shove.getViewportHeight() / JumpscareController.frames[JumpscareController.id]["jmp_" .. JumpscareController.frame]:getHeight()
            )
        end
    end
end

function JumpscareController.update(elapsed)
    if JumpscareController.active then    
        JumpscareController.acc = JumpscareController.acc + elapsed
        if JumpscareController.acc >= (1 / JumpscareController.speedAnim) then
            JumpscareController.acc = 0
            JumpscareController.frame = JumpscareController.frame + 1
            if JumpscareController.frame >= JumpscareController.frames[JumpscareController.id].frameCount - 1 then
                JumpscareController.frame = JumpscareController.frames[JumpscareController.id].frameCount
                JumpscareController.active = false
                JumpscareController.onComplete()
            end
        end
    end
end

return JumpscareController