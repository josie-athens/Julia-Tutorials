#=
Julia functions
=#

hint(text) = Markdown.MD(Markdown.Admonition("hint", "Answer", [text]))

head(df) = first(df, 5)

odds_ratio(a::Int, b::Int, c::Int, d::Int) = (a * d) / (b * c)
odds_ratio(p1::Float64, p0::Float64) = ((p1) / (1 - p1)) / ((p0) / (1 - p0))
odds_ratio(x::Matrix{Int}) = (x[1, 1] * x[2, 2]) / (x[1, 2] * x[2, 1])

relative_risk(a::Int, b::Int, c::Int, d::Int) = (a / (a + b)) / (c / (c + d))
relative_risk(x::Matrix{Int}) = (x[1, 1] / (x[1, 1] + x[1, 2])) / (x[2, 1] / (x[2, 1] + x[2, 2]))

"""
  matched(v1::Array, v2::Array)

Returns a vector of positions of first matches of its first argument in its second.

Args:
- v1: A vector.
- v2: A vector.

Returns:
- The vector of positions in the second vector to retrieve the components from the first vector.
"""
matched = function (v1::Array, v2::Array)
  res = zeros(length(v1))
  for i in 1:length(v1)
    res[i] = findfirst(v2, v1[i])
  end
  return res
end

"""
  rel_dis(x)

Estimates the relative dispersion (coefficient of variation) of a vector.

Args:
- x: A numerical vector.

Returns:
- The relative dispersion (coefficient of variation) of vector x.
"""
rel_dis(x) = std(x) / mean(x)

"""
  inv_logit(x)

Function to back-transform coefficients from logistic regression models to probabilities.

Args:
- x: A numeric variable

Returns:
- The predicted probability from a logistic model using the logit link.
"""
inv_logit(x) = exp(x) / (1 + exp(x))


"""
  r3(x)

Rounds to 3 significant figures

Args:
- x: A number.

Returns:
- The number rounded to 3 significant figures
"""
r3(x) = round(x; digits=3)

"""
  coef_det(fit::Array, obs::Array)

Estimates the coefficient of determination (r²) from fitted (predicted) and observed values. Outcome from the model is assumed to be numerical.

Args:
- fit: Vector with fitted (predicted) values.
- obs: Vector with observed values (numerical outcome).

Returns:
- A scalar, the coefficient of determination (r²)
"""
coef_det = function (fit::Array, obs::Array)
  obm = mean(obs)
  SSres = sum((obs - fit) .^ 2)
  SStot = sum((obs .- obm) .^ 2)
  res = 1 - (SSres / SStot)
  return res
end

"""
  ci_mean(x::Array, digits)

Estimates the confidence interval for a sample mean.

Args:
- x: A numerical vector.
- digits: An integer, the number of digits to use for rounding. Default is 2.

Returns:
- The lower and upper 95% CI of the sample.
"""
ci_mean = function (x::Array, digits=2)
  n = length(x)
  s = std(x)
  α = 0.05
  za = quantile(TDist(n - 1), 1 - α + (α / 2))
  se = s / sqrt(n)
  ci = [mean(x) - za * se, mean(x) + za * se]
  res = round.(ci, digits=digits)
  return res
end

"""
  reference_range(μ, σ)

Estimates the reference range (reference interval) of a numerical variable.

Args:
- μ: A scalar, the mean of the variable.
- σ: A scalar, the standard deviation of the variable.

Returns:
- The reference range.
"""
reference_range = function (μ, σ)
  low = quantile(Normal(μ, σ), 0.025)
  up = quantile(Normal(μ, σ), 0.975)
  ri = [low, up]
  return ri
end

"""
  non_mising(x)

Calculates the number of non missing observations from a variable.
  
Args:
- x: The variable to count the non missing observations from.
  
Returns:
- The number of non missing observations.
"""
non_missing = function (x)
  res = count(!ismissing, x)
  return res
end

"""
  mape(df)

Calculates the Mean Absolute Percentage Error.

Args:
- df: A data frame with the performance of the model. It most include variables :error and :observed.

Returns:
- The mean absolute percentage error of a model.
"""
mape = function (df)
  mape = mean(abs.(df.error / df.observed))
  return mape
end

"""
  rmse(df)

Calculates the Root Mean Square Error.

Args:
- df: A data frame with the performance of the model. It most include variable :error.

Returns:
- The root mean square error of a model.
"""
rmse = function (df)
  rmse = sqrt(mean(df.error .* df.error))
  return rmse
end

"""
  vec_group(df, outcome, group)

Generates vectors of the outcome variable for each level of variable group in data frame df. This function helps performing hypothesis test by group.

Args:
- df: A data frame.
- outcome: Numerical variable.
- group: Variable used to split the outcome. A categorical variable or integer.

Returns:
- Vectors of the outcome variable, for each level of the group variable.
"""
vec_group = function (df, outcome, group)
  gps = DataFrames.groupby(df, group)
  y = map(keys(gps)) do key
    collect(skipmissing(gps[key][!, outcome]))
  end
  return y
end

"""
  coef_plot(model; labs, ratio)

Constructs a coefficient plot from a regression model.

Args:
- model: A regression model.
- labs: A vector for the names of the predictors. Order of strings should match the order of the coefficients except the intercept, which should be omitted.
- ratio: Logical. If true, the function exponentiates the results to plot a ratio (e.g. OR in logistic regression). Default is: ratio=false.
		
Returns:
- A Makie plot.
"""
coef_plot = function (model; labs, ratio = false)
  n = length(coef(model))
	n2 = n-1
  estimate = ratio ? exp.(coef(model)[2:n]) : coef(model)[2:n]
  low = ratio ? exp.(confint(model)[2:n, 1]) : confint(model)[2:n, 1]
  up = ratio ? exp.(confint(model)[2:n, 2]) : confint(model)[2:n, 2]
  n0 = n - 1
  y = 1:1:n0
  x0 = ratio ? 1 : 0

  df = DataFrame(; estimate, low, up, y)

	fig = Figure()
	ax = Axis(
		fig[1, 1], 
		yticks = (1:n2, labs),
		xlabel  = ratio ? "Ratio" : "Coefficient"
	)
	
	scatter!(ax, df.estimate, df.y)
	rangebars!(ax, df.y, df.low, df.up, whiskerwidth = 10, direction = :x)
	vlines!(ax, x0, linestyle=:dash, color=:cadetblue)
	fig
end

"""
  model_perf(model)

Generates a data frame with some performance related variables like fitted values, total error, Cook's distance and leverage.

Args:
- model: A regression model.

Returns:
- A data frame with performance columns:
  - :observed -> the response variable.
  - :predicted -> the fitted values.
  - :error -> the residuals.
  - :std_error -> the standardised residuals.
  - :cook -> Cook's distances.
  - :lever -> leverages.
  - :sqr_error -> square root of absolute standardised residuals.
"""
model_perf = function (model)
  x = response(model)
  inv = 1 / length(x)
  μ = mean(x)
  ssx = (x .- μ) .^ 2
  ssx2 = sum(ssx)
  lev = inv .+ ssx / ssx2
  df = DataFrame(
    observed=response(model),
    predicted=fitted(model),
    error=residuals(model),
    std_error=StatsBase.standardize(
      ZScoreTransform,
      residuals(model)
    ),
    cook=cooksdistance(model),
    lever=lev,
    sqr_error=sqrt.(abs.(residuals(model)))
  )
  return df
end

"""
  resid_plot(perf; title)

Constructs a QQ-plot of the residuals from a linear regression model which assumes a normal distribution.

Args:
- perf: A data frame obtained via model_perf.
- title: An optional string for the title.

Returns:
- A QQ-plot of the residuals from the model against the Normal quantiles.
"""
resid_plot = function (perf::DataFrames.DataFrame; title::String = "")
  qq_plot(perf.error, ylab="Residuals", title=title)
end

"""
  rvf_plot(perf; title)

Plots Std. Residuals versus Fitted values from a linear regression model.

Args:
- perf: A data frame obtained via model_perf.
- title: An optional string for the title.

Returns:
- A Makie plot.
"""
rvf_plot = function (perf::DataFrames.DataFrame; title::String = "")
  fig = Figure()
  ax = Axis(
    fig[1, 1],
    xlabel="Fitted values",
    ylabel="Std Residuals",
    title=title
  )

  layers = visual(
    Scatter, markersize=6, color=:indianred
  ) + smooth()

  p = data(perf) *
      mapping(
        :predicted,
        :std_error
      ) *
      layers * mapping()

  draw!(ax, p)
  hlines!(ax, [-2, 2], linestyle=:dash, color=:cadetblue)
  fig
end

"""
  variance_plot(perf; title)

Plots the square root of the absolute Std. Residuals versus Fitted values from a linear regression model. Diagnostic plot to check on homoscedasticity.

Args:
- perf: A data frame obtained via model_perf.
- title: An optional string for the title.

Returns:
- A Makie plot.
"""
variance_plot = function (perf::DataFrames.DataFrame; title::String = "")
  fig = Figure()
  ax = Axis(
    fig[1, 1],
    xlabel="Fitted values",
    ylabel="√|Std res|",
    title=title
  )

  layers = visual(
    Scatter, markersize=5, color=:indianred
  ) + smooth()

  p = data(perf) *
      mapping(
        :predicted,
        :sqr_error
      ) *
      layers * mapping()

  draw!(ax, p)
  fig
end

"""
  res_lev_plot(perf; title)

Plots the standardised residuals versus leverage from a linear regression model. 

Args:
- perf: A data frame obtained via model_perf.

Returns:
- A Makie plot.
"""
res_lev_plot = function (perf::DataFrames.DataFrame; title::String = "")
  fig = Figure()
  ax = Axis(
    fig[1, 1],
    xlabel="Leverage",
    ylabel="Std residuals",
    title=title
  )

  layers = visual(
    Scatter, markersize=5, color=:indianred
  ) + smooth()

  p = data(perf) *
      mapping(
        :lever,
        :std_error
      ) *
      layers * mapping()

  draw!(ax, p)
  hlines!(ax, [-2, 2], linestyle=:dash, color=:cadetblue)
  fig
end

"""
  cook_lev_plot(perf; title)

Plots Cook's distance versus leverage from a linear regression model. 

Args:
- perf: A data frame obtained via model_perf.
- title: An optional string for the title.

Returns:
- A Makie plot.
"""
cook_lev_plot = function (perf::DataFrames.DataFrame; title::String = "")
  fig = Figure()
  ax = Axis(
    fig[1, 1],
    xlabel="Leverage",
    ylabel="Cook's Distance",
    title=title
  )

  layers = visual(
    Scatter, markersize=5, color=:cadetblue
  )

  p = data(perf) *
      mapping(
        :lever => "Leverage",
        :cook => "Cook's Distance"
      ) *
      layers * mapping()

  draw!(ax, p)
  fig
end

"""
  cooks_plot(perf; title)

Plots Cook's distance of residuals. Diagnostic plot to check on potential outliers.

Args:
- perf: A data frame obtained via model_perf.
- title: An optional string for the title.

Returns:
- A Makie plot.
"""
cooks_plot = function (perf::DataFrames.DataFrame; title::String = "")
  fig = Figure()

  ax = Axis(
    fig[1, 1],
    xlabel="Index",
    ylabel="Cook's Distance",
    title=title
  )

  μ = mean(perf.cook)

  stem!(ax, 1:nrow(perf), perf.cook; markersize=7)
  hlines!(ax, μ, linestyle=:dash, color=:plum)

  fig
end

"""
  qq_plot(df::DataFrames.DataFrame, var::Symbol; ylab::String = "Sample quantiles")

Constructs a QQ-plot against theoretical quartiles from the normal distribution.

Args:
- var: A numerical variable.
- ylab: String to be used for the y-label.
- title: An optional string for the title.

Returns:
- A Makie QQ-Plot.
"""
qq_plot = function (var::Array; ylab::String="Sample quantiles", title::String="")
  fig = Figure()

  ax = Axis(
    fig[1, 1],
    xlabel="Normal quantiles",
    ylabel=ylab,
    title=title
  )

  qqnorm!(ax, var, qqline=:fitrobust, color=:indianred, markersize=6)
  return fig
end

"""
  strip_error(predictor, outcome, df, df_bst; 
    xlab = "Predictor", ylab = "Outcome", title = "")

Constructs a strip chart with error bars on bootstrapped 95% CI around the mean.

Args:
- predictor: A categorical variable: the predictor.
- outcome: A numerical variable: the outcome.
- df: The original data frame.
- df_bst: A data frame with the CI generated via pubh.gen_bst_df.

Returns:
- A Gadfly plot.
"""
strip_error = function (
  predictor,
  outcome,
  df,
  df_bst;
  xlab="Predictor",
  ylab="Outcome",
  title=""
)

  p1 = plot(
    layer(
      df,
      x=predictor,
      y=outcome,
      Geom.beeswarm,
      size=fill(2px, nrow(df)),
      Theme(default_color="MidnightBlue")
    ),
    layer(
      df_bst,
      x=predictor,
      y=outcome,
      ymin=:LowerCI,
      ymax=:UpperCI,
      Geom.point,
      Geom.errorbar,
      Theme(default_color="IndianRed")
    ),
    Guide.xlabel(xlab),
    Guide.ylabel(ylab),
    Guide.title(title)
  )
  return p1
end

"""
  effect_plot(predictor, outcome, df_eff; 
    xlab = "Predictor", ylab = "Outcome", title = "")

Constructs a strip chart with error bars on bootstrapped 95% CI around the mean. Version for effects data frame.

Args:
- predictor: A categorical variable: the predictor.
- outcome: A numerical variable: the outcome.
- df_eff: A data frame with the CI generated via Effects.

Returns:
- A Gadfly plot.
"""
effect_plot = function (
  predictor,
  outcome,
  df_eff;
  xlab::String="Predictor",
  ylab::String="Outcome",
  title::String=""
)

  p1 = plot(
    df_eff,
    x=predictor,
    y=outcome,
    ymin=:lower,
    ymax=:upper,
    Geom.point,
    Geom.errorbar,
    Theme(default_color="IndianRed"),
    Guide.xlabel(xlab),
    Guide.ylabel(ylab),
    Guide.title(title)
  )
  return p1
end

"""
  estat(df, labs)

Calculates, number of non-missing observations, mean, median, standard deviation and relative dispersion of variables contained in the data frame.

Args:
- df: A data frame.
- labs: A vector with the labels to be used as name of the variables. If not provided, the names of the variables in the data frame are used.
    
Returns:
- A data frame with descriptive statistics.
"""
estat = function (df, labs=nothing)
  res = describe(df, non_missing => :n, median => :Median, mean => :Mean, std => :SD, rel_dis => :CV)
  @transform!(res,
    :Median = r3(:Median),
    :Mean = r3(:Mean),
    :SD = r3(:SD),
    :CV = r3(:CV)
  )
  if labs !== nothing
    res.variable = labs
  end
  DataFrames.rename!(res, :variable => :Variable)
  return res
end
