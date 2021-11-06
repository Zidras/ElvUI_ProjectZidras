local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames

function ZUF:Construct_PartyFrames()
	UF.HealCommBar = ZUF:Construct_HealComm(self)
end

hooksecurefunc(UF, "Construct_PartyFrames", ZUF.Construct_PartyFrames)