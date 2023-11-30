### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 373a8f0b-cf27-43d0-b214-9bef8145ac2d
using PlutoUI; PlutoUI.TableOfContents(aside=true, title="📚 Contents")

# ╔═╡ eb51482a-1eb0-4d11-a5e5-ff13cdeb940e
begin
	using StatsBase, DataFrameMacros, Chain, TexTables
	using MLJ , RCall, DataFrames, Effects
	using GLM, MLJGLMInterface, StableRNGs
	import AnovaGLM as aov
end

# ╔═╡ 1c345bc7-ba34-4f21-b3f2-8bb7f9ba3fdf
begin
	using AlgebraOfGraphics, CairoMakie, MakieThemes
	CairoMakie.activate!(type = "svg")
	AoG = AlgebraOfGraphics; data = AoG.data
	set_theme!(ggthemr(:solarized))
end

# ╔═╡ 0c997303-be4a-437c-8842-8965db6114f8
using MixedModelsExtras: gvif

# ╔═╡ e026e88e-0c37-4c53-b6ea-556db747ad55
include("pubh.jl");

# ╔═╡ e02d1d08-31a6-11ee-05c0-3fded2c52dc0
md"""
# Statistical Modelling

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform, **AgRresearch Ltd**
	- 3 August 2023
"""

# ╔═╡ dc3c9cd9-98c3-48ff-89ef-881991721051
md"""
## 📖 Main Menu

[Return to Main Menu](index.html)
"""

# ╔═╡ e595e681-0dcf-40db-8459-61992f38a149
schema = MLJ.schema;

# ╔═╡ eab1f185-3190-4a5c-9c0d-f91d9e62a98a
# ╠═╡ show_logs = false
R"""
require("pubh", quietly=TRUE)
require("sjlabelled", quietly=TRUE)
require("readr", quietly=TRUE)
""";

# ╔═╡ 93e932a6-d7b5-4bd3-ab83-884277a86252
md"""
# Introduction

## Initial data manipulation

!!! warning \"Example\"

	We will look at data from 500 singleton births in a London Hospital. We will estimate the effect of several potential predictors on the birth weights of babies.
"""

# ╔═╡ 0b16e142-f9ed-4842-9a17-3d3d1dabea4c
R"""
data(births, package = "Epi")
""";

# ╔═╡ 5022fb0a-850d-46f8-99a9-0973270e1591
@rget births; schema(births)

# ╔═╡ b872f35f-658e-49ee-ad00-a687dee8ac5b
dropmissing!(births);

# ╔═╡ d0cdff5b-3d49-49a6-8aad-373376cd78ff
md"""
In this tutorial, we have a first look at machine learning with `MLJ`. `MLJ` requires that all our variables are of scitype Continuous. For convenience, I will transform categorical variables in `R` and save it as a different data frame.
"""

# ╔═╡ c007858c-f865-4a08-a6bf-210ab409c358
R"""
births2 = births %>%
  mutate(
    low = factor(lowbw, labels=c('No', 'Yes')),
    preterm = factor(preterm, labels=c('No', 'Yes')),
    hyp = factor(hyp, labels=c('No hypertension', 'Hypertension')),
    sex = factor(sex, labels=c('Male', 'Female'))
  ) %>%
  na.omit() %>%
  var_labels(
    bweight = "Birth weight (g)",
    low = "Birth weight < 2.5 kg?",
    gestwks = "Gestation period (weeks)",
    preterm = "Gestation period < 37 weeks?",
    matage = "Maternal age (years)",
    hyp = "Maternal hypertension",
    sex = "Sex"
  )
""";

# ╔═╡ 23483986-4127-4e3d-96b7-36cf9f1412c7
@rget births2; schema(births2)

# ╔═╡ c12d37f6-b0e6-4b10-9009-acea72869ef3
DataFrames.rename!(
	births2,
	:gestwks => :Gestation,
	:matage => :Age,
	:hyp => :Hypertension,
	:sex => :Sex
);

# ╔═╡ b56e5aa2-914a-4240-a1a7-02cc4449732b
md"""
## Descriptive Statistics

Let's start by looking at the table of descriptive statistics.
"""

# ╔═╡ 373683e8-acfc-49a4-ad4e-5d7cba0667f8
R"""
births2 %>%
select(-c(id, lowbw)) %>%
tbl_summary() %>% 
cosm_sum() %>% theme_pubh() %>% 
set_caption("Descriptive statistics of singleton births in a London Hospital.") %>%
print_screen()
""";

# ╔═╡ 74e69afe-95db-445e-bc78-f91c1108f614
md"""
!!! warning \"Exercise\"

	Construct QQ-Norm plots to check the distributions of birth weight and gestational period.
"""

# ╔═╡ 49911172-6663-4c57-9f9d-1bd0398c2c5a
md"""
```julia
let
	fig = Figure()
	
	p1 = data(births) *
	mapping(:bweight) *
	visual(QQNorm, qqline=:fitrobust, markersize=8, color=:cadetblue)

	p2 = data(births) *
	mapping(:gestwks) *
	visual(QQNorm, qqline=:fitrobust, markersize=8, color=:cadetblue)

	AoG.draw!(fig[1, 1], p1, axis=(
		xlabel="Normal quantiles",
		ylabel="Birth weight (g)"
		)
	)
	
	AoG.draw!(fig[1, 2], p2, axis=(
		xlabel="Normal quantiles",
		ylabel="Gestational weeks"
		)
	)
	
	fig
end
```
""" |> hint

# ╔═╡ 64b3c32c-bd24-4ed1-be84-d9ce6ffdbb17
let
	fig = Figure()
	
	p1 = data(births) *
	mapping(:bweight) *
	visual(QQNorm, qqline=:fitrobust, markersize=8, color=:cadetblue)

	p2 = data(births) *
	mapping(:gestwks) *
	visual(QQNorm, qqline=:fitrobust, markersize=8, color=:cadetblue)

	AoG.draw!(fig[1, 1], p1, axis=(
		xlabel="Normal quantiles",
		ylabel="Birth weight (g)"
		)
	)
	
	AoG.draw!(fig[1, 2], p2, axis=(
		xlabel="Normal quantiles",
		ylabel="Gestational weeks"
		)
	)
	
	fig
end

# ╔═╡ efd3b952-3fb4-4e87-9e68-bf3a0ac03740
md"""
## Linearity

Let's graphically check if there is a linear relationship between gestation time and birth weight.
"""

# ╔═╡ d9b2dad1-0a27-461a-9e45-2819c30a33eb
let
	layers = visual(Scatter, markersize=7, color=:cadetblue) + smooth()
	data(births) *
	mapping(
		:gestwks => "Gestational weeks",
		:bweight => "Birth weight (g)"
	) *
	layers * mapping() |>
	draw
end

# ╔═╡ 0d0440cf-241c-4b86-9de7-03eb4f9e7890
md"""
!!! tip \"Question\"

	What is your observation about linearity from your scatter plot?
"""

# ╔═╡ fa216c50-71cf-4708-ae73-3ad877093325
md"""
There is a linear relationship, but only for the middle part of the curve. The curve is clearly non-linear and more like an S-shape characteristic of human growth.
""" |> hint

# ╔═╡ 83b559dd-5aa4-4fd0-a684-9a9dd963fef5
md"Let's construct the plot for the section where linearity is more evident."

# ╔═╡ b5d1b8f4-5e4e-49ba-81e1-deeaa7782181
let
	layers = visual(Scatter, markersize=7, color=:cadetblue) + smooth()
	data(@subset(births, :gestwks .> 31, :gestwks .< 40)) *
	mapping(
		:gestwks => "Gestational weeks",
		:bweight => "Birth weight (g)"
	) *
	layers * mapping() |>
	draw
end

# ╔═╡ e362468a-ab9a-4b17-9a0f-e67af2503231
md"Let's generate a new dataset with the subset of observations that are within the linear section of the relationship between gestation period and birth weight. For this subset, we will select only variables of interest."

# ╔═╡ 99a86494-1c5b-49b9-be6b-7d003f08b07b
babies = @chain @subset(births, :gestwks .> 31, :gestwks .< 40) begin
	select(Not([:id, :preterm, :lowbw]))
end;

# ╔═╡ 119c3526-d75a-471c-846c-e11df58d696f
babies_cat = @chain @subset(births2, :Gestation .> 31, :Gestation .< 40) begin
	select(Not([:id, :lowbw, :preterm, :low]))
end;

# ╔═╡ 82cec8cc-6991-4141-ac13-c6ad9e090215
md"""
## Interactions

We will check for potential interactions graphically. Let's start with sex.
"""

# ╔═╡ 56ead667-4ba6-4563-be7d-b4234ffc33b8
let
	layers = visual(Scatter, markersize=7, color=:cadetblue) + linear()
	data(babies_cat) *
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)"
	) *
	layers * mapping(color=:Sex) |>
	draw
end

# ╔═╡ c47399ab-0c48-454c-9104-449d3a61cf21
md"""
!!! tip \"Question\"

	Do you think there is graphical evidence of interaction with sex?
"""

# ╔═╡ 39059e21-6f4f-40af-9f54-e2b06d8e7808
md"""
The fitted lines are not strictly parallel, but there is no strong evidence of any interaction.
""" |> hint

# ╔═╡ ab3a4347-21bf-447b-8a56-1219dda6adf9
md"""
!!! warning \"Exercise\"

	Determine if there is graphical evidence of hypertension effects on the relationship between gestation time and birth weight.
"""

# ╔═╡ 10af0650-5798-469d-ad88-33f4a2d3c3e3
md"""
let
	layers = visual(Scatter, markersize=7, color=:cadetblue) + linear()
	data(babies_cat) *
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)"
	) *
	layers * mapping(color=:Hypertension => "") |>
	draw
end
""" |> hint

# ╔═╡ a0165481-f6f2-4e7b-a09e-bd58cc140a40
let
	layers = visual(Scatter, markersize=7, color=:cadetblue) + linear()
	data(babies_cat) *
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)"
	) *
	layers * mapping(color=:Hypertension => "") |>
	draw
end

# ╔═╡ 6ab51b36-797d-4d55-81f8-7c5fb9a0fc32
md"""
# MLR

## GLM Approach
### Model Simplification

We can start model simplification using ANOVA.
"""

# ╔═╡ 2b708fce-a3b6-4de5-a259-186b2ed179b2
model_1 = lm(
	@formula(bweight ~ Gestation + Age + Hypertension + Sex),
	births2
); aov.anova(model_1; type=3)

# ╔═╡ fef1615f-af29-4a54-a308-644d2a103a14
md"""
Let's remove `matage` from the model and define our contrasts for the categorical variables.
"""

# ╔═╡ 35da6608-113f-4651-95be-4e9e10303685
bw_cont = Dict(
	:Hypertension => EffectsCoding(),
	:Sex => EffectsCoding()
);

# ╔═╡ 2e1e7a0c-7734-47f2-9ae6-980776bebc4a
model_2 = lm(
	@formula(bweight ~ Gestation + Hypertension + Sex),
	births2; contrasts=bw_cont
); aov.anova(model_2; type=3)

# ╔═╡ 4615af75-7341-49b1-b9ab-e44f6b6ce3f3
md"""

## MLJ - Continuous predictors

### Response and Predictors

Our first model will contain all relevant predictors with no interaction terms. We can use `unpack` to define *response* and *explanatory* variables.
"""

# ╔═╡ 735d055b-93f8-410d-a7a0-2b915aa5854d
@select!(babies, :bweight, :gestwks, :hyp, :sex);

# ╔═╡ d456f6fa-097e-451d-975c-fde6b3882bf9
y1, x1 = unpack(babies, ==(:bweight));

# ╔═╡ bcdf5cf2-10c4-4fd7-a143-e92fcfc04b37
md"""
### Data Splitting

We split the outcome in two:

- train: 70 % of the data
- test: 30 % of the data
"""

# ╔═╡ e614d405-a0d9-4aa5-aa50-baca613cde1f
begin
	rng = StableRNG(566)
	train, test = partition(eachindex(y1), 0.7, shuffle=true, rng=rng)
end;

# ╔═╡ f25655b4-1c60-45c3-9a1b-8e470460cb9c
md"""
### Model
"""

# ╔═╡ 8a27954a-0872-4a7e-ae84-35d0eda99423
LinearRegressor = @load LinearRegressor pkg=GLM verbosity=0

# ╔═╡ b05b5336-867e-4363-bf1d-1ecf3f0193cf
glm = LinearRegressor()

# ╔═╡ 0d04220f-3b20-446f-a868-89c47786b699
bw_mach = machine(glm, x1, y1)

# ╔═╡ 5c424cda-2a85-4aab-b781-cb07eb71bdb1
fit!(bw_mach, rows=train)

# ╔═╡ daae6c76-e0d3-4cb1-973d-392e85533344
report(bw_mach).coef_table

# ╔═╡ a9d97ec1-ffd4-4b14-bcbc-1032c10477e2
md"The table of coefficients from the MLJ approach are very similar to those of the traditional GLM approach:"

# ╔═╡ 6c5f55a1-d122-4b31-a14a-ac5ef4a2da6d
model_2

# ╔═╡ 67113ad5-c737-4f5a-9973-1b99b075d6b2
md"""
## MLJ Categorical predictors

In the previous section, we used a continuous version for all predictors. Let's see what happens when we work with the categorical, original versions of the predictors.

### One Hot Encoding

One hot encoding is a process of converting categorical variables to form multiple numerical columns as there are categories. This is done so that the variables can be fed into ML algorithms to do a better job in prediction.

As before, first, we unpack data into response (outcome) and explanatory (exposure, predictor) variables.
"""

# ╔═╡ 4860ca61-0103-4677-8e7e-f2ec7544d450
@select!(babies_cat, :bweight, :Gestation, :Hypertension, :Sex);

# ╔═╡ fe127eef-5a9e-4ba6-ab20-3eae2a9adde6
y2, x2 = unpack(babies_cat, ==(:bweight));

# ╔═╡ ab52e070-7f3e-45e3-977c-fa8ba3aa456f
md"""
In `OneHotEncoder`, all categorical variables are included by default (`features` argument). We want to drop one of the levels to use as a reference, we achieve this with the argument `drop_last=true`.
"""

# ╔═╡ fa974bc0-24a9-4d0f-80fa-2f5c0ddbd8b3
bw_hot = OneHotEncoder(drop_last=true)

# ╔═╡ 96669b55-ae7c-4d8f-a690-f7f1be4d5f44
md"""
!!! warning

	As we *drop* the last level, we need to change the levels of categorical predictors so now exposed ones become the reference and their coefficients are shown in the coefficient table.
"""

# ╔═╡ 7fd05bc2-e3a0-4e37-a6cc-27e767bc6261
levels!(x2.Hypertension, ["Hypertension", "No hypertension"]);

# ╔═╡ ef795a76-7471-4a55-9628-6f9b46e4b6c6
bwX = machine(bw_hot, x2) |> fit!

# ╔═╡ 51c566ad-c54b-4406-9195-cec1fd368892
md"""
Once the one hot encoder machine has been defined, we can use it to *transform* our categorical predictors.
"""

# ╔═╡ 184204d9-8184-4827-8e67-0b862df0981d
x3 = MLJ.transform(bwX, x2); schema(x3)

# ╔═╡ 9967a627-5755-417c-ba56-89827a0d3287
md"""
!!! note

	From the *schema*, we can see that we are comparing *Hypertension* against *No Hypertension" and *Males* against *Females*.
"""

# ╔═╡ 1a1e898d-f7d0-4647-a079-306c92aaace1
md"""
### Model

We can also generate *pipe workflows* on which we combine or concatenate processes together as shown bellow.
"""

# ╔═╡ d8a3eec1-3931-4c96-9cd2-784cbe7f5e65
pipe = 	ContinuousEncoder(drop_last=true) |> glm

# ╔═╡ 7162cd94-4741-4395-b6d2-decfd7cbb106
mach = machine(pipe, x2, y2)

# ╔═╡ 645206ca-e604-4727-bade-ee1ddae623ce
bw_mach2 = machine(glm, x3, y2)

# ╔═╡ 10864522-1f9f-466e-8abc-fb5be45fea27
fit!(bw_mach2, rows=train)

# ╔═╡ d40fa321-576d-4b5b-a711-9e473826567b
report(bw_mach2).coef_table

# ╔═╡ b33b6bb6-ea41-4b1e-977e-9cc554808a94
md"Our results, are consistent, yay!!"

# ╔═╡ e9b85328-d023-4a32-a1d6-71dee5c5a200
fit!(mach, rows=train)

# ╔═╡ 1d416826-109c-4dea-89af-49317c5cb57a
report(mach).linear_regressor.coef_table

# ╔═╡ 8bce14bd-2aed-45dc-bde5-1b2ce531077a
md"""
# Diagnostics

## Normality
"""

# ╔═╡ 760a6a5f-aca2-412d-8079-8c956f5effa0
bw_perf = model_perf(model_2);

# ╔═╡ 1eb34940-7f96-4503-b19d-7aeedf1342fc
let
	plt = data(bw_perf) *
	mapping(
		:error => "Residuals"
	) *
	visual(QQNorm, qqline=:fitrobust, markersize=8, color=:cadetblue)
	draw(plt, axis=(
		xlabel="Normal quantiles",
		ylabel="Residuals"
	))
end

# ╔═╡ 46d201be-8889-4f7c-ba6a-618dcaaa69e7
md"## Homoscedasticity"

# ╔═╡ dcd430a1-d627-4076-98aa-4b55462deb4d
let
	layers = visual(Scatter, markersize=8, color=:cadetblue) + smooth()

	p1 = data(bw_perf) *
	mapping(
  		:predicted => "Fitted values",
  		:std_error => "Std residuals"
	) *
	layers * mapping()
	draw(p1)
end

# ╔═╡ 8b006583-45f0-4a5d-bb9d-1a2cfe7d95ec
let
	layers = visual(Scatter, markersize=8, color=:cadetblue) + smooth()

	p1 = data(bw_perf) *
	mapping(
  		:predicted => "Fitted values",
  		:std_error => (x -> sqrt.(abs.(x))) => "√|Std res|"
	) *
	layers * mapping()
	draw(p1)
end

# ╔═╡ 7c00571c-39a2-4727-8ed8-8c7d817101f8
md"## Influential observations"

# ╔═╡ ad05b5a9-59d7-4e95-a071-adcfc89f258e
let
	fig = Figure()

	ax = Axis(
		fig[1, 1],
		xlabel="Index",
		ylabel="Cook's Distance"
	)

	μ = mean(bw_perf.cook)

	stem!(ax, 1:nrow(bw_perf), bw_perf.cook; markersize=8)
	hlines!(ax, μ, linestyle=:dash, color=:plum)

	fig
end

# ╔═╡ fdcf2cea-745b-4254-8503-65c12233cc57
data(bw_perf) *
mapping(
  	:lever => "Leverage",
	:cook => "Cook's distance"
) *
visual(Scatter, markersize=8, color=:cadetblue) |>
draw

# ╔═╡ 26f4dad9-4575-4c66-9a8f-41e274978ed7
md"""
## Collinearity

When more than two variables are involved, it is often called multicollinearity. However, the terms collinearity and multicollinearity are often used interchangeably. The variance inflation factor (VIF) is used to test for collinearity. The rule of thumb is:

- Values larger than 10 give evidence of collinearity.
- A mean of the VIF factors considerably greater than 1 suggests collinearity.
"""

# ╔═╡ 2897caf3-0033-4e98-99ae-9ddc37d4e570
r3.(gvif(model_2))

# ╔═╡ 73d900ca-a1cb-456f-822b-6367cc8b11af
md"""
The results from `gvif` follow the same order as the coefficients of the model, this is:

- `gestwks` : gestational weeks.
- `hyp` : hypertension.
- `sex`
"""

# ╔═╡ 0dfc97ee-03a0-421a-a2c8-9b9f7a8488ae
md"""
# Table of Coefficients
"""

# ╔═╡ fa4201d1-fb3e-45b0-a391-450a3c260381
import RegressionTables as RT

# ╔═╡ ee014c7c-1b84-49aa-bd0b-d1045b9cd305
RT.regtable(
	model_2,
	labels = Dict(
		"gestwks" => "Gestation period (weeks)",
		"hyp: Hypertension" => "Maternal hypertension",
		"sex: Female" => "Sex (female - male)",
		"bweight" => "Birth weight (g)"
	),
	number_regressions=false
)

# ╔═╡ 523fde92-67ab-45e0-999d-b29327c8d3b1
Show(
	MIME"text/html"(),
	String(
		RT.regtable(
			model_1,
			model_2,
			labels = Dict(
				"gestwks" => "Gestation period (weeks)",
				"hyp: Hypertension" => "Maternal hypertension",
				"sex: Female" => "Sex (female - male)",
				"bweight" => "Birth weight (g)",
				"matage" => "Maternal age"
			),
			number_regressions=true,
			below_statistic = :se;
			renderSettings = RT.htmlOutput(),
			print_result=false
		)
	)
)

# ╔═╡ 07a6daab-9aa4-477d-86d9-6f90eef03f64
regtable(model_1, model_2) |> to_ascii |> print

# ╔═╡ c2131a98-589a-4ae9-a6f3-b6ae29c02aab
md"""
# Effect Plots

We can plot all the predictors who have an effect on birth weight.
"""

# ╔═╡ 991ee3ba-47dc-4d25-9bc8-93e96e9814d5
let
	layers = visual(Scatter, markersize=7; alpha=0.5) + linear()
	data(babies_cat) *
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)",
		layout = :Hypertension
	) *
	layers * mapping(color = :Sex => "") |>
	draw
end

# ╔═╡ a74109c3-2b23-4e54-8aad-9d5cce1153d6
md"""
!!! danger \"Interpretation\"

	Babies born from mothers with a hystory of hypertension, have on average, a lower birth weight and this is independent of their sex. For the group of babies whose mothers do not have a history of hypertension, girls have on average, a lower birth weight than boys. In all cases, as the number of gestational weeks increase, the birth weight also increases.
"""

# ╔═╡ 4e7a73de-2ab4-4d6f-a2a3-769f8f4c80e7
md"""
## Effect of sex

We can show the effect of sex on birth weight for babies of mothers with no hypertension.
"""

# ╔═╡ a0e34c6e-5a21-4367-9a75-2b61170c05e1
bw_sex = effects!(@subset(babies_cat, :Hypertension .== "No hypertension"), model_2);

# ╔═╡ 224745a0-276a-4b49-9f10-e59806ec6bd9
begin
	bw_sex[!, :lower] = @. bw_sex.bweight - 1.96 * bw_sex.err
	bw_sex[!, :upper] = @. bw_sex.bweight + 1.96 * bw_sex.err
	sort!(bw_sex, [:Gestation]);
end

# ╔═╡ e122ea68-a61e-4fd7-a182-8230fa4d7439
let
	p1 = data(bw_sex) * 
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)"; 
		lower=:lower, upper=:upper, 
		layout=:Sex) *
	(visual(Lines) + visual(LinesFill, color=:firebrick))

	p2 = data(babies_cat) *
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)",
		layout=:Sex
	) *
	visual(Scatter, markersize=8, color=:cadetblue)
	draw(p1 + p2)
end

# ╔═╡ 339b293e-46e3-4dc3-aa4b-8c18267e4841
md"In the following plot, hypertension is not part of the predictors."

# ╔═╡ 08f2272a-dc81-4a45-8a37-3e7bd397b99a
let
	layers = visual(Scatter, markersize=8, color=:cadetblue) + 
	linear() * visual(color=:firebrick)
	data(babies_cat) *
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)",
		layout=:Sex
	) *
	layers * mapping() |>
	draw
end

# ╔═╡ b80d663e-fe00-4fb8-aa08-8271e0a973c2
md"""
## Effect of hypertension
"""

# ╔═╡ 62e648df-96ec-4682-a5c1-4f79ecf47a7c
bw_hyp = effects!(@subset(babies_cat, :Sex .== "Female"), model_2);

# ╔═╡ 90ca3511-62db-41b0-ae42-52b90adf6c54
begin
	bw_hyp[!, :lower] = @. bw_hyp.bweight - 1.96 * bw_hyp.err
	bw_hyp[!, :upper] = @. bw_hyp.bweight + 1.96 * bw_hyp.err
	sort!(bw_hyp, [:Gestation]);
end

# ╔═╡ f2944e30-733a-4112-8bd8-ebd0affb2693
let
	p1 = data(bw_hyp) * 
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)"; 
		lower=:lower, upper=:upper, 
		layout=:Hypertension) *
	(visual(Lines) + visual(LinesFill, color=:firebrick))

	p2 = data(babies_cat) *
	mapping(
		:Gestation => "Gestational weeks",
		:bweight => "Birth weight (g)",
		layout=:Hypertension
	) *
	visual(Scatter, markersize=8, color=:cadetblue)
	draw(p1 + p2)
end

# ╔═╡ 7463d81f-413c-4929-bae6-aa8926550f8c
md"## Coefficient Plot"

# ╔═╡ 558e7ec7-d43f-4eea-8e12-44d2321b4b37
coef_plot(
	model_2,
	[
		"Gestational weeks",
		"Maternal \n hypertension",
		"Sex \n Female - Male"
	]
)

# ╔═╡ d2bd3ec9-b47b-40d1-ac27-d46b96747754
md"""
# Performance

## On Full dataset
"""

# ╔═╡ b4d6c989-41a8-4022-a52f-56d704a60e22
@show r2(model_2) |> r3

# ╔═╡ 6576fe9b-9417-4591-b0ea-755c032dcae4
coef_det(bw_perf.predicted, bw_perf.observed) |> r3

# ╔═╡ b7d25489-cfb2-47dc-927b-2f96caa7527b
@show adjr2(model_2) |> r3

# ╔═╡ bf652bcb-a854-4982-a26a-79d4d7afc369
@show mape(bw_perf)

# ╔═╡ 3e4165bd-cb7e-4abe-a04e-578263ad967b
@show rmse(bw_perf) |> r3

# ╔═╡ 3f119061-f5c8-409e-ba74-bed863ba71f2
md"""
## On Test dataset
"""

# ╔═╡ 1689d81c-1a53-4ecd-b020-4e01f956018e
ŷ = MLJ.predict(mach, rows=test);

# ╔═╡ ffe2a36d-65ca-4c25-8242-b8cbcf20e346
ȳ = MLJ.predict_mode(mach, rows=test);

# ╔═╡ d37a7255-723b-4923-80bc-a06b6965752d
cross_entropy(ŷ, y2[test]) |> mean |> r3

# ╔═╡ 17078f8e-6409-4247-9f53-ef7ad5a7af71
coef_det(ȳ, y2[test]) |> r3

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
AnovaGLM = "0a47a8e3-ec57-451e-bddb-e0be9d22772b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Effects = "8f03c58b-bd97-4933-a826-f71b64d2cca2"
GLM = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
MLJ = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
MLJGLMInterface = "caf8df21-4939-456d-ac9c-5fefbfb04c0c"
MakieThemes = "e296ed71-da82-5faf-88ab-0034a9761098"
MixedModelsExtras = "781a26e1-49f4-409a-8f4c-c3159d78c17e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
RegressionTables = "d519eb52-b820-54da-95a6-98e1306fdade"
StableRNGs = "860ef19b-820b-49d6-a774-d7a799459cd3"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
TexTables = "ebf5ac4f-3ec1-555f-9ac9-3d72ed88c471"

[compat]
AlgebraOfGraphics = "~0.6.16"
AnovaGLM = "~0.2.2"
CairoMakie = "~0.10.7"
Chain = "~0.5.0"
DataFrameMacros = "~0.4.1"
DataFrames = "~1.6.1"
Effects = "~0.1.6"
GLM = "~1.8.3"
MLJ = "~0.19.2"
MLJGLMInterface = "~0.3.5"
MakieThemes = "~0.1.0"
MixedModelsExtras = "~1.1.0"
PlutoUI = "~0.7.52"
RCall = "~0.13.15"
RegressionTables = "~0.5.9"
StableRNGs = "~1.0.0"
StatsBase = "~0.33.21"
TexTables = "~0.2.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "81dfc23248cf6d31f4eaef8fd98f665c09c59c5c"

[[deps.ARFFFiles]]
deps = ["CategoricalArrays", "Dates", "Parsers", "Tables"]
git-tree-sha1 = "e8c8e0a2be6eb4f56b1672e46004463033daa409"
uuid = "da404889-ca92-49ff-9e8b-0aa6b4d38dc8"
version = "1.4.1"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "cad4c758c0038eea30394b1b671526921ca85b21"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.4.0"
weakdeps = ["ChainRulesCore"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"

[[deps.AbstractLattices]]
git-tree-sha1 = "f35684b7349da49fcc8a9e520e30e45dbb077166"
uuid = "398f06c4-4d28-53ec-89ca-5b2656b7603d"
version = "0.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AlgebraOfGraphics]]
deps = ["Colors", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "PrecompileTools", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "c58b2c0f1161b8a2e79dcb1a0ec4b639c2406f15"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.16"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.AnovaBase]]
deps = ["Distributions", "Printf", "Reexport", "Statistics", "StatsBase", "StatsModels"]
git-tree-sha1 = "5938520131e2d94b6d288cce76e67689be12ba6b"
uuid = "946dddda-6a23-4b48-8e70-8e60d9b8d680"
version = "0.7.4"

[[deps.AnovaGLM]]
deps = ["AnovaBase", "Distributions", "GLM", "LinearAlgebra", "Printf", "Reexport", "Statistics", "StatsBase", "StatsModels"]
git-tree-sha1 = "d4d62c676b0078e7c174226959eaddb43a8edafd"
uuid = "0a47a8e3-ec57-451e-bddb-e0be9d22772b"
version = "0.2.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "f83ec24f76d4c8f525099b2ac475fc098138ec31"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.4.11"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Arrow]]
deps = ["ArrowTypes", "BitIntegers", "CodecLz4", "CodecZstd", "ConcurrentUtilities", "DataAPI", "Dates", "EnumX", "LoggingExtras", "Mmap", "PooledArrays", "SentinelArrays", "Tables", "TimeZones", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "954666e252835c4cf8819ce4ffaf31073c1b7233"
uuid = "69666777-d1a9-59fb-9406-91d4454c9d45"
version = "2.6.2"

[[deps.ArrowTypes]]
deps = ["Sockets", "UUIDs"]
git-tree-sha1 = "8c37bfdf1b689c6677bbfc8986968fe641f6a299"
uuid = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
version = "2.2.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["ScanByte", "TranscodingStreams"]
git-tree-sha1 = "48e54446df62fdf9ef76959c32dc33f3cff659ee"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.3"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.BitIntegers]]
deps = ["Random"]
git-tree-sha1 = "abb894fb55122b4604af0d460d3018e687a60963"
uuid = "c3b6d118-76ef-56ca-8cc7-ebb389d030a1"
version = "0.3.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "32abd86e3c2025db5172aa182b982debed519834"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.1"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools", "SHA"]
git-tree-sha1 = "e041782fed7614b1726fa250f2bf24fd5c789689"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.10.7"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"
weakdeps = ["JSON", "RecipesBase", "SentinelArrays", "StructTypes"]

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

[[deps.CategoricalDistributions]]
deps = ["CategoricalArrays", "Distributions", "Missings", "OrderedCollections", "Random", "ScientificTypes"]
git-tree-sha1 = "da68989f027dcefa74d44a452c9e36af9730a70d"
uuid = "af321ab8-2d2e-40a6-b165-3d674595d28e"
version = "0.1.10"

    [deps.CategoricalDistributions.extensions]
    UnivariateFiniteDisplayExt = "UnicodePlots"

    [deps.CategoricalDistributions.weakdeps]
    UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228"

[[deps.Chain]]
git-tree-sha1 = "8c4920235f6c561e401dfe569beb8b924adad003"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.5.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e30f2f4e20f7f186dc36529910beaedc60cfa644"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.16.0"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[deps.CodecLz4]]
deps = ["Lz4_jll", "TranscodingStreams"]
git-tree-sha1 = "59fe0cb37784288d6b9f1baebddbf75457395d40"
uuid = "5ba52731-8f18-5e0d-9241-30f10d1ec561"
version = "0.4.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.CodecZstd]]
deps = ["CEnum", "TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "849470b337d0fa8449c21061de922386f32949d9"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.7.2"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "dd3000d954d483c1aad05fe1eb9e6a715c97013e"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.22.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "4e88377ae7ebeaf29a047aa1ee40826e0b708a5d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.7.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "8c86e48c0db1564a1d49548d3515ced5d604c408"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.9.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fe2838a593b5f776e1597e086dcd47560d94e816"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.3"
weakdeps = ["IntervalSets", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrameMacros]]
deps = ["DataFrames", "MacroTools"]
git-tree-sha1 = "5275530d05af21f7778e3ef8f167fb493999eea1"
uuid = "75880514-38bc-4a95-a458-c2aea5a3a702"
version = "0.4.1"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cf25ccb972fec4e4817764d01c82386ae94f77b4"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.14"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelaunayTriangulation]]
deps = ["DataStructures", "EnumX", "ExactPredicates", "Random", "SimpleGraphs"]
git-tree-sha1 = "a1d8532de83f8ce964235eff1edeff9581144d02"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "0.7.2"
weakdeps = ["MakieCore"]

    [deps.DelaunayTriangulation.extensions]
    DelaunayTriangulationMakieCoreExt = "MakieCore"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "e82c3c97b5b4ec111f3c1b55228cebc7510525a2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.25"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "b6def76ffad15143924a2199f72a5cd883a2e8a9"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.9"
weakdeps = ["SparseArrays"]

    [deps.Distances.extensions]
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "e76a3281de2719d7c81ed62c6ea7057380c87b1d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.98"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EarlyStopping]]
deps = ["Dates", "Statistics"]
git-tree-sha1 = "98fdf08b707aaf69f524a6cd0a67858cefe0cfb6"
uuid = "792122b4-ca99-40de-a6bc-6742525f08b6"
version = "0.3.0"

[[deps.Effects]]
deps = ["Combinatorics", "DataFrames", "Distributions", "ForwardDiff", "LinearAlgebra", "Statistics", "StatsBase", "StatsModels", "Tables"]
git-tree-sha1 = "5dc2e3534cc5b5ce1223d9bc32b89fd26058f147"
uuid = "8f03c58b-bd97-4933-a826-f71b64d2cca2"
version = "0.1.9"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.ErrorfreeArithmetic]]
git-tree-sha1 = "d6863c556f1142a061532e79f611aa46be201686"
uuid = "90fa49ef-747e-5e6f-a989-263ba693cf1a"
version = "0.5.2"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArraysCore", "Test"]
git-tree-sha1 = "276e83bc8b21589b79303b9985c321024ffdf59c"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.5"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "b4fbdd20c889804969571cc589900803edda16b7"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.7.1"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FastRounding]]
deps = ["ErrorfreeArithmetic", "LinearAlgebra"]
git-tree-sha1 = "6344aa18f654196be82e62816935225b3b9abe44"
uuid = "fa42c844-2597-5d31-933b-ebd51ab2693f"
version = "0.3.1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "299dc33549f68299137e51e6d49a13b5b1da9673"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "f0af9b12329a637e8fba7d6543f915fff6ba0090"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.4.2"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "Setfield", "SparseArrays"]
git-tree-sha1 = "c6e4a1fbe73b31a3dea94b1da449503b8830c306"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.21.1"

    [deps.FiniteDiff.extensions]
    FiniteDiffBandedMatricesExt = "BandedMatrices"
    FiniteDiffBlockBandedMatricesExt = "BlockBandedMatrices"
    FiniteDiffStaticArraysExt = "StaticArrays"

    [deps.FiniteDiff.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.FixedEffectModels]]
deps = ["DataFrames", "FixedEffects", "LinearAlgebra", "Printf", "Reexport", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels", "Tables", "Vcov"]
git-tree-sha1 = "0c5a7774a7c74deb05a9ff09cc62f1803bb3cfdf"
uuid = "9d5cd8c9-2029-5cab-9928-427838db53e3"
version = "1.8.0"

[[deps.FixedEffects]]
deps = ["GroupedArrays", "LinearAlgebra", "Printf", "StatsBase"]
git-tree-sha1 = "a1d7b4db4dc5cb970e5b18c1876b3d2bebf1f916"
uuid = "c8885935-8500-56a7-9867-7708b20db0eb"
version = "2.2.0"

    [deps.FixedEffects.extensions]
    CUDAExt = "CUDA"
    MetalExt = "Metal"

    [deps.FixedEffects.weakdeps]
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "00e252f4d706b3d55a8863432e742bf5717b498d"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.35"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "38a92e40157100e796690421e34a11c107205c86"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "97829cfda0df99ddaeaafb5b370d6cab87b7013e"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.8.3"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "bb198ff907228523f3dee1070ceee63b9359b6ab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "424a5a6ce7c5d97cca7bcc4eac551b97294c54af"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.9"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "678d136003ed5bceaab05cf64519e3f956ffa4ba"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.9.1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.GroupedArrays]]
deps = ["DataAPI", "Missings"]
git-tree-sha1 = "44c812379b629eea08b6d25a196010f1f4b001e3"
uuid = "6407cd72-fade-4a84-8a1e-56e431fc1533"
version = "0.3.3"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "cb56ccdd481c0dd7f975ad2b3b62d9eda088f7e2"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.9.14"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "83e95aaab9dc184a6dcd9c4c52aa0dc26cd14a1d"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.21"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "bca20b2f5d00c4fbc192c3212da8fa79f4688009"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.7"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3d09a9f60edf77f8a4d99f9e015e8fbf9989605d"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.7+0"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "b8ffb903da9f7b8cf695a8bead8e01814aa24b30"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.2"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0cb9352ef2e01574eeebdb102948a58740dcaf83"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2023.1.0+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "FastRounding", "LinearAlgebra", "Markdown", "Random", "RecipesBase", "RoundingEmulator", "SetRounding", "StaticArrays"]
git-tree-sha1 = "5ab7744289be503d76a944784bac3f2df7b809af"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "0.20.9"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "16c0cc91853084cb5f58a78bd209513900206ce6"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.4"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.IterationControl]]
deps = ["EarlyStopping", "InteractiveUtils"]
git-tree-sha1 = "d7df9a6fdd82a8cfdfe93a94fcce35515be634da"
uuid = "b3c1a2ee-3fec-4384-bf48-272ea71de57c"
version = "0.5.3"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "95220473901735a0f4df9d1ca5b171b568b2daa3"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.13.2"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "327713faef2a3e5c80f96bf38d1fa26f7a6ae29e"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "90442c50e202a5cdf21a7899c66b240fdef14035"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.7"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LatinHypercubeSampling]]
deps = ["Random", "StableRNGs", "StatsBase", "Test"]
git-tree-sha1 = "825289d43c753c7f1bf9bed334c253e9913997f8"
uuid = "a5e1c1ea-c99a-51d3-a14d-a9a37257b02d"
version = "1.9.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LightXML]]
deps = ["Libdl", "XML2_jll"]
git-tree-sha1 = "e129d9391168c677cd4800f5c0abb1ed8cb3794f"
uuid = "9c8b4983-aa76-5018-a973-4c85ecc9e179"
version = "0.9.0"

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LinearAlgebraX]]
deps = ["LinearAlgebra", "Mods", "Permutations", "Primes", "SimplePolynomials"]
git-tree-sha1 = "558a338f1eeabe933f9c2d4052aa7c2c707c3d52"
uuid = "9b3f67b0-2d00-526e-9884-9e4938f8fb88"
version = "0.1.12"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "9c6b2a4c99e7e153f3cf22e10bf40a71c7a3c6a9"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.6.1"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "c3ce8e7420b3a6e071e0fe4745f5d4300e37b13f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.24"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.LossFunctions]]
deps = ["Markdown", "Requires", "Statistics"]
git-tree-sha1 = "065084a6e63bb30b622b46c613a8f61116787174"
uuid = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
version = "0.10.1"
weakdeps = ["CategoricalArrays"]

    [deps.LossFunctions.extensions]
    LossFunctionsCategoricalArraysExt = "CategoricalArrays"

[[deps.Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "154d7aaa82d24db6d8f7e4ffcfe596f40bff214b"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2023.1.0+0"

[[deps.MLJ]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "LinearAlgebra", "MLJBase", "MLJEnsembles", "MLJIteration", "MLJModels", "MLJTuning", "OpenML", "Pkg", "ProgressMeter", "Random", "ScientificTypes", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "d26cd777c711c332019b39445823cbb1f6cdb7e5"
uuid = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
version = "0.19.2"

[[deps.MLJBase]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LinearAlgebra", "LossFunctions", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "ScientificTypes", "Serialization", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "4cc167b6c0a3ab25d7050e4ac38fe119e97cd1ab"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "0.21.11"

[[deps.MLJEnsembles]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Distributed", "Distributions", "MLJBase", "MLJModelInterface", "ProgressMeter", "Random", "ScientificTypesBase", "StatsBase"]
git-tree-sha1 = "95b306ef8108067d26dfde9ff3457d59911cc0d6"
uuid = "50ed68f4-41fd-4504-931a-ed422449fee0"
version = "0.3.3"

[[deps.MLJGLMInterface]]
deps = ["Distributions", "GLM", "MLJModelInterface", "StatsModels", "Tables"]
git-tree-sha1 = "06aba1c96b19f31744f7e97d96fcf66b79739e05"
uuid = "caf8df21-4939-456d-ac9c-5fefbfb04c0c"
version = "0.3.5"

[[deps.MLJIteration]]
deps = ["IterationControl", "MLJBase", "Random", "Serialization"]
git-tree-sha1 = "be6d5c71ab499a59e82d65e00a89ceba8732fcd5"
uuid = "614be32b-d00c-4edb-bd02-1eb411ab5e55"
version = "0.5.1"

[[deps.MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "c8b7e632d6754a5e36c0d94a4b466a5ba3a30128"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.8.0"

[[deps.MLJModels]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Combinatorics", "Dates", "Distances", "Distributions", "InteractiveUtils", "LinearAlgebra", "MLJModelInterface", "Markdown", "OrderedCollections", "Parameters", "Pkg", "PrettyPrinting", "REPL", "Random", "RelocatableFolders", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "8f2cf0a7147d370d0de402d43f6de0d3473fcd5e"
uuid = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
version = "0.16.9"

[[deps.MLJTuning]]
deps = ["ComputationalResources", "Distributed", "Distributions", "LatinHypercubeSampling", "MLJBase", "ProgressMeter", "Random", "RecipesBase"]
git-tree-sha1 = "02688098bd77827b64ed8ad747c14f715f98cfc4"
uuid = "03970b2e-30c4-11ea-3135-d1576263f10f"
version = "0.7.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "InteractiveUtils", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Setfield", "ShaderAbstractions", "Showoff", "SignedDistanceFields", "SparseArrays", "StableHashTraits", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun"]
git-tree-sha1 = "729640354756782c89adba8857085a69e19be7ab"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.19.7"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "87a85ff81583bd392642869557cb633532989517"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.6.4"

[[deps.MakieThemes]]
deps = ["Colors", "Makie", "Random"]
git-tree-sha1 = "22f0ac33ecb2827e21919c086a74a6a9dc7932a1"
uuid = "e296ed71-da82-5faf-88ab-0034a9761098"
version = "0.1.0"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "PrecompileTools", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "5c5cd501ae1d76d3ccd7c7e6b4325a15dde7f31c"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.18.0"

[[deps.MathProgBase]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9abbe463a1e9fc507f12a69e7f29346c2cdc472c"
uuid = "fdba3010-5040-5b88-9595-932c9decdf73"
version = "0.7.8"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test", "UnicodeFun"]
git-tree-sha1 = "8f52dbaa1351ce4cb847d95568cb29e62a307d93"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.5.6"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.MixedModels]]
deps = ["Arrow", "DataAPI", "Distributions", "GLM", "JSON3", "LazyArtifacts", "LinearAlgebra", "Markdown", "NLopt", "PooledArrays", "ProgressMeter", "Random", "SnoopPrecompile", "SparseArrays", "StaticArrays", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels", "StructTypes", "Tables"]
git-tree-sha1 = "fa0816c673c5da589ab8c7bbbd0b0f358ddca53b"
uuid = "ff71e718-51f3-5ec2-a782-8ffcbfa3c316"
version = "4.8.2"

[[deps.MixedModelsExtras]]
deps = ["LinearAlgebra", "MixedModels", "Statistics", "StatsBase", "StatsModels", "Tables"]
git-tree-sha1 = "b304a39ee68eb4d89c9eb52a95be3e00086bc89c"
uuid = "781a26e1-49f4-409a-8f4c-c3159d78c17e"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "4cc0c5a83933648b615c36c2b956d94fda70641e"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.7"

[[deps.Mods]]
git-tree-sha1 = "61be59e4daffff43a8cec04b5e0dc773cbb5db3a"
uuid = "7475f97c-0381-53b1-977b-4c60186c8d62"
version = "1.3.3"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.Multisets]]
git-tree-sha1 = "8d852646862c96e226367ad10c8af56099b4047e"
uuid = "3b2b4ff1-bcff-5658-a3ee-dbcf1ce5ac09"
version = "0.4.4"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "964cb1a7069723727025ae295408747a0b36a854"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.3.0"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NLopt]]
deps = ["MathOptInterface", "MathProgBase", "NLopt_jll"]
git-tree-sha1 = "5a7e32c569200a8a03c3d55d286254b0321cd262"
uuid = "76087f3c-5699-56af-9a33-bf431cd00edd"
version = "0.6.5"

[[deps.NLopt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9b1f15a08f9d00cdb2761dcfa6f453f5d0d6f973"
uuid = "079eb43e-fd8e-5478-9966-2cf3e3edb778"
version = "2.7.1+0"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2ac17d29c523ce1cd38e27785a7d23024853a4bb"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.10"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "a4ca623df1ae99d09bc9868b008262d0c0ac1e4f"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.4+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenML]]
deps = ["ARFFFiles", "HTTP", "JSON", "Markdown", "Pkg", "Scratch"]
git-tree-sha1 = "6efb039ae888699d5a74fb593f6f3e10c7193e33"
uuid = "8b6db2d4-7670-4922-a472-f9537c81ab66"
version = "0.3.1"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1aa4b74f80b01c6bc2b89992b861b5f210e665b5"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.21+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "e3a6546c1577bfd701771b477b794a52949e7594"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.7.6"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "9b02b27ac477cad98114584ff964e3052f656a0f"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.0"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "ec3edfe723df33528e085e632414499f26650501"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.0"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "84a314e3926ba9ec66ac097e3635e270986b0f10"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.9+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "4b2e829ee66d4218e0cef22c0a64ee37cf258c29"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.1"

[[deps.Permutations]]
deps = ["Combinatorics", "LinearAlgebra", "Random"]
git-tree-sha1 = "6e6cab1c54ae2382bcc48866b91cf949cea703a1"
uuid = "2ae35dd2-176d-5d53-8349-f30d82d94d4f"
version = "0.4.16"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase"]
git-tree-sha1 = "3aa2bb4982e575acd7583f01531f241af077b163"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "3.2.13"
weakdeps = ["ChainRulesCore", "MakieCore", "MutableArithmetics"]

    [deps.Polynomials.extensions]
    PolynomialsChainRulesCoreExt = "ChainRulesCore"
    PolynomialsMakieCoreExt = "MakieCore"
    PolynomialsMutableArithmeticsExt = "MutableArithmetics"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.PrettyPrinting]]
git-tree-sha1 = "22a601b04a154ca38867b991d5017469dc75f2db"
uuid = "54e16d92-306c-5ea0-a30b-337be88ac337"
version = "0.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "ee094908d720185ddbdc58dbe0c1cbe35453ec7a"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.7"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "4c9f306e5d6603ae203c2000dd460d81a5251489"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.4"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "6ec7ac8412e83d57e313393220879ede1740f9ee"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.2"

[[deps.RCall]]
deps = ["CategoricalArrays", "Conda", "DataFrames", "DataStructures", "Dates", "Libdl", "Missings", "REPL", "Random", "Requires", "StatsModels", "WinReg"]
git-tree-sha1 = "d441bdeea943f8e8f293e0e3a78fe2d7c3aa24e6"
uuid = "6f49c342-dc21-5d91-9882-a32aef131414"
version = "0.13.15"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegressionTables]]
deps = ["Compat", "Distributions", "FixedEffectModels", "Formatting", "GLM", "Statistics", "StatsBase", "StatsModels", "UnPack"]
git-tree-sha1 = "129bad054effa2b5cb3e2cded441ad316f918b2e"
uuid = "d519eb52-b820-54da-95a6-98e1306fdade"
version = "0.5.9"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.RingLists]]
deps = ["Random"]
git-tree-sha1 = "9712ebc42e91850f35272b48eb840e60c0270ec0"
uuid = "286e9d63-9694-5540-9e3c-4e6708fa07b2"
version = "0.2.7"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "0e270732477b9e551d884e6b07e23bb2ec947790"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.5"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "d49e35f413186528f1d7cc675e67d0ed16fd7800"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.4.0"

[[deps.ScientificTypes]]
deps = ["CategoricalArrays", "ColorTypes", "Dates", "Distributions", "PrettyTables", "Reexport", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "75ccd10ca65b939dab03b812994e571bf1e3e1da"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "3.0.2"

[[deps.ScientificTypesBase]]
git-tree-sha1 = "a8e18eb383b5ecf1b5e6fc237eb39255044fd92b"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "3.0.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SetRounding]]
git-tree-sha1 = "d7a25e439d07a17b7cdf97eecee504c50fedf5f6"
uuid = "3cc68bcd-71a2-5612-b932-767ffbe40ab0"
version = "0.2.1"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "0d15c3e7b2003f4451714f08ffec2b77badc2dc4"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.3.0"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "503688b59397b3307443af35cd953a13e8005c16"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "2.0.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleGraphs]]
deps = ["AbstractLattices", "Combinatorics", "DataStructures", "IterTools", "LightXML", "LinearAlgebra", "LinearAlgebraX", "Optim", "Primes", "Random", "RingLists", "SimplePartitions", "SimplePolynomials", "SimpleRandom", "SparseArrays", "Statistics"]
git-tree-sha1 = "b608903049d11cc557c45e03b3a53e9260579c19"
uuid = "55797a34-41de-5266-9ec1-32ac4eb504d3"
version = "0.8.4"

[[deps.SimplePartitions]]
deps = ["AbstractLattices", "DataStructures", "Permutations"]
git-tree-sha1 = "dcc02923a53f316ab97da8ef3136e80b4543dbf1"
uuid = "ec83eff0-a5b5-5643-ae32-5cbf6eedec9d"
version = "0.3.0"

[[deps.SimplePolynomials]]
deps = ["Mods", "Multisets", "Polynomials", "Primes"]
git-tree-sha1 = "d073c45302132b324ca653e1053966b4beacc2a5"
uuid = "cc47b68c-3164-5771-a705-2bc0097375a0"
version = "0.2.11"

[[deps.SimpleRandom]]
deps = ["Distributions", "LinearAlgebra", "Random"]
git-tree-sha1 = "3a6fb395e37afab81aeea85bae48a4db5cd7244a"
uuid = "a6525b86-64cd-54fa-8f65-62fc48bdc0e8"
version = "0.3.1"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "7beb031cf8145577fbccacd94b8a8f4ce78428d3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StableHashTraits]]
deps = ["CRC32c", "Compat", "Dates", "SHA", "Tables", "TupleTools", "UUIDs"]
git-tree-sha1 = "0b8b801b8f03a329a4e86b44c5e8a7d7f4fe10a3"
uuid = "c5dd0088-6c3f-4803-b00e-f31a60c170fa"
version = "0.3.1"

[[deps.StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore"]
git-tree-sha1 = "9cabadf6e7cd2349b6cf49f1915ad2028d65e881"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.2"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "30b9236691858e13f167ce829490a68e1a597782"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "3.2.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "a5e15f27abd2692ccb61a99e0854dfb7d48017db"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.33"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "521a0e828e98bb69042fec1809c1b5a680eb7389"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.15"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TexTables]]
deps = ["Compat", "DataFrames", "DataStructures", "Distributions", "Formatting", "GLM", "Parameters", "StatsBase", "StatsModels"]
git-tree-sha1 = "b1adb560810b2cd88e505f50e02b245730447149"
uuid = "ebf5ac4f-3ec1-555f-9ac9-3d72ed88c471"
version = "0.2.7"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "8621f5c499a8aa4aa970b1ae381aae0ef1576966"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.4"

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Scratch", "Unicode"]
git-tree-sha1 = "5b347464bdac31eccfdbe1504d9484c31645cafc"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.11.0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.TupleTools]]
git-tree-sha1 = "3c712976c47707ff893cf6ba4354aa14db1d8938"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.3.0"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Vcov]]
deps = ["Combinatorics", "GroupedArrays", "LinearAlgebra", "StatsAPI", "StatsBase", "Tables"]
git-tree-sha1 = "7391d297ff5bff38c7158f0e04aaf2f4974b74ba"
uuid = "ec2bfdc2-55df-4fc9-b9ae-4958c2cf2486"
version = "0.7.1"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.WinReg]]
git-tree-sha1 = "cd910906b099402bcc50b3eafa9634244e5ec83b"
uuid = "1b915085-20d7-51cf-bf83-8f477d6f5128"
version = "1.0.0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╟─e02d1d08-31a6-11ee-05c0-3fded2c52dc0
# ╟─dc3c9cd9-98c3-48ff-89ef-881991721051
# ╠═373a8f0b-cf27-43d0-b214-9bef8145ac2d
# ╠═eb51482a-1eb0-4d11-a5e5-ff13cdeb940e
# ╠═1c345bc7-ba34-4f21-b3f2-8bb7f9ba3fdf
# ╠═e595e681-0dcf-40db-8459-61992f38a149
# ╠═e026e88e-0c37-4c53-b6ea-556db747ad55
# ╠═eab1f185-3190-4a5c-9c0d-f91d9e62a98a
# ╟─93e932a6-d7b5-4bd3-ab83-884277a86252
# ╠═0b16e142-f9ed-4842-9a17-3d3d1dabea4c
# ╠═5022fb0a-850d-46f8-99a9-0973270e1591
# ╠═b872f35f-658e-49ee-ad00-a687dee8ac5b
# ╟─d0cdff5b-3d49-49a6-8aad-373376cd78ff
# ╠═c007858c-f865-4a08-a6bf-210ab409c358
# ╠═23483986-4127-4e3d-96b7-36cf9f1412c7
# ╠═c12d37f6-b0e6-4b10-9009-acea72869ef3
# ╟─b56e5aa2-914a-4240-a1a7-02cc4449732b
# ╠═373683e8-acfc-49a4-ad4e-5d7cba0667f8
# ╟─74e69afe-95db-445e-bc78-f91c1108f614
# ╟─49911172-6663-4c57-9f9d-1bd0398c2c5a
# ╟─64b3c32c-bd24-4ed1-be84-d9ce6ffdbb17
# ╟─efd3b952-3fb4-4e87-9e68-bf3a0ac03740
# ╠═d9b2dad1-0a27-461a-9e45-2819c30a33eb
# ╟─0d0440cf-241c-4b86-9de7-03eb4f9e7890
# ╟─fa216c50-71cf-4708-ae73-3ad877093325
# ╟─83b559dd-5aa4-4fd0-a684-9a9dd963fef5
# ╠═b5d1b8f4-5e4e-49ba-81e1-deeaa7782181
# ╟─e362468a-ab9a-4b17-9a0f-e67af2503231
# ╠═99a86494-1c5b-49b9-be6b-7d003f08b07b
# ╠═119c3526-d75a-471c-846c-e11df58d696f
# ╟─82cec8cc-6991-4141-ac13-c6ad9e090215
# ╠═56ead667-4ba6-4563-be7d-b4234ffc33b8
# ╟─c47399ab-0c48-454c-9104-449d3a61cf21
# ╟─39059e21-6f4f-40af-9f54-e2b06d8e7808
# ╟─ab3a4347-21bf-447b-8a56-1219dda6adf9
# ╟─10af0650-5798-469d-ad88-33f4a2d3c3e3
# ╟─a0165481-f6f2-4e7b-a09e-bd58cc140a40
# ╟─6ab51b36-797d-4d55-81f8-7c5fb9a0fc32
# ╠═2b708fce-a3b6-4de5-a259-186b2ed179b2
# ╟─fef1615f-af29-4a54-a308-644d2a103a14
# ╠═35da6608-113f-4651-95be-4e9e10303685
# ╠═2e1e7a0c-7734-47f2-9ae6-980776bebc4a
# ╟─4615af75-7341-49b1-b9ab-e44f6b6ce3f3
# ╠═735d055b-93f8-410d-a7a0-2b915aa5854d
# ╠═d456f6fa-097e-451d-975c-fde6b3882bf9
# ╟─bcdf5cf2-10c4-4fd7-a143-e92fcfc04b37
# ╠═e614d405-a0d9-4aa5-aa50-baca613cde1f
# ╟─f25655b4-1c60-45c3-9a1b-8e470460cb9c
# ╠═8a27954a-0872-4a7e-ae84-35d0eda99423
# ╠═b05b5336-867e-4363-bf1d-1ecf3f0193cf
# ╠═0d04220f-3b20-446f-a868-89c47786b699
# ╠═5c424cda-2a85-4aab-b781-cb07eb71bdb1
# ╠═daae6c76-e0d3-4cb1-973d-392e85533344
# ╟─a9d97ec1-ffd4-4b14-bcbc-1032c10477e2
# ╠═6c5f55a1-d122-4b31-a14a-ac5ef4a2da6d
# ╟─67113ad5-c737-4f5a-9973-1b99b075d6b2
# ╠═4860ca61-0103-4677-8e7e-f2ec7544d450
# ╠═fe127eef-5a9e-4ba6-ab20-3eae2a9adde6
# ╟─ab52e070-7f3e-45e3-977c-fa8ba3aa456f
# ╠═fa974bc0-24a9-4d0f-80fa-2f5c0ddbd8b3
# ╟─96669b55-ae7c-4d8f-a690-f7f1be4d5f44
# ╠═7fd05bc2-e3a0-4e37-a6cc-27e767bc6261
# ╠═ef795a76-7471-4a55-9628-6f9b46e4b6c6
# ╟─51c566ad-c54b-4406-9195-cec1fd368892
# ╠═184204d9-8184-4827-8e67-0b862df0981d
# ╟─9967a627-5755-417c-ba56-89827a0d3287
# ╟─1a1e898d-f7d0-4647-a079-306c92aaace1
# ╠═d8a3eec1-3931-4c96-9cd2-784cbe7f5e65
# ╠═7162cd94-4741-4395-b6d2-decfd7cbb106
# ╠═645206ca-e604-4727-bade-ee1ddae623ce
# ╠═10864522-1f9f-466e-8abc-fb5be45fea27
# ╠═d40fa321-576d-4b5b-a711-9e473826567b
# ╟─b33b6bb6-ea41-4b1e-977e-9cc554808a94
# ╠═e9b85328-d023-4a32-a1d6-71dee5c5a200
# ╠═1d416826-109c-4dea-89af-49317c5cb57a
# ╟─8bce14bd-2aed-45dc-bde5-1b2ce531077a
# ╠═760a6a5f-aca2-412d-8079-8c956f5effa0
# ╠═1eb34940-7f96-4503-b19d-7aeedf1342fc
# ╟─46d201be-8889-4f7c-ba6a-618dcaaa69e7
# ╠═dcd430a1-d627-4076-98aa-4b55462deb4d
# ╠═8b006583-45f0-4a5d-bb9d-1a2cfe7d95ec
# ╟─7c00571c-39a2-4727-8ed8-8c7d817101f8
# ╠═ad05b5a9-59d7-4e95-a071-adcfc89f258e
# ╠═fdcf2cea-745b-4254-8503-65c12233cc57
# ╟─26f4dad9-4575-4c66-9a8f-41e274978ed7
# ╠═0c997303-be4a-437c-8842-8965db6114f8
# ╠═2897caf3-0033-4e98-99ae-9ddc37d4e570
# ╟─73d900ca-a1cb-456f-822b-6367cc8b11af
# ╟─0dfc97ee-03a0-421a-a2c8-9b9f7a8488ae
# ╠═fa4201d1-fb3e-45b0-a391-450a3c260381
# ╠═ee014c7c-1b84-49aa-bd0b-d1045b9cd305
# ╠═523fde92-67ab-45e0-999d-b29327c8d3b1
# ╠═07a6daab-9aa4-477d-86d9-6f90eef03f64
# ╟─c2131a98-589a-4ae9-a6f3-b6ae29c02aab
# ╠═991ee3ba-47dc-4d25-9bc8-93e96e9814d5
# ╟─a74109c3-2b23-4e54-8aad-9d5cce1153d6
# ╟─4e7a73de-2ab4-4d6f-a2a3-769f8f4c80e7
# ╠═a0e34c6e-5a21-4367-9a75-2b61170c05e1
# ╠═224745a0-276a-4b49-9f10-e59806ec6bd9
# ╠═e122ea68-a61e-4fd7-a182-8230fa4d7439
# ╟─339b293e-46e3-4dc3-aa4b-8c18267e4841
# ╠═08f2272a-dc81-4a45-8a37-3e7bd397b99a
# ╟─b80d663e-fe00-4fb8-aa08-8271e0a973c2
# ╠═62e648df-96ec-4682-a5c1-4f79ecf47a7c
# ╠═90ca3511-62db-41b0-ae42-52b90adf6c54
# ╠═f2944e30-733a-4112-8bd8-ebd0affb2693
# ╟─7463d81f-413c-4929-bae6-aa8926550f8c
# ╠═558e7ec7-d43f-4eea-8e12-44d2321b4b37
# ╟─d2bd3ec9-b47b-40d1-ac27-d46b96747754
# ╠═b4d6c989-41a8-4022-a52f-56d704a60e22
# ╠═6576fe9b-9417-4591-b0ea-755c032dcae4
# ╠═b7d25489-cfb2-47dc-927b-2f96caa7527b
# ╠═bf652bcb-a854-4982-a26a-79d4d7afc369
# ╠═3e4165bd-cb7e-4abe-a04e-578263ad967b
# ╟─3f119061-f5c8-409e-ba74-bed863ba71f2
# ╠═1689d81c-1a53-4ecd-b020-4e01f956018e
# ╠═ffe2a36d-65ca-4c25-8242-b8cbcf20e346
# ╠═d37a7255-723b-4923-80bc-a06b6965752d
# ╠═17078f8e-6409-4247-9f53-ef7ad5a7af71
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
