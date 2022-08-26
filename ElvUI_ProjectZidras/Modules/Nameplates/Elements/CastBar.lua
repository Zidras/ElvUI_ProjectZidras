local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZNP = PZ.NamePlates
local NP = E.NamePlates

local abs = math.abs
local format = string.format

local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local FAILED = FAILED
local INTERRUPTED = INTERRUPTED
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local function resetAttributes(self)
	self.casting = nil
	self.channeling = nil
	self.notInterruptible = nil
	self.spellName = nil
end

local function spellNameWithUnit(self, frame, spellName, sourceUnitTarget)
	if not E.db.pz.nameplates.tags.displayTarget.enable then return spellName end

	local sourceUnitTargetName = UnitName(sourceUnitTarget)

	if not sourceUnitTargetName then return spellName end

	if UnitIsPlayer(sourceUnitTarget) then
		local _, englishClass = UnitClass(sourceUnitTarget)
		local classColorTable = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[englishClass] or RAID_CLASS_COLORS[englishClass]

		if classColorTable then
			return format("%s > \124cff%.2x%.2x%.2x%s\124r", spellName, classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, sourceUnitTargetName)
		end
	else
		local db = self.db.colors
		local unitReaction = UnitReaction(frame.unit, sourceUnitTarget)
		local r, g, b
		if unitReaction == 5 then -- friendly
			r, g, b = db.reactions.good.r, db.reactions.good.g, db.reactions.good.b
		elseif unitReaction == 1 or unitReaction == 2 then -- hostile
			r, g, b = db.reactions.bad.r, db.reactions.bad.g, db.reactions.bad.b
		elseif unitReaction == 4  then -- neutral
			r, g, b = db.reactions.neutral.r, db.reactions.neutral.g, db.reactions.neutral.b
		else
			r, g, b = 1, 1, 1
		end

		return format("%s > \124cff%.2x%.2x%.2x%s\124r", spellName, r*255, g*255, b*255, sourceUnitTargetName)
	end
end

function ZNP:Update_CastBarOnValueChanged(value)
	local frame = self:GetParent().UnitFrame
	if not frame.UnitType then return end

	if frame.oldCastBar and frame.oldCastBar.Icon:IsShown() then -- Instead of SetParent to E.HiddenFrame, workaround it by hiding it here. This is necessary because SetParent will change Region count and thus break Weakauras findNewPlate.
		frame.oldCastBar.Icon:Hide() -- Keep this before db checks, since NameOnly doesn't have a ElvUI castbar but still needs to hide Blizzard NP castbar icon.
	end

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

	if not castBar:IsShown() then -- First cast of a nameplate gets hidden somewhere in the chain of execution, so re-check visibility here and correct it.
		castBar:Show()
	end

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

function ZNP:Update_CastBar(frame, event, unit, forceCheck)
	if frame.CastBar.spellName and not forceCheck then return end

	if not (self.db.units[frame.UnitType].castbar.enable and frame.Health:IsShown()) then return end

	if (not event and unit)
	or event == "UNIT_SPELLCAST_START"
	or event == "UNIT_SPELLCAST_CHANNEL_START"
	then
		local name = UnitCastingInfo(unit) or UnitChannelInfo(unit)
		if name then
			frame.CastBar.spellName = spellNameWithUnit(self, frame, name, unit.."target")
		end
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		if frame.CastBar:IsShown() then
			frame.CastBar.Name:SetText(event == "UNIT_SPELLCAST_FAILED" and FAILED or INTERRUPTED)
		end
	end
end

function ZNP:Configure_CastBar(frame)
	local castBar = frame.CastBar
	castBar.Name:SetPoint("BOTTOMRIGHT", castBar.Time, "BOTTOMLEFT") -- prevent overlap by making spellName elide with ...
end