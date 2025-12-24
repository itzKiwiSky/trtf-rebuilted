VideoPlayerState = {}

VideoPlayerState.path = ""
VideoPlayerState.onSceneComplete = function() end

function VideoPlayerState:enter()
    self.sceneRun = love.graphics.newVideo(VideoPlayerState.path)
    self.sceneRun:play()
end

function VideoPlayerState:draw()
    love.graphics.draw(self.sceneRun, 0, 0, 0, self.sceneRun:getWidth() / shove.getViewportWidth(), self.sceneRun:getHeight() / shove.getViewportHeight())
end

function VideoPlayerState:leave()
    flux.removeAll()
    self.sceneRun:release()
    VideoPlayerState.onSceneComplete()
end

return VideoPlayerState
