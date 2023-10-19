struct SolverShell{T} end

JSOSolvers.LBFGSSolver() = SolverShell{LBFGSSolver}()
JSOSolvers.TrunkSolver() = SolverShell{TrunkSolver}()
JSOSolvers.TronSolver() = SolverShell{TronSolver}()
Percival.PercivalSolver() = SolverShell{PercivalSolver}()

function (::SolverShell{T})(nlp::AbstractNLPModel, args...; kwargs...) where {T}
  return T(nlp, args...; kwargs...)
end

abstract type ObjectiveKindTrait end
struct LinearObjective <: ObjectiveKindTrait end
struct QuadraticObjective <: ObjectiveKindTrait end
struct NonlinearObjective <: ObjectiveKindTrait end
struct LinearLeastSquaresObjective <: ObjectiveKindTrait end
struct NonlinearLeastSquaresObjective <: ObjectiveKindTrait end
ObjectiveKindTrait(::Type) = NonlinearObjective()
get_objective_kind(::Type{S}) where {S} = ObjectiveKindTrait(S)

abstract type ConstraintKindTrait end
struct NoConstraint <: ConstraintKindTrait end
struct LinearConstraint <: ConstraintKindTrait end
struct QuadraticConstraint <: ConstraintKindTrait end
struct NonlinearConstraint <: ConstraintKindTrait end
ConstraintKindTrait(::Type) = NoConstraint()
get_constraint_kind(::Type{S}) where {S} = ConstraintKindTrait(S)

abstract type HandleBoundsTrait end
struct NoHandleBounds <: HandleBoundsTrait end
struct YesHandleBounds <: HandleBoundsTrait end
HandleBoundsTrait(::Type) = NoHandleBounds()
get_handle_bounds(::Type{S}) where {S} = HandleBoundsTrait(S) == YesHandleBounds()

abstract type HandleEqualitiesTrait end
struct NoHandleEqualities <: HandleEqualitiesTrait end
struct YesHandleEqualities <: HandleEqualitiesTrait end
HandleEqualitiesTrait(::Type) = NoHandleEqualities()
get_handle_equalities(::Type{S}) where {S} = HandleEqualitiesTrait(S) == YesHandleEqualities()

abstract type HandleInequalitiesTrait end
struct NoHandleInequalities <: HandleInequalitiesTrait end
struct YesHandleInequalities <: HandleInequalitiesTrait end
HandleInequalitiesTrait(::Type) = NoHandleInequalities()
get_handle_inequalities(::Type{S}) where {S} = HandleInequalitiesTrait(S) == YesHandleInequalities()

abstract type DerivativeLevelTrait end
struct DerivativeLevel0 <: DerivativeLevelTrait end
struct DerivativeLevel1 <: DerivativeLevelTrait end
struct DerivativeLevel2 <: DerivativeLevelTrait end
DerivativeLevelTrait(::Type) = DerivativeLevel2()
get_derivative_level(::Type{S}) where {S} = begin
  dl = DerivativeLevelTrait(S)
  return if dl == DerivativeLevel0()
    0
  elseif dl == DerivativeLevel1()
    1
  elseif dl == DerivativeLevel2()
    2
  end
end

abstract type RequiresDoublePrecisionTrait end
struct NoRequiresDouble <: RequiresDoublePrecisionTrait end
struct YesRequiresDouble <: RequiresDoublePrecisionTrait end
RequiresDoublePrecisionTrait(::Type) = YesRequiresDouble()
get_requires_double_precision(::Type{S}) where {S} =
  RequiresDoublePrecisionTrait(S) == YesRequiresDouble()

abstract type UsesFactorizationTrait end
struct NoUsesFactorization <: UsesFactorizationTrait end
struct YesUsesFactorization <: UsesFactorizationTrait end
UsesFactorizationTrait(::Type) = YesUsesFactorization()
get_uses_factorization(::Type{S}) where {S} =
  UsesFactorizationTrait(S) == YesUsesFactorization()

abstract type UsesMatrixFreeLinAlgTrait end
struct NoUsesMatrixFreeLinAlg <: UsesMatrixFreeLinAlgTrait end
struct YesUsesMatrixFreeLinAlg <: UsesMatrixFreeLinAlgTrait end
UsesMatrixFreeLinAlgTrait(::Type) = YesUsesMatrixFreeLinAlg()
get_uses_matrix_free_lin_alg(::Type{S}) where {S} =
  UsesMatrixFreeLinAlgTrait(S) == YesUsesMatrixFreeLinAlg()
