export minimize, solve!

"""
    stats = minimize(nlp::Union{AbstractNLPModel, JuMP.Model}; kwargs...)

Compute a local minimum of the optimization problem `nlp`.

    stats = minimize(f::Function, x0::AbstractVector, args...; kwargs...)
    stats = minimize(F::Function, x0::AbstractVector, nequ::Integer, args...; kwargs...)

Define an NLPModel using [`ADNLPModel`](https://juliasmoothoptimizers.github.io/ADNLPModels.jl/stable/).

    stats = minimize(c, H, c0 = c0, x0 = x0, name = name; kwargs...)
    stats = minimize(c, H, lvar, uvar, c0 = c0, x0 = x0, name = name; kwargs...)
    stats = minimize(c, H, A, lcon, ucon, c0 = c0, x0 = x0, name = name; kwargs...)
    stats = minimize(c, H, lvar, uvar, A, lcon, ucon, c0 = c0, x0 = x0, name = name; kwargs...)

Define a QuadraticModel using [`QuadraticModel`](https://juliasmoothoptimizers.github.io/QuadraticModels.jl/stable/).

The optimizer can be chosen by giving calling the solver empty constructor of type as the first argument:

    stats = minimize(LBFGSSolver, args...; kwargs...)
    stats = minimize(TrunkSolver(), args...; kwargs...)

`JuMP.Model` are converted in NLPModels via NLPModelsJuMP.jl.

If your optimization problem has a quadratic or linear objective and linear constraints consider using QuadraticModels.jl or LLSModels.jl for the model definition.

# Keyword Arguments

All the keyword arguments are passed to the selected solver.
Keywords available for all the solvers are given below:

- `atol`: absolute tolerance;
- `rtol`: relative tolerance;
- `max_time`: maximum number of seconds;
- `max_iter`: maximum number of iterations;
- `max_eval`: maximum number of cons + obj evaluations;
- `callback = (args...) -> nothing`: callback called at each iteration;
- `verbose::Int = 0`: if > 0, display iteration details every `verbose` iteration.

The following are specific to nonlinear least squares:

- `Fatol::T = √eps(T)`: absolute tolerance on the residual;
- `Frtol::T = eps(T)`: relative tolerance on the residual, the algorithm stops when ‖F(xᵏ)‖ ≤ Fatol + Frtol * ‖F(x⁰)‖.

Further possible options are documented in each solver's documentation.

## Callback

The callback is called at each iteration.
The expected signature of the callback is `callback(nlp, solver, stats)`, and its output is ignored.
Changing any of the input arguments will affect the subsequent iterations.
In particular, setting `stats.status = :user` will stop the algorithm.
All relevant information should be available in `nlp` and `solver`.

# Output

The value returned is a `GenericExecutionStats`, see `SolverCore.jl`.

# Examples
```jldoctest; output = false
using JSOSuite
stats = minimize(x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0], verbose = 0)
stats

# output

"Execution stats: first-order stationary"
```

The list of available solver can be obtained using `JSOSuite.optimizers[!, :name]` or see [`select_optimizers`](@ref).

```jldoctest; output = false
using JSOSuite
stats = minimize("TRON", x -> 100 * (x[2] - x[1]^2)^2 + (x[1] - 1)^2, [-1.2; 1.0], verbose = 0)
stats

# output

"Execution stats: first-order stationary"
```

Some optimizers are available after loading only.

```jldoctest; output = false
using JSOSuite
# We minimize here a quadratic problem with bound-constraints
c = [1.0; 1.0]
H = [-2.0 0.0; 3.0 4.0]
uvar = [1.0; 1.0]
lvar = [0.0; 0.0]
x0 = [0.5; 0.5]
stats = minimize("TRON", c, H, lvar, uvar, x0 = x0, name = "bndqp_QP", verbose = 0)
stats

# output

"Execution stats: first-order stationary"

```

"""
function minimize end

function minimize(
  nlp::AbstractNLPModel;
  verbose = 1,
  highest_derivative_available::Integer = 2,
  kwargs...,
)
  select = select_optimizers(nlp, verbose, highest_derivative_available)
  (verbose ≥ 1) && println("Solve using $(first(select).name):")
  solver = first(select)
  return minimize(Val(Symbol(solver.name)), nlp; verbose = verbose, kwargs...)
end

# function minimize(
#   nlp::AbstractNLSModel;
#   verbose = 1,
#   highest_derivative_available::Integer = 2,
#   kwargs...,
# )
#   select = select_optimizers(nlp, verbose, highest_derivative_available)
#   nls_select = select[select.specialized_nls, :]
#   solver = if !isempty(nls_select)
#     first(nls_select)
#   else
#     first(select)
#   end
#   (verbose ≥ 1) && println("Solve using $(solver.name):")
#   return minimize(Val(Symbol(solver.name)), nlp; verbose = verbose, kwargs...)
# end

# function throw_error_solve(solver::Symbol)
#   solver_pkg = optimizers[optimizers.name .== string(solver), :name_pkg]
#   if isempty(solver_pkg)
#     str = "$solver does not exist."
#   else
#     solver_pkg = replace(solver_pkg[1], ".jl" => "")
#     str = "$solver solver package needs to be loaded, please run `using $(solver_pkg)`."
#   end
#   return throw(ArgumentError(str))
# end

function minimize(::Type{T}, nlp; kwargs...) where {T <: SolverCore.AbstractOptimizationSolver}
  return minimize(SolverShell{T}(), nlp; kwargs...)
end

function minimize(::SolverShell{Solver}, nlp; solver_kwargs = Dict(), kwargs...) where {Solver}
  solver = Solver(nlp; solver_kwargs...)
  return solve!(solver, nlp; kwargs...)
end

# function is_available(solver::Symbol)
#   solver_isa = optimizers[optimizers.name .== string(solver), :is_available]
#   if solver_isa == []
#     return false
#   end
#   return solver_isa[1]
# end
