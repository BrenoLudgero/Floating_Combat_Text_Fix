local _, fctf = ...

-- Last FCT state set by the add-on. Remains nil until the user's preferences have been applied
local addonFctState = nil

-- Sets the FCT CVar while flagging the change as made by the add-on so it isn't intercepted
local function setFctCVar(state)
    addonFctState = state
    fctf.isSettingFctState = true
    SetCVar("enableFloatingCombatText", state)
    fctf.isSettingFctState = false
end

-- Turns FCT on or off depending on "state"
local function changeFctState(state, message)
    setFctCVar(state)
    if message ~= nil then
        print(message)
    end
end

local function isFctEnabled()
    return fctf.getCurrentFctState() == "1"
end

function fctf.toggleFct(supressMessage)
    if isFctEnabled() then
        fctf.suppressPreferenceSave = true
        for _, option in pairs(fctf.fctOptions) do
            SetCVar(option, 0)
        end
        fctf.suppressPreferenceSave = false
        changeFctState("0", not supressMessage and fctf.getLocalizedText("fctDisabled") or nil)
    else
        for key, option in pairs(fctf.fctOptions) do
            SetCVar(option, fctfPreferences[key])
        end
        changeFctState("1", not supressMessage and fctf.getLocalizedText("fctEnabled") or nil)
    end
    fctf.updateInterfaceState()
end

local function getFctStatusMessage(lastFctState)
    if lastFctState == "0" then
        return fctf.getLocalizedText("fctDisabled")
    else
        return fctf.getLocalizedText("fctEnabled")
    end
end

local function updateFctStatus()
    local restoreLastFctState = fctfPreferences["rememberLastFctState"]
    local lastFctState = fctfPreferences["lastFctState"]
    local message = getFctStatusMessage(lastFctState)
    if restoreLastFctState == true then -- Restores the FCT state from last log off
        changeFctState(lastFctState)
    elseif restoreLastFctState ~= true and not isFctEnabled() then
        changeFctState("1")
        message = fctf.getLocalizedText("fctNowEnabled")
    end
    return message
end

function fctf.refreshFct()
    if fctf.getCurrentFctState() == "1" then
        setFctCVar("0")
        RunNextFrame(function() 
            setFctCVar("1")
        end)
    end
end

-- Updates the FCT options based on the user's preferences on log in / reload
function fctf.applyUserPreferences()
    for key, option in pairs(fctf.fctOptions) do
        SetCVar(option, fctfPreferences[key])
    end
    local shouldDisplayFctStatusMessage = fctfPreferences["displayFctStatusMessageOnLogin"] ~= false
    local fctStatusMessage = updateFctStatus()
    if shouldDisplayFctStatusMessage then
        print(fctStatusMessage)
    end
    addonFctState = fctf.getCurrentFctState()
    fctf.updateInterfaceState()
end

-- Replaces FCT toggles made outside of the add-on (e.g. Options -> Gameplay -> Combat) with fctf.toggleFct()
function fctf.interceptFctToggle(newState)
    newState = tostring(newState)
    if addonFctState == nil 
    or fctf.isSettingFctState 
    or newState == addonFctState then
        return
    end
    setFctCVar(addonFctState) -- Reverts the external change before toggling
    fctf.toggleFct()
end
