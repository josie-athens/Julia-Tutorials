# This file was generated, do not modify it. # hide
let
    plt = data(wcgs) * mapping(:dbp) *
    visual(
        QQNorm, qqline=:fitrobust,
        markersize=5, color=:forestgreen
    )

    draw(
        plt, axis=(xlabel="Normal quantiles",
        ylabel="DBP (mm Hg)")
    )
end