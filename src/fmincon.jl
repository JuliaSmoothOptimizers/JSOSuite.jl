export fmincon

"""
    fmincon(nlp)

Minimize the problem `nlp` f subject to ℓ ≤ x ≤ u, lcon ≤ c(x) ≤ ucon starting from the point x₀.

$OPTIONS_STRING
"""
function fmincon(nlp :: AbstractNLPModel;
                 solver :: Symbol = :ipopt,
                 atol :: Real = 1e-8,
                 rtol :: Real = 1e-8,
                 max_eval :: Int = -1,
                 max_time :: Float64 = 30.0,
                 verbose :: Bool = false,
                 logger = verbose ? ConsoleLogger() : NullLogger(),
                 kwargs...
                )
  output = with_logger(logger) do
    solver_list[solver](nlp; atol=atol, rtol=rtol, max_eval=max_eval, max_time=max_time, kwargs...)
  end
  return output
end

"""
    fmincon(f, x₀, c, ncon)

Minimize the function f subject to c(x) = 0 starting from the point x₀.
"""
function fmincon(f, x :: AbstractVector, c :: Function, ncon :: Int; kwargs...)
  nlp = ADNLPModel(f, x, c=c, lcon=zeros(ncon), ucon=zeros(ncon))
  return fmincon(nlp; kwargs...)
end

"""
    fmincon(f, x₀, c, lcon, ucon)

Minimize the function f subject to lcon ≤ c(x) ≤ ucon starting from the point x₀.
"""
function fmincon(f :: Function, x :: AbstractVector, c :: Function, lcon :: AbstractVector, ucon :: AbstractVector; kwargs...)
  nlp = ADNLPModel(f, x, c=c, lcon=lcon, ucon=ucon)
  return fmincon(nlp; kwargs...)
end

"""
    fmincon(f, x₀, ceq, neq, cgeq, ngeq)

Minimize the function f subject to ceq(x) = 0 and cineq(x) ≥ 0 starting from the point x₀.
"""
function fmincon(f :: Function, x :: AbstractVector, ceq :: Function, neq :: Int, cgeq :: Function, ngeq :: Int; kwargs...)
  nlp = ADNLPModel(f, x, c=x -> [ceq(x); cgeq(x)], lcon=zeros(neq+ngeq), ucon=[zeros(neq);fill(Inf,ngeq)]; kwargs...)
  return fmincon(nlp; kwargs...)
end

"""
    fmincon(f, x₀, ℓ, u, c, lcon, ucon)

Minimize f subject to ℓ ≤ x ≤ u, lcon ≤ c(x) ≤ ucon starting from the point x₀.
"""
function fmincon(f, x :: AbstractVector, ℓ :: AbstractVector, u :: AbstractVector, c :: Function, lcon :: AbstractVector, ucon :: AbstractVector; kwargs...)
  nlp = ADNLPModel(f, x, lvar=ℓ, uvar=u, c=c, lcon=lcon, ucon=ucon)
  return fmincon(nlp; kwargs...)
end

