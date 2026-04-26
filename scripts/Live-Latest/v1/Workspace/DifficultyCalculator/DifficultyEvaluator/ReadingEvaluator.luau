local workspace = game:GetService("Workspace")
local DifficultyEvaluator = require(script.Parent)
local DifficultyCalculationUtils = require(script.Parent.DifficultyCalculationUtils)
local preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)

-- Cache math functions for faster access
local math_clamp = math.clamp
local math_pow = math.pow
local math_sqrt = math.sqrt
local math_max = math.max
local math_min = math.min
local math_abs = math.abs
local math_cos = math.cos
local math_rad = math.rad

type DifficultyHitObject = preprocessing.ObjectData
local ReadingEvaluator = {}

local READING_WINDOW_SIZE = 3000
local NORMALIZED_RADIUS = 50
local NORMALIZED_DIAMETER = NORMALIZED_RADIUS * 2
local DISTANCE_INFLUENCE_THRESHOLD = NORMALIZED_DIAMETER * 1.5
local HIDDEN_MULTIPLIER = 0.28
local DENSITY_MULTIPLIER = 2.4
local DENSITY_DIFFICULTY_BASE = 2.5
local PREEMPT_BALANCING_FACTOR = 140000
local PREEMPT_STARTING_POINT = 500
local MINIMUM_ANGLE_RELEVANCY_TIME = 2000
local MAXIMUM_ANGLE_RELEVANCY_TIME = 200
-- Pre-computed constants
local HALF_READING_WINDOW = READING_WINDOW_SIZE / 2
local RAD_30 = math_rad(30)

local function smootherstep(x: number, _start: number, _end: number)
	x = math_clamp((x - _start) / (_end - _start), 0.0, 1.0)
	local x2 = x * x
	return x2 * x * (x * (6.0 * x - 15.0) + 10.0)
end

local function calculateDensityDifficulty(nextObj: DifficultyHitObject?, 
    velocity: number, 
    constantAngleNerfFactor: number, 
    pastObjectDifficultyInfluence: number,
    currentVisibleObjectDensity: number)
    local futureObjectDifficultyInfluence = math_sqrt(currentVisibleObjectDensity)

    if nextObj then
        futureObjectDifficultyInfluence *= smootherstep(nextObj.LazyJumpDistance, 15, DISTANCE_INFLUENCE_THRESHOLD)
    end

    local noteDensityDifficulty = math_pow(pastObjectDifficultyInfluence + futureObjectDifficultyInfluence, 1.7) * 0.4 * constantAngleNerfFactor * velocity

    noteDensityDifficulty = math_max(0, noteDensityDifficulty - DENSITY_DIFFICULTY_BASE)
    noteDensityDifficulty = math_pow(noteDensityDifficulty, 0.45) * DENSITY_MULTIPLIER

    return noteDensityDifficulty
end

local function calculateHiddenDifficulty(
        crrObj: DifficultyHitObject, 
        pastObjectDifficultyInfluence: number, 
        currentVisibleObjectDensity: number, 
        velocity: number, 
        constantAngleNerfFactor: number
    )
    local preemptFactor = math_pow(crrObj.Preempt, 2.2) * 0.01
    local densityFactor = math_pow(currentVisibleObjectDensity + pastObjectDifficultyInfluence, 3.3) * 3
    
    local hiddenDifficulty = (preemptFactor + densityFactor) * constantAngleNerfFactor * velocity * 0.01
    hiddenDifficulty = math.pow(hiddenDifficulty, 0.4) * HIDDEN_MULTIPLIER
    local previousObj = crrObj.Previous(1)
    if crrObj.LazyJumpDistance == 0 and crrObj.OpacityAt(previousObj.Time) == 0 and previousObj.Time > crrObj.Time - crrObj.Preempt then
        hiddenDifficulty += HIDDEN_MULTIPLIER * 2500 / math.pow(crrObj.AdjustedDeltaTime, 1.5)
    end
   
    return hiddenDifficulty
end

local function calculatePreemptDifficulty(velocity: number, constantAngleNerfFactor: number, preempt: number)
    local diff = PREEMPT_STARTING_POINT - preempt
    local preemptDifficulty = math_pow((diff + math_abs(diff)) * 0.5, 2.5) / PREEMPT_BALANCING_FACTOR
    preemptDifficulty *= constantAngleNerfFactor * velocity

    return preemptDifficulty
end

local function retrievePastVisibleObjects(current: DifficultyHitObject): {DifficultyHitObject}
    local objList = {}
    for i = 1, current.objID do
        local hitObject = current.Previous(i)
        if not hitObject or
            hitObject.Time - current.Time > READING_WINDOW_SIZE or
            current.Time < hitObject.Time - current.Preempt
        then
            break
        end

        objList[#objList + 1] = hitObject
    end

    return objList
end

local function getTimeNerfFactor(dt)
    return math_clamp(2 - dt / HALF_READING_WINDOW, 0, 1)
end

local function getPastObjectDifficultyInfluence(crrObj: DifficultyHitObject)
    local pastObjectDifficultyInfluence = 0
    local pastVisibleObjs = retrievePastVisibleObjects(crrObj)
    for i = 1, #pastVisibleObjs do
        local loopObj = pastVisibleObjs[i]

        local loopDifficulty = crrObj.OpacityAt(loopObj.Time)
        loopDifficulty *= smootherstep(loopObj.LazyJumpDistance, 15, DISTANCE_INFLUENCE_THRESHOLD)
        
        local timeBetweenCurrAndLoopObj = crrObj.Time - loopObj.Time
        local timeNerfFactor = getTimeNerfFactor(timeBetweenCurrAndLoopObj)
        
        loopDifficulty *= timeNerfFactor
        pastObjectDifficultyInfluence += loopDifficulty
    end

    return pastObjectDifficultyInfluence
end

local function retrieveCurrentVisibleObjectDensity(current: DifficultyHitObject)
    local visibleObjectCount = 0
    local hitObject = current.Next(1)

    while hitObject do
        if hitObject.Time - current.Time > READING_WINDOW_SIZE or
            current.Time < hitObject.Time - hitObject.Preempt then
            break
        end

        local timeBetweenCurrAndLoopObj = hitObject.Time - current.Time
        local timeNerfFactor = getTimeNerfFactor(timeBetweenCurrAndLoopObj)

        visibleObjectCount += hitObject.OpacityAt(current.Time) * timeNerfFactor
        
        hitObject = hitObject.Next(1)
    end

    return visibleObjectCount
end

local function checkAngle(angle: number?)
    return angle ~= nil and angle ~= -1
end

local function getConstantAngleNerfFactor(current: DifficultyHitObject)
    local constantAngleCount = 0
    local index = 0
    local currentTimeGap = 0
    local currentAngle = current.Angle
    local currentTime = current.Time
    local reverseLerpDenom = 1 / (MINIMUM_ANGLE_RELEVANCY_TIME - MAXIMUM_ANGLE_RELEVANCY_TIME)

    local loopObjPrev0: DifficultyHitObject = current
    local loopObjPrev1: DifficultyHitObject? = nil
    local loopObjPrev2: DifficultyHitObject? = nil


    while currentTimeGap < MINIMUM_ANGLE_RELEVANCY_TIME do
        local loopObj = current.Previous(index + 1)

        if not loopObj then
            break
        end

        local longIntervalFactor = 1 - math_clamp((loopObj.AdjustedDeltaTime - MAXIMUM_ANGLE_RELEVANCY_TIME) * reverseLerpDenom, 0, 1)

        if loopObj.Angle and currentAngle then
            local angleDifference = math_abs(currentAngle - loopObj.Angle)
            local angleDifferenceAlternating  = math.pi

            if loopObjPrev0 and checkAngle(loopObjPrev0.Angle) and loopObjPrev1 and checkAngle(loopObjPrev1.Angle) and loopObjPrev2 and checkAngle(loopObjPrev2.Angle) then
                angleDifferenceAlternating = math.abs(loopObjPrev1.Angle - loopObj.Angle)
                angleDifferenceAlternating += math.abs(loopObjPrev2.Angle - loopObjPrev0.Angle)

                local weight = 1

                weight *= DifficultyCalculationUtils.ReverseLerp(math.min(loopObj.Angle, loopObjPrev0.Angle) * 180 / math.pi, 20, 5);
                weight *= DifficultyCalculationUtils.ReverseLerp(math.max(loopObj.Angle, loopObjPrev0.Angle) * 180 / math.pi, 60, 120);

                angleDifferenceAlternating = math.lerp(math.pi, 0.1 * angleDifferenceAlternating, weight)
            end
            local stackFactor = smootherstep(loopObj.LazyJumpDistance, 0, NORMALIZED_RADIUS)

            constantAngleCount += math_cos(3 * math_min(RAD_30, math.min(angleDifference, angleDifferenceAlternating)  * stackFactor)) * longIntervalFactor
        end

        currentTimeGap = currentTime - loopObj.Time
        index += 1

        loopObjPrev2 = loopObjPrev1
        loopObjPrev1 = loopObjPrev0
        loopObjPrev0 = loopObj
    end

    return math_clamp(2 / constantAngleCount, 0.2, 1)
end

local function getHighBPMBonus(ms: number)
    return 1 / (1 - math.pow(0.8, ms / 1000))
end

function ReadingEvaluator.GetReadingDiff(crrObj: DifficultyHitObject, isHidden: boolean)
    if crrObj.isSpinner or crrObj.objID <= 2 then
        return 0
    end

    local nextObj = crrObj.Next(1)
    local strainTime = crrObj.AdjustedDeltaTime
    local lazyJumpDistance = crrObj.LazyJumpDistance
    local velocity = math_max(1, lazyJumpDistance / strainTime) 
    local currentVisibleObjectDensity = retrieveCurrentVisibleObjectDensity(crrObj)
    local pastObjectDifficultyInfluence = getPastObjectDifficultyInfluence(crrObj)
    local constantAngleNerfFactor = getConstantAngleNerfFactor(crrObj)
    local noteDensityDifficulty = calculateDensityDifficulty(nextObj, velocity, constantAngleNerfFactor, pastObjectDifficultyInfluence, currentVisibleObjectDensity)
    
    local hiddenDifficulty = isHidden and calculateHiddenDifficulty(crrObj, pastObjectDifficultyInfluence, currentVisibleObjectDensity, velocity, constantAngleNerfFactor) or 0

    local preemptDifficulty = calculatePreemptDifficulty(velocity, constantAngleNerfFactor, crrObj.Preempt)

    local readingDifficulty = DifficultyEvaluator.Normalise(1.5, preemptDifficulty, hiddenDifficulty, noteDensityDifficulty)

    readingDifficulty *= getHighBPMBonus(crrObj.AdjustedDeltaTime)

    return readingDifficulty
end

return ReadingEvaluator