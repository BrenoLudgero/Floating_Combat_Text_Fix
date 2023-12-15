-- © 2023 Breno Ludgero. All Rights Reserved.

local frame = CreateFrame("FRAME")
local locale = GetLocale()
local fctOptions = {
    floatMode = "floatingCombatTextFloatMode",
    lowManaHealth = "floatingCombatTextLowManaHealth",
    auras = "floatingCombatTextAuras",
    fadingAuras = "floatingCombatTextAuraFade",
    combatState = "floatingCombatTextCombatState",
    miss = "floatingCombatTextDodgeParryMiss",
    damageReduct = "floatingCombatTextDamageReduction",
    reputation = "floatingCombatTextRepChanges",
    reactives = "floatingCombatTextReactives",
    healerNames = "floatingCombatTextFriendlyHealers",
    comboPoints = "floatingCombatTextComboPoints",
    energyGains = "floatingCombatTextEnergyGains",
    honorGains = "floatingCombatTextHonorGains",
    damage = "floatingCombatTextCombatDamage",
    damagePeriod = "floatingCombatTextCombatLogPeriodicSpells",
    damagePet = "floatingCombatTextPetMeleeDamage",
    healing = "floatingCombatTextCombatHealing"
}

-- Turns FCT on or off depending on "state"
local function changeFctState(state, message)
    SetCVar("enableFloatingCombatText", state)
    print(message)
end

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

local function fctIsDisabled()
    return GetCVar("enableFloatingCombatText") == "0"
end

local function toggleFct()
    if fctIsDisabled() then
        changeFctState("1", fctEnabled[locale])
    else
        changeFctState("0", fctDisabled[locale])
    end
end

-- Creates the chat command /fct to toggle the FCT on or off
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

-- Saves the user's FCT options in SavedVariables
local function saveOptions()
    for key, option in pairs(fctOptions) do
        fctPreferences[key] = GetCVar(option)
    end
end

-- Creates the user's preferences table to be stored in SavedVariables
local function createSavedVariables()
    if not fctPreferences then
        fctPreferences = {}
        saveOptions()
    end
end

-- Updates the FCT options based on the user's preferences
local function updateInterfaceOptions()
    for key, option in pairs(fctOptions) do
        SetCVar(option, fctPreferences[key])
    end
end

-- If the FCT is disabled, enables it
local function enableCombatText()
    if fctIsDisabled() then
        changeFctState("1", fctNowEnabled[locale])
    else
        print(fctEnabled[locale])
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

-- Runs the functions below once the addOn loads
local function handleAddOnLoaded(event, addOnName)
    if event == "ADDON_LOADED" and addOnName == "FloatingCombatTextFix" then
        enableCombatText()
        createSavedVariables()
        -- Updating the interface options after a delay ensures that the Blizzard_CombatText addOn has already implemented its changes
        C_Timer.After(1, updateInterfaceOptions)
    end
end

-- Saves current preferences when the user logs out or reloads the UI
local function handleLogout(event)
    if event == "PLAYER_LOGOUT" then
        saveOptions()
    end
end

-- Runs the functions below when one of the registered in-game events occur
frame:SetScript("OnEvent", function(_, event, ...)
    handleAddOnLoaded(event, ...)
    handleLogout(event)
end)
