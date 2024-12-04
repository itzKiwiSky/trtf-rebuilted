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
            
        end,
        ["pirate_cove"] = function()
            
        end,
        ["parts_and_service"] = function()
            
        end,
        ["showstage"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], this.areas["showstage"]) then
                -- only bonnie --
                this.cameraMeta["showstage"].frame = 5
            else
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
            
        end,
        ["left_vent"] = function()
            
        end,
        ["right_vent"] = function()
            
        end,
    })
end