export minimize

"""
    minimize(nlp)

Minimize the problem given by `nlp` (an NLPModel).
"""
function minimize(nlp :: AbstractNLPModel; kwargs...)
  output = ipopt(nlp; kwargs...)
  return output
end

"""
    minimize(f, x₀)

Minimize the function f starting from the point x₀.

    minimize(f, x₀, ℓ, u)

Minimize the function f with bounds ℓ ≤ x ≤ u starting from the point x₀.
"""
function minimize(f :: Function, x :: AbstractVector, ℓ :: AbstractVector = fill(-Inf, length(x)), u :: AbstractVector = fill(Inf, length(x)); kwargs...)
  minimize(ADNLPModel(f, x, lvar=ℓ, uvar=u); kwargs...)
end
