local _, fctf = ...
local L = fctf.L

-- Turns FCT on or off depending on "state"
local function changeFctState(state, message)
    SetCVar("enableFloatingCombatText", state)
    if message ~= nil then
        print(message)
    end
end

-- Checks if the value is not already enabled / disabled for options that are not "floatingCombatTextFloatMode"
local function shouldChangeOption(option, value)
    return option ~= fctf.fctOptions.floatMode and GetCVar(option) == value
end

function fctf.toggleFct()
    if fctf.isFctEnabled() then
        changeFctState("0", L.fctDisabled[fctf.locale])
    else
        changeFctState("1", L.fctEnabled[fctf.locale])
    end
end

-- Enables all options related to FCT
function fctf.enableAllFctOptions()
    for key, option in pairs(fctf.fctOptions) do
        if shouldChangeOption(option, "0") then
            SetCVar(option, "1")
        end
    end
    print(L.optionsEnabled[fctf.locale])
end

function fctf.disableAllFctOptions()
    for key, option in pairs(fctf.fctOptions) do
        if shouldChangeOption(option, "1") then
            SetCVar(option, "0")
        end
    end
    print(L.optionsDisabled[fctf.locale])
end

local function getFctStatusMessage(lastFctState)
    if lastFctState == "0" then
        return L.fctDisabled[fctf.locale]
    else
        return L.fctEnabled[fctf.locale]
    end
end

local function updateFctStatus()
    local restoreLastFctState = fctfPreferences["rememberLastFctState"]
    local lastFctState = fctfPreferences["lastFctState"]
    local message = getFctStatusMessage(lastFctState)
    if restoreLastFctState == true then -- Restores the FCT state from last log off
        changeFctState(lastFctState)
    elseif restoreLastFctState ~= true and fctf.isFctEnabled() == false then
        changeFctState("1")
        message = L.fctNowEnabled[fctf.locale]
    end
    return message
end

-- Updates the FCT options based on the user's preferences on log in / reload
function fctf.applyUserPreferences()
    for key, option in pairs(fctf.fctOptions) do
        SetCVar(option, fctfPreferences[key])
    end
    local displayFctStatusMessage = fctfPreferences["displayFctStatusMessageOnLogin"] ~= false
    local fctStatusMessage = updateFctStatus()
    if displayFctStatusMessage then
        print(fctStatusMessage)
    end
end
