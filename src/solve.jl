function solve(
  nlp::AbstractNLPModel;
  verbose = 1,
  highest_derivative_available::Integer = 2,
  kwargs...,
)
  select = select_solvers(nlp, verbose, highest_derivative_available)
  (verbose ≥ 1) && println("Solve using $(first(select).name):")
  solver = first(select)
  return solve(Val(Symbol(solver.name)), nlp; verbose = verbose, kwargs...)
end

function solve(
  nlp::AbstractNLSModel;
  verbose = 1,
  highest_derivative_available::Integer = 2,
  kwargs...,
)
  select = select_solvers(nlp, verbose, highest_derivative_available)
  nls_select = select[select.specialized_nls, :]
  solver = if !isempty(nls_select)
    first(nls_select)
  else
    first(select)
  end
  (verbose ≥ 1) && println("Solve using $(solver.name):")
  return solve(Val(Symbol(solver.name)), nlp; verbose = verbose, kwargs...)
end

function solve(solver_name::String, nlp; kwargs...)
  solver = solvers[solvers.name .== solver_name, :]
  if isempty(solver)
    @warn "$(solver_name) does not exist."
    return GenericExecutionStats(nlp)
  end
  return solve(Val(Symbol(solver_name)), nlp; kwargs...)
end

function throw_error_solve(solver::Symbol)
  solver_pkg = solvers[solvers.name .== string(solver), :name_pkg]
  if isempty(solver_pkg)
    str = "$solver does not exist."
  else
    solver_pkg = replace(solver_pkg[1], ".jl" => "")
    str = "$solver solver package needs to be loaded, please run `using $(solver_pkg)`."
  end
  return throw(ArgumentError(str))
end

function solve(::Val{solver_name}, nlp; kwargs...) where {solver_name}
  solver = solvers[solvers.name .== string(solver_name), :]
  if !is_available(solver_name)
    throw_error_solve(solver_name)
  end
  return eval(solver.solve_function[1])(nlp; kwargs...)
end

function is_available(solver::Symbol)
  solver_isa = solvers[solvers.name .== string(solver), :is_available]
  if solver_isa == []
    return false
  end
  return solver_isa[1]
end
