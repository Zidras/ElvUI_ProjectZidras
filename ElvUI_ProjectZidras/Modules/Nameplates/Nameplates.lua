local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZNP = PZ.NamePlates
local NP = E.NamePlates

local pairs = pairs
local twipe = table.wipe

local SetCVar = SetCVar
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitName = UnitName

local UnitIterator = T.UnitIterator

-- GLOBALS: hooksecurefunc

function NP:CacheArenaUnits()
	twipe(self.ENEMY_PLAYER)
	twipe(self.ENEMY_NPC)

	for i = 1, 5 do
		local unit = "arena"..i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local guid = UnitGUID(unit)
			local unitType = NP:GetUnitTypeFromUnit(unit)

			self.ENEMY_PLAYER[name] = unit

			if not self.GUIDList[guid] then
				self.GUIDList[guid] = {name, unitType}
			end

			for frame in pairs(self.VisiblePlates) do
				if frame.UnitName == name and frame.UnitType == unitType then
					frame.guid = guid
					frame.unit = unit
				end
			end
		end

		unit = "arenapet"..i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local guid = UnitGUID(unit)
			local unitType = NP:GetUnitTypeFromUnit(unit)

			self.ENEMY_NPC[name] = unit

			if not self.GUIDList[guid] then
				self.GUIDList[guid] = {name, unitType}
			end

			for frame in pairs(self.VisiblePlates) do
				if frame.UnitName == name and frame.UnitType == unitType then
					frame.guid = guid
					frame.unit = unit
				end
			end
		end
	end
end

function NP:CacheGroupUnits()
	twipe(self.FRIENDLY_PLAYER)

	for unit, owner in UnitIterator() do
		if owner == nil then -- ignore pets
			local name = UnitName(unit)
			local guid = UnitGUID(unit)
			local unitType = NP:GetUnitTypeFromUnit(unit)

			self.FRIENDLY_PLAYER[name] = unit

			if not self.GUIDList[guid] then
				self.GUIDList[guid] = {name, unitType}
			end

			for frame in pairs(self.VisiblePlates) do
				if frame.UnitName == name and frame.UnitType == unitType then
					frame.guid = guid
					frame.unit = unit
					break
				end
			end
		end
	end
end

function NP:CacheGroupPetUnits()
	twipe(self.FRIENDLY_NPC)
	twipe(self.ENEMY_NPC)

	for i = 1, 5 do
		local unit = "arenapet"..i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local guid = UnitGUID(unit)
			local unitType = NP:GetUnitTypeFromUnit(unit)

			self.ENEMY_NPC[name] = unit

			if not self.GUIDList[guid] then
				self.GUIDList[guid] = {name, unitType}
			end

			for frame in pairs(self.VisiblePlates) do
				if frame.UnitName == name and frame.UnitType == unitType then
					frame.guid = guid
					frame.unit = unit
				end
			end
		end
	end

	for unit, owner in UnitIterator() do
		if owner ~= nil then -- ignore players
			local name = UnitName(unit)
			local guid = UnitGUID(unit)
			local unitType = NP:GetUnitTypeFromUnit(unit)

			self.FRIENDLY_NPC[name] = unit

			if not self.GUIDList[guid] then
				self.GUIDList[guid] = {name, unitType}
			end

			for frame in pairs(self.VisiblePlates) do
				if frame.UnitName == name and frame.UnitType == unitType then
					frame.guid = guid
					frame.unit = unit
					break
				end
			end
		end
	end
end

function ZNP:CacheBossUnits()
	for i = 1, 5 do
		local unit = "boss"..i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local guid = UnitGUID(unit)
			local unitType = NP:GetUnitTypeFromUnit(unit)

			NP.UnitByName[name] = unit
			NP[unitType][name] = unit

			if not NP.GUIDList[guid] then
				NP.GUIDList[guid] = {name, unitType}
			end

			for frame in pairs(NP.VisiblePlates) do
				if frame.UnitName == name and frame.UnitType == unitType then
					frame.guid = guid
					frame.unit = unit
				end
			end
		end
	end
end

function ZNP:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, sourceGUID, sourceName, _, _, _, _, _, spellName)
	if event == "SPELL_CAST_START" then
		if sourceName and sourceGUID then -- sourceName needed, because in some cases there will be no sourceName, but only wrong unitguid so we skip those
			local frame = NP:SearchNameplateByGUID(sourceGUID)
			if frame then
				frame.CastBar.spellName = spellName
			end
		end
	end
end

local function updatePVPNameHook(self, frame)
	ZNP.hooks[NP].Update_Name(self, frame)

	if not frame.unit then return end

	if UnitIsPlayer(frame.unit) then
		frame.Name:SetText(UnitPVPName(frame.unit))
	end
end

function ZNP:Initialize()
	if E.db.pz.nameplates.tags.title.enable then
		if not ZNP:IsHooked(NP, "Update_Name") then
			ZNP:RawHook(NP, "Update_Name", updatePVPNameHook, true)
		end
	elseif not E.db.pz.nameplates.tags.title.enable then
		if ZNP:IsHooked(NP, "Update_Name") then
			ZNP:Unhook(NP, "Update_Name")
		end
	end

	if not E.db.pz.nameplates.hdClient.hdNameplates then return end -- Tags theoretically don't need HD client/nameplates, but since HD nameplates overwrite NP functions, refactoring this would be too high effort for low reward.

	NP.Update_CastBar = ZNP.Update_CastBar

	hooksecurefunc(NP, "OnCreated", function(this, frame)
		local CastBar = frame.UnitFrame.oldCastBar
		CastBar.Icon:SetParent(E.HiddenFrame)

		CastBar:HookScript("OnShow", ZNP.Update_CastBarOnShow)
		CastBar:HookScript("OnHide", ZNP.Update_CastBarOnHide)
		CastBar:HookScript("OnValueChanged", ZNP.Update_CastBarOnValueChanged)

		frame.UnitFrame.CastBar:SetScript("OnUpdate", nil)
	end)

	hooksecurefunc(NP, "OnShow", function(np)
		local frame = np.UnitFrame
		if not frame.tagGUID then
			frame.tagGUID = ZNP:Construct_tagGUID(frame) -- this is running here and not OnCreated due to a bug on ElvUI funtion runtime: UpdateElement_All finishes before OnShow, which finishes before OnCreated, so hooking them both is not possible unless I'd full replace OnCreated
		end
		ZNP:Configure_tagGUID(frame)
		ZNP:Update_tagGUID(frame)
	end)

	hooksecurefunc(NP, "OnHide", function(np)
		local frame = np.UnitFrame
		if frame.tagGUID then
			frame.tagGUID:SetText()
		end
	end)

	NP.OnEvent = function(this, event, unit, ...)
		if not unit then return end
		NP:Update_CastBar(this, event, unit, ...)
	end

	NP.RegisterEvents = function(this, frame)
		if not frame.unit then return end

		if NP.db.units[frame.UnitType].health.enable or (frame.isTarget and NP.db.alwaysShowTargetHealth) then
			if NP.db.units[frame.UnitType].castbar.enable then
				frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
				frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
				frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
				frame.isEventsRegistered = true
			end

			NP.OnEvent(frame, nil, frame.unit)
		end
	end

	NP.UnregisterAllEvents = function(this, frame)
		frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		frame:UnregisterEvent("UNIT_SPELLCAST_FAILED")
		frame.isEventsRegistered = nil
	end

	-- Couldn't find an efficient workaround to the UpdateElement_All finishing before OnShow/OnCreated, and hooking SetTargetFrame is onUpdate, so I am overwriting NP SetTargetFrame instead, to properly place the Update_tagGUID so it only runs once
	local hasTarget
	hooksecurefunc(NP, "PLAYER_TARGET_CHANGED", function()
		hasTarget = UnitExists("target") == 1
	end)
	NP.SetTargetFrame = function(this, frame)
		if hasTarget and frame.alpha == 1 then
			if not frame.isTarget then
				frame.isTarget = true

				this:SetPlateFrameLevel(frame, this:GetPlateFrameLevel(frame), true)

				if this.db.useTargetScale then
					this:SetFrameScale(frame, (frame.ThreatScale or 1) * this.db.targetScale)
				end

				if not frame.isGroupUnit then
					frame.unit = "target"
					frame.guid = UnitGUID("target")
					ZNP:Update_tagGUID(frame)

					if E.db.pz.nameplates.tags.title.enable then
						NP:Update_Name(frame)
					end

					this:RegisterEvents(frame)
				end

				this:UpdateElement_Auras(frame)

				if not this.db.units[frame.UnitType].health.enable and this.db.alwaysShowTargetHealth then
					frame.Health.r, frame.Health.g, frame.Health.b = nil, nil, nil

					this:Configure_HealthBar(frame)
					this:Configure_CastBar(frame)
					this:Configure_Elite(frame)
					this:Configure_CPoints(frame)

					this:RegisterEvents(frame)

					this:UpdateElement_All(frame, true)
				end

				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)

				this:Update_Highlight(frame)
				this:Update_CPoints(frame)
				this:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
				this:ForEachVisiblePlate("ResetNameplateFrameLevel") --keep this after `StyleFilterUpdate`
			end
		elseif frame.isTarget then
			frame.isTarget = nil

			this:SetPlateFrameLevel(frame, this:GetPlateFrameLevel(frame))

			if this.db.useTargetScale then
				this:SetFrameScale(frame, (frame.ThreatScale or 1))
			end

			if not frame.isGroupUnit then
				frame.unit = nil

				if frame.isEventsRegistered then
					this:UnregisterAllEvents(frame)
					this:Update_CastBar(frame)
				end
			end

			if not this.db.units[frame.UnitType].health.enable then
				this:UpdateAllFrame(frame, nil, true)
			end

			this:Update_CPoints(frame)

			if not frame.AlphaChanged then
				if hasTarget then
					NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), this.db.nonTargetTransparency)
				else
					NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)
				end
			end

			this:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
			this:ForEachVisiblePlate("ResetNameplateFrameLevel") --keep this after `StyleFilterUpdate`
		else
			if hasTarget and not frame.isAlphaChanged then
				frame.isAlphaChanged = true

				if not frame.AlphaChanged then
					NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), this.db.nonTargetTransparency)
				end

				this:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
			elseif not hasTarget and frame.isAlphaChanged then
				frame.isAlphaChanged = nil

				if not frame.AlphaChanged then
					NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)
				end

				this:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
			end
		end

		this:Configure_Glow(frame)
		this:Update_Glow(frame)
	end

	NP.SetMouseoverFrame = function(this, frame)
		if frame.oldHighlight:IsShown() then
			if not frame.isMouseover then
				frame.isMouseover = true

				this:Update_Highlight(frame)

				if not frame.isGroupUnit then
					frame.unit = "mouseover"
					frame.guid = UnitGUID("mouseover")
					ZNP:Update_tagGUID(frame)
					if E.db.pz.nameplates.tags.title.enable then
						NP:Update_Name(frame)
					end

					NP:Update_CastBar(frame, nil, frame.unit)
				end

				this:UpdateElement_Auras(frame)
			end
		elseif frame.isMouseover then
			frame.isMouseover = nil

			this:Update_Highlight(frame)

			if not frame.isGroupUnit then
				frame.unit = nil

				NP:Update_CastBar(frame)
			end
		end

		this:StyleFilterUpdate(frame, "UNIT_AURA")
	end

	NP.UpdateCVars = function(this)
		SetCVar("ShowClassColorInNameplate", "1")
		SetCVar("showVKeyCastbar", "1")
		SetCVar("nameplateAllowOverlap", NP.db.motionType == "STACKED" and "0" or "1")
	end

	if NP.Initialized then
		NP:UpdateCVars()

		for frame in pairs(NP.CreatedPlates) do
			frame:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
			frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
			frame:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
			frame:UnregisterEvent("UNIT_SPELLCAST_START")
			frame:UnregisterEvent("UNIT_SPELLCAST_STOP")

			frame.UnitFrame.CastBar:SetScript("OnUpdate", nil)
		end
	end

	ZNP:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	-- Bosses
	ZNP:CacheBossUnits()
	ZNP:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CacheBossUnits")
end

local function InitializeCallback()
    ZNP:Initialize()
end

E:RegisterModule(ZNP:GetName(), InitializeCallback)