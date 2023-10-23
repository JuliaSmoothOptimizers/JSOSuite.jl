module JSOSuite

# Core definitinos
using SolverCore, NLPModels

# User friendly packages
using ADNLPModels

# Basic solvers
using JSOSolvers, Percival

# stdlib
using LinearAlgebra, Logging, SparseArrays

# traits
include("solver-shell.jl")
include("traits.jl")
# optimizers
include("optimizers.jl")
# selection
include("selection.jl")
# user-friendly API

# include("optimizers.jl")
# include("selection.jl")
# include("solve-model.jl")
# include("solve.jl")
# include("load-solvers.jl")
# include("bmark-solvers.jl")
# include("feasible-point.jl")

end # module
