return function()
    local file = love.filesystem.getInfo("src/ApiConfig.json")
    if file then
        local data = json.decode(file ~= nil and love.filesystem.read("src/ApiConfig.json") or "{}")
        local code, body = https.request("https://gamejolt.com/api/game/v1/")
        if code == 200 then
            gamejolt.init(data.gamejolt.gameID, data.gamejolt.gameKey)
            if gameSave.save.user.settings.misc.gamejolt.username ~= "" and gameSave.save.user.settings.misc.gamejolt.usertoken ~= "" then
                loggedin = gamejolt.authUser(gameSave.save.user.settings.misc.gamejolt.username, gameSave.save.user.settings.misc.gamejolt.usertoken)
                gamejolt.openSession()
                io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client connected (%s, %s){reset}", gamejolt.username, gamejolt.userToken))
            else
                io.printf("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client failed to connect to gamejolt {reset}")
            end
        else
            io.printf("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Failed to connect to gamejolt, please check your internet connection{reset}")
        end
    end
end