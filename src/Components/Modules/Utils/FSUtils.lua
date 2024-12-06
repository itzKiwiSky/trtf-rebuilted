local fsutils = {}

function fsutils.scanFolder(folder, includeFolder, ignoreFolder)
    ignoreFolder = ignoreFolder or {}
    includeFolder = includeFolder or false
    local files = {}
    local function _scan(path)
        local items = love.filesystem.getDirectoryItems(path)

        for _, item in ipairs(items) do
            local iPath = path .. "/" .. item
            if not table.contains(ignoreFolder, iPath) or #ignoreFolder == 0 then
                if love.filesystem.getInfo(iPath).type == "file" then
                    table.insert(files, iPath)
                elseif love.filesystem.getInfo(iPath).type == "directory" then
                    if includeFolder then table.insert(files, iPath) end
                    _scan(iPath)
                end 
            end
        end
    end

    _scan(folder)
    return files
end

return fsutils