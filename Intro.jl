### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ e1db0c5e-2221-4462-9c68-4d132146ac3f
using PlutoUI; PlutoUI.TableOfContents(aside=true, title="📚 Contents")

# ╔═╡ 117ad43e-8e0a-413b-9ffc-b44858238a34
using Memoize, BenchmarkTools

# ╔═╡ 01f1594f-8d8b-4e08-a603-cad7ec16a526
using HypertextLiteral

# ╔═╡ dad39f10-160a-11ee-2819-8f36b5de056b
md"""

# Introductory tutorial to Julia

!!! note \"Josie Athens\"

	- Systems Biology Enabling Platform
	- 30 November 2023
"""

# ╔═╡ 148ad253-f75a-4e52-8cc1-a87631617423
md"""
## 📖 Main Menu

[Return to Main Menu](index.html)
"""

# ╔═╡ 33c531e4-de3b-4e55-a686-777cbe291691
md"""
# Basics

## Variables

Julia was build for doing applied math and comes with a simple syntax. You can assign variables by plain `=` like in *Python* or *R*.
"""

# ╔═╡ 8d43f3b9-b0af-4f0f-9608-8d64b1fb0648
a = 3

# ╔═╡ 11dcb3e3-4931-43dd-b27f-3a3f814eca45
md"Let's do some calculations."

# ╔═╡ e8b7c664-8c90-4f9f-b449-e3ebade12e00
2a + a^2

# ╔═╡ 67537955-9ff0-401f-8ed8-204963495859
md"Quite common in Julia is the use of greek symbols and some other cool utf-8 stuff. Typing backslash \ and then the latex name of something, and finish with pressing TAB, you can insert many symbols quite conveniently. Try it out!"

# ╔═╡ 9612ba96-fd98-4295-8503-ba38aefa52f5
θ = 1.34; 2θ

# ╔═╡ 278d3d53-c99f-41fb-b563-f120bbfda4d8
π

# ╔═╡ 343b7d62-339d-4086-9b00-028e8cc9783e
a² = a*a  # a\^2

# ╔═╡ d5a837b8-3a5a-4fd9-b5bf-2e82196a8f53
md"## If/Else 
In Julia you have a multiline if/else block and the ternary question mark operator ``?``."

# ╔═╡ 0f84cb4e-29f3-4647-b4d6-b4a07d91eb93
if a == 1
	println("It's one Jonny!! It's one!!")
elseif a in (2,3,4,5)
	println("It is a $a.")
else
	println("No idea!")
end

# ╔═╡ c895d0ea-fb09-460a-8c3c-de3a0941fbdd
a

# ╔═╡ e76bbf6c-00bf-4115-a34b-7c238f266b3b
a == 3 ? "three" : "other"

# ╔═╡ cd7814f6-abec-4b6b-a6cb-d3f62fe3a6d7
a² > 10 ? "Yes!" : "Oh no!"

# ╔═╡ e740b018-a47a-4ec9-9f42-b3f9c7aef724
if a == 3
  μ = 2a
else
  μ = 0
end

# ╔═╡ f75892f6-8c9c-49ef-9845-a6bfc16df9ec
@show μ

# ╔═╡ 57e96f1a-24ef-4c19-a212-620b8fb00f07
a == 3 ? ϕ = 3a : ϕ = 0; @show ϕ

# ╔═╡ aa5d2329-7dfc-4017-a55b-0acc24ba8085
md"""
In addition you have short-cycling AND `&&`, and OR `||`. In both cases, the first argument has to be a boolean, however the last argument can be anything.

`&&` evaluates and returns the second argument if the first is true.
"""

# ╔═╡ 58909f82-9c02-44a7-8df8-1a05bb09cd49
true && 1

# ╔═╡ 4734d8c3-5a3b-479b-85dd-128d5e5bdf34
a == 3 && "The power of three!"

# ╔═╡ 9b2b2ad0-7801-41bd-83e3-cceca2355725
md"Otherwise, `&&` returns false."

# ╔═╡ 8dfb24fc-1a23-412c-a925-fa37df6c0cb5
false && 1

# ╔═╡ 64f31aaa-f8f5-4650-8626-5194fa4ec30d
3a > 10 && "I'm bigger than 10"

# ╔═╡ 841755e3-dd55-4f4a-ae04-9f889fba1383
μ == 9 && @show a

# ╔═╡ 44b8eb6a-6e67-47a6-b286-98b3e08ede5d
ϕ == 9 && @show 2a

# ╔═╡ 097d1036-35ac-48b9-a00e-a76c10b968f2
md"`||` evaluates and returns the second argument if the first is false."

# ╔═╡ 1e4b0f32-024f-4151-8297-346c83a10e34
returnvalue = false || println("Note that `nothing` is returned")

# ╔═╡ 13429994-4ef8-406a-9683-ae5ce33f2832
returnvalue == nothing

# ╔═╡ 4a6e096b-7f47-4de1-a5cb-7577ffa6bdbd
3a > 10 || println("Three times $a is less than 10")

# ╔═╡ ef66021f-14ab-49b7-941a-ba03d4d08acd
md"We see these in loops or functions commonly, where it is combined with `return`, `continue` or `break`."

# ╔═╡ 6e4f311c-b998-4025-8870-fae95076f89a
md"""
## Functions

While variables are the synapsis, the brain of Julia are its functions. Really: If you understood functions in Julia, you are ready to work in Julia.

There are many functions available builtin, we already saw a couple of them.
"""

# ╔═╡ c1d95835-dd3d-4732-8ba8-0b518af7fda1
isodd(3), iseven(a), a + a, +(a, a), 1 in (1,2), in(1, [1,2,3])

# ╔═╡ 8972c871-3610-4ab8-a285-e955c5f56a60
md"Generating a vector `[start:increment:end;]`,"

# ╔═╡ 1a4fd325-1c5b-464f-8386-48ae53ec622c
[1:1:4;]

# ╔═╡ 8ca76d6a-ba5d-4a09-8c64-78e863ab8f45
md"We can **broadcast** functions over a vector with a dot:"

# ╔═╡ e2c380a0-a7c5-44dc-9182-5f9a47477858
a .+ [1:1:4;]

# ╔═╡ 814ff8d1-a524-4a88-aec8-4d52e0eac399
md"It is relatively simple to define our own functions"

# ╔═╡ b25d10d8-13da-47e2-9f3b-6d32489bfab3
"""
    add2(x)
    
adds 2 to the given input and returns the result
"""
add2(x) = x + 2

# ╔═╡ c9b7750f-71aa-4b8a-9f79-9d898299ab25
md"Now, let's actually run the function."

# ╔═╡ eb168a44-d441-4d8e-b5ca-d0861da24485
md"There is a second syntax to create functions which span multiple lines:"

# ╔═╡ 6d7b1d51-4482-4264-969a-412cbfd256a2
function add2(x, y)
	x′ = add2(x) # x\prime
	y′ = add2(y)
	return x′, y′
end

# ╔═╡ 00464137-e763-4243-9430-eca5357ada67
add2(7), add2(9), add2(100)

# ╔═╡ 92a110ab-75e6-4cec-b7c7-812fbce28bd7
add2(1, 2)

# ╔═╡ 6d352a0c-3a97-4377-92fe-36fb3572fba0
md"There is support for an arbitrary number of positional and keyword arguments. Functions can be overloaded with an arbitrary number of arguments, as well as arbitrary argument types."

# ╔═╡ 06075c8a-002c-484d-93b2-16ad3e2f5ece
func(a::Int) = a+2

# ╔═╡ 77bfc702-50d2-42ee-9641-545c78d803e3
begin
	func(a::AbstractFloat) = a/2
	func(a::Rational) = a/11
	func(a::Complex) = sqrt(a) 
	func(a, b::String) = "$a, $b"
end

# ╔═╡ f73cb8f7-2d57-4f4a-89a7-22dd27c3aaca
md"Let's test our function when `a` is an integer:"

# ╔═╡ 8c3e3f38-aaa0-4075-a26c-8c90595f8ba2
md"But what about if `a` is a float?"

# ╔═╡ 8af8d8c2-5aea-4a20-a415-3a8076ed47d6
md"A rational?"

# ╔═╡ b4801d00-c761-4a92-aee0-101d053f0ac4
md"We have full support for working with true rational numbers."

# ╔═╡ 4aac4ca7-f69a-4b5e-afda-a267f3ff26d9
md"""
# Memoize and BenchmarkTools

By now, we have everything you need to define your own fibonacci function :) https://en.wikipedia.org/wiki/Fibonacci_number
"""

# ╔═╡ ca134076-afae-49fc-90d4-a516be012ada
"""
  fibonacci(n)

Returns the nth fibonacci number
"""
function fibonacci(n)
  if n <= 2
    return 1
  else
    return fibonacci(n - 1) + fibonacci(n - 2)    
  end
end

# ╔═╡ b513431c-cded-4e81-95d6-647c66546b58
fibonacci(2)

# ╔═╡ 0194b123-4334-4742-ba17-a20d864f5b96
fibonacci(3)

# ╔═╡ dc88eb03-712e-4f19-80b3-18f9cffe0230
fibonacci(7), fibonacci(10)

# ╔═╡ 7d55420a-5ca2-4284-b78c-672d44ee9fc8
md"This generates optimal code for small numbers of `n`, however gets quickly out of reach for larger `n` (for 45 it takes about 7 seconds for me). We can optimize the function by reusing already computed results. A quick trick to do so is to use the ``@memoize`` Macro from the ``Memoize`` package."

# ╔═╡ 235237f9-9ae4-497b-a7d8-8fe7dd10cf1c
@memoize function fibonacci_mem(n)
    if n <= 2
        return 1
      else
        return fibonacci_mem(n - 1) + fibonacci_mem(n - 2)    
      end
end

# ╔═╡ 39289f20-9e98-4622-b367-eb8da20d7f85
md"With the help of the famous `@benchmark` macro from the `BenchmarkTools` package you can directly compare the time and memory footprint of the two functions."

# ╔═╡ d7958e96-d001-4d94-ba85-1d78abd40eff
@benchmark fibonacci(30)

# ╔═╡ 7d3501ec-2166-4a63-9f93-dc3d6fd8b914
@benchmark fibonacci_mem(30)

# ╔═╡ e5fe7f37-6976-43c8-8839-bc7b283d9cef
md"As you can see the memoization kicks in and we have about constant access time."

# ╔═╡ 4c3dc062-0caf-4de9-be90-dd015bf5ae1e
md"""
## Arrays

Arrays are the best supported DataType in Julia, it is multidimensional and highly optimized. You use it as both `list` and `numpy.array` in Python, i.e. no more switching between worlds.
"""

# ╔═╡ 29345dc7-9200-4a5e-bf5f-92043318a0b6
[1, 2, 3, 4]  # create column vector with respective elements

# ╔═╡ 4823bbc9-4ab9-4ebf-bb6c-838c8fb8b33c
[1:1:4;]

# ╔═╡ 4d56fb91-e955-44ef-9fc2-ec31119bb40c
[1 2 3 4]  # horizontally concatinate elements separated by space

# ╔═╡ 44a52975-ad15-4a9e-bba1-63a43d99bd56
[1
 2
 3
 4]  # vertically concatinate elements separated by newline

# ╔═╡ fed92120-13a9-4c57-bf6f-63f738b1609f
[1; 2; 3; 4]  # vertically concatinate elements separated by semicolon

# ╔═╡ cf67741e-1f91-4827-a96b-9bf5e131268e
# TODO create matrix with first row consisting of 1 & 2 and second row of 3 & 4
[1 2
 3 4]

# ╔═╡ f2208e8a-8bef-402b-a712-13d8be531679
md"There are many common functions for dealing with Arrays, most importantly for construction."

# ╔═╡ 536f71a3-4b29-4a2a-9160-5fa06a5f5dc5
Array{String}(undef, (2, 5))

# ╔═╡ 24e3d044-b53b-49a9-a43b-cee1f1007887
Matrix{String}(undef, (3, 4))

# ╔═╡ 78f71b25-84eb-4e7c-b9b2-bc2ad707fbe1
fill(5, (3, 4))

# ╔═╡ 98228a3a-a51e-42ae-abea-b9e110e9a043
md"We have index support."

# ╔═╡ fda0626f-9901-4b5e-84fa-56d2026b931b
α = [100, 200, 300]

# ╔═╡ e431e99f-7f29-486c-a407-f15a3450b0c8
α[1] # the first element

# ╔═╡ c869ff5d-3c74-475f-b3e5-0e223a34e6a3
α[end] # the last element

# ╔═╡ 7443d7ce-0e16-4809-9882-508cc1c66a7b
md"""
A beautiful aspect of julia is that many many things are not at all hardcoded, but actually have generic implementations under the hood.

One of these is applying a function elementwise to an array, also called *Broadcasting*.
"""

# ╔═╡ 8e983865-bb43-4b10-8477-21d35894270f
add2.(α)

# ╔═╡ 083bb060-f4c8-4997-a571-07e61b95e1a1
c = [7, 9, 100]

# ╔═╡ 16c6231b-d040-4150-9dc0-36c7159cd816
add2.(c)

# ╔═╡ 1afd2b37-a174-407d-9045-a3d3abcc6d53
# the dot syntax translates to
broadcast(add2, α)

# ╔═╡ 0d2205e1-1133-490a-acd0-aa56c4eb2ecd
α .== 100

# ╔═╡ b7b32acf-6018-4f1d-85de-39883048e82c
α == 100

# ╔═╡ c4e94a08-a8b2-4029-ad71-ebc7f94dd199
md"""
We can transpose an Array by using '
"""

# ╔═╡ 5b8d981a-25ec-43cd-b2bc-9a4c13dd9515
α .+ α'

# ╔═╡ 81b211ba-b8f5-4604-9ca5-a5c7d06db571
md"""
Unlike `Numpy` in `Python`, Julia's Arrays can hold any type of data.
"""

# ╔═╡ cefee368-aa7c-4984-b2d0-16276e3d3c43
mycombine(a, b) = (a, b, [a + b])

# ╔═╡ 06a420f6-03f3-4f15-952c-0bdb15f22657
mycombine.(α, α')

# ╔═╡ 8ea7613c-accd-4181-8d9d-22eccf5a707a
md"Alternatively, we can construct the same with a *multi-dimensional* for comprehension."

# ╔═╡ 056a8da7-a2ad-473c-b5e8-9360fd587f96
[mycombine(x, y) for x in α, y in α]

# ╔═╡ 66680509-65e2-44b4-aef9-908a13f3c5fc
md"We can see that perfomance improved drastically, while now having a memory footprint on each call."

# ╔═╡ f1645ccb-5c05-4b15-9afa-466df79a3582
md"""
# NamedTuples & Structs

In practice we often have a bunch of variables we need to handle at once. 
- In julia we can construct our own types for this, but they may be a bit clumsy at times.
- Luckily there is also a simple way to use the alternative: *named tuples*, which we can use for fast development.

We already saw *tuples* and tuple destructing.
"""

# ╔═╡ 8d7cb385-4726-4db0-835c-a113c7339f79
x, y = (1, 2)

# ╔═╡ 9afdcf98-3852-4f89-a118-addf52b66802
x + y

# ╔═╡ fe78d986-9cb8-4974-8b27-6326980fcf75
md"We can also give name to tuples:"

# ╔═╡ 7ba3f58a-3c04-4424-ab81-739a22c6ac22
namedtuple = (key=1, value=2)

# ╔═╡ f3674eae-d8d6-4be5-a2f4-108f58c5b982
namedtuple.key

# ╔═╡ 9bc66daf-9c4b-4867-9f35-1f5123d15179
md"""
## Struct
This is one of the most useful tools for fast prototyping. There is even no performance penalty in using namedtuples, actually it is able to create optimal code.

In case we want to define our own types for a more stable interface between different parts of our code you can use `struct`.
"""

# ╔═╡ 1044e5f9-3be5-46e4-b5bc-e3ef72a3432c
struct MyType
    key::Int        # always specify the types by prepending ::
    value::String
end

# ╔═╡ 75cd9335-8cf8-49ac-8fe9-39ed51ae1368
MyType(3, "hi").value  # TODO construct MyType with other arguments

# ╔═╡ d7f6a76c-b0a5-4528-9ea1-5258e2894d91
md"If we want flexible types, the best way is to parameterise the types."

# ╔═╡ 172a5879-cf3f-41a9-8232-29ce1386a690
struct MyType2{Key, Value}
    key::Key
    value::Value
end

# ╔═╡ 61b7f4ff-ba68-47fb-b172-3ea63f57aaf1
MyType2("yeah", true)  # you see the types are automatically inferred

# ╔═╡ 71c79745-ce8d-4fea-bb38-de0861de3451
MyType2("yeah", true).key

# ╔═╡ 5cb5e072-8407-41aa-9769-8157d5485a0a
md"""
There is also the alternative of not specifying types at all

```julia
struct MyType3
    key
    value
end
```

Which is equivalent to specifying

```julia
struct MyType3
    key::Any
    value::Any
end
```

> Very important to know is that this leads to pour type inference and hence pourer performance. If we run `MyType3(1, "value").key` julia does not know any longer that the key is actually of type Int,  this was forgotten when wrapped into the `MyType3`. Hence not much code optimization can be done.

Always prefer to parameterise types, as it is not much work and gives optimal performance.
"""

# ╔═╡ 124cff95-6c2f-45e9-9782-d7366651dc6e
func(a::MyType2) = "$(a.key): $(a.value)"

# ╔═╡ 8d9cf21a-acc0-4b56-b45d-5b588bc8df88
func(20)

# ╔═╡ ce5d5ea0-7bb2-4f46-b814-a7658e299e48
func(20.0)

# ╔═╡ 2100c3f9-3208-47c0-871d-133bc215e8a3
func(3/4)

# ╔═╡ b02c3331-c6ce-42ec-b2ae-2e4d17b8f8bf
func(33//4)

# ╔═╡ 9cd54e93-1e6b-460d-a2b7-9f95eb2b01a0
func(-2 + 0im)

# ╔═╡ 1a5cdffe-eac0-44ff-a2b3-d1924f80ade4
func(5, "Hola")

# ╔═╡ 076bf04b-1d0e-4d06-9d39-e2764730ce5e
md"""
> We can overload functions with our own types, actually, any funtion, also those defined by other packages including Julia bultin functions.
"""

# ╔═╡ eb6c24d1-1457-447d-95e7-05f130a22dd9
func(MyType2(42, "Multiple Dispatch this is called, and it is the answer to almost everything"))

# ╔═╡ 3984e8ce-00ef-413f-afd6-2fc7b86b50f6
md"# Loops"

# ╔═╡ 76c9b3a1-facb-4564-b108-edb36bc5021d
for i in 1:4
    println(i)
end

# ╔═╡ ddd8cb87-1acc-42ac-a416-6146002d3645
md"""
!!! danger

	However what does not work is adapting GLOBAL variables within a loop. It does not work within scripts and not in the Julia shell. Surprisingly, and conveniently, it works in the Jupyter Notebook though ;-)
"""

# ╔═╡ bb528f9e-152a-4602-bf34-4f7bcbd0f5f2
let
	a = 0
	for i in 1:4
		a += i
	end
	a
end

# ╔═╡ eb86f1d1-e331-4e80-8372-14bf782cfd9d
1+2+3+4

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Memoize = "c03570c3-d221-55d1-a50c-7939bbd78826"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.3.2"
HypertextLiteral = "~0.9.4"
Memoize = "~0.4.4"
PlutoUI = "~0.7.51"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "658f772138d771cfcbf25a60982c7a957eebf69d"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "4b2e829ee66d4218e0cef22c0a64ee37cf258c29"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─dad39f10-160a-11ee-2819-8f36b5de056b
# ╟─148ad253-f75a-4e52-8cc1-a87631617423
# ╠═e1db0c5e-2221-4462-9c68-4d132146ac3f
# ╠═117ad43e-8e0a-413b-9ffc-b44858238a34
# ╟─33c531e4-de3b-4e55-a686-777cbe291691
# ╠═8d43f3b9-b0af-4f0f-9608-8d64b1fb0648
# ╟─11dcb3e3-4931-43dd-b27f-3a3f814eca45
# ╠═e8b7c664-8c90-4f9f-b449-e3ebade12e00
# ╟─67537955-9ff0-401f-8ed8-204963495859
# ╠═9612ba96-fd98-4295-8503-ba38aefa52f5
# ╠═278d3d53-c99f-41fb-b563-f120bbfda4d8
# ╠═343b7d62-339d-4086-9b00-028e8cc9783e
# ╟─d5a837b8-3a5a-4fd9-b5bf-2e82196a8f53
# ╠═0f84cb4e-29f3-4647-b4d6-b4a07d91eb93
# ╠═c895d0ea-fb09-460a-8c3c-de3a0941fbdd
# ╠═e76bbf6c-00bf-4115-a34b-7c238f266b3b
# ╠═cd7814f6-abec-4b6b-a6cb-d3f62fe3a6d7
# ╠═e740b018-a47a-4ec9-9f42-b3f9c7aef724
# ╠═f75892f6-8c9c-49ef-9845-a6bfc16df9ec
# ╠═57e96f1a-24ef-4c19-a212-620b8fb00f07
# ╟─aa5d2329-7dfc-4017-a55b-0acc24ba8085
# ╠═58909f82-9c02-44a7-8df8-1a05bb09cd49
# ╠═4734d8c3-5a3b-479b-85dd-128d5e5bdf34
# ╟─9b2b2ad0-7801-41bd-83e3-cceca2355725
# ╠═8dfb24fc-1a23-412c-a925-fa37df6c0cb5
# ╠═64f31aaa-f8f5-4650-8626-5194fa4ec30d
# ╠═841755e3-dd55-4f4a-ae04-9f889fba1383
# ╠═44b8eb6a-6e67-47a6-b286-98b3e08ede5d
# ╟─097d1036-35ac-48b9-a00e-a76c10b968f2
# ╠═1e4b0f32-024f-4151-8297-346c83a10e34
# ╠═13429994-4ef8-406a-9683-ae5ce33f2832
# ╠═4a6e096b-7f47-4de1-a5cb-7577ffa6bdbd
# ╟─ef66021f-14ab-49b7-941a-ba03d4d08acd
# ╟─6e4f311c-b998-4025-8870-fae95076f89a
# ╠═c1d95835-dd3d-4732-8ba8-0b518af7fda1
# ╟─8972c871-3610-4ab8-a285-e955c5f56a60
# ╠═1a4fd325-1c5b-464f-8386-48ae53ec622c
# ╟─8ca76d6a-ba5d-4a09-8c64-78e863ab8f45
# ╠═e2c380a0-a7c5-44dc-9182-5f9a47477858
# ╟─814ff8d1-a524-4a88-aec8-4d52e0eac399
# ╠═b25d10d8-13da-47e2-9f3b-6d32489bfab3
# ╟─c9b7750f-71aa-4b8a-9f79-9d898299ab25
# ╠═00464137-e763-4243-9430-eca5357ada67
# ╟─eb168a44-d441-4d8e-b5ca-d0861da24485
# ╠═6d7b1d51-4482-4264-969a-412cbfd256a2
# ╠═92a110ab-75e6-4cec-b7c7-812fbce28bd7
# ╟─6d352a0c-3a97-4377-92fe-36fb3572fba0
# ╠═06075c8a-002c-484d-93b2-16ad3e2f5ece
# ╠═77bfc702-50d2-42ee-9641-545c78d803e3
# ╟─f73cb8f7-2d57-4f4a-89a7-22dd27c3aaca
# ╠═8d9cf21a-acc0-4b56-b45d-5b588bc8df88
# ╟─8c3e3f38-aaa0-4075-a26c-8c90595f8ba2
# ╠═ce5d5ea0-7bb2-4f46-b814-a7658e299e48
# ╟─8af8d8c2-5aea-4a20-a415-3a8076ed47d6
# ╠═2100c3f9-3208-47c0-871d-133bc215e8a3
# ╟─b4801d00-c761-4a92-aee0-101d053f0ac4
# ╠═b02c3331-c6ce-42ec-b2ae-2e4d17b8f8bf
# ╠═9cd54e93-1e6b-460d-a2b7-9f95eb2b01a0
# ╠═1a5cdffe-eac0-44ff-a2b3-d1924f80ade4
# ╟─4aac4ca7-f69a-4b5e-afda-a267f3ff26d9
# ╠═ca134076-afae-49fc-90d4-a516be012ada
# ╠═b513431c-cded-4e81-95d6-647c66546b58
# ╠═0194b123-4334-4742-ba17-a20d864f5b96
# ╠═dc88eb03-712e-4f19-80b3-18f9cffe0230
# ╟─7d55420a-5ca2-4284-b78c-672d44ee9fc8
# ╠═235237f9-9ae4-497b-a7d8-8fe7dd10cf1c
# ╟─39289f20-9e98-4622-b367-eb8da20d7f85
# ╠═d7958e96-d001-4d94-ba85-1d78abd40eff
# ╠═7d3501ec-2166-4a63-9f93-dc3d6fd8b914
# ╟─e5fe7f37-6976-43c8-8839-bc7b283d9cef
# ╟─4c3dc062-0caf-4de9-be90-dd015bf5ae1e
# ╠═29345dc7-9200-4a5e-bf5f-92043318a0b6
# ╠═4823bbc9-4ab9-4ebf-bb6c-838c8fb8b33c
# ╠═4d56fb91-e955-44ef-9fc2-ec31119bb40c
# ╠═44a52975-ad15-4a9e-bba1-63a43d99bd56
# ╠═fed92120-13a9-4c57-bf6f-63f738b1609f
# ╠═cf67741e-1f91-4827-a96b-9bf5e131268e
# ╟─f2208e8a-8bef-402b-a712-13d8be531679
# ╠═536f71a3-4b29-4a2a-9160-5fa06a5f5dc5
# ╠═24e3d044-b53b-49a9-a43b-cee1f1007887
# ╠═78f71b25-84eb-4e7c-b9b2-bc2ad707fbe1
# ╟─98228a3a-a51e-42ae-abea-b9e110e9a043
# ╠═fda0626f-9901-4b5e-84fa-56d2026b931b
# ╠═e431e99f-7f29-486c-a407-f15a3450b0c8
# ╠═c869ff5d-3c74-475f-b3e5-0e223a34e6a3
# ╠═01f1594f-8d8b-4e08-a603-cad7ec16a526
# ╟─7443d7ce-0e16-4809-9882-508cc1c66a7b
# ╠═8e983865-bb43-4b10-8477-21d35894270f
# ╠═083bb060-f4c8-4997-a571-07e61b95e1a1
# ╠═16c6231b-d040-4150-9dc0-36c7159cd816
# ╠═1afd2b37-a174-407d-9045-a3d3abcc6d53
# ╠═0d2205e1-1133-490a-acd0-aa56c4eb2ecd
# ╠═b7b32acf-6018-4f1d-85de-39883048e82c
# ╟─c4e94a08-a8b2-4029-ad71-ebc7f94dd199
# ╠═5b8d981a-25ec-43cd-b2bc-9a4c13dd9515
# ╟─81b211ba-b8f5-4604-9ca5-a5c7d06db571
# ╠═cefee368-aa7c-4984-b2d0-16276e3d3c43
# ╠═06a420f6-03f3-4f15-952c-0bdb15f22657
# ╟─8ea7613c-accd-4181-8d9d-22eccf5a707a
# ╠═056a8da7-a2ad-473c-b5e8-9360fd587f96
# ╟─66680509-65e2-44b4-aef9-908a13f3c5fc
# ╟─f1645ccb-5c05-4b15-9afa-466df79a3582
# ╠═8d7cb385-4726-4db0-835c-a113c7339f79
# ╠═9afdcf98-3852-4f89-a118-addf52b66802
# ╟─fe78d986-9cb8-4974-8b27-6326980fcf75
# ╠═7ba3f58a-3c04-4424-ab81-739a22c6ac22
# ╠═f3674eae-d8d6-4be5-a2f4-108f58c5b982
# ╟─9bc66daf-9c4b-4867-9f35-1f5123d15179
# ╠═1044e5f9-3be5-46e4-b5bc-e3ef72a3432c
# ╠═75cd9335-8cf8-49ac-8fe9-39ed51ae1368
# ╟─d7f6a76c-b0a5-4528-9ea1-5258e2894d91
# ╠═172a5879-cf3f-41a9-8232-29ce1386a690
# ╠═61b7f4ff-ba68-47fb-b172-3ea63f57aaf1
# ╠═71c79745-ce8d-4fea-bb38-de0861de3451
# ╟─5cb5e072-8407-41aa-9769-8157d5485a0a
# ╠═124cff95-6c2f-45e9-9782-d7366651dc6e
# ╟─076bf04b-1d0e-4d06-9d39-e2764730ce5e
# ╠═eb6c24d1-1457-447d-95e7-05f130a22dd9
# ╟─3984e8ce-00ef-413f-afd6-2fc7b86b50f6
# ╠═76c9b3a1-facb-4564-b108-edb36bc5021d
# ╟─ddd8cb87-1acc-42ac-a416-6146002d3645
# ╠═bb528f9e-152a-4602-bf34-4f7bcbd0f5f2
# ╠═eb86f1d1-e331-4e80-8372-14bf782cfd9d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
