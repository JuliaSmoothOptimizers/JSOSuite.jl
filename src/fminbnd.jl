export fminbnd

"""
    fminbnd(f, x₀, ℓ, u)

Minimize f subject to bounds ℓ ≤ x ≤ u, starting from the point x₀.

$OPTIONS_STRING
"""
function fminbnd(
  f,
  x::AbstractVector,
  ℓ::AbstractVector,
  u::AbstractVector;
  solver::Symbol = :tron,
  atol::Real = 1e-8,
  rtol::Real = 1e-8,
  max_eval::Int = -1,
  max_time::Float64 = 30.0,
  verbose::Bool = false,
  logger = verbose ? ConsoleLogger() : NullLogger(),
  kwargs...,
)
  with_logger(logger) do
    solver_list[solver](
      ADNLPModel(f, x, lvar = ℓ, uvar = u);
      atol = atol,
      rtol = rtol,
      max_eval = max_eval,
      max_time = max_time,
      kwargs...,
    )
  end
end
