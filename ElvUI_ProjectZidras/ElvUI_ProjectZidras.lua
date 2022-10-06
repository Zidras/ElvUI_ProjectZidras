local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:GetLocale("ElvUI", E.global.general.locale)
local AddOnName, Engine = ...
local _G = _G

local PZ = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")
local EP = E.Libs.EP

local print = print
local format = string.format

PZ.BrandHex		= "|cFF00BFFF" -- DeepSkyBlue
PZ.Title 		= format("%sProject Zidras|r", PZ.BrandHex)
PZ.Version		= GetAddOnMetadata(AddOnName, "Version")
PZ.Authors		= GetAddOnMetadata(AddOnName, "Author")
PZ.Credits		= GetAddOnMetadata(AddOnName, "X-Credits")

--Creating a toolkit table
local Toolkit = E:CopyTable({}, Engine.Compat) --adding Compat into the Toolkit

--Setting up table to unpack
Engine[1] = PZ
Engine[2] = Toolkit
Engine[3] = E
Engine[4] = L
Engine[5] = V
Engine[6] = P
Engine[7] = G
_G[AddOnName] = Engine

-- List of Modules
PZ.Chat = E:NewModule("ProjectZidras_Chat", "AceEvent-3.0")
PZ.NamePlates = E:NewModule("ProjectZidras_NamePlates", "AceEvent-3.0", "AceHook-3.0")
PZ.UnitFrames = E:NewModule("ProjectZidras_UnitFrames")
PZ.WrathArmory = E:NewModule("ProjectZidras_WrathArmory", "AceEvent-3.0", "AceHook-3.0")

-- Database Conversion
local function databaseConversions()
	--Profile options conversion
	for _, data in pairs(ElvDB.profiles) do
		if data then
			if data.pz then
				if data.pz.nameplates then
					if data.pz.nameplates.hdNameplates then
						if data.pz.nameplates.hdClient then
							data.pz.nameplates.hdClient.hdNameplates = data.pz.nameplates.hdNameplates
						else
							data.pz.nameplates.hdClient = {
								hdNameplates = data.pz.nameplates.hdNameplates
							}
						end
						data.pz.nameplates.hdNameplates = nil
					end
				end
			end
		end
	end
end

function PZ:Initialize()
	ProjectZidrasDB = ProjectZidrasDB or {}
	databaseConversions()

	EP:RegisterPlugin(AddOnName, self.InsertOptions)

	if E.db.general.loginmessage then
		print(format(L["PZ_LOGIN_MSG"], self.Title, self.BrandHex, self.Version, E.media.hexvaluecolor))
	end
end

EP:HookInitialize(PZ, PZ.Initialize)