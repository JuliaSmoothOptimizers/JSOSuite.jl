export multi_start

"""
    multi_start(nlp::AbstractNLPModel; kwargs...)

This function runs a simple optimization strategy that run local optimizers
 for several initial guesses.

# Arguments
- `nlp::AbstractNLPModel{T, V}` represents the model to solve, see `NLPModels.jl`.

The keyword arguments may include

- `multi_solvers::Bool = false`: If true it runs all the available solvers, one solver otherwise;
- `skip_solvers::Vector{String} = String[]`: If `multi_solvers` is true, the solvers in this list are skipped;
- `N::Integer = get_nvar(nlp)`: number of additional initial guesses considered;
- `max_time::Float64 = 60.0`: maximum time limit in seconds;
- `verbose::Integer = 0`: if > 0, display iteration details every `verbose` iteration.
- `solver_verbose::Integer = 0`: verbosity of the solver;
- `strategy::Symbol = :random`: strategy to compute a next initial guess in [:random].

Other keyword arguments are passed to the solvers.

"""
function multi_start end

function multi_start(
  nlp::AbstractNLPModel{T, S};
  multi_solvers::Bool = false,
  skip_solvers::Vector{String} = String[],
  N::Integer = get_nvar(nlp),
  max_time::Float64 = 60.0,
  verbose::Integer = 0,
  solver_verbose::Integer = 0,
  strategy::Symbol = :random,
  kwargs...,
) where {T, S}
  best_x = get_x0(nlp)
  dom = Vector{RealInterval{Float64}}(undef, get_nvar(nlp))
  new_x0, best_x = S(undef, get_nvar(nlp)), S(undef, get_nvar(nlp))
  for i in 1:get_nvar(nlp)
    dom[i] = RealInterval(nlp.meta.lvar[i], nlp.meta.uvar[i])
  end
  new_x0 .= get_x0(nlp)
  best_obj = obj(nlp, get_x0(nlp))
  best_x .= get_x0(nlp)

  # optimizers
  select = select_optimizers(nlp)
  if !multi_solvers
    solvers = first(select.name)
  else
    solvers = select.name
    @info solvers
    @info skip_solvers
    for skip in skip_solvers
      ind_skip = findfirst(x -> x == skip, solvers)
      if !isnothing(ind_skip)
        deleteat!(solvers, ind_skip)
      end
    end
  end
  @info solvers
  nsolvers = length(solvers)

  start_time = time()
  verbose > 0 && @info log_header(
    [:i, :f, :normx, :normx0, :status],
    [Int, T, T, T, Symbol],
    hdr_override = Dict(:f => "f(x)", :normx => "‖x‖", :normx0 => "‖x₀‖"),
  )
  best_obj = run_solver!(
    best_x,
    best_obj,
    solvers,
    nlp,
    new_x0,
    verbose,
    solver_verbose,
    max_time;
    kwargs...,
  )

  for i in 1:N
    get_next_x0!(Val(strategy), new_x0, i, dom, best_x)
    el_time = time() - start_time
    best_obj = run_solver!(
      best_x,
      best_obj,
      solvers,
      nlp,
      new_x0,
      verbose,
      solver_verbose,
      max_time - el_time;
      kwargs...,
    )
  end
  return best_x
end

function run_solver!(
  best_x,
  best_obj,
  solvers::Vector{String},
  nlp,
  new_x0,
  verbose,
  solver_verbose,
  max_time;
  kwargs...,
)
  for solver_name in solvers
    stats = minimize(solver_name, nlp; x = new_x0, verbose = solver_verbose, kwargs...)
    if (stats.status == :first_order) && (stats.objective < best_obj)
      best_obj = stats.objective
      best_x .= stats.solution
    end
    verbose > 0 && @info log_row(Any[0, best_obj, norm(best_x), norm(new_x0), stats.status])
  end
  return best_obj
end

function run_solver!(
  best_x,
  best_obj,
  solver_name::String,
  nlp,
  new_x0,
  verbose,
  solver_verbose,
  max_time;
  kwargs...,
)
  stats = minimize(solver_name, nlp; x = new_x0, verbose = solver_verbose, kwargs...)
  if (stats.status == :first_order) && (stats.objective < best_obj)
    best_obj = stats.objective
    best_x .= stats.solution
  end
  verbose > 0 && @info log_row(Any[0, best_obj, norm(best_x), norm(new_x0), stats.status])
  return best_obj
end

function Random.rand!(
  rng::AbstractRNG,
  next_x0::AbstractArray{T},
  dom::Vector{RealInterval{T}},
) where {T}
  # check that length(next_x0) == length(dom)
  for i in 1:length(next_x0)
    next_x0[i] = rand(rng, dom[i])
  end
  return next_x0
end

function get_next_x0!(
  ::Val{:random},
  new_x0::S,
  ::Integer,
  dom::Vector{RealInterval{T}},
  x::S,
  args...;
  random_seed::Integer = 1234,
  rng = Random.default_rng(random_seed),
) where {S, T}
  rand!(rng, new_x0, dom)
end
