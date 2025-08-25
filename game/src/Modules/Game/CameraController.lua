return function(self)
    switch(self.camID, {
        ["arcade"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["arcade"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["arcade"])
            then
                self.cameraMeta["arcade"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["arcade"]) then
                self.cameraMeta["arcade"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["arcade"]) then
                self.cameraMeta["arcade"].frame = 3
            else
                self.cameraMeta["arcade"].frame = 4
            end
        end,
        ["storage"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["storage"]) 
            then
                self.cameraMeta["storage"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["storage"])
            then
                self.cameraMeta["storage"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["storage"])
            then
                self.cameraMeta["storage"].frame = 3
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["storage"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["storage"])
            then
                self.cameraMeta["storage"].frame = 4
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["storage"]) then
                self.cameraMeta["storage"].frame = 5
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["storage"]) then
                self.cameraMeta["storage"].frame = 6
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["storage"]) then
                self.cameraMeta["storage"].frame = 7
            else
                self.cameraMeta["storage"].frame = 8
            end
        end,
        ["dining_area"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["dining_area"]) 
            then
                -- all --
                self.cameraMeta["dining_area"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["dining_area"]) 
            then
                -- all --
                self.cameraMeta["dining_area"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["dining_area"]) 
            then
                -- all --
                self.cameraMeta["dining_area"].frame = 3
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["dining_area"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["dining_area"]) 
            then
                -- all --
                self.cameraMeta["showstage"].frame = 4
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["dining_area"]) then
                -- all --
                self.cameraMeta["dining_area"].frame = 5
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["dining_area"]) then
                -- all --
                self.cameraMeta["dining_area"].frame = 6
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["dining_area"]) then
                -- all --
                self.cameraMeta["dining_area"].frame = 7
            else
                self.cameraMeta["dining_area"].frame = 8
            end
        end,
        ["pirate_cove"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["foxy"], self.areas["pirate_cove"]) then
                self.cameraMeta["pirate_cove"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["pirate_cove"]) then
                self.cameraMeta["pirate_cove"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["sugar"], self.areas["pirate_cove"]) then
                self.cameraMeta["pirate_cove"].frame = 3
            else
                self.cameraMeta["pirate_cove"].frame = 4
            end
        end,
        ["parts_and_service"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["sugar"], self.areas["parts_and_service"]) then
                self.cameraMeta["parts_and_service"].frame = 1
            else
                self.cameraMeta["parts_and_service"].frame = 2
            end
        end,
        ["showstage"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["showstage"]) 
            then
                -- all --
                self.cameraMeta["showstage"].frame = 1
            elseif 
            collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["showstage"]) 
            then
                -- feddy chisca --
                self.cameraMeta["showstage"].frame = 2
            elseif 
            collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["showstage"]) 
            then
                -- bonnie feddy --
                self.cameraMeta["showstage"].frame = 3
            elseif 
            collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["showstage"]) and
            collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["showstage"]) 
            then
                -- bonnie chicas --
                self.cameraMeta["showstage"].frame = 4
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["showstage"]) then
                -- bonnie --
                self.cameraMeta["showstage"].frame = 5
            elseif collision.rectRect(NightState.AnimatronicControllers["chica"], self.areas["showstage"]) then
                --  chicas --
                self.cameraMeta["showstage"].frame = 6
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["showstage"]) then
                -- feddy --
                self.cameraMeta["showstage"].frame = 7
            else
                -- empty --
                self.cameraMeta["showstage"].frame = 8
            end
        end,
        ["kitchen"] = function()
            return
        end,
        ["prize_corner"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["puppet"], self.areas["prize_corner"]) then
                self.cameraMeta["prize_corner"].frame = 1
            elseif not NightState.AnimatronicControllers["puppet"].released then
                self.cameraMeta["prize_corner"].frame = 2
            end
        end,
        ["left_hall"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["left_hall"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["left_hall"])
            then
                self.cameraMeta["left_hall"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["left_hall"]) then
                self.cameraMeta["left_hall"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["left_hall"]) then
                self.cameraMeta["left_hall"].frame = 3
            else
                self.cameraMeta["left_hall"].frame = 4
            end
        end,
        ["right_hall"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["right_hall"]) and
            collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["right_hall"])
            then
                self.cameraMeta["right_hall"].frame = 1
            elseif collision.rectRect(NightState.AnimatronicControllers["bonnie"], self.areas["right_hall"]) then
                self.cameraMeta["right_hall"].frame = 2
            elseif collision.rectRect(NightState.AnimatronicControllers["freddy"], self.areas["right_hall"]) then
                self.cameraMeta["right_hall"].frame = 3
            else
                self.cameraMeta["right_hall"].frame = 4
            end
        end,
        ["vent_sugar"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["sugar"], self.areas["left_vent"]) then
                self.cameraMeta["vent_sugar"].frame = 1
            else
                self.cameraMeta["vent_sugar"].frame = 2
            end
        end,
        ["vent_kitty"] = function()
            if collision.rectRect(NightState.AnimatronicControllers["kitty"], self.areas["right_vent"]) then
                self.cameraMeta["vent_kitty"].frame = 1
            else
                self.cameraMeta["vent_kitty"].frame = 2
            end
        end,
    })
end