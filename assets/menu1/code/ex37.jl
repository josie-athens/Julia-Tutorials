# This file was generated, do not modify it. # hide
data(birth) *
mapping(
	:Race => "",
    :bwt => "Birth weight (g)",
    color=:Race => "Ethnicity",
    layout = :smoke
) *
visual(BoxPlot) |>
draw