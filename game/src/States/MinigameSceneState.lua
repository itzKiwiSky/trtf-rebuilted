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
    love.graphics.setColor(r / 255, g / 255, b / 255, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r / 255, g / 255, b / 255)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(1, 1, 1, 1)
end

function MinigameSceneState:enter()
    self.player = require 'src.Modules.Game.Minigame.Player'
    self.world = bump.newWorld(16)

    if FEATURE_FLAGS.developerMode then
        registers.devWindowContent = function()
            Slab.BeginWindow("mainNightDev", { Title = "Night development" })
                Slab.Text("General settings")
                if Slab.CheckBox(registers.showDebugHitbox, "Show mouse hitboxes") then
                    registers.showDebugHitbox = not registers.showDebugHitbox
                end
            Slab.EndWindow()
        end
    end

    self.minigameCRT = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.vignette)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)
    .chain(moonshine.effects.scanlines)

    self.minigameCRT.scanlines.width = 1.5
    self.minigameCRT.scanlines.opacity = 0.65

    self.minigameCRT.pixelate.feedback = 0.1
    self.minigameCRT.pixelate.size = {1.5, 1.5}
    self.minigameCRT.chromasep.radius = 1
    
    self.mainMap = love.graphics.newImage("assets/images/game/minigames/map.png")
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
        table.insert(self.map.actionAreas, {
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
            }
        })
    end

    for _, col in ipairs(collisions.objects) do
        local wall = {
            name = "wall_" .. _,
            color = collisions.properties["debug_color"],
            x = col.x,
            y = col.y,
            w = col.width,
            h = col.height,
        }
        self.world:add(wall, wall.x, wall.y, wall.w, wall.h)
    end

    for i = 1, #spawnAreaMap.objects, 1 do
        self.map.spawnAreas[spawnAreaMap.objects[i].name] = spawnAreaMap.objects[i]
    end

    self.player.x = self.map.spawnAreas["freddy"].x + 8
    self.player.y = self.map.spawnAreas["freddy"].y + 8
    self.world:add( self.player,  self.player.x,  self.player.y,  self.player.w,  self.player.h)

    love.graphics.print(inspect(self.player.cooldown), 30, 64)
    --print(debug.formattable(map.areas))

    --love.graphics.setBackgroundColor(0.5, 0.1, 0.6, 1)

    self.gameBuffer = love.graphics.newCanvas(shove.getViewportDimensions())

    self.currentArea = "showstage"

    self.minigameCam = camera()
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
    
    love.graphics.setCanvas({self.gameBuffer, stencil = true})
        love.graphics.clear(0, 0, 0)

        self.minigameCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)
        
            love.graphics.draw(self.mainMap)

            love.graphics.stencil(function()
                for k, areas in pairs(self.map.areas) do
                    if currentArea == k then
                        love.graphics.rectangle("fill", areas.x, areas.y, areas.w, areas.h)
                        --love.graphics.draw(vignetteMask, areas.x, areas.y, vignetteMask:getWidth() / areas.w, vignetteMask:getHeight() / areas.h)
                    end
                end
            end, "replace")

            love.graphics.setStencilTest("greater", 1)
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle("fill", 0, 0, self.mainMap:getWidth(), self.mainMap:getHeight())
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setStencilTest()

            for k, areas in pairs(self.map.areas) do
                if currentArea == k then
                    love.graphics.draw(self.vignetteMask, areas.x, areas.y, 0, areas.w / self.vignetteMask:getWidth() , areas.h / self.vignetteMask:getHeight())
                end
            end

            -- debug --
            if FEATURE_FLAGS.developerMode and registers.showDebugHitbox then
                for k, areas in pairs(self.map.areas) do
                    if currentArea == k then
                        local cr, cg, cb = lume.color(areas.color)
                        love.graphics.setColor(cr, cg, cb, 0.4)
                        love.graphics.rectangle("fill", areas.x, areas.y, areas.w, areas.h)
                        love.graphics.setColor(cr, cg, cb, 1)
                        love.graphics.rectangle("line", areas.x, areas.y, areas.w, areas.h)
                        love.graphics.setColor(1, 1, 1, 1)
                    end
                end

                for _, areas in ipairs(self.map.actionAreas) do
                    local cr, cg, cb = lume.color(areas.color)
                    love.graphics.setColor(cr, cg, cb, 0.4)
                    love.graphics.rectangle("fill", areas.x, areas.y, areas.w, areas.h)
                    love.graphics.setColor(cr, cg, cb, 1)
                    love.graphics.rectangle("line", areas.x, areas.y, areas.w, areas.h)
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
            
            self.player.draw()
            drawBox(self.player, 200, 32, 10)
        self.minigameCam:detach()

    love.graphics.setCanvas()

    self.minigameCRT(function()
        love.graphics.draw(self.gameBuffer, 0, 0)
    end)

    --love.graphics.print(inspect(self.map.actionAreas), 30, 30)
end

function MinigameSceneState:update(elapsed)
    self.player.update(elapsed)

    -- set room size --
    self.camView.width = self.map.areas[self.currentArea].w
    self.camView.height = self.map.areas[self.currentArea].h
    self.camView.x = math.clamp(self.player.x - self.camView.width / 2, self.map.areas[self.currentArea].x, 
        self.map.areas[self.currentArea].x + self.map.areas[self.currentArea].w - self.camView.width
    )
    self.camView.y = math.clamp(self.player.y - self.camView.height / 2, self.map.areas[self.currentArea].y, 
        self.map.areas[self.currentArea].y + self.map.areas[self.currentArea].h - self.camView.height
    )
    --self.camView.x = self.map.areas[self.currentArea].x + self.camView.width / 2
    --self.camView.y = self.map.areas[self.currentArea].y + self.camView.height / 2
    --self.camView.scale =

    self.minigameCam.x, self.minigameCam.y = self.camView.x, self.camView.y

    for k, areas in pairs(self.map.areas) do
        if collision.rectRect(self.player, areas) then
            self.currentArea = k
        end
    end

    for i = 1, #self.map.actionAreas, 1 do
        local zone = self.map.actionAreas[i]
        zone.enter = false
    end

    for _, zone in ipairs(self.map.actionAreas) do
        if collision.rectRect(self.player, zone) and not zone.enter then
            zone.enter = true
            switch(zone.direction, {
                ["up"] = function()
                    self.player.y = self.player.y - zone.increment
                end,
                ["down"] = function()
                    self.player.y = self.player.y + zone.increment
                end,
                ["left"] = function()
                    self.player.x = self.player.x - zone.increment
                end,
                ["right"] = function()
                    self.player.x = self.player.x + zone.increment
                end
            })
        end
    end

    -- camera bounds --

end

function MinigameSceneState:keypressed()
    
end

function MinigameSceneState:wheelmoved(x, y)
    if y < 0 then
        if self.minigameCam.scale > 0.1 then
            self.minigameCam.scale = self.minigameCam.scale - 0.05
        end
    elseif y > 0 then
        if self.minigameCam.scale < 3.9 then
            self.minigameCam.scale = self.minigameCam.scale + 0.05
        end
    end
end

return MinigameSceneState