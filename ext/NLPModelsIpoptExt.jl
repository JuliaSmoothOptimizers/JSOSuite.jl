module NLPModelsIpoptExt

using NLPModelsIpopt, JSOSuite
JSOSuite.optimizers[JSOSuite.optimizers.name .== "IPOPT", :is_available] .= 1
    include("solvers/ipopt_solve.jl")
end
