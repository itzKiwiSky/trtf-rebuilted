MinigameSceneState = {}

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
            Slab.EndWindow()
        end
    end

    -- animation and objects --
    self.animSets = {
        ["animatronics"] = {},
    }

    self.gameSprites = love.graphics.newImage("assets/images/game/minigames/game_spritesheet.png")
    self.animatronicSprites = love.graphics.newImage("assets/images/game/minigames/animatronics.png")
    self.animationsAnimatronics = love.graphics.getQuads(self.animatronicSprites, "assets/images/game/minigames/animatronics.json", "hash")
--    print(inspect(self.animationsAnimatronics))

    -- separation of animations --
    local availableAnimatronics = { "freddy", "chica", "bonnie", "foxy", "kitty", "lockjaw" }
    for _, animatronic in ipairs(availableAnimatronics) do
        local anim = {
            down = {self.animationsAnimatronics[animatronic .. "_" .. 0], self.animationsAnimatronics[animatronic .. "_" .. 1]},
            left = {self.animationsAnimatronics[animatronic .. "_" .. 2], self.animationsAnimatronics[animatronic .. "_" .. 3]},
            right = {self.animationsAnimatronics[animatronic .. "_" .. 4], self.animationsAnimatronics[animatronic .. "_" .. 5]},
            up = {self.animationsAnimatronics[animatronic .. "_" .. 6], self.animationsAnimatronics[animatronic .. "_" .. 7]},
        }

        self.animSets[animatronic] = anim
    end

    self.interferenceFX = love.graphics.newShader("assets/shaders/Interference.glsl")
    self.interferenceFX:send("intensity", 0.012)
    self.interferenceFX:send("speed", 100.0)
    self.interferenceIntensity = 0.012
    self.interferenceSpeed = 100.0
    self.pixelationInterference = 1.5
    self.interferenceData = {
        acc = 0,
        timer = 0.05,
        interferenceTimerMax = 2,
        interferenceTimerAcc = 0,
    }

    self.minigameCRT = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.vignette)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)

    self.minigameCRT.pixelate.feedback = 0.1
    self.minigameCRT.pixelate.size = {1.5, 1.5}
    self.minigameCRT.chromasep.radius = 1
    
    self.mainMap = love.graphics.newImage("assets/images/game/minigames/map.png")
    self.decoCRT = love.graphics.newImage("assets/images/game/effects/perfect_crt.png")
    self.vignetteMask = love.graphics.newImage("assets/images/game/effects/vignette.png")
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

end

function MinigameSceneState:draw()
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
            

            -- debug --
            if FEATURE_FLAGS.developerMode and registers.showDebugHitbox then
                for k, areas in pairs(self.map.areas) do
                    if currentArea == k then
                        local cr, cg, cb = lume.color(areas.color)
                        drawBox(area, cr, cg, cb)
                    end
                end

                for _, areas in ipairs(self.map.actionAreas) do
                    local cr, cg, cb = lume.color(areas.color)
                    drawBox(areas, cr, cg, cb)
                end
                
                for _, walls in ipairs(self.map.collisions) do
                    local cr, cg, cb = lume.color(walls.color)
                    drawBox(walls, cr, cg, cb)
                end
            end
            self.player.draw()
            --drawBox(self.player.hitbox, 0.75, 1, 0)
        self.minigameCam:detach()

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
        love.graphics.draw(self.decoCRT, 0, 0, 0, shove.getViewportWidth() / self.decoCRT:getWidth(), shove.getViewportHeight() / self.decoCRT:getHeight())
    end)

    --love.graphics.print(inspect(self.player.animation), 45, 45)
    --love.graphics.print(inspect(self.map.actionAreas), 30, 30)
end

function MinigameSceneState:update(elapsed)
    self.player.update(elapsed)

    self.interferenceFX:send("time", love.timer.getTime())
    self.interferenceFX:send("intensity", self.interferenceIntensity)
    self.interferenceFX:send("speed", self.interferenceSpeed)
    self.minigameCRT.pixelate.size = { self.pixelationInterference, self.pixelationInterference }

    self.interferenceIntensity = math.lerp(self.interferenceIntensity, 0.012, self.interferenceData.timer)
    self.pixelationInterference = math.lerp(self.pixelationInterference, 1.5, self.interferenceData.timer)

    self.interferenceData.interferenceTimerAcc = self.interferenceData.interferenceTimerAcc + elapsed
    if self.interferenceData.interferenceTimerAcc >= self.interferenceData.interferenceTimerMax then
        self.interferenceData.interferenceTimerAcc = 0
        self.interferenceData.interferenceTimerMax = math.random(4, 7)
        self.interferenceIntensity = 5
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
end

function MinigameSceneState:keypressed()
    
end

return MinigameSceneState