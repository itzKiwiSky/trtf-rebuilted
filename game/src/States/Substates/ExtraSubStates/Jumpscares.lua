local Jumpscares = {}
Jumpscares.assets = {}
Jumpscares.multimedia = {
    showUI = true,
    playing = true,
    playSound = false,
}
Jumpscares.loaded = false

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function Jumpscares:load()
    self.buttons = {}
    self.jumpscaresController = require 'src.Modules.Game.JumpscareController'
    self.jumpscaresController.playAudio = false
    self.jumpscaresController.stopAllAudio = false
    self.jumpscaresController.audioVolume = 0.7
    self.fnt_animatronics = fontcache.getFont("ocrx", 32)
    self.fnt_UI = fontcache.getFont("ocrx", 40)
    self.fnt_warn = fontcache.getFont("ocrx", 27)

    self.animatronicCurrentID = 1
    self.animatronicNames = {
        "freddy",
        "freddy_power_out",
        "bonnie",
        "chica",
        "foxy",
        "sugar",
        "kitty",
        "puppet",
    }

    self.display = {
        ["freddy"] = "Freddy",
        ["freddy_power_out"] = "Freddy",
        ["bonnie"] = "Bonnie",
        ["chica"] = "Chica",
        ["foxy"] = "Foxy",
        ["sugar"] = "Sugar",
        ["kitty"] = "Kitty",
        ["puppet"] = "Puppet"
    }

    self.lockjawdance = {
        cfg = {
            acc = 0,
            speed = 35,
            frame = 1
        }
    }
    self.lockjawdance.image,self.lockjawdance.quads = love.graphics.newQuadFromImage("array", "assets/images/game/loading_lockjaw")

    if not self.loaded then
        local jmps = fsutil.scanFolder("assets/images/game/night/jumpscares", true)
        for _, j in ipairs(jmps) do
            local isFolder = love.filesystem.getInfo(j).type == "directory"
            local folderName = j:match("[^/]+$")
            if isFolder then
                local fls = love.filesystem.getDirectoryItems(j)
                self.assets[folderName] = {}
                self.assets[folderName].frameCount = 0
                if folderName == "freddy_power_out" then
                    table.sort(fls, function(a, b)
                        return tonumber(a:match("^(%d+)")) < tonumber(b:match("^(%d+)"))
                    end)
                end
                for f, v in ipairs(fls) do
                    loveloader.newImage(self.assets[folderName], "jmp_" .. f, j .. "/" .. fls[f])
                    self.assets[folderName].frameCount = f
                end
            end
        end

        loveloader.start(function()
            self.loaded = true
            self.jumpscaresController.frames = self.assets
            --print(inspect(self.jumpscaresController))
            --print(self.animatronicNames[self.animatronicCurrentID])
            self.jumpscaresController.id = self.animatronicNames[self.animatronicCurrentID]
            self.jumpscaresController.speedAnim = 36
            self.jumpscaresController:init()
        end, function(k, h, f)
            if FEATURE_FLAGS.debug then
                io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : File loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}", f))
            end
        end)
    end


    self.buttons["left"] = {
        ignore = false,
        text = " << ",
        x = shove.getViewportWidth() / 2 - 256,
        y = shove.getViewportHeight() / 2 + 270
    }
    self.buttons["left"].hitbox = newButtonHitbox(self.buttons["left"].x - 3, self.buttons["left"].y - 2, self.fnt_UI:getWidth(self.buttons["left"].text) + 8, self.fnt_UI:getHeight() + 8)

    self.buttons["right"] = {
        ignore = false,
        text = " >> ",
        x = shove.getViewportWidth() / 2 + 128,
        y = shove.getViewportHeight() / 2 + 270
    }
    self.buttons["right"].hitbox = newButtonHitbox(self.buttons["right"].x - 3, self.buttons["right"].y - 2, self.fnt_UI:getWidth(self.buttons["right"].text) + 8, self.fnt_UI:getHeight() + 8)

    AudioSources["msc_extras_bg"]:setVolume(0.1)

    self.assets["multimedia"] = {}
    self.assets["multimedia"].img = love.graphics.newImage("assets/images/game/multimedia.png")
    self.assets["multimedia"].quads = love.graphics.getQuads(self.assets["multimedia"].img, "assets/images/game/multimedia.json", "hash")

    loveView.loadView("src/Modules/Game/Views/JumpscaresMultimedia.lua")
end

function Jumpscares:draw()
    if not self.loaded then
        love.graphics.draw(self.lockjawdance.image, self.lockjawdance.quads[self.lockjawdance.cfg.frame], shove.getViewportWidth() / 2, shove.getViewportHeight() / 2, 0, 200 / 300, 200 / 300, 150, 150)

        local percent = 0
        if loveloader.resourceCount > 0 then percent = loveloader.loadedCount / loveloader.resourceCount end
        love.graphics.printf(languageService["extras_category_jumpscares_loading"] .. string.format("\n%s%%", math.floor(percent * 100)), self.fnt_warn, 0, shove.getViewportHeight() / 2 + 160, shove.getViewportWidth(), "center")
    else
        self.jumpscaresController.draw()

        love.graphics.printf(self.display[self.animatronicNames[self.animatronicCurrentID]], self.fnt_animatronics, 0, shove.getViewportHeight() / 2 + 276, shove.getViewportWidth(), "center")

        loveView.draw()
        
        for _, e in pairs(self.buttons) do
            --love.graphics.rectangle("line", e.hitbox.x, e.hitbox.y, e.hitbox.w, e.hitbox.h)
            love.graphics.print(e.text, self.fnt_UI, e.x, e.y)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function Jumpscares:update(elapsed)
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
    else
        loveView.update(elapsed)
        if self.multimedia.playing then
            self.jumpscaresController.update(elapsed)
        end
    end
end

function Jumpscares:mousepressed(x, y, button)
    local inside, mx, my = shove.mouseToViewport()

    if button == 1 then
        for k, e in pairs(self.buttons) do
            if collision.pointRect({ x = mx, y = my }, e.hitbox) then
                if k == "left" then
                    if self.animatronicCurrentID > 1 then
                        self.animatronicCurrentID = self.animatronicCurrentID - 1
                        self.jumpscaresController.id = self.animatronicNames[self.animatronicCurrentID]
                        self.jumpscaresController.speedAnim = 36
                        self.jumpscaresController.init()
                    end
                end
                if k == "right" then
                    if self.animatronicCurrentID < #self.animatronicNames then
                        self.animatronicCurrentID = self.animatronicCurrentID + 1
                        self.jumpscaresController.id = self.animatronicNames[self.animatronicCurrentID]
                        self.jumpscaresController.speedAnim = 36
                        self.jumpscaresController.init()
                    end
                end
            end
        end
    end
end

return Jumpscares