local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames

function ZUF:Construct_RaidFrames()
	UF.HealCommBar = ZUF:Construct_HealComm(self)
end

hooksecurefunc(UF, "Construct_RaidFrames", ZUF.Construct_RaidFrames)