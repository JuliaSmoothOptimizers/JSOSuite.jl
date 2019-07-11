export quadprog

const MatrixOrOperator = Union{AbstractMatrix, AbstractLinearOperator}

"""
    quadprog(Q, c; x0, Aineq, blow, bupp, Aeq, beq, lvar, uvar)
Minimize the quadratic problem gᵀ x + ½ xᵀ Q x subject to A*x ≤ b.
"""
function quadprog(Q::AbstractMatrix, g::AbstractVector;
                  x0::AbstractVector = zeros(length(g)), Aineq::MatrixOrOperator = zeros(0, length(g)),
                  blow::AbstractVector = fill(-Inf, size(Aineq, 1)), bupp::AbstractVector = fill(Inf, size(Aineq, 1)),
                  lvar::AbstractVector = fill(-Inf, length(g)), uvar::AbstractVector = fill(Inf, length(g)),
                  Aeq::MatrixOrOperator = zeros(0, length(g)), beq::AbstractVector = eltype(x0)[])
  nvar = length(g)
  @assert size(Q, 1) == size(Q, 2) == nvar
  @assert length(lvar) == length(uvar) == nvar
  @assert size(Aineq, 2) == size(Aeq, 2) == nvar
  @assert size(Aineq, 1) == length(blow) && size(Aineq, 1) == length(bupp)
  @assert size(Aeq, 1) == length(beq)
  f(x) = dot(x, Q*x)/2 + dot(g,x)
  con = x -> [Aineq * x; Aeq * x]
  nlp = ADNLPModel(f, x0, c = con, lcon = [blow; beq], ucon = [bupp; beq], lvar = lvar, uvar = uvar)
  output = ipopt(nlp, print_level=0)
  return output
end

"""
    quadprog(Q, g; x0)

Minimize gᵀ x + ½ xᵀ Q x without any constraints.
"""
function quadprog(Q::AbstractMatrix, g::AbstractVector, A::MatrixOrOperator, b::AbstractVector; x0::AbstractVector = zeros(length(g)))
  return quadprog(Q, g, x0 = x0)
end

"""
    quadprog(Q, g, A, b; x0)

Minimize gᵀ x + ½ xᵀ Q x subject to A x ≤ b.
"""
function quadprog(Q::AbstractMatrix, g::AbstractVector, A::MatrixOrOperator, b::AbstractVector; x0::AbstractVector = zeros(length(g)))
  return quadprog(Q, g, Aineq = A, bupp = b, x0 = x0)
end

"""
    quadprog(Q, g, A, b, Aeq, beq; x0)

Minimize gᵀ x + ½ xᵀ Q x subject to A x ≤ b and Aeq x = beq.
"""
function quadprog(Q::AbstractMatrix, g::AbstractVector, A::MatrixOrOperator, b::AbstractVector, Aeq::MatrixOrOperator, beq::AbstractVector;
                  x0::AbstractVector = zeros(length(g)))
  return quadprog(Q, g, Aineq = A, bupp = b, Aeq = Aeq, beq = beq, x0 = x0)
end

"""
    quadprog(Q, g, A, b, lvar, uvar; x0)

Minimize gᵀ x + ½ xᵀ Q x subject to A x ≤ b and lvar ≤ x ≤ uvar.
"""
function quadprog(Q::AbstractMatrix, g::AbstractVector, A::MatrixOrOperator, b::AbstractVector,
                 lvar::AbstractVector, uvar::AbstractVector; x0::AbstractVector = zeros(length(g)))
  return quadprog(Q, g, Aineq = A, bupp = b, lvar = lvar, uvar = uvar, x0 = x0)
end

"""
    quadprog(Q, g, A, b, Aeq, beq, lvar, uvar; x0)

Minimize gᵀ x + ½ xᵀ Q x subject to A x ≤ b, Aeq x = beq and lvar ≤ x ≤ uvar.
"""
function quadprog(Q::AbstractMatrix, g::AbstractVector, A::MatrixOrOperator, b::AbstractVector, Aeq::MatrixOrOperator,
                  beq::AbstractVector, lvar::AbstractVector, uvar::AbstractVector; x0::AbstractVector = zeros(length(g)))
  return quadprog(Q, g, Aineq = A, bupp = b, Aeq = Aeq, beq = beq, lvar = lvar, uvar = uvar, x0 = x0)
end

"""
    quadprog(Q, g, Aineq, blow, bupp; x0)

Minimize gᵀ x + ½ xᵀ Q x subject to blow ≤ Aineq x ≤ bupp.
"""
function quadprog(Q::AbstractMatrix, g::AbstractVector, Aineq::MatrixOrOperator, blow::AbstractVector, bupp::AbstractVector;
                  x0::AbstractVector = zeros(length(g)))
  return quadprog(Q, g, Aineq = Aineq, blow = blow, bupp = bupp, x0 = x0)
end