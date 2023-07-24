module JSOSuite

# other dependencies
using DataFrames, JuMP, Requires
# stdlib
using LinearAlgebra, Logging, SparseArrays
# JSO
using ADNLPModels, LLSModels, NLPModels, NLPModelsJuMP, QuadraticModels
using LinearOperators, NLPModelsModifiers, SolverCore
# JSO solvers
using JSOSolvers, Percival

"""
    optimizers

DataFrame with the JSO-compliant solvers and their properties.

For each solver, the following are available:
- `name::String`: name of the solver;
- `name_solver::Symbol`: name of the solver structure for in-place solve, `:not_implemented` if not implemented;
- `name_pkg::String`: name of the package implementing this solver or its NLPModel wrapper;
- `solve_function::Symbol`: name of the function;
- `is_available::Bool`: `true` if the solver is available;
- `bounds::Bool`: `true` if the solver can handle bound constraints;
- `equalities::Bool`: `true` if the solver can handle equality constraints;
- `inequalities::Bool`: `true` if the solver can handle inequality constraints;
- `specialized_nls::Bool`: `true` if the solver has a specialized variant for nonlinear least squares;
- `can_solve_nlp::Bool`: `true` if the solver can solve general problems. Some may only solve nonlinear least squares;
- `nonlinear_obj::Bool`: `true` if the solver can handle nonlinear objective;
- `nonlinear_con::Bool`: `true` if the solver can handle nonlinear constraints;
- `double_precision_only::Bool`: `true` if the solver only handles double precision (`Float64`);
- `highest_derivative::Int`: order of the highest derivative used by the algorithm.
"""
optimizers = DataFrame(
  name = String[],
  name_solver = Symbol[],
  name_pkg = String[],
  solve_function = Symbol[],
  is_available = Bool[],
  bounds = Bool[],
  equalities = Bool[],
  inequalities = Bool[],
  specialized_nls = Bool[],
  can_solve_nlp = Bool[],
  nonlinear_obj = Bool[],
  nonlinear_con = Bool[],
  double_precision_only = Bool[],
  highest_derivative = Int[],
)
push!(
  optimizers,
  (
    "KNITRO",
    :KnitroSolver,
    "NLPModelsKnitro.jl",
    :knitro,
    false,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    2,
  ),
)
push!(
  optimizers,
  (
    "LBFGS",
    :LBFGSSolver,
    "JSOSolvers.jl",
    :lbfgs,
    true,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    1,
  ),
)
push!(
  optimizers,
  (
    "R2",
    :R2Solver,
    "JSOSolvers.jl",
    :R2,
    true,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    1,
  ),
)
push!(
  optimizers,
  (
    "TRON",
    :TronSolver,
    "JSOSolvers.jl",
    :tron,
    true,
    true,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "TRUNK",
    :TrunkSolver,
    "JSOSolvers.jl",
    :trunk,
    true,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "TRON-NLS",
    :TronSolverNLS,
    "JSOSolvers.jl",
    :tron,
    true,
    true,
    false,
    false,
    true,
    false,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "TRUNK-NLS",
    :TrunkSolverNLS,
    "JSOSolvers.jl",
    :trunk,
    true,
    false,
    false,
    false,
    true,
    false,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "CaNNOLeS",
    :CaNNOLeSSolver,
    "CaNNOLeS.jl",
    :cannoles,
    false,
    false,
    true,
    false,
    true,
    false,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "IPOPT",
    :IpoptSolver,
    "NLPModelsIpopt.jl",
    :ipopt,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    true,
    2,
  ),
)
push!(
  optimizers,
  (
    "DCISolver",
    :DCIWorkspace,
    "DCISolver.jl",
    :dci,
    false,
    false,
    true,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "FletcherPenaltySolver",
    :FPSSSolver,
    "FletcherPenaltySolver.jl",
    :fps_solve,
    false,
    false,
    true,
    false,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "Percival",
    :PercivalSolver,
    "Percival.jl",
    :percival,
    true,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    2,
  ),
)
push!(
  optimizers,
  (
    "RipQP",
    :RipQPSolver,
    "RipQP.jl",
    :ripqp,
    false,
    true,
    true,
    true,
    false,
    false,
    false,
    false,
    false,
    2,
  ),
) # need to check linear constraints and quadratic constraints

include("selection.jl")

export minimize, solve!, feasible_point

"""
    stats = minimize(nlp::Union{AbstractNLPModel, JuMP.Model}; kwargs...)

Compute a local minimum of the optimization problem `nlp`.

    stats = minimize(f::Function, x0::AbstractVector, args...; kwargs...)
    stats = minimize(F::Function, x0::AbstractVector, nequ::Integer, args...; kwargs...)

Define an NLPModel using [`ADNLPModel`](https://juliasmoothoptimizers.github.io/ADNLPModels.jl/stable/).

    stats = minimize(c, H, c0 = c0, x0 = x0, name = name; kwargs...)
    stats = minimize(c, H, lvar, uvar, c0 = c0, x0 = x0, name = name; kwargs...)
    stats = minimize(c, H, A, lcon, ucon, c0 = c0, x0 = x0, name = name; kwargs...)
    stats = minimize(c, H, lvar, uvar, A, lcon, ucon, c0 = c0, x0 = x0, name = name; kwargs...)

Define a QuadraticModel using [`QuadraticModel`](https://juliasmoothoptimizers.github.io/QuadraticModels.jl/stable/).

The optimizer can be chosen as follows.

    stats = minimize(optimizer_name::String, args...; kwargs...)

`JuMP.Model` are converted in NLPModels via NLPModelsJuMP.jl.

If your optimization problem has a quadratic or linear objective and linear constraints consider using QuadraticModels.jl or LLSModels.jl for the model definition.

# Keyword Arguments

All the keyword arguments are passed to the selected solver.
Keywords available for all the solvers are given below:

- `atol`: absolute tolerance;
- `rtol`: relative tolerance;
- `max_time`: maximum number of seconds;
- `max_iter`: maximum number of iterations;
- `max_eval`: maximum number of cons + obj evaluations;
- `callback = (args...) -> nothing`: callback called at each iteration;
- `verbose::Int = 0`: if > 0, display iteration details every `verbose` iteration.

The following are specific to nonlinear least squares:

- `Fatol::T = √eps(T)`: absolute tolerance on the residual;
- `Frtol::T = eps(T)`: relative tolerance on the residual, the algorithm stops when ‖F(xᵏ)‖ ≤ Fatol + Frtol * ‖F(x⁰)‖.

Further possible options are documented in each solver's documentation.

## Callback

The callback is called at each iteration.
The expected signature of the callback is `callback(nlp, solver, stats)`, and its output is ignored.
Changing any of the input arguments will affect the subsequent iterations.
In particular, setting `stats.status = :user` will stop the algorithm.
All relevant information should be available in `nlp` and `solver`.

# Output

The value returned is a `GenericExecutionStats`, see `SolverCore.jl`.

# Examples
```jldoctest; output = false
using JSOSuite
stats = minimize(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0], verbose = 0)
stats

# output

"Execution stats: first-order stationary"
```

The list of available solver can be obtained using `JSOSuite.optimizers[!, :name]` or see [`select_optimizers`](@ref).

```jldoctest; output = false
using JSOSuite
stats = minimize("TRON", x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0], verbose = 0)
stats

# output

"Execution stats: first-order stationary"
```

Some optimizers are available after loading only.

```jldoctest; output = false
using JSOSuite
# We minimize here a quadratic problem with bound-constraints
c = [1.0; 1.0]
H = [-2.0 0.0; 3.0 4.0]
uvar = [1.0; 1.0]
lvar = [0.0; 0.0]
x0 = [0.5; 0.5]
stats = minimize("TRON", c, H, lvar, uvar, x0 = x0, name = "bndqp_QP", verbose = 0)
stats

# output

"Execution stats: first-order stationary"

```

"""
function minimize end

"""
    solve!(solver::AbstractOptimizationSolver, model::Union{AbstractNLPModel, JuMP.Model}; kwargs...)
    solve!(solver::AbstractOptimizationSolver, model::Union{AbstractNLPModel, JuMP.Model}, stats; kwargs...)

`JSOSuite` extension of `SolverCore.solve!`.
The first argument should be of type `SolverCore.AbstractOptimizationSolver`, see for instance `JSOSuite.optimizers[!, :name_solver]`.
"""
function SolverCore.solve!(solver, args...; kwargs...)
  throw(
    "solve! not implemented first argument should be of type `SolverCore.AbstractOptimizationSolver` and not $(typeof(solver)), see for instance `JSOSuite.optimizers[!, :name_solver]`.",
  )
end

include("solve_model.jl")

include("solve.jl")

@init begin
  @require CaNNOLeS = "5a1c9e79-9c58-5ec0-afc4-3298fdea2875" begin
    JSOSuite.optimizers[JSOSuite.optimizers.name .== "CaNNOLeS", :is_available] .= 1
    function minimize(::Val{:CaNNOLeS}, nlp; kwargs...)
      return CaNNOLeS.cannoles(nlp; linsolve = :ldlfactorizations, kwargs...)
    end

  end
end

@init begin
  @require DCISolver = "bee2e536-65f6-11e9-3844-e5bb4c9c55c9" begin
    JSOSuite.optimizers[JSOSuite.optimizers.name .== "DCISolver", :is_available] .= 1
    function minimize(::Val{:DCISolver}, nlp; kwargs...)
      return DCISolver.dci(nlp; kwargs...)
    end
  end
end

@init begin
  @require FletcherPenaltySolver = "e59f0261-166d-4fee-8bf3-5e50457de5db" begin
    JSOSuite.optimizers[JSOSuite.optimizers.name .== "FletcherPenaltySolver", :is_available] .= 1
    function minimize(::Val{:FletcherPenaltySolver}, nlp; kwargs...)
      return FletcherPenaltySolver.fps_solve(nlp; kwargs...)
    end
  end
end

@init begin
  @require NLPModelsIpopt = "f4238b75-b362-5c4c-b852-0801c9a21d71" begin
    JSOSuite.optimizers[JSOSuite.optimizers.name .== "IPOPT", :is_available] .= 1
    include("solvers/ipopt_solve.jl")
  end
end

@init begin
  @require NLPModelsKnitro = "bec4dd0d-7755-52d5-9a02-22f0ffc7efcb" begin
    @init begin
      @require NLPModelsKnitro = "bec4dd0d-7755-52d5-9a02-22f0ffc7efcb" begin
        JSOSuite.optimizers[JSOSuite.optimizers.name .== "KNITRO", :is_available] .= KNITRO.has_knitro()
      end
    end
    include("solvers/knitro_solve.jl")
  end
end

@init begin
  @require RipQP = "1e40b3f8-35eb-4cd8-8edd-3e515bb9de08" begin
    JSOSuite.optimizers[JSOSuite.optimizers.name .== "RipQP", :is_available] .= 1
    include("solvers/ripqp_solve.jl")
  end
end

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
using ADNLPModels, JSOSuite, SolverBenchmark
nlps = (
  ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
  ADNLPModel(x -> 4 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0]),
)
names = ["LBFGS", "TRON"] # see `JSOSuite.optimizers.name` for the complete list
stats = bmark_solvers(nlps, names, atol = 1e-3, verbose = 0, colstats = [:name, :nvar, :ncon, :status])
keys(stats)

# output

[ Info:            Name    nvar    ncon           status  
[ Info:         Generic       2       0      first_order
[ Info:         Generic       2       0      first_order
[ Info:            Name    nvar    ncon           status  
[ Info:         Generic       2       0      first_order
[ Info:         Generic       2       0      first_order
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
stats = bmark_solvers(nlps, names, other_solvers, atol = 1e-3, verbose = 0, colstats = [:name, :nvar, :ncon, :status])
keys(stats)

# output

[ Info:            Name    nvar    ncon           status  
[ Info:         Generic       2       0      first_order
[ Info:         Generic       2       0      first_order
[ Info:            Name    nvar    ncon           status
[ Info:         Generic       2       0      first_order
[ Info:         Generic       2       0      first_order
[ Info:            Name    nvar    ncon           status
[ Info:         Generic       2       0      first_order
[ Info:         Generic       2       0      first_order
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
          )
      end
      return SolverBenchmark.bmark_solvers(solvers, problems; kwargs...)
    end

  end
end

"""
    stats = feasible_point(nlp::Union{AbstractNLPModel, JuMP.Model}; kwargs...)
    stats = feasible_point(nlp::Union{AbstractNLPModel, JuMP.Model}, solver_name::Symbol; kwargs...)

Compute a feasible point of the optimization problem `nlp`. The signature is the same as the function [`solve`](@ref).

## Output

The value returned is a `GenericExecutionStats`, see `SolverCore.jl`, where the `status`, `solution`, `primal_residual`, `iter` and `time` are filled-in.

```jldoctest; output = false
using ADNLPModels, JSOSuite
c(x) = [10 * (x[2] - x[1]^2); x[1] - 1]
b = zeros(2)
nlp = ADNLPModel(x -> 0.0, [-1.2; 1.0], c, b, b)
stats = feasible_point(nlp, verbose = 0)
stats

# output

"Execution stats: first-order stationary"
```
"""
function feasible_point end

function feasible_point(nlp::AbstractNLPModel, args...; kwargs...)
  nls = FeasibilityFormNLS(FeasibilityResidual(nlp))
  stats_nls = minimize(nls, args...; kwargs...)
  stats = GenericExecutionStats(nlp)
  set_status!(stats, stats_nls.status)
  set_solution!(stats, stats_nls.solution[1:get_nvar(nlp)])
  set_primal_residual!(stats, stats_nls.objective)
  set_iter!(stats, stats_nls.iter)
  set_time!(stats, stats_nls.elapsed_time)
  return stats
end

function feasible_point(model::JuMP.Model, args...; kwargs...)
  return feasible_point(MathOptNLPModel(model), args...; kwargs...)
end

end # module
