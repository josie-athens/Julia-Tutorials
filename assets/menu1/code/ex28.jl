# This file was generated, do not modify it. # hide
let
	air2 = air |> dropmissing
	nms = names(air2, 1:4)
	p = select(air2, nms)
	pairplot(p,
		labels = Dict(
			:Temp => "Temp (°F)",
			:Solar_R => "Radiation (Å)",
			:Wind => "Wind (mph)",
			:Ozone => "Ozone (ppb)",
		)
	)
end