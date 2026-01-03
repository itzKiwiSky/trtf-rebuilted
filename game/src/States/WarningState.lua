WarningState = {}

function WarningState:enter()
    self.assets = {
        ["head"] = love.graphics.newImage("assets/images/game/menu/logo_new_feddy.png"),
        ["num"] = love.graphics.newImage("assets/images/game/menu/logo_new_num.png"),
        ["back"] = love.graphics.newImage("assets/images/game/menu/logo_new_back.png"),
    }

    self.audioSFX = love.audio.newSource("assets/sounds/sfx_warning_ignored.ogg", "stream")

    self.fnt_warn = fontcache.getFont("ocrx", 28)
    self.canPress = false

    local height = shove.getViewportHeight()

    local objColor = { lume.color("#0468C4") }
    local textColor = { lume.color("#6475C8") }
    self.objects = {
        ["head"] = {
            alpha = 0,
            scale = 0.4,
            posX = shove.getViewportWidth() / 2,
            posY = height,
            finalPosY = 180,
            angle = 0,
            color = objColor
        },
        ["num"] = {
            alpha = 0,
            scale = 0.4,
            posX = shove.getViewportWidth() / 2,
            posY = height,
            finalPosY = 180,
            angle = 0,
            color = objColor
        },
        ["back"] = {
            alpha = 0,
            scale = 0.4,
            posX = shove.getViewportWidth() / 2,
            posY = height,
            finalPosY = 180,
            angle = 0,
            color = objColor
        },
        ["text"] = {
            text = languageRaw["warn"],
            alpha = 0,
            posY = height,
            finalPosY = 400,
            color = textColor
        }
    }

    self.fadeTrans = {
        alpha = 0,
    }

    flux.to(self.objects["head"], 1, { posY = self.objects["head"].finalPosY, alpha = 1 })
        :delay(0.25)
        :ease("backinout")
        :oncomplete(function()
            self.objects["num"].posY = self.objects["num"].finalPosY
            flux.to(self.objects["back"], 1, { posY = self.objects["back"].finalPosY, alpha = 1 })
                :delay(0.1)
                :ease("backinout")
                :after(self.objects["num"], 1, { alpha = 1 })
                :oncomplete(function()
                    flux.to(self.objects["back"], 1, { angle = 360 }):ease("sineinout"):delay(0.3)
                end)
        end)

    flux.to(self.objects["text"], 1, { posY = self.objects["text"].finalPosY, alpha = 1 })
        :ease("backinout")
        :delay(3)
        :oncomplete(function() self.canPress = true end)

    self.ignored = false

    self.fxGlow = moonshine(moonshine.effects.gaussianblur)
    self.fxGlow.gaussianblur.sigma = 10

    self.cnv_glow = love.graphics.newCanvas(shove.getViewportDimensions())

    if gameSave.save.user.progress.warningIgnored then
        gamestate.switch(SplashState)
    end
end

function WarningState:draw()
    --love.graphics.draw(self.assets["head"])
    local function render()
        for key, obj in pairs(self.objects) do
            if key ~= "text" then
                love.graphics.setColor(obj.color[1], obj.color[2], obj.color[3], obj.alpha)
                love.graphics.draw(self.assets[key], obj.posX, obj.posY, math.rad(obj.angle), obj.scale, obj.scale, 256, 256)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end

        love.graphics.setColor(self.objects["text"].color[1], self.objects["text"].color[2], self.objects["text"].color[3], self.objects["text"].alpha)
        love.graphics.printf(table.concat(self.objects["text"].text, ""), self.fnt_warn, 0, self.objects["text"].posY, shove.getViewportWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
    end

    self.cnv_glow:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        self.fxGlow(function()
            render()
        end)
    end)

    love.graphics.setBlendMode("add")
    love.graphics.draw(self.cnv_glow)
    love.graphics.setBlendMode("alpha")
    render()

    love.graphics.setColor(0, 0, 0, self.fadeTrans.alpha)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)
end

function WarningState:update(elapsed)
    flux.update(elapsed)
end

function WarningState:keypressed(k)
    if not self.canPress then return end
    if self.ignored then return end
    if k == "return" then
        gameSave.save.user.progress.warningIgnored = true
        gameSave:saveSlot()
    end
    self.ignored = true
    self.audioSFX:play()
    flux.to(self.fadeTrans, 1.2, { alpha = 1 })
        :delay(2.5)
        :oncomplete(function()
            gamestate.switch(SplashState)
        end)
end

function WarningState:leave()
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

return WarningState
