# This file was generated, do not modify it. # hide
R"""
birth = $birth
print(
    birth %>%
    strip_error(bwt ~ smoke, pch = ~Race, col = ~Race) %>%
    gf_labs(
        x = "Smoking status",
        y = "Birth weight (g)"
    )
)
""";