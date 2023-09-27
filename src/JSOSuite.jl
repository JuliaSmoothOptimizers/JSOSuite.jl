module JSOSuite

# other dependencies
using DataFrames
# stdlib
using LinearAlgebra, Logging, SparseArrays
# JSO
using ADNLPModels, NLPModels, QuadraticModels
using LinearOperators, NLPModelsModifiers, SolverCore
# JSO solvers
using JSOSolvers, Percival

struct SolverShell{T} end

for (Package, Solvers) in
    ((:JSOSolvers, (:LBFGSSolver, :TrunkSolver, :TronSolver)), (:Percival, (:PercivalSolver,)))
  for Solver in Solvers
    @eval begin
      $Package.$Solver() = SolverShell{$Solver}()
    end
  end
end

function (::SolverShell{T})(nlp::AbstractNLPModel, args...; kwargs...) where {T}
  return T(nlp, args...; kwargs...)
end

# include("optimizers.jl")
# include("selection.jl")
include("solve-model.jl")
include("solve.jl")
# include("load-solvers.jl")
# include("bmark-solvers.jl")
# include("feasible-point.jl")

end # module
