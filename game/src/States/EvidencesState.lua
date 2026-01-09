EvidencesState = {}

function EvidencesState:enter()
    self.bg = love.graphics.newImage("assets/images/game/bg_evidences.png")
    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")
    self.shadowGlow = love.graphics.newImage("assets/images/game/effects/light.png")
    self.lock = love.graphics.newImage("assets/images/game/lock.png")
    self.light = love.graphics.newImage("assets/images/game/night8/lantern_light.png")

    self.currentZoom = 1
    self.targetZoom = 1

    self.assets = {}
    self.currentSelection = ""

    self.buttons = {
        config = {
            startX = 72,
            startY = 120,
            padding = 72,
            scale = 0.143,
        },
        elements = {},
    }

    self.camera = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)

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
            id = name,
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

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setBlendMode("add")
    love.graphics.draw(self.light, shove.getViewportWidth() - 350, 32, math.rad(-90), 0.75, 0.75, self.light:getWidth() / 2, self.light:getHeight() / 2)
    love.graphics.setBlendMode("alpha")

    if self.currentSelection ~= "" then
        self.camera:attach()
        local sprite = self.assets[self.currentSelection]
        love.graphics.draw(sprite, shove.getViewportWidth() - 350, shove.getViewportHeight() / 2, 0, self.currentZoom, self.currentZoom, sprite:getWidth() / 2, sprite:getHeight() / 2)
        self.camera:detach()
    end

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

        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
    end
end

function EvidencesState:update(elapsed)
    self.currentZoom = math.lerp(self.currentZoom, self.targetZoom, 0.05)

    self.camera.x = math.clamp(self.camera.x, shove.getViewportWidth() / 2, shove.getViewportWidth())
    self.camera.y = math.clamp(self.camera.y, shove.getViewportHeight() / 2, shove.getViewportHeight())
end

function EvidencesState:mousepressed(x, y, button)
    local inside, vmx, vmy = shove.mouseToViewport()

    if button == 1 then
        for name, btn in spairs(self.buttons.elements) do
            if collision.pointRect({ x = vmx, y = vmy }, btn) then
                self.currentSelection = btn.id
            end
        end
    end
end

function EvidencesState:wheelmoved(x, y)
    if y < 0 then
        if self.targetZoom > 0.45 then
            self.targetZoom = self.targetZoom - 0.05
        end
    elseif y > 0 then
        if self.targetZoom < 1.8 then
            self.targetZoom = self.targetZoom + 0.05
        end
    end
end

function EvidencesState:mousemoved(x, y, dx, dy)
    if love.mouse.isDown(3) then
        self.camera.x = self.camera.x - dx / self.camera.scale
        self.camera.y = self.camera.y - dy / self.camera.scale
    end
end

function EvidencesState:leave()
    flux.removeAll()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    local function releaseRecursive(tbl)
        for key, value in pairs(tbl) do
            if type(value) == "table" then
                releaseRecursive(value)
            else
                if type(value) == "userdata" and value.release then
                    value:release()
                end
            end
        end
    end

    releaseRecursive(self.assets)
end

return EvidencesState
