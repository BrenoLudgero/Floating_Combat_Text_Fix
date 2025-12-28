local _, fctf = ...

function fctf.getCurrentFctState()
    return GetCVar("enableFloatingCombatText")
end

function fctf.isFctEnabled()
    return fctf.getCurrentFctState() == "1"
end