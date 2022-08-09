local Log = {
	URL = "https://raw.githubusercontent.com/VtntGaming/osu-RoVer/",
	Location = {
	{"V1.14","main/updatelog/V1_14.txt"},
	{"V1.13","main/updatelog/V1_13.txt"}
}}


-- Convert to JSON format and change back to roblox game later
print(game.HttpService:JSONEncode(Log))
