local _, fctf = ...
local isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

---------------------------------  STRINGS  ---------------------------------

local addonTitle = fctf.getLocalizedText("addonTitle")
local subtitleText = fctf.getLocalizedText("optionsInterfaceSubtitle")
local preferencesText = fctf.getLocalizedText("preferences")
local enableFctText = fctf.getLocalizedText("enableFct")
local rememberFctStateLabel = fctf.getLocalizedText("rememberFctStateCheckBoxLabel")
local displayFctStateLabel = fctf.getLocalizedText("displayFctStateCheckBoxLabel")
local rememberFctStateTooltipText = fctf.getLocalizedText("rememberFctStateCheckBoxTooltip")
local fctCustomizationHeaderText = fctf.getLocalizedText("fctCustomizationHeader")
local floatModeLabelText = fctf.getLocalizedText("floatModeLabel")
local floatModeUpwardText = fctf.getLocalizedText("floatModeUpward")
local floatModeDownwardText = fctf.getLocalizedText("floatModeDownward")
local floatModeArcText = fctf.getLocalizedText("floatModeArc")

---------------------------------  HORIZONTAL OFFSETS  ---------------------------------

local initialElementsXPosition = 13
local tooltipTextureXOffset = 5

-- PREFERENCES CHECKBOXES
local checkButtonXPosition = initialElementsXPosition + 12

-- FCT OPTIONS SECTION
local leftColumnXPosition = checkButtonXPosition
local rightColumnXPosition = checkButtonXPosition + 300

---------------------------------  VERTICAL OFFSETS  ---------------------------------

-- STRINGS
local addonTitleYPosition = -15
local subtitleYPosition = addonTitleYPosition - 25
local preferencesYPosition = subtitleYPosition - 50

-- PREFERENCES CHECKBOXES
local enableFctCheckBoxYPosition = -120
local fctStateCheckBoxYPosition = enableFctCheckBoxYPosition - 35
local fctMessageCheckBoxYPosition = fctStateCheckBoxYPosition - 35

-- FCT OPTIONS SECTION
local fctCustomizationHeaderYPosition = fctMessageCheckBoxYPosition - 55
local floatModeRowYPosition = fctCustomizationHeaderYPosition - 35
local fctOptionsFirstRowYPosition = floatModeRowYPosition - 35
local fctOptionsRowSpacing = -30

---------------------------------  FCT OPTIONS  ---------------------------------

local fctDropdown = nil
local fctOptionElements = {}
local enableFctCheckButton = nil
local floatModes = { 
    { value = "1", label = floatModeUpwardText },
    { value = "2", label = floatModeDownwardText },
    { value = "3", label = floatModeArcText },
}
local leftColumnOptions = {
    { key = "damage",       label = "showDamage" },
    { key = "damagePeriod", label = "showDamagePeriod" },
    { key = "damageReduct",  label = "showDamageReduct" },
    { key = "damagePet",    label = "showDamagePet" },
    { key = "healing",      label = "showHealing" },
    { key = "healerNames",   label = "showHealerNames" },
    { key = "miss",          label = "showMiss" },
    { key = "lowManaHealth", label = "showLowManaHealth" },
}
local rightColumnOptions = {
    { key = "combatState",   label = "showCombatState" },
    { key = "comboPoints",  label = "showComboPoints" },
    { key = "energyGains",  label = "showEnergyGains" },
    { key = "auras",         label = "showAuras" },
    { key = "fadingAuras",   label = "showFadingAuras" },
    { key = "spells",     label = "showSpells" },
    { key = "reputation",   label = "showReputation" },
    { key = "honorGains",   label = "showHonorGains" },
}

---------------------------------  ELEMENT CREATION FUNCTIONS  ---------------------------------

local function setFctOptionsEnabled(fctIsEnabled)
    for _, element in ipairs(fctOptionElements) do
        if fctIsEnabled then
            element:Enable()
            UIDropDownMenu_EnableDropDown(fctDropdown)
        else
            element:Disable()
            UIDropDownMenu_DisableDropDown(fctDropdown)
        end
    end
end

function fctf.updateInterfaceState()
    local fctIsEnabled = fctf.getCurrentFctState() == "1"
    if enableFctCheckButton then
        enableFctCheckButton:SetChecked(fctIsEnabled)
    end
    setFctOptionsEnabled(fctIsEnabled)
end

local function createText(font, text, yPosition, xPosition)
    local fontString = fctf.frame:CreateFontString(nil, "ARTWORK", font)
    fontString:SetText(text)
    fontString:SetJustifyH("LEFT")
    local textXPosition = xPosition or initialElementsXPosition
    if yPosition then
        fontString:SetPoint("TOPLEFT", textXPosition, yPosition)
    end
    return fontString
end

local function createBasicCheckButton(text, yPosition, xPosition)
    local button = CreateFrame("CheckButton", nil, fctf.frame, "InterfaceOptionsCheckButtonTemplate")
    local label = createText("GameFontHighlight", text)
    label:SetParent(button)
    label:SetPoint("LEFT", button, "RIGHT", 4, 1)
    button.label = label
    local buttonXPosition = xPosition or initialElementsXPosition
    button:SetPoint("TOPLEFT", buttonXPosition, yPosition)
    return button
end

local function createFctToggleCheckButton()
    local button = createBasicCheckButton(
        enableFctText,
        enableFctCheckBoxYPosition,
        checkButtonXPosition
    )
    local supressMessage = true
    button:SetChecked(fctf.getCurrentFctState() == "1")
    button:SetScript("OnClick", function()
        fctf.toggleFct(supressMessage)
    end)
    return button
end

local function createPreferenceCheckButton(text, yPosition, xPosition, relatedSavedVariable)
    local button = createBasicCheckButton(text, yPosition, xPosition)
    button:SetChecked(fctfPreferences[relatedSavedVariable])
    button:SetScript("OnClick", function(self) 
        fctfPreferences[relatedSavedVariable] = self:GetChecked()
    end)
    return button
end

local function createFctOptionCheckButton(text, yPosition, xPosition, fctKey)
    local button = createBasicCheckButton(text, yPosition, xPosition)
    button:SetChecked(fctfPreferences[fctKey] ~= "0")
    button:SetScript("OnClick", function(self)
        local newValue = self:GetChecked() and "1" or "0"
        fctfPreferences[fctKey] = newValue
        SetCVar(fctf.fctOptions[fctKey], newValue)
        fctf.refreshFct()
    end)
    fctOptionElements[#fctOptionElements + 1] = button
    return button
end

local function createElementTooltip(element, tooltip)
    element:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tooltip)
        GameTooltip:Show()
    end)
    element:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function createQuestionMarkTooltip(tooltipText, anchorPoint, xOffset)
    local textureContainer = CreateFrame("Frame", nil, fctf.frame, "BackdropTemplate")
    textureContainer:SetSize(25, 25)
    textureContainer:SetPoint("LEFT", anchorPoint, "RIGHT", xOffset, 0)
    local texture = textureContainer:CreateTexture(nil)
    texture:SetTexture("interface/icons/inv_misc_questionmark")
    texture:SetAllPoints(textureContainer)
    createElementTooltip(textureContainer, tooltipText)
    return textureContainer
end

local function createFloatModeDropdown(yPosition)
    local label = createText("GameFontHighlight", floatModeLabelText, yPosition, checkButtonXPosition)
    local dropdown = CreateFrame("Frame", nil, fctf.frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", label, "RIGHT", 0, -3)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")
    UIDropDownMenu_Initialize(dropdown, function()
        local currentMode = fctfPreferences["floatMode"] or "1"
        for _, mode in ipairs(floatModes) do
            local option = UIDropDownMenu_CreateInfo()
            option.text = mode.label
            option.value = mode.value
            option.checked = currentMode == mode.value
            option.func = function()
                fctfPreferences["floatMode"] = mode.value
                SetCVar(fctf.fctOptions["floatMode"], mode.value)
                UIDropDownMenu_SetText(dropdown, mode.label)
                fctf.refreshFct()
            end
            UIDropDownMenu_AddButton(option)
        end
    end)
    UIDropDownMenu_SetText(dropdown, floatModes[fctfPreferences["floatMode"]] or floatModeUpwardText)
    return dropdown
end

---------------------------------  ELEMENT CREATION  ---------------------------------

function fctf.createInterfaceElements()
    createText("GameFontNormalLarge", addonTitle, addonTitleYPosition)
    createText("GameFontHighlight", subtitleText, subtitleYPosition)
    createText("GameFontNormalMed1", preferencesText, preferencesYPosition)
    enableFctCheckButton = createFctToggleCheckButton()
    local fctStateCheckButton = createPreferenceCheckButton(
        rememberFctStateLabel,
        fctStateCheckBoxYPosition, 
        checkButtonXPosition,
        "rememberLastFctState"
    )
    createQuestionMarkTooltip(
        rememberFctStateTooltipText, 
        fctStateCheckButton.label,
        tooltipTextureXOffset
    )
    createPreferenceCheckButton(
        displayFctStateLabel, 
        fctMessageCheckBoxYPosition, 
        checkButtonXPosition,
        "displayFctStatusMessageOnLogin"
    )
    if isMainline then
        createText("GameFontNormalMed1", fctCustomizationHeaderText, fctCustomizationHeaderYPosition)
        fctDropdown = createFloatModeDropdown(floatModeRowYPosition)
        for i, option in ipairs(leftColumnOptions) do
            local y = fctOptionsFirstRowYPosition + (i - 1) * fctOptionsRowSpacing
            createFctOptionCheckButton(fctf.getLocalizedText(option.label), y, leftColumnXPosition, option.key)
        end
        for i, option in ipairs(rightColumnOptions) do
            local y = fctOptionsFirstRowYPosition + (i - 1) * fctOptionsRowSpacing
            createFctOptionCheckButton(fctf.getLocalizedText(option.label), y, rightColumnXPosition, option.key)
        end
        setFctOptionsEnabled(fctf.getCurrentFctState() == "1")
    end
end
