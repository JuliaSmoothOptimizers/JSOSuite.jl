export suiteipopt

function suiteipopt(
  nlp::AbstractNLPModel;
  atol::Real = 1e-8,
  rtol::Real = 1e-8,
  max_eval::Int = -1,
  max_time::Float64 = 30.0,
  kwargs...,
)
  tol = rtol
  max_cpu_time = max_time
  ipopt(nlp, tol = tol, max_cpu_time = max_cpu_time, print_level = 0; kwargs...)
end
