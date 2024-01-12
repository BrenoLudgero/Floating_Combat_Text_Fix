function fctIsDisabled()
    return GetCVar("enableFloatingCombatText") == "0"
end

-- Turns FCT on or off depending on "state"
function changeFctState(state, message)
    SetCVar("enableFloatingCombatText", state)
    print(message)
end

-- If the FCT is disabled, enables it
function enableCombatText()
    if fctIsDisabled() then
        changeFctState("1", fctNowEnabled[locale])
    else
        print(fctEnabled[locale])
    end
end

-- Updates the FCT options based on the user's preferences
function updateInterfaceOptions()
    for key, option in pairs(fctOptions) do
        SetCVar(option, fctPreferences[key])
    end
end
