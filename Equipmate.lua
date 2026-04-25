

--[[
    Equipmate consists of 2 major parts

    Equipment Flyouts:
        These buttons are attached to the Character PaperDollFrame inventory slot buttons
        and allow players the ability to quickly swap their gear per slot

    Equipmate UI:
        This panel/window acts as an equipment set manager and allows players the ability to
        create and equip complete sets (ie all slots)
]]

local addonName, addon = ...;

local Database = addon.Database;
local L = addon.locales;



--[[
    ====================================
    StaticPopupDialogs
    ====================================
]]

StaticPopupDialogs.NewOutfit = {
    text = "New Outfit",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self, data)
        local str = self.EditBox:GetText()
        if str and (#str > 0) and (str ~= " ") then
            local outfit = str;
            Database:NewOutfit(outfit, addon.thisCharacter)
        end
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    showAlert = false,
}






---Create the PaperDollFrame slot buttons and UI toggle button
local function CreatePaperDollButtons()

    local toggleButton = CreateFrame("BUTTON", addonName.."ToggleButton", PaperDollItemsFrame, "TBDSquareSlotButton")
    toggleButton:RegisterForClicks("AnyDown")

    if RuneFrameControlButton then
        toggleButton:SetPoint("RIGHT", RuneFrameControlButton, "LEFT", -4, 0)
    else
        toggleButton:SetPoint("BOTTOMRIGHT", CharacterHandsSlot, "TOPRIGHT", 0, 3)
    end

    toggleButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(toggleButton, "ANCHOR_RIGHT")
        GameTooltip:AddLine(EQUIPMATE_PAPERDOLL_TOGGLE_BUTTON_TITLE)
        GameTooltip:AddLine(EQUIPMATE_PAPERDOLL_TOGGLE_BUTTON_TEXT)
        GameTooltip:Show()
    end)
    --toggleButton.icon:SetTexture("Interface/WorldMap/Gear_64")
    toggleButton.icon:SetAtlas("transmog-nav-slot-head")
    toggleButton.icon:ClearAllPoints()
    toggleButton.icon:SetPoint("CENTER", toggleButton, "CENTER", 0, -2)
    toggleButton.isOpen = false
    
    toggleButton:SetScript("OnClick", function(f, but)

        --left click to toggle item slot swap flyout
        if but == "LeftButton" then
            for k, v in ipairs(Equipmate.Constants.PaperDollInventorySlotToggleButtons) do
                v:SetShown(not v:IsVisible())
            end

        --right click to open full UI
        else
            f.isOpen = not f.isOpen
            for k, v in ipairs(Equipmate.Constants.PaperDollInventorySlotToggleButtons) do
                v:SetShown(f.isOpen)
            end
    
            EquipmateUI:SetShown(f.isOpen)
    
            if f.isOpen then
                if EngravingFrame and EngravingFrame:IsVisible() then
                    RuneFrameControlButton:Click()
                end
            end
        end

    end)

    local function toggleFlyout(flyoutOpenButton, slotButton, slotID, isVerticle)

        for k, v in ipairs(Equipmate.Constants.PaperDollInventorySlotToggleButtons) do
            Equipmate.Api.EquipmentFlyoutPopoutButton_SetReversed(v, false)
        end

        local flyout = EquipmentFlyoutFrame
        flyout:Hide()
        flyout:SetSlot(slotID)
        flyout:IsVerticle(isVerticle)
        flyout:SetParent(slotButton)
        flyout:SetFrameStrata("TOOLTIP")
        flyout:SetFrameLevel(9996)
        flyout:ClearAllPoints()
        flyout:SetPoint("TOPLEFT", -2, 4)
        flyout:Show()

        Equipmate.Api.EquipmentFlyoutPopoutButton_SetReversed(flyoutOpenButton, true)
    end

    for slotName, info in pairs(Equipmate.Constants.PaperDollSlotNames) do

        local slot = _G[slotName]

        --this key value is used to set the texcoords
        local isVerticle = (info.allignment == "bottom") and true or false
        slot.verticalFlyout = isVerticle;

        local button = CreateFrame("BUTTON", string.format("%s%sFlyoutButton", addonName, slotName), slot, "TBDSlotFlyoutButton")
        if info.allignment == "right" then
            button:SetPoint("TOPRIGHT", 12, 0)
            button:SetPoint("BOTTOMRIGHT", 12, 0)
            button:SetWidth(16)

            Equipmate.Api.EquipmentFlyoutPopoutButton_SetReversed(button, false)

        else
            button:SetPoint("BOTTOMLEFT", 0, -12)
            button:SetPoint("BOTTOMRIGHT", 0, -12)
            button:SetHeight(16)

            Equipmate.Api.EquipmentFlyoutPopoutButton_SetReversed(button, false)
        end

        table.insert(Equipmate.Constants.PaperDollInventorySlotToggleButtons, button)

        -- button:SetScript("OnLeave", function(slotButton)
        --     slotButton:Click()
        -- end)
        button:SetScript("OnEnter", function()
            toggleFlyout(button, slot, info.slotID, isVerticle)
        end)

        button:Hide()
    end
end











--[[
    Equipmate main UI

    This is the main frame for managing outfits
]]




EquipmateMixin = {
    selectedOutfit = {},
}
function EquipmateMixin:OnLoad()

    self:SetTitle(addonName)

    self:RegisterForDrag("LeftButton")

    self.portraitMask = self:CreateMaskTexture()
    self.portraitMask:SetAllPoints(EquipmateUIPortrait)
    self.portraitMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    EquipmateUIPortrait:AddMaskTexture(self.portraitMask)
    EquipmateUIPortrait:SetTexture("Interface/Addons/Equipmate/tbd-icon")


    self.outfitConfig.icon:SetTexture("Interface/WorldMap/Gear_64")
    self.outfitConfig.icon:SetTexCoord(0, 0.5, 0, 0.5)
    self.outfitConfig:SetScript("OnClick", function()
        self:OutfitConfig_OnClick()
        self:SetView("configPanel")
    end)

    self.rescanOutfit.icon:SetAtlas("transmog-icon-revert")
    self.rescanOutfit:SetScript("OnClick", function()
        self:RescanEquipment(true)
    end)

    --self.outfitItems.icon:SetAtlas("UI-LFG-RoleIcon-Generic")
    self.outfitItems.icon:SetAtlas("charactercreate-icon-customize-torso-selected")
    self.outfitItems.icon:ClearAllPoints()
    self.outfitItems.icon:SetPoint("TOPLEFT", -2, 2)
    self.outfitItems.icon:SetPoint("BOTTOMRIGHT", 2, -2)
    self.outfitItems:SetScript("OnClick", function()
        self:SetView("equipmentListview")
    end)

    --self.outfitStats.icon:SetAtlas("UI-LFG-PendingMark")
    self.outfitStats.icon:SetAtlas("charactercreate-gendericon-female-selected")
    self.outfitStats.icon:SetDrawLayer("BACKGROUND")
    self.outfitStats:SetScript("OnClick", function()
        self:SetView("statsContainer")
    end)

    self.swapScanOutfit.icon:SetAtlas("Garr_SwapIcon")
    self.swapScanOutfit.icon:SetPoint("TOPLEFT", 2, -2)
    self.swapScanOutfit.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    self.swapScanOutfit:SetScript("OnClick", function()
        
        if self.selectedOutfit and self.selectedOutfit.items then
            self.swapScanReturnOutfit = Equipmate.Api.GetPlayerEquipment()
            Equipmate.Api.EquipItemSet(self.selectedOutfit, self.isBankOpen, true)
        end
    end)


    for k, v in pairs(Equipmate.Constants.BlizzardEvents) do
        self:RegisterEvent(v)
    end

    for k, v in pairs(Equipmate.Constants.ConfigEvents) do
        self:RegisterEvent(k)
    end

    Equipmate.CallbackRegistry:RegisterCallback("Database_OnInitialised", self.Database_OnInitialised, self)
    Equipmate.CallbackRegistry:RegisterCallback("Database_OnNewOutfit", self.OnNewOutfit, self)
    Equipmate.CallbackRegistry:RegisterCallback("Database_OnOutfitChanged", self.OnOutfitChanged, self)
    Equipmate.CallbackRegistry:RegisterCallback("Database_OnOutfitDeleted", self.Database_OnOutfitDeleted, self)

    Equipmate.CallbackRegistry:RegisterCallback(Equipmate.Constants.CallbackEvents.BankFrameStateChanged, self.SetBankState, self)
    Equipmate.CallbackRegistry:RegisterCallback(Equipmate.Constants.CallbackEvents.OutfitSetSlotIgnore, self.SetSlotIgnore, self)

    Equipmate.CallbackRegistry:RegisterCallback(Equipmate.Constants.CallbackEvents.OutfitOnSwapScanInitialEquip, self.PerformSwapScanReturn, self)

    --self.outfitHelptip:SetScale(0.8)
    self.outfitHelptip:SetScript("OnClick", function()
        self:LaunchTuturial()
    end)
    self.equipOutfit:SetEnabled(false)
    self.equipOutfit:SetScript("OnClick", function()
        self:ApplySelectedOutfit()
    end)
    self.deleteOutfit:SetEnabled(false)
    self.deleteOutfit:SetScript("OnClick", function()
        self:DeleteOutfit()
    end)
    self.newOutfit:SetScript("OnClick", function()
        StaticPopup_Show("NewOutfit")
    end)


    --rework this
    GameTooltip:HookScript('OnShow', function(tooltip)
        local data = tooltip:GetOwner()
        if data.arg1 and data.arg1 == "equipmate-dropdown-tooltip-hook" then
            tooltip:SetHyperlink(data.arg2)
        end
    end)


    --this isn't perfect as it uses itemlinks which could be none unique
    GameTooltip:HookScript('OnTooltipSetItem', function(tooltip)
        local _, link = tooltip:GetItem()
        if link then
            local bag, slot = Equipmate.Api.FindItemContainerLocationbyLink(link)
            if type(bag) == "number" and type(slot) == "number" then
                local itemLoc = CreateFromMixins(ItemLocationMixin)
                itemLoc:SetBagAndSlot(bag, slot)
                local guid = C_Item.GetItemGUID(itemLoc)
                if guid then
                    local outfits = Equipmate.Api.GetOutfitsForContainerItem(guid)
                    if #outfits > 0 then
                        GameTooltip_AddBlankLineToTooltip(GameTooltip);
                        --tooltip:AddLine(BLUE_FONT_COLOR:WrapTextInColorCode(addonName))
                        GameTooltip_AddColoredLine(GameTooltip, EQUIPMATE_ITEM_TOOLTIP_EQUIPMENT_SET_ITEM_HEADER_LINE, BLUE_FONT_COLOR);
                        for _, outfit in ipairs(outfits) do
                            --tooltip:AddLine(TRANSMOGRIFY_FONT_COLOR:WrapTextInColorCode(outfit.name))
                            --GameTooltip_AddColoredLine(GameTooltip, outfit.name, NECROLORD_GREEN_COLOR);
                            GameTooltip_AddColoredLine(GameTooltip, outfit.name, WHITE_FONT_COLOR);
                        end
                        GameTooltip_AddBlankLineToTooltip(GameTooltip);
                    end
                end
            end
        end
    end)


    self:SetupTuturial()

end

function EquipmateMixin:SetupTuturial()
    for k, v in ipairs(self.helptips) do
        v.next:Show()
        v:Hide()
    end

    self.helptip1:SetText(EQUIPMATE_HELPTIP_NEW_OUTFIT)
    self.helptip2:SetText(EQUIPMATE_HELPTIP_DRAG_DROP_LISTVIEW)
    self.helptip3:SetText(EQUIPMATE_HELPTIP_DROPDOWN_CONTROLS)
    self.helptip4:SetText(EQUIPMATE_HELPTIP_EQUIP_OUTFIT)
    self.helptip5:SetText(EQUIPMATE_HELPTIP_RIBBON_CONTROLS)
    self.helptip6:SetText(EQUIPMATE_HELPTIP_PAPERDOLL)

    local function helptip_onNextClick(id)
        self["helptip"..id]:Hide()

        if self["helptip"..(id+1)] then
            self["helptip"..(id+1)]:Show()
        end
    end

    for i = 1, #self.helptips do
        self["helptip"..i].next:SetScript("OnClick", function()
            helptip_onNextClick(i)
        end)
    end

end

function EquipmateMixin:LaunchTuturial()
    for k, v in ipairs(self.helptips) do
        v:Hide()
    end
    self.helptip1:Show()
end

function EquipmateMixin:SetView(view)
    for k, frame in ipairs(self.views) do
        frame:Hide()
    end
    if self[view] then
        self[view]:Show()
    end
end

function EquipmateMixin:PerformSwapScanReturn()
    C_Timer.After(1.0, function()
        local resistances = Equipmate.Api.GetPlayerResistances()
        local stats = Equipmate.Api.GetPaperDollStats()

        if self.selectedOutfit then
            self.selectedOutfit.resistances = resistances
            self.selectedOutfit.stats = stats
        end

        self:LoadOutfitStats(resistances, stats)
        Equipmate.Api.EquipItemSet({ name = "SWAP_SCAN_RETURN_SET", items = self.swapScanReturnOutfit, }, self.isBankOpen)
    end)
end

function EquipmateMixin:OutfitConfig_OnClick()

    -- local outfits = Database:GetOutfits(addon.thisCharacter)
    -- for k, v in ipairs(outfits) do
        
    -- end

    if self.selectedOutfit and self.selectedOutfit.name and self.selectedOutfit.id then
        local menu = {
            {
                text = self.selectedOutfit.name,
                isTitle = true,
                notCheckable = true,
            },
            {
                text = "Set Keybind ID",
                isTitle = true,
                notCheckable = true,
            },
        }
        table.insert(menu, 2, Equipmate.ContextMenuSeparator)

        for i = 1, 10 do
            table.insert(menu, {
                text = i,
                notCheckable = true,
                func = function()
                    Database:SetKeyBindingOutfit(i, self.selectedOutfit.id)
                end,
            })
        end

        EasyMenu(menu, Equipmate.ContextMenu, "cursor", 0, 0, "MENU", 1.25)
    end
end

function EquipmateMixin:SetBankState(isOpen)
    self.isBankOpen = isOpen;
    Equipmate.Constants.IsBankOpen = isOpen; --update to this constant for other areas
end

function EquipmateMixin:SetSlotIgnore(slotID, ignored)
    if self.selectedOutfit and self.selectedOutfit.name then
        for k, v in ipairs(self.selectedOutfit.items) do
            if v.slotID == slotID then
                v.ignored = ignored
            end
        end
    end
end

function EquipmateMixin:OnEvent(event, ...)
    if event == Equipmate.Constants.BlizzardEvents.PlayerEnteringWorld then
        self:PlayerEnteringWorld()
    end

    if event == Equipmate.Constants.BlizzardEvents.BankFrameOpened then
        Equipmate.CallbackRegistry:TriggerEvent(Equipmate.Constants.CallbackEvents.BankFrameStateChanged, true)
    end

    if event == Equipmate.Constants.BlizzardEvents.BankFrameClosed then
        Equipmate.CallbackRegistry:TriggerEvent(Equipmate.Constants.CallbackEvents.BankFrameStateChanged, false)
    end

    if Equipmate.Constants.ConfigEvents[event] then
        self:ApplyConfigRules()
    end
end

function EquipmateMixin:OnShow()

end

function EquipmateMixin:OnHide()
    for k, v in ipairs(Equipmate.Constants.PaperDollInventorySlotToggleButtons) do
        v:SetShown(false)
    end
end

function EquipmateMixin:Database_OnInitialised()
    self:CreateOutfitDropdownMenu()

    self:SetupConfigPanel()

    CreatePaperDollButtons()

    -- local function foo(outfit)
    --     DevTools_Dump(outfit.items)
    -- end

    -- Equipmate.Api.RegisterCallBack("EQUIPMATE_ON_SET_SELECTED", foo)

    local function baganator()

        Baganator.API.RegisterItemSetSource("Equipmate", "equipmate", function(itemLocation, guid)

            local outfits = Equipmate.Api.GetOutfitsForContainerItem(guid)
            -- use the location or guid to generate a table like this:
            -- return {
            --   {name = "First Equipment Set", iconTexture = 3802},
            --   {name = "Another Equipment Set This Item Happens To Be In", iconTexture = 3223},
            -- }

            local t = {}

            if #outfits > 0 then
                for _, outfit in ipairs(outfits) do
                    table.insert(t, {
                        name = outfit.name
                    })
                end
            end

            return t;
            --nothing returned so ?
        end)
    end

    if Baganator and Baganator.API then
        baganator()
    end
end

function EquipmateMixin:PlayerEnteringWorld()

    self:UnregisterEvent(Equipmate.Constants.BlizzardEvents.PlayerEnteringWorld)

    local name, realm = UnitName("player")
    if not realm then
        realm = GetNormalizedRealmName()
    end
    local nameRealm = string.format("%s-%s", name, realm)
    local _, _, classID = UnitClass("player")
    local _, _, raceID = UnitRace("player")

    addon.thisCharacter = nameRealm;

    addon.Database:Init() --pass in true to reset the db

    addon.Database:NewCharacter(nameRealm, classID, raceID)

    self:CreateSlashCommands()
end

function EquipmateMixin:CreateSlashCommands()
    SLASH_EQUIPMATE1 = '/equipmate'
    SLASH_EQUIPMATE2 = '/eqm'
    SlashCmdList['EQUIPMATE'] = function(msg)
        local arg1, arg2 = strsplit(" ", msg)
        if arg1 == "" then
            self:Show()

        elseif (arg1 == "equip") and (type(arg2) == "string") then
            self:ApplySelectedOutfit(arg2)
        end
    end
end

function EquipmateMixin:OnNewOutfit(name, outfit)
    self.selectedOutfit = outfit;
    self.deleteOutfit:SetEnabled(true)
    self.equipOutfit:SetEnabled(true)
    self:CreateOutfitDropdownMenu()
    self.selectOutfitDropdown:SetText(name)

    local currentEquipment = Equipmate.Api.GetPlayerEquipment()
    outfit.items = currentEquipment;

    self:LoadOutfitItems(outfit)
end

function EquipmateMixin:RescanEquipment(updateSelectedOutfit)
    
    if updateSelectedOutfit and self.selectedOutfit then
        local currentEquipment = Equipmate.Api.GetPlayerEquipment()
        self:UpdateOutfitItems(nil, currentEquipment)
    end
end

function EquipmateMixin:UpdateOutfitItems(outfit, items)
    
    if not outfit then
        if self.selectedOutfit and self.selectedOutfit.name then
            self.selectedOutfit.items = items;
            self:LoadOutfitItems(self.selectedOutfit)
            print(string.format("[%s] updated outfit items for - %s", addonName, self.selectedOutfit.name))
        end
    end
end

function EquipmateMixin:OnOutfitSelected(outfit)
    self.selectedOutfit = outfit;
    self.deleteOutfit:SetEnabled(true)
    self.equipOutfit:SetEnabled(true)
    self:LoadOutfitItems(outfit)
end

function EquipmateMixin:OnOutfitChanged(name, outfit)
    self:LoadOutfitItems(outfit)
end

function EquipmateMixin:Database_OnOutfitDeleted()
    self:LoadOutfitItems({})
    self.selectOutfitDropdown:SetText("")
    self.selectedOutfit = nil
    self.deleteOutfit:SetEnabled(false)
    self.equipOutfit:SetEnabled(false)
    self:CreateOutfitDropdownMenu()
end

function EquipmateMixin:DeleteOutfit()
    if self.selectedOutfit then
        Database:DeleteOutfit(self.selectedOutfit.name)
    end
end

function EquipmateMixin:ApplySelectedOutfit(name)

    --this is for macro use
    --look for an outfit with matching name
    --call OnOutfitSelected to simulate the dropdown menu
    if name then
        local foundOutift = false
        local outfits = Database:GetOutfits()
        for k, v in ipairs(outfits) do
            if v.name == name and v.character == addon.thisCharacter then
                self:OnOutfitSelected(v)
                foundOutift = true
            end
        end
        if foundOutift == false then
            return
        end
    end

    if not self.selectedOutfit then
        return
    end

    Equipmate.Api.EquipItemSet(self.selectedOutfit, self.isBankOpen)

end

function EquipmateMixin:LoadOutfitItems(outfit)

    if not outfit.items then
        self.equipmentListview.scrollView:SetDataProvider(CreateDataProvider({}))
        return
    end

    if outfit.resistances and outfit.stats then
        self:LoadOutfitStats(outfit.resistances, outfit.stats)
    end


    local minIlvl, maxIlvl = 10000, 0;
    for k, item in ipairs(outfit.items) do
        if item.link then
            local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(item.link)
            if effectiveILvl then
                if effectiveILvl <= minIlvl then
                    minIlvl = effectiveILvl
                end
                if effectiveILvl >= maxIlvl then
                    maxIlvl = effectiveILvl
                end
            end
        end
    end

    local iLvlRange = maxIlvl - minIlvl;

    local outfitItemInfo = Equipmate.Api.GetInfoForEquipmentSetItems(outfit.items)
    self.equipmentListview.outfitInfoLeft:SetText(string.format("%d items", outfitItemInfo.numItems))
    self.equipmentListview.outfitInfoRight:SetText(string.format("Average ilvl %s", outfitItemInfo.averageItemLevel))

    local characterInfo = Database:GetCharacterInfo(addon.thisCharacter)
    if characterInfo and characterInfo.classID then
        local t = {}
        for k, item in ipairs(outfit.items) do

            local labelRight = ""

            if item.link then
                local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(item.link)
                if effectiveILvl then

                    local percent = ((effectiveILvl - minIlvl) / iLvlRange) * 100
                    --print(string.format("ilvl %s - min %s - max %s, range %s, percent = %s", effectiveILvl, minIlvl, maxIlvl, iLvlRange, per))
                    local r = (percent > 50 and 1 - 2 * (percent - 50) / 100.0 or 1.0);
                    local g = (percent > 50 and 1.0 or 2 * percent / 100.0);
                    local b = 0.0;


                    labelRight = CreateColor(r, g, b):WrapTextInColorCode(string.format("ilvl %d", effectiveILvl))
                end
            end

            table.insert(t, {
                label = item.link,
                labelRight = labelRight,
                --iconRight = (item.ignored == true) and 255352 or nil,
                icon = item.icon,
                iconSize = { 22, 22 },
                onMouseEnter = function(f)
                    if item.link then
                        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(item.link)
                        GameTooltip:Show()
                    end

                    if CursorHasItem() then
                        local infoType, itemID, itemLink = GetCursorInfo()
                        if infoType == "item" then
                            local _, _, _, equipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(itemLink)
                            if equipLoc and itemClassID and itemSubClassID then
                                local match = Equipmate.Api.TestItemForClassAndSlot(characterInfo.classID, equipLoc, itemClassID, itemSubClassID, item.slotID, false)
                                if match then
                                    local itemLoc = C_Cursor.GetCursorItem()
                                    if itemLoc then
                                        local guid = C_Item.GetItemGUID(itemLoc)
                                        if guid then
                                            item.link = itemLink
                                            item.guid = guid
                                            Equipmate.CallbackRegistry:TriggerEvent(Equipmate.Constants.CallbackEvents.DatabaseOnOutfitChanged, outfit.name, outfit)
                                            ClearCursor()
                                        end
                                    end
                                end
                            end
                        end
                    end

                end,
            })
        end
        self.equipmentListview.scrollView:SetDataProvider(CreateDataProvider(t))
    end

end

function EquipmateMixin:LoadOutfitStats(resistances, stats)

    --print(Equipmate.Api.GetCurrentOutfitStatus())

    local res = {}
    for k, v in ipairs(resistances) do
        table.insert(res, {
            label = string.format("|cffffffff%s|r", v.name),
            labelRight = v.total,
            fontObject = GameFontNormalSmall,
        })
    end
    self.statsContainer.resistances.listview.scrollView:SetDataProvider(CreateDataProvider(res))

    local attributes = {}
    for k, v in ipairs(stats.attributes) do
        table.insert(attributes, {
            label = string.format("|cffffffff%s|r", v.name),
            labelRight = v.val,
            fontObject = GameFontNormalSmall,
        })
    end
    self.statsContainer.attributes.listview.scrollView:SetDataProvider(CreateDataProvider(attributes))

    local def = {}
    for stat, val in pairs(stats.defence) do

        if stat == "tooltips" then
            
        else
            table.insert(def, {
                label = string.format("|cffffffff%s|r", stat),
                labelRight = val,
                fontObject = GameFontNormalSmall,
            })
        end

    end
    table.sort(def, function(a, b)
        return a.label < b.label
    end)
    self.statsContainer.defence.listview.scrollView:SetDataProvider(CreateDataProvider(def))

    local melee = {}
    for stat, val in pairs(stats.melee) do
        table.insert(melee, {
            label = string.format("|cffffffff%s|r", stat),
            labelRight = val,
            fontObject = GameFontNormalSmall,
        })
    end
    table.sort(melee, function(a, b)
        return a.label < b.label
    end)
    self.statsContainer.melee.listview.scrollView:SetDataProvider(CreateDataProvider(melee))

    local ranged = {}
    for stat, val in pairs(stats.ranged) do
        table.insert(ranged, {
            label = string.format("|cffffffff%s|r", stat),
            labelRight = val,
            fontObject = GameFontNormalSmall,
        })
    end
    table.sort(ranged, function(a, b)
        return a.label < b.label
    end)
    self.statsContainer.ranged.listview.scrollView:SetDataProvider(CreateDataProvider(ranged))

    local spell = {}
    for stat, val in pairs(stats.spell) do
        if type(val) == "number" then
            if stat == "SpellCrit" then
                table.insert(spell, {
                    label = string.format("|cffffffff%s|r", stat),
                    labelRight = val,
                    fontObject = GameFontNormalSmall,
                    onMouseEnter = function(f)
                        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
                        GameTooltip:AddLine(" ")
                        for k, v in ipairs(stats.spell.tooltips.crit) do
                            GameTooltip:AddDoubleLine(v.name, v.val)
                        end
                        GameTooltip:Show()
                    end,
                })
            elseif stat == "SpellDamage" then
                table.insert(spell, {
                    label = string.format("|cffffffff%s|r", stat),
                    labelRight = val,
                    fontObject = GameFontNormalSmall,
                    onMouseEnter = function(f)
                        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
                        GameTooltip:AddLine(" ")
                        for k, v in ipairs(stats.spell.tooltips.damage) do
                            GameTooltip:AddDoubleLine(v.name, v.val)
                        end
                        GameTooltip:Show()
                    end,
                })
            else
                table.insert(spell, {
                    label = string.format("|cffffffff%s|r", stat),
                    labelRight = val,
                    fontObject = GameFontNormalSmall,
                })
            end
        end
    end
    table.sort(spell, function(a, b)
        return a.label < b.label
    end)
    self.statsContainer.spell.listview.scrollView:SetDataProvider(CreateDataProvider(spell))

end

function EquipmateMixin:CreateOutfitDropdownMenu()
    -- local outfitMenu = {
    --     {
    --         text = "New Outfit",
    --         icon = "communities-icon-addgroupplus",
    --         func = function()
    --             StaticPopup_Show("NewOutfit")
    --         end,
    --     },
    -- }
    local outfitMenu = {}
    local outfits = Database:GetOutfits(addon.thisCharacter)

    for i = #outfits, 1, -1 do
        local outfit = outfits[i]
        table.insert(outfitMenu, {
            text = outfit.name,
            func = function()
                self:OnOutfitSelected(outfit)
            end,
        })
    end
    self.selectOutfitDropdown:SetMenu(outfitMenu)
end




--[[
    ==============================
    options panel
    ==============================
]]


function EquipmateMixin:SetupConfigPanel()

    self.configPanel.header.title:SetText(addon.thisCharacter)

    local function spinShiftButtons(frame)
        frame.shiftUp.icon:SetRotation(1.57)
        frame.shiftDown.icon:SetRotation(-1.57)
    end

    local function party_onLoad(frame, data)

        spinShiftButtons(frame)

        frame.label:SetText(data.label)
        local outfits = Database:GetOutfits(addon.thisCharacter)
        local menu = {}
        for k, v in ipairs(outfits) do
            table.insert(menu, {
                text = v.name,
            })
        end
        frame.dropdown:SetMenu(menu)
    end

    local config = {}
    config.party5 = {
        label = "Party 5",
    }
    config.party25 = {
        label = "Party 25",
    }
    config.party10 = {
        label = "Party 10",
    }
    config.party40 = {
        label = "Party 40",
    }

    local characterConfigDefaults = {
        ["party-5"] = {
            template = "EquipmateSettingsDropdownTemplate",
            height = 35,
            initializer = function(f)
                party_onLoad(f, config.party5)
            end,
        },
        ["party-10"] = {
            template = "EquipmateSettingsDropdownTemplate",
            height = 35,
            initializer = function(f)
                party_onLoad(f, config.party10)
            end,
        },
        ["party-25"] = {
            template = "EquipmateSettingsDropdownTemplate",
            height = 35,
            initializer = function(f)
                party_onLoad(f, config.party25)
            end,
        },
        ["party-40"] = {
            template = "EquipmateSettingsDropdownTemplate",
            height = 35,
            initializer = function(f)
                party_onLoad(f, config.party40)
            end,
        },
    }

    local sv = {
        {
            rule = "inGroup",
            active = false,
            priority = 0,
            action = "none",
        },
        {
            rule = "isRested",
            active = false,
            priority = 0,
            action = "none",
        },
    }

    local t = {}
    for k, v in ipairs(sv) do
        table.insert(t, characterConfigDefaults[v])
    end
    self.configPanel.listview.scrollView:SetDataProvider(CreateDataProvider(t))

    local function updateListview(t)
        -- table.sort(t, function(a, b)
        --     return a.index < b.index;
        -- end)
        self.configPanel.listview.scrollView:SetDataProvider(CreateDataProvider(t))
    end

end



function EquipmateMixin:ApplyConfigRules()

end













--[[
    Equipmate Flyout

    This is the flyout frame for the character paperdoll window inventory slots
]]

EquipmentFlyoutFrameMixin = {}
function EquipmentFlyoutFrameMixin:OnLoad()
    self.items = {}
    self.buttons = {}
    self.slotID = false

    local ignoreSlotButton = CreateFrame("BUTTON", string.format("%sEquipmentFlyoutButton%s", addonName, "1"), self.buttonFrame, "EquipmentFlyoutButtonTemplate")
    ignoreSlotButton:SetNormalTexture(255352)
    ignoreSlotButton:SetSize(40,40)
    ignoreSlotButton:SetTooltip(L.FLYOUT_IGNORE_SLOT)
    self.buttons[1] = ignoreSlotButton;

    local putInBagButton = CreateFrame("BUTTON", string.format("%sEquipmentFlyoutButton%s", addonName, "2"), self.buttonFrame, "EquipmentFlyoutButtonTemplate")
    putInBagButton:SetNormalTexture(255351)
    putInBagButton:SetSize(40,40)
    putInBagButton:SetTooltip(L.FLYOUT_PUT_IN_BAG)
    self.buttons[2] = putInBagButton;

    NineSliceUtil.ApplyLayout(self.buttonFrame, Equipmate.Constants.FlyoutButtonsFrameLayout)

    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("MODIFIER_STATE_CHANGED")
    self:SetScript("OnEvent", function(_, event, ...)
        if event == "BAG_UPDATE_DELAYED" then
            self:Update()
        end
        if event == "MODIFIER_STATE_CHANGED" then
            if IsShiftKeyDown() then
                self:Update()
            end
        end
    end)

    Equipmate.CallbackRegistry:RegisterCallback(Equipmate.Constants.CallbackEvents.BankFrameStateChanged, self.SetBankState, self)

end
function EquipmentFlyoutFrameMixin:SetBankState(isOpen)
    self.isBankOpen = isOpen;
end
function EquipmentFlyoutFrameMixin:IsVerticle(isVerticle)
    self.isVerticle = isVerticle;
end
function EquipmentFlyoutFrameMixin:SetSlot(slotID)
    self.slotID = slotID;
end
function EquipmentFlyoutFrameMixin:ClearItems()
    wipe(self.items)
end
function EquipmentFlyoutFrameMixin:OnHide()
    for k, v in ipairs(Equipmate.Constants.PaperDollInventorySlotToggleButtons) do
        Equipmate.Api.EquipmentFlyoutPopoutButton_SetReversed(v, false)
    end
    self:SetScript("OnUpdate", nil)
    if self.fadeTimer then
        self.fadeTimer:Cancel()
    end
end
function EquipmentFlyoutFrameMixin:OnShow()
    self:Update()

    self.fadeTimer = C_Timer.NewTimer(1.75, function()
        self:SetScript("OnUpdate", function()
            if self.buttonFrame:IsVisible() then
                local isOver = false
                if self:IsMouseOver() then
                    isOver = true
                end
                if self.buttonFrame:IsMouseOver() then
                    isOver = true
                end
                for k, v in ipairs(self.buttons) do
                    if v:IsMouseOver() then
                        isOver = true
                    end
                end
                if self:GetParent():IsMouseOver() then
                    isOver = true
                end
                if not isOver then
                    self:Hide()
                end
            end
        end)
    end)
end
function EquipmentFlyoutFrameMixin:OnKeyUp(key)
    self:Update()
end
function EquipmentFlyoutFrameMixin:OnKeyDown(key)
    self:Update()
end
function EquipmentFlyoutFrameMixin:Update()

    if not self.slotID then
        return;
    end

    self.items = Equipmate.Api.GetItemsForInvSlot(self.slotID, self.isBankOpen)
    
    for k, v in ipairs(self.buttons) do
        v:Hide()
    end
    self.buttons[1]:Show()
    self.buttons[2]:Show()

    self.buttons[2]:SetScript("OnClick", function()
        for bag = 0, 4 do
            local freeSlots = C_Container.GetContainerFreeSlots(bag)
            if #freeSlots > 0 then
                PickupInventoryItem(self.slotID)
                C_Container.PickupContainerItem(bag, freeSlots[1])
            end
        end
    end)
    self.buttons[1]:SetScript("OnClick", function()
        Equipmate.CallbackRegistry:TriggerEvent(Equipmate.Constants.CallbackEvents.OutfitSetSlotIgnore, self.slotID, true)
    end)

    if #self.items > 0 then
        for k, item in ipairs(self.items) do
            local buttonIndex = k+2
            if not self.buttons[buttonIndex] then
                local button = CreateFrame("BUTTON", string.format("%sEquipmentFlyoutButton%s", addonName, buttonIndex), self.buttonFrame, "EquipmentFlyoutButtonTemplate")
                button:SetSize(40,40)
                self.buttons[buttonIndex] = button;
            end
            self.buttons[buttonIndex]:SetItem(item)
        end
    end

    local columOffset = 0;
    local rowOffset = 0;

    if self.isVerticle then
        local i = 0;
        for k, button in ipairs(self.buttons) do
            button:ClearAllPoints()
            button:SetPoint("TOP", 0, (i * -40) - 5)
            i = i + 1;
        end
        self.buttonFrame:SetSize(50, 10 + ((#self.items+2)*40))
        self.buttonFrame:ClearAllPoints()
        self.buttonFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -6)

        --self:SetHitRectInsets(-1, -1, -1, -6)

    else
        local i = 0;
        for k, button in ipairs(self.buttons) do
            button:ClearAllPoints()
            button:SetPoint("LEFT", (i * 40) + 5, rowOffset)
            i = i + 1;
        end
        self.buttonFrame:SetSize(10 + ((#self.items+2)*40), 50)
        self.buttonFrame:ClearAllPoints()
        self.buttonFrame:SetPoint("LEFT", self, "RIGHT", 6, 0)

        --self:SetHitRectInsets(-1, -6, -1, -1)
    end

    --is this mayeb a better layout?
    -- for k, button in ipairs(self.buttons) do
    --     button:ClearAllPoints()
    --     button:SetPoint("LEFT", ((k-1) * 40) + 5, 0)
    -- end
    --self.buttonFrame:SetSize(10 + ((#self.items+1)*40), 50)

end





