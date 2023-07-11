# This file was generated, do not modify it. # hide
using DataFramesMeta, RCall, RDatasets, RData, FreqTables
using StatsKit, PrettyTables
using ScientificTypes: schema

wcgs2 = DataFrame(CSV.File("data/wcgs.csv"))
wcgs2 |> schema