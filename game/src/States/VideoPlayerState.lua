VideoPlayerState = {}

VideoPlayerState.path = ""
VideoPlayerState.triggered = false
VideoPlayerState.onSceneComplete = function() end

function VideoPlayerState:enter()
    self.triggered = false
    self.sceneRun = love.graphics.newVideo(VideoPlayerState.path)
    self.sceneRun:play()
end

function VideoPlayerState:draw()
    local VIDEO_WIDTH = shove.getViewportWidth() / self.sceneRun:getWidth()
    local VIDEO_HEIGHT = shove.getViewportHeight() / self.sceneRun:getHeight()
    love.graphics.draw(self.sceneRun, 0, 0, 0, VIDEO_WIDTH, VIDEO_HEIGHT)
end

function VideoPlayerState:update(elapsed)
    if not self.sceneRun:isPlaying() and not self.triggered then
        self.triggered = true
        VideoPlayerState.onSceneComplete()
    end
end

function VideoPlayerState:leave()
    flux.removeAll()
    self.sceneRun:release()
end

return VideoPlayerState
