export show_loaded_optimizers

using JSOSolvers, Percival, SolverCore

# Define the solver list
# In order of complexity/requirements
# Least requirements first
global _optimizers = [TrunkSolver, LBFGSSolver, TronSolver, PercivalSolver]

"""
    show_loaded_optimizers()

Prints the loaded optimizers on screen.
"""
show_loaded_optimizers() = println(_optimizers)

# For each solver, define the traits
# JSOSolvers
ObjectiveKindTrait(::Type{TrunkSolver}) = NonlinearObjective()
ObjectiveKindTrait(::Type{LBFGSSolver}) = NonlinearObjective()
ObjectiveKindTrait(::Type{TronSolver}) = NonlinearObjective()
ObjectiveKindTrait(::Type{PercivalSolver}) = NonlinearObjective()
ConstraintKindTrait(::Type{TrunkSolver}) = NoConstraint()
ConstraintKindTrait(::Type{LBFGSSolver}) = NoConstraint()
ConstraintKindTrait(::Type{TronSolver}) = NoConstraint()
ConstraintKindTrait(::Type{PercivalSolver}) = NonlinearConstraint()
HandleBoundsTrait(::Type{TrunkSolver}) = NoHandleBounds()
HandleBoundsTrait(::Type{LBFGSSolver}) = NoHandleBounds()
HandleBoundsTrait(::Type{TronSolver}) = YesHandleBounds()
HandleBoundsTrait(::Type{PercivalSolver}) = YesHandleBounds()
HandleEqualitiesTrait(::Type{TrunkSolver}) = NoHandleEqualities()
HandleEqualitiesTrait(::Type{LBFGSSolver}) = NoHandleEqualities()
HandleEqualitiesTrait(::Type{TronSolver}) = NoHandleEqualities()
HandleEqualitiesTrait(::Type{PercivalSolver}) = YesHandleEqualities()
HandleInequalitiesTrait(::Type{TrunkSolver}) = NoHandleInequalities()
HandleInequalitiesTrait(::Type{LBFGSSolver}) = NoHandleInequalities()
HandleInequalitiesTrait(::Type{TronSolver}) = NoHandleInequalities()
HandleInequalitiesTrait(::Type{PercivalSolver}) = YesHandleInequalities()
DerivativeLevelTrait(::Type{TrunkSolver}) = DerivativeLevel2()
DerivativeLevelTrait(::Type{LBFGSSolver}) = DerivativeLevel1()
DerivativeLevelTrait(::Type{TronSolver}) = DerivativeLevel2()
DerivativeLevelTrait(::Type{PercivalSolver}) = DerivativeLevel2()
HandleNonDoublePrecisionTrait(::Type{TrunkSolver}) = YesHandleNonDouble()
HandleNonDoublePrecisionTrait(::Type{LBFGSSolver}) = YesHandleNonDouble()
HandleNonDoublePrecisionTrait(::Type{TronSolver}) = YesHandleNonDouble()
HandleNonDoublePrecisionTrait(::Type{PercivalSolver}) = YesHandleNonDouble()
UsesFactorizationTrait(::Type{TrunkSolver}) = NoUsesFactorization()
UsesFactorizationTrait(::Type{LBFGSSolver}) = NoUsesFactorization()
UsesFactorizationTrait(::Type{TronSolver}) = NoUsesFactorization()
UsesFactorizationTrait(::Type{PercivalSolver}) = NoUsesFactorization()
UsesMatrixFreeLinAlgTrait(::Type{TrunkSolver}) = YesUsesMatrixFreeLinAlg()
UsesMatrixFreeLinAlgTrait(::Type{LBFGSSolver}) = NoUsesMatrixFreeLinAlg()
UsesMatrixFreeLinAlgTrait(::Type{TronSolver}) = YesUsesMatrixFreeLinAlg()
UsesMatrixFreeLinAlgTrait(::Type{PercivalSolver}) = YesUsesMatrixFreeLinAlg()
# TODO: Implement PercivalSolver{Subsolver} and define traits accordingly

# TODO: Move solver definitions to Package Extension
