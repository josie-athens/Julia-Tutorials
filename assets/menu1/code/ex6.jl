# This file was generated, do not modify it. # hide
wcgs.chd = categorical(
	recode(wcgs.chd, 0 => "No CHD", 1 => "CHD"),
	ordered=true
);

wcgs.arcus = categorical(
	recode(wcgs.arcus, 0 => "Absent", 1 => "Present"),
	ordered=true
);

wcgs.beh_pat = categorical(
	recode(wcgs.beh_pat, 1 => "A1", 2 => "A2",
		3 => "B1", 4 => "B2"),
	ordered=true
);

wcgs.dib_pat = categorical(
	recode(wcgs.dib_pat, 0 => "B", 1 => "A"),
	ordered=true
);

wcgs.type_chd = categorical(
	recode(wcgs.type_chd, 0 => "No CHD", 1 => "MI or SD",
		2 => "Angina", 3 => "Silent MI"),
		ordered=true
);

freqtable(wcgs, :chd, :dib_pat)