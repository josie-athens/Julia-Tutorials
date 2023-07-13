# This file was generated, do not modify it. # hide
let
    plt = data(birth) *
    mapping(:bwt) *
    visual(QQNorm, qqline=:fitrobust, markersize=5, color=:firebrick)

    draw(
        plt, axis=(
        xlabel="Normal quantiles",
        ylabel="Birth weight (g)")
    )
end