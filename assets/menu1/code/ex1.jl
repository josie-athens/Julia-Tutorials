# This file was generated, do not modify it. # hide
using StatsKit
using DataFramesMeta
using FreqTables
using PrettyTables
using RCall
using RData
using RDatasets
using ScientificTypes: schema

wcgs2 = DataFrame(CSV.File("data/wcgs.csv"))
wcgs2 |> schema