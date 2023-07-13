# This file was generated, do not modify it. # hide
let
    plt = data(wcgs) * mapping(:dbp => log10) *
    visual(QQNorm, qqline=:fitrobust, markersize=5)

    draw(
        plt, axis=(xlabel="Normal quantiles",
        ylabel="log (DBP)", yscale=Makie.pseudolog10)
    )
end