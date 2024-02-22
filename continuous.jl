### A Pluto.jl notebook ###
# v0.19.38

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
	using StatsPlots, PlotThemes
	theme(:wong)
end

# ╔═╡ 813f7d1a-5bf1-44bc-bfb0-90df8679aac6
using HypothesisTests

# ╔═╡ 3929273b-4572-486e-93d0-a84cdab67391
begin
	import GLM.@formula
	include("pubh.jl")
	@rimport readr
	@rimport pubh
end

# ╔═╡ 2a9b0e48-2da3-11ee-21f3-c3e92488a854
md"""
# Continuous Outcomes

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform, **AgRresearch Ltd**
	- 9 February 2024
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

# ╔═╡ e1b14054-3676-46fc-87ff-2db88a1e0576
qq_plot(
	bernard.temp0, ylab="Baseline Temperature (°C)"
)

# ╔═╡ b9232d76-707e-486f-bc61-f1fbe4c835da
md"Let’s assume normality and estimate the 95% CI around the mean baseline temperature for all patients."

# ╔═╡ 68e29f99-cf15-44fa-b977-f246aa343ed6
 bernard.temp0 |> cis

# ╔═╡ 8ce5ef9b-7a5f-4b4f-991c-a15e1ab49dad
md"What about the 95% CI around the mean temperature after 36 hr of treatment?"

# ╔═╡ 32616602-1282-4f82-a33e-f731564c3a37
@subset(bernard, !ismissing(:temp10)).temp10 |> cis

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
qq_plot(
	bern.temp_change, ylab="Temperature Change (°C)"
)
```
""" |> hint

# ╔═╡ c7dd80c5-063c-4bbc-857d-118268737df6
qq_plot(
	bern.temp_change, ylab="Temperature Change (°C)"
)

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
strip_error(
	energy, :stature, :expend,
	xlab="Stature",
	ylab="Energy expenditure (MJ)"
)
```
""" |> hint

# ╔═╡ 2e1cb31a-34c9-4e36-9697-c0350ba067cb
strip_error(
	energy, :stature, :expend,
	xlab="Stature",
	ylab="Energy expenditure (MJ)"
)

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

# ╔═╡ f4afbecf-e13f-4dad-afe6-50660cf7a3d0
let
	ctl = @subset(hodgkin, :Group=="Non-Hodgkin")
	tx = @subset(hodgkin, :Group=="Hodgkin")
	
	p1 = qq_plot(
		ctl.ratio,
		ylab="CD4⁺ / CD8⁺", title="Non-Hodgkin"
	)

	p2 = qq_plot(
		tx.ratio,
		ylab="", title="Hodgkin"
	)

	plot(p1,p2)
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

# ╔═╡ f723f7f5-9477-4b71-8327-7eb264f103cb
summarize_by(smokew, :smoking, :bweight)

# ╔═╡ 072b0791-daac-4eb5-ac51-5bc74b45973c
md"Given the number of observations per group, we use a strip chart to compare the four groups graphically."

# ╔═╡ 1424910e-ee12-417e-91db-f9310f93af39
strip_error(
	smokew, :smoking, :bweight,
	xlab="Smoking status", ylab="Birth weight (kg)"
)

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

# ╔═╡ b5506649-ed02-4623-80a7-1f078d971123
resid_plot(smoke_perf)

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

# ╔═╡ 8bfe2d94-6d71-4b25-a0a7-fa3ae4fbbb47
@df smoke_eff scatter(
	:smoking, :bweight,
	ylabel="Birth weight (kg)",
	yerr=:err, leg=false, 
	xrot=20, ylim=(2.5, 4)
)

# ╔═╡ e58d3dba-f513-4a8f-8a9b-c13f56cdb452
md"""
!!! tip

	We can rotate the labels of the ticks with `xrotation` or `xrot` (even `xr`) and the degrees.
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

# ╔═╡ 9879f454-6514-40ad-814d-f96af76e8e88
qq_plot(air.log_oz, ylab="log (Ozone)")

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
resid_plot(air_perf)

# ╔═╡ 9d9248b5-b2f6-4fd6-be80-e5dabdd469bf
md"Variance:"

# ╔═╡ d96205ef-ed6a-43ee-8e0f-12a2777d7f73
let
	@df air_perf scatter(
		:predicted, :std_error,
		xlabel="Fitted values",
    	ylabel="Std Residuals",
		leg=false, msize=2, mc=:midnightblue
	)
	hline!([-2, 2], linestyle=:dash)
end

# ╔═╡ 365a49c0-a700-407d-8006-0b541612cb8d
air_des = Dict(:Month => unique(air.Month));

# ╔═╡ 33b647a8-ab99-4716-8738-131baff5ce4c
air_eff = effects(air_des, model_air, invlink=exp)

# ╔═╡ 2b876adb-7beb-4c8f-82f2-ef5b6d4cd868
@df air_eff scatter(
	:Month, :log_oz,
	ylabel="log (Ozone)",
	yerr=:err, leg=false
)

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
strip_error(
	fent, :group, :pain,
	xlab="Cohort", ylab="Pain reduction"
)
```
""" |> hint

# ╔═╡ c62c76fe-f7fd-44ad-9ccb-91c66c63cfae
strip_error(
	fent, :group, :pain,
	xlab="Cohort", ylab="Pain reduction"
)

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AnovaGLM = "0a47a8e3-ec57-451e-bddb-e0be9d22772b"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Effects = "8f03c58b-bd97-4933-a826-f71b64d2cca2"
GLM = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
HypothesisTests = "09f84164-cd44-5f33-b23f-e6b0d136a0d5"
MLJ = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
MultipleTesting = "f8716d33-7c4a-5097-896f-ce0ecbd3ef6b"
PlotThemes = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"
TexTables = "ebf5ac4f-3ec1-555f-9ac9-3d72ed88c471"

[compat]
AnovaGLM = "~0.2.3"
CategoricalArrays = "~0.10.8"
DataFrameMacros = "~0.4.1"
DataFrames = "~1.6.1"
Distributions = "~0.25.107"
Effects = "~1.1.1"
GLM = "~1.9.0"
HypothesisTests = "~0.11.0"
MLJ = "~0.20.2"
MultipleTesting = "~0.6.0"
PlotThemes = "~3.1.0"
PlutoUI = "~0.7.55"
RCall = "~0.14.1"
StatsBase = "~0.34.2"
StatsPlots = "~0.15.6"
TexTables = "~0.2.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.1"
manifest_format = "2.0"
project_hash = "0b9596cbf72dc551cf6dc3193bea001a2961f471"

[[deps.ARFFFiles]]
deps = ["CategoricalArrays", "Dates", "Parsers", "Tables"]
git-tree-sha1 = "e8c8e0a2be6eb4f56b1672e46004463033daa409"
uuid = "da404889-ca92-49ff-9e8b-0aa6b4d38dc8"
version = "1.4.1"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "c278dfab760520b8bb7e9511b968bf4ba38b7acc"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.3"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Test"]
git-tree-sha1 = "cb96992f1bec110ad211b7e410e57ddf7944c16f"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.35"

    [deps.Accessors.extensions]
    AccessorsAxisKeysExt = "AxisKeys"
    AccessorsIntervalSetsExt = "IntervalSets"
    AccessorsStaticArraysExt = "StaticArrays"
    AccessorsStructArraysExt = "StructArrays"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cde29ddf7e5726c9fb511f340244ea3481267608"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AnovaBase]]
deps = ["Distributions", "Printf", "Reexport", "Statistics", "StatsBase", "StatsModels"]
git-tree-sha1 = "b0695c88a131d066c3b7b76a01c6fcba70d4c738"
uuid = "946dddda-6a23-4b48-8e70-8e60d9b8d680"
version = "0.7.5"

[[deps.AnovaGLM]]
deps = ["AnovaBase", "Distributions", "GLM", "LinearAlgebra", "Printf", "Reexport", "Statistics", "StatsBase", "StatsModels"]
git-tree-sha1 = "a7f1af40966d9fd108761af5781e7b597396abc8"
uuid = "0a47a8e3-ec57-451e-bddb-e0be9d22772b"
version = "0.2.3"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra", "Logging"]
git-tree-sha1 = "9b9b347613394885fd1c8c7729bfc60528faa436"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.5.4"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "7aa7ad1682f3d5754e3491bb59b8103cae28e3a3"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.40"

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
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9e2a6b69137e6969bab0152632dcb3bc108c8bdd"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+1"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

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

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.CategoricalDistributions]]
deps = ["CategoricalArrays", "Distributions", "Missings", "OrderedCollections", "Random", "ScientificTypes"]
git-tree-sha1 = "6d4569d555704cdf91b3417c0667769a4a7cbaa2"
uuid = "af321ab8-2d2e-40a6-b165-3d674595d28e"
version = "0.1.14"

    [deps.CategoricalDistributions.extensions]
    UnivariateFiniteDisplayExt = "UnicodePlots"

    [deps.CategoricalDistributions.weakdeps]
    UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "1287e3872d646eed95198457873249bd9f0caed2"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.20.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "9ebb045901e9bbf58767a9f34ff89831ed711aae"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.15.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

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
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "75bd5b6fc5089df449b5d35fa501c846c9b6549b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.12.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "51cab8e982c5b598eea9c8ceaced4b58d9dd37c9"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.10.0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

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
git-tree-sha1 = "ac67408d9ddf207de5cfa9a97e114352430f01ed"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.16"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

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
git-tree-sha1 = "66c4c81f259586e8f002eacebc177e1fb06363b0"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.11"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "7c302d7a5fec5214eb8a5a4c466dcf7a51fcf169"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.107"

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

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarlyStopping]]
deps = ["Dates", "Statistics"]
git-tree-sha1 = "98fdf08b707aaf69f524a6cd0a67858cefe0cfb6"
uuid = "792122b4-ca99-40de-a6bc-6742525f08b6"
version = "0.3.0"

[[deps.Effects]]
deps = ["Combinatorics", "DataFrames", "Distributions", "ForwardDiff", "LinearAlgebra", "Statistics", "StatsAPI", "StatsBase", "StatsModels", "Tables"]
git-tree-sha1 = "457765ab020f6f1d9566ce063355374c7f84ed1a"
uuid = "8f03c58b-bd97-4933-a826-f71b64d2cca2"
version = "1.1.1"

    [deps.Effects.extensions]
    EffectsGLMExt = "GLM"
    EffectsMixedModelsExt = ["GLM", "MixedModels"]

    [deps.Effects.weakdeps]
    GLM = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
    MixedModels = "ff71e718-51f3-5ec2-a782-8ffcbfa3c316"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "4820348781ae578893311153d69049a93d05f39d"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.0"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "5b93957f6dcd33fc343044af3d48c215be2562f1"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.9.3"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

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
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "ff38ba61beff76b8f4acad8ab0c97ef73bb670cb"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.9+0"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "273bd1cd30768a2fddfa3fd63bbc746ed7249e5f"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.9.0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "3458564589be207fa6a77dbbf8b97674c9836aab"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "77f81da2964cc9fa7c0127f941e8bce37f7f1d70"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.2+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "e94c92c7bf4819685eb80186d51c43e71d4afa17"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.76.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "abbbb9ec3afd783a7cbd82ef01dcd088ea051398"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.1"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.HypothesisTests]]
deps = ["Combinatorics", "Distributions", "LinearAlgebra", "Printf", "Random", "Rmath", "Roots", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "4b5d5ba51f5f473737ed9de6d8a7aa190ad8c72f"
uuid = "09f84164-cd44-5f33-b23f-e6b0d136a0d5"
version = "0.11.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5fdf2fe6724d8caabf43b557b84ce53f3b7e2f6b"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.0.2+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "68772f49f54b479fa88ace904f6127f0a3bb2e46"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.12"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterationControl]]
deps = ["EarlyStopping", "InteractiveUtils"]
git-tree-sha1 = "e663925ebc3d93c1150a7570d114f9ea2f664726"
uuid = "b3c1a2ee-3fec-4384-bf48-272ea71de57c"
version = "0.5.4"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "a53ebe394b71470c7f97c2e7e170d51df21b17af"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.7"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "60b1194df0a3298f460063de985eae7b01bc011a"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.1+0"

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "LinearAlgebra", "MacroTools", "PrecompileTools", "Requires", "SparseArrays", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "4e0cb2f5aad44dcfdc91088e85dee4ecb22c791c"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.16"

    [deps.KernelAbstractions.extensions]
    EnzymeExt = "EnzymeCore"

    [deps.KernelAbstractions.weakdeps]
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "fee018a29b60733876eb557804b5b109dd3dd8a7"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.8"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Preferences", "Printf", "Requires", "Unicode"]
git-tree-sha1 = "cb4619f7353fc62a1a22ffa3d7ed9791cfb47ad8"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "6.4.2"

    [deps.LLVM.extensions]
    BFloat16sExt = "BFloat16s"

    [deps.LLVM.weakdeps]
    BFloat16s = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "98eaee04d96d973e79c25d49167668c5c8fb50e2"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.27+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d986ce2d884d49126836ea94ed5bfb0f12679713"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LatinHypercubeSampling]]
deps = ["Random", "StableRNGs", "StatsBase", "Test"]
git-tree-sha1 = "825289d43c753c7f1bf9bed334c253e9913997f8"
uuid = "a5e1c1ea-c99a-51d3-a14d-a9a37257b02d"
version = "1.9.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

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

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

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
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "72dc3cf284559eb8f53aa593fe62cb33f83ed0c0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.0.0+0"

[[deps.MLFlowClient]]
deps = ["Dates", "FilePathsBase", "HTTP", "JSON", "ShowCases", "URIs", "UUIDs"]
git-tree-sha1 = "ea8a8dea5d252489d930763e5d6af4795930e0e2"
uuid = "64a0f543-368b-4a9a-827a-e71edb2a0b83"
version = "0.4.5"

[[deps.MLJ]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "LinearAlgebra", "MLJBalancing", "MLJBase", "MLJEnsembles", "MLJFlow", "MLJIteration", "MLJModels", "MLJTuning", "OpenML", "Pkg", "ProgressMeter", "Random", "Reexport", "ScientificTypes", "StatisticalMeasures", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "981196c41a23cbc1befbad190558b1f0ebb97910"
uuid = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
version = "0.20.2"

[[deps.MLJBalancing]]
deps = ["MLJBase", "MLJModelInterface", "MLUtils", "OrderedCollections", "Random", "StatsBase"]
git-tree-sha1 = "f02e28f9f3c54a138db12a97a5d823e5e572c2d6"
uuid = "45f359ea-796d-4f51-95a5-deb1a414c586"
version = "0.1.4"

[[deps.MLJBase]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LearnAPI", "LinearAlgebra", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "RecipesBase", "Reexport", "ScientificTypes", "Serialization", "StatisticalMeasuresBase", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "4927a192f5b5156f3952f3f0dbbb4b207eef0836"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "1.1.1"
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
git-tree-sha1 = "89d0e7a7e08359476482f20b2d8ff12080d171ee"
uuid = "7b7b8358-b45c-48ea-a8ef-7ca328ad328f"
version = "0.3.0"

[[deps.MLJIteration]]
deps = ["IterationControl", "MLJBase", "Random", "Serialization"]
git-tree-sha1 = "991e10d4c8da49d534e312e8a4fbe56b7ac6f70c"
uuid = "614be32b-d00c-4edb-bd02-1eb411ab5e55"
version = "0.6.0"

[[deps.MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "14bd8088cf7cd1676aa83a57004f8d23d43cd81e"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.9.5"

[[deps.MLJModels]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Combinatorics", "Dates", "Distances", "Distributions", "InteractiveUtils", "LinearAlgebra", "MLJModelInterface", "Markdown", "OrderedCollections", "Parameters", "Pkg", "PrettyPrinting", "REPL", "Random", "RelocatableFolders", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "6868ebd0963fd3d6bfd6d5389dddd0219070120e"
uuid = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
version = "0.16.15"

[[deps.MLJTuning]]
deps = ["ComputationalResources", "Distributed", "Distributions", "LatinHypercubeSampling", "MLJBase", "ProgressMeter", "Random", "RecipesBase", "StatisticalMeasuresBase"]
git-tree-sha1 = "8d435794dbfba25509f6b32ab5e55779db1bfda2"
uuid = "03970b2e-30c4-11ea-3135-d1576263f10f"
version = "0.8.1"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MLUtils]]
deps = ["ChainRulesCore", "Compat", "DataAPI", "DelimitedFiles", "FLoops", "NNlib", "Random", "ShowCases", "SimpleTraits", "Statistics", "StatsBase", "Tables", "Transducers"]
git-tree-sha1 = "b45738c2e3d0d402dffa32b2c1654759a2ac35a4"
uuid = "f1d291b0-491e-4a28-83b9-f70985020b54"
version = "0.4.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

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

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.MultipleTesting]]
deps = ["Distributions", "SpecialFunctions", "StatsBase"]
git-tree-sha1 = "1e98f8f732e7035c4333135b75605b74f3462b9b"
uuid = "f8716d33-7c4a-5097-896f-ce0ecbd3ef6b"
version = "0.6.0"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "68bf5103e002c44adfd71fea6bd770b3f0586843"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.10.2"

[[deps.NNlib]]
deps = ["Adapt", "Atomix", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "LinearAlgebra", "Pkg", "Random", "Requires", "Statistics"]
git-tree-sha1 = "d2811b435d2f571bdfdfa644bb806a66b458e186"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.9.11"

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

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "ded64ff6d4fdd1cb68dfcbb818c69e144a5b2e4c"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.16"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "6a731f2b5c03157418a20c12195eb4b74c8f8621"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.13.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

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
git-tree-sha1 = "60e3045590bd104a16fefb12836c00c0ef8c7f8c"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.13+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "862942baf5663da528f66d24996eb6da85218e76"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.0"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "38a748946dca52a622e79eea6ed35c6737499109"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.0"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "68723afdb616445c6caaef6255067a8339f91325"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.55"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.PrettyPrinting]]
git-tree-sha1 = "22a601b04a154ca38867b991d5017469dc75f2db"
uuid = "54e16d92-306c-5ea0-a30b-337be88ac337"
version = "0.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "00099623ffee15972c16111bcf84c58a0051257c"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.9.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "37b7bb7aabf9a085e0044307e1717436117f2b3b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9b23c31e76e333e6fb4c1595ae6afa74966a729e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.4"

[[deps.RCall]]
deps = ["CategoricalArrays", "Conda", "DataFrames", "DataStructures", "Dates", "Libdl", "Missings", "Preferences", "REPL", "Random", "Requires", "StatsModels", "WinReg"]
git-tree-sha1 = "846b2aab2d312fda5e7b099fc217c661e8fae27e"
uuid = "6f49c342-dc21-5d91-9882-a32aef131414"
version = "0.14.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

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

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

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
deps = ["Accessors", "ChainRulesCore", "CommonSolve", "Printf"]
git-tree-sha1 = "39ebae5b76c8cd5629bec21adfca78b437dac1e6"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.1.1"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

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
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

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

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "ddc1a7b85e760b5285b50b882fa91e40c603be47"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "7b0e9c14c624e435076d19aea1e5cbdec2b9ca37"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.2"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.StatisticalMeasures]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Distributions", "LearnAPI", "LinearAlgebra", "MacroTools", "OrderedCollections", "PrecompileTools", "ScientificTypesBase", "StatisticalMeasuresBase", "Statistics", "StatsBase"]
git-tree-sha1 = "b9a868f0f8d033efe8e5b50603ce0cf28b398c65"
uuid = "a19d573c-0a75-4610-95b3-7071388c7541"
version = "0.1.4"

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
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsAPI", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "5cf6c4583533ee38639f73b880f35fc85f2941e0"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.7.3"

[[deps.StatsPlots]]
deps = ["AbstractFFTs", "Clustering", "DataStructures", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "NaNMath", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "9115a29e6c2cf66cf213ccc17ffd61e27e743b24"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.15.6"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

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

[[deps.TranscodingStreams]]
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "3064e780dbb8a9296ebb3af8f440f787bb5332af"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.80"

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
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

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

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "3c793be6df9dd77a0cf49d80984ef9ff996948fa"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.19.0"
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "323e3d0acf5e78a56dfae7bd8928c989b4f3083e"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.1.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.WinReg]]
git-tree-sha1 = "cd910906b099402bcc50b3eafa9634244e5ec83b"
uuid = "1b915085-20d7-51cf-bf83-8f477d6f5128"
version = "1.0.0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "5f24e158cf4cee437052371455fe361f526da062"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.6"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "801cbe47eae69adc50f36c3caec4758d2650741b"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.2+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522b8414d40c4cbbab8dee346ac3a09f9768f25d"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.5+0"

[[deps.Xorg_libICE_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5becd4411063bdcac16be8b66fc2f9f6f1e8fe5"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.0.10+1"

[[deps.Xorg_libSM_jll]]
deps = ["Libdl", "Pkg", "Xorg_libICE_jll"]
git-tree-sha1 = "4a9d9e4c180e1e8119b5ffc224a7b59d3a7f7e18"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.3+0"

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

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

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

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

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

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a68c9655fbe6dfcab3d972808f1aafec151ce3f8"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.43.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

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
version = "5.8.0+1"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "93284c28274d9e75218a416c65ec49d0e0fcdf3d"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.40+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

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

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
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
# ╠═e1b14054-3676-46fc-87ff-2db88a1e0576
# ╟─b9232d76-707e-486f-bc61-f1fbe4c835da
# ╠═68e29f99-cf15-44fa-b977-f246aa343ed6
# ╟─8ce5ef9b-7a5f-4b4f-991c-a15e1ab49dad
# ╠═32616602-1282-4f82-a33e-f731564c3a37
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
# ╟─c7dd80c5-063c-4bbc-857d-118268737df6
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
# ╟─2e1cb31a-34c9-4e36-9697-c0350ba067cb
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
# ╠═f4afbecf-e13f-4dad-afe6-50660cf7a3d0
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
# ╠═1424910e-ee12-417e-91db-f9310f93af39
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
# ╠═b5506649-ed02-4623-80a7-1f078d971123
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
# ╠═8bfe2d94-6d71-4b25-a0a7-fa3ae4fbbb47
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
# ╠═9879f454-6514-40ad-814d-f96af76e8e88
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
# ╠═d96205ef-ed6a-43ee-8e0f-12a2777d7f73
# ╠═365a49c0-a700-407d-8006-0b541612cb8d
# ╠═33b647a8-ab99-4716-8738-131baff5ce4c
# ╠═2b876adb-7beb-4c8f-82f2-ef5b6d4cd868
# ╟─ad96607f-6702-4348-a7fe-f332b9c9b2a7
# ╟─d8b13182-78c0-4506-9996-2023a997a12f
# ╠═ce7a2511-4541-404d-abfd-67994e55a823
# ╟─d58867bb-ba19-4abe-8f37-13bbec5bbb7e
# ╟─52dd9fb8-c692-414d-81a8-ef9c9489eb77
# ╟─e7fb28d9-e4dc-46e1-9220-25e0a07a54dc
# ╟─10e33689-61c6-474e-9d82-fa342f105425
# ╟─9030fb68-2ed1-4091-a911-a89fe0a0ed52
# ╟─c62c76fe-f7fd-44ad-9ccb-91c66c63cfae
# ╟─ffa17295-5587-40a9-8433-aade6069aa26
# ╟─352cfd84-01f3-408a-a01e-0ccde2556d71
# ╟─d0197886-a129-4812-a7fd-020f9df476cd
# ╠═24dd9c5b-c5e6-48f8-867a-9450ff77466c
# ╟─1d5bed22-e79a-4ae4-b70f-0f804baab527
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
