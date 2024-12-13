local args = {...}
registers = args[1]
require 'src.Addons.ColoredWrite'
user, token = args[2], args[3]
jit = require 'jit'
https = require 'https'
utf8 = require 'utf8'
bit = require 'bit'
json = require 'libraries.json'

gamejolt = require 'libraries.gamejolt'
_connectGJ = require 'src.Components.Modules.API.InitializeGJ'
local loggedin = false

if not gamejolt.isLoggedIn then
    local file = love.filesystem.getInfo("src/ApiStuff.json")
    if file then
        local data = json.decode(file ~= nil and love.filesystem.read("src/ApiStuff.json") or "{}")
        local code, body = https.request("http://gamejolt.com/api/game/v1/")
        if code == 200 then
            gamejolt.init(data.gamejolt.gameID, data.gamejolt.gameKey)
            if user ~= "" and token ~= "" then
                loggedin = gamejolt.authUser(user, token)
                gamejolt.openSession()
                io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client connected (%s, %s){reset}\n", gamejolt.username, gamejolt.userToken))
            end
        else
            io.printf("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Failed to connect to gamejolt, please check your internet connection{reset}\n")
        end
    end
end


if loggedin then
    gamejolt.pingSession(true)
    io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client heartbeated a session (%s, %s){reset}\n", gamejolt.username, gamejolt.userToken))
end
