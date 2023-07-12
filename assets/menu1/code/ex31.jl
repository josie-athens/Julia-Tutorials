# This file was generated, do not modify it. # hide
@memoize function fibonacci_mem(n)
  if n <= 2
      return 1
    else
      return fibonacci_mem(n - 1) + fibonacci_mem(n - 2)
    end
end