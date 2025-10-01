local args = {...}
require 'src.Modules.System.Addons.prinf'
local user, token = args[1], args[2]
local jit = require 'jit'
local https = require 'https'
local utf8 = require 'utf8'
local bit = require 'bit'
local json = require 'libraries.json'

gamejolt = require 'src.Modules.System.Utils.Gamejolt'
local loggedin = false

if not gamejolt.isLoggedIn then
    local file = love.filesystem.getInfo("src/ApiConfig.json")

    if file then
        local filedata = json.decode(file ~= nil and love.filesystem.read("src/ApiConfig.json") or "{gamejolt={gameID = 0, gameKey=\"\"}}")
        if gamejolt.isLoggedIn then
            gamejolt.pingSession(true)
            io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client heartbeated a session (%s, %s){reset}", gamejolt.username, gamejolt.userToken))
            return
        end

        local code, body = https.request("https://gamejolt.com/api/game/v1/")   -- check internet --
        -- return if code is different from 200 (or sucess) --
        if code ~= 200 then 
            io.printf("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Failed to connect to gamejolt, please check your internet connection{reset}")
            return 
        end

        gamejolt.init(filedata.gamejolt.gameID, filedata.gamejolt.gameKey)
        if user == "" and token == "" then return end

        local state = gamejolt.authUser(user, token)

        if not state then
            io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client failed to connect to gamejolt (%s , %s) {reset}", user, token))
            return
        end

        gamejolt.openSession()
        io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client connected (%s, %s){reset}", gamejolt.username, gamejolt.userToken))

        local success = gamejolt.pingSession(true)
    end
end


if loggedin then
    gamejolt.pingSession(true)
    io.printf(string.format("{bgGreen}{brightWhite}{bold}[Gamejolt]{reset}{brightWhite} : Client heartbeated a session (%s, %s){reset}", gamejolt.username, gamejolt.userToken))
end
