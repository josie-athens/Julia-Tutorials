# This file was generated, do not modify it. # hide
@chain iris begin
  @subset(:Species .== "setosa")
  select(Not(:Species))
  describe(:mean, :median, :std, rel_dis => :cv)
end