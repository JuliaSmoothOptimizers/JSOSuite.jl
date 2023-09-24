module SolverBenchmarkExt

using SolverBenchmark, JSOSuite
function SolverBenchmark.bmark_solvers(
    problems,
    solver_names::Vector{String},
    solvers::Dict{Symbol, Function} = Dict{Symbol, Function}();
    atol::Real = √eps(),
    rtol::Real = √eps(),
    verbose::Integer = 0,
    max_time::Float64 = 300.0,
    max_eval::Integer = 10000,
    max_iter::Integer = 10000,
    kwargs...,
  )
    for s in solver_names
      solvers[Symbol(s)] =
        nlp -> minimize(
          s,
          nlp;
          atol = atol,
          rtol = rtol,
          verbose = verbose,
          max_time = max_time,
          max_eval = max_eval,
          max_iter = max_iter,
        )
    end
    return SolverBenchmark.bmark_solvers(solvers, problems; kwargs...)
  end
end
