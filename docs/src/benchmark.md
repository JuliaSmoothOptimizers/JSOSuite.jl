# Benchmarking solvers

Benchmarking is very important when researching new algorithms or selecting the most approriate ones.

The package [`SolverBenchmark`](https://github.com/JuliaSmoothOptimizers/SolverBenchmark.jl) exports the function [`bmark_solvers`](https://github.com/JuliaSmoothOptimizers/SolverBenchmark.jl/blob/main/src/bmark_solvers.jl) that runs a set of solvers on a set of problems. `JSOSuite.jl` specialize this function, see [`bmark_solvers`](@ref).


The [JuliaSmoothOptimizers organization](https://juliasmoothoptimizers.github.io) contains several packages of test problems ready to use for benchmarking. The main ones are
- [`OptimizationProblems.jl`](https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl);
- [`CUTEst.jl`](https://github.com/JuliaSmoothOptimizers/CUTEst.jl);
- [`NLSProblems.jl`](https://github.com/JuliaSmoothOptimizers/CUTEst.jl).

## Benchmark with OptimizationProblems.jl

```@example op
using ADNLPModels, OptimizationProblems, JSOSuite
```

```@example op
selected_meta = OptimizationProblems.meta
selected_meta = selected_meta[(selected_meta.nvar .< 10) .&& (selected_meta.nvar .> 5), :]
# unconstrained
selected_meta = selected_meta[.!selected_meta.has_bounds .&& (selected_meta.ncon .== 0), :]
```

```@example op
ad_problems = [
  OptimizationProblems.ADNLPProblems.eval(Meta.parse(problem))() for problem ∈ selected_meta[!, :name]
]
length(ad_problems)
```

```@example op
select = JSOSuite.solvers[JSOSuite.solvers.can_solve_nlp, :name]
```

```@example op
stats = bmark_solvers(ad_problems, select, atol = 1e-3, max_time = 10.0, verbose = 0)
```

```@example op
first_order(df) = df.status .== :first_order
unbounded(df) = df.status .== :unbounded
solved(df) = first_order(df) .| unbounded(df)
costnames = ["time", "obj + grad + hess"]
costs = [
  df -> .!solved(df) .* Inf .+ df.elapsed_time,
  df -> .!solved(df) .* Inf .+ df.neval_obj .+ df.neval_grad .+ df.neval_hess,
]

using Plots, SolverBenchmark
gr()

profile_solvers(stats, costs, costnames)
```
