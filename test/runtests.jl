# this package
using JSOSuite

# others
using JuMP, NLPModelsJuMP

using KNITRO
if KNITRO.has_knitro()
  using NLPModelsKnitro
end

# JSO
using ADNLPModels, NLPModels, NLSProblems, QuadraticModels, OptimizationProblems, SparseMatricesCOO
using CaNNOLeS,
  DCISolver, FletcherPenaltySolver, JSOSolvers, NLPModelsIpopt, Percival, RipQP, SolverCore

meta = OptimizationProblems.meta

# stdlib
using LinearAlgebra, SparseArrays, Test

function test_in_place_solve(nlp, solver_name)
  pkg_name = JSOSuite.solvers[JSOSuite.solvers.name_solver .== solver_name, :name_pkg][1]
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
  pkg_name = JSOSuite.solvers[JSOSuite.solvers.name_solver .== solver_name, :name_pkg][1]
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
  @testset "Test $solver_name" for solver_name in JSOSuite.solvers[!, :name_solver]
    solver_name == :DCIWorkspace && continue
    solver_name == :RipQPSolver && continue
    is_available = JSOSuite.solvers[JSOSuite.solvers.name_solver .== solver_name, :is_available]
    can_solve_nlp = JSOSuite.solvers[JSOSuite.solvers.name_solver .== solver_name, :can_solve_nlp]
    spec_nls = JSOSuite.solvers[JSOSuite.solvers.name_solver .== solver_name, :specialized_nls]
    if is_available[1] && can_solve_nlp[1]
      test_in_place_solve(nlp, solver_name)
      test_in_place_solve(model, solver_name)
    elseif is_available[1] && spec_nls[1] # NLS
      nls = OptimizationProblems.ADNLPProblems.arglina(use_nls = true)
      test_in_place_solve(nls, solver_name)
    elseif is_available[1] # RipQP
      nlp_qm = QuadraticModel(nlp, nlp.meta.x0)
      test_in_place_solve(nlp_qm, solver_name)
    end
  end
end

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

@testset "JSOSuite JuMP API" begin
  model = OptimizationProblems.PureJuMP.genrose()
  jum = MathOptNLPModel(model)
  @test JSOSuite.select_solvers(model) == JSOSuite.select_solvers(jum)
  for solver in eachrow(JSOSuite.select_solvers(model))
    solve(solver.name, model, verbose = 0)
    @test true
  end
end

@testset "Benchmark on unconstrained problems" begin
  ad_problems = [
    OptimizationProblems.ADNLPProblems.eval(Meta.parse(problem))() for
    problem ∈ meta[(5 .<= meta.nvar .<= 10) .& (meta.ncon .== 0) .& (.!meta.has_bounds), :name]
  ]
  select = JSOSuite.solvers[JSOSuite.solvers.can_solve_nlp .& JSOSuite.solvers.is_available, :name]
  stats = bmark_solvers(ad_problems, select, atol = 1e-3, max_time = 10.0, verbose = 0)
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

@testset "Test solve OptimizationProblems: $name" for name in meta[meta.nvar .< 100, :name]
  name in ["AMPGO13"] && continue # fix in OptimizationProblems.jl ≥ 0.7.2
  nlp = OptimizationProblems.ADNLPProblems.eval(Meta.parse(name))()
  solve(nlp, verbose = 0)
  @test true
  model = OptimizationProblems.PureJuMP.eval(Meta.parse(name))()
  solve(model, verbose = 0)
  @test true
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

@testset "Test kwargs in solvers on $model" for model in (:arglina, :hs6)
  nlp = OptimizationProblems.ADNLPProblems.eval(model)()
  nls = OptimizationProblems.ADNLPProblems.eval(model)(use_nls = true)
  callback = (args...) -> nothing
  for solver in eachrow(JSOSuite.solvers)
    @testset "Test options in $(solver.name)" begin
      solver.is_available || continue
      ((nlp.meta.ncon > 0) && (!solver.equalities)) && continue
      # We just test that the solver runs with the options
      if solver.can_solve_nlp
        solve(
          solver.name,
          nlp,
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
        solve(
          solver.name,
          nls,
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
        solve(
          solver.name,
          nlp_qm,
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
