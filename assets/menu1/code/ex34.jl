# This file was generated, do not modify it. # hide
data(wcgs |> dropmissing) *
mapping(
	:chd => "CHD",
    :chol => "Cholesterol (mg/dl)"
) *
visual(BoxPlot, color=:plum3) |>
draw