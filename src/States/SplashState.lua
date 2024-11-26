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

end

function SplashState:leave()
    
end

return SplashState