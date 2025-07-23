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

using ADNLPModels: ADNLPModels, ADNLPModel, ADNLSModel
using DataFrames: DataFrames, DataFrame, delete!, nrow
using JSOSolvers: JSOSolvers
using JuMP: JuMP, solver_name
using LLSModels: LLSModels, LLSModel
using LinearAlgebra: LinearAlgebra, convert, norm
using LinearOperators: LinearOperators, AbstractLinearOperator
using Logging: Logging, @info, @warn
using NLPModels:
  NLPModels,
  AbstractNLPModel,
  AbstractNLSModel,
  get_nvar,
  get_x0,
  has_bounds,
  has_equalities,
  has_inequalities,
  linearly_constrained,
  obj,
  unconstrained
using NLPModelsJuMP: NLPModelsJuMP, MathOptNLPModel
using NLPModelsModifiers: NLPModelsModifiers, FeasibilityFormNLS, FeasibilityResidual
using Percival: Percival, solve!
using QuadraticModels: QuadraticModels, QuadraticModel
using Random: Random, AbstractRNG, rand!
using Requires: Requires, @init, @require
using SolverCore:
  SolverCore,
  GenericExecutionStats,
  log_header,
  log_row,
  set_iter!,
  set_primal_residual!,
  set_solution!,
  set_status!,
  set_time!
using SolverParameters: SolverParameters, RealInterval
using SparseArrays: SparseArrays

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
