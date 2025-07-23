using JSOSuite
using Test

# others
using JuMP, LinearAlgebra, SparseArrays

# JSO
using ADNLPModels, NLPModels, NLSProblems, QuadraticModels, OptimizationProblems, SparseMatricesCOO
using JSOSolvers, Percival, SolverCore, ExpressionTreeForge, NLPModelsJuMP, NLPModelsTest

#=
Don't add your tests to runtests.jl. Instead, create files named

    test-title-for-my-test.jl

The file will be automatically included inside a `@testset` with title "Title For My Test".
=#
for (root, dirs, files) in walkdir(@__DIR__)
  for file in files
    if isnothing(match(r"^test-.*\.jl$", file))
      continue
    end
    title = titlecase(replace(splitext(file[6:end])[1], "-" => " "))
    @testset "$title" begin
      include(file)
    end
  end
end
