# This file was generated, do not modify it. # hide
data(wcgs) *
mapping(
	:sbp => "SBP (mm Hg)",
	color=:chd => "CHD", dodge=:chd
) *
histogram(bins=30, normalization=:pdf) |>
draw