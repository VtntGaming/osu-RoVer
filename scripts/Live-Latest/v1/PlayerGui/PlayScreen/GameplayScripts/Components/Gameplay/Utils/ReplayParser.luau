--!strict

export type ReplayData = {
	Score: number,
	MaxCombo: number,
	Accuracy: { number },
	User: string,
	Date: number,
	PS: number,
	FileName: string,
	Speed: number,
}

type Ctx = {
	finalReplayData: ReplayData,
	setFinalReplayData: (ReplayData) -> (),
	setBeatmapByFilename: (string) -> (boolean),
	setEnvKey: (string, boolean) -> (),
}

local ReplayParser = {}

function ReplayParser.defaultData(): ReplayData
	return {
		Score = 0,
		MaxCombo = 0,
		Accuracy = { 0, 0, 0, 0 },
		User = "",
		Date = 0,
		PS = 0,
		FileName = "",
		Speed = 1,
	}
end

function ReplayParser.processLine(line: string, ctx: Ctx): boolean
	local data = ctx.finalReplayData

	if string.find(line, "USER") then
		data.User = string.sub(line, 6, #line)
	elseif string.find(line, "DATE") then
		data.Date = tonumber(string.sub(line, 6, #line)) or 0
	elseif string.find(line, "SCORE") then
		data.Score = tonumber(string.sub(line, 7, #line)) or 0
	elseif string.find(line, "MAXCOMBO") then
		data.MaxCombo = tonumber(string.sub(line, 10, #line)) or 0
	elseif string.find(line, "PS") then
		data.PS = tonumber(string.sub(line, 4, #line)) or 0
	elseif string.find(line, "ACCURACY") then
		local accFormat = string.sub(line, 10, #line)
		local nextIdx = string.find(accFormat, " ")
		if not nextIdx then
			return true
		end
		nextIdx -= 1
		local a = 1
		for i = 1, 4 do
			data.Accuracy[i] = tonumber(string.sub(accFormat, a, nextIdx)) or 0
			a = nextIdx
			if i <= 3 then
				if i < 3 then
					nextIdx = string.find(accFormat, " ", nextIdx + 1)
				else
					nextIdx = string.find(accFormat, "\n", nextIdx + 1)
				end
				if not nextIdx then
					break
				end
				nextIdx -= 1
			end
		end
	elseif string.find(line, "MOD") then
		local modFormatString = string.sub(line, 5, #line)
		local bitBoolean = { ["0"] = false, ["1"] = true }
		-- MOD StableNL EnableTouchDevice AT HC HD HR EZ SL FL
		local modFormat = {
			"--osuStableNotelock",
			"Replay_TouchDevice",
			"AutoPlay",
			"NoFail",
			"HiddenMod",
			"HardRock",
			"EasyMod",
			"SliderMode",
			"Flashlight",
		}
		for i = 1, #modFormatString do
			local key = modFormat[i]
			if key then
				ctx.setEnvKey(key, bitBoolean[string.sub(modFormatString, i, i)] == true)
			end
		end
	elseif string.find(line, "FILENAME") then
		local filename = string.sub(line, 10, #line)
		data.FileName = filename
		local ok = ctx.setBeatmapByFilename(filename)
		if not ok then
			ctx.setFinalReplayData(ReplayParser.defaultData())
			return false
		end
	elseif string.find(line, "SPEED") then
		data.Speed = tonumber(string.sub(line, 7, #line)) or 1
	end

	ctx.setFinalReplayData(data)
	return true
end

function ReplayParser.parse(raw: string, ctx: Ctx): boolean
	local i = 1
	local finish = false
	repeat
		local nextIdx = string.find(raw, "\n", i)
		if not nextIdx then
			finish = true
			break
		elseif i == 0 or not tonumber(string.sub(raw, i, i)) then
			local ok = ReplayParser.processLine(string.sub(raw, i, nextIdx - 1), ctx)
			if not ok then
				return false
			end
			i = nextIdx + 1
			continue
		end
		finish = true
		i = nextIdx + 1
	until finish == true

	return true
end

return ReplayParser
