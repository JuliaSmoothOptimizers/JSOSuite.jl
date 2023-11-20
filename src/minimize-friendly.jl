# TODO: Allow extra argument to select_optimizer

# ADNLPModel interfaces
function minimize(f, x0::AbstractVector; kwargs...)
  nlp = ADNLPModel(f, x0)
  solver = select_optimizer(constraint_kind = :none, handle_bounds = false, derivative_level = 2)
  @debug "Select solver $solver"
  return minimize(solver, nlp; kwargs...)
end

function minimize(f, x0::AbstractVector, lvar, uvar; kwargs...)
  nlp = ADNLPModel(f, x0, lvar, uvar)
  solver = select_optimizer(constraint_kind = :none, handle_bounds = true, derivative_level = 2)
  @debug "Select solver $solver"
  return minimize(solver, nlp; kwargs...)
end

function minimize(f, x0::AbstractVector, c, lcon, ucon; kwargs...)
  nlp = ADNLPModel(f, x0, c, lcon, ucon)
  handle_equalities = any(lcon .== ucon)
  handle_inequalities = any(lcon .< ucon)
  solver = select_optimizer(
    constraint_kind = :nonlinear,
    handle_bounds = false,
    handle_equalities = handle_equalities,
    handle_inequalities = handle_inequalities,
    derivative_level = 2,
  )
  @debug "Select solver $solver"
  return minimize(solver, nlp; kwargs...)
end

function minimize(f, x0::AbstractVector, lvar, uvar, c, lcon, ucon; kwargs...)
  nlp = ADNLPModel(f, x0, lvar, uvar, c, lcon, ucon)
  handle_equalities = any(lcon .== ucon)
  handle_inequalities = any(lcon .< ucon)
  solver = select_optimizer(
    constraint_kind = :nonlinear,
    handle_bounds = true,
    handle_equalities = handle_equalities,
    handle_inequalities = handle_inequalities,
    derivative_level = 2,
  )
  @debug "Select solver $solver"
  return minimize(solver, nlp; kwargs...)
end

function minimize(
  ::Type{Solver},
  f,
  x0::AbstractVector,
  args...;
  kwargs...,
) where {Solver <: SolverCore.AbstractOptimizationSolver}
  nlp = ADNLPModel(f, x0, args...)
  return minimize(Solver, nlp; kwargs...)
end

function minimize(::SolverShell{Solver}, f, x0::AbstractVector, args...; kwargs...) where {Solver}
  nlp = ADNLPModel(f, x0, args...)
  return minimize(Solver, nlp; kwargs...)
end
