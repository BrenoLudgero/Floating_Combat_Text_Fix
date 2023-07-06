local frame = CreateFrame("FRAME")   -- Attributes CreateFrame() to a variable for ease of use
local locale = GetLocale()           -- Checks the user's client language and saves it to a variable
local isCombatTextEnabled = GetCVar("enableFloatingCombatText")  -- Saves the current state of Floating Combat Text in a variable
frame:RegisterEvent("ADDON_LOADED")  -- Starts listening to the in-game ADDON_LOADED events

local function enableCombatText()
    if isCombatTextEnabled == "0" then  -- If the Floating Combat text is disabled, warns the user then enables it
        print(combatTextDisabledMessage[locale])
        SetCVar("enableFloatingCombatText", 1)
    else  -- If it's enabled, shows a different message
        print(combatTextEnabledMessage[locale])
    end
end

local function handleAddonLoaded(event, addOnName)  -- All ADDON_LOADED events are handled here
    if event == "ADDON_LOADED" and addOnName == "FloatingCombatTextFix" then  -- If an addOn loads and is called FloatingCombatTextFix:
        enableCombatText()  -- Runs the function responsible for enabling the Floating Combat Text
    end
    frame:UnregisterEvent("ADDON_LOADED")  -- Stops listening to ADDON_LOADED events
end

frame:SetScript("OnEvent", function(_, event, ...)  -- Runs the function below when the addOn is loaded
    handleAddonLoaded(event, ...)
end)
