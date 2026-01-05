VideoPlayerState = {}

VideoPlayerState.path = ""
VideoPlayerState.triggered = false
VideoPlayerState.jumpScene = false
VideoPlayerState.onSceneComplete = function() end

function VideoPlayerState:preload()
    self.sceneRun = love.graphics.newVideo(VideoPlayerState.path)
end

function VideoPlayerState:enter()
    self.triggered = false
    self.jumpScene = false
    self.started = false

    if type(self.sceneRun) == nil then
        self.sceneRun = love.graphics.newVideo(VideoPlayerState.path, {
            audio = true,
            dpi = love.graphics.getDPIScale()
        })
    end

    self.fnt_jump = fontcache.getFont("ocrx", 28)

    self.fade = { alpha = 0, volume = 1 }
    self.fadetext = { alpha = 0 }

    flux.to(self.fadetext, 3, { alpha = 1 }):delay(3)
    flux.to(self.fadetext, 3, { alpha = 1 }):delay(3)

    self.sceneRun:seek(0)
    print("video play")
    self.sceneRun:play()
end

function VideoPlayerState:draw()
    local VIDEO_WIDTH = shove.getViewportWidth() / self.sceneRun:getWidth()
    local VIDEO_HEIGHT = shove.getViewportHeight() / self.sceneRun:getHeight()
    love.graphics.draw(self.sceneRun, 0, 0, 0, VIDEO_WIDTH, VIDEO_HEIGHT)

    love.graphics.setColor(1, 1, 1, self.fadetext.alpha)
    love.graphics.printf(languageService["video_click_to_jump"], self.fnt_jump, -32, shove.getViewportHeight() - (self.fnt_jump:getHeight() + 16), shove.getViewportWidth(), "right")
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, self.fade.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function VideoPlayerState:update(elapsed)
    self.sceneRun:getSource():setVolume(self.fade.volume)
    if self.sceneRun:isPlaying() then
        self.started = true
    end

    if self.started and not self.sceneRun:isPlaying() and not self.triggered then
        self.triggered = true
        VideoPlayerState.onSceneComplete()
    end
    flux.update(elapsed)
end

function VideoPlayerState:mousepressed(x, y, button)
    if not self.jumpScene then
        VideoPlayerState.jumpScene = true
        flux.to(self.fade, 3, { alpha = 1, volume = 0 }):oncomplete(function()
            self.sceneRun:pause()
            self.sceneRun:seek(0)
            VideoPlayerState.onSceneComplete()
        end)
    end
end

function VideoPlayerState:keypressed(k)
    if not self.jumpScene then
        VideoPlayerState.jumpScene = true
        flux.to(self.fade, 3, { alpha = 1, volume = 0 }):oncomplete(function()
            self.sceneRun:pause()
            self.sceneRun:seek(0)
            VideoPlayerState.onSceneComplete()
        end)
    end
end

function VideoPlayerState:leave()
    flux.removeAll()
    self.jumpScene = false
    --self.sceneRun:release()
end

return VideoPlayerState
