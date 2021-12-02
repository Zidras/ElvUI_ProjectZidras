local PZ, T, E, L, V, P, G = unpack(select(2, ...))
local ZCH = PZ.Chat
local UF = E.UnitFrames
local ACH = LibStub("LibAceConfigHelper")

--GLOBALS: unpack, format
local format = string.format
local wipe = wipe

--* Leave here as there is no need for translation
L["ELVUI_PZ_DONORS"] = [[Inmortalz
Volke]]

L["ELVUI_PZ_CODERS"] = [[Apollyon
Loaal
Inmortalz
Empress
Kader
Alchem1ster]]

local roleValues = {}

local positionValues = {
	TOPLEFT = "TOPLEFT",
	LEFT = "LEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	RIGHT = "RIGHT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM"
}

local attachToValues = {
	Health = L["Health"],
	Power = L["Power"],
	InfoPanel = L["Information Panel"],
	Frame = L["Frame"],
}

local function ChatOptions()
	local config = ACH:Group(L["Chat"], nil, 1, nil, function(info) return E.db.pz.chat[info[#info]] end)
	config.args.header = ACH:Header(L["Chat"], 0)
	config.args.guildmaster = ACH:Toggle(L["Guild Master Icon"], L["Displays an icon near your Guild Master in chat.\n\n|cffFF0000Note:|r Some messages in chat history may disappear on login."], 1, nil, nil, nil, nil, function(self, value)	E.db.pz.chat.guildmaster = value ZCH:GMIconUpdate()	end)
	config.args.lfgIcons = ACH:Toggle(L["Role Icon"], L["Display LFG Icons in chat."], 2, nil, nil, nil, nil, function(self, value)	E.db.pz.chat.lfgIcons = value ZCH:CheckLFGRoles() end)

	return config
end

local function NamePlatesOptions()
	local config = ACH:Group(L["NamePlates"], nil, 2, nil, function(info) return E.db.pz.nameplates[info[#info]] end)
	config.args.header = ACH:Header(L["NamePlates"], 0)
	config.args.hdClient = ACH:Description(L["HD-Client"], 1)
	config.args.hdNameplates = ACH:Toggle(L["HD-Nameplates"], L["HD-Nameplates_DESC"], 2, nil, nil, 100, nil, function(info, value) E.db.pz.nameplates[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end)

	return config
end

local function GetOptionsTable_AbsorbPrediction(updateFunc, groupName, numGroup, subGroup)
	local config = ACH:Group(L["Absorbs Prediction"], L["Show a prediction bar with all absorbs on the unitframe. Also displays a slightly different colored bar for heal absorbing shields"], nil, nil, function(info) return E.db.pz.unitframe.units[groupName].absorbPrediction[info[#info]] end, function(info, value) E.db.pz.unitframe.units[groupName].absorbPrediction[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 1)
	config.args.height = ACH:Range(L["Height"], nil, 2, { min = -1, max = 500, step = 1 })
	config.args.colorsButton = ACH:Execute(L["COLORS"], nil, 3, function() E.Libs.AceConfigDialog:SelectGroup("ElvUI", "PZ", "modules", "unitFramesGroup", "colors", "absorbPrediction") end)
	config.args.anchorPoint = ACH:Select(L["Anchor Point"], nil, 4, { TOP = "TOP", BOTTOM = "BOTTOM", CENTER = "CENTER" })
	config.args.absorbStyle = ACH:Select(L["Absorb Style"], nil, 5, { NONE = L["NONE"], NORMAL = L["Normal"], REVERSED = L["Reversed"], WRAPPED = L["Wrapped"], OVERFLOW = L["Overflow"], STACKED = L["Stacked"] })
	config.args.overflowButton = ACH:Execute(L["Max Overflow"], nil, 6, function() E.Libs.AceConfigDialog:SelectGroup("ElvUI", "unitframe", "generalOptionsGroup", "allColorsGroup", "healPrediction") end)
	config.args.absorbTexture = ACH:SharedMediaStatusbar(L["Absorb StatusBar Texture"], nil, 7)
	config.args.warning = ACH:Description(function()
				if UF.db.colors.healPrediction.maxOverflow == 0 then
					local text = L["Max Overflow is set to zero. Absorb Overflows will be hidden when using Overflow style.\nIf used together Max Overflow at zero and Overflow mode will act like Normal mode without the ending sliver of overflow."]
					return text .. (E.db.pz.unitframe.units[groupName].absorbPrediction.absorbStyle == "OVERFLOW" and (" |cffFF9933" .. L["You are using Overflow with Max Overflow at zero."] .. "|r ") or "")
				end
			end, 50, "medium", nil, nil, nil, nil, "full")

	if subGroup then
		config.inline = true
		config.get = function(info) return E.db.pz.unitframe.units[groupName][subGroup].absorbPrediction[info[#info]] end
		config.set = function(info, value) E.db.pz.unitframe.units[groupName][subGroup].absorbPrediction[info[#info]] = value updateFunc(UF, groupName, numGroup) end
	end

	return config
end

local function GetOptionsTable_RoleIcons(updateFunc, groupName, numGroup)
	local config = ACH:Group(L["Role Icon"], nil, nil, nil, function(info) return E.db.pz.unitframe.units[groupName].roleIcon[info[#info]] end, function(info, value) E.db.pz.unitframe.units[groupName].roleIcon[info[#info]] = value updateFunc(UF, groupName, numGroup) end)
	config.args.enable = ACH:Toggle(L["Enable"], nil, 0)
	config.args.options = ACH:MultiSelect(' ', nil, 1, { tank = L["Show For Tanks"], healer = L["Show For Healers"], damager = L["Show For DPS"], combatHide = L["Hide In Combat"] }, nil, nil, function(_, key) return E.db.pz.unitframe.units[groupName].roleIcon[key] end, function(_, key, value) E.db.pz.unitframe.units[groupName].roleIcon[key] = value updateFunc(UF, groupName, numGroup) end)
	config.args.position = ACH:Select(L["Position"], nil, 2, positionValues)
	config.args.attachTo = ACH:Select(L["Attach To"], L["The object you want to attach to."], 4, attachToValues)
	config.args.size = ACH:Range(L["Size"], nil, 5, { min = 8, max = 60, step = 1 })
	config.args.xOffset = ACH:Range(L["X-Offset"], nil, 6, { min = -300, max = 300, step = 1 })
	config.args.yOffset = ACH:Range(L["Y-Offset"], nil, 7, { min = -300, max = 300, step = 1 })

	return config
end

local function RoleIconValues()
	wipe(roleValues)
	for name, path in pairs(PZ.rolePaths) do
		roleValues[name] = name..' |T'..path['TANK']..':15:15:0:0:64:64:2:56:2:56|t '..'|T'..path['HEALER']..':15:15:0:0:64:64:2:56:2:56|t '..'|T'..path['DAMAGER']..':15:15:0:0:64:64:2:56:2:56|t '
	end

	return roleValues
end

local function UnitFramesOptions()
	local config = ACH:Group(L["UnitFrames"], nil, 3, "tab", function(info) return E.db.pz.unitframe[info[#info]] end, function(info, value) E.db.pz.unitframe[info[#info]] = value end, function() return not E.private.unitframe.enable end)
	config.args.desc = ACH:Description(L["Options for customizing unit frames. Please don't change these setting when ElvUI's testing frames for bosses and arena teams are shown. That will make them invisible until retoggling."], 1)

	config.args.general = ACH:Group(L["General"], nil, 1, "tab")
	config.args.general.args.roleIcons = ACH:Group(L["Role Icon"], nil, 1, nil, function(info) return E.db.pz.unitframe.general[info[#info-1]][info[#info]] end, function(info, value) E.db.pz.unitframe.general[info[#info-1]][info[#info]] = value UF:Update_AllFrames() end)
	config.args.general.args.roleIcons.inline = true
	config.args.general.args.roleIcons.args.icons = ACH:Select(L["LFG Icons"], nil, 2, RoleIconValues)

	config.args.colors = ACH:Group(L["COLORS"], nil, 2, "tree", function(info) return E.db.pz.unitframe.colors[info[#info]] end, function(info, value) E.db.pz.unitframe.colors[info[#info]] = value UF:Update_AllFrames() end, function() return not E.UnitFrames.Initialized end)
	config.args.colors.args.absorbPrediction = ACH:Group(L["Absorbs Prediction"], nil, 1, nil, function(info)
		if info.type == "color" then
			local t, d = E.db.pz.unitframe.colors.absorbPrediction[info[#info]], P.pz.unitframe.colors.absorbPrediction[info[#info]]
			return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
		else
			return E.db.pz.unitframe.colors.absorbPrediction[info[#info]]
		end
	end,
	function(info, ...)
		if info.type == "color" then
			local r, g, b, a = ...
			local t = E.db.pz.unitframe.colors.absorbPrediction[info[#info]]
			t.r, t.g, t.b, t.a = r, g, b, a
		else
			local value = ...
			E.db.pz.unitframe.colors.absorbPrediction[info[#info]] = value
		end

		UF:Update_AllFrames()
	end)
	local colorsAbsorbPrediction = config.args.colors.args.absorbPrediction.args
	colorsAbsorbPrediction.absorbs = ACH:Color(L["Absorbs"], nil, 2, true)
	colorsAbsorbPrediction.healAbsorbs = ACH:Color(L["Heal Absorbs"], nil, 2, true)
	colorsAbsorbPrediction.overabsorbs = ACH:Color(L["Over Absorbs"], nil, 3, true)
	colorsAbsorbPrediction.overhealabsorbs = ACH:Color(L["Over Heal Absorbs"], nil, 4, true)

	config.args.individualUnits = ACH:Group(L["Individual Units"], nil, 3, "tab", nil, nil, function() return not E.UnitFrames.Initialized end)
	local individualUnits = config.args.individualUnits.args
	individualUnits.player = ACH:Group(L["Player"], nil, 1, nil, function(info) return E.db.unitframe.units.player[info[#info]] end, function(info, value) E.db.unitframe.units.player[info[#info]] = value UF:CreateAndUpdateUF("player") end)
	individualUnits.player.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateUF, "player")
	individualUnits.player.args.roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateUF, "player")
	individualUnits.target = ACH:Group(L["Target"], nil, 2, nil, function(info) return E.db.unitframe.units.target[info[#info]] end, function(info, value) E.db.unitframe.units.target[info[#info]] = value UF:CreateAndUpdateUF("target") end)
	individualUnits.target.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateUF, "target")
	individualUnits.target.args.roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateUF, "target")
	individualUnits.focus = ACH:Group(L["Focus"], nil, 5, nil, function(info) return E.db.unitframe.units.focus[info[#info]] end, function(info, value) E.db.unitframe.units.focus[info[#info]] = value UF:CreateAndUpdateUF("focus") end)
	individualUnits.focus.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateUF, "focus")
	individualUnits.focus.args.roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateUF, "focus")
	individualUnits.pet = ACH:Group(L["Pet"], nil, 7, nil, function(info) return E.db.unitframe.units.pet[info[#info]] end, function(info, value) E.db.unitframe.units.pet[info[#info]] = value UF:CreateAndUpdateUF("pet") end)
	individualUnits.pet.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateUF, "pet")

	config.args.groupUnits = ACH:Group(L["Group Units"], nil, 4, "tab", nil, nil, function() return not E.UnitFrames.Initialized end)
	local groupUnits = config.args.groupUnits.args
	groupUnits.arena = ACH:Group(L["Arena"], nil, 1, nil, function(info) return E.db.unitframe.units.arena[info[#info]] end, function(info, value) E.db.unitframe.units.arena[info[#info]] = value UF:CreateAndUpdateUFGroup("arena", 5) end)
	groupUnits.arena.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateUFGroup, "arena", 5)
	groupUnits.arena.args.roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateUFGroup, "arena", 5)
	groupUnits.party = ACH:Group(L["Party"], nil, 2, nil, function(info) return E.db.unitframe.units.party[info[#info]] end, function(info, value) E.db.unitframe.units.party[info[#info]] = value UF:CreateAndUpdateHeaderGroup("party") end)
	groupUnits.party.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateHeaderGroup, "party")
	groupUnits.raid = ACH:Group(L["Raid"], nil, 3, nil, function(info) return E.db.unitframe.units.raid[info[#info]] end, function(info, value) E.db.unitframe.units.raid[info[#info]] = value UF:CreateAndUpdateHeaderGroup("raid") end)
	groupUnits.raid.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateHeaderGroup, "raid")
	groupUnits.raid40 = ACH:Group(L["Raid-40"], nil, 4, nil, function(info) return E.db.unitframe.units.raid40[info[#info]] end, function(info, value) E.db.unitframe.units.raid40[info[#info]] = value UF:CreateAndUpdateHeaderGroup("raid40") end)
	groupUnits.raid40.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateHeaderGroup, "raid40")
	groupUnits.raid40.args.roleIcon = GetOptionsTable_RoleIcons(UF.CreateAndUpdateHeaderGroup, "raid40")
	groupUnits.raidpet = ACH:Group(L["Raid Pet"], nil, 5, nil, function(info) return E.db.unitframe.units.raidpet[info[#info]] end, function(info, value) E.db.unitframe.units.raidpet[info[#info]] = value UF:CreateAndUpdateHeaderGroup("raidpet") end)
	groupUnits.raidpet.args.absorbPrediction = GetOptionsTable_AbsorbPrediction(UF.CreateAndUpdateHeaderGroup, "raidpet")

	return config
end

function PZ:InsertOptions()
	E.Options.name = E.Options.name.." + "..format("%s: |cff99ff33%s|r", PZ.Title, PZ.Version)

	local function CreateQuestion(i, text)
		local question = {
			type = "group", name = "", order = i, guiInline = true,
			args = {
				q = { order = 1, type = "description", fontSize = "medium", name = text },
			},
		}
		return question
	end

	--Main options group
	E.Options.args.PZ = {
		order = 1,
		type = "group",
		childGroups = "tab",
		name = PZ.Title,
		desc = L["Plugin for |cff1784d1ElvUI|r by Zidras."],
		args = {
			header = {
				order = 1,
				type = "header",
				name = format("|cff99ff33%s|r", PZ.Version)
			},
			logo = {
				type = "description",
				name = "",
				order = 2,
				image = function() return "Interface\\AddOns\\ElvUI_ProjectZidras\\Media\\Textures\\ProjectZidras_Logo.tga", 256, 64 end,
			},
			modules = {
				order = 10,
				type = "group",
				name = L["Modules"],
				args = {
					--* Modules are added here
					chatGroup = ChatOptions(),
					namePlatesGroup = NamePlatesOptions(),
					unitFramesGroup = UnitFramesOptions(),
				},
			},
			help = {
				type = "group",
				name = L["About/Help"]..[[ |TInterface\MINIMAP\TRACKING\OBJECTICONS:18:18:0:0:256:64:60:90:32:64|t]],
				order = 90,
				childGroups = "tab",
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["About/Help"]
					},
					about = {
						type = "group", name = L["About"].." "..E.NewSign, order = 2,
						args = {
							content = {
								order = 2,
								type = "description",
								name = "\n"..L["PZ_DESC"],
								fontSize = "medium"
							},
						},
					},
					faq = {
						type = "group",
						name = [[FAQ |TInterface\MINIMAP\TRACKING\OBJECTICONS:18:18:0:0:256:64:60:90:32:64|t]],
						order = 5,
						childGroups = "select",
						args = {
							desc = {
								order = 1,
								type = "description",
								name = L["FAQ_DESC"],
								fontSize = "medium"
							},
							elvui = {
								type = "group", order = 10, name = "ElvUI",
								args = {
									q1 = CreateQuestion(1, L["FAQ_Elv_1"]),
									q2 = CreateQuestion(2, L["FAQ_Elv_2"]),
									q3 = CreateQuestion(3, L["FAQ_Elv_3"]),
									q4 = CreateQuestion(4, L["FAQ_Elv_4"]),
									q5 = CreateQuestion(5, L["FAQ_Elv_5"]),
								},
							},
							pz = {
								type = "group", order = 20, name = "Project Zidras",
								args = {
									q1 = CreateQuestion(1, L["FAQ_pz_1"]),
									q2 = CreateQuestion(2, L["FAQ_pz_2"]),
									q3 = CreateQuestion(3, L["FAQ_pz_3"]),
									q4 = CreateQuestion(4, L["FAQ_pz_4"]),
									q5 = CreateQuestion(5, L["FAQ_pz_5"]),
								},
							},
						},
					},
					links = {
						type = "group",
						name = L["Links"]..[[ |TInterface\MINIMAP\TRACKING\FlightMaster:16:16|t]],
						order = 10,
						args = {
							desc = {
								order = 1,
								type = "description",
								name = L["LINK_DESC"],
								fontSize = "medium"
							},
							githublink = {
								order = 2, type = "input", width = "full", name = L["GitHub Link / Report Errors"],
								get = function() return "https://github.com/Zidras/ElvUI_ProjectZidras" end,
							},
							discord = {
								order = 3, type = "input", width = "full", name = L["Discord"],
								get = function() return "https://discord.gg/CyVWDWS" end,
							},
						},
					},
					patrons = {
						order = 100,
						type = "group",
						name = L["Donators"]..[[ |TInterface\BUTTONS\UI-GroupLoot-Coin-Up:16:16|t]],
						args = {
							header = {
								order = 1,
								type = "header",
								name = L["Donators"]
							},
							donators = {
								order = 2,
								type = "group",
								guiInline = true,
								name = L["Donators"],
								args = {
									desc = {
										order = 1,
										type = "description",
										name = L["ELVUI_PZ_DONORS_TITLE"].."\n",
									},
									list = {
										order = 2,
										type = "description",
										name = L["ELVUI_PZ_DONORS"],
										width = "half"
									},
								},
							},
						},
					},
					credits = {
						order = 400,
						type = "group",
						name = L["Credits"]..[[ |TInterface\AddOns\ElvUI_ProjectZidras\Media\Textures\Chat\Chat_Test:14:14|t]],
						args = {
							header = {
								order = 1,
								type = "header",
								name = L["Credits"]
							},
							desc = {
								order = 2,
								type = "description",
								name = L["ELVUI_PZ_CREDITS"].."\n",
							},
							coding = {
								order = 3,
								type = "group",
								guiInline = true,
								name = L["Submodules and Coding:"],
								args = {
									list = {
										order = 1,
										type = "description",
										name = L["ELVUI_PZ_CODERS"],
									},
								},
							},
						},
					},
				},
			},
		},
	}
end