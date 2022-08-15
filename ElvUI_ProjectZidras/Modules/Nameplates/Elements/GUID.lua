local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZNP = PZ.NamePlates
local LSM = E.Libs.LSM

function ZNP:Update_tagGUID(frame)
	if not E.db.pz.nameplates.tags.guid.enable then return end
	local db = E.db.pz.nameplates.tags.guid

	local guid = frame.guid
	local tagGUID = frame.tagGUID
	tagGUID:ClearAllPoints()

	if frame.Health:IsShown() then
		tagGUID:SetJustifyH("RIGHT")
		tagGUID:SetPoint(E.InversePoints[db.position], db.parent == "Nameplate" and frame or frame[db.parent], db.position, db.xOffset, db.yOffset)
		tagGUID:SetParent(frame.Health)
	else
		tagGUID:SetPoint("TOPLEFT", frame, "TOPRIGHT", -38, 0)
		tagGUID:SetParent(frame)
		tagGUID:SetJustifyH("LEFT")
	end
	tagGUID:SetText(guid)
end

function ZNP:Configure_tagGUID(frame)
	local db = E.db.pz.nameplates.tags.guid
	frame.tagGUID:FontTemplate(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
end

function ZNP:Construct_tagGUID(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end