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

function ZNP:Initialize()
	if not E.db.pz.nameplates.hdNameplates then return end

	NP.Update_CastBar = ZNP.Update_CastBar

	hooksecurefunc(NP, "OnCreated", function(this, frame)
		local CastBar = frame.UnitFrame.oldCastBar
		CastBar.Icon:SetParent(E.HiddenFrame)

		CastBar:HookScript("OnShow", ZNP.Update_CastBarOnShow)
		CastBar:HookScript("OnHide", ZNP.Update_CastBarOnHide)
		CastBar:HookScript("OnValueChanged", ZNP.Update_CastBarOnValueChanged)

		frame.UnitFrame.CastBar:SetScript("OnUpdate", nil)
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

	NP.SetMouseoverFrame = function(this, frame)
		if frame.oldHighlight:IsShown() then
			if not frame.isMouseover then
				frame.isMouseover = true

				this:Update_Highlight(frame)

				if not frame.isGroupUnit then
					frame.unit = "mouseover"
					frame.guid = UnitGUID("mouseover")

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