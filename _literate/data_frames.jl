#=
# Data Frames
## Data Manipulation

### Import from CSV
=#

using StatsKit
using DataFrameMacros
using Chain
using FreqTables
using PrettyTables
using RCall
using RData
using RDatasets
using ScientificTypes: schema
include("pubh.jl");

wcgs2 = DataFrame(CSV.File("data/wcgs.csv"))
wcgs2 |> schema

# Dimensions:

wcgs2 |> size

# Names of columns (variables):

wcgs2 |> names

#=
### Import from rds
=#

kfm = load("data/kfm.rds")
kfm |> schema

#=
### Changing names of variables
=#

wcgs = DataFrames.rename!(
	wcgs2,
	:age0 => :age,
	:height0 => :height,
	:weight0 => :weight,
	:sbp0 => :sbp,
	:dbp0 => :dbp,
	:chol0 => :chol,
	:behpat0 => :beh_pat,
	:ncigs0 => :ncigs,
	:dibpat0 => :dib_pat,
	:chd69 => :chd,
	:typechd => :type_chd,
	:time169 => :time,
	:arcus0 => :arcus
);

wcgs[1:5, 2:6]

#=
### Creating Factors
=#

wcgs.chd = categorical(
	recode(wcgs.chd, 0 => "No CHD", 1 => "CHD"), 
	ordered=true
);

wcgs.arcus = categorical(
	recode(wcgs.arcus, 0 => "Absent", 1 => "Present"), 
	ordered=true
);

wcgs.beh_pat = categorical(
	recode(wcgs.beh_pat, 1 => "A1", 2 => "A2", 
		3 => "B1", 4 => "B2"), 
	ordered=true
);

wcgs.dib_pat = categorical(
	recode(wcgs.dib_pat, 0 => "B", 1 => "A"), 
	ordered=true
);

wcgs.type_chd = categorical(
	recode(wcgs.type_chd, 0 => "No CHD", 1 => "MI or SD", 
		2 => "Angina", 3 => "Silent MI"), 
		ordered=true
);

freqtable(wcgs, :chd, :dib_pat)

#=
### Transforming to a binary variable

One of our variables is a count and stores the number of smoked cigarettes/day. We can define a new variable `Smoker` in which, everyone who smokes one or more cigarette/day will be a smoker. One of the easiest ways to create binary variables is to use a conditional statement. For example, the result of `wcgs.ncigs .> 0` is a vector with TRUE and FALSE results.
=#

wcgs.smoker = wcgs.ncigs .> 0;

wcgs.smoker = categorical(
	recode(wcgs.smoker, 0 => "Non-Smoker", 1 => "Smoker"), 
	ordered=true
);

# Contingency table between coronary heart disease and smoking status.

pretty_table(
	freqtable(wcgs, :chd, :smoker);
	row_labels = ["CHD", "No CHD"],
	header = ["Non Smoker", "Smoker"]
)

# An alternative to `freqtable`:

@chain wcgs begin
	groupby([:chd, :smoker])
	combine(nrow => :value)
	unstack(:smoker, :value)
end

# Corresponding proportions:

pretty_table(
	@chain wcgs begin
		freqtable(:chd, :smoker)
		prop(margins = 1)
	end;
	row_labels = ["CHD", "No CHD"],
	header = ["Non Smoker", "Smoker"],
	formatters = ft_printf("%5.2f")
)

# > **Note:** As the outcome is presented in rows, the first row shows the prevalence of coronary heart disese in both unexposed (non-smokers) and exposed (smokers) groups.

#=
### Simple numeric transformations

We also, prefer units in the metric system. We will convert from inches to centimetres and from pounds to kg.
=#

wcgs.height = wcgs.height * 2.54
wcgs.weight = wcgs.weight * 0.4536;

#=
### Centring

We can centre a variable by removings its mean. Let's centre height in `wcgs` as an example.
=#

@transform!(wcgs, :height_cent = @bycol :height .- mean(:height));

@chain wcgs begin
	select(:height, :height_cent)
	describe(:mean, :median, :std)
end

wcgs.height_cent[1:5]

#=
## Indexing and subsets

Let’s said that we are only interested in subjects who are smokers. If that is the case, we can create a new data frame. We can use either, the `subset` function from `DataFramesMeta`.
=#

@subset(wcgs, :smoker .== "Smoker") |> nrow

smokers = @subset(wcgs, :smoker .== "Smoker")
smokers[1:5, 2:6]

# Let's check for the number of observations:

smokers |> nrow

# We can access one of those columns easily using `.colname`, this returns a vector that you can access like any Julia vector:

wcgs.chd[1:5]

# We can also use `select`:

@chain wcgs begin
	select(:ncigs, :smoker)
	first(5)
end

# Or the `@select` macro:

first(
	@select(wcgs, :ncigs, :smoker),
	5
)

# For negative indexing, we use `Not`:

@chain smokers begin
	select(Not([:id, :type_chd, :ncigs, :beh_pat]))
	size
end

#=
> **Note:** In the case of negative indexing, a list of variables is given in vector format; the equivalent to `c`, the concatenate function in `R`.
=#

#=
## Descriptive Statistics

`Statistics` offers a convenient `describe` function which you can use on a data frame to get an overview of the data:
=#

@chain kfm begin
  select(Not(1, 3))
	describe(:min, :max, :mean, :median, :std)
end

#=
We can pass a number of symbols to the `describe` function to indicate which statistics to compute for each feature:

- `mean`, `std`, `min`, `max`, `median`, `first`, `last` are all fairly self explanatory
- `q25`, `q75` are respectively for the 25th and 75th percentile,
- `eltype`, `nunique`, `nmissing` can also be used
=#

#=
> For **`Not`** we define columns by number. If we want to use names, the names of the columuns go inside square brackets.
=#

kfm_tbl = DataFrame(
	@chain kfm begin
		select(Not([:no, :sex, :ml_suppl]))
		describe(:mean, :median, :std, rel_dis => :cv)
	end
);

kfm_tbl.variable = [
	"Breast milk intake (dl/day)",
	"Weight (kg)",
	"Maternal Weight (kg)",
	"Maternal Height (m)"
];

pretty_table(
	kfm_tbl;
	header = ["Variable", "Mean", "Median", "SD", "CV"],
	formatters = ft_printf("%5.2f")
)

#=
### Converting the data

If we want to get the content of the dataframe as one big matrix, use `Matrix`:
=#

kfm_mat = Matrix(
	@chain kfm begin
		select(Not(1, 3, 5))
	end
);

kfm_mat[1:5, :]

# ### Missing values

mao = dataset("gap", "mao")
mao |> schema


# Lots of missing values...

# If we wanted to compute simple functions on columns, they  may just return `missing`:

std(mao.Age)

# Some functions remove missing though:

@chain mao begin
	select(:Age)
	describe(:min, :max, :mean, :median, :std, rel_dis => :cv)
end

# The `skipmissing` and `dropmissing` functions can help counter this:

round(
	std(skipmissing(mao.Age)),
	digits=3
)

#=
## Group manipulations
### Split-Apply-Combine
=#

iris = dataset("datasets", "iris")
iris |> schema

#=
The `groupby` function allows to form sub-dataframes corresponding to groups of rows. This can be very convenient to run specific analyses for specific groups without copying the data.

The basic usage is `groupby(df, cols)` where `cols` specifies one or several columns to use for the grouping.

Consider a simple example: in `iris` there is a `Species` column with 3 species:
=#

@chain iris begin
  select(:Species)
  unique()
end

# We can form views for each of these:

gdf = groupby(iris, :Species)
subdf_setosa = gdf[1]
describe(subdf_setosa, :mean, :median, :std, rel_dis => :cv)

# Or using pipes (`@chain`), without the need of creating subsets:

@chain iris begin
  @subset(:Species .== "setosa")
  select(Not(:Species))
  describe(:mean, :median, :std, rel_dis => :cv)
end