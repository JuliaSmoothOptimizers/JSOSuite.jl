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

The optimizer can be chosen as follows.

    stats = minimize(optimizer_name::String, args...; kwargs...)

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

"""
    solve!(solver::AbstractOptimizationSolver, model::Union{AbstractNLPModel, JuMP.Model}; kwargs...)
    solve!(solver::AbstractOptimizationSolver, model::Union{AbstractNLPModel, JuMP.Model}, stats; kwargs...)

`JSOSuite` extension of `SolverCore.solve!`.
The first argument should be of type `SolverCore.AbstractOptimizationSolver`, see for instance `JSOSuite.optimizers[!, :name_solver]`.
"""
function SolverCore.solve!(solver, args...; kwargs...)
  throw(
    "solve! not implemented first argument should be of type `SolverCore.AbstractOptimizationSolver` and not $(typeof(solver)), see for instance `JSOSuite.optimizers[!, :name_solver]`.",
  )
end

function minimize(f::Function, x0::AbstractVector, args...; kwargs...)
  nlp = ADNLPModel(f, x0, args...)
  return minimize(nlp; kwargs...)
end

function minimize(solver_name::String, f::Function, x0::AbstractVector, args...; kwargs...)
  nlp = ADNLPModel(f, x0, args...)
  return minimize(solver_name, nlp; kwargs...)
end

function minimize(F::Function, x0::AbstractVector, nequ::Integer, args...; kwargs...)
  nlp = ADNLSModel(F, x0, nequ, args...)
  return minimize(nlp; kwargs...)
end

function minimize(
  solver_name::String,
  F::Function,
  x0::AbstractVector,
  nequ::Integer,
  args...;
  kwargs...,
)
  nlp = ADNLSModel(F, x0, nequ, args...)
  return minimize(solver_name, nlp; kwargs...)
end

function minimize(model::JuMP.Model, args...; kwargs...)
  nlp = MathOptNLPModel(model)
  return minimize(nlp, args...; kwargs...)
end

function minimize(solver_name::String, model::JuMP.Model, args...; kwargs...)
  nlp = MathOptNLPModel(model)
  return minimize(solver_name, nlp, args...; kwargs...)
end

function minimize(
  solver::Val{solver_name},
  model::JuMP.Model,
  args...;
  kwargs...,
) where {solver_name}
  nlp = MathOptNLPModel(model)
  return minimize(solver, nlp, args...; kwargs...)
end

# TODO: Add AbstractOptimizationSolver constructors with JuMP model.
function SolverCore.solve!(
  solver::SolverCore.AbstractOptimizationSolver,
  model::JuMP.Model,
  args...;
  kwargs...,
)
  nlp = MathOptNLPModel(model)
  return SolverCore.solve!(solver, nlp, args...; kwargs...)
end

function QuadraticModel(
  c::S,
  H::Union{AbstractMatrix{T}, AbstractLinearOperator{T}},
  lvar::S,
  uvar::S;
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
) where {T, S <: AbstractVector{T}}
  return QuadraticModel(c, H, lvar = lvar, uvar = uvar, c0 = c0, x0 = x0, name = name)
end

function QuadraticModel(
  c::S,
  H::Union{AbstractMatrix{T}, AbstractLinearOperator{T}},
  A::Union{AbstractMatrix, AbstractLinearOperator},
  lcon::S,
  ucon::S;
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
) where {T, S <: AbstractVector{T}}
  return QuadraticModel(c, H, A = A, lcon = lcon, ucon = ucon, c0 = c0, x0 = x0, name = name)
end

function QuadraticModel(
  c::S,
  H::Union{AbstractMatrix{T}, AbstractLinearOperator{T}},
  lvar::S,
  uvar::S,
  A::Union{AbstractMatrix, AbstractLinearOperator},
  lcon::S,
  ucon::S;
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
) where {T, S <: AbstractVector{T}}
  return QuadraticModel(
    c,
    H,
    A = A,
    lcon = lcon,
    ucon = ucon,
    lvar = lvar,
    uvar = uvar,
    c0 = c0,
    x0 = x0,
    name = name,
  )
end

function minimize(
  c::S,
  args...;
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, args...; c0 = c0, x0 = x0, name = name)
  return minimize(qp_model; kwargs...)
end

function minimize(
  solver_name::String,
  c::S,
  args...;
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, args...; c0 = c0, x0 = x0, name = name)
  return minimize(solver_name, qp_model; kwargs...)
end
