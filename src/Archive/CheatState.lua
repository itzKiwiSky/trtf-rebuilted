CheatState = {}

local function privateQuads(image, data)
    local image = love.graphics.newImage(image)
    local sparrow = json.decode(data)

    local quads = {}
    for key, obj in pairs(sparrow.frames) do
        quads[key:gsub("%.[^.]+$", "")] = love.graphics.newQuad(
            obj.frame.x,
            obj.frame.y,
            obj.frame.w,
            obj.frame.h,
            image
        )
    end

    return image, quads
end

local function addText(id, x, y, sx, sy)
    table.insert(texts, {
        quad = system_text_quads["txt" .. id],
        x = x,
        y = y,
        sx = sx,
        sy = sy,
    })
end

local function clearText()
    for i = #texts, 0, -1 do
        table.remove(texts, 1)
    end
end

function CheatState:enter()
    cryptdata = require 'libraries.neuron.Crypt'
    sound_pool = require 'src.Components.Modules.Utils.Sound'
    
    local binText = love.filesystem.read("assets/data/mapping_data.b64")
    local crypttext = cryptdata(binText, "YmxhY2tzbWlsZXRlYW0=")
    local unb64 = love.data.decode("string", "base64", crypttext)
    local systemData, err = loadstring(unb64)()

    shader_invert = love.graphics.newShader([[ vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) { vec4 col = texture2D( texture, texture_coords ); return vec4(1-col.r, 1-col.g, 1-col.b, col.a); } ]])

    accum = 0
    
    payloads = {
        reverse = false,
        randomMove = false,
        randomSize = false,
        moveWindow = false,
        sound = false,
        addTxt = false,
        crash = false,
    }

    tmr_reverse = timer.new()
    tmr_randomMove = timer.new()
    tmr_randomSize = timer.new()
    tmr_sound = timer.new()
    tmr_addText = timer.new()
    tmr_removeText = timer.new()
    tmr_crash = timer.new()

    tmr_reverse:every(1.7, function()
        payloads.reverse = not payloads.reverse
    end)

    tmr_randomMove:every(0.03, function()
        system_icon.x, system_icon.y = math.random(system_icon.img:getWidth() / 2, love.graphics.getWidth() - system_icon.img:getWidth() / 2), math.random(system_icon.img:getHeight() / 2, love.graphics.getHeight() - system_icon.img:getHeight() / 2)
        local t = system_text_quads[math.random(1, #system_text_quads)]
        if t then
            local qx, qy, qw, qh = t.quad:getViewport()
            t.x, t.y = math.random(0, love.graphics.getWidth() - qw), math.random(0, love.graphics.getHeight() - qh)
        end
    end)

    tmr_randomSize:every(1.4, function()
        system_icon.sx, system_icon.sy = math.random(0.3, 2), math.random(0.3, 2)

        local t = system_text_quads[math.random(1, #system_text_quads)]
        if t then
            local qx, qy, qw, qh = t.quad:getViewport()
            t.sx, t.sy = math.random(1, 20), math.random(1, 20)
        end
    end)

    tmr_addText:every(0.7, function()
        addText(
            math.random(1, #system_text_quads), 
            math.random(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2), 
            math.random(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2), 
            math.random(1, 3),
            math.random(1, 3)
        )
    end)

    tmr_removeText:every(2, function()
        clearText()
    end)


    tmr_crash:after(22, function()
        gameslot.save.game.user.canUse = true
        for i = 1, math.random(1, 4) do
            love.window.showMessageBox("Kiwi2D Internal error!", "GIVE UP", "error")
        end
        love.event.quit()
    end)

    system_icon = {
        img = love.graphics.newImage(love.data.decode("data", "base64", systemData["sys_main"])),
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        sx = 1,
        sy = 1,
        a = 0
    }

    cnv_texts = love.graphics.newCanvas(love.graphics.getDimensions())

    system_text_img, system_text_quads = privateQuads(love.data.decode("data", "base64", systemData["sys_text"]), love.data.decode("string", "base64", systemData["sys_text_data"]))
    print(debug.formattable(system_text_quads))
    texts = {}

    love.graphics.clear(0, 0, 0, 0)
end

function CheatState:draw()
    cnv_texts:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setShader(shader_invert)
            for _, t in ipairs(texts) do
                local qx, qy, qw, qh = t.quad:getViewport()
                love.graphics.draw(system_text_img, t.quad, t.x, t.y, 0, t.sx, t.sy)
            end
        love.graphics.setShader()
    end)


    love.graphics.draw(cnv_texts, 0, 0)
    if payloads.reverse then
        love.graphics.setShader(shader_invert)
    end
    love.graphics.draw(system_icon.img, system_icon.x, system_icon.y, math.rad(system_icon.a), system_icon.sx, system_icon.sy, system_icon.img:getWidth() / 2, system_icon.img:getHeight() / 2)

    love.graphics.setShader()
end

function CheatState:update(elapsed)
    tmr_reverse:update(elapsed)
    tmr_addText:update(elapsed)
    tmr_removeText:update(elapsed)
    tmr_randomMove:update(elapsed)
    tmr_randomSize:update(elapsed)
    tmr_crash:update(elapsed)

end

return CheatState