local workspace = game:GetService("Workspace")
local DifficultyEvaluator = require(script.Parent)
local DifficultyCalculationUtils = require(script.Parent.DifficultyCalculationUtils)
local preprocessing = require(workspace.DifficultyCalculator.DifficultyHitObjects)


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

local function smootherstep(x: number, _start: number, _end: number)
	x = math.clamp((x - _start) / (_end - _start), 0.0, 1.0)
	return x * x * x * (x * (6.0 * x - 15.0) + 10.0)
end

local function calculateDensityDifficulty(nextObj: DifficultyHitObject?, 
    velocity: number, 
    constantAngleNerfFactor: number, 
    pastObjectDifficultyInfluence: number,
    currentVisibleObjectDensity: number)
    local futureObjectDifficultyInfluence = math.sqrt(currentVisibleObjectDensity)

    if nextObj then
        futureObjectDifficultyInfluence *= smootherstep(nextObj.LazyJumpDistance, 15, DISTANCE_INFLUENCE_THRESHOLD)
    end

    local noteDensityDifficulty = math.pow(pastObjectDifficultyInfluence + futureObjectDifficultyInfluence, 1.7) * 0.4 * constantAngleNerfFactor * velocity

    noteDensityDifficulty = math.max(0, noteDensityDifficulty - DENSITY_DIFFICULTY_BASE)
    noteDensityDifficulty = math.pow(noteDensityDifficulty, 0.45) * DENSITY_MULTIPLIER

    return noteDensityDifficulty
end

local function calculateHiddenDifficulty(
    crrObj: DifficultyHitObject, 
    pastObjectDifficultyInfluence: number, 
    currentVisibleObjectDensity: number, 
    velocity: number, 
    constantAngleNerfFactor: number)
    
    local timeSpentInvisible = crrObj.DurationSpentInvisible() / crrObj.ClockRate

    local timeSpentInvisibleFactor = math.pow(timeSpentInvisible, 2.2) * 0.022

    local densityFactor = math.pow(currentVisibleObjectDensity + pastObjectDifficultyInfluence, 3.3) * 3
    local hiddenDifficulty = (timeSpentInvisibleFactor + densityFactor) * constantAngleNerfFactor * velocity * 0.01
    hiddenDifficulty = math.pow(hiddenDifficulty, 0.4) * HIDDEN_MULTIPLIER

    local previousObj = crrObj.Previous(1)

    if crrObj.LazyJumpDistance == 0 and crrObj.OpacityAt(previousObj.Time + previousObj.Preempt) == 0 and previousObj.Time + previousObj.Preempt > crrObj.Time then
        hiddenDifficulty += HIDDEN_MULTIPLIER * 7500 / math.pow(crrObj.Time, 1.5)
    end

    return hiddenDifficulty
end

local function calculatePreemptDifficulty(velocity: number, constantAngleNerfFactor: number, preempt: number)
    local preemptDifficulty = math.pow((PREEMPT_STARTING_POINT - preempt + math.abs(preempt - PREEMPT_STARTING_POINT)) / 2, 2.5) / PREEMPT_BALANCING_FACTOR
    preemptDifficulty *= constantAngleNerfFactor * velocity

    return preemptDifficulty
end

local function retrievePastVisibleObjects(current: DifficultyHitObject): {DifficultyHitObject}
    local objList = {}
    for i = 1, current.objID do
        local hitObject = current.Previous(i)
        if not hitObject or
            current.Time - hitObject.Time > READING_WINDOW_SIZE or
            hitObject.Time + hitObject.Preempt < current.Time
        then
            break
        end

        objList[#objList + 1] = hitObject
    end

    return objList
end

local function getTimeNerfFactor(dt)
    return math.clamp(2 - dt / (READING_WINDOW_SIZE / 2), 0, 1)
end

local function getPastObjectDifficultyInfluence(crrObj: DifficultyHitObject)
    local pastObjectDifficultyInfluence = 0
    local pastVisibleObjs = retrievePastVisibleObjects(crrObj)
    for i = 1, #pastVisibleObjs do
        local loopObj = pastVisibleObjs[i]

        local loopDifficulty = crrObj.OpacityAt(loopObj.Time)
        loopDifficulty *= smootherstep(loopObj.LazyJumpDistance, 15, DISTANCE_INFLUENCE_THRESHOLD)
        
        local timeBetweenCurrAndLoopObj = crrObj.StrainTime - loopObj.Time
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
        if current.Time - hitObject.Time > READING_WINDOW_SIZE or
            hitObject.Time + hitObject.Preempt < current.Time then
            break
        end

        local timeBetweenCurrAndLoopObj = hitObject.StrainTime - current.Time
        local timeNerfFactor = getTimeNerfFactor(timeBetweenCurrAndLoopObj)

        visibleObjectCount += hitObject.OpacityAt(current.Time) * timeNerfFactor
        
        hitObject = hitObject.Next(1)
    end

    return visibleObjectCount
end

local function getConstantAngleNerfFactor(current: DifficultyHitObject)
    local constantAngleCount = 0
    local index = 0
    local currentTimeGap = 0

    while currentTimeGap < MINIMUM_ANGLE_RELEVANCY_TIME do
        local loopObj = current.Previous(index + 1)

        if not loopObj then
            break
        end

        local longIntervalFactor = 1 - DifficultyCalculationUtils.ReverseLerp(loopObj.StrainTime, MAXIMUM_ANGLE_RELEVANCY_TIME, MINIMUM_ANGLE_RELEVANCY_TIME)

        if loopObj.Angle and current.Angle then
            local angleDifference = math.abs(current.Angle - loopObj.Angle)
            local stackFactor = smootherstep(loopObj.LazyJumpDistance, 0, NORMALIZED_RADIUS)

            constantAngleCount += math.cos(3 * math.min(math.rad(30), angleDifference * stackFactor)) * longIntervalFactor
        end

        currentTimeGap = current.Time - loopObj.Time
        index += 1
    end

    return math.clamp(2 / constantAngleCount, 0.2, 1)
end

function ReadingEvaluator.GetReadingDiff(crrObj: DifficultyHitObject, isHidden: boolean)
    if crrObj.isSpinner or crrObj.objID < 2 then
        return 0
    end

    local nextObj = crrObj.Next(1)
    local velocity = math.max(1, crrObj.LazyJumpDistance / crrObj.StrainTime)
    local currentVisibleObjectDensity = retrieveCurrentVisibleObjectDensity(crrObj)
    local pastObjectDifficultyInfluence = getPastObjectDifficultyInfluence(crrObj)
    local constantAngleNerfFactor = getConstantAngleNerfFactor(crrObj)
    local noteDensityDifficulty = calculateDensityDifficulty(nextObj, velocity, constantAngleNerfFactor, pastObjectDifficultyInfluence, currentVisibleObjectDensity)
    
    local hiddenDifficulty = isHidden and calculateHiddenDifficulty(crrObj, pastObjectDifficultyInfluence, currentVisibleObjectDensity, velocity, constantAngleNerfFactor) or 0

    local preemptDifficulty = calculatePreemptDifficulty(velocity, constantAngleNerfFactor, crrObj.Preempt)

    local difficulty = DifficultyEvaluator.Normalise(1.5, preemptDifficulty, hiddenDifficulty, noteDensityDifficulty)

    return difficulty
end

return ReadingEvaluator