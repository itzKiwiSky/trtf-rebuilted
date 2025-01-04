SplashState = {}

function SplashState:enter()
    subtitlesController.clear()

    
    local introID = lume.weightedchoice({["trtl_meme.ogv"] = 25, ["new_intro.ogv"] = 75}) -- new_intro.ogv
    introVideo = love.graphics.newVideo("assets/videos/" .. introID)
    canContinue = false

    if introVideo then
        introVideo:play()
    end
    love.mouse.setVisible(false)

    VIDEO_WIDTH = love.graphics.getWidth() / introVideo:getWidth()
    VIDEO_HEIGHT = love.graphics.getHeight() / introVideo:getHeight()
end

function SplashState:draw()
    love.graphics.draw(introVideo, 0, 0, 0, VIDEO_WIDTH, VIDEO_HEIGHT)
end

function SplashState:update(elapsed)
    if not introVideo:isPlaying() then
        --[[
        if not gameslot.save.game.user.progress.initialCutscene then
            VideoSceneState.path = "assets/videos/lockjaw_cinematic.ogv"
            VideoSceneState.onSceneComplete = function()
                gameslot.save.game.user.progress.initialCutscene = true
                gameslot:saveSlot()
            end
            VideoSceneState.targetState = MenuState
            gamestate.switch(VideoSceneState)
        else
            gamestate.switch(MenuState)
        end
        ]]--
        love.mouse.setVisible(true)
        gamestate.switch(MenuState)
    end
end

function SplashState:keypressed(k)
    introVideo:pause()
    introVideo:rewind()
    love.mouse.setVisible(true)
    gamestate.switch(MenuState)
end

function SplashState:mousepressed(x, y, button)
    introVideo:pause()
    introVideo:rewind()
    love.mouse.setVisible(true)
    gamestate.switch(MenuState)
end

function SplashState:leave()
    introVideo:pause()
    introVideo:rewind()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
end

return SplashState