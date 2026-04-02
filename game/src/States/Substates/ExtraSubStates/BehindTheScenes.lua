local BTS = {} -- is not reference to the korean pop band :angry: --
BTS.assets = {}
BTS.loaded = false

local function getComfortableScale(img, screenW, screenH, factor)
    if type(img) == "nil" then return end


    factor = factor or 0.8

    local sx = (screenW * factor) / img:getWidth()
    local sy = (screenH * factor) / img:getHeight()

    return math.min(sx, sy)
end

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function BTS:load()
    self.fnt_animatronics = fontcache.getFont("ocrx", 32)
    self.fnt_UI = fontcache.getFont("ocrx", 40)
    self.fnt_warn = fontcache.getFont("ocrx", 27)
    self.fnt_txt = fontcache.getFont("ocrx", 24)

    self.currentZoom = 0.75


    --love.graphics.release(self.assets)

    self.filesCatNames = {} -- store only name for the files --
    self.currentFileID = 1
    self.currentFile = ""
    self.currentCategory = ""

    self.isMaking = false
    self.isDisplaying = false

    self.lockjawdance = {
        cfg = {
            acc = 0,
            speed = 35,
            frame = 1
        }
    }
    self.lockjawdance.image, self.lockjawdance.quads = love.graphics.newQuadFromImage("array", "assets/images/game/loading_lockjaw")

    if not self.loaded then
        local files = fsutil.scanFolder("assets/images/game/extras/bts", true)
        for _, j in ipairs(files) do
            local isFolder = love.filesystem.getInfo(j).type == "directory"
            local folderName = j:match("[^/]+$")
            if isFolder then
                local fls = love.filesystem.getDirectoryItems(j)
                self.assets[folderName] = {}
                self.assets[folderName].count = 0
                self.assets[folderName].explain = false
                self.filesCatNames[folderName] = {}
                for f, v in ipairs(fls) do
                    local filename = (fls[f]:gsub("%.[^.]+$", "")):match("[^/]+$")
                    local ext = fls[f]:match("[^.]+$")
                    if ext == "txt" then
                        self.assets[folderName].explain = true
                    elseif ext == "png" then
                        self.filesCatNames[folderName][f] = filename
                        loveloader.newImage(self.assets[folderName], filename, j .. "/" .. fls[f])
                        self.assets[folderName].count = f
                    end
                end
            end
        end

        loveloader.start(function()
            ExtrasState.loadingData = false
            self.loaded = true
        end, function(k, h, f)
            if FEATURE_FLAGS.debug then
                io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : File loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}", f))
            end
        end)
    end

    self.txtLoaded = ""

    self.buttons = {}

    self.buttons["left"] = {
        ignore = false,
        text = " << ",
        x = shove.getViewportWidth() / 2 - 200,
        y = 672,
        hitbox = {},
    }
    self.buttons["left"].hitbox = newButtonHitbox(self.buttons["left"].x - 3, self.buttons["left"].y - 2, self.fnt_UI:getWidth(self.buttons["left"].text) + 8, self.fnt_UI:getHeight() + 8)

    self.buttons["right"] = {
        ignore = false,
        text = " >> ",
        x = self.buttons["left"].hitbox.x + self.buttons["left"].hitbox.w + 480,
        y = 672,
        hitbox = {},
    }
    self.buttons["right"].hitbox = newButtonHitbox(self.buttons["right"].x - 3, self.buttons["right"].y - 2, self.fnt_UI:getWidth(self.buttons["right"].text) + 8, self.fnt_UI:getHeight() + 8)

    self.buttons["back"] = {
        ignore = false,
        text = languageService["extras_category_bts_back"],
        x = shove.getViewportWidth() / 2 - 200,
        y = 128,
        hitbox = {},
    }

    self.buttons["back"].hitbox = newButtonHitbox(self.buttons["back"].x - 3, self.buttons["back"].y - 2, self.fnt_UI:getWidth(self.buttons["back"].text) + 8, self.fnt_UI:getHeight() + 8)
end

function BTS:draw()
    if not self.loaded then
        love.graphics.draw(self.lockjawdance.image, self.lockjawdance.quads[self.lockjawdance.cfg.frame], shove.getViewportWidth() / 2, shove.getViewportHeight() / 2, 0, 200 / 300, 200 / 300, 150, 150)

        local percent = 0
        if loveloader.resourceCount > 0 then percent = loveloader.loadedCount / loveloader.resourceCount end
        love.graphics.printf(languageService["extras_category_bts_loading"] .. string.format("\n%s%%", math.floor(percent * 100)), self.fnt_warn, 0, shove.getViewportHeight() / 2 + 160, shove.getViewportWidth(), "center")
    else
        if self.isDisplaying then
            local file = self.filesCatNames[self.currentCategory][self.currentFileID]
            local img = self.assets[self.currentCategory][file]
            local scale = getComfortableScale(img, shove.getViewportWidth(), shove.getViewportHeight(), 0.62)
            love.graphics.draw(img, shove.getViewportWidth() - 512, shove.getViewportHeight() / 2, 0, scale * self.currentZoom, scale * self.currentZoom, img:getWidth() / 2, img:getHeight() / 2)

            if self.isMaking then
                love.graphics.printf(self.currentCategory, self.fnt_warn, shove.getViewportWidth() / 2, self.buttons["left"].y, 256, "center")
            else
                love.graphics.printf(file, self.fnt_warn, shove.getViewportWidth() / 2 - 100, self.buttons["left"].y, 512, "center")

                if self.assets[self.currentCategory].explain then
                    if self.txtLoaded == "" then
                        if self.currentCategory == "Scrapped post night" then
                            self.txtLoaded = love.filesystem.read(languageRaw["__ENGINE__"]["freeRoamPath"])
                        elseif self.currentCategory == "Scrapped Classic mode" then
                            self.txtLoaded = love.filesystem.read(languageRaw["__ENGINE__"]["classicModePath"])
                        end
                    end
                end

                if self.currentCategory == "random stuff" and file == "jumpscare_wip" then
                    self.txtLoaded = languageService["type_his_name"]
                    love.graphics.setColor(1, 0, 0, 1)
                end

                love.graphics.printf(self.txtLoaded, self.fnt_txt, 400, self.buttons["left"].y - 70, 720, "center")
                love.graphics.setColor(1, 1, 1, 1)
            end

            for _, e in pairs(self.buttons) do
                love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
                love.graphics.print(e.text, self.fnt_UI, e.x, e.y)
                love.graphics.setColor(1, 1, 1, 1)
            end
        else
            local startY = 100
            local y = 0
            if self.currentCategory == "" then
                for k, value in spairs(self.filesCatNames) do
                    local posY = startY + y
                    local hbox = {
                        shove.getViewportWidth() / 2 - 200,
                        posY,
                        480,
                        self.fnt_animatronics:getHeight() + 4
                    }
                    love.graphics.print(k, self.fnt_animatronics, shove.getViewportWidth() / 2 - 200, posY)
                    love.graphics.rectangle("line", unpack(hbox))
                    y = y + (self.fnt_animatronics:getHeight() + 24)
                end
            end
        end
    end
end

function BTS:update(elapsed)
    local inside, mx, my = shove.mouseToViewport()
    if ExtrasState.loadingData then
        self.lockjawdance.cfg.acc = self.lockjawdance.cfg.acc + elapsed

        if self.lockjawdance.cfg.acc >= 1 / self.lockjawdance.cfg.speed then
            self.lockjawdance.cfg.acc = 0
            self.lockjawdance.cfg.frame = self.lockjawdance.cfg.frame + 1
            if self.lockjawdance.cfg.frame > #self.lockjawdance.quads then
                self.lockjawdance.cfg.frame = 1
            end
        end
    else
        if self.isDisplaying then
            if Controller:pressed("player_mouse_click") then
                if collision.pointRect({ x = mx, y = my }, self.buttons["back"].hitbox) then
                    self.currentFileID = 1
                    self.currentCategory = ""
                    self.isDisplaying = false
                    self.isMaking = false
                end
                if collision.pointRect({ x = mx, y = my }, self.buttons["left"].hitbox) then
                    if self.currentFileID > 1 then
                        self.currentFileID = self.currentFileID - 1
                    end
                end
                if collision.pointRect({ x = mx, y = my }, self.buttons["right"].hitbox) then
                    if self.currentFileID < self.assets[self.currentCategory].count then
                        self.currentFileID = self.currentFileID + 1
                    end
                end
            end
        else
            local startY = 100
            local y = 0
            if self.currentCategory == "" then
                for k, value in spairs(self.filesCatNames) do
                    local posY = startY + y
                    local hbox = {
                        x = shove.getViewportWidth() / 2 - 200,
                        y = posY,
                        w = 480,
                        h = self.fnt_animatronics:getHeight() + 4
                    }

                    if collision.pointRect({ x = mx, y = my }, hbox) then
                        if Controller:pressed("player_mouse_click") then
                            --print(k)
                            if k:match("(%f[%a])[Mm]aking(%f[%A])") then
                                self.isMaking = true
                            end
                            self.currentCategory = k
                            self.isDisplaying = true
                        end
                    end

                    y = y + (self.fnt_animatronics:getHeight() + 24)
                end
            end
        end
    end
end

function BTS:wheelmoved(x, y)
    if y < 0 then
        if self.currentZoom > 0.45 then
            self.currentZoom = self.currentZoom - 0.05
        end
    elseif y > 0 then
        if self.currentZoom < 2.3 then
            self.currentZoom = self.currentZoom + 0.05
        end
    end
end

function BTS:release()
    --self.loaded = false
    --love.graphics.release(self.assets)
end

return BTS
