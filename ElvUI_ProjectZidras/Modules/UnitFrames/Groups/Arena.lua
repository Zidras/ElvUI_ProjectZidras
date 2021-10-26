local E, L, V, P, G = unpack(ElvUI)

local ZUF = E:GetModule("ProjectZidras_UnitFrames")
local UF = E:GetModule("UnitFrames")

function ZUF:Construct_ArenaFrames(frame)
	frame.HealCommBar = ZUF:Construct_HealComm(frame)
end

hooksecurefunc (UF, "Construct_ArenaFrames", ZUF.Construct_ArenaFrames)