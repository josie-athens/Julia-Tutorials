<!--This file was generated, do not modify it.-->
# Graphical Analysis

Loading packages:

````julia:ex1
using StatsKit
using DataFrameMacros
using Chain
using RData
using RCall
using ScientificTypes: schema
````

Plotting packages:

````julia:ex2
using AlgebraOfGraphics
using CairoMakie
using MakieThemes
CairoMakie.activate!(type = "svg")
AoG = AlgebraOfGraphics
data = AoG.data
set_theme!(ggthemr(:fresh))
update_theme!(Axis = (width = 400, height = 300))
````

Package for corner plots:

````julia:ex3
using PairPlots
````

## Data

The Western Collaborative Group Study (WCGS) is a well known prospective chohort study. Male participants aged 39 to 59 from 10 California companies were originally selected to study the relationship between behaviour pattern and the risk of coronary heart disease (CHD).

````julia:ex4
wcgs = load("data/wcgs.rds")
wcgs |> schema
````

The `kfm` data frame was collected by Kim Fleischer Michaelsen and contains data for 50 infants of age approximately 2 months. They were weighed immediately before and after each breast feeding. and the measured intake of breast milk was registered along with various other data.

````julia:ex5
kfm = load("data/kfm.rds")
kfm |> schema
````

Data on reported cases of influenza by age group in the 1957 pandemic in England and Wales.

````julia:ex6
flu = DataFrame(CSV.File("data/fluraw.csv"))
flu |> schema
````

Data on birth weights from newborns in a London Hospital.

````julia:ex7
birth = load("data/birthwt.rds")
birth |> schema
````

Data on the energy expenditure in groups of lean and obese womnen.

````julia:ex8
energy = rcopy(R"ISwR::energy")
energy |> schema
````

Fisher’s iris dataset on measurements for three species of iris.

````julia:ex9
iris = rcopy(R"datasets::iris")
iris |> schema
````

Data on air quality and weather conditions in New York, recorded May to September 1973.

````julia:ex10
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
````

## Distributions

### Histograms

We use histograms to look at the distribution of continuous variables. Histograms make most sense for relatively large data (≥ 100 observations). In this fist histogram, we show the density.

````julia:ex11
data(birth) *
mapping(:bwt => "Birth weight (g)") *
histogram(bins=20, normalization=:density) *
visual(color=:pink) |>
draw
````

In general, `AlgebraOfGraphics` uses the following syntax for constructing plots:

`data(my_data) *`
`mapping(:x, :y) *`
`plot_type(key_args) |>`
`draw`

Where:

- `my_data` is the name of the data frame (a DataFrame object).
- `x` is the name of the column (variable) to be plotted on the *x*-axis.
- `y` is the name of the column (variable) to be plotted on the *y*-axis.
- `plot_type` is the kind of plot we want to construct. In many cases this is done with: `visual(PlotType)` (see scatter plot examples).

The default for histograms is to show the absolute frequency (counts):

````julia:ex12
data(wcgs) *
mapping(:sbp => "SBP (mm Hg)") *
histogram(bins=30) *
visual(color=:plum) |>
draw
````

We can compare distributions using the density or the probability density function (pdf), as shown here:

````julia:ex13
data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	color=:chd => "CHD", dodge=:chd
) *
histogram(bins=30, normalization=:pdf) |>
draw
````

We have a better plot when we use *faceting*, i.e., plotting the distributions in two different panels:

````julia:ex14
data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	layout=:chd => "CHD"
) *
histogram(bins=30, normalization=:pdf) |>
draw
````

### Density Plots

Another way to look at the distribution of a continuous variable is with density plots.

````julia:ex15
data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	layout=:chd => "CHD"
) *
AoG.density(datalimits=extrema) *
visual(color=:plum1) |>
draw
````

> **Note:** Function `density` is shared with other packages, hence, we explictly tell `Julia` to use the one from `AlgebraOfGraphics`.

Diastolic blood pressure (DBP) is skewed to the right (see the QQ-Plot). In the following example, we log-transform DBP.

````julia:ex16
data(wcgs) *
mapping(
	:dbp => log => "log (DBP)",
	color=:chd => "CHD", dodge=:chd
) *
AoG.density(datalimits=extrema) |>
draw
````

We have missing values in `chol`, thus we need to drop them before constructing a density plot or else, we would have an error.

````julia:ex17
data(wcgs |> dropmissing) *
mapping(
	:chol => "Cholesterol (mg/dl)",
	color=:chd => "CHD", dodge=:chd
) *
AoG.density(datalimits=extrema) |>
draw
````

### QQ-Plots

The best way to determine if a continuous variable is normally distributed or not is with quantile-quantile plots (QQ-plots). We plot the quantiles of our variable of interest against quantiles from the standard normal distribution (which has a mean μ = 0 and a standard deviation σ = 1). This type of QQ-plots against the normal distribution are known as QQ-normal plots. If the variable is normally distributed, then a linear relationship will be observed.

By default, `QQNorm` uses the name of the variable as title for the *x*-axis, whih is wrong! We define the titles of the plot in `draw`:

````julia:ex18
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
````

Right-skewed variables, show an upper right curve in the QQ-plot:

````julia:ex19
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
````

The next two plots, shows the use of log scales.

````julia:ex20
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
````

An alternative to log-scales, is to log-transform the variable, in this case, the scale of the axis needs to also be adjusted.

````julia:ex21
let
    plt = data(wcgs) * mapping(:dbp => log10) *
    visual(QQNorm, qqline=:fitrobust, markersize=5)

    draw(
        plt, axis=(xlabel="Normal quantiles",
        ylabel="log (DBP)", yscale=Makie.pseudolog10)
    )
end
````

## Associations Between Continuous Variables

### Scatter Plots

We use scatter plots to look at the relationship between two continuous variables. By default, the dependent variable (response) is plotted on the *y*-axis while the independent variable (explanatory) is plotted on the *x*-axis.

From the `kfm` dataset, let’s see if there is a relationship between the weight of the mother and the breast-milk intake of the child.

````julia:ex22
data(kfm) *
mapping(
	:mat_weight => "Maternal weight (kg)",
  :dl_milk => "Breast-milk intake (dl/day)",
  color = :sex => "Sex"
) *
visual(Scatter, markersize=5) |>
draw
````

We can extend plots by adding new *layers*. In the following example, we use two layers: one for the scatter plot and a second to add a line representing a linear fit.

````julia:ex23
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
````

In the next plot, instead of showing the linear fit, we show trend with a smoother:

````julia:ex24
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
````

In the next plot, we use different line colours and different symbols (by sex):

````julia:ex25
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
````

### Corner Plots

When we are working with more than two continuous variables and we want to look at potential correlations between them, we can construct a single plot, with all two-variable combinations displayed in diffeerent panels. These are known as scatter plot matrices, *pair plots* or *corner plots*.

````julia:ex26
let
	nms = names(iris, 1:4)
	p = select(iris, nms .=> replace.(nms, "_" => " "))
	pairplot(p)
end
````

The defaullt for `pairplot` is to plot a countour plot to show the relationship between variables (see above figure). We have flexibility, for example, we can plot the traditional scatter plot:

````julia:ex27
let
	nms = names(iris, 1:4)
	p = select(iris, nms .=> replace.(nms, "_" => " "))
	pairplot(p => (
		PairPlots.Scatter(color=:firebrick, markersize=5),
		PairPlots.MarginDensity(),
		)
	)
end
````

The `airquality` dataset contains some environmental variables associated with pollution measure as ozone concentrations. Let's try to find which of those environmental variables has a stronger correlation with ozone.

````julia:ex28
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
````

And now, without the contour:

````julia:ex29
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
````

Temperature has a positive correlation with ozone, while wind has a negative one. Let's take a further look to the latter one:

````julia:ex30
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
````

### Line Charts

In this example, our dataset is in *wide* format.

````julia:ex31
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
````

Reshaping *wide* to *long* data:

````julia:ex32
flu_melt = stack(flu, Not(:week));
first(flu_melt, 5)
````

In *long* format, the construct of the the plot is easier.

````julia:ex33
data(flu_melt) *
mapping(
	:week => "Date",
    :value => "Number of cases",
    color=:variable => "Age group"
) *
visual(ScatterLines, markersize=7) |>
draw
````

## Comparing Groups

### Box-Plots

When we are comparing continuous variables, between two or more groups, box plots are the best option, particularly if the number of observations in the groups is relatively large (n ≥ 30).

````julia:ex34
data(wcgs |> dropmissing) *
mapping(
	:chd => "CHD",
    :chol => "Cholesterol (mg/dl)"
) *
visual(BoxPlot, color=:plum3) |>
draw
````

In the previous figure the presence of an outlier is clear. If we would like to remove that outlier, we would need to declare that in the report. For demonstration purposes, if we do not want to show the outlier in the plot, we have the option to *filter* the data using the `@subset` command.

````julia:ex35
data(@subset(wcgs |> dropmissing, :chol.<500) ) *
mapping(
	:chd => "CHD",
    :chol => "Cholesterol (mg/dl)",
    color=:chd => "CHD"
) *
visual(BoxPlot) |>
draw
````

We can compare distributions between groups (levels) of one categorical variable, stratified by groups of a second categorical variable.

````julia:ex36
data(birth) *
mapping(
	:race => "Ethnicity",
    :bwt => "Birth weight (g)",
    color=:smoke => "Smoking status",
    dodge = :smoke
) *
visual(BoxPlot) |>
draw
````

In the previous case, we used `dodge` and different colours. We can also use faceting:

````julia:ex37
data(birth) *
mapping(
	:Race => "",
    :bwt => "Birth weight (g)",
    color=:Race => "Ethnicity",
    layout = :smoke
) *
visual(BoxPlot) |>
draw
````

### Strip Charts and Rain Clouds

When we want to compare groups and the number of observations is relatively small (*n* < 30), strip charts are superior than box-plots as we can show all observations.

````julia:ex38
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
````

Umm, not perfect. In the previous plot, dots are plotted to the right side of the corresponding thick. An alternative is to use *rain clouds*: we show the distribution on the left side (e.g., a violin plot) and the observations on the right side (i.e., a strip chart).

````julia:ex39
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
````

We can also call `R` and use a function from the `pubh` package.

````julia:ex40
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
````

With `R` it is also possible to add a significant line!

````julia:ex41
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
````

Let's check at the effect of smoking status of mothers on the birth weights of their babies, by ethnicity:

````julia:ex42
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
````

