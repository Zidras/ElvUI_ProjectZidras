local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local LSM = E.Libs.LSM
local EnchantLib = LibStub("LibGetEnchant-1.0-WrathArmory")

-- backported from WrathArmory (ElvUI Plugin for WotLK Classic): https://github.com/Repooc/ElvUI_WrathArmory
local module = PZ.WrathArmory

function module:UpdateOptions(unit, updateGems)
	if unit then
		module:UpdateInspectPageFonts(unit, updateGems)
	else
		module:UpdateInspectPageFonts('Character')
		module:UpdateInspectPageFonts('Inspect')
	end
end

local InspectItems = {
	'HeadSlot',			--1L
	'NeckSlot',			--2L
	'ShoulderSlot',		--3L
	'',					--4
	'ChestSlot',		--5L
	'WaistSlot',		--6R
	'LegsSlot',			--7R
	'FeetSlot',			--8R
	'WristSlot',		--9L
	'HandsSlot',		--10R
	'Finger0Slot',		--11R
	'Finger1Slot',		--12R
	'Trinket0Slot',		--13R
	'Trinket1Slot',		--14R
	'BackSlot',			--15L
	'MainHandSlot',		--16
	'SecondaryHandSlot',--17
	'RangedSlot',		--18
}

local whileOpenEvents = {
	UPDATE_INVENTORY_DURABILITY = true,
}

function module:CreateInspectTexture(slot, point, relativePoint, x, y, gemStep, spacing)
	local prevGem = gemStep - 1
	local texture = slot:CreateTexture()
	-- texture:Point(point, (gemStep == 1 and slot) or slot['textureSlot'..(prevGem)], relativePoint, gemStep == 1 and x or 25, y)
	texture:Point(point, (gemStep == 1 and slot) or slot['textureSlot'..prevGem], relativePoint, (gemStep == 1 and x) or spacing, (gemStep == 1 and x) or y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)

	local backdrop = CreateFrame('Frame', nil, (gemStep == 1 and slot) or slot['textureSlotBackdrop'..prevGem])
	backdrop:SetTemplate(nil, nil, true)
	backdrop:SetBackdropColor(0,0,0,0)
	backdrop:SetOutside(texture)
	backdrop:Hide()

	return texture, backdrop
end

function module:GetGemPoints(id, db)
	if not id or not db then return end
	local x, y = db.gems.xOffset, db.gems.yOffset
	local mhX, mhY = db.gems.MainHandSlot.xOffset, db.gems.MainHandSlot.yOffset
	local ohX, ohY = db.gems.SecondaryHandSlot.xOffset, db.gems.SecondaryHandSlot.yOffset
	local rX, rY = db.gems.RangedSlot.xOffset, db.gems.RangedSlot.yOffset
	local spacing = db.gems.spacing
	-- Returns point, relativeFrame, relativePoint, x, y

	if id <= 5 or (id == 9 or id == 15) then --* Left Side
		return 'BOTTOMLEFT', 'BOTTOMRIGHT', x, y, spacing
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then --* Right Side
		return 'BOTTOMRIGHT', 'BOTTOMLEFT', -x, y, -spacing
	elseif id == 16 then --* MainHandSlot
		return 'BOTTOMRIGHT', 'BOTTOMLEFT', mhX, mhY, -spacing
	elseif id == 17 then --* SecondaryHandSlot
		return 'BOTTOMRIGHT', 'TOPRIGHT', ohX, ohY, -spacing
	else --* RangedSlot
		return 'BOTTOMLEFT', 'BOTTOMRIGHT', rX, rY, spacing
	end
end

function module:GetEnchantPoints(id, db)
	if not id or not db then return end
	local x, y = db.enchant.xOffset, db.enchant.yOffset
	local mhX, mhY = db.enchant.MainHandSlot.xOffset, db.enchant.MainHandSlot.yOffset
	local ohX, ohY = db.enchant.SecondaryHandSlot.xOffset, db.enchant.SecondaryHandSlot.yOffset
	local rX, rY = db.enchant.RangedSlot.xOffset, db.enchant.RangedSlot.yOffset
	local spacing = db.enchant.spacing or 0
	-- Returns point, relativeFrame, relativePoint, x, y

	if id <= 5 or (id == 9 or id == 15) then --* Left Side
		return 'TOPLEFT', 'TOPRIGHT', x, y, spacing
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then --* Right Side
		return 'TOPRIGHT', 'TOPLEFT', -x, y, -spacing
	elseif id == 16 then --* MainHandSlot
		return 'TOPRIGHT', 'TOPLEFT', mhX, mhY, -spacing
	elseif id == 17 then --* SecondaryHandSlot
		return 'TOP', 'BOTTOM', ohX, ohY, -spacing
	else --* RangedSlot
		return 'TOPLEFT', 'TOPRIGHT', rX, rY, spacing
	end
end

function module:UpdateInspectInfo(_, arg1)
	E:Delay(0.75, function()
		if _G.InspectFrame and _G.InspectFrame:IsVisible() then
			module:UpdatePageInfo(_G.InspectFrame, 'Inspect', arg1)
		end
	end)
	module:UpdatePageInfo(_G.InspectFrame, 'Inspect', arg1)
end

function module:UpdateCharacterInfo(event)
	if (not E.db.pz.wratharmory.character.enable)
	or (whileOpenEvents[event] and not _G.CharacterFrame:IsShown()) then return end

	module:UpdatePageInfo(_G.CharacterFrame, 'Character')
end

function module:ClearPageInfo(frame, which)
	if not frame or not which then return end

	for i = 1, 18 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText('')

			for y = 1, 10 do
				inspectItem['textureSlot'..y]:SetTexture()
				inspectItem['textureSlotBackdrop'..y]:Hide()
			end
		end
	end
end

function module:ToggleArmoryInfo(setupCharacterPage)
	if setupCharacterPage then
		module:CreateSlotStrings(_G.CharacterFrame, 'Character')
	end

	if E.db.pz.wratharmory.character.enable then
		module:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'UpdateCharacterInfo')
		module:RegisterEvent('UPDATE_INVENTORY_DURABILITY', 'UpdateCharacterInfo')

		if not _G.CharacterFrame.CharacterInfoHooked then
			_G.CharacterFrame:HookScript('OnShow', function()
				module.UpdateCharacterInfo()
			end)

			_G.CharacterFrame.CharacterInfoHooked = true
		end

		if not setupCharacterPage then
			module:UpdateCharacterInfo()
		end
	else
		module:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
		module:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')

		module:ClearPageInfo(_G.CharacterFrame, 'Character')
	end

	if E.db.pz.wratharmory.inspect.enable then
		module:RegisterEvent('INSPECT_TALENT_READY', 'UpdateInspectInfo')
	else
		module:UnregisterEvent('INSPECT_TALENT_READY')
		module:ClearPageInfo(_G.InspectFrame, 'Inspect')
	end
end

function module:UpdatePageStrings(i, inspectItem, slotInfo, which)
	local db = E.db.pz.wratharmory[string.lower(which)]

	do
		local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
		inspectItem.enchantText:ClearAllPoints()
		inspectItem.enchantText:Point(point, inspectItem, relativePoint, x, y)
		inspectItem.enchantText:FontTemplate(LSM:Fetch('font', db.enchant.font), db.enchant.fontSize, db.enchant.fontOutline)
		inspectItem.enchantText:SetText(slotInfo.enchantTextShort)
		if db.enchant.enable then
			inspectItem.enchantText:Show()
		else
			inspectItem.enchantText:Hide()
		end
		local enchantTextColor = (db.enchant.qualityColor and slotInfo.itemQualityColors) or db.enchant.color
		if enchantTextColor and next(enchantTextColor) then
			inspectItem.enchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
		end
	end

	if which == 'Inspect' then
		local unit = _G.InspectFrame.unit or 'target'
		if unit then
			local itemLink = GetInventoryItemLink(unit, i)
			if itemLink then
				local _, _, quality = GetItemInfo(itemLink) -- GetInventoryItemQuality only works for player, not inspected unit, despite what it says on API documentation
				if quality and quality > 1 then
					inspectItem.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					inspectItem.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end

	do
		local point, relativePoint, x, y, spacing = module:GetGemPoints(i, db)
		local gemStep = 1
		for index = 1, 5 do
			local texture = inspectItem['textureSlot'..index]
			texture:Size(db.gems.size)
			texture:ClearAllPoints()
			texture:Point(point, (index == 1 and inspectItem) or inspectItem['textureSlot'..(index-1)], relativePoint, index == 1 and x or spacing, index == 1 and y or 0)

			local backdrop = inspectItem['textureSlotBackdrop'..index]
			local gem = slotInfo.gems and slotInfo.gems[gemStep]
			if gem then
				texture:SetTexture(gem)
				backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				backdrop:Show()

				if db.gems.enable then
					texture:Show()
					backdrop:Show()
				else
					texture:Hide()
					backdrop:Hide()
				end

				gemStep = gemStep + 1
			else
				texture:SetTexture()
				backdrop:Hide()
			end
		end
	end
end

function module:TryGearAgain(frame, which, i, inspectItem)
	E:Delay(0.05, function()
		if which == 'Inspect' and (not frame or not frame.unit) then return end

		local unit = (which == 'Character' and 'player') or frame.unit
		local slotInfo = module:GetGearSlotInfo(unit, i)
		if slotInfo == 'tooSoon' then return end

		module:UpdatePageStrings(i, inspectItem, slotInfo, which)
	end)
end

do
	function module:UpdatePageInfo(frame, which, guid)
		-- if not (which and frame and frame.ItemLevelText) then return end --for avgilvlstats window
		if not which or not frame then return end
		if which == 'Inspect' and (not frame or not frame.unit or (guid and guid ~= 'target' and frame:IsShown() and UnitGUID(frame.unit) ~= guid)) then return end

		local waitForItems
		for i = 1, 18 do
			if i ~= 4 then
				local inspectItem = _G[which..InspectItems[i]]
				inspectItem.enchantText:SetText('')

				local unit = (which == 'Character' and 'player') or frame.unit
				local slotInfo = module:GetGearSlotInfo(unit, i)
				if slotInfo == 'tooSoon' then
					if not waitForItems then waitForItems = true end
					module:TryGearAgain(frame, which, i, inspectItem)
				else
					module:UpdatePageStrings(i, inspectItem, slotInfo, which)
				end
			end
		end
	end
end


function module:CreateSlotStrings(frame, which)
	if not frame or not which then return end

	local db = E.db.pz.wratharmory[string.lower(which)]
	local enchant = db.enchant

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]

			slot.enchantText = slot:CreateFontString(nil, 'OVERLAY')
			slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
			do
				local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
				slot.enchantText:ClearAllPoints()
				slot.enchantText:Point(point, slot, relativePoint, x, y)
			end

			do
				local point, relativePoint, x, y, spacing = module:GetGemPoints(i, db)
				for u = 1, 5 do
					slot['textureSlot'..u], slot['textureSlotBackdrop'..u] = module:CreateInspectTexture(slot, point, relativePoint, x, y, u, spacing)
				end
			end
		end
	end
end

function module:SetupInspectPageInfo()
	module:CreateSlotStrings(_G.InspectFrame, 'Inspect')
end

function module:UpdateInspectPageFonts(which, gems)
	local frame = _G[which..'Frame']
	if not frame then return end

	local unit = (which == 'Character' and 'player') or frame.unit
	if not unit then return end

	local db = E.db.pz.wratharmory[string.lower(which)]
	local enchant = db.enchant

	local slot, quality, enchantTextColor
	local qualityColor = {}
	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			slot = _G[which..s]
			if slot then
				local itemLink = GetInventoryItemLink(unit, slot)
				if itemLink then
					quality = select(3, GetItemInfo(itemLink)) -- GetInventoryItemQuality only works for player, not inspected unit, despite what it says on API documentation
					if quality then
						qualityColor.r, qualityColor.g, qualityColor.b = GetItemQualityColor(quality)
					end
				end

				do
					local point, relativePoint, x, y = module:GetEnchantPoints(i, db)
					slot.enchantText:ClearAllPoints()
					slot.enchantText:Point(point, slot, relativePoint, x, y)
				end

				slot.enchantText:FontTemplate(LSM:Fetch('font', enchant.font), enchant.fontSize, enchant.fontOutline)
				enchantTextColor = (enchant.qualityColor and qualityColor) or enchant.color
				if enchantTextColor and next(enchantTextColor) then
					slot.enchantText:SetTextColor(enchantTextColor.r, enchantTextColor.g, enchantTextColor.b)
				end
				if enchant.enable then
					slot.enchantText:Show()
				else
					slot.enchantText:Hide()
				end
			end
		end
	end

	if gems then
		module:UpdatePageInfo(frame, which, unit)
	end
end

function module:ScanTooltipTextures()
	local tt = E.ScanTooltip

	if not tt.gems then
		tt.gems = {}
	else
		wipe(tt.gems)
	end

	for i = 1, 5 do
		local tex = _G['ElvUI_ScanTooltipTexture'..i]
		local texture = tex and tex:IsShown() and tex:GetTexture()
		if texture then
			tt.gems[i] = texture
		end
	end

	return tt.gems
end

function module:GetGearSlotInfo(unit, slot)
	local tt = E.ScanTooltip
	tt:SetOwner(_G.UIParent, 'ANCHOR_NONE')
	tt:SetInventoryItem(unit, slot)
	tt:Show()

	if not tt.SlotInfo then tt.SlotInfo = {} else wipe(tt.SlotInfo) end
	local slotInfo = tt.SlotInfo

	slotInfo.gems = module:ScanTooltipTextures()
	-- print('1', tt.itemQualityColors)
	-- if not tt.itemQualityColors then tt.itemQualityColors = {} else wipe(tt.itemQualityColors) end
	-- print('2', tt.itemQualityColors)

	-- slotInfo.itemQualityColors = tt.itemQualityColors
	slotInfo.itemQualityColors = slotInfo.itemQualityColors or {}

	for x = 1, tt:NumLines() do
		local line = _G['ElvUI_ScanTooltipTextLeft'..x]
		if line then
			local lineText = line:GetText()
			if x == 1 and lineText == RETRIEVING_ITEM_INFO then
				return 'tooSoon'
			end
		end
	end

	local itemLink = GetInventoryItemLink(unit, slot)
	if itemLink then
		local _, _, quality = GetItemInfo(itemLink) -- GetInventoryItemQuality only works for player, not inspected unit, despite what it says on API documentation
		slotInfo.itemQualityColors.r, slotInfo.itemQualityColors.g, slotInfo.itemQualityColors.b = GetItemQualityColor(quality)

		local enchantID = tonumber(string.match(itemLink, 'item:%d+:(%d+):'))
		if enchantID and enchantID ~= 0 then
			local enchantTextShort = EnchantLib.GetEnchant(enchantID)

			if not enchantTextShort then
				local msg = format('The enchant id, *%s|r, seems to be missing from our database and the enchant won\'t be displayed properly. Please open a ticket with the missing id and name of the enchant that found on %s.', enchantID, itemLink):gsub('*', E.InfoColor)
				PZ:Print(msg)
			end

			slotInfo.enchantTextShort = enchantTextShort or ''
		end
	end

	tt:Hide()

	return slotInfo
end

function module:ADDON_LOADED(_, addon)
	if addon == 'Blizzard_InspectUI' then
		module:SetupInspectPageInfo()
	end
end

function module:Initialize()
	if not E.db.pz.wratharmory.enable then return end

	module:ToggleArmoryInfo(true)

	if IsAddOnLoaded('Blizzard_InspectUI') then
		module:SetupInspectPageInfo()
	else
		module:RegisterEvent('ADDON_LOADED')
	end
end

E:RegisterModule(module:GetName(), module.Initialize)