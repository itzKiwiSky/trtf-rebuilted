return function()
    local dataFile = "gamedata.dba"
    local fileExist = love.filesystem.getInfo(love.filesystem.getSourceBaseDirectory() .. "/" ..dataFile)
    --local th_install = love.thread.newThread("src/Components/Initialization/ThreadInstall.lua")
    if fileExist then
        print("[DEBUG] : Game data package found")
        -- Content management --
        if love.filesystem.isFused() then
            local sucessSource = love.filesystem.mount(love.filesystem.getSourceBaseDirectory(), "source") 
            local sucessData = love.filesystem.mount(love.filesystem.newFileData(love.filesystem.read("source/" .. dataFile), "gameassets.zip"), "assets")

            if not sucessSource then
                love.window.showMessageBox("Kiwi2D Error", "An Error occurred and the engine could not be initialized", "error")
                love.event.quit()
            else
                print("[DEBUG] : Mount on source with sucess")
            end

            if not sucessData then
                love.window.showMessageBox("Kiwi2D Error", "An Error occurred during load the 'gamedata.dba'. The file does not exist.", "error")
                love.event.quit()
            else
                print("[DEBUG] : Mount on assets with sucess")
            end
        end
    end
end