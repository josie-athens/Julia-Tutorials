# This file was generated, do not modify it. # hide
@chain kfm begin
	select(Not([:no, :sex, :ml_suppl]))
	describe(:mean, :median, :std, rel_dis => :cv)
end

kfm_tbl = DataFrame(
	@chain kfm begin
		select(Not([:no, :sex, :ml_suppl]))
		describe(:mean, :median, :std, rel_dis => :cv)
	end
);

kfm_tbl.variable = [
	"Breast milk intake (dl/day)",
	"Weight (kg)",
	"Maternal Weight (kg)",
	"Maternal Height (m)"
];

pretty_table(
	kfm_tbl;
	header = ["Variable", "Mean", "Median", "SD", "CV"],
	formatters = ft_printf("%5.2f")
)