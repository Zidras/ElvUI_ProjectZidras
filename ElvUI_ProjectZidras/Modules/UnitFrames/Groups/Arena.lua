local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames

function ZUF:Construct_ArenaFrames(frame)
	frame.HealCommBar = ZUF:Construct_HealComm(frame)
end

hooksecurefunc(UF, "Construct_ArenaFrames", ZUF.Construct_ArenaFrames)