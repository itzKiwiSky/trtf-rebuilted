local BeeperView = {}

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function BeeperView:init()
    self.fnt_poop = fontcache.getFont("lcddot", 45)
    self.texts = languageRaw["secret_night"]["beeper_instructions"]
    self.page = 1
    self.maxPage = #self.texts

    local centerX, centerY = shove.getViewportWidth() / 2, shove.getViewportHeight() / 2

    self.buttons = {
        ["left"] = {
            x = centerX + 35,
            y = centerY + 200,
            w = 72,
            h = 90,
        },
        ["right"] = {
            x = centerX + 240,
            y = centerY + 200,
            w = 80,
            h = 90,
        },
        ["close"] = {
            x = centerX - 240,
            y = centerY + 172,
            w = 90,
            h = 48,
        },
    }

    self.glow = moonshine(moonshine.effects.gaussianblur)
    self.glow.gaussianblur.sigma = 10
    self.glowcnv = love.graphics.newCanvas(shove.getViewportDimensions())
end

function BeeperView:draw()
    if not SecretNightState.beeperController.tabUp then return end

    local ox, oy = SecretNightState.assets["ui"]["bg_beeper"]:getWidth() / 2, SecretNightState.assets["ui"]["bg_beeper"]:getHeight() / 2
    love.graphics.draw(SecretNightState.assets["ui"]["bg_beeper"], 0, 0)

    -- rgb(13, 40, 23)
    love.graphics.setColor(lume.color("rgb(13, 40, 23)"))
    love.graphics.printf(self.texts[self.page], self.fnt_poop, shove.getViewportWidth() / 2 - 235, shove.getViewportHeight() / 2 - 140, 500, "center")

    love.graphics.printf(string.format("%s / %s", self.page, self.maxPage), self.fnt_poop, shove.getViewportWidth() / 2 - 235, shove.getViewportHeight() / 2 + 80, 500, "center")
    love.graphics.setColor(1, 1, 1, 1)

    self.glowcnv:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.glow(function()
            love.graphics.draw(SecretNightState.assets["ui"]["bg_beeper"], 0, 0)
            --love.graphics.printf(self.texts[self.page], self.fnt_poop, shove.getViewportWidth() / 2 - 195, shove.getViewportHeight() / 2 - 250, 500, "center")
            love.graphics.setColor(lume.color("rgb(13, 40, 23)"))
            love.graphics.printf(self.texts[self.page], self.fnt_poop, shove.getViewportWidth() / 2 - 235, shove.getViewportHeight() / 2 - 140, 500, "center")
            love.graphics.setColor(1, 1, 1, 1)
        end)
    end)
end

function BeeperView:postDraw()
    if not SecretNightState.beeperController.tabUp then return end

    love.graphics.setColor(1, 1, 1, 0.75)
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.glowcnv)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)


    for key, box in pairs(self.buttons) do
        --drawBox(value, 0.2, 0.6, 0.54)
        local r, g, b = 0.2, 0.6, 0.54
        love.graphics.setColor(r, g, b, 0.25)
        love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function BeeperView:update(elapsed)

end

function BeeperView:mousepressed(x, y, button)
    if not SecretNightState.beeperController.tabUp then return end

    for key, box in pairs(self.buttons) do
        if collision.pointRect({ x = x, y = y }, box ) then
            if key == "left" then
                if self.page > 1 then
                    self.page = self.page - 1
                end
            end

            if key == "right" then
                if self.page < self.maxPage then
                    self.page = self.page + 1
                end
            end

            if key == "close" then
                SecretNightState.beeperController:setState(false)
                SecretNightState.beeperController.onComplete = function()
                    SecretNightState.officeState.nightStarted = true
                    SecretNightState.nightTextDisplay.displayNightText = true

                    AudioSources["msc_lockjaw_theme"]:setLooping(true)
                    AudioSources["msc_lockjaw_theme"]:setVolume(0.45)
                    AudioSources["msc_lockjaw_theme"]:play()
                end
                AudioSources["sfx_beeper_open"]:play()
                AudioSources["sfx_beeper_open"]:setVolume(0.87)
            end

            AudioSources["sfx_beeper_use"]:play()
            AudioSources["sfx_beeper_use"]:setVolume(0.87)
        end
    end
end

return BeeperView