# This file was generated, do not modify it. # hide
@chain wcgs begin
	groupby([:chd, :smoker])
	combine(nrow => :value)
	unstack(:smoker, :value)
end