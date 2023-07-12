# This file was generated, do not modify it. # hide
pretty_table(
	@chain wcgs begin
		freqtable(:chd, :smoker)
		prop(margins = 1)
	end;
	row_labels = ["CHD", "No CHD"],
	header = ["Non Smoker", "Smoker"],
	formatters = ft_printf("%5.2f")
)