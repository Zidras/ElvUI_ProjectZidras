local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames
local LSM = E.Libs.LSM

local StatusBarPrototype = T.StatusBarPrototype

function ZUF.HealthClipFrame_HealComm(frame)
	if frame.HealCommBar then
		ZUF:SetAlpha_HealComm(frame.HealCommBar, 1)
	end
end

function ZUF:SetAlpha_HealComm(obj, alpha)
	obj.myBar:SetAlpha(alpha)
	obj.otherBar:SetAlpha(alpha)
	obj.absorbBar:SetAlpha(alpha)
	obj.healAbsorbBar:SetAlpha(alpha)
end

function ZUF:SetTexture_HealComm(obj, texture)
	obj.myBar:SetStatusBarTexture(texture)
	obj.otherBar:SetStatusBarTexture(texture)
	obj.absorbBar:SetStatusBarTexture(texture)
	obj.healAbsorbBar:SetStatusBarTexture(texture)
end

function ZUF:SetFrameLevel_HealComm(obj, level)
	obj.myBar:SetFrameLevel(level)
	obj.otherBar:SetFrameLevel(level)
	obj.absorbBar:SetFrameLevel(level)
	obj.healAbsorbBar:SetFrameLevel(level)
end

local function dbUpdater(frame)
	if frame then
		local unit = frame.unitframeType
		if unit then
			frame.db.healPrediction = E.db.pz.unitframe.units[unit].absorbPrediction
		end
	end
end

function ZUF:Construct_HealComm(frame)
	local health = frame.Health
	local parent = health.ClipFrame

	local myBar = StatusBarPrototype(nil, parent)
	local otherBar = StatusBarPrototype(nil, parent)
	local absorbBar = StatusBarPrototype(nil, parent)
	local healAbsorbBar = StatusBarPrototype(nil, parent)
	local overAbsorb = parent:CreateTexture(nil, "OVERLAY")
	local overHealAbsorb = parent:CreateTexture(nil, "OVERLAY")

	local prediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		PostUpdate = ZUF.UpdateHealComm,
		maxOverflow = 1,
		health = health,
		parent = parent,
		frame = frame
	}

	ZUF:SetAlpha_HealComm(prediction, 0)
	ZUF:SetFrameLevel_HealComm(prediction, 12)
	ZUF:SetTexture_HealComm(prediction, E.media.blankTex)
	dbUpdater(frame)
	return prediction
end

function ZUF:SetSize_HealComm(frame)
	local health = frame.Health
	local pred = frame.HealCommBar
	local orientation = health:GetOrientation()

	local db = frame.db.healPrediction
	local width, height = health:GetSize()

	if orientation == "HORIZONTAL" then
		local barHeight = db.height or -1
		if barHeight == -1 or barHeight > height then barHeight = height end

		pred.myBar:SetSize(width, barHeight)
		pred.otherBar:SetSize(width, barHeight)
		pred.healAbsorbBar:SetSize(width, barHeight)
		pred.absorbBar:SetSize(width, barHeight)
		pred.overAbsorb:SetSize(16, barHeight + 5)
		pred.overHealAbsorb:SetSize(16, barHeight + 5)
		pred.parent:SetSize(width * (pred.maxOverflow or 0), height)
	else
		local barWidth = db.height or -1 -- this is really width now not height
		if barWidth == -1 or barWidth > width then barWidth = width end

		pred.myBar:SetSize(barWidth, height)
		pred.otherBar:SetSize(barWidth, height)
		pred.healAbsorbBar:SetSize(barWidth, height)
		pred.absorbBar:SetSize(barWidth, height)
		pred.overAbsorb:SetSize(barWidth + 5, 16)
		pred.overHealAbsorb:SetSize(barWidth + 5, 16)
		pred.parent:SetSize(width, height * (pred.maxOverflow or 0))
	end
end

function ZUF:Configure_HealComm(frame)
	if not (frame.HealCommBar and frame.HealCommBar.absorbBar) then return end -- prevents lua error with ElvUI_Enhanced portrait HD fix option.
	local db = frame.db.healPrediction

	if not db.anchorPoint then
		dbUpdater(frame)
		if db.enable ~= E.db.pz.unitframe.units[frame.unitframeType].absorbPrediction.enable then db.enable = true end -- workaround because RaidGroup1Button1 and PartyGroup1Button1 db.enable were being rewritten to false for some reason
	end

	if db and db.enable then

		local pred = frame.HealCommBar
		local parent = pred.parent
		local myBar = pred.myBar
		local otherBar = pred.otherBar
		local absorbBar = pred.absorbBar
		local healAbsorbBar = pred.healAbsorbBar
		local overAbsorb = pred.overAbsorb
		local overHealAbsorb = pred.overHealAbsorb

		local unit = frame.unitframeType
		db = E.db.pz.unitframe.units[unit].absorbPrediction
		E:Delay(1, dbUpdater, frame) -- workaround to db being overwritten after configure

		local colors = UF.db.colors.healPrediction
		local absorbColors = E.db.pz.unitframe.colors.absorbPrediction
		pred.maxOverflow = 1 + (colors.maxOverflow or 0)

		if not frame:IsElementEnabled("HealthPrediction") then
			frame:EnableElement("HealthPrediction")
		end

		local health = frame.Health
		local orientation = health:GetOrientation()
		local reverseFill = false--[[health:GetReverseFill()]]
		local healthBarTexture = health:GetStatusBarTexture()

		pred.reverseFill = reverseFill
		pred.healthBarTexture = healthBarTexture
		pred.myBarTexture = myBar:GetStatusBarTexture()
		pred.otherBarTexture = otherBar:GetStatusBarTexture()

		ZUF:SetTexture_HealComm(pred, UF.db.colors.transparentHealth and E.media.blankTex or healthBarTexture:GetTexture())

		local absorbTexture = LSM:Fetch("statusbar", db.absorbTexture)
		absorbBar:SetStatusBarTexture(absorbTexture)

		myBar:SetReverseFill(reverseFill)
		otherBar:SetReverseFill(reverseFill)
		healAbsorbBar:SetReverseFill(not reverseFill)

		if db.absorbStyle == "REVERSED" then
			absorbBar:SetReverseFill(not reverseFill)
		else
			absorbBar:SetReverseFill(reverseFill)
		end

		myBar:SetStatusBarColor(colors.personal.r, colors.personal.g, colors.personal.b, colors.personal.a)
		otherBar:SetStatusBarColor(colors.others.r, colors.others.g, colors.others.b, colors.others.a)
		absorbBar:SetStatusBarColor(absorbColors.absorbs.r, absorbColors.absorbs.g, absorbColors.absorbs.b, absorbColors.absorbs.a)
		healAbsorbBar:SetStatusBarColor(absorbColors.healAbsorbs.r, absorbColors.healAbsorbs.g, absorbColors.healAbsorbs.b, absorbColors.healAbsorbs.a)

		myBar:SetOrientation(orientation)
		otherBar:SetOrientation(orientation)
		absorbBar:SetOrientation(orientation)
		healAbsorbBar:SetOrientation(orientation)

		pred.anchor, pred.anchor1, pred.anchor2 = db.anchorPoint or "BOTTOM", "LEFT", "RIGHT"

		if orientation == "HORIZONTAL" then
			local p1 = reverseFill and "RIGHT" or "LEFT"
			local p2 = reverseFill and "LEFT" or "RIGHT"

			local anchor = db.anchorPoint
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			myBar:ClearAllPoints()
			myBar:Point(anchor, health)
			myBar:Point(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:Point(anchor, health)
			otherBar:Point(p1, pred.myBarTexture, p2)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:Point(anchor, health)

			absorbBar:ClearAllPoints()
			absorbBar:Point(anchor, health)

			overAbsorb:ClearAllPoints()
			overAbsorb:Point(p1, health, p2, -7, 0)

			overHealAbsorb:ClearAllPoints()
			overHealAbsorb:Point(p2, health, p1, 7, 0)

			parent:ClearAllPoints()
			parent:Point(p1, health, p1)

			if db.absorbStyle == "REVERSED" then
				absorbBar:Point(p2, healthBarTexture, p2)
			elseif db.absorbStyle == "STACKED" then
				absorbBar:Point(p1, pred.otherBarTexture, p2)
			else
				absorbBar:Point(p1, healthBarTexture, p2)
			end
		else
			local p1 = reverseFill and "TOP" or "BOTTOM"
			local p2 = reverseFill and "BOTTOM" or "TOP"

			-- anchor converts while the health is in vertical orientation to be able to use a height
			-- (well in this case, width) other than -1 which positions the absorb on the left or right side
			local anchor = (db.anchorPoint == "BOTTOM" and "RIGHT") or (db.anchorPoint == "TOP" and "LEFT") or db.anchorPoint
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			myBar:ClearAllPoints()
			myBar:Point(anchor, health)
			myBar:Point(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:Point(anchor, health)
			otherBar:Point(p1, pred.myBarTexture, p2)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:Point(anchor, health)

			absorbBar:ClearAllPoints()
			absorbBar:Point(anchor, health)

			overAbsorb:ClearAllPoints()
			overAbsorb:Point(p1, health, p2, 0, -7)
			overAbsorb:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)

			overHealAbsorb:ClearAllPoints()
			overHealAbsorb:Point(p2, health, p1, 0, 7)
			overHealAbsorb:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)

			parent:ClearAllPoints()
			parent:Point(p1, health, p1)

			if db.absorbStyle == "REVERSED" then
				absorbBar:Point(p2, healthBarTexture, p2)
			elseif db.absorbStyle == "STACKED" then
				absorbBar:Point(p1, pred.otherBarTexture, p2)
			else
				absorbBar:Point(p1, healthBarTexture, p2)
			end
		end
	elseif frame:IsElementEnabled("HealthPrediction") then
		frame:DisableElement("HealthPrediction")
	end
end

function ZUF:UpdateHealComm(_, myIncomingHeal, otherIncomingHeal, absorb, _, hasOverAbsorb, hasOverHealAbsorb, health, maxHealth)
	local frame = self.frame
	local db = frame and frame.db and frame.db.healPrediction
	if not db or not db.absorbStyle or not health then return end

	local pred = frame.HealCommBar
	local healAbsorbBar = pred.healAbsorbBar
	local absorbBar = pred.absorbBar

	if not pred.anchor then
		ZUF:Configure_HealComm(frame) -- workaround to db.enable returning false for some reason on configure_HealComm initial run
	end

	ZUF:SetSize_HealComm(frame)

	-- absorbs is set to none so hide both and kill code execution
	if db.absorbStyle == "NONE" then
		healAbsorbBar:Hide()
		absorbBar:Hide()
		return
	end

	local missingHealth = maxHealth - health
	local healthPostHeal = health + myIncomingHeal + otherIncomingHeal

	-- handle over heal absorbs
	healAbsorbBar:ClearAllPoints()
	healAbsorbBar:Point(pred.anchor, frame.Health)

	local colors = UF.db.colors.healPrediction
	local absorbColors = E.db.pz.unitframe.colors.absorbPrediction
	if hasOverHealAbsorb then -- forward fill it when its greater than health so that you can still see this is being stolen
		healAbsorbBar:SetReverseFill(pred.reverseFill)
		healAbsorbBar:Point(pred.anchor1, pred.healthBarTexture, pred.anchor2)
		healAbsorbBar:SetStatusBarColor(absorbColors.overhealabsorbs.r, absorbColors.overhealabsorbs.g, absorbColors.overhealabsorbs.b, absorbColors.overhealabsorbs.a)
		healAbsorbBar:SetValue(missingHealth) -- workaround to clipframe.
	else -- otherwise just let it backfill so that we know how much is being stolen
		healAbsorbBar:SetReverseFill(not pred.reverseFill)
		healAbsorbBar:Point(pred.anchor2, pred.healthBarTexture, pred.anchor2)
		healAbsorbBar:SetStatusBarColor(absorbColors.healAbsorbs.r, absorbColors.healAbsorbs.g, absorbColors.healAbsorbs.b, absorbColors.healAbsorbs.a)
	end

	-- color absorb bar if in over state
	if hasOverAbsorb then
		absorbBar:SetStatusBarColor(absorbColors.overabsorbs.r, absorbColors.overabsorbs.g, absorbColors.overabsorbs.b, absorbColors.overabsorbs.a)
	else
		absorbBar:SetStatusBarColor(absorbColors.absorbs.r, absorbColors.absorbs.g, absorbColors.absorbs.b, absorbColors.absorbs.a)
	end

	-- if we are in normal mode and overflowing happens we should let a bit show, like blizzard does
	if db.absorbStyle == "NORMAL" then
		if hasOverAbsorb then
			if health == maxHealth then
				absorbBar:SetValue(0)
			elseif health + absorb > maxHealth then -- workaround to clipframe
				absorbBar:SetValue(missingHealth)
			end
		end
	elseif db.absorbStyle == "STACKED" then
		if hasOverAbsorb then
			if health == maxHealth then
				absorbBar:SetValue(0)
			elseif healthPostHeal + absorb > maxHealth then -- workaround to clipframe
				absorbBar:SetValue(maxHealth - healthPostHeal)
			end
		end
	elseif db.absorbStyle == "REVERSED" then
		if absorb > health then
			absorbBar:SetValue(health)
			healAbsorbBar:SetValue(health)
		end
	else
		if hasOverAbsorb then -- non normal mode overflowing
			if db.absorbStyle == "WRAPPED" then -- engage backfilling
				absorbBar:SetReverseFill(not pred.reverseFill)

				absorbBar:ClearAllPoints()
				absorbBar:Point(pred.anchor, pred.health)
				absorbBar:Point(pred.anchor2, pred.health, pred.anchor2)
			elseif db.absorbStyle == "OVERFLOW" then -- we need to display the overflow but adjusting the values
				local overflowAbsorb = absorb * (colors.maxOverflow or 0)
				if health == maxHealth then
					absorbBar:SetValue(overflowAbsorb)
				else -- fill the inner part along with the overflow amount so it smoothly transitions
					absorbBar:SetValue((maxHealth - health) + overflowAbsorb)
				end
			end
		elseif db.absorbStyle == "WRAPPED" then -- restore wrapped to its forward filling state
			absorbBar:SetReverseFill(pred.reverseFill)

			absorbBar:ClearAllPoints()
			absorbBar:Point(pred.anchor, pred.health)
			absorbBar:Point(pred.anchor1, pred.otherBarTexture, pred.anchor2)
		end
	end
end

UF.HealthClipFrame_HealComm = ZUF.HealthClipFrame_HealComm
UF.SetAlpha_HealComm = ZUF.SetAlpha_HealComm
UF.Construct_HealComm = ZUF.Construct_HealComm
UF.Configure_HealComm = ZUF.Configure_HealComm
UF.UpdateHealComm = ZUF.UpdateHealComm

-- Add Tags to ElvUI Options
E:AddTagInfo("incomingheals", PZ:Color("PZ"), L["Displays all incoming heals"])
E:AddTagInfo("incomingheals:personal", PZ:Color("PZ"), L["Displays only personal incoming heals"])
E:AddTagInfo("incomingheals:others", PZ:Color("PZ"), L["Displays only incoming heals from other units"])
E:AddTagInfo("absorbs", PZ:Color("PZ"), L["Displays the amount of absorbs"])