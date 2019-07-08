export linprog

const MatrixOrOperator = Union{AbstractMatrix,AbstractLinearOperator}

"""
    linprog(c, A, b)

Minimize the linear problem cᵀ x with constraints A x ≤ b.
"""
function linprog(c::AbstractVector, A::MatrixOrOperator, b::AbstractVector)
  f(x) = dot(c, x)
  con(x) = A*x
  nlp = ADNLPModel(f, zeros(length(c)), c = con, ucon = b)
  output = ipopt(nlp, print_level=0)
  return output
end

function linprog(c::AbstractVector, A::MatrixOrOperator, b::AbstractVector, Aeq::MatrixOrOperator, beq::AbstractVector)
  f(x) = dot(c, x)
  con(x) = [A*x; Aeq*x]
  lcon = [fill(-Inf, length(b)); beq]
  ucon = [b; beq]
  nlp = ADNLPModel(f, zeros(length(c)), c = con, lcon = lcon, ucon = ucon)
  output = ipopt(nlp)
  return output
end
