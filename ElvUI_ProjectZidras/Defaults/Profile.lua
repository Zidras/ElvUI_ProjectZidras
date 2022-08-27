local PZ, T, E, L, V, P, G = unpack(select(2, ...))

local ZUF_AbsorbPrediction = {
	enable = true,
	absorbStyle = "REVERSED",
	anchorPoint = "BOTTOM",
	absorbTexture = "ElvUI Norm",
	absorbOverlay = "None",
	height = -1
}

local ZUF_RoleIcon = {
	enable = false,
	position = "BOTTOMRIGHT",
	attachTo = "Health",
	xOffset = 0,
	yOffset = 0,
	size = 15,
	tank = true,
	healer = true,
	damager = true,
	combatHide = false,
}

P.pz = {
	chat = {
		guildmaster = true,
		lfgIcons = true,
	},
	nameplates = {
		hdClient = {
			hdNameplates = false,
		},
		tags = {
			guid = {
				enable = false,
				position = "BOTTOM",
				parent = "Health",
				font = "PT Sans Narrow",
				fontSize = 12,
				fontOutline = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
			},
			unit = {
				enable = false,
				position = "RIGHT",
				parent = "Health",
				font = "PT Sans Narrow",
				fontSize = 10,
				fontOutline = "OUTLINE",
				xOffset = 0,
				yOffset = 0,
			},
			title = {
				enable = false,
			},
			displayTarget = {
				enable = false,
				separator = ">",
				friendlyPlayer = false,
				friendlyNPC = true,
				enemyPlayer = false,
				enemyNPC = true,
			},
		}
	},
	unitframe = {
		general = {
			roleIcons = {
				icons = "ElvUI",
			}
		},
		colors = {
			absorbPrediction = {
				absorbs = {r = 0, g = 1, b = 1, a = 1},
				healAbsorbs = {r = 1, g = 0, b = 0, a = 0.25},
				overabsorbs = {r = 0, g = 1, b = 1, a = 1},
				overhealabsorbs = {r = 1, g = 0, b = 0, a = 0.25},
			}
		},
		units = {
			player = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
				roleIcon = CopyTable(ZUF_RoleIcon),
			},
			target = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
				roleIcon = CopyTable(ZUF_RoleIcon),
			},
			focus = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
				roleIcon = CopyTable(ZUF_RoleIcon),
			},
			pet = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			arena = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
				roleIcon = CopyTable(ZUF_RoleIcon),
			},
			party = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			raid = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			raid40 = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
				roleIcon = CopyTable(ZUF_RoleIcon),
			},
			raidpet = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
		}
	}
}