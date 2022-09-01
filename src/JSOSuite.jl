module JSOSuite

# other dependencies
using DataFrames, JuMP, KNITRO
# stdlib
using LinearAlgebra, Logging
# JSO
using NLPModels, NLPModelsJuMP, NLPModelsModifiers, SolverCore
# JSO solvers
using CaNNOLeS, DCISolver, JSOSolvers, NLPModelsIpopt, JSOSolvers, Percival, RipQP
if KNITRO.has_knitro()
  using NLPModelsKnitro
end

# DataFrame with the solver and their properties
solvers = DataFrame(
  name = String[],
  solve_function = Symbol[],
  is_available = Bool[],
  bounds = Bool[],
  equalities = Bool[],
  inequalities = Bool[],
  specialized_nls = Bool[],
  can_solve_nlp = Bool[],
)
push!(solvers, ("KNITRO", :knitro, KNITRO.has_knitro(), true, true, true, true, true))
push!(solvers, ("LBFGS", :lbfgs, true, false, false, false, false, true))
push!(solvers, ("TRON", :tron, true, true, false, false, true, true))
push!(solvers, ("TRUNK", :trunk, true, false, false, false, true, true))
push!(solvers, ("CaNNOLeS", :cannoles, true, false, true, false, true, false)) # cannot solve nlp
push!(solvers, ("IPOPT", :ipopt, true, true, true, true, false, true))
push!(solvers, ("Percival", :percival, true, true, true, true, false, true))
push!(solvers, ("DCISolver", :dci, true, false, true, false, false, true))
# push!(solvers, ("RipQP", :ripqp, true, true, missing, missing, false, true)) # need to check linear constraints and quadratic constraints

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
  else
    (verbose ≥ 1) && println("Problem is unconstrained.")
  end
  (verbose ≥ 1) && println("There are $(nrow(select)) solvers available.")
  return select
end

export solve

"""
    stats = solve(nlp::Union{AbstractNLPModel, JuMP.Model}; kwargs...)
    stats = solve(nlp::Union{AbstractNLPModel, JuMP.Model}, solver_name::Symbol; kwargs...)

Compute a local minimum of the optimization problem `nlp`.

`JuMP.Model` are converted in NLPModels via NLPModelsJuMP.jl.

# Keyword Arguments

All the keyword arguments are passed to the selected solver.
Keywords available for all the solvers are given below:

- `atol`: absolute tolerance;
- `rtol`: relative tolerance;
- `max_time`: maximum number of seconds;
- `max_eval`: maximum number of cons + obj evaluations;
- `verbose::Int = 0`: if > 0, display iteration details every `verbose` iteration.

Further possible options are documented in each solver's documentation.

# Examples
```jldoctest; output = false
using ADNLPModels, JSOSuite
nlp = ADNLPModel(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0])
stats = solve(nlp, verbose = false)
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
