local _, fctf = ...
-- fctf: Globals within Floating Combat Text Fix
local gameLanguage = GetLocale()
fctf.frame = CreateFrame("Frame")
fctf.L = {} -- Localized text

fctf.fctOptions = {
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
fctf.persistenceVariables = {
    rememberLastFctState = false,
    lastFctState = "1",
    displayFctStatusMessageOnLogin = true
}

function fctf.getLocalizedText(variableName)
    local immediateTableValue = fctf.L[variableName]
    if type(immediateTableValue) == "string" then
        return immediateTableValue
    else
        return immediateTableValue[gameLanguage]
    end
end

function fctf.getCurrentFctState()
    return GetCVar("enableFloatingCombatText")
end

-- Stores the user's current preferences in SavedVariables
function fctf.saveUserPreferences()
    for key, option in pairs(fctf.fctOptions) do
        fctfPreferences[key] = GetCVar(option)
    end
    fctfPreferences["lastFctState"] = fctf.getCurrentFctState()
end

local function createPersistenceVariablesIfMissing()
    for key, option in pairs(fctf.persistenceVariables) do
        if fctfPreferences[key] == nil then
            fctfPreferences[key] = option
        end
    end
end

-- Creates the user's preferences table to be stored in SavedVariables.
-- Also renames the old SavedVariables if found, keeping previous preferences (2.0.3 -> 3.0.0)
function fctf.createSavedVariablesIfNeeded()
    local deprecatedSavedVariables = fctPreferences
    if deprecatedSavedVariables == nil and fctfPreferences == nil then 
        fctfPreferences = {}
        fctf.saveUserPreferences()
    elseif deprecatedSavedVariables ~= nil then
        fctfPreferences = deprecatedSavedVariables
        fctPreferences = nil
    end
    createPersistenceVariablesIfMissing()
end

-- Displays the add-on in Options -> AddOns
function fctf.initializeInterface()
    fctf.frame.name = fctf.getLocalizedText("addonTitle")
    local category = Settings.RegisterCanvasLayoutCategory(fctf.frame, fctf.frame.name)
    category.ID = fctf.frame.name
    Settings.RegisterAddOnCategory(category)
end

-- Creates the base chat command /fct with optional arguments
function fctf.createChatCommands()
    SLASH_FCTFIX1 = "/fct"
    SlashCmdList["FCTFIX"] = function(cmd)
        local command = strlower(cmd)
        if command == "" or command == nil then
            fctf.toggleFct()
        elseif command == "options" or command == "o" then
            Settings.OpenToCategory(fctf.frame.name)
        end
    end
end
