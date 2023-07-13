# This file was generated, do not modify it. # hide
data(flu_melt) *
mapping(
	:week => "Date",
    :value => "Number of cases",
    color=:variable => "Age group"
) *
visual(ScatterLines, markersize=7) |>
draw