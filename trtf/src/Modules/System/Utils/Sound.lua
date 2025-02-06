local function assertType(val, typestr)
    assert(type(val) ==  tostring(typestr), string.format("[ERROR] : Invalid argument type. Expected '%s', got '%s'", tostring(typestr), type(val)))
end

local function clamp(x, min, max)
    return math.max(min, math.min(x, max))
end

local Sound = {}
Sound.defaultVolume = 1
Sound.defaultPanning = 0
Sound.sources = {}      -- is for my use, you can pass all the source objects in this list --
Sound.channels = {}

---@ class SoundChannel 
local SoundChannel = {}
SoundChannel.__index = SoundChannel

--- Constructor for channel object
---@param id string
---@param sourceName string
function SoundChannel.new(id, sourceName)

    local tmpsource = nil
    if sourceName then
        assert(Sound.sources[sourceName] ~= nil, ("[ERROR] The audio source named: '%s' is not loaded"):format(sourceName))
        tmpsource = Sound.sources[sourceName]
    end
    
    local self = setmetatable({}, SoundChannel)
    self.id = id

    self.source = tmpsource or nil
    self.volume = clamp(Sound.defaultVolume, 0, 1)
    self.panning = clamp(Sound.defaultPanning, -1, 1)
    
    if tmpsource then
        self.channels = tmpsource:getChannelCount() or 1
    end

    Sound.channels[id] = self
    return self
end

function SoundChannel:loadSource(sourceName)
    assert(Sound.sources[sourceName] ~= nil, ("[ERROR] The audio source named: '%s' is not loaded"):format(sourceName))
    self.source = Sound.sources[sourceName]
    self.audioChannels = self.source:getChannelCount()
end

function SoundChannel:play()
    if self.source then
        self.source:play()
    end
end

function SoundChannel:pause()
    if self.source then
        self.source:pause()
    end
end

function SoundChannel:stop()
    if self.source then
        self.source:stop()
    end
end

function SoundChannel:getSource()
    if self.source then
        return self.source
    end
end

--- Set volume for a channel
---@param vol number
function SoundChannel:setVolume(vol)
    assertType(vol, "number")
    self.volume = clamp(vol, 0, 1)
    if self.source then
        self.source:setVolume(clamp(self.volume, 0, 1))
    end
end

--- Set audio panning for a channel, only works for mono channel audio only
---@param val number
function SoundChannel:setPanning(val)
    assertType(val, "number")
    self.panning = clamp(val, -1, 1)
    if self.audioChannels == 1 then
        if self.source then
            self.source:setPosition(clamp(self.panning, -1, 1))
        end
    end
end

function SoundChannel:setLooping(loop)
    self.source:setLooping(loop)
end

--- Destroy the object reference and the channel
function SoundChannel:destroy()
    if self.source and self.source:isPlaying() then
        self.source:stop()
    end
    Sound.channels[self.id] = nil
    collectgarbage("collect")
end

------------------------------------------------------------

--- Create a new channel object
---@param id string
---@param sourceObject love.audio.newSource:audioSource 
---@return SoundChannel class
function Sound.newChannel(id)
    assertType(id, "string")
    return Sound.channels[id] or SoundChannel.new(id)
end

function Sound.getChannel(name)
    assertType(name, "string")
    return Sound.channels[name]
end

--- Set all channels volume
---@param vol number
function Sound.setAllChannelsVolume(vol)
    assertType(vol, "number")
    for _, channel in ipairs(Sound.channels) do
        channel:setVolume(vol)
    end
end

--- Stop all channels
function Sound.stopAllChannels()
    for _, channel in ipairs(Sound.channels) do
        channel:stop()
    end
end

--- Destroy all classes
function Sound.destroyAllChannels()
    for _, channel in ipairs(Sound.channels) do
        channel:destroy()
    end
end

return Sound