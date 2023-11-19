local frame = CreateFrame("FRAME")  -- Attributes CreateFrame() to a variable for ease of use
local locale = GetLocale()          -- Saves the user's client language
frame:RegisterEvent("ADDON_LOADED")

-- Returns the current state of Floating Combat Text
local function checkCombatTextStatus()
    return GetCVar("enableFloatingCombatText")
end

-- Creates the chat command /fct to enable or disable the Floating Combat Text
SLASH_FCTFIX1 = "/fct"
SlashCmdList["FCTFIX"] = function()
    if checkCombatTextStatus() == "0" then
        SetCVar("enableFloatingCombatText", 1)
        print(combatTextIsEnabledMessage[locale])
    else
        SetCVar("enableFloatingCombatText", 0)
        print(combatTextIsDisabledMessage[locale])
    end
end

-- If the Floating Combat Text is disabled, enables it
local function enableCombatText()
    if checkCombatTextStatus() == "0" then
        SetCVar("enableFloatingCombatText", 1)
        print(combatTextNowEnabledMessage[locale])
    else
        print(combatTextIsEnabledMessage[locale])
    end
end

-- Runs enableCombatText() once the addOn loads
local function handleAddonLoaded(event, addOnName)
    if event == "ADDON_LOADED" and addOnName == "FloatingCombatTextFix" then
        enableCombatText()
    end
    frame:UnregisterEvent("ADDON_LOADED") -- Stops listening to ADDON_LOADED events
end

-- Runs the functions below when one of the registered in-game events occur
frame:SetScript("OnEvent", function(_, event, ...)
    handleAddonLoaded(event, ...)
end)
