local Minigame = {}

local function updatePuppetPos(Minigame)
    Minigame.chars["puppet"].setArea(Minigame.giftList[Minigame.currentGift].startArea)
    print(Minigame.chars["puppet"].x, Minigame.chars["puppet"].y)

    table.clear(Minigame.chars["puppet"].currentAreas)
    for k, v in spairs(Minigame.giftList[Minigame.currentGift].activationAreas) do
        table.insert(Minigame.chars["puppet"].currentAreas, k)
    end

    print(#Minigame.chars["puppet"].currentAreas)

    --Minigame.chars["puppet"].currentAreas = Minigame.giftList[Minigame.currentGift].activationArea
    --Minigame.chars["puppet"].moveDirection = Minigame.giftList[Minigame.currentGift].direction

    Minigame.chars["puppet"].moveDirection = Minigame.giftList[Minigame.currentGift].activationAreas[MinigameSceneState.currentArea]
end

function Minigame.init()
    Minigame.chars = {}

    table.clear(Minigame.chars)

    --Minigame.chars["puppet"] = require 'src.Modules.Game.Minigame.Puppet'
    Minigame.statues = require 'src.Modules.Game.Minigame.Statues'
    Minigame.assets = {}
    Minigame.assets["tomato_sauce"] = love.graphics.newImage("assets/images/game/minigames/tomato_sauce.png")
    MinigameSceneState.displayFace.currentFace = "freddy"

    MinigameSceneState.displayDate = "11-04-2005"
    MinigameSceneState.displayText = languageService["minigame_display_freddy_collect_gift"]

    AudioSources["msc_bg_freddy"]:play()
    AudioSources["msc_bg_freddy"]:setLooping(true)
    AudioSources["msc_bg_freddy"]:setVolume(0.75)

    Minigame.currentGift = 1
    Minigame.showSauce = false
    Minigame.stopAll = false

    Minigame.gifts = {}
    Minigame.assets["gifts"] = { img = nil, quads = {} }
    Minigame.assets["gifts"].img = love.graphics.newImage("assets/images/game/minigames/gifts.png")
    Minigame.assets["gifts"].quads = love.graphics.getQuads(Minigame.assets["gifts"].img, "assets/images/game/minigames/gifts.json", "array")

    local charsPos = { "sugar", "bonnie", "chica", "foxy" }
    for _, c in ipairs(charsPos) do
        local char = Minigame.statues:new(MinigameSceneState.animatronicSprites,
            MinigameSceneState.animSets[c]["idle"],
            MinigameSceneState.spawnAreas[c].centerX, MinigameSceneState.spawnAreas[c].centerY, false, true
        )

        char.drawOffset.x = -14
        char.drawOffset.y = -12
        char.hitbox.w = 28
        char.hitbox.h = 24
        char.hitbox.x = MinigameSceneState.spawnAreas[c].centerX - 14
        char.hitbox.y = MinigameSceneState.spawnAreas[c].centerY - 16
        MinigameSceneState.world:add(char.hitbox, char.hitbox.x, char.hitbox.y, char.hitbox.w, char.hitbox.h)
        --table.insert(Minigame.chars, char)
        Minigame.chars[c] = char
    end

    for i = 0, 4, 1 do
        if i > 0 then
            table.insert(Minigame.gifts, MinigameSceneState.spawnAreas["spawn_gift" .. i])
        else
            table.insert(Minigame.gifts, MinigameSceneState.spawnAreas["spawn_gift"])
        end
    end

    --MinigameSceneState.spawnAreas["bonnie_child_minigame"]
    MinigameSceneState.player.sprite = "freddy"
    local playerPos = MinigameSceneState.spawnAreas["freddy"]
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)

    -- hopefully the gift will spawn in correct order --
    table.sort(Minigame.gifts, function(a, b)
        return a.y < b.y
    end)

    local barrier = Minigame.statues:new(MinigameSceneState.barrierSprites, MinigameSceneState.animSets["barrier"]["big"],
        MinigameSceneState.spawnAreas["barrier_big"].centerX, MinigameSceneState.spawnAreas["barrier_big"].centerY, false, false, 1
    )
    barrier.drawOffset.x = -8
    barrier.drawOffset.y = 8

    barrier.hitbox.w = MinigameSceneState.spawnAreas["barrier_big"].w
    barrier.hitbox.h = MinigameSceneState.spawnAreas["barrier_big"].h

    MinigameSceneState.world:add(barrier.hitbox, barrier.hitbox.x - 8, barrier.hitbox.y - 24, barrier.hitbox.w, barrier.hitbox.h)
    table.insert(Minigame.chars, barrier)

    Minigame.giftList = {
        {
            startArea = "showstage",
            activationAreas = {
                ["showstage"] = "left"
            },
        },
        {
            startArea = "dinning_area",
            activationAreas = {
                ["dinning_area"] = "right"
            },
        },
        {
            startArea = "dinning_area",
            activationAreas = {
                ["dinning_area"] = "down"
            },
        },
        {
            startArea = "left_hall",
            activationAreas = {
                ["left_hall"] = "down",
                ["right_hall"] = "down",
            },
        },
        {
            startArea = "office_left_hall",
            activationAreas = {
                ["office_left_hall"] = "right",
                ["office_right_hall"] = "left",
            },
        },
    }

    Minigame.chars["puppet"] = {
        img = love.graphics.newImage("assets/images/game/minigames/puppet.png"),
        x = 0,
        y = 0,
        puppetMoveCooldown = 0.5,
        step = 16,
        moveCooldown = 0.5,
        currentAreas = { "showstage" },
        moveDirection = "left",
    }

    Minigame.chars["puppet"].setArea = function(areaname)
        Minigame.chars["puppet"].x = MinigameSceneState.map.areas[areaname].centerX
        Minigame.chars["puppet"].y = MinigameSceneState.map.areas[areaname].centerY
    end

    updatePuppetPos(Minigame)
end

function Minigame.draw()
    -- draw gift --
    local gift = Minigame.gifts[Minigame.currentGift]
    for anim, char in pairs(Minigame.chars) do
        if char.draw then
            char:draw()
        end
    end

    if table.contains(Minigame.chars["puppet"].currentAreas, MinigameSceneState.currentArea) then
        love.graphics.draw(Minigame.chars["puppet"].img,
            Minigame.chars["puppet"].x, Minigame.chars["puppet"].y, 0,
            Minigame.chars["puppet"].moveDirection == "left" and -1.2 or 1.2, 1.2,
            Minigame.chars["puppet"].img:getWidth() / 2, Minigame.chars["puppet"].img:getHeight() / 2
        )
    end

    if Minigame.showSauce then
        love.graphics.draw(
            Minigame.assets["tomato_sauce"],
            MinigameSceneState.player.x, MinigameSceneState.player.y, 0, 2, 2,
            Minigame.assets["tomato_sauce"]:getWidth() / 2,
            Minigame.assets["tomato_sauce"]:getHeight() / 2
        )
    end

    if gift ~= nil then
        love.graphics.draw(Minigame.assets["gifts"].img, Minigame.assets["gifts"].quads[Minigame.currentGift], gift.x, gift.y, 0, 1.2, 1.2)
    end
    love.graphics.print(string.format("%s / %s", Minigame.currentGift, #Minigame.giftList), 30, 30)
end

function Minigame.update(elapsed)
    local gift = Minigame.gifts[Minigame.currentGift]


    if gift ~= nil then
        if collision.rectRect(MinigameSceneState.player.hitbox, gift) then
            Minigame.currentGift = Minigame.currentGift + 1
            AudioSources["sfx_collect"]:setVolume(1)
            AudioSources["sfx_collect"]:play()

            if Minigame.currentGift < #Minigame.gifts then
                updatePuppetPos(Minigame)
            end
        end

        if table.contains(Minigame.chars["puppet"].currentAreas, MinigameSceneState.currentArea) then
            Minigame.chars["puppet"].moveDirection = Minigame.giftList[Minigame.currentGift].activationAreas[MinigameSceneState.currentArea]
            Minigame.chars["puppet"].moveCooldown = Minigame.chars["puppet"].moveCooldown - elapsed
            if Minigame.chars["puppet"].moveCooldown <= 0 then
                switch(Minigame.chars["puppet"].moveDirection, {
                    ["left"] = function()
                        Minigame.chars["puppet"].x = Minigame.chars["puppet"].x - Minigame.chars["puppet"].step
                    end,
                    ["right"] = function()
                        Minigame.chars["puppet"].x = Minigame.chars["puppet"].x + Minigame.chars["puppet"].step
                    end,
                    ["up"] = function()
                        Minigame.chars["puppet"].y = Minigame.chars["puppet"].y - Minigame.chars["puppet"].step
                    end,
                    ["down"] = function()
                        Minigame.chars["puppet"].y = Minigame.chars["puppet"].y + Minigame.chars["puppet"].step
                    end,
                })
                Minigame.chars["puppet"].moveCooldown = Minigame.chars["puppet"].puppetMoveCooldown
            end
        else
            if Minigame.currentGift < #Minigame.giftList then
                if #Minigame.chars["puppet"].currentAreas <= 1 then
                    Minigame.chars["puppet"].setArea(Minigame.giftList[Minigame.currentGift].startArea)
                else
                    for k, v in spairs(Minigame.giftList[Minigame.currentGift].activationAreas) do
                        if MinigameSceneState.currentArea == k then
                            Minigame.chars["puppet"].setArea(k)
                        end
                    end
                end
            end
        end

        if Minigame.currentGift > #Minigame.gifts then
            for k, v in pairs(AudioSources) do
                if not Minigame.stopAll then
                    v:stop()
                end
            end
            MinigameSceneState.player.displayPlayer = false
            Minigame.stopAll = true
            Minigame.showSauce = true
            MinigameSceneState.player.locked = true
            MinigameSceneState.isShuttingDown = true
            MinigameSceneState.interferenceIntensity = 60
            MinigameSceneState.interferenceSpeed = 100
            MinigameSceneState.interferenceFX:send("intensity", MinigameSceneState.interferenceIntensity)
            MinigameSceneState.interferenceFX:send("speed", MinigameSceneState.interferenceSpeed)
            AudioSources["sfx_minigame_shutdown"]:setLooping(true)
            AudioSources["sfx_minigame_shutdown"]:play()
        end
    end
end

function Minigame.shutdown()
    -- release all assets used in the minigame --
    for k, asset in pairs(Minigame.assets) do
        if type(asset) == "userdata" then
            asset:release()
        end
    end
end

return Minigame
