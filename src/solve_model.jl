function solve(f::Function, x0::AbstractVector, args...; kwargs...)
  nlp = ADNLPModel(f, x0, args...)
  return solve(nlp; kwargs...)
end

function solve(solver_name::String, f::Function, x0::AbstractVector, args...; kwargs...)
  nlp = ADNLPModel(f, x0, args...)
  return solve(solver_name, nlp; kwargs...)
end

function solve(F::Function, x0::AbstractVector, nequ::Integer, args...; kwargs...)
  nlp = ADNLSModel(F, x0, nequ, args...)
  return solve(nlp; kwargs...)
end

function solve(
  solver_name::String,
  F::Function,
  x0::AbstractVector,
  nequ::Integer,
  args...;
  kwargs...,
)
  nlp = ADNLSModel(F, x0, nequ, args...)
  return solve(solver_name, nlp; kwargs...)
end

function solve(model::JuMP.Model, args...; kwargs...)
  nlp = MathOptNLPModel(model)
  return solve(nlp, args...; kwargs...)
end

function solve(solver_name::String, model::JuMP.Model, args...; kwargs...)
  nlp = MathOptNLPModel(model)
  return solve(solver_name, nlp, args...; kwargs...)
end

function solve(solver::Val{solver_name}, model::JuMP.Model, args...; kwargs...) where {solver_name}
  nlp = MathOptNLPModel(model)
  return solve(solver, nlp, args...; kwargs...)
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

function solve(
  c::S,
  args...;
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, args...; c0 = c0, x0 = x0, name = name)
  return solve(qp_model; kwargs...)
end

function solve(
  solver_name::String,
  c::S,
  args...;
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, args...; c0 = c0, x0 = x0, name = name)
  return solve(solver_name, qp_model; kwargs...)
end
