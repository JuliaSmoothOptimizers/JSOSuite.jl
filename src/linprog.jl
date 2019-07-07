export linprog

"""
    linprog(c, A, b)

Minimize the linear problem c'*x with constraints A*x ≤ b.
"""
function linprog(c, A, b)
  f(x) = dot(c, x)
  con(x) = A*x
  nlp = ADNLPModel(f, zeros(length(c)), c = con, ucon = b)
  output = ipopt(nlp)
  return output
end
