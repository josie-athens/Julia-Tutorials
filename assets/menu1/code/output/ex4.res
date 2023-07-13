┌──────────┬───────────────────────────────┬─────────────────────────────────────────────────┐
│ names    │ scitypes                      │ types                                           │
├──────────┼───────────────────────────────┼─────────────────────────────────────────────────┤
│ id       │ Count                         │ Int32                                           │
│ age      │ Count                         │ Int32                                           │
│ height   │ Continuous                    │ Float64                                         │
│ weight   │ Continuous                    │ Float64                                         │
│ sbp      │ Count                         │ Int32                                           │
│ dbp      │ Count                         │ Int32                                           │
│ chol     │ Union{Missing, Count}         │ Union{Missing, Int32}                           │
│ beh_pat  │ Multiclass{4}                 │ CategoricalValue{String, UInt8}                 │
│ ncigs    │ Count                         │ Int32                                           │
│ dib_pat  │ Multiclass{2}                 │ CategoricalValue{String, UInt8}                 │
│ chd      │ Multiclass{2}                 │ CategoricalValue{String, UInt8}                 │
│ type_chd │ Multiclass{4}                 │ CategoricalValue{String, UInt8}                 │
│ time     │ Count                         │ Int32                                           │
│ arcus    │ Union{Missing, Multiclass{2}} │ Union{Missing, CategoricalValue{String, UInt8}} │
│ smoker   │ Multiclass{2}                 │ CategoricalValue{String, UInt8}                 │
└──────────┴───────────────────────────────┴─────────────────────────────────────────────────┘
