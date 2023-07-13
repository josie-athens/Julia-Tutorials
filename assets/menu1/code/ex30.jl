# This file was generated, do not modify it. # hide
let
	d = data(air |> dropmissing) * mapping(:Wind, :Ozone)
	p1 = d * visual(Scatter, markersize=5) * mapping(color=:Month)
	p2 = d * smooth()
	draw(
        p1 + p2,
        axis=(
            xlabel="Wind (mph)",
            ylabel="Ozone (ppb)"
        )
    )
end