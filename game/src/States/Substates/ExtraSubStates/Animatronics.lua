local Animatronics = {}

function Animatronics:load()
    self.names = {
        old = {
            { animatronicID = "old_freddy", name = "Old Freddy", author = "Marco Antonio", isNew = false },
            { animatronicID = "", name = "Old Bonnie", author = "Marco Antonio", isNew = false },
            { animatronicID = "", name = "Old Chica", author = "Marco Antonio", isNew = false },
            { animatronicID = "", name = "Old Foxy", author = "Marco Antonio", isNew = false },
            { animatronicID = "", name = "Old Frankburt", author = "Marco Antonio", isNew = false },
            { animatronicID = "", name = "Old Puppet", author = "Marco Antonio", isNew = false },
            { animatronicID = "", name = "Old Sugar", author = "Papas", isNew = false },
            { animatronicID = "", name = "Old Withered Sugar", author = "Papas", isNew = false },
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
            { animatronicID = "withered_kitty", name = "Withered Kitty", author = "ShotOfRabbet", isNew = false },
            { animatronicID = "yellow_bear", name = "Yellow Bear", author = "ElEternaut", isNew = true },
        }
    }

    self.assets = {}
    self.assets.animatronics = {
        old = {},
        new = {},
    }

    self.shadowGlow = love.graphics.newImage("assets/images/game/effects/light.png")
end

function Animatronics:draw()
    
end

function Animatronics:update(elapsed)
    
end

return Animatronics