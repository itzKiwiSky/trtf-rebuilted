CutsceneState = {}
CutsceneState.assets = {}

local function circularPath(t, radius, speed)
    local angle = speed * love.timer.getTime()

    local x = radius * math.cos(angle)
    local y = radius * math.sin(angle)

    t.rx = t.rx + x
    t.ry = t.ry + y
end

function applyShake(amplitude, frequency)
    return math.sin(love.timer.getTime() * frequency) * amplitude
end

function CutsceneState:enter()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
    love.mouse.setVisible(false)

    self.font = fontcache.getFont("tnr", 34)

    self.blinkAlpha = 1
    self.cutsceneEnd = false

    self.roomSize = {
        width = 2000,
        height = 960,
        topOffset = 160,
    }

    self.mainCam = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    self.mainCam.factorX = 2.452
    self.mainCam.factorY = 25
    self.cameraObject = { -- this will allow camera view --
        x = 0,
        y = 0,
    }

    self.scrollingCam = {
        x = 0,
        y = 0,
        scrollX = 0,
        scrollY = 0,
    }
    self.scrollingCam.scrollX = self.scrollingCam.x
    self.scrollingCam.scrollY = self.scrollingCam.y

    self.shd_perspective = love.graphics.newShader("assets/shaders/Projection.glsl")
    self.shd_perspective:send("latitudeVar", 22.5)
    self.shd_perspective:send("longitudeVar", 45)
    self.shd_perspective:send("fovVar", 0.2630)

    self.cnv_mainCanvas = love.graphics.newCanvas(shove.getViewportDimensions())

    self.shadow = {
        saludState = 1,
        state = "saludos",
        visible = false,
        lookAnim = false,
        anim = {
            speed = 20,
            frame = 1,
            acc = 0
        },
        eyeX = 0,
    }

    self.mask = {
        x = shove.getViewportWidth() / 2,
        y = shove.getViewportHeight() / 2,
        rx = 0,
        ry = 0,
        speed = 5,
        radius = 0.3
    }

    self.textFX = {
        text = languageService["cutscene_day"],
        alpha = 0,
    }

    AudioSources["msc_bg_ambient"]:setLooping(true)
    AudioSources["msc_bg_ambient"]:setVolume(0.75)
    AudioSources["msc_bg_ambient"]:play()

    AudioSources["sfx_mask_breath"]:setLooping(true)
    AudioSources["sfx_mask_breath"]:setVolume(0.6)
    AudioSources["sfx_mask_breath"]:play()

    self.scr_cutscene = timer.new()

    --print(inspect(self.assets))

    self.scr_cutscene:script(function(sleep)
        sleep(20)
        self.blinkAlpha = 1
        self.shadow.saludState = 1
        self.shadow.visible = true
        AudioSources["sfx_shadow_ch_pos"]:setVolume(0.4)
        AudioSources["sfx_shadow_ch_pos"]:play()
        sleep(15)
        self.blinkAlpha = 1
        self.shadow.saludState = 2
        AudioSources["sfx_shadow_ch_pos"]:setVolume(0.6)
        AudioSources["sfx_shadow_ch_pos"]:play()
        sleep(10)
        self.blinkAlpha = 1
        self.shadow.saludState = 3
        AudioSources["sfx_shadow_ch_pos"]:setVolume(0.76)
        AudioSources["sfx_shadow_ch_pos"]:play()
        sleep(10)
        self.blinkAlpha = 1
        self.shadow.state = "look"
        self.shadow.visible = false
        self.shadow.lookAnim = true
        AudioSources["sfx_shadow_ch_pos"]:setVolume(0.8)
        AudioSources["sfx_shadow_ch_pos"]:play()
        AudioSources["sfx_look"]:setLooping(true)
        AudioSources["sfx_look"]:setVolume(0.8)
        AudioSources["sfx_look"]:play()
        sleep(10)
        self.blinkAlpha = 1
        self.cutsceneEnd = true
        for k, v in pairs(AudioSources) do
            v:stop()
        end
        AudioSources["sfx_cutscene_end"]:setVolume(0.8)
        AudioSources["sfx_cutscene_end"]:play()
        sleep(1)
        flux.to(self.textFX, 2, { alpha = 1 }):oncomplete(function()
            flux.to(self.textFX, 2, { alpha = 0 }):delay(1):oncomplete(function()
                if registers.isStoryMode then
                    LoadingState.mode = "normal"
                    gamestate.switch(LoadingState)
                else
                    gamestate.switch(MenuState)
                end
            end)
        end)
    end)
end

function CutsceneState:draw()
    self.mainCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
    self.cnv_mainCanvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        if self.shadow.visible and self.shadow.saludState == 1 then
            love.graphics.draw(
                self.assets["shadow"][self.shadow.state]["saludo" .. self.shadow.saludState]
                ["frame_" .. self.shadow.anim.frame], 0, 0
            )
        end
        love.graphics.draw(self.assets["office"], 0, 0)
        if self.shadow.visible and self.shadow.saludState > 1 then
            love.graphics.draw(
                self.assets["shadow"][self.shadow.state]["saludo" .. self.shadow.saludState]
                ["frame_" .. self.shadow.anim.frame], 0, 0
            )
        end
        if self.shadow.lookAnim then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 842, 281, 318, 138)
            love.graphics.setColor(1, 1, 1)

            love.graphics.draw(self.assets["eyes"], self.shadow.eyeX, 0)

            love.graphics.draw(
                self.assets["shadow"]["look"]["frame_" .. self.shadow.anim.frame], 0, 0
            )

            love.graphics.setColor(1, 1, 1, 0.32)
            love.graphics.setBlendMode("add")
            love.graphics.draw(self.assets["eyes_glow"], self.shadow.eyeX, 0)
            love.graphics.setBlendMode("alpha")
            love.graphics.setColor(1, 1, 1)
        end
    end)
    self.mainCam:detach()

    love.graphics.setShader(self.shd_perspective)
    love.graphics.draw(self.cnv_mainCanvas, 0, 0)
    love.graphics.setShader()

    love.graphics.draw(self.assets["mask"],
        self.mask.x + self.mask.rx, self.mask.y + self.mask.ry, 0, 1.14, 1.14,
        self.assets["mask"]:getWidth() / 2, self.assets["mask"]:getHeight() / 2
    )

    love.graphics.setColor(0, 0, 0, self.blinkAlpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(1, 1, 1, self.textFX.alpha)
    love.graphics.printf(self.textFX.text, self.font, 0, shove.getViewportHeight() / 2, shove.getViewportWidth(), "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function CutsceneState:update(elapsed)
    local inside, mx, my = shove.mouseToViewport() -- get the mouse --

    circularPath(self.mask, self.mask.radius, self.mask.speed)

    local vmx, vmy = mx or 0, my or 0
    if self.cutsceneEnd then
        if self.blinkAlpha < 1 then
            self.blinkAlpha = self.blinkAlpha + elapsed * 3
        end
    else
        --mx, my = self.mainCam:worldCoords(vmx, vmy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

        self.scrollingCam.scrollX = self.scrollingCam.scrollX - (self.scrollingCam.scrollX - vmx) * 0.005
        self.scrollingCam.scrollY = self.scrollingCam.scrollY - (self.scrollingCam.scrollY - vmy) * 0.005
        self.scrollingCam.x = self.scrollingCam.scrollX
        self.scrollingCam.y = self.scrollingCam.scrollY

        self.mainCam:lookAt(self.scrollingCam.x, self.scrollingCam.y)

        self.mainCam.x = math.clamp(self.mainCam.x, shove.getViewportWidth() / 2, self.roomSize.width - shove.getViewportWidth() / 2)
        self.mainCam.y = math.clamp(self.mainCam.y, shove.getViewportHeight() / 2 - self.roomSize.topOffset, self.roomSize.height - shove.getViewportHeight() / 2)

        if self.blinkAlpha > 0 then
            self.blinkAlpha = self.blinkAlpha - elapsed * 4
        end

        self.shadow.eyeX = applyShake(3, 20)

        if self.shadow.visible or self.shadow.lookAnim then
            self.shadow.anim.acc = self.shadow.anim.acc + elapsed

            if self.shadow.anim.acc > (1 / self.shadow.anim.speed) then
                self.shadow.anim.frame = self.shadow.anim.frame + 1
                self.shadow.anim.acc = 0

                if self.shadow.lookAnim then
                    if self.shadow.anim.frame > self.assets["shadow"]["look"].frameCount then
                        self.shadow.anim.frame = 1
                    end
                else
                    if self.shadow.anim.frame > self.assets["shadow"]["saludos"]["saludo" .. self.shadow.saludState].frameCount then
                        self.shadow.anim.frame = 1
                    end
                end
            end
        end
    end

    self.scr_cutscene:update(elapsed)
    flux.update(elapsed)
end

function CutsceneState:leave()
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

    love.mouse.setVisible(true)
end

return CutsceneState
