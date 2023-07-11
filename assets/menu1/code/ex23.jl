# This file was generated, do not modify it. # hide
gdf = groupby(iris, :Species)
subdf_setosa = gdf[1]
describe(subdf_setosa, :mean, :median, :std, rel_dis => :cv)