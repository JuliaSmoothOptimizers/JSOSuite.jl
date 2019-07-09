export linprog

const MatrixOrOperator = Union{AbstractMatrix, AbstractLinearOperator}

"""
    linprog(c; x0, A, blow, bup, Aeq, beq, lvar, uvar)

Minimize cᵀ x subject to any combination of the optional constraints
blow ≤ A x ≤ bup, Aeq x = beq and lvar ≤ x ≤ uvar.
Initial solution is optional and set to zeros by default.
One sided inequalities like A x ≤ bup are equivalent to [-∞,…,-∞] ≤ A x ≤ bup.

"""
function linprog(c::AbstractVector; x0::AbstractVector = zeros(length(c)), A::MatrixOrOperator = zeros(0,0),
         blow::AbstractVector = eltype(x0)[], bup::AbstractVector = eltype(x0)[],
         lvar::AbstractVector = fill(-Inf, length(c)), uvar::AbstractVector = fill(Inf, length(c)),
         Aeq::MatrixOrOperator = zeros(0,0), beq::AbstractVector = eltype(x0)[])
  f(x) = dot(c, x)

  if size(A)[1] == 0
    if size(Aeq)[1] == 0
      nlp = ADNLPModel(f, x0, lvar = lvar, uvar = uvar)
    else
      con = x -> Aeq * x
      nlp = ADNLPModel(f, x0, c = con, lcon = beq, ucon = beq, lvar = lvar, uvar = uvar)
    end
  else
    if size(Aeq)[1] == 0
      con = x -> A * x
      nlp = ADNLPModel(f, x0, c = con, lcon = blow, ucon = bup, lvar = lvar, uvar = uvar)
    else
      con = x -> [A * x; Aeq * x]
      nlp = ADNLPModel(f, x0, c = con, lcon = [blow; beq], ucon = [bup; beq], lvar = lvar, uvar = uvar)
    end
  end
  output = ipopt(nlp, print_level = 0)
  return output
end

"""
    linprog(c, A, blow, bup; x0)

Minimize cᵀ x subject to blow ≤ A x ≤ bup, with optional initial solution x0.
"""
function linprog(c, A, blow, bup; x0 = zeros(length(c)))
  return linprog(c, A = A, blow = blow, bup = bup, x0 = x0)
end

"""
    linprog(c, A, blow, bup, Aeq, beq; x0)

Minimize cᵀ x subject to blow ≤ A x ≤ bup and lvar ≤ x ≤ uvar,
with optional initial solution x0.
"""
function linprog(c, A, blow, bup, Aeq, beq; x0 = zeros(length(c)))
  return linprog(c, A = A, blow = blow, bup = bup, Aeq = Aeq, beq = beq, x0 = x0)
end

"""
    linprog(c, A, blow, bup, Aeq, beq, lvar, uvar; x0)

Minimize cᵀ x subject to blow ≤ A x ≤ bup, lvar ≤ x ≤ uvar, and lvar ≤ x ≤ uvar,
with optional initial solution x0.
"""
function linprog(c, A, blow, bup, Aeq, beq, lvar, uvar; x0 = zeros(length(c)))
  return linprog(c, A = A, blow = blow, bup = bup, Aeq = Aeq, beq = beq, lvar = lvar, uvar = uvar, x0 = x0)
end