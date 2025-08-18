local Animatronics = {}

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function Animatronics:load()
    self.viewCam = camera(shove.getViewportWidth() / 2 - 200, shove.getViewportHeight() / 2)

    self.buttons = {}

    self.fnt_animatronics = fontcache.getFont("ocrx", 32)
    self.fnt_authors = fontcache.getFont("ocrx", 20)
    self.fnt_UI = fontcache.getFont("ocrx", 40)
    self.fnt_warn = fontcache.getFont("ocrx", 27)

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

    self.animatronicsNames = {
        counter = 1,
        oldScale = 0.75,
        newScale = 0.41,
        old = {
            "freddy",
            "bonnie",
            "chica",
            "foxy",
            "frankburt",
            "puppet",
            "sugar",
            "withered_sugar",
        },
        new = {
            "freddy",
            "bonnie",
            "chica",
            "foxy",
            "sugar",
            "kitty_fazcat",
            "frankburt",
            "puppet",
            "withered_sugar",
            "yellow_bear"
        }
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

    self.buttons["left"] = {
        ignore = false,
        text = " << ",
        x = shove.getViewportWidth() / 2 - 200,
        y = 672
    }
    self.buttons["left"].hitbox = newButtonHitbox(self.buttons["left"].x - 3, self.buttons["left"].y - 2, self.fnt_UI:getWidth(self.buttons["left"].text) + 8, self.fnt_UI:getHeight() + 8)

    self.buttons["right"] = {
        ignore = false,
        text = " >> ",
        x = self.buttons["left"].hitbox.x + self.buttons["left"].hitbox.w + 256,
        y = 672
    }
    self.buttons["right"].hitbox = newButtonHitbox(self.buttons["right"].x - 3, self.buttons["right"].y - 2, self.fnt_UI:getWidth(self.buttons["right"].text) + 8, self.fnt_UI:getHeight() + 8)

    self.buttons["animatronic"] = {
        ignore = true,
        text = "",
        x = shove.getViewportWidth() / 2 - 130,
        y = 90
    }

    self.buttons["animatronic"].hitbox = newButtonHitbox(self.buttons["animatronic"].x, self.buttons["animatronic"].y, 280, 450)

    self.shadowGlow = love.graphics.newImage("assets/images/game/effects/light.png")
end

function Animatronics:draw()
    self.viewCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.draw(self.shadowGlow, 650, 580, 0, 3.3, 1.2, self.shadowGlow:getWidth() / 2, self.shadowGlow:getHeight() / 2)
        love.graphics.setColor(1, 1, 1, 1)
        if not self.oldAnimatronics then
            local currentAnimatronic = self.animatronicsNames.new[self.animatronicsNames.counter]
            love.graphics.draw(self.animatronics.new[currentAnimatronic], shove.getViewportWidth() / 2 + 20, 310, 0, self.animatronicsNames.newScale, self.animatronicsNames.newScale,
                self.animatronics.new[currentAnimatronic]:getWidth() / 2, self.animatronics.new[currentAnimatronic]:getHeight() / 2
            )

            love.graphics.printf(self.names.new[self.animatronicsNames.counter].name, self.fnt_animatronics, (shove.getViewportWidth() / 2 + 20) - 256, 600, 512, "center")
        else
            local currentAnimatronic = self.animatronicsNames.old[self.animatronicsNames.counter]
            love.graphics.draw(self.animatronics.old[currentAnimatronic], shove.getViewportWidth() / 2 + 20, 310, 0, self.animatronicsNames.oldScale, self.animatronicsNames.oldScale,
                self.animatronics.old[currentAnimatronic]:getWidth() / 2, self.animatronics.old[currentAnimatronic]:getHeight() / 2
            )

            love.graphics.printf(self.names.old[self.animatronicsNames.counter].name, self.fnt_animatronics, (shove.getViewportWidth() / 2 + 20) - 256, 600, 512, "center")
        end

        local diff = self.buttons["right"].hitbox.x - (self.buttons["left"].hitbox.x + self.buttons["left"].hitbox.w)
        love.graphics.printf(string.format("%s\n%s", languageService["extras_category_animatronics_author"], 
            self.names[self.oldAnimatronics and "old" or "new"][self.animatronicsNames.counter].author), self.fnt_authors, 
            (self.buttons["left"].hitbox.x + self.buttons["left"].hitbox.w) + 10, 670, diff - 10, "center"
        )

        for _, e in pairs(self.buttons) do
            --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
            love.graphics.print(e.text, self.fnt_UI, e.x, e.y)
            love.graphics.setColor(1, 1, 1, 1)
        end
    self.viewCam:detach()

    love.graphics.printf(languageService["extras_category_animatronics_click"], self.fnt_warn, 0, shove.getViewportHeight() - 64, shove.getViewportWidth(), "center")
end

function Animatronics:update(elapsed)
    local nameCount = self.oldAnimatronics and #self.animatronicsNames.old or #self.animatronicsNames.new
    if self.animatronicsNames.counter > nameCount then
        self.animatronicsNames.counter = nameCount
    end
end

function Animatronics:mousepressed(x, y, button)
    local inside, mx, my = shove.mouseToViewport()
    mx, my = self.viewCam:worldCoords(mx, my, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    if button == 1 then
        for k, e in pairs(self.buttons) do
            if collision.pointRect({ x = mx, y = my }, e.hitbox) then
                if k == "left" then
                    if self.animatronicsNames.counter > 1 then
                        self.animatronicsNames.counter = self.animatronicsNames.counter - 1
                    end
                end
                if k == "right" then
                    local nameCount = self.oldAnimatronics and #self.animatronicsNames.old or #self.animatronicsNames.new
                    print(nameCount)
                    if self.animatronicsNames.counter < nameCount then
                        self.animatronicsNames.counter = self.animatronicsNames.counter + 1
                    end
                end
                if k == "animatronic" then
                    self.oldAnimatronics = not self.oldAnimatronics
                end
            end
        end
    end
end

function Animatronics:wheelmoved(x, y)

end

return Animatronics