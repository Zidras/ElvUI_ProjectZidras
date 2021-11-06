local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZCH = PZ.Chat
local CH = E.Chat
local LGT = LibStub("LibGroupTalents-1.0")

local strsplit, gsub = strsplit, string.gsub
local wipe = wipe

local IsInGuild, GetNumGuildMembers, GetGuildRosterInfo = IsInGuild, GetNumGuildMembers, GetGuildRosterInfo
local UnitIsUnit, UnitName = UnitIsUnit, UnitName

local IsInGroup = T.IsInGroup
local GetUnitRole = T.GetUnitRole
local UnitIterator = T.UnitIterator

local roleIcons = {
	TANK = E:TextureString(E.Media.Textures.Tank, ":20:20:0:0:64:64:2:56:2:56"),
	HEALER = E:TextureString(E.Media.Textures.Healer, ":20:20:0:0:64:64:2:56:2:56"),
	DAMAGER = E:TextureString(E.Media.Textures.DPS, ":20:20")
}
local lfgRoles = {}
local leader = [[|TInterface\GroupFrame\UI-Group-LeaderIcon:20:20|t]]
local guildMaster = ""
local gmName = ""
local gmRealm = ""
local playerRealm = strmatch(E.myrealm, "%s*(%S+)$")
local playerName = E.myname.."-"..playerRealm
local specialChatIcons

do
	local y = ":20:20"
	local ElvZidras	= E:TextureString("Interface\\AddOns\\ElvUI_ProjectZidras\\Media\\Textures\\Chat\\Chat_ZidrasLogo", y)

	-- Zidras
	specialChatIcons = {
		["Icecrown"] = {
			["Zidras"]		= ElvZidras,
			["Sidras"]		= ElvZidras,
			["Sidraz"]		= ElvZidras,
			["Ziidras"]		= ElvZidras,
			["Strongbows"]	= ElvZidras,
			["Zidra"]		= ElvZidras,
			["Zidraz"]		= ElvZidras,
			["Izidru"]		= ElvZidras,
			["Baard"]		= ElvZidras,
		},
		["Lordaeron"] = {
			["Zidras"]		= ElvZidras,
		},
		["Truth"] = {
			["Zidras"]		= ElvZidras,
		},
	}
end

local function GetChatIcon(sender)
	if not specialChatIcons then
		specialChatIcons = specialChatIcons
	end
	local senderName, senderRealm, icon
	if sender then
		senderName, senderRealm = strsplit("-", sender)
	else
		senderName = E.myname
	end
	senderRealm = senderRealm or playerRealm
	senderRealm = gsub(senderRealm, " ", "")

	if specialChatIcons and specialChatIcons[senderRealm] and specialChatIcons[senderRealm][senderName] then
		icon = specialChatIcons[senderRealm][senderName]
	end
	if IsInGuild() and E.db.pz.chat.guildmaster then
		if senderName == gmName and senderRealm == gmRealm then icon = icon and (leader..icon) or leader end
	end
	local lfgRole = lfgRoles[sender]
	if lfgRole and E.db.pz.chat.lfgIcons  then
		icon = icon and icon..lfgRole or lfgRole
	end
	return icon
end

function ZCH:GMCheck()
	if GetNumGuildMembers() == 0 and IsInGuild() then E:Delay(2, ZCH.GMCheck) return end
	if not IsInGuild() then guildMaster = ""; gmName = ""; gmRealm = ""; return end
	for i = 1, GetNumGuildMembers() do
		local name, _, rank = GetGuildRosterInfo(i)
		if rank == 0 then guildMaster = name break end
	end

	if guildMaster then gmName, gmRealm = strsplit("-", guildMaster) end
	gmRealm = gmRealm or playerRealm
end

local function roster(_, update)
	if update then ZCH:GMCheck() end
end

function ZCH:GMIconUpdate()
	if E.private.chat.enable ~= true then return end
	if E.db.pz.chat.guildmaster then
		self:RegisterEvent("GUILD_ROSTER_UPDATE", roster)
		ZCH:GMCheck()
	else
		self:UnregisterEvent("GUILD_ROSTER_UPDATE")
		guildMaster, gmName, gmRealm = "", "", ""
	end
end

function ZCH:CheckLFGRoles()
	if not E.db.pz.chat.lfgIcons or not IsInGroup() then wipe(lfgRoles) return end

	wipe(lfgRoles)

	local playerRole = GetUnitRole()
	if playerRole then
		lfgRoles[playerName] = roleIcons[playerRole]
	end

	for unit, owner in UnitIterator() do
		if owner == nil and not UnitIsUnit(unit, "player") then
			local role = GetUnitRole(unit)
			local name, realm = UnitName(unit)
			if realm then
				realm = strmatch(realm, "%s*(%S+)$")
			end
			if role and name then
				name = (realm and realm ~= "" and name.."-"..realm) or name.."-"..playerRealm

				lfgRoles[name] = roleIcons[role]
			end
		end
	end
end

function ZCH:ChangeRole(_, _, unit)
	local name, realm = UnitName(unit)
	if name then
		name = (realm and realm ~= "" and name.."-"..realm) or name.."-"..playerRealm
		lfgRoles[name] = roleIcons[GetUnitRole(unit)]
	end
end

function ZCH:ForUpdateAll()
	self:GMIconUpdate()
end

function ZCH:Initialize()
	if not E.private.chat.enable then return end

	self:ForUpdateAll()

	if E.db.pz.chat.guildmaster then
		self:RegisterEvent("GUILD_ROSTER_UPDATE", roster)
		E:Delay(0.1, self.GMCheck)
	end
	if E.db.pz.chat.lfgIcons then
		self:RegisterEvent("RAID_ROSTER_UPDATE", "CheckLFGRoles")
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", "CheckLFGRoles")
		LGT.RegisterCallback(ZCH, "LibGroupTalents_RoleChange", "ChangeRole")

		E:Delay(0.1, self.CheckLFGRoles)
	end
end

local function InitializeCallback()
	ZCH:Initialize()
end

CH:AddPluginIcons(GetChatIcon)

E:RegisterModule(ZCH:GetName(), InitializeCallback)