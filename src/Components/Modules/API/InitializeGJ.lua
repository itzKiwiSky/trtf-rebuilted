return function()
    local file = love.filesystem.getInfo("src/ApiStuff.json")
    if file then
        local data = json.decode(file ~= nil and love.filesystem.read("src/ApiStuff.json") or "{}")
        local code, body = http.request("http://gamejolt.com/api/game/v1/")
        if code == 200 then
            gamejolt.init(data.gamejolt.gameID, data.gamejolt.gameKey)
            if gameslot.save.game.user.settings.gamejolt.username ~= "" and gameslot.save.game.user.settings.gamejolt.usertoken ~= "" then
                gamejolt.authUser(
                    gameslot.save.game.user.settings.gamejolt.username,
                    gameslot.save.game.user.settings.gamejolt.usertoken
                )
                gamejolt.openSession()
                io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client connected (%s, %s){reset}\n", gamejolt.username, gamejolt.userToken))
            end
        else
            io.printf("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Failed to connect to gamejolt, please check your internet connection{reset}\n")
        end
    end
end