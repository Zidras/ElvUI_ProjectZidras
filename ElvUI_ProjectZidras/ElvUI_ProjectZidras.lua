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

--Role icons
PZ.rolePaths = {
	["ElvUI"] = {
		TANK = [[Interface\AddOns\ElvUI\Media\Textures\tank]],
		HEALER = [[Interface\AddOns\ElvUI\Media\Textures\healer]],
		DAMAGER = [[Interface\AddOns\ElvUI\Media\Textures\dps]]
	},
	["SupervillainUI"] = {
		TANK = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\svui-tank]],
		HEALER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\svui-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\svui-dps]]
	},
	["Blizzard"] = {
		TANK = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\blizz-tank]],
		HEALER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\blizz-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\blizz-dps]]
	},
	["BlizzardCircle"] = {
		TANK = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\blizz-tank-circle]],
		HEALER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\blizz-healer-circle]],
		DAMAGER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\blizz-dps-circle]]
	},
	["MiirGui"] = {
		TANK = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\mg-tank]],
		HEALER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\mg-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\mg-dps]]
	},
	["Lyn"] = {
		TANK = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\lyn-tank]],
		HEALER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\lyn-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\lyn-dps]]
	},
	["Philmod"] = {
		TANK = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\philmod-tank]],
		HEALER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\philmod-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\philmod-dps]]
	},
	["ReleafUI"] = {
		TANK = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\releaf-tank]],
		HEALER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\releaf-healer]],
		DAMAGER = [[Interface\AddOns\ElvUI_ProjectZidras\Media\Textures\Role\releaf-dps]]
	},
}

-- List of Modules
PZ.ZUF = E:NewModule("ProjectZidras_UnitFrames")

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