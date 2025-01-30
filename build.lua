return 
{
    -- basic settings:
    name = "Engine Test", -- name of the game for your executable
    developer = "BrightSmileTeam", -- dev name used in metadata of the file
    output = "export", -- output location for your game, defaults to $SAVE_DIRECTORY
    version = "0.0.1", -- "version" of your game, used to name the folder in output
    love = "11.5", -- version of LÖVE to use, must match github releases
    ignore = {
        "export",
        "project",
        ".gitattributes",
        ".gitignore"
    },
    icon = "resources/icon.png", -- 256x256px PNG icon for game, will be converted for you
    
    identifier = "com.brightsmileteam.trtf", -- macos team identifier, defaults to game.developer.name
    libs = { -- files to place in output directly rather than fuse
        all = {"./LICENSE"}
    },
    platforms = {"windows"} -- set if you only want to build for a specific platform
    
}