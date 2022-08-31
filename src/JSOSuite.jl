module JSOSuite

# other dependencies
using DataFrames, KNITRO
# stdlib
using LinearAlgebra, Logging
# JSO
using NLPModels, NLPModelsModifiers, SolverCore
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
push!(solvers, ("KNITRO", :knitro, KNITRO.has_knitro(), true, true, true, true, true)) # set-up factorization_free option
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
    stats = solve(nlp::AbstractNLPModel; kwargs...)
    stats = solve(nlp::AbstractNLPModel, solver_name::Symbol; kwargs...)

JSOSuite main function solves an AbstractNLPModel, see [NLPModels.jl](https://github.com/JuliaSmoothOptimizers/NLPModels.jl).

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
function solve(nlp::AbstractNLPModel; verbose = true, kwargs...)
  select = select_solvers(nlp, verbose)
  select = select[select.can_solve_nlp, :]
  (verbose ≥ 1) && println("Solve using $(first(select).name):")
  return eval(first(select).solve_function)(nlp; kwargs...)
end

function solve(nlp::AbstractNLSModel; kwargs...)
  select = select_solvers(nlp, verbose)
  nls_select = select[select.specialized_nls, :]
  solver = if !isempty(nls_select)
    return first(nls_select)
  else
    return first(select)
  end
  (verbose ≥ 1) && println("Solve using $(solver.name):")
  return eval(solver.solve_function)(nlp; kwargs...)
end

function solve(nlp, solver_name::Symbol; kwargs...)
  solver = solvers[solvers.name .== solver_name, :]
  if isempty(nls_select)
    @warn "$(solver_name) does not exist."
    return nothing
  end
  return eval(solver.solve_function)(nlp; kwargs...)
end

end # module
