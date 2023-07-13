# This file was generated, do not modify it.

using StatsKit
using DataFrameMacros
using Chain
using RData
using RCall
using ScientificTypes: schema

using AlgebraOfGraphics
using CairoMakie
using MakieThemes
CairoMakie.activate!(type = "svg")
AoG = AlgebraOfGraphics
data = AoG.data
set_theme!(ggthemr(:fresh))
update_theme!(Axis = (width = 400, height = 300))

using PairPlots

wcgs = load("data/wcgs.rds")
wcgs |> schema

kfm = load("data/kfm.rds")
kfm |> schema

flu = DataFrame(CSV.File("data/fluraw.csv"))
flu |> schema

birth = load("data/birthwt.rds")
birth |> schema

energy = rcopy(R"ISwR::energy")
energy |> schema

iris = rcopy(R"datasets::iris")
iris |> schema

air = rcopy(R"datasets::airquality");

air.Month = categorical(recode(
    air.Month,
    5 => "May",
    6 => "Jun",
    7 => "Jul",
    8 => "Aug",
    9 => "Sep"
), ordered=true);

air |> schema

data(birth) *
mapping(:bwt => "Birth weight (g)") *
histogram(bins=20, normalization=:density) *
visual(color=:pink) |>
draw

data(wcgs) *
mapping(:sbp => "SBP (mm Hg)") *
histogram(bins=30) *
visual(color=:plum) |>
draw

data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	color=:chd => "CHD", dodge=:chd
) *
histogram(bins=30, normalization=:pdf) |>
draw

data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	layout=:chd => "CHD"
) *
histogram(bins=30, normalization=:pdf) |>
draw

data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	layout=:chd => "CHD"
) *
AoG.density(datalimits=extrema) *
visual(color=:plum1) |>
draw

data(wcgs) *
mapping(
	:dbp => log => "log (DBP)",
	color=:chd => "CHD", dodge=:chd
) *
AoG.density(datalimits=extrema) |>
draw

data(wcgs |> dropmissing) *
mapping(
	:chol => "Cholesterol (mg/dl)",
	color=:chd => "CHD", dodge=:chd
) *
AoG.density(datalimits=extrema) |>
draw

let
    plt = data(birth) *
    mapping(:bwt) *
    visual(QQNorm, qqline=:fitrobust, markersize=5, color=:firebrick)

    draw(
        plt, axis=(
        xlabel="Normal quantiles",
        ylabel="Birth weight (g)")
    )
end

let
    plt = data(wcgs) * mapping(:dbp) *
    visual(
        QQNorm, qqline=:fitrobust,
        markersize=5, color=:forestgreen
    )

    draw(
        plt, axis=(xlabel="Normal quantiles",
        ylabel="DBP (mm Hg)")
    )
end

let
    plt = data(wcgs) * mapping(:dbp => log10) *
    visual(QQNorm, qqline=:fitrobust, markersize=5)

    draw(
        plt, axis=(xlabel="Normal quantiles",
        ylabel="DBP (mm Hg)", yscale=log10,
        yminorticksvisible = true, yminorgridvisible = true,
        yminorticks = IntervalsBetween(5))
    )
end

let
    plt = data(wcgs) * mapping(:dbp => log10) *
    visual(QQNorm, qqline=:fitrobust, markersize=5)

    draw(
        plt, axis=(xlabel="Normal quantiles",
        ylabel="log (DBP)", yscale=Makie.pseudolog10)
    )
end

data(kfm) *
mapping(
	:mat_weight => "Maternal weight (kg)",
  :dl_milk => "Breast-milk intake (dl/day)",
  color = :sex => "Sex"
) *
visual(Scatter, markersize=5) |>
draw

let
    layers = visual(Scatter, markersize=5) + linear()
    data(kfm) *
    mapping(
        :mat_weight => "Maternal weight (kg)",
        :dl_milk => "Breast-milk intake (dl/day)"
    ) *
    layers * mapping(color=:sex => "Sex") |>
    draw
end

let
	layers = visual(Scatter, markersize=5, color=:firebrick) + smooth()
	data(kfm) *
	mapping(
		:mat_weight => "Maternal weight (kg)",
    	:dl_milk => "Breast-milk intake (dl/day)"
	) *
	layers |>
	draw
end

let
	layers = visual(Scatter, markersize=5) + linear()
	data(kfm) *
	mapping(
		:mat_weight => "Maternal weight (kg)",
    	:dl_milk => "Breast-milk intake (dl/day)"
	) *
	layers * mapping(color=:sex, marker=:sex) |>
	draw
end

let
	nms = names(iris, 1:4)
	p = select(iris, nms .=> replace.(nms, "_" => " "))
	pairplot(p)
end

let
	nms = names(iris, 1:4)
	p = select(iris, nms .=> replace.(nms, "_" => " "))
	pairplot(p => (
		PairPlots.Scatter(color=:firebrick, markersize=5),
		PairPlots.MarginDensity(),
		)
	)
end

let
	air2 = air |> dropmissing
	nms = names(air2, 1:4)
	p = select(air2, nms)
	pairplot(p,
		labels = Dict(
			:Temp => "Temp (°F)",
			:Solar_R => "Radiation (Å)",
			:Wind => "Wind (mph)",
			:Ozone => "Ozone (ppb)",
		)
	)
end

let
	air2 = air |> dropmissing
	nms = names(air2, 1:4)
	p = select(air2, nms)
	pairplot(
		p => (
		PairPlots.Scatter(color=:firebrick, markersize=5),
		PairPlots.MarginDensity(),
		),
		labels = Dict(
			:Temp => "Temp (°F)",
			:Solar_R => "Radiation (Å)",
			:Wind => "Wind (mph)",
			:Ozone => "Ozone (ppb)",
		)
	)
end

let
	d = data(air |> dropmissing) * mapping(:Wind, :Ozone)
	p1 = d * visual(Scatter, markersize=5) * mapping(color=:Month)
	p2 = d * smooth()
	draw(
        p1 + p2,
        axis=(
            xlabel="Wind (mph)",
            ylabel="Ozone (ppb)"
        )
    )
end

let
    labels = ["Child" "Young" "Mid" "Old"]
    plt = data(flu) *
    mapping(
        :week => "Date",
        [:child, :young, :mid, :old],
        color=dims(1) => renamer(labels) => "Age group"
    ) *
    visual(Lines)
    draw(
        plt,
        axis=(xlabel="Date", ylabel="Number of cases")
    )
end

flu_melt = stack(flu, Not(:week));
first(flu_melt, 5)

data(flu_melt) *
mapping(
	:week => "Date",
    :value => "Number of cases",
    color=:variable => "Age group"
) *
visual(ScatterLines, markersize=7) |>
draw

data(wcgs |> dropmissing) *
mapping(
	:chd => "CHD",
    :chol => "Cholesterol (mg/dl)"
) *
visual(BoxPlot, color=:plum3) |>
draw

data(@subset(wcgs |> dropmissing, :chol.<500) ) *
mapping(
	:chd => "CHD",
    :chol => "Cholesterol (mg/dl)",
    color=:chd => "CHD"
) *
visual(BoxPlot) |>
draw

data(birth) *
mapping(
	:race => "Ethnicity",
    :bwt => "Birth weight (g)",
    color=:smoke => "Smoking status",
    dodge = :smoke
) *
visual(BoxPlot) |>
draw

data(birth) *
mapping(
	:Race => "",
    :bwt => "Birth weight (g)",
    color=:Race => "Ethnicity",
    layout = :smoke
) *
visual(BoxPlot) |>
draw

data(energy) *
mapping(
	:stature => "Stature",
    :expend => "Energy expenditure (MJ)"
) *
visual(
    RainClouds, clouds=nothing,
    plot_boxplots=false, markersize=7
) |>
draw

data(energy) *
mapping(
	:stature => "Stature",
    :expend => "Energy expenditure (MJ)"
) *
visual(
    RainClouds, clouds=violin,
    plot_boxplots=false, markersize=7
) |>
draw

RCall.ijulia_setdevice(MIME("image/svg+xml"); width=7, height=5)
R"""
require("pubh", quietly=TRUE)
theme_set(sjPlot::theme_sjplot2(base_size = 14))
energy = $energy
print(
    energy %>%
    strip_error(expend ~ stature, size=2) %>%
    gf_labs(
        y = "Energy expenditure (MJ)",
        x = "Stature"
    )
)
""";

R"""
print(
    energy %>%
    strip_error(expend ~ stature, size=2) %>%
    gf_labs(
        y = "Energy expenditure (MJ)",
        x = "Stature"
    ) %>%
    gf_star(x1=1, x2=2, y1=13.3, y2=13.4, y3=13.5)
)
""";

R"""
birth = $birth
print(
    birth %>%
    strip_error(bwt ~ smoke, pch = ~Race, col = ~Race) %>%
    gf_labs(
        x = "Smoking status",
        y = "Birth weight (g)"
    )
)
""";

