local Log = {
	URL = "https://raw.githubusercontent.com/VtntGaming/osu-RoVer/",
	Location = {
		{"Beta V1.42","main/updatelog/V1_42.txt"},
		{"V1.41","main/updatelog/V1_41.txt"},
		{"V1.40","main/updatelog/V1_40.txt"},
		{"V1.39","main/updatelog/V1_39.txt"},
		{"V1.38","main/updatelog/V1_38.txt"},
		{"V1.37","main/updatelog/V1_37.txt"},
		{"V1.36","main/updatelog/V1_36.txt"},
		{"V1.35","main/updatelog/V1_35.txt"},
		{"V1.34","main/updatelog/V1_34.txt"},
		{"V1.33","main/updatelog/V1_33.txt"},
		{"V1.32","main/updatelog/V1_32.txt"},
		{"V1.31","main/updatelog/V1_31.txt"},
		{"V1.30","main/updatelog/V1_30.txt"},
		{"V1.29","main/updatelog/V1_29.txt"},
		{"V1.28","main/updatelog/V1_28.txt"},
		{"V1.27","main/updatelog/V1_27.txt"},
		{"V1.26","main/updatelog/V1_26.txt"},
		{"V1.25","main/updatelog/V1_25.txt"},
		{"V1.24","main/updatelog/V1_24.txt"},
		{"V1.23","main/updatelog/V1_23.txt"},
		{"V1.22","main/updatelog/V1_22.txt"},
		{"V1.21","main/updatelog/V1_21.txt"},
		{"V1.20","main/updatelog/V1_20.txt"},
		{"V1.19","main/updatelog/V1_19.txt"},
		{"V1.18","main/updatelog/V1_18.txt"},
		{"V1.17","main/updatelog/V1_17.txt"},
		{"V1.16","main/updatelog/V1_16.txt"},
		{"V1.15","main/updatelog/V1_15.txt"},
		{"V1.14","main/updatelog/V1_14.txt"},
		{"V1.13","main/updatelog/V1_13.txt"}
}}


-- Convert to JSON format and change back to roblox game later
print(game.HttpService:JSONEncode(Log))
