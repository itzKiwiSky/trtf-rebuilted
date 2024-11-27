SplashState = {}

function SplashState:init()
    introVideo = love.graphics.newVideo("assets/videos/new_intro.ogv")
end

function SplashState:enter()
    if introVideo then
        introVideo:play()
    end
end

function SplashState:draw()
    love.graphics.draw(introVideo, 0, 0)
end

function SplashState:update(elapsed)
    if not introVideo:isPlaying() then
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
    end
end

function SplashState:leave()
    
end

return SplashState