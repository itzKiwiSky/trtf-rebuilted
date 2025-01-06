CustomNightMenuState = {}

local function doShitCalc(i)
    local p = animatronicsPortraits.portraits[i + 1]
    local row = math.floor(i / animatronicsPortraits.settings.maxPerRow)
    local col = i % animatronicsPortraits.settings.maxPerRow

    local totalRowWidth = (p.img:getWidth() + animatronicsPortraits.settings.spacingX) * animatronicsPortraits.settings.maxPerRow - animatronicsPortraits.settings.spacingX
    local startX = (love.graphics.getWidth() - totalRowWidth) / 2
    local px = startX + col * (p.img:getWidth() + animatronicsPortraits.settings.spacingX)
    local py = animatronicsPortraits.settings.startY + row * (p.img:getHeight() + animatronicsPortraits.settings.spacingY)
    return px, py
end

function CustomNightMenuState:enter()
    buttonCamera = require 'src.Components.Modules.Game.Utils.ButtonCamera'

    for k, v in pairs(AudioSources) do
        v:stop()
    end

    AudioSources["msc_arcade"]:setLooping(true)
    AudioSources["msc_arcade"]:setVolume(0.54)
    AudioSources["msc_arcade"]:play()


    fxBlurBG = moonshine(moonshine.effects.boxblur)
    fxBlurBG.boxblur.radius = {7, 7}
    shdFXScreen = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.pixelate)
    .chain(moonshine.effects.chromasep)

    
    shdFXScreen.pixelate.feedback = 0.1
    shdFXScreen.pixelate.size = {1.5, 1.5}

    shdFXScreen.chromasep.radius = 1

    menuCam = camera.new(0, nil)
    menuCam.factorX = 25
    menuCam.factorY = 34


    staticTextureFX = {
        config = {
            timer = 0,
            frameid = 1,
            speed = 0.05
        },
        frames = {}
    }
    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static")
    for s = 1, #statics, 1 do
        table.insert(staticTextureFX.frames, love.graphics.newImage("assets/images/game/effects/static/" .. statics[s]))
    end

    cnicons = {}
    local icfls = love.filesystem.getDirectoryItems("assets/images/game/night/cn_icons")
    for c = 1, #icfls, 1 do
        local name = icfls[c]:gsub("%.[^.]+$", "")
        if name ~= "dummy" then
            table.insert(cnicons, {
                img = love.graphics.newImage("assets/images/game/night/cn_icons/" .. icfls[c]),
                name = name,
            })
        end
    end

    challengePresets = json.decode(love.filesystem.read("assets/data/Presets.json"))

    crtOverlay = love.graphics.newImage("assets/images/game/effects/perfect_crt.png")

    CRASH = false
    goldenFeddy = love.graphics.newImage("assets/images/game/golden_alusinacion.png")

    fnt_cnTitle = fontcache.getFont("tnr", 40)
    fnt_menuCN = fontcache.getFont("ocrx", 30)
    fnt_values = fontcache.getFont("vcr", 40)

    animatronicsPortraits = {
        settings = {
            spacingX= 32,
            spacingY = 118,
            maxPerRow = 4,
            startY = 120
        },
        portraits = {}
    }

    for p = 1, #cnicons, 1 do
        table.insert(animatronicsPortraits.portraits, {
            img = cnicons[p].img,
            name = cnicons[p].name,
            value = 0,
            meta = {},
        })
    end

    for i = 0, #animatronicsPortraits.portraits - 1, 1 do
        local pt = animatronicsPortraits.portraits[i + 1]
        local px, py = doShitCalc(i)

        pt.meta.buttons = {}
        pt.meta.buttons[1] = {
            text = "<<",
            hitbox = buttonCamera(px, py + 230, 72, 72),
            visible = false,
            acc = 0,
            action = function()
                pt.value = pt.value - 1
            end
        }
        pt.meta.buttons[2] = {
            text = ">>",
            hitbox = buttonCamera(px + 128, py + 230, 72, 72),
            visible = false,
            acc = 0,
            action = function()
                pt.value = pt.value + 1
            end
        }
    end

    buttonsOptions = {}
    buttonsOptions["ready"] = {
        text = languageService["custom_night_menu_ready"],
        hitbox = buttonCamera(love.graphics.getWidth() - 150, love.graphics.getHeight() - 130, 128, 72),
        visible = false,
    }
    buttonsOptions["ready"].action = function()
        AudioSources["blip_ui"]:play()
        NightState.nightID = 1000
        NightState.isCustomNight = true
        for i = 1, #animatronicsPortraits.portraits, 1 do
            local port = animatronicsPortraits.portraits[i]
            NightState.animatronicsAI[port.name] = port.value
        end
        if NightState.animatronicsAI["bonnie"] == 1 and
        NightState.animatronicsAI["chica"] == 9 and
        NightState.animatronicsAI["foxy"] == 8 and
        NightState.animatronicsAI["freddy"] == 7
        then
            for k, v in pairs(AudioSources) do
                v:stop()
            end
            AudioSources["this_is_golden_feddy"]:play()
            CRASH = true
        else
            gamestate.switch(LoadingState)
        end
    end

    menuBG = love.graphics.newImage("assets/images/game/cn_menu.png")
    roomSize = {
        windowWidth = love.graphics.getWidth(),
        windowHeight = love.graphics.getHeight(),
        width = 1600,
        height = 900,
    }

    X_LEFT_FRAME = menuCam.x
    X_RIGHT_FRAME = menuCam.x + roomSize.width
    Y_TOP_FRAME = menuCam.y
    Y_BOTTOM_FRAME = menuCam.y + roomSize.height

    cnv_blurredBG = love.graphics.newCanvas(love.graphics.getDimensions())
    cnv_UIStuff = love.graphics.newCanvas(love.graphics.getDimensions())
end

function CustomNightMenuState:draw()
    if not CRASH then
        cnv_blurredBG:renderTo(function()
            love.graphics.clear(0, 0, 0, 0)
            fxBlurBG(function()
                menuCam:attach()
                    love.graphics.draw(menuBG)
                menuCam:detach()
            end)
        end)
    
        cnv_UIStuff:renderTo(function()
            love.graphics.clear(0, 0, 0, 0)
            love.graphics.printf(languageService["custom_night_menu_title"], fnt_cnTitle, 0, 32, love.graphics.getWidth(), "center")
    
            -- portrait renderer --
            for i = 0, #animatronicsPortraits.portraits - 1, 1 do
                local pt = animatronicsPortraits.portraits[i + 1]
                local btns = pt.meta.buttons
                local px, py = doShitCalc(i)
    
                love.graphics.draw(pt.img, px, py)
                love.graphics.setLineWidth(4)
                love.graphics.rectangle("line", px, py, pt.img:getWidth(), pt.img:getHeight())
                love.graphics.setLineWidth(1)
    
                love.graphics.printf(pt.value, fnt_values, px, py + 240, 200, "center")
    
                for _, b in ipairs(btns) do
                    love.graphics.setColor(0.5, 0.5, 0.5, 1)
                    love.graphics.rectangle("fill", b.hitbox.x + 8, b.hitbox.y + 8, b.hitbox.w - 8, b.hitbox.h - 8)
                    love.graphics.setColor(0.75, 0.75, 0.75, 1)
        
                    love.graphics.rectangle("fill", b.hitbox.x, b.hitbox.y, b.hitbox.w - 8, b.hitbox.h - 8)
                    love.graphics.setColor(1, 1, 1, 1)

                    love.graphics.setColor(0.25, 0.25, 0.25, 1)
                    love.graphics.printf(b.text, fnt_menuCN, b.hitbox.x + 3, b.hitbox.y + 10, b.hitbox.w - 8, "center")
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
    
            for k, b in pairs(buttonsOptions) do
                if b.active then
                    if love.timer.getTime() % 1 > 0.5 then
                        love.graphics.setColor(0, 0, 1, 1)
                    else
                        love.graphics.setColor(1, 1, 0, 1)
                    end
                else
                    love.graphics.setColor(0.5, 0.5, 0.5, 1)
                end
                love.graphics.rectangle("fill", b.hitbox.x + 8, b.hitbox.y + 8, b.hitbox.w - 8, b.hitbox.h - 8)
                love.graphics.setColor(0.75, 0.75, 0.75, 1)
    
                love.graphics.rectangle("fill", b.hitbox.x, b.hitbox.y, b.hitbox.w - 8, b.hitbox.h - 8)
                love.graphics.setColor(1, 1, 1, 1)
    
                love.graphics.setColor(0.5, 0.5, 0.5, 1)
                love.graphics.printf(b.text, fnt_menuCN, b.hitbox.x + 3, b.hitbox.y + 10, b.hitbox.w - 8, "center")
                love.graphics.setColor(1, 1, 1, 1)
            end
        end)
    
        shdFXScreen(function()
            love.graphics.draw(cnv_blurredBG)
    
            love.graphics.draw(cnv_UIStuff)
    
            love.graphics.draw(crtOverlay, 0, 0, 0, love.graphics.getWidth() / crtOverlay:getWidth(), love.graphics.getHeight() / crtOverlay:getHeight())
    
            love.graphics.setBlendMode("add")
                love.graphics.setColor(1, 1, 1, 0.07)
                    love.graphics.draw(staticTextureFX.frames[staticTextureFX.config.frameid], 0, 0)
                love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setBlendMode("alpha")
    
            --love.graphics.draw(mesh, 128, 128, 0, 128, 128)
        end)
    else
        love.graphics.draw(goldenFeddy, 0, 0, 0, love.graphics.getWidth() / goldenFeddy:getWidth(), love.graphics.getHeight() / goldenFeddy:getHeight())
    end
end

function CustomNightMenuState:update(elapsed)
    local smx, smy = love.mouse.getPosition()
    local mx, my = menuCam:mousePosition()
    menuCam.x = (roomSize.width / 2 + (mx - roomSize.width / 2) / menuCam.factorX)
    menuCam.y = (roomSize.height / 2 + (my - roomSize.height / 2) / menuCam.factorY)

    -- static animation --
    staticTextureFX.config.timer = staticTextureFX.config.timer + elapsed
    if staticTextureFX.config.timer >= staticTextureFX.config.speed then
        staticTextureFX.config.timer = 0
        staticTextureFX.config.frameid = staticTextureFX.config.frameid + 1
        if staticTextureFX.config.frameid >= #staticTextureFX.frames then
            staticTextureFX.config.frameid = 1
        end
    end

    if love.mouse.isDown(1) then
        for i = 1, #animatronicsPortraits.portraits, 1 do
            for _, b in ipairs(animatronicsPortraits.portraits[i].meta.buttons) do
                if b.acc > 0 then
                    b.acc = b.acc - 7 * elapsed
                end
                if collision.pointRect({x = smx, y = smy}, b.hitbox) and b.acc <= 0 then
                    AudioSources["blip_ui"]:play()
                    b.action()
                    if animatronicsPortraits.portraits[i].value < 0 then
                        animatronicsPortraits.portraits[i].value = 0
                    elseif animatronicsPortraits.portraits[i].value > 20 then
                        animatronicsPortraits.portraits[i].value = 20
                    end
                    b.acc = 1.2
                end
            end
        end
    end

    if CRASH and not AudioSources["this_is_golden_feddy"]:isPlaying() then
        love.event.quit()
    end

    -- camera bounds --
    if menuCam.x < X_LEFT_FRAME then
        menuCam.x = X_LEFT_FRAME
    end

    if menuCam.y < Y_TOP_FRAME then
        menuCam.y = Y_TOP_FRAME
    end

    if menuCam.x > X_RIGHT_FRAME then
        menuCam.x = X_RIGHT_FRAME
    end

    if menuCam.y > Y_BOTTOM_FRAME then
        menuCam.y = Y_BOTTOM_FRAME
    end
end

function CustomNightMenuState:mousepressed(x, y, button)
    if button == 1 then
        for k, b in pairs(buttonsOptions) do
            b.active = false
        end
        for k, b in pairs(buttonsOptions) do
            if collision.pointRect({x = love.mouse.getX(), y = love.mouse.getY()}, b.hitbox) then
                b.active = true
                b.action()
            end
        end
    end
end

return CustomNightMenuState