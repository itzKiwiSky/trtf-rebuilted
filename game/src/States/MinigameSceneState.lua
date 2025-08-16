MinigameSceneState = {}

MinigameSceneState.currentMinigame = "debug"
MinigameSceneState.script = nil

local function getTableByName(tbl, val)
    for _, t in ipairs(tbl) do
        if t.name == val then
            return t
        end
    end
    return false
end

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function MinigameSceneState:enter()
    self.player = require 'src.Modules.Game.Minigame.Player'
    self.world = bump.newWorld(16)
    self.isShuttingDown = false
    
    AudioSources["sfx_minigame_loop_bg"]:play()
    AudioSources["sfx_minigame_loop_bg"]:setLooping(true)
    AudioSources["sfx_minigame_loop_bg"]:setVolume(0.5)

    self.faces = {}
    self.displayFace = {
        currentFace = "",
        flash = true,
        black = false,
        visible = false,
        flashCount = 0,
        flashTimer = timer.new(),
    }


    self.displayFace.flashTimer:script(function(sleep)
        sleep(3)
        while self.displayFace.flashCount < 25 do
            self.displayFace.visible = not self.displayFace.visible
            sleep(0.075)
            self.displayFace.flashCount = self.displayFace.flashCount + 1
        end
        sleep(0.01)
        for k, v in pairs(AudioSources) do
            v:stop()
        end
        self.displayFace.visible = true
        sleep(5)
        self.displayFace.visible = false
        self.displayFace.black = true
        sleep(3)
        gamestate.switch(MenuState)
    end)

    --self.displayFace.flashTimer:every(0.075, function ()
    --    self.displayFace.visible = not self.displayFace.visible
    --end)

    local files = love.filesystem.getDirectoryItems("assets/images/game/minigames/aftergame")
    for _, f in ipairs(files) do
        local filename = (((f:lower()):gsub(" ", "_")):gsub("%.[^.]+$", "")):match("[^/]+$")
        self.faces[filename] = love.graphics.newImage("assets/images/game/minigames/aftergame/" .. filename .. ".png")
    end

    self.mapdata = require 'assets.images.game.minigames.minigame_map'

    -- map parsing --
    self.map = {
        areas = {},
        collisions = {},
        spawnAreas = {},
        actionAreas = {},
    }

    local areasMap = getTableByName(self.mapdata.layers, "areas")
    local spawnAreaMap = getTableByName(self.mapdata.layers, "spawn_area")
    local actionZones = getTableByName(self.mapdata.layers, "action_zones")
    local collisions = getTableByName(self.mapdata.layers, "collision")

    for i = 1, #areasMap.objects, 1 do
        self.map.areas[areasMap.objects[i].properties["zone_name"]] = {
            color = areasMap.properties["debug_color"],
            x = areasMap.objects[i].x,
            y = areasMap.objects[i].y,
            w = areasMap.objects[i].width,
            h = areasMap.objects[i].height,
            properties = areasMap.objects[i].properties,
        }
    end

    for i = 1, #actionZones.objects, 1 do
        local actionArea = {
            color = actionZones.properties["debug_color"],
            x = actionZones.objects[i].x,
            y = actionZones.objects[i].y,
            w = actionZones.objects[i].width,
            h = actionZones.objects[i].height,
            direction = actionZones.objects[i].properties["direction"],
            locked = actionZones.objects[i].properties["locked"],
            increment = actionZones.objects[i].properties["increment"],
            meta = {
                enter = false,
            },
            kind = "portal"
        }

        self.world:add(actionArea, actionArea.x, actionArea.y, actionArea.w, actionArea.h)
        table.insert(self.map.actionAreas, actionArea)
    end

    for _, col in ipairs(collisions.objects) do
        local wall = {
            name = "wall_" .. _,
            kind = "solid",
            color = collisions.properties["debug_color"],
            x = col.x,
            y = col.y,
            w = col.width,
            h = col.height,
        }
        self.world:add(wall, wall.x, wall.y, wall.w, wall.h)
        table.insert(self.map.collisions, wall)
    end

    for i = 1, #spawnAreaMap.objects, 1 do
        self.map.spawnAreas[spawnAreaMap.objects[i].name] = spawnAreaMap.objects[i]
    end

    self.spawnAreas = {}

    local count = 0
    for _, obj in ipairs(spawnAreaMap.objects) do
        if self.spawnAreas[obj.name] == nil then
            self.spawnAreas[obj.name] = {
                x = obj.x,
                y = obj.y,
                w = obj.width,
                h = obj.height,
                centerX = obj.x + obj.width / 2,
                centerY = obj.y + obj.height / 2,
            }
            count = 0
        else
            count = count + 1
            self.spawnAreas[obj.name .. count] = {
                x = obj.x,
                y = obj.y,
                w = obj.width,
                h = obj.height,
                centerX = obj.x + obj.width / 2,
                centerY = obj.y + obj.height / 2,
            }
        end
    end

    local minigames = {
        ["bonnie"] = require 'src.Modules.Game.Minigame.Events.MinigameBonnie',
        ["foxy"] = require 'src.Modules.Game.Minigame.Events.MinigameFoxy'
    }

    self.displayText = ""
    self.fnt_text = fontcache.getFont("vcr", 34)
    self.script = minigames[self.currentMinigame] or {}
    
    if FEATURE_FLAGS.developerMode then
        registers.devWindowContent = function()
            Slab.BeginWindow("mainNightDev", { Title = "Minigame development" })
                Slab.Text("General settings")
                if Slab.CheckBox(registers.showDebugHitbox, "Show hitboxes") then
                    registers.showDebugHitbox = not registers.showDebugHitbox
                end
                Slab.Text("Player Cooldown")
                Slab.SameLine()
                if Slab.Input("playerSpeedCooldownInput", { Text = tostring(self.player.maxCooldown), ReturnOnText = false, NumbersOnly = true, Precision = 0.01 }) then
                    self.player.maxCooldown = Slab.GetInputNumber()
                end
                Slab.Separator()
                for name, script in spairs(minigames) do
                    if Slab.Button(name) then
                        self.currentMinigame = name
                        self.script = minigames[self.currentMinigame]
                        self.script.init()
                    end
                end
            Slab.EndWindow()
        end
    end

    -- animation and objects --
    self.animSets = {}

    --self.gameSprites = love.graphics.newImage("assets/images/game/minigames/game_spritesheet.png")
    self.barrierSprites = love.graphics.newImage("assets/images/game/minigames/barriers.png")
    local barrierQuads = love.graphics.getQuads(self.barrierSprites, "assets/images/game/minigames/barriers.json", "hash")
    self.animatronicSprites = love.graphics.newImage("assets/images/game/minigames/animatronics.png")
    self.animationsAnimatronics = love.graphics.getQuads(self.animatronicSprites, "assets/images/game/minigames/animatronics.json", "hash")

    -- separation of animations --
    local availableAnimatronics = { "freddy", "chica", "bonnie", "foxy", "kitty", "lockjaw" }

    for _, animatronic in ipairs(availableAnimatronics) do
        local anim = {
            down = {self.animationsAnimatronics[animatronic .. "_" .. 0], self.animationsAnimatronics[animatronic .. "_" .. 1]},
            left = {self.animationsAnimatronics[animatronic .. "_" .. 2], self.animationsAnimatronics[animatronic .. "_" .. 3]},
            right = {self.animationsAnimatronics[animatronic .. "_" .. 4], self.animationsAnimatronics[animatronic .. "_" .. 5]},
            up = {self.animationsAnimatronics[animatronic .. "_" .. 6], self.animationsAnimatronics[animatronic .. "_" .. 7]},
        }

        if animatronic == "bonnie" then
            anim["misc"] = { self.animationsAnimatronics[animatronic .. "_" .. 8], self.animationsAnimatronics[animatronic .. "_" .. 9] }
            anim["idle"] = self.animationsAnimatronics[animatronic .. "_" .. 10]
        else
            anim["idle"] = self.animationsAnimatronics[animatronic .. "_" .. 8]
        end

        self.animSets[animatronic] = anim
    end

    self.animSets["barrier"] = {
        ["small"] = barrierQuads["small"],
        ["big"] = barrierQuads["big"]
    }

    self.interferenceFX = love.graphics.newShader("assets/shaders/Interference.glsl")
    self.interferenceFX:send("intensity", 0.012)
    self.interferenceFX:send("speed", 100.0)
    self.interferenceIntensity = 0.012
    self.interferenceSpeed = 100.0
    self.interferenceData = {
        acc = 0,
        timer = 0.05,
        interferenceTimerMax = 2,
        interferenceTimerAcc = 0,
    }

    self.minigameCRT = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.vignette)
    .chain(moonshine.effects.chromasep)

    self.minigameCRT.chromasep.radius = 1
    
    self.mainMap = love.graphics.newImage("assets/images/game/minigames/map.png")
    self.decoCRT = love.graphics.newImage("assets/images/game/effects/perfect_crt.png")
    self.vignetteMask = love.graphics.newImage("assets/images/game/effects/vignette.png")

    self.player.animation.maxFrames = 2
    self.player.x = self.map.spawnAreas["freddy"].x + 8
    self.player.y = self.map.spawnAreas["freddy"].y + 16
    self.player.hitbox.x = self.player.x
    self.player.hitbox.y = self.player.y
    self.world:add(self.player.hitbox, self.player.hitbox.x, self.player.hitbox.y, self.player.hitbox.w, self.player.hitbox.h)

    --love.graphics.print(inspect(self.player.cooldown), 30, 64)

    self.gameBuffer = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight(), { readable = true })
    self.interfereceBuffer = love.graphics.newCanvas(shove.getViewportWidth(), shove.getViewportHeight(), { readable = true })

    self.currentArea = "showstage"

    self.minigameCam = camera(shove.getViewportWidth() / 2, shove.getViewportHeight() / 2)
    self.minigameCam:zoomTo(3.5)

    self.camView = {
        windowWidth = shove.getViewportWidth(),
        windowHeight = shove.getViewportHeight(),
        x = 0,
        y = 0,
        width = 2000,
        height = 800,
    }

    -- only execute scripted minigames if is a valid minigame script --
    if self.script.init then
        self.script.init()
    end
end

function MinigameSceneState:draw()
    if self.displayFace.black then
        return
    end

    love.graphics.push("all")
    love.graphics.setCanvas({self.gameBuffer, stencil = true})
        love.graphics.clear(0, 0, 0)

        self.minigameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        
            love.graphics.draw(self.mainMap)

            love.graphics.stencil(function()
                for k, areas in pairs(self.map.areas) do
                    if self.currentArea == k then
                        love.graphics.rectangle("fill", areas.x, areas.y, areas.w, areas.h)
                        --love.graphics.draw(vignetteMask, areas.x, areas.y, vignetteMask:getWidth() / areas.w, vignetteMask:getHeight() / areas.h)
                    end
                end
            end, "replace")

            love.graphics.setStencilTest("less", 1)
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle("fill", 0, 0, self.mainMap:getDimensions())
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setStencilTest()

            if self.script.draw then
                self.script.draw()
            end

            self.player.draw()
            -- debug --
            if FEATURE_FLAGS.developerMode and registers.showDebugHitbox then
                for k, areas in pairs(self.map.areas) do
                    if currentArea == k then
                        local cr, cg, cb = lume.color(areas.color)
                        drawBox(area, cr, cg, cb)
                    end
                end
                
                for _, walls in ipairs(self.map.collisions) do
                    local cr, cg, cb = lume.color(walls.color)
                    drawBox(walls, cr, cg, cb)
                end

                --for _, spawn in pairs(self.spawnAreas) do
                    --drawBox(spawn, 0.75, 0, 1)
                    --love.graphics.print(_, spawn.x, spawn.y - 5, 0, 0.5, 0.5)
                --end

                drawBox(self.player.hitbox, 0.75, 1, 0)
            end
        self.minigameCam:detach()

        --local cycleDuration = 0.3
        --local activeThreshold = 0.5
        --if (love.timer.getTime() % cycleDuration) / cycleDuration > activeThreshold == 0 then
        love.graphics.print(self.displayText, self.fnt_text, 64, shove.getViewportHeight() - 64)
        --end
    love.graphics.setCanvas()
    love.graphics.pop()

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, shove.getViewportDimensions())
    love.graphics.setColor(1, 1, 1, 1)

    self.interfereceBuffer:renderTo(function()
        love.graphics.clear()
        love.graphics.setShader(self.interferenceFX)
            love.graphics.draw(self.gameBuffer)
        love.graphics.setShader()
    end)

    self.minigameCRT(function()
        love.graphics.draw(self.interfereceBuffer)
        if self.displayFace.visible then
            love.graphics.draw(self.faces[self.displayFace.currentFace], 0, 0)
        end
        love.graphics.draw(self.decoCRT, 0, 0, 0, shove.getViewportWidth() / self.decoCRT:getWidth(), shove.getViewportHeight() / self.decoCRT:getHeight())
    end)
end

function MinigameSceneState:update(elapsed)
    self.player.update(elapsed)

    self.interferenceFX:send("time", love.timer.getTime())
    if not self.isShuttingDown then
        self.interferenceFX:send("intensity", self.interferenceIntensity)
        self.interferenceFX:send("speed", self.interferenceSpeed)

        self.interferenceIntensity = math.lerp(self.interferenceIntensity, 0.012, self.interferenceData.timer)

        self.interferenceData.interferenceTimerAcc = self.interferenceData.interferenceTimerAcc + elapsed
        if self.interferenceData.interferenceTimerAcc >= self.interferenceData.interferenceTimerMax then
            self.interferenceData.interferenceTimerAcc = 0
            self.interferenceData.interferenceTimerMax = math.random(4, 7)
            self.interferenceIntensity = math.random(1, 3)
        end
    end

    if self.isShuttingDown then
        self.displayFace.flashTimer:update(elapsed)
    end 

    -- set room size --
    local area = self.map.areas[self.currentArea]
    self.camView.width = area.w
    self.camView.height = area.h
    self.camView.x = area.x + self.camView.width / 2
    self.camView.y = area.y + self.camView.height / 2

    -- lógica de scroll da câmera considerando escala
    local windowW = shove.getViewportWidth()
    local windowH = shove.getViewportHeight()
    local scale = self.minigameCam.scale or 1

    local visibleW = windowW / scale
    local visibleH = windowH / scale

    local minX = area.x + visibleW / 2
    local maxX = (area.x + area.w) - visibleW / 2
    local minY = area.y + visibleH / 2
    local maxY = (area.y + area.h) - visibleH / 2

    local targetX = self.player.x
    local targetY = self.player.y

    -- se área menor que tela, centraliza
    if area.w <= visibleW then
        targetX = area.x + area.w / 2
    else
        targetX = math.max(minX, math.min(maxX, targetX))
    end
    if area.h <= visibleH then
        targetY = area.y + area.h / 2
    else
        targetY = math.max(minY, math.min(maxY, targetY))
    end

    self.minigameCam.x = targetX
    self.minigameCam.y = targetY

    if self.currentArea ~= k then
        for k, areas in pairs(self.map.areas) do
            if collision.rectRect(self.player, areas) then
                self.currentArea = k
            end
        end
    end

    if self.script.update then
        self.script.update(elapsed)
    end
end

function MinigameSceneState:leave()
    for k, v in pairs(AudioSources) do
        v:stop()
    end
end

return MinigameSceneState