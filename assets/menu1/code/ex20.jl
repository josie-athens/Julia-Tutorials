# This file was generated, do not modify it. # hide
let
    plt = data(wcgs) * mapping(:dbp => log10) *
    visual(QQNorm, qqline=:fitrobust, markersize=5)

    draw(
        plt, axis=(xlabel="Normal quantiles",
        ylabel="DBP (mm Hg)", yscale=log10,
        yminorticksvisible = true, yminorgridvisible = true,
        yminorticks = IntervalsBetween(5))
    )
end