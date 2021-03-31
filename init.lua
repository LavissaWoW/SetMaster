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
		local tab = _G[self:GetName().."Tab"..i]
		tab:SetScript("OnClick", WardrobeCollectionFrame_ClickTab);
	end
	-- Moving the progress bar slightly to make room for larger tabs
	self.progressBar:SetPoint("TOPLEFT", self.Tabs[1], "TOPLEFT", 210, -11)

end

local function AddOutfitsPanel()
	local OutfitsCollection = CreateFrame("Frame", "OutfitsCollectionFrame", WardrobeCollectionFrame, "OutfitsCollectionFrameTemplate");
	OutfitsCollection.searchType = U.SM_TRANSMOG_SEARCH_TYPE_OUTFITS;
	SM.OutfitsCollectionFrame = OutfitsCollection;
	HybridScrollFrame_CreateButtons(OutfitsCollection.ScrollFrame, "WardrobeSetsScrollFrameButtonTemplate", 44, 0);
	HybridScrollFrame_SetDoNotHideScrollBar(OutfitsCollection.ScrollFrame, true);
end

local function AddTransmogPanel()
	local TransmogPanel = CreateFrame("Frame", "OutfitsTransmogFrame", WardrobeCollectionFrame, "CollectionsBackgroundTemplate, OutfitsTransmogFrameTemplate");
	TransmogPanel.searchType = U.SM_TRANSMOG_SEARCH_TYPE_OUTFITS;
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

local function CreateStaticPopupEntries()
	StaticPopupDialogs["SETMASTER_APPLY_SET"] = {
		text = "This action will apply all collected appearances in %s.|n|nCost: %s",
		button1 = "Accept",
		button2 = "Cancel",
		hideOnEscape = 1,
		OnAccept = function(self)
			if (self.insertedFrame:GetChecked()) then
				SM.db.char.acceptedTransmogMoneyRisk = true;
			end
			C_Transmog.ApplyAllPending()
		end,
		OnShow = function(self) self.insertedFrame:SetPoint("LEFT", self.button1, "TOPLEFT", -3, 0) end,
	}
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
		CreateStaticPopupEntries();
		DP.TransmogToastAlert = AlertFrame:AddQueuedAlertFrameSubSystem("SetMasterTransmogToastTemplate", SetMasterTransmogToast_SetUp, 3, 10, nil);
		local SMF = CreateFrame("Frame");
		SMF:SetScript("OnEvent", function(_, event, ...)
										if (event == "TRANSMOG_COLLECTION_SOURCE_ADDED") then
											local sourceID = ...;
											C_Timer.After(0, function() SetMasterTransmogToast_Trigger(sourceID);end);
										end
									end);
		SMF:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED");
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
		DP:SetSearch("");
		DP:ClearBaseSets();
		DP:ClearVariantSets();
		DP:ClearUsableSets();
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
					WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.OutfitsTransmogFrame;
				else
					WardrobeCollectionFrame.searchBox:SetPoint("TOPLEFT", 19, -69);
					WardrobeCollectionFrame.searchBox:SetWidth(145);
					WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.OutfitsCollectionFrame;
				end
			-- Hiding Sets tab
			elseif selectedTab == U.TAB_SETS then
				if atTransmogrifier then
					WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.OutfitsTransmogFrame;
				else
					WardrobeCollectionFrame.activeFrame = WardrobeCollectionFrame.OutfitsCollectionFrame;
				end
				WardrobeCollectionFrame.SetsCollectionFrame:Hide();
				WardrobeCollectionFrame.SetsTransmogFrame:Hide();
			end
		else
			OutfitsTransmogFrame:Hide();
			OutfitsCollectionFrame:Hide();
			WardrobeCollectionFrame.searchBox:SetText("");
			return BlizzWardrobeCollectionFrame_SetTab(...);
		end
	end
end

function SetMasterTransmogToast_Trigger(sourceID)
	local appearance = C_TransmogCollection.GetSourceInfo(sourceID).visualID;
	local sources = C_TransmogCollection.GetAppearanceSources(appearance);
	local numCollected = 0;
	for _, item in pairs(sources) do
		if (item.isCollected) then
			numCollected = numCollected + 1;
		end
	end
	if(numCollected == 1 and not C_TransmogCollection.IsNewAppearance(appearance) or numCollected > 1 and C_TransmogCollection.IsNewAppearance(appearance)) then
		print("THE TEST FAILED");
	end
	if (numCollected == 1) then
		DP.TransmogToastAlert:AddAlert(sourceID);
	end

end

function SetMasterTransmogToast_SetUp(frame, sourceID)
	local isSet;
	local numSets = DP:GetSourceNumSets(sourceID);
	frame.Icon:SetTexture(C_TransmogCollection.GetSourceIcon(sourceID));
	frame.Heading:SetText((isSet and "Set" or "Appearance").." collected");
	frame.Count:SetText("Part of "..numSets.." sets");
end
