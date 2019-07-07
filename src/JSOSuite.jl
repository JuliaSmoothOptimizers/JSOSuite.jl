module JSOSuite

# JSO
using NLPModels, NLPModelsIpopt

# stdlib
using LinearAlgebra

include("minimize.jl")
include("linprog.jl")
include("quadprog.jl")

end # module
