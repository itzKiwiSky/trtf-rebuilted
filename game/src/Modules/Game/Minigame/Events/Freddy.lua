local Minigame = {}

function Minigame.init()
    Minigame.chars = {}
    --Minigame.chars["puppet"] = require 'src.Modules.Game.Minigame.Puppet'
    Minigame.statues = require 'src.Modules.Game.Minigame.Statues'
    Minigame.assets = {}
    Minigame.assets["tomato_sauce"] = love.graphics.newImage("assets/images/game/minigames/tomato_sauce.png")
    MinigameSceneState.displayFace.currentFace = "freddy"

    MinigameSceneState.displayDate = "1-11-2005"
    MinigameSceneState.displayText = languageService["minigame_display_freddy_collect_gift"]

    AudioSources["msc_bg_freddy"]:play()
    AudioSources["msc_bg_freddy"]:setLooping(true)
    AudioSources["msc_bg_freddy"]:setVolume(0.75)

    Minigame.currentGift = 1
    Minigame.showSauce = false

    Minigame.gifts = {}
    Minigame.assets["gifts"] = { img = nil, quads = {} }
    Minigame.assets["gifts"].img =  love.graphics.newImage("assets/images/game/minigames/gifts.png")
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
    local playerPos = MinigameSceneState.spawnAreas["freddy"]
    MinigameSceneState.player.setPos(playerPos.x, playerPos.y)

    -- hopefully the gift will spawn in correct order --
    table.sort(Minigame.gifts, function (a, b)
        return a.y < b.y
    end)

    --dinning_area
    Minigame.giftList = {
        {
            ["showstage"] = {
                direction = "left",
                area = "showstage"
            },
        },
        {
            ["dinning_area"] = "right",
            ["storage"] = {
                direction = "left",
                area = "storage"
            },
        },
        {
            ["dinning_area"] = "down",
            ["storage"] = "left",
            ["right_hall"] = "up",
        },
        {
            ["right_hall"] = "down",
            ["left_hall"] = "down",
        },
        {
            ["office_right_hall"] = "left",
            ["office_left_hall"] = "right",
        },
    }

    --Minigame.chars["puppet"]:init()
end

function Minigame.draw()
    -- draw gift --
    local gift = Minigame.gifts[Minigame.currentGift]
    --Minigame.chars["puppet"]:draw(MinigameSceneState.camView)
    for anim, char in pairs(Minigame.chars) do
        char:draw()
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
end

function Minigame.update(elapsed)
    local gift = Minigame.gifts[Minigame.currentGift]

    --Minigame.chars["puppet"]:update(MinigameSceneState.camView, Minigame, elapsed)

    if gift ~= nil then
        if collision.rectRect(MinigameSceneState.player.hitbox, gift) then
            Minigame.currentGift = Minigame.currentGift + 1
            AudioSources["sfx_collect"]:setVolume(1)
            AudioSources["sfx_collect"]:play()

            if Minigame.currentGift < #Minigame.gifts then
                --updatePuppetPos(Minigame)
                --Minigame.chars["puppet"]:updatePos(Minigame)
            end
        end

        if Minigame.currentGift > #Minigame.gifts then
            Minigame.showSauce = true           
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