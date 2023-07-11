# This file was generated, do not modify it. # hide
mao = dataset("gap", "mao")
mao |> schema

mao[1:7, 2:6]

describe(mao, :nmissing)