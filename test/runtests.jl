# this package
using JSOSuite

# JSO
using ADNLPModels, NLPModels, OptimizationProblems

# stdlib
using LinearAlgebra, Test

meta = OptimizationProblems.meta
for name in meta[meta.nvar .< 100, :name]
  nlp = OptimizationProblems.ADNLPProblems.eval(Meta.parse(name))()
  solve(nlp)
end
