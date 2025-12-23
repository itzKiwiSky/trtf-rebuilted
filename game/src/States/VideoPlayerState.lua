VideoPlayerState = {}

VideoPlayerState.path = ""
VideoPlayerState.onSceneComplete = function() end
VideoPlayerState.targetState = nil

function VideoPlayerState:enter()
    self.sceneRun = love.graphics.newVideo(VideoPlayerState.path)
    self.sceneRun:play()
end

function VideoPlayerState:draw()
    love.graphics.draw(self.sceneRun, 0, 0)
end

function VideoPlayerState:update(elapsed)
    if not self.sceneRun:isPlaying() then
        gamestate.switch(VideoPlayerState.targetState)
    end
end

function VideoPlayerState:leave()
    self.sceneRun:release()
    VideoPlayerState.onSceneComplete()
end

return VideoPlayerState
