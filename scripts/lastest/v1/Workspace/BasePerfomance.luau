--[LOCATION]:[Workspace.PerformanceCalculator.BasePerfomance]
return function (value)
	return value > 0.01 and math.pow(5.0 * math.max(1.0, value / 0.0675) - 4.0, 3.0) / 100000 or 0
end