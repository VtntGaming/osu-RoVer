export type ModData = {
	HD:boolean?,	-- Hidden
	HR:boolean?,	-- Hardrock
	EZ:boolean?,	-- Easy
	NF:boolean?,	-- No fail
	NS:boolean?,	-- No sliders
	SA:number?,		-- Speed adjust
	FL:boolean?,	-- Flashlight
	RX:boolean?,	-- Relax
	AP:boolean?,	-- Autopilot
	AT:boolean?,	-- Autoplay
	SO:boolean?,	-- SpunOut
	V2:boolean?,	-- ScoreV2
	TD:boolean?,	-- Touchdevice
	DA:{Active:boolean?, Data:{
		CS:number?, AR:number?, OD:number?, HP:number?
	}?}?,			-- Difficulty adjust
	-- osu!lazer possible mods
	MG:{
		Active:boolean?, 
		Strength:number?
	}?,				-- Magnetised

}

return nil