### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 5cee562c-f108-49d3-bece-d62d37c19879
using PlutoUI; PlutoUI.TableOfContents(aside=true, title="📚 Contents")

# ╔═╡ 45a17582-72ed-4b60-9ab7-0e3caf91e2c8
begin
	using StatsBase, DataFrames, DataFrameMacros, MLJ
	using RCall, TexTables, CategoricalArrays, Distributions
	using AnovaGLM, Effects, MultipleTesting
	using MLJ: schema
end

# ╔═╡ 36e844c2-a33e-454f-bf6e-995c660dfb94
begin
	using AlgebraOfGraphics, CairoMakie
	CairoMakie.activate!(type = "svg")
	AoG = AlgebraOfGraphics; data = AoG.data
end;

# ╔═╡ 813f7d1a-5bf1-44bc-bfb0-90df8679aac6
using HypothesisTests

# ╔═╡ 3929273b-4572-486e-93d0-a84cdab67391
begin
	include("pubh.jl")
	@rimport readr
	@rimport pubh
	import GLM.@formula
end

# ╔═╡ 2a9b0e48-2da3-11ee-21f3-c3e92488a854
md"""
# Continuous Outcomes

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform, **AgRresearch Ltd**
	- 23 January 2024
"""

# ╔═╡ 953e1df5-0f62-4832-b7c0-47c216ac95a5
md"""
## [📖 Main Menu](index.html)
"""

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

# ╔═╡ 48cedb36-34e2-44d7-b89a-db5dc4ef4f34
qq_plot(bernard.temp0, ylab = "Baseline Temperature (°C)")

# ╔═╡ b9232d76-707e-486f-bc61-f1fbe4c835da
md"Let’s assume normality and estimate the 95% CI around the mean baseline temperature for all patients."

# ╔═╡ 68e29f99-cf15-44fa-b977-f246aa343ed6
r3.(ci_mean(bernard.temp0))

# ╔═╡ 8ce5ef9b-7a5f-4b4f-991c-a15e1ab49dad
md"What about the 95% CI around the mean temperature after 36 hr of treatment?"

# ╔═╡ aa8bb4b0-5c26-4d5f-858d-c00e234cd162
r3.(ci_mean(@subset(bernard, !ismissing(:temp10)).temp10))

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
!!! important

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

# ╔═╡ b3d44284-5f16-419f-9cda-07a0d9abfa45
placebo = @select(
	@subset(bernard, :treat == "Placebo"),
	:temp0, :temp10
);

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
	bern = @select(bernard, :temp0, :temp10, :treat)
	@transform!(bern, :temp_change = :temp10 - :temp0)
	dropmissing!(bern)
	bern |> head
end

# ╔═╡ 6d2a66ef-4c57-43b4-979c-ab510b3bac7c
md"""
One of the assumptions is that the distribution of `temp_change` is normal for each group. The another big assumption is that the variance is the same. To compare variances, we perform a variance test. The null hypothesis is that the ratio of the two variances is equal to one (same variance) and the alternative is that is different from one. A *p* ≤ 0.05 means that there is no statistical difference between the two variances and, therefore, that the assumption of homogeneity of variances holds.

First, we perform a standard descriptive analysis on `temp_change`.
"""

# ╔═╡ 0a49603f-d9b9-47dd-82ec-7a23c9e25c93
summarize_by(bern, :treat, :temp_change)

# ╔═╡ 46246b07-f620-4683-aa9c-59082cdd246a
pubh.estat(@formula(temp_change ~ treat), data=bern) |> rcopy

# ╔═╡ 80245239-d03a-46b6-9543-ce0efed87a7f
md"""
!!! warning \"Exercise\"

	Construct a QQ-plot of `temp_change` from subjects by treatment group, against the standard normal distribution to check for the normality assumption.
"""

# ╔═╡ 58f87d23-7dcc-403d-8c6e-ffe4b5dfdf40
md"""
```julia
qq_plot(bern.temp_change, ylab = "Temperature Change (°C)")
```
""" |> hint

# ╔═╡ 214c37a4-5320-458d-89d1-6636ffacc6c5
qq_plot(bern.temp_change, ylab = "Temperature Change (°C)")

# ╔═╡ ff6846f9-3398-47db-9fff-ad3d2f951990
md"We perform a variance test with `VarianceFTest`."

# ╔═╡ d631b4b5-790d-4f96-b1bb-e9f4574d3d3a
VarianceFTest(
  	@subset(bern, :treat.=="Ibuprofen").temp_change,
  	@subset(bern, :treat.=="Placebo").temp_change
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
!!! warning \"Exercise\"

	Calculate descriptive statistics for variable `expend` by `stature` from the `energy` dataset.
"""

# ╔═╡ 19b6a4f8-313c-4484-ba53-2be2e8246011
md"""
```julia
summarize_by(energy, :stature, :expend)
```
""" |> hint

# ╔═╡ f30fe277-55f8-4ce4-a379-c14028221ed6
summarize_by(energy, :stature, :expend)

# ╔═╡ 30709ba4-bd51-4a54-b00a-083b53263373
pubh.estat(@formula(expend~stature), data=energy) |> rcopy

# ╔═╡ ddad013c-f146-451d-b4bb-d7c468154cdf
md"""
!!! tip \"Question\"

	What are your general observations from the descriptive analysis?
"""

# ╔═╡ d0404fcd-6b09-4910-a40e-2534b1388505
md"""
On average, obese women have more energy expenditure than lean woman, but we do not know if that difference is significant.
""" |> hint

# ╔═╡ 30d44015-5bde-4549-a31c-7dd2774e22fe
md"Given that our samples are relatively small (less than 30 observations per group), the best way to graphically compare distributions is by strip charts."

# ╔═╡ 99f33bab-5ccd-459d-a5a3-7b75554e7074
md"""
!!! warning \"Exercise\"

	Construct a strip chart comparing the energy expenditure by stature.
"""

# ╔═╡ 36e12d56-d432-427a-a37c-164e27c32660
md"""
```julia
let
	energy_bst = pubh.gen_bst_df(@formula(expend ~ stature), data=energy) |> rcopy

	data(energy) *
	mapping(
		:stature => "Stature", 
    	:expend => "Energy expenditure (MJ)",
		color = :stature
	) *
	visual(
		RainClouds, clouds=violin, 
		plot_boxplots=false, markersize=7
	) |>
	draw
end
```
""" |> hint

# ╔═╡ 80d79cca-5aca-406b-ae80-b12842f4d191
energy_bst = pubh.gen_bst_df(@formula(expend ~ stature), data=energy) |> rcopy

# ╔═╡ b2796fec-f19d-4403-b9c1-808540cf0415
data(energy) *
mapping(
	:stature => "Stature", 
    :expend => "Energy expenditure (MJ)",
	color = :stature
) *
visual(
	RainClouds, clouds=violin, 
	plot_boxplots=false, markersize=7
) |>
draw

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
@transform!(
  hodgkin,
  :ratio = :CD4 / :CD8
);
```
""" |> hint

# ╔═╡ d2f46f92-838f-4c75-9a49-b57d73f76b9d
@transform!(
  hodgkin,
  :ratio = :CD4 / :CD8
);

# ╔═╡ 66a2377d-83d7-44b2-8955-50a82b150d41
md"""
!!! warning \"Exercise\"

	Generate a table with descriptive statistics for `ratio`, stratified by `Group`.
"""

# ╔═╡ 3c52c5b3-d397-48f9-8520-54aeadc30817
md"""
```julia
summarize_by(hodgkin, :Group, :ratio)
```
""" |> hint

# ╔═╡ 6f1532f9-c624-4b5a-8a93-554e2134b37c
summarize_by(hodgkin, :Group, :ratio)

# ╔═╡ d179dfdb-455c-4afe-bdde-a5b9eb314ccb
md"Let's take a look the distributions of the ratios:"

# ╔═╡ bee3e9ee-0463-48c0-ba6d-1635ca42d1b2
data(hodgkin) *
mapping(
	:ratio,
	color = :Group
) *
visual(QQNorm, qqline=:fitrobust, markersize=8, color=:indianred) |>
draw

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

# ╔═╡ f723f7f5-9477-4b71-8327-7eb264f103cb
summarize_by(smokew, :smoking, :bweight)

# ╔═╡ 072b0791-daac-4eb5-ac51-5bc74b45973c
md"Given the number of observations per group, we use a strip chart to compare the four groups graphically."

# ╔═╡ c9f19d78-0736-46bd-bbc9-a71e049ef8d3
data(smokew) *
mapping(
	:smoking => "Smoking status",
	:bweight => "Birth weight (kg)",
	color = :smoking => ""
) *
visual(
	RainClouds, clouds=violin,
	plot_boxplots=false, markersize=7
) |> draw

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

# ╔═╡ 3ec2a82d-d5db-4943-8b5d-f9bc53accbbd
qq_plot(smoke_perf.error, ylab = "Residuals")

# ╔═╡ ccb32055-42e6-4b44-9ec0-c12a1db54c9f
md"Variance."

# ╔═╡ a3e3413d-dc87-41a3-a9ff-ce87bf7c47a3
rvf_plot(smoke_perf)

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
model_des = Dict(:smoking => levels(smokew.smoking));

# ╔═╡ d0f135af-322e-4242-9f86-37d7ddf703cb
smoke_eff = effects(model_des, model_eff)

# ╔═╡ a7a2780c-f04b-4632-b3ca-d5c6339d171b
md"We can use the estimated effects to get a nice visualisation of the data:"

# ╔═╡ fb39471a-fe04-4826-9656-f5e1add558c0
data(smoke_eff) *
mapping(
	:smoking => sorter(levels(smokew.smoking)) => "Smoking status",
	:bweight => "Birth weight (kg)"
) *
(visual(Scatter) + mapping(:err) * visual(Errorbars)) |>
draw

# ╔═╡ e58d3dba-f513-4a8f-8a9b-c13f56cdb452
md"""
!!! tip

	To display the levels of smoking in the right order, we used `sorter`. Notice that the function was applied on the orginal data set, `smokew`, which is the one that has the right order.
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
summarize_by(air, :Month, :Ozone)
```
""" |> hint

# ╔═╡ 36a963d5-b437-4682-a6d6-4fe68d0099d7
summarize_by(air, :Month, :Ozone)

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

# ╔═╡ d4eb87e6-932c-4b71-a086-8777a1d71150
@transform!(air, :log_oz = log.(:Ozone));

# ╔═╡ c5a53a29-1b9a-4dbb-a58a-61dc367b023e
data(air) *
mapping(:log_oz, layout = :Month) *
visual(QQNorm, qqline=:fitrobust, markersize=5, color=:indianred) |>
draw

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

# ╔═╡ 7b1b4aa9-c23b-448c-b2f3-fd6cbf604b5a
qq_plot(air_perf.error, ylab="Residuals")

# ╔═╡ 9d9248b5-b2f6-4fd6-be80-e5dabdd469bf
md"Variance:"

# ╔═╡ bda61c30-e782-42a3-8971-13dbbd1e331c
rvf_plot(air_perf)

# ╔═╡ 365a49c0-a700-407d-8006-0b541612cb8d
air_des = Dict(:Month => unique(air.Month));

# ╔═╡ 33b647a8-ab99-4716-8738-131baff5ce4c
air_eff = effects(air_des, model_air, invlink=exp)

# ╔═╡ 0ca79744-f2bd-4c4c-b193-ad3fff9884f7
data(air_eff) *
mapping(
	:Month => sorter(levels(air.Month)),
	:log_oz => "log (Ozone)"
) *
(visual(Scatter) + mapping(:err) * visual(Errorbars)) |>
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
summarize_by(fent, :group, :pain)
```
""" |> hint

# ╔═╡ e7fb28d9-e4dc-46e1-9220-25e0a07a54dc
summarize_by(fent, :group, :pain)

# ╔═╡ 10e33689-61c6-474e-9d82-fa342f105425
md"""
!!! warning \"Exercise\"

	Compare the mucociliary efficiency between groups with a rain cloud plot.
"""

# ╔═╡ 9030fb68-2ed1-4091-a911-a89fe0a0ed52
md"""
```julia
data(fent) *
mapping(
	:group => "Cohort",
	:pain => "Pain reduction",
	color = :group => ""
) *
visual(
	RainClouds, clouds=violin, 
	plot_boxplots=false, markersize=7
) |>
draw
```
""" |> hint

# ╔═╡ 906da5c0-ee31-4618-b29a-1c031802b8f7
data(fent) *
mapping(
	:group => "Cohort",
	:pain => "Pain reduction",
	color = :group => ""
) *
visual(
	RainClouds, clouds=violin, 
	plot_boxplots=false, markersize=7
) |>
draw

# ╔═╡ ffa17295-5587-40a9-8433-aade6069aa26
md"""
!!! tip \"Question\"

	What is your main concern regarding your descriptive analysis?
"""

# ╔═╡ 352cfd84-01f3-408a-a01e-0ccde2556d71
md"""
Dispersion of pain reduction is greater in the Untreated group than in the other two groups. The sample size is relatively small for the control limit theorem to compensate.
""" |> hint

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

# ╔═╡ Cell order:
# ╟─2a9b0e48-2da3-11ee-21f3-c3e92488a854
# ╟─953e1df5-0f62-4832-b7c0-47c216ac95a5
# ╠═5cee562c-f108-49d3-bece-d62d37c19879
# ╠═45a17582-72ed-4b60-9ab7-0e3caf91e2c8
# ╠═36e844c2-a33e-454f-bf6e-995c660dfb94
# ╠═3929273b-4572-486e-93d0-a84cdab67391
# ╟─98a1299b-282f-4a2e-a656-4416d7f61377
# ╟─416cdc5a-917d-4960-9bfc-c36de90c40f0
# ╠═c49f7411-b1b4-4e93-aca1-5bdd539bf26f
# ╟─6f01c3f3-e5ad-493a-b721-fe193e54d7cd
# ╟─befed92f-0930-426c-97a9-c558bccecac3
# ╠═48cedb36-34e2-44d7-b89a-db5dc4ef4f34
# ╟─b9232d76-707e-486f-bc61-f1fbe4c835da
# ╠═68e29f99-cf15-44fa-b977-f246aa343ed6
# ╟─8ce5ef9b-7a5f-4b4f-991c-a15e1ab49dad
# ╠═aa8bb4b0-5c26-4d5f-858d-c00e234cd162
# ╟─abec6086-b66d-45aa-bed1-305b5b5c695f
# ╠═554ed4b0-c91c-4e0f-b7a9-b2a185b4e975
# ╟─2e43817a-82ab-4bab-aade-1b7a64ee32ff
# ╠═813f7d1a-5bf1-44bc-bfb0-90df8679aac6
# ╠═3900cc27-0189-45a1-81e0-fb08bafa4a4f
# ╟─cabb0151-ae7d-4db3-93ee-dc83ff947028
# ╟─c7cf1d8c-bc0e-4032-b935-a9c6ea9298d6
# ╟─20deaef0-8b81-473b-b57a-73699c3481f4
# ╟─beed3a18-0cc6-4a24-9b65-ae58b1329369
# ╠═b3d44284-5f16-419f-9cda-07a0d9abfa45
# ╠═dd31202f-4c60-4aba-a6bb-1e2972830718
# ╠═4226300d-36ca-48dd-bac4-8c2fd457a651
# ╟─5517eee5-38e7-468b-b11f-2cb9c2924441
# ╟─27c36c66-69d1-47f3-b9ee-1c55c69eaab8
# ╠═d54f8e2c-7c1f-44df-89a8-01bfb2711f26
# ╟─6d2a66ef-4c57-43b4-979c-ab510b3bac7c
# ╠═0a49603f-d9b9-47dd-82ec-7a23c9e25c93
# ╠═46246b07-f620-4683-aa9c-59082cdd246a
# ╟─80245239-d03a-46b6-9543-ce0efed87a7f
# ╟─58f87d23-7dcc-403d-8c6e-ffe4b5dfdf40
# ╟─214c37a4-5320-458d-89d1-6636ffacc6c5
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
# ╟─f30fe277-55f8-4ce4-a379-c14028221ed6
# ╠═30709ba4-bd51-4a54-b00a-083b53263373
# ╟─ddad013c-f146-451d-b4bb-d7c468154cdf
# ╟─d0404fcd-6b09-4910-a40e-2534b1388505
# ╟─30d44015-5bde-4549-a31c-7dd2774e22fe
# ╟─99f33bab-5ccd-459d-a5a3-7b75554e7074
# ╟─36e12d56-d432-427a-a37c-164e27c32660
# ╟─80d79cca-5aca-406b-ae80-b12842f4d191
# ╟─b2796fec-f19d-4403-b9c1-808540cf0415
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
# ╟─6f1532f9-c624-4b5a-8a93-554e2134b37c
# ╟─d179dfdb-455c-4afe-bdde-a5b9eb314ccb
# ╠═bee3e9ee-0463-48c0-ba6d-1635ca42d1b2
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
# ╠═f723f7f5-9477-4b71-8327-7eb264f103cb
# ╟─072b0791-daac-4eb5-ac51-5bc74b45973c
# ╠═c9f19d78-0736-46bd-bbc9-a71e049ef8d3
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
# ╠═3ec2a82d-d5db-4943-8b5d-f9bc53accbbd
# ╟─ccb32055-42e6-4b44-9ec0-c12a1db54c9f
# ╠═a3e3413d-dc87-41a3-a9ff-ce87bf7c47a3
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
# ╠═fb39471a-fe04-4826-9656-f5e1add558c0
# ╟─e58d3dba-f513-4a8f-8a9b-c13f56cdb452
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
# ╠═d4eb87e6-932c-4b71-a086-8777a1d71150
# ╠═c5a53a29-1b9a-4dbb-a58a-61dc367b023e
# ╟─6b257908-fbf7-4d9f-b30e-9d1aa6cc80bc
# ╠═bdf576c0-0f68-4014-a27e-014e5da4aea7
# ╟─ab17e2d4-e55b-42da-9843-5f6829202767
# ╠═4ea05476-1a66-4681-bda9-5952274100b9
# ╠═3e45637d-c39a-4bc4-aab8-8796d22931a5
# ╟─b84b4438-0925-4c5a-9d44-50eef5b35d49
# ╠═8139dfb6-88cb-4d4b-b502-18005505fe9d
# ╟─12be6ea0-7a6e-4f4f-9d8e-da5b320709ab
# ╠═7b1b4aa9-c23b-448c-b2f3-fd6cbf604b5a
# ╟─9d9248b5-b2f6-4fd6-be80-e5dabdd469bf
# ╠═bda61c30-e782-42a3-8971-13dbbd1e331c
# ╠═365a49c0-a700-407d-8006-0b541612cb8d
# ╠═33b647a8-ab99-4716-8738-131baff5ce4c
# ╠═0ca79744-f2bd-4c4c-b193-ad3fff9884f7
# ╟─ad96607f-6702-4348-a7fe-f332b9c9b2a7
# ╟─d8b13182-78c0-4506-9996-2023a997a12f
# ╠═ce7a2511-4541-404d-abfd-67994e55a823
# ╟─d58867bb-ba19-4abe-8f37-13bbec5bbb7e
# ╟─52dd9fb8-c692-414d-81a8-ef9c9489eb77
# ╟─e7fb28d9-e4dc-46e1-9220-25e0a07a54dc
# ╟─10e33689-61c6-474e-9d82-fa342f105425
# ╟─9030fb68-2ed1-4091-a911-a89fe0a0ed52
# ╟─906da5c0-ee31-4618-b29a-1c031802b8f7
# ╟─ffa17295-5587-40a9-8433-aade6069aa26
# ╟─352cfd84-01f3-408a-a01e-0ccde2556d71
# ╟─d0197886-a129-4812-a7fd-020f9df476cd
# ╠═24dd9c5b-c5e6-48f8-867a-9450ff77466c
# ╟─1d5bed22-e79a-4ae4-b70f-0f804baab527
