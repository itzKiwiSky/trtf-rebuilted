EvidencesState = {}

function EvidencesState:enter()
    self.bg = love.graphics.newImage("assets/images/game/bg_evidences.png")
    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")
    self.shadowGlow = love.graphics.newImage("assets/images/game/effects/light.png")
    self.lock = love.graphics.newImage("assets/images/game/lock.png")
    self.light = love.graphics.newImage("assets/images/game/night8/lantern_light.png")

    self.assets = {}

    self.buttons = {
        config = {
            startX = 72,
            startY = 120,
            padding = 72,
            scale = 0.15,
        },
        elements = {},
    }

    AudioSources["msc_evidences_bg"]:setLooping(true)
    AudioSources["msc_evidences_bg"]:play()

    local imgs = fsutil.scanFolder("assets/images/game/evidences/")
    for _, value in ipairs(imgs) do
        local name = (value:gsub("%.[^.]+$", "")):match("[^/]+$")
        self.assets[name] = love.graphics.newImage(value)
    end

    print(inspect(self.assets))

    self.fxBlurBG = moonshine(moonshine.effects.gaussianblur)
    self.fxBlurBG.gaussianblur.sigma = 15

    self.cnv_blurFX = love.graphics.newCanvas(shove.getViewportDimensions())

    self.shdFXScreen = moonshine(moonshine.effects.crt)
        .chain(moonshine.effects.pixelate)
        .chain(moonshine.effects.chromasep)

    self.shdFXScreen.pixelate.feedback = 0.1
    self.shdFXScreen.pixelate.size = { 1.5, 1.5 }

    self.shdFXScreen.chromasep.radius = 1.25

    local x, y = 0, 0
    local r, c = 1, 1
    for name, challenge in spairs(gameSave.save.user.progress.challenges) do
        local image = self.assets[name]
        self.buttons.elements[name] = {
            x = self.buttons.config.startX + x,
            y = self.buttons.config.startY + y,
            w = 0,
            h = 0,
            unlocked = challenge,
            img = self.assets[name]
        }

        print(name)

        self.buttons.elements[name].w = self.assets[name]:getWidth() * self.buttons.config.scale
        self.buttons.elements[name].h = self.assets[name]:getHeight() * self.buttons.config.scale

        x = (x + self.assets[name]:getWidth() * self.buttons.config.scale) + self.buttons.config.padding
        r = r + 1

        if r > 3 then
            r = 1
            c = c + 1
            x = self.buttons.config.startX
            y = (y + self.assets[name]:getHeight() * self.buttons.config.scale) + self.buttons.config.padding
        end
    end
end

function EvidencesState:draw()
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    self.cnv_blurFX:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.fxBlurBG(function()
            love.graphics.draw(self.bg, shove.getViewportWidth() / self.bg:getWidth(), shove.getViewportHeight() / self.bg:getHeight())
        end)
    end)
    self.shdFXScreen(function()
        love.graphics.draw(self.bg, shove.getViewportWidth() / self.bg:getWidth(), shove.getViewportHeight() / self.bg:getHeight())
    end)
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 0.75)
    love.graphics.draw(self.cnv_blurFX)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")

    love.graphics.draw(self.crtOverlay, 0, 0, 0, shove.getViewportWidth() / self.crtOverlay:getWidth(), shove.getViewportHeight() / self.crtOverlay:getHeight())
    for name, btn in spairs(self.buttons.elements) do
        local scaleGlow = 1.5
        love.graphics.setBlendMode("add")
        love.graphics.draw(self.shadowGlow, btn.x + btn.w * 0.5, btn.y + btn.h * 0.5, 0, (self.shadowGlow:getWidth() / btn.w) * scaleGlow, (self.shadowGlow:getHeight() / btn.h) * scaleGlow, self.shadowGlow:getWidth() / 2, self.shadowGlow:getHeight() / 2)
        love.graphics.setBlendMode("alpha")

        if btn.unlocked then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0, 0, 0, 1)
        end
        love.graphics.draw(btn.img, btn.x, btn.y, 0, self.buttons.config.scale, self.buttons.config.scale)
        love.graphics.setColor(1, 1, 1, 1)

        --love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
    end
end

function EvidencesState:update(elapsed)

end

return EvidencesState
