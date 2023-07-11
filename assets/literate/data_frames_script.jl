# This file was generated, do not modify it.

using DataFramesMeta, RCall, RDatasets, RData, FreqTables
using StatsKit, PrettyTables
using ScientificTypes: schema

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

first(wcgs, 5)

wcgs[1:5, 2:6]

wcgs.chd = categorical(recode(wcgs.chd, 0 => "No CHD", 1 => "CHD"), ordered=true)
wcgs.arcus = categorical(recode(wcgs.arcus, 0 => "Absent", 1 => "Present"), ordered=true)
wcgs.beh_pat = categorical(recode(wcgs.beh_pat, 1 => "A1", 2 => "A2", 3 => "B1", 4 => "B2"), ordered=true)
wcgs.dib_pat = categorical(recode(wcgs.dib_pat, 0 => "B", 1 => "A"), ordered=true)
wcgs.type_chd = categorical(recode(wcgs.type_chd, 0 => "No CHD", 1 => "MI or SD",
	2 => "Angina", 3 => "Silent MI"), ordered=true);

@chain wcgs begin
    select([:chd, :arcus, :beh_pat, :dib_pat, :type_chd])
    schema
end

levels(wcgs.chd)

freqtable(wcgs, :chd, :dib_pat)

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

wcgs.height = wcgs.height * 2.54
wcgs.weight = wcgs.weight * 0.4536;

@subset(wcgs, :smoker .== "Smoker") |> nrow

smokers = @subset(wcgs, :smoker .== "Smoker")
smokers[1:5, 2:6]

wcgs |> nrow

smokers |> nrow

wcgs.chd[1:5]

@chain wcgs begin
	select(:ncigs, :smoker)
	first(5)
end

@chain smokers begin
	select(Not([:id, :type_chd, :ncigs, :beh_pat]))
	size
end

@chain kfm begin
    select(Not(1, 3))
	describe(:min, :max, :mean, :median, :std)
end

"""
	rel_dis()

Estimates the relative dispersion (coefficient of variation) of a vector.
"""
rel_dis(x) = std(x) / mean(x)

@chain kfm begin
	select(Not(1, 3, 5))
	describe(:mean, :median, :std, rel_dis => :cv)
end

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

kfm_mat = Matrix(
	@chain kfm begin
		select(Not(1, 3, 5))
	end
);

kfm |> size

kfm_mat |> size

kfm_mat[1:5, :]

mao = dataset("gap", "mao")
mao |> schema

mao[1:7, 2:6]

describe(mao, :nmissing)

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

