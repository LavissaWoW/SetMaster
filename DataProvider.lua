-----------------------
-- Namespaces
-----------------------
local SM, DB, DP, L, U = unpack(select(2, ...))

local SetsDataProvider = DP

-- Adding blizzard Mixins to reduce code maintenance
function SetsDataProvider:AddBlizzardMixins()
	Mixin(self, {
		GetBaseSetByID = WardrobeSetsDataProviderMixin.GetBaseSetByID,
		GetSetSources = WardrobeSetsDataProviderMixin.GetSetSources,
		GetSetSourceCounts = WardrobeSetsDataProviderMixin.GetSetSourceCounts,
		GetSetSourceTopCounts = WardrobeSetsDataProviderMixin.GetSetSourceTopCounts,
		ClearSets = WardrobeSetsDataProviderMixin.ClearSets,
		ClearBaseSets = WardrobeSetsDataProviderMixin.ClearBaseSets,
		ClearVariantSets = WardrobeSetsDataProviderMixin.ClearVariantSets,
		ClearUsableSets = WardrobeSetsDataProviderMixin.ClearUsableSets,
		GetIconForSet = WardrobeSetsDataProviderMixin.GetIconForSet,
		GetSortedSetSources = WardrobeSetsDataProviderMixin.GetSortedSetSources,
		ResetBaseSetNewStatus = WardrobeSetsDataProviderMixin.ResetBaseSetNewStatus,
		GetIconForSet = WardrobeSetsDataProviderMixin.GetIconForSet,
		DetermineFavorites = WardrobeSetsDataProviderMixin.DetermineFavorites,
		RefreshFavorites = WardrobeSetsDataProviderMixin.RefreshFavorites,
		});
end

function SetsDataProvider:SortSets(sets, reverseUIOrder, IgnorePatchID)
	local comparison = function(set1, set2)
		local groupFavorite1 = set1.favoriteSetID and true;
		local groupFavorite2 = set2.favoriteSetID and true;
		if ( groupFavorite1 ~= groupFavorite2 ) then
			return groupFavorite1;
		end
		if ( set1.favorite ~= set2.favorite ) then
			return set1.favorite;
		end
		if ( set1.expansionID ~= set2.expansionID ) then
			return set1.expansionID > set2.expansionID;
		end
	end

	table.sort(sets, comparison)
end

function SetsDataProvider:OnLoad()
	self.playerClass = select(3, UnitClass("player"));
	self.playerLevel = UnitLevel("player");
	self.armorType = DB.classes[self.playerClass].armor;
	self.filters = {};
	self.filters.sourceType = {};
	self.filters.expansion = {};
	self:GetBaseSets();
	self:CreateItemIndex();
end

function SetsDataProvider:CreateItemIndex()
	self.itemToSetList = {};
	self.newSetStatusList = {};
	
	local sets = self:GetBaseSets();
	local count = 0;
	for _, set in pairs(sets) do
		local variantSets = self:GetVariantSets(set.setID)
		for _, variant in pairs(variantSets) do
			for _, slot in pairs(variant.items) do
				for _, item in pairs(slot) do
					if self.itemToSetList[item] then
						tinsert(self.itemToSetList[item], variant.setID);
					else
						count = count + 1;
						self.itemToSetList[item] = {variant.setID};
					end
				end
			end
		end
	end
	print("Number of items:", count);
end

function SetsDataProvider:NewSourceAdded(sourceID)
	local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
	local setIDs = self.itemToSetList[sourceInfo.itemID];
	if (setIDs) then
		for _, id in pairs(setIDs) do
			local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType)
			if (not self.newSetStatusList[id]) then
				self.newSetStatusList[id] = {};
			end
			self.newSetStatusList[id][slot] = true;
		end
	end

end

function SetsDataProvider:GetBaseSets()
	if (not self.baseSets) then
		self.baseSets = self:C_GetBaseSets();
		self:DetermineFavorites();
		self:SortSets(self.baseSets);
	end
	return self.baseSets;
end

-- GetBaseSetByID reused from Blizzard's code.

-- Used for transmog tab. 
function SetsDataProvider:GetUsableSets()
	if (not self.usableSets) then
		self.usableSets = self:C_GetUsableSets();
		self:SortSets(self.usableSets);

		for i, set in ipairs(self.usableSets) do
			if (false) then -- TODO: Implement favorites
				local baseSetID = set.baseSetID or base.setID;
				local numRelatedSets = 0;
				for j = i + 1, #self.usableSets do
					if (self.usableSets[j].baseSetID == baseSetID or self.usableSets[j].setID == baseSetID) then
						numRelatedSets = numRelatedSets + 1;

						if (j ~= i + numRelatedSets) then
							local relatedSet = self.usableSets[j];
							tremove(self.usableSets, j);
							tinsert(self.usableSets, i + numRelatedSets, relatedSet)
						end
					end
				end
			end
		end
	end
	return self.usableSets
end

function SetsDataProvider:GetVariantSets(baseSetID)
	if (not self.variantSets) then
		self.variantSets = {}
	end

	local variantSets = self.variantSets[baseSetID]
	if (not variantSets) then
		variantSets = self:C_GetVariantSets(baseSetID)
		self.variantSets[baseSetID] = variantSets
	
		if(#variantSets > 0) then
			local baseSet = self:GetBaseSetByID(baseSetID)
			if (baseSet) then
				tinsert(variantSets, baseSet)
			end
			local reverseUIOrder = true;
			local ignorePatchID = true;
			self:SortSets(variantSets, reverseUIOrder, ignorePatchID);
		end
	end
	return variantSets
end

function SetsDataProvider:GetSetSourceData(setID)
	if ( not self.sourceData ) then
		self.sourceData = { };
	end

	local sourceData = self.sourceData[setID];
	if (not sourceData) then
		local sources = self:C_GetSetSources(setID);
		local numCollected = 0;
		local numTotal = 0;

		for sourceID, collected in pairs(sources) do
			if (collected) then
				numCollected = numCollected + 1;
			end
			numTotal = numTotal + 1;
		end
		sourceData = { numCollected = numCollected, numTotal = numTotal, sources = sources};
		self.sourceData[setID] = sourceData;
	end
	return sourceData;
end

-- GetSetSources(setID) reused from Blizzard's code.
-- GetSetSourceCounts(setID) reused from Blizzard's code.

function SetsDataProvider:GetBaseSetData(setID)
	if ( not self.baseSetsData ) then
		self.baseSetsData = { };
	end

	if ( not self.baseSetsData[setID] ) then
		local baseSetID = self:C_GetBaseSetID(setID);
		if ( baseSetID ~= setID ) then
			return;
		end

		local topCollected, topTotal = self:GetSetSourceCounts(setID);
		local variantSets = self:GetVariantSets(setID);
		for i = 1, #variantSets do
			local numCollected, numTotal = self:GetSetSourceCounts(variantSets[i].setID);
			-- This part is modified from Blizzard's code due to out sets varying in size
			if ( numCollected > topCollected and topCollected ~= topTotal) then
				topCollected = numCollected;
				topTotal = numTotal;
			elseif (numCollected == numTotal) then
				topCollected = numCollected;
				topTotal = numTotal;
			end
		end
		local setInfo = { topCollected = topCollected, topTotal = topTotal, completed = (topCollected == topTotal) };
		self.baseSetsData[setID] = setInfo;
	end
	return self.baseSetsData[setID];
end

-- GetSetSourceTopCounts(setID) reused from Blizzard's code.

function SetsDataProvider:IsBaseSetNew(baseSetID)
	local baseSetData = self:GetBaseSetData(baseSetID)
	if ( not baseSetData.newStatus ) then
		local newStatus = self:C_SetHasNewSources(baseSetID);
		if ( not newStatus ) then
			-- check variants
			local variantSets = self:GetVariantSets(baseSetID);
			for i, variantSet in ipairs(variantSets) do
				if ( self:C_SetHasNewSources(variantSet.setID) ) then
					print("Has new")
					newStatus = true;
					break;
				end
			end
		end
		baseSetData.newStatus = newStatus;
	end
--	print("setID", baseSetID, baseSetData.newStatus)
	return baseSetData.newStatus;
end

function SetsDataProvider:SetSearch(query)
	if (query == "") then
		self.filters.search = nil
	else
		self.filters.search = query
	end
end

-- ResetBaseSetNewStatus(baseSetID) reused from Blizzard's code.
-- GetSortedSetSources(setID) reused from Blizzard's code.
-- ClearSets() reused from Blizzard's code.
-- ClearBaseSets() reused from Blizzard's code.
-- ClearVariantSets() reused from Blizzard's code.
-- ClearUsableSets() reused from Blizzard's code.
-- GetIconForSet(setID) reused from Blizzard's code.
-- DetermineFavorites() reused from Blizzard's code.
-- RefreshFavorites() reused from Blizzard's code.


-- Set data is not fetched from Blizzard, so we create some custom functions in place of Blizzard's API

-- Replaces Blizzard's C_TransmogSets.GetBaseSets()
function SetsDataProvider:C_GetBaseSets()
	local baseSets = {}
	if (WardrobeCollectionFrame:IsShown()) then
		print(C_TransmogCollection.IsSearchInProgress(WardrobeCollectionFrame.activeFrame.searchType))
	end
	for _, set in pairs(DB.allSets) do
		if ((set.setID and not set.baseSetID) and set.armorType == self.armorType) then
			if (SM.db.char.favorites[set.setID]) then
				set.favorite = true;
			end

			-- Filtering base sets based on user chosen filters
			local filtered = false
			for idx, srcType in ipairs(set.sourceTypes) do
				if (self.filters.sourceType[srcType]) then
					filtered = true
				end
			end
			if self.filters.expansion[set.expansionID] then
				filtered = true
			end

			local baseSetData = self:GetBaseSetData(set.setID)
			if (baseSetData.completed) then
				if(self.filters[U.SM_COLLECTED_FILTER]) then
					filtered = true
				end
			else
				if(self.filters[U.SM_UNCOLLECTED_FILTER]) then
					filtered = true
				end
			end

			-- Search filtering
			if (self.filters.search) then
				local searched = self.filters.search
				if (not string.match(set.name:lower(), searched:lower())) then
					filtered = true
				end
			end

			if (not filtered) then
				tinsert(baseSets, set);
			end
		end
	end
	return baseSets
end

function SetsDataProvider:C_GetVariantSets(baseSetID)
	local variantSets = {};
	for _, set in pairs(DB.allSets) do
		if (set.baseSetID == baseSetID) then
			if (SM.db.char.favorites[set.setID]) then
				set.favorite = true;
			end
			tinsert(variantSets, set);
		end
	end
	return variantSets;
end


-- Replaces Blizzard's C_TransmogSets.GetBaseSetID(setID)
function SetsDataProvider:C_GetBaseSetID(id)
	local set = DB.allSets[id]
	return set.baseSetID or set.setID
end

function SetsDataProvider:C_GetSetInfo(id)
	return DB.allSets[id]
end

-- Replaces Blizzard's C_TransmogSets.GetSetSources(setID)
function SetsDataProvider:C_GetSetSources(setID)
	local setSources = {}

	local set = DB.allSets[setID]
	if (set.setID == setID) then 
		local items = set.items
		for idx, itemSlot in pairs(items) do
			for itemNum, item in pairs(itemSlot) do
				local itemId, itemMod = strsplit(":", item)
				local appearance, source = C_TransmogCollection.GetItemInfo(itemId, true and itemMod or set.modID)
				if (source) then
					local sourceInfo = C_TransmogCollection.GetSourceInfo(source)
					if (sourceInfo.isCollected) then
						tinsert(setSources, source, sourceInfo.isCollected)
						break
					else
						if (itemNum == #itemSlot) then
							tinsert(setSources, source, sourceInfo.isCollected)
						end
					end
				end
			end
		end
	end
	return setSources
end

-- Replaces Blizzard's function C_TransmogSets.GetUsableSets()
function SetsDataProvider:C_GetUsableSets()
	local returnSets = {}

	for idx, set in pairs(DB.allSets) do
		if (set.armorType == DB.classes[self.playerClass].armor and set.minRequiredLevel <= self.playerLevel) then
			if(set.requiredClassMask) then
				local correctClass = bit.band(bit.lshift(1, self.playerClass), set.requiredClassMask)
				if(correctClass) then
					tinsert(returnSets, set)
				end
			else
				tinsert(returnSets, set)
			end
		end
	end
	return returnSets;
end

function SetsDataProvider:C_GetSourcesForSlot(setID, slot)
	local set = DB.allSets[setID]
	local item = set.items[slot]
	-- Caller referenced a slot not present in the set
	if (not item) then
		return
	end
	local appearance
	local mod = set.modID
	for i = 1, #item do
		appearance = C_TransmogCollection.GetItemInfo(item[i], mod)
		if (appearance) then
			break
		end
	end
	local sources = C_TransmogCollection.GetAppearanceSources(appearance)

	return sources or {}
end

function SetsDataProvider:C_SetHasNewSources(setID)
	if (self.newSetStatusList[setID]) then
		return true
	end
end

function SetsDataProvider:C_SetHasNewSourcesForSlot(setID, transmogSlot)
	if (self.newSetStatusList[setID]) then
		return self.newSetStatusList[setID][transmogSlot]
	end
end

function SetsDataProvider:C_SetIsFavorite(setID, status)
	SM.db.char.favorites[setID] = status
	local baseSet = self:GetBaseSetByID(self:C_GetBaseSetID(setID))

	baseSet.favorite = status
	if (not status) then 
		baseSet.favoriteSetID = nil
	else
		baseSet.favoriteSetID = setID
	end
end

function SetsDataProvider:C_GetBaseSetsCounts()
	local baseSets = self:GetBaseSets()

	numCollected = 0

	for _, set in pairs(baseSets) do
		local setData = self:GetBaseSetData(set.setID)
		if (setData.completed) then
			numCollected = numCollected + 1;
		end
	end

	return numCollected, #baseSets
end

function SetsDataProvider:C_SetFilter(filter, value)
	self.filters[filter] = not value
	self:ClearSets();
	self:GetBaseSets();
end

function SetsDataProvider:C_GetFilter(filter)
	return not self.filters[filter]
end

function SetsDataProvider:C_SetSourceTypeFilter(i, value)
	self.filters.sourceType[i] = not value
	self:ClearSets();
	self:GetBaseSets();
end

function SetsDataProvider:C_SetAllSourceTypeFilters(value)
	if (not self.filters.source) then
		self.filters.source = {}
	end

	for i = 1, #DB.setSources.sourceType do
		self.filters.sourceType[i] = not value
	end
	self:ClearSets();
	self:GetBaseSets();
end

function SetsDataProvider:C_GetNumTransmogSources()
	return #DB.setSources.sourceType
end

function SetsDataProvider:C_IsSourceTypeFilterChecked(i)
	return self.filters.sourceType[i]
end

function SetsDataProvider:C_SetExpansionFilter(i, value)
	if (not self.filters.expansion) then
		self.filters.expansion = {}
	end

	self.filters.expansion[i] = not value
	self:ClearSets();
	self:GetBaseSets();
end

function SetsDataProvider:C_SetAllExpansionFilters(value)
	if (not self.filters.expansion) then
		self.filters.expansion = {}
	end

	for i = 1, #DB.setSources do
		self.filters.expansion[i] = not value
	end
	self:ClearSets();
	self:GetBaseSets();
end

function SetsDataProvider:C_GetNumTransmogExpansions()
	return #DB.setSources
end

function SetsDataProvider:C_IsExpansionFilterChecked(i)
	return self.filters.expansion[i]
end

-- This function checks for differences between the addon DB and the game sources.
-- We are only interested in when the game has more sources than the addon and when
-- the addon has too many items, thus meaning it has several appearances in a slot.
-- The errors reported by this function will serve to manually correct the addon DB.
function DB.GetAppearanceGroups(setID)
	local set = SetsDataProvider:C_GetSetInfo(setID)
	local setItems = set.items

	for slot, items in pairs(setItems) do
		local sourcesList = {}
		local appearances = {num = 0}
		for i = 1, #items do
			local appearance, source = C_TransmogCollection.GetItemInfo(items[i], mod)
			if(appearance) then
				local sources = C_TransmogCollection.GetAppearanceSources(appearance)
				if not appearances[appearance] then
					tinsert(appearances, appearance, {items[i], num = 1})
					appearances.num = appearances.num + 1;
				else
					appearances[appearance].num = appearances[appearance].num + 1;
					tinsert(appearances[appearance], items[i])
				end
				tinsert(sourcesList, items[i], sources)
			end
		end
		-- All sources have been removed from the game
		if (not sourcesList[items[1]]) then
			return
		end
		if (appearances.num == 1 and #(sourcesList[items[1]]) ~= #items) then
			local numItems = #items
			local itemSources = sourcesList[items[1]]
			local numSources = #itemSources
			if (numItems > numSources) then
				-- Do nothing. Some items have been removed from the game over time.
			elseif(numSources > numItems) then
				local gameIDs = {}
				for i = 1, numSources do
					tinsert(gameIDs, itemSources[i].itemID)
				end
				local unlistedItemIDs = {}
				for _, id in pairs(gameIDs) do
					local present = false
					for _, dbID in pairs(items) do
						if (id == dbID) then
							present = true
						end
					end
					if (not present) then
						tinsert(unlistedItemIDs, id)
					end
				end
				local printString = "Blizzard has added new items for ["..set.name.." "..set.description.."] "..DB.itemSlots[slot].." slot:"
				for k, v in pairs(unlistedItemIDs) do
					printString = printString.." [Item "..v.."]"
				end
				printString = printString..". Shares appearance with [Item "..items[1].."]. Please post this to the author."
				print(printString)
			end
		elseif (appearances.num > 1) then
			print("Several ["..set.name.." "..set.description.."] "..DB.itemSlots[slot].." appearances present:")
			for id, appear in pairs(appearances) do
				local printString = ""
				if(id ~= 'num') then
					printString = printString..appear.num.." items has [Appearance "..id.."]:"
					for idx, itemID in pairs(appear) do
						if(idx ~= 'num') then
							printString = printString.." [Item "..itemID.."]"
						end
					end
				end
				print (printString)
			end
		end
	end
end
