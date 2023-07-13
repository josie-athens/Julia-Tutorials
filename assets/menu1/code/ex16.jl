# This file was generated, do not modify it. # hide
data(wcgs) *
mapping(
	:dbp => log => "log (DBP)",
	color=:chd => "CHD", dodge=:chd
) *
AoG.density(datalimits=extrema) |>
draw