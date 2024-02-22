### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ afded31c-1284-4d19-8ced-0380aa00f194
using PlutoUI; PlutoUI.TableOfContents(aside=true, title="📚 Contents")

# ╔═╡ 7726fa51-5f23-4254-a27f-1e30a3e4611a
# ╠═╡ show_logs = false
begin
	using StatsBase, DataFrameMacros, TexTables
	using RCall, DataFrames, ScientificTypes
	using AutoMLPipeline, DecisionTree
end

# ╔═╡ 377e88e0-fdaa-45b3-a756-e54ac8147690
include("pubh.jl");

# ╔═╡ 7e7339d4-6163-11ee-1730-cb042077bc21
md"""
# Binary Classification

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform, **AgRresearch Ltd**
	- 3 October 2023
"""

# ╔═╡ ac5b0002-fe77-494c-a8e5-72269eea50f5
md"""
## 📖 Main Menu

[Return to Main Menu](index.html)
"""

# ╔═╡ 22460c36-166b-4bd4-911f-88e16c567c9a
# ╠═╡ show_logs = false
R"""
require("pubh", quietly=TRUE)
require("sjlabelled", quietly=TRUE)
require("readr", quietly=TRUE)
""";

# ╔═╡ fd8b7b6f-8bbb-4421-8c5c-e1cf026f901c
md"""
# Data

## Onchocerciasis

Data on microfilariae infection with *Onchocerciasis volvulus*
"""

# ╔═╡ b76bbe73-80fa-42fb-bb35-f2b20fb2d531
R"""
data(Oncho, package="pubh")
Oncho = as.data.frame(Oncho)
""";

# ╔═╡ af2a30a9-0f2b-4841-9b3d-c772972b4280
@rget Oncho; Oncho |> head

# ╔═╡ cb09f4c9-2774-4bd6-8df5-c9ee1e174b76
Oncho |> schema

# ╔═╡ b77ab9ae-a7af-48d9-a8b8-243f4be18017
oncho_x = Oncho[:, 3:5]; oncho_y= Oncho[:, 2] |> Vector;

# ╔═╡ b3c85b48-a531-43e9-b1cf-b6f7c31ba1c1
oncho_x |> size

# ╔═╡ ed2f5658-6844-490a-9223-16326e3573e5
md"""
## Diabetes
"""

# ╔═╡ 2089a01a-3760-4efd-81a3-c985e94393c6
R"""
data(PimaIndiansDiabetes, package = "mlbench")
pima = PimaIndiansDiabetes
""";

# ╔═╡ 3294c77d-8d37-494a-aa72-e4947e8cefcc
@rget pima; pima |> head

# ╔═╡ d2deaccc-717d-4f1c-a07f-8c611ba3677f
pima |> schema

# ╔═╡ 15f2f157-75d8-4117-80b3-f175766e8f0c
pima_x = pima[:, 1:end-1]; pima_y = pima[:, end] |> Vector;

# ╔═╡ cb381e8e-efd2-4276-8dc5-2e1486f8ad20
pima_x |> size

# ╔═╡ f9ca3ff5-4d1c-4e08-99a3-46161da303bc
md"What is interesting with this dataset is that one or more numeric columns can be categorical and should be hot-bit encoded. One way to verify is to compute the number of unique instances for each column and look for columns with relatively smaller count:"

# ╔═╡ 0693a608-5689-4062-a268-3abb2e948dfa
[n=>length(unique(x)) for (n,x) in pairs(eachcol(pima))] |> collect

# ╔═╡ b88914e8-bd67-4e31-a605-219de33afcca
md"""
Among the input columns, `pregnant` has only 17 unique instances and it can be treated as a categorical variable. However, its description indicates that the feature refers to the number of times the patient is pregnant and can be considered numerical. With this dilemma, we need to figure out which representation provides better performance to our classifier. In order to test the two options, we can use the Feature Discriminator module (`CatNumDiscriminator`) to filter and transform the `pregnant` column to either numeric or categorical and choose the pipeline with the optimal performance.
"""

# ╔═╡ 51b766ac-0f59-4bf7-85bc-f6cab6c4028a
md"""
# ML Encoders
"""

# ╔═╡ 96bbf27e-26ae-4661-9e3d-ca08c219e725
auto_pipe = AutoMLPipeline;

# ╔═╡ 29870c95-24b8-4b5a-af93-acd821a606d7
begin
	pca = SKPreprocessor("PCA")
	disc = CatNumDiscriminator()
	ohe = OneHotEncoder()
	catf = CatFeatureSelector()
	numf = NumFeatureSelector()
	dt = SKLearner("DecisionTreeClassifier")
	rb = SKPreprocessor("RobustScaler")
	jrf = RandomForest()
end;

# ╔═╡ af248f21-e861-4e41-8535-ffa4653211ca
md"""
!!! note

	For the Machine Learning encoders, I am selecting some from 3 different categories:

	- **Selectors:** `catf` and `numf`.
	- **Pre-processing:** `pca`, `disc`, `ohe` and `rb`.
	- **Learners:** `tree` and `jrf`.
"""

# ╔═╡ 6d2854ca-3a46-42ec-87d1-3a52e804d838
md"""
# Pre-processing

## Categorical variables

We use `OneHotEncoder` (`ohe`) as pre-processing of categorical variables. In rough terms, it transforms the variable from categorical to continuous and creates a dummy variable for each level of the original factor.

To apply `ohe`, we first select the categorical variables with `catf`.
"""

# ╔═╡ a5b07dfa-c231-4bc8-829b-c94f4ae99ca3
md"""
## Numerical variables

For continuous variables, it is important to scale them before using the learning machine on them. In our current example, we are using a robust scaling (`rb`) to account for the presence of potential outliers. We can also use `pca` as part of the pre-processing pipeline of continuous variables.

We can use `disc` to consider a particular column as categorical. For the sake of this discussion, we are using its default value which is 24.
"""

# ╔═╡ 3ac6819f-433a-4cca-abb1-6083f7bb4832
@pipeline disc;

# ╔═╡ ccd9d384-f828-4a01-b020-9d0fd6a9af5c
begin
	pima_disc = fit_transform!(disc, pima_x, pima_y)
	pima_disc |> head
end

# ╔═╡ b406f8db-2866-48a7-9042-42288c7c401a
pima_disc |> size

# ╔═╡ 0eb3ff6c-b706-4e79-8bae-06493792359e
md"""
!!! note

	The *pregnant* column was converted by `disc` from `Float64`  into `String` type which can be fed to `ohe` to preprocess categorical data:
"""

# ╔═╡ 295acac5-ba61-49bf-ad15-650ba392cdcb
pohe = @pipeline disc |> catf |> ohe

# ╔═╡ 9710b152-fcdf-4d7c-967b-5ded1d5f6eaf
begin
	pima_pohe = fit_transform!(pohe, pima_x, pima_y)
	pima_pohe |> head
end

# ╔═╡ 68d25dff-522d-47f2-8baa-0b4e8c5ab657
pima_pohe |> size

# ╔═╡ 41044f38-e2f8-494e-b9d8-946dc460a5cd
md"""
We have now converted all categorical variables from the `pima` dataset into hot-bit encoded values.

!!! important

	For a typical scenario, one can consider columns with around 3-10 unique numeric instances to be categorical. Using `CatNumDiscriminator`, it is trivial to convert columns of features with small unique instances into categorical and hot-bit encode them as shown above.
"""

# ╔═╡ b5a823ca-59f8-4405-9c0e-9f2c2d2eaa33
md"""
## Performance evaluation

Let's compare the random forest cross-validation result between two options:

- *pregnant* as a categorical variable
- *pregnant* as a numerical variable

We are predicting diabetes (outcome) where numerical values are scaled by a robust scaler and decomposed by PCA.
"""

# ╔═╡ ab1bf0f2-e0b1-47de-8c41-1533d4a5978b
md"""
### As categorical
"""

# ╔═╡ f310f8d2-bd99-4bcd-8aad-18ad02448225
# ╠═╡ show_logs = false
begin
	cat_pl = @pipeline disc |> ((numf |> rb |>  pca) + (catf |> ohe)) |> jrf
	crossvalidate(cat_pl, pima_x, pima_y, "accuracy_score", 30)
end

# ╔═╡ 8a9208e5-104c-41e9-8073-118510bbc699
md"""
### As numerical
"""

# ╔═╡ 4c31f4a8-7209-4481-a5ab-f0172036c82e
# ╠═╡ show_logs = false
begin
	num_pl = @pipeline ((numf |> rb |>  pca) + (catf |> ohe)) |> jrf
	crossvalidate(num_pl, pima_x, pima_y, "accuracy_score", 30)
end

# ╔═╡ 2c243ede-c67a-443a-9017-e23cfe6b64e3
md"""
!!! important \"Conclusion\"

	The mean accuracy score when we consider *pregnant* as categorical is higher and with a lower dispersion than when we consider it as numerical.
"""

# ╔═╡ 0b94b67f-0b5c-4896-a7e5-134e667d78cf
md"""
# Analysis

## Onchocerciasis
"""

# ╔═╡ 313d02f6-541a-49dc-801d-fd5b7e8eb68c
oncho_pldt = @pipeline (catf |> ohe) |> dt

# ╔═╡ 27dbc6f5-0608-4979-8284-a42c59ebc802
oncho_fit_dt = fit_transform!(oncho_pldt, oncho_x, oncho_y);

# ╔═╡ dc69c226-f13c-4d79-8218-6822b839f84b
# ╠═╡ show_logs = false
crossvalidate(oncho_pldt, oncho_x, oncho_y, "accuracy_score", 30)

# ╔═╡ 842421d3-7ea4-4c3e-977a-bf0bbcba4549
# ╠═╡ show_logs = false
crossvalidate(oncho_pldt, oncho_x, oncho_y, "cohen_kappa_score", 30)

# ╔═╡ a254130d-3765-4597-8c96-8a8f6dd7f751
cat_pipe = @pipeline catf |> ohe

# ╔═╡ 2490bdfa-69da-4741-b4fb-0534b46d1544
oncho_pre = fit_transform!(cat_pipe, oncho_x, oncho_y);

# ╔═╡ 45036ff2-a737-49ed-847d-8a96a13c564c
oncho_pre |> head

# ╔═╡ ff05d195-d7b1-46e8-b0b0-1eda087d19af
oncho_x |> head

# ╔═╡ a8e3b486-8420-49b9-9419-f4680541a5ff


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AutoMLPipeline = "08437348-eef5-4817-bc1b-d4e9459680d6"
DataFrameMacros = "75880514-38bc-4a95-a458-c2aea5a3a702"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DecisionTree = "7806a523-6efd-50cb-b5f6-3fa6f1930dbb"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
ScientificTypes = "321657f4-b219-11e9-178b-2701a2544e81"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
TexTables = "ebf5ac4f-3ec1-555f-9ac9-3d72ed88c471"

[compat]
AutoMLPipeline = "~0.4.2"
DataFrameMacros = "~0.4.1"
DataFrames = "~1.6.1"
DecisionTree = "~0.10.13"
PlutoUI = "~0.7.52"
RCall = "~0.13.18"
ScientificTypes = "~3.0.2"
StatsBase = "~0.33.21"
TexTables = "~0.2.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "a07886c90b355fb4727ad7795619aa0145138aee"

[[deps.AMLPipelineBase]]
deps = ["CSV", "DataFrames", "Dates", "DecisionTree", "IterTools", "MLBase", "PooledArrays", "Random", "Statistics", "StatsBase"]
git-tree-sha1 = "d926f111137b7e3914c16dacbd293519200546ed"
uuid = "e3c3008a-8869-4d53-9f34-c96f99c8a2b6"
version = "0.1.12"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AutoMLPipeline]]
deps = ["AMLPipelineBase", "CondaPkg", "DataFrames", "PythonCall", "Random", "Test"]
git-tree-sha1 = "3a3e3064809da6c3601247dede4f921fe47671e4"
uuid = "08437348-eef5-4817-bc1b-d4e9459680d6"
version = "0.4.2"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "44dbf560808d49041989b8a96cae4cffbeb7966a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.11"

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

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "8c86e48c0db1564a1d49548d3515ced5d604c408"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.9.1"

[[deps.CondaPkg]]
deps = ["JSON3", "Markdown", "MicroMamba", "Pidfile", "Pkg", "Preferences", "TOML"]
git-tree-sha1 = "bbd0c518cb11acc6707190199025dbc34b6c7ca7"
uuid = "992eb4ea-22a4-4c89-a5bb-47a3300528ab"
version = "0.2.21"

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
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DecisionTree]]
deps = ["AbstractTrees", "DelimitedFiles", "LinearAlgebra", "Random", "ScikitLearnBase", "Statistics"]
git-tree-sha1 = "cac532376d6dd379208cebfbee67c898cc549fad"
uuid = "7806a523-6efd-50cb-b5f6-3fa6f1930dbb"
version = "0.10.13"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "3d5873f811f582873bb9871fc9c451784d5dc8c7"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.102"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "a20eaa3ad64254c61eeb5f230d9306e937405434"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.6.1"
weakdeps = ["SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "273bd1cd30768a2fddfa3fd63bbc746ed7249e5f"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.9.0"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

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

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "95220473901735a0f4df9d1ca5b171b568b2daa3"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.13.2"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MLBase]]
deps = ["IterTools", "Random", "Reexport", "StatsBase"]
git-tree-sha1 = "ac79beff4257e6e80004d5aee25ffeee79d91263"
uuid = "f0e99cf1-93fa-52ec-9ecc-5026115318e0"
version = "0.9.2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MicroMamba]]
deps = ["Pkg", "Scratch", "micromamba_jll"]
git-tree-sha1 = "011cab361eae7bcd7d278f0a7a00ff9c69000c51"
uuid = "0b3b1443-0f03-428d-bdfb-f27f9c1191ea"
version = "0.1.14"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "b7c4f29f93b548caa58f703580f4d79ab753c8ac"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.21"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pidfile]]
deps = ["FileWatching", "Test"]
git-tree-sha1 = "2d8aaf8ee10df53d0dfb9b8ee44ae7c04ced2b03"
uuid = "fa939f87-e72e-5be4-a000-7fc836dbe307"
version = "1.3.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

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

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "ee094908d720185ddbdc58dbe0c1cbe35453ec7a"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PythonCall]]
deps = ["CondaPkg", "Dates", "Libdl", "MacroTools", "Markdown", "Pkg", "REPL", "Requires", "Serialization", "Tables", "UnsafePointers"]
git-tree-sha1 = "70af6bdbde63d7d0a4ea99f3e890ebdb55e9d464"
uuid = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
version = "0.9.14"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9ebcd48c498668c7fa0e97a9cae873fbee7bfee1"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.1"

[[deps.RCall]]
deps = ["CategoricalArrays", "Conda", "DataFrames", "DataStructures", "Dates", "Libdl", "Missings", "REPL", "Random", "Requires", "StatsModels", "WinReg"]
git-tree-sha1 = "3084689b18f9e5e817a6ce9a83a7654d8ad0f2f6"
uuid = "6f49c342-dc21-5d91-9882-a32aef131414"
version = "0.13.18"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

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

[[deps.ScikitLearnBase]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "7877e55c1523a4b336b433da39c8e8c08d2f221f"
uuid = "6e75b9c4-186b-50bd-896f-2d2496a4843e"
version = "0.5.0"

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

[[deps.ShiftedArrays]]
git-tree-sha1 = "503688b59397b3307443af35cd953a13e8005c16"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "2.0.0"

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
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

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
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

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
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsAPI", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "5cf6c4583533ee38639f73b880f35fc85f2941e0"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.7.3"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a1f34829d5ac0ef499f6d84428bd6b4c71f02ead"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TexTables]]
deps = ["Compat", "DataFrames", "DataStructures", "Distributions", "Formatting", "GLM", "Parameters", "StatsBase", "StatsModels"]
git-tree-sha1 = "b1adb560810b2cd88e505f50e02b245730447149"
uuid = "ebf5ac4f-3ec1-555f-9ac9-3d72ed88c471"
version = "0.2.7"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafePointers]]
git-tree-sha1 = "c81331b3b2e60a982be57c046ec91f599ede674a"
uuid = "e17b2a0c-0bdf-430a-bd0c-3a23cae4ff39"
version = "1.0.0"

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

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.micromamba_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "66d07957bcf7e4930d933195aed484078dd8cbb5"
uuid = "f8abcde7-e9b7-5caa-b8af-a437887ae8e4"
version = "1.4.9+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─7e7339d4-6163-11ee-1730-cb042077bc21
# ╟─ac5b0002-fe77-494c-a8e5-72269eea50f5
# ╠═afded31c-1284-4d19-8ced-0380aa00f194
# ╠═7726fa51-5f23-4254-a27f-1e30a3e4611a
# ╠═377e88e0-fdaa-45b3-a756-e54ac8147690
# ╠═22460c36-166b-4bd4-911f-88e16c567c9a
# ╟─fd8b7b6f-8bbb-4421-8c5c-e1cf026f901c
# ╠═b76bbe73-80fa-42fb-bb35-f2b20fb2d531
# ╠═af2a30a9-0f2b-4841-9b3d-c772972b4280
# ╠═cb09f4c9-2774-4bd6-8df5-c9ee1e174b76
# ╠═b77ab9ae-a7af-48d9-a8b8-243f4be18017
# ╠═b3c85b48-a531-43e9-b1cf-b6f7c31ba1c1
# ╟─ed2f5658-6844-490a-9223-16326e3573e5
# ╠═2089a01a-3760-4efd-81a3-c985e94393c6
# ╠═3294c77d-8d37-494a-aa72-e4947e8cefcc
# ╠═d2deaccc-717d-4f1c-a07f-8c611ba3677f
# ╠═15f2f157-75d8-4117-80b3-f175766e8f0c
# ╠═cb381e8e-efd2-4276-8dc5-2e1486f8ad20
# ╟─f9ca3ff5-4d1c-4e08-99a3-46161da303bc
# ╠═0693a608-5689-4062-a268-3abb2e948dfa
# ╟─b88914e8-bd67-4e31-a605-219de33afcca
# ╟─51b766ac-0f59-4bf7-85bc-f6cab6c4028a
# ╠═96bbf27e-26ae-4661-9e3d-ca08c219e725
# ╠═29870c95-24b8-4b5a-af93-acd821a606d7
# ╟─af248f21-e861-4e41-8535-ffa4653211ca
# ╟─6d2854ca-3a46-42ec-87d1-3a52e804d838
# ╟─a5b07dfa-c231-4bc8-829b-c94f4ae99ca3
# ╠═3ac6819f-433a-4cca-abb1-6083f7bb4832
# ╠═ccd9d384-f828-4a01-b020-9d0fd6a9af5c
# ╠═b406f8db-2866-48a7-9042-42288c7c401a
# ╟─0eb3ff6c-b706-4e79-8bae-06493792359e
# ╠═295acac5-ba61-49bf-ad15-650ba392cdcb
# ╠═9710b152-fcdf-4d7c-967b-5ded1d5f6eaf
# ╠═68d25dff-522d-47f2-8baa-0b4e8c5ab657
# ╟─41044f38-e2f8-494e-b9d8-946dc460a5cd
# ╟─b5a823ca-59f8-4405-9c0e-9f2c2d2eaa33
# ╟─ab1bf0f2-e0b1-47de-8c41-1533d4a5978b
# ╠═f310f8d2-bd99-4bcd-8aad-18ad02448225
# ╟─8a9208e5-104c-41e9-8073-118510bbc699
# ╠═4c31f4a8-7209-4481-a5ab-f0172036c82e
# ╟─2c243ede-c67a-443a-9017-e23cfe6b64e3
# ╟─0b94b67f-0b5c-4896-a7e5-134e667d78cf
# ╠═313d02f6-541a-49dc-801d-fd5b7e8eb68c
# ╠═27dbc6f5-0608-4979-8284-a42c59ebc802
# ╠═dc69c226-f13c-4d79-8218-6822b839f84b
# ╠═842421d3-7ea4-4c3e-977a-bf0bbcba4549
# ╠═a254130d-3765-4597-8c96-8a8f6dd7f751
# ╠═2490bdfa-69da-4741-b4fb-0534b46d1544
# ╠═45036ff2-a737-49ed-847d-8a96a13c564c
# ╠═ff05d195-d7b1-46e8-b0b0-1eda087d19af
# ╠═a8e3b486-8420-49b9-9419-f4680541a5ff
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
