local soundthread = {} 

--% originally written by StrawberryChocolate, Improved by AyanoTheFoxy (thanks friend <3)
function soundthread.newTone(note, waveLength, waveType, volume, amplitude, pitch)
    --I stole this shit from litium >w<
    waveType = waveType or 'square'
    amplitude = amplitude or 0
    volume = volume or 1
    pitch = pitch or nil


    local Tone = note
    
    local length    = waveLength / 32
    local phase     = math.floor(44100 / Tone)
    local soundData = love.sound.newSoundData(math.floor(length * 44100), 44100, 16, 1)
    
    for i = 0, soundData:getSampleCount() - 1 do 
        if waveType == 'noise' then
            soundData:setSample( i, love.math.random()) 
        elseif waveType == 'sine' then
            soundData:setSample( i, math.sin(2 * math.pi * i / phase))
        elseif waveType == 'square' then
            soundData:setSample( i, i % phase < phase / 2 and 1 or -1)
        elseif waveType == 'triangle' then
            soundData:setSample( i, 4 * 1 / phase * math.abs((((i - phase / 4) % phase) + phase) % phase - phase / 2) - amplitude)
        elseif waveType == 'sawtooth' then
            soundData:setSample( i, 2 * math.atan(math.tan(i / 2)))
        end
    end
    
    local snd = love.audio.newSource(soundData)
    
    snd:setVolume(volume)
    snd:setPitch(pitch)
    snd:play()
end 

return soundthread