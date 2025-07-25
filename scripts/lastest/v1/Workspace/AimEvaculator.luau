--!strict
local preprocessing = require(workspace.DifficultyCalculator.Preprocessing)
local Evaculator = require(script.Parent)
local aimEvaculator = {}

function aimEvaculator.Smootherstep(x:number, _start:number, _end:number)
	x = math.clamp((x - _start) / (_end - _start), 0.0, 1.0)

	return x * x * x * (x * (6.0 * x - 15.0) + 10.0)
end

function aimEvaculator.Smoothstep(x:number, _start:number, _end:number)
	x = math.clamp((x - _start) / (_end	- _start), 0, 1)
	
	return x * x * (3 - 2 * x)
end

function aimEvaculator.calcWideAngleBonus(angle) return aimEvaculator.Smoothstep(angle, math.rad(40), math.rad(140)) end
function aimEvaculator.calcAcuteAngleBonus(angle) return aimEvaculator.Smoothstep(angle, math.rad(140), math.rad(40)) end

-- Constants
local wide_angle_multiplier = 1.5
local acute_angle_multiplier = 2.55
local slider_multiplier = 1.35
local velocity_change_multiplier = 0.75
local wiggle_multiplier = 1.02



function aimEvaculator.GetAimDiff(CrrObj:preprocessing.ObjectData)
	if CrrObj.isSpinner or CrrObj.objID < 3 then
		return 0
	end

	local PrevObj = CrrObj.Previous(1)
	local PrevPrevObj = CrrObj.Previous(2)
	local Prev2Obj = CrrObj.Previous(3)
	local NormalizedRadius = 50
	local NormalizedDiameter = NormalizedRadius * 2

	if not PrevObj or PrevObj.isSpinner then
		return 0
	end


	local crrVelocity = (CrrObj.LazyJumpDistance and CrrObj.StrainTime) and (CrrObj.LazyJumpDistance/CrrObj.StrainTime) or 0

	if PrevObj.isSlider then
		local travelVelocity = PrevObj.BaseTravelDistance/PrevObj.BaseTravelTime -- previous slider head to slider tail
		local movementVelocity = CrrObj.MinimumJumpDistance/CrrObj.MinimumJumpTime -- previous slider tail to the current note

		crrVelocity = math.max(crrVelocity, travelVelocity + movementVelocity)
	end
	local prevVelocity = (PrevObj.LazyJumpDistance and PrevObj.StrainTime) and (PrevObj.LazyJumpDistance/PrevObj.StrainTime) or 0
	if PrevPrevObj and PrevPrevObj.isSlider then
		local travelVelocity = PrevPrevObj.BaseTravelDistance/PrevPrevObj.BaseTravelTime
		local movementVelocity = PrevObj.MinimumJumpDistance/PrevObj.MinimumJumpTime
		prevVelocity = math.max(prevVelocity, travelVelocity + movementVelocity)
	end
	
	local wideAngleBonus = 0
	local acuteAngleBonus = 0
	local velocityChangeBonus = 0
	local wiggleBonus = 0
	local SliderBonus = 0

	local baseAimStrain = crrVelocity
	if (CrrObj.Angle and PrevObj.Angle) then
		local crrAngle = CrrObj.Angle
		local lastAngle = PrevObj.Angle

		local angleBonus = math.min(crrVelocity, prevVelocity)
		if PrevObj.StrainTime and math.max(CrrObj.StrainTime,PrevObj.StrainTime) < 1.25 * math.min(CrrObj.StrainTime,PrevObj.StrainTime) then
			acuteAngleBonus = aimEvaculator.calcAcuteAngleBonus(crrAngle)
			acuteAngleBonus *= 0.08 + 0.92 * (1 - math.min(acuteAngleBonus, math.pow(aimEvaculator.calcAcuteAngleBonus(lastAngle), 3)))
			acuteAngleBonus *= angleBonus *
				aimEvaculator.Smootherstep(Evaculator.milisecondToBPM(CrrObj.StrainTime, 2), 300, 400) *
				aimEvaculator.Smootherstep(CrrObj.LazyJumpDistance, NormalizedDiameter, NormalizedDiameter * 2)
		end

		wideAngleBonus = aimEvaculator.calcWideAngleBonus(crrAngle)
		wideAngleBonus *= 1 - math.min(wideAngleBonus, math.pow(aimEvaculator.calcWideAngleBonus(lastAngle), 3))
		wideAngleBonus *= angleBonus * aimEvaculator.Smootherstep(CrrObj.LazyJumpDistance, 0, NormalizedDiameter)
		wiggleBonus = angleBonus
			* aimEvaculator.Smootherstep(CrrObj.LazyJumpDistance, NormalizedRadius, NormalizedDiameter)
			* math.pow(Evaculator.ReverseLerp(CrrObj.LazyJumpDistance, NormalizedDiameter * 3, NormalizedDiameter), 1.8)
			* aimEvaculator.Smootherstep(crrAngle, math.rad(110), math.rad(60))
			* aimEvaculator.Smootherstep(PrevObj.LazyJumpDistance, NormalizedRadius, NormalizedDiameter)
			* math.pow(Evaculator.ReverseLerp(PrevObj.LazyJumpDistance, NormalizedDiameter * 3, NormalizedDiameter), 1.8)
			* aimEvaculator.Smootherstep(lastAngle, math.rad(110), math.rad(60))
		
		if Prev2Obj and Prev2Obj.CirclePosition then
			local distance = (Prev2Obj.CirclePosition - PrevObj.CirclePosition).Magnitude
			if distance < 1 then
				wideAngleBonus *= 1 - 0.35 * (1 - distance)
			end
		end
	end

	if math.max(prevVelocity, crrVelocity) ~= 0 then
		prevVelocity = (PrevObj.LazyJumpDistance + (PrevPrevObj.BaseTravelDistance or 0))/CrrObj.StrainTime
		crrVelocity = (CrrObj.LazyJumpDistance + (PrevObj.BaseTravelDistance or 0))/CrrObj.StrainTime

		local distanceRatio = aimEvaculator.Smoothstep(math.abs(prevVelocity - crrVelocity) / math.max(prevVelocity, crrVelocity), 0, 1)
		local overlapVelocityBuff = math.min(NormalizedDiameter * 1.25 / math.min(CrrObj.StrainTime, PrevObj.StrainTime), math.abs(prevVelocity - crrVelocity))
		velocityChangeBonus = overlapVelocityBuff * distanceRatio

		velocityChangeBonus *= math.pow(math.min(CrrObj.StrainTime, PrevObj.StrainTime)/ math.max(CrrObj.StrainTime,PrevObj.StrainTime),2)
	end

	baseAimStrain *= CrrObj.SmallCircleBonus

	if PrevObj.isSlider then
		SliderBonus = PrevObj.BaseTravelDistance/PrevObj.BaseTravelTime
	end
	baseAimStrain += SliderBonus * slider_multiplier

	baseAimStrain += wiggleBonus * wiggle_multiplier
	baseAimStrain += velocityChangeBonus * velocity_change_multiplier
	baseAimStrain += math.max(acuteAngleBonus * acute_angle_multiplier, wideAngleBonus * wide_angle_multiplier)
	
	return baseAimStrain
end

return aimEvaculator