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

function solve(
  c::S,
  Hrows::AbstractVector{<:Integer},
  Hcols::AbstractVector{<:Integer},
  Hvals::S;
  Arows::AbstractVector{<:Integer} = Int[],
  Acols::AbstractVector{<:Integer} = Int[],
  Avals::S = S(undef, 0),
  lcon::S = S(undef, 0),
  ucon::S = S(undef, 0),
  lvar::S = fill!(S(undef, length(c)), eltype(c)(-Inf)),
  uvar::S = fill!(S(undef, length(c)), eltype(c)(Inf)),
  c0::T = zero(eltype(c)),
  sortcols::Bool = false,
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, Hrows, Hcols, Hvals, Arows = Arows, Acols = Acols, Avals = Avals, lcon = lcon, ucon = ucon, lvar = lvar, uvar = uvar, c0 = c0, sortcols = sortcols, x0 = x0, name = name)
  return solve(qp_model; kwargs...)
end

function solve(
  solver_name::String,
  c::S,
  Hrows::AbstractVector{<:Integer},
  Hcols::AbstractVector{<:Integer},
  Hvals::S;
  Arows::AbstractVector{<:Integer} = Int[],
  Acols::AbstractVector{<:Integer} = Int[],
  Avals::S = S(undef, 0),
  lcon::S = S(undef, 0),
  ucon::S = S(undef, 0),
  lvar::S = fill!(S(undef, length(c)), eltype(c)(-Inf)),
  uvar::S = fill!(S(undef, length(c)), eltype(c)(Inf)),
  c0::T = zero(eltype(c)),
  sortcols::Bool = false,
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, Hrows, Hcols, Hvals, Arows = Arows, Acols = Acols, Avals = Avals, lcon = lcon, ucon = ucon, lvar = lvar, uvar = uvar, c0 = c0, sortcols = sortcols, x0 = x0, name = name)
  return solve(solver_name, qp_model; kwargs...)
end

function solve(
  c::S,
  H::Union{AbstractMatrix{T}, AbstractLinearOperator{T}};
  A::Union{AbstractMatrix, AbstractLinearOperator} = similar(c, 0, length(c)),
  lcon::S = S(undef, 0),
  ucon::S = S(undef, 0),
  lvar::S = fill!(S(undef, length(c)), T(-Inf)),
  uvar::S = fill!(S(undef, length(c)), T(Inf)),
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, H, A = A, lcon = lcon, ucon = ucon, lvar = lvar, uvar = uvar, c0 = c0, x0 = x0, name = name)
  return solve(qp_model; kwargs...)
end

function solve(
  solver_name::String,
  c::S,
  H::Union{AbstractMatrix{T}, AbstractLinearOperator{T}};
  A::Union{AbstractMatrix, AbstractLinearOperator} = similar(c, 0, length(c)),
  lcon::S = S(undef, 0),
  ucon::S = S(undef, 0),
  lvar::S = fill!(S(undef, length(c)), T(-Inf)),
  uvar::S = fill!(S(undef, length(c)), T(Inf)),
  c0::T = zero(T),
  x0 = fill!(S(undef, length(c)), zero(T)),
  name::String = "Generic",
  kwargs...,
) where {T, S <: AbstractVector{T}}
  qp_model = QuadraticModel(c, H, A = A, lcon = lcon, ucon = ucon, lvar = lvar, uvar = uvar, c0 = c0, x0 = x0, name = name)
  return solve(solver_name, qp_model; kwargs...)
end
