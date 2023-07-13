# This file was generated, do not modify it.

using StatsKit
using DataFrameMacros
using Chain
using FreqTables
using PrettyTables
using RCall
using RData
using RDatasets
using ScientificTypes: schema
include("pubh.jl");

wcgs2 = DataFrame(CSV.File("data/wcgs.csv"))
wcgs2 |> schema

wcgs2 |> size

wcgs2 |> names

kfm = load("data/kfm.rds")
kfm |> schema

wcgs = DataFrames.rename!(
	wcgs2,
	:age0 => :age,
	:height0 => :height,
	:weight0 => :weight,
	:sbp0 => :sbp,
	:dbp0 => :dbp,
	:chol0 => :chol,
	:behpat0 => :beh_pat,
	:ncigs0 => :ncigs,
	:dibpat0 => :dib_pat,
	:chd69 => :chd,
	:typechd => :type_chd,
	:time169 => :time,
	:arcus0 => :arcus
);

wcgs[1:5, 2:6]

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

wcgs.smoker = wcgs.ncigs .> 0;

wcgs.smoker = categorical(
	recode(wcgs.smoker, 0 => "Non-Smoker", 1 => "Smoker"),
	ordered=true
);

pretty_table(
	freqtable(wcgs, :chd, :smoker);
	row_labels = ["CHD", "No CHD"],
	header = ["Non Smoker", "Smoker"]
)

@chain wcgs begin
	groupby([:chd, :smoker])
	combine(nrow => :value)
	unstack(:smoker, :value)
end

pretty_table(
	@chain wcgs begin
		freqtable(:chd, :smoker)
		prop(margins = 1)
	end;
	row_labels = ["CHD", "No CHD"],
	header = ["Non Smoker", "Smoker"],
	formatters = ft_printf("%5.2f")
)

wcgs.height = wcgs.height * 2.54
wcgs.weight = wcgs.weight * 0.4536;

@transform!(wcgs, :height_cent = @bycol :height .- mean(:height));

@chain wcgs begin
	select(:height, :height_cent)
	describe(:mean, :median, :std)
end

wcgs.height_cent[1:5]

@subset(wcgs, :smoker .== "Smoker") |> nrow

smokers = @subset(wcgs, :smoker .== "Smoker")
smokers[1:5, 2:6]

smokers |> nrow

wcgs.chd[1:5]

@chain wcgs begin
	select(:ncigs, :smoker)
	first(5)
end

first(
	@select(wcgs, :ncigs, :smoker),
	5
)

@chain smokers begin
	select(Not([:id, :type_chd, :ncigs, :beh_pat]))
	size
end

@chain kfm begin
  select(Not(1, 3))
	describe(:min, :max, :mean, :median, :std)
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

kfm_mat = Matrix(
	@chain kfm begin
		select(Not(1, 3, 5))
	end
);

kfm_mat[1:5, :]

mao = dataset("gap", "mao")
mao |> schema

std(mao.Age)

@chain mao begin
	select(:Age)
	describe(:min, :max, :mean, :median, :std, rel_dis => :cv)
end

round(
	std(skipmissing(mao.Age)),
	digits=3
)

iris = dataset("datasets", "iris")
iris |> schema

@chain iris begin
  select(:Species)
  unique()
end

gdf = groupby(iris, :Species)
subdf_setosa = gdf[1]
describe(subdf_setosa, :mean, :median, :std, rel_dis => :cv)

@chain iris begin
  @subset(:Species .== "setosa")
  select(Not(:Species))
  describe(:mean, :median, :std, rel_dis => :cv)
end

