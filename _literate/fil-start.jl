#=
# Introductory tutorial to Julia

This tutorial will lead you through the 101 of Julia. After it you will be able to create your own Julia functions and understand the key language features like Multiple Dispatch. In other words, you will be able to program in Julia.
=#

using StatsKit
using DataFramesMeta
using Memoize
using BenchmarkTools
using HypertextLiteral
include("pubh.jl");

#=
Julia was build for doing applied math and comes with a simple syntax. You can assign variables by plain `=` like in *Python* or *R*.
=#

a=3

# Let's do some calculations:

2a + a^2

#=
Quite common in Julia is the use of greek symbols and some other cool utf-8 stuff. Typing backslash \ and then the latex name of something, and finish with pressing TAB, you can insert many symbols quite conveniently. Try it out!
=#

θ = 1.34; 2θ # \tetha + tab

# Some variables are already defined:

π

# We can also have super and superscripts.

a² = a*a # a\^2 + tab

#=
## If/Else 

In Julia you have a multiline if/else block and the ternary question mark operator ``?``.
=#

if a == 1
  println("It's one Jonny!! It's one!!")
elseif a in (2:5)
  println("It is a $a.")
else
  println("No idea!")
end

# Using ``?``

a == 3 ? "three" : "other"

# If the comparison is `true` then the first statement happens, else the second statement happens.

a² > 10 ? "Yes!" : "Oh no!"

# Another example:

if a == 3
  μ = 2a
else
  μ = 0
end

# We can use `@show` to be explict on the output:

@show μ

# One more example:

a == 3 ? ϕ = 3a : ϕ = 0
@show ϕ

#=
In addition, we have short-cycling AND `&&`, and OR `||`. In both cases, the first argument has to be a boolean, however the last argument can be anything.

`&&` evaluates and returns the second argument if the first is true.
=#

a == 3 && "The power of three!"

# Otherwise, `&&` returns false.

3a > 10 && "I'm bigger than 10"

# Another example:

ϕ == 9 && @show 2a

# `||` evaluates and returns the second argument if the first is false.

3a > 10 || println("Three times $a is less than 10")

# We see these in loops or functions commonly, where it is combined with `return`, `continue` or `break`.

#=
## Functions

While variables are the synapsis, the brain of Julia are its functions. Really: If you understood functions in Julia, you are ready to work in Julia.

There are many functions available builtin, we already saw a couple of them.

An example of a function:
=#

isodd(3), iseven(a), a + a, +(a, a), 1 in (1,2), in(1, [1,2,3])

# Generating a vector [start:increment:end;]

[1:1:4;]

# We can **broadcast** functions over a vector with a dot:

a .+ [1:1:4;]

# It is relatively simple to define our own functions:

"""
    add2(x)
    
adds 2 to the given input and returns the result
"""
add2(x) = x + 2

# There is a second syntax to create functions which span multiple lines:

function add2(x, y)
	x₁ = add2(x) 
	y₁ = add2(y)
	return x₁, y₁
end

# Here, we are applying the function over only one argument. Note how the output is reported.

add2(7), add2(9), add2(100)

# Here, we apply the function over two arguments:

add2(1, 2)

# There is support for an arbitrary number of positional and keyword arguments. Functions can be overloaded with an arbitrary number of arguments, as well as arbitrary argument types.

func(a::Int) = a+2

# The name of our new function is `func`, in the previous command, when `a` is an integer, adds 2 to the number. Let's add other possibilities:

begin
	func(a::AbstractFloat) = a/2
	func(a::Rational) = a/11
	func(a::Complex) = sqrt(a) 
	func(a, b::String) = "$a, $b"
end

# Let's test our function when `a` is an integer:

func(20)

# But what about if `a` is a float?

func(20.0)

# A rational?

func(3/4)

# Testing the last method:

func(5, "Hola!")

#=
## Memoize and BenchmarkTools

By now, we have everything we need to define our own fibonacci function :) https://en.wikipedia.org/wiki/Fibonacci_number
=#

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

fibonacci(2), fibonacci(3), fibonacci(7), fibonacci(10)

#=
This generates optimal code for small numbers of `n`, however gets quickly out of reach for larger `n`. We can optimize the function by reusing already computed results. A quick trick to do so is to use the ``@memoize`` Macro from the ``Memoize`` package.
=#

@memoize function fibonacci_mem(n)
  if n <= 2
      return 1
    else
      return fibonacci_mem(n - 1) + fibonacci_mem(n - 2)    
    end
end

# With the help of the famous `@benchmark` macro from the `BenchmarkTools` package you can directly compare the time and memory footprint of the two functions.

@benchmark fibonacci(30)

# Now, the benchmark of the memoize version:

@benchmark fibonacci_mem(30)

# Wow, that was fast!! As you can see the memoization kicks in and we have about constant access time.

#=
## Arrays

Arrays are the best supported DataType in Julia, it is multidimensional and highly optimized. You use it as both `list` and `numpy.array` in Python, i.e. no more switching between worlds.
=#

# Create a column vector with respective elements:

[1, 2, 3, 4]

# We generate result using a sequence:

[1:1:4;]

# To create a row vector, we remove the commas:

[1 2 3 4]

# We can create a matrix relatively easy (a small matrix, of course!):

[
  1 2
  3 4
]

# There are many common functions for dealing with Arrays, most importantly for construction. Using `Array`:

Array{String}(undef, (2, 5))

# Using `Matrix`:

Matrix{String}(undef, (2, 5))

# Using fill, first example, all zero values

fill(0, (3, 4))

# A matrix with all elements equal to 5:

fill(5, (6, 3))

# We have index support:

β = [100, 200, 300]

# The second element:

β[2]

# The first element:

β[1]

# The last element!

β[end]

#=
A beautiful aspect of julia is that many many things are not at all hardcoded, but actually have generic implementations under the hood.

One of these is applying a function elementwise to an array, also called **Broadcasting**.
=#

add2.(β)

# The dot syntax translates to:

broadcast(add2, β)

# Evaluate if each element of β is equal to 100:

β .== 100

# If we do not broadcast, the comparison is not by element:

β == 100

# We can *transpose* an Array by using '

β .+ β'