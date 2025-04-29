-- Credited the osu! team on the github for the difficulty calculator and preprocessing
-- Even though I have to transfer code from C# to lua all by myself
-- The calculator might different compare to the original one

local calculator = {}

function calculator.calcWideAngleBonus(angle) return calculator.Smootherstep(angle, math.rad(40), math.rad(140)) end
function calculator.calcAcuteAngleBonus(angle) return  calculator.Smootherstep(angle, math.rad(140), math.rad(40)) end
function calculator.nerfDistanceBetween(distance, CSRate, isHR, isEZ, isSLCal)
	local CS = CSRate * ((isHR and 1.3) or (isEZ and 0.5) or 1)
	if isHR or isEZ then
		CS = math.clamp(CS, 0, 10)
	end
	local radius = 54.4 - 4.48 * CS
	if isSLCal then
		radius *= 2
	end
	local data = distance - radius
	return math.max(0,data)
end 

function calculator.nerfSpeedDistnaceBetween(distance, CSRate, isEZ, isHR)
	local CS = CSRate * ((isHR and 1.3) or (isEZ and 0.5) or 1)
	if isHR or isEZ then
		CS = math.clamp(CS, 0, 10)
	end
	local radius = 54.4 - 4.48 * CS
	-- less strict than aim
	local data = distance - radius * 0.25
	return math.max(0,data)
end

function calculator.GetDistanceMultiplierWithCS(CSRate, isHR, isEZ)
	local Normalized_Radius = 50
	local CSRateAfterMod = CSRate * ((isHR and 1.3) or (isEZ and 0.5) or 1)
	if isHR or isEZ then
		CSRateAfterMod = math.clamp(CSRateAfterMod, 0, 10)
	end
	local CircleRadius = (54.4 - 4.48 * CSRateAfterMod)
	local DistanceMultiplier = Normalized_Radius / CircleRadius
	if CircleRadius < 30 then
		local SmallCircleBonus = math.min(30 - CircleRadius, 5) / 50
		DistanceMultiplier *= 1 + SmallCircleBonus
	end
	
	return DistanceMultiplier
end

function calculator.Smootherstep(x, _start, _end)
	x = math.clamp((x - _start) / (_end - _start), 0.0, 1.0)

	return x * x * x * (x * (6.0 * x - 15.0) + 10.0)
end

function calculator.ReverseLerp(x, _start, _end)
	return math.clamp((x - _start) / (_end - _start), 0.0, 1.0)
end

function calculator.GetAimDiff(CrrObj)
	if CrrObj.isSpinner or CrrObj.objID < 3 then
		return 0
	end
	local wide_angle_multiplier = 1.5
	local acute_angle_multiplier = 2.6
	local wiggle_multiplier = 1.02
	local slider_multiplier = 1.35
	local velocity_change_multiplier = 0.75
	local PrevObj = CrrObj.Previous(1)
	local PrevPrevObj = CrrObj.Previous(2)
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
	if PrevObj.StrainTime and math.max(CrrObj.StrainTime,PrevObj.StrainTime) < 1.25 * math.min(CrrObj.StrainTime,PrevObj.StrainTime) then
		-- process for same or "almost same" note time
		if (CrrObj.Angle and PrevObj.Angle) then
			local crrAngle = CrrObj.Angle
			local lastAngle = PrevObj.Angle
			

			local angleBonus = math.min(crrVelocity, prevVelocity)
			

			wideAngleBonus = calculator.calcWideAngleBonus(crrAngle)
			acuteAngleBonus = calculator.calcAcuteAngleBonus(crrAngle)

			wideAngleBonus *= 1 - math.min(wideAngleBonus, math.pow(calculator.calcWideAngleBonus(lastAngle), 3))
			acuteAngleBonus *= 0.08 + 0.92 * (1 - math.min(acuteAngleBonus, math.pow(calculator.calcAcuteAngleBonus(lastAngle), 3)))
			
			wideAngleBonus *= angleBonus * calculator.Smootherstep(CrrObj.LazyJumpDistance, 0, NormalizedDiameter)
			
			acuteAngleBonus *= angleBonus *
				calculator.Smootherstep(calculator.milisecondToBPM(CrrObj.StrainTime, 2), 300, 400) *
				calculator.Smootherstep(CrrObj.LazyJumpDistance, NormalizedDiameter, NormalizedDiameter * 2)

			wiggleBonus = angleBonus
				* calculator.Smootherstep(CrrObj.LazyJumpDistance, NormalizedRadius, NormalizedDiameter)
				* math.pow(calculator.ReverseLerp(CrrObj.LazyJumpDistance, NormalizedDiameter * 3, NormalizedDiameter), 1.8)
				* calculator.Smootherstep(crrAngle, math.rad(110), math.rad(60))
				* calculator.Smootherstep(PrevObj.LazyJumpDistance, NormalizedRadius, NormalizedDiameter)
				* math.pow(calculator.ReverseLerp(PrevObj.LazyJumpDistance, NormalizedDiameter * 3, NormalizedDiameter), 1.8)
				* calculator.Smootherstep(lastAngle, math.rad(110), math.rad(60))
		end
	end

	if math.max(prevVelocity, crrVelocity) ~= 0 then
		prevVelocity = (PrevObj.LazyJumpDistance + (PrevPrevObj.BaseTravelDistance or 0))/CrrObj.StrainTime
		crrVelocity = (CrrObj.LazyJumpDistance + (PrevObj.BaseTravelDistance or 0))/CrrObj.StrainTime
		
		local distanceRatio = math.pow(math.sin(math.pi/2*math.abs(prevVelocity-crrVelocity)/math.max(prevVelocity,crrVelocity)),2)
		local overlapVelocityBuff = math.min(NormalizedDiameter * 1.25 / math.min(CrrObj.StrainTime, PrevObj.StrainTime), math.abs(prevVelocity - crrVelocity))
		velocityChangeBonus = overlapVelocityBuff * distanceRatio

		velocityChangeBonus *= math.pow(math.min(CrrObj.StrainTime, PrevObj.StrainTime)/ math.max(CrrObj.StrainTime,PrevObj.StrainTime),2)
	end
	
	
	if PrevObj.isSlider then
		SliderBonus = PrevObj.BaseTravelDistance/PrevObj.BaseTravelTime
	end
	baseAimStrain += SliderBonus * slider_multiplier

	baseAimStrain += wiggleBonus * wiggle_multiplier
	baseAimStrain += math.max(acuteAngleBonus * acute_angle_multiplier, wideAngleBonus * wide_angle_multiplier + velocityChangeBonus * velocity_change_multiplier)

	return baseAimStrain * 25.6
end

function calculator.milisecondToBPM(ms, delimiter)
	delimiter = delimiter or 4
	return 60000 / (ms * delimiter)
end

function calculator.BPMToMilisecond(bpm, delimiter)
	delimiter = delimiter or 4
	return 60000 / delimiter / bpm
end

local function getIslandCount(islandList, currentIsland)
	for i, island in pairs(islandList) do
		if island.IsEqual(currentIsland) then
			return i-1, island
		end
	end
	return nil
end

local function Logistic(x, midpointOffset, multiplier, maxValue)
	if not maxValue then maxValue = 1 end
	
	return maxValue / (1 + math.exp(multiplier * (midpointOffset - x)))
end
function calculator.GetRhythmDiff(CrrObj)
	-- This is the most complicate section I ever transfer
	
	local history_time_max = 5000 -- ms
	local history_obj_max = 32
	local rhythm_overall_multiplier = 0.95
	local rhythm_ratio_multiplier = 12
	local min_delta_time = 25
	
	local function newIsland(delta, epsilon) -- Initiate Island class
		local island = {
			deltaDifferenceEpsilon = epsilon,
			delta = 9999999999999, -- maximum value possible
			Count = 1,
			deltaCount = 0
		}
		
		if delta then
			island.delta = math.max(delta, min_delta_time)
			island.deltaCount += 1
		end
		
		function island.AddDelta(delta)
			if island.delta == 9999999999999 then
				island.delta = math.max(delta, min_delta_time)
			end
			island.deltaCount += 1
		end
		
		function island.IsSimilarPolarity(otherDelta)
			return island.deltaCount % 2 == otherDelta.deltaCount % 2
		end
		
		function island.IsEqual(otherDelta)
			if not otherDelta then return false	end
			
			return math.abs(island.delta - otherDelta.delta) < island.deltaDifferenceEpsilon and island.deltaCount == otherDelta.deltaCount
		end
		
		return island
	end
	
	if CrrObj.isSpinner or not CrrObj.Hit300Value then
		return 0
	end
	
	local rhythmComplexitySum = 0
	local deltaDifferenceEpsilon = CrrObj.Hit300Value * 0.3
	
	local Island = newIsland(nil, deltaDifferenceEpsilon)
	local PrevIsland = newIsland(nil, deltaDifferenceEpsilon)
	local IslandList = {}
	
	local startRatio = 0
	local firstDeltaSwitch = false
	local historicalNoteCount = math.min(CrrObj.objID, history_obj_max)
	local rhythmStart = 0
	
	while rhythmStart < historicalNoteCount - 2 and CrrObj.Time - CrrObj.Previous(rhythmStart).Time < history_time_max do
		rhythmStart += 1
	end
	
	local PrevObj = CrrObj.Previous(rhythmStart)
	local LastObj = CrrObj.Previous(rhythmStart + 1)

	for i = rhythmStart, 1, -1 do
		local currentObj = CrrObj.Previous(i - 1)
		local timeDecay = (history_time_max - (CrrObj.Time - currentObj.Time)) / history_time_max
		local noteDecay = (historicalNoteCount - i) / historicalNoteCount
		
		local currHistoricalDecay = math.min(noteDecay, timeDecay)
		local currDelta = currentObj.StrainTime
		local prevDelta = PrevObj.StrainTime
		local lastDelta = LastObj.StrainTime
		
		local deltaDifferenceRatio = math.min(prevDelta, currDelta) / math.max(prevDelta, currDelta)
		local currRatio = 1.0 + rhythm_ratio_multiplier * math.min(0.5, math.pow(math.sin(math.pi / deltaDifferenceRatio), 2))
		
		local fraction = math.max(prevDelta / currDelta, currDelta / prevDelta)
		local fractionMultiplier = math.clamp(2.0 - fraction / 8.0, 0.0, 1.0)
		
		local windowPenalty = math.min(1, math.max(0, math.abs(prevDelta - currDelta) - deltaDifferenceEpsilon) / deltaDifferenceEpsilon)
		local effectiveRatio = windowPenalty * currRatio * fractionMultiplier
		
		if firstDeltaSwitch then
			if math.abs(prevDelta - currDelta) < deltaDifferenceEpsilon then
				Island.AddDelta(currDelta)
			else
				if currentObj.isSlider then
					effectiveRatio *= 0.125
				end
				
				if PrevObj.isSlider then
					effectiveRatio *= 0.3
				end
				
				
				if Island.IsSimilarPolarity(PrevIsland) then
					effectiveRatio *= 0.5
				end
				
				if lastDelta > prevDelta + deltaDifferenceEpsilon and prevDelta > currDelta + deltaDifferenceEpsilon then
					effectiveRatio *= 0.125
				end
				
				if PrevIsland.DeltaCount == Island.DeltaCount then
					effectiveRatio *= 0.5
				end
				
				local countIndex , islandCount = getIslandCount(IslandList, Island)
				if islandCount then
					if PrevIsland.IsEqual(Island) then
						islandCount.Count += 1
					end
					
					local power = Logistic(Island.delta, 58.33, 0.24, 2.75)
					effectiveRatio *= math.min(3.0 / islandCount.Count, math.pow(1.0 / islandCount.Count, power))
					
					IslandList[countIndex] = islandCount
				else
					IslandList[#IslandList+1] = Island
				end
				
				local doubletapness = PrevObj.getDoubletapness(currentObj)
				effectiveRatio *= 1 - doubletapness * 0.75
				
				rhythmComplexitySum += math.sqrt(effectiveRatio * startRatio) * currHistoricalDecay
				startRatio = effectiveRatio
				PrevIsland = Island
				
				if prevDelta + deltaDifferenceEpsilon < currDelta then
					-- the beat is slowed down, stop counting
					firstDeltaSwitch = false
				end
				
				Island = newIsland(currDelta, deltaDifferenceEpsilon)
			end
		elseif prevDelta > currDelta + deltaDifferenceEpsilon then -- the beat is speeding up again
			-- start counting
			firstDeltaSwitch = true
			
			if currentObj.isSlider then
				effectiveRatio *= 0.6
			end
			
			if PrevObj.isSlider then
				effectiveRatio *= 0.6
			end
			
			startRatio = effectiveRatio
			Island = newIsland(currDelta, deltaDifferenceEpsilon)
		end
		LastObj = PrevObj
		PrevObj = currentObj
	end
	
	return math.sqrt(4 + rhythmComplexitySum * rhythm_overall_multiplier) / 2.0
end

function calculator.GetSpeedDiff(CrrObj)
	if CrrObj.isSpinner then
		return 0
	end
	
	local prevObj = CrrObj.Previous(1)
	local nextObj = CrrObj.Next(1)
	
	if not prevObj or prevObj.isSpinner then
		return 0
	end
	local single_spacing_threshold = 125
	local min_speed_bonus = 200
	local speed_balancing_factor = 40
	local distance_multiplier = 0.9

	local strainTime = CrrObj.StrainTime
	local doubletapness = math.max(0, 1 - (CrrObj.getDoubletapness(nextObj)))

	strainTime /= math.clamp((strainTime/CrrObj.Hit300Value)/ 0.93, 0.92, 1)

	local speedBonus = 0

	if (calculator.milisecondToBPM(strainTime) > min_speed_bonus) then
		speedBonus = 0.75 * math.pow((calculator.BPMToMilisecond(min_speed_bonus) - strainTime)/speed_balancing_factor , 2)
	end
	
	-- this feature is related to the slider category
	-- and we will pretent all map does not have slider...
	-- probably avaiable in uhh.. V1.48?
	local travelDistance = (prevObj and prevObj.BaseTravelDistance) or 0
	travelDistance += CrrObj.MinimumJumpDistance
	local distance = math.min(single_spacing_threshold, travelDistance)
	local distanceBonus = math.pow(distance/single_spacing_threshold, 3.95) * distance_multiplier

	local SpeedDiff = ((1 + speedBonus + distanceBonus) * 1000 / strainTime) * doubletapness
	return SpeedDiff * 1.46
end


function calculator.getOpacityAt(Time, ObjList, ARRate, isEZ, isHR, isHD, SongSpeed)
	local ObjStartTime = ObjList[0].StartTime

	local ARRate = ARRate
	ARRate *= (isEZ and 0.5) or (isHR and 1.4) or 1

	local CircleApproachTime = 1200
	local CircleFadeInTime = 0.8
	if ARRate < 5 then
		CircleApproachTime = 1200 + 600 * (5 - ARRate) / 5
		CircleFadeInTime = (800 + 400 * (5 - ARRate) / 5)/1000
	elseif ARRate > 5 then
		CircleApproachTime = 1200 - 750 * (ARRate - 5) / 5
		CircleFadeInTime = (800 - 500 * (ARRate - 5) / 5)/1000
	end

	CircleFadeInTime /= SongSpeed
	CircleApproachTime/= SongSpeed

	if isHD then
		CircleFadeInTime = (CircleApproachTime - (CircleApproachTime*1/6))/2000
	end
	local TimeLeft = (ObjStartTime)/1000 - Time/1000
	local TimePassed = CircleApproachTime/1000 - TimeLeft

	local CircleTransparency = math.clamp((CircleFadeInTime - (TimePassed))/CircleFadeInTime,0,1)
	return 1-CircleTransparency
end

function calculator.getFlashLightDiff(CrrObj, IsHD)
	if CrrObj.isSpinner or (CrrObj.Previous(1) and CrrObj.Previous(1).isSpinner) or CrrObj.objID <= 1 then
		return 0
	end
	local maxOpacityBonus = 0.4
	local HDBonus = 0.2

	local minVelocity = 0.5
	local sliderMultiplier = 1.3

	local minAngleMultiplier = 0.2
	local scalingFactor = 52 / CrrObj.Radius
	local smallDistanceNerf = 1
	local cumulativeStrainTime = 0

	local Result = 0
	local angleRepeatCount = 0
	local LastObj = CrrObj
	
	for i = 1, math.min(CrrObj.objID, 10) do
		local CurrentCheck = CrrObj.Previous(i)
		
		if CurrentCheck.objID <= 1 then
			break
		end
		
		cumulativeStrainTime += LastObj.StrainTime
		
		if not CurrentCheck.isSpinner and not CurrentCheck.isInvalid then
			local JumpDistance = 0
			if CrrObj.CirclePosition and CurrentCheck.CirclePosition then
				JumpDistance = (CrrObj.CirclePosition - CurrentCheck.CirclePosition).Magnitude
			end
			
			if i == 1 then
				smallDistanceNerf = math.min(1, JumpDistance/75)
			end

			
			local StackNerf = math.min(1, (CurrentCheck.LazyJumpDistance/scalingFactor) / 25)
			
			local OpacityBonus = 1 + maxOpacityBonus * (1 - CrrObj.OpacityAt(CurrentCheck.Time))
			
			Result += StackNerf * OpacityBonus * scalingFactor * JumpDistance / cumulativeStrainTime
			
			if CurrentCheck.Angle ~= nil and CrrObj.Angle ~= nil then
				if (math.abs(CurrentCheck.Angle - CrrObj.Angle) < 0.02) then
					angleRepeatCount += math.max(1.0 - 0.1 * i, 0.0)
				end
			end
		end
		
		LastObj = CurrentCheck
	end
	
	Result = math.pow(smallDistanceNerf * Result, 2)
	
	if IsHD then
		Result *= (1 + HDBonus)
	end
	
	Result *= minAngleMultiplier + (1.0 - minAngleMultiplier) / (angleRepeatCount + 1.0)
	
	local SliderBonus = 0
	
	if CrrObj.IsSlider then
		local pixelTravelDistance = CrrObj.lazyTravelDistance / scalingFactor
		SliderBonus = math.pow(math.max(0.0, pixelTravelDistance / CrrObj.BaseTravelTime - minVelocity), 0.5)
		SliderBonus *= pixelTravelDistance
		if (CrrObj.SLRepeatCount > 0) then
			SliderBonus /= (CrrObj.SLRepeatCount + 1)
		end
	end
	
	Result += SliderBonus * sliderMultiplier
	
	return Result * 0.05512
end

function sortStrain(data)
	table.sort(data,function(a,b) return a>b end)
end

function lerp(a,b,r)
	return a + (b-a)*r
end

function calculator.DifficultyValue(StrainData, IsgetRelevantNoteCount, isAim, RhythmDiffData)
	local reducedSelectionCount = 10
	local weight = 1
	local decayWeight = 0.9
	local difficulty = 0
	local ReducedStrainBaseline = 0.75
	
	if RhythmDiffData then -- it's for speed difficulty
		for i, speedStrain in pairs(StrainData) do
			local rhythmDiff = 1
			if RhythmDiffData[i] then
				rhythmDiff = RhythmDiffData[i]
			end
			StrainData[i] = speedStrain * rhythmDiff
		end
	end
	
	sortStrain(StrainData)
	
	for i,a in pairs(StrainData) do
		local scale = math.log10(lerp(1,10,math.clamp((i-1)/reducedSelectionCount,0,1)))
		StrainData[i] *= lerp(ReducedStrainBaseline, 1, scale)
		if i > 10 then
			break
		end
	end

	sortStrain(StrainData)
	for _,strain in pairs(StrainData) do
		if strain <= 0 then break end
		
		difficulty += strain * weight
		weight *= decayWeight
	end
	
	local StrainCount = 0
	local consistentTopStrain = difficulty/10
	local SpeedRelevantNoteCount = 0
	for _,a in pairs(StrainData) do
		StrainCount += 1.1 / (1 + math.exp(-10 * (a / consistentTopStrain - 0.88)))
		if IsgetRelevantNoteCount then
			SpeedRelevantNoteCount += 1 / (1 + math.exp(-(a / StrainData[1] * 12 - 6)))
		end
	end
	
	return difficulty, StrainCount, SpeedRelevantNoteCount
end

function calculator.DifficultyValueFlashlight(StrainData)
	local difficulty = 0
	sortStrain(StrainData)
	for i, strain in pairs(StrainData) do
		if strain <= 0 or i > 400 then break end
		difficulty += strain
	end
	return difficulty
end

return calculator