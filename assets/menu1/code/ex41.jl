# This file was generated, do not modify it. # hide
R"""
print(
    energy %>%
    strip_error(expend ~ stature, size=2) %>%
    gf_labs(
        y = "Energy expenditure (MJ)",
        x = "Stature"
    ) %>%
    gf_star(x1=1, x2=2, y1=13.3, y2=13.4, y3=13.5)
)
""";