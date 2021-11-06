local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames

function ZUF.HealthClipFrame_OnUpdate(clipFrame)
	ZUF.HealthClipFrame_HealComm(clipFrame.__frame)

	clipFrame:SetScript("OnUpdate", nil)
end

UF.HealthClipFrame_OnUpdate = ZUF.HealthClipFrame_OnUpdate