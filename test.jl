using StatsBase, Tidier, CSV
using TexTables, RCall, RDatasets
using MLJ
include("pubh.jl");

@rlibrary readr

wcgs = DataFrame(CSV.File("data/wcgs.csv"))
wcgs |> schema |> print

