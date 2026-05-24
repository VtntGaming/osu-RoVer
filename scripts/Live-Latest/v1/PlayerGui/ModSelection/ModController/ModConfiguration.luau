--!strict
export type ModType = "DifficultyIncrease" | "DifficultyReduction" | "Conversion" | "Automation" | "Misc"

export type ModData = {
	Name: string,
	Type: ModType,
	Description: string,
	IconImage: string?,
	DisableUI: boolean?,
}

local ModList: {[string]: ModData} = {
	HD = {
		Name = "Hidden",
		Type = "DifficultyIncrease",
		Description = "No approach circle and the circle fade out before you click it.",		
	},
	HR = {
		Name = "Hard Rock",
		Type = "DifficultyIncrease",
		Description = "Faster react time, more accuracy required.",
	},
	FL = {
		Name = "Flashlight",
		Type = "DifficultyIncrease",
		Description = "Restricted view area. The higher combo you have, the less playfield area it gets.",
	},
	EZ = {
		Name = "Easy",
		Type = "DifficultyReduction",
		Description = "Take it easy, bigger circle, more timing to react and such more mercy.",
	},
	NF = {
		Name = "No Fail",
		Type = "DifficultyReduction",
		Description = "Now nothing can stop you from clearing the map."
	},
	SA = {
		Name = "Speed Adjust",
		Type = "Conversion",
		Description = "Adjust the gameplay speed",
	},
	-- Alternative display from SA
	DT = {
		Name = "Double Time",
		Type = "DifficultyIncrease",
		Description = "Let's gooooooooo!",
		IconImage = "rbxassetid://110452058696064",
		DisableUI = true,
	},
	HT = {
		Name = "Half Time",
		Type = "DifficultyIncrease",
		Description = "Slowww downnnnnnn...",
		DisableUI = true,
	},
}

export type CategoryColor = {
	BackgroundColor: Color3,
	TextColor: Color3,
	StrokeColor: Color3,
}

local Palette: {[string]: CategoryColor} = {
	DifficultyIncrease = {
		BackgroundColor = Color3.fromHex("#1e0606"),
		TextColor = Color3.fromHex("#ff9b9b"),
		IconColor = Color3.fromHex("#ff9b9b"),
		StrokeColor = Color3.fromHex("#ff3737"),
	}
}

local ModConfiguration = {}

ModConfiguration.ModList = ModList
ModConfiguration.Palette = Palette

return ModConfiguration