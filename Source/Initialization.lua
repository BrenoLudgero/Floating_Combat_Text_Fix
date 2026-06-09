local _, fctf = ...
-- fctf: Globals within Floating Combat Text Fix
local gameLanguage = GetLocale()
fctf.frame = CreateFrame("Frame")
fctf.L = {} -- Localized text

local isVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isBurningCrusade = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

if isVanilla or isBurningCrusade then
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
else
    fctf.fctOptions = {
        floatMode = "floatingCombatTextFloatMode_v2",
        lowManaHealth = "floatingCombatTextLowManaHealth_v2",
        auras = "floatingCombatTextAuras_v2",
        fadingAuras = "floatingCombatTextAuraFade_v2",
        combatState = "floatingCombatTextCombatState_v2",
        miss = "floatingCombatTextDodgeParryMiss_v2",
        damageReduct = "floatingCombatTextDamageReduction_v2",
        reputation = "floatingCombatTextRepChanges_v2",
        reactives = "floatingCombatTextReactives_v2",
        healerNames = "floatingCombatTextFriendlyHealers_v2",
        comboPoints = "floatingCombatTextComboPoints_v2",
        energyGains = "floatingCombatTextEnergyGains_v2",
        honorGains = "floatingCombatTextHonorGains_v2",
        damage = "floatingCombatTextCombatDamage_v2",
        damagePeriod = "floatingCombatTextCombatLogPeriodicSpells_v2",
        damagePet = "floatingCombatTextPetMeleeDamage_v2",
        healing = "floatingCombatTextCombatHealing_v2"
    }
end

local persistenceVariables = {
    rememberLastFctState = false,
    lastFctState = "1",
    displayFctStatusMessageOnLogin = true,
    temporaryMessagesRemaining = 7,
    ignoreTemporaryMessages = false
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
    if fctf.getCurrentFctState() == "1" then
        for key, option in pairs(fctf.fctOptions) do
            fctfPreferences[key] = GetCVar(option)
        end
    end
    fctfPreferences["lastFctState"] = fctf.getCurrentFctState()
end

local function createPersistenceVariablesIfMissing()
    for key, option in pairs(persistenceVariables) do
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
    fctf.category = Settings.RegisterCanvasLayoutCategory(fctf.frame, fctf.frame.name)
    Settings.RegisterAddOnCategory(fctf.category)
end

-- Creates the base chat command /fct with optional arguments
function fctf.createChatCommands()
    SLASH_FCTFIX1 = "/fct"
    SlashCmdList["FCTFIX"] = function(cmd)
        local command = strlower(cmd)
        local ignoreTemporaryMessages = fctfPreferences["ignoreTemporaryMessages"]
        if command == "" or command == nil then
            fctf.toggleFct()
        elseif command == "options" or command == "o" then
            Settings.OpenToCategory(fctf.category:GetID())
        elseif command == "stop" and ignoreTemporaryMessages == false then
            fctfPreferences["ignoreTemporaryMessages"] = true
        end
    end
end

-- Display the message 3 times, once every 3 logins
-- function fctf.printTemporaryMessage()
--     local remainingMessages = fctfPreferences["temporaryMessagesRemaining"]
--     if remainingMessages <= 0 or fctfPreferences["ignoreTemporaryMessages"] == true then
--         return
--     elseif remainingMessages <= 0 and fctfPreferences["ignoreTemporaryMessages"] == true then
--         fctfPreferences["ignoreTemporaryMessages"] = false
--         return
--     end
--     if remainingMessages % 3 == 1 then
--         local displayedMessageCount = 3 - math.floor((remainingMessages - 1) / 3)
--         print("\n")
--         print(fctf.getLocalizedText("temporaryMessage"))
--         print("    Message "..displayedMessageCount.." out of 3. Send '/fct stop' in the chat to ignore the remaining messages.")
--         print("\n")
--     end
--     fctfPreferences["temporaryMessagesRemaining"] = remainingMessages - 1
-- end
