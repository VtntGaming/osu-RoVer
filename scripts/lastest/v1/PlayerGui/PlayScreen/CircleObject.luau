local Tool = {}

-- 01234567
--[[
		^	^	^	^	^	^	^
	|	|	|	|	|	|	|	| osu!mania hold
	|	|	|	|	|	|	| 3 bit integer on how many combo to skip
	|	|	|	|	|	|>>>^
	|	|	|	|	|>>>>>>>^
	|	|	|	| Spinner
	|	|	| New combo
	|	| Slider
	| Circle
	0	1	2	3	4	5	6	7
]]

local function convertTo8BitBinary(num)
	local Bits = {}
	local Values = {
		[0] = false, [1] = true
	}
	
	for i = 1, 8 do
		local crrBit = num%2
		table.insert(Bits, Values[crrBit])
		if num == 0 then
			break
		end
		num = math.floor(num/2)
	end
	for i = #Bits, 7 do
		table.insert(Bits, false)
	end
	
	return Bits
end

local function getAmountColorSkip(BitData)
	local count = 0
	for i , data in pairs(BitData) do
		count = data and count * 2 + 1 or count * 2
	end
	return count
end


function Tool.GetObjectProperties(ObjType)
	local Bits = convertTo8BitBinary(ObjType)
	local Properties = {
		isCircle = Bits[1],
		isSlider = Bits[2],
		isNewCombo = Bits[3],
		isSpinner = Bits[4],
		ColorSkip = getAmountColorSkip({Bits[7], Bits[6], Bits[5]})
	}
	-- we don't includes osu!mania hold
	
	return Properties
end

return Tool