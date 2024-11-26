local AudioController = {}

function AudioController:init()
    self.sources = {}
    self.channels = {}
    self.mode = "static"
end

function AudioController:addSource(id, source)
    self.sources[id] = source
end

function AudioController:playInChannel(filename, channelID)
    
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