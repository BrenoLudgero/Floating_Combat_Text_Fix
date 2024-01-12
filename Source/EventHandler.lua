frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

-- Runs the functions below once the addOn loads
function handleAddOnLoaded(event, addOnName)
    if event == "ADDON_LOADED" and addOnName == "FloatingCombatTextFix" then
        enableCombatText()
        createSavedVariables()
        -- Delaying the interface update ensures that the Blizzard_CombatText addOn has already implemented its changes
        C_Timer.After(1, updateInterfaceOptions)
    end
end

-- Saves current preferences when the user logs out or reloads the UI
function handleLogout(event)
    if event == "PLAYER_LOGOUT" then
        saveOptions()
    end
end
