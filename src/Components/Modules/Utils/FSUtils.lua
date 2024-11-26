local fsutils = {}

function fsutils.scanFolder(folder)
    local files = {}
    local function _scan(path)
        local items = love.filesystem.getDirectoryItems(path)

        for _, item in ipairs(items) do
            local iPath = path .. "/" .. item
            if love.filesystem.getInfo(iPath).type == "file" then
                table.insert(files, iPath)
            elseif love.filesystem.getInfo(iPath).type == "directory" then
                _scan(iPath)
            end 
        end
    end

    _scan(folder)
    return files
end

return fsutils