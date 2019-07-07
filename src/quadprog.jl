"""
    quadprog(Q, g, A, b)
Minimize the quadratic problem gᵀ x + ½ xᵀ Q x subject to A*x ≤ b.
"""
function quadprog(Q, g, A, b)
  f(x) = dot(x, Q*x)/2 + dot(g,x)
  con(x) = A*x
  nlp = ADNLPModel(f, zeros(length(g)), c = con, ucon = b)
  output = ipopt(nlp)
  return output
end
