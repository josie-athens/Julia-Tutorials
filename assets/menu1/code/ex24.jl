# This file was generated, do not modify it. # hide
let
	layers = visual(Scatter, markersize=5, color=:firebrick) + smooth()
	data(kfm) *
	mapping(
		:mat_weight => "Maternal weight (kg)",
    	:dl_milk => "Breast-milk intake (dl/day)"
	) *
	layers |>
	draw
end