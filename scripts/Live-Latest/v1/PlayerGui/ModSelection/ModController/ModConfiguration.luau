--!strict
export type ModType = "DifficultyIncrease" | "DifficultyReduction" | "Conversion" | "Automation" | "Misc"

local ModOptionType = {
	Boolean = "Boolean",
	Slider = "Slider",
}

export type ModOptionDefault = {
	Name: string,
	Type: string,
}

export type ModOptionBoolean = ModOptionDefault & {
	Default: boolean,
}

export type ModOptionSlider = ModOptionDefault & {
	Default: number,
	Min: number,
	Max: number,
	Step: number?,
}

export type ModOptionCombined = ModOptionBoolean | ModOptionSlider

export type ModData = {
	Name: string,
	Type: ModType,
	Description: string,
	ScoreMultiplier: number?,
	IconImage: string?,
	DisableUI: boolean?,
	IncompatibleMods: {string}?,
	ModOptions: {ModOptionCombined}?,
}

local ModList: {[string]: ModData} = {
	-- DifficultyIncrease
	HD = {
		Name = "Hidden",
		Type = "DifficultyIncrease",
		Description = "No approach circle and the circle fade out before you click it.",
		ScoreMultiplier = 1.06,
	},
	HR = {
		Name = "Hard Rock",
		Type = "DifficultyIncrease",
		Description = "Faster react time, more accuracy required.",
		ScoreMultiplier = 1.06,
		IncompatibleMods = {"EZ"}
	},
	FL = {
		Name = "Flashlight",
		Type = "DifficultyIncrease",
		Description = "Restricted view area. The higher combo you have, the less playfield area it gets.",
		ScoreMultiplier = 1.12
	},
	-- DifficultyReduction
	EZ = {
		Name = "Easy",
		Type = "DifficultyReduction",
		Description = "Take it easy, bigger circle, more timing to react and such more mercy.",
		ScoreMultiplier = 0.5,
		IncompatibleMods = {"HR"}
	},
	NF = {
		Name = "No Fail",
		Type = "DifficultyReduction",
		Description = "Now nothing can stop you from clearing the map.",
		ScoreMultiplier = 0.5,
	},
	-- Conversion
	SA = {
		Name = "Speed Adjust",
		Type = "Conversion",
		Description = "Adjust the gameplay speed",
		ModOptions = {
			{
				Name = "Speed",
				Type = ModOptionType.Slider,
				Default = 0.5,
				Min = 0.5,
				Max = 2,
				Step = 0.1
			}
		},
		DisableUI = true
	},
	-- Automation
	AT = {
		Name = "Auto Play",
		Type = "Automation",
		Description = " Let the game play itself, watch the masterpiece it can do!",
	},
	-- Alternative display from SA
	DT = {
		Name = "Double Time",
		Type = "DifficultyIncrease",
		Description = "Let's gooooooooo!",
		IconImage = "rbxassetid://110452058696064",
		--DisableUI = true,
		ScoreMultiplier = 1.12,
		IncompatibleMods = {"HT"},
	},
	HT = {
		Name = "Half Time",
		Type = "DifficultyReduction",
		Description = "Slowww downnnnnnn...",
		--DisableUI = true,
		ScoreMultiplier = 0.3,
		IncompatibleMods = {"DT"},
	},
}

export type CategoryColor = {
	-- Default color
	BackgroundColor: Color3,
	TextColor: Color3,
	StrokeColor: Color3,
	IconColor: Color3,
	-- Highlight color (when enabled)
	HighlightedBackgroundColor: Color3,
	HighlightedTextColor: Color3,
	HighlightedStrokeColor: Color3,
	HighlightedIconColor: Color3,
}

local Palette: {[string]: CategoryColor} = {
	DifficultyIncrease = {
		BackgroundColor = Color3.fromHex("#1e0606"),
		TextColor = Color3.fromHex("#ff9b9b"),
		IconColor = Color3.fromHex("#ff9b9b"),
		StrokeColor = Color3.fromHex("#ff3737"),
		HighlightedBackgroundColor = Color3.fromHex("#ff6969"),
		HighlightedTextColor = Color3.fromHex("#961e1e"),
		HighlightedIconColor = Color3.fromHex("#961e1e"),
		HighlightedStrokeColor = Color3.fromHex("#ff3737"),
	},
	DifficultyReduction = {
		BackgroundColor = Color3.fromHex("#0e1e06"),
		TextColor = Color3.fromHex("#bcff9b"),
		IconColor = Color3.fromHex("#bcff9b"),
		StrokeColor = Color3.fromHex("#7aff37"),
		HighlightedBackgroundColor = Color3.fromHex("#beff9b"),
		HighlightedTextColor = Color3.fromHex("#2f6414"),
		HighlightedIconColor = Color3.fromHex("#2f6414"),
		HighlightedStrokeColor = Color3.fromHex("#44cc00"),
	},
	Conversion = {
		BackgroundColor = Color3.fromHex("#06061e"),
		TextColor = Color3.fromHex("#9b9bff"),
		IconColor = Color3.fromHex("#9b9bff"),
		StrokeColor = Color3.fromHex("#5555ff"),
		HighlightedBackgroundColor = Color3.fromHex("#afafff"),
		HighlightedTextColor = Color3.fromHex("#141464"),
		HighlightedIconColor = Color3.fromHex("#141464"),
		HighlightedStrokeColor = Color3.fromHex("#3333cc"),
	},
	Automation = {
		BackgroundColor = Color3.fromHex("#061e1e"),
		TextColor = Color3.fromHex("#9bffff"),
		IconColor = Color3.fromHex("#9bffff"),
		StrokeColor = Color3.fromHex("#37ffff"),
		HighlightedBackgroundColor = Color3.fromHex("#9bffff"),
		HighlightedTextColor = Color3.fromHex("#146464"),
		HighlightedIconColor = Color3.fromHex("#146464"),
		HighlightedStrokeColor = Color3.fromHex("#00cccc"),
	},
}

local ModConfiguration = {}

ModConfiguration.ModList = ModList
ModConfiguration.Palette = Palette
ModConfiguration.ModOptionType = ModOptionType

return ModConfiguration