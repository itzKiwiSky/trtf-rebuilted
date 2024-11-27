local AudioController = {}

function AudioController:init()
    self.sources = {}
    self.channels = {}
    self.mode = "static"
end

function AudioController:addSource(sourceID, source)
    if not self.sources[sourceID] then
        self.sources[sourceID] = source
    end
end

function AudioController:playInChannel(sourceID, channelID, loop)
    if not self.channels[channelID] then
        self.channels[channelID] = self.sources[sourceID]
        self.channels[channelID]:play()
    end
end

function AudioController:setChannelVolume(vol)
    
end

function AudioController:pause()
    
end

function AudioController:stopAllChannels()
    for c = #self.channels, 1, -1 do
        local ch = self.channels[c]
        ch:stop()
        ch:setLooping(false)
    end
end

function AudioController:clearQueue()
    
end

return AudioController