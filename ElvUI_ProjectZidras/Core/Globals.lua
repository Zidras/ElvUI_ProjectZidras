local PZ, T, E, L, V, P, G = unpack(select(2, ...))

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