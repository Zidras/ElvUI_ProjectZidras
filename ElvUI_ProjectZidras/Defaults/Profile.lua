local PZ, T, E, L, V, P, G = unpack(select(2, ...))

local ZUF_AbsorbPrediction = {
	enable = true,
	absorbStyle = "REVERSED",
	anchorPoint = "BOTTOM",
	absorbTexture = "ElvUI Norm",
	absorbOverlay = "None",
	height = -1,
	overAbsorb = true,
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

local SharedFontOptions = {
	enable = true,
	font = "PT Sans Narrow",
	fontSize = 12,
	fontOutline = "OUTLINE",
	xOffset = 0,
	yOffset = 0,
	color = {r = 0.99, g = 0.81, b = 0},
	qualityColor = false,
}

local SharedGemOptions = {
	enable = true,
	size = 14,
	xOffset = 3,
	yOffset = 0,
	spacing = 2,
	MainHandSlot = {
		xOffset = -2,
		yOffset = 0,
	},
	SecondaryHandSlot = {
		xOffset = 0,
		yOffset = 2,
	},
	RangedSlot = {
		xOffset = 2,
		yOffset = 0,
	},
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
		allUnits = {
			healPrediction = {
				lookAhead = 5,
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
	},
	wratharmory = {
		enable = true,
		character = {
			enable = true,
			enchant = CopyTable(SharedFontOptions),
			gems = CopyTable(SharedGemOptions),
		},
		inspect = {
			enable = true,
			enchant = CopyTable(SharedFontOptions),
			gems = CopyTable(SharedGemOptions),
		},
	},
}

--* Character
-- Enchant
--P.pz.wratharmory.character.enchant.mouseover = false --! NYI
P.pz.wratharmory.character.enchant.color = {r = 0, g = 0.99, b = 0}
P.pz.wratharmory.character.enchant.qualityColor = false
P.pz.wratharmory.character.enchant.xOffset = 1
P.pz.wratharmory.character.enchant.yOffset = -2
P.pz.wratharmory.character.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -9,
}
P.pz.wratharmory.character.enchant.SecondaryHandSlot = {
	xOffset = -2,
	yOffset = 0,
}
P.pz.wratharmory.character.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
}

--* Inspect
-- Enchant
--P.pz.wratharmory.inspect.enchant.mouseover = false --! NYI
P.pz.wratharmory.inspect.enchant.color = {r = 0, g = 0.99, b = 0}
P.pz.wratharmory.inspect.enchant.qualityColor = false
P.pz.wratharmory.inspect.enchant.xOffset = 1
P.pz.wratharmory.inspect.enchant.yOffset = -2
P.pz.wratharmory.inspect.enchant.MainHandSlot = {
	xOffset = -1,
	yOffset = -9,
}
P.pz.wratharmory.inspect.enchant.SecondaryHandSlot = {
	xOffset = 0,
	yOffset = -2,
}
P.pz.wratharmory.inspect.enchant.RangedSlot = {
	xOffset = 2,
	yOffset = 0,
}