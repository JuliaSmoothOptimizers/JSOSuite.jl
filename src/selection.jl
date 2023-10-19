function select_optimizer(;
	objective_kind = 
)
end

function _select_optimizer(args...)
    return PercivalSolver()
end

function _select_optimizer(
    ::ObjectiveKindTrait,
    ::NoConstraint,
    ::NoHandleBounds,
    ::NoHandleEqualities,
    ::NoHandleInequalities,
    ::DerivativeLevel2,
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
    ::NoUsesFactorization,
    ::YesUsesMatrixFreeLinAlg,
)
    return TrunkSolver()
end
