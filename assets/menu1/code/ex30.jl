# This file was generated, do not modify it. # hide
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