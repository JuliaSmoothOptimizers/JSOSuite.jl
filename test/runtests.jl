# this package
using JSOSuite

# JSO
using NLPModels

# stdlib
using LinearAlgebra, Test

function tests()
  nlp = ADNLPModel(x -> (x[1] - 1)^2 + 100 * (x[2] - x[1]^2)^2, [-1.2; 1.0])
  output = minimize(nlp)
  @test norm(output.solution .- 1) < 1e-8
  @test output.dual_feas < 1e-8
end

tests()
