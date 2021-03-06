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
	local label = Engine[2].setSources[set.expansionID]
	for k, v in pairs(set.sourceTypes) do
		label = label..", "..Engine[2].setSources.sourceType[v]
	end
	return label
end