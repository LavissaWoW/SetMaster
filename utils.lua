-----------------------
-- Namespaces
-----------------------
local AddOnName, Engine = ...
--[[
local SM, DB, DP, L, U = unpack(select(2, ...))
]]--
local SM, DB, DP, L, U = unpack(select(2, ...))

local Utils = { }

Utils.TAB_ITEMS = 1;
Utils.TAB_SETS = 2;
Utils.TAB_EXT = 3;
Utils.TABS_MAX_WIDTH = 200; -- Taken from Blizzard_Wardrobe.lua, line 643
Utils.BASE_SET_BUTTON_HEIGHT = 46;
Utils.IN_PROGRESS_FONT_COLOR_CODE = "|cff40c040";

Utils.SM_COLLECTED_FILTER = 1;
Utils.SM_UNCOLLECTED_FILTER = 2;
Utils.SM_SOURCES_FILTER = 3;
Utils.SM_EXPANSION_FILTER = 4;
Utils.SM_TRANSMOG_SEARCH_TYPE_OUTFITS = 10;

Engine[1] = LibStub("AceAddon-3.0"):NewAddon(AddOnName) -- Main Addon Table
Engine[2] = {} -- Database Table
Engine[3] = {} -- Data Provider
Engine[4] = {} -- Locales
Engine[5] = Utils

_G[AddOnName] = Engine;

SETMASTER_TRANSMOG_SLOTS = {
	[1] = "HEADSLOT",
	[3] = "SHOULDERSLOT",
	[4] = "SHIRTSLOT",
	[5] = "CHESTSLOT",
	[6] = "WAISTSLOT",
	[7] = "LEGSSLOT",
	[8] = "FEETSLOT",
	[9] = "WRISTSLOT",
	[10] = "HANDSSLOT",
	[15] = "BACKSLOT",
	[16] = "MAINHANDSLOT",
	[17] = "SECONDARYHANDSLOT",
	[19] = "TABARDSLOT",
}

SETMASTER_WARDROBE_MODEL_SETUP = {
	["HEADSLOT"] 		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = false } },
	["SHOULDERSLOT"]	= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["BACKSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["CHESTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["TABARDSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["SHIRTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["WRISTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["HANDSSLOT"]		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = true,  HEADSLOT = true  } },
	["WAISTSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["LEGSSLOT"]		= { useTransmogSkin = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["FEETSLOT"]		= { useTransmogSkin = false, slots = { CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true  } },
}

SETMASTER_WARDROBE_MODEL_SETUP_GEAR = {
	["CHESTSLOT"] = 78420,
	["LEGSSLOT"] = 78425,
	["FEETSLOT"] = 78427,
	["HANDSSLOT"] = 78426,
	["HEADSLOT"] = 78416,
}

function Utils:PrintTableValues(table)
	for k, v in pairs(table) do print (k, v) end
end

function Utils:CreateFontStrings(name, parent, size, anchors, textColor, shadowColor, shadowOffset, inherits)
	local fontString = parent:CreateFontString(name, "ARTWORK", inherits);
	if (size) then
		fontString:SetSize(unpack(size))
	end
	for key, value in pairs(anchors) do
		fontString:SetPoint(unpack(value))
	end
	if (textColor) then
		fontString:SetTextColor(unpack(textColor))
	end
	if (shadowColor) then
		fontString:SetShadowColor(unpack(shadowColor))
	end
	if (shadowOffset) then
		fontString:SetShadowOffset(unpack(shadowOffset))
	end

	return fontString
end

function Utils:CreateSetLabel(set)
	if(not set.sourceTypes) then
		return ""
	end
	local label = Engine[2].setSources[set.expansionID]
	for k, v in pairs(set.sourceTypes) do
		label = label..", "..Engine[2].setSources.sourceType[v]
	end
	return label
end