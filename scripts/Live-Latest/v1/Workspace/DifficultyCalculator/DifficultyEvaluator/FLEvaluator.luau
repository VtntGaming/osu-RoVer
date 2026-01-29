--[LOCATION]:[Workspace.DifficultyCalculator.DifficultyEvaluator.FLEvaluator]
local flashlightEvaluator = {}

-- Cache math functions
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local math_pow = math.pow

-- Const
local MAX_OPACITY_BONUS = 0.4
local HIDDEN_BONUS = 0.2
local MIN_VELOCITY = 0.5
local SLIDER_MULTIPLIER = 1.3
local MIN_ANGLE_MULTIPLIER = 0.2

function flashlightEvaluator.getFlashLightDiff(CrrObj, IsHD)
	if CrrObj.isSpinner or (CrrObj.Previous(1) and CrrObj.Previous(1).isSpinner) or CrrObj.objID <= 1 then
		return 0
	end
	local scalingFactor = 52 / CrrObj.Radius
	local smallDistanceNerf = 1
	local cumulativeStrainTime = 0
	local crrCirclePos = CrrObj.CirclePosition
	local crrAngle = CrrObj.Angle
	local crrObjID = CrrObj.objID

	local Result = 0
	local angleRepeatCount = 0
	local LastObj = CrrObj
	local loopMax = math_min(crrObjID + 1, 11)

	for i = 1, loopMax do
		local CurrentCheck = CrrObj.Previous(i)

		if CurrentCheck.objID <= 1 then
			break
		end

		cumulativeStrainTime += LastObj.StrainTime

		if not CurrentCheck.isSpinner and not CurrentCheck.isInvalid then
			local JumpDistance = 0
			local checkCirclePos = CurrentCheck.CirclePosition
			if crrCirclePos and checkCirclePos then
				JumpDistance = (crrCirclePos - checkCirclePos).Magnitude
			end

			if i == 1 then
				smallDistanceNerf = math_min(1, JumpDistance/75)
			end


			local StackNerf = math_min(1, (CurrentCheck.LazyJumpDistance/scalingFactor) / 25)

			local OpacityBonus = 1 + MAX_OPACITY_BONUS * (1 - CrrObj.OpacityAt(CurrentCheck.Time))

			Result += StackNerf * OpacityBonus * scalingFactor * JumpDistance / cumulativeStrainTime

			local checkAngle = CurrentCheck.Angle
			if checkAngle ~= nil and crrAngle ~= nil then
				if (math_abs(checkAngle - crrAngle) < 0.02) then
					angleRepeatCount += math_max(1.0 - 0.1 * i, 0.0)
				end
			end
		end

		LastObj = CurrentCheck
	end

	Result = math_pow(smallDistanceNerf * Result, 2)

	if IsHD then
		Result *= (1 + HIDDEN_BONUS)
	end

	Result *= MIN_ANGLE_MULTIPLIER + (1.0 - MIN_ANGLE_MULTIPLIER) / (angleRepeatCount + 1.0)

	local SliderBonus = 0

	if CrrObj.IsSlider then
		local pixelTravelDistance = CrrObj.lazyTravelDistance / scalingFactor
		SliderBonus = math_pow(math_max(0.0, pixelTravelDistance / CrrObj.BaseTravelTime - MIN_VELOCITY), 0.5)
		SliderBonus *= pixelTravelDistance
		if (CrrObj.SLRepeatCount > 0) then
			SliderBonus /= (CrrObj.SLRepeatCount + 1)
		end
	end

	Result += SliderBonus * SLIDER_MULTIPLIER

	return Result
end

return flashlightEvaluator