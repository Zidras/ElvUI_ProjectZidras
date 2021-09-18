local E, L, V, P, G = unpack(ElvUI)
local PZ = E:GetModule("ProjectZidras")

--GLOBALS: unpack, format
local format = string.format

--* Leave here as there is no need for translation
L["ELVUI_PZ_CODERS"] = [[Apollyon
Loaal
Inmortalz
Empress
Kader]]

local function NamePlatesOptions()
	return {
		type = "group",
		name = L["NamePlates"],
		get = function(info) return E.db.pz.nameplates[info[#info]] end,
		args = {
			header = {
				order = 0,
				type = "header",
				name = L["NamePlates"]
			},
			hdClient = {
				order = 1,
				type = "description",
				name = L["HD-Client"]
			},
			hdNameplates = {
				order = 2,
				type = "toggle",
				name = L["HD-Nameplates"],
				desc = L["HD-Nameplates_DESC"],
				set = function(info, value)
					E.db.pz.nameplates[info[#info]] = value
					E:StaticPopup_Show("PRIVATE_RL")
				end
			},
		}
	}
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
					namePlatesGroup = NamePlatesOptions(),
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