EvidencesState = {}

function EvidencesState:enter()
    self.bg = love.graphics.newImage("assets/images/game/bg_evidences.png")
    self.crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt_noframe.png")
    self.shadowGlow = love.graphics.newImage("assets/images/game/effects/light.png")
    self.lock = love.graphics.newImage("assets/images/game/lock.png")
    self.light = love.graphics.newImage("assets/images/game/night8/lantern_light.png")

    self.assets = {}
    self.assets["multimedia"] = {}
    self.assets["multimedia"].img = love.graphics.newImage("assets/images/game/multimedia.png")
    self.assets["multimedia"].quads = love.graphics.getQuads(self.assets["multimedia"].img, "assets/images/game/multimedia.json", "hash")

    self.fnt_text = fontcache.getFont("ocrx", 28)
    self.fnt_title = fontcache.getFont("ocrx", 36)

    self.currentZoom = 1
    self.targetZoom = 1
    self.lastClickTime = 0
    self.doubleClickDelay = 0.23

    self.currentSelection = ""
    self.wasPlayingStartSFX = false
    self.wasPlayingTape = false
    self.tapeState = "none"

    self.showCollectionButtons = false
    self.currentCollectionImage = 1
    self.canMoveMouse = false

    self.record = love.audio.newSource(languageRaw["__ENGINE__"].vincentRecordTrophyPath, "stream")

    self.mouseDragFade = {
        alpha = 1
    }

    self.audioFade = {
        volume = 0.5,
    }

    self.tapeHitbox = {
        x = shove.getViewportWidth() - 350,
        y = shove.getViewportHeight() / 2,
        w = 522,
        h = 800,
        offsetX = -680,
        offsetY = -300,
    }

    self.camera = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)

    AudioSources["msc_evidences_bg"]:setLooping(true)
    AudioSources["msc_evidences_bg"]:play()

    local imgsTrohies = fsutil.scanFolder("assets/images/game/evidences/trophies", true)
    self.assets["icons"] = {}
    self.assets["icons"].image = love.graphics.newImage("assets/images/game/evidences/icons.png")
    self.assets["icons"].quads = love.graphics.getQuads(self.assets["icons"].image, "assets/images/game/evidences/icons.json", "hash")
    for _, value in ipairs(imgsTrohies) do
        if love.filesystem.getInfo(value).type == "directory" then
            local name = value:match("[^/]+$")

            self.assets["trophy_" .. name] = {}
        else
            local name = (value:gsub("%.[^.]+$", "")):match("[^/]+$")
            if string.find(name, "evidence") then
                self.assets["trophy_double_trouble"][name] = love.graphics.newImage(value)
            else
                self.assets["trophy_" .. name] = love.graphics.newImage(value)
            end
        end
    end

    self.fxBlurBG = moonshine(moonshine.effects.gaussianblur)
    self.fxBlurBG.gaussianblur.sigma = 15

    self.cnv_blurFX = love.graphics.newCanvas(shove.getViewportDimensions())

    self.shdFXScreen = moonshine(moonshine.effects.crt)
        .chain(moonshine.effects.pixelate)
        .chain(moonshine.effects.chromasep)

    self.shdFXScreen.pixelate.feedback = 0.1
    self.shdFXScreen.pixelate.size = { 1.5, 1.5 }

    self.shdFXScreen.chromasep.radius = 1.25

    --languageService["evidences_trophies_" .. self.currentSelection]
    self.UICanvas = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight(), { readable = true })

    loveView.unloadView()
    loveView.registerLoveframesEvents()
    loveView.loadView("src/Modules/Game/Views/EvidencesView.lua")
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

    love.graphics.setColor(0, 0, 0, 0.67)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setBlendMode("add")
    love.graphics.draw(self.light, shove.getViewportWidth() - 350, 32, math.rad(-90), 0.75, 0.75, self.light:getWidth() / 2, self.light:getHeight() / 2)
    love.graphics.setBlendMode("alpha")

    love.graphics.draw(self.crtOverlay, 0, 0, 0, shove.getViewportWidth() / self.crtOverlay:getWidth(), shove.getViewportHeight() / self.crtOverlay:getHeight())

    if self.currentSelection ~= "" then
        self.camera:attach()
        local sprite = self.assets[self.currentSelection]
        local spriteMultiplier = 10

        if type(sprite) == "table" then
            local img = sprite["evidence_" .. self.currentCollectionImage]
            love.graphics.setBlendMode("add")
            love.graphics.draw(self.shadowGlow, shove.getViewportWidth() - 350, shove.getViewportHeight() / 2, 0, self.currentZoom * spriteMultiplier, self.currentZoom * spriteMultiplier, self.shadowGlow:getWidth() / 2, self.shadowGlow:getHeight() / 2)
            love.graphics.setBlendMode("alpha")

            love.graphics.draw(img, shove.getViewportWidth() - 350, shove.getViewportHeight() / 2, 0, self.currentZoom, self.currentZoom, img:getWidth() / 2, img:getHeight() / 2)
        else
            love.graphics.setBlendMode("add")
            love.graphics.draw(self.shadowGlow, shove.getViewportWidth() - 350, shove.getViewportHeight() / 2, 0, self.currentZoom * spriteMultiplier, self.currentZoom * spriteMultiplier, self.shadowGlow:getWidth() / 2, self.shadowGlow:getHeight() / 2)
            love.graphics.setBlendMode("alpha")

            love.graphics.draw(sprite, shove.getViewportWidth() - 350, shove.getViewportHeight() / 2, 0, self.currentZoom, self.currentZoom, sprite:getWidth() / 2, sprite:getHeight() / 2)

            if self.currentSelection == "trophy_strings_from_the_past" then
                local z     = self.currentZoom

                local rectX = self.tapeHitbox.x + (self.tapeHitbox.x + self.tapeHitbox.offsetX - sprite:getWidth() / 2) * z
                local rectY = self.tapeHitbox.y + (self.tapeHitbox.y + self.tapeHitbox.offsetY - sprite:getHeight() / 2) * z

                local rectW = self.tapeHitbox.w * z
                local rectH = self.tapeHitbox.h * z
                love.graphics.setColor(1, 1, 1, 0.6)
                love.graphics.rectangle("fill", rectX, rectY, rectW, rectH)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
        self.camera:detach()
    end

    love.graphics.draw(self.UICanvas)
end

function EvidencesState:update(elapsed)
    self.currentZoom = math.lerp(self.currentZoom, self.targetZoom, 0.05)

    self.camera.x = math.clamp(self.camera.x, shove.getViewportWidth() / 2, shove.getViewportWidth())
    self.camera.y = math.clamp(self.camera.y, shove.getViewportHeight() / 2, shove.getViewportHeight())

    love.graphics.setCanvas({ self.UICanvas, stencil = true })
    love.graphics.clear(0, 0, 0, 0)
    loveView.draw()
    love.graphics.setCanvas()

    AudioSources["msc_evidences_bg"]:setVolume(self.audioFade.volume)

    if self.tapeState == "starting" and not AudioSources["snd_tape_start"]:isPlaying() then
        self.tapeState = "playing"
        self.record:setVolume(0.75)
        AudioSources["snd_tape_buzz_loop"]:play()
        AudioSources["snd_tape_buzz_loop"]:setVolume(0.3)
        AudioSources["snd_tape_buzz_loop"]:setLooping(true)
        self.record:play()
    end

    if self.tapeState == "playing" and not self.record:isPlaying() then
        self.tapeState = "ending"
        AudioSources["snd_tape_buzz_loop"]:stop()
        AudioSources["snd_tape_end"]:play()
    end

    if self.tapeState == "ending" and not AudioSources["snd_tape_end"]:isPlaying() then
        self.tapeState = "none"
        print("Sequência finalizada")

        flux.to(self.audioFade, 2, { volume = 0.5 })
    end

    flux.update(elapsed)
    loveView.update(elapsed)
end

function EvidencesState:wheelmoved(x, y)
    if not self.canMoveMouse then return end
    if self.currentSelection == "" then return end
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
    if self.currentSelection == "" then return end
    if not self.canMoveMouse then return end
    if love.mouse.isDown(1) then
        self.camera.x = self.camera.x - dx / self.camera.scale
        self.camera.y = self.camera.y - dy / self.camera.scale
    end
end

function EvidencesState:mousepressed(x, y, button)
    if self.currentSelection ~= "trophy_strings_from_the_past" then return end
    if button ~= 1 then return end

    local sprite           = self.assets["trophy_strings_from_the_past"]

    local inside, vmx, vmy = shove.mouseToViewport()
    local mx, my           = self.camera:worldCoords(vmx, vmy)

    local z                = self.currentZoom

    local rectX            = self.tapeHitbox.x + (self.tapeHitbox.x + self.tapeHitbox.offsetX - sprite:getWidth() / 2) * z
    local rectY            = self.tapeHitbox.y + (self.tapeHitbox.y + self.tapeHitbox.offsetY - sprite:getHeight() / 2) * z

    local rectW            = self.tapeHitbox.w * z
    local rectH            = self.tapeHitbox.h * z

    local hitbox           = {
        x = rectX,
        y = rectY,
        w = rectW,
        h = rectH
    }

    local now              = love.timer.getTime()

    if collision.pointRect({ x = mx, y = my }, hitbox) then
        if now - self.lastClickTime <= self.doubleClickDelay then
            -- here --
            flux.to(self.audioFade, 2, { volume = 0 }):oncomplete(function()
                AudioSources["snd_tape_start"]:play()
                self.tapeState = "starting"
            end)
            self.lastClickTime = 0
        else
            self.lastClickTime = now
        end
    end
end

function EvidencesState:leave()
    flux.removeAll()

    self.record:stop()
    for k, v in pairs(AudioSources) do
        v:stop()
    end

    loveView.unloadView()

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
