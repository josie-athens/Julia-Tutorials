# This file was generated, do not modify it. # hide
wcgs.smoker = wcgs.ncigs .> 0
freqtable(wcgs, :chd, :smoker)

wcgs.smoker = categorical(recode(wcgs.smoker, 0 => "Non-Smoker", 1 => "Smoker"), ordered=true)
freqtable(wcgs, :chd, :smoker)

pretty_table(
	freqtable(wcgs, :smoker, :chd);
	header = ["CHD", "No CHD"],
	row_labels = ["Non Smoker", "Smoker"]
)

@chain wcgs begin
	freqtable(:smoker, :chd)
	prop(margins = 2)
end

pretty_table(
	@chain wcgs begin
		freqtable(:smoker, :chd)
		prop(margins = 2)
	end;
	header = ["CHD", "No CHD"],
	row_labels = ["Non Smoker", "Smoker"],
	formatters = ft_printf("%5.2f")
)