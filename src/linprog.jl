export linprog

const MatrixOrOperator = Union{AbstractMatrix,AbstractLinearOperator}

"""
    linprog(c, A, bup)

Minimize the linear problem cᵀ x subject to A x ≤ bup.

    linprog(c, A, bup, blow = blow, uvar = uvar, lvar = lvar, x0 = x0)

Optional arguments allow additional constraints blow ≤ A x ≤ bup and lvar ≤ x ≤ uvar, and initial solution x0.
"""
function linprog(c::AbstractVector, A::MatrixOrOperator, bup::AbstractVector;
				 blow::AbstractVector = fill(-Inf, length(bup)), lvar::AbstractVector = fill(-Inf, length(c)),
				 uvar::AbstractVector = fill(+Inf, length(c)), x0::AbstractVector = zeros(length(c)))
  f(x) = dot(c, x)
  con(x) = A*x
  nlp = ADNLPModel(f, x0, c = con, ucon = bup, lcon = blow, lvar = lvar, uvar = uvar)
  output = ipopt(nlp, print_level=0)
  return output
end

"""
    linprog(c, A, bup, Aeq, beq)

Minimize cᵀ x subject to A x ≤ bup and Aeq x = beq.

    linprog(c, A, bup, Aeq, beq, uvar, lvar)

Minimize cᵀ x subject to A x ≤ bup, Aeq x = beq and lvar ≤ x ≤ uvar.

    linprog(c, A, bup, Aeq, beq, uvar, lvar, blow = blow, x0 = x0)

Optional arguments allow additional constraints blow ≤ A x ≤ bup, Aeq x = beq and lvar ≤ x ≤ uvar, and initial solution x0.
"""
function linprog(c::AbstractVector, A::MatrixOrOperator, bup::AbstractVector, Aeq::MatrixOrOperator, beq::AbstractVector,
				 uvar::AbstractVector = fill(+Inf, length(c)), lvar::AbstractVector = fill(-Inf, length(c));
				 blow::AbstractVector = fill(-Inf, length(bup)), x0::AbstractVector = zeros(length(c)))
  f(x) = dot(c, x)
  con(x) = [A*x; Aeq*x]
  lcon = [blow; beq]
  ucon = [bup; beq]
  nlp = ADNLPModel(f, x0, c = con, ucon = ucon, lcon = lcon, uvar = uvar, lvar = lvar)
  output = ipopt(nlp, print_level=0)
  return output
end