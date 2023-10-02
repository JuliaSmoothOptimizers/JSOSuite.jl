# JSOSuite.jl

`JSOSuite` is a unique solution to access all the solvers available in the [JuliaSmoothOptimizers](https://github.com/JuliaSmoothOptimizers) organization.

All these solvers rely on the `NLPModel API` from [NLPModels.jl](https://github.com/JuliaSmoothOptimizers/NLPModels.jl) for general nonlinear optimization problems of the form

```math
\begin{aligned}
\min \quad & f(x) \\
& c_L \leq c(x) \leq c_U \\
& c_A \leq Ax \leq l_A, \\
& \ell \leq x \leq u.
\end{aligned}
```

The package `JSOSuite` exports a function [`minimize`](@ref):

```julia
output = minimize(args...; kwargs...)
```

where the arguments define the problem, see [Tutorial](@ref tutorial-section).

It is also possible to define an `NLPModel` or a `JuMP` model representing the problem, and then call `minimize`:

```julia
output = minimize(nlpmodel; kwargs...)
output = minimize(jump; kwargs...)
```

The `NLPModel API` is a general API for solvers to interact with models by providing flexible data types to represent the objective and constraint functions to evaluate their derivatives, and to provide essentially any information that a solver might request from a model. [JuliaSmoothOrganization's website jso.dev](https://jso.dev) or [NLPModels.jl's documentation](https://jso.dev/NLPModels.jl/dev/) provide more tutorials on this topic.

## NLPModel

JuliaSmoothOptimizers' compliant solvers accept any model compatible with the `NLPModel API`. See the [Tutorial](@ref tutorial-section) section for examples.

Depending on the origin of the problem several modeling tools are available. The following generic modeling tools are accepted:

- `JuMP` models are internally made compatible with NLPModel via [NLPModelsJuMP.jl](https://github.com/JuliaSmoothOptimizers/NLPModelsJuMP.jl);
- `Ampl` models stored in a `.nl` file can be instantiated with `AmplModel("name_of_file.nl")` using [AmplNLReader.jl](https://github.com/JuliaSmoothOptimizers/AmplNLReader.jl);
- [QPSReader.jl](https://github.com/JuliaSmoothOptimizers/QPSReader.jl) reads linear problems in MPS format and quadratic problems in QPS format;
- Models using automatic differentiation can be generated using [ADNLPModels.jl](https://github.com/JuliaSmoothOptimizers/ADNLPModels.jl);
- Models with manually input derivatives can be defined using [ManualNLPModels.jl](https://github.com/JuliaSmoothOptimizers/ManualNLPModels.jl).

It is also possible to define your `NLPModel` variant. Several examples are available within JuliaSmoothOptimizers' umbrella:

- [KnetNLPModels.jl](https://github.com/JuliaSmoothOptimizers/KnetNLPModels.jl): An NLPModels Interface to Knet.
- [PDENLPModels.jl](https://github.com/JuliaSmoothOptimizers/PDENLPModels.jl): A NLPModel API for optimization problems with PDE-constraints.

A nonlinear least squares problem is a special case with the objective function defined as  ``f(x) = \tfrac{1}{2}\|F(x)\|^2_2``.
Although the problem can be solved using only  ``f``, knowing  ``F`` independently allows the development of more efficient methods.
See the [Nonlinear Least Squares](@ref nls-section) for more on the special treatment of these problems.

## Output

The value returned is a [`GenericExecutionStats`](https://jso.dev/SolverCore.jl/dev/reference/#SolverCore.GenericExecutionStats), which is a structure containing the available information at the end of the execution, such as a solver status, the objective function value, the norm of the residuals, the elapsed time, etc.

It contains the following fields:

- `status`: Indicates the output of the solver. Use `show_statuses()` for the full list;
- `solution`: The final approximation returned by the solver (default: an uninitialized vector like `nlp.meta.x0`);
- `objective`: The objective value at `solution` (default: `Inf`);
- `dual_feas`: The dual feasibility norm at `solution` (default: `Inf`);
- `primal_feas`: The primal feasibility norm at `solution` (default: `0.0` if unconstrained, `Inf` otherwise);
- `multipliers`: The Lagrange multipliers wrt to the constraints (default: an uninitialized vector like `nlp.meta.y0`);
- `multipliers_L`: The Lagrange multipliers wrt to the lower bounds on the variables (default: an uninitialized vector like `nlp.meta.x0` if there are bounds, or a zero-length vector if not);
- `multipliers_U`: The Lagrange multipliers wrt to the upper bounds on the variables (default: an uninitialized vector like `nlp.meta.x0` if there are bounds, or a zero-length vector if not);
- `iter`: The number of iterations computed by the solver (default: `-1`);
- `elapsed_time`: The elapsed time computed by the solver (default: `Inf`);
- `solver_specific::Dict{Symbol,Any}`: A solver specific dictionary.

The list of statuses is available via the function `SolverCore.show_statuses`:

```@example
using SolverCore
show_statuses()
```

## Keyword Arguments

All the keyword arguments are passed to the selected solver.
Keywords available for all the solvers are given below:

- `atol::T = √eps(T)`: absolute tolerance;
- `rtol::T = √eps(T)`: relative tolerance;
- `max_time::Float64 = 300.0`: maximum number of seconds;
- `max_iter::Int = typemax(Int)`: maximum number of iterations;
- `max_eval::Int = 10 000`: maximum number of constraint and objective functions evaluations;
- `callback = (args...) -> nothing`: callback called at each iteration;
- `verbose::Int = 0`: if > 0, display iteration details for every `verbose` iteration.

The expected signature of the callback is `callback(nlp, solver, stats)`, and its output is ignored.
Changing any of the input arguments will affect the subsequent iterations.
In particular, setting `stats.status = :user` will stop the algorithm.
All relevant information should be available in `nlp` and `solver`.

The following are specific to nonlinear least squares:

- `Fatol::T = √eps(T)`: absolute tolerance on the residual;
- `Frtol::T = eps(T)`: relative tolerance on the residual, the algorithm stops when ‖F(xᵏ)‖ ≤ Fatol + Frtol * ‖F(x⁰)‖.

Further possible options are documented in each solver's documentation.

## Installation

```julia-pkg
pkg> add JSOSuite
```

## Table of Contents

```@contents
```

## Bug reports and discussions

If you think you found a bug, feel free to open an [issue](https://github.com/JuliaSmoothOptimizers/JSOSuite.jl/issues).
Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.

If you want to ask a question not suited for a bug report, feel free to start a discussion [here](https://github.com/JuliaSmoothOptimizers/Organization/discussions). This forum is for general discussion about this repository and the [JuliaSmoothOptimizers](https://github.com/JuliaSmoothOptimizers), so questions about any of our packages are welcome.
