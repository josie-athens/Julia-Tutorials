# This file was generated, do not modify it. # hide
data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	layout=:chd => "CHD"
) *
histogram(bins=30, normalization=:pdf) |>
draw