local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZUF = PZ.UnitFrames
local UF = E.UnitFrames

local random = math.random
local UnitIsConnected = UnitIsConnected
local hooksecurefunc = hooksecurefunc

local GetUnitRole = T.GetUnitRole

local function dbUpdater(frame)
	if frame then
		local unit = frame.unitframeType
		if unit then
			frame.db.roleIcon = E.db.pz.unitframe.units[unit].roleIcon
		end
	end
end

function ZUF:Construct_RoleIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
	tex:Size(17)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)
	tex.Override = ZUF.UpdateRoleIcon
	frame:RegisterEvent("UNIT_CONNECTION", ZUF.UpdateRoleIcon)

	return tex
end

function ZUF:UpdateRoleIcon(event)
	local lfdrole = self.GroupRoleIndicator
	if not self.db then return end
	local pzdb = E.db.pz.unitframe.general.roleIcons
	local db = self.db.roleIcon

	if not db or not db.enable then
		lfdrole:Hide()
		return
	end

	local role = GetUnitRole(self.unit)
	if self.isForced and role == "NONE" then
		local rnd = random(1, 3)
		role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER"))
	end

	local shouldHide = ((event == "PLAYER_REGEN_DISABLED" and db.combatHide and true) or false)

	if (self.isForced or UnitIsConnected(self.unit)) and ((role == "DAMAGER" and db.damager) or (role == "HEALER" and db.healer) or (role == "TANK" and db.tank)) then
		lfdrole:SetTexture(PZ.rolePaths[pzdb.icons][role])
		if not shouldHide then
			lfdrole:Show()
		else
			lfdrole:Hide()
		end
	else
		lfdrole:Hide()
	end
end

function ZUF:Configure_RoleIcon(frame)
	local role = frame.GroupRoleIndicator
	local db = frame.db

	if not db.roleIcon then
		dbUpdater(frame)
	end

	if db.roleIcon.enable then
		frame:EnableElement("UnitGroupRoleIndicator")
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.roleIcon.attachTo or "Health")

		role:ClearAllPoints()
		role:Point(db.roleIcon.position or "BOTTOMRIGHT", attachPoint, db.roleIcon.position or "BOTTOMRIGHT", db.roleIcon.xOffset or 0, db.roleIcon.yOffset or 0)
		role:Size(db.roleIcon.size or 15)

		if db.roleIcon.combatHide then
			E:RegisterEventForObject("PLAYER_REGEN_ENABLED", frame, ZUF.UpdateRoleIcon)
			E:RegisterEventForObject("PLAYER_REGEN_DISABLED", frame, ZUF.UpdateRoleIcon)
		else
			E:UnregisterEventForObject("PLAYER_REGEN_ENABLED", frame, ZUF.UpdateRoleIcon)
			E:UnregisterEventForObject("PLAYER_REGEN_DISABLED", frame, ZUF.UpdateRoleIcon)
		end
	else
		frame:DisableElement("UnitGroupRoleIndicator")
		role:Hide()
		--Unregister combat hide events
		E:UnregisterEventForObject("PLAYER_REGEN_ENABLED", frame, ZUF.UpdateRoleIcon)
		E:UnregisterEventForObject("PLAYER_REGEN_DISABLED", frame, ZUF.UpdateRoleIcon)
	end
end

UF.Construct_RoleIcon = ZUF.Construct_RoleIcon
UF.UpdateRoleIcon = ZUF.UpdateRoleIcon
UF.Configure_RoleIcon = ZUF.Configure_RoleIcon

hooksecurefunc(UF, "Update_PlayerFrame", function(_, frame)
	dbUpdater(frame)
	if frame and not frame.GroupRoleIndicator then
		frame.GroupRoleIndicator = ZUF:Construct_RoleIcon(frame)
	end
end)
hooksecurefunc(UF, "Update_TargetFrame", function(_, frame)
	dbUpdater(frame)
	if frame and not frame.GroupRoleIndicator then
		frame.GroupRoleIndicator = ZUF:Construct_RoleIcon(frame)
	end
end)
hooksecurefunc(UF, "Update_FocusFrame", function(_, frame)
	dbUpdater(frame)
	if frame and not frame.GroupRoleIndicator then
		frame.GroupRoleIndicator = ZUF:Construct_RoleIcon(frame)
	end
end)
hooksecurefunc(UF, "Update_ArenaFrames", function(_, frame)
	dbUpdater(frame)
	if frame and not frame.GroupRoleIndicator then
		frame.GroupRoleIndicator = ZUF:Construct_RoleIcon(frame)
	end
end)
hooksecurefunc(UF, "Update_Raid40Frames", function(_, frame)
	dbUpdater(frame)
	if frame and not frame.GroupRoleIndicator then
		frame.GroupRoleIndicator = ZUF:Construct_RoleIcon(frame)
	end
end)