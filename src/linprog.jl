export linprog

const MatrixOrOperator = Union{AbstractMatrix, AbstractLinearOperator}

"""
    linprog(c; x0, Aineq, blow, bupp, Aeq, beq, lvar, uvar)

Minimize cᵀ x subject to any combination of the optional constraints
blow ≤ Aineq x ≤ bupp, Aeq x = beq and lvar ≤ x ≤ uvar.
Initial solution is optional and set to zeros by default.
One sided inequalities like Aineq x ≤ bupp are equivalent to [-∞,…,-∞] ≤ Aineq x ≤ bupp.

"""
function linprog(c::AbstractVector; x0::AbstractVector = zeros(length(c)), Aineq::MatrixOrOperator = zeros(0, length(c)),
         blow::AbstractVector = eltype(x0)[], bupp::AbstractVector = eltype(x0)[],
         lvar::AbstractVector = fill(-Inf, length(c)), uvar::AbstractVector = fill(Inf, length(c)),
         Aeq::MatrixOrOperator = zeros(0, length(c)), beq::AbstractVector = eltype(x0)[])
  nvar = length(c)
  @assert length(lvar) == nvar && length(uvar) == nvar
  @assert size(Aineq, 2) == nvar && size(Aeq, 2) == nvar
  @assert size(Aineq, 1) == length(blow) && size(Aineq, 1) == length(bupp)
  @assert size(Aeq, 1) == length(beq)

  f(x) = dot(c, x)

  if size(Aineq)[1] == 0
    if size(Aeq)[1] == 0
      nlp = ADNLPModel(f, x0, lvar = lvar, uvar = uvar)
    else
      con = x -> Aeq * x
      nlp = ADNLPModel(f, x0, c = con, lcon = beq, ucon = beq, lvar = lvar, uvar = uvar)
    end
  else
    con = x -> [Aineq * x; Aeq * x]
    nlp = ADNLPModel(f, x0, c = con, lcon = [blow; beq], ucon = [bupp; beq], lvar = lvar, uvar = uvar)
  end
  output = ipopt(nlp, print_level = 0)
  return output
end

"""
    linprog(c, Aineq, blow, bupp; x0)

Minimize cᵀ x subject to blow ≤ Aineq x ≤ bupp, with optional initial solution x0.
"""
function linprog(c, Aineq, blow, bupp; x0 = zeros(length(c)))
  return linprog(c, Aineq = Aineq, blow = blow, bupp = bupp, x0 = x0)
end

"""
    linprog(c, Aineq, blow, bupp, Aeq, beq; x0)

Minimize cᵀ x subject to blow ≤ Aineq x ≤ bupp and lvar ≤ x ≤ uvar,
with optional initial solution x0.
"""
function linprog(c, Aineq, blow, bupp, Aeq, beq; x0 = zeros(length(c)))
  return linprog(c, Aineq = Aineq, blow = blow, bupp = bupp, Aeq = Aeq, beq = beq, x0 = x0)
end

"""
    linprog(c, Aineq, blow, bupp, Aeq, beq, lvar, uvar; x0)

Minimize cᵀ x subject to blow ≤ Aineq x ≤ bupp, lvar ≤ x ≤ uvar, and lvar ≤ x ≤ uvar,
with optional initial solution x0.
"""
function linprog(c, Aineq, blow, bupp, Aeq, beq, lvar, uvar; x0 = zeros(length(c)))
  return linprog(c, Aineq = Aineq, blow = blow, bupp = bupp, Aeq = Aeq, beq = beq, lvar = lvar, uvar = uvar, x0 = x0)
end