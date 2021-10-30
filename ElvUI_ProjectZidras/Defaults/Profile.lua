local E, L, V, P, G = unpack(ElvUI)

local ZUF_AbsorbPrediction = {
	enable = true,
	absorbStyle = "REVERSED",
	anchorPoint = "BOTTOM",
	absorbTexture = "ElvUI Norm",
	height = -1
}

P.pz = {
	chat = {
		guildmaster = true,
		lfgIcons = true,
	},
	nameplates = {
		hdNameplates = false,
	},
	unitframe = {
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
			},
			target = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			focus = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			pet = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			arena = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			party = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			raid = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			raid40 = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
			raidpet = {
				absorbPrediction = CopyTable(ZUF_AbsorbPrediction),
			},
		}
	}
}