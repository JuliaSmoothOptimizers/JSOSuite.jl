# Benchmarking optimizers

Benchmarking is very important when researching new algorithms or selecting the most approriate ones.

The package [`SolverBenchmark`](https://github.com/JuliaSmoothOptimizers/SolverBenchmark.jl) exports the function [`bmark_solvers`](https://github.com/JuliaSmoothOptimizers/SolverBenchmark.jl/blob/main/src/bmark_solvers.jl) that runs a set of optimizers on a set of problems. `JSOSuite.jl` specialize this function, see `bmark_solvers`.

The [JuliaSmoothOptimizers organization](https://jso.dev) contains several packages of test problems ready to use for benchmarking. The main ones are

- [`OptimizationProblems.jl`](https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl): This package provides a collection of optimization problems in JuMP and ADNLPModels syntax;
- [`CUTEst.jl`](https://github.com/JuliaSmoothOptimizers/CUTEst.jl);
- [`NLSProblems.jl`](https://github.com/JuliaSmoothOptimizers/NLSProblems.jl).

In this tutorial, we will use [`OptimizationProblems.jl`](https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl) with automatic differentiation.

## Benchmark with OptimizationProblems.jl

```@example op
using ADNLPModels, OptimizationProblems, JSOSuite
```

The package [`OptimizationProblems.jl`](https://github.com/JuliaSmoothOptimizers/OptimizationProblems.jl) provides a `meta` containing all the problem information.
It is possible to then select the problems without evaluating them first.

```@example op
selected_meta = OptimizationProblems.meta
selected_meta = selected_meta[(selected_meta.nvar .< 200), :] # choose problem with <200 variables.
selected_meta = selected_meta[.!selected_meta.has_bounds .&& (selected_meta.ncon .== 0), :]; # unconstrained problems
list = selected_meta[!, :name]
```

Then, we generate the list of problems using [`ADNLPModel`](https://jso.dev/ADNLPModels.jl/dev/reference/).

```@example op
ad_problems = [
  OptimizationProblems.ADNLPProblems.eval(Meta.parse(problem))() for problem ∈ list
]
length(ad_problems) # return the number of problems
```

We now want to select appropriate optimizers using the `JSOSuite.optimizers`.

```@example op
using NLPModelsIpopt
selected_optimizers = JSOSuite.optimizers
# optimizers can solve general `nlp` as some are specific to variants (NLS, ...)
selected_optimizers = selected_optimizers[selected_optimizers.can_solve_nlp, :]
selected_optimizers[selected_optimizers.is_available, :] # optimizers available
```

For the purpose of this example, we will consider 3 optimizers.

```@example op
select = ["IPOPT", "TRUNK", "LBFGS"]
```

Once the problems and optimizers are chosen, the function `bmark_solvers` runs the benchmark.

```@example op
using SolverBenchmark
stats = bmark_solvers(ad_problems, select, atol = 1e-3, max_time = 10.0, verbose = 0)
```

Finally, the result can be processed. For instance, we show here performance profiles comparing the elapsed time and the number of evaluations.

```@example op
first_order(df) = df.status .== :first_order
unbounded(df) = df.status .== :unbounded
solved(df) = first_order(df) .| unbounded(df)
costnames = ["time", "obj + grad + hess"]
costs = [
  df -> .!solved(df) .* Inf .+ df.elapsed_time,
  df -> .!solved(df) .* Inf .+ df.neval_obj .+ df.neval_grad,
]

using Plots, SolverBenchmark
gr()

profile_solvers(stats, costs, costnames)
```

Note that there are fundamental differences between these optimizers as highlighted in the following.

```@example op
for solver in ["IPOPT", "TRUNK", "LBFGS"]
  println("$solver evaluations:")
  a, b, c, d = eachcol(
    stats[Symbol(solver)][!, [:neval_obj, :neval_grad, :neval_hess, :neval_hprod]]
  )
  println(
    "neval_obj: $(sum(a)),  neval_grad: $(sum(b)), neval_hess: $(sum(c)), neval_hprod: $(sum(d))."
  )
end
```
