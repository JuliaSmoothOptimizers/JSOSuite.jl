module JSOSuite

# other dependencies
using DataFrames, JuMP, Requires
# stdlib
using LinearAlgebra, Logging, Random, SparseArrays
# JSO
using ADNLPModels, LLSModels, NLPModels, NLPModelsJuMP, QuadraticModels
using LinearOperators, NLPModelsModifiers, SolverCore, SolverParameters
# JSO solvers
using JSOSolvers, Percival

@init begin
  @require ExpressionTreeForge = "93090adf-0e31-445f-8c8f-44d91f61d7ad" begin
    include("parse-functions.jl")
  end
end

include("optimizers.jl")
include("selection.jl")
include("solve-model.jl")
include("solve.jl")
include("load-solvers.jl")
include("bmark-solvers.jl")
include("feasible-point.jl")
include("multi-start.jl")

end # module
