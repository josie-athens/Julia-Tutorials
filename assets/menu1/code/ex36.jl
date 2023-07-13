# This file was generated, do not modify it. # hide
data(birth) *
mapping(
	:race => "Ethnicity",
    :bwt => "Birth weight (g)",
    color=:smoke => "Smoking status",
    dodge = :smoke
) *
visual(BoxPlot) |>
draw