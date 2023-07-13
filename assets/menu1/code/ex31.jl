# This file was generated, do not modify it. # hide
let
    labels = ["Child" "Young" "Mid" "Old"]
    plt = data(flu) *
    mapping(
        :week => "Date",
        [:child, :young, :mid, :old],
        color=dims(1) => renamer(labels) => "Age group"
    ) *
    visual(Lines)
    draw(
        plt,
        axis=(xlabel="Date", ylabel="Number of cases")
    )
end