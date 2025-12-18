return function(night)
    local assets = {}

    local function loadBulk(key, path)
        local b = {}
        b.frameCount = 0
        local a = love.filesystem.getDirectoryItems(path)
        for s = 1, #a, 1 do
            loveloader.newImage(b, key .. s, path .. a[s])
            b.frameCount = s
        end
        a = nil
        collectgarbage("collect")
        return b
    end

    if night == "normal" then
        -- calls --
        assets.calls = {}
        local callsF = fsutil.scanFolder(languageRaw["__ENGINE__"].voicelinePath)
        for c = 1, #callsF, 1 do
            local filename = (((callsF[c]:lower()):gsub(" ", "_")):gsub("%.[^.]+$", "")):match("[^/]+$")
            loveloader.newSource(assets.calls, filename, callsF[c], "stream")
        end

        -- office --
        assets.office = {}

        loveloader.newImage(assets.office, "idle", "assets/images/game/night/office/idle.png")
        loveloader.newImage(assets.office, "off", "assets/images/game/night/office/off.png")

        -- front office --
        assets["front_office"] = {}

        loveloader.newImage(assets["front_office"], "idle", "assets/images/game/night/front_office/Empty.png")
        loveloader.newImage(assets["front_office"], "foxy1", "assets/images/game/night/front_office/Foxy.png")
        loveloader.newImage(assets["front_office"], "foxy2", "assets/images/game/night/front_office/Foxy2.png")
        loveloader.newImage(assets["front_office"], "foxy3", "assets/images/game/night/front_office/Foxy3.png")
        loveloader.newImage(assets["front_office"], "foxy4", "assets/images/game/night/front_office/Foxy4.png")

        loveloader.newImage(assets, "front_office_bonnie", "assets/images/game/night/front_office/Bonnie.png")
        loveloader.newImage(assets, "front_office_chica", "assets/images/game/night/front_office/Chica.png")

        loveloader.newImage(assets, "in_office_bonnie", "assets/images/game/night/in_office/bonnie.png")
        loveloader.newImage(assets, "in_office_chica", "assets/images/game/night/in_office/chica.png")

        loveloader.newImage(assets, "door_freddy_attack", "assets/images/game/night/freddy_door/attack.png")
        loveloader.newImage(assets, "door_freddy_idle", "assets/images/game/night/freddy_door/idle.png")

        loveloader.newImage(assets, "perfect_crt", "assets/images/game/effects/perfect_crt.png")

        -- fan --
        assets["fanAnim"] = {}
        assets["fanAnim"].frameCount = 0
        local numberOneFan = love.filesystem.getDirectoryItems("assets/images/game/night/fan")
        for f = 1, #numberOneFan, 1 do
            loveloader.newImage(assets["fanAnim"], "fan_" .. f, "assets/images/game/night/fan/" .. numberOneFan[f])
            assets["fanAnim"].frameCount = f
        end
        numberOneFan = nil

        -- door buttons --
        assets.doorButtons = { left = {}, right = {} }

        loveloader.newImage(assets.doorButtons.left, "on", "assets/images/game/night/doors/bl_on.png")
        loveloader.newImage(assets.doorButtons.left, "off", "assets/images/game/night/doors/bl_off.png")

        loveloader.newImage(assets.doorButtons.right, "on", "assets/images/game/night/doors/br_on.png")
        loveloader.newImage(assets.doorButtons.right, "off", "assets/images/game/night/doors/br_off.png")

        loveloader.newImage(assets.doorButtons.left, "not_ok", "assets/images/game/night/doors/bl_not_ok.png")
        loveloader.newImage(assets.doorButtons.right, "not_ok", "assets/images/game/night/doors/br_not_ok.png")

        -- doors --
        assets.doorsAnim = { left = {}, right = {} }

        local dl = love.filesystem.getDirectoryItems("assets/images/game/night/doors/door_left")
        assets.doorsAnim.left.frameCount = 0
        for a = 1, #dl, 1 do
            loveloader.newImage(assets.doorsAnim.left, "dl_" .. a, "assets/images/game/night/doors/door_left/" .. dl[a])
            assets.doorsAnim.left.frameCount = a
        end

        local dr = love.filesystem.getDirectoryItems("assets/images/game/night/doors/door_right")
        assets.doorsAnim.right.frameCount = 0
        for a = 1, #dl, 1 do
            loveloader.newImage(assets.doorsAnim.right, "dr_" .. a, "assets/images/game/night/doors/door_right/" .. dl
                [a])
            assets.doorsAnim.right.frameCount = a
        end

        dl, dr = nil, nil
        -- tablet --
        assets["tablet"] = {}
        assets["tablet"].frameCount = 0
        local tab = love.filesystem.getDirectoryItems("assets/images/game/night/tablet")
        for t = 1, #tab, 1 do
            loveloader.newImage(assets["tablet"], "tab_" .. t, "assets/images/game/night/tablet/" .. tab[t])
            assets["tablet"].frameCount = t
        end
        tab = nil

        -- mask --
        assets["maskAnim"] = {}
        assets["maskAnim"].frameCount = 0
        local mask = love.filesystem.getDirectoryItems("assets/images/game/night/mask")
        for m = 1, #mask, 1 do
            loveloader.newImage(assets["maskAnim"], "mask_" .. m, "assets/images/game/night/mask/" .. mask[m])
            assets["maskAnim"].frameCount = m
        end
        mask = nil

        -- cam ui stuff --
        loveloader.newImage(assets, "camMap", "assets/images/game/night/cameraUI/cam_map.png")
        loveloader.newImage(assets, "camSystemLogo", "assets/images/game/night/cameraUI/system_logo.png")
        loveloader.newImage(assets, "camSystemError", "assets/images/game/night/cameraUI/camera_error.png")

        -- cameras itself --
        assets["cameras"] = {}
        local cams = fsutil.scanFolder("assets/images/game/night/cameras", true)
        for _, c in ipairs(cams) do
            local isFolder = love.filesystem.getInfo(c).type == "directory"
            local folderName = c:match("[^/]+$")
            if isFolder then
                assets["cameras"][folderName] = {}
                local fls = love.filesystem.getDirectoryItems(c)
                assets["cameras"][folderName].frameCount = 0
                for f = 1, #fls, 1 do
                    loveloader.newImage(assets["cameras"][folderName], "cs_" .. f, c .. "/" .. fls[f])
                    assets["cameras"][folderName].frameCount = fls
                end
                fls = nil
            end
        end

        -- game ui stuff --
        loveloader.newImage(assets, "maskButton", "assets/images/game/night/gameUI/mask_hover.png")
        loveloader.newImage(assets, "camButton", "assets/images/game/night/gameUI/cam_hover.png")

        assets["staticfx"] = {}
        assets["staticfx"].frameCount = 0
        local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static3")
        for s = 1, #statics, 1 do
            loveloader.newImage(assets["staticfx"], "static_" .. s, "assets/images/game/effects/static3/" .. statics[s])
            assets["staticfx"].frameCount = s
        end
        statics = {}

        -- phone shit --
        local phone = love.filesystem.getDirectoryItems("assets/images/game/night/phone/anim")
        assets["phoneModel"] = {}
        assets["phoneModel"].frameCount = 0
        for p = 1, #phone, 1 do
            loveloader.newImage(assets["phoneModel"], "ph" .. p, "assets/images/game/night/phone/anim/" .. phone[p])
            assets["phoneModel"].frameCount = p
        end

        phone = nil
        loveloader.newImage(assets, "phone_bg", "assets/images/game/night/phone/UI/bg.png")
        loveloader.newImage(assets, "phone_refuse", "assets/images/game/night/phone/UI/phone_refuse_button.png")
        loveloader.newImage(assets, "phone_accept", "assets/images/game/night/phone/UI/phone_accept_button.png")

        -- jumpscares --
        local jmps = fsutil.scanFolder("assets/images/game/night/jumpscares", true)
        for _, j in ipairs(jmps) do
            local isFolder = love.filesystem.getInfo(j).type == "directory"
            local folderName = j:match("[^/]+$")
            if isFolder then
                local fls = love.filesystem.getDirectoryItems(j)
                assets[folderName] = {}
                assets[folderName].frameCount = 0
                if folderName == "freddy_power_out" then
                    table.sort(fls, function(a, b)
                        return tonumber(a:match("^(%d+)")) < tonumber(b:match("^(%d+)"))
                    end)
                end
                for f, v in ipairs(fls) do
                    loveloader.newImage(assets[folderName], "jmp_" .. f, j .. "/" .. fls[f])
                    assets[folderName].frameCount = f
                end
            end
        end
    elseif night == "secret" then
        assets.effects = {
            light = {},
            static = {},
        }
        assets.ui = {}
        assets.office = {
            states = {
                ["idle"] = {},
                ["look_back"] = {},
                ["boiler_open"] = {},
            },
            animatronic = {},
            animated = {}
        }

        loveloader.newImage(assets.ui, "flashlight_mask", "assets/images/game/night8/flashlight_mask.png")
        loveloader.newImage(assets.ui, "flashlight_icon", "assets/images/game/night8/flashlight_icon.png")
        loveloader.newImage(assets.ui, "flashlight_bg", "assets/images/game/night8/flashlight_bg.png")
        loveloader.newImage(assets.effects["light"], "flashlight", "assets/images/game/night8/flashlight.png")
        loveloader.newImage(assets.effects["light"], "light_beam", "assets/images/game/night8/lantern_light.png")
        loveloader.newImage(assets.effects["light"], "light_glare", "assets/images/game/night8/light_glare.png")
        loveloader.newImage(assets.office.states["idle"], "front", "assets/images/game/night8/front.png")
        loveloader.newImage(assets.office.states["idle"], "front_light", "assets/images/game/night8/front_light.png")
        loveloader.newImage(assets.office.states["idle"], "back", "assets/images/game/night8/back.png")
        loveloader.newImage(assets.ui, "hover_panel", "assets/images/game/night8/tablet_hover.png")
        loveloader.newImage(assets.ui, "hover_look", "assets/images/game/night8/look_hover.png")
        loveloader.newImage(assets.ui, "hover_monitor", "assets/images/game/night8/monitor_hover.png")
        loveloader.newImage(assets.ui, "bg_beeper", "assets/images/game/night8/bg_beeper.png")
        loveloader.newImage(assets, "wood_hold", "assets/images/game/night8/wood.png")

        assets.ui["pc_icons"] = {
            quads = {},
        }

        assets.ui["pc_icons"].image = love.graphics.newImage("assets/images/game/night8/pc_icons.png")
        assets.ui["pc_icons"].quads = love.graphics.getQuads(assets.ui["pc_icons"].image, "assets/images/game/night8/pc_icons.json", "hash")

        loveloader.newImage(assets, "monitor_static", "assets/images/game/night8/monitor_static.png")
        loveloader.newImage(assets.office.animatronic, "right", "assets/images/game/night8/lockjaw_states/infront1.png")
        loveloader.newImage(assets.office.animatronic, "front", "assets/images/game/night8/lockjaw_states/infront2.png")
        loveloader.newImage(assets.office.animatronic, "office", "assets/images/game/night8/lockjaw_states/near.png")
        loveloader.newImage(assets.office.animatronic, "office_light", "assets/images/game/night8/lockjaw_states/near_on.png")

        assets.effects["staticfx"] = loadBulk("static_", "assets/images/game/effects/static3/")
        assets.office.states["look_back"] = loadBulk("lb_", "assets/images/game/night8/look_back/")
        assets.office.states["boiler_open"] = loadBulk("bo_", "assets/images/game/night8/boiler_open/")
        assets["beeper"] = loadBulk("beep_", "assets/images/game/night8/beeper/")
        assets["monitor"] = loadBulk("mon", "assets/images/game/night8/monitor/")
        assets["loadUI"] = loadBulk("load", "assets/images/game/night8/load/", 0)

        assets["jumpscares"] = {
            ["frankburt"] = {
                ["front"] = loadBulk("frankburt_jmp", "assets/images/game/night8/jumpscares/lockjaw_jumpscare/"),
                ["back"] = loadBulk("frankburt_jmp", "assets/images/game/night8/jumpscares/lockjaw_jumpscare_back/")
            }
        }


        tab = nil
        collectgarbage("collect")
    end

    return assets
end
