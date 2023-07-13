# This file was generated, do not modify it. # hide
data(kfm) *
mapping(
	:mat_weight => "Maternal weight (kg)",
  :dl_milk => "Breast-milk intake (dl/day)",
  color = :sex => "Sex"
) *
visual(Scatter, markersize=5) |>
draw