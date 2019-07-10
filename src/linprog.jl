export linprog

const MatrixOrOperator = Union{AbstractMatrix, AbstractLinearOperator}

"""
    linprog(c; x0, Aineq, blow, bupp, Aeq, beq, lvar, uvar)

Minimize cᵀ x subject to any combination of the optional constraints
blow ≤ Aineq x ≤ bupp, Aeq x = beq and lvar ≤ x ≤ uvar.
Initial solution is optional in all methods and set to zeros by default.
"""
function linprog(c::AbstractVector; x0::AbstractVector = zeros(length(c)), Aineq::MatrixOrOperator = zeros(0, length(c)),
                 blow::AbstractVector = fill(-Inf, size(Aineq, 1)), bupp::AbstractVector = fill(Inf, size(Aineq, 1)),
                 lvar::AbstractVector = fill(-Inf, length(c)), uvar::AbstractVector = fill(Inf, length(c)),
                 Aeq::MatrixOrOperator = zeros(0, length(c)), beq::AbstractVector = eltype(x0)[])
  nvar = length(c)
  @assert length(lvar) == length(uvar) == nvar
  @assert size(Aineq, 2) == size(Aeq, 2) == nvar
  @assert size(Aineq, 1) == length(blow) && size(Aineq, 1) == length(bupp)
  @assert size(Aeq, 1) == length(beq)

  f(x) = dot(c, x)
  con = x -> [Aineq * x; Aeq * x]
  nlp = ADNLPModel(f, x0, c = con, lcon = [blow; beq], ucon = [bupp; beq], lvar = lvar, uvar = uvar)
  output = ipopt(nlp, print_level = 0)
  return output
end

"""
    linprog(c, A, b; x0)

Minimize cᵀ x subject to A x ≤ b.
"""
function linprog(c::AbstractVector, A::MatrixOrOperator, b::AbstractVector; x0::AbstractVector = zeros(length(c)))
  return linprog(c, Aineq = A, bupp = b, x0 = x0)
end

"""
    linprog(c, A, b, Aeq, beq; x0)

Minimize cᵀ x subject to A x ≤ b and Aeq x = beq.
"""
function linprog(c::AbstractVector, A::MatrixOrOperator, b::AbstractVector, Aeq::MatrixOrOperator, beq::AbstractVector;
                 x0::AbstractVector = zeros(length(c)))
  return linprog(c, Aineq = A, bupp = b, Aeq = Aeq, beq = beq, x0 = x0)
end

"""
    linprog(c, A, b, lvar, uvar; x0)

Minimize cᵀ x subject to A x ≤ b and lvar ≤ x ≤ uvar.
"""
function linprog(c::AbstractVector, A::MatrixOrOperator, b::AbstractVector,
                 lvar::AbstractVector, uvar::AbstractVector; x0::AbstractVector = zeros(length(c)))
  return linprog(c, Aineq = A, bupp = b, lvar = lvar, uvar = uvar, x0 = x0)
end

"""
    linprog(c, A, b, Aeq, beq, lvar, uvar; x0)

Minimize cᵀ x subject to A x ≤ b, Aeq x = beq and lvar ≤ x ≤ uvar.
"""
function linprog(c::AbstractVector, A::MatrixOrOperator, b::AbstractVector, Aeq::MatrixOrOperator,
                 beq::AbstractVector, lvar::AbstractVector, uvar::AbstractVector; x0::AbstractVector = zeros(length(c)))
  return linprog(c, Aineq = A, bupp = b, Aeq = Aeq, beq = beq, lvar = lvar, uvar = uvar, x0 = x0)
end

"""
    linprog(c, Aineq, blow, bupp; x0)

Minimize cᵀ x subject to blow ≤ Aineq x ≤ bupp.
"""
function linprog(c::AbstractVector, Aineq::MatrixOrOperator, blow::AbstractVector, bupp::AbstractVector;
                 x0::AbstractVector = zeros(length(c)))
  return linprog(c, Aineq = Aineq, blow = blow, bupp = bupp, x0 = x0)
end
