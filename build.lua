return {
    name = "The Return To Freddy's Rebuilt - Again",
    developer = "BrightSmile Team & KiwiStation",
    output = "./export",
    version = "0.0.1",
    love = "11.5",
    ignore = {
        "export", 
        "boot.cmd", 
        ".gitignore", 
        ".gitattribute", 
        ".commitid", 
        "icon_old.png", 
        "docs", 
        ".VSCodeCounter", 
        "project",
        "gjassets"
    },
    icon = "icon.png",
    identifier = "com.brightsmileteam.trtfrebuiltagain", 
    libs = { 
        --[[
        windows = {
            "assets/bin/win/https.dll",
            "assets/bin/win/discord-rpc.dll"
        },
        macos = {
            "assets/bin/macos/https.so",
            "assets/bin/macos/libdiscord-rpc.dylib"
        },
        linux = {
            "assets/bin/linux/https.so",
            "assets/bin/linux/libdiscord-rpc.so"
        },
        ]]--
        all = {"LICENSE"}
    },
    platforms = {"windows", "linux", "macos"} 
}