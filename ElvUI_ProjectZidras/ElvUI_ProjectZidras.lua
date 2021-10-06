local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local PZ = E:NewModule("ProjectZidras", "LibCompat-1.0")
local EP = E.Libs.EP

local AddOnName = ...

local print = print
local strconcat, format = strconcat, string.format

PZ.BrandHex		= "|cFF00BFFF" -- DeepSkyBlue
PZ.Title 		= format("%sProject Zidras|r", PZ.BrandHex)
PZ.Version		= GetAddOnMetadata(AddOnName, "Version")
PZ.Authors		= GetAddOnMetadata(AddOnName, "Author")
PZ.Credits		= GetAddOnMetadata(AddOnName, "X-Credits")

do
	local color = strconcat(PZ.BrandHex, "%s|r")
	function PZ:Color(name)
		return format(color, name)
	end

	local title = PZ:Color(strconcat(PZ.Title, ":"))
	function PZ:Print(...)
		print(title, ...)
	end
end

function PZ:Initialize()
	ProjectZidrasDB = ProjectZidrasDB or {}

	EP:RegisterPlugin(AddOnName, self.InsertOptions)

	if E.db.general.loginmessage then
		print(format(L["PZ_LOGIN_MSG"], self.Title, self.BrandHex, self.Version, E.media.hexvaluecolor))
	end
end

local function InitializeCallback()
	PZ:Initialize()
end

E:RegisterModule(PZ:GetName(), InitializeCallback)