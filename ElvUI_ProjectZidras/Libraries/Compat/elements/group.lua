local parent, ns = ...
local Compat = ns.Compat

local unitExists = Compat.Private.UnitExists
local QuickDispatch = Compat.Private.QuickDispatch

local format = string.format
local strmatch = string.match

local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitAffectingCombat = UnitAffectingCombat

local IsPartyLeader = IsPartyLeader
local IsRaidLeader = IsRaidLeader
local GetPartyLeaderIndex = GetPartyLeaderIndex
local GetRaidRosterInfo = GetRaidRosterInfo

function Compat.IsInGroup()
	return (GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0)
end

function Compat.IsInRaid()
	return (GetNumRaidMembers() > 0)
end

function Compat.GetNumSubgroupMembers()
	return GetNumPartyMembers()
end

function Compat.GetNumGroupMembers()
	return Compat.IsInRaid() and GetNumRaidMembers() or GetNumPartyMembers()
end

function Compat.GetGroupTypeAndCount()
	if Compat.IsInRaid() then
		return "raid", 1, GetNumRaidMembers()
	elseif Compat.IsInGroup() then
		return "party", 0, GetNumPartyMembers()
	else
		return nil, 0, 0
	end
end

do
	local rmem, pmem, step, count

	local function SelfIterator(excPets)
		while step do
			local unit, owner
			if step == 1 then
				unit, owner, step = "player", nil, 2
			elseif step == 2 then
				if not excPets then
					unit, owner = "playerpet", "player"
				end
				step = nil
			end
			if unitExists(unit) then
				return unit, owner
			end
		end
	end

	local function PartyIterator(excPets)
		while step do
			local unit, owner
			if step <= 2 then
				unit, owner = SelfIterator(excPets)
				step = step or 3
			elseif step == 3 then
				unit, owner, step = format("party%d", count), nil, 4
			elseif step == 4 then
				if not excPets then
					unit, owner = format("partypet%d", count), format("party%d", count)
				end
				count = count + 1
				step = count <= pmem and 3 or nil
			end
			if unitExists(unit) then
				return unit, owner
			end
		end
	end

	local function RaidIterator(excPets)
		while step do
			local unit, owner
			if step == 1 then
				unit, owner, step = format("raid%d", count), nil, 2
			elseif step == 2 then
				if not excPets then
					unit, owner = format("raidpet%d", count), format("raid%d", count)
				end
				count = count + 1
				step = count <= rmem and 1 or nil
			end
			if unitExists(unit) then
				return unit, owner
			end
		end
	end

	function Compat.UnitIterator(excPets)
		rmem, step = GetNumRaidMembers(), 1
		if rmem == 0 then
			pmem = GetNumPartyMembers()
			if pmem == 0 then
				return SelfIterator, excPets
			end
			count = 1
			return PartyIterator, excPets
		end
		count = 1
		return RaidIterator, excPets
	end
end

function Compat.IsGroupDead(incPets)
	for unit in Compat.UnitIterator(not incPets) do
		if not UnitIsDeadOrGhost(unit) then
			return false
		end
	end
	return true
end

function Compat.IsGroupInCombat(incPets)
	for unit in Compat.UnitIterator(not incPets) do
		if UnitAffectingCombat(unit) then
			return true
		end
	end
	return false
end

function Compat.GroupIterator(func, ...)
	for unit, owner in Compat.UnitIterator() do
		QuickDispatch(func, unit, owner, ...)
	end
end

function Compat.UnitIsGroupLeader(unit)
	if not Compat.IsInGroup() then
		return false
	elseif unit == "player" then
		return (Compat.IsInRaid() and IsRaidLeader() or IsPartyLeader())
	else
		local index = strmatch(unit, "%d+")
		return (index and GetPartyLeaderIndex() == tonumber(index))
	end
end

function Compat.UnitIsGroupAssistant(unit)
	if not Compat.IsInRaid() then
		return false
	end
	local index = strmatch(unit, "%d+")
	return (index and select(2, GetRaidRosterInfo(index)) == 1)
end