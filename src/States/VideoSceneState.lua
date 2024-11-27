VideoSceneState = {}

VideoSceneState.path = ""
VideoSceneState.onSceneComplete = function()end
VideoSceneState.targetState = nil

function VideoSceneState:enter()
    
    sceneRun = love.graphics.newVideo(VideoSceneState.path)
    sceneRun:play()
end

function VideoSceneState:draw()
    love.graphics.draw(sceneRun, 0, 0)
end

function VideoSceneState:update(elapsed)
    if not sceneRun:isPlaying() then
        gamestate.switch(VideoSceneState.targetState)
    end
end

function VideoSceneState:leave()
    sceneRun:release()
    VideoSceneState.onSceneComplete()
end

return VideoSceneState