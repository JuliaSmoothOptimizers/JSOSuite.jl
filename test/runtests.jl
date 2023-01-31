# this package
using JSOSuite

# JSO
using ADNLPModels, NLPModels, NLSProblems, QuadraticModels, OptimizationProblems, SparseMatricesCOO

meta = OptimizationProblems.meta

# stdlib
using LinearAlgebra, SparseArrays, Test

include("qp_tests.jl")

@testset "Test `Float32`" begin
  nlp = OptimizationProblems.ADNLPProblems.genrose(type = Val(Float32))
  atol, rtol = √eps(Float32), √eps(Float32)
  for solver in eachrow(JSOSuite.select_solvers(nlp))
    if solver.nonlinear_obj
      solve(solver.name, nlp, verbose = 0, atol = atol, rtol = rtol)
      @test true
    else
      nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
      solve(solver.name, nlp_qm, verbose = 0, atol = atol, rtol = rtol)
      @test true
    end
  end
end

@testset "Benchmark on unconstrained problems" begin
  ad_problems = [
    OptimizationProblems.ADNLPProblems.eval(Meta.parse(problem))() for
    problem ∈ meta[(5 .<= meta.nvar .<= 10) .& (meta.contype .== :unconstrained), :name]
  ]
  select = JSOSuite.solvers[JSOSuite.solvers.can_solve_nlp, :name]
  stats = bmark_solvers(
    ad_problems,
    select,
    atol = 1e-3,
    max_time = 10.0,
    verbose = 0,
  )
  @test true # just test that it runs
end

@testset "Basic solve tests" begin
  f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
  stats = solve(f, [-1.2; 1.0], verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)

  stats = solve("DCISolver", f, [-1.2; 1.0], verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)

  F = x -> [10 * (x[2] - x[1]^2); x[1] - 1]
  stats = solve(F, [-1.2; 1.0], 2, verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)

  stats = solve("DCISolver", F, [-1.2; 1.0], 2, verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)
end

@testset "Test solve on OptimizationProblems" begin
  for name in meta[meta.nvar .< 100, :name]
    nlp = OptimizationProblems.ADNLPProblems.eval(Meta.parse(name))()
    solve(nlp, verbose = 0)
    @test true
    model = OptimizationProblems.PureJuMP.eval(Meta.parse(name))()
    solve(model, verbose = 0)
    @test true
  end
end

@testset "Test feasible" begin
  nlp = OptimizationProblems.ADNLPProblems.lincon()
  feasible_point(nlp)

  nlp = OptimizationProblems.PureJuMP.lincon()
  feasible_point(nlp)
end

for solver in eachrow(JSOSuite.solvers)
  nlp = mgh17()
  @testset "Test options in $(solver.name)" begin
    # We just test that the solver runs with the options
    if solver.is_available
      if solver.nonlinear_obj
        solve(
          solver.name,
          nlp,
          atol = 1e-5,
          rtol = 1e-5,
          max_time = 12.0,
          max_eval = 10,
          verbose = 0,
        )
        @test true
      else
        nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
        solve(
          solver.name,
          nlp_qm,
          atol = 1e-5,
          rtol = 1e-5,
          max_time = 12.0,
          max_eval = 10,
          verbose = 0,
        )
        @test true
      end
    end
  end
end

for solver in eachrow(JSOSuite.solvers)
  nlp = OptimizationProblems.ADNLPProblems.genrose()
  @testset "Test options in $(solver.name)" begin
    # We just test that the solver runs with the options
    if solver.is_available && solver.can_solve_nlp
      if solver.nonlinear_obj
        solve(
          solver.name,
          nlp,
          atol = 1e-5,
          rtol = 1e-5,
          max_time = 12.0,
          max_eval = 10,
          verbose = 0,
        )
        @test true
      else
        nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
        solve(
          solver.name,
          nlp_qm,
          atol = 1e-5,
          rtol = 1e-5,
          max_time = 12.0,
          max_eval = 10,
          verbose = 0,
        )
        @test true
      end
    end
  end
end
