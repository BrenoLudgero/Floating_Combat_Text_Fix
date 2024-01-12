-- Updates the user's FCT options in SavedVariables
function saveOptions()
    for key, option in pairs(fctOptions) do
        fctPreferences[key] = GetCVar(option)
    end
end

-- Creates the user's preferences table to be stored in SavedVariables
function createSavedVariables()
    if not fctPreferences then
        fctPreferences = {}
        saveOptions()
    end
end
