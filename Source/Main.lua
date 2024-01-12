-- © 2023 Breno Ludgero. All Rights Reserved.

-- Checks if the value should change for options that are not "floatingCombatTextFloatMode"
local function shouldChangeOption(option, value)
    return option ~= fctOptions.floatMode and GetCVar(option) == value
end

-- Enables all options related to FCT
local function enableAll()
    for key, option in pairs(fctOptions) do
        if shouldChangeOption(option, "0") then
            SetCVar(option, "1")
        end
    end
    print(optionsEnabled[locale])
end

local function disableAll()
    for key, option in pairs(fctOptions) do
        if shouldChangeOption(option, "1") then
            SetCVar(option, "0")
        end
    end
    print(optionsDisabled[locale])
end

local function toggleFct()
    if fctIsDisabled() then
        changeFctState("1", fctEnabled[locale])
    else
        changeFctState("0", fctDisabled[locale])
    end
end

-- Creates the chat command /fct with additional commands
SLASH_FCTFIX1 = "/fct"
SlashCmdList["FCTFIX"] = function(command)
    local cmd = strlower(command)
    if cmd == "" or cmd == nil then
        toggleFct()
    elseif cmd == "enable" or cmd == "e" then
        enableAll()
    elseif cmd == "disable" or cmd == "d" then
        disableAll()
    end
end

-- Runs the functions below when one of the registered in-game events occur
frame:SetScript("OnEvent", function(_, event, ...)
    handleAddOnLoaded(event, ...)
    handleLogout(event)
end)
