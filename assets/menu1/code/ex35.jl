# This file was generated, do not modify it. # hide
data(@subset(wcgs |> dropmissing, :chol.<500) ) *
mapping(
	:chd => "CHD",
    :chol => "Cholesterol (mg/dl)",
    color=:chd => "CHD"
) *
visual(BoxPlot) |>
draw