# this package
using JSOSuite

# stdlib
using LinearAlgebra, SparseArrays, Test

# others
using JuMP, NLPModelsJuMP

# JSO
using ADNLPModels, NLPModels, NLSProblems, QuadraticModels, OptimizationProblems, SparseMatricesCOO
using JSOSolvers, Percival, SolverCore

meta = OptimizationProblems.meta

using ExpressionTreeForge

include("parse-function-test.jl")

@testset "Test loading parameter set" for paramset in JSOSuite.optimizers[!, :name_parameters]
  pkg_name = JSOSuite.optimizers[JSOSuite.optimizers.name_parameters .== paramset, :name_pkg][1]
  pkg_name = replace(pkg_name, ".jl" => "")
  if paramset != :not_implemented
    @test !isnothing(eval(Meta.parse(pkg_name * ".$paramset")))
  end
end

@testset "Test not loaded solvers" begin
  nlp = ADNLPModel(x -> sum(x), ones(2))

  @test_throws ArgumentError minimize("CaNNOLeS", nlp)
  @test_throws ArgumentError minimize("DCISolver", nlp)
  @test_throws ArgumentError minimize("FletcherPenaltySolver", nlp)
  @test_throws ArgumentError minimize("IPOPT", nlp)
  @test_throws ArgumentError minimize("KNITRO", nlp)
  @test_throws ArgumentError minimize("RipQP", nlp)
end

# optionals
using KNITRO
if KNITRO.has_knitro()
  using NLPModelsKnitro
end
using CaNNOLeS, DCISolver, FletcherPenaltySolver, NLPModelsIpopt, RipQP
using SolverBenchmark

function test_in_place_solve(nlp, solver_name)
  pkg_name = JSOSuite.optimizers[JSOSuite.optimizers.name_solver .== solver_name, :name_pkg][1]
  pkg_name = replace(pkg_name, ".jl" => "")
  solver = eval(Meta.parse(pkg_name * ".$solver_name"))(nlp)
  stats = solve!(solver, nlp)
  @test stats.status == :first_order
  reset!(solver, nlp)
  stats = GenericExecutionStats(nlp)
  solve!(solver, nlp, stats)
  @test stats.status == :first_order
end

function test_in_place_solve(model::JuMP.Model, solver_name)
  nlp = MathOptNLPModel(model)
  pkg_name = JSOSuite.optimizers[JSOSuite.optimizers.name_solver .== solver_name, :name_pkg][1]
  pkg_name = replace(pkg_name, ".jl" => "")
  solver = eval(Meta.parse(pkg_name * ".$solver_name"))(nlp)
  stats = solve!(solver, model)
  @test stats.status == :first_order
  reset!(solver, nlp)
  stats = GenericExecutionStats(nlp)
  solve!(solver, model, stats)
  @test stats.status == :first_order
end

@testset "Test in-place solve!" begin
  nlp = OptimizationProblems.ADNLPProblems.arglina()
  model = OptimizationProblems.PureJuMP.arglina()
  @testset "Test $solver_name" for solver_name in JSOSuite.optimizers[!, :name_solver]
    solver_name == :DCIWorkspace && continue
    solver_name == :RipQPSolver && continue
    is_available =
      JSOSuite.optimizers[JSOSuite.optimizers.name_solver .== solver_name, :is_available]
    can_solve_nlp =
      JSOSuite.optimizers[JSOSuite.optimizers.name_solver .== solver_name, :can_solve_nlp]
    spec_nls =
      JSOSuite.optimizers[JSOSuite.optimizers.name_solver .== solver_name, :specialized_nls]
    if is_available[1] && can_solve_nlp[1]
      test_in_place_solve(nlp, solver_name)
      test_in_place_solve(model, solver_name)
    elseif is_available[1] && spec_nls[1] # NLS
      nls = OptimizationProblems.ADNLPProblems.arglina(; use_nls = true)
      test_in_place_solve(nls, solver_name)
    elseif is_available[1] # RipQP
      nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
      test_in_place_solve(nlp_qm, solver_name)
    end
  end
end

include("qp_tests.jl")

@testset "Test `Float32`" begin
  nlp = OptimizationProblems.ADNLPProblems.genrose(; type = Float32)
  atol, rtol = √eps(Float32), √eps(Float32)
  for solver in eachrow(JSOSuite.select_optimizers(nlp))
    if solver.nonlinear_obj
      minimize(solver.name, nlp; verbose = 0, atol = atol, rtol = rtol)
      @test true
    else
      nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
      minimize(solver.name, nlp_qm; verbose = 0, atol = atol, rtol = rtol)
      @test true
    end
  end
end

@testset "JSOSuite JuMP API" begin
  model = OptimizationProblems.PureJuMP.genrose()
  jum = MathOptNLPModel(model)
  @test JSOSuite.select_optimizers(model) == JSOSuite.select_optimizers(jum)
  for solver in eachrow(JSOSuite.select_optimizers(model))
    minimize(solver.name, model; verbose = 0)
    @test true
  end
end

@testset "Benchmark on unconstrained problems" begin
  ad_problems = [
    OptimizationProblems.ADNLPProblems.eval(Meta.parse(problem))() for problem in
    first(meta[(5 .<= meta.nvar .<= 10) .& (meta.ncon .== 0) .& (.!meta.has_bounds), :name], 5)
  ]
  select = JSOSuite.optimizers[
    JSOSuite.optimizers.can_solve_nlp .& JSOSuite.optimizers.is_available,
    :name,
  ]
  stats = bmark_solvers(ad_problems, select; atol = 1e-3, max_time = 10.0, verbose = 0)
  @test true # just test that it runs
end

@testset "Basic solve tests" begin
  f = x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
  stats = minimize(f, [-1.2; 1.0]; verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)

  stats = minimize("DCISolver", f, [-1.2; 1.0]; verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)

  F = x -> [10 * (x[2] - x[1]^2); x[1] - 1]
  stats = minimize(F, [-1.2; 1.0], 2; verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)

  stats = minimize("DCISolver", F, [-1.2; 1.0], 2; verbose = 0)
  @test stats.status_reliable && (stats.status == :first_order)
end

@testset "Test solve OptimizationProblems: $name" for name in first(meta[meta.nvar .< 10, :name], 5)
  name in ["bennett5", "channel", "hs253", "hs73", "misra1c"] && continue
  nlp = OptimizationProblems.ADNLPProblems.eval(Meta.parse(name))()
  minimize(nlp; verbose = 0)
  @test true
  model = OptimizationProblems.PureJuMP.eval(Meta.parse(name))()
  minimize(model; verbose = 0)
  @test true
end

@testset "Test feasible" begin
  nlp = OptimizationProblems.ADNLPProblems.lincon()
  feasible_point(nlp)

  nlp = OptimizationProblems.PureJuMP.lincon()
  feasible_point(nlp)
end

for solver in eachrow(JSOSuite.optimizers)
  nlp = mgh17()
  @testset "Test options in $(solver.name)" begin
    # We just test that the solver runs with the options
    if solver.is_available
      if solver.nonlinear_obj
        minimize(
          solver.name,
          nlp;
          atol = 1e-5,
          rtol = 1e-5,
          max_time = 12.0,
          max_eval = 10,
          verbose = 0,
        )
        @test true
      else
        nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
        minimize(
          solver.name,
          nlp_qm;
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

@testset "Test kwargs in optimizers on $model" for model in (:arglina, :hs6)
  nlp = OptimizationProblems.ADNLPProblems.eval(model)()
  nls = OptimizationProblems.ADNLPProblems.eval(model)(; use_nls = true)
  callback = (args...) -> nothing
  for solver in eachrow(JSOSuite.optimizers)
    @testset "Test options in $(solver.name)" begin
      solver.is_available || continue
      ((nlp.meta.ncon > 0) && (!solver.equalities)) && continue
      # We just test that the solver runs with the options
      if solver.can_solve_nlp
        minimize(
          solver.name,
          nlp;
          atol = 1e-5,
          rtol = 1e-5,
          max_time = 12.0,
          max_iter = 100,
          max_eval = 10,
          callback = callback,
          verbose = 0,
        )
        @test true
      elseif solver.specialized_nls
        minimize(
          solver.name,
          nls;
          atol = 1e-5,
          rtol = 1e-5,
          Fatol = 1e-5,
          Frtol = 1e-5,
          max_time = 12.0,
          max_iter = 100,
          max_eval = 10,
          callback = callback,
          verbose = 0,
        )
        @test true
      else # RipQP
        nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
        minimize(
          solver.name,
          nlp_qm;
          atol = 1e-5,
          rtol = 1e-5,
          max_time = 12.0,
          max_iter = 100,
          max_eval = 10,
          callback = callback,
          verbose = 0,
        )
        @test true
      end
    end
  end
end
