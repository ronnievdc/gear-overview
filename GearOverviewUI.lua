local lib = GearOverview
local libScroll = LibScroll
local LAM = LibAddonMenu2

local localStorage = {
    displayWeapons = "WEAPONS_ALL"
}

--- Callback function to render on set
--- @param rowControl
--- @param data table
--- @param scrollList
local function SetupDataRow(rowControl, data, scrollList)
    local itemSetId = data.id
    local itemSetName = GetItemSetName(itemSetId)
    local skipOrderNumbers = {}

    lib.log(lib.LOG_LEVEL_INFO, "localStorage.displayWeapons", localStorage.displayWeapons)
    if localStorage.displayWeapons == "WEAPONS_TANK" then
        skipOrderNumbers = { 10, 14, 15, 16, 17, 18, 19, 21 }
    elseif localStorage.displayWeapons == "WEAPONS_HEALER" then
        skipOrderNumbers = { 10, 11, 12, 13, 14, 15, 16, 17, 22 }
    end

    for i = 1, 22 do
        local button = rowControl:GetNamedChild("Box" .. i)
        if not button then
            button = WINDOW_MANAGER:CreateControl("$(parent)Box" .. i, rowControl, CT_TEXTURE)
        end

        button:SetHidden(false)
        button:SetDimensions(24, 24)
        button:SetAnchor(LEFT, rowControl, LEFT, 423 + (i - 1) * 30, 0) -- original 140+(i-1)*30
        button:SetMouseEnabled(false)

        local isUnlocked = false
        local isAvailable = false

        for idx = 1, GetNumItemSetCollectionPieces(itemSetId) do
            pieceId, _ = GetItemSetCollectionPieceInfo(itemSetId, idx)
            local itemLink = GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE, nil)
            local orderNumber = lib.getOrderNumber(itemLink)

            if i == orderNumber then
                isUnlocked = IsItemSetCollectionPieceUnlocked(pieceId)
                isAvailable = true
            end
        end

        local bagItem = nil
        if lib.bag[itemSetId] then
            bagItem = lib.bag[itemSetId][i]
        end

        local skipRow = false
        for _, OrderIdx in pairs(skipOrderNumbers) do
            if OrderIdx == i then
                skipRow = true
            end
        end

        if skipRow then
            button:SetHidden(true)
        elseif bagItem then
            button:SetTexture("/esoui/art/cadwell/check.dds")
            local quality = bagItem
            local red, green, blue, alpha = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
            button:SetColor(red, green, blue, alpha)
        elseif isUnlocked then
            button:SetTexture("/esoui/art/icons/servicemappins/servicepin_transmute.dds")
            button:SetColor(1, 1, 1)
        elseif isAvailable then
            button:SetTexture("/esoui/art/buttons/swatchframe_down.dds")  -- little square box
            button:SetColor(1, 1, 1)
        else
            button:SetHidden(true)
        end
    end

    rowControl:GetNamedChild("Name"):SetText(itemSetName)
end

function lib.CreateScrollList()
    local mainWindow = GearOverviewList
    local scrollData = {
        name = "GearScrollList2",
        parent = mainWindow,
        rowTemplate = "WishListRow2",
        setupCallback = SetupDataRow,
        width = 1133,
        height = 700,
    }

    local scrollList = libScroll:CreateScrollList(scrollData)
    scrollList:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 25, 100)

    return scrollList
end

function lib.getSetList()
    lib.log(lib.LOG_LEVEL_DEBUG, "lib.getSetList", lib.activePreset, lib.custom, table.concat(lib.customList, ', '))
    if lib.activePreset then
        return lib.presets[lib.activePreset]
    elseif lib.custom then
        return lib.customList
    end
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "|cff0000Please select a valid list!|r")
end

function lib.showWindow()
    local myList = lib.getSetList()
    if not myList then
        return
    end

    lib.fetchItems()
    lib.scrollList:Clear()
    lib.scrollList:Update(myList)
    GearOverviewList:SetHidden(false)
end

function lib.createSettings()
    lib.log(lib.LOG_LEVEL_DEBUG, "lib.createSettings")

    local panelName = "GearOverviewSettingsPanel"
    local panelData = {
        type = "panel",
        name = lib.name,
        author = lib.author,
        version = lib.version,
        slashCommand = "/gear"
    }

    local NO_PRESET = "No preset"

    local presets = lib.getTableKeys(lib.presets)
    table.insert(presets, 1, NO_PRESET)

    local optionsTable = {
        {
            type = "dropdown",
            name = "Set preset",
            tooltip = "Which gear preset should be displayed.",
            choices = presets,
            default = NO_PRESET,
            getFunc = function()
                return nil
            end,
            setFunc = function(value)
                if value == NO_PRESET then
                    lib.activePreset = nil
                else
                    lib.activePreset = value
                end
            end
        },
        {
            type = "editbox",
            name = "Custom list of sets (one per line)",
            tooltip = "Paste here the sets you want to list",
            getFunc = function()
                return ""
            end,
            setFunc = lib.parseSets,
            isMultiline = true,
            isExtraWide = true,
        },
        {
            type = "dropdown",
            name = "Weapon types",
            tooltip = "Click here to show the window.",
            choices = { "All", "Tank (S&B, Ice staff)", "Header (All staffs)" },
            choicesValues = { "WEAPONS_ALL", "WEAPONS_TANK", "WEAPONS_HEALER" },
            default = localStorage.displayWeapons,
            getFunc = function()
                return localStorage.displayWeapons
            end,
            setFunc = function(value)
                localStorage.displayWeapons = value
            end,
        },
        {
            type = "button",
            name = "Show Window",
            tooltip = "Click here to show the window.",
            width = "half",
            func = lib.showWindow,
        },
        --{
        --    type = "button",
        --    name = "Take Screenshot",
        --    tooltip = "Click here to take a screenshot (Saved to the ESO Screenshots folder).",
        --    width = "half",
        --    func = lib.takeScreenshot,
        --}
    }

    local panel = LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end
