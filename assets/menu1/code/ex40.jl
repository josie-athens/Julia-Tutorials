# This file was generated, do not modify it. # hide
RCall.ijulia_setdevice(MIME("image/svg+xml"); width=7, height=5)
R"""
require("pubh", quietly=TRUE)
theme_set(sjPlot::theme_sjplot2(base_size = 14))
energy = $energy
print(
    energy %>%
    strip_error(expend ~ stature, size=2) %>%
    gf_labs(
        y = "Energy expenditure (MJ)",
        x = "Stature"
    )
)
""";