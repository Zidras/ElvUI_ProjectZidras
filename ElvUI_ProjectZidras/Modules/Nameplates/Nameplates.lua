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
local function OnCreatedHook(self, frame) -- this function requires a reload to properly replace the original function, since there are HookScripts in place that can't be unhooked (couldn't fully validate this)
--	ZNP.hooks[NP].OnCreated(self, frame)

	local CastBar = frame.UnitFrame.oldCastBar
--	CastBar.Icon:SetParent(E.HiddenFrame) -- Hide the original castbar icon. Commented out and moved to OnValueChanged :Hide()

	CastBar:HookScript("OnShow", ZNP.Update_CastBarOnShow)
	CastBar:HookScript("OnHide", ZNP.Update_CastBarOnHide)
	CastBar:HookScript("OnValueChanged", ZNP.Update_CastBarOnValueChanged)

	frame.UnitFrame.CastBar:SetScript("OnUpdate", nil)
end

local function OnEventHook(self, event, unit, ...) -- Exiting on unit - self.unit mismatch would prevent castbars from showing on the nameplate that have unit already cached. Hook required since for non-HD it would make it so every unit cached would replace the nameplate castbar
	if not unit then return end
	NP:Update_CastBar(self, event, unit, ...) -- overwritten later on HD Nameplates
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

local function UpdateCVarsHook(self)
	SetCVar("ShowClassColorInNameplate", "1")
	SetCVar("showVKeyCastbar", "1")
	SetCVar("nameplateAllowOverlap", self.db.motionType == "STACKED" and "0" or "1")
end

function ZNP:CastBarHD()
	if E.db.pz.nameplates.hdClient.hdNameplates then
--[[ initially designed with AceHook to prevent not having to reload, but it caused unstable behavior (possibly due to hookscripts not being able to be unhooked), so revert back to a reload based toggle and hooksecurefunc/replace.
		if not self:IsHooked(NP, "Update_CastBar") then
			self:RawHook(NP, "Update_CastBar", ZNP.Update_CastBar) -- keep this before OnCreated hook
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
		if not self:IsHooked(NP, "UpdateCVars") then
			self:RawHook(NP, "UpdateCVars", UpdateCVarsHook)
		end
]]
		NP.Update_CastBar = ZNP.Update_CastBar -- keep this before OnCreated hook
		hooksecurefunc(NP, "OnCreated", OnCreatedHook)
		NP.OnEvent = OnEventHook
		NP.RegisterEvents = RegisterEventsHook
		NP.UnregisterAllEvents = UnregisterAllEventsHook
		NP.UpdateCVars = UpdateCVarsHook

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
--[[elseif not E.db.pz.nameplates.hdClient.hdNameplates then
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
		end]]
	end
end

-- Tags
function ZNP:Update_Tags(frame)
	local tagsOptions = E.db.pz.nameplates.tags

	if tagsOptions.guid.enable then
		ZNP:Update_tagGUID(frame)
	end
	if tagsOptions.title.enable then
		NP:Update_Name(frame)
	end
end

function ZNP:PLAYER_TARGET_CHANGED()
	hasTarget = UnitExists("target") == 1
	if hasTarget then
		E:Delay(0.01, function() -- Delay needed since nameplate alpha only gets set a few frames after the event fires
			for frame in pairs(NP.VisiblePlates) do
				if frame.alpha == 1 then
					ZNP:Update_Tags(frame)
					break
				end
			end
		end)
	end
end

function ZNP:UPDATE_MOUSEOVER_UNIT()
	if UnitExists("mouseover") and not UnitIsUnit("mouseover", "player") then
		for frame in pairs(NP.VisiblePlates) do
			if frame.oldHighlight:IsShown() then
				-- runs before SetMouseoverFrame so ensure frame.unit and frame.guid are the right values (also needed due to CURSOR_UPDATE when mouseovering a model and afterwards a different nameplate would assume a different frame.guid)
				frame.unit = "mouseover"
				frame.guid = UnitGUID("mouseover")

				ZNP:Update_Tags(frame)
				break
			end
		end
	end
end
ZNP.CURSOR_UPDATE = ZNP.UPDATE_MOUSEOVER_UNIT

local function OnShowHook(self)
	local frame = self.UnitFrame
	if not frame.tagGUID then
		frame.tagGUID = ZNP:Construct_tagGUID(frame) -- this is running here and not OnCreated due to a bug on ElvUI funtion runtime: UpdateElement_All finishes before OnShow, which finishes before OnCreated, so hooking them both is not possible unless I'd full replace OnCreated
	end
	ZNP:Configure_tagGUID(frame)
	ZNP:Update_Tags(frame)

	if hasTarget then
		E:Delay(0.01, function() if frame.alpha == 1 then ZNP:Update_Tags(frame) end end) -- Delay needed since nameplate alpha only gets set a few frames after this
	end
end

local function OnHideHook(self)
	local frame = self.UnitFrame
	if frame.tagGUID then
		frame.tagGUID:SetText()
	end
end

local function updatePVPNameHook(self, frame)
	if not frame.unit then return end -- if Name Only, de-targeting will run UpdateAllFrame(frame, nil, true) and cause PVPName to reset to UnitName since frame.unit is nil

	if UnitIsPlayer(frame.unit) then
		frame.Name:SetText(UnitPVPName(frame.unit))
	end
end

function ZNP:NameplateTags()
	local tagsOptions = E.db.pz.nameplates.tags
	if tagsOptions.guid.enable or tagsOptions.title.enable then
		if not self:IsHooked(NP, "OnShow") then
			self:SecureHook(NP, "OnShow", OnShowHook)
		end
		if not self:IsHooked(NP, "OnHide") then
			self:SecureHook(NP, "OnHide", OnHideHook)
		end
	elseif not tagsOptions.guid.enable and not tagsOptions.title.enable then
		if self:IsHooked(NP, "OnShow") then
			self:Unhook(NP, "OnShow")
		end
		if self:IsHooked(NP, "OnHide") then
			NP:ForEachPlate("UpdateAllFrame", true, true) -- run it once before unhooking to clear the ZNP tags
			self:Unhook(NP, "OnHide")
		end
	end
	if tagsOptions.title.enable then
		if not self:IsHooked(NP, "Update_Name") then
			self:SecureHook(NP, "Update_Name", updatePVPNameHook)
		end
	elseif not tagsOptions.title.enable then
		if self:IsHooked(NP, "Update_Name") then
			self:Unhook(NP, "Update_Name")
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
	ZNP:RegisterEvent("PLAYER_TARGET_CHANGED")
	ZNP:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	ZNP:RegisterEvent("CURSOR_UPDATE")

	-- Bosses
	ZNP:CacheBossUnits()
	ZNP:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CacheBossUnits")
end

local function InitializeCallback()
    ZNP:Initialize()
end

E:RegisterModule(ZNP:GetName(), InitializeCallback)