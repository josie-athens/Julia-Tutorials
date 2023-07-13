# This file was generated, do not modify it. # hide
let
	nms = names(iris, 1:4)
	p = select(iris, nms .=> replace.(nms, "_" => " "))
	pairplot(p => (
		PairPlots.Scatter(color=:firebrick, markersize=5),
		PairPlots.MarginDensity(),
		)
	)
end