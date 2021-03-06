-----------------------
-- Namespaces
-----------------------
local AddOnName, core = ...;
local SM, DB, DP, L, U = unpack(select(2, ...))

local function AddNewTab(self)
	PanelTemplates_SetNumTabs(self, 3); -- Increase number of tabs
	local SetMasterTab = CreateFrame("Button", self:GetName().."Tab3", self, "TabButtonTemplate");
	SetMasterTab:SetPoint("LEFT", WardrobeCollectionFrameTab2, "RIGHT", 0, 0);
	SetMasterTab:SetText("Outfits");
	SetMasterTab:SetID(3)
	self.Tabs[3] = SetMasterTab; -- Adding new tab to  tab table
	PanelTemplates_ResizeTabsToFit(self, U.TABS_MAX_WIDTH);
	-- Using a hooked function in order to enlarge the tabs' width
	for i = 1, 3 do
		tab = _G[self:GetName().."Tab"..i]
		tab:SetScript("OnClick", WardrobeCollectionFrame_ClickTab);
	end
	-- Moving the progress bar slightly to make room for larger tabs
	self.progressBar:SetPoint("TOPLEFT", self.Tabs[1], "TOPLEFT", 210, -11)

end

function AddOutfitsPanel()
	local OutfitsCollection = CreateFrame("Frame", "OutfitsCollectionFrame", WardrobeCollectionFrame, "OutfitsCollectionFrameTemplate");
	OutfitsCollection.searchType = U.SM_TRANSMOG_SEARCH_TYPE_OUTFITS;
	SM.OutfitsCollectionFrame = OutfitsCollection;
	HybridScrollFrame_CreateButtons(OutfitsCollection.ScrollFrame, "WardrobeSetsScrollFrameButtonTemplate", 44, 0);
	HybridScrollFrame_SetDoNotHideScrollBar(OutfitsCollection.ScrollFrame, true);
end

function AddTransmogPanel()
	local TransmogPanel = CreateFrame("Frame", "OutfitsTransmogFrame", WardrobeCollectionFrame, "CollectionsBackgroundTemplate, OutfitsTransmogFrameTemplate");
	WardrobeCollectionFrame.OutfitsTransmogFrame = TransmogPanel;
end

function SM:OnInitialize()
	local defaults = {
		char = {
			favorites = { }
		}
	}
	self.db = LibStub("AceDB-3.0"):New(AddOnName.."DB", defaults ,true);
	--self.db:ResetDB() -- Debug function
end

local function AddBlizzardMixins()
	DP:AddBlizzardMixins();
	ExtSetsCollectionMixin:AddBlizzardMixins();
	ScrollFrameMixin:AddBlizzardMixins();
	SetMasterSetsModelMixin:AddBlizzardMixins();
	SetMasterTransmogOutfitsCollectionMixin:AddBlizzardMixins();
	SetMasterTransmogScrollFrameMixin:AddBlizzardMixins();
end

function SM:OnEnable()
	local loaded, reason = LoadAddOn('Blizzard_Collections');
	if (loaded) then -- In case Blizzard-Collections fails to load
		AddBlizzardMixins();
		-- Running frame setup
		HookDropDown();
		DP:OnLoad();
		HookClickTab();
		AddNewTab(WardrobeCollectionFrame);
		AddOutfitsPanel();
		AddTransmogPanel();
		WardrobeCollectionSetTabPostHook(); -- Post hook to make our tab appear at all
		CreateDebugSlashCMDs();
	else
		print ("Blizzard_Collections did not load properly. Please post this to the author: ", reason);
	end
end

function CreateDebugSlashCMDs()
	SLASH_SETMASTER_ADDITEM1 = '/sma';
	SlashCmdList['SETMASTER_ADDITEM'] = function(itemID)
		if(itemID ~= "" and not itemID:match("%D")) then
			DP:NewSourceAdded(tonumber(itemID))
			print("Item", itemID, "added to new Sources")
			DP:ClearSets()
		else
			print("Usage: /sma *itemID* (Can only be numerical)")
		end
	end
end

function HookDropDown()
	function Initialize(self, level)
		if ( not WardrobeCollectionFrame.activeFrame ) then
			return;
		end

		if ( WardrobeCollectionFrame.activeFrame.searchType == LE_TRANSMOG_SEARCH_TYPE_ITEMS ) then
			WardrobeFilterDropDown_InitializeItems(self, level);
		elseif ( WardrobeCollectionFrame.activeFrame.searchType == LE_TRANSMOG_SEARCH_TYPE_BASE_SETS ) then
			WardrobeFilterDropDown_InitializeBaseSets(self, level);
		elseif ( WardrobeCollectionFrame.activeFrame.searchType == U.SM_TRANSMOG_SEARCH_TYPE_OUTFITS) then
			SetsTabFilterDropDown_InitializeSets(self, level);
		end
	end

	UIDropDownMenu_Initialize(WardrobeFilterDropDown, Initialize, "MENU");
end

function HookClickTab()
	local BlizzWardrobeCollectionFrame_ClickTab = WardrobeCollectionFrame_ClickTab;

	function WardrobeCollectionFrame_ClickTab(tab)
		WardrobeCollectionFrame_SetTab(tab:GetID());
		PanelTemplates_ResizeTabsToFit(WardrobeCollectionFrame, U.TABS_MAX_WIDTH);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

-- In order for proper tab updating, we're pre hooking the Blizzard function WardrobeCollectionFrame_SetTab.
-- Blizzard has hard coded behaviour for each tab into their function.
-- We execute our own code if we're trying to switch to or from the SetMaster tab, else we just run Blizzard's original function.
-- This function is only run from SM:OnEnable()
function WardrobeCollectionSetTabPostHook()

	local BlizzWardrobeCollectionFrame_SetTab = WardrobeCollectionFrame_SetTab;

	function WardrobeCollectionFrame_SetTab(...)
		local tabID = ...;
		local atTransmogrifier = WardrobeFrame_IsAtTransmogrifier();
		if tabID == U.TAB_EXT then
			WardrobeCollectionFrame_ClearSearch();
			PanelTemplates_SetTab(WardrobeCollectionFrame, tabID);
			local selectedTab;
			if atTransmogrifier then
				--print("You have visited the Transmogrifier vendor. This functionality is not yet implemented. Expect this in a future update.");
				OutfitsTransmogFrame:Show();
				selectedTab = WardrobeCollectionFrame.selectedTransmogTab;
			else
				OutfitsCollectionFrame:Show();
				selectedTab = WardrobeCollectionFrame.selectedCollectionTab;
			end
			-- Hiding Items tab
			WardrobeCollectionFrame.searchBox:ClearAllPoints();
			WardrobeCollectionFrame.searchBox:SetEnabled(true);
			WardrobeCollectionFrame.searchBox:SetText("");
			if selectedTab == U.TAB_ITEMS then
				WardrobeCollectionFrame.ItemsCollectionFrame:Hide();
				if atTransmogrifier then
					-- If special transmogrifier options are added
				else
					WardrobeCollectionFrame.searchBox:SetPoint("TOPLEFT", 19, -69);
					WardrobeCollectionFrame.searchBox:SetWidth(145);
					WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.OutfitsCollectionFrame;
				end
			-- Hiding Sets tab
			elseif selectedTab == U.TAB_SETS then
				WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.OutfitsCollectionFrame;
				WardrobeCollectionFrame.SetsCollectionFrame:Hide();
				WardrobeCollectionFrame.SetsTransmogFrame:Hide();
			end
		else
			OutfitsTransmogFrame:Hide();
			OutfitsCollectionFrame:Hide();
			return BlizzWardrobeCollectionFrame_SetTab(...);
		end
	end
end
