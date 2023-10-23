module JSOSuite

# Core definitions
using SolverCore, NLPModels

# User friendly packages
using ADNLPModels

# Basic solvers
using JSOSolvers, Percival

# stdlib
using LinearAlgebra, Logging, SparseArrays

include("solver-shell.jl")
include("traits.jl")
include("optimizers-traits.jl")
include("selection.jl")

include("minimize-core.jl")
include("minimize-friendly.jl")

end # module
