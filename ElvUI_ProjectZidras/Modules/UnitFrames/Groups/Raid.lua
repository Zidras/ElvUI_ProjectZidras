local E, L, V, P, G = unpack(ElvUI)

local ZUF = E:GetModule("ProjectZidras_UnitFrames")
local UF = E:GetModule("UnitFrames")

function ZUF:Construct_RaidFrames()
	UF.HealCommBar = ZUF:Construct_HealComm(self)
end

hooksecurefunc (UF, "Construct_RaidFrames", ZUF.Construct_RaidFrames)