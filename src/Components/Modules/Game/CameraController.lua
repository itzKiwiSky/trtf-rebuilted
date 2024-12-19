return function(this)
    switch(this.camID, {
        ["arcade"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["arcade"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["arcade"])
            then
                this.cameraMeta["arcade"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["arcade"]) then
                this.cameraMeta["arcade"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["arcade"]) then
                this.cameraMeta["arcade"].frame = 3
            else
                this.cameraMeta["arcade"].frame = 4
            end
        end,
        ["storage"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["storage"]) 
            then
                this.cameraMeta["storage"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["storage"])
            then
                this.cameraMeta["storage"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["storage"])
            then
                this.cameraMeta["storage"].frame = 3
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["storage"])
            then
                this.cameraMeta["storage"].frame = 4
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["storage"]) then
                this.cameraMeta["storage"].frame = 5
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["storage"]) then
                this.cameraMeta["storage"].frame = 6
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["storage"]) then
                this.cameraMeta["storage"].frame = 7
            else
                this.cameraMeta["storage"].frame = 8
            end
        end,
        ["dining_area"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["dining_area"]) 
            then
                -- all --
                this.cameraMeta["dining_area"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["dining_area"]) 
            then
                -- all --
                this.cameraMeta["dining_area"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["dining_area"]) 
            then
                -- all --
                this.cameraMeta["dining_area"].frame = 3
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["dining_area"]) 
            then
                -- all --
                this.cameraMeta["showstage"].frame = 4
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["dining_area"]) then
                -- all --
                this.cameraMeta["dining_area"].frame = 5
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["dining_area"]) then
                -- all --
                this.cameraMeta["dining_area"].frame = 6
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["dining_area"]) then
                -- all --
                this.cameraMeta["dining_area"].frame = 7
            else
                this.cameraMeta["dining_area"].frame = 8
            end
        end,
        ["pirate_cove"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["foxy"], this.areas["pirate_cove"]) then
                this.cameraMeta["pirate_cove"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], this.areas["pirate_cove"]) then
                this.cameraMeta["pirate_cove"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["sugar"], this.areas["pirate_cove"]) then
                this.cameraMeta["pirate_cove"].frame = 3
            else
                this.cameraMeta["pirate_cove"].frame = 4
            end
        end,
        ["parts_and_service"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["sugar"], this.areas["parts_and_service"]) then
                this.cameraMeta["parts_and_service"].frame = 1
            else
                this.cameraMeta["parts_and_service"].frame = 2
            end
        end,
        ["showstage"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["showstage"]) 
            then
                -- all --
                this.cameraMeta["showstage"].frame = 1
            elseif 
            collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["showstage"]) 
            then
                -- feddy chisca --
                this.cameraMeta["showstage"].frame = 2
            elseif 
            collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["showstage"]) 
            then
                -- bonnie feddy --
                this.cameraMeta["showstage"].frame = 3
            elseif 
            collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["showstage"]) 
            then
                -- bonnie chicas --
                this.cameraMeta["showstage"].frame = 4
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["showstage"]) then
                -- bonnie --
                this.cameraMeta["showstage"].frame = 5
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["showstage"]) then
                --  chicas --
                this.cameraMeta["showstage"].frame = 6
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["showstage"]) then
                -- feddy --
                this.cameraMeta["showstage"].frame = 7
            else
                -- empty --
                this.cameraMeta["showstage"].frame = 8
            end
        end,
        ["kitchen"] = function()
            return
        end,
        ["prize_corner"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["puppet"], this.areas["prize_corner"]) then
                this.cameraMeta["right_vent"].frame = 1
            else
                this.cameraMeta["right_vent"].frame = 2
            end
        end,
        ["left_hall"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["left_hall"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["left_hall"])
            then
                this.cameraMeta["left_hall"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["left_hall"]) then
                this.cameraMeta["left_hall"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["left_hall"]) then
                this.cameraMeta["left_hall"].frame = 3
            else
                this.cameraMeta["left_hall"].frame = 4
            end
        end,
        ["right_hall"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["right_hall"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["right_hall"])
            then
                this.cameraMeta["right_hall"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["right_hall"]) then
                this.cameraMeta["right_hall"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], this.areas["right_hall"]) then
                this.cameraMeta["right_hall"].frame = 3
            else
                this.cameraMeta["right_hall"].frame = 4
            end
        end,
        ["left_vent"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["sugar"], this.areas["left_vent"]) then
                this.cameraMeta["left_vent"].frame = 1
            else
                this.cameraMeta["left_vent"].frame = 2
            end
        end,
        ["right_vent"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["sugar"], this.areas["right_vent"]) then
                this.cameraMeta["right_vent"].frame = 1
            else
                this.cameraMeta["right_vent"].frame = 2
            end
        end,
    })
end