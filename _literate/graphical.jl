#=
# Graphical Analysis

Loading packages:
=#

using StatsKit
using DataFrameMacros
using RData
using RCall
using ScientificTypes: schema

# Plotting packages:

using AlgebraOfGraphics
using CairoMakie
using MakieThemes
CairoMakie.activate!(type = "svg")
AoG = AlgebraOfGraphics
data = AoG.data
set_theme!(ggthemr(:fresh))
update_theme!(Axis = (width = 400, height = 300))

# Package for corner plots:

using PairPlots

#=
## Data

The Western Collaborative Group Study (WCGS) is a well known prospective chohort study. Male participants aged 39 to 59 from 10 California companies were originally selected to study the relationship between behaviour pattern and the risk of coronary heart disease (CHD).
=#

wcgs = load("data/wcgs.rds")
wcgs |> schema

# The `kfm` data frame was collected by Kim Fleischer Michaelsen and contains data for 50 infants of age approximately 2 months. They were weighed immediately before and after each breast feeding. and the measured intake of breast milk was registered along with various other data.

kfm = load("data/kfm.rds")
kfm |> schema

# Data on reported cases of influenza by age group in the 1957 pandemic in England and Wales.

flu = DataFrame(CSV.File("data/fluraw.csv"))
flu |> schema

# Data on birth weights from newborns in a London Hospital.

birth = load("data/birthwt.rds")
birth |> schema

# Data on the energy expenditure in groups of lean and obese womnen.

energy = rcopy(R"ISwR::energy")
energy |> schema

# Fisher’s iris dataset on measurements for three species of iris.

iris = rcopy(R"datasets::iris")
iris |> schema

# Data on air quality and weather conditions in New York, recorded May to September 1973.

air = rcopy(R"datasets::airquality")

air.Month = categorical(recode(
    air.Month,
    5 => "May",
    6 => "Jun",
    7 => "Jul",
    8 => "Aug",
    9 => "Sep"
), ordered=true)

air |> schema

#=
## Distributions

### Histograms

We use histograms to look at the distribution of continuous variables. Histograms make most sense for relatively large data (≥ 100 observations). In this fist histogram, we show the density.
=#

data(birth) *
mapping(:bwt => "Birth weight (g)") *
histogram(bins=20, normalization=:density) *
visual(color=:pink) |>
draw

#=
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
=#