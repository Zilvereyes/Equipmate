

local addonName, addon = ...;

local locales = {}

locales.enUS = {

    HELPTIP_NEW_OUTFIT = "Click here to create a new outfit.",
    HELPTIP_DRAG_DROP_LISTVIEW = "Drag and drop items here to build your outfit.\n\n|cff33ccffNote the item will only 'drop' into the correct slot for the item.",
    HELPTIP_DROPDOWN_CONTROLS = "Use the dropdown to select outfits.",
    HELPTIP_EQUIP_OUTFIT = "Click to equip the outfit.\n\n|cff33ccffRequires the outfit items to be accesible.",
    HELPTIP_RIBBON_CONTROLS = "View outfit items, rescan your current equipment, view stats or setup advanced config options.",
    HELPTIP_PAPERDOLL = "Toggle the flyout buttons to quickly swap items.\n\n|cff33ccffNote that this doesn't automatically save the item to the outfit, use the rescan button to update the selected outfit.",


    PAPERDOLL_TOGGLE_BUTTON_TITLE = "Equipmate",
    PAPERDOLL_TOGGLE_BUTTON_TEXT = "|cffffffffLeft click for quick swap\nRight click to show manager",

    UI_RESCAN_BUTTON_TOOLTIP_TITLE = "Rescan equipment",
    UI_RESCAN_BUTTON_TOOLTIP_TEXT = "Scan your characters equipment and update the current outfit.", --\n|cff33ccffThis will overwrite the currently selected outfit.",

    UI_SWAP_SCAN_BUTTON_TOOLTIP_TITLE = "Swap and Scan",
    UI_SWAP_SCAN_BUTTON_TOOLTIP_TEXT = "Equipmate will attempt to equip the outfit items, scan your characters stats and then swap back to your current gear.\n|cff33ccffIt takes a few seconds to perform this operation and requires items to be available and accessible",

    UI_OUTFIT_ITEMS_TOOLTIP_TITLE = "Items",
    UI_OUTFIT_ITEMS_TOOLTIP_TEXT = "View the outfit items",

    UI_OUTFIT_STATS_TOOLTIP_TITLE = "Stats",
    UI_OUTFIT_STATS_TOOLTIP_TEXT = "View character stats for an outfit. Equipmate will display the stats from the previous Swap and Scan, if the outfit changed this may be outdated information.\n|cff33ccffTo update the stats, select an outfit from the dropdown and click the 'Swap and Scan' button.",

    UI_OUTFIT_SELECT_DROPDOWN_TOOLTIP_TITLE = "Select outfit",
    UI_OUTFIT_SELECT_DROPDOWN_TOOLTIP_TEXT = "Your outfits will be listed here. Select an outfit to view its items.\nIf an outfit is selected you can rescan to update the items.",

    UI_OUTFIT_CONFIG_BUTTON_TITLE = "Outfit config",
    UI_OUTFIT_CONFIG_BUTTON_TEXT = "You can set an ID for this set which is used in the key bindings.",
    
    CHARACTER_HELPTIP = "You can manage your character's equipment here.\n\nCreate a new equipment set and give it a name.\n\nThe set will be created with your current gear loaded into the list.\n\nYou can view alternative items via the slot flyouts or manually change items. To save the set click 'Rescan'.\n\nTo equip a set click on Equip, or use a macro \n/equipmate equip [set name] (set name cannot contain any spaces)\n\nWarning, items in the bank will require you to have the bank open.",

    FLYOUT_IGNORE_SLOT = "Ignore slot",
    FLYOUT_PUT_IN_BAG = "Put item in bag",

    ITEM_TOOLTIP_EQUIPMENT_SET_ITEM_HEADER_LINE = "Part of the following outfits",
    ITEM_TOOLTIP_BINDING_CONFIRMATION = "Binding an item requires confirmation.",
}


addon.locales = locales[GetLocale()];


--thsi allows use in xml without having to constantly set in Lua
--CAUTION - always prefix the key (done in the string.format now)
for k, v in pairs(addon.locales) do
    _G[string.format("%s_%s", addonName:upper(), k)] = v;
end
