local E, L, V, P, G = unpack(ElvUI)

local ZUF = E:GetModule("ProjectZidras_UnitFrames")
local UF = E:GetModule("UnitFrames")

function ZUF:Construct_FocusFrame(frame)
	frame.HealCommBar = self:Construct_HealComm(frame)
end

hooksecurefunc (UF, "Construct_FocusFrame", ZUF.Construct_FocusFrame)