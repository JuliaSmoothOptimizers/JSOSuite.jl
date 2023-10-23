using JSOSolvers, Percival

struct SolverShell{T} end

JSOSolvers.LBFGSSolver() = SolverShell{LBFGSSolver}()
JSOSolvers.TrunkSolver() = SolverShell{TrunkSolver}()
JSOSolvers.TronSolver() = SolverShell{TronSolver}()
Percival.PercivalSolver() = SolverShell{PercivalSolver}()

function (::SolverShell{T})(nlp::AbstractNLPModel, args...; kwargs...) where {T}
  return T(nlp, args...; kwargs...)
end
