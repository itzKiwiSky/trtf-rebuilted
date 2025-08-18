Jumpscares = {}
Jumpscares.assets = {}
Jumpscares.loaded = false

local function newButtonHitbox(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

function Jumpscares:load()
    
    self.jumpscaresController = require 'src.Modules.Game.JumpscareController'
    self.jumpscaresController.playAudio = false
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

    local jmps = fsutil.scanFolder("assets/images/game/night/jumpscares", true)
    for _, j in ipairs(jmps) do
        local isFolder = love.filesystem.getInfo(j).type == "directory"
        local folderName = j:match("[^/]+$")
        if isFolder then
            local fls = love.filesystem.getDirectoryItems(j)
            self.assets[folderName] = {}
            self.assets[folderName].frameCount = 0
            for f = 1, #fls, 1 do
                loveloader.newImage(self.assets[folderName], "jmp_" .. f, j .. "/" .. fls[f])
                self.assets[folderName].frameCount = f
            end
        end
    end

    loveloader.start(function()
        self.loaded = true
        self.jumpscaresController.frames = self.assets
        --print(inspect(self.jumpscaresController))
        print(self.animatronicNames[self.animatronicCurrentID])
        self.jumpscaresController:init("", 36)
        self.jumpscaresController.id = self.animatronicNames[self.animatronicCurrentID]
        self.jumpscaresController.speedAnim = 36
    end, function(k, h, k)
        if FEATURE_FLAGS.debug then
            io.printf(string.format("{bgBrightMagenta}{brightCyan}{bold}[LOVE]{reset}{brightWhite} : File loaded with {brightGreen}sucess{reset} | {bold}{underline}{brightYellow}%s{reset}\n", k))
        end
    end)

    loveView.loadView("src/Modules/Game/Views/JumpscaresMultimedia.lua")
end

function Jumpscares:draw()
    if not self.loaded then
        love.graphics.draw(self.lockjawdance.image, self.lockjawdance.quads[self.lockjawdance.cfg.frame], shove.getViewportWidth() / 2, shove.getViewportHeight() / 2, 0, 200 / 300, 200 / 300, 150, 150)

        love.graphics.printf(languageService["extras_category_jumpscares_loading"], self.fnt_warn, 0, shove.getViewportHeight() / 2 + 160, shove.getViewportWidth(), "center")
    else
        self.jumpscaresController.draw()
        loveView.draw()
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
        self.jumpscaresController.update(elapsed)
    end
end

function Jumpscares:mousepressed(x, y, button)
    
end

return Jumpscares