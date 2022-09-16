module JSOSuite

# other dependencies
using DataFrames, JuMP, KNITRO
# stdlib
using LinearAlgebra, Logging
# JSO
using LLSModels, NLPModels, NLPModelsJuMP, NLPModelsModifiers, QuadraticModels, SolverCore
# JSO solvers
using CaNNOLeS, DCISolver, JSOSolvers, NLPModelsIpopt, JSOSolvers, Percival, RipQP
if KNITRO.has_knitro()
  using NLPModelsKnitro
end

"""
    solvers

DataFrame with the solver and their properties.

For each solver, the following are available:
- `name::String`: name of the solver;
- `solve_function = Symbol`: name of the function;
- `is_available = Bool`: `true` if the solver is available as some may require a license;
- `bounds = Bool`: `true` if the solver can handle bound constraints;
- `equalities = Bool`: `true` if the solver can handle equality constraints;
- `inequalities = Bool`: `true` if the solver can handle inequality constraints;
- `specialized_nls = Bool`: `true` if the solver has a specialized variant for nonlinear least squares;
- `can_solve_nlp = Bool`: `true` if the solver can solve any nlp. Some may only solve nonlinear least squares;
- `nonlinear_obj = Bool`: `true` if the solver can handle nonlinear objective;
- `nonlinear_con = Bool`: `true` if the solver can handle nonlinear constraints;
- `highest_derivative = Int`: order of the highest derivative used by the algorithm.
"""
solvers = DataFrame(
  name = String[],
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
# push!(solvers, ("KNITRO", :knitro, KNITRO.has_knitro(), true, true, true, true, true, true, true))
push!(solvers, ("LBFGS", :lbfgs, true, false, false, false, false, true, true, true, 1))
push!(solvers, ("TRON", :tron, true, true, false, false, true, true, true, true, 2))
push!(solvers, ("TRUNK", :trunk, true, false, false, false, true, true, true, true, 2))
push!(solvers, ("CaNNOLeS", :cannoles, true, false, true, false, true, false, true, true, 2)) # cannot solve nlp
push!(solvers, ("IPOPT", :ipopt, true, true, true, true, false, true, true, true, 2))
push!(solvers, ("Percival", :percival, true, true, true, true, false, true, true, true, 2))
push!(solvers, ("DCISolver", :dci, true, false, true, false, false, true, true, true, 2))
push!(solvers, ("RipQP", :ripqp, true, true, true, true, false, true, false, false, 2)) # need to check linear constraints and quadratic constraints

function select_solvers(nlp::AbstractNLPModel, verbose = true, highest_derivative_available::Integer = 2)
push!(solvers, ("LBFGS", :lbfgs, true, false, false, false, false, true, true, true))
push!(solvers, ("TRON", :tron, true, true, false, false, true, true, true, true))
push!(solvers, ("TRUNK", :trunk, true, false, false, false, true, true, true, true))
push!(solvers, ("CaNNOLeS", :cannoles, true, false, true, false, true, false, true, true)) # cannot solve nlp
push!(solvers, ("IPOPT", :ipopt, true, true, true, true, false, true, true, true))
push!(solvers, ("Percival", :percival, true, true, true, true, false, true, true, true))
push!(solvers, ("DCISolver", :dci, true, false, true, false, false, true, true, true))
push!(solvers, ("RipQP", :ripqp, true, true, true, true, false, true, false, false)) # need to check linear constraints and quadratic constraints

"""
    select_solvers(nlp::AbstractNLPModel, verbose = true, highest_derivative_available::Integer = 2)

Narrow the list of solvers to solve `nlp` problem using `highest_derivative_available`.

This function checks whether the model has:
  - linear or nonlinear constraints;
  - unconstrained, bound constraints, equality constraints, inequality constraints;
  - nonlinear or quadratic objective.
We detect linear or quadratic objective if the type of `nlp` is a `QuadraticModel` or an `LLSModel`.
The selection between general optimization problem and nonlinear least squares is done in [`solve`](@ref).

If no solvers were selected, consider setting `verbose` to `true` to see what went wrong.

## Output

- `selected_solvers::DataFrame`: A subset of [`solvers`](@ref) adapted to the problem `nlp`.

See also [`solvers`](@ref), [`solve`](@ref).

## Examples

```jldoctest
julia> a = [1 2; 3 4]
2×2 Array{Int64,2}:
 1  2
 3  4
```
"""
function select_solvers(nlp::AbstractNLPModel, verbose = true)
  select = solvers[solvers.is_available, :]
  (verbose ≥ 1) && println(
    "Problem $(nlp.meta.name) with $(nlp.meta.nvar) variables and $(nlp.meta.ncon) constraints",
  )
  (verbose ≥ 1) && println("Select algorithm:")
  if !unconstrained(nlp)
    if has_equalities(nlp)
      (verbose ≥ 1) && println("equalities: true")
      select = select[select.equalities, :]
    end
    if has_inequalities(nlp)
      (verbose ≥ 1) && println("inequalities: true")
      select = select[select.inequalities, :]
    end
    if has_bounds(nlp)
      (verbose ≥ 1) && println("bounds: true")
      select = select[select.inequalities, :]
    end
    if !linearly_constrained(nlp)
      (verbose ≥ 1) && println("nonlinear constraints: true")
      select = select[select.nonlinear_con, :]
    else
      (verbose ≥ 1) && println("linear constraints: true")
    end
    if !(typeof(nlp) <: QuadraticModel) || !(typeof(nlp) <: LLSModel)
      (verbose ≥ 1) && println("nonlinear objective: true")
      select = select[select.nonlinear_obj, :]
    else
      (verbose ≥ 1) && println("quadratic objective: true")
    end
  else
    (verbose ≥ 1) && println("Problem is unconstrained.")
  end
  nsolvers_before_derivative = nrow(select)
  if nsolvers_before_derivative == 0
    (verbose ≥ 1) && println("No solvers are available for this type of problem. Consider open an issue to JSOSuite.jl")
  else
    (verbose ≥ 1) && println("Problem may use $(highest_derivative_available).")
    select = select[select.highest_derivative .<= highest_derivative_available, :]
    nsolvers_after_derivative = nrow(select)
    if (nsolvers_after_derivative == 0) && (nsolvers_before_derivative > 0)
      (verbose ≥ 1) && println("No solvers are available. Consider using higher derivatives, there are $(nsolvers_before_derivative) available.")
    else
      (verbose ≥ 1) && println("There are $(nrow(select)) solvers available.")
    end
  end
  return select
end

export solve

"""
    stats = solve(nlp::Union{AbstractNLPModel, JuMP.Model}; kwargs...)
    stats = solve(nlp::Union{AbstractNLPModel, JuMP.Model}, solver_name::Symbol; kwargs...)

Compute a local minimum of the optimization problem `nlp`.

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

# Examples
```jldoctest; output = false
using ADNLPModels, JSOSuite
nlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0])
stats = solve(nlp, verbose = false)
stats

# output

"Execution stats: first-order stationary"
```

The list of available solver can be obtained using `JSOSuite.solvers[!, :name]`.

```jldoctest; output = false
using ADNLPModels, JSOSuite
nlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0])
stats = solve(nlp, "DCISolver", verbose = false)
stats

# output

"Execution stats: first-order stationary"
```
"""
function solve end

function solve(model::JuMP.Model, args...; kwargs...)
  nlp = MathOptNLPModel(model)
  return solve(nlp, args...; kwargs...)
end

include("solve.jl")

end # module
