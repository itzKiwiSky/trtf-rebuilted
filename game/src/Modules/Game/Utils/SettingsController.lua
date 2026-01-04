local SettingsController = {}

SettingsController.virtualSettings = {
    video = {
        winsize = 1,
        fullscreen = false,
        vsync = false,
        fpsCap = 200,
        filter = "nearest",
        showFPS = false,
    },
    audio = {
        masterVolume = 75,
        sfxVolume = 60,
        musicVolume = 60,
    },
    misc = {
        language = "English",
        gamejolt = {
            username = "",
            usertoken = ""
        },
        subtitles = true,
        discordRichPresence = true,
        lockCursor = false,
    }
}

---Used to sync from the interal module to the save file but don't save
function SettingsController.syncSave()
    gameSave.save.user.settings = SettingsController.virtualSettings
end

---Used to sync the configs on the save, to the internal lib --
function SettingsController.syncInternal()
    SettingsController.virtualSettings = gameSave.save.user.settings
end

function SettingsController.applySettings()
    local languageManager = require 'src.Modules.System.Utils.LanguageManager'
    -- videos settings --
    local winSize = love.window.resolutionModes[gameSave.save.user.settings.video.winsize]
    love.window.setVSync(gameSave.save.user.settings.video.vsync and 1 or 0)
    love.window.setFullscreen(gameSave.save.user.settings.video.fullscreen)

    ---shove.resize(winSize.width, winSize.height)
    shove.updateWindowMode(winSize.width, winSize.height, {
        fullscreen = gameSave.save.user.settings.video.fullscreen,
        vsync = gameSave.save.user.settings.video.vsync,
    })

    love._showFPS = gameSave.save.user.settings.video.showFPS

    love._FPSCap = gameSave.save.user.settings.video.fpsCap
    love.graphics.setDefaultFilter(
        gameSave.save.user.settings.video.filter and "linear" or "nearest",
        gameSave.save.user.settings.video.filter and "linear" or "nearest"
    )

    if gameSave.save.user.settings.misc.lockCursor then
        love.mouse.setRelativeMode(true)
        fakeCursor.x = love.graphics.getWidth() / 2
        fakeCursor.y = love.graphics.getHeight() / 2
    else
        love.mouse.setRelativeMode(false)
    end
    -- audio --
    love.audio.setVolume(gameSave.save.user.settings.audio.masterVolume * 0.01)
    -- misc stuff --
    languageService = languageManager.getData(gameSave.save.user.settings.misc.language)
    languageRaw = languageManager.getRawData(gameSave.save.user.settings.misc.language)
end

return SettingsController
