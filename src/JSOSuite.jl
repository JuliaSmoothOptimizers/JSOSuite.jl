module JSOSuite

# other dependencies
using DataFrames, JuMP, KNITRO
# stdlib
using LinearAlgebra, Logging
# JSO
using ADNLPModels,
  LLSModels, NLPModels, NLPModelsJuMP, NLPModelsModifiers, QuadraticModels, SolverCore
# JSO solvers
using CaNNOLeS, DCISolver, JSOSolvers, NLPModelsIpopt, JSOSolvers, Percival, RipQP
if KNITRO.has_knitro()
  using NLPModelsKnitro
end

"""
    solvers

DataFrame with the JSO-compliant solvers and their properties.

For each solver, the following are available:
- `name::String`: name of the solver;
- `name_solver::Symbol`: name of the solver structure for in-place solve, `:not_implemented` if not implemented;
- `solve_function::Symbol`: name of the function;
- `is_available::Bool`: `true` if the solver is available;
- `bounds::Bool`: `true` if the solver can handle bound constraints;
- `equalities::Bool`: `true` if the solver can handle equality constraints;
- `inequalities::Bool`: `true` if the solver can handle inequality constraints;
- `specialized_nls::Bool`: `true` if the solver has a specialized variant for nonlinear least squares;
- `can_solve_nlp::Bool`: `true` if the solver can solve general problems. Some may only solve nonlinear least squares;
- `nonlinear_obj::Bool`: `true` if the solver can handle nonlinear objective;
- `nonlinear_con::Bool`: `true` if the solver can handle nonlinear constraints;
- `highest_derivative::Int`: order of the highest derivative used by the algorithm.
"""
solvers = DataFrame(
  name = String[],
  name_solver = Symbol[],
  solve_function = Symbol[],
  is_available = Bool[],
  bounds = Bool[],
  equalities = Bool[],
  inequalities = Bool[],
  specialized_nls = Bool[],
  can_solve_nlp = Bool[],
  nonlinear_obj = Bool[],
  nonlinear_con = Bool[],
  highest_derivative = Int[],
)
push!(
  solvers,
  (
    "KNITRO",
    :KnitroSolver,
    :knitro,
    KNITRO.has_knitro(),
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
  solvers,
  ("LBFGS", :LBFGSSolver, :lbfgs, true, false, false, false, false, true, true, true, 1),
)
# push!(solvers, ("R2", :R2Solver, :R2, true, false, false, false, false, true, true, true, 1))
push!(solvers, ("TRON", :TronSolver, :tron, true, true, false, false, false, true, true, true, 2))
push!(
  solvers,
  ("TRUNK", :TrunkSolver, :trunk, true, false, false, false, false, true, true, true, 2),
)
push!(
  solvers,
  ("TRON-NLS", :TronSolverNLS, :tron, true, true, false, false, true, false, true, true, 2),
)
push!(
  solvers,
  ("TRUNK-NLS", :TrunkSolverNLS, :trunk, true, false, false, false, true, false, true, true, 2),
)
push!(
  solvers,
  ("CaNNOLeS", :not_implemented, :cannoles, true, false, true, false, true, false, true, true, 2),
)
push!(solvers, ("IPOPT", :IpoptSolver, :ipopt, true, true, true, true, false, true, true, true, 2))
push!(
  solvers,
  ("Percival", :PercivalSolver, :percival, true, true, true, true, false, true, true, true, 2),
)
push!(
  solvers,
  ("DCISolver", :DCIWorkspace, :dci, true, false, true, false, false, true, true, true, 2),
)
push!(
  solvers,
  ("RipQP", :not_implemented, :ripqp, true, true, true, true, false, true, false, false, 2),
) # need to check linear constraints and quadratic constraints

include("selection.jl")

export solve

"""
    stats = solve(nlp::Union{AbstractNLPModel, JuMP.Model}; kwargs...)

Compute a local minimum of the optimization problem `nlp`.

    stats = solve(f::Function, x0::AbstractVector, args...; kwargs...)
    stats = solve(F::Function, x0::AbstractVector, nequ::Integer, args...; kwargs...)

Define an NLPModel using [`ADNLPModel`](https://juliasmoothoptimizers.github.io/ADNLPModels.jl/stable/).

The solver can be chosen as follows.

    stats = solve(solver_name::Symbol, args...; kwargs...)

`JuMP.Model` are converted in NLPModels via NLPModelsJuMP.jl.

If your optimization problem has a quadratic or linear objective and linear constraints consider using QuadraticModels.jl or LLSModels.jl for the model definition.

# Keyword Arguments

All the keyword arguments are passed to the selected solver.
Keywords available for all the solvers are given below:

- `atol`: absolute tolerance;
- `rtol`: relative tolerance;
- `max_time`: maximum number of seconds;
- `max_eval`: maximum number of cons + obj evaluations;
- `verbose::Int = 0`: if > 0, display iteration details every `verbose` iteration.

Further possible options are documented in each solver's documentation.

## Output

The value returned is a `GenericExecutionStats`, see `SolverCore.jl`.

# Examples
```jldoctest; output = false
using JSOSuite
stats = solve(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0], verbose = 0)
stats

# output

"Execution stats: first-order stationary"
```

The list of available solver can be obtained using `JSOSuite.solvers[!, :name]` or see [`select_solvers`](@ref).

```jldoctest; output = false
using JSOSuite
stats = solve("DCISolver", x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0], verbose = 0)
stats

# output

"Execution stats: first-order stationary"
```
"""
function solve end

function solve(f::Function, x0::AbstractVector, args...; kwargs...)
  nlp = ADNLPModel(f, x0, args...)
  return solve(nlp; kwargs...)
end

function solve(solver_name::String, f::Function, x0::AbstractVector, args...; kwargs...)
  nlp = ADNLPModel(f, x0, args...)
  return solve(solver_name, nlp; kwargs...)
end

function solve(F::Function, x0::AbstractVector, nequ::Integer, args...; kwargs...)
  nlp = ADNLSModel(F, x0, nequ, args...)
  return solve(nlp; kwargs...)
end

function solve(
  solver_name::String,
  F::Function,
  x0::AbstractVector,
  nequ::Integer,
  args...;
  kwargs...,
)
  nlp = ADNLSModel(F, x0, nequ, args...)
  return solve(solver_name, nlp; kwargs...)
end

function solve(model::JuMP.Model, args...; kwargs...)
  nlp = MathOptNLPModel(model)
  return solve(nlp, args...; kwargs...)
end

include("solve.jl")

end # module
