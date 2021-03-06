-----------------------
-- Namespaces
-----------------------
local _, core = ...;
local SM, DB, DP, L, U = unpack(select(2, ...))

-- Setting up namespace-available and local varialbes for mixins
SM.ModelMixin = {}
SM.ExtSetsCollectionMixin = {}
SM.ScrollFrameMixin = {}
-- Stolen from Blizzard_Wardrobe.lua
-- Used by ScrollFrameMixin to define progress bars on buttons
local IN_PROGRESS_FONT_COLOR = CreateColor(0.251, 0.753, 0.251);
local SET_PROGRESS_BAR_MAX_WIDTH = 204;

-- Initializes filter dropdown menu for the appearances tab
--
-- Arguments
-- self: Frame to initialize dropdown in
-- level: The nested level of the dropdown
-- ...: Not used p.t.
-- Return
-- None
function SetsTabFilterDropDown_InitializeSets(self, level, ...)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;
	--local atTransmogrifier = WardrobeFrame_IsAtTransmogrifier();
	if level == 1 then
		info.isNotRadio = true;
		info.text = COLLECTED
		info.func = function(_, _, _, value)
						DP:C_SetFilter(U.SM_COLLECTED_FILTER, value)
						SM.OutfitsCollectionFrame:Refresh()
					end
		info.checked = DP:C_GetFilter(U.SM_COLLECTED_FILTER)
		UIDropDownMenu_AddButton(info, level)

		info.text = NOT_COLLECTED
		info.func = function(_, _, _, value) 
						DP:C_SetFilter(U.SM_UNCOLLECTED_FILTER, value)
						SM.OutfitsCollectionFrame:Refresh()
					end
		info.checked = DP:C_GetFilter(U.SM_UNCOLLECTED_FILTER)
		UIDropDownMenu_AddButton(info, level)

		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;

		info.text = SOURCES
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)

		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;

		info.text = "Expansion"
		info.value = 2;
		UIDropDownMenu_AddButton(info, level)
	else
		if level == 2 then
			if (UIDROPDOWNMENU_MENU_VALUE == 1) then
				local refreshLevel = 2--atTransmogrifier and 1 or 2;
				info.hasArrow = false;
				info.isNotRadio = true;
				info.notCheckable = true;

				info.text = CHECK_ALL
				info.func = function()
								DP:C_SetAllSourceTypeFilters(true);
								UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
								SM.OutfitsCollectionFrame:Refresh()
							end
				UIDropDownMenu_AddButton(info, level)

				info.text = UNCHECK_ALL
				info.func = function()
								DP:C_SetAllSourceTypeFilters(false);
								UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
								SM.OutfitsCollectionFrame:Refresh()
							end
				UIDropDownMenu_AddButton(info, level)

				info.notCheckable = false;
				local numSources = DP:C_GetNumTransmogSources();
				for i = 1, numSources do
					info.text = DB.setSources.sourceType[i];
					info.func = function(_, _, _, value)
								DP:C_SetSourceTypeFilter(i, value);
								SM.OutfitsCollectionFrame:Refresh()
							end
					info.checked = function() return not DP:C_IsSourceTypeFilterChecked(i) end;
					UIDropDownMenu_AddButton(info, level);
				end
			elseif (UIDROPDOWNMENU_MENU_VALUE == 2) then
				local refreshLevel = 2--atTransmogrifier and 1 or 2;
				info.hasArrow = false;
				info.isNotRadio = true;
				info.notCheckable = true;

				info.text = CHECK_ALL
				info.func = function()
								DP:C_SetAllExpansionFilters(true);
								UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
								SM.OutfitsCollectionFrame:Refresh()
							end
				UIDropDownMenu_AddButton(info, level)

				info.text = UNCHECK_ALL
				info.func = function()
								DP:C_SetAllExpansionFilters(false);
								UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
								SM.OutfitsCollectionFrame:Refresh()
							end
				UIDropDownMenu_AddButton(info, level)
				info.notCheckable = false;

				local numSources = DP:C_GetNumTransmogExpansions();
				for i = 1, numSources do
					info.text = DB.setSources[i];
					info.func = function(_, _, _, value)
								DP:C_SetExpansionFilter(i, value);
								SM.OutfitsCollectionFrame:Refresh()
							end
					info.checked = function() return not DP:C_IsExpansionFilterChecked(i) end;
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
	end
end

-- Initializes favorite dropdown menu for the appearance tab
--
-- Arguments
-- self Frame to initialize dropdown in
-- Returns
-- None
local function MyWardrobeSetsCollectionScrollFrame_FavoriteDropDownInit(self)
	if ( not self.baseSetID ) then
		return;
	end

	local baseSet = DP:GetBaseSetByID(self.baseSetID);
	local variantSets = DP:GetVariantSets(self.baseSetID);
	local useDescription = (#variantSets > 0);

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.disabled = nil;

	if ( baseSet.favoriteSetID ) then
		if ( useDescription ) then
			local setInfo = DP:C_GetSetInfo(baseSet.favoriteSetID);
			info.text = format(TRANSMOG_SETS_UNFAVORITE_WITH_DESCRIPTION, setInfo.description);
		else
			info.text = BATTLE_PET_UNFAVORITE;
		end
		info.func = function()
			DP:C_SetIsFavorite(baseSet.favoriteSetID, nil);
			_G["OutfitsCollectionFrame"].ScrollFrame:Update()
		end
	else
		local targetSetID = OutfitsCollectionFrame:GetDefaultSetIDForBaseSet(self.baseSetID);
		if ( useDescription ) then
			local setInfo = DP:C_GetSetInfo(targetSetID);
			info.text = format(TRANSMOG_SETS_FAVORITE_WITH_DESCRIPTION, setInfo.description);
		else
			info.text = BATTLE_PET_FAVORITE;
		end
		info.func = function()
			DP:C_SetIsFavorite(targetSetID, true);
			_G["OutfitsCollectionFrame"].ScrollFrame:Update()
		end
	end

	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;

	info.text = CANCEL;
	info.func = nil;
	UIDropDownMenu_AddButton(info, level);
end

----------------------------------------------------------------------------------------------------------
-- Appearances collection tab ScrollFrame
----------------------------------------------------------------------------------------------------------

ScrollFrameMixin = {}

-- Adding some event Mixins from Blizzard. 
-- This is run in init.lua SM:OnEnable
-- to populate the Mixin table before frame creation.
function ScrollFrameMixin:AddBlizzardMixins()
	Mixin(self, {
		OnShow = WardrobeSetsCollectionScrollFrameMixin.OnShow,
		OnHide = WardrobeSetsCollectionScrollFrameMixin.OnHide,
		OnEvent = WardrobeSetsCollectionScrollFrameMixin.OnEvent
		})
end

function ScrollFrameMixin:OnLoad()
	UIDropDownMenu_Initialize(self.FavoriteDropDown, MyWardrobeSetsCollectionScrollFrame_FavoriteDropDownInit, "MENU");
end

-- Dummy function getting replaced OnLoad
function ScrollFrameMixin:OnShow()
	WardrobeSetsCollectionScrollFrameMixin.OnShow(self);
end

-- Dummy function getting replaced OnLoad
function ScrollFrameMixin:OnHide()
	WardrobeSetsCollectionScrollFrameMixin.OnHide(self);
end

-- Dummy function getting replaced OnLoad
function ScrollFrameMixin:OnEvent()
	WardrobeSetsCollectionScrollFrameMixin.OnEvent(self);
end

-- Updates the buttons showing set names and icons in the ScrollFrame
function ScrollFrameMixin:Update()
	local offset = HybridScrollFrame_GetOffset(self);
	local buttons = self.buttons;
	local baseSets = DP:GetBaseSets();

	local currentSelectedSetID = self:GetParent():GetSelectedSetID()
	local selectedBaseSetID = currentSelectedSetID and DP:C_GetBaseSetID(currentSelectedSetID)


	for i = 1, #buttons do
		local button = buttons[i];
		local setIndex = i + offset;
		if (setIndex <= #baseSets) then
			local baseSet = baseSets[setIndex];
			button:Show();
			button.Name:SetText(baseSet.name);
			local topSourcesCollected, topSourcesTotal = DP:GetSetSourceTopCounts(baseSet.setID);
			local setCollected = (topSourcesCollected == topSourcesTotal);
			local color = IN_PROGRESS_FONT_COLOR;
			if ( setCollected ) then
				color = NORMAL_FONT_COLOR;
			elseif ( topSourcesCollected == 0 ) then
				color = GRAY_FONT_COLOR;
			end
			button.Name:SetTextColor(color.r, color.g, color.b);
			button.Label:SetText(U:CreateSetLabel(baseSet));
			button.Icon:SetTexture(DP:GetIconForSet(baseSet.setID));
			button.Icon:SetDesaturation((topSourcesCollected == 0) and 1 or 0);
			button.SelectedTexture:SetShown(baseSet.setID == selectedBaseSetID);
			button.Favorite:SetShown(baseSet.favoriteSetID);
			button.New:SetShown(DP:IsBaseSetNew(baseSet.setID));
			button.setID = baseSet.setID;

			if ( topSourcesCollected == 0 or setCollected ) then
				button.ProgressBar:Hide();
			else
				button.ProgressBar:Show();
				button.ProgressBar:SetWidth(SET_PROGRESS_BAR_MAX_WIDTH * topSourcesCollected / topSourcesTotal);
			end
			button.IconCover:SetShown(not setCollected);
		else
			button:Hide();
		end
	end

	local extraHeight = (self.largeButtonHeight and self.largeButtonHeight - U.BASE_SET_BUTTON_HEIGHT) or 0;
	local totalHeight = #baseSets * U.BASE_SET_BUTTON_HEIGHT + extraHeight;
	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
end

----------------------------------------------------------------------------------------------------------
-- Appearances collection tab Model Frame 
----------------------------------------------------------------------------------------------------------

SetMasterSetsModelMixin = {};

function SetMasterSetsModelMixin:OnLoad()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:FreezeAnimation(0, 0, 0);
	self:SetAutoDress(false)
	self:SetUnit("player")
	self:UpdatePanAndZoomModelType();
	self:SetLight(true, false, -1, 0, 0, .7, .7, .7, .7, .6, 1, 1, 1)
	local x, y, z = self:TransformCameraSpaceToModelSpace(0, 0, -0.25);
	self:SetPosition(x, y, z);
	self:RefreshCameras()
end

-- Using Blizzard's own model control functions.
-- This is run in init.lua SM:OnEnable
-- to populate the Mixin table before frame creation.
function SetMasterSetsModelMixin:AddBlizzardMixins()
	Mixin(self, {
		UpdatePanAndZoomModelType = WardrobeSetsDetailsModelMixin.UpdatePanAndZoomModelType,
		GetPanAndZoomLimits = WardrobeSetsDetailsModelMixin.GetPanAndZoomLimits,
		OnUpdate = WardrobeSetsDetailsModelMixin.OnUpdate,
		OnMouseDown = WardrobeSetsDetailsModelMixin.OnMouseDown,
		OnMouseUp = WardrobeSetsDetailsModelMixin.OnMouseUp,
		OnModelLoaded = WardrobeSetsDetailsModelMixin.OnModelLoaded,
		OnMouseWheel = WardrobeSetsDetailsModelMixin.OnMouseWheel
		})
end

-- Dummy function getting replaced OnLoad
function SetMasterSetsModelMixin:OnUpdate()
	WardrobeSetsDetailsModelMixin.OnUpdate(self);
end

-- Dummy function getting replaced OnLoad
function SetMasterSetsModelMixin:OnMouseDown()
	WardrobeSetsDetailsModelMixin.OnMouseDown(self);
end

-- Dummy function getting replaced OnLoad
function SetMasterSetsModelMixin:OnMouseUp()
	WardrobeSetsDetailsModelMixin.OnMouseUp(self);
end

-- Dummy function getting replaced OnLoad
function SetMasterSetsModelMixin:OnModelLoaded()
	WardrobeSetsDetailsModelMixin.OnModelLoaded(self);
end

-- Dummy function getting replaced OnLoad
function SetMasterSetsModelMixin:OnMouseWheel()
	WardrobeSetsDetailsModelMixin.OnMouseWheel(self);
end

function SetMasterSetsModelMixin:RefreshCameras()
	if ( self:IsShown() ) then
		local detailsCameraID, transmogCameraID = C_TransmogSets.GetCameraIDs();
		local model = self;
		self:RefreshCamera();
		Model_ApplyUICamera(self, detailsCameraID);
		if ( model.cameraID ~= detailsCameraID ) then
			model.cameraID = detailsCameraID;
			model.defaultPosX, model.defaultPosY, model.defaultPosZ, model.yaw = GetUICameraInfo(detailsCameraID);
		end
	end
end

----------------------------------------------------------------------------------------------------------
-- Appearances Collection tab Mixin
----------------------------------------------------------------------------------------------------------

ExtSetsCollectionMixin = {};

function ExtSetsCollectionMixin:OnEvent(event, ...)
	print("Event Triggered:", event, "Args:", ...)
	if ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		for itemFrame in self.DetailsFrame.itemFramesPool:EnumerateActive() do
			if ( itemFrame.itemID == itemID ) then
				self:SetItemFrameQuality(itemFrame);
				break;
			end
		end
	elseif ( event == "TRANSMOG_COLLECTION_ITEM_UPDATE" ) then
		for itemFrame in self.DetailsFrame.itemFramesPool:EnumerateActive() do
			self:SetItemFrameQuality(itemFrame);
		end
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED" ) then
		DP:ClearSets();
		self:Refresh();
		if(self:IsShown()) then
			self:UpdateProgressBar();
		end
		--self:ClearLatestSource();
	elseif (event == "TRANSMOG_COLLECTION_SOURCE_ADDED") then
		print("A new item was added: ", ...)
	end
end

function ExtSetsCollectionMixin:OnShow()
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
	self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED");

	if (not self.init) then
		self.init = true;
		self.selectedVariantSets = {}
		if (self.baseSets and self.baseSets[1]) then
			self:SelectSet(self:GetDefaultSetIDForBaseSet(baseSets[1].setID));
		end
	else
		self:Refresh();
	end

	if (not self.selectedSetID) then
		self.selectedSetID = self:GetDefaultSetIDForBaseSet(DP:GetBaseSets()[1].setID)
	end
	self:UpdateProgressBar()
	self.ScrollFrame:Update()
	self.ScrollFrame.update = self.ScrollFrame.Update
	self:DisplaySet(self:GetSelectedSetID())

end

function ExtSetsCollectionMixin:UpdateProgressBar()
	WardrobeCollectionFrame_UpdateProgressBar(DP:C_GetBaseSetsCounts());
end

-- Is replaced by the Blizz function OnLoad, but needs to be here for other OnLoad functions.
function ExtSetsCollectionMixin:GetSelectedSetID()
	WardrobeSetsCollectionMixin.GetSelectedSetID(self);
end

-- To save coding effort and avoid having to duplicate Blizzard code, we're adding
-- Blizzard's mixins where we just need the same code.
-- This is run in init.lua SM:OnEnable
-- to populate the Mixin table before frame creation.
function ExtSetsCollectionMixin:AddBlizzardMixins()
	Mixin(self, {
		SelectSetFromButton = WardrobeSetsCollectionMixin.SelectSetFromButton,
		Refresh = WardrobeSetsCollectionMixin.Refresh,
		GetSelectedSetID = WardrobeSetsCollectionMixin.GetSelectedSetID,
		SetAppearanceTooltip = WardrobeSetsCollectionMixin.SetAppearanceTooltip,
		SetItemFrameQuality = WardrobeSetsCollectionMixin.SetItemFrameQuality,
		CanHandleKey = WardrobeSetsCollectionMixin.CanHandleKey,
		})
end

-- Handles keypresses for up and down 
function ExtSetsCollectionMixin:HandleKey(key)
	if ( not self:GetSelectedSetID() ) then
		return false;
	end
	local selectedSetID = DP:C_GetBaseSetID(self:GetSelectedSetID());
	local _, index = DP:GetBaseSetByID(selectedSetID);
	if ( not index ) then
		return;
	end
	if ( key == WARDROBE_DOWN_VISUAL_KEY ) then
		index = index + 1;
	elseif ( key == WARDROBE_UP_VISUAL_KEY ) then
		index = index - 1;
	end
	local sets = DP:GetBaseSets();
	index = Clamp(index, 1, #sets);
	self:SelectSet(self:GetDefaultSetIDForBaseSet(sets[index].setID));
	self:ScrollToSet(sets[index].setID);
end

-- Scrolls to the selected set
function ExtSetsCollectionMixin:ScrollToSet(setID)
	local totalHeight = 0;
	local scrollFrameHeight = self.ScrollFrame:GetHeight();
	local buttonHeight = self.ScrollFrame.buttonHeight;
	for i, set in ipairs(DP:GetBaseSets()) do
		if ( set.setID == setID ) then
			local offset = self.ScrollFrame.scrollBar:GetValue();
			if ( totalHeight + buttonHeight > offset + scrollFrameHeight ) then
				offset = totalHeight + buttonHeight - scrollFrameHeight;
			elseif ( totalHeight < offset ) then
				offset = totalHeight;
			end
			self.ScrollFrame.scrollBar:SetValue(offset, true);
			break;
		end
		totalHeight = totalHeight + buttonHeight;
	end
end

function ExtSetsCollectionMixin:OnSearchUpdate()
	DP:SetSearch(WardrobeCollectionFrameSearchBox:GetText())
	if ( self.init ) then
		DP:ClearBaseSets();
		DP:ClearVariantSets();
		DP:ClearUsableSets();
		self:Refresh();
	end
end

function ExtSetsCollectionMixin:DisplaySet(setID)
	local setInfo = (setID and DP:C_GetSetInfo(setID)) or nil;
	if (not setInfo) then
		self.DetailsFrame:Hide();
		self.Model:Hide();
		return;
	else
		self.DetailsFrame:Show();
		self.Model:Show();
	end
	-- Used for debugging new sets added to the DB.
	DB.GetAppearanceGroups(setID)

	self.DetailsFrame.Name:SetText(setInfo.name);
	if (self.DetailsFrame.Name:IsTruncated() ) then
		self.DetailsFrame.Name:Hide();
		self.DetailsFrame.LongName:SetText(setInfo.name);
		self.DetailsFrame.LongName:Show();
	else
		self.DetailsFrame.Name:Show();
		self.DetailsFrame.LongName:Hide();
	end

	local label = U:CreateSetLabel(setInfo)
	self.DetailsFrame.Label:SetText(label);
	self.DetailsFrame.LimitedSet:SetShown(setInfo.limitedTimeSet);

	self.DetailsFrame.itemFramesPool:ReleaseAll();
	self.Model:Undress();
	local sources = DP:GetSortedSetSources(setID)

	local BUTTON_SPACE = 37;
	local xOffset = -floor((#sources - 1) * BUTTON_SPACE / 2);
	for i = 1, #sources do
		local itemFrame = self.DetailsFrame.itemFramesPool:Acquire();
		itemFrame.sourceID = sources[i].sourceID;
		local sourceInfo = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID)
		itemFrame.itemID = sourceInfo.itemID
		itemFrame.collected = sourceInfo.isCollected
		itemFrame.invType = sourceInfo.invType
		local texture = C_TransmogCollection.GetSourceIcon(sources[i].sourceID)
		itemFrame.Icon:SetTexture(texture);
		if ( sourceInfo.isCollected ) then
			itemFrame.Icon:SetDesaturated(false);
			itemFrame.Icon:SetAlpha(1);
			itemFrame.IconBorder:SetDesaturation(0);
			itemFrame.IconBorder:SetAlpha(1);

			local transmogSlot = C_Transmog.GetSlotForInventoryType(itemFrame.invType);
			if ( DP:C_SetHasNewSourcesForSlot(setID, transmogSlot) ) then
				itemFrame.New:Show();
				itemFrame.New.Anim:Play();
			else
				itemFrame.New:Hide();
				itemFrame.New.Anim:Stop();
			end
		else
			itemFrame.Icon:SetDesaturated(true);
			itemFrame.Icon:SetAlpha(0.3);
			itemFrame.IconBorder:SetDesaturation(1);
			itemFrame.IconBorder:SetAlpha(0.3);
			itemFrame.New:Hide();
		end

		self:SetItemFrameQuality(itemFrame)
		itemFrame:SetPoint("TOP", self.DetailsFrame, "TOP", xOffset + (i - 1) * BUTTON_SPACE, -94);
		itemFrame:Show();
		self.Model:TryOn(sources[i].sourceID);
	end

	local baseSetID = DP:C_GetBaseSetID(setID)
	local variantSets = DP:GetVariantSets(baseSetID)
	if(#variantSets<2) then
		self.DetailsFrame.VariantSetButton:Hide()
	else
		self.DetailsFrame.VariantSetButton:Show()
		self.DetailsFrame.VariantSetButton:SetText(setInfo.description)
	end
end

function ExtSetsCollectionMixin:OpenVariantSetsDropDown()
	local selectedSetID = self:GetSelectedSetID();
	if ( not selectedSetID ) then
		return;
	end
	local info = UIDropDownMenu_CreateInfo();
	local baseSetID = DP:C_GetBaseSetID(selectedSetID);
	local variantSets = DP:GetVariantSets(baseSetID);

	for i = 1, #variantSets do
		local variantSet = variantSets[i];
		local numSourcesCollected, numSourcesTotal = DP:GetSetSourceCounts(variantSet.setID);
		local colorCode = U.IN_PROGRESS_FONT_COLOR_CODE;
		if ( numSourcesCollected == numSourcesTotal ) then
			colorCode = NORMAL_FONT_COLOR_CODE;
		elseif ( numSourcesCollected == 0 ) then
			colorCode = GRAY_FONT_COLOR_CODE;
		end
		info.text = format(ITEM_SET_NAME, variantSet.description..colorCode, numSourcesCollected, numSourcesTotal);
		info.checked = (variantSet.setID == selectedSetID);
		info.func = function() self:SelectSet(variantSet.setID); end;
		UIDropDownMenu_AddButton(info);
	end
end

function ExtSetsCollectionMixin:GetDefaultSetIDForBaseSet(baseSetID)
	if (not baseSetID) then
		print("No baseSetID")
	end
	if ( self.selectedVariantSets[baseSetID] ) then
		return self.selectedVariantSets[baseSetID];
	end

	local baseSet = DP:GetBaseSetByID(baseSetID);
	if ( baseSet.favoriteSetID ) then
		return baseSet.favoriteSetID;
	end

	local highestCount = 0;
	local highestCountFinished = 0;
	local highestCountSetID;
	local variantSets = DP:GetVariantSets(baseSetID);
	for i = 1, #variantSets do
		local variantSetID = variantSets[i].setID;
		local numCollected, numTotal = DP:GetSetSourceCounts(variantSetID);
		if (numCollected == numTotal and numCollected > highestCountFinished) then
			highestCount = numCollected;
			highestCountFinished = numCollected;
			highestCountSetID = variantSetID;
		elseif (numCollected > 0 and numCollected >= highestCount and highestCountFinished == 0) then
			highestCount = numCollected;
			highestCountSetID = variantSetID;
		end
	end
	return highestCountSetID or baseSetID;
end

function ExtSetsCollectionMixin:SelectSet(setID)
	self.selectedSetID = setID;

	local baseSetID = DP:C_GetBaseSetID(setID);
	local variantSets = DP:GetVariantSets(baseSetID);
	if ( #variantSets > 0 ) then
		self.selectedVariantSets[baseSetID] = setID;
	end

	self:Refresh();
end

function ExtSetsCollectionMixin:RefreshAppearanceTooltip()
	if ( not self.tooltipTransmogSlot ) then
		return;
	end

	local sources = DP:C_GetSourcesForSlot(self:GetSelectedSetID(), self.tooltipTransmogSlot);

	if ( #sources == 0 ) then
		-- can happen if a slot only has HiddenUntilCollected sources
		local sourceInfo = C_TransmogCollection.GetSourceInfo(self.tooltipPrimarySourceID);
		if (sourceInfo) then
			tinsert(sources, sourceInfo);
		end
	end
	WardrobeCollectionFrame_SortSources(sources, sources[1].visualID, self.tooltipPrimarySourceID);
	WardrobeCollectionFrame_SetAppearanceTooltip(self, sources, self.tooltipPrimarySourceID);
end
