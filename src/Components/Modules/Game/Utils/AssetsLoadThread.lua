return function()
    local assets = {}

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

    -- fan --
    assets["fanAnim"] = {}
    local numberOneFan = love.filesystem.getDirectoryItems("assets/images/game/night/fan")
    for f = 1, #numberOneFan, 1 do
        loveloader.newImage(assets["fanAnim"], "fan_" .. f, "assets/images/game/night/fan/" .. numberOneFan[f])
    end
    numberOneFan = nil

    -- door buttons --
    assets.doorButtons = { left = {}, right = {} }

    loveloader.newImage(assets.doorButtons.left, "on", "assets/images/game/night/doors/bl_on.png")
    loveloader.newImage(assets.doorButtons.left, "off", "assets/images/game/night/doors/bl_off.png")

    loveloader.newImage(assets.doorButtons.right, "on", "assets/images/game/night/doors/br_on.png")
    loveloader.newImage(assets.doorButtons.right, "off", "assets/images/game/night/doors/br_off.png")

    -- doors --
    assets.doorsAnim = { left = {}, right = {} }

    local dl = love.filesystem.getDirectoryItems("assets/images/game/night/doors/door_left")
    for a = 1, #dl, 1 do
        loveloader.newImage(assets.doorsAnim.left, "dl_" .. a, "assets/images/game/night/doors/door_left/" .. dl[a])
    end

    local dr = love.filesystem.getDirectoryItems("assets/images/game/night/doors/door_right")
    for a = 1, #dl, 1 do
        loveloader.newImage(assets.doorsAnim.right, "dr_" .. a, "assets/images/game/night/doors/door_right/" .. dl[a])
    end

    dl, dr = nil, nil
    -- tablet --
    assets["tablet"] = {}
    local tab = love.filesystem.getDirectoryItems("assets/images/game/night/tablet")
    for t = 1, #tab, 1 do
        loveloader.newImage(assets["tablet"], "tab_" .. t, "assets/images/game/night/tablet/" .. tab[t])
    end
    tab = nil

    -- mask --
    assets["maskAnim"] = {}
    local mask = love.filesystem.getDirectoryItems("assets/images/game/night/mask")
    for m = 1, #mask, 1 do
        loveloader.newImage(assets["maskAnim"], "mask_" .. m, "assets/images/game/night/mask/" .. mask[m])
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
            for f = 1, #fls, 1 do
                loveloader.newImage(assets["cameras"][folderName], "cs_" .. f, c .. "/" .. fls[f])
            end
            fls = nil
        end
    end

    -- game ui stuff --
    loveloader.newImage(assets, "maskButton", "assets/images/game/night/gameUI/mask_hover.png")
    loveloader.newImage(assets, "camButton", "assets/images/game/night/gameUI/cam_hover.png")

    assets["staticfx"] = {}
    local statics = love.filesystem.getDirectoryItems("assets/images/game/effects/static3")
    for s = 1, #statics, 1 do
        loveloader.newImage(assets["staticfx"], "static_" .. s, "assets/images/game/effects/static3/" .. statics[s])
    end
    statics = {}

    -- phone shit --
    local phone = love.filesystem.getDirectoryItems("assets/images/game/night/phone/anim")
    assets["phoneModel"] = {}
    for p = 1, #phone, 1 do
        loveloader.newImage(assets["phoneModel"], "ph" .. p, "assets/images/game/night/phone/anim/" .. phone[p])
    end
    phone = nil

    -- jumpscares --
    assets["jumpscares"] = {}
    local jmps = fsutil.scanFolder("assets/images/game/night/jumpscares", true)
    for _, j in ipairs(jmps) do
        local isFolder = love.filesystem.getInfo(j).type == "directory"
        local folderName = j:match("[^/]+$")
        if isFolder then
            assets["jumpscares"][folderName] = {}
            local fls = love.filesystem.getDirectoryItems(j)
            for f = 1, #fls, 1 do
                loveloader.newImage(assets["jumpscares"][folderName], "jmp_" .. f, j .. "/" .. fls[f])
            end
            fls = nil
        end
    end

    return assets
end