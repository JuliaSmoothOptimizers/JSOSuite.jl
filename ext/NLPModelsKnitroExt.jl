module NLPModelsKnitroExt

using KNITRO, NLPModelsKnitro, JSOSuite
  JSOSuite.optimizers[JSOSuite.optimizers.name .== "KNITRO", :is_available] .= KNITRO.has_knitro()
  include("solvers/knitro_solve.jl")
end
