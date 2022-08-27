local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZNP = PZ.NamePlates
local LSM = E.Libs.LSM

function ZNP:Update_tagUnit(frame)
	if not E.db.pz.nameplates.tags.unit.enable then return end
	local db = E.db.pz.nameplates.tags.unit

	local unit = frame.unit
	local tagUnit = frame.tagUnit
	tagUnit:ClearAllPoints()

	if frame.Health:IsShown() then
		tagUnit:SetJustifyH("RIGHT")
		tagUnit:SetPoint(E.InversePoints[db.position], db.parent == "Nameplate" and frame or frame[db.parent], db.position, db.xOffset, db.yOffset)
		tagUnit:SetParent(frame.Health)
	else
		tagUnit:SetPoint("TOPLEFT", frame, "TOPRIGHT", -38, 0)
		tagUnit:SetParent(frame)
		tagUnit:SetJustifyH("LEFT")
	end
	tagUnit:SetText(unit or "")
end

function ZNP:Configure_tagUnit(frame)
	local db = E.db.pz.nameplates.tags.unit
	frame.tagUnit:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
end

function ZNP:Construct_tagUnit(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end