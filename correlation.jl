### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ 8ead4307-bd34-4dbf-a838-08fa43c0c0a6
using PlutoUI; PlutoUI.TableOfContents(aside=true, title="📚 Contents")

# ╔═╡ 4f46ec39-efd4-4f3e-91f6-d178d35f669b
begin
	using StatsBase, DataFrames, DataFrameMacros, MLJ
	using RCall, TexTables, CategoricalArrays
	using CausalityTools
	using MLJ: schema
end

# ╔═╡ 1319a5ac-b711-4cda-b7e5-04e60e6d4c12
begin
	using StatsPlots, PlotThemes
	theme(:wong)
end

# ╔═╡ 2f60dd1a-c310-11ee-15df-772a362cf3ad
md"""
# Correlation and Causality

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform, **AgRresearch Ltd**
	- 4 February 2024
"""

# ╔═╡ 87d752d6-e19c-42d6-a031-0c710b12096e
md"""
## [📖 Main Menu](index.html)
"""

# ╔═╡ 70ede15c-2dce-4187-a0b3-ab5a4c74a9aa


# ╔═╡ Cell order:
# ╟─2f60dd1a-c310-11ee-15df-772a362cf3ad
# ╟─87d752d6-e19c-42d6-a031-0c710b12096e
# ╠═8ead4307-bd34-4dbf-a838-08fa43c0c0a6
# ╠═4f46ec39-efd4-4f3e-91f6-d178d35f669b
# ╠═1319a5ac-b711-4cda-b7e5-04e60e6d4c12
# ╠═70ede15c-2dce-4187-a0b3-ab5a4c74a9aa
