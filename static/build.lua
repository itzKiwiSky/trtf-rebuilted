return {
    name = "The Return To Freddy's Rebuilt - Again",
    developer = "BrightSmile Team & KiwiStation",
    output = "./export",
    version = "0.0.1",
    love = "11.5",
    ignore = {
        -- folders --
        "static",
        "export",
        "assets",
        "project",
        "gjassets",
        "docs", 
        ".VSCodeCounter",
        ".git",
        -- files --
        "boot.cmd",
        "make.cmd",
        ".gitignore", 
        ".gitattribute", 
        ".commitid", 
        "README.md",
        "lookup.txt"
    },
    icon = "icon.png",
    identifier = "com.brightsmileteam.trtfrebuiltagain", 
    libs = { 
        all = {"static/LICENSE"}
    },
    platforms = {"love"} 
}