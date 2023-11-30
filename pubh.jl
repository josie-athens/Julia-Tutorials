#=
Julia functions
=#

hint(text) = Markdown.MD(Markdown.Admonition("hint", "Answer", [text]))

head(df) = first(df, 5)

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
r3(x) = round(x; digits = 3)

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
    SSres = sum((obs - fit).^2)
    SStot = sum((obs .- obm).^2)
    res = 1 - (SSres/SStot)
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
    za = quantile(TDist(n-1), 1 - α + (α/2))
    se = s / sqrt(n)
    ci = [mean(x) - za*se, mean(x) + za*se]
    res = round.(ci, digits = digits)
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
    mape = mean(abs.(df.error/df.observed))
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
    rmse = sqrt(mean(df.error.*df.error))
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
    gps = DF.groupby(df, group)
    y = map(keys(gps)) do key
        collect(skipmissing(gps[key][!, outcome]))
    end
    return y
end

"""
	coef_plot(model, labs; ratio)

Constructs a coefficient plot from a regression model.

Args:
- model: A regression model.
- labs: A vector for the names of the predictors. Order of strings should match the order of the coefficients except the intercept, which should be omitted.
- ratio: Logical. If true, the function exponentiates the results to plot a ratio (e.g. OR in logistic regression). Default is: ratio=false.
		
Returns:
- A makie plot.
"""
coef_plot = function (model, labs; ratio=false)
	
	n = length(coef(model))
	estimate = ratio ? exp.(coef(model)[2:n]) : coef(model)[2:n]
	low = ratio ? exp.(confint(model)[2:n, 1]) : confint(model)[2:n, 1]
	up = ratio ? exp.(confint(model)[2:n, 2]) : confint(model)[2:n, 2]
	n0 = n-1
	x = 1:1:n0
  	
	fig = Figure()
	Axis(
		fig[1, 1],
		ylabel = "Predictors",
		xlabel = ratio ? "Ratio" : "Coefficients",
		yticks=(1:1:n0, labs)
	)
  	
	rangebars!(x, low, up, whiskerwidth=10, direction=:x)
	scatter!(estimate, x, color=:black, markersize=10)
	vlines!(ratio ? 1 : 0, linestyle=:dash, color=:plum)
	fig
end

"""
    model_perf(model)

Generates a data frame with some perfomance related variables like fitted values, total error, Cook's distance and leverage.

Args:
- model: A regression model.

Returns:
- A data frame with performance columns:
    - :observed -> the response variable.
    - :predicted -> the fitted values.
    - :error -> the residuals.
    - :std_error -> the standardized residuals.
    - :cook -> Cook's distances.
    - :lever -> leverages.
"""
model_perf = function (model)
    x = response(model)
    inv = 1/length(x)
    μ = mean(x)
    ssx = (x .- μ).^2
    ssx2 = sum(ssx)
    lev = inv .+ ssx/ssx2
    df = DataFrame(
        observed = response(model), 
        predicted = fitted(model),
        error = residuals(model),
        std_error = StatsBase.standardize(
            ZScoreTransform,
            residuals(model)
        ),
        cook = cooksdistance(model),
        lever = lev
    )
    return df
end

"""
    estat(df, labs)

Calculates, number of non-missing observations, mean, median, standard deviation and relative dispersion of variables contained in dataframe.

Args:
- df: A data frame.
- labs: A vector with the labels to be used as name of the variables. If not provided, the names of the variables in the data frame are used.
    
Returns:
- A data frame with descriptive statistics.
"""
estat = function (df, labs = nothing)
    res = describe(df, non_missing => :n, median => :Median, mean => :Mean, std => :SD, rel_dis => :CV)
    res = Tidier.@mutate(res,
        Median = r3(Median),
        Mean = r3(Mean),
        SD = r3(SD),
        CV = r3(CV)
    )
    if labs !== nothing
      res.variable = labs
    end
    DataFrames.rename!(res, :variable => :Variable)
    return res
end