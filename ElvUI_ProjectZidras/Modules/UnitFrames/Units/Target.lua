local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames

function ZUF:Construct_TargetFrame(frame)
	frame.HealCommBar = self:Construct_HealComm(frame)
end

hooksecurefunc(UF, "Construct_TargetFrame", ZUF.Construct_TargetFrame)