#=
Julia functions
=#

"""
    rel_dis(x)

Estimates the relative dispersion (coefficient of variation) of a vector.
"""
rel_dis(x) = std(x) / mean(x)


"""
    ci_mean(x, digits)

Estimates the confidence interval for a sample mean
"""
ci_mean = function (x, digits=2)
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

- μ The mean of the variable
- σ The standard deviation of the variable
"""
reference_range = function (μ, σ)
    low = quantile(Normal(μ, σ), 0.025)
    up = quantile(Normal(μ, σ), 0.975)
    ri = [low, up]
    return ri
end
