module RipQPExt

using RipQP, JSOSuite, LLSModels, QuadraticModels
JSOSuite.optimizers[JSOSuite.optimizers.name .== "RipQP", :is_available] .= 1
    include("solvers/ripqp_solve.jl")
end
