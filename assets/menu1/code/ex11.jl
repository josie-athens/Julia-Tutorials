# This file was generated, do not modify it. # hide
data(birth) *
mapping(:bwt => "Birth weight (g)") *
histogram(bins=20, normalization=:density) *
visual(color=:pink) |>
draw