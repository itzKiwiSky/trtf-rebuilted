return function(this)
    switch(this.camID, {
        ["arcade"] = function()
            -- only bonnie --
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["arcade"]) then
                -- only bonnie --
                this.cameraMeta["arcade"].frame = 4
            else
                this.cameraMeta["arcade"].frame = 1
            end
        end,
        ["storage"] = function()
            
        end,
        ["dining_area"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["dining_area"]) then
                -- only chica --
                this.cameraMeta["dining_area"].frame = 3
            else
                -- empty --
                this.cameraMeta["dining_area"].frame = 2
            end
        end,
        ["pirate_cove"] = function()
            
        end,
        ["parts_and_service"] = function()
            
        end,
        ["showstage"] = function()
            if 
                collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["showstage"]) and 
                collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["showstage"])
            then
                -- chica and bonnie --
                this.cameraMeta["showstage"].frame = 7
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["showstage"]) then
                -- only bonnie --
                this.cameraMeta["showstage"].frame = 5
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["showstage"]) then
                -- only chica --
                this.cameraMeta["showstage"].frame = 6
            else
                -- all animatronics left --
                this.cameraMeta["showstage"].frame = 8
            end
        end,
        ["kitchen"] = function()
            
        end,
        ["prize_corner"] = function()
            
        end,
        ["left_hall"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["left_hall"]) then
                -- only bonnie --
                this.cameraMeta["left_hall"].frame = 2
            else
                this.cameraMeta["left_hall"].frame = 1
            end
        end,
        ["right_hall"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["chica"], this.areas["right_hall"]) then
                -- only chica --
                this.cameraMeta["left_hall"].frame = 2
            else
                this.cameraMeta["left_hall"].frame = 1
            end
        end,
        ["left_vent"] = function()
            
        end,
        ["right_vent"] = function()
            
        end,
    })
end