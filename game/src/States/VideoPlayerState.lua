VideoPlayerState = {}

VideoPlayerState.path = ""
VideoPlayerState.triggered = false
VideoPlayerState.jumpScene = false
VideoPlayerState.onSceneComplete = function() end

function VideoPlayerState:enter()
    self.triggered = false
    self.sceneRun = love.graphics.newVideo(VideoPlayerState.path)
    self.sceneRun:play()

    self.fnt_jump = fontcache.getFont("ocrx", 28)

    self.fade = { alpha = 0, volume = 1 }
    self.fadetext = { alpha = 0 }

    self.timerFade = timer.new()
    self.timerFade:after(3, function()
        flux.to(self.fadetext, 3, { alpha = 1 })
    end)

    --[[
    flux.to(self.fade, 3, { alpha = 1, volume = 0 }):oncomplete(function()
            VideoPlayerState.onSceneComplete()
        end)
        ]]
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
    if (not self.sceneRun:isPlaying() and not self.triggered) then
        self.triggered = true
        VideoPlayerState.onSceneComplete()
    end
    flux.update(elapsed)
    self.timerFade:update(elapsed)
end

function VideoPlayerState:mousepressed(x, y, button)
    if not self.jumpScene then
        VideoPlayerState.jumpScene = true
        flux.to(self.fade, 3, { alpha = 1, volume = 0 }):oncomplete(function()
            VideoPlayerState.onSceneComplete()
        end)
    end
end

function VideoPlayerState:keypressed(k)
    if not self.jumpScene then
        VideoPlayerState.jumpScene = true
        flux.to(self.fade, 3, { alpha = 1, volume = 0 }):oncomplete(function()
            self.sceneRun:stop()
            VideoPlayerState.onSceneComplete()
        end)
    end
end

function VideoPlayerState:leave()
    flux.removeAll()
    VideoPlayerState.jumpScene = false
    self.sceneRun:release()
end

return VideoPlayerState
