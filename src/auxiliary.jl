const solver_list = Dict{Symbol,Function}(
          :ipopt => suiteipopt,
          :lbfgs => JSOSolvers.lbfgs,
          :tron  => JSOSolvers.tron,
          :trunk => JSOSolvers.trunk,
         )

const OPTIONS_STRING = raw"""
Options:
- `solver::Symbol=:lbfgs`: check ... for complete list
- `atol::Real=1e-8`: absolute tolerance of optimality measure: `measure ≤ atol + rtol * initial_measure`
- `rtol::Real=1e-8`: relative tolerance of optimality measure. Check solver for which measure is used.
- `max_eval::Int=-1`: maximum number of evaluations. Negative values means no limit.
- `max_time::Float64=30.0`: maximum elapsed time allowed in seconds.
- `verbose::Bool=false`: sets the logger below. Ignore if `logger` is set.
- `logger::Logging.AbstractLogger`: logger wrapping the solver. Default value is `ConsoleLogger` if `verbose=true` or `NullLogger` if `verbose=false`.
"""
