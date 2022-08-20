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

local hasTarget = false

-- GLOBALS: hooksecurefunc

-- ElvUI Bugfixes -- (Doesn't need db check as they're intended to fix ElvUI core bugs or bad behaviour)
-- Replace ElvUI Nameplate cache functions with proper GUID caching. .
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

-- Exiting on unit - self.unit mismatch would prevent castbars from showing on the nameplate that have unit already cached, so fix that too
function NP:OnEvent(event, unit, ...)
	if not unit then return end
	NP:Update_CastBar(self, event, unit, ...) -- overwritten later on HD Nameplates
end
-- End ElvUI Bugfixes --

-- For HD nameplates castbar spellName completion. Could also be used to generate castbars for non-HD clients if nameplateGUID is cached, but I won't develop it since HD nameplates are the better option
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

-- Below are the functions meant to be hooked if HD client is used
local function OnCreatedHook(self, frame)
	ZNP.hooks[NP].OnCreated(self, frame)

	local CastBar = frame.UnitFrame.oldCastBar
--	CastBar.Icon:SetParent(E.HiddenFrame) -- Hide the original castbar icon. Commented out and moved to OnValueChanged :Hide()

	CastBar:HookScript("OnShow", ZNP.Update_CastBarOnShow)
	CastBar:HookScript("OnHide", ZNP.Update_CastBarOnHide)
	CastBar:HookScript("OnValueChanged", ZNP.Update_CastBarOnValueChanged)

	frame.UnitFrame.CastBar:SetScript("OnUpdate", nil)
end

local function OnShowHook(self, ...)
	ZNP.hooks[NP].OnShow(self, ...)

	local frame = self.UnitFrame
	if not frame.tagGUID then
		frame.tagGUID = ZNP:Construct_tagGUID(frame) -- this is running here and not OnCreated due to a bug on ElvUI funtion runtime: UpdateElement_All finishes before OnShow, which finishes before OnCreated, so hooking them both is not possible unless I'd full replace OnCreated
	end
	ZNP:Configure_tagGUID(frame)
	ZNP:Update_tagGUID(frame)
end

local function OnHideHook(self, ...)
	ZNP.hooks[NP].OnHide(self, ...)

	local frame = self.UnitFrame
	if frame.tagGUID then
		frame.tagGUID:SetText()
	end
end

local function RegisterEventsHook(self, frame)
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

local function UnregisterAllEventsHook(self, frame)
	frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	frame:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	frame.isEventsRegistered = nil
end

local function SetTargetFrameHook(self, frame)
	if hasTarget and frame.alpha == 1 then
		if not frame.isTarget then
			frame.isTarget = true

			self:SetPlateFrameLevel(frame, self:GetPlateFrameLevel(frame), true)

			if self.db.useTargetScale then
				self:SetFrameScale(frame, (frame.ThreatScale or 1) * self.db.targetScale)
			end

			if not frame.isGroupUnit then
				frame.unit = "target"
				frame.guid = UnitGUID("target")
				ZNP:Update_tagGUID(frame)

				if E.db.pz.nameplates.tags.title.enable then
					NP:Update_Name(frame)
				end

				self:RegisterEvents(frame)
			end

			self:UpdateElement_Auras(frame)

			if not self.db.units[frame.UnitType].health.enable and self.db.alwaysShowTargetHealth then
				frame.Health.r, frame.Health.g, frame.Health.b = nil, nil, nil

				self:Configure_HealthBar(frame)
				self:Configure_CastBar(frame)
				self:Configure_Elite(frame)
				self:Configure_CPoints(frame)

				self:RegisterEvents(frame)

				self:UpdateElement_All(frame, true)
			end

			NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)

			self:Update_Highlight(frame)
			self:Update_CPoints(frame)
			self:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
			self:ForEachVisiblePlate("ResetNameplateFrameLevel") --keep this after `StyleFilterUpdate`
		end
	elseif frame.isTarget then
		frame.isTarget = nil

		self:SetPlateFrameLevel(frame, self:GetPlateFrameLevel(frame))

		if self.db.useTargetScale then
			self:SetFrameScale(frame, (frame.ThreatScale or 1))
		end

		if not frame.isGroupUnit then
			frame.unit = nil

			if frame.isEventsRegistered then
				self:UnregisterAllEvents(frame)
				self:Update_CastBar(frame)
			end
		end

		if not self.db.units[frame.UnitType].health.enable then
			self:UpdateAllFrame(frame, nil, true)
		end

		self:Update_CPoints(frame)

		if not frame.AlphaChanged then
			if hasTarget then
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), self.db.nonTargetTransparency)
			else
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)
			end
		end

		self:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
		self:ForEachVisiblePlate("ResetNameplateFrameLevel") --keep this after `StyleFilterUpdate`
	else
		if hasTarget and not frame.isAlphaChanged then
			frame.isAlphaChanged = true

			if not frame.AlphaChanged then
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), self.db.nonTargetTransparency)
			end

			self:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
		elseif not hasTarget and frame.isAlphaChanged then
			frame.isAlphaChanged = nil

			if not frame.AlphaChanged then
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)
			end

			self:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
		end
	end

	self:Configure_Glow(frame)
	self:Update_Glow(frame)
end

local function SetMouseoverFrameHook(self, frame)
	if frame.oldHighlight:IsShown() then
		if not frame.isMouseover then
			frame.isMouseover = true

			self:Update_Highlight(frame)

			if not frame.isGroupUnit then
				frame.unit = "mouseover"
				frame.guid = UnitGUID("mouseover")
				ZNP:Update_tagGUID(frame)

				if E.db.pz.nameplates.tags.title.enable then
					NP:Update_Name(frame)
				end

				self:Update_CastBar(frame, nil, frame.unit)
			end

			self:UpdateElement_Auras(frame)
		end
	elseif frame.isMouseover then
		frame.isMouseover = nil

		self:Update_Highlight(frame)

		if not frame.isGroupUnit then
			frame.unit = nil

			self:Update_CastBar(frame)
		end
	end

	self:StyleFilterUpdate(frame, "UNIT_AURA")
end

local function UpdateCVarsHook(self)
	SetCVar("ShowClassColorInNameplate", "1")
	SetCVar("showVKeyCastbar", "1")
	SetCVar("nameplateAllowOverlap", self.db.motionType == "STACKED" and "0" or "1")
end

local function updatePVPNameHook(self, frame)
	ZNP.hooks[NP].Update_Name(self, frame)

	if not frame.unit then return end -- if Name Only, de-targeting will run UpdateAllFrame(frame, nil, true) and cause PVPName to reset to UnitName since frame.unit is nil

	if UnitIsPlayer(frame.unit) then
		frame.Name:SetText(UnitPVPName(frame.unit))
	end
end

function ZNP:CastBarHD()
	local db = E.db.pz.nameplates
	if db.hdClient.hdNameplates then
		if not self:IsHooked(NP, "Update_CastBar") then
			self:RawHook(NP, "Update_CastBar", ZNP.Update_CastBar)
		end
		if not self:IsHooked(NP, "OnCreated") then
			self:RawHook(NP, "OnCreated", OnCreatedHook, true)
		end
		if not self:IsHooked(NP, "RegisterEvents") then
			self:RawHook(NP, "RegisterEvents", RegisterEventsHook)
		end
		if not self:IsHooked(NP, "UnregisterAllEvents") then
			self:RawHook(NP, "UnregisterAllEvents", UnregisterAllEventsHook)
		end
		-- Couldn't find an efficient workaround to the UpdateElement_All finishing before OnShow/OnCreated, and post-hooking SetTargetFrame is onUpdate, so I am overwriting NP SetTargetFrame instead, to properly place the Update_tagGUID so it only runs once
		if not self:IsHooked(NP, "PLAYER_TARGET_CHANGED") then
			self:SecureHook(NP, "PLAYER_TARGET_CHANGED", function()
				hasTarget = UnitExists("target") == 1
			end)
		end
		if not self:IsHooked(NP, "SetTargetFrame") then
			self:RawHook(NP, "SetTargetFrame", SetTargetFrameHook)
		end
		if not self:IsHooked(NP, "SetMouseoverFrame") then
			self:RawHook(NP, "SetMouseoverFrame", SetMouseoverFrameHook)
		end
		if not self:IsHooked(NP, "UpdateCVars") then
			self:RawHook(NP, "UpdateCVars", UpdateCVarsHook)
		end
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
	elseif not db.hdClient.hdNameplates then
		if self:IsHooked(NP, "Update_CastBar") then
			self:Unhook(NP, "Update_CastBar")
		end
		if self:IsHooked(NP, "OnCreated") then
			self:Unhook(NP, "OnCreated")
		end
		if self:IsHooked(NP, "RegisterEvents") then
			self:Unhook(NP, "RegisterEvents")
		end
		if self:IsHooked(NP, "UnregisterAllEvents") then
			self:Unhook(NP, "UnregisterAllEvents")
		end
		if self:IsHooked(NP, "PLAYER_TARGET_CHANGED") then
			self:Unhook(NP, "PLAYER_TARGET_CHANGED")
		end
		if not db.tags.guid.enable and not db.tags.title.enable then
			if self:IsHooked(NP, "SetTargetFrame") then
				self:Unhook(NP, "SetTargetFrame")
			end
			if self:IsHooked(NP, "SetMouseoverFrame") then
				self:Unhook(NP, "SetMouseoverFrame")
			end
		end
		if self:IsHooked(NP, "UpdateCVars") then
			self:Unhook(NP, "UpdateCVars")
		end
		for frame in pairs(NP.CreatedPlates) do
			frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
			frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
			frame:RegisterEvent("UNIT_SPELLCAST_START")
			frame:RegisterEvent("UNIT_SPELLCAST_STOP")

			frame.UnitFrame.CastBar:SetScript("OnUpdate", NP.Update_CastBarOnUpdate)
		end
	end
end

function ZNP:NameplateTags()
	local tagsOptions = E.db.pz.nameplates.tags
	if tagsOptions.guid.enable or tagsOptions.title.enable then
		if not self:IsHooked(NP, "OnShow") then
			self:RawHook(NP, "OnShow", OnShowHook, true)
		end
		if not self:IsHooked(NP, "OnHide") then
			self:RawHook(NP, "OnHide", OnHideHook)
		end
		-- Couldn't find an efficient workaround to the UpdateElement_All finishing before OnShow/OnCreated, and post-hooking SetTargetFrame is onUpdate, so I am overwriting NP SetTargetFrame instead, to properly place the Update_tagGUID so it only runs once
		if not self:IsHooked(NP, "PLAYER_TARGET_CHANGED") then
			self:SecureHook(NP, "PLAYER_TARGET_CHANGED", function()
				hasTarget = UnitExists("target") == 1
			end)
		end
		if not self:IsHooked(NP, "SetTargetFrame") then
			self:RawHook(NP, "SetTargetFrame", SetTargetFrameHook)
		end
		if not self:IsHooked(NP, "SetMouseoverFrame") then
			self:RawHook(NP, "SetMouseoverFrame", SetMouseoverFrameHook)
		end
		if tagsOptions.title.enable then
			if not ZNP:IsHooked(NP, "Update_Name") then
				ZNP:RawHook(NP, "Update_Name", updatePVPNameHook, true)
			end
		elseif not tagsOptions.title.enable then
			if ZNP:IsHooked(NP, "Update_Name") then
				ZNP:Unhook(NP, "Update_Name")
			end
		end
	elseif not tagsOptions.guid.enable and not tagsOptions.title.enable then
		if self:IsHooked(NP, "OnShow") then
			self:Unhook(NP, "OnShow")
		end
		if self:IsHooked(NP, "OnHide") then
			self:Unhook(NP, "OnHide")
		end
		if not tagsOptions.title.enable then
			if ZNP:IsHooked(NP, "Update_Name") then
				ZNP:Unhook(NP, "Update_Name")
			end
		end
		if not E.db.pz.nameplates.hdClient.hdNameplates then
			if ZNP:IsHooked(NP, "SetTargetFrame") then
				ZNP:Unhook(NP, "SetTargetFrame")
			end
			if ZNP:IsHooked(NP, "SetMouseoverFrame") then
				ZNP:Unhook(NP, "SetMouseoverFrame")
			end
		end
	end
end

function ZNP:UpdateAllSettings()
	self:CastBarHD()
	self:NameplateTags()
end

function ZNP:Initialize()
	if NP.Initialized then
		ZNP:UpdateAllSettings()

		if E.db.pz.nameplates.hdClient.hdNameplates then
			UpdateCVarsHook(NP) -- update once since we cannot hook it in time on NP:Initialize.
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