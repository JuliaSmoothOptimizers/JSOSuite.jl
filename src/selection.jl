export select_optimizer

_objective_kind_map = Dict(
  :linear => LinearObjective(),
  :quadratic => QuadraticObjective(),
  :nonlinear => NonlinearObjective(),
)

_constraint_kind_map =
  Dict(:none => NoConstraint(), :linear => LinearConstraint(), :nonlinear => NonlinearConstraint())

function _satisfy_objective_kind(::Type{T}, desired_objective_kind) where {T}
  return _objective_kind_map[desired_objective_kind] == get_objective_kind(T)
end

function _satisfy_constraint_kind(::Type{T}, desired_constraint_kind) where {T}
  return _constraint_kind_map[desired_constraint_kind] == get_constraint_kind(T)
end

function _satisfy_handle_bounds(::Type{T}, handle_bounds) where {T}
  return get_handle_bounds(T) == YesHandleBounds()
end

"""
    select_optimizer(; kwargs...)

Select an optimizer based on what optimizers are loaded and the keywords arguments passed.
See the loaded optimizers by calling [`show_loaded_optimizers`](@ref).

!!! warning
    The default arguments fail to return a solver.

## Arguments

- `objective_kind = :nonlinear`: What kind of objective function the solver needs to handle.
  Options are `[:linear, :quadratic, :nonlinear]`.
- `constraint_kind = :nonlinear`: What kind of constraint function the solver needs to handle.
  Options are `[:none, :linear, :nonlinear]`.
- `handle_bounds = true`: Whether the solver needs to be able to handle bounded variables.
- `handle_equalities = true`: Whether the solver needs to be able to handle equality constraints.
  This will be ignored if `constraint_kind` is `:none`.
- `handle_inequalities = true`: Whether the solver needs to be able to handle inequality constraints.
  This will be ignored if `constraint_kind` is `:none`.
- `derivative_level = 1`: Highest level of derivatives that the solver can use.
- `handle_non_double_precision = true`: Whether the solver needs to be able to handle non-double precision.
- `uses_factorization = false`: Whether we want a solver that uses factorization.
- `uses_matrix_free = false`: Whether we want a solver that uses matrix-free linear algebra.
  Notice that `uses_factorization` and `uses_matrix_free` can BOTH BE FALSE (e.g. LBFGS).
"""
function select_optimizer(;
  objective_kind = :nonlinear,
  constraint_kind = :nonlinear,
  handle_bounds = true,
  handle_equalities = true,
  handle_inequalities = true,
  derivative_level = 1,
  handle_non_double_precision = true,
  uses_factorization = false,
  uses_matrix_free = false,
)
  for optimizer in JSOSuite._optimizers
    if !_satisfy_objective_kind(optimizer, objective_kind)
      continue
    end

    if !_satisfy_constraint_kind(optimizer, constraint_kind)
      continue
    end

    if !get_handle_bounds(optimizer) && handle_bounds
      continue
    end

    if constraint_kind != :none
      if !get_handle_equalities(optimizer) && handle_equalities
        continue
      end

      if !get_handle_inequalities(optimizer) && handle_inequalities
        continue
      end
    end

    if derivative_level < get_derivative_level(optimizer)
      continue
    end

    if handle_non_double_precision && !get_handle_non_double_precision(optimizer)
      continue
    end

    if uses_factorization != get_uses_factorization(optimizer)
      continue
    end

    if uses_matrix_free != get_uses_matrix_free_lin_alg(optimizer)
      continue
    end

    return optimizer
  end

  error("No optimizer can handle this problem type")
end

"""
    _select_optimizer(...)

Select an optimizer with the required attributes.
This dispatches on the traits, so it should be type stable.

## Arguments

- ::ObjectiveKindTrait
- ::ConstraintKindTrait
- ::HandleBoundsTrait
- ::HandleEqualitiesTrait
- ::HandleInequalitiesTrait
- ::DerivativeLevelTrait
- ::HandleNonDoublePrecisionTrait
- ::UsesFactorizationTrait
- ::UsesMatrixFreeLinAlgTrait
"""
function _select_optimizer end

function _get_traits_of_optimizer(::Type{T}) where {T}
  return (
    ObjectiveKindTrait(T),
    ConstraintKindTrait(T),
    HandleBoundsTrait(T),
    HandleEqualitiesTrait(T),
    HandleInequalitiesTrait(T),
    DerivativeLevelTrait(T),
    HandleNonDoublePrecisionTrait(T),
    UsesFactorizationTrait(T),
    UsesMatrixFreeLinAlgTrait(T),
  )
end

function _select_optimizer(
  ::ObjectiveKindTrait,
  ::NoConstraint,
  ::NoHandleBounds,
  ::NoHandleEqualities,
  ::NoHandleInequalities,
  ::DerivativeLevel2,
  ::HandleNonDoublePrecisionTrait,
  ::NoUsesFactorization,
  ::YesUsesMatrixFreeLinAlg,
)
  return TrunkSolver()
end

function _select_optimizer(
  ::ObjectiveKindTrait,
  ::NoConstraint,
  ::NoHandleBounds,
  ::NoHandleEqualities,
  ::NoHandleInequalities,
  ::DerivativeLevel1,
  ::HandleNonDoublePrecisionTrait,
  ::NoUsesFactorization,
  ::NoUsesMatrixFreeLinAlg,
)
  return LBFGSSolver()
end

function _select_optimizer(
  ::ObjectiveKindTrait,
  ::NoConstraint,
  ::YesHandleBounds,
  ::NoHandleEqualities,
  ::NoHandleInequalities,
  ::DerivativeLevel2,
  ::HandleNonDoublePrecisionTrait,
  ::NoUsesFactorization,
  ::YesUsesMatrixFreeLinAlg,
)
  return TronSolver()
end

function _select_optimizer(
  ::ObjectiveKindTrait,
  ::ConstraintKindTrait,
  ::HandleBoundsTrait,
  ::HandleEqualitiesTrait,
  ::HandleInequalitiesTrait,
  ::DerivativeLevel2,
  ::HandleNonDoublePrecisionTrait,
  ::NoUsesFactorization,
  ::YesUsesMatrixFreeLinAlg,
)
  return PercivalSolver()
end
