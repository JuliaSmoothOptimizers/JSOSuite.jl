"""
    bmark_solvers(problems, solver_names::Vector{String}; kwargs...)
    bmark_solvers(problems, solver_names::Vector{String}, solvers::Dict{Symbol, Function}; kwargs...)

Wrapper to the function [SolverBenchmark.bmark_solvers](https://github.com/JuliaSmoothOptimizers/SolverBenchmark.jl/blob/main/src/bmark_solvers.jl).

# Arguments
- `problems`: The set of problems to pass to the solver, as an iterable of`AbstractNLPModel`;
- `solver_names::Vector{String}`: The names of the benchmarked solvers. They should be valid `JSOSuite` names, see `JSOSuite.solvers.name` for a list;
- `solvers::solvers::Dict{Symbol, Function}`: A dictionary of additional solvers to benchmark.

# Output

A Dict{Symbol, DataFrame} of statistics.

# Keyword Arguments

The following keywords available are passed to the `JSOSuite` solvers:

- `atol`: absolute tolerance;
- `rtol`: relative tolerance;
- `max_time`: maximum number of seconds;
- `max_eval`: maximum number of cons + obj evaluations;
- `verbose::Int = 0`: if > 0, display iteration details every `verbose` iteration.

All the remaining keyword arguments are passed to the function `SolverBenchmark.bmark_solvers`.

# Examples

```jldoctest; output = false
using ADNLPModels, JSOSuite, Logging, SolverBenchmark
nlps = (
  ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
  ADNLPModel(x -> 4 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
)
names = ["LBFGS", "TRON"] # see `JSOSuite.optimizers.name` for the complete list
stats = with_logger(NullLogger()) do
  bmark_solvers(nlps, names, atol = 1e-3, colstats = [:name, :nvar, :ncon, :status])
end
keys(stats)

# output

KeySet for a Dict{Symbol, DataFrames.DataFrame} with 2 entries. Keys:
  :TRON
  :LBFGS

```

The second example shows how to add you own solver to the benchmark.

```jldoctest; output = false
using ADNLPModels, JSOSolvers, JSOSuite, Logging, SolverBenchmark
nlps = (
  ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
  ADNLPModel(x -> 4 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
)
names = ["LBFGS", "TRON"] # see `JSOSuite.optimizers.name` for the complete list
other_solvers = Dict{Symbol, Function}(
  :test => nlp -> lbfgs(nlp; mem = 2, atol = 1e-3, verbose = 0),
)
stats = with_logger(NullLogger()) do
  bmark_solvers(nlps, names, other_solvers, atol = 1e-3, colstats = [:name, :nvar, :ncon, :status])
end
keys(stats)

# output

KeySet for a Dict{Symbol, DataFrames.DataFrame} with 3 entries. Keys:
  :test
  :TRON
  :LBFGS

```
"""
function bmark_solvers end

@init begin
  @require SolverBenchmark = "581a75fa-a23a-52d0-a590-d6201de2218a" begin
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
end
