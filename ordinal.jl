### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ cb09c9ac-7509-4fec-afdc-181c85b9af25
using PlutoUI; PlutoUI.TableOfContents(aside=true, title="📚 Contents")

# ╔═╡ 91ca908f-3c2e-4dde-8302-ee262628eb4d
begin
	using StatsBase, DataFrameMacros, TexTables
	using MLJ , RCall, DataFrames, CategoricalArrays , Effects
	using GLM,  MultipleTesting, Econometrics
	import AnovaGLM as aov
	using MLJ: schema
end

# ╔═╡ ee2a485e-6dc1-42ea-81b3-3ab8a63daf16
begin
	using StatsPlots, PlotThemes
	theme(:wong)
end

# ╔═╡ 6521bb29-86dd-467a-a2d6-d2760e66386b
using MixedModels

# ╔═╡ 90a50002-faa6-4e79-8313-3a21b45d3506
begin
	include("pubh.jl")
	@rimport readr
	@rimport pubh
end

# ╔═╡ 899faafa-bd7e-11ee-2df4-69f67c450b7a
md"""
# Extensions to Logistic Regression

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform, **AgResearch Ltd**
	- 6 February 2024
"""

# ╔═╡ d3699318-3792-4a4a-9971-1159688cc96f
md"""
## [📖 Main Menu](index.html)
"""

# ╔═╡ 45dc60a6-19ba-4bff-89c3-495dbd43da5d
# ╠═╡ show_logs = false
R"""
library(pubh)
library(sjlabelled)
""";

# ╔═╡ 52e727ca-73b6-42a5-8c17-02c6c02b8bbd
md"""
# Interactions

We are going to look at a different way to test for interactions, try to think about biological interactions more than on statistical interactions.
"""

# ╔═╡ eaf5de29-ebba-4866-ab8d-758f0e38e168
md"""
!!! tip \"Example\"

	We follow an example from Rothman regarding the effect of oral contraceptives and hypertension on strokes in young women.
"""

# ╔═╡ 9c502a06-5733-4944-84b7-ebcdea6b2cd1
R"""
data(Rothman)

levels(Rothman$stroke) = c("No stroke", "Stroke")
levels(Rothman$ht) = c("No-Hypertension", "Hypertension")
""";

# ╔═╡ 9c1316fa-1fa0-4921-9a1d-8293eaca1ca8
rothman = @rget Rothman; rothman |> head

# ╔═╡ bf4e2f8b-3bc0-40e9-8208-5776d1f016d0
md"""
!!! note \"Exercise\"

	Perform descriptive statistics showing the distribution of stroke by hypertensive status and stratified by oral contraceptives usage.
"""

# ╔═╡ a6cee07c-b5fd-4561-bf4f-def82469c668
md"""
In `R` mode:

``` R
Rothman |>
  select(stroke, ht, oc) |> 
    mutate(
    stroke = relevel(stroke, ref = "Stroke"),
    ht = relevel(ht, ref = "Hypertension"),
    oc = relevel(oc, ref = "User")
  ) |> 
  copy_labels(Rothman) |> 
  tbl_strata(
    strata = oc,
    .tbl_fun = ~ .x |> 
      tbl_summary(by = ht, missing = "no")
  ) |>  
  cosm_sum(bold = TRUE) |> set_font_size(10) |> theme_pubh(2) |> 
  set_align(1, everywhere, "center") |>
  set_right_border(everywhere, 3) |>
  print_screen()
```
""" |> hint

# ╔═╡ 4153f1dd-9ca5-41e2-a964-53d751b84962
R"""
Rothman |>
  select(stroke, ht, oc) |> 
    mutate(
    stroke = relevel(stroke, ref = "Stroke"),
    ht = relevel(ht, ref = "Hypertension"),
    oc = relevel(oc, ref = "User")
  ) |> 
  copy_labels(Rothman) |> 
  tbl_strata(
    strata = oc,
    .tbl_fun = ~ .x |> 
      tbl_summary(by = ht, missing = "no")
  ) |>  
  cosm_sum(bold = TRUE) |> set_font_size(10) |> theme_pubh(2) |> 
  set_align(1, everywhere, "center") |>
  set_right_border(everywhere, 3) |>
  print_screen()
""";

# ╔═╡ af5da8de-da11-49b4-9cfc-a2948ca552b2
md"""
## Mantel-Haenszel approach

We can start with a stratified analysis (Mantel-Haenszel):
"""

# ╔═╡ 9aff1386-2fa3-45c1-9707-0a3db932edfc
pubh.mhor(@formula(stroke ~ ht/oc), data = rothman) |> rcopy

# ╔═╡ 62e1c4eb-99d1-412c-ada1-c37fae4fdaf4
md"""
!!! warning \"Question\"

	What are your conclusions?
"""

# ╔═╡ 018add89-7f01-48f3-b5ee-b9203f250d31
md"""
!!! hint \"Answer\"

	The odds of having thrombotic stroke is 4.52 times more in users of oral contraceptives than in non-users (95% CIs: 2.77, 7.37) adjusted for history of hypertension. The effect of oral contraceptives on having stroke is statistically significant ( $p$ < 0.001) and is not different between women with a history of hypertension and women without history of hypertension ( $p$ = 0.600).
"""

# ╔═╡ 74fa4b23-8f71-4bee-b952-3627959eb5d8
md"""
## Statistical Interactions

From the test of effect modification, we know that the interaction between use of oral contraceptives and history of hypertension was not significant. Let’s compare with the logistic regression approach.
"""

# ╔═╡ d6ebbe22-eb72-4a2d-988d-015b35b834bb
md"""
!!! important

	Remember that for `glm` the outcome has to be an Integer.
"""

# ╔═╡ 4ab77f72-3a5b-44dd-bda8-cbbe40528b96
rothman.stroke_cont = coerce(rothman.stroke, Continuous) .- 1;

# ╔═╡ 92719b31-c40f-4bd6-b4ab-d75693e45aa6
roth_1 = glm(@formula(stroke_cont ~ oc * ht), rothman, Binomial(), LogitLink())

# ╔═╡ fe22b114-7af3-4236-8b59-6ed0d7f3804e
md"""
Corresponding ORs:
"""

# ╔═╡ e9756676-6ade-4483-baad-e790eb98d872
r3.(exp.(roth_1 |> coef))[2:4]

# ╔═╡ 890bc506-bc9d-415e-a018-0cf5e0a4f329
md"""
!!! note \"Exercise\"

	Construct the effect plot of oral contraceptive usage by history of hypertension.
"""

# ╔═╡ d8846f54-b5a2-40b4-8e5d-bb9e7592afe4
md"""
```julia
eff_1 = effects(
    Dict(
        :ht => levels(rothman.ht),
        :oc => levels(rothman.oc)
    ),
    roth_1, invlink=inv_logit
)
```
""" |> hint

# ╔═╡ 0fd5f22d-4238-4258-a3b5-1b4c62e67f10
eff_1 = effects(
    Dict(
        :ht => levels(rothman.ht),
        :oc => levels(rothman.oc)
    ),
    roth_1, invlink=inv_logit
)

# ╔═╡ 323844db-8a0c-4b84-9ac1-aecce4580364
md"""
```julia
@df eff_1 scatter(
	:oc, :stroke_cont, 
	group=:ht, yerr=:err,
	xlab="Oral contraceptives",
	ylab="P (Stroke)"
)
```
""" |> hint

# ╔═╡ e0013c53-3b67-4713-a0ce-01f20f7af922
@df eff_1 scatter(
	:oc, :stroke_cont, 
	group=:ht, yerr=:err,
	xlab="Oral contraceptives",
	ylab="P (Stroke)"
)

# ╔═╡ 5924fc5b-adee-4931-8c5e-846f1b579c83
md"""
### Joined exposures

The $p$−value of the interaction term ( $p$ = 0.598) is the same as the test of homogeneity (if robust standard errors are not used).

From a epidemiological (biological) point of view, we might be interested in testing what is the effect of both oral contraceptive use and history of hypertension (exposure) on stroke. We can generate a new variable (join) with different levels of exposure (based upon the combinations):
"""

# ╔═╡ 6648fde8-ebe1-4983-85cc-a37623ac33a9
begin
	rothman.join .= 0
	n = nrow(rothman)

	for i in 1:n
  		if rothman.oc[i] == "Non-user" && rothman.ht[i] == "Hypertension"
    		rothman.join[i] = 1
  		elseif rothman.oc[i] == "User" && rothman.ht[i] == "No-Hypertension"
    		rothman.join[i] = 2
  		elseif rothman.oc[i] == "User" && rothman.ht[i] == "Hypertension"
    		rothman.join[i] = 3
  		else
    		rothman.join[i] = 0
  		end
	end

	rothman.join = recode(
  		rothman.join,
  		0 => "Unexposed",
  		1 => "Hypertension",
  		2 => "OC user",
  		3 => "OC+hypertension"
	)

	coerce!(rothman, :join => Multiclass)
	levels!(
		rothman.join, 
		["Unexposed", "Hypertension", "OC user", "OC+hypertension"]
	)

	tabulate(rothman, :join)
end

# ╔═╡ 174799b3-94b8-4ed9-b221-184671e8435f
md"""
Now, we perform the logistic regression using join as our only predictor:
"""

# ╔═╡ db2ec059-b0f4-412e-96d5-5d6fce540b83
roth_2 = glm(@formula(stroke_cont ~ join), rothman, Binomial(), LogitLink())

# ╔═╡ 93bc3a82-9184-4faa-bf7b-8af83b33673c
md"""
Corresponding ORs:
"""

# ╔═╡ 06113563-2526-4525-8fcb-43b05d17893a
r3.(exp.(roth_2 |> coef))[2:4]

# ╔═╡ 6ae83d0d-db46-4761-bacd-fb26c82aacb7
md"""
Look at the odds ratios. The join exposure has about 3 times more the effect of the single exposures. We can look at the trend in odds.
"""

# ╔═╡ 4972f7c4-9951-4ced-91a0-d811f6be4caf
R"""
stroke_df = odds_trend(stroke ~ join, data = $rothman)$df
""";

# ╔═╡ 780bfbdc-111e-4ebb-b5f0-3d136cc21e72
@rget stroke_df

# ╔═╡ 06947211-189e-43d5-85ed-a52ec5861ebf
@df stroke_df plot(
	:Exposure, :OR,
	xlab="Exposure",
	ylab="OR",
	lw=2, marker=3, leg=false,
	lc=:indianred, mc=:firebrick
)

# ╔═╡ c27bc25c-877f-499a-94fb-bfc4dd69e5b2
md"""
Is the trend significant?
"""

# ╔═╡ cd33dfa6-f11d-4eb5-95db-3ca15a2fc450
roth_2 |> aov.anova

# ╔═╡ 9fa42197-dcad-427e-93e4-7813f24ce048
md"""
Why do we have different results regarding the interaction term? Because we are testing different things. The first model, `roth_1`, is testing if the effect of oral contraceptives use on stroke is different between women with a history of hypertension and women without a history of hypertension; that was not the case. The second model, `roth_2`, is testing if both the use of oral contraceptives and history of hypertension has an effect on stroke, and that was the case. Strictly speaking, our second model is not looking for interaction, but the effect of a combination of predictors.

The results from the second model, show that women with a history of hypertension and who are users of oral contraceptives are 16.79 times more likely to have stroke than unexposed women (OR: 16.79, 95% CIs: 5.62, 50.17) vs. the unexposed group ( $p$ < 0.001).
"""

# ╔═╡ 5bae50ad-a7ab-4a16-b62d-2eada65a5ad7
md"""
# Conditional Logistic Regression

Conditional logistic regression is used for matched case-control studies.

Matching is a way of controlling for confounding during the design stage of the study. Each case is paired with one or more controls according to levels of specified predictors.
"""

# ╔═╡ 672c9ac7-5711-4133-829d-4455e017439b
md"""
!!! tip \"Example\"

	We will look at a matched case-control study investigating the association between the use of oestrogen and endometrial cancer. Four controls were matched to each case by age and marital status.
"""

# ╔═╡ 0f19fe09-44a9-4f30-874e-2f334549b7da
R"""
data(bdendo, package = "Epi")

bdendo = bdendo |>
mutate(
    cancer = factor(d, labels = c('Control', 'Case')),
    gall = factor(gall, labels = c("No GBD", "GBD")),
    est = factor(est, labels = c("No oestrogen", "Oestrogen"))
  ) |>
  var_labels(
    cancer = 'Endometrial cancer',
    gall = 'Gall bladder disease',
    est = 'Oestrogen'
  )
""";

# ╔═╡ 76fc2536-3dc5-4733-8409-d220733f33ac
@rget bdendo; bdendo |> schema

# ╔═╡ 215675e8-d8f0-4d76-bd18-2228532328ea
coerce!(bdendo, :set => Multiclass);

# ╔═╡ 25096971-ac57-436a-94a9-ef6b2d2c8d1b
md"""
!!! note \"Exercise\"

	Perform descriptive analysis to show the distribution of endometrial cancer by gall bladder disease stratified by oral contraceptive usage.
"""

# ╔═╡ 4d23a9ac-7f54-4c36-aca6-0f08c2ab62d5
md"""
In `R` mode:

```R
bdendo |> 
  select(cancer, gall, est) |> 
    mutate(
    cancer = relevel(cancer, ref = "Case"),
    gall = relevel(gall, ref = "GBD"),
    est = relevel(est, ref = "Oestrogen")
  ) |>
  copy_labels(bdendo) |>
  tbl_strata(
    strata = gall,
    .tbl_fun = ~ .x |>
      tbl_summary(by = est, missing = "no")
  ) |> 
  cosm_sum(bold = TRUE) |> set_font_size(10) |> theme_pubh(2) |> 
  set_align(1, everywhere, "center") |>
  set_right_border(everywhere, 3) |>
  print_screen()
```
""" |> hint

# ╔═╡ 0594c28b-23bd-4d1e-add3-c7c40615aae3
R"""
bdendo |> 
  select(cancer, gall, est) |> 
    mutate(
    cancer = relevel(cancer, ref = "Case"),
    gall = relevel(gall, ref = "GBD"),
    est = relevel(est, ref = "Oestrogen")
  ) |>
  copy_labels(bdendo) |>
  tbl_strata(
    strata = gall,
    .tbl_fun = ~ .x |>
      tbl_summary(by = est, missing = "no")
  ) |> 
  cosm_sum(bold = TRUE) |> set_font_size(10) |> theme_pubh(2) |> 
  set_align(1, everywhere, "center") |>
  set_right_border(everywhere, 3) |>
  print_screen()
""";

# ╔═╡ 96d2ea61-b894-4dc3-9fd3-607334ec4b9c
md"""
## Unadjusted Analysis

We will start with the unadjusted analysis.
"""

# ╔═╡ 9b2ca828-3f9b-4bd7-8920-9ecac6b5c367
endom_1 = fit(
  MixedModel,
  @formula(d ~ 1 + est + (1 | set)),
  bdendo, Bernoulli()
);

# ╔═╡ a0a88b1e-bc95-4b63-bff1-f6abeda508a0
endom_1 |> println

# ╔═╡ 9303cc04-62d4-4c53-97a1-c7bc4b667faf
exp.(coef(endom_1))[2] |> r3

# ╔═╡ 44407077-4ac9-47cf-9d3c-327b9e2fa04b
md"""
Corresponding 95% CIs:
"""

# ╔═╡ 493b3c34-cd23-48e1-b89a-ac29da44a284
exp(coef(endom_1)[2] - 1.96*0.420221) |> r3, 
exp(coef(endom_1)[2] + 1.96*0.420221) |> r3

# ╔═╡ 739f2197-354e-43a1-9113-e7f8d54dcbd0
md"""
!!! warning \"Question\"

	What are your conclusions?
"""

# ╔═╡ 31f2d170-cf1e-48bd-9d9c-3d5ff9d5e047
md"""
!!! hint \"Answer\"

	When not adjusting for confounders, the odds of developing endometrial cancer is 7.87 times more (95% CIs: 3.46, 17.94) in women with a history of oestrogen use in comparison to women without a history of oestrogen use ( $p$ < 0.001).
"""

# ╔═╡ 6f510999-b7a4-49d7-8c53-de188596b9fd
md"""
## Adjusted Analysis

Effect of oestrogen use on endometrial cancer controlling for history of gall bladder disease.
"""

# ╔═╡ cc624224-1cde-490c-8047-eb5b0166e679
endom_2 = fit(
  MixedModel,
  @formula(d ~ est * gall + (1 | set)),
  bdendo, Binomial()
);

# ╔═╡ cd125df3-bece-4402-9456-eabfcdd537f1
endom_2 |> println

# ╔═╡ c1b9a3cb-2973-4e97-a2f0-ba3cc1c9a398
r3.(exp.(coef(endom_2)))

# ╔═╡ 3f4757ca-a3ce-4148-96e8-538a8269fc15
md"""
We can understand better the interaction term by looking at its corresponding effect plot.

Creating data frame for effect plot:
"""

# ╔═╡ f9116d81-c607-4417-af93-d6fe3f7049a5
endom_eff = effects(
  Dict(
    :est => levels(bdendo.est),
    :gall => levels(bdendo.gall)
  ),
endom_2, invlink=inv_logit
)

# ╔═╡ ef9d7787-fdf0-4883-bcb0-8232012733ee
@df endom_eff scatter(
	:est, :d,
	group=:gall, yerr=:err,
	ylab="P(Endometrial cancer)"
)

# ╔═╡ 851525f6-cf4e-4d5b-8037-9df00167c272
md"""
!!! warning \"Question\"

	What are your conclusions from the effect plot?
"""

# ╔═╡ 267780f8-cf65-40f8-a318-8efe850c9bbd
md"""
!!! hint \"Answer\"

	In women without a history of gall bladder disease, oestrogen consumers are more likely to develop endometrial cancer than non-oestrogen consumers; i.e., oestrogen use has a positive effect on the development of endometrial cancer. In women with a history of gall bladder disease, there is no significant effect of oestrogen consumption in the development of endometrial cancer.
"""

# ╔═╡ c4a396be-aa7a-40ae-bc59-a6508ea85d73
md"""
# Ordinal Logistic Regression

So far, we have considered situations where the outcome was binary. What analysis do we perform if the outcome has more than two categories and is ordinal?

Examples of ordinal variables:

- The level of agreement: strongly disagree, disagree, neutral, agree, strongly agree.
- A form of disease: mild, moderate, severe.
"""

# ╔═╡ c9c5dc12-a058-4676-8796-f8c87eca6950
md"""
!!! tip \"Example\"

	We will use data from a questionnaire on the benefits of mammography.
"""

# ╔═╡ 5c0cf4e0-e745-48ba-917f-fb94f7020129
mammo = rcopy(R"TH.data::mammoexp"); mammo |> head

# ╔═╡ c1d81f05-a7a3-4eb2-928d-8b7a9495c73c
md"""
Our outcome of interest is `ME` (mammography experience), and ordinal variable.
"""

# ╔═╡ 162e699c-f737-4d35-8848-65a3b082e4e6
tabulate(mammo, :ME)

# ╔═╡ 057ec774-1be1-445c-8efc-b46a5e48d545
md"""
If $y$ is the ordinal outcome with levels $1,2,\dots,k$, then the proportional odds ordinal logistic model can be written as a series of logistic models:

```math
\begin{gather}
 P(y>1) & = & \text{logit}^{-1}(\beta x) \\
 P(y>2) & = & \text{logit}^{-1}(\beta x - c_2) \\
 \vdots & & \vdots \\
 P(y>[k-1]) & = & \text{logit}^{-1}(\beta x - c_{k-1})
\end{gather}
```

Hence $e^{\beta}$ is the odds ratio of being in a higher category for a one unit change in the predictor variable.

When we have three groups, we are comparing: unlikely vs. (somewhat likely and very likely) and (unlikely and somewhat likely) vs. (very likely).

With the proportional odds assumption (parallel regression assumption) we assume that the relationship between each pair of outcome groups is the same. Hence, there is only one model. If this assumption did not hold, we would need different models to describe the relationship between each pair of outcome variables. We should test this hypothesis before we report the results.
"""

# ╔═╡ 03d769a6-8921-40e4-8d01-13e994f3a65c
md"""
!!! important

	For the model to work, the response variable has to be defined as an `OrderedFactor`.
"""

# ╔═╡ b1fd4b31-a72d-4ba5-b55f-d9f627ebb1a9
coerce!(
  	mammo,
  	:ME => OrderedFactor,
  	:SYMPT => OrderedFactor
);

# ╔═╡ c693b258-d259-4351-a5fa-15607ef7097e
mammo_1 = fit(
  	EconometricModel,
  	@formula(ME ~ SYMPT + PB + HIST + BSE + DECT),
 	 mammo
)

# ╔═╡ 62d4e9ba-f664-44c5-8bcb-9d1984b80f58
md"""
Let’s remove `DECT` from the model:
"""

# ╔═╡ c0ff1e42-ace9-46ed-8340-677178604db4
mammo_2 = fit(
  	EconometricModel,
  	@formula(ME ~ SYMPT + PB + HIST + BSE),
  	mammo
)

# ╔═╡ b30db2a0-c613-42c9-8f71-38b632dc0610
md"""
We will create a data frame with the table of coefficients.
"""

# ╔═╡ 2b49f581-52ba-4c92-a0da-c96f5c212e47
mammo_coef = coeftable(mammo_2) |> DataFrame

# ╔═╡ ecfc5608-bb7a-43f9-ba57-3f8cb9af66d9
md"""
Corresponding table of coefficients showing Odds Ratios and confindence intervals:
"""

# ╔═╡ 0583f606-bb57-4f12-af2e-09cc151167fe
mammo_exp = DataFrame(
	;
	Variable = mammo_coef[1:6, 1],
	PE = exp.(mammo_coef[1:6, 2]),
	lower = exp.(mammo_coef[1:6, 6]),
	upper = exp.(mammo_coef[1:6, 7])
)

# ╔═╡ Cell order:
# ╟─899faafa-bd7e-11ee-2df4-69f67c450b7a
# ╟─d3699318-3792-4a4a-9971-1159688cc96f
# ╠═cb09c9ac-7509-4fec-afdc-181c85b9af25
# ╠═91ca908f-3c2e-4dde-8302-ee262628eb4d
# ╠═ee2a485e-6dc1-42ea-81b3-3ab8a63daf16
# ╠═90a50002-faa6-4e79-8313-3a21b45d3506
# ╠═45dc60a6-19ba-4bff-89c3-495dbd43da5d
# ╟─52e727ca-73b6-42a5-8c17-02c6c02b8bbd
# ╟─eaf5de29-ebba-4866-ab8d-758f0e38e168
# ╠═9c502a06-5733-4944-84b7-ebcdea6b2cd1
# ╠═9c1316fa-1fa0-4921-9a1d-8293eaca1ca8
# ╟─bf4e2f8b-3bc0-40e9-8208-5776d1f016d0
# ╟─a6cee07c-b5fd-4561-bf4f-def82469c668
# ╟─4153f1dd-9ca5-41e2-a964-53d751b84962
# ╟─af5da8de-da11-49b4-9cfc-a2948ca552b2
# ╠═9aff1386-2fa3-45c1-9707-0a3db932edfc
# ╟─62e1c4eb-99d1-412c-ada1-c37fae4fdaf4
# ╟─018add89-7f01-48f3-b5ee-b9203f250d31
# ╟─74fa4b23-8f71-4bee-b952-3627959eb5d8
# ╟─d6ebbe22-eb72-4a2d-988d-015b35b834bb
# ╠═4ab77f72-3a5b-44dd-bda8-cbbe40528b96
# ╠═92719b31-c40f-4bd6-b4ab-d75693e45aa6
# ╟─fe22b114-7af3-4236-8b59-6ed0d7f3804e
# ╠═e9756676-6ade-4483-baad-e790eb98d872
# ╟─890bc506-bc9d-415e-a018-0cf5e0a4f329
# ╟─d8846f54-b5a2-40b4-8e5d-bb9e7592afe4
# ╟─0fd5f22d-4238-4258-a3b5-1b4c62e67f10
# ╟─323844db-8a0c-4b84-9ac1-aecce4580364
# ╟─e0013c53-3b67-4713-a0ce-01f20f7af922
# ╟─5924fc5b-adee-4931-8c5e-846f1b579c83
# ╠═6648fde8-ebe1-4983-85cc-a37623ac33a9
# ╟─174799b3-94b8-4ed9-b221-184671e8435f
# ╠═db2ec059-b0f4-412e-96d5-5d6fce540b83
# ╟─93bc3a82-9184-4faa-bf7b-8af83b33673c
# ╠═06113563-2526-4525-8fcb-43b05d17893a
# ╟─6ae83d0d-db46-4761-bacd-fb26c82aacb7
# ╠═4972f7c4-9951-4ced-91a0-d811f6be4caf
# ╠═780bfbdc-111e-4ebb-b5f0-3d136cc21e72
# ╠═06947211-189e-43d5-85ed-a52ec5861ebf
# ╟─c27bc25c-877f-499a-94fb-bfc4dd69e5b2
# ╠═cd33dfa6-f11d-4eb5-95db-3ca15a2fc450
# ╟─9fa42197-dcad-427e-93e4-7813f24ce048
# ╟─5bae50ad-a7ab-4a16-b62d-2eada65a5ad7
# ╟─672c9ac7-5711-4133-829d-4455e017439b
# ╠═0f19fe09-44a9-4f30-874e-2f334549b7da
# ╠═76fc2536-3dc5-4733-8409-d220733f33ac
# ╠═215675e8-d8f0-4d76-bd18-2228532328ea
# ╟─25096971-ac57-436a-94a9-ef6b2d2c8d1b
# ╟─4d23a9ac-7f54-4c36-aca6-0f08c2ab62d5
# ╟─0594c28b-23bd-4d1e-add3-c7c40615aae3
# ╟─96d2ea61-b894-4dc3-9fd3-607334ec4b9c
# ╠═6521bb29-86dd-467a-a2d6-d2760e66386b
# ╠═9b2ca828-3f9b-4bd7-8920-9ecac6b5c367
# ╠═a0a88b1e-bc95-4b63-bff1-f6abeda508a0
# ╠═9303cc04-62d4-4c53-97a1-c7bc4b667faf
# ╟─44407077-4ac9-47cf-9d3c-327b9e2fa04b
# ╠═493b3c34-cd23-48e1-b89a-ac29da44a284
# ╟─739f2197-354e-43a1-9113-e7f8d54dcbd0
# ╟─31f2d170-cf1e-48bd-9d9c-3d5ff9d5e047
# ╟─6f510999-b7a4-49d7-8c53-de188596b9fd
# ╠═cc624224-1cde-490c-8047-eb5b0166e679
# ╠═cd125df3-bece-4402-9456-eabfcdd537f1
# ╠═c1b9a3cb-2973-4e97-a2f0-ba3cc1c9a398
# ╟─3f4757ca-a3ce-4148-96e8-538a8269fc15
# ╟─f9116d81-c607-4417-af93-d6fe3f7049a5
# ╠═ef9d7787-fdf0-4883-bcb0-8232012733ee
# ╟─851525f6-cf4e-4d5b-8037-9df00167c272
# ╟─267780f8-cf65-40f8-a318-8efe850c9bbd
# ╟─c4a396be-aa7a-40ae-bc59-a6508ea85d73
# ╟─c9c5dc12-a058-4676-8796-f8c87eca6950
# ╠═5c0cf4e0-e745-48ba-917f-fb94f7020129
# ╟─c1d81f05-a7a3-4eb2-928d-8b7a9495c73c
# ╠═162e699c-f737-4d35-8848-65a3b082e4e6
# ╟─057ec774-1be1-445c-8efc-b46a5e48d545
# ╟─03d769a6-8921-40e4-8d01-13e994f3a65c
# ╠═b1fd4b31-a72d-4ba5-b55f-d9f627ebb1a9
# ╠═c693b258-d259-4351-a5fa-15607ef7097e
# ╟─62d4e9ba-f664-44c5-8bcb-9d1984b80f58
# ╠═c0ff1e42-ace9-46ed-8340-677178604db4
# ╟─b30db2a0-c613-42c9-8f71-38b632dc0610
# ╠═2b49f581-52ba-4c92-a0da-c96f5c212e47
# ╟─ecfc5608-bb7a-43f9-ba57-3f8cb9af66d9
# ╠═0583f606-bb57-4f12-af2e-09cc151167fe
