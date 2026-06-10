local addonName, fctf = ...

fctf.frame:RegisterEvent("ADDON_LOADED")
fctf.frame:RegisterEvent("PLAYER_LOGOUT")
fctf.frame:RegisterEvent("CVAR_UPDATE")

-- Runs the functions below once the addOn loads
function fctf.handleAddonLoaded(event, addon)
    if event == "ADDON_LOADED" and addon == addonName then
        fctf.createSavedVariablesIfNeeded()
        fctf.createChatCommands()
        -- Delaying the options update ensures that the Blizzard_CombatText add-on has already implemented its changes
        C_Timer.After(1, function()
            -- fctf.printTemporaryMessage()
            fctf.applyUserPreferences()
            fctf.initializeInterface()
            fctf.createInterfaceElements()
        end)
        fctf.frame:UnregisterEvent("ADDON_LOADED")
    end
end

-- Saves current preferences when the user logs out or reloads the UI
function fctf.handleLogout(event)
    if event == "PLAYER_LOGOUT" then
        fctf.saveUserPreferences()
    end
end

-- Saves FCT preferences as soon as they've been changed
function fctf.handleCVarUpdates(event, cvar, newValue)
    if event == "CVAR_UPDATE" and not fctf.suppressPreferenceSave then
        for key, option in pairs(fctf.fctOptions) do
            if option == cvar then
                fctfPreferences[key] = newValue
                break
            end
        end
    end
end
