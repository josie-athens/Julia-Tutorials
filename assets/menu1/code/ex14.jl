# This file was generated, do not modify it. # hide
"""
	rel_dis()

Estimates the relative dispersion (coefficient of variation) of a vector.
"""
rel_dis(x) = std(x) / mean(x)

@chain kfm begin
	select(Not(1, 3, 5))
	describe(:mean, :median, :std, rel_dis => :cv)
end