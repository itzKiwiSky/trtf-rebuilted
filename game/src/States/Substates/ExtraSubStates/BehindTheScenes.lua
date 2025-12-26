local BTS = {} -- is not reference to the korean pop band :angry: --
BTS.assets = {}
BTS.loaded = false

function BTS:load()
    self.fnt_animatronics = fontcache.getFont("ocrx", 32)
    self.fnt_UI = fontcache.getFont("ocrx", 40)
    self.fnt_warn = fontcache.getFont("ocrx", 27)

    self.filesCatNames = {} -- store only name for the files --
    self.currentFileID = 0
    self.currentFile = ""
    self.currentCategory = ""

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
                self.filesCatNames[folderName] = {}
                for f, v in ipairs(fls) do
                    local filename = (fls[f]:gsub("%.[^.]+$", "")):match("[^/]+$")
                    local ext = fls[f]:match("[^.]+$")
                    self.assets[folderName][f] = filename
                    loveloader.newImage(self.assets[folderName], filename, j .. "/" .. fls[f])
                end
            end
        end

        loveloader.start(function()
            self.loaded = true
        end, function(k, h, f)
            if FEATURE_FLAGS.debug then
                io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : File loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}", f))
            end
        end)
    end
end

function BTS:draw()
    if not self.loaded then
        love.graphics.draw(self.lockjawdance.image, self.lockjawdance.quads[self.lockjawdance.cfg.frame], shove.getViewportWidth() / 2, shove.getViewportHeight() / 2, 0, 200 / 300, 200 / 300, 150, 150)

        local percent = 0
        if loveloader.resourceCount > 0 then percent = loveloader.loadedCount / loveloader.resourceCount end
        love.graphics.printf(languageService["extras_category_bts_loading"] .. string.format("\n%s%%", math.floor(percent * 100)), self.fnt_warn, 0, shove.getViewportHeight() / 2 + 160, shove.getViewportWidth(), "center")
    else
        if self.currentCategory == "" then
            for k, value in pairs(self.filesCatNames) do
                love.graphics.print()
            end
        end
    end
end

function BTS:update(elapsed)
    if not self.loaded then
        self.lockjawdance.cfg.acc = self.lockjawdance.cfg.acc + elapsed

        if self.lockjawdance.cfg.acc >= 1 / self.lockjawdance.cfg.speed then
            self.lockjawdance.cfg.acc = 0
            self.lockjawdance.cfg.frame = self.lockjawdance.cfg.frame + 1
            if self.lockjawdance.cfg.frame > #self.lockjawdance.quads then
                self.lockjawdance.cfg.frame = 1
            end
        end
        loveloader.update()
    end
end

function BTS:mousepressed(x, y, button)

end

function BTS:release()
    love.graphics.release(self.assets)
end

return BTS
