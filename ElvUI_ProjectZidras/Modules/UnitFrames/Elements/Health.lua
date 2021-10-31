local E, L, V, P, G = unpack(ElvUI)

local ZUF = E:GetModule("ProjectZidras_UnitFrames")
local UF = E:GetModule("UnitFrames")

function ZUF.HealthClipFrame_OnUpdate(clipFrame)
	ZUF.HealthClipFrame_HealComm(clipFrame.__frame)

	clipFrame:SetScript("OnUpdate", nil)
end

UF.HealthClipFrame_OnUpdate = ZUF.HealthClipFrame_OnUpdate