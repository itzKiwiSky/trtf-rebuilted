local SoundController = {}
SoundController.sources = {}      -- is for my use, you can pass all the source objects in this list --
SoundController.channels = {}

--- Create a new channel object
---@param id string
---@param sourceObject love.audio.newSource:audioSource 
---@return SoundChannel class
function SoundController.newChannel(id)
    assertType(id, "string")
    return SoundController.channels[id] or SoundChannel.new(id)
end

function SoundController.getChannel(name)
    assertType(name, "string")
    return SoundController.channels[name]
end

--- Set all channels volume
---@param vol number
function SoundController.setAllChannelsVolume(vol)
    assertType(vol, "number")
    for _, channel in ipairs(SoundController.channels) do
        channel:setVolume(vol)
    end
end

--- Stop all channels
function SoundController.stopAllChannels()
    for _, channel in ipairs(SoundController.channels) do
        channel:stop()
    end
end

--- Destroy all classes
function SoundController.destroyAllChannels()
    for _, channel in ipairs(SoundController.channels) do
        channel:destroy()
    end
end

return SoundController