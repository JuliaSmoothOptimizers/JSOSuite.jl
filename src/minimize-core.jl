export minimize, solve!

"""
    stats = minimize(f, x0; kwargs...)
    stats = minimize(f, x0, lvar, uvar; kwargs...)
    stats = minimize(f, x0, c, lcon, ucon; kwargs...)
    stats = minimize(f, x0, lvar, uvar, c, lcon, ucon; kwargs...)

    stats = minimize(nlp; kwargs...)

    stats = minimize(solver, ...; kwargs...)

Compute a local minimum of an optimization problem.
Check the arguments section below to see how to define the optimization problem.

## Arguments

- `f`: The objective function. It should receive a vector and return a value.
  By default, the derivatives of this function will be obtained by automatic differentiation.
- `x0`: The starting point for the optimization method.
- `lvar`: Lower bounds for the variables. Should have the same length as `x0`.
- `uvar`: Upper bounds for the variables. Should have the same length as `x0`.
- `c`: Constraints function. Should return an array with the length of `lcon` and `ucon`.
- `lcon`: Lower bounds for the constraints. Should have the same length as `c(x)` and `ucon`.
- `ucon`: Upper bounds for the constraints. Should have the same length as `c(x)` and `lcon`.
- `nlp`: Any AbstractNLPModel.
- `solver`: If not provided, JSOSuite will decide which solver to use based on characteristics
  of the problem. To override this, pass the solver as first argument:


  The list of loaded solvers can be obtained using [`get_loaded_optimizers()`](@ref).

## Keyword Arguments

All the keyword arguments are passed to the selected solver.
The most common keywords available for all the solvers are given below:

- `atol`: absolute tolerance for the stopping criteria based on the gradient norm.
- `rtol`: relative tolerance for the stopping criteria based on the gradient norm.
  The stopping based on the gradient norm if `‖∇f(xₖ)‖ ≤ atol + rtol * ‖∇f(x₀)‖`.
- `max_time`: maximum elapsed time in seconds.
- `max_iter`: maximum number of iterations.
- `max_eval`: maximum number of cons + obj evaluations.
- `callback = (args...) -> nothing`: callback called at each iteration.
- `verbose::Int = 0`: if > 0, display iteration details every `verbose` iteration.

Further possible options are documented in each solver's documentation.

## Callback

The callback is called at the end of each iteration.
The expected signature of the callback is `callback(nlp, solver, stats)`, and its output is ignored.
Changing any of the input arguments will affect the subsequent iterations.
In particular, setting `stats.status = :user` will stop the algorithm.
All relevant information should be available in `nlp` and `solver`.

## Output

The value returned is a `GenericExecutionStats`. See `SolverCore.jl` for more information.

## Examples

```julia
using JSOSuite

f(x) = 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
stats = minimize(f, x0, verbose = true)
```

```julia
using JSOSuite

f(x) = 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2
x0 = [-1.2; 1.0]
stats = minimize(TrunkSolver(), f, x0, verbose = true)
```
"""
function minimize end

function minimize(::Type{T}, nlp; kwargs...) where {T <: SolverCore.AbstractOptimizationSolver}
  return minimize(SolverShell{T}(), nlp; kwargs...)
end

function minimize(::SolverShell{Solver}, nlp; solver_kwargs = Dict(), kwargs...) where {Solver}
  solver = Solver(nlp; solver_kwargs...)
  return solve!(solver, nlp; kwargs...)
end
