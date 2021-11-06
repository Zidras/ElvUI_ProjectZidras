local parent, ns = ...

local LGT = LibStub and LibStub("LibGroupTalents-1.0", true)
if not LGT then return end

local Compat = ns.Compat
local unitExists = Compat.Private.UnitExists

local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local MAX_TALENT_TABS = MAX_TALENT_TABS or 3
local GetActiveTalentGroup = GetActiveTalentGroup
local GetTalentTabInfo = GetTalentTabInfo
local GetSpellInfo = GetSpellInfo
local UnitClass = UnitClass

local LGTRoleTable = {melee = "DAMAGER", caster = "DAMAGER", healer = "HEALER", tank = "TANK"}

local specsTable = {
	["MAGE"] = {62, 63, 64},
	["PRIEST"] = {256, 257, 258},
	["ROGUE"] = {259, 260, 261},
	["WARLOCK"] = {265, 266, 267},
	["WARRIOR"] = {71, 72, 73},
	["PALADIN"] = {65, 66, 70},
	["DEATHKNIGHT"] = {250, 251, 252},
	["DRUID"] = {102, 103, 104, 105},
	["HUNTER"] = {253, 254, 255},
	["SHAMAN"] = {262, 263, 264}
}

function Compat.GetSpecialization(isInspect, isPet, specGroup)
	local currentSpecGroup = GetActiveTalentGroup(isInspect, isPet) or (specGroup or 1)
	local points, specname, specid = 0, nil, nil

	for i = 1, MAX_TALENT_TABS do
		local name, _, pointsSpent = GetTalentTabInfo(i, isInspect, isPet, currentSpecGroup)
		if points <= pointsSpent then
			points = pointsSpent
			specname = name
			specid = i
		end
	end
	return specid, specname, points
end

function Compat.UnitHasTalent(unit, spell, talentGroup)
	spell = (type(spell) == "number") and GetSpellInfo(spell) or spell
	return LGT:UnitHasTalent(unit, spell, talentGroup)
end

function Compat.GetInspectSpecialization(unit, class)
	local spec  -- start with nil

	if unitExists(unit) then
		class = class or select(2, UnitClass(unit))
		if class and specsTable[class] then
			local talentGroup = LGT:GetActiveTalentGroup(unit)
			local maxPoints, index = 0, 0

			for i = 1, MAX_TALENT_TABS do
				local _, _, pointsSpent = LGT:GetTalentTabInfo(unit, i, talentGroup)
				if pointsSpent ~= nil then
					if maxPoints < pointsSpent then
						maxPoints = pointsSpent
						if class == "DRUID" and i >= 2 then
							if i == 3 then
								index = 4
							elseif i == 2 then
								local points = Compat.UnitHasTalent(unit, 57881)
								index = (points and points > 0) and 3 or 2
							end
						else
							index = i
						end
					end
				end
			end
			spec = specsTable[class][index]
		end
	end

	return spec
end

function Compat.GetSpecializationRole(unit, class)
	unit = unit or "player" -- always fallback to player

	-- For LFG using "UnitGroupRolesAssigned" is enough.
	local isTank, isHealer, isDamager = UnitGroupRolesAssigned(unit)
	if isTank then
		return "TANK"
	elseif isHealer then
		return "HEALER"
	elseif isDamager then
		return "DAMAGER"
	end

	-- speedup things using classes.
	class = class or select(2, UnitClass(unit))
	if class == "HUNTER" or class == "MAGE" or class == "ROGUE" or class == "WARLOCK" then
		return "DAMAGER"
	end
	return LGTRoleTable[LGT:GetUnitRole(unit)] or "NONE"
end

-- aliases
Compat.UnitGroupRolesAssigned = Compat.GetSpecializationRole
Compat.GetUnitRole = Compat.GetSpecializationRole
Compat.GetUnitSpec = Compat.GetInspectSpecialization

-- utilities

function Compat.UnitHasTalent(unit, spell, talentGroup)
	spell = (type(spell) == "number") and GetSpellInfo(spell) or spell
	return LGT:UnitHasTalent(unit, spell, talentGroup)
end

function Compat.UnitHasGlyph(unit, glyphID)
	return LGT:UnitHasGlyph(unit, glyphID)
end


-- functions that simply replaced other api functions
local GetNumTalentTabs = GetNumTalentTabs
local GetNumTalentGroups = GetNumTalentGroups
local GetUnspentTalentPoints = GetUnspentTalentPoints
local SetActiveTalentGroup = SetActiveTalentGroup

Compat.GetNumSpecializations = GetNumTalentTabs
Compat.GetNumSpecGroups = GetNumTalentGroups
Compat.GetNumUnspentTalents = GetUnspentTalentPoints
Compat.GetActiveSpecGroup = GetActiveTalentGroup
Compat.SetActiveSpecGroup = SetActiveTalentGroup