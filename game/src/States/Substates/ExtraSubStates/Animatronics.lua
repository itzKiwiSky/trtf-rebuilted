local Animatronics = {}

function Animatronics:load()
    self.viewCam = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    self.viewCam.targetScale = self.viewCam.scale

    self.names = {
        old = {
            { animatronicID = "freddy", name = "Old Freddy", author = "Marco Antonio", isNew = false },
            { animatronicID = "bonnie", name = "Old Bonnie", author = "Marco Antonio", isNew = false },
            { animatronicID = "chica", name = "Old Chica", author = "Marco Antonio", isNew = false },
            { animatronicID = "foxy", name = "Old Foxy", author = "Marco Antonio", isNew = false },
            { animatronicID = "frankburt", name = "Old Frankburt", author = "Marco Antonio", isNew = false },
            { animatronicID = "puppet", name = "Old Puppet", author = "Marco Antonio", isNew = false },
            { animatronicID = "sugar", name = "Old Sugar", author = "Papas", isNew = false },
            { animatronicID = "withered_sugar", name = "Old Withered Sugar", author = "Papas", isNew = false },
        },
        new = {
            { animatronicID = "freddy", name = "Freddy", author = "ElEternaut", isNew = false },
            { animatronicID = "bonnie", name = "Bonnie", author = "ShotOfRabbet", isNew = false },
            { animatronicID = "chica", name = "Chica", author = "ElEternaut", isNew = false },
            { animatronicID = "foxy", name = "Foxy", author = "ElEternaut", isNew = false },
            { animatronicID = "sugar", name = "Sugar", author = "ShotOfRabbet", isNew = false },
            { animatronicID = "kitty_fazcat", name = "Kitty Fazcat", author = "ShotOfRabbet", isNew = true },
            { animatronicID = "frankburt", name = "Frankburt", author = "ElEternaut", isNew = false },
            { animatronicID = "puppet", name = "Puppet", author = "ElEternaut", isNew = false },
            { animatronicID = "withered_sugar", name = "Withered Sugar", author = "ShotOfRabbet", isNew = false },
            { animatronicID = "yellow_bear", name = "Yellow Bear", author = "ElEternaut", isNew = true },
        }
    }

    self.oldAnimatronics = false
    self.animatronics = {
        old = {},
        new = {},
    }

    local oldAnims = love.filesystem.getDirectoryItems("assets/images/game/extras/animatronics/old")
    local newAnims = love.filesystem.getDirectoryItems("assets/images/game/extras/animatronics/")

    for _, a in ipairs(oldAnims) do
        self.animatronics.old[(a:match("[^/]+$")):gsub("%.[^.]+$", "")] = love.graphics.newImage("assets/images/game/extras/animatronics/old/" .. a)
    end

    for _, a in ipairs(newAnims) do
        if love.filesystem.getInfo("assets/images/game/extras/animatronics/" .. a).type == "file" then
            self.animatronics.new[(a:match("[^/]+$")):gsub("%.[^.]+$", "")] = love.graphics.newImage("assets/images/game/extras/animatronics/" .. a)
        end
    end

    print(inspect(self.animatronics))

    self.shadowGlow = love.graphics.newImage("assets/images/game/effects/light.png")
end

function Animatronics:draw()
    self.viewCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.draw(self.shadowGlow, 0, 0, 0, 5.3, 3.1, self.shadowGlow:getWidth() / 2, self.shadowGlow:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)

    if not self.oldAnimatronics then
        --love.graphics.draw(self.animatronics.new)
    end

    self.viewCam:detach()
end

function Animatronics:update(elapsed)
    
end

function Animatronics:wheelmoved(x, y)

end

return Animatronics