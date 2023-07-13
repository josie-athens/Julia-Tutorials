# This file was generated, do not modify it. # hide
data(wcgs |> dropmissing) *
mapping(
	:chol => "Cholesterol (mg/dl)",
	color=:chd => "CHD", dodge=:chd
) *
AoG.density(datalimits=extrema) |>
draw