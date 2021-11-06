local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZNP = PZ.NamePlates
local NP = E.NamePlates

local abs = math.abs

local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local FAILED = FAILED
local INTERRUPTED = INTERRUPTED

local function resetAttributes(self)
	self.casting = nil
	self.channeling = nil
	self.notInterruptible = nil
	self.spellName = nil
end

function ZNP:Update_CastBarOnValueChanged(value)
	local frame = self:GetParent().UnitFrame
	if not frame.UnitType then return end

	local db = NP.db.units[frame.UnitType]
	if not db.castbar.enable or (not db.health.enable and not (frame.isTarget and NP.db.alwaysShowTargetHealth)) then return end

	local castBar = frame.CastBar

	local min, max = self:GetMinMaxValues()
	local cur = castBar:GetValue()

	--castBar.spellName = self.Name:GetText()
	castBar.casting = value > cur
	castBar.channeling = value < cur
	castBar.notInterruptible = frame.oldCastBar.Shield:IsShown()

	castBar:SetMinMaxValues(min, max)
	castBar:SetValue(value)

	if castBar.channeling then
		if castBar.channelTimeFormat == "CURRENT" then
			castBar.Time:SetFormattedText("%.1f", abs(value - max))
		elseif castBar.channelTimeFormat == "CURRENTMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", abs(value - max), max)
		elseif castBar.channelTimeFormat == "REMAINING" then
			castBar.Time:SetFormattedText("%.1f", value)
		elseif castBar.channelTimeFormat == "REMAININGMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", value, max)
		end
	else
		if castBar.castTimeFormat == "CURRENT" then
			castBar.Time:SetFormattedText("%.1f", value)
		elseif castBar.castTimeFormat == "CURRENTMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", value, max)
		elseif castBar.castTimeFormat == "REMAINING" then
			castBar.Time:SetFormattedText("%.1f", abs(value - max))
		elseif castBar.castTimeFormat == "REMAININGMAX" then
			castBar.Time:SetFormattedText("%.1f / %.2f", abs(value - max), max)
		end
	end

	if castBar.Spark then
		local sparkPosition = (value / max) * castBar:GetWidth()
		castBar.Spark:SetPoint("CENTER", castBar, "LEFT", sparkPosition, 0)
	end

	local colors = NP.db.colors
	if castBar.notInterruptible then
		castBar:SetStatusBarColor(colors.castNoInterruptColor.r, colors.castNoInterruptColor.g, colors.castNoInterruptColor.b)
		castBar.Icon.texture:SetDesaturated(colors.castbarDesaturate and true or false)
	else
		castBar:SetStatusBarColor(colors.castColor.r, colors.castColor.g, colors.castColor.b)
		castBar.Icon.texture:SetDesaturated(false)
	end

	castBar.Name:SetText(castBar.spellName)
	castBar.Icon.texture:SetTexture(self.Icon:GetTexture())

	NP:StyleFilterUpdate(frame, "FAKE_Casting")
end

function ZNP:Update_CastBarOnShow()
	local frame = self:GetParent().UnitFrame
	local db = NP.db.units[frame.UnitType]

	if db.castbar.enable then
		local healthShown = db.health.enable or (frame.isTarget and NP.db.alwaysShowTargetHealth)
		local noFilter = frame.NameOnlyChanged == nil and frame.IconOnlyChanged == nil

		if healthShown and noFilter then
			resetAttributes(frame.CastBar)
			frame.CastBar:Show()

			NP:Update_CastBar(frame, nil, frame.unit) -- Sometimes resetAttributes ran after Update_CastBar, which was nilling spellName.
			NP:StyleFilterUpdate(frame, "FAKE_Casting")
		end
	end
end

function ZNP:Update_CastBarOnHide()
	local frame = self:GetParent().UnitFrame

	resetAttributes(frame.CastBar)
	frame.CastBar:Hide()

	NP:StyleFilterUpdate(frame, "FAKE_Casting")
end

function ZNP:Update_CastBar(frame, event, unit)
	if frame.CastBar.spellName then return end

	if not (self.db.units[frame.UnitType].castbar.enable and frame.Health:IsShown()) then return end

	if (not event and unit)
	or event == "UNIT_SPELLCAST_START"
	or event == "UNIT_SPELLCAST_CHANNEL_START"
	then
		local name = UnitCastingInfo(unit) or UnitChannelInfo(unit)
		if name then
			frame.CastBar.spellName = name
		end
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		if frame.CastBar:IsShown() then
			frame.CastBar.Name:SetText(event == "UNIT_SPELLCAST_FAILED" and FAILED or INTERRUPTED)
		end
	end
end