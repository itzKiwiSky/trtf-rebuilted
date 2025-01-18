return function()
    slab.BeginWindow("debugWindow", { Title = "Debug shader"})
        slab.Text("FOV (fovVar)")
        slab.SameLine()
        if slab.InputNumberDrag("fovInput", tostring(tuneConfig.fovVar), -1, 1, 0.01) then
            tuneConfig.fovVar = slab.GetInputNumber()
        end
        slab.Text("Latitute (latituteVar)")
        slab.SameLine()
        if slab.InputNumberDrag("latituteInput", tostring(tuneConfig.latitudeVar), -200, 200, 0.1) then
            tuneConfig.latitudeVar = slab.GetInputNumber()
        end
        slab.Text("Longitude (longitudeVar)")
        slab.SameLine()
        if slab.InputNumberDrag("longitudeInput", tostring(tuneConfig.longitudeVar), -200, 200, 0.1) then
            tuneConfig.longitudeVar = slab.GetInputNumber()
        end

        slab.Text("Camera X Factor (factorX)")
        slab.SameLine()
        if slab.InputNumberDrag("factorXInput", tostring(gameCam.factorX), 0, 20, 0.01) then
            gameCam.factorX = slab.GetInputNumber()
        end
    slab.EndWindow()
end