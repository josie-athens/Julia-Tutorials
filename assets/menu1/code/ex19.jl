# This file was generated, do not modify it. # hide
@chain mao begin
	select(:Age)
	describe(:min, :max, :mean, :median, :std, rel_dis => :cv)
end