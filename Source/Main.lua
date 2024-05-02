local _, fctf = ...

-- Runs the functions below when one of the registered in-game events occur
fctf.frame:SetScript("OnEvent", function(_, event, ...)
    if fctf.handleAddonLoaded then
        fctf.handleAddonLoaded(event, ...)
        C_Timer.After(2, function() fctf.handleAddonLoaded = nil end)
    end
    fctf.handleLogout(event)
end)
