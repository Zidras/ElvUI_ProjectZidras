local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames

function ZUF:Construct_Raid40Frames()
	UF.HealCommBar = ZUF:Construct_HealComm(self)
end

hooksecurefunc(UF, "Construct_Raid40Frames", ZUF.Construct_Raid40Frames)