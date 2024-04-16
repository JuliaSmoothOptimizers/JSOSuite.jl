# [Re-solve and in-place solve](@id resolve)

It is very convenient to pre-allocate the memory used during the optimization of a given problem either for improved memory management or re-solving the same or a similar problem.

Let us consider the following 2-dimensional unconstrained problem
```math
\begin{aligned}
\min_x \quad & f(x):= x₂² exp(x₁²) 
\end{aligned}
```
Using `JSOSuite`’s `minimize` function, the problem can be solved as follows
```@example ex1
using JSOSuite
f(x) = x[2]^2 * exp(x[1]^2)
x0 = ones(Float64, 2)
stats = minimize(f, x0)
```
Using L-BFGS, the problem is locally solved.

Note that when passing Julia functions as input to `minimize`, the problem is modeled as an [`ADNLPModel`](https://github.com/JuliaSmoothOptimizers/ADNLPModels.jl).
So, the following would be equivalent:
```@example ex2
using ADNLPModels, JSOSuite
f(x) = x[2]^2 * exp(x[1]^2)
x0 = ones(Float64, 2)
nlp = ADNLPModel(f, x0)
stats = minimize(nlp)
```

As an additional note, previous example (and the following) works for a `JuMP` model.
```@example 3
using JuMP, JSOSuite
model = Model()
@variable(model, x[i=1:2], start = [1.0; 1.0][i])
@objective(model, Min, x[2]^2 * exp(x[1]^2))
stats = minimize(model)
```

## In-place solve

If we want to solve the same problem several times, for instance, for several initial guesses, it is recommended to use an in-place solve.
```@example ex1
using ADNLPModels, JSOSolvers, SolverCore
f(x) = x[2]^2 * exp(x[1]^2)
x0 = ones(Float64, 2)
nlp = ADNLPModel(f, x0) # or use JuMP
solver = JSOSolvers.LBFGSSolver(nlp)
stats = SolverCore.GenericExecutionStats(nlp)
solve!(solver, nlp, stats, x = x0)
```
This deserves more explanations.
The name of the solver structure and the corresponding package can be accessed via the DataFrame `JSOSuite.optimizers`.
```@example ex1
JSOSuite.optimizers[!, [:name_solver, :name_pkg]]
```
In our example, the solver L-BFGS is implemented in [`JSOSolvers.jl`](https://github.com/JuliaSmoothOptimizers/JSOSolvers.jl) and the solver structure is `LBFGSSolver`.

Now, it is possible to reuse the memory allocated for the first solve for another round:
```@example ex1
# NLPModels.reset!(nlp) would also reset the evaluation counters of the model
SolverCore.reset!(solver)
new_x0 = [1.4; 5.0] # another initial guess
solve!(solver, nlp, stats, x = new_x0)  # new solve with existing solver object
```

## In-place solve of a different problem

It is also possible to reuse the allocated memory to solve another problem with the same number of variables and constraints:
```@example ex1
f2(x) = x[2]^2 + exp(x[1]^2)
x0 = ones(Float64, 2)
nlp = ADNLPModel(f2, x0) # or use JuMP
SolverCore.reset!(solver, nlp)
solve!(solver, nlp, stats)
```

## Allocation-free solvers

In order to measure, the amount of allocations made by the solvers the package [`NLPModelsTest.jl`](https://github.com/JuliaSmoothOptimizers/NLPModelsTest.jl) defines a set of test problems that are allocation-free.
```@example ex1
using NLPModelsTest, SolverCore, JSOSolvers
nlp = BROWNDEN(Float64)
solver = LBFGSSolver(nlp)
stats = GenericExecutionStats(nlp)
solve!(solver, nlp, stats)
@allocated solve!(solver, nlp, stats)
```
Several of the pure Julia solvers available in JSOSuite have this property.
