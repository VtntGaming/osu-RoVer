--[LOCATION]:[Workspace.OsuConvert.test]
local function GetWideAngleBonus(Angle)

	if Angle > 180 then
		Angle = 180 - (Angle-180)
	end
	
	Angle = math.rad(Angle)
	
	if Angle < math.pi / 3 then -- 60
		return 0
	elseif Angle < 2 * math.pi / 3 then -- 120
		return math.pow(math.sin(1.5 * (Angle - math.pi / 3)), 2)
	else
		return 0.25 + 0.75 * math.pow(math.sin(1.5 * (math.pi - Angle)), 2)
	end
end

local function GetAcuteAngleBonus(Angle)
	Angle = math.rad(Angle)

	if Angle < math.pi / 3 then -- 60
		return 0.5 + 0.5 * math.pow(math.sin(1.5 * Angle), 2)
	elseif Angle < 2 * math.pi / 3 then -- 120
		return math.pow(math.sin(1.5 * (2 * math.pi / 3 - Angle)), 2)
	else
		return 0
	end
end

local function GetAngleBonus(Angle,CurrentMoveTime,PrevMoveTime,lengthprev,lengthcurrent)

	local AngleBonus = math.min(lengthprev,lengthcurrent)
	local Acute = GetAcuteAngleBonus(Angle)
	local wide = GetWideAngleBonus(Angle)

	if PrevMoveTime > 100 then
		Acute = 0
	else
		Acute *= math.min(2,math.pow((100-PrevMoveTime)/15,1.5))
		wide *= math.pow(PrevMoveTime/100,6)
	end
	if Acute > wide then
		AngleBonus = math.min(AngleBonus,150/PrevMoveTime) * math.min(1,math.pow(math.min(PrevMoveTime,CurrentMoveTime)/150,2))
	end


	AngleBonus *= math.max(Acute,wide)/130
	
	local AngleMultiplier = 1+(AngleBonus/0.75)*0.2

	return AngleMultiplier
end

for i = 1,360 do
	print(i,GetAngleBonus(i,1000,900,100,200))
end