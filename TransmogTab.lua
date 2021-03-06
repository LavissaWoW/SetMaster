-----------------------
-- Namespaces
-----------------------
local SM, DB, DP, L, U = unpack(select(2, ...))

SM.TransmogOutfitsCollectionMixin = {};
SM.TransmogScrollFrameMixin = {};
SetMasterTransmogScrollFrameMixin = {}
SetMasterTransmogOutfitsCollectionMixin = {}

local IN_PROGRESS_FONT_COLOR = CreateColor(0.251, 0.753, 0.251);
local EXPANDED_BUTTON_HEIGHT = 86;

function SetMasterTransmogScrollFrameMixin:AddBlizzardMixins()
	Mixin(self, {
		--OnShow = WardrobeSetsCollectionScrollFrameMixin.OnShow,
		OnHide = WardrobeSetsCollectionScrollFrameMixin.OnHide,
		OnEvent = WardrobeSetsCollectionScrollFrameMixin.OnEvent,
		SetItemFrameQuality = WardrobeSetsCollectionMixin.SetItemFrameQuality,
        SetAppearanceTooltip = WardrobeSetsCollectionMixin.SetAppearanceTooltip,
        RefreshAppearanceTooltip = ExtSetsCollectionMixin.RefreshAppearanceTooltip
		})
end

function SetMasterTransmogScrollFrameMixin:OnShow()
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");
	self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED");
    self:Update();
end

function SetMasterTransmogScrollFrameMixin:OnEvent(event)
    self:Update();
end

function SetMasterTransmogScrollFrameMixin:OnLoad()
    self.update = self.Update; -- HybridScrollFrames calls update(), and not Update()
	HybridScrollFrame_CreateButtons(self, "OutfitsTransmogFrameScrollFrameButtonTemplate2", 0, 0);
	HybridScrollFrame_SetDoNotHideScrollBar(self, true);
    for i = 1, #self.buttons do
        self.buttons[i].itemFramesPool = CreateFramePool("Frame", self.buttons[i], "WardrobeSetsDetailsItemFrameTemplate, SetMasterTransmogSetsIconFrame");
        self.buttons[i]:ToggleSelected(false);
        self.buttons[i]:ToggleTransmogged(false);
        Mixin(self.buttons[i], {SetAppearanceTooltip = WardrobeSetsCollectionMixin.SetAppearanceTooltip})
    end
end

function SetMasterTransmogScrollFrameMixin:Update()
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
            local variantSets = DP:GetVariantSets(DP:C_GetBaseSetID(baseSet.setID));
            button.baseSetID = baseSet.setID
            button.setID = self:GetParent():GetDefaultSetIDForBaseSet(baseSet.setID)
            local setInfo = DP:C_GetSetInfo(button.setID)

			local topSourcesCollected, topSourcesTotal = DP:GetSetSourceTopCounts(baseSet.setID);
			local setCollected = (topSourcesCollected == topSourcesTotal);
            local color = IN_PROGRESS_FONT_COLOR;
			if ( setCollected ) then
				color = NORMAL_FONT_COLOR;
			elseif ( topSourcesCollected == 0 ) then
				color = GRAY_FONT_COLOR;
            end

            if (baseSet.setID == selectedBaseSetID) then
                HybridScrollFrame_ExpandButton(self, ((setIndex - 1)*self.buttonHeight), EXPANDED_BUTTON_HEIGHT)
                button:Expand();
                if(#variantSets > 1) then
                    button.VariantSetsButton:Show();
                    button.VariantSetsButton:SetText(setInfo.description);
                end
                button.Variant:SetText(nil)
            else
                button.VariantSetsButton:Hide();
                button.VariantSetsButton:SetText("");
                button.Variant:SetText(#variantSets > 1 and "("..setInfo.description..")")
                button:Collapse();
            end

            button:ToggleTransmogged(baseSet.setID == selectedBaseSetID and self:GetParent():GetParent():GetParent().toTransmog == true)
            button:ToggleSelected(baseSet.setID == selectedBaseSetID);
            button:Show();
            button.Name:SetText(baseSet.name);

            button.Name:SetTextColor(color.r, color.g, color.b);
            button.Variant:SetTextColor(color.r, color.g, color.b);
            button.Variant:SetShown(baseSet.setID ~= selectedBaseSetID);

            -- Fontstring showing the number of variants the set has
            if (#variantSets > 0) then
                button.NumVariants:SetText("("..#variantSets.." variants)");
            else
                button.NumVariants:SetText("")
            end

            button.Label:SetText(U:CreateSetLabel(baseSet));
            button:DisplayItems();
        else
            button:Hide();
        end
    end

    local extraHeight = (self.largeButtonHeight and self.largeButtonHeight - U.BASE_SET_BUTTON_HEIGHT) or 0;
	local totalHeight = #baseSets * U.BASE_SET_BUTTON_HEIGHT + extraHeight;
	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
end

function SetMasterTransmogOutfitsCollectionMixin:OnLoad()
    self.searchType = U.SM_TRANSMOG_SEARCH_TYPE_OUTFITS;
    self.BGCornerTopRight:Hide();
	self.BGCornerTopLeft:Hide();
	self.BGCornerBottomRight:Hide();
	self.BGCornerBottomLeft:Hide();
    if (not self.init) then
        self.init = true;
        self.selectedVariantSets = {};
        self.toTransmog = false;
    end

end

function SetMasterTransmogOutfitsCollectionMixin:AddBlizzardMixins()
    Mixin(self, {
        RefreshCameras = WardrobeSetsTransmogMixin.RefreshCameras,
        OnUnitModelChangedEvent = WardrobeSetsTransmogMixin.OnUnitModelChangedEvent,
        GetDefaultSetIDForBaseSet = ExtSetsCollectionMixin.GetDefaultSetIDForBaseSet,
        GetSelectedSetID = WardrobeSetsCollectionMixin.GetSelectedSetID,
        SelectSet = ExtSetsCollectionMixin.SelectSet,
    })
end

function SetMasterTransmogOutfitsCollectionMixin:UpdateProgressBar()
    WardrobeCollectionFrame_UpdateProgressBar(DP:C_GetBaseSetsCounts());
end

function SetMasterTransmogOutfitsCollectionMixin:SelectSetFromButton(setID)
    CloseDropDownMenus();
    if (self.selectedSetID == setID) then
        self.toTransmog = true;
    else
        self:SelectSet(self:GetDefaultSetIDForBaseSet(setID));
    end
end

function SetMasterTransmogOutfitsCollectionMixin:Refresh()
	self.ScrollFrame:Update();
end

function TransmogItemFrame_OnEnter(self)
    self:GetParent():SetAppearanceTooltip(self);

    ItemModel = _G["SetMasterTransmogItemModelFrame"];
    ItemModel.slot = 
	self:SetScript("OnUpdate",
		function()
            if IsModifiedClick("DRESSUP") then
                ItemModel:SetFrameStrata("HIGH")
                ItemModel:EnableMouse(false)
                ItemModel:Show();
				--ShowInspectCursor();
			else
                ItemModel:Hide();
				ResetCursor();
			end
		end
    );
	if ( self.New:IsShown() ) then
		local transmogSlot = C_Transmog.GetSlotForInventoryType(self.invType);
		local setID = WardrobeCollectionFrame.SetsCollectionFrame:GetSelectedSetID();
		C_TransmogSets.ClearSetNewSourcesForSlot(setID, transmogSlot);
		local baseSetID = C_TransmogSets.GetBaseSetID(setID);
		SetsDataProvider:ResetBaseSetNewStatus(baseSetID);
		WardrobeCollectionFrame.SetsCollectionFrame:Refresh();
	end
end

function TransmogItemFrame_OnLeave(self)
    ItemModel = _G["SetMasterTransmogItemModelFrame"];
    ItemModel:Hide();
	self:SetScript("OnUpdate", nil);
	ResetCursor();
	WardrobeCollectionFrame_HideAppearanceTooltip();
end

OutfitsTransmogButtonMixin = {};

function OutfitsTransmogButtonMixin:RefreshAppearanceTooltip()
    if ( not self.tooltipTransmogSlot ) then
		return;
	end
    local sources = DP:C_GetSourcesForSlot(self.setID, self.tooltipTransmogSlot);

	if ( #sources == 0 ) then
		-- can happen if a slot only has HiddenUntilCollected sources
		local sourceInfo = C_TransmogCollection.GetSourceInfo(self.tooltipPrimarySourceID);
		if (sourceInfo) then
			tinsert(sources, sourceInfo);
		end
    end

    WardrobeCollectionFrame_SortSources(sources, nil, self.tooltipPrimarySourceID);
    WardrobeCollectionFrame_SetAppearanceTooltip(self, sources, self.tooltipPrimarySourceID);
end

function OutfitsTransmogButtonMixin:OnLoad()
    Mixin (self, {
        SetItemFrameQuality = WardrobeSetsCollectionMixin.SetItemFrameQuality
    })
end

function OutfitsTransmogButtonMixin:OnShow()
    self:RegisterEvent("MODIFIER_STATE_CHANGED")
end

function OutfitsTransmogButtonMixin:OnEvent(event, ...)
    local currentSelectedSetID = self:GetParent():GetParent():GetParent():GetSelectedSetID()
    local selectedBaseSetID = currentSelectedSetID and DP:C_GetBaseSetID(currentSelectedSetID)
    local Model = _G["SetMasterTransmogModelFrame"];
    if(GetMouseFocus() == self) then
        if(event == "MODIFIER_STATE_CHANGED") then
            local modifier, state = ...;

            if(modifier == "RCTRL" or modifier == "LCTRL") then
                Model.setID = state == 1 and self.setID;
                Model:SetShown(state == 1 and true);
            end
        end
    end
end

function OutfitsTransmogButtonMixin:OnEnter()
    local Model = _G["SetMasterTransmogModelFrame"];
    if(IsControlKeyDown()) then
        Model.setID = self.setID;
        Model:Show();
    end
end

function OutfitsTransmogButtonMixin:OnLeave()
    local Model = _G["SetMasterTransmogModelFrame"];
    --Model.setID = nil;
    Model:Hide();
end

function OutfitsTransmogButtonMixin:ToggleSelected(status)
    self.SelectedCornerTopLeft:SetShown(status)
    self.SelectedLeft:SetShown(status)
    self.SelectedCornerBottomLeft:SetShown(status)
    self.SelectedTop:SetShown(status)
    self.SelectedBottom:SetShown(status)
    self.SelectedCornerBottomRight:SetShown(status)
    self.SelectedRight:SetShown(status)
    self.SelectedCornerTopRight:SetShown(status)
end

function OutfitsTransmogButtonMixin:ToggleTransmogged(status)
    self.TMedCornerTopLeft:SetShown(status)
    self.TMedLeft:SetShown(status)
    self.TMedCornerBottomLeft:SetShown(status)
    self.TMedTop:SetShown(status)
    self.TMedBottom:SetShown(status)
    self.TMedCornerBottomRight:SetShown(status)
    self.TMedRight:SetShown(status)
    self.TMedCornerTopRight:SetShown(status)
end

function OutfitsTransmogButtonMixin:Expand()
    local largeButtonHeight = self:GetParent():GetParent().largeButtonHeight;
    self:SetHeight(largeButtonHeight)
    self.BgLeft:SetHeight(largeButtonHeight - self.BgCornerTopLeft:GetHeight() - self.BgCornerBottomLeft:GetHeight())
    self.BgRight:SetHeight(largeButtonHeight - self.BgCornerTopRight:GetHeight() - self.BgCornerBottomRight:GetHeight())
    self.SelectedLeft:SetHeight(largeButtonHeight - self.SelectedCornerTopLeft:GetHeight() - self.SelectedCornerBottomLeft:GetHeight())
    self.SelectedRight:SetHeight(largeButtonHeight - self.SelectedCornerTopRight:GetHeight() - self.SelectedCornerBottomRight:GetHeight())
    self.HoverLeft:SetHeight(largeButtonHeight - self.HoverCornerTopLeft:GetHeight() - self.HoverCornerBottomLeft:GetHeight())
    self.HoverRight:SetHeight(largeButtonHeight - self.HoverCornerTopRight:GetHeight() - self.HoverCornerBottomRight:GetHeight())
end

function OutfitsTransmogButtonMixin:Collapse()
    local buttonHeight = self:GetParent():GetParent().buttonHeight;
    self:SetHeight(buttonHeight)
    self.BgLeft:SetHeight(buttonHeight - self.BgCornerTopLeft:GetHeight() - self.BgCornerBottomLeft:GetHeight())
    self.BgRight:SetHeight(buttonHeight - self.BgCornerTopRight:GetHeight() - self.BgCornerBottomRight:GetHeight())
    self.SelectedLeft:SetHeight(buttonHeight - self.SelectedCornerTopLeft:GetHeight() - self.SelectedCornerBottomLeft:GetHeight())
    self.SelectedRight:SetHeight(buttonHeight - self.SelectedCornerTopRight:GetHeight() - self.SelectedCornerBottomRight:GetHeight())
    self.HoverLeft:SetHeight(buttonHeight - self.HoverCornerTopLeft:GetHeight() - self.HoverCornerBottomLeft:GetHeight())
    self.HoverRight:SetHeight(buttonHeight - self.HoverCornerTopRight:GetHeight() - self.HoverCornerBottomRight:GetHeight())
end

function OutfitsTransmogButtonMixin:OpenVariantSetsDropDown()
    local selectedSetID = self.setID;
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

function OutfitsTransmogButtonMixin:SelectSet(setID)

    local baseSetID = DP:C_GetBaseSetID(setID);
	local variantSets = DP:GetVariantSets(baseSetID);
	if ( #variantSets > 0 ) then
		self:GetParent():GetParent():GetParent().selectedVariantSets[baseSetID] = setID;
	end
    self:GetParent():GetParent():Update();
end

function OutfitsTransmogButtonMixin:DisplayItems()
    local currentSelectedSetID = self:GetParent():GetParent():GetParent():GetSelectedSetID()
    local selectedBaseSetID = currentSelectedSetID and DP:C_GetBaseSetID(currentSelectedSetID)
    local Model = _G["SetMasterTransmogModelFrame"];
    
    local sources = DP:GetSortedSetSources(self.setID);
    self.itemFramesPool:ReleaseAll();
    for j = 1, #sources do
        local itemFrame = self.itemFramesPool:Acquire();
        itemFrame.sourceID = sources[j].sourceID;
        local sourceInfo = C_TransmogCollection.GetSourceInfo(sources[j].sourceID);
        itemFrame.itemID = sourceInfo.itemID;
        itemFrame.collected = sourceInfo.isCollected;
        itemFrame.invType = sourceInfo.invType;
        local texture = C_TransmogCollection.GetSourceIcon(sources[j].sourceID);
        itemFrame.Icon:SetTexture(texture);
        itemFrame:Show();
        itemFrame.Red:SetShown(sourceInfo.useError ~= nil and sourceInfo.isCollected);
        itemFrame.Red:SetAlpha(0.45)
        if ( sourceInfo.isCollected ) then
            itemFrame.Icon:SetDesaturated(false);
            itemFrame.Icon:SetAlpha(1);
            itemFrame.IconBorder:SetDesaturation(0);
            itemFrame.IconBorder:SetAlpha(1);

            local transmogSlot = C_Transmog.GetSlotForInventoryType(itemFrame.invType);
            if ( DP:C_SetHasNewSourcesForSlot(self.setID, transmogSlot) ) then
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

        if (self.baseSetID ~= selectedBaseSetID) then
            itemFrame:SetScript("OnEnter", nil);
            itemFrame:EnableMouse(false)
            itemFrame:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT",  (j-1) * 20, -2);
            itemFrame:SetSize(19,19)
            itemFrame.IconBorder:ClearAllPoints();
            itemFrame.IconBorder:SetPoint("TOPLEFT", itemFrame.Icon, "TOPLEFT", -4, 4)
            itemFrame.IconBorder:SetPoint("BOTTOMRIGHT", itemFrame.Icon, "BOTTOMRIGHT", 4, -4)
            itemFrame.IconBorder:SetSize(19,19)
            itemFrame.Icon:SetSize(15, 15);
        else
            itemFrame:EnableMouse(true)
            itemFrame:SetScript("OnEnter", TransmogItemFrame_OnEnter);
            itemFrame:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT",  (j-1) * 27, -2);
            itemFrame:SetSize(26,26)
            itemFrame.IconBorder:ClearAllPoints();
            itemFrame.IconBorder:SetPoint("TOPLEFT", itemFrame.Icon, "TOPLEFT", -4, 4)
            itemFrame.IconBorder:SetPoint("BOTTOMRIGHT", itemFrame.Icon, "BOTTOMRIGHT", 4, -4)
            itemFrame.IconBorder:SetSize(26,26)
            itemFrame.Icon:SetSize(22, 22);
        end
    end
end

OutfitsTransmogButtonModelMixin = {};

function OutfitsTransmogButtonModelMixin:OnLoad()
    self:RegisterEvent("UI_SCALE_CHANGED");
    self:RegisterEvent("DISPLAY_SIZE_CHANGED");
    self:SetScript("OnEnter", nil);
    self:SetScript("OnLeave", nil);
    self:SetScript("OnHide", nil);
    self:EnableMouse(false);
    self:SetAutoDress(false);
    self.Border:ClearAllPoints();
    self.Border:SetPoint("TOPLEFT", -20, 8);
    self.Border:SetPoint("BOTTOMRIGHT", 18, -25);
	self:SetUnit("player");
    self:FreezeAnimation(0, 0, 0);
    local x, y, z = self:TransformCameraSpaceToModelSpace(0.7, 0, 0);
	self:SetPosition(x, y, z);
    self:SetLight(true, false, -1, 1, -1, 1, 1, 1, 1, 0, 1, 1, 1);
end

function OutfitsTransmogButtonModelMixin:OnEvent()
	self:RefreshCamera();
	local x, y, z = self:TransformCameraSpaceToModelSpace(0.7, 0, 0);
	self:SetPosition(x, y, z);
end

function OutfitsTransmogButtonModelMixin:OnModelLoaded()
    if ( self.cameraID ) then
		Model_ApplyUICamera(self, self.cameraID);
	end
end

function OutfitsTransmogButtonModelMixin:OnShow()
    self:SetFrameStrata("HIGH");
    local sources = DP:GetSortedSetSources(self.setID or self:GetParent().setID);
    local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition();
    
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (x / uiScale) + 2, (y / uiScale) + 2)

    for i = 1, #sources do
        self:TryOn(sources[i].sourceID)
    end
    self:RefreshCamera();
end

function OutfitsTransmogButtonModelMixin:OnUpdate()
    local uiScale, x, y = self:GetEffectiveScale(), GetCursorPosition();
    
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (x / uiScale) + 2, (y / uiScale) + 2)
end

SetMasterItemTransmogFrameMixin = {}

function SetMasterItemTransmogFrameMixin:OnShow()
	if ( self.needsReload ) then
		self:Reload(self.slot);
	end
end

function SetMasterItemTransmogFrameMixin:OnUpdate()
    local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition();
    
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (x / uiScale) + 2, (y / uiScale) + 2)

end