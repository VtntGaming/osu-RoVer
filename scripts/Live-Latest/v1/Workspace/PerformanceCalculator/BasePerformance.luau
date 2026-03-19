--[LOCATION]:[Workspace.PerformanceCalculator.BasePerformance]
local BasePerformance = {}

function BasePerformance.DifficultyToPerformance (value: number): number
	return 4 * math.pow(value, 3)
end

function BasePerformance.DifficultyToPerformanceFL(value: number): number
	return 25 * math.pow(value, 2)
end

return BasePerformance