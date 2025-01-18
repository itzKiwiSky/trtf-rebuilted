if nightEndTextDisplay.displayNightText and not nightEndTextDisplay.invert then
    if not AudioSources["bells"]:isPlaying() then
        AudioSources["bells"]:play()
    end
    nightEndTextDisplay.acc = nightEndTextDisplay.acc + elapsed
    if nightEndTextDisplay.acc >= 0.1 then
        nightEndTextDisplay.acc = 0
        nightEndTextDisplay.fade = nightEndTextDisplay.fade + 8.5 * elapsed
        nightEndTextDisplay.scale = nightEndTextDisplay.scale + 0.4 * elapsed

        if nightEndTextDisplay.fade >= 1.4 then
            nightEndTextDisplay.invert = true
        end
    end
elseif nightEndTextDisplay.displayNightText and nightEndTextDisplay.invert then
    officeState.nightRun = true
    nightEndTextDisplay.acc = nightEndTextDisplay.acc + elapsed
    if nightEndTextDisplay.acc >= 0.3 then
        nightEndTextDisplay.acc = 0
        nightEndTextDisplay.fade = nightEndTextDisplay.fade - 3.2 * elapsed
        nightEndTextDisplay.scale = nightEndTextDisplay.scale + 0.2 * elapsed

        if nightEndTextDisplay.fade <= 0 then
            nightEndTextDisplay.displayNightText = false
        end
    end
end