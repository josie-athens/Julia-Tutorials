### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 5cee562c-f108-49d3-bece-d62d37c19879
using PlutoUI; PlutoUI.TableOfContents(aside=true, title="📚 Contents")

# ╔═╡ 45a17582-72ed-4b60-9ab7-0e3caf91e2c8
begin
	using StatsBase, Distributions, HypothesisTests
	using AnovaGLM, Effects, MultipleTesting
	using DataFrames, Tidier, TexTables, RCall, MLJ
	using MLJ: schema
end

# ╔═╡ 36e844c2-a33e-454f-bf6e-995c660dfb94
begin
	using AlgebraOfGraphics, CairoMakie, MakieThemes
	CairoMakie.activate!(type = "svg")
	AoG = AlgebraOfGraphics; data = AoG.data
	set_theme!(ggthemr(:light))
end

# ╔═╡ 3929273b-4572-486e-93d0-a84cdab67391
include("pubh.jl");

# ╔═╡ 2a9b0e48-2da3-11ee-21f3-c3e92488a854
md"""
# Continuous Outcomes

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform, **AgRresearch Ltd**
	- 1 December 2023
"""

# ╔═╡ 953e1df5-0f62-4832-b7c0-47c216ac95a5
md"""
## [📖 Main Menu](index.html)
"""

# ╔═╡ f682fce2-327c-4e7c-b712-ceb99ef9df5c
begin
	@rimport readr
	@rimport pubh
end

# ╔═╡ 98a1299b-282f-4a2e-a656-4416d7f61377
md"""
# Confidence Intervals around the Mean
"""

# ╔═╡ 416cdc5a-917d-4960-9bfc-c36de90c40f0
md"""
!!! tip \"Example\"

	The data set we will be using for this tutorial is from Bernard, GR, *et al*. (1997) The effects of ibuprofen on the physiology and survival of patients with sepsis, N Engl J Med 336(13): 912–918. Here is an abbreviated version of the abstract.

	> "we conducted a randomized, double-blind, placebo-controlled trial of intravenous ibuprofen in 455 patients who had sepsis, defined as fever, tachycardia, tachypnea, and acute failure of at least one organ system. In the ibuprofen group, but not the placebo group, there were significant declines in [various measures including] temperature; however, treatment with ibuprofen did not reduce the incidence or duration of shock or the acute respiratory distress syndrome and did not significantly improve the rate of survival at 30 days (mortality, 37 percent with ibuprofen vs. 40 percent with placebo)."
"""

# ╔═╡ c49f7411-b1b4-4e93-aca1-5bdd539bf26f
bernard = rcopy(R"pubh::Bernard"); bernard |> schema

# ╔═╡ 6f01c3f3-e5ad-493a-b721-fe193e54d7cd
md"""
!!! note

	We can see from the initial description that there are missing values on `temp10`. We will need to deal with those later.
"""

# ╔═╡ befed92f-0930-426c-97a9-c558bccecac3
md"Let’s take a look at the distribution of baseline temperature."

# ╔═╡ f7d6d84c-51d6-4533-a991-fa7821786447
let
	plt = data(bernard) * 
	mapping(:temp0) *
	visual(QQNorm, qqline=:fitrobust, markersize=5, color=:firebrick)

	draw(plt, 
  		axis=(
    	xlabel="Normal quantiles",
    	ylabel="Temperature (°C)"
  )
)
end

# ╔═╡ b9232d76-707e-486f-bc61-f1fbe4c835da
md"Let’s assume normality and estimate the 95% CI around the mean baseline temperature for all patients."

# ╔═╡ 68e29f99-cf15-44fa-b977-f246aa343ed6
r3.(ci_mean(bernard.temp0))

# ╔═╡ 8ce5ef9b-7a5f-4b4f-991c-a15e1ab49dad
md"What about the 95% CI around the mean temperature after 36 hr of treatment?"

# ╔═╡ aa8bb4b0-5c26-4d5f-858d-c00e234cd162
r3.(ci_mean(@filter(bernard, !ismissing(temp10)).temp10))

# ╔═╡ abec6086-b66d-45aa-bed1-305b5b5c695f
md"""
!!! tip 

	We can estimate bootstrap CI via `bst` from `R` package `pubh`.
"""

# ╔═╡ 554ed4b0-c91c-4e0f-b7a9-b2a185b4e975
pubh.bst(bernard.temp10) |> rcopy

# ╔═╡ 2e43817a-82ab-4bab-aade-1b7a64ee32ff
md"""
# Tests for Means

## One-sample *t*-tests

Perform the following two-sided one-sample *t*-test, where the normal core temperature is 37°C. Note that because sepsis was diagnosed in this case by a set of symptoms including fever, you would be very surprised if there were no evidence of a difference between the mean baseline temperature of sepsis patients and the normal body temperature.

If we define x̄ as the mean baseline temperature, our two hypotheses are:

-   H₀ = x̄ = 37°C
-   Hₐ = x̄ ≠ 37°C

By default, we are using a two-sided test, with a significant α = 0.05 (95% CI).
"""

# ╔═╡ 3900cc27-0189-45a1-81e0-fb08bafa4a4f
OneSampleTTest(bernard.temp0, 37)

# ╔═╡ cabb0151-ae7d-4db3-93ee-dc83ff947028
md"""
!!! note

	We are making a one-sample *t*-test, comparing the mean baseline temperature, against the mean reference value of μ = 37°C. Because the test is two-sided, if our mean value is significantly greater or significantly less than μ = 37°C we reject the null hypothesis. The probability of observing a mean baseline temperature of x̄ = 37°C in our sample is *p* < 0.001. The mean baseline temperature in our sample was x̄ = 38.09°C (95% CI: 37.91°C, 38.12°C).
"""

# ╔═╡ c7cf1d8c-bc0e-4032-b935-a9c6ea9298d6
md"""
!!! note

	There are deviations from normality in baseline temperature. Lower temperatures are particularly very unlikely to come from a normal distribution.

	Our sample is large enough to not be worried about small deviations from normality. In healthy subjects, the temperature would be expected to be centred, and normally distributed.
"""

# ╔═╡ 20deaef0-8b81-473b-b57a-73699c3481f4
md"""
## Paired *t*-tests
"""

# ╔═╡ beed3a18-0cc6-4a24-9b65-ae58b1329369
md"""
!!! tip \"Example\"

	Assume we want to know if there was a significant decrease in the mean temperature at 36 hours in the Placebo group. The *t*-test assumes that data is independent. In this example, the same subjects were measured twice: at baseline and 36 hours. This is a classic example of a *paired* analysis.
"""

# ╔═╡ 3b506761-587c-4853-bf12-d605ea889e82
 placebo = @chain bernard begin
	 @filter(treat == "Placebo")
	 @select(temp0, temp10)
 end;

# ╔═╡ dd31202f-4c60-4aba-a6bb-1e2972830718
dropmissing!(placebo);

# ╔═╡ 4226300d-36ca-48dd-bac4-8c2fd457a651
OneSampleTTest(placebo.temp10, placebo.temp0)

# ╔═╡ 5517eee5-38e7-468b-b11f-2cb9c2924441
md"""
!!! danger \"Interpretation\"

	The mean decrease in temperature from baseline to 36 hr in the placebo group was 0.50°C (95% CI: 0.35°C, 0.64°C). There was a significant placebo effect (*p* =0.001) as the 95% CI for the temperature change in the placebo group did not include the null value of zero.
"""

# ╔═╡ 27c36c66-69d1-47f3-b9ee-1c55c69eaab8
md"""
## Two-sample *t*-tests

Our real question of interest is to test if given Ibuprofen was statistically different from given placebo in patients with sepsis. This is a two-sided, two-sample hypothesis. The two samples are independent (treatment groups), and our variable of interest is `temp_change`.

First, we calculate the difference in temperatures.
"""

# ╔═╡ d54f8e2c-7c1f-44df-89a8-01bfb2711f26
begin
	bern = @chain bernard begin
		@select(temp0, temp10, treat)
		@mutate(temp_change = temp10 - temp0)
	end
	dropmissing!(bern)
	bern |> head
end

# ╔═╡ 6d2a66ef-4c57-43b4-979c-ab510b3bac7c
md"""
One of the assumptions is that the distribution of `temp_change` is normal for each group. The another big assumption is that the variance is the same. To compare variances, we perform a variance test. The null hypothesis is that the ratio of the two variances is equal to one (same variance) and the alternative is that is different from one. A *p* ≤ 0.05 means that there is no statistical difference between the two variances and, therefore, that the assumption of homogeneity of variances holds.

First, we perform a standard descriptive analysis on `temp_change`.
"""

# ╔═╡ 46246b07-f620-4683-aa9c-59082cdd246a
pubh.estat(@formula(temp_change ~ treat), data=bern) |> rcopy

# ╔═╡ 80245239-d03a-46b6-9543-ce0efed87a7f
md"""
!!! note \"Exercise\"

	Construct a QQ-plot of `temp_change` from subjects by treatment group, against the standard normal distribution to check for the normality assumption.
"""

# ╔═╡ 58f87d23-7dcc-403d-8c6e-ffe4b5dfdf40
md"""
```julia
let
	plt = data(bern) * 
	mapping(:temp_change, color=:treat => "Cohort") *
	visual(QQNorm, qqline=:fitrobust, markersize=5, color=:firebrick)

	draw(plt, 
  		axis=(;
    		xlabel="Normal quantiles",
    		ylabel="Temperature (°C)"
    	))
end
```
""" |> hint

# ╔═╡ e13e5217-b0af-45aa-99d2-e696a22e27de
let
	plt = data(bern) * 
	mapping(:temp_change, color=:treat => "Cohort") *
	visual(QQNorm, qqline=:fitrobust, markersize=5, color=:firebrick)

	draw(plt, 
  		axis=(;
    		xlabel="Normal quantiles",
    		ylabel="Temperature (°C)"
    	))
end

# ╔═╡ ff6846f9-3398-47db-9fff-ad3d2f951990
md"We perform a variance test with `VarianceFTest`."

# ╔═╡ d631b4b5-790d-4f96-b1bb-e9f4574d3d3a
VarianceFTest(
  	@filter(bern, treat == "Ibuprofen").temp_change,
  	@filter(bern, treat == "Placebo").temp_change
) |> pvalue |> r3

# ╔═╡ d5b02686-1780-4181-b6d1-fd99ee4b4402
md"""
!!! note

	`HypothesisTests` is not designed yet, to work with data frames, hence, one needs to provides each vector. As an alternative to the previous code, we can generate these vectors with the function `vec_group`. The arguments of `vec_group` are the data frame, the outcome (continuous) variable and the group (categorical) variable.
"""

# ╔═╡ 083a6819-a089-4b3a-ba69-62c2696970af
VarianceFTest(
  	vec_group(bern, :temp_change, :treat)...
) |> pvalue |> r3

# ╔═╡ 7ae638ee-00df-45c9-a1cb-4a50e6a9bf53
md"Now, let's test the null hypothesis that the mean temperature change between the two groups is the same."

# ╔═╡ 74bd1dcb-95ff-45d5-b660-1a3ffcce0c4f
EqualVarianceTTest(
  	vec_group(bern, :temp_change, :treat)...
)

# ╔═╡ c2a3950a-3f83-408c-9867-6004c92fc8ab
md"""
# Non Parametric tests

## Mann-Whitney

In some disciplines, researchers are not interested in the magnitude of the difference, e.g., when there is no precise knowledge of the interpretation of the scales. Under those circumstances, they may choose a priori, to use non-parametric tests for relatively small samples.

Non-parametric tests are also used when violations to the *t*-test assumptions occur.
"""

# ╔═╡ 25430d11-55c9-4d3a-82f3-2c4d9ce87a37
md"""
!!! warning

	We never, ever perform both a parametric and a non-parametric test. That decision has to be taken *a priori*, given our assumptions. When we perform both tests, we may fall into the temptation to report the more beneficial results; in other words, by performing both tests, we introduce bias in our analysis.
"""

# ╔═╡ 20dd0235-976a-4915-b9c3-e92b2f1ee7ea
md"""
!!! tip \"Example\"

	We will compare energy expenditure between lean and obese woman.
"""

# ╔═╡ e133ad57-7908-4e49-a6c6-bde30d1e82e6
energy = rcopy(R"ISwR::energy"); energy |> schema

# ╔═╡ f659cb9f-25df-4230-88a1-a2513a2b3132
md"""
!!! note \"Exercise\"

	Calculate descriptive statistics for variable `expend` by `stature` from the `energy` dataset.
"""

# ╔═╡ 19b6a4f8-313c-4484-ba53-2be2e8246011
md"""
!!! hint
	```julia
	pubh.estat(@formula(expend~stature), data=energy) |> rcopy
	```
"""

# ╔═╡ 30709ba4-bd51-4a54-b00a-083b53263373
pubh.estat(@formula(expend~stature), data=energy) |> rcopy

# ╔═╡ ddad013c-f146-451d-b4bb-d7c468154cdf
md"""
!!! warning \"Question\"

	What are your general observations from the descriptive analysis?
"""

# ╔═╡ d0404fcd-6b09-4910-a40e-2534b1388505
md"""
!!! hint

	On average, obese women have more energy expenditure than lean woman, but we do not know if that difference is significant.
"""

# ╔═╡ 30d44015-5bde-4549-a31c-7dd2774e22fe
md"Given that our samples are relatively small (less than 30 observations per group), the best way to graphically compare distributions is by strip charts."

# ╔═╡ 99f33bab-5ccd-459d-a5a3-7b75554e7074
md"""
!!! note \"Exercise\"

	Construct a strip chart comparing the energy expenditure by stature.
"""

# ╔═╡ 36e12d56-d432-427a-a37c-164e27c32660
md"""
```julia
data(energy) *
mapping(
  	:stature => "Stature", 
  	:expend => "Energy expenditure (MJ)",
	color = :stature => "Stature"
) *
visual(
  	RainClouds, clouds=violin, 
  	plot_boxplots=false, markersize=7
  	) |>
draw
```
""" |> hint

# ╔═╡ bee8a0ea-09da-4223-9d6b-a5571c7a1d10
data(energy) *
mapping(
  	:stature => "Stature", 
  	:expend => "Energy expenditure (MJ)",
	color = :stature => "Stature"
) *
visual(
  	RainClouds, clouds=violin, 
  	plot_boxplots=false, markersize=7
  	) |>
draw

# ╔═╡ 422454cf-0d53-4ae1-99d1-cf06a6e0f260
md"""
We can use bootstrap CI to construct a strip chart with error bars.
"""

# ╔═╡ 44644d56-addf-45c9-914a-a578225eff85
let
	ϵ = coerce(energy, :stature => Count)
	ϵ.x = randn(ϵ |> nrow)/100  + ϵ.stature
	df = pubh.gen_bst_df(@formula(expend ~ stature), data=energy) |> rcopy
	
	fig = Figure()
	Axis(
		fig[1, 1],
		xticks= (1:2, ["Lean", "Obese"]),
		ylabel="Energy expenditure (MJ)",
		xlabel="Stature"
	)

	scatter!(ϵ.x, ϵ.expend, markersize=7, color=:cadetblue)
	scatter!(1:2, df.expend, markersize=10, color=:firebrick)
	rangebars!(1:2, df.LowerCI, df.UpperCI, whiskerwidth=10, color=:firebrick)
	fig
end

# ╔═╡ 37247129-36b3-434a-ab86-c53e2b136072
md"""
!!! note

	1. We convert our categorical variable to an integer and we assign this to a new data frame (`ϵ`) to not mess with our original data set.
	2. In `x` we are adding a jitter so we can see better the observations.
	3. We define a data frame with the bootstrap CI.
	4. We construct the plot. For the errorbars, we use `rangebars!`.
"""

# ╔═╡ 34236077-91c8-4650-aa24-9b641af142ee
md"We can check graphically for normality. Strictly speaking, the mean difference is the one that has to be normally distributed, for simplicity, we will look at the distribution of energy for each group, as that is a good indicator about normality on the mean difference."

# ╔═╡ 3f28fbe5-649c-45a5-8185-f0e5617926ff
md"What about variance equality?"

# ╔═╡ 64be2b20-3133-4d44-bf2e-2325d3060da9
VarianceFTest(
  	vec_group(energy, :expend, :stature)...
) |> pvalue |> r3

# ╔═╡ ff86a788-1c31-4b73-a677-7cef064e3595
md"The associated non-parametric test to the *t*-test is the Wilcoxon-Mann-Whitney test, more commonly known as Mann-Whitney test."

# ╔═╡ 85f78f71-b811-408f-9dcf-ab2c95210238
MannWhitneyUTest(
  	vec_group(energy, :expend, :stature)...
) |> pvalue |> r3

# ╔═╡ 43764081-e021-4974-aecd-c6001f0628ee
md"""
!!! tip \"Example\"

	We are going to use an example from Altman on the number of CD4⁺ T cells and CD8⁺ T cells in patients with Hodgkin's disease or with disseminated malignancies (the Non-Hodgkin's disease group).
"""

# ╔═╡ ab211c01-94fa-41cb-9698-ddd8d2d121b3
hodgkin = rcopy(R"pubh::Hodgkin"); hodgkin |> schema

# ╔═╡ bb339ab5-fc8b-4824-a68f-4199577b6424
md"""
!!! warning \"Exercise\"

	Generate a new variable, named ratio that will contain the ratio of CD4⁺ / CD8⁺ T cells.
"""

# ╔═╡ d36891cc-0ebe-4251-b927-581f24312539
md"""
```julia
hodgkin.ratio = hodgkin.CD4 ./ hodgkin.CD8;
```
""" |> hint

# ╔═╡ d2f46f92-838f-4c75-9a49-b57d73f76b9d
hodgkin.ratio = hodgkin.CD4 ./ hodgkin.CD8;

# ╔═╡ 66a2377d-83d7-44b2-8955-50a82b150d41
md"""
!!! warning \"Exercise\"

	Generate a table with descriptive statistics for `ratio`, stratified by `Group`.
"""

# ╔═╡ 3c52c5b3-d397-48f9-8520-54aeadc30817
md"""
```julia
pubh.estat(@formula(ratio ~ Group), data=hodgkin) |> rcopy
```
""" |> hint

# ╔═╡ 4c27fcdf-e6bd-4fa5-bef9-36f8f0e4957a
pubh.estat(@formula(ratio ~ Group), data=hodgkin) |> rcopy

# ╔═╡ d179dfdb-455c-4afe-bdde-a5b9eb314ccb
md"Let's compare the distributions of the ratios with a QQ-Plot:"

# ╔═╡ 786d9da2-aa32-432f-8bf8-886b328f10b5
let
  	hodg = DataFrame(
    	x = @filter(hodgkin, Group == "Hodgkin").ratio,
    	y = @filter(hodgkin, Group == "Non-Hodgkin").ratio
  	)
  
  	data(hodg) *
  	mapping(
    	:x => "Hodgkin ratio", 
    	:y => "Non-Hodgkin ratio") *
  	visual(QQPlot, qqline=:fit) |>
  	draw
end

# ╔═╡ 10a24fb2-81f0-4ee2-9ba6-c4005f90b1e8
md"""
!!! note

	I know that for the normal, healthy population about 60% of their T-cells is CD4⁺ and about 40% CD8⁺ , i.e., a Ratio = 1.5. Given this, I know that the population who is showing abnormal levels is the group of non-Hodgkin's lymphoma (see descriptive analysis). I would not be interested in knowing the confidence intervals of that difference.

	Given that:

	-   The sample size is relatively small.
	-   The distribution of CD4⁺ / CD8⁺ T cells is not the same in the two groups.
	-   Small changes (regardless of magnitude) in the distribution of T cell populations have significant biological consequences.

	I would perform a non-parametric test. Once I know that this difference is statistically significant (i.e., very unlikely due to chance), I would conduct further studies to find out more about what is happening at a cellular and molecular level.

	Would it be wrong to make a parametric test? Not at all, as long as the rationale and assumptions are clear. What is wrong it to perform both tests. We are not going to do that and perform only the Mann-Whitney test.
"""

# ╔═╡ 0eab88cf-4679-4f1e-b753-cd33368888ac
MannWhitneyUTest(
  	vec_group(hodgkin, :ratio, :Group)...
) |> pvalue |> r3

# ╔═╡ dfe03441-641c-468f-abb2-c79795e2cb2c
md"""
## Paired data

Paired tests are used when there are two measurements on the same experimental unit. We will use data on pre- and post-menstrual energy intake in a group of 11 women.
"""

# ╔═╡ f7ffb18a-c481-480b-b486-7374ce3398a6
intake = rcopy(R"ISwR::intake"); intake |> schema

# ╔═╡ 4a269c90-fe88-4ca8-80fa-d7898cca4572
md"We can start, as usual, with descriptive statistics."

# ╔═╡ 62d401d9-6f2d-4c7b-98e3-aefadf7ca83f
estat(intake)

# ╔═╡ 342d2e81-3363-4ff3-a96a-0ce379351c77
md"Let's work on the assumption that we are not interested in the magnitude of the difference but only if that difference is significant or not. On those circumstances and given the small sample size, we would perform a non-parametric test that would be equivalent to the paired *t*-test."

# ╔═╡ e92f440c-692f-433f-9055-d30eaf015895
md"""
!!! note

	Having a small sample does not imply that a non-parametric test should be used. For example, when we know or assume that our variable of interest is normally distributed, we use a parametric test.
"""

# ╔═╡ dad0b0ad-b840-4c3e-b9af-1c6610f8500f
SignedRankTest(
	intake.pre,
	intake.post
)

# ╔═╡ b7638900-802a-4ae7-904b-8237f1a4b1e7
md"""
!!! tip \"Question\"

	What is your conclusion from the analysis?
"""

# ╔═╡ ad74d409-555f-4ab5-821c-3e8a288538db
md"""
On a sample of 11 women, we found that women have a significantly higher energy intake before their menstrual period than after (*p* = 0.001, Exact Wilcoxon signed rank test).
""" |> hint

# ╔═╡ 262cd181-386c-4dee-80d9-50baad46d48a
md"# ANOVA"

# ╔═╡ 796a1050-53fb-491e-8446-b1e2a1100be7
md"""
!!! tip \"Example\"

	We will use a dataset on infant birth weight (in kg) and the smoking status of their mothers at the end of the first trimester.
"""

# ╔═╡ 0471593f-c67c-4aa9-8415-7267b7e68b5a
smokew = readr.read_rds("data/smokew.rds") |> rcopy; smokew |> schema

# ╔═╡ f04892f9-cef4-4168-aa55-51eac5096a3e
md"We can start with descriptive statistics."

# ╔═╡ 18f11e0b-e6e2-499b-ba01-e35f4b8ef62d
pubh.estat(@formula(bweight ~ smoking), data=smokew) |> rcopy

# ╔═╡ 072b0791-daac-4eb5-ac51-5bc74b45973c
md"Given the number of observations per group, we use a strip chart to compare the four groups graphically."

# ╔═╡ 5265094a-6358-4b13-9093-f0623a3e91c8
let
	plt = data(smokew) *
	mapping(
  		:smoking => "Smoking status",
  		:bweight => "Birth weight (kg)",
		color = :smoking => ""
	) *
	visual(
  	RainClouds, clouds=violin, 
  	plot_boxplots=false, markersize=7
  	)
	draw(plt, axis=(; xticklabelrotation = pi/6))
end

# ╔═╡ 4db1ac27-d967-4fd3-9cc0-d9383dac645a
md"""
## Initial assumptions

Normality can be tested using the Shapiro-Wilks test. The null hypothesis is that the distribution of the error is normal. We could look at the distribution of `bweight` for each group with QQ-plots. We will check for normality after *fitting* the model.

Homoscedasticity (homogeneity of variances) can be tested with Bartlett's or Levene's test of variance. The null hypothesis is that the variances are equal (homogeneous).
"""

# ╔═╡ 00d69a4b-6dd2-4a93-ba27-f849694e1dcd
LeveneTest(
  	vec_group(smokew, :bweight, :smoking)...
) |> pvalue |> r3

# ╔═╡ 7d4db3f7-14f0-4924-bf35-af9d35f7471e
md"""
## Model

We will make ANOVA after first fitting a linear model with `lm`:
"""

# ╔═╡ 170ca72e-a01c-4e0e-8d5f-8ac1fbe45d66
model_smoke = lm(@formula(bweight ~ smoking), smokew);

# ╔═╡ a916e255-d4b6-42ec-97ab-caf1e45f816c
anova(model_smoke)

# ╔═╡ 0bb684cb-1916-434b-a31d-0ae900cf16e1
md"""
!!! danger \"Interpretation\"

	Not all groups of babies have the same mean birth weight. At least one of them is statistically different to another (*p* = 0.014). From the descriptive statistics, we know that the cohort of babies born from non-smoker mothers have a mean birth weight significantly higher than those born from heavy-smoker mothers.
"""

# ╔═╡ 459f1dcf-6c60-4f45-9676-0374b13d5d5c
md"""
## Post-hoc tests

So far, we know that there is evidence that at least the cohort of babies born from non-smoker mothers has a mean birth weight higher than those born from heavy-smoker mothers, but we do not know about any other comparison.

If we perform all possible paired *t*-test between the groups we would be increasing our error. To avoid that, we adjust our confidence intervals and *p*-values for multiple comparisons. There are several methods for making the adjustment.

We can use the function `empairs` to do the pairwise comparison and then adjust corresponding *p*-values with functions from `MultipleTesting`.
"""

# ╔═╡ 9d8bab1f-0602-48e3-9c38-1a3621d8b917
BH_adj(pvals) = MultipleTesting.adjust(PValues(pvals), BenjaminiHochberg());

# ╔═╡ d4d10073-f368-4c58-a58a-ea84e0eae408
empairs(model_smoke; dof=dof_residual, padjust=BH_adj)

# ╔═╡ a08c158d-9d0c-4c9a-a77e-7a2b58269f8a
md"""
!!! danger \"Interpretation\"

	We compared the birth weights of babies born from mothers of four different smoking status: non-smokers, ex-smokers, light-smokers and heavy-smokers with one-way ANOVA. We obtained a significant result (*p* = 0.014) that merited a post-hoc analysis. For the post-hoc analysis, we adjusted *p*-values for multiple comparisons by the method of Benjamini-Hochberg. After adjusting for multiple comparisons, the only statistical difference found was between babies born from non-smoker mothers and babies born from heavy-smoker mothers (*p* = 0.022). On average, babies born from non-smoker mothers had a birth weight of 0.71 kg higher than babies born from heavy-smoker mothers.
"""

# ╔═╡ b8a2a834-0b19-463e-8d36-1232732935f4
md"""
## Diagnostics
"""

# ╔═╡ eeb10e3b-ce08-4365-9684-2706e4ae9178
smoke_perf = model_perf(model_smoke);

# ╔═╡ fc1ba662-2bab-49a3-b0d3-b2e0795baf7e
md"Normality."

# ╔═╡ 277f4b22-82ba-4edf-adf0-5acd92159390
data(smoke_perf) *
mapping(:error) *
visual(QQNorm, qqline=:fit, markersize=5) |>
draw

# ╔═╡ ccb32055-42e6-4b44-9ec0-c12a1db54c9f
md"Variance."

# ╔═╡ b03537b7-d823-43b9-b495-6a76f930ae42
let
	layers = visual(Scatter, markersize=5) + smooth()
	data(smoke_perf) *
	mapping(
  	:predicted => "Fitted values",
  	:error => "Residuals"
	) *
	layers * mapping() |>
	draw
end

# ╔═╡ b87dfffd-464c-4ebd-8ad1-4b17d72c40ce
println("Mean absolute error: ", mean(abs.(smoke_perf.error)) |> r3)

# ╔═╡ c1cd47eb-a6ed-4f6a-bc29-d6d090a96832
println("Mean absolute percentage error: ", mape(smoke_perf) |> r3)

# ╔═╡ 1cf83581-5f32-40e3-b90f-3deb00491e52
println("Root mean square error: ", rmse(smoke_perf) |> r3)

# ╔═╡ 17a21808-996c-44ac-8b25-2ddc2ab76182
md"""
## Effects

In *treatment* coding of categorical variables (the default), the hypothesis for the coefficients for each level is against the reference level.
"""

# ╔═╡ 4855f585-c016-4c8d-beeb-2603089ca622
model_smoke

# ╔═╡ 36268f8d-b9d8-4052-8a96-448724169f7b
md"In *effects* coding of categorical variables, the hypothesis for the coefficients for each level is against the mean across all levels."

# ╔═╡ 08f8b157-94e1-4e77-a43b-5d1df166ea1c
model_eff = lm(
  	@formula(bweight ~ smoking), smokew;
  	contrasts=Dict(:smoke => EffectsCoding())
)

# ╔═╡ 17133ea3-a5e8-4ad9-b983-2d63433e1226
md"To look at the effects, we first generate a reference grid:"

# ╔═╡ 5e824fe3-a64f-4efc-aa04-3865041473f8
model_des = Dict(:smoking => unique(smokew.smoking));

# ╔═╡ d0f135af-322e-4242-9f86-37d7ddf703cb
smoke_eff = effects(model_des, model_eff)

# ╔═╡ a7a2780c-f04b-4632-b3ca-d5c6339d171b
md"We can use the estimated effects to get a nice visual of the data:"

# ╔═╡ de9ff5fd-f0dd-4175-b83f-cf322ec29495
let
	plt = data(smoke_eff) *
	mapping(
  		:smoking => sorter(levels(smokew.smoking)) => "Smoking status",
  		:bweight => "Birth weight (kg)"
	) *
	(
  		visual(Scatter, markersize=10) + 
  		mapping(:err) * 
  		visual(Errorbars, whiskerwidth=10)
	)
	draw(plt, axis=(; xticklabelrotation=pi/6))
end

# ╔═╡ a80cab2d-f676-4e3f-a342-87e5fb337415
md"""
!!! note

	We used `sorter` to display the levels of our categorical variable in the correct order, else, they would be plotted sorted alphabetically.
"""

# ╔═╡ 53a8b3e5-b5d4-4922-b7dd-85572c1e1a6f
model_smoke

# ╔═╡ 2cc1d3c6-d05b-43b6-aa36-9dfab655483a
md"## Alternatives for non-Normal data"

# ╔═╡ 22144c93-88ca-44a6-a483-158050828ef8
md"""
!!! tip \"Example\"

	The `airquality` dataset has daily readings on air quality values for May 1, 1973 (a Tuesday) to September 30, 1973.
"""

# ╔═╡ 6d3cd456-e289-499d-a338-509f37222dd4
begin
	air = rcopy(R"datasets::airquality")
	dropmissing!(air)
	air.Month = recode(
    	air.Month,
   		5 => "May",
    	6 => "Jun",
    	7 => "Jul",
    	8 => "Aug",
    	9 => "Sep"
	)
	coerce!(air, :Month => Multiclass)
	levels!(air.Month, unique(air.Month))
	air |> schema
end

# ╔═╡ 38c7fa4a-1ffc-49ec-b7d3-00ef3a536918
md"""
!!! warning \"Exercise\"

	Calculate descriptive statistics for `Ozone` by `Month`.
"""

# ╔═╡ 11e86b74-9e4a-4e0d-a228-e1f054faf55c
md"""
```julia
pubh.estat(@formula(Ozone ~ Month), data = air) |> rcopy
```
""" |> hint

# ╔═╡ 36a963d5-b437-4682-a6d6-4fe68d0099d7
pubh.estat(@formula(Ozone ~ Month), data = air) |> rcopy

# ╔═╡ a76e3ed8-2d46-47d4-9c9f-ffc7319defcf
md"""
!!! danger \"Interpretation\"

	Look at the relative dispersion; the distribution of ozone is clearly not normal. The months of July and August have the highest median concentrations of ozone. We do not know yet, if the month with the highest median ozone concentration (July), is significantly different from the one with the lowest median ozone concentration (May). In June, ozone concentrations were recorded for only nine days.
"""

# ╔═╡ 13e9cf09-4f25-46c3-a1a9-8b3200045607
md"""
!!! warning \"Exercise\"

	Use Levene's test to test for homoscedasticity.
"""

# ╔═╡ 40fdede1-b7b9-4e3c-864c-1dddedb60b22
md"""
```julia
LeveneTest(
  	vec_group(air, :Ozone, :Month)...
) |> pvalue |> r3
```
""" |> hint

# ╔═╡ a3cbc677-f112-4531-95d2-1de079a003b7
LeveneTest(
  	vec_group(air, :Ozone, :Month)...
) |> pvalue |> r3

# ╔═╡ c67e2cf1-b0a9-4c82-89f5-97b9683b05d0
md"""
### Log-transformation

We can log-transform to make the distribution closer to Normal and the variance constant between groups.

We check for normality for each group.
"""

# ╔═╡ 7c592c80-e343-45d0-b3ea-43865ecd890b
air.log_oz = log.(air.Ozone);

# ╔═╡ ae5f7ed5-e854-4b58-89af-d88ca40118a7
let
	plt = data(air) * 
	mapping(:log_oz, layout=:Month) *
	visual(QQNorm, qqline=:fitrobust, markersize=5)
    
	draw(plt, 
  	axis=(
    	xlabel="Normal quantiles",
    	ylabel="log (Ozone)"
    	))
end

# ╔═╡ 6b257908-fbf7-4d9f-b30e-9d1aa6cc80bc
md"Normality seems to be good enough, though we will check the distribution of the residuals later. What about homoscedasticity?"

# ╔═╡ bdf576c0-0f68-4014-a27e-014e5da4aea7
LeveneTest(
  	vec_group(air, :log_oz, :Month)...
) |> pvalue |> r3

# ╔═╡ ab17e2d4-e55b-42da-9843-5f6829202767
md"We can proceed to fit an ANOVA model to our data."

# ╔═╡ 4ea05476-1a66-4681-bda9-5952274100b9
model_air = lm(
  	@formula(log_oz ~ Month), air;
  	contrasts=Dict(:Month => EffectsCoding())
);

# ╔═╡ 3e45637d-c39a-4bc4-aab8-8796d22931a5
anova(model_air)

# ╔═╡ b84b4438-0925-4c5a-9d44-50eef5b35d49
md"Diagnostics:"

# ╔═╡ 8139dfb6-88cb-4d4b-b502-18005505fe9d
air_perf = model_perf(model_air);

# ╔═╡ 12be6ea0-7a6e-4f4f-9d8e-da5b320709ab
md"Normality:"

# ╔═╡ b011dd84-23f7-4f45-9588-cda878479e4f
data(air_perf) *
mapping(:error) *
visual(QQNorm, qqline=:fit, markersize=5) |>
draw

# ╔═╡ 9d9248b5-b2f6-4fd6-be80-e5dabdd469bf
md"Variance:"

# ╔═╡ fd1f18f6-aded-4978-bcd1-b2ba20a47e66
let
	layers = visual(Scatter, markersize=5) + smooth()
	data(air_perf) *
	mapping(
  	:predicted => "Fitted values",
  	:error => "Residuals"
	) *
	layers * mapping() |>
	draw
end

# ╔═╡ 365a49c0-a700-407d-8006-0b541612cb8d
air_des = Dict(:Month => unique(air.Month));

# ╔═╡ 33b647a8-ab99-4716-8738-131baff5ce4c
air_eff = effects(air_des, model_air, invlink=exp)

# ╔═╡ 71a72c35-390d-4b67-aa56-dd3f9db6d04c
data(air_eff) *
mapping(
  	:Month => sorter(levels(air.Month)),
  	:log_oz => "Ozone (ppb)"
  	) *
(
  	visual(Scatter, markersize=10) + 
	  mapping(:err) * 
  	visual(Errorbars, whiskerwidth=10)
) |>
draw

# ╔═╡ ad96607f-6702-4348-a7fe-f332b9c9b2a7
md"### Kruskal-Wallis test"

# ╔═╡ d8b13182-78c0-4506-9996-2023a997a12f
md"""
!!! tip \"Example\"

	We are going to look at a RCT about treatment of children suffering from frequent and severe migraine.
"""

# ╔═╡ ce7a2511-4541-404d-abfd-67994e55a823
fent = rcopy(R"pubh::Fentress"); fent |> schema

# ╔═╡ d58867bb-ba19-4abe-8f37-13bbec5bbb7e
md"""
!!! warning \"Exercise\"

	Calculate statistics of `pain` by `group` from the `fent` dataset.
"""

# ╔═╡ 52dd9fb8-c692-414d-81a8-ef9c9489eb77
md"""
```julia
pubh.estat(@formula(pain ~ group), data=fent) |> rcopy
```
""" |> hint

# ╔═╡ e7fb28d9-e4dc-46e1-9220-25e0a07a54dc
pubh.estat(@formula(pain ~ group), data=fent) |> rcopy

# ╔═╡ 10e33689-61c6-474e-9d82-fa342f105425
md"""
!!! warning \"Exercise\"

	Compare the mucociliary efficiency between groups with a `RainCloud` plot.
"""

# ╔═╡ 9030fb68-2ed1-4091-a911-a89fe0a0ed52
md"""
```julia
let
	plt = data(fent) *
	mapping(
  		:group => "Cohort", 
  		:pain => "Pain reduction",
		color = :group => ""
	) *
	visual(
  	RainClouds, clouds=violin, 
  	plot_boxplots=false, markersize=7
  	)
	draw(plt, axis=(; xticklabelrotation=pi/6))
end
```
""" |> hint

# ╔═╡ 8abb5ea3-745a-42cf-9056-4ed0902989dc
let
	plt = data(fent) *
	mapping(
  		:group => "Cohort", 
  		:pain => "Pain reduction",
		color = :group => ""
	) *
	visual(
  	RainClouds, clouds=violin, 
  	plot_boxplots=false, markersize=7
  	)
	draw(plt, axis=(; xticklabelrotation=pi/6))
end

# ╔═╡ ffa17295-5587-40a9-8433-aade6069aa26
md"""
!!! warning \"Question\"

	What is your main concern regarding your descriptive analysis?
"""

# ╔═╡ 352cfd84-01f3-408a-a01e-0ccde2556d71
md"""
!!! hint
	Dispersion of pain reduction is greater in the Untreated group than in the other two groups. The sample size is relatively small for the control limit theorem to compensate.
"""

# ╔═╡ d0197886-a129-4812-a7fd-020f9df476cd
md"We are going to perform the non-parametric, Kruskal-Wallis test, to test if the differences in pain reduction between groups are statistically significant or not."

# ╔═╡ 24dd9c5b-c5e6-48f8-867a-9450ff77466c
KruskalWallisTest(
  	vec_group(fent, :pain, :group)...
) |> pvalue |> r3

# ╔═╡ 1d5bed22-e79a-4ae4-b70f-0f804baab527
md"""
!!! danger \"Interpretation\"

	We did not find a significant difference between pain reduction in the untreated group and treatment groups (either relaxation or with biofeedback) (*p* = 0.057, Kruskal-Wallis test).
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
AnovaGLM = "0a47a8e3-ec57-451e-bddb-e0be9d22772b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Effects = "8f03c58b-bd97-4933-a826-f71b64d2cca2"
HypothesisTests = "09f84164-cd44-5f33-b23f-e6b0d136a0d5"
MLJ = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
MakieThemes = "e296ed71-da82-5faf-88ab-0034a9761098"
MultipleTesting = "f8716d33-7c4a-5097-896f-ce0ecbd3ef6b"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
TexTables = "ebf5ac4f-3ec1-555f-9ac9-3d72ed88c471"
Tidier = "f0413319-3358-4bb0-8e7c-0c83523a93bd"

[compat]
AlgebraOfGraphics = "~0.6.16"
AnovaGLM = "~0.2.2"
CairoMakie = "~0.10.7"
DataFrames = "~1.6.1"
Distributions = "~0.25.103"
Effects = "~1.0.2"
HypothesisTests = "~0.11.0"
MLJ = "~0.20.0"
MakieThemes = "~0.1.0"
MultipleTesting = "~0.6.0"
PlutoUI = "~0.7.52"
RCall = "~0.13.15"
StatsBase = "~0.33.21"
TexTables = "~0.2.7"
Tidier = "~1.0.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "878c1f0b098d46b07f5a6a3e566aad8c8f4a3122"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

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

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

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

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

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

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "e28912ce94077686443433c2800104b061a827ed"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.39"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

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

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "44dbf560808d49041989b8a96cae4cffbeb7966a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.11"

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
git-tree-sha1 = "3124343a1b0c9a2f5fdc1d9bcc633ba11735a4c4"
uuid = "af321ab8-2d2e-40a6-b165-3d674595d28e"
version = "0.1.13"

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

[[deps.Cleaner]]
deps = ["Tables"]
git-tree-sha1 = "f0ebda9a8284c10ec10df406f669edca4c69892f"
uuid = "caabdcdb-0ab6-47cf-9f62-08858e44f38f"
version = "0.5.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
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

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

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

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

    [deps.CompositionsBase.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

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

[[deps.ContextVariablesX]]
deps = ["Compat", "Logging", "UUIDs"]
git-tree-sha1 = "25cc3803f1030ab855e383129dcd3dc294e322cc"
uuid = "6add18c4-b38d-439d-96f6-d6bc489c04c5"
version = "0.1.3"

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

[[deps.DataDeps]]
deps = ["HTTP", "Libdl", "Reexport", "SHA", "p7zip_jll"]
git-tree-sha1 = "6e8d74545d34528c30ccd3fa0f3c00f8ed49584c"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.11"

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

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

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
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "a6c00f894f24460379cb7136633cef54ac9f6f4a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.103"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Documenter]]
deps = ["ANSIColoredPrinters", "Base64", "Dates", "DocStringExtensions", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "REPL", "Test", "Unicode"]
git-tree-sha1 = "39fd748a73dce4c05a9655475e437170d8fb1b67"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "0.27.25"

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
git-tree-sha1 = "780c5dca344d16e6e4cafbec38e7e3635de863ab"
uuid = "8f03c58b-bd97-4933-a826-f71b64d2cca2"
version = "1.0.2"

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

[[deps.FLoops]]
deps = ["BangBang", "Compat", "FLoopsBase", "InitialValues", "JuliaVariables", "MLStyle", "Serialization", "Setfield", "Transducers"]
git-tree-sha1 = "ffb97765602e3cbe59a0589d237bf07f245a8576"
uuid = "cc61a311-1640-44b5-9fba-1b764f453329"
version = "0.2.1"

[[deps.FLoopsBase]]
deps = ["ContextVariablesX"]
git-tree-sha1 = "656f7a6859be8673bf1f35da5670246b923964f7"
uuid = "b9860ae5-e623-471e-878b-f6a53c775ea6"
version = "0.1.1"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

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

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

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

[[deps.HypothesisTests]]
deps = ["Combinatorics", "Distributions", "LinearAlgebra", "Printf", "Random", "Rmath", "Roots", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "4b5d5ba51f5f473737ed9de6d8a7aa190ad8c72f"
uuid = "09f84164-cd44-5f33-b23f-e6b0d136a0d5"
version = "0.11.0"

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

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

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

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "LinearAlgebra", "MacroTools", "PrecompileTools", "Requires", "SparseArrays", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "5f1ecfddb6abde48563d08b2cc7e5116ebcd6c27"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.10"

    [deps.KernelAbstractions.extensions]
    EnzymeExt = "EnzymeCore"

    [deps.KernelAbstractions.weakdeps]
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"

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

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Preferences", "Printf", "Requires", "Unicode"]
git-tree-sha1 = "c879e47398a7ab671c782e02b51a4456794a7fa3"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "6.4.0"

    [deps.LLVM.extensions]
    BFloat16sExt = "BFloat16s"

    [deps.LLVM.weakdeps]
    BFloat16s = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "a84f8f1e8caaaa4e3b4c101306b9e801d3883ace"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.27+0"

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

[[deps.LearnAPI]]
deps = ["InteractiveUtils", "Statistics"]
git-tree-sha1 = "ec695822c1faaaa64cee32d0b21505e1977b4809"
uuid = "92ad9a40-7767-427a-9ee6-6e577f1266cb"
version = "0.1.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "154d7aaa82d24db6d8f7e4ffcfe596f40bff214b"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2023.1.0+0"

[[deps.MLFlowClient]]
deps = ["Dates", "FilePathsBase", "HTTP", "JSON", "ShowCases", "URIs", "UUIDs"]
git-tree-sha1 = "32cee10a6527476bef0c6484ff4c60c2cead5d3e"
uuid = "64a0f543-368b-4a9a-827a-e71edb2a0b83"
version = "0.4.4"

[[deps.MLJ]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "LinearAlgebra", "MLJBase", "MLJEnsembles", "MLJFlow", "MLJIteration", "MLJModels", "MLJTuning", "OpenML", "Pkg", "ProgressMeter", "Random", "Reexport", "ScientificTypes", "StatisticalMeasures", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "58d17a367ee211ade6e53f83a9cc5adf9d26f833"
uuid = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
version = "0.20.0"

[[deps.MLJBase]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LearnAPI", "LinearAlgebra", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "Reexport", "ScientificTypes", "Serialization", "StatisticalMeasuresBase", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "6d433d34a1764324cf37a1ddc47dcc42ec05340f"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "1.0.1"
weakdeps = ["StatisticalMeasures"]

    [deps.MLJBase.extensions]
    DefaultMeasuresExt = "StatisticalMeasures"

[[deps.MLJEnsembles]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Distributed", "Distributions", "MLJModelInterface", "ProgressMeter", "Random", "ScientificTypesBase", "StatisticalMeasuresBase", "StatsBase"]
git-tree-sha1 = "94403b2c8f692011df6731913376e0e37f6c0fe9"
uuid = "50ed68f4-41fd-4504-931a-ed422449fee0"
version = "0.4.0"

[[deps.MLJFlow]]
deps = ["MLFlowClient", "MLJBase", "MLJModelInterface"]
git-tree-sha1 = "dc0de70a794c6d4c1aa4bde8196770c6b6e6b550"
uuid = "7b7b8358-b45c-48ea-a8ef-7ca328ad328f"
version = "0.2.0"

[[deps.MLJIteration]]
deps = ["IterationControl", "MLJBase", "Random", "Serialization"]
git-tree-sha1 = "991e10d4c8da49d534e312e8a4fbe56b7ac6f70c"
uuid = "614be32b-d00c-4edb-bd02-1eb411ab5e55"
version = "0.6.0"

[[deps.MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "381d99f0af76d98f50bd5512dcf96a99c13f8223"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.9.3"

[[deps.MLJModels]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Combinatorics", "Dates", "Distances", "Distributions", "InteractiveUtils", "LinearAlgebra", "MLJModelInterface", "Markdown", "OrderedCollections", "Parameters", "Pkg", "PrettyPrinting", "REPL", "Random", "RelocatableFolders", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "10d221910fc3f3eedad567178ddbca3cc0f776a3"
uuid = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
version = "0.16.12"

[[deps.MLJTuning]]
deps = ["ComputationalResources", "Distributed", "Distributions", "LatinHypercubeSampling", "MLJBase", "ProgressMeter", "Random", "RecipesBase", "StatisticalMeasuresBase"]
git-tree-sha1 = "44dc126646a15018d7829f020d121b85b4def9bc"
uuid = "03970b2e-30c4-11ea-3135-d1576263f10f"
version = "0.8.0"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MLUtils]]
deps = ["ChainRulesCore", "Compat", "DataAPI", "DelimitedFiles", "FLoops", "NNlib", "Random", "ShowCases", "SimpleTraits", "Statistics", "StatsBase", "Tables", "Transducers"]
git-tree-sha1 = "3504cdb8c2bc05bde4d4b09a81b01df88fcbbba0"
uuid = "f1d291b0-491e-4a28-83b9-f70985020b54"
version = "0.4.3"

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

[[deps.MarketData]]
deps = ["CSV", "Dates", "HTTP", "JSON3", "Random", "Reexport", "TimeSeries"]
git-tree-sha1 = "715536b6af6292883128e22857c83291e30fea25"
uuid = "945b72a4-3b13-509d-9b46-1525bb5c06de"
version = "0.13.12"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

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

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

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

[[deps.MultipleTesting]]
deps = ["Distributions", "SpecialFunctions", "StatsBase"]
git-tree-sha1 = "1e98f8f732e7035c4333135b75605b74f3462b9b"
uuid = "f8716d33-7c4a-5097-896f-ce0ecbd3ef6b"
version = "0.6.0"

[[deps.Multisets]]
git-tree-sha1 = "8d852646862c96e226367ad10c8af56099b4047e"
uuid = "3b2b4ff1-bcff-5658-a3ee-dbcf1ce5ac09"
version = "0.4.4"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NNlib]]
deps = ["Adapt", "Atomix", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "LinearAlgebra", "Pkg", "Random", "Requires", "Statistics"]
git-tree-sha1 = "3bc568de99214f72a76c7773ade218819afcc36e"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.9.7"

    [deps.NNlib.extensions]
    NNlibAMDGPUExt = "AMDGPU"
    NNlibCUDACUDNNExt = ["CUDA", "cuDNN"]
    NNlibCUDAExt = "CUDA"
    NNlibEnzymeCoreExt = "EnzymeCore"

    [deps.NNlib.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    cuDNN = "02a925ec-e4fe-4b08-9a7e-0d78e3d38ccd"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

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

[[deps.PalmerPenguins]]
deps = ["CSV", "DataDeps"]
git-tree-sha1 = "e7c581b0e29f7d35f47927d65d4965b413c10d90"
uuid = "8b842266-38fa-440a-9b57-31493939ab85"
version = "0.1.4"

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

    [deps.Polynomials.extensions]
    PolynomialsChainRulesCoreExt = "ChainRulesCore"
    PolynomialsMakieCoreExt = "MakieCore"
    PolynomialsMutableArithmeticsExt = "MutableArithmetics"

    [deps.Polynomials.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    MakieCore = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
    MutableArithmetics = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"

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

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.PrettyPrinting]]
git-tree-sha1 = "22a601b04a154ca38867b991d5017469dc75f2db"
uuid = "54e16d92-306c-5ea0-a30b-337be88ac337"
version = "0.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "542b1bd03329c1d235110f96f1bb0eeffc48a87d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.6"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "4c9f306e5d6603ae203c2000dd460d81a5251489"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.4"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

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

[[deps.Roots]]
deps = ["ChainRulesCore", "CommonSolve", "Printf", "Setfield"]
git-tree-sha1 = "0f1d92463a020321983d04c110f476c274bafe2e"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.0.22"

    [deps.Roots.extensions]
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"

    [deps.Roots.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"

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

[[deps.ShowCases]]
git-tree-sha1 = "7f534ad62ab2bd48591bdeac81994ea8c445e4a5"
uuid = "605ecd9f-84a6-4c9e-81e2-4798472b76a3"
version = "0.1.0"

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

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

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

[[deps.StatisticalMeasures]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Distributions", "LearnAPI", "LinearAlgebra", "MacroTools", "OrderedCollections", "PrecompileTools", "ScientificTypesBase", "StatisticalMeasuresBase", "Statistics", "StatsBase"]
git-tree-sha1 = "b58c7cc3d7de6c0d75d8437b81481af924970123"
uuid = "a19d573c-0a75-4610-95b3-7071388c7541"
version = "0.1.3"

    [deps.StatisticalMeasures.extensions]
    LossFunctionsExt = "LossFunctions"
    ScientificTypesExt = "ScientificTypes"

    [deps.StatisticalMeasures.weakdeps]
    LossFunctions = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
    ScientificTypes = "321657f4-b219-11e9-178b-2701a2544e81"

[[deps.StatisticalMeasuresBase]]
deps = ["CategoricalArrays", "InteractiveUtils", "MLUtils", "MacroTools", "OrderedCollections", "PrecompileTools", "ScientificTypesBase", "Statistics"]
git-tree-sha1 = "17dfb22e2e4ccc9cd59b487dce52883e0151b4d3"
uuid = "c062fc1d-0d66-479b-b6ac-8b44719de4cc"
version = "0.1.1"

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

[[deps.Tidier]]
deps = ["Reexport", "TidierCats", "TidierData", "TidierDates", "TidierPlots", "TidierStrings"]
git-tree-sha1 = "c7a6c4db043a4d27a4150a3ea07b03d3a9a158ca"
uuid = "f0413319-3358-4bb0-8e7c-0c83523a93bd"
version = "1.0.1"

[[deps.TidierCats]]
deps = ["CategoricalArrays", "DataFrames", "Reexport", "Statistics"]
git-tree-sha1 = "c4660f2c0ffd733ec243ea0a5447bd3bfae40c6d"
uuid = "79ddc9fe-4dbf-4a56-a832-df41fb326d23"
version = "0.1.1"

[[deps.TidierData]]
deps = ["Chain", "Cleaner", "DataFrames", "MacroTools", "Reexport", "ShiftedArrays", "Statistics"]
git-tree-sha1 = "a4a83e2f5083ee6b18e0f01c99b4483b4f7978a2"
uuid = "fe2206b3-d496-4ee9-a338-6a095c4ece80"
version = "0.10.0"

[[deps.TidierDates]]
deps = ["Dates", "Documenter", "Reexport"]
git-tree-sha1 = "ba1e0e3e7c99cdccb7c8d9d568e413283323716f"
uuid = "20186a3f-b5d3-468e-823e-77aae96fe2d8"
version = "0.1.0"

[[deps.TidierPlots]]
deps = ["AlgebraOfGraphics", "CairoMakie", "DataFrames", "Makie", "MarketData", "PalmerPenguins", "Reexport"]
git-tree-sha1 = "1e2f273690efe000786b142bbe83b431fceb29f1"
uuid = "337ecbd1-5042-4e2a-ae6f-ca776f97570a"
version = "0.1.0"

[[deps.TidierStrings]]
git-tree-sha1 = "1e704fbaf9f4d651ed9c59b4b6a6c325c0f09558"
uuid = "248e6834-d0f8-40ef-8fbb-8e711d883e9c"
version = "0.1.0"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "8621f5c499a8aa4aa970b1ae381aae0ef1576966"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.4"

[[deps.TimeSeries]]
deps = ["Dates", "DelimitedFiles", "DocStringExtensions", "RecipesBase", "Reexport", "Statistics", "Tables"]
git-tree-sha1 = "8b9288d84da88ea44693ca8cf9c236da1778f274"
uuid = "9e3dc215-6440-5c97-bce1-76c03772f85e"
version = "0.23.2"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "53bd5978b182fa7c57577bdb452c35e5b4fb73a5"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.78"

    [deps.Transducers.extensions]
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

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

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "323e3d0acf5e78a56dfae7bd8928c989b4f3083e"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.1.3"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WinReg]]
git-tree-sha1 = "cd910906b099402bcc50b3eafa9634244e5ec83b"
uuid = "1b915085-20d7-51cf-bf83-8f477d6f5128"
version = "1.0.0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

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
version = "1.52.0+1"

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
# ╟─2a9b0e48-2da3-11ee-21f3-c3e92488a854
# ╟─953e1df5-0f62-4832-b7c0-47c216ac95a5
# ╠═5cee562c-f108-49d3-bece-d62d37c19879
# ╠═45a17582-72ed-4b60-9ab7-0e3caf91e2c8
# ╠═3929273b-4572-486e-93d0-a84cdab67391
# ╠═36e844c2-a33e-454f-bf6e-995c660dfb94
# ╠═f682fce2-327c-4e7c-b712-ceb99ef9df5c
# ╟─98a1299b-282f-4a2e-a656-4416d7f61377
# ╟─416cdc5a-917d-4960-9bfc-c36de90c40f0
# ╠═c49f7411-b1b4-4e93-aca1-5bdd539bf26f
# ╟─6f01c3f3-e5ad-493a-b721-fe193e54d7cd
# ╟─befed92f-0930-426c-97a9-c558bccecac3
# ╠═f7d6d84c-51d6-4533-a991-fa7821786447
# ╟─b9232d76-707e-486f-bc61-f1fbe4c835da
# ╠═68e29f99-cf15-44fa-b977-f246aa343ed6
# ╟─8ce5ef9b-7a5f-4b4f-991c-a15e1ab49dad
# ╠═aa8bb4b0-5c26-4d5f-858d-c00e234cd162
# ╟─abec6086-b66d-45aa-bed1-305b5b5c695f
# ╠═554ed4b0-c91c-4e0f-b7a9-b2a185b4e975
# ╟─2e43817a-82ab-4bab-aade-1b7a64ee32ff
# ╠═3900cc27-0189-45a1-81e0-fb08bafa4a4f
# ╟─cabb0151-ae7d-4db3-93ee-dc83ff947028
# ╟─c7cf1d8c-bc0e-4032-b935-a9c6ea9298d6
# ╟─20deaef0-8b81-473b-b57a-73699c3481f4
# ╟─beed3a18-0cc6-4a24-9b65-ae58b1329369
# ╠═3b506761-587c-4853-bf12-d605ea889e82
# ╠═dd31202f-4c60-4aba-a6bb-1e2972830718
# ╠═4226300d-36ca-48dd-bac4-8c2fd457a651
# ╟─5517eee5-38e7-468b-b11f-2cb9c2924441
# ╟─27c36c66-69d1-47f3-b9ee-1c55c69eaab8
# ╠═d54f8e2c-7c1f-44df-89a8-01bfb2711f26
# ╟─6d2a66ef-4c57-43b4-979c-ab510b3bac7c
# ╠═46246b07-f620-4683-aa9c-59082cdd246a
# ╟─80245239-d03a-46b6-9543-ce0efed87a7f
# ╟─58f87d23-7dcc-403d-8c6e-ffe4b5dfdf40
# ╟─e13e5217-b0af-45aa-99d2-e696a22e27de
# ╟─ff6846f9-3398-47db-9fff-ad3d2f951990
# ╠═d631b4b5-790d-4f96-b1bb-e9f4574d3d3a
# ╟─d5b02686-1780-4181-b6d1-fd99ee4b4402
# ╠═083a6819-a089-4b3a-ba69-62c2696970af
# ╟─7ae638ee-00df-45c9-a1cb-4a50e6a9bf53
# ╠═74bd1dcb-95ff-45d5-b660-1a3ffcce0c4f
# ╟─c2a3950a-3f83-408c-9867-6004c92fc8ab
# ╟─25430d11-55c9-4d3a-82f3-2c4d9ce87a37
# ╟─20dd0235-976a-4915-b9c3-e92b2f1ee7ea
# ╠═e133ad57-7908-4e49-a6c6-bde30d1e82e6
# ╟─f659cb9f-25df-4230-88a1-a2513a2b3132
# ╟─19b6a4f8-313c-4484-ba53-2be2e8246011
# ╟─30709ba4-bd51-4a54-b00a-083b53263373
# ╟─ddad013c-f146-451d-b4bb-d7c468154cdf
# ╟─d0404fcd-6b09-4910-a40e-2534b1388505
# ╟─30d44015-5bde-4549-a31c-7dd2774e22fe
# ╟─99f33bab-5ccd-459d-a5a3-7b75554e7074
# ╟─36e12d56-d432-427a-a37c-164e27c32660
# ╟─bee8a0ea-09da-4223-9d6b-a5571c7a1d10
# ╟─422454cf-0d53-4ae1-99d1-cf06a6e0f260
# ╠═44644d56-addf-45c9-914a-a578225eff85
# ╟─37247129-36b3-434a-ab86-c53e2b136072
# ╟─34236077-91c8-4650-aa24-9b641af142ee
# ╟─3f28fbe5-649c-45a5-8185-f0e5617926ff
# ╠═64be2b20-3133-4d44-bf2e-2325d3060da9
# ╟─ff86a788-1c31-4b73-a677-7cef064e3595
# ╠═85f78f71-b811-408f-9dcf-ab2c95210238
# ╟─43764081-e021-4974-aecd-c6001f0628ee
# ╠═ab211c01-94fa-41cb-9698-ddd8d2d121b3
# ╟─bb339ab5-fc8b-4824-a68f-4199577b6424
# ╟─d36891cc-0ebe-4251-b927-581f24312539
# ╟─d2f46f92-838f-4c75-9a49-b57d73f76b9d
# ╟─66a2377d-83d7-44b2-8955-50a82b150d41
# ╟─3c52c5b3-d397-48f9-8520-54aeadc30817
# ╟─4c27fcdf-e6bd-4fa5-bef9-36f8f0e4957a
# ╟─d179dfdb-455c-4afe-bdde-a5b9eb314ccb
# ╠═786d9da2-aa32-432f-8bf8-886b328f10b5
# ╟─10a24fb2-81f0-4ee2-9ba6-c4005f90b1e8
# ╠═0eab88cf-4679-4f1e-b753-cd33368888ac
# ╟─dfe03441-641c-468f-abb2-c79795e2cb2c
# ╠═f7ffb18a-c481-480b-b486-7374ce3398a6
# ╟─4a269c90-fe88-4ca8-80fa-d7898cca4572
# ╠═62d401d9-6f2d-4c7b-98e3-aefadf7ca83f
# ╟─342d2e81-3363-4ff3-a96a-0ce379351c77
# ╟─e92f440c-692f-433f-9055-d30eaf015895
# ╠═dad0b0ad-b840-4c3e-b9af-1c6610f8500f
# ╟─b7638900-802a-4ae7-904b-8237f1a4b1e7
# ╟─ad74d409-555f-4ab5-821c-3e8a288538db
# ╟─262cd181-386c-4dee-80d9-50baad46d48a
# ╟─796a1050-53fb-491e-8446-b1e2a1100be7
# ╠═0471593f-c67c-4aa9-8415-7267b7e68b5a
# ╟─f04892f9-cef4-4168-aa55-51eac5096a3e
# ╠═18f11e0b-e6e2-499b-ba01-e35f4b8ef62d
# ╟─072b0791-daac-4eb5-ac51-5bc74b45973c
# ╠═5265094a-6358-4b13-9093-f0623a3e91c8
# ╟─4db1ac27-d967-4fd3-9cc0-d9383dac645a
# ╠═00d69a4b-6dd2-4a93-ba27-f849694e1dcd
# ╟─7d4db3f7-14f0-4924-bf35-af9d35f7471e
# ╠═170ca72e-a01c-4e0e-8d5f-8ac1fbe45d66
# ╠═a916e255-d4b6-42ec-97ab-caf1e45f816c
# ╟─0bb684cb-1916-434b-a31d-0ae900cf16e1
# ╟─459f1dcf-6c60-4f45-9676-0374b13d5d5c
# ╠═9d8bab1f-0602-48e3-9c38-1a3621d8b917
# ╠═d4d10073-f368-4c58-a58a-ea84e0eae408
# ╟─a08c158d-9d0c-4c9a-a77e-7a2b58269f8a
# ╟─b8a2a834-0b19-463e-8d36-1232732935f4
# ╠═eeb10e3b-ce08-4365-9684-2706e4ae9178
# ╟─fc1ba662-2bab-49a3-b0d3-b2e0795baf7e
# ╠═277f4b22-82ba-4edf-adf0-5acd92159390
# ╟─ccb32055-42e6-4b44-9ec0-c12a1db54c9f
# ╠═b03537b7-d823-43b9-b495-6a76f930ae42
# ╠═b87dfffd-464c-4ebd-8ad1-4b17d72c40ce
# ╠═c1cd47eb-a6ed-4f6a-bc29-d6d090a96832
# ╠═1cf83581-5f32-40e3-b90f-3deb00491e52
# ╟─17a21808-996c-44ac-8b25-2ddc2ab76182
# ╠═4855f585-c016-4c8d-beeb-2603089ca622
# ╟─36268f8d-b9d8-4052-8a96-448724169f7b
# ╠═08f8b157-94e1-4e77-a43b-5d1df166ea1c
# ╟─17133ea3-a5e8-4ad9-b983-2d63433e1226
# ╠═5e824fe3-a64f-4efc-aa04-3865041473f8
# ╠═d0f135af-322e-4242-9f86-37d7ddf703cb
# ╟─a7a2780c-f04b-4632-b3ca-d5c6339d171b
# ╠═de9ff5fd-f0dd-4175-b83f-cf322ec29495
# ╟─a80cab2d-f676-4e3f-a342-87e5fb337415
# ╠═53a8b3e5-b5d4-4922-b7dd-85572c1e1a6f
# ╟─2cc1d3c6-d05b-43b6-aa36-9dfab655483a
# ╟─22144c93-88ca-44a6-a483-158050828ef8
# ╠═6d3cd456-e289-499d-a338-509f37222dd4
# ╟─38c7fa4a-1ffc-49ec-b7d3-00ef3a536918
# ╟─11e86b74-9e4a-4e0d-a228-e1f054faf55c
# ╟─36a963d5-b437-4682-a6d6-4fe68d0099d7
# ╟─a76e3ed8-2d46-47d4-9c9f-ffc7319defcf
# ╟─13e9cf09-4f25-46c3-a1a9-8b3200045607
# ╟─40fdede1-b7b9-4e3c-864c-1dddedb60b22
# ╟─a3cbc677-f112-4531-95d2-1de079a003b7
# ╟─c67e2cf1-b0a9-4c82-89f5-97b9683b05d0
# ╠═7c592c80-e343-45d0-b3ea-43865ecd890b
# ╠═ae5f7ed5-e854-4b58-89af-d88ca40118a7
# ╟─6b257908-fbf7-4d9f-b30e-9d1aa6cc80bc
# ╠═bdf576c0-0f68-4014-a27e-014e5da4aea7
# ╟─ab17e2d4-e55b-42da-9843-5f6829202767
# ╠═4ea05476-1a66-4681-bda9-5952274100b9
# ╠═3e45637d-c39a-4bc4-aab8-8796d22931a5
# ╟─b84b4438-0925-4c5a-9d44-50eef5b35d49
# ╠═8139dfb6-88cb-4d4b-b502-18005505fe9d
# ╟─12be6ea0-7a6e-4f4f-9d8e-da5b320709ab
# ╠═b011dd84-23f7-4f45-9588-cda878479e4f
# ╟─9d9248b5-b2f6-4fd6-be80-e5dabdd469bf
# ╠═fd1f18f6-aded-4978-bcd1-b2ba20a47e66
# ╠═365a49c0-a700-407d-8006-0b541612cb8d
# ╠═33b647a8-ab99-4716-8738-131baff5ce4c
# ╠═71a72c35-390d-4b67-aa56-dd3f9db6d04c
# ╟─ad96607f-6702-4348-a7fe-f332b9c9b2a7
# ╟─d8b13182-78c0-4506-9996-2023a997a12f
# ╠═ce7a2511-4541-404d-abfd-67994e55a823
# ╟─d58867bb-ba19-4abe-8f37-13bbec5bbb7e
# ╟─52dd9fb8-c692-414d-81a8-ef9c9489eb77
# ╟─e7fb28d9-e4dc-46e1-9220-25e0a07a54dc
# ╟─10e33689-61c6-474e-9d82-fa342f105425
# ╟─9030fb68-2ed1-4091-a911-a89fe0a0ed52
# ╟─8abb5ea3-745a-42cf-9056-4ed0902989dc
# ╟─ffa17295-5587-40a9-8433-aade6069aa26
# ╟─352cfd84-01f3-408a-a01e-0ccde2556d71
# ╟─d0197886-a129-4812-a7fd-020f9df476cd
# ╠═24dd9c5b-c5e6-48f8-867a-9450ff77466c
# ╟─1d5bed22-e79a-4ae4-b70f-0f804baab527
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
