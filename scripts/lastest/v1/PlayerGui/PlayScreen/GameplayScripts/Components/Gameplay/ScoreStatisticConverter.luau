--[LOCATION]:[StarterGui.PlayScreen.GameplayScripts.Components.Gameplay.ScoreStatisticConverter]
--!strict

--[[
	Version 0:
	ExtraData = {
			HaveReplay = CanUploadReplay,
			Accurancy = tostringAcc,
			MaxCombo = AccuracyData.MaxCombo,
			Grade = GameplayRank,
			Date = os.time(),
			ExtraAccurancy = {AccuracyData.h300,AccuracyData.h100,AccuracyData.h50,AccuracyData.miss},
			Speed = SongSpeed,
			PS = TotalRewardedPS,
			Mod = {
				FL = Flashlight,
				SL = SliderMode,
				NF = NoFail,
				HD = HiddenMod,
				HR = HardRock,
				EZ = EasyMod,
				AT = AutoPlay,
				TD = TouchDeviceDetected
			}
		},
		
	Version 1:
	ExtraData = {
			Version = 1,
			HaveReplay = CanUploadReplay,
			Accuracy = GameAccuracy,
			MaxCombo = AccuracyData.MaxCombo,
			Date = os.time(),
			Statistic = {
				h300 = AccuracyData.h300,
				h100 = AccuracyData.h100,
				h50 = AccuracyData.h50,
				missCount = AccuracyData.miss
			},
			Performance = TotalRewardedPS,
			ModData = {
				FL = Flashlight,
				NS = not SliderMode,
				NF = NoFail,
				HD = HiddenMod,
				HR = HardRock,
				EZ = EasyMod,
				AT = AutoPlay,
				TD = TouchDeviceDetected,
				SA = SongSpeed
			},
			Score = RankedScore,
			ScoreV2 = getScoreV2(),			
			Consistency = getConsistency(),
		}::ScoreStatistic,
]]

local modData = require(workspace.ModData)
local converter = {}
local CURRENT_VERSION = 1

type ScoreStatisticVersion0 = {
	Version:number?,
	HaveReplay:boolean,
	Accurancy:string,
	MaxCombo:number,
	Grade:string,
	Date:number,
	ExtraAccurancy:{number},
	Speed:number,
	PS:number,
	Mod:{
		FL:boolean,
		SL:boolean,
		NF:boolean,
		HD:boolean,
		HR:boolean,
		EZ:boolean,
		AT:boolean,
		TD:boolean
	}
}

type ScoreStatisticVersion1 = {
	Version:number,
	HaveReplay:boolean,
	Accuracy:number,
	MaxCombo:number,
	Date:number,
	Statistic:{
		h300:number,
		h100:number,
		h50:number,
		missCount:number
	},
	ModData:modData.ModData,
	Consistency:number,
	Score:number,
	ScoreV2:number,
	Performance:number
}

export type ScoreStatistic = ScoreStatisticVersion1

local ConvertVersion = {
	["Default"] = function(oldStat:ScoreStatisticVersion0):ScoreStatistic
		local newStat:ScoreStatistic = {
			Version = 0,
			HaveReplay = oldStat.HaveReplay,
			Accuracy = tonumber(oldStat.Accurancy) or 0,
			MaxCombo = oldStat.MaxCombo,
			Date = oldStat.Date,
			Statistic = {
				h300 = oldStat.ExtraAccurancy[1],
				h100 = oldStat.ExtraAccurancy[2],
				h50 = oldStat.ExtraAccurancy[3],
				missCount = oldStat.ExtraAccurancy[4]
			},
			ModData = {
				FL = oldStat.Mod.FL,
				NS = not oldStat.Mod.SL,
				NF = oldStat.Mod.NF,
				HD = oldStat.Mod.HD,
				HR = oldStat.Mod.HR,
				EZ = oldStat.Mod.EZ,
				AT = oldStat.Mod.AT,
				TD = oldStat.Mod.TD,
				SA = oldStat.Speed
			},
			Consistency = 0,
			Score = 0,
			ScoreV2 = 0,
			Performance = oldStat.PS
		}		
		
		return newStat
	end,
}

type InputStatictic = ScoreStatistic|ScoreStatisticVersion0

function converter.ConvertStatictic(stat:InputStatictic):ScoreStatistic
	local scoreVersion = stat.Version
	if scoreVersion == CURRENT_VERSION then
		return stat::ScoreStatistic
	end
	
	local newStat:ScoreStatistic
	
	if not scoreVersion then
		newStat = ConvertVersion.Default(stat::ScoreStatisticVersion0)
	end
	
	return newStat
end

return converter