MinigameState = {}

local function getTableByName(tbl, val)
    for _, t in ipairs(tbl) do
        if t.name == val then
            return t
        end
    end
    return false
end

function MinigameState:enter()
    player = require 'src.Components.Modules.Game.Minigame.Player'

    minigameCRT = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.vignette)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)
    .chain(moonshine.effects.scanlines)

    minigameCRT.scanlines.width = 1.5
    minigameCRT.scanlines.opacity = 0.65

    minigameCRT.pixelate.feedback = 0.1
    minigameCRT.pixelate.size = {1.5, 1.5}
    minigameCRT.chromasep.radius = 1
    
    mainMap = love.graphics.newImage("assets/images/game/minigames/map.png")
    vignetteMask = love.graphics.newImage("assets/images/game/effects/vignette.png")
    mapdata = json.decode(love.filesystem.read("assets/images/game/minigames/minigame_map.json"))

    -- map parsing --
    map = {
        areas = {},
        collisions = {},
        spawnAreas = {},
        actionAreas = {},
    }

    local areasMap = getTableByName(mapdata.layers, "areas")
    local spawnAreaMap = getTableByName(mapdata.layers, "spawn_area")
    local actionZones = getTableByName(mapdata.layers, "action_zones")

    for i = 1, #areasMap.objects, 1 do
        map.areas[areasMap.objects[i].properties["zone_name"]] = {
            color = areasMap.color,
            x = areasMap.objects[i].x,
            y = areasMap.objects[i].y,
            w = areasMap.objects[i].width,
            h = areasMap.objects[i].height,
            properties = areasMap.objects[i].properties,
        }
    end

    for i = 1, #actionZones.objects, 1 do
        table.insert(map.actionAreas, {
            color = actionZones.color,
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

    for i = 1, #spawnAreaMap.objects, 1 do
        map.spawnAreas[spawnAreaMap.objects[i].name] = spawnAreaMap.objects[i]
    end

    player:init(map.spawnAreas["freddy"].x + 8, map.spawnAreas["freddy"].y + 8)

    --print(debug.formattable(map.areas))

    love.graphics.setBackgroundColor(0.5, 0.1, 0.6, 1)

    gameBuffer = love.graphics.newCanvas(love.graphics.getDimensions())

    currentArea = "showstage"

    minigameCam = camera()
    minigameCam:zoomTo(3.5)

    camView = {
        windowWidth = love.graphics.getWidth(),
        windowHeight = love.graphics.getHeight(),
        x = 0,
        y = 0,
        width = 2000,
        height = 800,
    }
end

function MinigameState:draw()
    
    love.graphics.setCanvas({gameBuffer, stencil = true})
        love.graphics.clear(0, 0, 0)

        minigameCam:attach()
        
            love.graphics.draw(mainMap)

            love.graphics.stencil(function()
                for k, areas in pairs(map.areas) do
                    if currentArea == k then
                        love.graphics.rectangle("fill", areas.x, areas.y, areas.w, areas.h)
                        --love.graphics.draw(vignetteMask, areas.x, areas.y, vignetteMask:getWidth() / areas.w, vignetteMask:getHeight() / areas.h)
                    end
                end
            end, "replace", 1)

            love.graphics.setStencilTest("less", 1)
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle("fill", 0, 0, mainMap:getWidth(), mainMap:getHeight())
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setStencilTest()

            for k, areas in pairs(map.areas) do
                if currentArea == k then
                    love.graphics.draw(vignetteMask, areas.x, areas.y, 0, areas.w / vignetteMask:getWidth() , areas.h / vignetteMask:getHeight())
                end
            end

            -- debug --
            if DEBUG_APP then
                for k, areas in pairs(map.areas) do
                    if currentArea == k then
                        local cr, cg, cb = lume.color(areas.color)
                        love.graphics.setColor(cr, cg, cb, 1)
                        love.graphics.rectangle("line", areas.x, areas.y, areas.w, areas.h)
                        love.graphics.setColor(cr, cg, cb, 0.4)
                        love.graphics.rectangle("fill", areas.x, areas.y, areas.w, areas.h)
                        love.graphics.setColor(1, 1, 1, 1)
                    end
                end

                for _, areas in ipairs(map.actionAreas) do
                    local cr, cg, cb = lume.color(areas.color)
                    love.graphics.setColor(cr, cg, cb, 1)
                    love.graphics.rectangle("line", areas.x, areas.y, areas.w, areas.h)
                    love.graphics.setColor(cr, cg, cb, 0.4)
                    love.graphics.rectangle("fill", areas.x, areas.y, areas.w, areas.h)
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
            
            player:draw()
        minigameCam:detach()

    love.graphics.setCanvas()

    love.graphics.print(debug.formattable(map.actionAreas), 30, 30)

    minigameCRT(function()
        love.graphics.draw(gameBuffer, 0, 0)
    end)
end

function MinigameState:update(elapsed)
    player:update(elapsed)

    -- set room size --
    camView.width = map.areas[currentArea].w
    camView.height = map.areas[currentArea].h
    camView.x = map.areas[currentArea].x + camView.width / 2
    camView.y = map.areas[currentArea].y + camView.height / 2

    if map.areas[currentArea].properties["scroll"] then
        minigameCam.x, minigameCam.y = player.x, player.y
    else
        minigameCam.x, minigameCam.y = camView.x, camView.y
    end

    for k, areas in pairs(map.areas) do
        if collision.rectRect(player, areas) then
            currentArea = k
        end
    end

    for i = 1, #map.actionAreas, 1 do
        local zone = map.actionAreas[i]
        zone.enter = false
    end

    for _, zone in ipairs(map.actionAreas) do
        if collision.rectRect(player, zone) and not zone.enter then
            zone.enter = true
            switch(zone.direction, {
                ["up"] = function()
                    player.y = player.y - zone.increment
                end,
                ["down"] = function()
                    player.y = player.y + zone.increment
                end,
                ["left"] = function()
                    player.x = player.x - zone.increment
                end,
                ["right"] = function()
                    player.x = player.x + zone.increment
                end
            })
        end
    end

    -- camera bounds --

end

function MinigameState:keypressed()
    
end

function MinigameState:wheelmoved(x, y)
    if y < 0 then
        if minigameCam.scale > 0.1 then
            minigameCam.scale = minigameCam.scale - 0.05
        end
    elseif y > 0 then
        if minigameCam.scale < 3.9 then
            minigameCam.scale = minigameCam.scale + 0.05
        end
    end
end

return MinigameState