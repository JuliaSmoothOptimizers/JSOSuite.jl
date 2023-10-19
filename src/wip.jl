# List traits per solver
# Based on problem, filter by traits
# Use the filtered solver

export select_solver
export NewtonMethod, ProjGradMethod, NelderMeadMethod, SQPEqualityMethod, AugLagMethod

abstract type AbstractMethod end
mutable struct NewtonMethod <: AbstractMethod end
mutable struct ProjGradMethod <: AbstractMethod end
mutable struct NelderMeadMethod <: AbstractMethod end
mutable struct SQPEqualityMethod <: AbstractMethod end
mutable struct AugLagMethod <: AbstractMethod end

abstract type DoesItHandleUnconstrainedProblem end
struct CanHandleUnconstrainedProblem <: DoesItHandleUnconstrainedProblem end
struct CannotHandleUnconstrainedProblem <: DoesItHandleUnconstrainedProblem end
handles_unconstrained_problem(::M) where {M <: AbstractMethod} =
  DoesItHandleUnconstrainedProblem(M) == CanHandleUnconstrainedProblem()

DoesItHandleUnconstrainedProblem(::Type) = CannotHandleUnconstrainedProblem()
DoesItHandleUnconstrainedProblem(::Type{NewtonMethod}) = CanHandleUnconstrainedProblem()
DoesItHandleUnconstrainedProblem(::Type{ProjGradMethod}) = CanHandleUnconstrainedProblem()
DoesItHandleUnconstrainedProblem(::Type{NelderMeadMethod}) = CanHandleUnconstrainedProblem()
DoesItHandleUnconstrainedProblem(::Type{SQPEqualityMethod}) = CannotHandleUnconstrainedProblem()
DoesItHandleUnconstrainedProblem(::Type{AugLagMethod}) = CanHandleUnconstrainedProblem()

abstract type DerivariteLevel end
struct DerivariteLevel0 <: DerivariteLevel end
struct DerivariteLevel1 <: DerivariteLevel end
struct DerivariteLevel2 <: DerivariteLevel end
get_derivative_level(::M) where {M} = get_derivative_level(M)
function get_derivative_level(::Type{M}) where {M <: AbstractMethod}
  trait_value = DerivariteLevel(M)
  if trait_value == DerivariteLevel0()
    return 0
  elseif trait_value == DerivariteLevel1()
    return 1
  else
    return 2
  end
end

DerivariteLevel(::Type) = DerivariteLevel2()
DerivariteLevel(::Type{ProjGradMethod}) = DerivariteLevel1()
DerivariteLevel(::Type{NelderMeadMethod}) = DerivariteLevel0()

abstract type DoesItHandleBoundedVariables end
struct CanHandleBoundedVariables <: DoesItHandleBoundedVariables end
struct CannotHandleBoundedVariables <: DoesItHandleBoundedVariables end
handles_bounded_variables(::Type{M}) where {M <: AbstractMethod} =
  DoesItHandleBoundedVariables(M) == CanHandleBoundedVariables()

DoesItHandleBoundedVariables(::Type) = CannotHandleBoundedVariables()
DoesItHandleBoundedVariables(::Type{ProjGradMethod}) = CanHandleBoundedVariables()
DoesItHandleBoundedVariables(::Type{AugLagMethod}) = CanHandleBoundedVariables()

abstract type DoesItHandleEqualityConstraints end
struct CanHandleEqualityConstraints <: DoesItHandleEqualityConstraints end
struct CannotHandleEqualityConstraints <: DoesItHandleEqualityConstraints end
handles_equality_constraints(::Type{M}) where {M <: AbstractMethod} =
  DoesItHandleEqualityConstraints(M) == CanHandleEqualityConstraints()

DoesItHandleEqualityConstraints(::Type) = CannotHandleEqualityConstraints()
DoesItHandleEqualityConstraints(::Type{SQPEqualityMethod}) = CanHandleEqualityConstraints()
DoesItHandleEqualityConstraints(::Type{AugLagMethod}) = CanHandleEqualityConstraints()

abstract type DoesItHandleInequalityConstraints end
struct CanHandleInequalityConstraints <: DoesItHandleInequalityConstraints end
struct CannotHandleInequalityConstraints <: DoesItHandleInequalityConstraints end
handles_inequality_constraints(::Type{M}) where {M <: AbstractMethod} =
  DoesItHandleInequalityConstraints(M) == CanHandleInequalityConstraints()

DoesItHandleInequalityConstraints(::Type) = CannotHandleInequalityConstraints()
DoesItHandleInequalityConstraints(::Type{AugLagMethod}) = CanHandleInequalityConstraints()

method_list =
  [NewtonMethod(), AugLagMethod(), SQPEqualityMethod(), ProjGradMethod(), NelderMeadMethod()]

function select_method(has_bounds = false, has_equ = false, has_ineq = false, derivative_level = 2)
  parameters = (
    has_bounds ? CanHandleBoundedVariables() : CannotHandleBoundedVariables(),
    has_equ ? CanHandleEqualityConstraints() : CannotHandleEqualityConstraints(),
    has_ineq ? CanHandleInequalityConstraints() : CannotHandleInequalityConstraints(),
    if derivative_level == 0
      DerivariteLevel0()
    elseif derivative_level == 1
      DerivariteLevel1()
    else
      DerivariteLevel2()
    end,
  )
  return select_method(parameters...)
end

function select_method(
  ::DoesItHandleBoundedVariables,
  ::DoesItHandleEqualityConstraints,
  ::DoesItHandleInequalityConstraints,
  ::DerivariteLevel,
)
  return AugLagMethod()
end

function select_method(
  ::CannotHandleBoundedVariables,
  ::CannotHandleEqualityConstraints,
  ::CannotHandleInequalityConstraints,
  ::DerivariteLevel2,
)
  return NewtonMethod()
end

function select_method(
  ::CannotHandleBoundedVariables,
  ::CannotHandleEqualityConstraints,
  ::CannotHandleInequalityConstraints,
  ::DerivariteLevel0,
)
  return NelderMeadMethod()
end
