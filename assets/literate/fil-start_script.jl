# This file was generated, do not modify it.

using StatsKit
using DataFramesMeta
using Memoize
using BenchmarkTools
using HypertextLiteral
include("pubh.jl");

a=3

2a + a^2

θ = 1.34; 2θ # \tetha + tab

π

a² = a*a # a\^2 + tab

if a == 1
  println("It's one Jonny!! It's one!!")
elseif a in (2:5)
  println("It is a $a.")
else
  println("No idea!")
end

a == 3 ? "three" : "other"

a² > 10 ? "Yes!" : "Oh no!"

if a == 3
  μ = 2a
else
  μ = 0
end

@show μ

a == 3 ? ϕ = 3a : ϕ = 0
@show ϕ

a == 3 && "The power of three!"

3a > 10 && "I'm bigger than 10"

ϕ == 9 && @show 2a

3a > 10 || println("Three times $a is less than 10")

isodd(3), iseven(a), a + a, +(a, a), 1 in (1,2), in(1, [1,2,3])

[1:1:4;]

a .+ [1:1:4;]

"""
    add2(x)

adds 2 to the given input and returns the result
"""
add2(x) = x + 2

function add2(x, y)
	x₁ = add2(x)
	y₁ = add2(y)
	return x₁, y₁
end

add2(7), add2(9), add2(100)

add2(1, 2)

func(a::Int) = a+2

begin
	func(a::AbstractFloat) = a/2
	func(a::Rational) = a/11
	func(a::Complex) = sqrt(a)
	func(a, b::String) = "$a, $b"
end

func(20)

func(20.0)

func(3/4)

func(5, "Hola!")

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

@memoize function fibonacci_mem(n)
  if n <= 2
      return 1
    else
      return fibonacci_mem(n - 1) + fibonacci_mem(n - 2)
    end
end

@benchmark fibonacci(30)

@benchmark fibonacci_mem(30)

[1, 2, 3, 4]

[1:1:4;]

[1 2 3 4]

[
  1 2
  3 4
]

Array{String}(undef, (2, 5))

Matrix{String}(undef, (2, 5))

fill(0, (3, 4))

fill(5, (6, 3))

β = [100, 200, 300]

β[2]

β[1]

β[end]

add2.(β)

broadcast(add2, β)

β .== 100

β == 100

β .+ β'

